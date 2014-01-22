
#include "std.h"
#include "decl.h"

using namespace CG;

static vector<ClassType*> _classTypes;
static vector<ObjectType*> _objectTypes;
static vector<PtrType*> _ptrTypes;

IntType *Type::int8;
IntType *Type::int16;
IntType *Type::int32;
IntType *Type::int64;
FloatType *Type::float32;
FloatType *Type::float64;
CStringType *Type::c_string;
WStringType *Type::w_string;
PtrType *Type::bytePtr;
NullType *Type::null;
ModuleType *Type::blitzModule;
ObjectType *Type::objectObject;
StringType *Type::stringObject;
Val *Type::objectClass,*Type::stringClass,*Type::arrayClass;

void Type::createTypes(){
	
	int8=new IntType(1);
	int16=new IntType(2);
	int32=new IntType(4);
	int64=new IntType(8);
	float32=new FloatType(4);
	float64=new FloatType(8);
	c_string=new CStringType();
	w_string=new WStringType();
	bytePtr=new PtrType(new IntType(1));
	null=new NullType();
	
	objectClass=new Val((Type*)0,(CGExp*)0);
	objectObject=new ObjectType(0);
	objectObject->ident="Object";
	objectObject->class_val=objectClass;

	stringClass=new Val((Type*)0,(CGExp*)0);
	stringObject=new StringType(0);
	stringObject->ident="String";
	stringObject->class_val=stringClass;

	arrayClass=new Val((Type*)0,(CGExp*)0);

	blitzModule=new ModuleType();
}

void Type::resolveTypes(){
	int k;
	for( k=0;k<_classTypes.size();++k ) _classTypes[k]->resolve();
	for( k=0;k<_objectTypes.size();++k ) _objectTypes[k]->resolve();
	for( k=0;k<_ptrTypes.size();++k ) _ptrTypes[k]->resolve();
}

//********************* Type **********************
Type::~Type(){
}
NumericType *Type::numericType(){
	return 0;
}
IntType *Type::intType(){
	return 0;
}
FloatType *Type::floatType(){
	return 0;
}
StringType *Type::stringType(){
	return 0;
}
CStringType *Type::cstringType(){
	return 0;
}
WStringType *Type::wstringType(){
	return 0;
}
ArrayType *Type::arrayType(){
	return 0;
}
ClassType *Type::classType(){
	return 0;
}
ObjectType *Type::objectType(){
	return 0;
}
ObjectType *Type::exObjectType(){
	return 0;
}
FunType *Type::funType(){
	return 0;
}
PtrType *Type::ptrType(){
	return 0;
}
VarType *Type::varType(){
	return 0;
}
RefType *Type::refType(){
	return 0;
}
NullType *Type::nullType(){
	return 0;
}
ModuleType *Type::moduleType(){
	return 0;
}
string Type::encoding(){
	return "?";
}
string Type::toString(){
	return "<void>";
}
bool Type::equals( Type *ty ){
	return false;
}
bool Type::extends( Type *ty ){
	return equals(ty);
}
int Type::size(){
	switch( cgType() ){
	case CG_VOID:return 0;
	case CG_INT8:return 1;
	case CG_INT16:return 2;
	case CG_INT32:return 4;
	case CG_INT64:return 8;
	case CG_FLOAT32:return 4;
	case CG_FLOAT64:return 8;
	case CG_PTR:return 4;
	}
	assert(0);
	return 0;
}
int Type::cgType(){
	switch( encoding()[0] ){
	case '?':return CG_VOID;
	case 'b':return CG_INT8;
	case 's':return CG_INT16;
	case 'i':return CG_INT32;
	case 'l':return CG_INT64;
	case 'f':return CG_FLOAT32;
	case 'd':return CG_FLOAT64;
	}
	return CG_PTR;
}
PtrType *Type::ptrType( string valEncoding ){
	PtrType *p=ptrType();
	return (p && p->val_type->encoding()==valEncoding) ? p : 0;
}

//****************** NumericType ******************
NumericType::NumericType( int sz,bool fp ){
	switch( sz ){
	case 1:assert(!fp);_encoding="b";break;
	case 2:assert(!fp);_encoding="s";break;
	case 4:_encoding=fp ? "f" : "i";break;
	case 8:_encoding=fp ? "d" : "l";break;
	default:assert(0);
	}
}

