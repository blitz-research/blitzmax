
#include "cgstd.h"

#include "cgframe.h"
#include "cgallocregs.h"
#include "cgutil.h"
#include "cgdebug.h"
#include "cgint64.h"

typedef map<string,CGExp*> IdExpMap;

CGFrame::CGFrame( CGFun *_fun ):fun(_fun),flow(0),int64ret(0){
	asm_it=assem.end;
	big_endian=!(little_endian=env_config.count("x86")?true:false);
}

CGFrame::~CGFrame(){
	deleteFlow();
}

CGMem *CGFrame::int64el( CGMem *i64,int n ){
	CGMem *m=CG::mem(CG_INT32,i64->exp,i64->offset+n);
	m->flags=i64->flags;
	return m;
}

CGMem *CGFrame::int64lo( CGMem *i64 ){
	return int64el( i64,big_endian ? 4 : 0 );
}

CGMem *CGFrame::int64hi( CGMem *i64 ){
	return int64el( i64,big_endian ? 0 : 4 );
}

//****************** Linearize ********************
struct CGLinearizer : public CGVisitor{
	CGFrame *frame;
	
	CGLinearizer( CGFrame *f ):frame(f){}
	
	CGStm *visit( CGStm *stm ){
		if( stm->nop() || stm->seq() ) return stm;
		frame->fun->stms.push_back(stm);
		return stm;
	}
	
	CGExp *visit( CGExp *exp ){
	
		if( CGEsq *t=exp->esq() ) return t->rhs;
		
		if( exp->type==CG_INT64 ) return exp;
		
		if( CGCvt *t=exp->cvt() ){
			if( t->isint() && t->exp->isfloat() ){
				if( env_config.count("x86") ){
					exp=CG::cvt(t->type,CG::jsr(CG_INT32,"bbFloatToInt",CG::cvt(CG_FLOAT64,t->exp)));
				}
			}
		}else if( CGUop *t=exp->uop() ){
			string iop,fop;
			switch( t->op ){
			case CG_ABS:iop="bbIntAbs";fop="bbFloatAbs";break;
			case CG_SGN:iop="bbIntSgn";fop="bbFloatSgn";break;
			}
			if( t->isint() && iop.size() ){
				exp=CG::cvt(t->type,CG::jsr(CG_INT32,iop,CG::cvt(CG_INT32,t->exp)));
			}else if( t->isfloat() && fop.size() ){
				exp=CG::cvt(t->type,CG::jsr(CG_FLOAT64,fop,CG::cvt(CG_FLOAT64,t->exp)));
			}
		}else if( CGBop *t=exp->bop() ){
			string iop,fop;
			switch( t->op ){
			case CG_MOD:fop="bbFloatMod";break;
			case CG_MIN:iop="bbIntMin";fop="bbFloatMin";break;
			case CG_MAX:iop="bbIntMax";fop="bbFloatMax";break;
			}
			if( t->isint() && iop.size() ){
				exp=CG::cvt(t->type,CG::jsr(CG_INT32,iop,CG::cvt(CG_INT32,t->lhs),CG::cvt(CG_INT32,t->rhs)));
			}else if( t->isfloat() && fop.size() ){
				exp=CG::cvt(t->type,CG::jsr(CG_FLOAT64,fop,CG::cvt(CG_FLOAT64,t->lhs),CG::cvt(CG_FLOAT64,t->rhs)));
			}
		}
		return exp;
	}
};

void CGFrame::linearize(){

	CGFun *in=fun;
	fun=CG::fun( in->type,in->call_conv,in->sym,in->self );
	
	if( int64ret ) fun->args.push_back( int64ret );
	
	int k;
	for( k=0;k<in->args.size();++k ){
		CGExp *arg=in->args[k];
		if( arg->type!=CG_INT64 ){
			fun->args.push_back( arg );
			continue;
		}
		assert( arg->mem() );
		fun->args.push_back( int64el(arg->mem(),0) );
		fun->args.push_back( int64el(arg->mem(),4) );
	}
	
	CGLinearizer vis( this );
	
	for( k=0;k<in->stms.size();++k ) in->stms[k]->visit( vis );
}

//**************** Fix Symbols ********************
struct CGSymFixer : public CGVisitor{
	CGFrame *frame;
	
	map<CGExp*,CGExp*> done;
	
	CGSymFixer( CGFrame *f ):frame(f){}

