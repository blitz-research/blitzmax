
#ifndef BLITZ_H
#define BLITZ_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

//Which GC to use...

#ifdef THREADED
# define BB_GC_MS
#else
# define BB_GC_RC
#endif

#include "blitz_types.h"
#include "blitz_memory.h"
#include "blitz_thread.h"
#include "blitz_gc.h"
#include "blitz_ex.h"
#include "blitz_cclib.h"
#include "blitz_debug.h"
#include "blitz_module.h"
#include "blitz_incbin.h"
#include "blitz_object.h"
#include "blitz_string.h"
#include "blitz_array.h"
#include "blitz_handle.h"
#include "blitz_app.h" 

#ifdef __cplusplus
extern "C"{
#endif

extern void brl_blitz_NullObjectError();
extern void brl_blitz_NullMethodError();
extern void brl_blitz_NullFunctionError();
extern void brl_blitz_ArrayBoundsError();
extern void brl_blitz_OutOfDataError();
extern void brl_blitz_RuntimeError( BBString *error );

extern BBClass brl_blitz_TBlitzException;
extern BBClass brl_blitz_TNullObjectException;
extern BBClass brl_blitz_TNullMethodException;
extern BBClass brl_blitz_TNullFunctionException;
extern BBClass brl_blitz_TArrayBoundsException;
extern BBClass brl_blitz_TOutOfDataException;
extern BBClass brl_blitz_TRuntimeExeption;

#ifdef __cplusplus
}
#endif

#endif
