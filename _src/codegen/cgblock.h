
#ifndef CGBLOCK_H
#define CGBLOCK_H

#include "cgasm.h"

struct CGBlock;

typedef std::vector<CGBlock*> CGBlockSeq;
typedef CGBlockSeq::iterator CGBlockIter;
typedef CGBlockSeq::const_iterator CGBlockCIter;

struct CGBlock{
	CGAsm *begin,*end;
	CGBlockSeq succ,pred;
	CGIntSet use,def,live_in,live_out;
	std::set<CGBlock*> dom,loops;
	int loop_level;

	CGBlock():begin(0),end(0),loop_level(0){}

	void	removeSucc( CGBlock *blk );
	void	removePred( CGBlock *blk );
};

#endif