
#include "blitz.h"

#include <stdarg.h>

static void bbArrayFree( BBObject *o );

static BBDebugScope debugScope={
	BBDEBUGSCOPE_USERTYPE,
	"Array",
	BBDEBUGDECL_END
};

BBClass bbArrayClass={
	&bbObjectClass, //extends
	bbArrayFree,	//free
	&debugScope,	//DebugScope
	0,			//instance_size
	0,			//ctor
	0,			//dtor
	
	bbObjectToString,
	bbObjectCompare,
	bbObjectSendMessage,
	bbObjectReserved,
	bbObjectReserved,
	bbObjectReserved,
	
	bbArraySort,
	bbArrayDimensions
};

BBArray bbEmptyArray={
	&bbArrayClass,	//clas
	BBGC_MANYREFS,	//refs
	"",			//type
	0,			//dims
	0,			//size
	0			//scales[0]
};

//***** Note: Only used by ref counting GC.
static void bbArrayFree( BBObject *o ){
#ifdef BB_GC_RC
	int k;
	BBObject **p;
	BBArray *arr=(BBArray*)o;
	
	if( arr==&bbEmptyArray ){
		arr->refs=BBGC_MANYREFS;
		return;
	}

	switch( arr->type[0] ){
	case ':':case '$':case '[':
		p=(BBObject**)BBARRAYDATA(arr,arr->dims);
		for( k=arr->scales[0];k>0;--k ){
			BBObject *o=*p++;
			BBDECREFS( o );
		}
		break;
	}
	bbGCDeallocObject( arr,BBARRAYSIZE( arr->size,arr->dims ) );
#endif
}

static BBArray *allocateArray( const char *type,int dims,int *lens ){
	int k,*len;
	int size=4;
	int length=1;
	int flags=BBGC_ATOMIC;
	BBArray *arr;
	
	len=lens;
	for( k=0;k<dims;++k ){
		int n=*len++;
		if( n<=0 ) return &bbEmptyArray;
		length*=n;
	}
		
	switch( type[0] ){
	case 'b':size=1;break;
	case 's':size=2;break;
	case 'l':size=8;break;
	case 'd':size=8;break;
	case ':':flags=0;break;
	case '$':flags=0;break;
	case '[':flags=0;break;
	}
	size*=length;
	
	arr=(BBArray*)bbGCAllocObject( BBARRAYSIZE(size,dims),&bbArrayClass,flags );

	arr->type=type;
	arr->dims=dims;
	arr->size=size;
	
	len=lens;
	for( k=0;k<dims;++k ) arr->scales[k]=*len++;
	for( k=dims-2;k>=0;--k ) arr->scales[k]*=arr->scales[k+1];
		
	return arr;
}

static void *arrayInitializer( BBArray *arr ){
	switch( arr->type[0] ){
	case ':':return &bbNullObject;
	case '$':return &bbEmptyString;
	case '[':return &bbEmptyArray;
	case '(':return &brl_blitz_NullFunctionError;
	}
	return 0;
}

static void initializeArray( BBArray *arr ){
	void *init,**p;
	
	if( !arr->size ) return;
	
	init=arrayInitializer( arr );
	p=(void**)(BBARRAYDATA( arr,arr->dims ));

	if( init ){
		int k;
		for( k=arr->scales[0];k>0;--k ) *p++=init;
	}else{
		memset( p,0,arr->size );
	}
}

static volatile void *t;
void *addressOfParam( void *p ){
	t=p;
	return t;
} 

BBArray *bbArrayNew( const char *type,int dims,... ){

#if BB_ARGP
	int *lens=(int*)bbArgp(8);
#else
	int *lens=&dims+1;
#endif

	BBArray *arr=allocateArray( type,dims,lens );
	
	initializeArray( arr );
	
	return arr;
}

BBArray *bbArrayNewEx( const char *type,int dims,int *lens ){

	BBArray *arr=allocateArray( type,dims,lens );
	
	initializeArray( arr );
	
	return arr;
}

BBArray *bbArrayNew1D( const char *type,int length ){

	BBArray *arr=allocateArray( type,1,&length );
	
	initializeArray( arr );
	
	return arr;
}

