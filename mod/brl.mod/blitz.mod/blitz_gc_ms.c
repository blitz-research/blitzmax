
#include "blitz.h"

#ifdef BB_GC_MS

//#define DEBUG_GC

#define SIZEALIGN 16
#define ALIGNMASK (SIZEALIGN-1)

#define BBGC_MARKED 4
#define BBGC_LOCKED 8

#define PAGE_BITS 12
#define PAGE_SIZE (1<<PAGE_BITS)
#define PAGE_MASK ((PAGE_SIZE/4)-1)

typedef struct GCBlock GCBlock;

struct GCBlock{
	GCBlock *succ;
	int flags;		//low 4 bits - rest is size
	char data[0];
};

static int *pages[1<<(25-PAGE_BITS)];
static int pagesAlloced;

static GCBlock *usedBlocks;
static GCBlock *finalizedBlocks;

static char *freeBuf;
static int freeBufSize;
static GCBlock *freeBlocks[256];

static int gc_mode=BBGC_AUTOMATIC;
static int gc_debug;
static int gc_alloced;
static int gc_suspended;

static int n_global_vars;
static void ***global_vars;

static int n_alloced;

#ifdef _WIN32
extern void *_bss_start__;
extern void *_bss_end__;
extern void *_data_start__;
extern void *_data_end__;
extern void *_start_data__;
extern void *_stop_data__;
extern void *_end__;
#endif

#ifdef __linux
extern void *__data_start;
extern void *__bss_start;
extern void *_end;
#endif

static void **DATA_START;
static void **DATA_END;

static const char *typeName( void *p ){
	BBObject *o=(BBObject*)p;
	BBClass *c=o->clas;
	BBDebugScope *d=c->debug_scope;
	if( d ) return d->name;
	return "?";
}

/*
static void *getTIB(){
	void *tib;
	__asm__( "movl %%fs:0x18,%0":"=r"(tib) );
    return tib;
}

static int atomic_add( volatile int *p,int incr ){
	int result;

	__asm__ __volatile__ ("lock; xaddl %0, %1" :
			"=r" (result), "=m" (*p) : "0" (incr), "m" (*p)
			: "memory");

	return result;
}

static int compare_and_swap( volatile int *addr,int old,int new_val ){
	char result;

	__asm__ __volatile__("lock; cmpxchgl %3, %0; setz %1"
			: "=m"(*addr), "=q"(result)
			: "m"(*addr), "r" (new_val), "a"(old) : "memory");

	return (int) result;
}
*/

static void gcError( void *p,const char *msg ){
	printf( "GC ERROR: %s, object=$%p\n",msg,p );
	fflush( stdout );	
	bbExThrowCString( msg );
}

static int setMemBit( void *p ){
	unsigned page;
	unsigned offset;
	unsigned mask;
	
	page=(unsigned)p>>(PAGE_BITS+7);
	if( !pages[page] ){
		++pagesAlloced;
		pages[page]=malloc( PAGE_SIZE );
		memset( pages[page],0,PAGE_SIZE );
	}

	offset=((unsigned)p>>9) & PAGE_MASK;
	mask=1<<( ((unsigned)p>>4) & 31 );
	
	if( pages[page][offset] & mask ) gcError( p,"setMemBit error: membit already set" );

	pages[page][offset]|=mask;
}

static void clrMemBit( void *p ){
	unsigned page;
	unsigned offset;
	unsigned mask;

	page=(unsigned)p>>(PAGE_BITS+7);
	if( !pages[page] ) gcError( p,"clrMemBit error: mempage does not exist" );

	offset=((unsigned)p>>9) & PAGE_MASK;
	mask=1<<( ((unsigned)p>>4) & 31 );

	if( !(pages[page][offset] & mask) ) gcError( p,"clrMemBit error: membit not set" );

	pages[page][offset]&=~mask;
}

static int tstMemBit( void *p ){
	unsigned page;
	unsigned offset;
	unsigned mask;

	if( (unsigned)p & 15 ) return 0;

	page=(unsigned)p>>(PAGE_BITS+7);
	if( !pages[page] )return 0;

	offset=((unsigned)p>>9) & PAGE_MASK;
	mask=1<<( ((unsigned)p>>4) & 31 );

	return pages[page][offset] & mask;
}

static void collectMem( int );

static int heap_alloced,heap_size;

static void *heapAlloc( int size ){
	void *p,*q;
	
	size+=SIZEALIGN+4;
	
	p=malloc( size );
	
	if( !p ){
		bbGCCollect();
		p=malloc( size );
		if( !p ) return 0;
	}

	heap_alloced+=size;

	if( heap_alloced>heap_size ){
		heap_size=heap_alloced;
#ifdef DEBUG_GC
		printf( "heap_size=%i\n",heap_size );fflush( stdout );
#endif
	}
	
	q=(void*)( ((unsigned)p+ALIGNMASK+4) & ~ALIGNMASK );
	*((void**)q-1)=p;

	return q;
}

