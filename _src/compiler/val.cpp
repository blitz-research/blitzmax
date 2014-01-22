
#include "std.h"
#include "val.h"
#include "block.h"

using namespace CG;

static CGLit *literal( CGExp *e ){
	if( CGLit *t=e->lit() ) return t;
	if( CGDat *t=e->dat() ){
		if( t->exps.size()==3 ) return t->exps[2]->lit();
	}
	if( CGSym *t=e->sym() ){
		if( t->value=="bbEmptyString" ) return lit(bstring());
	}
	return 0;
}

//********************* Val ***********************
Val::Val( int n,Type *ty ):type(ty){
	assert( ty->intType() );
	switch( ty->cgType() ){
	case CG_INT8:n&=0xff;break;
	case CG_INT16:n&=0xffff;break;
	}
	cg_exp=ty->cgType()==CG_INT64 ? lit( int64(n) ) : lit( int(n) );
}

Val::Val( int64 n,Type *ty ):type(ty){
	assert( ty->intType() );
	switch( ty->cgType() ){
	case CG_INT8 :n&=int64(0xff);break;
	case CG_INT16:n&=int64(0xffff);break;
	case CG_INT32:n&=int64(0xffffffff);break;
	}
	cg_exp=ty->cgType()==CG_INT64 ? lit( int64(n) ) : lit( int(n) );
}

Val::Val( float n,Type *ty ):type(ty){
	assert( ty->floatType() );
	cg_exp=ty->cgType()==CG_FLOAT64 ? lit( double(n) ) : lit( float(n) );
}

Val::Val( double n,Type *ty ):type(ty){
	assert( ty->floatType() );
	cg_exp=ty->cgType()==CG_FLOAT64 ? lit( double(n) ) : lit( float(n) );
}

Val::Val( bstring t ):type(Type::stringObject){
	cg_exp=genBBString(t);
}

Val::Val( const char *t ):type(Type::c_string){
	cg_exp=genCString(t);
}

Val::Val( Type *t,CGExp *e ):type(t),cg_exp(e){
}

Val::~Val(){
}

CGExp *Val::constant(){
	return cg_exp->lit() || cg_exp->sym() ? cg_exp : 0;
}

int64 Val::intValue(){
	CGLit *t=literal( cg_exp );
	assert(t);
	switch( t->type ){
	case CG_INT8:case CG_INT16:return t->int_value;
	case CG_INT32:case CG_INT64:return t->int_value;
	case CG_FLOAT32:case CG_FLOAT64:return (int64)t->float_value;
	case CG_BSTRING:return toint(tostring(t->string_value));
	}
	assert(0);
	return 0;
}

double Val::floatValue(){
	CGLit *t=literal( cg_exp );
	assert(t);
	switch( t->type ){
	case CG_INT8:case CG_INT16:return t->int_value;
	case CG_INT32:case CG_INT64:return t->int_value;
	case CG_FLOAT32:case CG_FLOAT64:return t->float_value;
	case CG_BSTRING:return tofloat(tostring(t->string_value));
	}
	assert(0);
	return 0;
}

bstring Val::stringValue(){
	CGLit *t=literal( cg_exp );
	assert(t);
	switch( t->type ){
	case CG_INT8:return tobstring(fromint(t->int_value));
	case CG_INT16:return tobstring(fromint(t->int_value));
	case CG_INT32:return tobstring(fromint(t->int_value));
	case CG_INT64:return tobstring(fromint(t->int_value));
	case CG_FLOAT32:return tobstring(fromfloat(t->float_value));
	case CG_FLOAT64:return tobstring(fromdouble(t->float_value));
	case CG_BSTRING:return t->string_value;
	}
	assert(0);
	return tobstring("");
}