	CGExp *visit( CGExp *exp ){
		
		CGSym *t=exp->sym();
		if( !t || t->linkage==CG_INTERNAL ) return exp;
		
		map<CGExp*,CGExp*>::iterator it=done.find(t);
		if( it!=done.end() ) return it->second;
		
		string id=frame->fixSym( t->value );
		
		if( id==t->value ){
			exp=t;
		}else if( CGDat *d=exp->dat() ){
			CGDat *t;
			if( d->linkage==CG_INTERNAL ) t=CG::dat();
			else t=CG::dat(id);
			t->exps=d->exps;
			exp=t;
		}else{
			exp=CG::sym(id,t->linkage);
		}
		
		done.insert( make_pair(t,exp) );
		return exp;
	}
};

void CGFrame::fixSymbols(){

	CGSymFixer vis( this );
	
	fun=CG::visitFun( fun,vis );
}

//************* Find Escaping Tmps ****************
struct CGEscFinder : public CGVisitor{
	CGFrame *frame;
	
	CGEscFinder( CGFrame *f ):frame(f){}

	CGExp *visit( CGExp *exp ){
		if( CGLea *p=exp->lea() ){
			CGTmp *t=p->exp->tmp();
			if( !t ) return exp;
			if( frame->tmps.find(t->ident)==frame->tmps.end() ){
				frame->tmps.insert( make_pair(t->ident,frame->allocLocal(t->type)) );
			}
		}else if( CGTmp *t=exp->tmp() ){
			//always spill bytes, shorts, longs...
			if( t->type==CG_INT8 || t->type==CG_INT16 || t->type==CG_INT64 ){
				if( frame->tmps.find(t->ident)==frame->tmps.end() ){
					frame->tmps.insert( make_pair(t->ident,frame->allocLocal(t->type)) );
				}
			}
		}
		return exp;
	}
};

void CGFrame::findEscapes(){

	if( fun->type==CG_INT64 ) int64ret=reg(CG_PTR);

	CGEscFinder vis( this );
	
	fun=CG::visitFun( fun,vis );
}

//**************** Rename tmps ********************
struct CGTmpRenamer : public CGVisitor{
	CGFrame *frame;
	
	CGTmpRenamer( CGFrame *f ):frame(f){}
	
	CGExp *visit( CGExp *exp ){
		if( CGTmp *t=exp->tmp() ){
			return tmpReg( t );
		}
		return exp;
	}

	CGExp *tmpReg( CGTmp *t ){
		IdExpMap::iterator it=frame->tmps.find(t->ident);

		if( it==frame->tmps.end() ){

			CGReg *owner=0;
			if( t->owner ) owner=tmpReg( t->owner )->reg();

			it=frame->tmps.insert( make_pair(t->ident,frame->reg(t->type,owner)) ).first;
		}
		return it->second;
	}
};

void CGFrame::renameTmps(){

	CGTmpRenamer vis( this );

	fun=CG::visitFun( fun,vis );
}

//**************** PreOptimize ********************
static int shifter( int n ){
	int k;
	for( k=0;k<32;++k ) if( n==(1<<k) ) return k;
	return -1;
}

struct CGPreOpter : public CGVisitor{
	CGFrame *frame;
	
	CGPreOpter( CGFrame *f ):frame(f){}

	CGStm *visit( CGStm *stm ){
		if( CGBcc *t=stm->bcc() ){
			if( CGScc *p=t->lhs->scc() ){
				if( CGLit *q=t->rhs->lit() ){
					if( !q->int_value ){
						if( t->cc==CG_NE ){
							//bcc NE,scc,0,sym
							return CG::bcc( p->cc,p->lhs,p->rhs,t->sym );
						}else if( t->cc==CG_EQ ){
							//bcc EQ,scc,0,sym
							return CG::bcc( CG::swapcc(p->cc),p->lhs,p->rhs,t->sym );
						}
					}
				}
			}
			return stm;
		}
		return stm;
	}


