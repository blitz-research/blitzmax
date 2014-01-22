
#include "cgstd.h"

#include "cgutil.h"
#include "cgframe_x86.h"
#include "cgmodule_x86.h"
#include "cgdebug.h"

using namespace CG;

//Can't use %lld 'coz it doesn't work on mingw!
//#define FMTI64 "%lld"

const char *CGFrame_X86::x86cc( int cc ){
	switch( cc ){
	case CG_EQ:return "e";
	case CG_NE:return "ne";
	case CG_LT:return "l";
	case CG_GT:return "g";
	case CG_LE:return "le";
	case CG_GE:return "ge";
	case CG_LTU:return "b";
	case CG_GTU:return "a";
	case CG_LEU:return "be";
	case CG_GEU:return "ae";
	}
	assert(0);
	return 0;
}

const char *CGFrame_X86::x86size( int type ){
	switch(type){
	case CG_PTR:return "dword";
	case CG_INT8:return "byte";
	case CG_INT16:return "word";
	case CG_INT32:return "dword";
	case CG_INT64:return "dword";
	case CG_FLOAT32:return "dword";
	case CG_FLOAT64:return "qword";
	}
	cout<<"Unrcognized type:"<<type<<endl;
	assert(0);
	return 0;
}

CGMem *CGFrame_X86::tmpMem( int type ){
	if( !tmp_mem ){
		local_sz+=8;
		tmp_mem=-local_sz;
	}
	return mem(type,ebp,tmp_mem);
}

CGMem *CGFrame_X86::optMem( CGMem *e,char *buf ){

	CGBop *t=e->exp->bop();

	if( !t ) return 0;
	
	if( t->op!=CG_ADD && t->op!=CG_SUB ) return 0;

	char c=t->op==CG_ADD ? '+' : '-';

	CGBop *q=t->rhs->bop();
	if( q && q->op==CG_MUL ){
		if( CGLit *n=q->rhs->lit() ){
			int f=n->int_value;
			if( f==2 || f==4 || f==8 ){
				char x_buf[256];
				CGExp *x=genExp( t->lhs,x_buf,EA_IMM );
				CGReg *y=genExp( q->lhs );
				//x+y*v
				const char *tm=e->offset ? "%s [%s%c'%i*%i+%i]" : "%s [%s%c'%i*%i]";
				sprintf( buf,tm,x86size(e->type),x_buf,c,y->id,f,e->offset );

				return mem(e->type,bop(t->op,x,bop(CG_MUL,y,n)),e->offset);
			}
		}
	}

	char x_buf[256],y_buf[256];

	CGExp *x=genExp( t->lhs,x_buf,EA_IMM );
	CGExp *y=genExp( t->rhs,y_buf,EA_IMM );

	const char *tm=e->offset ? "%s [%s%c%s+%i]" : "%s [%s%c%s]";

	sprintf( buf,tm,x86size(e->type),x_buf,c,y_buf,e->offset );

	return mem(e->type,bop(t->op,x,y),e->offset);
}

bool CGFrame_X86::optMov( CGExp *lhs,CGExp *rhs ){

	if( !lhs->mem() ) return false;

	if( lhs->isfloat() ) return false;

	CGBop *t=rhs->bop();
	if( !t ) return false;
	
	const char *op;
	switch( t->op ){
	case CG_ADD:op="add";break;
	case CG_SUB:op="sub";break;
	case CG_ORL:op="or";break;
	case CG_AND:op="and";break;
	case CG_XOR:op="xor";break;
	default:return false;
	}

	if( !lhs->equals(t->lhs) ) return false;

	char x_buf[256];
	CGExp *x=genExp( lhs,x_buf,EA_MEM );

	if( CGLit *y=t->rhs->lit() ){
		int n=y->int_value;
		const char *q=0;
		if( t->op==CG_ADD ){
			if( n==1 ) q="inc";
			else if( n==-1 ) q="dec";
		}else if( t->op==CG_SUB ){
			if( n==1 ) q="dec";
			else if( n==-1 ) q="inc";
		}
		if( q ){
			gen( mov(x,bop(t->op,x,y)),"\t%s\t%s\n",q,x_buf );
			return true;
		}
	}

	char y_buf[256];
	CGExp *y=genExp( t->rhs,y_buf,x->reg() ? EA_MEM|EA_IMM : EA_IMM );

	gen( mov(x,bop(t->op,x,y)),"\t%s\t%s,%s\n",op,x_buf,y_buf );

	return true;
}