Val *Val::cond(){
	CGExp *e=0;

	if( type->nullType() ){
		e=lit0;
	}else if( type->intType() ){
		if( type->cgType()!=CG_INT64 ) return this;
		e=scc(CG_NE,cg_exp,lit(int64(0)));
	}else if( type->floatType() ){
		if( constant() ) e=floatValue() ? lit1 : lit0;
		else e=scc(CG_NE,cg_exp,type->size()==8 ? lit(0.0) : lit(0.0f));
	}else if( type->stringType() ){
		if( constant() ) e=stringValue().size() ? lit1 : lit0;
		else e=mem(CG_INT32,cg_exp,8);			//len of string
	}else if( type->arrayType() ){
		e=mem(CG_INT32,cg_exp,16);				//len of array
	}else if( type->objectType() ){
		e=scc(CG_NE,cg_exp,sym("bbNullObject",CG_IMPORT));//cmp with null object
	}else if( type->exObjectType() ){
		e=scc(CG_NE,cg_exp,lit0);				//cmp with 0
	}else if( type->ptrType() ){
		e=scc(CG_NE,cg_exp,lit0);				//cmp with 0
	}else if( FunType *f=type->funType() ){
		if( !f->method() ){
			e=scc(CG_NE,cg_exp,sym("brl_blitz_NullFunctionError",CG_IMPORT));
		}
	}

	if( !e ) fail( "Unable to convert expression to conditional value" );

	return new Val(Type::int32,e);
}

Type *Val::balance( Val *t ){
	return balance( t->type );
}

Type *Val::balance( Type *y ){

	Type *x=type;
	
	if( x->intType() ){
		if( y->intType() ) return (x->cgType()==CG_INT64 || y->cgType()==CG_INT64) ? Type::int64 : Type::int32;
		if( y->floatType() ) return y;
		if( y->stringType() ) return y;
		if( y->objectType() ) return y;
		if( y->classType() ) return y;
	}else if( x->floatType() ){
		if( y->intType() ) return x;
		if( y->floatType() ) return (x->cgType()==CG_FLOAT64 || y->cgType()==CG_FLOAT64) ? Type::float64 : Type::float32;
		if( y->stringType() ) return y;
		if( y->classType() ) return y;
		if( y->objectType() ) return y;
	}else if( x->stringType() ){
		if( y->intType() ) return x;
		if( y->floatType() ) return x;
		if( y->stringType() ) return x;
		if( y->objectType() ) return y;
		if( y->classType() ) return y;
	}else if( FunType *p=x->funType() ){
		if( FunType *q=y->funType() ){
			if( p->extends(q) ) return y;
			if( q->extends(p) ) return x;
		}
	}else if( ObjectType *p=x->objectType() ){
		if( ObjectType *q=y->objectType() ){
			if( p->extends(q) ) return y;
			if( q->extends(p) ) return x;
		}
	}else if( ObjectType *p=x->exObjectType() ){
		if( ObjectType *q=y->exObjectType() ){
			if( p->extends(q) ) return y;
			if( q->extends(p) ) return x;
		}
	}

	if( x->nullType() ) return y;
	if( y->nullType() ) return x;
	
	fail( "Types '%s' and '%s' are unrelated",x->toString().c_str(),y->toString().c_str() );
	return 0;
}