NumericType *NumericType::numericType(){
	return this;
}

string NumericType::encoding(){
	return _encoding;
}

string NumericType::toString(){
	switch( encoding()[0] ){
	case 'b':return "Byte";
	case 's':return "Short";
	case 'i':return "Int";
	case 'l':return "Long";
	case 'f':return "Float";
	case 'd':return "Double";
	default:assert(0);
	}
	return "";
}

bool NumericType::equals( Type *ty ){
	NumericType *t=ty->numericType();
	return t && encoding()==t->encoding();
}

//******************** IntType ********************
IntType *IntType::intType(){
	return this;
}

//******************* FloatType *******************
FloatType *FloatType::floatType(){
	return this;
}

//***************** CStringType *******************
CStringType *CStringType::cstringType(){
	return this;
}

string CStringType::encoding(){
	return "z";
}

string CStringType::toString(){
	return "CString";
}

bool CStringType::equals( Type *ty ){
	return ty->cstringType() ? true : false;
}

//***************** WStringType *******************
WStringType *WStringType::wstringType(){
	return this;
}

string WStringType::encoding(){
	return "w";
}

string WStringType::toString(){
	return "WString";
}

bool WStringType::equals( Type *ty ){
	return ty->wstringType() ? true : false;
}

//******************* StringType ******************
StringType::StringType( Val *clas ):ObjectType(clas){
}

StringType *StringType::stringType(){
	return this;
}

string StringType::encoding(){
	return "$";
}

string StringType::toString(){
	return "String";
}

bool StringType::equals( Type *ty ){
	return ty->stringType() ? true : false;
}

//****************** ArrayType ********************
ArrayType::ArrayType( Type *ty,int n ):ObjectType(arrayClass),element_type(ty),dims(n){
}

ArrayType *ArrayType::arrayType(){
	return this;
}

string ArrayType::encoding(){
	return "["+string(dims-1,',')+"]"+element_type->encoding();
}

string ArrayType::toString(){
	return element_type->toString()+" Array";
}

bool ArrayType::equals( Type *ty ){
	ArrayType *t=ty->arrayType();
	return t && dims==t->dims && element_type->equals(t->element_type);
}

bool ArrayType::extends( Type *ty ){
	ArrayType *t=ty->arrayType();
	if( !t ) return ObjectType::extends( ty );
	return t && dims==t->dims && element_type->extends(t->element_type);
}

//****************** ClassType ********************
ClassType::ClassType( string supername,Scope *sc,int attrs ):
super_name(supername),scope(sc),attrs(attrs),
sizeof_fields(0),sizeof_vtable(0),super_val(0),super_class(0),resolved(0){
	sourceinfo=source_info;
	_classTypes.push_back(this);
}

void ClassType::resolve(){
	if( resolved==1 ) return;
	source_info=sourceinfo;
	if( resolved==-1 ) fail( "Cyclic type dependancy" );
	resolved=-1;
	
	//resolve super
	if( super_name.size() ){
		if( super_val=scope->findTypeIdent( super_name ) ){
			super_class=super_val->type->classType();
		}
		if( !super_class ) badty( super_name );
		super_class->resolve();
		if( super_class->attrs & ClassType::FINAL ) fail( "Final types cannot be extended" );
		if( (attrs & ClassType::EXTERN) && !(super_class->attrs & ClassType::EXTERN) ) fail( "Extern types can only extends other extern types" );
		if( (super_class->attrs & ClassType::EXTERN) && !(attrs & ClassType::EXTERN) ) fail( "Extern types can only be extended by other extern types" );
		sizeof_fields=super_class->sizeof_fields;
		sizeof_vtable=super_class->sizeof_vtable;
	}else if( attrs & EXTERN ){
		sizeof_fields=4;
		sizeof_vtable=0;
	}else{
		sizeof_fields=8;
		sizeof_vtable=16;
	}
	
	//resolve fields
	int k;
	for( k=0;k<fields.size();++k ){
		Decl *d=fields[k];
		Type *type=d->val->type;

		int sz=type->size();
		sizeof_fields=(sizeof_fields+sz-1)/sz*sz;
		
		CGExp *e=mem( type->cgType(),tmp(CG_PTR,"@self"),sizeof_fields );
		
		Decl *t=new Decl( d->ident,type,e );
		t->setMetaData( d->meta );
		
		decls.push_back( t );
		sizeof_fields+=sz;
	}
	
	//resolve methods
	for( k=0;k<methods.size();++k ){
		Decl *d=methods[k];
		FunType *type=d->val->type->funType();
		
		CGExp *e;
		Val *v=findSuperMethod(d->ident);
		
		if( (attrs & FINAL) || (type->attrs & FunType::FINAL) ){
			e=d->val->cg_exp;
			if( type->method() ) e=vfn( e,tmp(CG_PTR,"@self") );
			if( !v ) sizeof_vtable+=4;
		}else if( v ){
			e=v->cg_exp;
		}else{
			e=mem( CG_PTR,tmp(CG_PTR,"@type"),sizeof_vtable );
			if( type->method() ) e=vfn( e,tmp(CG_PTR,"@self") );
			sizeof_vtable+=4;
		}
		
		Decl *t=new Decl( d->ident,type,e );
		t->setMetaData( d->meta );
		
		decls.push_back( t );
	}
	
	resolved=1;
}

