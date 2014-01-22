
#ifndef BLITZ_GC_H
#define BLITZ_GC_H

#include "blitz_types.h"

#ifdef __cplusplus
extern "C"{
#endif

#define BBGC_MANYREFS 0x40000000

//for bbGCSetMode
#define BBGC_AUTOMATIC 1
#define BBGC_MANUAL 2
#define BBGC_AGGRESSIVE -1

//for bbGCSetDebug
#define BBGC_NODEBUG 0
#define BBGC_STDOUTDEBUG 1

//for bbGCAlloc
#define BBGC_ATOMIC 1
#define BBGC_FINALIZE 2

//Probably shouldn't be here...
#if __ppc__
#define BBGC_NUM_ROOTREGS 19
#else
#define BBGC_NUM_ROOTREGS 4
#endif
void*	bbGCRootRegs( void *p );

void		bbGCStartup();
void		bbGCSetMode( int mode );
void		bbGCSetDebug( int debug );
void*	bbGCMalloc( int size,int flags );
BBObject*	bbGCAllocObject( int size,BBClass *clas,int flags );
int 		bbGCValidate( void *p );
int		bbGCMemAlloced();
int		bbGCCollect();
void		bbGCSuspend();
void		bbGCResume();
void		bbGCRetain( BBObject *p );
void		bbGCRelease( BBObject *p );

// BBRETAIN/BBRELEASE should be used to prevent an object from garbage collection.
//
// This is mainly of use if an object is being stored outside of BlitzMax's 'sight' - say, in a C++ table.
//
// You can also use bbGCRetain/bbGCRelease functions above if necessary - MACROS are just faster.

// For ref counting GC...
//
#ifdef BB_GC_RC
#define	BBRETAIN(X) {++(X)->refs;}
#define	BBRELEASE(X) {if( !--(X)->refs ) bbGCFree(X);}
#endif

// For Mark Sibly GC...
//
#ifdef BB_GC_MS
#define	BBRETAIN(X) bbGCRetain( ((BBObject*)(X)) );
#define	BBRELEASE(X) bbGCRelease( ((BBObject*)(X)) );
#endif

// For BDW GC...
//
#ifdef BB_GC_BDW
#define	BBRETAIN(X) {}
#define	BBRELEASE(X) {}
#endif

// Internal use only
#ifdef BB_GC_RC
void		bbGCFree( BBObject *p );					//called when refs==0 - MAY be eligble for GC
void		bbGCDeallocObject( BBObject *p,int size );	//called after destruction - Sayonara!
#define	BBINCREFS(X) {++(X)->refs;}
#define	BBDECREFS(X) {if( !--(X)->refs ) bbGCFree(X);}
#else
#define	BBINCREFS(X) {}
#define	BBDECREFS(X) {}
#endif

#ifdef __cplusplus
}
#endif

#endif