CGReg *CGFrame_X86::genExp( CGExp *e ){
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
	assert(0);
	return 0;
}

CGMem *CGFrame_X86::genMem( CGMem *e,char *buf ){
	if( CGMem *t=optMem(e,buf) ) return t;
	char t_buf[256];
	CGExp *t=genExp(e->exp,t_buf,EA_IMM );
	const char *tm=e->offset ? "%s [%s%+i]" : "%s [%s]";
	sprintf( buf,tm,x86size(e->type),t_buf,e->offset );
	return mem( e->type,t,e->offset );
}

CGExp *CGFrame_X86::genExp( CGExp *e,char *buf,int mask ){

	if( mask & EA_IMM ){
		if( CGLit *t=e->lit() ){
			if( t->isint() ){
//				sprintf( buf,FMTI64,t->int_value );
				strcpy( buf,fromint( t->int_value ).c_str() );
				return e;
			}
		}
		if( CGSym *t=e->sym() ){
			sprintf( buf,"%s",t->value.c_str() );
			return e;
		}
	}
	if( mask & EA_MEM ){
		if( CGLit *t=e->lit() ){
			if( t->type==CG_FLOAT32 ){
				CGDat *d=dat();
				d->push_back(t);
				return genMem( mem(CG_FLOAT32,d,0),buf );
			}
		}
		if( CGMem *t=e->mem() ){
			if( t->type!=CG_INT8 && t->type!=CG_INT16 ){
				return genMem( t,buf );
			}
		}
	}
	CGReg *r=genExp(e);
	sprintf( buf,"'%i",r->id );
	return r;
}

CGReg *CGFrame_X86::genLoad( CGMem *e ){

	char buf[256];
	e=genMem( e,buf );
	const char *zx=(e->type==CG_INT8 || e->type==CG_INT16) ? "zx" : "";

	CGReg *r=reg(e->type);
	gen( mov(r,e),
			"\tmov%s\t'%i,%s\n",zx,r->id,buf );

	return r;
}

void CGFrame_X86::genCopy( CGReg *r,CGReg *t ){
	if( r->id==t->id ) return;

	gen( mov(r,t),"\tmov\t'%i,'%i\n",r->id,t->id );
}

