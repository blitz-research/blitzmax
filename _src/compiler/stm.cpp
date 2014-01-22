
#include "std.h"
#include "stm.h"
#include "toker.h"

using namespace CG;

//******************** Stm ************************
Stm::~Stm(){
}

//***************** SourceInfo ********************
void DebugInfoStm::eval( Block *b ){
	CGDat *d=genDebugStm( source_info );
	if( d ) b->emit( eva(jsr(CG_INT32,CG_CDECL,mem(CG_PTR,sym("bbOnDebugEnterStm",CG_IMPORT),0),d)) );
}

//******************** Rem ************************
void RemStm::eval( Block *b ){
	if( comment.size() ) b->emit( rem(comment) );
}

//******************* StmStm **********************
void StmStm::eval( Block *b ){
	b->emit( stm );
}

//***************** ClassInits ********************
void EvalClassBlocksStm::eval( Block *b ){
	b->evalClassBlocks();
}

//******************* Label ***********************
void LabelStm::eval( Block *b ){
	b->emit( CG::lab(goto_sym) );
	b->fun_block->dataStms()->push_back( lit(tobstring(restore_sym->value),CG_LABEL) );
}

//******************** Goto ***********************
void GotoStm::eval( Block *b ){
	if( strictMode ) fail( "Goto cannot be used in strict mode" );
	FunBlock *f=b->fun_block;
	map<string,LabelStm*>::iterator it=f->labels.find( tolower(ident) );
	if( it==f->labels.end() ) fail( "Label '%s' not found",ident.c_str() );
	b->emit( CG::bra( it->second->goto_sym ) );
}

//******************** Eval ***********************
void EvalStm::eval( Block *b ){
	Val *v=exp->eval(b);
	b->emit(eva(v->cg_exp));
}

//******************** Ctor ***********************
void CtorStm::eval( Block *b ){
	CGExp *self=b->fun_block->fun_scope->cg_exp;
	CGDat *vtbl=block->class_decl->val->cg_exp->dat();
	
	ClassType *class_ty=block->type;
	Val *super_val=class_ty->superVal();
	ClassType *super_ty=class_ty->superClass();
	
	//invoke super ctor
	if( super_ty ){
		if( Val *super_ctor=super_ty->methods.find( "New" ) ){
			b->emit( eva( jsr( CG_PTR,CG_CDECL,vfn(super_ctor->cg_exp,self) ) ) );
		}
	}

	//install vtbl
	b->emit( mov( mem(CG_PTR,self,0),vtbl ) );
	
	//initialize fields
	block->field_ctors->eval();
	
	ctor_new->eval();
}

//******************** Dtor ***********************
void DtorStm::eval( Block *b ){

	CGExp *self=b->fun_block->fun_scope->cg_exp;
	CGDat *vtbl=block->class_decl->val->cg_exp->dat();
	
	ClassType *class_ty=block->type;
	
	dtor_delete->eval();
	
	//return sym hack - dtor return jumps here...
	b->emit(lab(b->fun_block->ret_sym));
	b->fun_block->ret_sym=sym();

	//destroy fields
	for( int k=class_ty->fields.size()-1;k>=0;--k ){
		Val *v=class_ty->decls.find( class_ty->fields[k]->ident );
		v=v->renameTmps("@self",self);
		if( v->refCounted() ){
			b->emit( v->release() );
		}
	}
	
	Val *super_val=class_ty->superVal();
	ClassType *super_ty=class_ty->superClass();

	//invoke super dtor
	while( super_ty ){
		if( Val *super_dtor=super_ty->methods.find( "Delete" ) ){
		
			//Don't bother calling root object dtor
			if( !super_ty->superClass() ) return;

			//install super vtbl
			b->emit( mov( mem(CG_PTR,self,0),super_val->cg_exp ) );
		
			//invoke super dtor
			b->emit( eva( jsr( CG_PTR,CG_CDECL,vfn(super_dtor->cg_exp,self) ) ) );
			
			return;
		}
		super_val=super_ty->superVal();
		super_ty=super_ty->superClass();
	}
	
	/*
	//invoke super dtor
	if( super_ty ){
		//install super vtbl
		b->emit( mov( mem(CG_PTR,self,0),super_val->cg_exp ) );
		if( Val *super_dtor=super_ty->methods.find( "Delete" ) ){
			b->emit( eva( jsr( CG_PTR,CG_CDECL,vfn(super_dtor->cg_exp,self) ) ) );
		}
	}else{
		b->emit( mov( mem(CG_PTR,self,0),lit0 ) );
	}
	*/
}

