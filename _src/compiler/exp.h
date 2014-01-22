
#ifndef EXP_H
#define EXP_H

#include "block.h"

struct Exp{

	virtual ~Exp();

	Val *evalRef( Block *block );
	
	Val *eval( Scope *scope );
	Val *eval( Scope *scope,Type *type );
	Val *evalInit( Scope *scope,Type *type );

protected:
	virtual Val *_eval( Scope *scope );
};

struct ExpSeq : public vector<Exp*>{
	ExpSeq();
	virtual ~ExpSeq();
};

struct ValExp : public Exp{
	Val *val;

	ValExp( Val *v ):val(v){}

	Val *_eval( Scope *scope );
};

struct CastExp : public Exp{
	Type *type;
	Exp *exp;

	CastExp( Type *t,Exp *e ):type(t),exp(e){}

	Val *_eval( Scope *scope );
};

struct NullExp : public Exp{
	Val *_eval( Scope *scope );
};

struct LocalDeclExp : public Exp{
	string ident;
	Type *type;
	Block *block;
	
	LocalDeclExp( string id,Type *ty,Block *b ):ident(id),type(ty),block(b){}
	
	Val *_eval( Scope *scope );
};

struct GlobalExp : public Exp{
	string ident;
	
	GlobalExp( string id ):ident(id){}
	
	Val *_eval( Scope *scope );
};

struct IdentExp : public Exp{
	string ident;
	Type *type;
	
	IdentExp( string id,Type *ty ):ident(id),type(ty){}

	Val *_eval( Scope *scope );
};

struct MemberExp : public Exp{
	Exp *lhs,*rhs;

	MemberExp( Exp *l,Exp *r ):lhs(l),rhs(r){}

	Val *_eval( Scope *scope );
};

struct SelfExp : public Exp{
	Val *_eval( Scope *scope );
};

struct SuperExp : public Exp{
	Val *_eval( Scope *scope );
};

struct NewExp : public Exp{
	Exp *exp;

	NewExp( Exp *e ):exp(e){}
	
	Val *_eval( Scope *scope );
};

struct ArrayExp : public Exp{
	Exp *exp;
	Type *type;
	
	ExpSeq dims;
	
	ArrayExp( Exp *e ):exp(e),type(0){}
	ArrayExp( Type *t ):exp(0),type(t){}
	
	Val *_eval( Scope *scope );
};

struct ArrayDataExp : public Exp{
	ExpSeq exps;

	Val *_eval( Scope *scope );
};

struct IntrinsicExp : public Exp{
	int toke;
	Type *type;
	Exp *exp;
	
	IntrinsicExp( int t,Type *ty,Exp *e ):toke(t),type(ty),exp(e){}

	Val *_eval( Scope *scope );
};

struct ExpSeqExp : public Exp{
	Exp *exp;
	ExpSeq seq;
	
	ExpSeqExp( Exp *e ):exp(e){}
	
	Val *_eval( Scope *scope );
	
	Val *invokeFun( Val *v,FunType *t,Scope *sc );
	Val *performCast( Val *v,Scope *sc );
	
	Val *indexString( Val *v,Scope *sc );
	Val *indexArray( Val *v,ArrayType *t,Scope *sc );
	Val *indexPointer( Val *v,Type *t,Scope *sc );
};

struct InvokeExp : public ExpSeqExp{

	InvokeExp( Exp *e ):ExpSeqExp(e){}

	Val *_eval( Scope *scope );
};

struct IndexExp : public ExpSeqExp{

	IndexExp( Exp *e ):ExpSeqExp(e){}

	Val *_eval( Scope *scope );
};

struct SliceExp : public Exp{
	int toke;
	Exp *exp;
	Exp *lhs,*rhs;
	
	SliceExp( int t,Exp *e,Exp *l,Exp *r ):toke(t),exp(e),lhs(l),rhs(r){}
	
	Val *_eval( Scope *scope );
};

//<, =, >, <=, >=, <>
struct CmpExp : public Exp{
	int op;
	Exp *lhs,*rhs;

	CmpExp( int o,Exp *l,Exp *r ):op(o),lhs(l),rhs(r){}

	Val *_eval( Scope *scope );
};

struct ShortCircExp : public Exp{
	int op;
	Exp *lhs,*rhs;

	ShortCircExp( int o,Exp *l,Exp *r ):op(o),lhs(l),rhs(r){}
	
	Val *_eval( Scope *scope );
};

struct NotExp : public Exp{
	Exp *exp;

	NotExp( Exp *e ):exp(e){}

	Val *_eval( Scope *scope );
};

//-, Abs
struct UnaryExp : public Exp{
	int op;
	Exp *exp;

	UnaryExp( int o,Exp *e ):op(o),exp(e){}

	Val *_eval( Scope *scope );
};

//+, -, *, /, Mod, Min, Max
struct ArithExp : public Exp{
	int op;
	Exp *lhs,*rhs;
	Val *lhs_val,*rhs_val;
	
	ArithExp( int o,Exp *l,Exp *r ):op(o),lhs(l),rhs(r),lhs_val(0),rhs_val(0){}
	ArithExp( int o,Val *l,Exp *r ):op(o),lhs(0),rhs(r),lhs_val(l),rhs_val(0){}

	Val *pointerArith( Val *pv,Val *iv );

	Val *_eval( Scope *scope );
};

//And, Or, Xor, Shl, Shr, Sar
struct BitwiseExp : public Exp{
	int op;
	Exp *lhs,*rhs;
	Val *lhs_val,*rhs_val;

	BitwiseExp( int o,Exp *l,Exp *r ):op(o),lhs(l),rhs(r),lhs_val(0),rhs_val(0){}
	BitwiseExp( int o,Val *l,Exp *r ):op(o),lhs(0),rhs(r),lhs_val(l),rhs_val(0){}

	Val *_eval( Scope *scope );
};

#endif
