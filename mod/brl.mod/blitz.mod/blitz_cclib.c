
#include "blitz.h"
#include <math.h>

int bbIntAbs( int x ){
	return x>=0 ? x : -x;
}
int bbIntSgn( int x ){
	return x==0 ? 0 : (x>0 ? 1 : -1);
}
int bbIntMod( int x,int y ){
	return x % y;
}
int bbIntMin( int x,int y ){
	return x<y ? x : y;
}
int bbIntMax( int x,int y ){ 
	return x>y ? x : y;
}
void bbIntToLong( BBInt64 *r,int x ){
	*r=x;
}

double bbFloatAbs( double x ){
	return fabs( x );
}
double bbFloatSgn( double x ){
	return x==0 ? 0 : (x>0 ? 1 : -1);
}
double bbFloatPow( double x,double y ){
	return pow(x,y);
}
double bbFloatMod( double x,double y ){
	return fmod( x,y );
}
double bbFloatMin( double x,double y ){
	return x<y ? x : y;
}
double bbFloatMax( double x,double y ){
	return x>y ? x : y;
}
void bbFloatToLong( BBInt64 *r,double x ){
	*r=x;
}

void bbLongNeg( BBInt64 *r,BBInt64 x ){
	*r=-x;
}
void bbLongNot( BBInt64 *r,BBInt64 x ){
	*r=~x;
}
void bbLongAbs( BBInt64 *r,BBInt64 x ){
	*r=x>=0 ? x : -x;
}
void bbLongSgn( BBInt64 *r,BBInt64 x ){
	*r=x>0 ? 1 : (x<0 ? -1 : 0);
}
void bbLongAdd( BBInt64 *r,BBInt64 x,BBInt64 y ){
	*r=x+y;
}
void bbLongSub( BBInt64 *r,BBInt64 x,BBInt64 y ){
	*r=x-y;
}
void bbLongMul( BBInt64 *r,BBInt64 x,BBInt64 y ){
	*r=x*y;
}
void bbLongDiv( BBInt64 *r,BBInt64 x,BBInt64 y ){
	*r=x/y;
}
void bbLongMod( BBInt64 *r,BBInt64 x,BBInt64 y ){
	*r=x%y;
}
void bbLongMin( BBInt64 *r,BBInt64 x,BBInt64 y ){
	*r=x<y ? x : y;
}
void bbLongMax( BBInt64 *r,BBInt64 x,BBInt64 y ){
	*r=x>y ? x : y;
}
void bbLongAnd( BBInt64 *r,BBInt64 x,BBInt64 y ){
	*r=x&y;
}
void bbLongOrl( BBInt64 *r,BBInt64 x,BBInt64 y ){
	*r=x|y;
}
void bbLongXor( BBInt64 *r,BBInt64 x,BBInt64 y ){
	*r=x^y;
}
void bbLongShl( BBInt64 *r,BBInt64 x,BBInt64 y ){
	*r=x<<y;
}
void bbLongShr( BBInt64 *r,BBInt64 x,BBInt64 y ){
	*r=(BBUInt64)x>>(BBUInt64)y;
}
void bbLongSar( BBInt64 *r,BBInt64 x,BBInt64 y ){
	*r=x>>y;
}
int bbLongSlt( BBInt64 x,BBInt64 y ){
	return x<y;
}
int bbLongSgt( BBInt64 x,BBInt64 y ){
	return x>y;
}
int bbLongSle( BBInt64 x,BBInt64 y ){
	return x<=y;
}
int bbLongSge( BBInt64 x,BBInt64 y ){
	return x>=y;
}
int bbLongSeq( BBInt64 x,BBInt64 y ){
	return x==y;
}
int bbLongSne( BBInt64 x,BBInt64 y ){
	return x!=y;
}
double bbLongToFloat( BBInt64 x ){
	return (double)x;
}
