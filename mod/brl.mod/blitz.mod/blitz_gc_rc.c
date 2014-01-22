
#include "blitz.h"

#ifdef BB_GC_RC

//#define DEBUG_GC

#ifdef _WIN32
#include <windows.h>
#endif

#define SIZEALIGN 16
#define ALIGNMASK (SIZEALIGN-1)

#define BUF_GROW 1024

#define BBGC_ZERO 0x80000000

#define PAGE_BITS 12
#define PAGE_SIZE (1<<PAGE_BITS)
#define PAGE_MASK ((PAGE_SIZE/4)-1)

static int gc_mode=BBGC_AUTOMATIC;
static int gc_debug=BBGC_NODEBUG;
static int gc_suspended=0;

static int gc_millisecs,gc_memfreed,gc_objsfreed;

static void **buf_base,**buf_put,**buf_end;
static int max_buflen;

static int *pages[1<<(25-PAGE_BITS)];
static int pagesAlloced;

static void **live;
static int live_len;

#define MAXSIZE 256

#define MAXFREEBUFSIZE 65536

static char*	freebuf;
static int	freebufsize,freebuf_alloced;
static char*	freelists[MAXSIZE/SIZEALIGN];

static int	gc_alloced;

#ifdef DEBUG_GC

#define DEBUG_COUNT 16384	//4096
#define DEBUG_MASK (DEBUG_COUNT-1)
#define DEBUG_OBJECT(X,Y) debugObject((X),(Y))

typedef struct GCDebugInfo{
	void *object;
	void *typename;
	const char *msg;
}GCDebugInfo;

static int dbIndex;
static GCDebugInfo dbInfos[DEBUG_COUNT];

static void dumpDebugInfo();

static int debugAtExit;

static const char *typeName( void *p ){
	BBObject *o=(BBObject*)p;
	BBClass *c=o->clas;
	BBDebugScope *d=c->debug_scope;
	if( d ) return d->name;
	return "?";
}

static void debugObject( void *p,const char *msg ){
	GCDebugInfo *db=dbInfos+(dbIndex & DEBUG_MASK);
	db->object=p;
	db->typename=typeName( p );
	db->msg=msg;
	++dbIndex;
	if( debugAtExit ) return;
	atexit( dumpDebugInfo );
	debugAtExit=1;
}

static void dumpDebugInfo(){
	int i;
	printf( "GC Debug info:\n" );
	for( i=0;i<DEBUG_COUNT;++i ){
		GCDebugInfo *db=dbInfos+((dbIndex+i) & DEBUG_MASK);
		if( !db->object ) continue;
		printf( "%s %s @ $%p\n",db->msg,db->typename,db->object );
	}
	fflush( stdout );
}

#else

#define DEBUG_OBJECT(X,Y)

#endif

static void gcError( void *p,const char *msg ){
#ifdef DEBUG_GC
	printf( "GC ERROR: %s, object=$%p\n",msg,p );
	fflush( stdout );	
#endif
	bbExThrowCString( msg );
}

static int setMemBit( void *p ){
	int page;
	int offset;
	int mask;
	
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
	
	DEBUG_OBJECT( p,"setMemBit" );
}

static void clrMemBit( void *p ){
	int page;
	int offset;
	int mask;

	page=(unsigned)p>>(PAGE_BITS+7);

	if( !pages[page] ) gcError( p,"clrMemBit error: mempage does not exist" );

	offset=((unsigned)p>>9) & PAGE_MASK;
	mask=1<<( ((unsigned)p>>4) & 31 );
	
	if( !(pages[page][offset] & mask) ) gcError( p,"clrMemBit error: membit not set" );

	pages[page][offset]&=~mask;
	
	DEBUG_OBJECT( p,"clrMemBit" );
}

static int tstMemBit( void *p ){
	int page;
	int offset;
	int mask;
	
	if( (int)p & 15 ) return 0;

	page=(unsigned)p>>(PAGE_BITS+7);
	if( !pages[page] ){
		return 0;
	}	
	offset=((unsigned)p>>9) & PAGE_MASK;
	mask=1<<( ((unsigned)p>>4) & 31 );
	
	return pages[page][offset] & mask;
}

