
#ifndef STD_H
#define STD_H

#include "stdutil.h"
#include "declseq.h"
#include "../codegen/codegen.h"

struct Decl;
struct FunBlock;
struct ClassBlock;
struct ModuleType;

extern int strictMode;					//strict option : 1=strict, 2=superstrict!
extern FunBlock* mainFun;				//main function

extern DeclSeq rootScope;				//root scope - moduletype decls
extern DeclSeq objectExports;			//exports from this object file
extern DeclSeq moduleExports;			//exports from this and imported object files
extern vector<string> objectImports;	//'import' directives for object
extern vector<string> moduleImports;	//'import' directives for module
extern vector<string> moduleInfos;		//'ModuleInfo' directives

extern set<string> importedSources;		//source files already imported

extern string globalIdent;

string  fixIdent( string id );

void	publish( Decl *d );
Val*	findGlobal( string id );

CGDat*  genCString( string t );
CGDat*  genBBString( bstring t );
CGDat*  genBBString2( bstring t );
CGDat*  genDebugStm( string t );

string  mungGlobal( string decl_id );
string  mungMember( string class_id,string decl_id );
string  mungObjectEntry( string path );
string  mungModuleEntry( string modname );

bstring escapeString( bstring t );
bstring unescapeString( bstring t );

void	dupid( string id,const char *fmt="Duplicate identifier '%s'" );
void	badid( string id,const char *fmt="Identifier '%s' not found" );
void	badty( string id,const char *fmt="Type '%s' not found" );
void	badmod( string id,const char *fmt="Module '%s' not found" );

#endif
