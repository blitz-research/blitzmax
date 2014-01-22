
#ifndef BLITZ_APP_H
#define BLITZ_APP_H

#include "blitz_types.h"

#ifdef __cplusplus
extern "C"{
#endif

/*
struct BBAppController{
	int (*shouldTerminate)();
};
*/

extern BBString*	bbAppDir;
extern BBString*	bbAppFile;
extern BBString*	bbAppTitle;
extern BBString*	bbLaunchDir;
extern BBArray*	bbAppArgs;

extern void**		bbGCStackTop;

void		bbEnd();
void		bbOnEnd( void(*f)() );

BBString*	bbReadStdin();
void		bbWriteStdout( BBString *t );
void		bbWriteStderr( BBString *t );

void		bbDelay( int ms );
int		bbMilliSecs();
int		bbIsMainThread();

void		bbStartup( int argc,char *argv[],void *dummy1,void *dummy2 );

#ifdef __cplusplus
}
#endif

#endif
