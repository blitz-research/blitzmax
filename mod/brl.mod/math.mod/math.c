
#include <math.h>

#define RAD_TO_DEG 57.2957795130823208767981548141052
#define DEG_TO_RAD 0.0174532925199432957692369076848861

int bbIsNan( double x ){
	return isnan(x) ? 1 : 0;
}
int bbIsInf( double x ){
	return isinf(x) ? 1 : 0;
}
double bbSqr( double x ){
	return sqrt( x );
}
double bbSin( double x ){
	return sin( x*DEG_TO_RAD );
}
double bbCos( double x ){
	return cos( x*DEG_TO_RAD );
}
double bbTan( double x ){
	return tan( x*DEG_TO_RAD );
}
double bbASin( double x ){
	return asin( x ) * RAD_TO_DEG;
}
double bbACos( double x ){
	return acos( x ) * RAD_TO_DEG;
}
double bbATan( double x ){
	return atan( x ) * RAD_TO_DEG;
}
double bbATan2( double y,double x ){
	return atan2( y,x ) * RAD_TO_DEG;
}
double bbSinh( double x ){
	return sinh( x );
}
double bbCosh( double x ){
	return cosh( x );
}
double bbTanh( double x ){
	return tanh( x );
}
double bbExp( double x ){
	return exp( x );
}
double bbFloor( double x ){
	return floor( x );
}
double bbLog( double x ){
	return log(x);
}
double bbLog10( double x ){
	return log10(x);
}
double bbCeil( double x ){
	return ceil( x );
}
