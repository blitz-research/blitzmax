
#include "cgstd.h"

#include "cgframe_ppc.h"
#include "cgmodule_ppc.h"

#include "cgutil.h"
#include "cgdebug.h"

using namespace CG;

enum{
	MEM_PARAM=1,
	MEM_LOCAL=2
};

CGMem *CGFrame_PPC::genMem( CGMem *m,char *buf ){
	CGReg *r=genExp(m->exp);
	const char *q="";
	switch( m->flags ){
	case MEM_PARAM:q="__FRAME+";break;
	case MEM_LOCAL:q="__LOCAL+";break;
	}
	sprintf( buf,"%s%i('%i)",q,m->offset,r->id );
	CGMem *t=mem(m->type,r,m->offset);
	t->flags=m->flags;
	return t;
}

CGReg *CGFrame_PPC::genLoad( CGMem *m ){

	CGReg *r=reg(m->type);
	
	const char *op=0;
	switch( m->type ){
	case CG_INT8:op="lbz";break;
	case CG_INT16:op="lhz";break;
	case CG_FLOAT32:op="lfs";break;
	case CG_FLOAT64:op="lfd";break;
	default:op="lwz";
	}
	char buf[256];
	m=genMem(m,buf);
	gen( mov(r,m),
		"\t%s\t'%i,%s\n",op,r->id,buf );
	return r;
}

void CGFrame_PPC::genStore( CGMem *m,CGExp *e ){

	CGReg *r=genExp(e);
	
	const char *op=0;
	switch( m->type ){
	case CG_INT8:op="stb";break;
	case CG_INT16:op="sth";break;
	case CG_FLOAT32:op="stfs";break;
	case CG_FLOAT64:op="stfd";break;
	default:op="stw";
	}
	char buf[256];
	m=genMem(m,buf);
	gen( mov( m,r ),"\t%s\t'%i,%s\n",op,r->id,buf );
}

void CGFrame_PPC::genCopy( CGReg *d,CGReg *r ){
	const char *op=d->isint() ? "mr" : "fmr";
	gen( mov(d,r),"\t%s\t'%i,'%i\n",op,d->id,r->id );
}

void CGFrame_PPC::genMov( CGExp *lhs,CGExp *rhs ){
	if( lhs->equals(rhs) ) return;
	if( CGMem *t=lhs->mem() ){
		genStore( t,rhs );
	}else if( CGReg *t=lhs->reg() ){
		genCopy( t,genExp( rhs ) );
	}else{
		assert(0);
	}
}

CGReg *CGFrame_PPC::genExp( CGExp *e ){
	if( CGReg *t=e->reg() ){
		return t;
	}else if( CGMem *t=e->mem() ){
		return genLoad( t );
	}else if( CGLea *t=e->lea() ){
		return genLea( t );
	}else if( CGCvt *t=e->cvt() ){
		return genCvt( t );
	}else if( CGUop *t=e->uop() ){
		return genUop( t );
	}else if( CGBop *t=e->bop() ){
		return genBop( t );
	}else if( CGScc *t=e->scc() ){
		return genScc( t );
	}else if( CGJsr *t=e->jsr() ){
		return genJsr( t );
	}else if( CGLit *t=e->lit() ){
		return genLit( t );
	}else if( CGSym *t=e->sym() ){
		return genSym( t );
	}else if( CGFrm *t=e->frm() ){
		return genFrm( t );
	}
	cout<<e<<endl;
	assert(0);
	return 0;
}

CGExp *CGFrame_PPC::genExp( CGExp *e,char *buf,int &mask ){
	if( mask & (EA_SIMM|EA_UIMM) ){
		if( CGLit *t=e->lit() ){
			if( t->isint() ){
				int n=t->int_value;
				if( (mask & EA_SIMM) && n>=-32768 && n<32768 ){
					sprintf( buf,"%i",n );
					mask=EA_SIMM;
					return e;
				}
				if( (mask & EA_UIMM) && n>=0 && n<65536 ){
					sprintf( buf,"%i",n );
					mask=EA_UIMM;
					return e;
				}
			}
		}
	}
	CGReg *r=genExp( e );
	sprintf( buf,"'%i",r->id );
	mask=0;
	return r;
}

