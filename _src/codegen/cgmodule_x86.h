
#ifndef CGMODULE_X86_H
#define CGMODULE_X86_H

#include "cgmodule.h"
#include "cgframe_x86.h"

struct CGModule_X86 : public CGModule{
	string		seg;
	
	CGModule_X86( ostream &out );
	
	void		setSeg( string t );
	
	CGFrame*	frame( CGFun *fun );
	void		emitHeader();
	void		emitImport( string t );
	void		emitExport( string t );
	void		emitFrame( CGFrame *f );
	void		emitMacFrame( CGFrame *f );
	void		emitData( CGDat *d );
	void		emitFooter();
	void		emitSubEsp( int sz );
};

#endif