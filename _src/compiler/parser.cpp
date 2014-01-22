
#include "std.h"
#include "parser.h"
#include "config.h"

static const double PI=3.1415926535897932384626433832795;

using namespace CG;

void Parser::fail( const char *fmt,... ){
	char buf[256];
	va_list args;
	va_start( args,fmt );
	vsprintf( buf,fmt,args );
	source_info=toker->sourceInfo();
	::fail( buf );
}

int Parser::curr(){
	return toker->curr();
}

int Parser::next(){
	return toker->next();
}

string Parser::text(){
	return toker->text();
}

bstring Parser::wtext(){
	if( toker->curr()==T_STRINGCONST ) return unescapeString( toker->wtext() );
	return toker->wtext();
}

void Parser::exp( int n ){
	fail( "Expecting %s but encountered %s",Toker::toString(n).c_str(),Toker::toString(curr()).c_str() );
}

void Parser::exp( string t ){
	fail( "Expecting %s but encountered %s",t.c_str(),Toker::toString(curr()).c_str() );
}

string Parser::parse( int n ){
	if( curr()!=n ) exp(n);
	string t=text();
	next();return t;
}

bool Parser::cparse( int n ){
	if( curr()!=n ) return false;
	next();return true;
}

bool Parser::pub(){
	return pub_ && block==mainFun;
}

void Parser::emitDebugInfo(){
	if( !block->debug_on ) return;
	DebugInfoStm *t=new DebugInfoStm;
	t->source_info=source_info;
	block->emit(t);
}

void Parser::emit( Stm *t,bool debugInfo ){
	if( debugInfo ) emitDebugInfo();
	t->source_info=source_info;
	block->emit(t);
}

void Parser::decl( Decl *d ){
	block->decl(d);
	if( pub() ) publish( d );
}

Type *Parser::parseLitType( Type *ty ){
	switch( curr() ){
	case '%':next();return cparse('%') ? Type::int64 : Type::int32;
	case '#':next();return cparse('#') ? Type::float64 : Type::float32;
	case '!':next();return Type::float64;
	case ':':next();break;
	default:return ty;
	}
	switch( curr() ){
	case T_BYTE:next();return Type::int8;
	case T_SHORT:next();return Type::int16;
	case T_INT:next();return Type::int32;
	case T_LONG:next();return Type::int64;
	case T_FLOAT:next();return Type::float32;
	case T_DOUBLE:next();return Type::float64;
	}
	fail( "Expecting literal type" );
	return 0;
}

Val *Parser::parseLitVal(){
	Val *v;
	Type *ty;
	switch( curr() ){
	case T_INTCONST:
		v=new Val( toint(text()) );
		ty=Type::int32;
		break;
	case T_FLOATCONST:
		v=new Val( tofloat(text()) );
		ty=Type::float32;
		break;
	default:
		exp( "integer or floating point literal value" );
	}
	next();
	ty=parseLitType( ty );
	return v->cast( ty );
}

CGExp *Parser::parseLitExp( Type *ty ){
	int sign=0;
	for(;;){
		if( cparse('+') ){
		}else if( cparse('-') ){
			sign=sign ? -sign : -1;
		}else{
			break;
		}
	}
	Val *v;
	switch( curr() ){
	case T_INTCONST:{
		int64 n=toint(text());
		if( sign<0 ) n=-n;
		v=new Val( n );
		next();
		break;
		}
	case T_FLOATCONST:{
		double n=tofloat(text());
		if( sign<0 ) n=-n;
		v=new Val( n );
		next();
		break;
		}
	case T_STRINGCONST:{
		if( sign ) exp( "Numeric or string literal value" );
		v=new Val( parseBString() );
		break;
		}
	default:
		exp( "Numeric or string literal value" );
	}
	ty=parseLitType( ty );
	v=v->cast( ty );
	return v->cg_exp;
}

string Parser::parseString(){
	string t=parse(T_STRINGCONST);
	return t.substr(1,t.size()-2);
}

bstring Parser::parseBString(){
	if( curr()!=T_STRINGCONST ) exp(T_STRINGCONST);
	bstring t=wtext();next();
	return t.substr(1,t.size()-2);
}

string Parser::parseIdent(){
	if( !import_nest ) return parse(T_IDENT);
	switch( curr() ){
	case T_OBJECT:case T_STRING:case T_NEW:case T_DELETE:case T_IDENT:
		break;
	default:
		fail( "Invalid import identifier: %s",Toker::toString(curr()).c_str() );
	}
	string id=text();
	next();
	return id;
}

string Parser::parseClassName(){
	string id=parseIdent();
	while( cparse('.') ) id+='.'+parseIdent();
	return id;
}

string Parser::parseModuleName(){
	string id=parseIdent();
	while( cparse('.') ) id+='.'+parseIdent();
	return tolower(id);
}

static void ass( bool t ){
	if( !t ) fail( "Error in import file" );
}

CGExp *Parser::parseCGExp(){

	int sgn=1;
	if( cparse('-') ) sgn=-1;

	if( curr()==T_INTCONST || curr()==T_FLOATCONST ){
		Val *v=parseLitVal();
		CGLit *t=v->cg_exp->lit();
		if( t->type==CG_INT64 ) return lit( sgn * t->int_value );
		if( t->type==CG_FLOAT64 ) return lit( sgn * t->float_value );
		if( t->type==CG_INT32 ) return lit( sgn * int(t->int_value ) );
		if( t->type==CG_FLOAT32 ) return lit( sgn * float(t->float_value) );
		assert(0);
	}else if( curr()==T_STRINGCONST ){
		return sym(parseString(),CG_IMPORT);
	}else if( cparse('$') ){
		return (new Val(parseBString()))->cg_exp;
	}
	
	string id=parseIdent();

	if( id=="nan" ){
		double zero=0.0;
		if( cparse('#') ) return lit( float(0.0/zero) );
		if( cparse('!') ) return lit( double(0.0/zero) );
		fail( "Nan error" );
	}
	if( id=="inf" ){
		double zero=0.0;
		if( cparse('#') ) return lit( float(sgn/zero) );
		if( cparse('!') ) return lit( double(sgn/zero) );
		fail( "Inf error" );
	}

	int ty=CG_INT32;
	if( cparse(':') ){
		string t=parseIdent();
		switch(t[0]){
		case 'b':ty=CG_INT8;break;
		case 's':ty=CG_INT16;break;
		case 'i':ty=CG_INT32;break;
		case 'l':ty=CG_INT64;break;
		case 'p':ty=CG_PTR;break;
		case 'f':ty=CG_FLOAT32;break;
		case 'd':ty=CG_FLOAT64;break;
		default:fail( "Unrecognized intermediate code data type" );
		}
	}

	parse('(');
	CGExp *exp=0;

	if( id=="mem" ){
		exp=parseCGExp();
		int n=0;
		if( curr()!=')' ){
			parse(',');
			n=parseLitVal()->cg_exp->lit()->int_value;
		}
		exp=CG::mem(ty,exp,n);
	}else{
		fail( "Unrecognized intermediate code expression" );
	}
	
	parse(')');
	return exp;
}

