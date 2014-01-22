
#include <brl.mod/blitz.mod/blitz.h>
#include <cstdarg>

extern "C"{

void *bbRefFieldPtr( BBObject *obj,int index ){
	return (char*)obj+index;
}

void *bbRefMethodPtr( BBObject *obj,int index ){
	return *( (void**) ((char*)obj->clas+index) );
}

void *bbRefArrayElementPtr( int sz,BBArray *array,int index ){
	return (char*)BBARRAYDATA( array,array->dims )+sz*index;
}

int bbRefArrayClass(){
	return (int)&bbArrayClass;
}

int bbRefStringClass(){
	return (int)&bbStringClass;
}

int bbRefObjectClass(){
	return (int)&bbObjectClass;
}

int bbRefArrayLength( BBArray *array, int dim ){
	return array->scales[((dim <= array->dims)? dim : 0)];
}

int bbRefArrayDimensions( BBArray *array ){
	return array->dims;
}

//Note: arrDims must be 1D int array...
BBArray *bbRefArrayCreate( const char *type,BBArray *arrDims ){
//	assert( arrDims->dims==1 );
//	assert( arrDims->type[0]=='i' );
	
	int dims=arrDims->scales[0];
	int *lens=(int*)BBARRAYDATA( arrDims,1 );
	
	return bbArrayNewEx( type,dims,lens );
}

BBString *bbRefArrayTypeTag( BBArray *array ){
	return bbStringFromCString( array->type );
}

BBObject *bbRefGetObject( BBObject **p ){
	return *p;
}

void bbRefPushObject( BBObject **p,BBObject *t ){
	*p=t;
}

void bbRefInitObject( BBObject **p,BBObject *t ){
	BBRETAIN( t );
	*p=t;
}

void bbRefAssignObject( BBObject **p,BBObject *t ){
	BBRETAIN( t );
	BBRELEASE( *p );
	*p=t;
}

BBClass *bbRefGetObjectClass( BBObject *p ){
	return p->clas;
}

BBClass *bbRefGetSuperClass( BBClass *clas ){
	return clas->super;
}

}
