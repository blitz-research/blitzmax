
#include <windows.h>
#include <mmsystem.h>
#include <stdio.h>

#include <brl.mod/system.mod/system.h>

#define MAX_TIMERS 16

void brl_timer__TimerFired( BBObject *bbTimer );

static int timers[MAX_TIMERS],n_timers;

static void timerSyncOp( BBObject *bbTimer,int timer ){
	int i;
	for( i=0;i<n_timers && timer!=timers[i];++i ) {}
	if( i<n_timers ) brl_timer__TimerFired( bbTimer );
}

static void __stdcall timerProc( UINT timer,UINT msg,DWORD user,DWORD u1,DWORD u2 ){
	bbSystemPostSyncOp( timerSyncOp,(BBObject*)user,timer );
}

int bbTimerStart( float hertz,BBObject *bbTimer ){
	int timer;
	
	if( n_timers==MAX_TIMERS ) return 0;
	
	timer=(int)timeSetEvent( 1000.0/hertz,0,timerProc,(DWORD)bbTimer,TIME_PERIODIC );
	if( !timer ) return 0;
	
	BBRETAIN( bbTimer );
	
	timers[n_timers++]=timer;
	return timer;
}

void bbTimerStop( int timer,BBObject *bbTimer ){
	int i;
	
	for( i=0;i<n_timers && timer!=timers[i];++i ) {}
	if( i==n_timers ) return;

	timers[i]=timers[--n_timers];
	timeKillEvent( timer );

	BBRELEASE( bbTimer );
}