Decl *Parser::parseImportDecl(){
	string id=parseIdent();
	Type  *ty=parseType();
	CGExp *cg=cparse(T_EQ) ? parseCGExp() : 0;
	return new Decl( id,ty,cg );
}

int Parser::parseCallConv(){

	if( curr()!=T_STRINGCONST ) return default_call_conv;
	
	string t=tolower(parseString());
	
	if( t=="c" ) return CG_CDECL;
	if( t=="blitz" ) return CG_CDECL;
	if( t=="os" ) t=env_platform;
	if( t=="macos" ) return CG_CDECL;
	if( t=="linux" ) return CG_CDECL;
	if( t=="win32" ) return CG_STDCALL;
	
	fail( "Unrecognized calling convention '%s'",t.c_str() );
	return 0;
}

void Parser::parseExtern(){
	next();
	
	++extern_nest;

	int call_conv=default_call_conv;
	default_call_conv=parseCallConv();
	
	while( !cparse(T_ENDEXTERN) ){
		source_info=toker->sourceInfo();
		if( cparse('\n') ){
		}else if( curr()==T_CONST ){
			parseConstDecls();
		}else if( cparse(T_GLOBAL) ){
			do{
				string id=parseIdent();
				Type *ty=parseRefType();
				CGExp *cg=cparse(T_EQ) ? parseCGExp() : 0;
				emit( new ExternDeclStm(T_GLOBAL,id,ty,cg,pub()),false );
			}while( cparse(',') );
		}else if( cparse(T_FUNCTION) ){
			do{
				string id=parseIdent();
				ExpSeq *defs=new ExpSeq();
				fun_defaults=defs;
				FunType *ty=parseType()->funType();
				fun_defaults=0;
				if( !ty ) exp( "function type" );
				CGExp *cg=cparse(T_EQ) ? parseCGExp() : 0;
				Decl *d=new FunDecl( id,ty,cg,block,defs );
				decl(d);
			}while( cparse(',') );
		}else if( cparse(T_TYPE) ){
			string id=parseIdent(),super_id;
			if( cparse(T_EXTENDS) ) super_id=parseIdent();
			ClassType *class_ty=new ClassType( super_id,block,ClassType::EXTERN );
			while( !cparse(T_ENDTYPE) ){
				if( cparse('\n') ){
				}else if( cparse(T_FIELD) ){
					do{
						string id=parseIdent();
						Type *ty=parseRefType();
						class_ty->fields.push_back( new Decl(id,ty,0) );
					}while( cparse(',') );
				}else if( cparse(T_METHOD) ){
					string id=parseIdent();
					ExpSeq *defs=new ExpSeq();
					fun_defaults=defs;
					FunType *ty=parseType()->funType();
					fun_defaults=0;
					if( !ty ) exp( "method type" );
					ty->attrs|=FunType::METHOD;
					CGExp *cg=cparse(T_EQ) ? parseCGExp() : 0;
					Decl *d=new FunDecl( id,ty,cg,block,defs );
					class_ty->methods.push_back( d );
/*
					string id=parseIdent();
					FunType *ty=parseType()->funType();
					if( !ty ) exp( "method type" );
					ty->attrs|=FunType::METHOD;
					class_ty->methods.push_back( new Decl(id,ty,0) );
*/
				}else{
					exp( "field or method declaration" );
				}
			}
			decl( new Decl(id,class_ty,lit0) );
		}else{
			fail( "Syntax error in extern block - expecting Const, Global, Function or Type declaration" );
		}
	}
	default_call_conv=call_conv;
	
	--extern_nest;
}

Type *Parser::parseBaseType(){
	Scope *scope=block;

	if( import_module ) scope=import_module;
	
	switch( curr() ){
	case '!':next();return Type::float64;
	case '$':next();return Type::stringObject;
	case '@':if( next()!='@' ) return Type::int8;
		next();return Type::int16;
	case '%':if( next()!='%' ) return Type::int32;
		next();return Type::int64;
	case '#':if( next()!='#' ) return Type::float32;
		next();return Type::float64;
	case T_CSTRING:
		next();return Type::c_string;
	case T_WSTRING:
		next();return Type::w_string;
	case ':':
		switch( next() ){
		case T_BYTE:next();return Type::int8;
		case T_SHORT:next();return Type::int16;
		case T_INT:next();return Type::int32;
		case T_LONG:next();return Type::int64;
		case T_FLOAT:next();return Type::float32;
		case T_DOUBLE:next();return Type::float64;
		case T_OBJECT:next();return Type::objectObject;
		case T_STRING:next();return Type::stringObject;
		case T_IDENT:return new ObjectType( parseClassName(),scope );
		}
		exp(T_IDENT);
	case '^':
		if( import_nest ){
			next();
			string super_name=cparse(T_NULL) ? "" : parseClassName();
			parse('{');
		
			ClassType *ty=new ClassType( super_name,scope );
		
			while( !cparse('}') ){
				if( cparse('\n') ){
				}else if( curr()=='+' || curr()=='-' ){
					int tok=curr();next();
					Decl *d=parseImportDecl();
					FunType *f=d->val->type->funType();ass( !!f );
					if( tok=='-' ) f->attrs|=FunType::METHOD;
					ty->methods.push_back(d);
				}else if( cparse('.') ){
					Decl *d=parseImportDecl();
					ass( !d->val->cg_exp );
					ty->fields.push_back(d);
				}else{
					Decl *d=parseImportDecl();
					ass( !!d->val->cg_exp );
					ty->decls.push_back(d);
				}
			}
			if( curr()==T_IDENT ){
				string id=tolower(parseIdent());
				if( id.find('a')!=string::npos ) ty->attrs|=ClassType::ABSTRACT;
				if( id.find('f')!=string::npos ) ty->attrs|=ClassType::FINAL;
				if( id.find('e')!=string::npos ) ty->attrs|=ClassType::EXTERN;
			}
			return ty;
		}
		break;
	}
	return Type::int32;
}

