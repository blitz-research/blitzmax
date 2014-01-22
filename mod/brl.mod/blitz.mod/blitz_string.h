
#ifndef BLITZ_STRING_H
#define BLITZ_STRING_H

#include "blitz_types.h"

#ifdef __cplusplus
extern "C"{
#endif

#define BBNULLSTRING (&bbEmptyString)

struct BBString{
	BBClass*	clas;
	int		refs;
	int		length;
	BBChar	buf[];
};

extern	BBClass bbStringClass;
extern	BBString bbEmptyString;

BBString*bbStringNew( int len );
BBString*bbStringFromChar( int c );

BBString*bbStringFromInt( int n );
BBString*	bbStringFromLong( BBInt64 n );
BBString*bbStringFromFloat( float n );
BBString*	bbStringFromDouble( double n );
BBString*	bbStringFromBytes( const char *p,int n );
BBString*	bbStringFromShorts( const unsigned short *p,int n );
BBString*	bbStringFromInts( const int *p,int n );
BBString*bbStringFromArray( BBArray *arr );
BBString*	bbStringFromCString( const char *p );
BBString*bbStringFromWString( const BBChar *p );
BBString*bbStringFromUTF8String( const char *p );

BBString*	bbStringToString( BBString *t );
int		bbStringCompare( BBString *x,BBString *y );
int		bbStringStartsWith( BBString *x,BBString *y );
int		bbStringEndsWith( BBString *x,BBString *y );
int		bbStringContains( BBString *x,BBString *y );

BBString*bbStringConcat( BBString *x,BBString *y );

BBString*	bbStringTrim( BBString *t );
BBString*	bbStringSlice( BBString *t,int beg,int end );
BBString*	bbStringReplace( BBString *str,BBString *sub,BBString *rep );

int		bbStringAsc( BBString *t );
int		bbStringFind( BBString *x,BBString *y,int i );
int		bbStringFindLast( BBString *x,BBString *y,int i );
BBString*	bbStringToLower( BBString *str );
BBString*	bbStringToUpper( BBString *str );

int		bbStringToInt( BBString *str );
float	bbStringToFloat( BBString *str );
double	bbStringToDouble( BBString *str );
void		bbStringToLong( BBString *str,BBInt64 *r );
char*	bbStringToCString( BBString *str );
BBChar*	bbStringToWString( BBString *str );
char*	bbStringToUTF8String( BBString *str );

BBArray*	bbStringSplit( BBString *str,BBString *sep );
BBString*	bbStringJoin( BBString *sep,BBArray *bits );

char*	bbTmpCString( BBString *str );
BBChar*	bbTmpWString( BBString *str );
char*	bbTmpUTF8String( BBString *str );

#ifdef __cplusplus
}
#endif

#endif
