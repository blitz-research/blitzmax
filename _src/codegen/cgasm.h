
#ifndef CGASM_H
#define CGASM_H

#include "cgcode.h"
#include "cgintset.h"

struct CGAsm{
	CGAsm *succ,*pred;

	CGStm *stm;
	char *assem;
	CGIntSet use,def;

	CGAsm( CGStm *t,const char *s );

	void genUseDef();
};

struct CGAsmSeq{
	CGAsm *begin,*end;

	CGAsmSeq();

	void	clear();

	CGAsm*	erase( CGAsm *as );
	CGAsm*	insert( CGAsm *as,CGAsm *succ );
};

#endif