FunType *Parser::parseFunType( Type *ty ){
	
	parse('(');
	
	FunType *fun=new FunType(ty);
	fun->call_conv=default_call_conv;
	
	if( !cparse(')') ){
		do{
			CGExp *cg=0;
	
			string id=parseIdent();
			
			ExpSeq *tmp_defaults=fun_defaults;
			fun_defaults=0;
			Type *ty=parseType();
			fun_defaults=tmp_defaults;
			
			if( cparse(T_VAR) ) ty=new VarType(ty);
			
			if( fun_defaults ){
				if( cparse(T_EQ) ) fun_defaults->push_back( parseExp() );
				else fun_defaults->push_back(0);
			}else if( cparse(T_EQ) ){
				if( !import_nest ){
					fail( "Function argument defaults can only be specified in function declaration" );
//					cg=parseLitExp( ty );
				}else{
					cg=parseCGExp();
				}
			}
			fun->args.push_back( new Decl(id,ty,cg) );
		}while( cparse(',') );
		parse(')');
	}
	if( import_nest ){
		if( curr()==T_IDENT ){
			string id=tolower(parseIdent());
			if( id.find('a')!=string::npos ) fun->attrs|=FunType::ABSTRACT;
			if( id.find('f')!=string::npos ) fun->attrs|=FunType::FINAL;
			if( id.find('s')!=string::npos ) fun->call_conv=CG_STDCALL;
		}
	}else if( curr()==T_STRINGCONST ){
		fun->call_conv=parseCallConv();
	}
	return fun;
}

int Parser::arrayDeclDims( string t ){
	assert( t.size()>1 && t[0]=='[' && t[t.size()-1]==']' );
	int n=1;
	for( int i=1;i<t.size()-1;++i ){
		if( t[i]==',' ) ++n;
	}
	return n;
}

Type *Parser::parseType(){

	Type *ty;
	
	if( strictMode>1 && !import_nest ){
		FunType *fun;
		switch( curr() ){
		case '(':
			fun=parseFunType( Type::int32 );
			fun->attrs|=FunType::VOIDFUN;
			ty=fun;
			break;
		case '%':case ':':
			ty=parseBaseType();
			break;
		default:
			ty=parseBaseType();
			if( ty==Type::int32 ) fail( "Missing type specifier" );
		}
	}else{
		ty=parseBaseType();
	}
	
	for(;;){
		if( curr()=='(' ){
			if( fun_defaults ){
				for( int i=0;i<fun_defaults->size();++i ){
					if( (*fun_defaults)[i] ){
						fail( "Illegal default function parameter" );
					}
				}
				fun_defaults->clear();
			}
			ty=parseFunType(ty);
			continue;
		}

		if( ty->cstringType() || ty->wstringType() ) break;

		if( curr()==T_ARRAYDECL ){
			if( !import_nest ) ty=new RefType(ty);
			ArrayType *arr=new ArrayType( ty,arrayDeclDims( text() ) );//text().size()-1 );
			next();
			ty=arr;
		}else if( import_nest && cparse('&') ){
			ty=new RefType(ty);
		}else if( import_nest && cparse('*') ){
			ty=new PtrType(ty);
		}else if( cparse(T_PTR) ){
			ty=new PtrType( ty );
		}else{
			break;
		}
	}
	return ty;
}

RefType *Parser::parseRefType(){
	Type *ty=parseType();
	if( ty->cstringType() || ty->wstringType() ) fail( "Illegal variable type" );
	return new RefType( ty );
}

Exp *Parser::parseCastExp( Type *ty ){
	for(;;){
		if( curr()==T_ARRAYDECL ){
			ty=new ArrayType( new RefType( ty ),arrayDeclDims( text() ) );
			next();
		}else if( cparse(T_PTR) ){
			ty=new PtrType(ty);
		}else{
			break;
		}
	}
	if( curr()=='(' ){
		return parsePostExp( new CastExp( ty,parsePriExp() ) );
	}
	return new CastExp( ty,parsePreExp() );
}

Exp *Parser::parseIdentExp(){
	string id=parseIdent();
	Type *ty=0;
	switch( curr() ){
	case '@':case '%':case '#':case '!':case '$':case ':':ty=parseBaseType();break;
	}
	return new IdentExp(id,ty);
}

ArrayExp *Parser::parseArrayExp( Type *ty ){
	parse('[');
	ArrayExp *exp=new ArrayExp(ty);
	do{
		exp->dims.push_back( parseExp() );
	}while(cparse(','));
	parse(']');
	return exp;
}

Exp *Parser::parseArrayDataExp(){
	parse('[');
	if( cparse(']') ) return new NullExp();
	ArrayDataExp *e=new ArrayDataExp();
	do{
		e->exps.push_back( parseExp() );
	}while( cparse(',') );
	parse(']');
	return e;
}

Exp *Parser::parseNewExp(){
	Type *t=0;
	switch( curr() ){
	case T_BYTE:t=Type::int8;break;
	case T_SHORT:t=Type::int16;break;
	case T_INT:t=Type::int32;break;
	case T_LONG:t=Type::int64;break;
	case T_FLOAT:t=Type::float32;break;
	case T_DOUBLE:t=Type::float64;break;
	case T_STRING:t=Type::stringObject;break;
	case T_OBJECT:t=Type::objectObject;break;
	}
	if( t ){
		next();
	}else{
		Exp *e=parsePriExp();
		if( curr()!=T_ARRAYDECL && curr()!=T_PTR && curr()!='[' ){
			return new NewExp(e);
		}
		IdentExp *id=dynamic_cast<IdentExp*>(e);
		if( !id ) fail( "Expecting element type" );
		t=new ObjectType( id->ident,block );
	}
	for(;;){
		if( curr()==T_ARRAYDECL ){
			t=new ArrayType( t,arrayDeclDims( text() ) );
			next();
		}else if( cparse(T_PTR) ){
			t=new PtrType( t );
		}else{
			break;
		}
	}
	parse('[');
	ArrayExp *exp=new ArrayExp(t);
	do{
		exp->dims.push_back( parseExp() );
	}while(cparse(','));
	parse(']');
	return exp;
}

