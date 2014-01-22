
#include "cgstd.h"

#include "cgblock.h"

void CGBlock::removeSucc( CGBlock *blk ){
	CGBlockIter it;
	for( it=succ.begin();it!=succ.end();++it ){
		if( *it==blk ){
			succ.erase(it);
			return;
		}
	}
}

void CGBlock::removePred( CGBlock *blk ){
	CGBlockIter it;
	for( it=pred.begin();it!=pred.end();++it ){
		if( *it==blk ){
			pred.erase(it);
			return;
		}
	}
}
