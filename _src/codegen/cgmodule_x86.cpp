
#include "cgstd.h"

#include "cgmodule_x86.h"
#include "cgfixfp_x86.h"

static bool USE_NASM=false;	//NASM doesn't seem to work at all

CGModule_X86::CGModule_X86( ostream &o ):CGModule(o){
}

void CGModule_X86::setSeg( string t ){
	if( seg==t ) return;
	seg=t;
	if( USE_NASM ){
		out<<"\tsection\t."<<seg<<'\n';
	}else{
		out<<"\tsection\t"<<seg<<'\n';
	}
}

CGFrame *CGModule_X86::frame( CGFun *fun ){
	return new CGFrame_X86( fun,this );
}

void CGModule_X86::emitHeader(){
	if( env_platform=="win32" ){
		out<<"\tformat\tMS COFF\n";
	}else if( env_platform=="linux" ){
		out<<"\tformat\tELF\n";
	}else if( env_platform!="macos" ){
		assert(0);
	}
}

void CGModule_X86::emitImport( string t ){
	if( USE_NASM ){
		out<<"\textern\t"<<t<<'\n';
	}else{
		out<<"\textrn\t"<<t<<'\n';
	}
}

void CGModule_X86::emitExport( string t ){
	if( USE_NASM ){
		out<<"\tglobal\t"<<t<<'\n';
	}else{
		out<<"\tpublic\t"<<t<<'\n';
	}
}

void CGModule_X86::emitFrame( CGFrame *f ){

	if( env_platform=="win32" ){
		setSeg( "\"code\" code" );
	}else if( env_platform=="linux" ){
		setSeg( "\"code\" executable" );
	}else if( env_platform=="macos" ){
		setSeg( "text" );
	}

	if( env_platform=="macos" ){
		emitMacFrame( f );
		return;
	}

	CGFrame_X86 *frame=dynamic_cast<CGFrame_X86*>(f);
	assert( frame );

	int k,n_use[7]={0};

	for( k=0;k<frame->regs.size();++k ){
		CGReg *r=frame->regs[k];
		if( r->isint() && r->id>=14 && r->color>=0 && r->color<7 ) ++n_use[r->color];
	}
	
	if( frame->extern_jsrs ){
		n_use[3]=n_use[4]=n_use[5]=-1;
	}

	int local_sz=frame->local_sz;

	//create frame
	out<<frame->fun->sym->value<<":\n";
	
	out<<"\tpush\tebp\n";
	out<<"\tmov\tebp,esp\n";
	emitSubEsp( local_sz );
	//push callee save
	if( n_use[3] ) out<<"\tpush\tebx\n";
	if( n_use[4] ) out<<"\tpush\tesi\n";
	if( n_use[5] ) out<<"\tpush\tedi\n";

	CGAsm *as;

	for( as=frame->assem.begin;as!=frame->assem.end;as=as->succ ){
		if( as->stm && as->stm->ret() ){
			//pop callee save
			if( n_use[5] ) out<<"\tpop\tedi\n";
			if( n_use[4] ) out<<"\tpop\tesi\n";
			if( n_use[3] ) out<<"\tpop\tebx\n";
			out<<"\tmov\tesp,ebp\n";
			out<<"\tpop\tebp\n";
		}

		const char *p=as->assem;
		if( !p ) continue;

		out<<p;
	}
}

void CGModule_X86::emitSubEsp( int sz ){
	while( sz>4096 ){
		out<<"\tsub\tesp,4092\n\tpush\teax\n";
		sz-=4096;
	}
	if( sz ) out<<"\tsub\tesp,"<<sz<<'\n';
}

void CGModule_X86::emitMacFrame( CGFrame *f ){

	CGFrame_X86 *frame=dynamic_cast<CGFrame_X86*>(f);
	assert( frame );

	int k,n_use[7]={0};

	for( k=0;k<frame->regs.size();++k ){
		CGReg *r=frame->regs[k];
		if( r->isint() && r->id>=14 && r->color>=0 && r->color<7 ) ++n_use[r->color];
	}

	int save_sz=8;				//ret address+ebp
	if( n_use[3] ) save_sz+=4;	//ebx
	if( n_use[4] ) save_sz+=4;	//esi
	if( n_use[5] ) save_sz+=4;	//edi

	int local_sz=frame->local_sz;
	int param_sz=frame->param_sz;

	int frame_sz=param_sz+local_sz+save_sz;

	frame_sz=(frame_sz+15)&~15;

	param_sz=frame_sz-(local_sz+save_sz);

	//create frame
	out<<frame->fun->sym->value<<":\n";

	//push ebp
	out<<"\tpush\tebp\n";
	out<<"\tmov\tebp,esp\n";

	if( save_sz>8 ){
		emitSubEsp( local_sz );
		if( n_use[3] ) out<<"\tpush\tebx\n";
		if(	n_use[4] ) out<<"\tpush\tesi\n";
		if( n_use[5] ) out<<"\tpush\tedi\n";
		emitSubEsp( param_sz );
	}else{
		emitSubEsp( local_sz+param_sz );
	}

	CGAsm *as;

	for( as=frame->assem.begin;as!=frame->assem.end;as=as->succ ){
		if( as->stm && as->stm->ret() ){
			//pop callee save
			if( save_sz>8 ){
				if( param_sz ) out<<"\tadd\tesp,"<<param_sz<<'\n';
				if( n_use[5] ) out<<"\tpop\tedi\n";
				if( n_use[4] ) out<<"\tpop\tesi\n";
				if( n_use[3] ) out<<"\tpop\tebx\n";
			}
			out<<"\tmov\tesp,ebp\n";
			out<<"\tpop\tebp\n";
		}

		const char *p=as->assem;
		if( !p ) continue;

		out<<p;
	}
}