//***************** Local Decl ********************
void LocalDeclStm::eval( Block *b ){

	Val *i=init->evalInit( b,type );
	
	Val *v=new Val(type,tmp(type->cgType()));
	Decl *d=new Decl( ident,v );
	
	FunBlock *f=b->fun_block;

	if( strictMode ){
		b->declLocal( d );
		b->initRef( v,i );
	}else{
		f->declLocal( d );
		b->assignRef( v,i );
	}
	
	if( !strictMode || opt_debug ){
		f->cg_enter->push_back( mov(v->cg_exp,Val::null(type)->cg_exp) );
	}
}

//***************** Field Decl ********************
void FieldDeclStm::eval( Block *b ){

	Val *i=init->evalInit( b,type );
	
	Val *v=b->fun_block->fun_scope->find( ident );
	v=b->linearizeRef(v);
	
	b->initRef( v,i );
}

//***************** Global Decl *******************
void GlobalDeclStm::eval( Block *b ){

	Val *i=init->evalInit( b,type );
	
	ClassBlock *cb=dynamic_cast<ClassBlock*>(b);

	CGDat *e;
	if( cb ){
		e=dat(mungMember(cb->class_decl->ident,ident));
	}else if( pub ){
		e=dat(mungGlobal(ident));
	}else{
		e=dat();
	}

	Val *v=new Val(type,mem(type->cgType(),e,0));
	Decl *d=new Decl( ident,v );
	
	if( i->constant() ){
		CGExp *t=i->cg_exp;
		if( i->type->cgType()==CG_INT8 || i->type->cgType()==CG_INT16 ){
			t=lit(t->lit()->int_value);
			t->type=i->type->cgType();
		}
		e->push_back( t );
		b->emit(eva(e));
	}else{
		e->push_back( (new Val(Type::null,0))->cast(type)->cg_exp );
		b->initGlobalRef( v,i );
	}
	b->decl(d);
	if( pub ) publish( d );
}

//***************** Extern Decl ******************
void ExternDeclStm::eval( Block *b ){

	if( !cg ) cg=sym(ident,CG_IMPORT);	
	
	switch( toke ){
	case T_GLOBAL:cg=mem(type->cgType(),cg,0);break;
	default:assert(0);
	}
	Decl *d=new Decl(ident,type,cg);
	b->decl(d);
	if( pub ) publish( d );
}

//****************** Import ***********************
void ImportStm::eval( Block *b ){
	b->emit( eva(jsr(CG_INT32,CG_CDECL,entry)) );
}

//****************** Incbin ***********************
IncbinStm::IncbinStm( string n ):name(n),path(realpath(n)){
}

void IncbinStm::eval( Block *b ){

	if( b!=mainFun ) fail( "Incbin can only be used in main program block" );
	
	Val *v=new Val( tobstring(name) );
	
	CGDat *d=dat();
	CGSym *q=sym();
	
	d->push_back(lit(tobstring(path),CG_BINFILE));
	d->push_back(lit(tobstring(q->value),CG_LABEL));
	
	b->cg_enter->push_back( eva(jsr(CG_INT32,"bbIncbinAdd",v->cg_exp,d,bop(CG_SUB,q,d))) );
}

//****************** Assign ***********************
void AssignStm::eval( Block *b ){

	Val *v=lhs->evalRef(b);
	
	b->assignRef( v,rhs->evalInit(b,v->type) );
}

