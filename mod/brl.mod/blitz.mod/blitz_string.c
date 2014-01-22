
#include "blitz.h"

#include "blitz_unicode.h"

static void bbStringFree( BBObject *o );

static BBDebugScope debugScope={
	BBDEBUGSCOPE_USERTYPE,
	"String",
	BBDEBUGDECL_END
};

BBClass bbStringClass={
	&bbObjectClass, //super
	bbStringFree,   //free
	&debugScope,	//DebugScope
	0,				//instance_size
	0,				//ctor
	0,				//dtor

	(BBString*(*)(BBObject*))bbStringToString,
	(int(*)(BBObject*,BBObject*))bbStringCompare,
	bbObjectSendMessage,
	bbObjectReserved,
	bbObjectReserved,
	bbObjectReserved,
	
	bbStringFind,
	bbStringFindLast,
	bbStringTrim,
	bbStringReplace,
	
	bbStringToLower,
	bbStringToUpper,
	
	bbStringToInt,
	bbStringToLong,
	bbStringToFloat,
	bbStringToDouble,
	bbStringToCString,
	bbStringToWString,

	bbStringFromInt,
	bbStringFromLong,
	bbStringFromFloat,
	bbStringFromDouble,
	bbStringFromCString,
	bbStringFromWString,
	
	bbStringFromBytes,
	bbStringFromShorts,

	bbStringStartsWith,
	bbStringEndsWith,
	bbStringContains,
	
	bbStringSplit,
	bbStringJoin,
	
	bbStringFromUTF8String,
	bbStringToUTF8String
};

BBString bbEmptyString={
	&bbStringClass, //clas
	BBGC_MANYREFS,	//refs
	0				//length
};

static int wstrlen( const BBChar *p ){
	const BBChar *t=p;
	while( *t ) ++t;
	return t-p;
}

static int charsEqual( unsigned short *a,unsigned short *b,int n ){
	while( n-- ){
		if (*a!=*b) return 0;
		a++;b++;
	}
	return 1;
}

//***** Note: Not called in THREADED mode.
static void bbStringFree( BBObject *o ){
#ifdef BB_GC_RC
	BBString *str=(BBString*)o;
	if( str==&bbEmptyString ){
		str->refs=BBGC_MANYREFS;
		return;
	}
	bbGCDeallocObject( str,sizeof(BBString)+str->length*sizeof(BBChar) );
#endif
}

BBString *bbStringNew( int len ){
	int flags;
	BBString *str;
	if( !len ) return &bbEmptyString;
	str=(BBString*)bbGCAllocObject( sizeof(BBString)+len*sizeof(BBChar),&bbStringClass,BBGC_ATOMIC );
	str->length=len;
	return str;
}

BBString *bbStringFromChar( int c ){
	BBString *str=bbStringNew(1);
	str->buf[0]=c;
	return str;
}

BBString *bbStringFromInt( int n ){
	char buf[64],*p=buf+64;
	int neg=n<0;
	if( neg ){
		n=-n;if( n<0 ) return bbStringFromBytes( "-2147483648",11 );
	}
	do{
		*--p=n%10+'0';
	}while(n/=10);
	if( neg ) *--p='-';
	return bbStringFromBytes( p,buf+64-p );
}

BBString *bbStringFromLong( BBInt64 n ){
	char buf[64],*p=buf+64;
	int neg=n<0;
	if( neg ){
		n=-n;if( n<0 ) return bbStringFromBytes( "-9223372036854775808",20 );
	}
	do{
		*--p=n%10+'0';
	}while(n/=10);
	if( neg ) *--p='-';
	return bbStringFromBytes( p,buf+64-p );
}

BBString *bbStringFromFloat( float n ){
	char buf[64];
	sprintf( buf,"%#.9g",n );
	return bbStringFromCString(buf);
}

BBString *bbStringFromDouble( double n ){
	char buf[64];
	sprintf( buf,"%#.17lg",n );
	return bbStringFromCString(buf);
}

BBString *bbStringFromBytes( const char *p,int n ){
	int k;
	BBString *str;
	if( !n ) return &bbEmptyString;
	str=bbStringNew( n );
	for( k=0;k<n;++k ) str->buf[k]=(unsigned char)p[k];
	return str;
}

BBString *bbStringFromShorts( const unsigned short *p,int n ){
	BBString *str;
	if( !n ) return &bbEmptyString;
	str=bbStringNew( n );
	bbMemCopy( str->buf,p,n*sizeof(short) );
	return str;
}

BBString *bbStringFromInts( const int *p,int n ){
	int k;
	BBString *str;
	if( !n ) return &bbEmptyString;
	str=bbStringNew( n );
	for( k=0;k<n;++k ) str->buf[k]=p[k];
	return str;
}

