
#include "std.h"
#include "block.h"
#include "val.h"

//******************** Scope **********************
Scope::~Scope(){
}

Val *Scope::find( string id ){
	return 0;
}

Val *Scope::findTypeIdent( string id ){

	int i=id.find('.');
	if( i==string::npos ){
		globalIdent="";
		Val *v=find( id );
		if( !v ) v=findGlobal( id );
		if( v && globalIdent.size() ) id=globalIdent;
		return v;
	}

	Scope *sc=mainFun;
	while( (i=id.find('.'))!=string::npos ){
		Val *v=sc->find(id.substr(0,i));
		if( !v ) return 0;
		id=id.substr(i+1);
		sc=v;
	}
	return sc->find(id);
}
