
#ifndef BLITZ_INCBIN_H
#define BLITZ_INCBIN_H

#include "blitz_types.h"

#ifdef __cplusplus
extern "C"{
#endif

int			bbIncbinAdd( BBString *file,void *ptr,int len );
void*		bbIncbinPtr( BBString *file );
int			bbIncbinLen( BBString *file );

#ifdef __cplusplus
}
#endif

#endif