void CGFrame_X86::genMov( CGExp *lhs,CGExp *rhs ){
	if( lhs->equals(rhs) ) return;

  	char lhs_buf[256];
	CGMem *lhs_mem=lhs->mem();
	CGReg *lhs_reg=lhs->reg();

	if( lhs_reg ){
		sprintf( lhs_buf,"'%i",lhs_reg->id );
	}else{
		lhs=lhs_mem=genMem( lhs_mem,lhs_buf );
	}

	if( CGBop *t=rhs->bop() ){
		if( t->lhs->equals(lhs) ){
			if( t->isint() ){
				const char *op=0;
				switch( t->op ){
				case CG_ADD:op="add";break;
				case CG_SUB:op="sub";break;
				case CG_ORL:op="or";break;
				case CG_AND:op="and";break;
				case CG_XOR:op="xor";break;
				}
				if( op ){
					char rhs_buf[256];
					int rhs_ea=EA_IMM;
					if( lhs_reg ) rhs_ea|=EA_MEM;
					rhs=genExp( t->rhs,rhs_buf,rhs_ea );
					gen( mov(lhs,bop(t->op,lhs,rhs)),
						"\t%s\t%s,%s\n",op,lhs_buf,rhs_buf );
					return;
				}
				switch( t->op ){
				case CG_SHL:op="shl";break;
				case CG_SHR:op="shr";break;
				case CG_SAR:op="sar";break;
				}
				if( op ){
					char rhs_buf[256];
					rhs=genExp( t->rhs,rhs_buf,EA_IMM );
					if( CGReg *r=rhs->reg() ){
						if( r->id!=ECX ){
							genMov( ecx,r );
							rhs=ecx;
						}
						strcpy( rhs_buf,"cl" );
					}
					gen( mov(lhs,bop(t->op,lhs,rhs)),
						"\t%s\t%s,%s\n",op,lhs_buf,rhs_buf );
					return;
				}
			}else if( lhs_reg && t->isfloat() ){
				const char *op=0;
				switch( t->op ){
				case CG_ADD:op="fadd";break;
				case CG_SUB:op="fsub";break;
				case CG_MUL:op="fmul";break;
				case CG_DIV:op="fdiv";break;
				}
				if( op ){
					int rhs_ea=0;
					char rhs_buf[256];
					if( lhs_reg ) rhs_ea|=EA_MEM;
					rhs=genExp( t->rhs,rhs_buf,rhs_ea );
					gen( mov(lhs,bop(t->op,lhs,rhs)),
						"\t%s\t%s,%s\n",op,lhs_buf,rhs_buf );
					return;
				}
			}
		}
	}

	char rhs_buf[256];
	int rhs_ea=EA_IMM;
	if( lhs_reg ) rhs_ea|=EA_MEM;
	rhs=genExp( rhs,rhs_buf,rhs_ea );

	if( lhs_mem && (lhs->type==CG_INT8 || lhs->type==CG_INT16) ){
		if( CGReg *r=rhs->reg() ){
			if( r->id!=EAX ){
				genMov( eax,cvt(CG_INT32,rhs) );
				rhs=cvt(lhs->type,eax);
			}
			strcpy( rhs_buf,lhs->type==CG_INT8 ? "al" : "ax" );
		}
	}

	gen( mov(lhs,rhs),
		"\tmov\t%s,%s\n",lhs_buf,rhs_buf );
}

CGReg *CGFrame_X86::genLea( CGLea *t ){

	CGReg *r=reg(t->type);
	CGMem *m=t->exp->mem();

	assert( m );

	char buf[256];
	m=genMem( m,buf );
	gen( mov(r,lea(m)),"\tlea\t'%i,%s\n",r->id,buf );
	return r;
}

CGReg *CGFrame_X86::genCvt( CGCvt *t ){
	CGReg *r;
	if( t->isint() && t->exp->isint() ){
		//int to int
		r=reg(t->type);
		char buf[256];
		CGExp *exp=genExp(t->exp,buf,EA_IMM|EA_MEM);
		if( r->type==CG_INT8 && t->exp->type!=CG_INT8 ){
			gen( mov(r,cvt(r->type,exp)),
				"\tmov\t'%i,%s\n"
				"\tand\t'%i,0xff\n",
				r->id,buf,r->id );
		}else if( t->type==CG_INT16 && (t->exp->type==CG_INT32 || t->exp->type==CG_PTR) ){
			gen( mov(r,cvt(r->type,exp)),
				"\tmov\t'%i,%s\n"
				"\tand\t'%i,0xffff\n",
				r->id,buf,r->id );
		}else{
			gen( mov(r,cvt(r->type,exp)),
				"\tmov\t'%i,%s\n",
				r->id,buf );
		}
	}else{
		r=reg(t->type);
		CGReg *exp=genExp(t->exp);
		gen( mov(r,cvt(r->type,exp)),
			"\tmov\t'%i,'%i\n",r->id,exp->id );
	}
	return r;
}

CGReg *CGFrame_X86::genUop( CGUop *t ){

	const char *op=0;

	switch( t->op ){
	case CG_NEG:op="neg";break;
	case CG_NOT:assert(t->isint());op="not";break;
	default:assert(0);
	}

	CGReg *r=reg(t->type);
	genMov( r,t->exp );
	gen( mov(r,uop(t->op,r)),"\t%s\t'%i\n",op,r->id );
	return r;
}

