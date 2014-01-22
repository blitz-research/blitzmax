
#ifndef BLITZ_MODULE_H
#define BLITZ_MODULE_H

#include "blitz_types.h"

#ifdef __cplusplus
extern "C"{
#endif

typedef struct BBModule BBModule;

struct BBModule{
	BBModule*	succ;
	const char*	ident;
	void		(*entry)();
};

void	bbModuleImport( BBModule *mod );
void	bbModuleRegister( BBModule *mod );

#ifdef __cplusplus
}
#endif

#endif
