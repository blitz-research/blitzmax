
#include "cgstd.h"

#include "cgframe_x86.h"
#include "cgutil.h"
#include "cgdebug.h"

//#define _DEBUG_FPSTACK

static CGFrame_X86 *frame;
static char tmpbuf8[256],tmpbuf16[256],tmpbuf32[256],*buf,*buf_a,*buf_b,*out;

struct FPStack;

typedef set<CGBlock*> BlockSet;
typedef map<CGBlock*,FPStack*> StackMap;

static BlockSet blocks_todo;
static StackMap stack_map;

static void emit( const char *fmt,... ){
	va_list args;
	va_start( args,fmt );
	vsprintf( out,fmt,args );
	out+=strlen(out);
}

struct FPStack{

	int regs[8],stack[8],sp;

	FPStack( int live ):sp(8){
		memset( regs,-1,sizeof(regs) );
		memset( stack,0,sizeof(stack) );
		for( int k=0;k<8;++k ){
			if( live & (1<<k) ) push(k);
		}
	}

	FPStack( FPStack *st ):sp(st->sp){
		memcpy( regs,st->regs,sizeof(regs) );
		memcpy( stack,st->stack,sizeof(stack) );
	}

	int liveMask(){
		int n=0;
		for( int k=sp;k<8;++k ) n|=1<<stack[k];
		return n;
	}

	bool equals( FPStack *st ){
		if( sp!=st->sp ) return false;
		for( int k=sp;k<8;++k ){
			if( stack[k]!=st->stack[k] ) return false;
		}
		return true;
	}

	int top(){
		return stack[sp];
	}

	void pop(){
		int r=stack[sp];
		regs[r]=-1;
		++sp;
	}

	void push( int r ){
		--sp;
		regs[r]=sp;
		stack[sp]=r;
	}

	void swap( int rd,int rs ){
		assert(regs[rs]>=0 && regs[rd]>=0);
		std::swap( stack[regs[rs]],stack[regs[rd]] );
		std::swap( regs[rs],regs[rd] );
	}

	int stoff( int r ){
		return regs[r]-sp;
	}

	void fpop(){
		emit( "\tfstp\tst0\n" );
		pop();
	}

	void fxch( int r ){
		if( r==top() ) return;
		emit( "\tfxch\tst%i\n",stoff(r) );
		swap( r,top() );
	}

	void fpop( int r ){
		if( regs[r]<0 ) return;
		fxch(r);
		fpop();
	}

	void debug(){
		for( int k=0;k<8;++k ){
			if( k<sp ) cout<<"-- ";
			else cout<<'f'<<stack[k]<<' ';
		}
		cout<<" sp:"<<sp<<endl;
	}


	void fdebug(){
//#ifdef _DEBUG_FPSTACK
		emit( "\t;" );
		for( int k=0;k<8;++k ){
			if( k<sp ) emit( "-- " );
			else emit( "f%i ",stack[k] );
		}
		emit( "\n" );
//#endif
	}

	void fadjust( int live ){
		for( int k=sp;k<8;++k ){
			if( !(live & (1<<stack[k])) ) fpop( stack[k] );
		}
	}

	void fadjust( FPStack *st ){
#ifdef _DEBUG_FPSTACK
		emit( "\t;fadjust...\n" );
#endif

		for( int t_sp=7;t_sp>=st->sp;--t_sp ){

			int t=top();

			for( ;st->regs[t]==-1;t=top() ) fpop();

			int rs=stack[t_sp];
			int rd=st->stack[t_sp];

			if( rs==rd ){

			}else if( st->regs[rs]==-1 ){
				fxch( rd );
				emit( "\tfstp\tst%i\n",t_sp-sp );
				stack[regs[rd]=t_sp]=rd;
				pop();
			}else{
				fxch( rd );
				fxch( rs );
			}
		}
		while( sp<st->sp ) fpop();
	}

	void fcopy( int rd,int rs,int live ){

		if( rd==rs || !(live&(1<<rd)) ){
			if( !(live&(1<<rd)) ) fpop(rd);
			if( !(live&(1<<rs)) ) fpop(rs);
			return;
		}

		if( live&(1<<rs) ){
			if( regs[rd]>=0 ){
				fxch(rs);
				emit( "\tfst\tst%i\n",stoff(rd) );
			}else{
				emit( "\tfld\tst%i\n",stoff(rs) );
				push(rd);
			}
		}else{
			if( regs[rd]>=0 ){
				fxch(rs);
				emit( "\tfstp\tst%i\n",stoff(rd) );
				pop();
			}else{
				stack[regs[rs]]=rd;
				regs[rd]=regs[rs];
				regs[rs]=-1;
			}
		}
	}