static int shifter( int n ){
	int k;
	for( k=0;k<32;++k ) if( (1<<k)==n ) return k;
	return -1;
}

CGReg *CGFrame_X86::genBop( CGBop *t ){

	if( t->isint() && (t->op==CG_MUL || t->op==CG_DIV) ){
		if( CGLit *c=t->rhs->lit() ){
			int i=c->int_value;
			if( t->op==CG_MUL ){
				int n=shifter(i);
				if( n!=-1 ){
					return genBop( bop(CG_SHL,t->lhs,lit(n)) );
				}
			}else if( t->op==CG_DIV ){
				int n=shifter(i);
				if( n!=-1 ){
					genMov( eax,t->lhs );
					gen( xop(XOP_CDQ,edx,eax),"\tcdq\n" );
					CGExp *e=edx;
					e=bop(CG_AND,edx,lit(i-1));
					e=bop(CG_ADD,eax,e);
					e=bop(CG_SAR,e,lit(n));
					return genExp(e);
				}
			}
		}
	}

	CGReg *r=reg(t->type);

	const char *op=0;

	if( t->isfloat() ){
		switch( t->op ){
		case CG_ADD:op="fadd";break;
		case CG_SUB:op="fsub";break;
		case CG_MUL:op="fmul";break;
		case CG_DIV:op="fdiv";break;
		}
	}else{
		switch( t->op ){
		case CG_ADD:op="add";break;
		case CG_SUB:op="sub";break;
		case CG_MUL:op="imul";break;
		case CG_AND:op="and";break;
		case CG_ORL:op="or";break;
		case CG_XOR:op="xor";break;
		}
	}

	if( op ){
		genMov( r,t->lhs );

		char buf[256];
		CGExp *rhs=genExp( t->rhs,buf,EA_MEM|EA_IMM );

		gen( mov(r,bop(t->op,r,rhs)),
			"\t%s\t'%i,%s\n",op,r->id,buf );
		return r;
	}

	assert( t->isint() );

	switch( t->op ){
	case CG_SHL:op="shl";break;
	case CG_SHR:op="shr";break;
	case CG_SAR:op="sar";break;
	}
	if( op ){
		genMov(r,t->lhs);

		if( CGLit *rhs=t->rhs->lit() ){
//			gen( mov(r,bop(t->op,r,rhs)),
//				"\t%s\t'%i," FMTI64 "\n",op,r->id,rhs->int_value );
			char buf[64];
			strcpy( buf,fromint( rhs->int_value ).c_str() );
			gen( mov(r,bop(t->op,r,rhs)),
				"\t%s\t'%i,%s\n",op,r->id,buf );
		}else{
			genMov( ecx,t->rhs );
			gen( mov(r,bop(t->op,r,ecx)),
				"\t%s\t'%i,cl\n",op,r->id );
		}
		return r;
	}
	switch( t->op ){
	case CG_MOD:case CG_DIV:break;
	default:assert(0);
	}

	char buf[256];
	CGExp *rhs=genExp( t->rhs,buf,EA_MEM );

	CGAsm *as;
	if( t->op==CG_MOD ){
		genMov( eax,t->lhs );
		gen( xop(XOP_CDQ,edx,eax),"\tcdq\n" );
		as=gen( mov(edx,bop(CG_MOD,eax,rhs)),"\tidiv\t%s\n",buf );
		as->use.insert( EDX );
		as->def.insert( EAX );
		genMov( r,edx );

//		genMov( eax,t->lhs );
//		as=gen( mov(edx,bop(CG_MOD,eax,rhs)),"\tcdq\n\tidiv\t%s\n",buf );
//		as->def.insert( EAX );
//		genMov( r,edx );
	}else{
		genMov( eax,t->lhs );
		gen( xop(XOP_CDQ,edx,eax),"\tcdq\n" );
		as=gen( mov(eax,bop(CG_DIV,eax,rhs)),"\tidiv\t%s\n",buf );
		as->use.insert( EDX );
		as->def.insert( EDX );
		genMov( r,eax );

//		genMov( eax,t->lhs );
//		as=gen( mov(eax,bop(CG_DIV,eax,rhs)),"\tcdq\n\tidiv\t%s\n",buf );
//		as->def.insert( EDX );
//		genMov( r,eax );
	}
	return r;
}