//****************** OpAssign *********************
void OpAssignStm::eval( Block *b ){

	Val *v=lhs->evalRef(b);
	
	switch( op ){
	case T_ADDASSIGN:rhs=new ArithExp('+',v,rhs);break;
	case T_SUBASSIGN:rhs=new ArithExp('-',v,rhs);break;
	case T_MULASSIGN:rhs=new ArithExp('*',v,rhs);break;
	case T_DIVASSIGN:rhs=new ArithExp('/',v,rhs);break;
	case T_MODASSIGN:rhs=new ArithExp(T_MOD,v,rhs);break;
	case T_ORASSIGN:rhs=new BitwiseExp('|',v,rhs);break;
	case T_ANDASSIGN:rhs=new BitwiseExp('&',v,rhs);break;
	case T_XORASSIGN:rhs=new BitwiseExp('~',v,rhs);break;
	case T_SHLASSIGN:rhs=new BitwiseExp(T_SHL,v,rhs);break;
	case T_SHRASSIGN:rhs=new BitwiseExp(T_SHR,v,rhs);break;
	case T_SARASSIGN:rhs=new BitwiseExp(T_SAR,v,rhs);break;
	default:assert(0);
	}

	b->assignRef( v,rhs->eval(b,v->type) );
}

//***************** If Then Else ******************
void IfStm::eval( Block *b ){

	Val *v=exp->eval(b)->cond();

	CGSym *t_sym=sym();

	b->emit( bcc(CG_EQ,v->cg_exp,lit0,t_sym) );

	then_block->eval();

	if( else_block ){

		CGSym *t_sym2=sym();
		b->emit( bra(t_sym2) );
		b->emit( lab(t_sym) );
		t_sym=t_sym2;

		else_block->eval();
	}

	b->emit(lab(t_sym));
}

//***************** Loop control ******************
void LoopCtrlStm::eval( Block *b ){

	LoopBlock *loop=0;
	FunBlock *f=b->fun_block;

	Block *p=b;
	while( p!=f ){
		b->emit( p->cg_leave );
		if( loop=dynamic_cast<LoopBlock*>(p) ){
			if( !label.size() || label==loop->label ) break;
		}
		p=p->outer;
	}
	if( p==f ){
		if( !loop ){
			fail( "Continue/Exit must appear inside a loop" );
		}else{
			fail( "Continue/Exit label '%s' not found",label.c_str() );
		}
	}

	if( toke==T_CONTINUE ){
		b->emit( bra(loop->cont_sym) );
	}else{
		b->emit( bra(loop->exit_sym) );
	}
}

//****************** For/Next *********************
void ForStm::eval( Block *b ){

	Val *v=var->evalRef(b);
	Type *ty=v->type;
	if( !ty->numericType() ) fail( "Loop index variable must be of numeric type" );

	Val *init_val=init->eval(b)->cast(ty);
	Val *to_val=to->eval(b)->cast(ty);
	Val *step_val;
	if( step ){
		step_val=step->eval(b)->cast(ty);
		if( !step_val->constant() ) fail( "Step expression must be constant" );
	}else{
		step_val=(new Val(1))->cast(ty);
	}
	
	int bcc_cc=CG_LE;
	if( ty->intType() && step_val->intValue()<0 ) bcc_cc=CG_GE;
	if( ty->floatType() && step_val->floatValue()<0 ) bcc_cc=CG_GE;
	if( until ) bcc_cc=(bcc_cc==CG_LE) ? CG_LT : CG_GT;

	CGSym *t_sym=sym();
	
	b->assignRef( v,init_val );
	
	CGExp *var_exp=v->cg_exp;

	if( !to_val->constant() ){
		CGTmp *t=tmp(ty->cgType());
		b->emit(mov(t,to_val->cg_exp));
		to_val=new Val(ty,t);
	}
	
	b->emit(bra(t_sym));

	b->emit(lab(block->loop_sym));

	block->eval();

	b->emit(lab(block->cont_sym));

	b->emit(mov(var_exp,bop(CG_ADD,var_exp,step_val->cg_exp)));
	b->emit(lab(t_sym));
	b->emit(bcc(bcc_cc,var_exp,to_val->cg_exp,block->loop_sym));

	b->emit(lab(block->exit_sym));
}