Exp *Parser::parsePriExp(){

	int t;
	Type *ty;
	Exp *e=0,*lhs,*rhs;

	//Yuck! This extremely nasty hack allows for 'bracketless' fun invocation by statements...
	if( primary ){
		e=primary;
		primary=0;
		return e;
	}
	
	switch( int op=curr() ){
	case '(':
		next();
		e=parseExp();
		parse(')');
		return e;
	case '[':
		return parseArrayDataExp();
	case T_IDENT:
		return parseIdentExp();
	case T_INTCONST:case T_FLOATCONST:
		return new ValExp( parseLitVal() );
	case T_STRINGCONST:
		return new ValExp( new Val(parseBString()) );
	case T_TRUE:
		next();return new ValExp( new Val(1) );
	case T_FALSE:
		next();return new ValExp( new Val(0) );
	case T_PI:
		next();return new ValExp( new Val((double)PI) );
	case T_NULL:
		next();return new NullExp();
	case T_SELF:
		next();return new SelfExp();
	case T_SUPER:
		next();return new SuperExp();
	case T_NEW:
		next();return parseNewExp();
	case T_LEN:
	case T_CHR:
	case T_ASC:
	case T_INCBINPTR:
	case T_INCBINLEN:
		ty=0;
		switch( next() ){
		case '@':case '%':case '#':case '!':case '$':case ':':
			if( op!=T_VARPTR ) ty=parseBaseType();
			break;
		}
		return new IntrinsicExp( op,ty,parsePriExp() );
	case '.':
		next();return new GlobalExp( parseIdent() );
	case T_MIN:case T_MAX:
		t=curr();next();
		parse('(');lhs=parseExp();parse(',');rhs=parseExp();parse(')');
		return new ArithExp( t,lhs,rhs );
	}
	exp( "expression" );
	return 0;
}

Exp *Parser::parsePostExp( Exp *t ){
	if( !t ) t=parsePriExp();
	for(;;){
		if( cparse('.') ){
			t=new MemberExp( t,parsePriExp() );
		}else if( cparse('(') ){
			InvokeExp *i=new InvokeExp(t);
			if( !cparse(')') ){
				do{
					if( curr()==',' ) i->seq.push_back(0);
					else i->seq.push_back(parseExp());
				}while( cparse(',') );
				parse(')');
			}
			t=i;
		}else if( cparse('[') ){
			int c=curr();
			if( c==T_DOTDOT ){
				if( next()==']' ) t=new SliceExp(c,t,0,0);
				else t=new SliceExp(c,t,0,parseExp());
			}else{
				Exp *e=parseExp();
				int c=curr();
				if( c==T_DOTDOT ){
					if( next()==']' ) t=new SliceExp(c,t,e,0);
					else t=new SliceExp(c,t,e,parseExp());
				}else{
					IndexExp *i=new IndexExp(t);
					i->seq.push_back(e);
					while( cparse(',') ) i->seq.push_back(parseExp());
					t=i;
				}
			}
			parse(']');
		}else if( curr()==T_ARRAYDECL || curr()==T_PTR ){
			IdentExp *e=dynamic_cast<IdentExp*>(t);
			if( !e ) fail( "Expecting identifier" );
			ObjectType *ty=new ObjectType( e->ident,block );
			t=parseCastExp(ty);
		}else{
			return t;
		}
	}
}

Exp *Parser::parsePreExp(){
	Type *ty;
	if( primary ) return parsePostExp();
	switch( int op=curr() ){
	case T_NOT:
		next();return new NotExp( parsePreExp() );
	case '-':case '+':case '~':case T_ABS:case T_SGN:
		next();return new UnaryExp( op,parsePreExp() );
	case T_SIZEOF:
	case T_VARPTR:
		ty=0;
		switch( next() ){
		case '@':case '%':case '#':case '!':case '$':case ':':
			if( op!=T_VARPTR ) ty=parseBaseType();
			break;
		}
		return new IntrinsicExp( op,ty,parsePostExp() );
	case T_BYTE:
		next();return parseCastExp( Type::int8 );
	case T_SHORT:
		next();return parseCastExp( Type::int16 );
	case T_INT:
		next();return parseCastExp( Type::int32 );
	case T_LONG:
		next();return parseCastExp( Type::int64 );
	case T_FLOAT:
		next();return parseCastExp( Type::float32 );
	case T_DOUBLE:
		next();return parseCastExp( Type::float64 );
	case T_STRING:
		if( next()=='.' ) return parsePostExp( new ValExp(Type::stringClass) );
		return parseCastExp( Type::stringObject );
	case T_OBJECT:
		if( next()=='.' ) return parsePostExp( new ValExp(Type::objectClass) );
		return parseCastExp( Type::objectObject );
	}
	
	return parsePostExp();
}

Exp *Parser::parsePowExp(){
	Exp *t=parsePreExp();
	for(;;){
		switch( int op=curr() ){
		case '^':
			next();
			t=new ArithExp( op,t,parsePreExp() );
			break;
		default:
			return t;
		}
	}
}

Exp *Parser::parseFactExp(){
	Exp *t=parsePowExp();
	for(;;){
		switch( int op=curr() ){
		case '*':case '/':case T_MOD:
			next();
			t=new ArithExp( op,t,parsePowExp() );
			break;
		case T_SHL:case T_SHR:case T_SAR:
			next();
			t=new BitwiseExp( op,t,parsePowExp() );
			break;
		default:
			return t;
		}
	}
}

Exp *Parser::parseTermExp(){
	Exp *t=parseFactExp();
	for(;;){
		switch( int op=curr() ){
		case '+':case '-':
			next();
			t=new ArithExp( op,t,parseFactExp() );
			break;
		default:
			return t;
		}
	}
}

Exp *Parser::parseBitwiseExp(){
	Exp *t=parseTermExp();
	for(;;){
		switch( int op=curr() ){
		case '&':case '|':case '~':
			next();
			t=new BitwiseExp( op,t,parseTermExp() );
			break;
		default:
			return t;
		}
	}
}

Exp *Parser::parseCmpExp(){
	Exp *t=parseBitwiseExp();
	for(;;){
		switch( int op=curr() ){
		case T_LT:case T_EQ:case T_GT:case T_LE:case T_GE:case T_NE:
			next();
			t=new CmpExp( op,t,parseBitwiseExp() );
			break;
		default:
			return t;
		}
	}
}

Exp *Parser::parseShortCircExp(){
	Exp *t=parseCmpExp();
	for(;;){
		switch( int op=curr() ){
		case T_AND:case T_OR:
			next();
			t=new ShortCircExp( op,t,parseCmpExp() );
			break;
		default:
			return t;
		}
	}
}

Exp *Parser::parseExp(){
	Exp *e=parseShortCircExp();
	return e;
}

string Parser::parseMetaData(){
	if( !cparse('{') ) return "";
	
	string meta;
	
	while( curr()==T_IDENT ){
		string id=parseIdent(),t;
		if( cparse( T_EQ ) ){
			switch( curr() ){
			case T_INTCONST:
			case T_FLOATCONST:
			case T_STRINGCONST:
				t=text();
				next();
				break;
			default:
				fail( "Meta data must be literal constant" );
			}
		}else{
			t="1";
		}
		if( meta.size() ) meta+=" ";
		meta+=id+"="+t;
	}
	
	parse( '}' );
	return meta;
}

void Parser::addMetaData( const vector<Decl*> &decls ){
	string meta=parseMetaData();
	for( vector<Decl*>::const_iterator it=decls.begin();it!=decls.end();++it ){
		(*it)->setMetaData( meta );
	}
}