CGReg *CGFrame_X86::genScc( CGScc *t ){

	CGReg *lhs=genExp( t->lhs );

	if( lhs->isfloat() ){
		CGReg *rhs=genExp( t->rhs );
		gen( mov(eax,scc(t->cc,lhs,rhs)),"" );
	}else{
		char rhs_buf[256];
		CGExp *rhs=genExp( t->rhs,rhs_buf,EA_MEM|EA_IMM );

		gen( mov(eax,scc(t->cc,lhs,rhs)),
			"\tcmp\t'%i,%s\n"
			"\tset%s\tal\n"
			"\tmovzx\teax,al\n",lhs->id,rhs_buf,x86cc(t->cc) );
	}

	CGReg *r=reg(CG_INT32);
	genMov( r,eax );
	return r;
}

CGReg *CGFrame_X86::genJsr( CGJsr *t ){

	if( env_platform=="macos" ){
		return genMacJsr( t );
	}

	int k,arg_sz=0;

	CGExp *ea=t->exp;

	for( k=0;k<t->args.size();++k ){
		arg_sz+=t->args[k]->type==CG_FLOAT64 ? 8 : 4;
	}
	if( CGVfn *p=ea->vfn() ){
		arg_sz+=p->self->type==CG_FLOAT64 ? 8 : 4;
	}

	for( k=t->args.size()-1;k>=0;--k ){
		genPush( t->args[k] );
	}
	if( CGVfn *p=ea->vfn() ){
		//put 'this' on stack
		genPush( p->self );
		ea=p->exp;
	}

	char buf[256];
	ea=genExp( ea,buf,EA_MEM|EA_IMM );

	CGReg *dst=t->isfloat() ? fp0 : eax;

	CGAsm *as=gen( mov(dst,jsr(t->type,t->call_conv,ea)),"\tcall\t%s\n",buf );

	as->def.insert(EAX);as->def.insert(EDX);as->def.insert(ECX);
	as->def.insert(FP0);as->def.insert(FP1);as->def.insert(FP2);
	as->def.insert(FP3);as->def.insert(FP4);as->def.insert(FP5);
	as->def.insert(FP6);

	if( t->call_conv==CG_CDECL ){
		genPop( lit(arg_sz) );
	}else{
		++extern_jsrs;
	
	}

	CGReg *r=reg(t->type);
	genMov( r,dst );
	return r;
}

static int argSize( CGExp *e ){
	return e->type==CG_FLOAT64 ? 8 : 4;
}

static int paramSize( CGJsr *t ){
	int i,sz=0;
	if( CGVfn *p=t->exp->vfn() ) sz+=argSize( p->self );
	for( i=0;i<t->args.size();++i ) sz+=argSize( t->args[i] );
	return sz;
}

struct MaxParamSizeVisitor : public CGVisitor{
	int size;
	
	MaxParamSizeVisitor():size(0){}

	CGExp *visit( CGExp *e ){
		CGJsr *t=e->jsr();
		if( !t ) return e;
		int sz=paramSize( t );
		if( sz>size ) size=sz;
		return e;
	}
};

static int maxParamSize( CGExp *e,int sz ){
	MaxParamSizeVisitor v;
	e->visit(v);
	return v.size>sz ? v.size : sz;
}

