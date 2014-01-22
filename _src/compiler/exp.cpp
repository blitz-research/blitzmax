 
#include "std.h"
#include "exp.h"
#include "toker.h"

using namespace CG;

//**************** Expression *********************
Exp::~Exp(){
}

//internal eval
Val *Exp::_eval( Scope *sc ){
	fail( "TODO!" );
	return 0;
}

Val *Exp::eval( Scope *sc ){
	return _eval(sc);
}

Val *Exp::eval( Scope *sc,Type *ty ){
	Val *v=_eval(sc);
	return v->cast(ty);
}

Val *Exp::evalRef( Block *b ){
	Val *v=_eval(b);
	if( !v->type->refType() ) fail( "Expression must be a variable" );
	v=b->linearizeRef(v);
	return v;
}

Val *Exp::evalInit( Scope *sc,Type *ty ){
	return _eval( sc )->initCast( ty );
}

//************ Expression sequence ****************
ExpSeq::ExpSeq(){
}

ExpSeq::~ExpSeq(){
}

//************** Cast Expression ******************
Val *CastExp::_eval( Scope *sc ){
	Val *v=exp->eval(sc);
	v=v->explicitCast( type );
	return v;
}

//*************** Val Expression ******************
Val *ValExp::_eval( Scope *sc ){
	return val;
}

//************ Local Decl Expression **************
Val *LocalDeclExp::_eval( Scope *sc ){

	Block *b=dynamic_cast<Block*>(sc);
	assert(b);

	Val *v=new Val(type,tmp(type->cgType()));
	Decl *d=new Decl( ident,v );
	
	Val *i=Val::null(type);
	FunBlock *func=b->fun_block;

	if( strictMode ){
		b->initRef( v,i );
		block->declLocal( d );
	}else{
		b->assignRef( v,i );
		func->declLocal( d );
	}
	
	if( !strictMode || opt_debug ){
		func->cg_enter->push_back( mov(v->cg_exp,i->cg_exp) );
	}
	
	return v;
}

//************* Global Expression *****************
Val *GlobalExp::_eval( Scope *sc ){
	Val *v=mainFun->find(ident);
	if( !v ) badid( ident );
	return v;
}

//************** Ident Expression *****************
Val *IdentExp::_eval( Scope *sc ){
	Val *v=sc->find(ident);
	
	if( !v ){
		if( !strictMode ){
			if( Block *b=dynamic_cast<Block*>(sc) ){
				FunBlock *f=b->fun_block;
				Type *ty=new RefType(type ? type : Type::int32);
				v=new Val(ty,tmp(ty->cgType()));
				f->cg_enter->push_back( mov(v->cg_exp,(new Val(Type::null,0))->cast(ty)->cg_exp) );
				f->declLocal(new Decl(ident,v));
				return v;
			}
		}
		badid(ident);
	}
	
	if( !v->cg_exp ) fail( "Identifier '%s' is not a legal expression",ident.c_str() );
	
	if( type ){
		Type *ty=v->type;
		if( FunType *t=ty->funType() ) ty=t->return_type;
		else if( ArrayType *t=ty->arrayType() ) ty=t->element_type;
		if( !type->equals(ty) ) fail( "Identifier type does not match declared type" );
	}
	
	return v;
}

//************** Member Expression ****************
Val *MemberExp::_eval( Scope *sc ){
	return rhs->eval( lhs->eval( sc ) );
}

//*************** Null Expression *****************
Val *NullExp::_eval( Scope *sc ){
	return new Val( Type::null,0 );
}

//*************** Self Expression *****************
Val *SelfExp::_eval( Scope *sc ){
	Block *b=dynamic_cast<Block*>(sc);
	Val *v=b ? b->fun_block->fun_scope : 0;
	if( !v ) fail( "'Self' can only be used within methods" );
	return v;
}

//************** Super Expression *****************
Val *SuperExp::_eval( Scope *sc ){
	Block *b=dynamic_cast<Block*>(sc);
	Val *v=b ? b->fun_block->fun_scope : 0;
	if( !v ) fail( "'Super' can only be used within methods" );
	return new SuperVal( v );
}

