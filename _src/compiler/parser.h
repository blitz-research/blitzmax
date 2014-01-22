
#ifndef PARSER_H
#define PARSER_H

#include "stm.h"
#include "toker.h"

class Parser{

	Toker*	toker;
	Block*  block;

	bool	pub_;
	Exp*	primary;
	ExpSeq* fun_defaults;
	int		default_call_conv;
	string  loopLabel;
	int		import_nest;
	int		extern_nest;
	ModuleType *import_module;

	void	fail( const char *fmt,... );
	int		curr();
	int		next();
	string	text();
	bstring wtext();
	string	parse( int n );
	bool	cparse( int n );
	void	exp( int n );
	void	exp( string t );

	bool	pub();
	int		linkage();

	void	emitDebugInfo();
	void	emit( Stm *t,bool debugInfo );
	void	decl( Decl *d );

	Type*   parseLitType( Type *ty );
	Val*	parseLitVal();
	CGExp *parseLitExp( Type *ty );
	string	parseString();
	bstring parseBString();
	string	parseIdent();
	string  parseClassName();
	string  parseModuleName();

	int		parseCGType();
	CGLit*	parseCGLit();
	CGExp*	parseCGExp();
	Decl*   parseImportDecl();

	void	importFile( string file,ModuleType *mod );
	void	importModule( string mod );
	void	importSource( string src );
	
	void	parseImport();
	int		parseCallConv();
	void	parseExtern();
	
	int		arrayDeclDims( string t );

	Type*	parseBaseType();
	FunType*parseFunType( Type *baseType );
	Type*	parseType();
	RefType*parseRefType();

	Exp*	parseCastExp( Type *base_ty );
	ArrayExp*parseArrayExp( Type *ty );
	Exp*	parsePeekExp();
	Exp*	parseIdentExp();
	
	Exp*	parseArrayDataExp();
	Exp*	parseNewExp();
	
	Exp*	parsePriExp();	//Ident, Constant, Self, Super, New(?)
	Exp*	parsePostExp( Exp *lhs=0 );	//Member, Extends, Invoke
	Exp*	parsePreExp();	//Cast, Varptr, Peek, First, Last, Before, After
	Exp*	parsePowExp();  //^
	Exp*	parseFactExp();	//*, /, Mod, Shl, Shr, Sar
	Exp*	parseTermExp();	//+, -
	Exp*	parseCmpExp();	//<, =, >, <=, >=, <>
	Exp*	parseShortCircExp();	//AndIf, OrIf
	Exp*	parseBitwiseExp();	//And, Or, Xor
	Exp*	parseExp();

	string	parseMetaData();
	void	addMetaData( const vector<Decl*> &decls );

	Decl*   parseInitDecl( Exp **init );
	
	void	parseLocalDecls();
	void	parseGlobalDecls();
	void	parseConstDecls();
	void	parseFieldDecls();

	void	parseTypeDecl();
	void	parseFunDecl( int attr );

	void	parseAccess();
	void	parseModule();
	
	void	parseLabelStm();
	void	parseGotoStm();
	void	parseFlushMemStm();
	void	parseDataStm();
	void	parseReadStm();
	void	parseRestoreStm();

	void	parseStm();
	void	parseEndStm();
	void	parseExpStm();
	void	parseIfStm( int term );
	void	parseLoopCtrlStm();
	void	parseForStm();
	void	parseWhileStm();
	void	parseRepeatStm();
	void	parseSelectStm();
	void	parseReturnStm();
	void	parseDeleteStm();
	void	parsePokeStm();
	void	parseAssertStm();
	void	parseTryStm();
	void	parseThrowStm();
	void	includeFile( string file );

	void	parseStms( Block *block,int term );
	
public:
	Parser();
	
	void	parse();
};

#endif