void CGModule_X86::emitData( CGDat *d ){

	if( env_platform=="win32" ){
		setSeg( "\"data\" data writeable align 8" );
	}else if( env_platform=="linux" ){
		setSeg( "\"data\" writeable align 8" );
	}else if( env_platform=="macos" ){
		setSeg( "data" );
	}
	
	int align=4;
	if( d->exps.size()==1 ){
		switch( d->exps[0]->type ){
		case CG_INT8:
		case CG_CSTRING:
			align=1;
			break;
		case CG_INT16:
			align=2;
			break;
		case CG_INT64:case CG_FLOAT64:
			align=8;
			break;
		}
	}
	if( align!=1 ){
		out<<"\talign\t"<<align<<"\n";
	}
	
	out<<d->value<<":\n";

	for( int k=0;k<d->exps.size();++k ){

		CGExp *e=d->exps[k];

		if( CGLit *t=e->lit() ){
			if( t->type==CG_INT8 ){
				out<<"\tdb\t"<<unsigned(t->int_value)<<'\n';
			}else if( t->type==CG_INT16 ){
				out<<"\tdw\t"<<unsigned(t->int_value)<<'\n';
			}else if( t->type==CG_INT32 ){
				out<<"\tdd\t"<<int(t->int_value)<<'\n';
			}else if( t->type==CG_INT64 ){
				out<<"\tdd\t"<<int(t->int_value)<<','<<int(t->int_value>>int64(32))<<'\n';
			}else if( t->type==CG_FLOAT32 ){
				float f=t->float_value;
				int n=*(int*)&f;
				out<<"\tdd\t0x"<<hex<<n<<dec<<'\n';
//				float f=t->float_value;
//				out<<"\tdd\t0x"<<hex<<*((int*)&f)<<dec<<'\n';
			}else if( t->type==CG_FLOAT64 ){
				double f=t->float_value;
				int64 n=*(int64*)&f;
				out<<"\tdd\t0x"<<hex<<int(n)<<",0x"<<int(n>>int64(32))<<dec<<'\n';
//				double f=t->float_value;
//#if __APPLE__ && __BIG_ENDIAN__
//				out<<"\tdd\t0x"<<hex<<*((int*)&f+1)<<",0x"<<*((int*)&f)<<dec<<'\n';
//#else
//				out<<"\tdd\t0x"<<hex<<*((int*)&f)<<",0x"<<*((int*)&f+1)<<dec<<'\n';
//#endif
			}else if( t->type==CG_CSTRING ){
				bstring s=t->string_value;
				out<<"\tdb\t\"";
				for( int k=0;k<s.size();++k ){
					if( s[k]==34 ){
						if( env_platform=="macos" ){
							out<<"\\\"";
						}else{
							out<<"\",34,\"";
						}
					}else{
					 	out<<(char)s[k];
					}
				}
				out<<"\",0\n";
			}else if( t->type==CG_BSTRING ){
				bstring s=t->string_value;
				out<<"\tdd\t"<<s.size();
				for( int k=0;k<s.size();++k ){
					if( k%16 ) out<<','<<(unsigned)s[k];
					else out<<"\n\tdw\t"<<(unsigned)s[k];
				}
				out<<"\n";
			}else if( t->type==CG_BINFILE ){
				string file=tostring(t->string_value);
				out<<"\tfile\t\""+file+"\"\n";
			}else if( t->type==CG_LABEL ){
				out<<tostring(t->string_value)<<":\n";
			}else{
				assert(0);
			}
		}else if( CGSym *t=e->sym() ){
			out<<"\tdd\t"<<t->value<<'\n';
		}else if( CGLea *t=e->lea() ){
			CGMem *m=t->exp->mem();
			assert(m);
			if( CGReg *t=m->exp->reg() ){
				out<<"\tdd\t"<<m->offset<<'\n';
			}else if( CGSym *t=m->exp->sym() ){
				assert(t);
				if( m->offset ){
					out<<"\tdd\t"<<t->value<<'+'<<m->offset<<'\n';
				}else{
					out<<"\tdd\t"<<t->value<<'\n';
				}
			}else{
				assert(0);
			}
		}else{
			fail( "cgmodule_x86::emitData - unrecognized data format" );
		}
	}
}

void CGModule_X86::emitFooter(){
}
