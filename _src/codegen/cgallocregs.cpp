
#include "cgstd.h"

#include "cgallocregs.h"
#include "cgdebug.h"
#include "cgutil.h"

#include <float.h>

//quick debug
//#define _DEBUG_ALLOCREGS

//BIG debug!
//#define _DEBUG_REGALLOC

using namespace CG;
using namespace std;

static CGFlow *flow;
static CGFrame *frame;

struct Node;
typedef set<Node*> NodeSet;
typedef NodeSet::iterator NodeIter;

static int reg_colors[4];

static int n_passes,n_spills,max_spill_id;

struct Node{
	Node *succ,*pred,*_list;

	CGReg *reg;
	Node *alias;
	int bank,color,degree;
	float usage;
	int block_count;
	NodeSet edges,moves;

	bool cant_spill;

	Node():reg(0),alias(0),bank(-1),color(-1),degree(0),usage(0),block_count(1),cant_spill(false){
		clear();
	}

	void setReg( CGReg *r ){
		reg=r;
		color=reg->color;
		bank=frame->reg_banks[reg->type];
	}

	Node *unAlias(){
		return alias ? alias->unAlias() : this;
	}

	void clear(){
		_list=0;
		succ=pred=this;
	}

	bool empty(){
		return succ==this;
	}

	void insert( Node *t_list ){
		if( _list==t_list ) return;
		pred->succ=succ;
		succ->pred=pred;
		succ=t_list;
		pred=succ->pred;
		succ->pred=pred->succ=this;
		_list=t_list;
	}

	int  colors(){
		return reg_colors[bank];
	}

	bool sigDegree(){
		return degree>=colors();
	}

	bool colored(){
		return color!=-1;
	}

	bool moveRelated(){
		return moves.size()>0;
	}
};

//node per enumerated tmp
static vector<Node> nodes;

//nodes not yet removed from graph
static Node *_simplify,*_coalesce,*_freeze,*_spill;

//nodes removed from graph
static Node *_selected,*_coalesced,*_spilled,*_colored;

static void freezeNode( Node *node );

static void createNodes(){

	nodes.clear();
	nodes.resize( frame->regs.size() );

	int k;
	for( k=0;k<frame->regs.size();++k ){
		CGReg *r=frame->regs[k];
		nodes[k].setReg( r );
		if( r->id!=k ) nodes[k].alias=&nodes[r->id];
	}
	for( k=0;k<nodes.size();++k ){
		if( nodes[k].alias ){
			CGReg *r=nodes[k].unAlias()->reg;
			assert( frame->regs[r->id]->id==r->id );
		}
	}
}

static void createGraph(){

	CGAsm *as;
	CGBlockCIter blk_it;

	//build interference edges
	for( blk_it=flow->blocks.begin();blk_it!=flow->blocks.end();++blk_it ){
		CGBlock *blk=*blk_it;

		float use_cost=pow((double)10,(double)blk->loop_level);

		//Increase usage for regs that are live_in and live_out
		CGIntCIter int_it;
		for( int_it=blk->live_in.begin();int_it!=blk->live_in.end();++int_it ){
			if( blk->live_out.count(*int_it) ) nodes[*int_it].block_count+=1;
		}

		CGIntSet live=blk->live_out;

		CGAsm *as=blk->end;

		while( as!=blk->begin ){
			as=as->pred;

			Node *copy_src=0;
			if( CGMov *t=as->stm->mov() ){
				if( CGReg *lhs=t->lhs->reg() ){
					if( CGReg *rhs=t->rhs->reg() ){
						copy_src=&nodes[rhs->id];
					}
				}
			}

			CGIntCIter def_it;
			for( def_it=as->def.begin();def_it!=as->def.end();++def_it ){
				Node *x=&nodes[*def_it];
				x->usage+=use_cost;

				CGIntCIter live_it;
				for( live_it=live.begin();live_it!=live.end();++live_it ){
					Node *y=&nodes[*live_it];
					if( (x!=y) && (y!=copy_src) && (x->bank==y->bank) ){
						x->edges.insert( y );
						y->edges.insert( x );
					}
				}
			}

			CGIntCIter use_it;
			for( use_it=as->use.begin();use_it!=as->use.end();++use_it ){
				Node *y=&nodes[*use_it];
				y->usage+=use_cost;
			}

			live.erase( as->def );
			live.insert( as->use );
		}
	}

	//build 'move' edges
	for( as=flow->assem.begin;as!=flow->assem.end;as=as->succ ){
		if( CGMov *t=as->stm->mov() ){
			if( CGReg *lhs=t->lhs->reg() ){
				if( CGReg *rhs=t->rhs->reg() ){
					Node *x=&nodes[lhs->id];
					Node *y=&nodes[rhs->id];
					if( x!=y && !x->edges.count(y) ){
						x->moves.insert(y);
						y->moves.insert(x);
					}
				}
			}
		}
	}

	//initial node degrees
	int k;
	for( k=0;k<nodes.size();++k ){
		Node *node=&nodes[k];
		node->degree=node->colored() ? 0x7fffffff : node->edges.size();
	}

#ifdef _DEBUG_REGALLOC
	cout<<endl<<";--- Flow ---;"<<endl;
	cout<<flow;
	cout<<endl<<";--- Interference graph ---;"<<endl;
	for( k=0;k<nodes.size();++k ){
		Node *node=&nodes[k];
		cout<<node->reg->id<<' ';
		cout<<"(usage="<<node->usage;
		cout<<" moves="<<node->moves.size();
		cout<<" degree="<<node->degree;
		if( node->degree ) cout<<" spill="<<(float)node->usage/(float)node->degree;
		cout<<"):";
		NodeIter it;
		for( it=node->edges.begin();it!=node->edges.end();++it ){
			cout<<' '<<(*it)->reg->id;
		}
		cout<<endl;
	}
#endif
}