CGReg *CGFrame_X86::genMacJsr( CGJsr *t ){

///*
	int i;
	vector<int> maxszs;
	vector<CGExp*> args;
	vector<CGMov*> movs;
	
	CGExp *ea=t->exp,*self=0;
	if( CGVfn *p=ea->vfn() ){
		ea=p->exp;
		self=p->self;
	}
	
	args.push_back( ea );
	if( self ) args.push_back( self );
	for( i=0;i<t->args.size();++i ){
		args.push_back( t->args[i] );
	}
	
	int maxsz=0;
	for( i=0;i<args.size();++i ){
		maxszs.push_back( maxsz );
		maxsz=maxParamSize( args[i],maxsz );
	}
	
	char buf[256];
	int offset=paramSize( t );
	if( offset>param_sz ) param_sz=offset;
	
	for( i=args.size()-1;i>=0;--i ){
		if( i ){
			CGExp *arg=args[i];
			offset-=argSize( arg );
			CGExp *lhs=mem( arg->type,esp,offset );
			CGExp *rhs=genExp( args[i],buf,EA_IMM );
			movs.push_back( mov(lhs,rhs) );
		}else{
			ea=genExp( ea,buf,EA_MEM|EA_IMM );
		}
		bool again=true;
		vector<CGMov*>::iterator it;
		while( again ){
			again=false;
			for( it=movs.begin();it!=movs.end();++it ){
				CGMov *t=*it;
				if(	t->lhs->mem()->offset>=maxszs[i] ){
					genMov( t->lhs,t->rhs );
					movs.erase( it );
					again=true;
					break;
				}
			}
		}
	}
//*/	
/*
	vector<CGExp*> args;
	
	int k,arg_sz=0;

	for( k=t->args.size()-1;k>=0;--k ){
		CGExp *arg=t->args[k];
		args.push_back( genExp(t->args[k]) );
	}

	CGExp *ea=t->exp;

	if( CGVfn *t=ea->vfn() ){
		args.push_back( genExp(t->self) );
		ea=t->exp;
	}

	char buf[256];
	ea=genExp( ea,buf,EA_MEM|EA_IMM );
	
	for( k=args.size()-1;k>=0;--k ){
		CGExp *arg=args[k],*p;
		p=mem( arg->type,esp,arg_sz );
		arg_sz+=(arg->type==CG_FLOAT64) ? 8 : 4;
		genMov( p,arg );
		args[k]=p;
	}

	if( arg_sz>param_sz ) param_sz=arg_sz;
*/

	CGReg *dst=t->isfloat() ? fp0 : eax;

	CGAsm *as=gen( mov(dst,jsr(t->type,t->call_conv,ea)),"\tcall\t%s\n",buf );

	as->def.insert(EAX);as->def.insert(EDX);as->def.insert(ECX);
	as->def.insert(FP0);as->def.insert(FP1);as->def.insert(FP2);
	as->def.insert(FP3);as->def.insert(FP4);as->def.insert(FP5);
	as->def.insert(FP6);

	CGReg *r=reg( t->type );
	genMov( r,dst );
	return r;
}

CGReg *CGFrame_X86::genLit( CGLit *t ){

	CGReg *r=reg(t->type);

	if( t->isfloat() ){
		double val=t->float_value;
		if( val==0.0 || val==1.0 ){
			gen( mov(r,t),"\tmov\t'%i,%f\n",r->id,t->float_value );
		}else{
			CGDat *d=dat();
			d->push_back(t);
			genMov( r,mem(t->type,d,0) );
		}
	}else if( t->int_value==0 ){
		gen( mov(r,t),"\txor\t'%i,'%i\n",r->id,r->id );
	}else{
//		gen( mov(r,t),"\tmov\t'%i," FMTI64 "\n",r->id,t->int_value );
		char buf[64];
		strcpy( buf,fromint( t->int_value ).c_str() );
		gen( mov(r,t),"\tmov\t'%i,%s\n",r->id,buf );
	}
	return r;
}

CGReg *CGFrame_X86::genSym( CGSym *t ){
	CGReg *r=reg(t->type);
	gen( mov(r,t),"\tmov\t'%i,%s\n",r->id,t->value.c_str() );
	return r;
}

CGReg *CGFrame_X86::genFrm( CGFrm *t ){
	CGReg *r=reg(CG_PTR);
	genMov( r,ebp );
	return r;
}