Val *Val::cast( Type *dst ){

	//nop?
	if( type->equals(dst) ) return this;
	if( type->extends(dst) ) return new Val(dst,cg_exp);

	//null casts...
	if( type->nullType() ){
		if( dst->intType() ) return new Val(0,dst);
		if( dst->floatType() ) return new Val(0.0,dst);
		if( dst->ptrType() ) return new Val(dst,lit0);
		if( dst->cstringType() ) return new Val(dst,lit0);
		if( dst->wstringType() ) return new Val(dst,lit0);
		if( dst->stringType() ) return new Val(dst,sym("bbEmptyString",CG_IMPORT));
		if( dst->arrayType() ) return new Val(dst,sym("bbEmptyArray",CG_IMPORT));
		if( dst->objectType() ) return new Val(dst,sym("bbNullObject",CG_IMPORT));
		if( dst->exObjectType() ) return new Val(dst,lit0);
		if( dst->funType() ) return new Val(dst,sym("brl_blitz_NullFunctionError",CG_IMPORT));
		fail( "Unable to cast 'Null' to '%s'",(dst->toString()).c_str() );
		return 0;
	}
	
	int cg_ty=dst->cgType();
	
	//literal conversions
	if( constant() && type->numericType() ){
		switch( cg_ty ){
		case CG_INT8:return new Val( intValue(),Type::int8 );
		case CG_INT16:return new Val( intValue(),Type::int16 );
		case CG_INT32:return new Val( intValue(),Type::int32 );
		case CG_INT64:return new Val( intValue(),Type::int64 );
		case CG_FLOAT32:return new Val( floatValue(),Type::float32 );
		case CG_FLOAT64:return new Val( floatValue(),Type::float64 );
		default:if( dst->stringType() ) return new Val( stringValue() );
		}
	}

	CGExp *e=0;

	//standard type conversions
	if( type->intType() ){
		if( dst->intType() ){
			e=cvt(cg_ty,cg_exp);
		}else if( dst->floatType() ){
			e=cvt(cg_ty,cg_exp);
		}else if( dst->stringType() ){
			if( type->cgType()==CG_INT64 ){
				e=jsr(cg_ty,"bbStringFromLong",cg_exp);
			}else{
				e=jsr(cg_ty,"bbStringFromInt",cvt(CG_INT32,cg_exp));
			}
		}
	}else if( type->floatType() ){
		if( dst->intType() ){
			e=cvt(cg_ty,cg_exp);
		}else if( dst->floatType() ){
			e=cvt(cg_ty,cg_exp);
		}else if( dst->stringType() ){
			if( type->cgType()==CG_FLOAT64 ){
				e=jsr(cg_ty,"bbStringFromDouble",cg_exp );
			}else{
				e=jsr(cg_ty,"bbStringFromFloat",cg_exp );
			}
		}
	}else if( type->stringType() ){
		/*
		if( dst->cstringType() ){
			e=jsr(CG_PTR,"bbStringToCString",cg_exp);
		}else if( dst->wstringType() ){
			e=jsr(CG_PTR,"bbStringToWString",cg_exp);
		}
		*/
	}else if( type->cstringType() ){
		/*
		if( dst->stringType() ){
			e=jsr(cg_ty,"bbStringFromCString",cg_exp);
		}else if( dst->cstringType() ){
			e=cg_exp;
		}
		*/
	}else if( type->wstringType() ){
		/*
		if( dst->stringType() ){
			e=jsr(cg_ty,"bbStringFromWString",cg_exp);
		}else if( dst->wstringType() ){
			e=cg_exp;
		}
		*/
	}else if( ArrayType *src_ty=type->arrayType() ){
		if( PtrType *dst_ty=dst->ptrType() ){
			Type *val_ty=dst_ty->val_type;
			if( val_ty->encoding()=="b" || val_ty->equals(src_ty->element_type) ){
				e=cg_exp;
				if( e->tmp() ){
					e=mem(CG_PTR,lea(e),0);
				}else if( !e->mem() ){
					CGTmp *t=tmp(CG_PTR);
					e=esq(mov(t,e),mem(CG_PTR,lea(t),0));
				}
				e=lea(mem(val_ty->cgType(),e,src_ty->dims*4+20));
			}
		}
	}else if( ObjectType *src_ty=type->objectType() ){
		if( PtrType *dst_ty=dst->ptrType() ){
			if( dst_ty->val_type->encoding()=="b" ){
				e=cg_exp;
				if( e->tmp() ){
					e=mem(CG_PTR,lea(e),0);
				}else if( !e->mem() ){
					CGTmp *t=tmp(CG_PTR);
					e=esq(mov(t,e),mem(CG_PTR,lea(t),0));
				}
				e=lea(mem(CG_PTR,e,8));
			}
		}
	}else if( ObjectType *src_ty=type->exObjectType() ){
		if( PtrType *dst_ty=dst->ptrType() ){
			if( dst_ty->val_type->encoding()=="b" ){
				e=cg_exp;
			}
		}
	}else if( PtrType *src_ty=type->ptrType() ){
		if( PtrType *dst_ty=dst->ptrType() ){
			if( dst_ty->val_type->equals(src_ty->val_type) || dst_ty->val_type->encoding()=="b" ){
				e=cg_exp;
			} 
		}else if( FunType *dst_ty=dst->funType() ){
			if( src_ty->val_type->encoding()=="b" ){
				//check for '0' func!
				CGTmp *t=tmp(CG_PTR);
				CGSym *p=sym();
				CGStm *s=CG::seq(
					mov(t,cg_exp),
					bcc(CG_NE,t,lit0,p),
					mov(t,sym("brl_blitz_NullFunctionError",CG_IMPORT)),
					lab(p),
					0 );
				e=esq(s,t);
			} 
		}
	}else if( FunType *src_ty=type->funType() ){
		if( PtrType *dst_ty=dst->ptrType() ){
			if( !src_ty->method() && dst_ty->val_type->encoding()=="b" ) e=cg_exp;
		}
	}

	if( !e ) fail( "Unable to convert from '%s' to '%s'",type->toString().c_str(),dst->toString().c_str() );

	return new Val(dst,e);
}