BBString *bbStringFromArray( BBArray *arr ){
	int n;
	void *p;
	if( arr->dims!=1 ) return &bbEmptyString;
	n=arr->scales[0];
	p=BBARRAYDATA(arr,arr->dims);
	switch( arr->type[0] ){
	case 'b':return bbStringFromBytes( p,n );
	case 's':return bbStringFromShorts( p,n );
	case 'i':return bbStringFromInts( p,n );
	}
	return &bbEmptyString;
}

BBString *bbStringFromCString( const char *p ){
	return p ? bbStringFromBytes( p,strlen(p) ) : &bbEmptyString;
}

BBString *bbStringFromWString( const BBChar *p ){
	return p ? bbStringFromShorts( p,wstrlen(p) ) : &bbEmptyString;
}

BBString *bbStringFromUTF8String( const char *p ){
	int c,n;
	short *d,*q;
	BBString *str;

	if( !p ) return &bbEmptyString;
	
	n=strlen(p);
	d=(short*)malloc( n*2 );
	q=d;
	
	while( c=*p++ & 0xff ){
		if( c<0x80 ){
			*q++=c;
		}else{
			int d=*p++ & 0x3f;
			if( c<0xe0 ){
				*q++=((c&31)<<6) | d;
			}else{
				int e=*p++ & 0x3f;
				if( c<0xf0 ){
					*q++=((c&15)<<12) | (d<<6) | e;
				}else{
					int f=*p++ & 0x3f;
					int v=((c&7)<<18) | (d<<12) | (e<<6) | f;
					if( v & 0xffff0000 ) bbExThrowCString( "Unicode character out of UCS-2 range" );
					*q++=v;
				}
			}
		}
	}
	str=bbStringFromShorts( d,q-d );
	free( d );
	return str;
}

BBString *bbStringToString( BBString *t ){
	return t;
}

int bbStringCompare( BBString *x,BBString *y ){
	int k,n,sz;
	sz=x->length<y->length ? x->length : y->length;
	for( k=0;k<sz;++k ) if( n=x->buf[k]-y->buf[k] ) return n;
	return x->length-y->length;
}

int bbStringStartsWith( BBString *x,BBString *y ){
	BBChar *p,*q;
	int k,sz=y->length;
	if( x->length<sz ) return 0;
	p=x->buf;
	q=y->buf;
	for( k=0;k<sz;++k ) if( *p++!=*q++ ) return 0;
	return 1;
}

int bbStringEndsWith( BBString *x,BBString *y ){
	BBChar *p,*q;
	int k,sz=y->length;
	if( x->length<sz ) return 0;
	p=x->buf+x->length-sz;
	q=y->buf;
	for( k=0;k<sz;++k ) if( *p++!=*q++ ) return 0;
	return 1;
}

int bbStringContains( BBString *x,BBString *y ){
	return bbStringFind( x,y,0 )!=-1;
}

BBString *bbStringConcat( BBString *x,BBString *y ){
    int len=x->length+y->length;
    BBString *t=bbStringNew(len);
    memcpy( t->buf,x->buf,x->length*sizeof(BBChar) );
    memcpy( t->buf+x->length,y->buf,y->length*sizeof(BBChar) );
    return t;
}

BBString *bbStringSlice( BBString *in,int beg,int end ){
	BBChar *p;
	BBString *out;
	int k,n,len,inlen;
	
	len=end-beg;
	if( len<=0 ) return &bbEmptyString;

	out=bbStringNew( len );
	
	p=out->buf;
	inlen=in->length;

	if( (n=-beg)>0 ){
		if( beg+n>end ) n=end-beg;
		for( k=0;k<n;++k ) *p++=' ';
		if( (beg+=n)==end ) return out;
	}
	if( (n=inlen-beg)>0 ){
		BBChar *q=in->buf+beg;
		if( beg+n>end ) n=end-beg;
		for( k=0;k<n;++k ) *p++=*q++;
		if( (beg+=n)==end ) return out;
	}
	if( (n=end-beg)>0 ){
		for( k=0;k<n;++k ) *p++=' ';
	}
	return out;
}

BBString *bbStringTrim( BBString *str ){
	int b=0,e=str->length;
	while( b<e && str->buf[b]<=' ' ) ++b;
	if( b==e ) return &bbEmptyString;
	while( str->buf[e-1]<=' ' ) --e;
	if( e-b==str->length ) return str;
	return bbStringFromShorts( str->buf+b,e-b );
}

