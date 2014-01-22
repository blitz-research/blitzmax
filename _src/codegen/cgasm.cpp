
#include "cgstd.h"
#include "cgasm.h"
#include "cgutil.h"

struct UseFinder : public CGVisitor{

	CGAsm *as;

	UseFinder( CGAsm *as ):as(as){}

	CGExp *visit( CGExp *e ){
		CGReg *r=e->reg();
		while( r ){
			as->use.insert(r->id);
			r=r->owner;
		}
		return e;
	}
};

CGAsm::CGAsm( CGStm *t,const char *s ):succ(0),pred(0),stm(t),assem(strdup(s)){
	assert(stm);
	assert(assem);
	genUseDef();
}

void CGAsm::genUseDef(){

	use.clear();
	def.clear();
	UseFinder uf(this);

	if( CGXop *t=stm->xop() ){
		if( CGReg *r=t->def ){
			def.insert( r->id );
		}
		if( t->exp ) t->exp->visit( uf );
		return;
	}

	if( CGMov *t=stm->mov() ){
		if( CGReg *r=t->lhs->reg() ){
			def.insert( r->id );
			t->rhs->visit( uf );
			return;
		}
	}

	stm->visit( uf );
}

CGAsmSeq::CGAsmSeq():begin(0),end(0){
	clear();
}

void CGAsmSeq::clear(){
	begin=end=new CGAsm(CG::nop(),"");
}

CGAsm *CGAsmSeq::erase( CGAsm *as ){
	CGAsm *succ=as->succ;
	if( as->pred ) as->pred->succ=succ;
	else begin=succ;
	succ->pred=as->pred;
	return succ;
}

CGAsm *CGAsmSeq::insert( CGAsm *as,CGAsm *succ ){
	as->succ=succ;
	if( as->pred=succ->pred ) as->pred->succ=as;
	else begin=as;
	succ->pred=as;
	return as;
}