//*************** New Expression ******************
Val *NewExp::_eval( Scope *sc ){

	Val *v=exp->eval(sc);
	
	ClassType *t=v->type->classType();

	if( !t ){
		ObjectType *o=v->type->objectType();
		if( !o ) fail( "Subexpression for 'New' must be a user defined type or object" );
		t=o->class_val->type->classType(); 
		assert(t);
		v=new Val( t,mem(CG_PTR,v->cg_exp,0) );
	}else if( t->attrs & ClassType::ABSTRACT ){
		string tyname="?";
		if( IdentExp *ie=dynamic_cast<IdentExp*>(exp) ) tyname=ie->ident;
		set<string> ids;
		while( t ){
			int k;
			for( k=0;k<t->methods.size();++k ){
				Decl *d=t->methods[k];
				if( ids.count(d->ident) ) continue;
				if( FunType *f=d->val->type->funType() ){
					if( f->attrs & FunType::ABSTRACT ){
						fail( "Unable to create new object of abstract type '%s' due to abstract method '%s'",tyname.c_str(),d->ident.c_str() );
					}
				}
				ids.insert(d->ident);
			}
			t=t->superClass();
		}
		fail( "Unable to create new object of abstract type '%s'",tyname.c_str() );
	}else if( t->attrs & ClassType::EXTERN ){
		fail( "'New' can not be used to create extern objects" );
	}
	
	Type *type=new ObjectType(v);
	v=new Val(type,jsr(CG_PTR,"bbObjectNew",v->cg_exp));
	return v;
}

//************** Array Expression *****************
Val *ArrayExp::_eval( Scope *sc ){

	if( !type ){
		Val *v=exp->eval(sc);
		type=v->type;
		if( !type->classType() ) fail( "Subexpression for 'New array' must be a Type" );
		type=new ObjectType(v);
	}
	
	ArrayType *arr=new ArrayType( type,dims.size() );

	string e=type->encoding();
	if( e.size() && e[0]==':' && type->exObjectType() ) e='?'+e.substr(1);

	CGDat *d=dat();
	d->push_back( lit(tobstring(e),CG_CSTRING) );

	CGJsr *cg;
	if( dims.size()==1 ){
		cg=jsr(CG_PTR,"bbArrayNew1D",d,dims[0]->eval(sc,Type::int32)->cg_exp);
	}else{
		cg=jsr(CG_PTR,"bbArrayNew",d,lit((int)dims.size()) );
		for( int k=0;k<dims.size();++k ){
			cg->args.push_back( dims[k]->eval(sc,Type::int32)->cg_exp );
		}
	}

	Val *v=new Val(arr,cg);
	return v;
}

//************ AutoArray Expression ***************
Val *ArrayDataExp::_eval( Scope *sc ){
	if( !exps.size() ) return new Val( Type::null,0 );
	
	int k;
	Type *ty=0;
	vector<Val*> vals;

	for( k=0;k<exps.size();++k ){
		Val *v=exps[k]->eval(sc);
		if( !v->type || v->type->nullType() ){
			fail( "Auto array element has no type" );
		}
		if( !ty ){
			ty=v->type;
		}else{
			if( !ty->equals(v->type) ) fail( "Auto array elements must have identical types" );
		}
		vals.push_back( v );
	}
	
	vector<CGStm*> stms;

	CGTmp *t=tmp(CG_PTR);
	stms.push_back( mov(t,jsr(CG_PTR,"bbArrayNew1D",genCString(ty->encoding()),lit((int)vals.size()))) );
	
	for( k=0;k<vals.size();++k ){
		Val *v=vals[k]->cast( ty );
		if( ty->objectType() && !opt_threaded ){
			v=v->retain();
		}
		stms.push_back( mov(mem(ty->cgType(),t,k*ty->size()+24),v->cg_exp) );
	}
	
	return new Val( new ArrayType(ty,1),esq( seq(stms),t ) );
}