Val *Val::initCast( Type *dst ){
	if( !strictMode && dst->cgType()==CG_INT32 ){
		if( type->objectType() && !type->stringType() && !type->arrayType() ){
			return new Val( dst,jsr(CG_INT32,"bbHandleFromObject",cg_exp) );
		}
	}
	return cast( dst );
}

Val *Val::funArgCast( Type *dst,CGSeq *cleanup ){
	//convert reference to var
	if( VarType *var=dst->varType() ){
		RefType *ref=type->refType();
		if( !ref ) fail( "Expression for 'Var' parameter must be a variable" );
		if( !ref->val_type->extends(var->val_type) ) fail( "Variable for 'Var' parameter is not of matching type" );
		CGExp *e=lea(cg_exp);
		if( !opt_threaded && var->val_type->objectType() && cg_exp->tmp() ){
			CGMem *m=mem(CG_INT32,cg_exp,4);
			e=esq(ati(m),e);
			CGSym *l=sym();
			cleanup->push_back( CG::seq(
				atd(m,l),
				eva(jsr(CG_INT32,"bbGCFree",cg_exp)),
				lab(l),
				0) );
		}
		return new Val( dst,e );
	}
	
	//convert int32 to object
	if( !strictMode && type->cgType()==CG_INT32 ){
		if( dst->objectType() && !dst->stringType() && !dst->arrayType() ){
			Val *v=new Val( Type::objectObject,jsr(CG_PTR,"bbHandleToObject",cg_exp) );
			return v->explicitCast(dst);
		}
	}
	
	//convert string to cstring/wstring
	if( type->stringType() ){
		CGExp *e=0;
		if( dst->cstringType() || dst->ptrType("b") ){
			e=jsr(CG_PTR,"bbStringToCString",cg_exp);
		}else if( dst->wstringType() || dst->ptrType("s") ){
			e=jsr(CG_PTR,"bbStringToWString",cg_exp);
		}
		if( e ){
			CGTmp *t=tmp(CG_PTR);
			e=esq(mov(t,e),t);
			cleanup->push_back( eva(jsr(CG_INT32,"bbMemFree",t)) );
			return new Val( dst,e );
		}
	}

	return cast(dst);
}

