
#ifndef BLITZ_ARRAY_H
#define BLITZ_ARRAY_H

#include "blitz_types.h"

#ifdef __cplusplus
extern "C"{
#endif

#define BBNULLARRAY (&bbEmptyArray)

#define BBARRAYSIZE(q,n) (20+(n)*sizeof(int)+(q))
#define BBARRAYDATA(p,n) ((void*)((char*)(p)+20+(n)*sizeof(int)))

struct BBArray{
	//extends BBObject
	BBClass*	clas;
	int			refs;

	const char* type;			//8
	int			dims;			//12
	int			size;			//16 : total size minus this header
	int			scales[1];		//20 : [dims]
								//sizeof=20+dims*sizeof(int)
};

extern		BBClass bbArrayClass;
extern		BBArray bbEmptyArray;

BBArray*	bbArrayNew( const char *type,int dims,... );
BBArray*	bbArrayNew1D( const char *type,int length );
BBArray*	bbArrayNewEx( const char *type,int dims,int *lens );	//alternate version of New...

BBArray*	bbArraySlice( const char *type,BBArray *arr,int beg,int end );
BBArray*	bbArrayFromData( const char *type,int length,void *data );
BBArray*	bbArrayCastFromObject( BBObject *o,const char *type_encoding );

void		bbArraySort( BBArray *arr,int ascending );

BBArray*	bbArrayDimensions( BBArray *arr );

BBArray*	bbArrayConcat( const char *type,BBArray *x,BBArray *y );

#ifdef __cplusplus
}
#endif

#endif