	void fload( int rd,double val,int live ){

		if( !(live&(1<<rd)) ){
			fpop(rd);
			return;
		}

		if( val==0.0 ) emit( "\tfldz\n" );
		else if( val==1.0 ) emit( "\tfld1\n" );
		else assert(0);

		if( regs[rd]>=0 ){
			emit( "\tfstp\tst%i\n",stoff(rd)+1 );
		}else{
			push(rd);
		}
	}

	void fload( int rd,const char *ea,const char *op,int live ){
		if( live&(1<<rd) ){
			emit( "\t%s\t%s\n",op,ea );
			if( regs[rd]>=0 ){
				emit( "\tfstp\tst%i\n",stoff(rd)+1 );
			}else{
				push(rd);
			}
		}else{
			fpop(rd);
		}
	}

	void fstore( int rs,const char *ea,const char *op,int live ){
		fxch( rs );
		if( live&(1<<rs) ){
			emit( "\t%s\t%s\n",op,ea );
		}else{
			emit( "\t%sp\t%s\n",op,ea );
			pop();
		}
	}

	void funiop( int rd,const char *op,int live ){
		if( !(live&(1<<rd)) ){
			fpop(rd);
			return;
		}
		fxch(rd);
		emit( "\t%s\n",op );
	}

	void fbinop( int rd,int rs,const char *op,int live ){
		if( !(live&(1<<rd)) ){
			fpop(rd);
			if( !(live&(1<<rs)) ) fpop(rs);
			return;
		}
		if( live&(1<<rs) ){
			if( top()==rs ){
				emit( "\t%s\tst%i,st0\n",op,stoff(rd) );
			}else{
				fxch(rd);
				emit( "\t%s\tst0,st%i\n",op,stoff(rs) );
			}
		}else{
			if( top()==rd ){
				const char *r_op=op;
				if( !strcmp(op,"fsub") ) r_op="fsubr";
				else if( !strcmp(op,"fdiv") ) r_op="fdivr";
				emit( "\t%sp\tst%i,st0\n",r_op,stoff(rs) );
				stack[regs[rs]]=rd;
				regs[rd]=regs[rs];
				regs[rs]=-1;
				++sp;
			}else{
				fxch(rs);
				emit( "\t%sp\tst%i,st0\n",op,stoff(rd) );
				pop();
			}
		}
	}

	void fbinop( int rd,const char *ea,const char *op,int live ){
		if( !(live&(1<<rd)) ){
			fpop(rd);
			return;
		}
		fxch(rd);
		emit( "\t%s\t%s\n",op,ea );
	}

	void fcomp( int rd,int rs,int live ){
		fxch(rd);
		if( live&(1<<rd) ){
			emit( "\tfucom\tst%i\n",stoff(rs) );
			if( !(live&(1<<rs)) ) fpop(rs);
		}else{
			if( live&(1<<rs) ){
				emit( "\tfucomp\tst%i\n",stoff(rs) );
				pop();
			}else if( stoff(rs)==1 ){
				emit( "\tfucompp\n" );
				pop();
				pop();
			}else{
				emit( "\tfucomp\tst%i\n",stoff(rs) );
				pop();
				fpop(rs);
			}
		}
		emit( "\tfnstsw\tax\n" );
		emit( "\tsahf\n" );
	}
};

static int liveMask( const CGIntSet &t ){
	int live=0;
	CGIntCIter it;
	for( it=t.begin();it!=t.end();++it ){
		CGReg *r=frame->regs[*it];
		if( r->isfloat() ){
			assert(r->color>=0);
			live|=(1<<r->color);
		}
	}
	return live;
}

static void adjustStack( FPStack *st,CGBlock *blk ){
	StackMap::iterator it=stack_map.find(blk);
	
	if( it!=stack_map.end() ){
		st->fadjust( it->second );
		return;
	}

	st->fadjust( liveMask(blk->live_in) );
	stack_map.insert( make_pair(blk,new FPStack(st)) );
	blocks_todo.insert( blk );
}

static const char *op1( CGAsm *as ){
	static char buf[256];

	const char *b=strchr( as->assem+1,'\t' );
	assert(b);
	++b;

	const char *e=strchr( as->assem,',' );
	if( !e ) e=b+strlen(b);

	int sz=e-b;
	memcpy(buf,b,sz);
	buf[sz]=0;
	return buf;
}

static const char *op2( CGAsm *as ){
	static char buf[256];

	const char *b=strchr( as->assem,',' );
	assert(b);
	++b;

	const char *e=strchr( b,'\n' );
	assert(e);

	int sz=e-b;
	memcpy(buf,b,sz);
	buf[sz]=0;
	return buf;
}