Val *Val::explicitCast( Type *dst ){

	if( type->nullType() ) return cast(dst);

	if( type->equals(dst) ) return this;

	int cg_ty=dst->cgType();
	
	//literal conversions
	if( constant() && type->stringType() ){
		switch( cg_ty ){
		case CG_INT8:return new Val( intValue(),Type::int8 );
		case CG_INT16:return new Val( intValue(),Type::int16 );
		case CG_INT32:return new Val( intValue(),Type::int32 );
		case CG_INT64:return new Val( intValue(),Type::int64 );
		case CG_FLOAT32:return new Val( floatValue(),Type::float32 );
		case CG_FLOAT64:return new Val( floatValue(),Type::float64 );
		}
	}
	
	CGExp *e=0;
	
	if( type->ptrType() ){
		if( dst->intType() ){
			//ptr to int
			e=cvt(cg_ty,cg_exp);
		}else if( dst->ptrType() ){
			//ptr to ptr
			e=cg_exp;
		}
	}else if( type->intType() ){
		if( dst->ptrType() ){
			//int to ptr
			e=cvt(cg_ty,cg_exp);
		}
	}else if( type->stringType() ){
		if( dst->intType() ){
			//string to int
			if( cg_ty==CG_INT64 ){
				e=jsr(cg_ty,CG_CDECL,vfn(sym("bbStringToLong",CG_IMPORT),cg_exp) );
			}else{
				e=cvt(cg_ty,jsr(CG_INT32,"bbStringToInt",cg_exp));
			}
		}else if( dst->floatType() ){
			//string to float
			if( cg_ty==CG_FLOAT64 ){
				e=jsr(cg_ty,"bbStringToDouble",cg_exp );
			}else{
				e=jsr(cg_ty,"bbStringToFloat",cg_exp );
			}
		}
	}else if( ObjectType *src_ty=type->objectType() ){
		if( ObjectType *dst_ty=dst->objectType() ){
			if( dst_ty->extends(src_ty) ){
				if( ArrayType *arr_ty=dst->arrayType() ){
					e=jsr(CG_PTR,"bbArrayCastFromObject",cg_exp,genCString(arr_ty->element_type->encoding()) );
				}else{
					e=jsr(CG_PTR,"bbObjectDowncast",cg_exp,dst_ty->class_val->cg_exp);
				}
				if( dst->stringType() || dst->arrayType() ){
					CGSym *t=sym( (dst->stringType() ? "bbEmptyString" : "bbEmptyArray"),CG_IMPORT );
					CGTmp *r=tmp(CG_PTR);
					CGSym *l=sym();
					CGStm *s=CG::seq(
						mov(r,e),
						bcc(CG_NE,r,sym("bbNullObject",CG_IMPORT),l),
						mov(r,t),
						lab(l),
					0 );
					e=esq(s,r);
				}
			}
		}
	}else if( ObjectType *src_ty=type->exObjectType() ){
		if( ObjectType *dst_ty=dst->exObjectType() ){
			if( dst_ty->extends(src_ty) ){
				e=cg_exp;
			}
		}
	}
	
	if( e ) return new Val( dst,e );
	
	return cast(dst);
}

Val *Val::forEachCast( Type *dst ){

	if( type->nullType() ) return cast(dst);

	if( type->equals(dst) ) return this;

	CGExp *e=0;
	int cg_ty=dst->cgType();
	
	if( ObjectType *src_ty=type->objectType() ){
		if( ObjectType *dst_ty=dst->objectType() ){
			if( dst_ty->extends(src_ty) ){
				if( dst_ty->objectClass()->attrs & ClassType::EXTERN ){
					e=cg_exp;
				}else if( ArrayType *arr_ty=dst->arrayType() ){
					e=jsr(CG_PTR,"bbArrayCastFromObject",cg_exp,genCString(arr_ty->element_type->encoding()) );
				}else{
					e=jsr(CG_PTR,"bbObjectDowncast",cg_exp,dst_ty->class_val->cg_exp);
				}
			}
		}
	}
	
	if( e ) return new Val( dst,e );
	
	return explicitCast( dst );
}

