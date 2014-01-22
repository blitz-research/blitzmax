
#ifndef DECL_H
#define DECL_H

#include "val.h"

struct Exp;
struct ExpSeq;

struct Decl{
	string  ident;		//real ident
	Val*	val;		//value of decl
	string	meta;		//meta data

	Decl( string id,Val *v );
	Decl( string id,Type *ty,CGExp *cg );
	
	void debugDecl( CGDat *d,int blockKind );
	
	void setMetaData( string meta );
	
	string debugEncoding();
	
	static void resolveDecls();
};

struct FunDecl : public Decl{
	string sourceinfo;
	Scope *scope;
	ExpSeq *defaults;

	FunDecl( string id,FunType *ty,CGExp *cg,Scope *sc,ExpSeq *defs );
	
	void resolve();
};

struct ConstDecl : public Decl{
	string sourceinfo;
	Scope *scope;
	Exp *exp;
	
	ConstDecl( string id,Type *ty,Scope *sc,Exp *e );
	
	void resolve();
};

#endif