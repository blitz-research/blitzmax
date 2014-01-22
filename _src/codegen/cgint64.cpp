
#include "cgstd.h"

#include "cgframe.h"
#include "cgallocregs.h"
#include "cgutil.h"
#include "cgdebug.h"

using namespace CG;

static CGFun *func;
static CGFrame *frame;
static CGMem *i64_dummy;

static void int32ToInt64( CGMem *m,CGExp *exp ){
	func->stms.push_back( mov(frame->int64lo(m),exp) );
	func->stms.push_back( mov(frame->int64hi(m),lit0) );
}

static CGExp *int64ToInt32( CGExp *exp ){
	if( CGLit *t=exp->lit() ){
		return lit((int)(t->int_value));
	}else if( CGMem *t=exp->mem() ){
		return frame->int64lo(t);
	}
	assert(0);
	return 0;
}

static void genInt64Stms( CGMem *m,CGExp *exp ){
	if( CGLit *t=exp->lit() ){
		//mov i64,lit
		CGLit *lo=lit( (int)(t->int_value) );
		CGLit *hi=lit( (int)(t->int_value>>int64(32)) );
		func->stms.push_back( mov(frame->int64lo(m),lo) );
		func->stms.push_back( mov(frame->int64hi(m),hi) );
	}else if( CGMem *t=exp->mem() ){
		func->stms.push_back( mov(frame->int64lo(m),frame->int64lo(t)) );
		func->stms.push_back( mov(frame->int64hi(m),frame->int64hi(t)) );
	}else if( CGJsr *t=exp->jsr() ){
		CGJsr *e=jsr(CG_INT32,t->call_conv,t->exp );
		e->args.push_back( lea(m) );
		for( int k=0;k<t->args.size();++k ) e->args.push_back( t->args[k] );
		func->stms.push_back( eva(e) );
	}else if( CGUop *t=exp->uop() ){
		string f;
		switch( t->op ){
		case CG_NEG:f="bbLongNeg";break;
		case CG_NOT:f="bbLongNot";break;
		case CG_ABS:f="bbLongAbs";break;
		case CG_SGN:f="bbLongSgn";break;
		default:assert(0);
		}
		CGJsr *e=jsr(CG_INT32,f);
		e->args.push_back( lea(m) );
		e->args.push_back( t->exp );
		func->stms.push_back( eva(e) );
	}else if( CGBop *t=exp->bop() ){
		string f;
		switch( t->op ){
		case CG_ADD:f="bbLongAdd";break;
		case CG_SUB:f="bbLongSub";break;
		case CG_MUL:f="bbLongMul";break;
		case CG_DIV:f="bbLongDiv";break;
		case CG_MOD:f="bbLongMod";break;
		case CG_AND:f="bbLongAnd";break;
		case CG_ORL:f="bbLongOrl";break;
		case CG_XOR:f="bbLongXor";break;
		case CG_SHL:f="bbLongShl";break;
		case CG_SHR:f="bbLongShr";break;
		case CG_SAR:f="bbLongSar";break;
		case CG_MIN:f="bbLongMin";break;
		case CG_MAX:f="bbLongMax";break;
		default:assert(0);
		}
		CGJsr *e=jsr(CG_INT32,f);
		e->args.push_back( lea(m) );
		e->args.push_back( t->lhs );
		e->args.push_back( t->rhs );
		func->stms.push_back( eva(e) );
	}else if( CGCvt *t=exp->cvt() ){
		CGExp *e=t->exp;
		switch( e->type ){
		case CG_INT8:   //int8 to int64
			int32ToInt64(m,cvt(CG_INT32,e));
			break;
		case CG_INT16:  //int16 to int64
			int32ToInt64(m,cvt(CG_INT32,e));
			break;
		case CG_PTR:	//ptr to int64
			int32ToInt64(m,e);
			break;
		case CG_INT32:  //int32 to int64
			func->stms.push_back( eva(jsr(CG_INT32,"bbIntToLong",lea(m),e)) );
			break;
		case CG_INT64:
			break;
		case CG_FLOAT32://float32 to int64
			func->stms.push_back( eva(jsr(CG_INT32,"bbFloatToLong",lea(m),cvt(CG_FLOAT64,e))) );
			break;
		case CG_FLOAT64://float64 to int64
			func->stms.push_back( eva(jsr(CG_INT32,"bbFloatToLong",lea(m),e)) );
			break;
		default:
			assert(0);
		}
	}else{
		cout<<exp<<endl;
		assert(0);
	}
}

struct CGInt64StmFixer : public CGVisitor{
	CGFrame *frame;
	
	CGInt64StmFixer( CGFrame *f ):frame(f){}
	
