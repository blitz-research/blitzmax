
#include "blitz.h"

void bbCAssertEx(){
	bbExThrowCString( "C Assert failed" );
}

static void debugNop(){
}

static void debugUnhandledEx( BBObject *ex ){
	bbWriteStderr( ex->clas->ToString( ex ) );
	exit(-1);
}

void (*bbOnDebugStop)()=debugNop;
void (*bbOnDebugLog)( BBString *str )=debugNop;
void (*bbOnDebugEnterStm)( BBDebugStm *stm )=debugNop;
void (*bbOnDebugEnterScope)( BBDebugScope *scope,void *inst )=debugNop;
void (*bbOnDebugLeaveScope)()=debugNop;
void (*bbOnDebugPushExState)()=debugNop;
void (*bbOnDebugPopExState)()=debugNop;

void (*bbOnDebugUnhandledEx)( BBObject *ex )=debugUnhandledEx;

