
#include "blitz.h"

#define SIZEALIGN 16
#define ALIGNMASK (SIZEALIGN-1)

//Allocates mem on 16 byte aligned boundary.
//
//Used by (some) GC routines to allocate large chunks, and GC mem needs to be on 16 byte boundary for
//mem bit flags system in ref couter/Mark Sibly GCs...
//
void *bbMemAlloc( int size ){
	void *p,*q;
	
	size+=SIZEALIGN+4;
	
	p=malloc( size );
	
	if( !p ){
		bbGCCollect();
		p=malloc( size );
		if( !p ) return 0;
	}

	q=(void*)( ((unsigned)p+ALIGNMASK+4) & ~ALIGNMASK );
	*((void**)q-1)=p;

	return q;
}

void bbMemFree( void *p ){
	if( p ) free( ((void**)p)[-1] );
}

void *bbMemExtend( void *mem,int size,int new_size ){
	void *p;
	p=bbMemAlloc( new_size );
	if(mem != NULL){
		bbMemCopy( p,mem,size );
		bbMemFree( mem );
	}
	return p;
}

void bbMemClear( void *dst,int size ){
	memset( dst,0,size );
}

void bbMemCopy( void *dst,const void *src,int size ){
	memcpy( dst,src,size );
}

void bbMemMove( void *dst,const void *src,int size ){
	memmove( dst,src,size );
}
