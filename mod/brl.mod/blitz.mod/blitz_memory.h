
#ifndef BLITZ_MEMORY_H
#define BLITZ_MEMORY_H

#include "blitz_types.h"

#ifdef __cplusplus
extern "C"{
#endif

void*	bbMemAlloc( int );
void		bbMemFree( void *mem );
void*	bbMemExtend( void *mem,int size,int new_size );

void		bbMemClear( void *dst,int size );
void		bbMemCopy( void *dst,const void *src,int size );
void		bbMemMove( void *dst,const void *src,int size );

#ifdef __cplusplus
}
#endif

#endif