//****************** For Each *********************
void ForEachStm::checkInt32Method( Val *v ){
	if( v ){
		if( FunType *ty=v->type->funType() ){
			if( ty->method() ){
				if( !ty->args.size() ){
					if( ty->return_type->intType() && ty->size()==4 ) return;
				}
			}   
		}
	}
	fail( "Illegal EachIn expression" );
}

ObjectType *ForEachStm::checkObjMethod( Val *v ){
	if( v ){
		if( FunType *ty=v->type->funType() ){
			if( ty->method() ){
				if( !ty->args.size() ){
					if( ObjectType *t=ty->return_type->objectType() ) return t;
				}
			}   
		}
	}
	fail( "Illegal EachIn expression" );
	return 0;
}

void ForEachStm::eval( Block *b ){

	Val *v=var->evalRef(b);
	Val *t=coll->eval(b);

	if( !t->type->arrayType() && !t->type->objectType() ){
		fail( "EachIn must be used with a string, array, or appropriate object" );
	}

	Val *c=new Val( t->type,tmp(CG_PTR) );

	b->emit( mov(c->cg_exp,t->cg_exp) );

	if( c->type->arrayType() ){
		evalArray( b,v,c );
	}else{
		evalCollection( b,v,c );
	}
}

void ForEachStm::evalArray( Block *b,Val *var,Val *coll ){

	Type *var_ty=var->type;
	ArrayType *arr_ty=coll->type->arrayType();
	Type *elem_ty=arr_ty->element_type;

	Val *arr=new Val( arr_ty,tmp(CG_PTR) );

	CGTmp *beg=tmp(CG_PTR);
	beg->owner=coll->cg_exp->tmp();

	CGTmp *end=tmp(CG_PTR);
	end->owner=coll->cg_exp->tmp();

	Val *next=new Val(elem_ty,mem(elem_ty->cgType(),beg,0));
	
	b->emit( mov(beg,bop(CG_ADD,coll->cg_exp,lit(20+arr_ty->dims*4))) );
	b->emit( mov(end,bop(CG_ADD,beg,mem(CG_INT32,coll->cg_exp,16))) );
	b->emit( bra(block->cont_sym) );
	
	//loop
	b->emit( lab(block->loop_sym) );
	b->assignRef( var,next->forEachCast(var_ty) );
	b->emit( mov(beg,bop(CG_ADD,beg,lit(elem_ty->size()))) );
	if( var_ty->objectType() ) b->emit( bcc(CG_EQ,var->cg_exp,sym("bbNullObject",CG_IMPORT),block->cont_sym) );
	
	//statements!
	block->eval();
	
	//continue
	b->emit( lab(block->cont_sym) );
	b->emit( bcc(CG_NE,beg,end,block->loop_sym) );

	//exit
	b->emit( lab(block->exit_sym) );
}

