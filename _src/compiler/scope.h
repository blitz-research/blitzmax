
#ifndef SCOPE_H
#define SCOPE_H

struct Val;

struct Scope{
	virtual		~Scope();
	
	virtual Val*	find( string id );
	
	Val*			findTypeIdent( string id );
};

#endif