static void heapFree( void *p,int size ){
	heap_alloced-=size;

	free( *((void**)p-1) );
}

static void *allocMem( int size,int flags ){
	size=(size + sizeof(GCBlock) + 15) & ~15;
	int i=size/16;
	
	GCBlock *t;
	
	if( i<256 && (t=freeBlocks[i]) ){
		freeBlocks[i]=t->succ;
	}else{
		static int alloced;
		if( gc_mode==BBGC_AUTOMATIC && (gc_alloced-alloced)>heap_size/3 ){
			collectMem(0);
			alloced=gc_alloced;
		}
	
		if( i>255 ){
			t=heapAlloc( size );
			setMemBit( t );
		}else if( t=freeBlocks[i] ){
			freeBlocks[i]=t->succ;
		}else{
			if( size>freeBufSize ){
				if( freeBufSize ){
					int i=freeBufSize/16;
					GCBlock *t=freeBuf;
					t->flags=BBGC_MARKED;
					t->succ=freeBlocks[i];
					freeBlocks[i]=t;
					setMemBit( t );
				}
				freeBufSize=65536;
				freeBuf=heapAlloc( freeBufSize );
			}
			t=freeBuf;
			freeBuf+=size;
			freeBufSize-=size;
			setMemBit( t );
		}
	}
	
	t->succ=usedBlocks;
	t->flags=size|flags;
	usedBlocks=t;

	gc_alloced+=size;
	return t->data;
}

static GCBlock *getBlock( void *p ){
	GCBlock *q=(GCBlock*)p-1;
	if( tstMemBit( q ) ) return q;
	return 0;
}

static void freeBlock( GCBlock *t ){
	int flags=t->flags;
	int size=flags & ~15;
	int i=size/16;

	if( i>255 ){
		clrMemBit( t );
		heapFree( t,size );
	}else{
		t->flags=BBGC_MARKED;
		t->succ=freeBlocks[i];
		freeBlocks[i]=t;
	}
	gc_alloced-=size;
}

static void mark( void *p ){
	GCBlock *t=getBlock( p );
	if( !t ) return;

	if( t->flags & BBGC_MARKED ) return;
	
	t->flags|=BBGC_MARKED;
	
	if( t->flags & BBGC_ATOMIC ) return;
	
	int size=t->flags & ~15,i;

	for( i=sizeof(GCBlock);i<size;i+=4 ){
		void **r=(char*)t+i;
		mark( *r );
	}
}

static void finalize( GCBlock *t ){
}

void collectMem( int dummy ){
	int i;
	void **r;
	
	static int recurs;
	if( recurs ){
//		printf( "RECURSIVE GC!\n" );fflush( stdout );
		return;
	}
	recurs=1;

#ifdef DEBUG_GC
	int ms=bbMilliSecs();
#endif
	
	BBThread *thread;
	BBThread *curThread=bbThreadGetCurrent();
	
	BBThread *lockedThreads=_bbThreadLockThreads();
	
	for( thread=lockedThreads;thread;thread=thread->succ ){
	
		for( i=0;i<32;++i ){
			mark( thread->data[i] );
		}

		if( thread==curThread ){
			void *regs[BBGC_NUM_ROOTREGS];
			void **sp=bbGCRootRegs( regs );
			for( i=0;i<BBGC_NUM_ROOTREGS;++i ){
				mark( regs[i] );
			}
			for( r=sp;r!=thread->stackTop;++r ){
				mark( *r );
			}
		}else{
			for( i=0;i<BB_THREADREGS;++i ){
				mark( (void*)thread->locked_regs[i] );
			}
			for( r=(void**)thread->locked_sp;r!=thread->stackTop;++r ){
				mark( *r );
			}
		}
	}
	
	for( i=0;i<n_global_vars;++i ){
		mark( *global_vars[i] );
	}

#ifdef DEBUG_GC
	int mark_ms=bbMilliSecs();
#endif
	
	GCBlock *t;

	//mark locked blocks
	for( t=usedBlocks;t;t=t->succ ){
		if( t->flags & BBGC_LOCKED ) mark( t->data );
	}

	//resurrect or free finalized blocks
	while( t=finalizedBlocks ){
		finalizedBlocks=t->succ;
		if( t->flags & BBGC_MARKED ){
			//resurrect me!
			t->succ=usedBlocks;
			usedBlocks=t;
			if( t->flags & BBGC_FINALIZE ){
				t->flags&=~BBGC_FINALIZE;
#ifdef DEBUG_GC
				BBObject *q=(BBObject*)t->data;
				printf( "GC resurrected:%s @%p\n",typeName( q ),q );fflush( stdout );
#endif
			}
		}else{
			freeBlock( t );
		}
	}

	GCBlock **p=&usedBlocks;

	int n_finalized=0;
	
	while( t=*p ){
		if( t->flags & BBGC_MARKED ){
			p=&t->succ;
			t->flags&=~BBGC_MARKED;
		}else{
			*p=t->succ;
			if( t->flags & BBGC_FINALIZE ){
				++n_finalized;
				BBObject *q=(BBObject*)t->data;
//				printf( "GC finalizing:%s\n",typeName( q ) );fflush( stdout );
				BBClass *c=q->clas;
				c->free( q );
				q->clas=c;
			}
			t->succ=finalizedBlocks;
			finalizedBlocks=t;
		}
	}
	
	if( !n_finalized ){
		//
		//No finalizers were run, so it's OK to free blocks NOW.
		//
		while( t=finalizedBlocks ){
			finalizedBlocks=t->succ;
			freeBlock( t );
		}
	}
	
	_bbThreadUnlockThreads();
	
#ifdef DEBUG_GC
	int end_ms=bbMilliSecs();
	printf( "gc ms=%i, marked=%i, marked_ms=%i, freed=%i, freed_ms=%i\n",end_ms-ms,n_marked,mark_ms-ms,n_freed,end_ms-mark_ms );fflush( stdout );
#endif

	recurs=0;	
}

