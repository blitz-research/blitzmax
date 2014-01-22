
#ifndef BLOCK_H
#define BLOCK_H

#include "decl.h"

struct Stm;
struct Block;
struct FunBlock;
struct LabelStm;

struct Block : public Scope{
	Block *outer;
	DeclSeq decls;
	DeclSeq locals;
	vector<Stm*> stms;
	FunBlock *fun_block;
	CGSeq *cg_enter,*cg_leave;
	CGDat *cg_debug;
	bool debug_on;
	
	Block( Block *outer );
	
	CGDat*  debugScope();
	
	void	emit( Stm *t );
	void	emit( CGStm *t );
	void	declLocal( Decl *d );
	
	Val*	linearizeRef( Val *v );
	void	initRef( Val *lhs,Val *rhs );
	void	assignRef( Val *lhs,Val *rhs );
	void	initGlobalRef( Val *lhs,Val *rhs );

	virtual void	decl( Decl *d );

	virtual Val*	find( string id );
	virtual Val*	_find( string id,Block *from );
	
	virtual void	eval();

	static void		resolveBlocks();
	static void		evalFunBlocks();
	static void		evalClassBlocks();
};

struct LoopBlock : public Block{
	CGSym *cont_sym,*exit_sym,*loop_sym;
	string label;

	LoopBlock( Block *outer,string lab );
};

struct FunBlock : public Block{
	FunType*	type;
	Decl*		fun_decl;
	Val*		fun_scope;
	
	map<string,LabelStm*> labels;

	CGDat*		data_ptr;
	CGDat*		data_stms;
	
	CGFun*		cg_fun;
	CGTmp*		ret_tmp;
	CGSym*		ret_sym;
	
	string		sourceinfo;
	
	FunBlock();
	FunBlock( Block *outer,string id,FunType *ty,bool pub,ExpSeq *defs=0 );
	
	virtual Val *_find( string id,Block *from );
	
	void		resolve();
	
	virtual void eval();
	
	CGTmp*		gcTmp();
	
	static void genAssem();
	static void genInterface();
	
	CGDat*		dataPtr();
	CGDat*		dataStms();
};

struct ClassBlock : public Block{
	ClassType   *type;
	Decl		*class_decl;
	FunBlock	*ctor,*dtor;
	Block		*ctor_new;
	Block		*dtor_delete;
	Block		*field_ctors;
	
	string		sourceinfo;
	
	ClassBlock( Block *outer,string id,ClassType *ty );
	
	void		makeDtor();
	
	void		resolve();
	
	virtual void eval();
	
	virtual void decl( Decl *d );
};

#endif
