
#import <AppKit/AppKit.h>

#include <brl.mod/blitz.mod/blitz.h>

void brl_timer__TimerFired( void *data );

@interface BBTimer : NSObject{
	NSTimer *_timer;
	void *_data;
}
-(id)initWithPeriod:(double)period data:(void*)data;
-(void)stop;
@end

@implementation BBTimer
-(id)initWithPeriod:(double)period data:(void*)data{
	self=[super init];
	_timer=[NSTimer scheduledTimerWithTimeInterval:period target:self selector:@selector(onTick:) userInfo:nil repeats:YES];
	_data=data;
	return self;
}
-(void)stop{
	[_timer invalidate];
	_timer=0;
}
-(void)onTick:(NSTimer*)timer{
	brl_timer__TimerFired( _data );
}
@end

BBTimer *bbTimerStart( float hertz,BBObject *bbTimer ){
	BBTimer *timer=[[BBTimer alloc] initWithPeriod:1.0/hertz data:bbTimer];
	if( !timer ) return 0;
	
	BBRETAIN( bbTimer );

	return timer;
}

void bbTimerStop( BBTimer *timer,BBObject *bbTimer ){
	[timer stop];
	[timer release];

	BBRELEASE( bbTimer );
}
