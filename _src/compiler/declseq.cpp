
#include "std.h"
#include "declseq.h"
#include "decl.h"

void DeclSeq::push_back( Decl *d ){
	if( !_map.insert( make_pair(tolower(d->ident),d->val) ).second ) dupid( d->ident );
	_vec.push_back(d);
}

Val *DeclSeq::find( string id ){
	map<string,Val*>::const_iterator it=_map.find(tolower(id));
	return it==_map.end() ? 0 : it->second;
}

void DeclSeq::update( int i,Decl *d ){
	_vec[i]=d;
	_map.find(tolower(d->ident))->second=d->val;
}