//************ Intrinsic Expression ***************
Val *IntrinsicExp::_eval( Scope *sc ){
	if( toke==T_VARPTR ){
		if( type ) fail( "No return type permitted for 'Varptr'" );
	
		Val *v=exp->eval(sc);
		RefType *t=v->type->refType();
		if( !t ) fail( "Subexpression for 'Ptr' must be a variable" );
		
		Type *type=new PtrType(t->val_type);
		
		return new Val(type,lea(v->cg_exp));
		
	}else if( toke==T_LEN ){
		if( type && type->encoding()!="i" ) fail( "Return type for 'Len' must be Int" );
	
		Val *v=exp->eval(sc);
		if( v->type->stringType() ){
			if( v->constant() ) return new Val((int)v->stringValue().size());
			return new Val(Type::int32,mem(CG_INT32,v->cg_exp,8));
		}else if( v->type->arrayType() ){
			return new Val(Type::int32,mem(CG_INT32,v->cg_exp,20));
		}
		return new Val(Type::int32,lit1);
		
	}else if( toke==T_SIZEOF ){
		if( type && type->encoding()!="i" ) fail( "Return type for 'SizeOf' must be Int" );
	
		Val *v=exp->eval(sc);
		if( v->type->stringType() ){
			if( v->constant() ) return new Val((int)v->stringValue().size()*2);
			return new Val(Type::int32,bop(CG_MUL,mem(CG_INT32,v->cg_exp,8),lit(2)));
		}else if( v->type->arrayType() ){
			return new Val(Type::int32,mem(CG_INT32,v->cg_exp,16));
		}else if( ObjectType *t=v->type->objectType() ){
			return new Val(Type::int32,lit(t->objectClass()->sizeof_fields-8));
		}else if( ClassType *t=v->type->classType() ){
			if( t->attrs & ClassType::EXTERN ){
			}else{
				return new Val(Type::int32,lit(t->sizeof_fields-8));
			}
		}
		return new Val(Type::int32,lit(v->type->size()));
		
	}else if( toke==T_CHR ){
		if( type && type->encoding()!="$" ) fail( "Return type for 'Chr' must be String" );
	
		Val *v=exp->eval(sc,Type::int32);
		if( v->constant() ){
			return new Val( bstring(1,(bchar_t)v->intValue()) );
		}
		return new Val( Type::stringObject,jsr(CG_PTR,"bbStringFromChar",v->cg_exp) );
		
	}else if( toke==T_ASC ){
		if( type && type->encoding()!="i" ) fail( "Return type for 'Asc' must be Int" );
	
		Val *v=exp->eval(sc,Type::stringObject);
		if( v->constant() ){
			if( v->stringValue().size() ) return new Val( (int)v->stringValue()[0] );
			return new Val(-1);
		}
		return new Val( Type::int32,jsr(CG_INT32,"bbStringAsc",v->cg_exp) );
		
	}else if( toke==T_INCBINPTR ){
		if( type && type->encoding()!="*b" ) fail( "Return type for 'IncbinPtr' must be Byte Ptr" );
	
		Val *v=exp->eval(sc,Type::stringObject);
		return new Val( Type::bytePtr,jsr(CG_PTR,"bbIncbinPtr",v->cg_exp) );
		
	}else if( toke==T_INCBINLEN ){
		if( type && type->encoding()!="i" ) fail( "Return type for 'IncbinLen' must be Int" );
	
		Val *v=exp->eval(sc,Type::stringObject);
		return new Val( Type::int32,jsr(CG_INT32,"bbIncbinLen",v->cg_exp) );

	}else{

		fail( "Internal error" );
	}
	return 0;
}

//************* ExpSeq Expression *****************
Val *ExpSeqExp::_eval( Scope *sc ){
	assert(0);
	return 0;
}

Val *ExpSeqExp::invokeFun( Val *v,FunType *fun,Scope *sc ){

	if( seq.size()>fun->args.size() ) fail( "Too many function parameters" );
	
	vector<Val*> args;
	vector<CGExp*> cg_args;
	CGSeq *cleanup=CG::seq(0);

	int k;
	for( k=0;k<fun->args.size();++k ){
		Decl *d=fun->args[k];
		Type *ty=d->val->type;
		if( k<seq.size() && seq[k] ){
			Val *t=seq[k]->eval(sc)->funArgCast(ty,cleanup);
			args.push_back(t);
		}else if( CGExp *e=d->val->cg_exp ){
			args.push_back( new Val(d->val->type,e) );
		}else{
			fail( "Missing function parameter '%s'",d->ident.c_str() );
		}
		cg_args.push_back( args.back()->cg_exp );
	}

	Type *ty=fun->return_type;
	CGExp *e=jsr( ty->cgType(),fun->call_conv,v->cg_exp,cg_args );
	
	if( ty->cstringType() ){
		ty=Type::stringObject;
		e=jsr( CG_PTR,"bbStringFromCString",e );
	}else if( ty->wstringType() ){
		ty=Type::stringObject;
		e=jsr( CG_PTR,"bbStringFromWString",e );
	}
	
	if( cleanup->stms.size() ){
		CGTmp *t=tmp( ty->cgType() );
		CGSeq *tseq=CG::seq(0);
		tseq->push_back( mov(t,e) );
		tseq->push_back( cleanup );
		e=esq( tseq,t );
	}

	return new Val( ty,e );
}