static void createLists(){
	//initialize lists
	if( !_simplify ){
		_simplify=new Node;
		_coalesce=new Node;
		_freeze=new Node;
		_spill=new Node;

		_selected=new Node;
		_coalesced=new Node;
		_spilled=new Node;
		_colored=new Node;
	}

	_simplify->clear();
	_coalesce->clear();
	_freeze->clear();
	_spill->clear();

	_selected->clear();
	_coalesced->clear();
	_spilled->clear();
	_colored->clear();

	for( int k=0;k<nodes.size();++k ){
		Node *node=&nodes[k];
		if( node->alias ) node->insert( _coalesced );
		else if( node->moveRelated() ) node->insert( _coalesce );
		else freezeNode( node );
	}
}

//decrement degree of a node.
static void decDegree( Node *node ){
	//dec degree
	if( --node->degree!=node->colors()-1 ) return;

	//OK node transitioned from sig to insig...

	//move frozen neighbors to coalesce
	NodeIter it;
	for( it=node->edges.begin();it!=node->edges.end();++it ){
		Node *t=(*it);
		if( t->_list==_freeze ) t->insert( _coalesce );
	}

	//simplify if in spill
	if( node->_list==_spill ) node->insert( _simplify );
}

//node has become non-move related
//(node in coalesce or frozen)
static void freezeNode( Node *node ){
	assert( !node->moveRelated() );
	if( node->colored() ) node->insert( _colored );
	else if( node->sigDegree() ) node->insert( _spill );
	else node->insert( _simplify );
}

//move node to select stack
//decrement degree of neighboring nodes
//(node is insig degree )
static void selectNode( Node *node ){
	assert( node->_list==_simplify || node->_list==_spill );
	node->degree=0;
	node->insert( _selected );
	NodeIter it;
	for( it=node->edges.begin();it!=node->edges.end();++it ){
		Node *t=(*it);
		decDegree( t );
	}
}

//combine nodes a,b to node a
//(a in coalesce, b in coalesce or frozen)
static void combine( Node *a,Node *b ){
	assert( a->_list==_coalesce && (b->_list==_coalesce||b->_list==_freeze) );

	a->cant_spill=true;

	b->alias=a;
	b->insert( _coalesced );

	NodeIter it;

	//fix moves
	for( it=b->moves.begin();it!=b->moves.end();++it ){
		Node *t=*it;

		t->moves.erase(b);
		if( t==a ) continue;

		if( !a->edges.count(t) ){
			t->moves.insert(a);
			a->moves.insert(t);
		}else if( !t->moveRelated() ){
			freezeNode(t);
		}
	}

	//fix edges
	for( it=b->edges.begin();it!=b->edges.end();++it ){
		Node *t=(*it);

		t->edges.erase(b);

		if( a->edges.count(t) ){
			decDegree(t);
			continue;
		}

		t->edges.insert(a);
		a->edges.insert(t);
		if( t->_list==_selected ) continue;

		if( !a->colored() ) ++a->degree;
		if( !t->moves.count(a) ) continue;

		t->moves.erase(a);
		a->moves.erase(t);
		if( !t->moveRelated() )	freezeNode(t);
	}

	a->usage+=b->usage;
	if( !a->moveRelated() ) freezeNode( a );
}

//Briggs:
//can we coalesce these 2 nodes?
//(a in coalesce, b in coalesce or frozen)
static bool canCoalesce( Node *a,Node *b ){
	assert( a->_list==_coalesce && (b->_list==_coalesce||b->_list==_freeze||b->_list==_colored) );

	if( b->colored() ) return false;

	NodeIter it;

	bool briggs;

	//Briggs...
	int n=0;
	for( it=a->edges.begin();it!=a->edges.end();++it ){
		Node *t=(*it);
		if( t->sigDegree() ) ++n;
	}
	for( it=b->edges.begin();it!=b->edges.end();++it ){
		Node *t=(*it);
		if( t->sigDegree() && !t->edges.count(a) ) ++n;
	}
	briggs=n<a->colors();

	return briggs;
}

static void simplify(){

	Node *node=_simplify->succ;

#ifdef _DEBUG_REGALLOC
	cout<<"Simplifying:\t"<<node->reg->id<<endl;
#endif

	selectNode( node );
}

