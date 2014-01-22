
#ifndef TYPE_H
#define TYPE_H

#include "scope.h"
#include "declseq.h"

struct Val;

/*

Runtime type Encoding:

b=byte
s=short
i=int
f=float
d=double
z=cstring
$=string
[]<type>=array
^<ident>.<ident>=class
:<ident>.<ident>=object
(<type>,...)<type>=function
*<type>=pointer

*/

struct NumericType;
struct IntType;
struct FloatType;
struct StringType;
struct CStringType;
struct WStringType;
struct ArrayType;
struct ClassType;
struct ObjectType;
struct FunType;
struct PtrType;
struct VarType;
struct RefType;
struct NullType;
struct ModuleType;

struct Type : public Scope{
	virtual ~Type();
	
	virtual NumericType*numericType();
	virtual IntType*	intType();
	virtual FloatType*	floatType();
	virtual StringType*	stringType();
	virtual CStringType*cstringType();
	virtual WStringType*wstringType();
	virtual ClassType*	classType();
	virtual ObjectType*	objectType();
	virtual ObjectType*	exObjectType();
	virtual ArrayType*	arrayType();
	virtual FunType*	funType();

	virtual PtrType*	ptrType();
	virtual VarType*	varType();
	virtual RefType*	refType();
	virtual NullType*	nullType();
	virtual ModuleType* moduleType();
	
	virtual string		encoding();
	virtual string		toString();
	virtual bool		equals( Type *ty );
	virtual bool		extends( Type *ty );

	int					size();
	int					cgType();
	PtrType*			ptrType( string valEncoding );

	static void			createTypes();
	static void			resolveTypes();

	static IntType		*int8,*int16,*int32,*int64;
	static FloatType	*float32,*float64;
	static CStringType  *c_string;
	static WStringType  *w_string;
	static PtrType		*bytePtr;
	static NullType		*null;
	static ModuleType   *blitzModule;
	static ObjectType   *objectObject;
	static StringType   *stringObject;
	static Val			*objectClass,*stringClass,*arrayClass;
};

struct NumericType : public Type{
	string _encoding;

	NumericType( int sz,bool fp );

	NumericType *numericType();

	string  encoding();
	string	toString();
	bool	equals( Type *ty );
};

struct IntType : public NumericType{
	IntType( int sz ):NumericType( sz,false ){}

	IntType *intType();
};

struct FloatType : public NumericType{
	FloatType( int sz ):NumericType( sz,true ){}

	FloatType *floatType();
};

struct CStringType : public Type{
	CStringType *cstringType();

	string  encoding();
	string	toString();
	bool	equals( Type *ty );
};

struct WStringType : public Type{
	WStringType *wstringType();

	string  encoding();
	string	toString();
	bool	equals( Type *ty );
};

struct ClassType : public Type{
	enum{
		ABSTRACT=1,FINAL=2,EXTERN=4,PRIVATE=8
	};
	
	string  super_name;
	Scope*  scope;
	DeclSeq decls,fields,methods;
	int		attrs,sizeof_fields,sizeof_vtable;
	
	ClassType( string supername,Scope *sc,int attrs=0 );

	ClassType*classType();
	
	string  encoding();
	string	toString();
	bool	equals( Type *ty );
	bool	extends( Type *ty );
	Val*	find( string id );

	Val*	findMethod( string id );
	Val*	findSuperMethod( string id );
	
	void	resolve();
	
	Val*	superVal();
	
	ClassType*superClass();
	
private:
	int		resolved;
	Val*	super_val;
	ClassType*super_class;
	string  sourceinfo;
};

struct ObjectType : public Type{
	string ident;
	Scope *scope;
	Val *class_val;
	string sourceinfo;

	ObjectType( Val *clas );
	ObjectType( string id,Scope *sc );

	ObjectType *objectType();
	ObjectType *exObjectType();

	void	resolve();
	string  encoding();
	string	toString();
	bool	equals( Type *ty );
	bool	extends( Type *ty );
	Val*	find( string id );

	Val*	classVal();
	ClassType *objectClass();
};

struct StringType : public ObjectType{

	StringType( Val *clas );
	
	StringType *stringType();

	string  encoding();
	string	toString();
	bool	equals( Type *ty );
};

struct ArrayType : public ObjectType{
	Type *element_type;
	int dims;

	ArrayType( Type *ty,int n );

	ArrayType *arrayType();

	string  encoding();
	string	toString();
	bool	equals( Type *ty );
	bool	extends( Type *ty );
};

struct FunType : public Type{
	enum{
		ABSTRACT=1,FINAL=2,METHOD=4,VOIDFUN=8
	};
	DeclSeq args;
	Type *return_type;
	int attrs,call_conv;

	FunType( Type *ty,int at=0 );
	
	FunType *funType();

	string  encoding();
	string	toString();
	bool	equals( Type *ty );
	bool	extends( Type *ty );
	bool	method();
};

struct PtrType : public Type{
	Type *val_type;
	string sourceinfo;

	PtrType( Type *ty );

	PtrType *ptrType();

	void	resolve();

	string  encoding();
	string	toString();
	bool	equals( Type *ty );
};

struct VarType : public Type{
	Type *val_type;

	VarType( Type *ty ):val_type(ty){}

	VarType *varType();

	string  encoding();
	string	toString();
	bool	equals( Type *ty );
};

struct AliasType : public Type{
	Type *val_type;

	AliasType( Type *ty );

	NumericType*numericType();
	IntType*	intType();
	FloatType*	floatType();
	StringType*	stringType();
	ClassType*	classType();
	ObjectType*	objectType();
	ObjectType*	exObjectType();
	ArrayType*	arrayType();
	FunType*	funType();
	PtrType*	ptrType();
	ModuleType* moduleType();

	string		encoding();
	string		toString();
	bool		equals( Type *ty );
	bool		extends( Type *ty );
	Val*		find( string id );
};

struct RefType : public AliasType{
	enum{
		VARPARAM=1
	};
	int	 attrs;

	RefType( Type *ty,int at=0 ):AliasType(ty),attrs(at){}

	RefType*	refType();
};

struct NullType : public Type{

	NullType	*nullType();

	string		toString();
	bool		equals( Type *ty );
};

struct ModuleType : public Type{
	DeclSeq		decls;
	
	ModuleType* moduleType();

	string		toString();
	bool		equals( Type *ty );
	Val*		find( string id );
};

#endif