ClassType *ClassType::classType(){
	return this;
}

Val *ClassType::superVal(){
	return super_val;
}

ClassType *ClassType::superClass(){
	return super_class;
}

string ClassType::encoding(){
	return "^";
}

string ClassType::toString(){
	return "Type";
}

bool ClassType::equals( Type *ty ){
	return this==ty->classType();
}

bool ClassType::extends( Type *ty ){
	ClassType *c=ty->classType();
	if( !c ) return false;
	ClassType *t;
	for( t=this;t;t=t->super_class ){
		if( t==ty ) return true;
	}
	return false;
}

Val *ClassType::find( string id ){
	ClassType *t;
	for( t=this;t;t=t->superClass() ){
		Val *v=t->decls.find(id);
		if( v && !v->countTmps( "@self" ) ) return v;
	}
	return 0;
}

Val *ClassType::findMethod( string id ){
	ClassType *t;
	for( t=this;t;t=t->super_class ){
		if( t->methods.find(id) ) return t->decls.find(id);
	}
	return 0;
}

Val *ClassType::findSuperMethod( string id ){
	return super_class ? super_class->findMethod( id ) : 0;
}

//****************** ObjectType *******************
ObjectType::ObjectType( Val *clas ):ident("<unknown>"),scope(0),class_val(clas){
}

ObjectType::ObjectType( string id,Scope *sc ):ident(id),scope(sc),class_val(0){
	sourceinfo=source_info;
	_objectTypes.push_back( this );
}

ObjectType *ObjectType::objectType(){
	if( objectClass()->attrs & ClassType::EXTERN ) return 0;
	return this;
}

ObjectType *ObjectType::exObjectType(){
	if( objectClass()->attrs & ClassType::EXTERN ) return this;
	return 0;
}

void ObjectType::resolve(){
	if( class_val ) return;
	
	source_info=sourceinfo;
	
	class_val=scope->findTypeIdent( ident );
	
	if( !class_val ) badid( ident );
	
	if( !class_val->type->classType() ) fail( "expecting type name" );
}

string ObjectType::encoding(){
//	if( objectClass()->attrs & ClassType::EXTERN ) return "?"+ident;
	return ":"+ident;
}

string ObjectType::toString(){
	return ident;
}

bool ObjectType::equals( Type *ty ){
	ObjectType *o=objectType() ? ty->objectType() : ty->exObjectType();
	return o ? objectClass()==o->objectClass() : false;
}

bool ObjectType::extends( Type *ty ){
	ObjectType *o=objectType() ? ty->objectType() : ty->exObjectType();
	return o && objectClass()->extends(o->objectClass());
}

Val *ObjectType::find( string id ){
	ClassType *t;
	for( t=objectClass();t;t=t->superClass() ){
		if( Val *v=t->decls.find(id) ) return v;
	}
	return 0;
}

ClassType *ObjectType::objectClass(){
	return class_val->type->classType();
}

//******************** FunType ********************
FunType::FunType( Type *ty,int attrs ):return_type(ty),attrs(attrs),call_conv(CG_CDECL){
}

FunType *FunType::funType(){
	return this;
}

string FunType::encoding(){
	string t="(";
	for( int k=0;k<args.size();++k ){
		if( k ) t+=",";
		t+=args[k]->val->type->encoding();
	}
	return t+")"+return_type->encoding();
}

