
#include "cgstd.h"

#include "codegen.h"
#include "cgdebug.h"
#include "cgallocregs.h"

#include "cgmodule_x86.h"
#include "cgmodule_ppc.h"

void cgGenCode( ostream &o,const vector<CGFun*> &funs ){

	CGModule *mod;

	if( opt_arch=="x86" ) mod=new CGModule_X86(o);
	else if( opt_arch=="ppc" ) mod=new CGModule_PPC(o);
	else fail( "No backend available" );

	for( int k=0;k<funs.size();++k ){

		CGFun *fun=funs[k];

//		cout<<"Fun:"<<fun->sym->value<<endl;

		CGFrame *frame=mod->createFrame( fun );

//		cout<<frame->fun;

//		cout<<"FindEscapes"<<endl;
		frame->findEscapes();		//local escaping tmps

		//cout<<"RenameTmps"<<endl;
		frame->renameTmps();		//rename tmps->regs

		//cout<<"Linearize"<<endl;
		frame->linearize();			//remove SEQ and ESQ nodes
		
		//cout<<"fixInt64"<<endl;
		frame->fixInt64();			//rewrite int_64 code

		//cout<<"fixSymbols"<<endl;
		frame->fixSymbols();		//fix symbols depending on platform

		//cout<<"preOptimize"<<endl;
		frame->preOptimize();		//do some opts before asm gen

		//cout<<"genAssem"<<endl;
		frame->genAssem();
		
		//cout<<"createFlow"<<endl;
		frame->createFlow();

//		cout<<frame->assem;
		
		//cout<<"optDeadCode"<<endl;
		frame->optDeadCode();

		//cout<<"optDupLoads"<<endl;
		frame->optDupLoads();

//		cout<<frame->fun;
//		cout<<frame->assem;
		
		//cout<<"allocRegs"<<endl;
		frame->allocRegs();

		frame->finish();

		frame->deleteFlow();
		
//		frame->peepOpt();		//BROKEN!!!!!

		//cout<<frame->assem;
	}

	mod->emitModule();
}