//***** GC Interface *****//
static int isGlobalVar( int *p ){
	if( p==&bbNullObject ) return 1;
	if( p==&bbEmptyString ) return 1;
	if( p==&bbEmptyArray ) return 1;
	if(	( p>=DATA_START && p<DATA_END-1 ) && 
		( *(void**)p==&bbStringClass ) &&
		( *(int**)(p+1)==0x7fffffff ) ) return 1;
	return 0;
}

void bbGCStartup(){

#ifdef _WIN32
/*
	printf( "_bss_start__=%p\n",&_bss_start__ );
	printf( "_bss_end__=%p\n",&_bss_end__ );
	printf( "_data_start__=%p\n",&_data_start__ );
	printf( "_data_end__=%p\n",&_data_end__ );
	printf( "_end__=%p\n",&_end__ );
	fflush( stdout );
*/
	DATA_START=&_data_start__;
	DATA_END=&_bss_end__;
#endif

#ifdef __APPLE__
	int *seg=getsegbyname( "__DATA" );
	DATA_START=(void**)seg[6];
	DATA_END=(void**)(seg[6]+seg[7]);
#endif

#ifdef __linux
	DATA_START=&__data_start;
	DATA_END=&_end;
#endif	
	
#ifdef DEBUG_GC
	printf( "DATA_START=%p, DATA_END=%p\n",DATA_START,DATA_END );fflush( stdout );
#endif
	
	void **r;
	n_global_vars=0;
	for( r=DATA_START;r!=DATA_END;++r ){
		void *p=*r;
		if( isGlobalVar( p ) ){
			++n_global_vars;
		}
	}
	
#ifdef DEBUG_GC
	printf( "Found %i global vars\n",n_global_vars );fflush( stdout );
#endif
	
	global_vars=(void***)malloc( n_global_vars*4 );
	int i=0;
	for( r=DATA_START;r!=DATA_END;++r ){
		void *p=*r;
		if( isGlobalVar( p ) ){
			global_vars[i++]=r;
		}
	}

}

void bbGCSetMode( int mode ){
	gc_mode=mode;
}

void bbGCSetDebug( int debug ){
	gc_debug=debug;
}

void *bbGCMalloc( int size,int flags ){
	if( size<=0 ) return 0;
	void *p;

	BB_LOCK

	p=allocMem( size,flags & BBGC_ATOMIC );

	BB_UNLOCK
	return p;
}

BBObject *bbGCAllocObject( int size,BBClass *clas,int flags ){
	BBObject *q;
	
	BB_LOCK
	
	q=(BBObject*)allocMem( size,flags );
	q->clas=clas;
	q->refs=0;
	
	BB_UNLOCK
	
//	if( clas!=&bbStringClass ){
//		printf( "%s = %p\n",typeName(q),q );fflush( stdout );
//	}
	
	return q;
}

int bbGCValidate( void *p ){
	int r;

	BB_LOCK

	r=getBlock( p ) ? 1 : 0;

	BB_UNLOCK
	return r;
}

int bbGCMemAlloced(){
	return gc_alloced;
}

int bbGCCollect(){
	int t;

	if( gc_suspended ) return 0;

	BB_LOCK

	t=gc_alloced;
	collectMem( 0 );
	t-=gc_alloced;

	BB_UNLOCK
	return t;
}

void bbGCSuspend(){
	BB_LOCK

	++gc_suspended;

	BB_UNLOCK
}

void bbGCResume(){
	BB_LOCK

	--gc_suspended;

	BB_UNLOCK
}

void bbGCRetain( BBObject *p ){
	BB_LOCK
	
	GCBlock *t=getBlock( p );
	if( t ){
		if( !p->refs++ ) t->flags|=BBGC_LOCKED;
	}

	BB_UNLOCK
}

void bbGCRelease( BBObject *p ){
	BB_LOCK
	
	GCBlock *t=getBlock( p );
	if( t ){
		if( !--p->refs ) t->flags&=~BBGC_LOCKED;
	}

	BB_UNLOCK
}

#endif