CGReg *CGFrame_PPC::genLea( CGLea *e ){

	CGReg *r=reg(e->type);
	CGMem *m=e->exp->mem();

	assert( m );

	char buf[256];
	m=genMem(m,buf);
	gen( mov(r,lea(m)),"\tla\t'%i,%s\n",r->id,buf );
	return r;
}

CGReg *CGFrame_PPC::genCvt( CGCvt *e ){

	CGReg *r=reg(e->type);
	
	if( r->isint() && e->exp->isint() ){
		//int to int
		CGReg *t=genExp(e->exp);
		if( r->type==CG_INT8 && e->exp->type!=CG_INT8 ){
			gen( mov(r,cvt(r->type,t)),
				"\tandi.\t'%i,'%i,0xff\n",
				r->id,t->id );
		}else if( r->type==CG_INT16 && e->exp->type==CG_INT32 ){
			gen( mov(r,cvt(r->type,t)),
				"\tandi.\t'%i,'%i,0xffff\n",
				r->id,t->id );
		}else{
			gen( mov(r,cvt(r->type,t)),
				"\tmr\t'%i,'%i\n",
				r->id,t->id );
		}
	}else if( r->isfloat() && e->exp->isfloat() ){
		//float to float
		CGReg *t=genExp(e->exp);
		gen( mov(r,cvt(r->type,t)),
			"\tfmr\t'%i,'%i\n",
			r->id,t->id );
	}else if( r->isint() && e->exp->isfloat() ){
		//float to int
		if( tmp_disp8<0 ){
			tmp_disp8=local_sz;
			local_sz+=8;
		}
		int off;
		const char *op;
		switch( r->type ){
		case CG_INT8:off=7;op="lbz";break;
		case CG_INT16:off=6;op="lhz";break;
		case CG_INT32:case CG_PTR:off=4;op="lwz";break;
		default:assert(0);
		}
		CGReg *t=genExp(e->exp),*f=F[0];
		
		CGAsm *as=gen( mov(r,cvt(e->type,t)),
			"\tfctiwz\t'%i,'%i\n"
			"\tstfd\t'%i,__LOCAL+%i(r1)\n"
			"\t%s\t'%i,__LOCAL+%i+%i(r1)\n",
			f->id,t->id,
			f->id,tmp_disp8,
			op,r->id,tmp_disp8,off );
		as->def.insert(f->id);
		
	}else if( r->isfloat() && e->exp->isint() ){
		//int to float
		if( tmp_disp8<0 ){
			tmp_disp8=local_sz;
			local_sz+=8;
		}
		if( !mod_ppc->fp_const ){
			mod_ppc->fp_const=sym();
		}
		CGReg *t=reg(CG_INT32),*f=F[0];
		
		string p=mod_ppc->fp_const->value;

		genMov( t,genExp(e->exp) );

		CGAsm *as=gen( mov(r,cvt(e->type,t)),
			"\tlis\tr0,0x4330\n"
			"\tstw\tr0,__LOCAL+%i(r1)\n"
			"\txoris\t'%i,'%i,0x8000\n"
			"\tstw\t'%i,__LOCAL+%i+4(r1)\n"
			"\tlis\t'%i,ha16(%s)\n"
			"\tlfd\t'%i,lo16(%s)('%i)\n"
			"\tlfd\t'%i,__LOCAL+%i(r1)\n"
			"\tfsub\t'%i,'%i,'%i\n",
			tmp_disp8,
			t->id,t->id,
			t->id,tmp_disp8,
			t->id,p.c_str(),
			f->id,p.c_str(),t->id,
			r->id,tmp_disp8,
			r->id,r->id,f->id );
		as->use.insert(t->id);
		as->def.insert(t->id);
		as->def.insert(f->id);

	}else{
		assert(0);
	}

	return r;

	/* int r3 to float f1
	addis R0,R0,0x4330 # R0 = 0x43300000
	stw R0,disp(R1) # store upper half
	xoris R3,R3,0x8000 # flip sign bit
	stw R3,disp+4(R1) # store lower half
	lfd FR1,disp(R1) # float load double of value
	fsub FR1,FR1,FR2 # subtract 0x4330000080000000
	*/

	/* float f1 to int r3
	fctiw[z] FR2,FR1 # convert to integer
	stfd FR2,disp(R1) # copy unmodified to memory
	lwz R3,disp+4(R1) # load the low-order 32 bits
	*/
}