static void allocTmp32(){
	if( tmpbuf32[0] ) return;
	CGMem *m=frame->allocLocal(CG_INT32);
	sprintf( tmpbuf8,"byte [ebp+%i]",m->offset );
	sprintf( tmpbuf16,"word [ebp+%i]",m->offset );
	sprintf( tmpbuf32,"dword [ebp+%i]",m->offset );
}

static bool fixXop( CGAsm *as,CGXop *op,FPStack *st,int live ){

	CGExp *exp=op->exp;

	if( op->op==CGFrame_X86::XOP_PUSH4 ){
		//push dword
		if( exp->isint() || exp->mem() ) return false;
		int rs=exp->reg()->color;
		emit( "\tsub\tesp,4\n" );
		st->fstore( rs,"dword [esp]","fst",live );
		return true;
	}
	if( op->op==CGFrame_X86::XOP_PUSH8 ){
		//push qword
		if( exp->isint() ) return false;
		assert( !exp->mem() );
		int rs=exp->reg()->color;
		emit( "\tsub\tesp,8\n" );
		st->fstore( rs,"qword [esp]","fst",live );
		return true;
	}
	return false;
}

static bool fixEva( CGAsm *as,CGEva *ev,FPStack *st,int live ){

	CGExp *exp=ev->exp;

	if( CGJsr *t=exp->jsr() ){
		if( !exp->isfloat() ) return false;
		if( !live ){
			emit(as->assem);
			emit("\tfstp\tst0\n");
			return true;
		}else if( live==1 ){
			if( st->regs[0]<0 ) st->push(0);
			return false;
		}
		cout<<"Invalid FP stack state after FP jsr"<<endl;
		return false;
	}
	return false;
}

static bool fixMov( CGAsm *as,CGMov *mv,FPStack *st,int live ){

	CGExp *lhs=mv->lhs;
	CGExp *rhs=mv->rhs;

	if( CGCvt *t=rhs->cvt() ){
		if( lhs->isfloat() ){
			if( t->exp->isfloat() ){
				//float to float
				st->fcopy( lhs->reg()->color,t->exp->reg()->color,live );
				return true;
			}
			//int to float
			allocTmp32();
			int rd=lhs->reg()->color;
			emit( "\tmov\t%s,%s\n",tmpbuf32,op2(as) );
			st->fload( rd,tmpbuf32,"fild",live );
			return true;
		}else if( t->exp->isfloat() ){
			//float to int
			allocTmp32();
			int rs=t->exp->reg()->color;
			st->fstore( rs,tmpbuf32,"fist",live );
			if( lhs->type==CG_INT8 ){
				emit( "\tmovzx\t%s,%s\n",op1(as),tmpbuf8 );
			}else if( lhs->type==CG_INT16 ){
				emit( "\tmovzx\t%s,%s\n",op1(as),tmpbuf16 );
			}else{
				emit( "\tmov\t%s,%s\n",op1(as),tmpbuf32 );
			}
			return true;
		}
		return false;
	}else if( CGScc *t=rhs->scc() ){
		if( !t->lhs->isfloat() ) return false;
		int rd=t->lhs->reg()->color;
		int rs=t->rhs->reg()->color;
		st->fcomp( rd,rs,live );
		const char *op;
		switch( t->cc ){
		case CG_EQ:op="z";break;
		case CG_NE:op="nz";break;
		case CG_LT:op="b";break;
		case CG_GT:op="a";break;
		case CG_LE:op="be";break;
		case CG_GE:op="ae";break;
		}
		emit( "\tset%s\tal\n",op );
		emit( "\tmovzx\teax,al\n" );
		return true;
	}

	if( lhs->isint() && rhs->isint() ) return false;
	assert( lhs->isfloat() && rhs->isfloat() );

	if( lhs->reg() && rhs->reg() ){
		st->fcopy( lhs->reg()->color,rhs->reg()->color,live );
		return true;
	}
	if( CGJsr *t=rhs->jsr() ){
		if( !live ){
			emit(as->assem);
			emit("\tfstp\tst0\n");
			return true;
		}else if( live==1 ){
			if( st->regs[0]<0 ) st->push(0);
			return false;
		}
		cout<<"Invalid FP stack state after FP jsr"<<endl;
		return false;
/*
		emit(as->assem);
		if( live&1 ){
			if( st->regs[0]<0 ) st->push(0);
		}else if( st->regs[0]>=0 ){
			st->fpop();
		}
		return true;
	*/
	}
	if( CGMem *t=rhs->mem() ){
		int rd=lhs->reg()->color;
		st->fload( rd,op2(as),"fld",live );
		return true;
	}
	if( CGMem *t=lhs->mem() ){
		int rs=rhs->reg()->color;
		st->fstore( rs,op1(as),"fst",live );
		return true;
	}
	if( CGUop *t=rhs->uop() ){
		int rd=lhs->reg()->color;
		const char *op;
		switch( t->op ){
		case CG_NEG:op="fchs";break;
		default:assert(0);
		}
		st->funiop( rd,op,live );
		return true;
	}
	if( CGBop *t=rhs->bop() ){
		int rd=lhs->reg()->color;
		const char *op;
		switch( t->op ){
		case CG_ADD:op="fadd";break;
		case CG_SUB:op="fsub";break;
		case CG_MUL:op="fmul";break;
		case CG_DIV:op="fdiv";break;
		default:assert(0);
		}
		if( CGReg *r=t->rhs->reg() ){
			st->fbinop( rd,r->color,op,live );
		}else{
			st->fbinop( rd,op2(as),op,live );
		}
		return true;
	}
	if( CGLit *t=rhs->lit() ){
		int rd=lhs->reg()->color;
		st->fload( rd,t->float_value,live );
		return true;
	}
	assert(0);
	return false;
}

