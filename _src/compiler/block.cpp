
#include "std.h"
#include "block.h"
#include "stm.h"
#include "toker.h"
#include "output.h"

using namespace CG;

static vector<FunBlock*> _funBlocks;
static vector<ClassBlock*> _classBlocks;

//******************** Block **********************
Block::Block( Block *o ):outer(o),cg_debug(0){
	fun_block=outer ? outer->fun_block : 0;
	cg_enter=CG::seq(0);
	cg_leave=CG::seq(0);
	debug_on=outer ? outer->debug_on : opt_debug;
}

CGDat *Block::debugScope(){

	if( cg_debug ) return cg_debug;
	
	int kind=0;
	string name;
	DeclSeq *scope=&decls;
	
	if( FunBlock *fun=dynamic_cast<FunBlock*>(this) ){
		kind=1;
		name=fun->fun_decl ? fun->fun_decl->ident : stripall( opt_infile );
	}else if( ClassBlock *clas=dynamic_cast<ClassBlock*>(this) ){
		kind=2;
		scope=&clas->type->decls;
		name=clas->class_decl->ident;
		string meta=clas->class_decl->meta;
		if( meta.size() ) name+="{"+meta+"}";
	}else{
		kind=3;
	}
	
	CGDat *d=CG::dat();
	
	d->push_back( lit(kind) );									//kind
	if( name.size() ) d->push_back( genCString(name) );			//name
	else d->push_back( lit0 );
	
	if( FunBlock *fun=dynamic_cast<FunBlock*>(this) ){
		ClassBlock *clas=dynamic_cast<ClassBlock*>(outer);
		if( clas && fun->type->method() ){
			assert( fun->fun_scope->cg_exp->tmp() );
			d->push_back( CG::lit(2) );
			d->push_back( genCString("Self") );
			d->push_back( genCString(":"+clas->class_decl->ident) );
			d->push_back( lea(fun->fun_scope->cg_exp) );
		}
	}
	
	for( int k=0;k<scope->size();++k ){
		(*scope)[k]->debugDecl( d,kind );
	}
	
	d->push_back( lit0 );
	
	return cg_debug=d;
}

void Block::emit( Stm *t ){
	stms.push_back(t);
}

void Block::emit( CGStm *t ){
	if( t ) fun_block->cg_fun->stms.push_back(t);
}

void Block::decl( Decl *d ){
	decls.push_back(d);
}

void Block::declLocal( Decl *d ){
	decls.push_back(d);
	locals.push_back(d);
}

Val *Block::linearizeRef( Val *v ){
	CGExp *e=v->cg_exp;

	if( !e->sideEffects() ) return v;
	
	while( CGEsq *t=e->esq() ){
		emit( t->lhs );
		e=t->rhs;
	}
	
	if( e->tmp() ) return new Val( v->type,e );

	CGMem *t=e->mem();
	if( !t ) fail( "Internal error: Can't linearize reference" );
	CGTmp *p=tmp(CG_PTR);
	emit( mov(p,t->exp) );
	return new Val( v->type,mem(v->type->cgType(),p,t->offset) );
}

void Block::initRef( Val *lhs,Val *rhs ){
	if( !lhs->type->refType() ) fail( "initRef expecting ref type" );

	if( !lhs->cg_exp->tmp() && !lhs->cg_exp->mem() ){
		cout<<lhs->cg_exp<<endl;
		fail( "Internal error: Block::initRef - value is not a reference" );
	}
	
	if( lhs->refCounted() ){
		rhs=rhs->retain();
	}
	
	emit( mov(lhs->cg_exp,rhs->cg_exp) );
}

void Block::assignRef( Val *lhs,Val *rhs ){

	RefType *ref=lhs->type->refType();

	if( !ref ) fail( "assignRef expecting ref type" );

	if( !lhs->cg_exp->tmp() && !lhs->cg_exp->mem() ){
		cout<<lhs->cg_exp<<endl;
		fail( "Internal error: Block::assignRef - value is not a reference" );
	}

	if( !lhs->refCounted() ){
		emit( mov( lhs->cg_exp,rhs->cg_exp ) );
		return;
	}
	
	//Release LHS AFTER evaluating and incing RHS
	CGTmp *t=tmp(CG_PTR);
	emit( mov( t,rhs->retain()->cg_exp ) );
	emit( lhs->release() );
	emit( mov( lhs->cg_exp,t ) );
}