Val *ExpSeqExp::performCast( Val *lhs,Scope *sc ){

	if( seq.size()!=1 ) fail( "Illegal subexpression for object cast" );
	
	Val *rhs=seq[0]->eval(sc);

	return rhs->explicitCast( new ObjectType(lhs) );
}

Val *ExpSeqExp::indexString( Val *v,Scope *sc ){
	if( seq.size()!=1 ) fail( "Illegal subexpression for string index" );
	
	CGExp *p=v->cg_exp;

	CGExp *e=seq[0]->eval( sc,Type::int32 )->cg_exp;

	if( opt_debug ){
		p=tmp(CG_PTR);
		CGTmp *t=tmp(CG_INT32);
		CGSym *q=sym();
		CGStm *stms=CG::seq(
			mov(p,v->cg_exp),
			mov(t,e),
			bcc(CG_LTU,t,mem(CG_INT32,p,8),q),
			eva(jsr(CG_INT32,"brl_blitz_ArrayBoundsError")),
			lab(q),
		0 );
		e=esq(stms,t);
	}

	e=cvt( CG_INT32,mem( CG_INT16,bop(CG_ADD,p,bop(CG_MUL,e,lit(2))),12 ) );
	return new Val(Type::int32,e);

//	Val *i=seq[0]->eval( sc,Type::int32 );
//	CGExp *e=cvt( CG_INT32,mem( CG_INT16,bop(CG_ADD,v->cg_exp,bop(CG_MUL,i->cg_exp,lit(2))),12 ) );
//	return new Val(Type::int32,e);
}

Val *ExpSeqExp::indexArray( Val *v,ArrayType *arr,Scope *sc ){

	if( arr->dims!=seq.size() ) fail( "Incorrect number of array dimensions" );

	CGExp *cg_exp=v->cg_exp,*p=0;
	
	bool sidefx=cg_exp->sideEffects();
	if( sidefx ) cg_exp=tmp(CG_PTR);

	for( int k=0;k<seq.size();++k ){
		
		Val *v=seq[k]->eval(sc)->cast( Type::int32 );
		
		CGExp *e=v->cg_exp;
		
		if( k<seq.size()-1 ) e=bop(CG_MUL,e,mem(CG_INT32,cg_exp,k*4+24));
		
		if( opt_debug ){
			CGTmp *t=tmp(CG_INT32);
			CGSym *q=sym();
			CGStm *stms=CG::seq(
				mov(t,e),
				bcc(CG_LTU,t,mem(CG_INT32,cg_exp,k*4+20),q),
				eva(jsr(CG_INT32,"brl_blitz_ArrayBoundsError")),
				lab(q),
			0 );
			e=esq(stms,t);
		}
		
		if( p ) p=bop(CG_ADD,p,e);
		else p=e;
	}
	
	Type *ty=arr->element_type;
	
	p=bop(CG_ADD,cg_exp,bop(CG_MUL,p,lit(ty->size())));
	
	if( sidefx ) p=esq( mov(cg_exp,v->cg_exp),p );
	
	p=mem(ty->cgType(),p,seq.size()*4+20);
	
	return new Val(ty,p);
}

Val *ExpSeqExp::indexPointer( Val *v,Type *t,Scope *sc ){
	if( seq.size()!=1 ) fail( "Illegal subexpression for pointer index" );

	Val *i=seq[0]->eval( sc,Type::int32 );
	CGExp *e=mem( t->cgType(),
				bop(CG_ADD,v->cg_exp,
					bop(CG_MUL,i->cg_exp,lit(t->size()))),0);
	Type *type=new RefType(t);
	return new Val(type,e);
}