Decl *Parser::parseInitDecl( Exp **init ){
	string id=parseIdent();
	Type *ty=parseRefType();
	Exp *_init=0;
	if( cparse(T_EQ) ){
		_init=parseExp();
	}else if( cparse('[') ){
		ArrayExp *exp=new ArrayExp(ty);
		do{
			exp->dims.push_back( parseExp() );
		}while( cparse(',') );
		parse(']');
		ty=new RefType( new ArrayType(ty,exp->dims.size()) );
		_init=exp;
	}else{
		_init=new NullExp();
	}
	*init=_init;
	return new Decl( id,ty,0 );
}

void Parser::parseLocalDecls(){
	next();
	emitDebugInfo();
	
	vector<Decl*> decls;

	do{
		Exp *e;
		Decl *d=parseInitDecl( &e );
		decls.push_back( d );
		emit( new LocalDeclStm(d->ident,d->val->type,e),false );
	}while( cparse(',') );
	
	addMetaData( decls );
}

void Parser::parseGlobalDecls(){
	next();
	emitDebugInfo();
	
	vector<Decl*> decls;
	
	do{
		Exp *e;
		Decl *d=parseInitDecl( &e );
		decls.push_back( d );
		emit( new GlobalDeclStm(d->ident,d->val->type,e,pub()),false );
	}while( cparse(',') );

	addMetaData( decls );
}

void Parser::parseConstDecls(){
	next();
	
	vector<Decl*> decls;
	
	do{
		string id=parseIdent();
		Type *ty=parseType();
		if( !cparse(T_EQ) ) fail( "Constants must be initialized" );
		Decl *d=new ConstDecl( id,ty,block,parseExp() );
		decls.push_back( d );
		decl( d );
	}while( cparse(',') );
	
	addMetaData( decls );
}

void Parser::parseTypeDecl(){
	next();
	
	string id=parseIdent();
	string super_name=cparse(T_EXTENDS) ? parseClassName() : "Object";
	
	int attrs=0;
	if( cparse(T_FINAL) ){
		attrs=ClassType::FINAL;
	}else if( cparse(T_ABSTRACT) ){
		attrs=ClassType::ABSTRACT;
	}
	
	string meta=parseMetaData();
	
	if( !pub() ) attrs|=ClassType::PRIVATE;
	
	ClassType *class_type=new ClassType( super_name,block,attrs );
	
	ClassBlock *class_block=new ClassBlock( block,id,class_type );
	
	class_block->class_decl->setMetaData( meta );
	
	block=class_block;
	while( !cparse(T_ENDTYPE) ){
		source_info=toker->sourceInfo();
		switch( curr() ){
		case '\n':case ';':next();break;
		case T_FIELD:parseFieldDecls();break;
		case T_CONST:parseConstDecls();break;
		case T_GLOBAL:parseGlobalDecls();break;
		case T_METHOD:parseFunDecl( FunType::METHOD );break;
		case T_FUNCTION:parseFunDecl( 0 );break;
		default:fail( "Syntax error in user defined type declaration" );
		}
	}
	block=block->outer;
	
}

void Parser::parseFieldDecls(){
	next();

	ClassBlock *class_block=dynamic_cast<ClassBlock*>(block);
	if( !class_block ) fail( "Field declarations must appear within a Type declaration" );
	ClassType *class_type=class_block->type;

	Block *t_block=block;
	block=class_block->field_ctors;

	emitDebugInfo();
	
	vector<Decl*> decls;
	
	do{
		Exp *e;
		Decl *d=parseInitDecl( &e );
		emit( new FieldDeclStm(d->ident,d->val->type,e),false );
		class_type->fields.push_back( d );
		decls.push_back( d );
	}while( cparse(',') );

	addMetaData( decls );

	block=t_block;
}

void Parser::parseFunDecl( int attrs ){
	next();

	bool method=!!(attrs & FunType::METHOD);
	
	ClassBlock *class_block=dynamic_cast<ClassBlock*>(block);
	ClassType *class_type=class_block ? class_block->type : 0;

	if( method && !class_block ) fail( "Methods must appear within a type" );
	
	string id;
	Block *fun_block=0;

	if( cparse(T_NEW) ){
		id="New";
		if( !method ) fail( "New must be a method" );

		fun_block=class_block->ctor_new;
		if( !fun_block ) fail( "New method already defined" );

		class_block->ctor_new=0;
	}else if( cparse(T_DELETE) ){
		id="Delete";
		if( !method ) fail( "Delete must be a method" );
		
		class_block->makeDtor();
		
		fun_block=class_block->dtor_delete;
		if( !fun_block ) fail( "Delete method already defined" );
		
		class_block->dtor_delete=0;
	}else{
		id=parseIdent();
	}
	
	ExpSeq *defs=new ExpSeq();
	fun_defaults=defs;
	FunType *ty=parseType()->funType();
	fun_defaults=0;
	
	if( !ty ) fail( "Expecting function type" );
	
	if( ty->return_type->cstringType() || ty->return_type->wstringType() ) fail( "Illegal function return type" );

	int i;
	for( i=0;i<ty->args.size();++i ){
		Type *t=ty->args[i]->val->type;
		if( t->cstringType() || t->wstringType() ) fail( "Illegal function parameter type" );
	}

	bool noDebug=false;
	
	if( cparse( T_NODEBUG ) ) noDebug=true;
	
	if( cparse( T_FINAL ) ){
		if( !class_block ){
			fail( "Final cannot be used with global functions" );
		}
		attrs|=FunType::FINAL;
	}else if( cparse( T_ABSTRACT ) ){
		if( !class_block ){
			fail( "Abstract cannot be used with global functions" );
		}
		if( class_type->attrs & ClassType::FINAL ){
			fail( "Abstract methods cannot appear in final types" );
		}
		attrs|=FunType::ABSTRACT;
	}else if( method && (class_type->attrs & ClassType::FINAL) ){
		attrs|=FunType::FINAL;
	}

	if( cparse( T_NODEBUG ) ) noDebug=true;
	
	ty->attrs|=attrs;
	
	string meta=parseMetaData();
	
	if( attrs & FunType::ABSTRACT ){
		FunDecl *decl=new FunDecl(id,ty,sym("brl_blitz_NullMethodError",CG_IMPORT),block,defs);
		class_type->methods.push_back( decl );
		decl->setMetaData( meta );
		return;
	}
	
	if( !fun_block ){
		bool pub=method || class_block || this->pub();
		FunBlock *t=new FunBlock( block,id,ty,pub,defs );
		t->fun_decl->setMetaData( meta );
		fun_block=t;
	}
	
	if( noDebug ) fun_block->debug_on=false;
	
	parseStms( fun_block,method ? T_ENDMETHOD : T_ENDFUNCTION );
}