void Block::initGlobalRef( Val *lhs,Val *rhs ){
	if( !lhs->type->refType() ) fail( "initGlobalRef expecting ref type" );
	if( !lhs->cg_exp->mem() ) fail( "initGlobalRef expecting mem exp" );

	if( lhs->refCounted() ){
		rhs=rhs->retain();
	}
	
	static int init_bit;
	static CGExp *init_var;
	
	init_bit<<=1;
	if( !init_bit ){
		init_bit=1;
		CGDat *d=dat();
		d->push_back(lit0);
		init_var=mem(CG_INT32,d);
	}
	CGLit *init_lit=lit(init_bit);
	
	CGSym *t=sym();
	
	emit( bcc(CG_NE,bop(CG_AND,init_var,init_lit),lit0,t) );
	emit( mov(lhs->cg_exp,rhs->cg_exp) );
	emit( mov(init_var,bop(CG_ORL,init_var,init_lit)) );
	emit( lab(t) );
}

Val *Block::find( string id ){
	Val *v;
	Block *t;
	for( t=this;t;t=t->outer ){
		if( v=t->_find( id,this ) ) return v;
	}
	return findGlobal( id );
}

Val *Block::_find( string id,Block *from ){
	Val *v=decls.find(id);
	if( !v || !locals.find(id) ) return v;
	return from && fun_block==from->fun_block ? v : 0;
}

void Block::eval(){
	ClassBlock *clas=dynamic_cast<ClassBlock*>(this);
	
	bool t_debug=opt_debug;
	opt_debug=debug_on;
	
	emit( cg_enter );
	for( int k=0;k<stms.size();++k ){
		Stm *st=stms[k];
		source_info=st->source_info;
		st->eval( this );
	}
	emit( cg_leave );
	
	opt_debug=t_debug;
	
	if( debug_on && !clas ){
		if( strictMode || dynamic_cast<FunBlock*>(this) ){
			cg_enter->push_back( eva(jsr(CG_INT32,CG_CDECL,mem(CG_PTR,sym("bbOnDebugEnterScope",CG_IMPORT),0),debugScope(),frm())) );
			cg_leave->push_front( eva(jsr(CG_INT32,CG_CDECL,mem(CG_PTR,sym("bbOnDebugLeaveScope",CG_IMPORT),0))) );
		}
	}
}

void Block::resolveBlocks(){
	int k;
	for( k=0;k<_classBlocks.size();++k ) _classBlocks[k]->resolve();
	for( k=0;k<_funBlocks.size();++k ) _funBlocks[k]->resolve();
}

void Block::evalFunBlocks(){
	int k;
	for( k=0;k<_funBlocks.size();++k ) _funBlocks[k]->eval();
}

void Block::evalClassBlocks(){
	int k;
	for( k=0;k<_classBlocks.size();++k ) _classBlocks[k]->eval();
}

//****************** Loop Block *******************
LoopBlock::LoopBlock( Block *o,string lab ):Block(o),label(lab){
	cont_sym=sym();
	exit_sym=sym();
	loop_sym=sym();
}

//**************** Function Block *****************
FunBlock::FunBlock():Block(0),
fun_decl(0),fun_scope(0),ret_tmp(0),ret_sym(0),data_ptr(0),data_stms(0){
	fun_block=this;
	sourceinfo=source_info;
	_funBlocks.push_back( this );
	
	type=new FunType( Type::int32,FunType::VOIDFUN );

	string entry;

	if( opt_apptype.size() ){
		entry="_bb_main";
	}else if( opt_module.size() && (moduleIdent(opt_module)==stripall(opt_infile)) ){
		entry=mungModuleEntry( opt_module );
	}else{
		entry=mungObjectEntry( opt_infile );
	}
	
	CGSym *cg_sym=sym( entry,CG_EXPORT );

	cg_fun=fun( CG_INT32,CG_CDECL,cg_sym,0 );
}

FunBlock::FunBlock( Block *o,string id,FunType *ty,bool pub,ExpSeq *defs ):Block(o),
type(ty),cg_fun(0),fun_scope(0),ret_tmp(0),ret_sym(0),data_ptr(0),data_stms(0){
	fun_block=this;
	sourceinfo=source_info;
	_funBlocks.push_back( this );
	
	ClassBlock *class_blk=dynamic_cast<ClassBlock*>(outer);
	ClassType *class_ty=class_blk ? class_blk->type : 0;
	
	CGSym *cg_sym;
	
	if( pub ){
		if( class_blk ) cg_sym=sym( mungMember(class_blk->class_decl->ident,id),CG_EXPORT );
		else cg_sym=sym( mungGlobal(id),CG_EXPORT );
	}else{
		cg_sym=sym();
	}
	
	fun_decl=new FunDecl(id,type,cg_sym,outer,defs);

	if( class_ty ){
		class_ty->methods.push_back(fun_decl);
	}else if( outer ){
		outer->decl(fun_decl);
		if( pub ) publish( fun_decl );
	}
}

