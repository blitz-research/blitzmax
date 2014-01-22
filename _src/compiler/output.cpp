
#include "std.h"
#include "output.h"
#include "decl.h"
#include "val.h"

ostream &out::operator<<( ostream &out,CGExp *exp ){

	if( CGLit *t=exp->lit() ){
		if( t->isint() ){
			out<<fromint(t->int_value);				
			if( t->type==CG_INT64 ) out<<":Long";
		}else if( t->isfloat() ){
			if( isnan( t->float_value ) ){
				out<<"nan";
			}else if( isinf( t->float_value ) ){
				out<<( t->float_value>0 ? "inf" : "-inf" );
			}else{
				out<<t->float_value;
			}
			out<<( t->type==CG_FLOAT32 ? '#' : '!' );
		}else{
			assert(0);
		}
	}else if( CGSym *t=exp->sym() ){
		out<<"\""<<t->value<<"\"";
	}else{
		const char *ty="";
		switch( exp->type ){
		case CG_INT8:ty=":b";break;
		case CG_INT16:ty=":s";break;
		case CG_INT32:break;
		case CG_INT64:ty=":l";break;
		case CG_PTR:ty=":p";break;
		case CG_FLOAT32:ty=":f";break;
		case CG_FLOAT64:ty=":d";break;
		default:
			cout<<"type error:"<<exp->type<<endl;
			assert(0);
		}
		if( CGMem *t=exp->mem() ){
			out<<"mem"<<ty<<"("<<t->exp;
			if( t->offset ) out<<","<<t->offset;
			out<<")";
		}else{
			fail( "Unrecognized intermediate code expression - !*#%" );
		}
	}
	return out;
}

ostream &out::operator<<( ostream &out,Type *ty ){
	if( RefType *t=ty->refType() ){
		out<<t->val_type<<'&';
	}else if( VarType *t=ty->varType() ){
		out<<t->val_type<<" Var";
	}else if( PtrType *t=ty->ptrType() ){
		out<<t->val_type<<'*';
	}else if( IntType *t=ty->intType() ){
		switch( t->size() ){
		case 1:out<<"@";break;
		case 2:out<<"@@";break;
		case 4:out<<"%";break;
		case 8:out<<"%%";break;
		default:assert(0);
		}
	}else if( FloatType *t=ty->floatType() ){
		switch( t->size() ){
		case 4:out<<"#";break;
		case 8:out<<"!";break;
		default:assert(0);
		}
	}else if( CStringType *t=ty->cstringType() ){
		out<<"$z";
	}else if( WStringType *t=ty->wstringType() ){
		out<<"$w";
	}else if( StringType *t=ty->stringType() ){
		out<<"$";
	}else if( ArrayType *t=ty->arrayType() ){
		out<<t->element_type<<'['<<string(t->dims-1,',')<<']';
	}else if( ObjectType *t=ty->objectType() ){
		if( t->ident=="<unknown>" ) fail( "export of unknown type" );
		string id=t->ident;
		ClassType *ty=t->objectClass();
		while( ty->attrs & ClassType::PRIVATE ){
			id=ty->super_name;
			ty=ty->superClass();
		}
		out<<':'<<id;
	}else if( ObjectType *t=ty->exObjectType() ){
		if( t->ident=="<unknown>" ) fail( "export of unknown type" );
		out<<':'<<t->ident;
	}else if( FunType *t=ty->funType() ){
		out<<t->return_type<<'(';
		for( int k=0;k<t->args.size();++k ){
			if( k ) out<<',';
			out<<t->args[k];
		}
		out<<')';
		if( t->attrs & FunType::ABSTRACT ) out<<'A';
		if( t->attrs & FunType::FINAL ) out<<'F';
		if( t->call_conv==CG_STDCALL ) out<<'S';
	}else if( ClassType *t=ty->classType() ){
		out<<'^';
		if( t->super_name.size() ) out<<t->super_name; else out<<"Null";
		out<<"{\n";
		int k;
		for( k=0;k<t->decls.size();++k ){
			Decl *d=t->decls[k];
			if( t->methods.find(d->ident) || t->fields.find(d->ident) ) continue;
			out<<d<<'\n';
		}
		for( k=0;k<t->fields.size();++k ){
			out<<'.'<<t->fields[k]<<'\n';
		}
		for( k=0;k<t->methods.size();++k ){
			FunType *ty=t->methods[k]->val->type->funType();
			out<<(ty->method() ? '-' : '+')<<t->methods[k]<<'\n';
		}
		out<<"}";
		if( t->attrs & ClassType::ABSTRACT ) out<<'A';
		if( t->attrs & ClassType::FINAL ) out<<'F';
		if( t->attrs & ClassType::EXTERN ) out<<'E';
	}else{
		fail( "Export Type '%s' failed",ty->toString().c_str() );
	}
	return out;
}

ostream &out::operator<<( ostream &out,Decl *d ){
	Val *v=d->val;
	out<<d->ident<<v->type;
	if( v->cg_exp ){
		if( v->type->stringType()  && v->constant() ){
			out<<"=$\""<<tostring( escapeString( v->stringValue() ) )<<'\"';
		}else{
			out<<'='<<v->cg_exp;
		}
	}
	return out;
}

ostream &out::operator<<( ostream &out,const DeclSeq &seq ){
	int k;
	for( k=0;k<seq.size();++k ){
		out<<seq[k]<<'\n';
	}
	return out;
}