void CGFrame_X86::genPush( CGExp *e ){
	if( e->type==CG_FLOAT32 ){
		if( CGLit *t=e->lit() ){
			float n=t->float_value;
			e=lit( *(int*)&n );
		}
		genPush4(e);
	}else if( e->type==CG_FLOAT64 ){
		genPush8(e);
	}else if( e->type==CG_INT8 || e->type==CG_INT16 ){
		if( e->mem() ) e=genExp(e);
		genPush4(e);
	}else{
		genPush4(e);
	}
}

void CGFrame_X86::genPush4( CGExp *e ){
	int ea=(e->type==CG_FLOAT64) ? 0 : EA_MEM|EA_IMM;
	char buf[256];
	e=genExp( e,buf,ea );
	gen( xop(XOP_PUSH4,0,e),"\tpush\t%s\n",buf );
}

void CGFrame_X86::genPush8( CGExp *e ){
	CGReg *r=genExp( e );
	gen( xop(XOP_PUSH8,0,r),"\tpush\t'%i\n",r->id );
}

void CGFrame_X86::genPop( CGExp *e ){
	
	if( CGLit *t=e->lit() ){
		if( !t->int_value ) return;
	}
	
	char buf[256];
	e=genExp( e,buf,EA_MEM|EA_IMM );
	
	if( buf[0]=='-' ){
		gen( xop(XOP_POP,0,e),"\tsub\tesp,%s\n",buf+1 );
	}else{
		gen( xop(XOP_POP,0,e),"\tadd\tesp,%s\n",buf );
	}
}

void CGFrame_X86::genBcc( int cc,CGExp *lhs,CGExp *rhs,CGSym *tgt ){

	//use scc for FP
	if( lhs->isfloat() ){
		lhs=genExp(lhs);
		rhs=genExp(rhs);
		gen( mov(eax,scc(cc,lhs,rhs)),"" );
		cc=CG_NE;
		lhs=eax;
		rhs=lit0;
	}

	char lhs_buf[256],rhs_buf[256];
	lhs=genExp(lhs,lhs_buf,EA_MEM);
	rhs=genExp(rhs,rhs_buf,lhs->mem() ? EA_IMM : EA_MEM|EA_IMM);
	gen(
		bcc(cc,lhs,rhs,tgt),
		"\tcmp\t%s,%s\n"
		"\tj%s\t%s\n",
		lhs_buf,rhs_buf,x86cc(cc),tgt->value.c_str() );
}

void CGFrame_X86::genRet( CGExp *e ){
	CGReg *r=0;
	if( e ){
		r=e->isfloat() ? fp0 : eax;
		genMov(r,e);
	}
	CGAsm *as;
	if( fun->call_conv==CG_CDECL ){
		as=gen( ret(r),"\tret\n" );
	}else{
		as=gen( ret(r),"\tret\t%i\n",arg_sz );
	}
	as->use.insert( EBP );
}

string CGFrame_X86::fixSym( string id ){
	if( env_platform=="linux" ) return id;
	return "_"+id;
}

void CGFrame_X86::genStm( CGStm *s ){

	if( CGAti *t=s->ati() ){
		char buf[256];
		CGMem *mem=genMem( t->mem,buf );
		gen( ati(mem),"\tinc\t%s\n",buf );
	}else if( CGAtd *t=s->atd() ){
		char buf[256];
		CGMem *mem=genMem( t->mem,buf );
		gen( atd(mem,t->sym),"\tdec\t%s\n\tjnz\t%s\n",buf,t->sym->value.c_str() );
	}else if( CGMov *t=s->mov() ){
		genMov( t->lhs,t->rhs );
	}else if( CGLab *t=s->lab() ){
		gen( t,"%s:\n",t->sym->value.c_str() );
	}else if( CGBra *t=s->bra() ){
		gen( t,"\tjmp\t%s\n",t->sym->value.c_str() );
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
		switch( t->op ){
		case XOP_PUSH4:genPush4(t->exp);break;
		case XOP_PUSH8:genPush8(t->exp);break;
		case XOP_POP:genPop(t->exp);break;
		case XOP_CDQ:break;
		default:assert(0);
		}
	}else{
		assert(0);
	}
}

