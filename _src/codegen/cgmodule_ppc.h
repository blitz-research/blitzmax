
#ifndef CGMODULE_PPC_H
#define CGMODULE_PPC_H

#include "cgmodule.h"
#include "cgframe_ppc.h"

struct CGModule_PPC : public CGModule{
	string		seg;
	CGSym*		fp_const;
	
	CGModule_PPC( std::ostream &out );
	
	void		setSeg( string t );
	
	CGFrame*	frame( CGFun *fun );
	void		emitHeader();
	void		emitImport( string t );
	void		emitExport( string t );
	void		emitFrame( CGFrame *f );
	void		emitData( CGDat *d );
	void		emitFooter();
};

#endif