//************* Invoke Expression *****************
Val *InvokeExp::_eval( Scope *sc ){
	Val *v=exp->eval(sc);
	Type *type=v->type;

	if( FunType *t=type->funType() ){
		return invokeFun( v,t,sc );
	}else if( ClassType *t=type->classType() ){
		return performCast( v,sc );
	}else if( ArrayType *t=type->arrayType() ){
		if( !strictMode ) return indexArray( v,t,sc );
	}
	if( !strictMode ){
		if( IdentExp *ie=dynamic_cast<IdentExp*>(exp) ){
			fail( "Identifier '%s' not found",ie->ident.c_str() );
		}
	}
	fail( "Expression of type '%s' cannot be invoked",type->toString().c_str() );
	return 0;
}

//************** Index Expression *****************
Val *IndexExp::_eval( Scope *sc ){

	Val *v=exp->eval(sc);
	Type *type=v->type;

	if( ArrayType *t=type->arrayType() ){
		return indexArray( v,t,sc );
	}else if( PtrType *t=type->ptrType() ){
		return indexPointer( v,t->val_type,sc );
	}else if( type->stringType() ){
		return indexString( v,sc );
	}
	fail( "Expression of type '%s' cannot be indexed",type->toString().c_str() );
	return 0;
}

//************** Slice Expression *****************
Val *SliceExp::_eval( Scope *sc ){

	Val *v=exp->eval(sc);

	ArrayType *arr=v->type->arrayType();
	StringType *str=v->type->stringType();

	if( (!arr && !str) || (arr && arr->dims!=1) ) fail( "Slices can only be used with strings or one dimensional arrays" );

	CGExp *e=v->cg_exp,*t=0;
	if( !rhs && v->cg_exp->sideEffects() ){
		t=e;
		e=tmp(CG_PTR);
	}

	CGExp *l=lhs ? lhs->eval(sc,Type::int32)->cg_exp : lit0;
	CGExp *r=rhs ? rhs->eval(sc,Type::int32)->cg_exp : mem(CG_INT32,e,arr ? 20 : 8);
	
	if( str ){
		l=jsr(CG_PTR,"bbStringSlice",e,l,r);
	}else{
		CGExp *ty=genCString( arr->element_type->encoding() );
		l=jsr(CG_PTR,"bbArraySlice",ty,e,l,r);
	}
	
	Type *ty=v->type;
	if( RefType *r=ty->refType() ) ty=r->val_type;

	if( !t ) return new Val( ty,l );

	return new Val( ty,esq(mov(e,t),l) );
}

