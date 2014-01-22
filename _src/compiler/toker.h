
#ifndef TOKER_H
#define TOKER_H

struct Toke{
	int		toke;
	int		begin,end;
	
	Toke():toke(0),begin(0),end(0){}
	Toke( int n,int b,int e ):toke(n),begin(b),end(e){}
};

struct Toker{
	FILE*   fh;

	enum{
		UNK=0,LATIN1=1,UTF8=2,UTF16BE=3,UTF16LE=4
	};
	Toke	curr_toke;
	int		toke_index;
	int		encoding;
	vector<char>	line;
	vector<bchar_t> wline;
	vector<Toke>	tokes;
	
	int		line_num;
	string  file_name;
	
	Toker( string file );
	void	close();
	
	int		curr();
	int		next();
	string  text();
	bstring wtext();
	int		peek( int n );
	void	nextLine();
	int		tgetc();
	
	string  sourceFile();
	string  sourceInfo();
	
	static  string toString( int n  );
};

enum{
	T_NOP=0x80000000,

	//non-ident
	T_DOTDOT,
	
	T_ARRAYDECL,
	
	T_LT,T_EQ,T_GT,T_LE,T_GE,T_NE,
	
	T_IDENT,T_INTCONST,T_FLOATCONST,T_STRINGCONST,T_BADSTRINGCONST,T_CSTRING,T_WSTRING,
	
	//ident
	T_STRICT,T_SUPERSTRICT,T_MODULE,T_FRAMEWORK,T_IMPORT,T_MODULEINFO,
	
	T_DEFDATA,T_READDATA,T_RESTOREDATA,
	
	T_REM,T_ENDREM,
	
	T_TRY,T_CATCH,T_ENDTRY,T_THROW,T_GOTO,
	
	T_TRUE,T_FALSE,T_PI,

	T_BYTE,T_SHORT,T_INT,T_LONG,T_FLOAT,T_DOUBLE,T_OBJECT,T_STRING,
	
	T_VAR,T_PTR,T_VARPTR,
	
	T_CHR,
	T_LEN,T_ASC,T_SIZEOF,
	
	T_SGN,
	T_ABS,T_MIN,T_MAX,T_MOD,
	T_SHL,T_SHR,T_SAR,
	T_NOT,T_AND,T_OR,
	
	T_ADDASSIGN,T_SUBASSIGN,T_MULASSIGN,T_DIVASSIGN,T_MODASSIGN,
	T_ORASSIGN,T_ANDASSIGN,T_XORASSIGN,T_SHLASSIGN,T_SHRASSIGN,T_SARASSIGN,

	T_RETURN,T_LOCAL,T_GLOBAL,T_CONST,T_FIELD,T_ALIAS,T_END,

	T_TYPE,T_ENDTYPE,T_EXTENDS,

	T_METHOD,T_ENDMETHOD,T_ABSTRACT,T_FINAL,

	T_FUNCTION,T_ENDFUNCTION,

	T_NEW,T_RELEASE,T_DELETE,

	T_NULL,T_SELF,T_SUPER,

	T_INCBIN,T_INCBINPTR,T_INCBINLEN,
	
	T_INCLUDE,T_EXTERN,T_ENDEXTERN,

	T_PUBLIC,T_PRIVATE,

	T_IF,T_THEN,T_ELSE,T_ELSEIF,T_ENDIF,

	T_FOR,T_TO,T_STEP,T_NEXT,T_EACHIN,

	T_WHILE,T_WEND,

	T_REPEAT,T_UNTIL,T_FOREVER,

	T_SELECT,T_CASE,T__DEFAULT,T_ENDSELECT,

	T_EXIT,T_CONTINUE,

	T_ASSERT,
	
	T_NODEBUG
};

#endif