CGReg *CGFrame_PPC::genUop( CGUop *e ){

	const char *op=0;
	
	switch( e->op ){
	case CG_NOT:assert(e->isint());op="not";break;
	case CG_NEG:op=e->isfloat() ? "fneg" : "neg";break;
	default:assert(0);
	}
	
	CGReg *r=reg(e->type);
	CGReg *s=genExp(e->exp);
	gen( mov(r,uop(e->op,s)),"\t%s\t'%i,'%i\n",op,r->id,s->id );
	return r;
}

static int shifter( int n ){
	int k;
	for( k=0;k<32;++k ) if( (1<<k)==n ) return k;
	return -1;
}

CGReg *CGFrame_PPC::genBop( CGBop *e ){

	if( e->isint() && (e->op==CG_MUL || e->op==CG_DIV) ){
		if( CGLit *c=e->rhs->lit() ){
			int i=c->int_value;
			if( e->op==CG_MUL ){
				int n=shifter(i);
				if( n!=-1 ){
					CGReg *r=reg(e->type);
					CGReg *t=genExp(e->lhs);
					gen( mov(r,bop(e->op,t,c)),
						"\tslwi\t'%i,'%i,%i\n",
						r->id,t->id,n );
						return r;
				}
			}else if( e->op==CG_DIV ){
				int n=shifter(i);
				if( n!=-1 ){
					CGReg *r=reg(e->type);
					CGReg *t=genExp(e->lhs);
					gen( mov(r,bop(e->op,t,c)),
						"\tsrawi\t'%i,'%i,%i\n"
						"\taddze\t'%i,'%i\n",
						r->id,t->id,n,r->id,r->id );
					return r;
				}
			}
		}
	}

	CGReg *r=reg(e->type);

	const char *op=0;
	
	int mask=0;

	if( e->isfloat() ){
		switch( e->op ){
		case CG_ADD:op="fadd";break;
		case CG_SUB:op="fsub";break;
		case CG_MUL:op="fmul";break;
		case CG_DIV:op="fdiv";break;
		}
	}else{
		switch( e->op ){
		case CG_ADD:op="add";mask=EA_SIMM;break;
		case CG_SUB:op="sub";mask=EA_SIMM;break;
		case CG_MUL:op="mullw";mask=EA_SIMM;break;
		case CG_DIV:op="divw";break;
		case CG_AND:op="and";mask=EA_UIMM;break;
		case CG_ORL:op="or";mask=EA_UIMM;break;
		case CG_XOR:op="xor";mask=EA_UIMM;break;
		case CG_SHL:op="slw";break;
		case CG_SHR:op="srw";break;
		case CG_SAR:op="sraw";break;
		}
	}

	if( op ){

		char buf[256];
		CGReg *lhs=genExp(e->lhs);
		CGExp *rhs=genExp(e->rhs,buf,mask);
		const char *ext="";
		if( mask ){
			ext="i";
			switch( e->op ){
			case CG_AND:ext="i.";break;
			case CG_MUL:op="mull";break;
			}
		}
	
		gen( mov(r,bop(e->op,lhs,rhs)),
			"\t%s%s\t'%i,'%i,%s\n",op,ext,r->id,lhs->id,buf );

		return r;
	}

	if( e->op==CG_MOD && e->isint() ){
		CGReg *lhs=genExp(e->lhs);
		CGReg *rhs=genExp(e->rhs);
		//divw Rt,Ra,Rb # quotient = (int)(Ra / Rb)
		//mullw Rt,Rt,Rb # quotient * Rb
		//subf Rt,Rt,Ra # remainder = Ra - quotient * Rb
		gen( mov(r,bop(e->op,lhs,rhs)),
			"\tdivw\tr0,'%i,'%i\n"
			"\tmullw\tr0,r0,'%i\n"
			"\tsubf\t'%i,r0,'%i\n",
			lhs->id,rhs->id,rhs->id,r->id,lhs->id );
		return r;
	}
	assert(0);
	return 0;
}