static int collectMem( int dummy ){

	int i,n;
	BBObject *p;
	void **sp,**spBase,**tsp;
	void *rootRegs[BBGC_NUM_ROOTREGS];
	
	if( gc_suspended || !bbGCStackTop ) return 0;
	
	++gc_suspended;
	
	gc_memfreed=bbGCMemAlloced();
	
	if( gc_debug ){
		gc_millisecs=-1;
#if _WIN32
		gc_millisecs=timeGetTime();
#endif
	}

	spBase=bbGCRootRegs( rootRegs );
	
	n=bbGCStackTop-spBase+BBGC_NUM_ROOTREGS;
	if( n>live_len ){
		void **t=live;
		int new_len=live_len+1000;
		if( n>new_len ) new_len=n;
		live=(void**)malloc( new_len*4 );
		if( t ) free( t );
		live_len=new_len;
	}

	tsp=live;
	sp=spBase;
	while( sp!=bbGCStackTop ){
		p=*sp++;
		if( tstMemBit( p ) ) *tsp++=p;
	}
	sp=rootRegs;
	for( n=0;n<BBGC_NUM_ROOTREGS;++n ){
		p=*sp++;
		if( tstMemBit( p ) ) *tsp++=p;
	}
	
	sp=live;
	while( sp!=tsp ){
		p=*sp++;
		++p->refs;
	}
	
	i=0;
	gc_objsfreed=0;
	while( i!=(buf_put-buf_base) ){
		p=buf_base[i++];
		if( p->refs>=0 ){
			printf( "bad refs:obj=$%x refs=$%x\n",(unsigned)p,(unsigned)p->refs );
			if( p->clas==&bbStringClass ){
				printf( "String:%s\n",bbStringToCString( (BBString*)p ) );
			}
			fflush( stdout );
		}
		if( p->refs&=~BBGC_ZERO ) continue;
		p->clas->free( p );
		++gc_objsfreed;
	}
	buf_put=buf_base;

	sp=live;
	while( sp!=tsp ){
		p=*sp++;
		if( !--p->refs ) bbGCFree( p );
	}
	
	gc_memfreed-=bbGCMemAlloced();
	
	if( gc_debug ){
#if _WIN32
		gc_millisecs=timeGetTime()-gc_millisecs;
#endif
		printf( "GC collectMem: memFreed=%i, time=%ims, objsFreed=%i, objsScanned=%i, objsLive=%i\n",
		gc_memfreed,
		gc_millisecs,
		gc_objsfreed,
		bbGCStackTop-spBase,
		tsp-live );
		fflush( stdout );
	}
	
	--gc_suspended;
	
	return gc_memfreed;
}

//***** GC INTERFACE *****//
void bbGCStartup(){
}

void bbGCSetMode( int mode ){
	gc_mode=mode;
}

void bbGCSetDebug( int debug ){
	gc_debug=debug;
}

BBObject *bbGCAllocObject( int size,BBClass *clas,int flags ){
	BBObject *p;

	if( gc_mode==BBGC_AUTOMATIC && !gc_suspended ){
		static int alloced;
		static int rate=500;
		alloced+=size;
		if( alloced>(1024*1024) || buf_put-buf_base>rate ){
			collectMem(0);
			rate+=500-gc_objsfreed;
			alloced=0;
		}
	}else if( gc_mode==BBGC_AGGRESSIVE ){
		collectMem(0);
	}

	if( size<=0 ) return 0;

	if( size>(MAXSIZE-SIZEALIGN) ){
		p=bbMemAlloc( size );
	}else{
		int n=(size+ALIGNMASK)/SIZEALIGN;
		p=freelists[n];
	
		if( p ){
			freelists[n]=*(char**)p;
		}else if( size<=freebufsize ){
			p=freebuf;
			n*=SIZEALIGN;
			freebuf+=n;
			freebufsize-=n;
		}else{
			if( freebufsize ){
				int n=(freebufsize+ALIGNMASK)/SIZEALIGN;
				*(char**)freebuf=freelists[n];
				freelists[n]=freebuf;
			}
			p=bbMemAlloc( MAXFREEBUFSIZE );
			n*=SIZEALIGN;
			freebuf=(char*)p+n;
			freebufsize=MAXFREEBUFSIZE-n;
		}
	}
	setMemBit( p );
	gc_alloced+=size;
	p->clas=clas;
	p->refs=0;
	bbGCFree( p );
	return p;
}

int bbGCValidate( void *p ){
	return tstMemBit( p ) ? 1 : 0;
}

int bbGCMemAlloced(){
	return gc_alloced;
}

int bbGCCollect(){
	return collectMem(0);
}

void bbGCSuspend(){
	++gc_suspended;
}

void bbGCResume(){
	--gc_suspended;
}

void bbGCRetain( BBObject *p ){
	BBINCREFS( p );
}

void bbGCRelease( BBObject *p ){
	BBDECREFS( p );
}

//***** Ref counter specific *****//
void bbGCFree( BBObject *p ){
	if( p->refs ){
		bbExThrowCString( "GC bbGCFree: mem has non-0 refs" );
	}
	if( buf_put==buf_end ){
		int len=buf_put-buf_base,new_len=len+BUF_GROW;
		buf_base=(void**)bbMemExtend( buf_base,len*4,new_len*4 );
		buf_end=buf_base+new_len;
		buf_put=buf_base+len;
		if( new_len>max_buflen ) max_buflen=new_len;
	}
	p->refs=BBGC_ZERO;
	*buf_put++=p;
}

void bbGCDeallocObject( BBObject *p,int size ){
	if( !p ) return;
	clrMemBit( p );
	if( size>(MAXSIZE-SIZEALIGN) ){
		bbMemFree( p );
	}else{
		int n=(size+ALIGNMASK)/SIZEALIGN;
		*(char**)p=freelists[n];
		freelists[n]=(char*)p;
	}
	gc_alloced-=size;
}

#endif
