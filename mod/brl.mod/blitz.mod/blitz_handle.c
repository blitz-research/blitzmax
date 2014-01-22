
#include "blitz.h"

#define HASH_SIZE 1024
#define HASH_SLOT(X) (((X)/8)&(HASH_SIZE-1))	// divide-by-8 for better void* mapping.

static int _handle_id;

typedef struct Hash Hash;

struct Hash{
	Hash *succ;
	int key,value;
};

static Hash *object_hash[HASH_SIZE];
static Hash *handle_hash[HASH_SIZE];

static int hashFind( Hash **table,int key ){
	Hash *t,**p;
	int t_key=HASH_SLOT(key);
	for( p=&table[t_key];(t=*p) && t->key!=key;p=&t->succ ){}
	return t ? t->value : 0;
}

static int hashRemove( Hash **table,int key ){
	Hash *t,**p;
	int t_key=HASH_SLOT(key),n;
	for( p=&table[t_key];(t=*p) && key!=t->key;p=&t->succ ){}
	if( !t ) return 0;
	n=t->value;
	*p=t->succ;
	bbMemFree( t );
	return n;
}

static void hashInsert( Hash **table,int key,int value ){
	int t_key=HASH_SLOT(key);
	Hash *t=(Hash*)bbMemAlloc( sizeof(Hash) );
	t->key=key;
	t->value=value;
	t->succ=table[t_key];
	table[t_key]=t;
}

int bbHandleFromObject( BBObject *o ){
	int		n;
	if( o==&bbNullObject ) return 0;
	n=hashFind( object_hash,(int)o );
	if( n ) return n/8;
	BBRETAIN( o );
	_handle_id+=8;
	if( !(_handle_id/8) ) _handle_id+=8;	//just-in-case!
	hashInsert( object_hash,(int)o,_handle_id );
	hashInsert( handle_hash,_handle_id,(int)o );
	return _handle_id/8;
}

BBObject *bbHandleToObject( int handle ){
	BBObject *o=(BBObject*)hashFind( handle_hash,handle*8 );
	return o ? o : &bbNullObject;
}

void bbHandleRelease( int handle ){
	BBObject *o=(BBObject*)hashRemove( handle_hash,handle*8 );
	if( !o ) return;
	hashRemove( object_hash,(int)o );
	BBRELEASE( o );
}