CGReg *CGFrame_PPC::genScc( CGScc *e ){

	CGReg *r=reg(CG_INT32);
	
	CGReg *lhs=genExp(e->lhs);
	CGReg *rhs=genExp(e->rhs);

	int bit=0;
	char cror[256];cror[0]=0;
	char exor[256];exor[0]=0;

	const char *op=lhs->isfloat() ? "fcmpu" : "cmpw";

	switch( e->cc ){
	case CG_LT:bit=29;break;
	case CG_GT:bit=30;break;
	case CG_EQ:bit=31;break;
	case CG_LE:bit=0;sprintf(cror,"\tcror\t31,30,28\n");break;
	case CG_GE:bit=0;sprintf(cror,"\tcror\t31,30,29\n");break;
	case CG_NE:bit=31;sprintf(exor,"\txori\t'%i,'%i,1\n",r->id,r->id);break;
	case CG_LTU:bit=29;op="cmplw";break;

	default:assert(0);
	}

	gen( mov(r,scc(e->cc,lhs,rhs)),
		"\t%s\tcr7,'%i,'%i\n%s"
		"\tmfcr\t'%i\n"
		"\trlwinm\t'%i,'%i,%i,31,31\n%s",
		op,lhs->id,rhs->id,cror,r->id,r->id,r->id,bit,exor );
		
	return r;
}

CGReg *CGFrame_PPC::genJsr( CGJsr *e ){
	
	vector<CGExp*> args;

	int k;
	for( k=e->args.size()-1;k>=0;--k ){
		CGExp *arg=e->args[k];
		args.push_back( genExp(e->args[k]) );
	}
	CGExp *ea=e->exp;
	if( CGVfn *t=ea->vfn() ){
		args.push_back( genExp(t->self) );
		ea=t->exp;
	}
	ea=genExp(ea);
	
	int arg_sz=0,fp_id=1;
	for( k=args.size()-1;k>=0;--k ){
		CGExp *t=args[k],*p;
		if( t->isfloat() && fp_id<14 ){
			p=F[fp_id++];
		}else if( t->isfloat() || arg_sz>=32 ){
			p=mem(t->type,R[1],arg_sz+24 );
		}else{
			p=R[arg_sz/4+3];
		}
		arg_sz+=(t->type==CG_FLOAT64) ? 8 : 4;
		genMov( p,t );
		args[k]=p;
	}
	if( arg_sz>param_sz ) param_sz=arg_sz;
        
	CGExp *dst=e->isfloat() ? F[1] : R[3];

	CGAsm *as=gen( mov(dst,jsr(e->type,e->call_conv,ea,args)),
		"\tmtctr\t'%i\n"
		"\tbctrl\n",ea->reg()->id );
		
	for( k=3;k<13;++k ) as->def.insert( R[k]->id );
	for( k=1;k<14;++k ) as->def.insert( F[k]->id );

	CGReg *r=reg( e->type );
	genMov( r,dst );
	return r;
}

CGReg *CGFrame_PPC::genLit( CGLit *e ){

	CGReg *r=reg(e->type);
	
	if( e->isfloat() ){
		CGDat *d=dat();
		d->push_back(e);
		genMov( r,mem(e->type,d,0) );
		return r;
	}
	CGStm *m=mov(r,e);
	int n=e->int_value;
	if( n>=-32768 && n<32768 ){
		//16 bit signed
		gen( m,
			"\tli\t'%i,%i\n",r->id,n );
	}else if( !(n&65535) ){
		//32 bit - 0 low word
		gen( m,
			"\tlis\t'%i,%i\n",r->id,(n>>16) );
	}else{
		//32 bit
		gen( m,
			"\tlis\t'%i,%i\n"
			"\tori\t'%i,'%i,%i\n",r->id,(n>>16),r->id,r->id,(n&65535) );
	}
	return r;
}

CGReg *CGFrame_PPC::genSym( CGSym *e ){
	CGReg *r=reg(e->type);
	if( e->linkage==CG_IMPORT ){
		string t=""+e->value+"$non_lazy_ptr";
		gen( mov(r,e),
			"\tlis\t'%i,ha16(%s)\n"
			"\tlwz\t'%i,lo16(%s)('%i)\n",r->id,t.c_str(),r->id,t.c_str(),r->id );
	}else{
		gen( mov(r,e),
			"\tlis\t'%i,hi16(%s)\n"
			"\tori\t'%i,'%i,lo16(%s)\n",r->id,e->value.c_str(),r->id,r->id,e->value.c_str() );
	}
	return r;
}