BBString *bbStringReplace( BBString *str,BBString *sub,BBString *rep ){
	int i,d,n,j,p;
	if( !sub->length ) return str;
	i=0;n=0;
	while( (i=bbStringFind(str,sub,i))!=-1 ) {i+=sub->length;n++;}
	if (!n) return str;
	d=rep->length-sub->length;
	BBString *t=bbStringNew( str->length+d*n );
	i=0;p=0;
	while( (j=bbStringFind(str,sub,i))!=-1 )
	{
		n=j-i;if (n) {memcpy( t->buf+p,str->buf+i,n*sizeof(BBChar) );p+=n;}
		n=rep->length;memcpy( t->buf+p,rep->buf,n*sizeof(BBChar) );p+=n;
		i=j+sub->length;		
	}
	n=str->length-i;
	if (n) memcpy( t->buf+p,str->buf+i,n*sizeof(BBChar) );
	return t;
}

int bbStringAsc( BBString *t ){
	return t->length ? t->buf[0] : -1;
}

int bbStringFind( BBString *x,BBString *y,int i ){
	if( i<0 ) i=0;
	while( i+y->length<=x->length ){
		if( charsEqual( x->buf+i,y->buf,y->length ) ) return i;
		++i;
	}
	return -1;
}

int bbStringFindLast( BBString *x,BBString *y,int i ){
	bbassert( i>=0 );
	i=x->length-i;
	if (i+y->length>x->length) i=x->length-y->length;
	while (i>=0)
	{
		if( charsEqual( x->buf+i,y->buf,y->length ) ) return i;
		--i;
	}
	return -1;
}

int bbStringToInt( BBString *t ){
	int i=0,neg=0,n=0;
	
	while( i<t->length && isspace(t->buf[i]) ) ++i;
	if( i==t->length ) return 0;
	
	if( t->buf[i]=='+' ) ++i;
	else if( neg=(t->buf[i]=='-') ) ++i;
	if( i==t->length ) return 0;

	if( t->buf[i]=='%' ){
		for( ++i;i<t->length;++i ){
			int c=t->buf[i];
			if( c!='0' && c!='1' ) break;
			n=n*2+(c-'0');
		}
	}else if( t->buf[i]=='$' ){
		for( ++i;i<t->length;++i ){
			int c=toupper(t->buf[i]);
			if( !isxdigit(c) ) break;
			if( c>='A' ) c-=('A'-'0'-10);
			n=n*16+(c-'0');
		}
	}else{
		for( ;i<t->length;++i ){
			int c=t->buf[i];
			if( !isdigit(c) ) break;
			n=n*10+(c-'0');
		}
	}
	return neg ? -n : n;
}

void bbStringToLong( BBString *t,BBInt64 *r ){
	int i=0,neg=0;
	BBInt64 n=0;
	
	while( i<t->length && isspace(t->buf[i]) ) ++i;
	if( i==t->length ){ *r=0;return; }
	
	if( t->buf[i]=='+' ) ++i;
	else if( neg=(t->buf[i]=='-') ) ++i;
	if( i==t->length ){ *r=0;return; }
	
	if( t->buf[i]=='%' ){
		for( ++i;i<t->length;++i ){
			int c=t->buf[i];
			if( c!='0' && c!='1' ) break;
			n=n*2+(c-'0');
		}
	}else if( t->buf[i]=='$' ){
		for( ++i;i<t->length;++i ){
			int c=toupper(t->buf[i]);
			if( !isxdigit(c) ) break;
			if( c>='A' ) c-=('A'-'0'-10);
			n=n*16+(c-'0');
		}
	}else{
		for( ;i<t->length;++i ){
			int c=t->buf[i];
			if( !isdigit(c) ) break;
			n=n*10+(c-'0');
		}
	}
	*r=neg ? -n : n;
}

float bbStringToFloat( BBString *t ){
	char *p=bbStringToCString( t );
	float n=atof( p );
	bbMemFree( p );
	return n;
}

double bbStringToDouble( BBString *t ){
	char *p=bbStringToCString( t );
	double n=atof( p );
	bbMemFree( p );
	return n;
}

BBString *bbStringToLower( BBString *str ){
	int k;
	BBString *t;
	t=bbStringNew( str->length );
	for( k=0;k<str->length;++k ){
		int c=str->buf[k];
		if( c<192 ){
			c=(c>='A' && c<='Z') ? (c|32) : c;
		}else{
			int lo=0,hi=sizeof(bbToLowerData)/4-1;
			while( lo<=hi ){
				int mid=(lo+hi)/2;
				if( c<bbToLowerData[mid*2] ){
					hi=mid-1;
				}else if( c>bbToLowerData[mid*2] ){
					lo=mid+1;
				}else{
					c=bbToLowerData[mid*2+1];
					break;
				}
			}
		}
		t->buf[k]=c;
	}
	return t;
}