	CGExp *visit( CGExp *exp ){
	
		if( CGCvt *t=exp->cvt() ){
			//remove cvt between same types
			CGExp *e=t->exp;
			if( t->type==e->type ) exp=e;
			return exp;
		}
		
		if( CGMem *t=exp->mem() ){
			//remove mem(lea(mem),0)...
			CGExp *e=t->exp;
			CGLea *p=e->lea();
			assert( !p || p->exp->mem() );
			if( p && !t->offset && t->type==p->exp->mem()->type ) exp=p->exp;
			return exp;
		}
		
		if( CGUop *t=exp->uop() ){
			//const precalc unary op
			if( t->isfloat() ) return exp;
			if( CGLit *p=t->exp->lit() ){
				int n=p->int_value;
				switch( t->op ){
				case CG_NOT:exp=CG::lit(~n);break;
				case CG_NEG:exp=CG::lit(-n);break;
				}
			}
			return exp;
		}
		
		if( CGBop *t=exp->bop() ){
			if( t->isfloat() ) return exp;

			//const precalc binary op
			CGLit *p=t->lhs->lit(),*q=t->rhs->lit();
			
			if( p && !q && t->commutes() ){
				//put const on RHS in commuting const,non-const BOPs.
				std::swap(p,q);
				exp=t=CG::bop(t->op,t->rhs,q);
			}
			
			if( p && q ){
				//const,const
				int x=p->int_value,y=q->int_value;
				switch( t->op ){
				case CG_ADD:exp=CG::lit(x+y);break;
				case CG_SUB:exp=CG::lit(x-y);break;
				case CG_MUL:exp=CG::lit(x*y);break;
				case CG_DIV:assert(y);exp=CG::lit(x/y);break;
				case CG_MOD:assert(y);exp=CG::lit(x%y);break;
				case CG_AND:exp=CG::lit(x&y);break;
				case CG_ORL:exp=CG::lit(x|y);break;
				case CG_XOR:exp=CG::lit(x^y);break;
				case CG_SHL:exp=CG::lit(x<<y);break;
				case CG_SHR:exp=CG::lit((int)((unsigned)x>>(unsigned)y));break;
				case CG_SAR:exp=CG::lit(x>>y);break;
				}
			}else if( p ){
				//const,non-const (ie: non-commuting)
				switch( p->int_value ){
				case 0:
					switch( t->op ){
					case CG_DIV:case CG_MOD:
					case CG_SHL:case CG_SHR:case CG_SAR:
						exp=CG::lit0;break;
					}
					break;
				}
			}else if( q ){
				//non-const,const
				switch( q->int_value ){
				case 0:
					switch( t->op ){
					case CG_ADD:case CG_SUB:
					case CG_ORL:case CG_XOR:
					case CG_SHL:case CG_SHR:case CG_SAR:
						exp=t->lhs;break;
					case CG_MUL:case CG_AND:
						exp=CG::lit0;break;
					}
					break;
				case 1:
					switch( t->op ){
					case CG_MUL:case CG_DIV:
						exp=t->lhs;break;
					}
					break;
				}
			}
			return exp;
		}
		return exp;
	}
};

void CGFrame::preOptimize(){

	CGPreOpter vis( this );
	
	fun=CG::visitFun( fun,vis );
}

//****************** GenAssem *********************
void CGFrame::genAssem(){
	assem.clear();
	asm_it=assem.end;
	genFun();
}

//**************** Create flow ********************
void CGFrame::createFlow(){
	deleteFlow();
	flow=new CGFlow(assem);
	flow->liveness();
}

//**************** Create a reg *******************
CGReg *CGFrame::reg( int type,CGReg *owner,int color ){
	assert( type!=CG_INT64 );
	CGReg *r=new CGReg;
	r->type=type;
	r->id=regs.size();
	r->owner=owner;
	r->color=color;
	regs.push_back(r);
	return r;
}

//*************** Generate assem ******************
static CGIntSet *genUse;

CGAsm *CGFrame::gen( CGStm *stm,const char *fmt,... ){
	CGAsm *as;
	if( fmt ){
		char buf[256];
		buf[255]=0;

		va_list args;
		va_start( args,fmt );
		vsprintf( buf,fmt,args );
		assert( !buf[255] );

		as=new CGAsm( stm,buf );

	}else{
		as=new CGAsm( stm,"" );
	}
	
	if( genUse ) as->use.insert( *genUse );
	
	asm_it=assem.insert(as,asm_it)->succ;
	return as;
}

//*************** Elim dead code ******************
void CGFrame::optDeadCode(){
	for(;;){
		bool changed=false;
		CGBlockIter blk_it;
		for( blk_it=flow->blocks.begin();blk_it!=flow->blocks.end();++blk_it ){
			CGBlock *blk=*blk_it;

			CGAsm *as=blk->end;

			CGIntSet live=blk->live_out;

			while( as!=blk->begin ){
				as=as->pred;

				bool elim=false;

				CGMov *t=as->stm->mov();

				if( t ){
					CGReg *lhs=t->lhs->reg();
					CGReg *rhs=t->rhs->reg();
					if( lhs && rhs && lhs==rhs ){
						elim=true;
					}else if( lhs && !t->rhs->sideEffects() && !live.count(lhs->id) ){
						elim=true;
					}
				}

				if( elim ){
					as=assem.erase(as);
					changed=true;
				}else{
					live.erase( as->def );
					live.insert( as->use );
				}
			}
		}
		if( !changed ) break;
		flow->liveness();
	}
}