void CGFrame_X86::genFun(){

	if( CGExp *t=fun->self ){
		//get 'this' from stack
		genMov( t,mem(CG_PTR,ebp,arg_sz+8) );
		arg_sz+=4;
	}

	int k;
	for( k=0;k<fun->args.size();++k ){
		//get args from stack
		CGExp *t=fun->args[k];
		int n=t->type==CG_FLOAT64 ? 8 :4;
		genMov(t,mem(t->type,ebp,arg_sz+8));
		arg_sz+=n;
	}

	for( k=0;k<fun->stms.size();++k ){
		genStm( fun->stms[k] );
	}
}

CGMem *CGFrame_X86::allocLocal( int type ){
	int n=(type==CG_FLOAT64 || type==CG_INT64) ? 8 : 4;
	local_sz+=n;
	return mem(type,ebp,-local_sz);
}

CGExp *CGFrame_X86::allocSpill( CGReg *r ){
	int sz=8;
	if( fun->self ){
		if( r->equals(fun->self) ) return mem(CG_PTR,ebp,sz);
		sz+=4;
	}
	int k;
	for( k=0;k<fun->args.size();++k ){
		CGExp *t=fun->args[k];
		if( r->equals(t) ) return mem(t->type,ebp,sz);
		sz+=(t->type==CG_FLOAT64) ? 8 : 4;
	}
	return allocLocal( r->type );
}

void CGFrame_X86::finish(){
	fixFp();
}

CGFrame_X86::CGFrame_X86( CGFun *f,CGModule_X86 *m ):CGFrame(f),mod_x86(m){

	arg_sz=0;
	tmp_mem=0;
	param_sz=0;
	local_sz=0;
	extern_jsrs=0;

	//int types map to reg bank 0
	reg_banks[CG_PTR]=0;
	reg_banks[CG_INT8]=0;
	reg_banks[CG_INT16]=0;
	reg_banks[CG_INT32]=0;
	reg_banks[CG_INT64]=-1; //no int64 regs!

	//int regs
	eax=reg( CG_INT32,0,0 );
	edx=reg( CG_INT32,0,1 );
	ecx=reg( CG_INT32,0,2 );
	ebx=reg( CG_INT32,0,3 );
	esi=reg( CG_INT32,0,4 );
	edi=reg( CG_INT32,0,5 );
	ebp=reg( CG_INT32,0,6 );
	esp=reg( CG_INT32,0,7 );

	reg_masks[0]=0x3f;	//no ebp or esp!

	//int reg names
	reg_names[0].push_back( "eax" );
	reg_names[0].push_back( "edx" );
	reg_names[0].push_back( "ecx" );
	reg_names[0].push_back( "ebx" );
	reg_names[0].push_back( "esi" );
	reg_names[0].push_back( "edi" );
	reg_names[0].push_back( "ebp" );
	reg_names[0].push_back( "esp" );

	//float types map to bank 1
	reg_banks[CG_FLOAT32]=1;
	reg_banks[CG_FLOAT64]=1;

	//float regs
	fp0=reg( CG_FLOAT64,0,0 );
	fp1=reg( CG_FLOAT64,0,1 );
	fp2=reg( CG_FLOAT64,0,2 );
	fp3=reg( CG_FLOAT64,0,3 );
	fp4=reg( CG_FLOAT64,0,4 );
	fp5=reg( CG_FLOAT64,0,5 );
	fp6=reg( CG_FLOAT64,0,6 );

	reg_masks[1]=0x7f;	//no f7!

	//float reg names
	reg_names[1].push_back( "fp0" );
	reg_names[1].push_back( "fp1" );
	reg_names[1].push_back( "fp2" );
	reg_names[1].push_back( "fp3" );
	reg_names[1].push_back( "fp4" );
	reg_names[1].push_back( "fp5" );
	reg_names[1].push_back( "fp6" );
}