BBArray *bbArraySlice( const char *type,BBArray *inarr,int beg,int end ){

	char *p;
	void *init;
	BBArray *arr;
	int n,k,el_size;
	int length=end-beg;

	if( length<=0 ) return &bbEmptyArray;
	
	arr=allocateArray( type,1,&length );

	el_size=arr->size/length;
	
	init=arrayInitializer( arr );
	p=(char*)BBARRAYDATA( arr,1 );

	n=-beg;
	if( n>0 ){
		if( beg+n>end ) n=end-beg;
		if( init ){
			void **dst=(void**)p;
			for( k=0;k<n;++k ) *dst++=init;
			p=(char*)dst;
		}else{
			memset( p,0,n*el_size );
			p+=n*el_size;
		}
		beg+=n;
		if( beg==end ) return arr;
	}
	n=inarr->scales[0]-beg;
	if( n>0 ){
		if( beg+n>end ) n=end-beg;
#ifdef BB_GC_RC
		if( type[0]==':' || type[0]=='$' || type[0]=='[' ){
			BBObject **dst=(BBObject**)p;
			BBObject **src=(BBObject**)BBARRAYDATA(inarr,inarr->dims)+beg;
			for( k=0;k<n;++k ){ 
				BBObject *o=*src++;
				BBINCREFS( o );
				*dst++=o; 
			}
			p=(char*)dst;
		}else{
			memcpy( p,(char*)BBARRAYDATA(inarr,inarr->dims)+beg*el_size,n*el_size );
			p+=n*el_size;
		}
#else
		memcpy( p,(char*)BBARRAYDATA(inarr,inarr->dims)+beg*el_size,n*el_size );
		p+=n*el_size;
#endif
		beg+=n;
		if( beg==end ) return arr;
	}
	n=end-beg;
	if( n>0 ){
		if( init ){
			void **dst=(void**)p;
			for( k=0;k<n;++k ) *dst++=init;
		}else{
			memset( p,0,n*el_size );
		}
	}
	return arr;
}

BBArray *bbArrayConcat( const char *type,BBArray *x,BBArray *y ){

	BBArray *arr;
	char *data;
	int length=x->scales[0]+y->scales[0];
	
	if( length<=0 ) return &bbEmptyArray;

	arr=allocateArray( type,1,&length );
	
	data=(char*)BBARRAYDATA( arr,1 );
	
	memcpy( data,BBARRAYDATA( x,1 ),x->size );
	memcpy( data+x->size,BBARRAYDATA( y,1 ),y->size );
	
#ifdef BB_GC_RC
	if( type[0]==':' || type[0]=='$' || type[0]=='[' ){
		int i;
		BBObject **p=(BBObject**)data;
		for( i=0;i<length;++i ){
			BBObject *o=*p++;
			BBINCREFS( o );
		}
	}
#endif
	return arr;
}

BBArray *bbArrayFromData( const char *type,int length,void *data ){

	int k;
	BBArray *arr;

	if( length<=0 ) return &bbEmptyArray;
	
	arr=allocateArray( type,1,&length );

	if( type[0]=='b' ){
		unsigned char *p=BBARRAYDATA( arr,1 );
		for( k=0;k<length;++k ) p[k]=((int*)data)[k];
	}else if( type[0]=='s' ){
		unsigned short *p=BBARRAYDATA( arr,1 );
		for( k=0;k<length;++k ) p[k]=((int*)data)[k];
	}else{
		memcpy( BBARRAYDATA( arr,1 ),data,arr->size );
	}
	return arr;
}

BBArray *bbArrayDimensions( BBArray *arr ){
	int *p,i,n;
	BBArray *dims;

	if( !arr->scales[0] ) return &bbEmptyArray;
	
	n=arr->dims;
	dims=bbArrayNew1D( "i",n );
	p=(int*)BBARRAYDATA( dims,1 );

	for( i=0;i<n-1;++i ){
		p[i]=arr->scales[i]/arr->scales[i+1];
	}
	p[i]=arr->scales[i];
	
	return dims;
}

BBArray *bbArrayCastFromObject( BBObject *o,const char *type ){
	BBArray *arr=(BBArray*)o;
	if( arr==&bbEmptyArray ) return arr;
	if( arr->clas!=&bbArrayClass ) return (BBArray*)BBNULLOBJECT;
	if( arr->type[0]==':' && type[0]==':' ) return arr;
	if( strcmp( arr->type,type ) ) return (BBArray*)BBNULLOBJECT;
	return arr;
}