BBString *bbStringToUpper( BBString *str ){
	int k;
	BBString *t;
	t=bbStringNew( str->length );
	for( k=0;k<str->length;++k ){
		int c=str->buf[k];
		if( c<181 ){
			c=(c>='a' && c<='z') ? (c&~32) : c;
		}else{
			int lo=0,hi=sizeof(bbToUpperData)/4-1;
			while( lo<=hi ){
				int mid=(lo+hi)/2;
				if( c<bbToUpperData[mid*2] ){
					hi=mid-1;
				}else if( c>bbToUpperData[mid*2] ){
					lo=mid+1;
				}else{
					c=bbToUpperData[mid*2+1];
					break;
				}
			}
		}
		t->buf[k]=c;
	}
	return t;
}

char *bbStringToCString( BBString *str ){
	char *p;
	int k,sz=str->length;
	p=(char*)bbMemAlloc( sz+1 );
	for( k=0;k<sz;++k ) p[k]=str->buf[k];
	p[sz]=0;
	return p;
}

BBChar *bbStringToWString( BBString *str ){
	BBChar *p;
	int k,sz=str->length;
	p=(BBChar*)bbMemAlloc( (sz+1)*sizeof(BBChar) );
	memcpy(p,str->buf,sz*sizeof(BBChar));
	p[sz]=0;
	return p;
}

char *bbStringToUTF8String( BBString *str ){
	int i,len=str->length;
	char *buf=(char*)bbMemAlloc( len*3+1 );
	char *q=buf;
	unsigned short *p=str->buf;
	for( i=0;i<len;++i ){
		unsigned int c=*p++;
		if( c<0x80 ){
			*q++=c;
		}else if( c<0x800 ){
			*q++=0xc0|(c>>6);
			*q++=0x80|(c&0x3f);
		}else{
			*q++=0xe0|(c>>12);
			*q++=0x80|((c>>6)&0x3f);
			*q++=0x80|(c&0x3f);
		}
	}
	*q=0;
	return buf;
}

BBArray *bbStringSplit( BBString *str,BBString *sep ){
	int i,i2,n;
	BBString **p,*bit;
	BBArray *bits;

	if( sep->length ){
		i=0;n=1;
		while( (i2=bbStringFind( str,sep,i ))!=-1 ){
			++n;
			i=i2+sep->length;
		}
		
		bits=bbArrayNew1D( "$",n );
		p=(BBString**)BBARRAYDATA( bits,1 );
	
		i=0;
		while( n-- ){
			i2=bbStringFind( str,sep,i );
			if( i2==-1 ) i2=str->length;
			bit=bbStringSlice( str,i,i2 );
			BBINCREFS( bit );
			*p++=bit;
			i=i2+sep->length;
		}
		return bits;
	}
		
	i=0;n=0;
	for(;;){
		while( i!=str->length && str->buf[i]<33 ) ++i;
		if( i++==str->length ) break;
		while( i!=str->length && str->buf[i]>32 ) ++i;
		++n;
	}
	if( !n ) return &bbEmptyArray;
	
	bits=bbArrayNew1D( "$",n );
	p=(BBString**)BBARRAYDATA( bits,1 );
	
	i=0;
	while( n-- ){
		while( str->buf[i]<33 ) ++i;
		i2=i++;
		while( i!=str->length && str->buf[i]>32 ) ++i;
		bit=bbStringSlice( str,i2,i );
		BBINCREFS( bit );
		*p++=bit;
	}
	return bits;
}

BBString *bbStringJoin( BBString *sep,BBArray *bits ){
	int i,sz=0;
	int n_bits=bits->scales[0];
	BBString **p,*str;
	BBChar *t;
	
	if( bits==&bbEmptyArray ){
		return &bbEmptyString;
	}
	
	p=(BBString**)BBARRAYDATA( bits,1 );
	for( i=0;i<n_bits;++i ){
		BBString *bit=*p++;
		sz+=bit->length;
	}

	sz+=(n_bits-1)*sep->length;
	str=bbStringNew( sz );
	t=str->buf;
	
	p=(BBString**)BBARRAYDATA( bits,1 );
	for( i=0;i<n_bits;++i ){
		if( i ){
			memcpy( t,sep->buf,sep->length*sizeof(BBChar) );
			t+=sep->length;
		}
		BBString *bit=*p++;
		memcpy( t,bit->buf,bit->length*sizeof(BBChar) );
		t+=bit->length;
	}
	
	return str;
}

static void mktmp( void *p ){
	static int i;
	static void *bufs[32];
	int n=bbAtomicAdd( &i,1 ) & 31;
	bbMemFree( bufs[n] );
	bufs[n]=p;
}

char *bbTmpCString( BBString *str ){
	char *p=bbStringToCString( str );
	mktmp( p );
	return p;
}

BBChar *bbTmpWString( BBString *str ){
	BBChar *p=bbStringToWString( str );
	mktmp( p );
	return p;
}

char *bbTmpUTF8String( BBString *str ){
	char *p=bbStringToUTF8String( str );
	mktmp( p );
	return p;
}
