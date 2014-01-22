
#include "cgstd.h"

#include "cgmodule.h"

CGModule::CGModule( ostream &o ):out(o){
}

CGModule::~CGModule(){
}

CGFrame *CGModule::createFrame( CGFun *fun ){
	CGFrame *f=frame(fun);
	frames.push_back(f);
	return f;
}

struct CGSymFinder : public CGVisitor{

	CGModule *module;
	
	CGSymFinder( CGModule *m ):module(m){}

	CGExp *visit( CGExp *exp ){
		if( CGSym *t=exp->sym() ){
			if( CGDat *d=t->dat() ){
				if( !module->dataSyms.count(d->value) ){
					module->datas.push_back(d);
					module->dataSyms.insert( d->value );
				}
			}
			if( t->linkage==CG_IMPORT ) module->importSyms.insert( t->value );
			else if( t->linkage==CG_EXPORT ) module->exportSyms.insert( t->value );
			
		}
		return exp;
	}
};

void CGModule::emitModule(){
	
	CGSymFinder vis(this);
	
	int k;
	for( k=0;k<frames.size();++k ){
		CGFrame *f=frames[k];
		CGSym *sym=f->fun->sym;
		if( sym->linkage==CG_EXPORT ) exportSyms.insert( sym->value );
		CGAsm *as;
		for( as=f->assem.begin;as!=f->assem.end;as=as->succ ){
			CGStm *t=as->stm;
			if( !t ) continue;
			t->visit( vis );
		}
	}
	
	set<string>::iterator sym_it;
	
	//header
	emitHeader();
	
	//imports
	for( sym_it=importSyms.begin();sym_it!=importSyms.end();++sym_it ){
		emitImport( *sym_it );
	}
	
	//exports
	for( sym_it=exportSyms.begin();sym_it!=exportSyms.end();++sym_it ){
		emitExport( *sym_it );
	}
	
	//frames
	for( k=0;k<frames.size();++k ){
		emitFrame( frames[k] );
	}
	
	//datas
	for( k=0;k<datas.size();++k ){
		emitData( datas[k] );
	}
	
	//footer
	emitFooter();
	
	out.flush();
}