static bool isExpOp( int t ){
	switch( t ){
	case '&':case '|':case '~':
	case '+':case '-':case '*':case '/':case T_MOD:case '^':
	case T_LT:case T_GT:case T_LE:case T_GE:case T_EQ:case T_NE:
	case T_AND:case T_OR:case T_SHL:case T_SHR:case T_SAR:
		return true;
	}
	return false;
}

void Parser::parseExpStm(){

	Exp *e=parsePreExp();
	
	if( cparse(T_EQ) ){
		emit( new AssignStm(e,parseExp()),true );
		return;
	}
	
	int op=0;
	switch( curr() ){
	case T_ADDASSIGN:case T_SUBASSIGN:case T_MULASSIGN:case T_DIVASSIGN:case T_MODASSIGN:
	case T_ORASSIGN:case T_ANDASSIGN:case T_XORASSIGN:case T_SHLASSIGN:case T_SHRASSIGN:case T_SARASSIGN:
		op=curr();next();break;
	}
	if( op ){
		emit( new OpAssignStm(op,e,parseExp()),true );
		return;
	}
	
	if( dynamic_cast<NewExp*>(e) ){
		emit( new EvalStm(e),true );
		return;
	}
	
	InvokeExp *t=dynamic_cast<InvokeExp*>(e);
	bool more=false;
	
	if( !t ){
		t=new InvokeExp(e);
		more=curr()!=';' && curr()!='\n' && curr()!=EOF;
	}else if( t->seq.size()==1 ){
		if( isExpOp(curr()) ){
			primary=t->seq[0];
			t->seq[0]=parseExp();
		}
		more=cparse(',');
	}
	if( more ){
		do{
			if( curr()==',' ) t->seq.push_back(0);
			else t->seq.push_back( parseExp() );
		}while( cparse(',') );
	}
	emit( new EvalStm(t),true );
}

void Parser::parseIfStm( int t_term ){
	source_info=toker->sourceInfo();
	next();

	Exp *e=parseExp();
	cparse( T_THEN );
	
	int term=t_term ? t_term : (curr()=='\n' ? T_ENDIF : '\n');

	IfStm *stm=new IfStm( e,0,0 );
	emit( stm,true );

	int t;
	block=stm->then_block=new Block( block );
	for(;;){
		t=curr();
		if( t==term || t==T_ELSE || t==T_ELSEIF ) break;
		parseStm();
	}
	block=block->outer;

	if( t!=term ){
		block=stm->else_block=new Block( block );
		if( t==T_ELSE ){
			if( next()==T_IF ){
				parseIfStm( term );
			}else{
				while( curr()!=term ) parseStm();
			}
		}else{
			//t==T_ELSEIF
			parseIfStm( term );
		}
		block=block->outer;
	}

	if( !t_term && term==T_ENDIF ) next();
}

void Parser::parseLoopCtrlStm(){
	int toke=curr();
	string lab;
	if( next()==T_IDENT ) lab=parseIdent();
	emit( new LoopCtrlStm( toke,lab ),true );
}

void Parser::parseForStm(){
	next();
	
	LoopBlock *loop_block=new LoopBlock( block,loopLabel );
	loopLabel="";
	
	Exp *var;
	if( cparse(T_LOCAL) ){
		string id=parseIdent();
		Type *ty=parseRefType();
		var=new LocalDeclExp( id,ty,loop_block );
	}else{
		var=parsePostExp();
	}
	if( !cparse(T_EQ) ) exp( "assignment" );
	
	if( cparse(T_EACHIN) ){
		Exp *coll=parseExp();
		emit( new ForEachStm( var,coll,loop_block ),true );
		parseStms( loop_block,T_NEXT );
		return;
	}

	Exp *init=parseExp();
	bool until;
	if( cparse(T_TO) ) until=false;
	else if( cparse(T_UNTIL) ) until=true;
	else fail( "Expecting 'To' or 'Until'" );
	Exp *to=parseExp();
	Exp *step=cparse(T_STEP) ? parseExp() : 0;
	emit( new ForStm( var,init,to,step,loop_block,until ),true );
	parseStms( loop_block,T_NEXT );
}

void Parser::parseWhileStm(){
	next();

	LoopBlock *loop_block=new LoopBlock( block,loopLabel );
	loopLabel="";

	emit( new WhileStm( parseExp(),loop_block),true );

	parseStms( loop_block,T_WEND );
}

void Parser::parseRepeatStm(){
	next();

	LoopBlock *loop_block=new LoopBlock( block,loopLabel );
	loopLabel="";

	block=loop_block;
	while( curr()!=T_UNTIL && curr()!=T_FOREVER ){
		parseStm();
	}
	source_info=toker->sourceInfo();
	int c=curr();next();
	block=block->outer;

	Exp *e=(c==T_UNTIL) ? parseExp() : 0;

	emit( new RepeatStm(e,loop_block),true );
}

void Parser::parseTryStm(){
	next();
	
	TryStm *try_stm=new TryStm( new Block(block) );
	emit( try_stm,true );
	
	block=try_stm->block;
	while( curr()!=T_CATCH && curr()!=T_ENDTRY ){
		parseStm();
	}
	block=block->outer;
	
	while( cparse(T_CATCH) ){
		TryCatch *t=new TryCatch( new Block(block) );
		try_stm->catches.push_back( t );
		
		t->ident=parseIdent();
		t->type=parseType();
		
		block=t->block;
		while( curr()!=T_CATCH && curr()!=T_ENDTRY ){
			parseStm();
		}
		block=block->outer;
	}
	parse( T_ENDTRY );
}

void Parser::parseThrowStm(){
	next();
	emit( new ThrowStm(parseExp()),true );
}

void Parser::parseSelectStm(){
	next();

	SelectStm *sel=new SelectStm( parseExp() );
	emit( sel,true );

	while( cparse('\n') ){}
	
	source_info=toker->sourceInfo();
	while( cparse(T_CASE) ){
		SelCase *t_case=new SelCase( new Block( block ) );
		t_case->source_info=source_info;
		sel->cases.push_back( t_case );

		do{
			t_case->exps.push_back( parseExp() );
		}while( cparse(',') );
		
		block=t_case->block;
		while( curr()!=T_CASE && curr()!=T__DEFAULT && curr()!=T_ENDSELECT ){
			parseStm();
		}
		source_info=toker->sourceInfo();
		block=block->outer;
	}
	
	if( cparse(T__DEFAULT) ){
		sel->_default=new Block( block );

		block=sel->_default;
		while( curr()!=T_ENDSELECT ){
			parseStm();
		}
		block=block->outer;
	}

	parse( T_ENDSELECT );
}

