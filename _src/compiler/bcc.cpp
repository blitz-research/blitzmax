
#include "std.h"
#include "parser.h"
#include "output.h"
#include "config.h"

using namespace CG;

int main( int argc,char *argv[] ){

	stdutil_init( argc,argv );

	int demo_days=demoDays();
	
	if( !opt_infile.size() ){
		if( demo_days<0 ){
			cout<<"BlitzMax Release Version "<<BCC_VERSION<<endl;
		}else if( demo_days<30 ){
			cout<<"BlitzMax Demo Version "<<BCC_VERSION<<" ("<<(30-demo_days)<<(demo_days<29 ? " days" : " day")<<" remaining)"<<endl;
		}else{
			cout<<"BlitzMax Demo Version "<<BCC_VERSION<<" (expired)"<<endl;
		}
		exit(0);
	}

	if( demo_days>=30 ){
		cout<<"BlitzMax demo has expired. Please visit www.blitzbasic.com to buy the full version of BlitzMax."<<endl;
		exit(0);
	}

	if( !ftime(opt_infile) ) fail( "Input file not found" );

	bool t_debug=opt_debug;
	
	Parser parser;
	
	if( opt_verbose ) cout<<"Parsing..."<<endl;
	parser.parse();
	
	if( opt_verbose ) cout<<"Resolving types..."<<endl;
	Type::resolveTypes();
	
	if( opt_verbose ) cout<<"Resolving decls..."<<endl;
	Decl::resolveDecls();
	
	if( opt_verbose ) cout<<"Resolving blocks..."<<endl;
	Block::resolveBlocks();

	if( opt_verbose ) cout<<"Evaluating fun blocks..."<<endl;
	Block::evalFunBlocks();

	opt_debug=t_debug;
	opt_release=!opt_debug;

	if( opt_verbose ) cout<<"Generating assembly..."<<endl;
	FunBlock::genAssem();
	
	if( opt_verbose ) cout<<"Generating interface..."<<endl;
	FunBlock::genInterface();
	
	return 0;
}
