
#ifndef VAL_H
#define VAL_H

#include "type.h"
#include "scope.h"

struct Val : public Scope{
	Type *type;
	CGExp *cg_exp;
	
	Val( int n,Type *ty=Type::int32 );
	Val( int64 n,Type *ty=Type::int64 );
	Val( float n,Type *ty=Type::float32 );
	Val( double n,Type *ty=Type::float64 );
	
	Val( bstring t );
	Val( const char *t );
	Val( Type *t,CGExp *e );
	virtual ~Val();
	
	CGExp*  constant();
	
	int64	intValue();
	double  floatValue();
	bstring stringValue();
	
	Val*	cond();
	Val*	cast( Type *ty );
	Val*	initCast( Type *ty );
	Val*	funArgCast( Type *ty,CGSeq *cleanup );
	Val*	forEachCast( Type *ty );
	Val*	explicitCast( Type *ty );
	Val*	find( string id );

	Type*   balance( Val *t );
	Type*   balance( Type *t );

	Val*	retain();
	CGStm*  release();
	
	bool	refCounted();
	int		countTmps( string id );
	Val*	renameTmps( string id,CGExp *e );
	
	static Val* null( Type *ty );
};

struct SuperVal : public Val{
	SuperVal( Val *v );

	Val*	find( string id );
};

#endif