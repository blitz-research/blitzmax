
#include "blitz.h"

static BBModule *modules;

void bbModuleImport( BBModule *mod ){
	BBModule *t;
	for( t=modules;t;t=t->succ ){
		if( t==mod ) return;
	}
	mod->entry();
}

void bbModuleRegister( BBModule *mod ){
	mod->succ=modules;
	modules=mod;
}
