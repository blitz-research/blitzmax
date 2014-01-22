
#include "cgstd.h"

#include "cgdebug.h"

#include <typeinfo>

static const char *ccSym( int cc ){
	switch( cc ){
	case CG_EQ:return "EQ";
	case CG_NE:return "NE";
	case CG_LT:return "LT";
	case CG_GT:return "GT";
	case CG_LE:return "LE";
	case CG_GE:return "GE";
	case CG_LTU:return "LTU";
	case CG_GTU:return "GTU";
	case CG_LEU:return "LEU";
	case CG_GEU:return "GEU";
	}
	assert(0);
	return 0;
}

static const char *uopSym( int op ){
	return "UOP";
}

static const char *bopSym( int op ){
	switch( op ){
	case CG_ADD:return "add";
	case CG_SUB:return "sub";
	case CG_MUL:return "mul";
	case CG_DIV:return "div";
	case CG_MOD:return "mod";
	case CG_AND:return "and";
	case CG_ORL:return "orl";
	case CG_XOR:return "xor";
	case CG_SHL:return "shl";
	case CG_SHR:return "shr";
	case CG_SAR:return "sar";
	}
	assert(0);
	return 0;
}

static const char *typeSym( int ty ){
	switch( ty ){
	case CG_PTR:return "PTR";
	case CG_VOID:return "VOID";
	case CG_INT8:return "INT8";
	case CG_INT16:return "INT16";
	case CG_INT32:return "INT32";
	case CG_INT64:return "INT64";
	case CG_FLOAT32:return "FLOAT32";
	case CG_FLOAT64:return "FLOAT64";
	case CG_CSTRING:return "CSTRING";
	case CG_BSTRING:return "BSTRING";
	}
	assert(0);
	return 0;
}

ostream &operator<<( ostream &o,CGStm *stm ){

	if( !stm ) return o;

	if( CGNop *t=stm->nop() ){
		o<<"nop";
	}else if( CGMov *t=stm->mov() ){
		o<<"mov "<<t->lhs<<','<<t->rhs;
	}else if( CGLab *t=stm->lab() ){
		o<<"lab "<<t->sym;
	}else if( CGBra *t=stm->bra() ){
		o<<"bra "<<t->sym;
	}else if( CGBcc *t=stm->bcc() ){
		o<<"bcc "<<ccSym(t->cc)<<','<<t->lhs<<','<<t->rhs<<","<<t->sym;
	}else if( CGRet *t=stm->ret() ){
		o<<"ret ";if( t->exp ) o<<t->exp;
	}else if( CGSeq *t=stm->seq() ){
		int i;
		o<<"seq ";
		for( i=0;i<t->stms.size();++i ){
			if( i ) o<<',';
			o<<t->stms[i];
		}
	}else if( CGXop *t=stm->xop() ){
		o<<"xop "<<t->op<<','<<t->exp;
	}else if( CGRem *t=stm->rem() ){
		o<<"rem "<<t->comment;
	}else if( CGEva *t=stm->eva() ){
		o<<"eva "<<t->exp;
	}else if( CGAti *t=stm->ati() ){
		o<<"ati "<<t->mem;
	}else if( CGAtd *t=stm->atd() ){
		o<<"atd "<<t->mem<<","<<t->sym;
	}else{
		o<<"STM: "<<typeid(*stm).name()<<endl;
		assert(0);
	}
	return o;
}