void ForEachStm::evalCollection( Block *b,Val *var,Val *coll ){

	ObjectType *var_ty=var->type->objectType();
	if( !var_ty ) fail( "EachIn index variable must be an object" );
	
	ObjectType *coll_ty=coll->type->objectType();

	Val *enumer=coll->find( "ObjectEnumerator" );
	ObjectType *enumer_ty=checkObjMethod( enumer );
	
	Val *enumer_tmp=new Val( enumer_ty,tmp(CG_PTR) );
	enumer_tmp->cg_exp->tmp()->owner=coll->cg_exp->tmp();

	Val *enumer_jsr=new Val( enumer_ty,jsr(CG_PTR,CG_CDECL,enumer->cg_exp) );
	
	Val *hasnext=enumer_tmp->find( "HasNext" );
	checkInt32Method( hasnext );
	
	Val *nextobj=enumer_tmp->find( "NextObject" );
	ObjectType *nextobj_ty=checkObjMethod( nextobj );
	
	Val *hasnext_jsr=new Val( Type::int32,jsr(CG_INT32,CG_CDECL,hasnext->cg_exp) );
	Val *nextobj_jsr=new Val( nextobj_ty,jsr(CG_PTR,CG_CDECL,nextobj->cg_exp) );
	
	//invoke 'ObjectEnumerator'
	b->emit( mov(enumer_tmp->cg_exp,enumer_jsr->cg_exp) );
	b->emit( bra(block->cont_sym) );
	
	//loop
	b->emit( lab(block->loop_sym) );
	b->assignRef( var,nextobj_jsr->forEachCast(var_ty) );
	b->emit( bcc(CG_EQ,var->cg_exp,sym("bbNullObject",CG_IMPORT),block->cont_sym) );
	
	//statements!
	block->eval();
	
	//continue
	b->emit( lab(block->cont_sym) );
	//invoke 'HasNext'
	b->emit( bcc(CG_NE,hasnext_jsr->cg_exp,lit0,block->loop_sym) );

	//exit
	b->emit( lab(block->exit_sym) );
}

//******************* While ***********************
void WhileStm::eval( Block *b ){

	Val *v=exp->eval(b)->cond();

	b->emit(bra(block->cont_sym));
	b->emit(lab(block->loop_sym));

	block->eval();

	b->emit(lab(block->cont_sym));
	b->emit(bcc(CG_NE,v->cg_exp,lit0,block->loop_sym));
	b->emit(lab(block->exit_sym));
}

//****************** Repeat ***********************
void RepeatStm::eval( Block *b ){

	b->emit(lab(block->loop_sym));
	if( !exp ) b->emit(lab(block->cont_sym));
	
	block->eval();

	::source_info=source_info;

	if( exp ){
		Val *v=exp->eval(b)->cond();
		b->emit(lab(block->cont_sym));
		b->emit(bcc(CG_EQ,v->cg_exp,lit0,block->loop_sym));
	}else{
		b->emit(bra(block->loop_sym));
	}

	b->emit(lab(block->exit_sym));
}

//****************** Return ***********************
void ReturnStm::eval( Block *b ){

	FunBlock *f=b->fun_block;
	Type *ty=f->type->return_type;
	
	if( exp ){
		if( strictMode>1 && (f->type->attrs & FunType::VOIDFUN) ) fail( "Function can not return a value" );
	}else{
		if( strictMode>1 && !(f->type->attrs & FunType::VOIDFUN) ) fail( "Function must return a value" );
		exp=new NullExp();
	}

	Val *v=exp->eval(b,ty);
	b->emit( mov(f->ret_tmp,v->cg_exp) );
	
	Block *t=b;
	while( t!=f ){
		b->emit(t->cg_leave);
		t=t->outer;
	}
	
	b->emit( bra(f->ret_sym) );
}

//****************** Release **********************
void ReleaseStm::eval( Block *b ){
	Val *v=exp->evalRef(b);
	Type *ty=v->type;

	if( ty->cgType()==CG_INT32 ){
		b->emit( eva(jsr(CG_INT32,"bbHandleRelease",v->cg_exp)) );
		b->emit( mov(v->cg_exp,cvt(v->type->cgType(),lit0)) );
	}else{
		fail( "Subexpression for release must be an integer variable" );
	}
}

//****************** delete ***********************
void DeleteStm::eval( Block *b ){

	Val *v=exp->eval(b);

	ObjectType *ty=v->type->objectType();
	
	if( !ty ) fail( "'Delete' expression does not evaluate to an object" );
	
	b->emit( eva(jsr(CG_INT32,"bbObjectDelete",v->cg_exp)) );
}