//************* Compare Expression ****************
Val *CmpExp::_eval( Scope *sc ){

	Val *l=lhs->eval(sc);
	Val *r=rhs->eval(sc);
	
	if( l->type->ptrType() && r->type->nullType() ) r=r->cast(l->type);
	else if( r->type->ptrType() && l->type->nullType() ) l=l->cast(r->type);

	if( PtrType *px=l->type->ptrType() ){
		if( PtrType *py=r->type->ptrType() ){
			if( px->val_type->equals( py->val_type ) ){
				int cgop;
				switch( op ){
				case T_LT:cgop=CG_LT;break;
				case T_EQ:cgop=CG_EQ;break;
				case T_GT:cgop=CG_GT;break;
				case T_LE:cgop=CG_LE;break;
				case T_GE:cgop=CG_GE;break;
				case T_NE:cgop=CG_NE;break;
				}
				return new Val(Type::int32,scc(cgop,l->cg_exp,r->cg_exp));
			}
		}
	}

	if( l->type->ptrType() || r->type->ptrType() ){
		fail( "Pointer type mismatch" );
	}

	Type *ty=l->balance(r);
	
	if( ty->numericType() ){
	}else if( ty->stringType() ){
	}else if( ObjectType *obj=ty->objectType() ){
		if( op!=T_EQ && op!=T_NE ) fail( "Operator '%s' cannot be applied to objects",Toker::toString(op).c_str() );
	}else if( ObjectType *obj=ty->exObjectType() ){
		if( op!=T_EQ && op!=T_NE ) fail( "Operator '%s' cannot be applied to extern objects",Toker::toString(op).c_str() );
	}else if( FunType *fun=ty->funType() ){
		if( (op!=T_EQ && op!=T_NE) || (fun->attrs & FunType::METHOD) ){
			const char *p=(fun->attrs & FunType::METHOD) ? "methods" : "functions";
			fail( "Operator '%s' cannot be applied to %s",Toker::toString(op).c_str(),p );
		}
	}else if( ty->nullType() ){
		if( op!=T_EQ && op!=T_NE )  fail( "Operator '%s' cannot be applied to 'Null'",Toker::toString(op).c_str() );
		return new Val( op==T_EQ ? 1 : 0);
	}else{
		fail( "Operands cannot be compared" );
	}
	
	l=l->cast(ty);
	r=r->cast(ty);

	if( l->constant() && r->constant() ){
		int z;
		if( ty->intType() ){
			int64 x=l->intValue(),y=r->intValue();
			switch(op){
			case T_LT:z=x<y;break;
			case T_EQ:z=x==y;break;
			case T_GT:z=x>y;break;
			case T_LE:z=x<=y;break;
			case T_GE:z=x>=y;break;
			case T_NE:z=x!=y;break;
			}
		}else if( ty->floatType() ){
			double x=l->floatValue(),y=r->floatValue();
			switch(op){
			case T_LT:z=x<y;break;
			case T_EQ:z=x==y;break;
			case T_GT:z=x>y;break;
			case T_LE:z=x<=y;break;
			case T_GE:z=x>=y;break;
			case T_NE:z=x!=y;break;
			}
		}else if( ty->stringType() ){
			bstring x=l->stringValue(),y=r->stringValue();
			switch(op){
			case T_LT:z=x<y;break;
			case T_EQ:z=x==y;break;
			case T_GT:z=x>y;break;
			case T_LE:z=x<=y;break;
			case T_GE:z=x>=y;break;
			case T_NE:z=x!=y;break;
			}
		}else{
			fail( "Operands cannot be compared" );
		}
		return new Val(z);
	}

	int cgop;
	switch( op ){
	case T_LT:cgop=CG_LT;break;
	case T_EQ:cgop=CG_EQ;break;
	case T_GT:cgop=CG_GT;break;
	case T_LE:cgop=CG_LE;break;
	case T_GE:cgop=CG_GE;break;
	case T_NE:cgop=CG_NE;break;
	}

	Val *t;
	if( ty->stringType() ){
		t=new Val(Type::int32,scc(cgop,jsr(CG_INT32,"bbStringCompare",l->cg_exp,r->cg_exp),lit0));
	}else{
		t=new Val(Type::int32,scc(cgop,l->cg_exp,r->cg_exp));
	}
	return t;
}

//************ Short Circuit Expression ***********
Val *ShortCircExp::_eval( Scope *sc ){

	Val *lv=lhs->eval(sc)->cond();
	Val *rv=rhs->eval(sc)->cond();
	
	int cg_op=op==T_AND ? CG_EQ : CG_NE;
	
	//result reg
	CGSym *e=sym();
	CGTmp *r=tmp(CG_INT32);
	
	CGStm *stms=seq(
		mov(r,lv->cg_exp),
		bcc(cg_op,r,lit0,e),
		mov(r,rv->cg_exp),
		lab(e), 
	0 );
	
	return new Val(Type::int32,esq(stms,r));
}

//***************** Not Expression ****************
Val *NotExp::_eval( Scope *sc ){

	Val *v=exp->eval(sc)->cond();
	
	if( v->constant() ) return new Val( !v->intValue() );

	return new Val(Type::int32,scc(CG_EQ,v->cg_exp,lit0));
}

