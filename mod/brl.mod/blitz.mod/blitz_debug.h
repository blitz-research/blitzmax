
#ifndef BLITZ_DEBUG_H
#define BLITZ_DEBUG_H

#include "blitz_types.h"

#ifdef __cplusplus
extern "C"{
#endif

#ifndef NDEBUG
#define bbassert( x ) if( !(x) ) bbCAssertEx()
#else
#define bbassert( x )
#endif

typedef struct BBDebugStm BBDebugStm;
typedef struct BBDebugDecl BBDebugDecl;
typedef struct BBDebugScope BBDebugScope;

enum{
	BBDEBUGDECL_END=0,
	BBDEBUGDECL_CONST=1,
	BBDEBUGDECL_LOCAL=2,
	BBDEBUGDECL_FIELD=3,
	BBDEBUGDECL_GLOBAL=4,
	BBDEBUGDECL_VARPARAM=5,

	BBDEBUGDECL_TYPEMETHOD=6,
	BBDEBUGDECL_TYPEFUNCTION=7
};

struct BBDebugDecl{
	int 			kind;
	const char		*name,*type_tag;
	union{
		BBString*	const_value;
		int			local_offset;
		int			field_offset;
		void		*global_address;
	};
};

enum{
	BBDEBUGSCOPE_FUNCTION=1,
	BBDEBUGSCOPE_USERTYPE=2,
	BBDEBUGSCOPE_LOCALBLOCK=3
};

struct BBDebugScope{
	int				kind;
	const char		*name;
	BBDebugDecl		decls[1];
};

struct BBDebugStm{
	const char		*source_file;
	int				line_num,char_num;
};

extern void bbCAssertEx();

extern void (*bbOnDebugStop)();
extern void (*bbOnDebugLog)( BBString *msg );
extern void (*bbOnDebugEnterStm)( BBDebugStm *stm );
extern void (*bbOnDebugEnterScope)( BBDebugScope *scope,void *inst );
extern void (*bbOnDebugLeaveScope)();
extern void (*bbOnDebugPushExState)();
extern void (*bbOnDebugPopExState)();
extern void (*bbOnDebugUnhandledEx)( BBObject *ex );

#ifdef __cplusplus
}
#endif

#endif