//****************** assert ***********************
void AssertStm::eval( Block *b ){

	Val *e=exp->eval(b)->cond();
	Val *m=msg->eval(b)->cast( Type::stringObject );
	
	if( !opt_debug ) return;
	
	CGSym *q=sym();
	b->emit( bcc(CG_NE,e->cg_exp,lit0,q) );
	b->emit( eva(jsr(CG_INT32,"brl_blitz_RuntimeError",m->cg_exp)) );
	b->emit( lab(q) );
}

//******************** end ************************
void EndStm::eval( Block *b ){

	b->emit( eva(jsr(CG_INT32,"bbEnd")) );
}

//***************** select/case *******************
void SelectStm::eval( Block *b ){

	Val *tv=exp->eval(b);
	Type *ty=tv->type;

	Val *t_val=new Val(ty,tmp(ty->cgType()));
	b->emit( mov(t_val->cg_exp,tv->cg_exp) );

	CGSym *end=sym();

	vector<CGSym*> case_syms;

	int k;
	for( k=0;k<cases.size();++k ){

		SelCase *t=cases[k];
		::source_info=t->source_info;

		case_syms.push_back( sym() );

		for( int j=0;j<t->exps.size();++j ){

			Val *r=t->exps[j]->eval( b,ty );

			if( ty->stringType() ){
				b->emit(
					bcc(CG_EQ,
					jsr(CG_INT32,"bbStringCompare",t_val->cg_exp,r->cg_exp),
					lit0,case_syms.back()) );
			}else{
				b->emit( 
					bcc(CG_EQ,t_val->cg_exp,r->cg_exp,case_syms.back()) );
			}
		}
	}

	if( _default ) _default->eval();

	b->emit( bra(end) );

	for( k=0;k<cases.size();++k ){

		b->emit( lab(case_syms[k]) );

		Block *block=cases[k]->block;
		block->eval();
		b->emit( bra(end) );
	}

	b->emit( lab(end) );
}

//********************** Try *************************
void TryStm::eval( Block *b ){

	block->cg_leave->push_back(eva(jsr(CG_INT32,"bbExLeave")));
	
	CGTmp *ex_tmp=tmp(CG_PTR);
	CGSym *catch_sym=sym(),*exit_sym=sym();
	
	if( opt_debug ) b->emit( eva(jsr(CG_INT32,CG_CDECL,mem(CG_PTR,sym("bbOnDebugPushExState",CG_IMPORT),0))) );
	
	b->emit( mov(ex_tmp,jsr(CG_PTR,"bbExEnter")) );
	b->emit( mov(ex_tmp,jsr(CG_PTR,"_bbExEnter",ex_tmp)) );
	b->emit( bcc(CG_NE,ex_tmp,lit0,catch_sym) );
	
	if( opt_debug ) block->cg_leave->push_back( eva(jsr(CG_INT32,CG_CDECL,mem(CG_PTR,sym("bbOnDebugPopExState",CG_IMPORT),0))) );
	
	block->eval();
	
	b->emit( bra(exit_sym) );
	
	b->emit( lab(catch_sym) );

	if( opt_debug ) b->emit( eva(jsr(CG_INT32,CG_CDECL,mem(CG_PTR,sym("bbOnDebugPopExState",CG_IMPORT),0))) );
	
	//exception thrown!
	vector<CGSym*> catch_syms;

	int k;
	for( k=0;k<catches.size();++k ){
		TryCatch *t=catches[k];

		catch_syms.push_back( sym() );
		
		ObjectType *type=t->type->objectType();
		if( !type ) fail( "'Catch' variables must be objects" );
		
		CGTmp *catch_tmp=tmp(CG_PTR);
		t->block->declLocal( new Decl(t->ident,type,catch_tmp) );
	
		b->emit( mov(catch_tmp,jsr(CG_PTR,"bbObjectDowncast",ex_tmp,type->class_val->cg_exp)) );
		b->emit( bcc(CG_NE,catch_tmp,sym("bbNullObject",CG_IMPORT),catch_syms.back()) );
	}
	b->emit( eva(jsr(CG_INT32,"bbExThrow",ex_tmp)) );
	for( k=0;k<catches.size();++k ){
		TryCatch *t=catches[k];

		b->emit( lab(catch_syms[k]) );
		
		t->block->eval();
		
		b->emit( bra(exit_sym) );
	}
	
	b->emit( lab(exit_sym) );
}

