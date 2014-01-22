
#include "std.h"
#include "decl.h"
#include "exp.h"

#include "../codegen/cgdebug.h"

static vector<ConstDecl*> _constDecls;
static vector<FunDecl*> _funDecls;

//********************* Decl **********************
Decl::Decl( string id,Val *v ):ident(id),val(v){
}

Decl::Decl( string id,Type *ty,CGExp *cg ):ident(id),val(new Val(ty,cg)){
}

void Decl::setMetaData( string meta ){
	this->meta=meta;
}

string Decl::debugEncoding(){
	Type *t=val->type;
	string e=t->encoding();
	if( e.size() && e[0]==':' && t->exObjectType() ) e='?'+e.substr(1);
	if( meta.size() ){
		e+="{"+meta+"}";
	}
	return e;
}

void Decl::resolveDecls(){
	int k;
	if( opt_verbose ) cout<<"Resolving const decls..."<<endl;
	for( k=0;k<_constDecls.size();++k ) _constDecls[k]->resolve();
	if( opt_verbose ) cout<<"Resolving fun decls..."<<endl;
	for( k=0;k<_funDecls.size();++k ) _funDecls[k]->resolve();
}

void Decl::debugDecl( CGDat *d,int blockKind ){

	CGExp *e=val->cg_exp;
	if( !e ) return;
	
	if( val->constant() ){
		if( val->type->numericType() || val->type->stringType() ){
			bstring t=val->stringValue();

			d->push_back( CG::lit(1) );
			d->push_back( genCString(ident) );
			d->push_back( genCString(debugEncoding()) );
			d->push_back( genBBString2( t ) );

			/*
			CGDat *dt=CG::dat();
			dt->push_back( CG::sym("bbStringClass",CG_IMPORT) );
			dt->push_back( CG::lit(0x7ffffffe) );	//normally 0x7fffffff - 0x..fe indicates 'ignore for GC'.
			dt->push_back( CG::lit(t,CG_BSTRING) );
			d->push_back( dt );
			*/
			
			/*
			d->push_back( CG::lit(1) );
			d->push_back( genCString(ident) );
			d->push_back( genCString(debugEncoding()) );
			d->push_back( val->cast(Type::stringObject)->cg_exp );
			*/
			
			return;
		}
	}
	
	if( !val->type->refType() ){
		if( blockKind==2 && val->type->funType() ){
			//type method/function
			int dt=7;
			if( CGVfn *t=e->vfn() ){
				e=t->exp;
				dt=6;
			}
			if( CGMem *t=e->mem() ){
				d->push_back( CG::lit( dt ) );
				d->push_back( genCString(ident) );
				d->push_back( genCString(debugEncoding()) );
				d->push_back( CG::lit( t->offset ) );
			}else if( CGSym *t=e->sym() ){
				d->push_back( CG::lit( dt ) );
				d->push_back( genCString(ident) );
				d->push_back( genCString(debugEncoding()) );
				d->push_back( t );
			}
		}
		return;
	}

	if( CGTmp *t=e->tmp() ){
		d->push_back( CG::lit(2) );
		d->push_back( genCString(ident) );
		d->push_back( genCString(debugEncoding()) );
		d->push_back( CG::lea(t) );
		return;
	}
	
	if( CGMem *t=e->mem() ){
		if( t->exp->tmp() ){
			if( blockKind==2 ){
				//field
				d->push_back( CG::lit(3) );
				d->push_back( genCString(ident) );
				d->push_back( genCString(debugEncoding()) );
				d->push_back( CG::lit(t->offset) );
			}else{
				d->push_back( CG::lit(5) );
				d->push_back( genCString(ident) );
				d->push_back( genCString(debugEncoding()) );
				d->push_back( CG::lea(t->exp->tmp()) );
			}
			return;
		}else if( t->exp->sym() && !t->offset ){
			d->push_back( CG::lit(4) );
			d->push_back( genCString(ident) );
			d->push_back( genCString(debugEncoding()) );
			d->push_back( t->exp );
			return;
		}
	}
	return;
}

//***************** fun Decl ********************
FunDecl::FunDecl( string id,FunType *ty,CGExp *cg,Scope *sc,ExpSeq *defs ):Decl( id,ty,cg ),scope(sc),defaults(defs){
	sourceinfo=source_info;
	_funDecls.push_back( this );
}

void FunDecl::resolve(){

	source_info=sourceinfo;
	FunType *fun=val->type->funType();
	
	ClassBlock *class_block=dynamic_cast<ClassBlock*>(scope);
	
	if( class_block ){
		if( Val *v=class_block->type->findSuperMethod( ident ) ){
			FunType *t=v->type->funType();
			if( t->attrs & FunType::FINAL ){
				fail( "Final methods cannot be overridden" );
			}
			if( !fun->extends(t) ){
				fail( "Overriding method differs by type" );
			}
		}
	}

	if( defaults ){
		int k;
		for( k=0;k<defaults->size();++k ){
			Exp *e=(*defaults)[k];
			if( !e ) continue;
			Val *v=e->eval(scope,fun->args[k]->val->type);
			if( !v->constant() ) fail( "Function defaults must be constant" );
			fun->args[k]->val->cg_exp=v->cg_exp;
		}
	}
	if( !val->cg_exp ){
		string id=ident;
		if( fun->call_conv==CG_STDCALL ){
			int sz=0;
			for( int k=0;k<fun->args.size();++k ){
				int n=fun->args[k]->val->type->size();
				sz+=n>4 ? n : 4;
			}
			id+="@"+fromint(sz);
		}
		val->cg_exp=CG::sym( id,CG_IMPORT );
	}
}

//****************** ConstDecl *********************
ConstDecl::ConstDecl( string id,Type *ty,Scope *sc,Exp *e ):Decl(id,ty,0),scope(sc),exp(e){
	sourceinfo=source_info;
	_constDecls.push_back(this);
}

void ConstDecl::resolve(){
	source_info=sourceinfo;
	Val *v=exp->eval(scope,val->type);
	if( !v->constant() ) fail( "Constant initializers must be constant" );
	val->cg_exp=v->cg_exp;
}