static void coalesce(){

	Node *node=_coalesce->succ;

	NodeIter it;
	for( it=node->moves.begin();it!=node->moves.end();++it ){
		Node *t=*it;

		if( !canCoalesce(node,t) ) continue;

#ifdef _DEBUG_REGALLOC
		cout<<"Coalescing:\t"<<t->reg->id<<"->"<<node->reg->id<<endl;
#endif
		combine(node,t);

		return;
	}
	
	if( node->colored() ) node->insert( _colored );
	else node->insert( _freeze );
}

//freeze heuristic:
//pick non-sig degree node with lowest move count
//
static void freeze(){

	int min=0x7fffffff;
	Node *node=0;
	for( Node *t=_freeze->succ;t!=_freeze;t=t->succ ){
		if( t->degree<min ){
			node=t;
			min=t->degree;
		}
	}

#ifdef _DEBUG_REGALLOC
	cout<<"Freezing:\t"<<node->reg->id<<endl;
#endif

	NodeIter it;
	for( it=node->moves.begin();it!=node->moves.end();++it ){
		Node *t=*it;
		t->moves.erase(node);
		if( !t->moveRelated() ) freezeNode( t );
	}

	node->moves.clear();
	freezeNode( node );
}

static void spill(){

	Node *node=0;
	float min=FLT_MAX;
	for( int pass=0;pass<2;++pass ){
		for( Node *t=_spill->succ;t!=_spill;t=t->succ ){

			if( t->cant_spill ) cout<<"Shouldn't spill:"<<t->reg->id<<endl;

			//don't spill reg generated by prior spill
			if( !pass && t->reg->id>=max_spill_id ) continue;

			//No idea...!			
//			if( !pass && t->reg->owner ) continue;

//			float cost=(float)t->usage/(float)t->degree;
			
			//***** Munged cost *****//
			float cost=(float)t->usage/((float)t->degree*(float)t->block_count);

			if( cost<min ){
				node=t;
				min=cost;
			}
		}
		if( node ) break;
		cout<<"Pass "<<n_passes<<": trouble finding spill candidate\n"<<endl;
	}

	if( !node ) fail( "Unable to find spill candidate" );

#ifdef _DEBUG_REGALLOC
	cout<<"Spilling:\t"<<node->reg->id<<endl;
#endif

	selectNode( node );
}

static bool selectRegs(){

#ifdef _DEBUG_REGALLOC
	cout<<endl<<";--- Popping stack ---;"<<endl;
#endif

	while( !_selected->empty() ){

		Node *node=_selected->pred;

		//find color;
		NodeIter it;

		unsigned avail=frame->reg_masks[node->bank];

		for( it=node->edges.begin();it!=node->edges.end();++it ){
			Node *t=(*it);
			if( t->color>=0 ) avail&=~(1<<t->color);
		}

		if( avail ){
			int color=0;
			for( ;!(avail&1);avail>>=1 ) ++color;
			node->color=color;
			node->insert( _colored );
#ifdef _DEBUG_REGALLOC
			cout<<"Colored:\t"<<node->reg->id<<"->"<<color<<endl;
#endif
		}else{
			node->insert( _spilled );
#ifdef _DEBUG_REGALLOC
			cout<<"Spilled:\t"<<node->reg->id<<endl;
#endif
		}
	}

	if( _spilled->empty() ){
		int k;
		for( k=0;k<nodes.size();++k ){
			Node *x=&nodes[k];
			Node *y=x->unAlias();
			assert( y->color>=0 );
			x->reg->color=y->color;
		}
		return true;
	}

//	max_spill_id=nodes.size();

	for( Node *node=_spilled->succ;node!=_spilled;node=node->succ ){
		frame->spillReg( node->reg,0 );
		++n_spills;
	}

	flow->liveness();
	return false;
}

static int countBits( unsigned n ){
	int c=0;
	for( ;n;n>>=1 ) c+=(n&1);
	return c;
}

static bool allocRegs(){

	createNodes();
	createGraph();
	createLists();
	
	if( !max_spill_id ) max_spill_id=nodes.size();

	for(;;){
		if( !_simplify->empty() ){
			simplify();
		}else if( !_coalesce->empty() ){
			coalesce();
		}else if( !_freeze->empty() ){
			freeze();
		}else if( !_spill->empty() ){
			spill();
		}else{
			break;
		}
	}

	return selectRegs();
}

void cgAllocRegs( CGFrame *t_frame ){

	frame=t_frame;
	flow=frame->flow;

	for( int k=0;k<4;++k ){
		reg_colors[k]=countBits( frame->reg_masks[k] );
	}

	nodes.clear();
	max_spill_id=0;//0x7fffffff;

	n_passes=0;
	n_spills=0;

	for(;;){
		if( ++n_passes==100 ){
			cout<<"INTERNAL ERROR! Register allocator terminally confused!"<<endl;
			abort();
		}
		if( allocRegs() ) break;
	}

#ifdef _DEBUG_ALLOCREGS
	if( n_spills ){
		cout<<frame->fun->sym->value<<" passes="<<n_passes<<" spills="<<n_spills<<endl;
	}
#endif
}
