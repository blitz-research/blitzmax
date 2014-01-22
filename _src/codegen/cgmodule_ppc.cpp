
#include "cgstd.h"
#include "cgdebug.h"

#include "cgmodule_ppc.h"

CGModule_PPC::CGModule_PPC( ostream &o ):CGModule(o),fp_const(0){
}

void CGModule_PPC::setSeg( string t ){
	if( t==seg ) return;
	seg=t;
	out<<"\t."<<seg<<'\n';
}

CGFrame *CGModule_PPC::frame( CGFun *f ){
	return new CGFrame_PPC( f,this );
}

void CGModule_PPC::emitHeader(){
}

void CGModule_PPC::emitImport( string t ){
	out<<"\t.non_lazy_symbol_pointer\n";
	out<<""<<t<<"$non_lazy_ptr:\n";
	out<<"\t.indirect_symbol\t"<<t<<"\n";
	out<<"\t.long\t0\n";
}

void CGModule_PPC::emitExport( string t ){
	out<<"\t.globl\t"<<t<<'\n';
}

void CGModule_PPC::emitFrame( CGFrame *f ){

	CGFrame_PPC *frame=dynamic_cast<CGFrame_PPC*>(f);
	assert(frame);
	
	setSeg( "text" );
	
	//find callee-save regs
	int k,max_int=12,max_flt=13;
	
	for( k=64;k<frame->regs.size();++k ){
		CGReg *r=frame->regs[k];
		if( r->isfloat() ){
			if( r->color>=14 && r->color<=31 && r->color>max_flt ) max_flt=r->color;
		}else{
			if( r->color>=13 && r->color<=31 && r->color>max_int ) max_int=r->color;
		}
	}
	
	int int_save=max_int-12;
	int flt_save=max_flt-13;
	int save_sz=int_save*4+flt_save*8;
	
	int stack_sz=24+frame->param_sz+frame->local_sz+save_sz;
	stack_sz=(stack_sz+15)&~15;
	
	//emit label
	out<<frame->fun->sym->value<<":\n";

	//setup frames
	out<<"__LOCAL="<<(24+frame->param_sz)<<'\n';
	out<<"__FRAME="<<stack_sz<<'\n';	

	//get link register
	out<<"\tmflr\tr0\n";

	//save float regs
	for( k=0;k<flt_save;++k ){
		out<<"\tstfd\tf"<<(k+14)<<","<<(-save_sz+int_save*4+k*8)<<"(r1)\n";
	}
	//save int regs
	if( int_save ){
		out<<"\tstmw\tr"<<(32-int_save)<<","<<(-save_sz)<<"(r1)\n";
	}

	//save link register
	out<<"\tstw\tr0,8(r1)\n";

	//allocate frame
	out<<"\tstwu\tr1,"<<-stack_sz<<"(r1)\n";

	CGAsm *as;
	for( as=frame->assem.begin;as!=frame->assem.end;as=as->succ ){
		if( as->stm->ret() ){
			out<<"\tlwz\tr1,0(r1)\n";
			out<<"\tlwz\tr0,8(r1)\n";
			out<<"\tmtlr\tr0\n";
			//restore int regs
			if( int_save ){
				out<<"\tlmw\tr"<<(32-int_save)<<","<<(-save_sz)<<"(r1)\n";
			}
			//restore float regs
			for( int k=flt_save-1;k>=0;--k ){
				out<<"\tlfd\tf"<<(k+14)<<","<<(-save_sz+int_save*4+k*8)<<"(r1)\n";
			}
		}

		const char *p=as->assem;
		if( !p ) continue;

		out<<p;
	}
}

void CGModule_PPC::emitData( CGDat *d ){

	setSeg( "data" );

	out<<"\t.align\t2\n";
	out<<d->value<<":\n";

	for( int k=0;k<d->exps.size();++k ){

		CGExp *e=d->exps[k];
		
		if( CGLit *t=e->lit() ){
			if( t->type==CG_INT8 ){
				out<<"\t.byte\t"<<unsigned(t->int_value)<<'\n';
			}else if( t->type==CG_INT16 ){
				out<<"\t.short\t"<<unsigned(t->int_value)<<'\n';
			}else if( t->type==CG_INT32 ){
				out<<"\t.long\t"<<int(t->int_value)<<'\n';
			}else if( t->type==CG_INT64 ){
				out<<"\t.long\t"<<int(t->int_value>>int64(32))<<','<<int(t->int_value)<<'\n';
			}else if( t->type==CG_FLOAT32 ){
				float f=t->float_value;
				out<<"\t.long\t0x"<<hex<<*((int*)&f)<<dec<<'\n';
			}else if( t->type==CG_FLOAT64 ){
				double f=t->float_value;
				out<<"\t.long\t0x"<<hex<<*((int*)&f+0)<<",0x"<<*((int*)&f+1)<<dec<<'\n';
			}else if( t->type==CG_CSTRING ){
				bstring s=t->string_value;
				out<<"\t.asciz\t\"";
				for( int k=0;k<s.size();++k ){
					if( s[k]==34 ){
						out<<"\\\"";
					}else{
						out<<(char)s[k];
					}
				}
				out<<"\"\n";
			}else if( t->type==CG_BSTRING ){
				bstring s=t->string_value;
				out<<"\t.long\t"<<s.size();
				for( int k=0;k<s.size();++k ){
					if( k%16 ) out<<','<<(unsigned)(unsigned short)s[k];
					else out<<"\n\t.short\t"<<(unsigned)(unsigned short)s[k];
				}
				out<<"\n";
			}else if( t->type==CG_BINFILE ){
				string file=tostring(t->string_value);
				ifstream is( file.c_str() );
				if( !is.good() ) fail( "Unable to read from file '%s'",file.c_str() );
				for(;;){
					char buf[16];
					is.read( buf,16 );
					int n=is.gcount();
					if( !n ) break;
					out<<"\t.byte\t";
					for( int k=0;k<n;++k ){
						if( k ) out<<',';
						out<<(unsigned)(unsigned char)buf[k];
					}
					out<<'\n';
				}
				is.close();
			}else if( t->type==CG_LABEL ){
				out<<tostring(t->string_value)<<":\n";
			}else{
				assert(0);
			}
		}else if( CGSym *t=e->sym() ){
			out<<"\t.long\t"<<t->value<<'\n';
		}else if( CGLea *t=e->lea() ){
			CGMem *m=t->exp->mem();
			assert(m);
			if( m->flags==1 ){  //PARAM
			}else if( m->flags==2 ){	//LOCAL
				out<<"\t.long\t"<<m->offset<<'\n';
			}else if( CGSym *t=m->exp->sym() ){
				assert(t);
				if( m->offset ){
					out<<"\t.long\t"<<t->value<<'+'<<m->offset<<'\n';
				}else{
					out<<"\t.long\t"<<t->value<<'\n';
				}
			}else{
				assert(0);
			}
		}else{
			cout<<e<<endl;
			assert(0);
		}
	}
}

void CGModule_PPC::emitFooter(){
	//emit fp_const
	if( fp_const ){
		setSeg( "data" );
		out<<fp_const->value<<":\n";
		out<<"\t.double\t0r4.50360177485414400000e15\n";
	}
}