ostream &operator<<( ostream &o,CGExp *exp ){

	const char *ty=typeSym(exp->type);

	if( CGMem *t=exp->mem() ){
		o<<"mem("<<ty<<','<<t->exp<<','<<t->offset<<')';
	}else if( CGLea *t=exp->lea() ){
		o<<"lea("<<ty<<","<<t->exp<<')';
	}else if( CGCvt *t=exp->cvt() ){
		o<<"cvt("<<ty<<','<<t->exp<<')';
	}else if( CGUop *t=exp->uop() ){
		o<<uopSym(t->op)<<'('<<ty<<','<<t->exp<<')';
	}else if( CGBop *t=exp->bop() ){
		o<<bopSym(t->op)<<'('<<ty<<','<<t->lhs<<','<<t->rhs<<')';
	}else if( CGJsr *t=exp->jsr() ){
		o<<"jsr("<<ty<<','<<t->exp;
		for( int k=0;k<t->args.size();++k ) o<<','<<t->args[k];
		o<<')';
	}else if( CGVfn *t=exp->vfn() ){
		o<<"vfn("<<ty<<','<<t->exp<<','<<t->self<<')';
	}else if( CGScc *t=exp->scc() ){
		o<<"scc("<<ty<<','<<t->lhs<<','<<t->rhs<<')';
	}else if( CGEsq *t=exp->esq() ){
		o<<"esq("<<ty<<','<<t->lhs<<','<<t->rhs<<')';
	}else if( CGReg *t=exp->reg() ){
		o<<"reg("<<ty<<','<<t->id<<')';
	}else if( CGTmp *t=exp->tmp() ){
		o<<"tmp("<<ty<<','<<t->ident<<')';
	}else if( CGLit *t=exp->lit() ){
		if( t->isfloat() ) o<<ty<<' '<<t->float_value;
		else o<<ty<<' '<<int(t->int_value);
	}else if( CGSym *t=exp->sym() ){
		o<<"sym("<<t->value<<")";
	}else if( CGFrm *t=exp->frm() ){
		o<<"frm";
	}else{
		assert(0);
	}
	return o;
}

ostream &operator<<( ostream &o,const CGStmSeq &seq ){
	for( int k=0;k<seq.size();++k ){
		o<<seq[k]<<endl;
	}
	return o;
}

ostream &operator<<( ostream &o,const CGAsmSeq &seq ){
	CGAsm *as;
	for( as=seq.begin;as!=seq.end;as=as->succ ){
		if( as->stm ) o<<"\t;"<<as->stm<<endl;
		if( as->assem ) o<<as->assem;
	}
	return o;
}

ostream &operator<<( ostream &o,const CGIntSet &t ){
	CGIntSet::const_iterator it;
	for( it=t.begin();it!=t.end();++it ) o<<' '<<*it;
	return o;
}

ostream &operator<<( ostream &o,CGFlow *flow ){

	CGBlockSeq &seq=flow->blocks;

	CGBlockCIter it;

	//enumerate blocks
	map<CGBlock*,int> blk_map;
	for( it=seq.begin();it!=seq.end();++it ){
		blk_map[*it]=blk_map.size();
	}

	for( it=seq.begin();it!=seq.end();++it ){
		CGBlock *blk=*it;
		CGBlockCIter t_it;
		o<<"\t;---block "<<blk_map[blk]<<"---"<<endl;
		o<<"\t;use:"<<blk->use<<endl;
		o<<"\t;def:"<<blk->def<<endl;
		o<<"\t;live_in:"<<blk->live_in<<endl;
		o<<"\t;live_out:"<<blk->live_out<<endl;

		o<<"\t;succ:";
		for( t_it=blk->succ.begin();t_it!=blk->succ.end();++t_it ) o<<' '<<blk_map[*t_it];
		o<<endl;

		o<<"\t;pred:";
		for( t_it=blk->pred.begin();t_it!=blk->pred.end();++t_it ) o<<' '<<blk_map[*t_it];
		o<<endl;

		set<CGBlock*>::iterator d_it;

		o<<"\t;dom:";
		for( d_it=blk->dom.begin();d_it!=blk->dom.end();++d_it ){
			o<<' '<<blk_map[*d_it];
		}
		o<<endl;

		/*
		o<<"\t;loops:";
		for( d_it=blk->loops.begin();d_it!=blk->loops.end();++d_it ){
			o<<' '<<blk_map[*d_it];
		}
		o<<endl;
		*/

		o<<"\t;loop_level:"<<blk->loop_level<<endl;

		o<<endl;
		CGAsm *as=blk->begin;
		while( as!=blk->end ){
			if( as->stm ) o<<"\t;"<<as->stm<<endl;
			if( as->def.size() ) o<<"\t;def="<<as->def<<endl;
			if( as->use.size() ) o<<"\t;use="<<as->use<<endl;
			if( as->assem ) o<<as->assem;
			as=as->succ;
		}

		o<<endl;
	}

	return o;
}

ostream &operator<<( ostream &o,CGFun *fun ){
	for( int k=0;k<fun->stms.size();++k ){
		o<<fun->stms[k]<<endl;
	}
	return o;
}

bool cgVerify( ostream &o,CGExp *exp ){
	return true;
}

bool cgVerify( ostream &o,CGStm *stm ){
	return true;
}

bool cgVerify( ostream &o,CGFun *fun ){
	return true;
}
