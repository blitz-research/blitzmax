
#include <brl.mod/blitz.mod/blitz.h>

#include <signal.h>

void __bb_appstub_appstub();

int main( int argc,char *argv[] ){

	signal( SIGPIPE,SIG_IGN );
	
	bbStartup( argc,argv,0,0 );
	
	__bb_appstub_appstub();

	return 0;
}