	CGStm *visit( CGStm *stm ){
		if( CGMov *t=stm->mov() ){
			if( t->lhs->type==CG_INT64 ){
				CGMem *lhs=t->lhs->mem();
				assert( lhs );
				genInt64Stms( lhs,t->rhs );
				return stm;
			}
		}else if( CGEva *t=stm->eva() ){
			if( t->exp->type==CG_INT64 ){
				if( !i64_dummy ) i64_dummy=frame->allocLocal( CG_INT64 );
				genInt64Stms( i64_dummy,t->exp );
				return stm;
			}
		}else if( CGRet *t=stm->ret() ){
			if( frame->int64ret ){
				CGMem *lhs=mem(CG_INT64,frame->int64ret,0);
				genInt64Stms( lhs,t->exp );
				func->stms.push_back( ret(0) );
				return stm;
			}
		}else if( CGBcc *t=stm->bcc() ){
			if( t->lhs->type==CG_INT64 ){
				func->stms.push_back( bcc(CG_NE,scc(t->cc,t->lhs,t->rhs),lit0,t->sym) );
				return stm;
			}
		}
		func->stms.push_back( stm );
		return stm; 
	}
};

struct CGInt64ExpFixer : public CGVisitor{
	CGFrame *frame;
	CGFun *fun;
	
	CGInt64ExpFixer( CGFrame *f ):frame(f),fun(frame->fun){}
	
	CGStm *visit( CGStm *stm ){
		func->stms.push_back( stm );
		return stm;
	}
	
	CGExp *visit( CGExp *exp ){
		if( CGScc *t=exp->scc() ){
			if( t->lhs->type!=CG_INT64 ) return exp;
			string f;
			switch( t->cc ){
			case CG_LT:f="bbLongSlt";break;
			case CG_GT:f="bbLongSgt";break;
			case CG_LE:f="bbLongSle";break;
			case CG_GE:f="bbLongSge";break;
			case CG_EQ:f="bbLongSeq";break;
			case CG_NE:f="bbLongSne";break;
			default:assert(0);
			}
			CGJsr *e=jsr(CG_INT32,f,t->lhs,t->rhs);
			return e;
		}else if( CGCvt *t=exp->cvt() ){
			CGExp *e=t->exp;
			if( e->type==CG_INT64 ){
				switch( t->type ){
				case CG_INT8:   //int64 to int8
					return cvt(CG_INT8,int64ToInt32(e));
				case CG_INT16:  //int64 to int16
					return cvt(CG_INT16,int64ToInt32(e));
				case CG_INT32:  //int64 to int32
					return int64ToInt32(e);
				case CG_INT64:
					return e;
				case CG_FLOAT32://int64 to float32
					return cvt(CG_FLOAT32,jsr(CG_FLOAT64,"bbLongToFloat",e));
				case CG_FLOAT64://int64 to float64
					return jsr(CG_FLOAT64,"bbLongToFloat",e);
				}
				assert(0);
			}
		}
		if( exp->type!=CG_INT64 ) return exp;
		if( exp->uop() || exp->bop() || exp->jsr() || exp->cvt() ){
			CGMem *m=frame->allocLocal( CG_INT64 );
			genInt64Stms( m,exp );
			return m;
		}
		return exp;
	}
};

struct CGInt64ArgFixer : public CGVisitor{
	CGFrame *frame;
	
	CGInt64ArgFixer( CGFrame *f ):frame(f){}
	
	CGExp *visit( CGExp *exp ){
		if( CGJsr *t=exp->jsr() ){
			int k;
			for( k=0;k<t->args.size();++k ){
				if( t->args[k]->type==CG_INT64 ) break;
			}
			if( k==t->args.size() ) return exp;
			CGJsr *e=jsr( t->type,t->call_conv,t->exp );
			for( k=0;k<t->args.size();++k ){
				CGExp *arg=t->args[k];
				if( arg->type!=CG_INT64 ){
					e->args.push_back( arg );
					continue;
				}
				if( CGMem *t=arg->mem() ){
					e->args.push_back( frame->int64el(t,0) );
					e->args.push_back( frame->int64el(t,4) );
				}else if( CGLit *t=arg->lit() ){
					assert( t->type==CG_INT64 );
					int *p=(int*)&t->int_value;
					e->args.push_back( lit(p[0]) );
					e->args.push_back( lit(p[1]) );
				}else{
					cout<<arg<<endl;
					assert(0);
				}
			}
			return e;
		}
		return exp;
	}
};

void CGFrame::fixInt64(){
	::func=fun;
	::frame=this;
	::i64_dummy=0;
	
	int k;
	vector<CGStm*> stms;
	
	stms.clear();
	stms.swap( func->stms );
	CGInt64StmFixer stm_vis( this );
	for( k=0;k<stms.size();++k ) stms[k]->visit( stm_vis );
	
	stms.clear();
	stms.swap( func->stms );
	CGInt64ExpFixer exp_vis( this );
	for( k=0;k<stms.size();++k ) stms[k]->visit( exp_vis );
	
	CGInt64ArgFixer arg_vis( this );
	func=visitFun( func,arg_vis );
	
	fun=func;
}