CGReg *CGFrame_PPC::genFrm( CGFrm *e ){
	CGReg *r=reg(CG_PTR);
	gen( mov(r,e),
		"\tla\t'%i,__LOCAL(r1)\n",r->id );
	return r;
}

void CGFrame_PPC::genBcc( int cc,CGExp *lhs,CGExp *rhs,CGSym *sym ){

	if( cc==CG_LTU ){
		genBcc( CG_NE,scc(cc,lhs,rhs),lit0,sym );
		return;
	}
	
	int tcc=cc;
	if( bigFun ) cc=CG::swapcc(cc);

	const char *p;
	switch( cc ){
	case CG_LT:p="lt";break;
	case CG_GT:p="gt";break;
	case CG_EQ:p="eq";break;
	case CG_LE:p="le";break;
	case CG_GE:p="ge";break;
	case CG_NE:p="ne";break;
	default:assert(0);
	}
	
	if( lhs->isfloat() ){
		CGReg *x=genExp(lhs);
		CGReg *y=genExp(rhs);
		if( bigFun ){
			CGSym *t=CG::sym();
			gen( bcc(tcc,x,y,sym),
				"\tfcmpu\tcr0,'%i,'%i\n"
				"\tb%s\t%s\n\tb\t%s\n%s:\n",x->id,y->id,p,t->value.c_str(),sym->value.c_str(),t->value.c_str() );
		}else{
			gen( bcc(cc,x,y,sym),
				"\tfcmpu\tcr0,'%i,'%i\n"
				"\tb%s\t%s\n",x->id,y->id,p,sym->value.c_str() );
		}
		return;
	}

	char buf[256];
	int mask=EA_SIMM;
	CGReg *x=genExp(lhs);
	CGExp *y=genExp(rhs,buf,mask);
	const char *ext=mask ? "i" : "";
	if( bigFun ){
		CGSym *t=CG::sym();
		gen( bcc(tcc,x,y,sym),
			"\tcmpw%s\t'%i,%s\n"
			"\tb%s\t%s\n\tb\t%s\n%s:\n",ext,x->id,buf,p,t->value.c_str(),sym->value.c_str(),t->value.c_str() );
	}else{
		gen( bcc(cc,x,y,sym),
			"\tcmpw%s\t'%i,%s\n"
			"\tb%s\t%s\n",ext,x->id,buf,p,sym->value.c_str() );
	}
}

void CGFrame_PPC::genRet( CGExp *e ){
	CGReg *r=0;
	if( e ){
		r=e->isfloat() ? F[1] : R[3];
		genMov(r,e);
	}
	CGAsm *as=gen( ret(r),"\tblr\n" );
	as->use.insert( R[1]->id );
}

string CGFrame_PPC::fixSym( string id ){
	return "_"+id;
}

void CGFrame_PPC::genStm( CGStm *s ){

	if( CGAti *t=s->ati() ){
		char buf[256];
		CGMem *m=genMem( t->mem,buf );
		CGAsm *as=gen( ati(m),
			"\tlwz\tr2,%s\n"
			"\taddi\tr2,r2,1\n"
			"\tstw\tr2,%s\n",
			buf,buf );
		/*
		CGReg *r=genLea( lea(t->mem) );
		CGAsm *as=gen( ati(mem(CG_INT32,r,0)),
			"1:\n"
			"\tlwarx\tr2,0,'%i\n"
			"\taddi\tr2,r2,1\n"
			"\tstwcx.\tr2,0,'%i\n"
			"\tbne\t1b\n",
			r->id,r->id );
		*/
	}else if( CGAtd *t=s->atd() ){
		char buf[256];
		CGMem *m=genMem( t->mem,buf );
		CGAsm *as=gen( atd(m,t->sym),
			"\tlwz\tr2,%s\n"
			"\taddi\tr2,r2,-1\n"
			"\tstw\tr2,%s\n"
			"\tcmpwi\tr2,0\n"
			"\tbne\t%s\n",
			buf,buf,t->sym->value.c_str() );
		/*
		CGReg *r=genLea( lea(t->mem) );
		CGAsm *as=gen( atd(mem(CG_INT32,r,0),t->sym),
			"1:\n"
			"\tlwarx\tr2,0,'%i\n"
			"\taddi\tr2,r2,-1\n"
			"\tstwcx.\tr2,0,'%i\n"
			"\tbne\t1b\n"
			"\tor.\tr2,r2,r2\n"
			"\tbne\t%s\n",
			r->id,r->id,t->sym->value.c_str() );
		*/
	}else if( CGMov *t=s->mov() ){
		genMov( t->lhs,t->rhs );
	}else if( CGLab *t=s->lab() ){
		gen( t,"%s:\n",t->sym->value.c_str() );
	}else if( CGBra *t=s->bra() ){
		gen( t,"\tb\t%s\n",t->sym->value.c_str() );
	}else if( CGBcc *t=s->bcc() ){
		genBcc( t->cc,t->lhs,t->rhs,t->sym );
	}else if( CGEva *t=s->eva() ){
		if( t->exp->dat() ){
			gen( t,"" );
		}else{
			genExp( t->exp );
		}
	}else if( CGRem *t=s->rem() ){
		gen( t,"\t;%s\n",t->comment.c_str() );
	}else if( CGRet *t=s->ret() ){
		genRet( t->exp );
	}else if( CGXop *t=s->xop() ){
		assert(0);
	}else{
		assert(0);
	}
}

