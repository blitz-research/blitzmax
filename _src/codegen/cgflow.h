
#ifndef CGFLOW_H
#define CGFLOW_H

#include "cgblock.h"

struct CGFlow{
	CGAsmSeq &assem;
	CGBlockSeq blocks;

	CGFlow( CGAsmSeq &assem );
	virtual ~CGFlow();

	void liveness();

private:
	void buildFlow();
	void findLoops();
	CGBlock *block( CGAsm *as,CGBlock *p );
};

#endif