string FunType::toString(){
	string t=return_type->toString()+"(";
	for( int k=0;k<args.size();++k ){
		if( k ) t+=",";
		t+=args[k]->val->type->toString();
	}
	return t+")";
}

bool FunType::equals( Type *ty ){
	FunType *f=ty->funType();
	if( !f ) return false;
	
	if( method()!=f->method() || args.size()!=f->args.size() ) return false;
	
	if( !return_type->equals(f->return_type) ) return false;

	for( int k=0;k<args.size();++k ){
		if( !args[k]->val->type->equals(f->args[k]->val->type) ) return false;
	}
	
	return true;
}

bool FunType::extends( Type *ty ){
	FunType *f=ty->funType();
	if( !f) return false;
	
	if( method()!=f->method() || args.size()!=f->args.size() ) return false;
	
	if( ObjectType *t=return_type->objectType() ){
		ObjectType *p=f->return_type->objectType();
		if( !p || !t->objectClass()->extends(p->objectClass()) ) return false;
	}else{
		if( !return_type->equals(f->return_type) ) return false;
	}

	for( int k=0;k<args.size();++k ){
		if( !args[k]->val->type->equals(f->args[k]->val->type) ) return false;
	}
	return true;
}

bool FunType::method(){
	return !!(attrs & METHOD);
}

//******************** PtrType ********************
PtrType::PtrType( Type *ty ):val_type(ty){
	_ptrTypes.push_back( this );
	sourceinfo=source_info;
}

PtrType *PtrType::ptrType(){
	return this;
}

void PtrType::resolve(){
	source_info=sourceinfo;
	if( val_type->ptrType() || val_type->numericType() || val_type->exObjectType() ) return;
	fail( "Illegal pointer type" );
}

string PtrType::encoding(){
	return "*"+val_type->encoding();
}

string PtrType::toString(){
	return val_type->toString()+ " Ptr";
}

bool PtrType::equals( Type *ty ){
	PtrType *t=ty->ptrType();
	return t && val_type->equals(t->val_type);
}

//******************** VarType ********************
VarType *VarType::varType(){
	return this;
}

string VarType::encoding(){
	return "*"+val_type->encoding();
}

string VarType::toString(){
	return val_type->toString()+" Var";
}

bool VarType::equals( Type *ty ){
	VarType *t=ty->varType();
	return t && val_type->equals(t->val_type);
}

//******************** AliasType ********************
AliasType::AliasType( Type *ty ):val_type(ty){
}

NumericType *AliasType::numericType(){
	return val_type->numericType();
}

IntType *AliasType::intType(){
	return val_type->intType();
}

FloatType *AliasType::floatType(){
	return val_type->floatType();
}

ClassType *AliasType::classType(){
	return val_type->classType();
}

ObjectType *AliasType::objectType(){
	return val_type->objectType();
}

ObjectType *AliasType::exObjectType(){
	return val_type->exObjectType();
}

StringType *AliasType::stringType(){
	return val_type->stringType();
}

ArrayType *AliasType::arrayType(){
	return val_type->arrayType();
}

FunType *AliasType::funType(){
	return val_type->funType();
}

PtrType *AliasType::ptrType(){
	return val_type->ptrType();
}

ModuleType *AliasType::moduleType(){
	return val_type->moduleType();
}

string AliasType::encoding(){
	return val_type->encoding();
}

string AliasType::toString(){
	return val_type->toString();
}

bool AliasType::equals( Type *ty ){
	return val_type->equals(ty);
}

bool AliasType::extends( Type *ty ){
	return val_type->extends(ty);
}

Val *AliasType::find( string id ){
	return val_type->find(id);
}

//***************** Reference Type ****************
RefType *RefType::refType(){
	return this;
}

//***************** Null Type *********************
NullType *NullType::nullType(){
	return this;
}

string NullType::toString(){
	return "null";
}

bool NullType::equals( Type *ty ){
	return !!ty->nullType();
}

//***************** Module Type *******************
ModuleType *ModuleType::moduleType(){
	return this;
}

string ModuleType::toString(){
	return "module";
}

bool ModuleType::equals( Type *ty ){
	return this==ty;
}

Val *ModuleType::find( string id ){
	return decls.find(id);
}
