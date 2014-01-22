
#ifndef STM_H
#define STM_H

#include "exp.h"

struct Decl;

struct Stm{
	string source_info;
	
	virtual ~Stm();
	virtual void eval( Block *b )=0;
};

struct DebugInfoStm : public Stm{
	void eval( Block *b );
};

struct RemStm : public Stm{
	string comment;

	void eval( Block *b );
};

struct StmStm : public Stm{
	CGStm *stm;

	StmStm( CGStm *s ):stm(s){}

	void eval( Block *b );
};

struct EvalClassBlocksStm : public Stm{
	
	void eval( Block *b );
};

struct LabelStm : public Stm{
	CGSym *goto_sym,*restore_sym;
	
	LabelStm( CGSym *x,CGSym *y ):goto_sym(x),restore_sym(y){}
	
	void eval( Block *b );
};

struct GotoStm : public Stm{
	string ident;
	
	GotoStm( string id ):ident(id){}
	
	void eval( Block *b );
};

struct EvalStm : public Stm{
	Exp *exp;

	EvalStm( Exp *e ):exp(e){}

	void eval( Block *b );
};

struct CtorStm : public Stm{
	ClassBlock *block;
	Block *ctor_new;
	
	CtorStm( ClassBlock *b,Block *n ):block(b),ctor_new(n){}
	
	void eval( Block *b );
};

struct DtorStm : public Stm{
	ClassBlock *block;
	Block *dtor_delete;
	
	DtorStm( ClassBlock *b,Block *d ):block(b),dtor_delete(d){}
	
	void eval( Block *b );
};

struct LocalDeclStm : public Stm{
	string ident;
	Type *type;
	Exp *init;
	
	LocalDeclStm( string id,Type *ty,Exp *e ):ident(id),type(ty),init(e){}
	
	void eval( Block *b );
};

struct FieldDeclStm : public Stm{
	string ident;
	Type *type;
	Exp *init;
	
	FieldDeclStm( string id,Type *ty,Exp *e ):ident(id),type(ty),init(e){}
	
	void eval( Block *b );
};

struct GlobalDeclStm : public Stm{
	string ident;
	Type *type;
	Exp *init;
	bool pub;
	
	GlobalDeclStm( string id,Type *ty,Exp *e,bool p ):ident(id),type(ty),init(e),pub(p){}

	void eval( Block *b );
};

struct ExternDeclStm : public Stm{
	int		toke;
	string  ident;
	Type*   type;
	CGExp*  cg;
	bool	pub;
	
	ExternDeclStm( int t,string id,Type *ty,CGExp *e,bool p ):toke(t),ident(id),type(ty),cg(e),pub(p){}

	void eval( Block *b );
};

struct ImportStm : public Stm{
	CGExp *entry;
	
	ImportStm( CGExp *e ):entry(e){}
	
	void eval( Block *b );
};

struct IncbinStm : public Stm{
	string name,path;
	
	IncbinStm( string n );

	void eval( Block *b );
};

struct AssignStm : public Stm{
	Exp *lhs,*rhs;

	AssignStm( Exp *l,Exp *r ):lhs(l),rhs(r){}

	void eval( Block *b );
};

struct OpAssignStm : public Stm{
	int op;
	Exp *lhs,*rhs;
	
	OpAssignStm( int o,Exp *l,Exp *r ):op(o),lhs(l),rhs(r){}
	
	void eval( Block *b );
};

struct IfStm : public Stm{
	Exp *exp;
	Block *then_block,*else_block;

	IfStm( Exp *e,Block *t,Block *l ):exp(e),then_block(t),else_block(l){}

	void eval( Block *b );
};

struct LoopCtrlStm : public Stm{
	int toke;
	string label;

	LoopCtrlStm( int t,string l ):toke(t),label(l){}

	void eval( Block *b );
};

struct ForStm : public Stm{
	Exp *var;
	Exp *init;
	Exp *to;
	Exp *step;
	bool until;

	LoopBlock *block;

	ForStm( Exp *v,Exp *i,Exp *t,Exp *s,LoopBlock *b,bool u ):var(v),init(i),to(t),step(s),block(b),until(u){}

	void eval( Block *b );
};

struct ForEachStm : public Stm{

	Exp *var;
	Exp *coll;
	
	LoopBlock *block;

	ForEachStm( Exp *v,Exp *c,LoopBlock *b ):var(v),coll(c),block(b){}
	
	void eval( Block *b );
	
	void evalArray( Block *b,Val *var,Val *arr );
	void evalString( Block *b,Val *var,Val *str );
	void evalCollection( Block *b,Val *var,Val *coll );
	
	ObjectType *checkObjMethod( Val *v );
	void checkInt32Method( Val *v );
};

struct WhileStm : public Stm{
	Exp *exp;
	LoopBlock *block;

	WhileStm( Exp *e,LoopBlock *b ):exp(e),block(b){}

	void eval( Block *b );
};

struct RepeatStm : public Stm{
	Exp *exp;
	LoopBlock *block;

	RepeatStm( Exp *e,LoopBlock *b ):exp(e),block(b){}

	void eval( Block *b );
};

struct ReturnStm : public Stm{
	Exp *exp;

	ReturnStm( Exp *e ):exp(e){}

	void eval( Block *b );
};

struct ReleaseStm : public Stm{
	Exp *exp;
	
	ReleaseStm( Exp *e ):exp(e){}
	
	void eval( Block *b );
};

struct DeleteStm : public Stm{
	Exp *exp;

	DeleteStm( Exp *e ):exp(e){}

	void eval( Block *b );
};

struct SelCase{
	ExpSeq exps;
	Block *block;
	string source_info;

	SelCase( Block *b ):block(b){}
};

struct SelectStm : public Stm{
	Exp *exp;
	vector<SelCase*> cases;
	Block *_default;

	SelectStm( Exp *e ):exp(e),_default(0){}

	void eval( Block *b );
};

struct AssertStm : public Stm{
	Exp *exp,*msg;
	
	AssertStm( Exp *e,Exp *m ):exp(e),msg(m){}
	
	void eval( Block *b );
};

struct EndStm : public Stm{

	void eval( Block *b );
};

struct TryCatch{
	string ident;
	Type *type;
	Block *block;
	string source_info;

	TryCatch( Block *b ):block(b){}
};

struct TryStm : public Stm{
	Block *block;
	vector<TryCatch*> catches;
	
	TryStm( Block *b ):block(b){}
	
	void eval( Block *b );
};

struct ThrowStm : public Stm{
	Exp *exp;
	
	ThrowStm( Exp *e ):exp(e){}
	
	void eval( Block *b );
};

struct DataStm : public Stm{
	ExpSeq exps;
	
	void eval( Block *b );
};

struct ReadStm : public Stm{
	ExpSeq exps;
	
	void eval( Block *b );
};

struct RestoreStm : public Stm{
	string ident;
	
	RestoreStm( string id ):ident(id){}
	
	void eval( Block *b );
};

#endif