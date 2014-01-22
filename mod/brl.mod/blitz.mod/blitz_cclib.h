
#ifndef BLITZ_CCLIB_H
#define BLITZ_CCLIB_H

#include "blitz_types.h"

#ifdef __cplusplus
extern "C"{
#endif

int		bbIntAbs( int x );
int		bbIntSgn( int x );
int		bbIntMod( int x,int y );
int		bbIntMin( int x,int y );
int		bbIntMax( int x,int y );
void	bbIntToLong( BBInt64 *r,int x );

double	bbFloatAbs( double x );
double	bbFloatSgn( double x );
double	bbFloatPow( double x,double y );
double	bbFloatMod( double x,double y );
double	bbFloatMin( double x,double y );
double	bbFloatMax( double x,double y );
int		bbFloatToInt( double x );
void	bbFloatToLong( BBInt64 *r,double x );

void	bbLongNeg( BBInt64 *r,BBInt64 x );
void	bbLongNot( BBInt64 *r,BBInt64 x );
void	bbLongAbs( BBInt64 *r,BBInt64 x );
void	bbLongSgn( BBInt64 *r,BBInt64 x );
void	bbLongAdd( BBInt64 *r,BBInt64 x,BBInt64 y );
void	bbLongSub( BBInt64 *r,BBInt64 x,BBInt64 y );
void	bbLongMul( BBInt64 *r,BBInt64 x,BBInt64 y );
void	bbLongDiv( BBInt64 *r,BBInt64 x,BBInt64 y );
void	bbLongMod( BBInt64 *r,BBInt64 x,BBInt64 y );
void	bbLongMin( BBInt64 *r,BBInt64 x,BBInt64 y );
void	bbLongMax( BBInt64 *r,BBInt64 x,BBInt64 y );
void	bbLongAnd( BBInt64 *r,BBInt64 x,BBInt64 y );
void	bbLongOrl( BBInt64 *r,BBInt64 x,BBInt64 y );
void	bbLongXor( BBInt64 *r,BBInt64 x,BBInt64 y );
void	bbLongShl( BBInt64 *r,BBInt64 x,BBInt64 y );
void	bbLongShr( BBInt64 *r,BBInt64 x,BBInt64 y );
void	bbLongSar( BBInt64 *r,BBInt64 x,BBInt64 y );
int		bbLongSlt( BBInt64 x,BBInt64 y );
int		bbLongSgt( BBInt64 x,BBInt64 y );
int		bbLongSle( BBInt64 x,BBInt64 y );
int		bbLongSge( BBInt64 x,BBInt64 y );
int		bbLongSeq( BBInt64 x,BBInt64 y );
int		bbLongSne( BBInt64 x,BBInt64 y );
double	bbLongToFloat( BBInt64 x );

#ifdef __cplusplus
}
#endif

#endif
