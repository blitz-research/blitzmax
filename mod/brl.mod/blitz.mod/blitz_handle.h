
#ifndef BLITZ_HANDLE_H
#define BLITZ_HANDLE_H

#include "blitz_types.h"

#ifdef __cplusplus
extern "C"{
#endif

int			bbHandleFromObject( BBObject *o );
BBObject*   bbHandleToObject( int handle );
void		bbHandleRelease( int handle );

#ifdef __cplusplus
}
#endif

#endif