//**************** Unary Expression ***************
Val *UnaryExp::_eval( Scope *sc ){
	Val *v=exp->eval(sc);
	Type *ty=v->type;

	if( !ty->numericType() ){
		fail( "Subexpression for '%s' must be of numeric type",Toker::toString(op).c_str() );
	}
	
	switch( op ){
	case '+':
		return v;
	case '~':
		if( !v->type->intType() ) fail( "Bitwise complement can only be used with integers" );
		if( v->type->cgType()!=CG_INT64 ) v=v->cast( Type::int32 );
		break;
	}

	ty=v->type;
	
	if( v->constant() ){
		if( ty->intType() ){
			int64 n=v->intValue();
			switch( op ){
			case '-':n=-n;break;
			case '~':n=~n;break;
			case T_ABS:n=(n>=0) ? n : -n;break;
			case T_SGN:n=(n==0) ? 0 : (n>0 ? 1 : -1);break;
			default:assert(0);
			}
			return new Val(n,ty);
		}else{
			double n=v->floatValue();
			switch( op ){
			case '-':n=-n;break;
			case T_ABS:n=fabs(n);break;
			case T_SGN:n=(n==0) ? 0 : (n>0 ? 1 : -1);break;
			default:assert(0);
			}
			return new Val(n,ty);
		}
		assert(0);
	}

	int cgop;
	switch( op ){
	case '-':cgop=CG_NEG;break;
	case '~':cgop=CG_NOT;break;
	case T_ABS:cgop=CG_ABS;break;
	case T_SGN:cgop=CG_SGN;break;
	default:assert(0);
	}

	return new Val(ty,uop(cgop,v->cg_exp));
}

//**************** Arith Expression ***************
Val *ArithExp::pointerArith( Val *lv,Val *rv ){

	PtrType *lp=lv->type->ptrType();
	PtrType *rp=rv->type->ptrType();
	PtrType *ty=lp ? lp : rp;
	
	CGLit *sz=lit( ty->val_type->size() );
	
	if( lp && rp ){
		if( op!='-' ) fail( "Illegal pointer arithmetic operator" );
		if( !lp->equals(rp) ) fail( "Pointer types are not equivalent" );
		CGExp *e=bop(CG_DIV,bop(CG_SUB,lv->cg_exp,rv->cg_exp),sz);
		return new Val(Type::int32,e);
	}
	CGExp *e=0;
	if( lp ){
		rv=rv->cast(Type::int32);
		if( op=='+' ) e=bop(CG_ADD,lv->cg_exp,bop(CG_MUL,rv->cg_exp,sz));
		else if( op=='-' ) e=bop(CG_SUB,lv->cg_exp,bop(CG_MUL,rv->cg_exp,sz));
	}else{
		lv=lv->cast(Type::int32);
		if( op=='+' ) e=bop(CG_ADD,rv->cg_exp,bop(CG_MUL,lv->cg_exp,sz));
	}
	if( !e ) fail( "Illegal pointer arithmetic operator" );
	return new Val( ty,e );
}