//*************** Optimize loads ******************
/*
This is dodgy and probably not worth it...
CGMov to reg should eliminate any loads which depend on reg - this doesn't.
*/
void CGFrame::optDupLoads(){
	/*
	vector<CGMov*> loads;

	bool changed=false;

	for( asm_it=assem.begin;asm_it!=assem.end;asm_it=asm_it->succ ){

		CGMov *t=asm_it->stm->mov();
		if( !t || t->lhs->mem() || t->rhs->sideEffects() ){
			loads.clear();
			continue;
		}

		if( !t->rhs->mem() ){
			continue;
		}

		int k;
		for( k=0;k<loads.size();++k ){
			if( !t->rhs->equals(loads[k]->rhs) ) continue;
			//found a load!
			cout<<"Eliminating load!"<<endl;
			asm_it=assem.erase(asm_it);
			genStm( CG::mov(t->lhs,loads[k]->lhs) );
			asm_it=asm_it->pred;
			changed=true;
			break;
		}
		if( k==loads.size() ) loads.push_back( t );
	}
	if( changed ) flow->liveness();
	*/
}

//*************** Allocate regs *******************
struct Spiller : public CGVisitor{

	CGReg *reg;
	CGExp *exp;
	CGIntSet owners;

	Spiller( CGReg *r,CGExp *e ):reg(r),exp(e){}

	CGExp *visit( CGExp *e ){
		CGReg *t=e->reg();
		if( t!=reg ) return e;
		
		while( t=t->owner ){
			owners.insert( t->id );
		}

		return exp;
		/*
		if( t==reg ) return exp;
		CGReg *r=reg;
		while( r=r->owner ){
			if( r==t ) owned.insert( r->id );
		}
		return e;
		*/
	}
};

void CGFrame::spillReg( CGReg *reg,CGExp *exp ){

	if( !exp ) exp=allocSpill(reg);

	int i;
	for( i=0;i<regs.size();++i ){
		if( regs[i]->owner==reg ) regs[i]->owner=0;
	}

	Spiller spiller( reg,exp );

	asm_it=assem.begin;
	while( asm_it!=assem.end ){
		spiller.owners.clear();
		CGStm *stm=asm_it->stm->visit( spiller );
		if( stm==asm_it->stm ){
			asm_it->use.erase( reg->id );
			asm_it=asm_it->succ;
			continue;
		}
		asm_it=assem.erase( asm_it );
		genUse=&spiller.owners;
		genStm( stm );
		genUse=0;
		/*
		asm_it=assem.erase( asm_it );
		genStm( stm );
		asm_it->pred->use.insert( spiller.owned );
		*/
	}
}

void CGFrame::allocRegs(){

	cgAllocRegs( this );
	
	CGAsm *as=assem.begin;

	while( as!=assem.end ){

		if( CGMov *t=as->stm->mov() ){
			CGReg *lhs=t->lhs->reg(),*rhs=t->rhs->reg();
			if( lhs && rhs && lhs->color==rhs->color ){
				as=assem.erase(as);
				continue;
			}
		}

		char buf[256],*q=buf;
		const char *p=as->assem;

		while( const char *t=strchr(p,'\'') ){

			memcpy(q,p,t-p);
			q+=t-p;

			int n=0,c;
			while( isdigit(c=*++t) ) n=n*10+(c-'0');

			CGReg *r=regs[n];

			int bank=reg_banks[r->type];
			const char *name=reg_names[bank][r->color];

			strcpy( q,name );
			q+=strlen(q);

			p=t;
		}

		if( q!=buf ){
			strcpy(q,p);
			as->assem=strdup(buf);
		}

		as=as->succ;
	}
}

void CGFrame::deleteFlow(){
	if( flow ){
		delete flow;
		flow=0;
	}
}

void CGFrame::peepOpt(){
	CGAsm *as;
	for( as=assem.begin;as!=assem.end;as=as->succ ){
		if( CGBra *p=as->stm->bra() ){
			if( CGLab *q=as->succ->stm->lab() ){
				if( p->sym->value==q->sym->value ){
					cout<<"Erasing:"<<as->assem<<endl;
					as=assem.erase( as );
					continue;
				}
			}
		}
	}
}