Val *Val::find( string id ){
	Val *v=type->find(id);
	if( !v ) return 0;
	
	int n_self=v->countTmps("@self");
	int n_type=v->countTmps("@type");
	if( !n_self && !n_type ) return v;
	
	CGExp *cg=cg_exp;
		
	if( n_self && opt_debug && !type->stringType() && !type->arrayType() ){
		cg=tmp(CG_PTR);
		
		CGSym *q=sym();
		CGStm *stms=CG::seq(
			mov(cg,cg_exp),
			bcc(CG_NE,cg,sym("bbNullObject",CG_IMPORT),q),
			eva(jsr(CG_INT32,"brl_blitz_NullObjectError")),
			lab(q),
		0 );
		v=new Val(v->type,esq(stms,v->cg_exp));
	}else if( n_self+n_type>1 ){
		cg=tmp(CG_PTR);
		v=new Val(v->type,esq(mov(cg,cg_exp),v->cg_exp));
	}
	
	if( type->objectType() || type->exObjectType() ){
		if( n_self ) v=v->renameTmps( "@self",cg );
		if( n_type ) v=v->renameTmps( "@type",mem(CG_PTR,cg,0) );
	}else if( type->classType() ){
		assert( !n_self );
		if( n_type ) v=v->renameTmps( "@type",cg );
	}else{
		assert(0);
	}
	
	return v;
}

bool Val::refCounted(){
	if( opt_threaded ) return false;
	RefType *t=type->refType();
	return t && t->objectType() && cg_exp->mem();
}

Val *Val::retain(){
	if( opt_threaded ){
		fail( "Internal error: Val::retain() invoked in threaded mode." );
	}
	CGTmp *p=tmp(CG_PTR);
	CGMem *m=mem(CG_INT32,p,4);
	CGStm *t=seq(
		mov(p,cg_exp),
		ati(m),
	0);
	return new Val(type,esq(t,p));
}

CGStm *Val::release(){
	if( opt_threaded ){
		fail( "Internal error: Val::release() invoked in threaded mode." );
	}
	CGTmp *p=tmp(CG_PTR);
	CGMem *m=mem(CG_INT32,p,4);
	CGSym *q=sym();
	CGStm *t=seq(
		mov(p,cg_exp),
		atd(m,q),
		eva(jsr(CG_INT32,"bbGCFree",p)),
		lab(q),
	0);
	return t;
}

struct TmpCounter : public CGVisitor{
	int n;
	string ident;
	
	TmpCounter( string id ):n(0),ident(id){
	}

	CGExp *visit( CGExp *e ){
		if( CGTmp *t=e->tmp() ){
			if( ident==t->ident ) ++n;
		}
		return e;
	}
};

int Val::countTmps( string id ){
	if( !cg_exp ) return 0;
	TmpCounter cnt( id );
	cg_exp->visit( cnt );
	return cnt.n;
}

struct TmpRenamer : public CGVisitor{
	string ident;
	CGExp *cg_exp;
	
	TmpRenamer( string id,CGExp *e ):ident(id),cg_exp(e){
	}

	CGExp *visit( CGExp *e ){
		if( CGTmp *t=e->tmp() ){
			if( ident==t->ident ) return cg_exp;
		}
		return e;
	}
};

Val *Val::renameTmps( string id,CGExp *e ){
	if( !cg_exp ) return this;
	TmpRenamer ren( id,e );
	CGExp *t=cg_exp->visit( ren );
	return t==cg_exp ? this : new Val(type,t);
}

Val *Val::null( Type *ty ){
	return (new Val(Type::null,0))->cast(ty);
}

//*********************** SuperVal *************************
SuperVal::SuperVal( Val *v ):Val(v->type,v->cg_exp){
}

Val *SuperVal::find( string id ){

	ObjectType *o=type->objectType();
	ClassType *t=o ? o->objectClass() : type->classType();
	
	assert(t);
	
	Val *v=0;
	bool method=false;
	
	for( t=t->superClass();t;t=t->superClass() ){
		v=t->methods.find(id);
		if( !v ) continue;
		method=v->type->funType()->method();
		if( o || !method ) break;
		v=0;
	}
	
	if( !v ) badid(id);

	if( method ) v=new Val( v->type,vfn(v->cg_exp,cg_exp) );
	
	return v;
}