static void fix( CGBlock *blk ){

	if( blk->begin==blk->end ) return;

	vector<int> live_stack;
	int live=liveMask( blk->live_out );

	CGAsm *as=blk->end;
	while( as!=blk->begin ){
		as=as->pred;

		live_stack.push_back( live );

		live&=~liveMask(as->def);
		live|=liveMask(as->use);
	}

	assert( stack_map.count(blk) );
	FPStack *st=new FPStack( stack_map[blk] );
	assert( st->liveMask()==live );

	for( as=blk->begin;as!=blk->end;as=as->succ ){

		live=live_stack.back();
		live_stack.pop_back();

		*(out=buf)=0;

		bool fix=false;

		if( CGMov *t=as->stm->mov() ){
			fix=fixMov( as,t,st,live );
		}else if( CGXop *t=as->stm->xop() ){
			fix=fixXop( as,t,st,live );
		}else if( CGEva *t=as->stm->eva() ){
			fix=fixEva( as,t,st,live );
		}

		if( fix ) as->assem=strdup(buf);
	}

	as=as->pred;

	buf_a[0]=0;
	CGBlock *blk_a=blk->succ.size()>0 ? blk->succ[0] : 0;
	if( blk_a ){
		out=buf_a;
		adjustStack( new FPStack(st),blk_a );
	}

	buf_b[0]=0;
	CGBlock *blk_b=blk->succ.size()>1 ? blk->succ[1] : 0;
	if( blk_b ){
		assert( as->stm->bcc() );
		out=buf_b;
		adjustStack( new FPStack(st),blk_b );
	}

	if( !buf_a[0] && !buf_b[0] ) return;

	*(out=buf)=0;

	assert( blk_a );

	if( !blk_b ){

		if( as->stm->bra() ){
			emit( buf_a );
			emit( as->assem );
		}else{
			emit( as->assem );
			emit( buf_a );
		}

	}else if( !buf_b[0] ){

		emit( as->assem );
		emit( buf_a );

	}else{

		CGBcc *t=as->stm->bcc();

		CGSym *skip=CG::sym();

		const char *cc=CGFrame_X86::x86cc( CG::swapcc(t->cc) );

		//find the jmp
		char *p=strstr( as->assem,"\tj" );assert(p);

		//cmp...
		memcpy( out,as->assem,p-as->assem );out+=p-as->assem;

		//new jmp
		emit( "\tj%s\t%s\n",cc,skip->value.c_str() );

		//normalize bra block
		emit( buf_b );

		//bra to block
		emit( "\tjmp\t%s\n",t->sym->value.c_str() );

		//our new symbol!
		emit( "%s:\n",skip->value.c_str() );

		emit( buf_a );
	}

	as->assem=strdup(buf);
}

void CGFrame_X86::fixFp(){

	if( !flow->blocks.size() ) return;

	::frame=this;

	tmpbuf32[0]=0;
	buf=new char[1024];
	buf_a=new char[1024];
	buf_b=new char[1024];

	CGBlock *blk=*flow->blocks.begin();

	stack_map.clear();
	stack_map.insert( make_pair(blk,new FPStack(0)) );

	blocks_todo.clear();
	blocks_todo.insert( blk );

	while( blocks_todo.size() ){
		BlockSet::iterator it=blocks_todo.begin();
		CGBlock *blk=*it;
		blocks_todo.erase(it);
		fix(blk);
	}

	blocks_todo.clear();
	stack_map.clear();

	delete[] buf_b;
	delete[] buf_a;
	delete[] buf;
}
