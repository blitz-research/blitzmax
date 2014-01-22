
#include "cgstd.h"

#include "cgflow.h"
#include "cgutil.h"
#include "cgdebug.h"

//#define _DEBUG_FLOW

static set<CGBlock*> reachable;

static void findReachable( CGBlock *blk ){
	if( !reachable.insert(blk).second ) return;
	CGBlockIter it;
	for( it=blk->succ.begin();it!=blk->succ.end();++it ){
		findReachable(*it);
	}
}

//******************* Build flow ******************
CGBlock *CGFlow::block( CGAsm *as,CGBlock *p ){
	CGBlock *b=new CGBlock;
	b->begin=b->end=as;
	blocks.push_back(b);
	if( !p ) return b;
	p->succ.push_back(b);
	b->pred.push_back(p);
	return b;
}

void CGFlow::buildFlow(){

	CGAsm *as;
	blocks.clear();
	map<CGSym*,CGBlock*> lab_map;
	map<CGBlock*,CGSym*> bra_map;

#ifdef _DEBUG_FLOW
	cout<<"CGFlow::buildFlow()"<<endl;
#endif

	//make sure there's a label at the start
	if( !assem.begin->stm->lab() ){
		assem.insert( new CGAsm(CG::lab(),""),assem.begin );
	}

	//ensure there's a LAB after each BRA/BCC/RET
	for( as=assem.begin;as!=assem.end;as=as->succ ){
		CGStm *st=as->stm;
		if( !st->bra() && !st->bcc() && !st->ret() ) continue;
		if( as->succ->stm->lab() ) continue;
		as=assem.insert( new CGAsm(CG::lab(),""),as->succ );
	}
	
	as=assem.begin;
	CGBlock *b=block(as,0);
	while( as!=assem.end ){

		CGStm *st=as->stm;

		if( CGLab *t=st->lab() ){
			if( as!=b->begin ){
				b->end=as;
				b=block(as,b);
			}
			lab_map[t->sym]=b;
			as=as->succ;
		}else if( CGBra *t=st->bra() ){
			bra_map[b]=t->sym;
			as=as->succ;
			b->end=as;
			b=block(as,0);
		}else if( CGBcc *t=st->bcc() ){
			bra_map[b]=t->sym;
			as=as->succ;
			b->end=as;
			b=block(as,b);
		}else if( CGRet *t=st->ret() ){
			as=as->succ;
			b->end=as;
			b=block(as,0);
		}else{
			as=as->succ;
		}
	}
	b->end=as;

	//patch bras
	map<CGBlock*,CGSym*>::iterator it;
	for( it=bra_map.begin();it!=bra_map.end();++it ){
		CGBlock *src=it->first;
		if( !lab_map.count(it->second) ) continue;
		CGBlock *dst=lab_map[it->second];
		src->succ.push_back( dst );
		dst->pred.push_back( src );
	}

	//find reachable blocks
	reachable.clear();
	findReachable( *blocks.begin() );

	CGBlockIter blk_it=blocks.begin();
	for( ++blk_it;blk_it!=blocks.end(); ){

		//reachable?
		CGBlock *blk=*blk_it;
		if( reachable.count(blk) ){
			++blk_it;
			continue;
		}

		//erase assem
		CGAsm *as=blk->begin;
		while( as!=blk->end ) as=assem.erase(as);
		(*(blk_it-1))->end=as;

		//erase block
		blk_it=blocks.erase( blk_it );
	}
}

//***************** Loop detection ****************

static void eraseDom( CGBlock *blk,CGBlock *dom ){

	if( blk==dom ) return;

	if( !blk->dom.insert(dom).second ) return;

	CGBlockIter it;
	for( it=blk->succ.begin();it!=blk->succ.end();++it ){
		eraseDom( *it,dom );
	}
}

static void insertLoop( CGBlock *blk,CGBlock *head ){

	if( !head->loops.insert( blk ).second ) return;

	CGBlockIter it;
	for( it=blk->pred.begin();it!=blk->pred.end();++it ){
		insertLoop( *it,head );
	}
}

void CGFlow::findLoops(){

#ifdef _DEBUG_FLOW
	cout<<"CGFlow::findLoops() - blocks="<<blocks.size()<<endl;
#endif

//	cout<<"findLoops blocks="<<blocks.size()<<endl;

	int k;
	for( k=0;k<blocks.size();++k ){
		blocks[k]->dom.clear();
		blocks[k]->loops.clear();
		blocks[k]->loop_level=0;
	}

	if( blocks.size()>1000 ) return;

//	cout<<"EraseDom"<<endl;

	for( k=0;k<blocks.size();++k ){
		eraseDom( blocks[0],blocks[k] );
	}

//	cout<<"Find back edges"<<endl;

	//find back edges
	for( k=0;k<blocks.size();++k ){
		CGBlock *blk=blocks[k];

		CGBlockIter it;
		for( it=blk->succ.begin();it!=blk->succ.end();++it ){
			CGBlock *head=*it;
			if( blk->dom.count(head) ) continue;
			head->loops.insert( head );
			insertLoop( blk,head );
		}
	}

//	cout<<"Creating loop_level"<<endl;

	//create loop_level
	for( k=0;k<blocks.size();++k ){
		CGBlock *blk=blocks[k];

		set<CGBlock*>::iterator it;
		for( it=blk->loops.begin();it!=blk->loops.end();++it ){
			++(*it)->loop_level;
		}
	}
}

//*************** liveness analysis ***************
static void liveIn( CGBlock *blk,int n ){

	if( !blk->live_in.insert( n ) ) return;

	CGBlockIter it;
	for( it=blk->pred.begin();it!=blk->pred.end();++it ){
		CGBlock *t=*it;

		if( t->live_out.insert(n) && !t->def.count(n) ) liveIn( t,n );
	}
}

void CGFlow::liveness(){

#ifdef _DEBUG_FLOW
	cout<<"CGFlow::liveness()"<<endl;
#endif

	CGBlockIter blk_it;
	for( blk_it=blocks.begin();blk_it!=blocks.end();++blk_it ){
		CGBlock *blk=*blk_it;

		blk->use.clear();
		blk->def.clear();
		blk->live_in.clear();
		blk->live_out.clear();

		CGAsm *as;

		for( as=blk->begin;as!=blk->end;as=as->succ ){

			blk->use.xinsert( as->use,blk->def );
			blk->def.xinsert( as->def,blk->use );
		}
	}

	for( blk_it=blocks.begin();blk_it!=blocks.end();++blk_it ){
		CGBlock *blk=*blk_it;

		CGIntCIter it;
		for( it=blk->use.begin();it!=blk->use.end();++it ){
			liveIn( blk,*it );
		}
	}
}

//***************** Constructor *******************
static vector<CGFlow*> _flows;

CGFlow::CGFlow( CGAsmSeq &t_assem ):assem(t_assem){
	buildFlow();
	findLoops();
	_flows.push_back( this );
}

CGFlow::~CGFlow(){
	for( int k=0;k<blocks.size();++k ){
		delete blocks[k];
	}
}
