
#include "std.h"
#include "block.h"

int strictMode;
FunBlock *mainFun;				//main function

DeclSeq rootScope;
DeclSeq objectExports;			//exports from this object file
DeclSeq moduleExports;			//exports from this and imported object files
vector<string> objectImports;   //imports to this object file
vector<string> moduleImports;   //imports to this object file
vector<string> moduleInfos;

string globalIdent;

set<string> importedSources;	//source files already imported

string fixIdent( string id ){
	int k;
	for( k=0;k<id.size();++k ){
		if( !isalnum(id[k]) && id[k]!='_' ) id[k]='_';
	}
	return id;
}

void publish( Decl *d ){
	objectExports.push_back(d);
	moduleExports.push_back(d);
}

Val *findGlobal( string id ){
	int k;
	Val *v=0;
	string mod;
	for( k=rootScope.size()-1;k>=0;--k ){
		if( Val *t=rootScope[k]->val->find(id) ){
			if( v ){
				fail( "Duplicate identifier '%s' in modules '%s' and '%s'",id.c_str(),mod.substr(1).c_str(),rootScope[k]->ident.substr(1).c_str() );
				dupid( id );
			}
			mod=rootScope[k]->ident;
			v=t;
		}
	}
	if( v ) globalIdent=mod.substr(1)+"."+id;
	return v;
}

CGDat *genDebugStm( string t ){
	CGDat *d=CG::dat();
	int i1=t.find(';');
	if( i1!=string::npos ){
		int i2=t.find(';',i1+1);
		if( i2!=string::npos ){
			string f=t.substr(0,i1);
			string l=t.substr(i1+1,i2-i1-1);
			string c=t.substr(i2+1);
			fixpath( f );
			if( !f.find(env_blitzpath+"/") ) f="$BMXPATH"+f.substr(env_blitzpath.size());
			d->push_back( genCString(f) );
			d->push_back( CG::lit(int(toint(l))) );
			d->push_back( CG::lit(int(toint(c))) );
			return d;
		}
	}
	return 0;
}

CGDat *genCString( string t ){
	static map<string,CGDat*> c_strings;
	map<string,CGDat*>::iterator it=c_strings.find(t);
	if( it!=c_strings.end() ) return it->second;
	CGDat *d=CG::dat();
	d->push_back( CG::lit(tobstring(t),CG_CSTRING) );
	c_strings.insert( make_pair(t,d) );
	return d;
}

CGDat *genBBString( bstring t ){
	static map<bstring,CGDat*> bb_strings;
	map<bstring,CGDat*>::iterator it=bb_strings.find(t);
	if( it!=bb_strings.end() ) return it->second;
	CGDat *d=CG::dat();
	d->push_back( CG::sym("bbStringClass",CG_IMPORT) );
	d->push_back( CG::lit(0x7fffffff) );
	d->push_back( CG::lit(t,CG_BSTRING) );
	bb_strings.insert( make_pair(t,d) );
	return d;
}

CGDat *genBBString2( bstring t ){
	static map<bstring,CGDat*> bb_strings2;
	map<bstring,CGDat*>::iterator it=bb_strings2.find(t);
	if( it!=bb_strings2.end() ) return it->second;
	CGDat *d=CG::dat();
	d->push_back( CG::sym("bbStringClass",CG_IMPORT) );
	d->push_back( CG::lit(0x7ffffffe) );
	d->push_back( CG::lit(t,CG_BSTRING) );
	bb_strings2.insert( make_pair(t,d) );
	return d;
}

string mungGlobal( string decl_id ){
	return global_mung+decl_id;
}

string mungMember( string class_id,string decl_id ){
	return "_"+global_mung+class_id+"_"+decl_id;
}

string mungObjectEntry( string path ){
	path=tolower(realpath(path));
	string dir=stripall(getdir(path));
	return "__bb_"+fixIdent(dir)+"_"+fixIdent(stripall(path));
}

string mungModuleEntry( string mod ){
	string id=moduleIdent(mod);
//#if DEMO_VERSION
//	if( id!="appstub" ) return "__bb_"+id+"_"+id+"_";
//#endif
	return "__bb_"+id+"_"+id;
}

void dupid( string id,const char *fmt ){
	fail( fmt,id.c_str() );
}

void badid( string id,const char *fmt ){
	fail( fmt,id.c_str() );
}

void badty( string id,const char *fmt ){
	fail( fmt,id.c_str() );
}

void badmod( string id,const char *fmt ){
	fail( fmt,id.c_str() );
}

static void escErr(){
	fail( "Bad escape sequence in string" );
}

bstring escapeString( bstring t ){
	bstring r;
	r.reserve( t.size() );
	int i=0;
	while( i<t.size() ){
		int c=t[i++],esc;
		switch( c ){
		case '~':
			esc='~';
			break;
		case '\0':
			esc='0';
			break;
		case '\t':
			esc='t';
			break;
		case '\r':
			esc='r';
			break;
		case '\n':
			esc='n';
			break;
		case '\"':
			esc='q';
			break;
		default:
			if( c>=32 && c<127 ){
				r+=bchar_t(c);
			}else{
				char buf[32];
				sprintf( buf,"~%i~",c );
				r+=tobstring(buf);
			}
			continue;
		}
		r+=bchar_t('~');
		r+=bchar_t(esc);
	}
	return r;
}

bstring unescapeString( bstring t ){
	bstring r;
	r.reserve( t.size() );
	int i=0;
	while( i<t.size() ){
		int c=t[i++];
		if( c!='~' ){
			r+=bchar_t(c);
			continue;
		}
		if( i==t.size() ) escErr();
		c=t[i++];
		switch( c ){
		case '~':
			r+=bchar_t('~');
			break;
		case '0':
			r+=bchar_t('\0');
			break;
		case 't':
			r+=bchar_t('\t');
			break;
		case 'r':
			r+=bchar_t('\r');
			break;
		case 'n':
			r+=bchar_t('\n');
			break;
		case 'q':
			r+=bchar_t('\"');
			break;
		default:
			if( c>='1' && c<='9' ){
				int n=0;
				while( c>='0' && c<='9' ){
					n=n*10+(c-'0');
					if( i==t.size() ) escErr();
					c=t[i++];
				}
				if( c!='~' ) escErr();
				r+=bchar_t(n);
			}else{
				escErr();
			}
		}
	}
	return r;
}