void FunBlock::resolve(){
	source_info=sourceinfo;
	
	ClassBlock *class_blk=dynamic_cast<ClassBlock*>(outer);
	ClassType *class_ty=class_blk ? class_blk->type : 0;
	
	CGTmp *cg_self=0;
	
	if( class_ty ){
		if( type->method() ){
			cg_self=tmp(CG_PTR);
			Val *class_val=new Val(class_ty,class_blk->class_decl->val->cg_exp);
			fun_scope=new Val( new ObjectType(class_val),cg_self );
		}else{
			fun_scope=class_blk->class_decl->val;
		}
	}
	
	if( !cg_fun ){
		//create cg_fun
		CGSym *cg_sym=fun_decl->val->cg_exp->sym();
		cg_fun=fun( type->return_type->cgType(),type->call_conv,cg_sym,cg_self );
		for( int k=0;k<type->args.size();++k ){
			cg_fun->args.push_back( tmp(type->args[k]->val->type->cgType()) );
		}
	}
		
	//copy args to locals
	for( int k=0;k<type->args.size();++k ){
		Decl *d=type->args[k];
		Type *ty=d->val->type;
		CGExp *cg=cg_fun->args[k];
		int attrs=0;
		if( VarType *t=ty->varType() ){
			ty=t->val_type;
			cg=mem(ty->cgType(),cg,0);
		}
		Val *v=new Val( new RefType(ty,attrs),cg );
		declLocal( new Decl(d->ident,v) );
	}
	
	ret_sym=sym();
	ret_tmp=tmp( type->return_type->cgType() );
	
	emit( new ReturnStm( (type->attrs&FunType::VOIDFUN) ? 0 : new NullExp() ) );
}

void FunBlock::eval(){
	
	Block::eval();

	//data statements?
	if( data_ptr ){
		data_stms->push_back( lit0 );
		cg_enter->push_back( mov( mem(CG_PTR,data_ptr,0),data_stms ) );
	}

	//if main, prevent recursive startup
	if( !outer ){
		CGDat *d=dat();
		d->push_back( lit0 );
		CGMem *m=mem(CG_INT32,d);
		CGSym *t=sym();
		CGStm *s=seq(
			bcc(CG_EQ,m,lit0,t),
			ret(lit0),
			lab(t),
			mov(m,lit1),
		0 );
		cg_enter->push_front(s);
	}

	cg_leave->push_front( lab(ret_sym) );
	emit( ret(ret_tmp) );
}

Val *FunBlock::_find( string id,Block *from ){

	Val *v;
	if( v=Block::_find( id,from ) ) return v;
	if( !fun_scope ) return 0;

	//bit naughty! turn off debug for members of 'Self'
	bool t_debug=debug_on;
	debug_on=false;
	v=fun_scope->find(id);
	debug_on=t_debug;
	return v;
}

void FunBlock::genAssem(){
	vector<CGFun*> cgfuns;
	int k;
	for( k=0;k<_funBlocks.size();++k ) cgfuns.push_back( _funBlocks[k]->cg_fun );
	string file=getdir(opt_infile)+"/.bmx/"+stripdir(opt_infile);
	if( opt_apptype.size() ) file+="."+opt_apptype;
	file+=config_mung+".s";
	ofstream out(file.c_str());
	cgGenCode( out,cgfuns );
	out.close();
}

void FunBlock::genInterface(){
	if( opt_apptype.size() ) return;
	if( moduleIdent(opt_module)==stripall(opt_infile) ){
		string file=modulePath(opt_module,true)+"/"+moduleIdent(opt_module)+config_mung+".i";
		ofstream out(file.c_str());
		int k;
		for( k=0;k<moduleInfos.size();++k ) out<<"ModuleInfo \""<<moduleInfos[k]<<"\"\n";
		for( k=0;k<moduleImports.size();++k ) out<<moduleImports[k]<<'\n';
		out::operator<<( out,moduleExports );
		out.close();
	}else{
		string file=getdir(opt_infile)+"/.bmx/"+stripdir(opt_infile)+config_mung+".i";
		ofstream out(file.c_str());
		for( int k=0;k<objectImports.size();++k ) out<<objectImports[k]<<'\n';
		out::operator<<( out,objectExports );
		out.close();
	}
}