//******************** Throw *************************
void ThrowStm::eval( Block *b ){
	Val *val=exp->eval( b );
	if( !val->type->objectType() ) fail( "'Throw' expression must be an object" );
	b->emit( eva(jsr(CG_INT32,"bbExThrow",val->cg_exp)) );
}

//********************* Data *************************
void DataStm::eval( Block *b ){
	int k;
	if( b!=mainFun ) fail( "Data can only be declared in main program" );
	FunBlock *f=mainFun;
	CGDat *d=f->dataStms();
	for( k=0;k<exps.size();++k ){
		Val *v=exps[k]->eval( b );
		if( v->type->nullType() ) fail( "Data items can not be 'Null'" );
		if( !v->constant() ) fail( "Data items must be constant" );
		if( v->type->intType() ) v=v->cast(Type::int32);
		string t;
		switch( v->type->encoding()[0] ){
		case 'i':t="bbIntTypeTag";break;
		case 'f':t="bbFloatTypeTag";break;
		case 'd':t="bbDoubleTypeTag";break;
		case '$':t="bbStringTypeTag";break;
		default:fail( "Data items must be numeric or strings" );
		}
		d->push_back( sym(t,CG_IMPORT) );
		d->push_back( v->cg_exp );
	}
}

//******************** Restore ***********************
void RestoreStm::eval( Block *b ){
	FunBlock *f=mainFun;
	map<string,LabelStm*>::iterator it=f->labels.find( tolower(ident) );
	if( it==f->labels.end() ) fail( "Label '%s' not found",ident.c_str() );
	b->emit( mov(mem(CG_PTR,f->dataPtr(),0),it->second->restore_sym) );
}

//********************* Read *************************
void ReadStm::eval( Block *b ){
	int k;
	FunBlock *f=mainFun;
	CGDat *d=f->dataPtr();
	CGTmp *p=tmp(CG_PTR);
	CGTmp *q=tmp(CG_PTR);
	b->emit( mov(p,mem(CG_PTR,d,0)) );
	for( k=0;k<exps.size();++k ){
		Val *v=exps[k]->evalRef( b );
		Type *ty=v->type;
		if( !ty->refType() ) fail( "Read may only be used with variables" );
		if( !ty->numericType() && !ty->stringType() ) fail( "Read may only be used with numeric or string variables" );
		string f;
		int cg_ty;
		if( ty->intType() ){
			f="bbConvertToInt";
			cg_ty=CG_INT32;
		}else if( ty->floatType() ){
			f="bbConvertToFloat";
			cg_ty=CG_FLOAT64;
		}else if( ty->stringType() ){
			f="bbConvertToString";
			cg_ty=CG_PTR;
		}else{
			fail( "Read may only be used with numeric or string variables" );
		}
		b->emit( mov(q,mem(CG_PTR,p,0)) );
		if( opt_debug ){
			CGSym *skip=sym();
			b->emit( bcc(CG_NE,q,lit0,skip) );
			b->emit( eva(jsr(CG_INT32,"brl_blitz_OutOfDataError")) );
			b->emit( lab(skip) );
		}
		b->emit( mov(q,mem(CG_PTR,q,0)) );
		b->emit( mov(p,bop(CG_ADD,p,lit(4))) );
		CGExp *e=cvt(ty->cgType(),jsr(cg_ty,f,p,q));
		b->assignRef( v,new Val(ty,e) );
		b->emit( mov(p,bop(CG_ADD,p,lit(4))) );
		CGSym *skip=sym();
		b->emit( bcc(CG_NE,mem(CG_INT8,q,0),lit('d'),skip) );
		b->emit( mov(p,bop(CG_ADD,p,lit(4))) );
		b->emit( lab(skip) );
	}
	b->emit( mov(mem(CG_PTR,d,0),p) );
}