void Parser::parseReturnStm(){
	next();
	Exp *exp=0;
	if( curr()!=';' && curr()!='\n' && curr()!=EOF ) exp=parseExp();
	emit( new ReturnStm(exp),true );
}

void Parser::parseDeleteStm(){
	next();
	Exp *exp=parseExp();
	emit( new DeleteStm(exp),true );
}

void Parser::parseAccess(){
	switch( curr() ){
	case T_PUBLIC:pub_=true;break;
	case T_PRIVATE:pub_=false;break;
	default:assert(0);
	}
	next();
}

void Parser::parseLabelStm(){
	next();
	string id=parseIdent();
	if( strictMode ){
		while( cparse('\n') ){}
		switch( curr() ){
		case T_FOR:case T_WHILE:case T_REPEAT:case T_DEFDATA:
			break;
		default:
			fail( "Labels must appear before a loop or DefData statement" );
		}
		if( curr()!=T_DEFDATA ){
			loopLabel=id;
			return;
		}
	}
	if( block->fun_block->labels.count(id) ) fail( "Duplicate label '%s'",id.c_str() );
	CGSym *goto_sym=CG::sym();
	CGSym *restore_sym=CG::sym();
	LabelStm *stm=new LabelStm(goto_sym,restore_sym);
	block->fun_block->labels.insert( make_pair(tolower(id),stm) );
	emit( stm,true );
}

void Parser::parseGotoStm(){
	next();
	emit( new GotoStm( parseIdent() ),true );
}

void Parser::parseAssertStm(){
	next();
	Exp *e=parseExp(),*m;
	if( cparse(',') || cparse(T_ELSE) ) m=parseExp();
	else m=new ValExp( new Val(tobstring("Assert failed")) );
	emit( new AssertStm(e,m),true );
}

void Parser::includeFile( string file ){

	file=realpath(file);

	Toker *t=toker;
	toker=new Toker( file );
	
	string cd=getcwd();
	setcwd( getdir(file) );
	
	while( curr()!=EOF ){
		parseStm();
	}
	setcwd( cd );
	toker=t;
}

void Parser::parseDataStm(){
	next();
	DataStm *t=new DataStm();
	emit( t,false );
	do{
		t->exps.push_back( parseExp() );
	}while( cparse(',') );
}

void Parser::parseReadStm(){
	next();
	ReadStm *t=new ReadStm();
	emit( t,true );
	do{
		t->exps.push_back( parseExp() );
	}while( cparse(',') );
}

void Parser::parseRestoreStm(){
	next();
	emit( new RestoreStm( parseIdent() ),true );
}

void Parser::parseStm(){
	source_info=toker->sourceInfo();

	switch( curr() ){
	case ';':
	case '\n':
		next();
		break;
	case '#':
		parseLabelStm();
		break;
	case T_DEFDATA:
		parseDataStm();
		break;
	case T_READDATA:
		parseReadStm();
		break;
	case T_RESTOREDATA:
		parseRestoreStm();
		break;
	case T_GOTO:
		parseGotoStm();
		break;
	case T_TRY:
		parseTryStm();
		break;
	case T_THROW:
		parseThrowStm();
		break;
	case T_IF:
	//case T_ELSEIF:
		parseIfStm(0);
		break;
	case T_GLOBAL:
		parseGlobalDecls();
		break;
	case T_FUNCTION:
		parseFunDecl( 0 );
		break;
	case T_EXIT:case T_CONTINUE:
		parseLoopCtrlStm();
		break;
	case T_FOR:
		parseForStm();
		break;
	case T_WHILE:
		parseWhileStm();
		break;
	case T_REPEAT:
		parseRepeatStm();
		break;
	case T_SELECT:
		parseSelectStm();
		break;
	case T_RETURN:
		parseReturnStm();
		break;
	case T_ASSERT:
		parseAssertStm();
		break;
	case T_END:
		next();emit( new EndStm(),true );
		break;
	case T_RELEASE:
		next();emit( new ReleaseStm( parseExp() ),true );
		break;
	case T_LOCAL:
		parseLocalDecls();
		break;
	case T_CONST:
		parseConstDecls();
		break;
	case T_TYPE:
		parseTypeDecl();
		break;
	case T_INCLUDE:
		next();includeFile( parseString() );
		break;
	case T_INCBIN:
		next();emit( new IncbinStm( parseString() ),false );
		break;
	case T_EXTERN:
		parseExtern();
		break;
	case T_PUBLIC:case T_PRIVATE:
		parseAccess();
		break;
	case T_MODULE:case T_MODULEINFO:case T_IMPORT:case T_STRICT:
		fail( "'%s' must appear at top of file",toker->text().c_str() );
	case T_FIELD:
		fail( "Field declaration outside of user defined type" );
	case T_METHOD:
		fail( "Method declaration outside of user defined type" );
	case T_ELSE:
		fail( "'Else' without matching 'If'" );
	case T_ENDIF:
		fail( "'%s' without matching 'If'",toker->text().c_str() );
	case T_NEXT:
		fail( "'Next' without matching 'For'" );
	case T_WEND:
		fail( "'%s' without matching 'While'",toker->text().c_str() );
	case T_UNTIL:
		fail( "'Until' without matching 'Repeat'" );
	case T_FOREVER:
		fail( "'Forever' without matching 'Repeat'" );
	case T_CASE:
		fail( "'Case' without matching 'Select'" );
	case T__DEFAULT:
		fail( "'Default' without matching 'Select'" );
	case T_CATCH:
		fail( "'Catch' without matching 'Try'" );
	case T_ENDTRY:
		fail( "'%s' without matching 'Try'",toker->text().c_str() );
	case T_ENDTYPE:
		fail( "'%s' without matching 'Type'",toker->text().c_str() );
	case T_ENDEXTERN:
		fail( "'%s' without matching 'Extern'",toker->text().c_str() );
	case T_ENDMETHOD:
		fail( "'%s' without matching 'Method'",toker->text().c_str() );
	case T_ENDFUNCTION:
		fail( "'%s' without matching 'Function'",toker->text().c_str() );
	case T_ENDSELECT:
		fail( "'%s' without matching 'Select'",toker->text().c_str() );
	default:
		parseExpStm();
	}
}

void Parser::parseStms( Block *t,int term ){

	Block *t_block=block;
	block=t;
	
	while( curr()!=term ){
		parseStm();
	}

	next();
	block=t_block;
}

