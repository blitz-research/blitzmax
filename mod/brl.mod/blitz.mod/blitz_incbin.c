
#include "blitz.h"

typedef struct BBIncbin BBIncbin;

struct BBIncbin{
	BBIncbin *succ;
	BBString *path;
	void *ptr;
	int len;
};

static BBIncbin *incs;

static BBIncbin *find( BBString *path ){
	BBIncbin *p;
	for( p=incs;p;p=p->succ ){
		if( !bbStringCompare(path,p->path) ) return p;
		
	}
	return 0;
}

int bbIncbinAdd( BBString *path,void *ptr,int len ){
	BBIncbin *p;
	
	p=find( path );
	if( p ) return 0;
	
	p=(BBIncbin*)bbMemAlloc( sizeof(BBIncbin) );
	
	BBRETAIN( path );
	p->path=path;
	p->ptr=ptr;
	p->len=len;
	p->succ=incs;
	incs=p;

	return 1;
}

void *bbIncbinPtr( BBString *path ){
	BBIncbin *p;
	
	p=find( path );

	return p ? p->ptr : 0;
}

int bbIncbinLen( BBString *path ){
	BBIncbin *p;
	
	p=find( path );
	
	return p ? p->len : 0;
}
