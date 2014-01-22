
#ifndef CGMODULE_H
#define CGMODULE_H

#include "cgframe.h"

struct CGModule{
	ostream&	out;
	vector<CGFrame*> frames;
	vector<CGDat*> datas;
	
	set<string> importSyms,exportSyms,dataSyms;
	
	CGModule( ostream &out );
	virtual ~CGModule();
	
	CGFrame*	createFrame( CGFun *f );
	void		emitModule();
	
	virtual CGFrame*frame( CGFun *fun )=0;
	virtual void	emitHeader()=0;
	virtual void	emitImport( string t )=0;
	virtual void	emitExport( string t )=0;
	virtual void	emitFrame( CGFrame *frame )=0;
	virtual void	emitData( CGDat *dat )=0;
	virtual void	emitFooter()=0;
};

/*
struct CGModule{

	IdentSet	externs;
	IdentSet	exports;
	IdentSet	imports;

	std::set<CGDat*> datas;
	
	virtual ~CGModule();

	virtual void		emit();

	virtual CGFrame*	createFrame( CGFun *fun )=0;
	virtual void		flush()=0;
};
*/

#endif