void Parser::importFile( string file,ModuleType *mod ){

	Toker *t=toker;
	toker=new Toker( file );
	ModuleType *m=import_module;
	import_module=mod;
	
	++import_nest;

	while( curr()!=EOF ){
		source_info=toker->sourceInfo();
		if( cparse(';') ){
		}else if( cparse('\n') ){
		}else if( cparse( T_IMPORT ) ){
			parseImport();
		}else if( cparse( T_MODULEINFO ) ){
			parseString();
		}else{
			Decl *d=parseImportDecl();
			if( import_module ){
				import_module->decls.push_back(d);
			}else{
				mainFun->decl(d);
				moduleExports.push_back(d);
			}
		}
	}
	
	--import_nest;

	toker->close();
	import_module=m;
	toker=t;
}

void Parser::importModule( string mod ){

	string mung="@"+mod;
	if( rootScope.find(mung) ) return;
	
	vector<string> ids;
	splitModule( mod,ids );
	
	ModuleType *mod_ty;
	DeclSeq *decls=&mainFun->decls;
	
	int k;
	for( k=0;k<ids.size();++k ){
		string id=ids[k];
		if( Val *v=decls->find(id) ){
			mod_ty=v->type->moduleType();
			if( !mod_ty ) fail( "Unable to import module '%s'",mod.c_str() );
		}else{
			mod_ty=new ModuleType();
			decls->push_back( new Decl(id,mod_ty,lit0) );
		}
		decls=&mod_ty->decls;
	}

	rootScope.push_back( new Decl(mung,mod_ty,lit0) );

	importFile( moduleInterface(mod),mod_ty );
	
	if( !import_module ){
		string t="import "+mod;
		if( !import_nest ){
			objectImports.push_back(t);
			emit( new ImportStm(sym(mungModuleEntry(mod),CG_IMPORT)),false );
		}
		moduleImports.push_back(t);
	}
}

void Parser::importSource( string file ){

	string ext=tolower(getext(file)),path=realpath(file);

	if( ext=="bmx" ){
		if( !importedSources.insert( tolower(path) ).second ) return;
		
		if( !ftime(path) ) fail( "File '%s' not found",path.c_str() );
		
		string cd=getcwd();
		setcwd( getdir(path) );
		
		importFile( ".bmx/"+stripdir(path)+config_mung+".i",0 );
		
		setcwd( cd );
		
		if( !import_nest ){
			string t="import \""+file+'\"';
			objectImports.push_back( t );
			emit( new ImportStm( sym(mungObjectEntry(file),CG_IMPORT) ),false );
		}
	}else  if( ext=="o" || ext=="a" || ext=="lib" ){

		if( !import_module ){

			if( !ftime(path) ) fail( "File '%s' not found",path.c_str() );
		
			string t="import \""+file+'\"';
			if( !import_nest ) objectImports.push_back( t );
			moduleImports.push_back(t);
		}
	}else if( ext=="c" || ext=="m" || ext=="cpp" || ext=="cxx" || ext=="cc" || ext=="mm" || ext=="s" || ext=="asm" ){
	
		if( !ftime(path) ) fail( "File '%s' not found",path.c_str() );

	}else{
	
		fail( "Unrecognized import file type for import '%s'",path.c_str() );
	}
}

void Parser::parseImport(){
	if( curr()==T_IDENT ){
		importModule( parseModuleName() );
	}else if( curr()==T_STRINGCONST ){
		string file=parseString();
		if( stripall(file)=="*" ){
		}else if( file[0]=='-' ){
			if( !import_module ){
				string t="import \""+file+'\"';
				if( !import_nest ) objectImports.push_back( t );
				moduleImports.push_back(t);
			}
			return;
		}else{
			importSource( file );
		}
	}else{
		fail( "Expecting module name or import file" );
	}
}

Parser::Parser(){
}

void Parser::parse(){

	pub_=true;
	primary=0;
	fun_defaults=0;
	default_call_conv=CG_CDECL;
	import_nest=0;
	extern_nest=0;
	import_module=0;
	
	Type::createTypes();

	setcwd( getdir(opt_infile) );
	toker=new Toker( opt_infile );
	mainFun=new FunBlock();
	block=mainFun;
	
	ModuleType *mod_ty=new ModuleType();
	mainFun->decls.push_back( new Decl("brl",mod_ty,lit0) );
	mod_ty->decls.push_back( new Decl("blitz",Type::blitzModule,lit0) );

	importFile( env_blitzpath+"/mod/brl.mod/blitz.mod/blitz_classes.i",Type::blitzModule );

	*Type::objectClass=*Type::blitzModule->find("Object");
	*Type::stringClass=*Type::blitzModule->find("String");
	*Type::arrayClass=*Type::blitzModule->find("Array");
	
	if( opt_module=="brl.blitz" ){
		if( stripall(opt_infile)=="blitz" ){
			rootScope.push_back( new Decl("@brl.blitz",Type::blitzModule,lit0) );
		}
	}else{
		importModule( "brl.blitz" );
	}

	//if( stripall(opt_infile)!="blitz" ) importModule( "brl.blitz" );
	//else rootScope.push_back( new Decl("@brl.blitz",Type::blitzModule,lit0) );

	while( curr()!=EOF ){
		source_info=toker->sourceInfo();
		if( cparse('\n') ){
		}else if( cparse( T_STRICT ) ){
			if( strictMode ) fail( "Strict or SuperStrict already specified" );
			strictMode=1;
		}else if( cparse( T_SUPERSTRICT ) ){
			if( strictMode ) fail( "Strict or SuperStrict already specified" );
			strictMode=2;
		}else if( cparse( T_NODEBUG ) ){
			opt_debug=false;
			opt_release=true;
			block->debug_on=false;
		}else if( cparse( T_MODULE ) ){
			string name=parseModuleName();
			if( name!=opt_module ) fail( "Module does not match commandline module" );
			if( opt_apptype.size() ) fail( "Modules cannot be built as applications" );
		}else if( cparse( T_MODULEINFO ) ){
			if( !opt_module.size() ) fail( "ModuleInfo can only be used with modules" );
			moduleInfos.push_back( parseString() );
		}else if( cparse( T_FRAMEWORK ) ){
			string framework=parseModuleName();
			if( opt_framework.size() && opt_framework!=framework ) fail( "Framework does not match commandline framework" );
			opt_framework=framework;
		}else if( cparse( T_IMPORT ) ){
			parseImport();
		}else{
			break;
		}
	}

	if( opt_module.size() ){
	}else if( opt_framework.size() ){
		importModule( opt_framework );
	}else{
		vector<string> mods;
		enumModules( "",mods );
		for( int k=0;k<mods.size();++k ){
			if( mods[k].find( "brl." )==0 || mods[k].find( "pub." )==0 ){
				importModule( mods[k] );
			}
		}
	}

	emit( new EvalClassBlocksStm(),false );
	
	while( curr()!=EOF ){
		parseStm();
	}
	
	toker->close();
}
