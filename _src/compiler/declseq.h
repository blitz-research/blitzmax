
#ifndef DECLSEQ_H
#define DECLSEQ_H

#include "scope.h"

struct Val;
struct Decl;

struct DeclSeq : public Scope{
	vector<Decl*> _vec;
	map<string,Val*> _map;

	void	push_back( Decl *d );
	Val*	find( string id );
	int		size()const{ return _vec.size(); }
	Decl*   operator[]( int n )const{ return _vec[n]; }
	void update( int i,Decl *d );
};

#endif