CGDat *FunBlock::dataPtr(){
	if( data_ptr ) return data_ptr;

	data_ptr=dat();
	data_stms=dat();
	
	data_ptr->push_back( lit0 );
	
	return data_ptr;
}

CGDat *FunBlock::dataStms(){
	dataPtr();
	return data_stms;
}

//******************* Type Block ******************
ClassBlock::ClassBlock( Block *o,string id,ClassType *ty ):Block(o),type(ty){
	sourceinfo=source_info;
	_classBlocks.push_back( this );
	
	bool pub=(ty->attrs & ClassType::PRIVATE) ? false : true;

	CGDat *d;
	if( pub ) d=dat( mungGlobal(id) );
	else d=dat();
	
	class_decl=new Decl(id,type,d);
	
	FunType *ctor_ty=new FunType( Type::int32,FunType::METHOD|FunType::VOIDFUN );
	ctor=new FunBlock( this,"New",ctor_ty,true );
	ctor_new=new Block( ctor );
	field_ctors=new Block( ctor );
	field_ctors->debug_on=false;
	ctor->emit( new CtorStm( this,ctor_new ) );
	
	dtor=0;
	dtor_delete=0;
	
	if( !opt_threaded ){
		makeDtor();
	}
	
	outer->decl( class_decl );
	
	if( pub ){
		publish( class_decl );
	}
}

void ClassBlock::makeDtor(){
	if( !dtor ){
		FunType *dtor_ty=new FunType( Type::int32,FunType::METHOD|FunType::VOIDFUN );
		dtor=new FunBlock( this,"Delete",dtor_ty,true );
		dtor->debug_on=false;
		
		dtor_delete=new Block(dtor);
		dtor->emit( new DtorStm( this,dtor_delete ) );
	}
}

void ClassBlock::resolve(){
	source_info=sourceinfo;

	CGDat *vtbl=class_decl->val->cg_exp->dat();

	Val *super_val=type->superVal();
	CGExp *exts=super_val ? super_val->cg_exp : lit0;

	//construct vtable methods
	vector<ClassType*> stk;
	for( ClassType *t=type;t;t=t->superClass() ) stk.push_back(t);
	
	vector<Decl*> vtbl_methods;
	for( ;stk.size();stk.pop_back() ){
		ClassType *t=stk.back();
		for( int k=0;k<t->methods.size();++k ){
			Decl *d=t->methods[k];
			string id=tolower(d->ident);
			
			for( int j=0;j<vtbl_methods.size();++j ){
				if( id!=tolower(vtbl_methods[j]->ident) ) continue;
				vtbl_methods[j]=d;
				d=0;break;
			}
			if( d ) vtbl_methods.push_back(d);
		}
	}
	
	CGExp *db=debugScope();
	
	vtbl->push_back( exts );						//super
	vtbl->push_back( sym("bbObjectFree",CG_IMPORT) );	//free method!
	vtbl->push_back( db );						//debug scope
	vtbl->push_back( lit(type->sizeof_fields) );		//sizeof_fields
	for( int k=0;k<vtbl_methods.size();++k ){		//methods
		Val *v=vtbl_methods[k]->val;
		vtbl->push_back( v->cg_exp );
		if( v->type->funType()->attrs & FunType::ABSTRACT ){
			if( type->attrs & ClassType::FINAL ){
				fail( "Abstract method '%s' in final type '%s'",
					vtbl_methods[k]->ident.c_str(),class_decl->ident.c_str() );
			}
			type->attrs|=ClassType::ABSTRACT;
		}
	}
}

void ClassBlock::eval(){
	bool t_debug=opt_debug;
	opt_debug=debug_on;
	for( int k=0;k<stms.size();++k ){
		Stm *st=stms[k];
		source_info=st->source_info;
		st->eval( this );
	}
	//globals initialized: register type
	//CGDat *name=genCString(class_decl->ident);
	CGDat *vtbl=class_decl->val->cg_exp->dat();

	emit( eva( jsr( CG_INT32,"bbObjectRegisterType",vtbl ) ) );
	
	opt_debug=t_debug;
}

void ClassBlock::decl( Decl *d ){
	decls.push_back(d);
	type->decls.push_back(d);
}