#define SWAP(X,Y) {t=*(X);*(X)=*(Y);*(Y)=t;}
#define QSORTARRAY( TYPE,IDENT )\
static void IDENT( TYPE *lo,TYPE *hi ){\
	TYPE t;\
	TYPE *i;\
	TYPE *x;\
	TYPE *y;\
	if( hi<=lo ) return;\
	if( lo+1==hi ){\
		if( LESSTHAN(hi,lo) ) SWAP(lo,hi);\
		return;\
	}\
	i=(hi-lo)/2+lo;\
	if( LESSTHAN(i,lo) ) SWAP(i,lo);\
	if( LESSTHAN(hi,i) ){\
		SWAP(i,hi);\
		if( LESSTHAN(i,lo) ) SWAP(i,lo);\
	}\
	x=lo+1;\
	y=hi-1;\
	do{\
		while( LESSTHAN(x,i) ) ++x;\
		while( LESSTHAN(i,y) ) --y;\
		if( x>y ) break;\
		if( x<y ){\
			SWAP(x,y);\
			if( i==x ) i=y;\
			else if( i==y ) i=x;\
		}\
		++x;\
		--y;\
	}while( x<=y );\
	IDENT(lo,y);\
	IDENT(x,hi);\
}

#undef LESSTHAN
#define LESSTHAN(X,Y) (*(X)<*(Y))
QSORTARRAY( unsigned char,_qsort_b )
QSORTARRAY( unsigned short,qsort_s )
QSORTARRAY( int,qsort_i )
QSORTARRAY( BBInt64,qsort_l );
QSORTARRAY( float,qsort_f );
QSORTARRAY( double,qsort_d );
#undef LESSTHAN
#define LESSTHAN(X,Y) ((*X)->clas->Compare(*(X),*(Y))<0)
QSORTARRAY( BBObject*,qsort_obj );
#undef LESSTHAN
#define LESSTHAN(X,Y) (*(X)>*(Y))
QSORTARRAY( unsigned char,qsort_b_d )
QSORTARRAY( unsigned short,qsort_s_d )
QSORTARRAY( int,qsort_i_d )
QSORTARRAY( BBInt64,qsort_l_d );
QSORTARRAY( float,qsort_f_d );
QSORTARRAY( double,qsort_d_d );
#undef LESSTHAN
#define LESSTHAN(X,Y) ((*X)->clas->Compare(*(X),*(Y))>0)
QSORTARRAY( BBObject*,qsort_obj_d );

void bbArraySort( BBArray *arr,int ascending ){
	int n;
	void *p;
	n=arr->scales[0]-1;
	if( n<=0 ) return;
	p=BBARRAYDATA(arr,arr->dims);
	if( ascending ){
		switch( arr->type[0] ){
		case 'b':_qsort_b( (unsigned char*)p,(unsigned char*)p+n );break;
		case 's':qsort_s( (unsigned short*)p,(unsigned short*)p+n );break;
		case 'i':qsort_i( (int*)p,(int*)p+n );break;
		case 'l':qsort_l( (BBInt64*)p,(BBInt64*)p+n );break;
		case 'f':qsort_f( (float*)p,(float*)p+n );break;
		case 'd':qsort_d( (double*)p,(double*)p+n );break;
		case '$':case ':':qsort_obj( (BBObject**)p,(BBObject**)p+n );break;
		}
	}else{
		switch( arr->type[0] ){
		case 'b':qsort_b_d( (unsigned char*)p,(unsigned char*)p+n );break;
		case 's':qsort_s_d( (unsigned short*)p,(unsigned short*)p+n );break;
		case 'i':qsort_i_d( (int*)p,(int*)p+n );break;
		case 'l':qsort_l_d( (BBInt64*)p,(BBInt64*)p+n );break;
		case 'f':qsort_f_d( (float*)p,(float*)p+n );break;
		case 'd':qsort_d_d( (double*)p,(double*)p+n );break;
		case '$':case ':':qsort_obj_d( (BBObject**)p,(BBObject**)p+n );break;
		}
	}
}