Val *ArithExp::_eval( Scope *sc ){
	Val *l=lhs ? lhs->eval(sc) : lhs_val;
	Val *r=rhs ? rhs->eval(sc) : rhs_val;
	
	if( l->type->ptrType() || r->type->ptrType() ) return pointerArith(l,r);

	Type *ty=0;

	if( op=='^' ){
		ty=Type::float64;
	}else if( ArrayType *p=l->type->arrayType() ){
		if( ArrayType *q=r->type->arrayType() ){
			if( p->dims==q->dims ){
				if( p->element_type->equals( q->element_type ) ){
					ty=p;
				}else if( ObjectType *pt=p->element_type->objectType() ){
					if( ObjectType *qt=q->element_type->objectType() ){
						if( pt->extends(qt) ){
							ty=q;
						}else if( qt->extends(pt) ){
							ty=p;
						}else{
							ty=new ArrayType( Type::objectObject,p->dims );
						}
					}
				}
			}
		}
	}

	if( !ty ) ty=l->balance(r);
	
	if( ty->nullType() ){
		fail( "Operator '%s' cannot be used with null",Toker::toString(op).c_str() );
	}else if( ty->arrayType() ){
		if( op!='+' ) fail( "Operator '%s' can not be used with arrays",Toker::toString(op).c_str() );
	}else if( ty->stringType() ){
		if( op!='+' ) fail( "Operator '%s' can not be used with strings",Toker::toString(op).c_str() );

	}else if( !ty->numericType() ){
		fail( "Operator '%s' can only be used with numeric types",Toker::toString(op).c_str() );
	}
	
	l=l->cast(ty);
	r=r->cast(ty);

	if( l->constant() && r->constant() ){
		if( ty->intType() ){
			int64 x=l->intValue(),y=r->intValue();
			switch( op ){
			case '+':x+=y;break;
			case '-':x-=y;break;
			case '*':x*=y;break;
			case '/':if( !y ) fail( "Integer division by zero" );x/=y;break;
			case '^':x=(int)pow((double)x,(double)y);break;
			case T_MOD:if( !y ) fail( "Integer division by zero" );x%=y;break;
			case T_MIN:x=x<y ? x : y;break;
			case T_MAX:x=x>y ? x : y;break;
			default:assert(0);
			}
			return new Val(x,ty);
		}else if( ty->floatType() ){
			double x=l->floatValue(),y=r->floatValue();
			switch( op ){
			case '+':x+=y;break;
			case '-':x-=y;break;
			case '*':x*=y;break;
			case '/':x/=y;break;
			case '^':x=pow(x,y);break;
			case T_MOD:x=fmod(x,y);break;
			case T_MIN:x=x<y ? x : y;break;
			case T_MAX:x=x>y ? x : y;break;
			default:assert(0);
			}
			return new Val(x,ty);
		}else if( ty->stringType() ){
			bstring x=l->stringValue(),y=r->stringValue();
			switch( op ){
			case '+':x+=y;break;
			default:assert(0);
			}
			return new Val(x);
		}
		assert(0);
	}
	
	if( ArrayType *t=ty->arrayType() ){
		if( l->type->arrayType()->dims!=1 || r->type->arrayType()->dims!=1 ){
			fail( "Multi-dimensional arrays can not be concatenated" );
		}
		CGExp *e=jsr(CG_PTR,"bbArrayConcat",genCString(t->element_type->encoding()),l->cg_exp,r->cg_exp );
		return new Val(ty,e);
	}

	if( ty->stringType() ){
		CGExp *e=jsr(CG_PTR,"bbStringConcat",l->cg_exp,r->cg_exp );
		return new Val(ty,e);
	}
	
	if( op=='^' ){
		CGExp *e=jsr(CG_FLOAT64,"bbFloatPow",l->cg_exp,r->cg_exp );
		return new Val(ty,e);
	}
	
	int cgop;
	switch( op ){
	case '+':cgop=CG_ADD;break;
	case '-':cgop=CG_SUB;break;
	case '*':cgop=CG_MUL;break;
	case '/':cgop=CG_DIV;break;
	case T_MOD:cgop=CG_MOD;break;
	case T_MIN:cgop=CG_MIN;break;
	case T_MAX:cgop=CG_MAX;break;
	default:assert(0);
	}

	return new Val(ty,bop(cgop,l->cg_exp,r->cg_exp));
}

//*************** Bitwise Expression **************
Val *BitwiseExp::_eval( Scope *sc ){

	Val *l=lhs ? lhs->eval(sc) : lhs_val;
	Val *r=rhs ? rhs->eval(sc) : rhs_val;
	
	if( !l->type->intType() || !r->type->intType() ) fail( "Bitwise operators can only be used with integers" );
	
	Type *ty=Type::int32;
	if( l->type->cgType()==CG_INT64 || r->type->cgType()==CG_INT64) ty=Type::int64;
	
	l=l->cast(ty);
	r=r->cast(ty);
	
	if( l->constant() && r->constant() ){
		int64 x=l->intValue(),y=r->intValue();
		switch( op ){
		case '&':x&=y;break;
		case '|':x|=y;break;
		case '~':x^=y;break;
		case T_SHL:x<<=y;break;
		case T_SAR:x>>=y;break;
		case T_SHR:x=(unsigned)x>>(unsigned)y;break;
		default:assert(0);
		}
		return new Val(x,ty);
	}

	int cgop;
	switch( op ){
	case '&':cgop=CG_AND;break;
	case '|':cgop=CG_ORL;break;
	case '~':cgop=CG_XOR;break;
	case T_SHL:cgop=CG_SHL;break;
	case T_SHR:cgop=CG_SHR;break;
	case T_SAR:cgop=CG_SAR;break;
	default:assert(0);
	}

	return new Val(ty,bop(cgop,l->cg_exp,r->cg_exp));
}