void CGFrame_PPC::genFun(){

	param_sz=32;
	tmp_disp8=-1;

	int k,arg_sz=0,fp_id=1;

	//move self to tmp
	if( CGExp *t=fun->self ){
		//get 'this' from stack
		genMov( t,R[3] );
		arg_sz+=4;
	}

	//move args to tmps
	for( k=0;k<fun->args.size();++k ){
		CGExp *t=fun->args[k],*p;
		if( t->isfloat() && fp_id<14 ){
			p=F[fp_id++];
		}else if( t->isfloat() || arg_sz>=32 ){
			CGMem *m=mem(t->type,R[1],arg_sz+24 );
			m->flags=MEM_PARAM;
			p=m;
		}else{
			p=R[arg_sz/4+3];
		}
		arg_sz+=(t->type==CG_FLOAT64) ? 8 : 4;
		genMov( t,p );
	}
	
	//genAsm for statements
	for( k=0;k<fun->stms.size();++k ){
		genStm( fun->stms[k] );
	}
}

CGMem *CGFrame_PPC::allocLocal( int type ){
	CGMem *m=mem(type,R[1],local_sz);
	m->flags=MEM_LOCAL;
	int sz=(type==CG_INT64 || type==CG_FLOAT64) ? 8 : 4;
	local_sz+=sz;
	return m;
}

CGExp *CGFrame_PPC::allocSpill( CGReg *r ){
	return allocLocal( r->type );
}

void CGFrame_PPC::finish(){
}

CGFrame_PPC::CGFrame_PPC( CGFun *fun,CGModule_PPC *mod ):CGFrame(fun),
mod_ppc(mod),local_sz(0){

	bigFun=fun->stms.size()>300;
/*
	if( bigFun ){
		printf( "Big function:%i stms\n",fun->stms.size() );
		fflush( stdout );
	}else{
		printf( "Small function:%i stms\n",fun->stms.size() );
		fflush( stdout );
	}
*/
	
	//int types map to reg bank 0
	reg_banks[CG_INT8]=0;
	reg_banks[CG_INT16]=0;
	reg_banks[CG_INT32]=0;
	reg_banks[CG_PTR]=0;

	//float types map to bank 1
	reg_banks[CG_FLOAT32]=1;
	reg_banks[CG_FLOAT64]=1;

	//available reg masks
	reg_masks[0]=0xfffffff8;	//R0/R1/R2 unavailable!
	reg_masks[1]=0xfffffffe;	//F0 unavailable!

	char *buf;
	
	for( int k=0;k<32;++k ){

		R[k]=reg( CG_INT32,0,k );
		F[k]=reg( CG_FLOAT64,0,k );

		buf=new char[4];
		sprintf( buf,"r%i",k<13 ? k : 31+13-k );
		reg_names[0].push_back( buf );

		buf=new char[4];
		sprintf( buf,"f%i",k );
		reg_names[1].push_back( buf );
	}
}
