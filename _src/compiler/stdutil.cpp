
#include "stdutil.h"

#include <errno.h>
#include <sys/types.h>

bool	opt_trace;		//-z BMK0: trace dependancies
string  opt_outfile;	//-o BMK0: output exe

bool	opt_quiet;		//-q
bool	opt_verbose;	//-v
bool	opt_makeall;	//-a
bool	opt_debug;		//-d
bool	opt_release;	//-r
bool opt_threaded;
string  opt_arch;		//-g x86/ppc
string  opt_apptype;	//-t apptype
string  opt_module;		//-m 'modname'
string  opt_framework;  //-f 'modname' or "*"
string  opt_infile;

set<string> env_config;
string  env_blitzpath,env_platform,env_binpath,env_libpath,config_mung,global_mung;

#if _WIN32

static void init_env(){
	char path[1024]={0};
	GetModuleFileName( GetModuleHandle(0),path,1024 );
	string t=path;
	int n=t.rfind( "\\bin\\" );
	if( n==string::npos ) n=t.rfind( "\\BIN\\" );
	if( n==string::npos ) abort();
	env_blitzpath=t.substr(0,n);

	env_platform="win32";
}

#elif __APPLE__

static void init_env(){

	CFURLRef url;
	char path[1024],*p;
	
	url=CFBundleCopyExecutableURL( CFBundleGetMainBundle() );
	CFURLGetFileSystemRepresentation( url,true,(UInt8*)path,1024 );
	
	string t=path;
	int n=t.rfind( "/bin/" );
	if( n==string::npos ) abort();
	env_blitzpath=t.substr(0,n);

	env_platform="macos";
}

#elif __linux

static void init_env(){

	char	linkname[256];			// /proc/<pid>/exe
	char	path[1024]={0};
	pid_t	pid;
	int		ret;

	pid=getpid();
	sprintf(linkname, "/proc/%i/exe", pid);
	ret=readlink(linkname, path,1024);
	if (ret<1 ||  ret>1022) abort();
	path[ret]=0;

	string t=path;
	int n=t.rfind( "/bin/" );
	if( n==string::npos ) abort();
	env_blitzpath=t.substr(0,n);

	env_platform="linux";
}

#else

#error "Unsuppported build platform"

#endif

void stdutil_init( int argc,char *argv[] ){
	
	init_env();

	fixpath( env_blitzpath );
	
	env_binpath=env_blitzpath+"/bin";
	env_libpath=env_blitzpath+"/lib";

#if __APPLE__
#if __ppc__
	if( is_pid_native(0) ) opt_arch="ppc"; else opt_arch="x86";
#elif __i386__
	if( is_pid_native(0) ) opt_arch="x86"; else opt_arch="ppc";
#endif
#else	
	opt_arch="x86";
#endif
	opt_debug=true;
	opt_release=false;

	for( int k=1;k<argc;++k ){
		char *t=argv[k];
		if( t[0]!='-' ){
			if( opt_infile.size() ) fail( "Only one input file may be specified" );
			opt_infile=realpath(t);
			continue;
		}
		switch( t[1] ){
		case 'q':
			opt_quiet=true;
			break;
		case 'v':
			opt_verbose=true;
			break;
		case 'a':
			opt_makeall=true;
			break;
		case 'd':
			opt_debug=true;
			opt_release=false;
			break;
		case 'r':
			opt_debug=false;
			opt_release=true;
			break;
		case 'h':
			opt_threaded=true;
			break;
		case 'z':
			opt_trace=true;
			break;
		case 't':
			if( ++k<argc ) opt_apptype=tolower(argv[k]);
			else fail( "Command line error" );
			break;
		case 'g':
			if( ++k<argc ) opt_arch=tolower(argv[k]);
			else fail( "Command line error" );
			break;
		case 'm':
			if( ++k<argc ) opt_module=tolower(argv[k]);
			else fail( "Command line error" );
			break;
		case 'f':
			if( ++k<argc ) opt_framework=tolower(argv[k]);
			else fail( "Command line error" );
			break;
		case 'o':
			if( ++k<argc ) opt_outfile=realpath( argv[k] );
			else fail( "Command line error" );
			break;
		default:
			fail( "Command line error" );
		}
	}
	
	if( opt_arch=="ppc" ){
		env_config.insert( "bigendian" );
	}else if( opt_arch=="x86" ){
		env_config.insert( "littleendian" );
	}else{
		fail( "Command line error" );
	}

	env_config.insert( opt_arch );
	env_config.insert( env_platform );
	env_config.insert( env_platform+opt_arch );
	env_config.insert( opt_debug ? "debug" : "release" );
	if( opt_threaded ) env_config.insert( "threaded" );

	config_mung=opt_debug ? "debug" : "release";
	if( opt_threaded ) config_mung+=".mt";
	config_mung="."+config_mung+"."+env_platform+"."+opt_arch;
	
	if( opt_module.size() ){
		vector<string> ids;
		splitModule( opt_module,ids );
		int k;
		for( k=0;k<ids.size();++k ) global_mung+=ids[k]+"_";
	}else{
		global_mung="bb_";
	}
}

void fixpath( string &path ){
	int i;
	for( i=0;i<path.size();++i ){
		if( path[i]=='\\' ) path[i]='/';
	}
}

void sys( string cmd ){
	if( opt_verbose ) cout<<cmd<<endl;
#if _WIN32
	// simon was here with win98 cludge
	char path[8192];
	int i,n;
	n=_snprintf(path,8192,cmd.c_str());
	for (i=0;i<n;i++)
	{
		if (path[i]==0) break;
		if (path[i]=='/') path[i]='\\';
	}
//	printf("%d%s",n,path);
	if( system( path ) ) 
		exit(-1);
#else	
	if( system( cmd.c_str() ) ) 
		exit(-1);
#endif
}

string modulePath( string mod,bool create ){
	
	string path=env_blitzpath+"/mod";
	if( !mod.size() ) return path;
	mod+=".";
	
	while( mod.size() ){
		int i=mod.find( '.' );
		string t=mod.substr(0,i);
		mod=mod.substr(i+1);
		path+='/'+t+".mod";
		if( create ){
			mkdir( path.c_str(),0777 );
			if( !ftime(path) ) fail( "mkdir failed!" );
		}
	}
	return path;
}

void splitModule( string mod,vector<string> &ids ){
	if( !mod.size() ) return;
	int i;
	while( (i=mod.find('.'))!=string::npos ){
		ids.push_back(mod.substr(0,i));
		mod=mod.substr(i+1);
	}
	ids.push_back(mod);
}

string moduleIdent( string mod ){
	int i=mod.rfind('.');
	return i==string::npos ? mod : mod.substr(i+1);
}

string moduleInterface( string mod ){
	string path=modulePath( mod,false )+"/"+moduleIdent(mod)+config_mung+".i";
	if( ftime( path ) ) return path;
	fail( "Can't find interface for module '%s'",mod.c_str() );
	return "";
/*
	string path=modulePath( mod,false );

	string d_ext=".debug."+env_platform+"."+opt_arch+".i";
	string r_ext=".release."+env_platform+"."+opt_arch+".i";

	string f1=path+"/"+moduleIdent(mod)+r_ext;
	string f2=path+"/"+moduleIdent(mod)+d_ext;
	if( opt_debug ) std::swap(f1,f2);
	if( ftime(f1) ) return f1;
	if( ftime(f2) ) return f2;
	
	fail( "Can't find interface for module '%s'",mod.c_str() );
	return "";
*/
}

void enumModules( string mod,vector<string> &mods ){
	string path=modulePath( mod,false );
	
	DIR *d=opendir( path.c_str() );
	if( !d ) return;
	
	string d_ext=".debug."+env_platform+"."+opt_arch+".i";
	string r_ext=".release."+env_platform+"."+opt_arch+".i";

	while( dirent *e=readdir( d ) ){
		string f=e->d_name;
		if( getext(f)!="mod" ) continue;
		string id=stripall(f);
		string tmod=mod.size() ? mod+"."+id : id;
		enumModules( tmod,mods );
		string path=modulePath( tmod,false )+"/"+id;
		if( ftime(path+d_ext) || ftime(path+r_ext) ){
			mods.push_back( tmod );
		}
	}
	closedir(d);
}

time_t	ftime( string path ){
    struct stat st;
	fixpath(path);
	if( !stat( path.c_str(),&st ) ) return st.st_mtime;
	return 0;
}

string getcwd(){
	char buf[256];
	if( !getcwd( buf,255 ) ) fail( "getcwd failed" );
	string path=string(buf);
	fixpath(path);
	return buf;
}

void setcwd( string path ){
	fixpath(path);
	chdir( path.c_str() );
}

string	getdir( string path ){
	fixpath(path);
	int n=path.rfind( '/' );
	if( n==string::npos ) return "";
	return path.substr(0,n);
}

string	getext( string path ){
	fixpath(path);
    int n=path.rfind( '.' );
    if( n==string::npos ) return "";
	if( path.find( '/',n+1 )!=string::npos ) return "";
    return path.substr(n+1);
}

string	stripdir( string path ){
	fixpath(path);
	int n=path.rfind( '/' );
	if( n==string::npos ) n=path.rfind( '\\' );
	if( n==string::npos ) return path;
	return path.substr(n+1);
}

string	stripext( string path ){
	fixpath(path);
    int n=path.rfind( '.' );
    if( n==string::npos ) return path;
	if( path.find( '/',n+1 )!=string::npos ) return path;
	if( path.find( '\\',n+1 )!=string::npos ) return path;
    return path.substr(0,n);
}

string	stripall( string path ){
	return stripext(stripdir(path));
}

string realpath( string path ){
	fixpath(path);
	string dir=getdir(path);
	string file=stripdir(path);
	static char buf[MAX_PATH+8];
	if( dir.size() ){
//		printf( "Calling realpath( %s ), MAX_PATH=%i PATH_MAX=%i\n",dir.c_str(),MAX_PATH,PATH_MAX );fflush( stdout );
		if( !_realpath( dir.c_str(),buf ) ){
			fail( "realpath failed for %s",path.c_str() );
		}
		dir=buf;
	}else{
		dir=getcwd();
	}
	fixpath( dir );
	return dir+"/"+file;
}

string tolower( string t ){
	for( int k=0;k<t.size();++k ){
		t[k]=tolower(t[k]);
	}
	return t;
}

int64 toint( string t ){
	if( !t.size() ) return 0;
	int i,sgn=1;
	for( i=0;i<t.size() && (t[i]=='+' || t[i]=='-');++i ) if( t[i]=='-' ) sgn=-sgn;
	int64 n=0;
	if( t[i]=='%' ){
		for( ++i;i<t.size();++i ){
			int c=t[i];
			if( c!='0' && c!='1' ) break;
			n=n*2+(c-'0');
		}
	}else if( t[i]=='$' ){
		for( ++i;i<t.size();++i ){
			int c=toupper(t[i]);
			if( !isxdigit(c) ) break;
			if( c>='A' ) c-=('A'-'0'-10);
			n=n*16+(c-'0');
		}
	}else{
		for( ;i<t.size();++i ){
			int c=t[i];
			if( !isdigit(c) ) break;
			n=n*10+(c-'0');
		}
	}
	return sgn>0 ? n : -n;
}

double tofloat( string t ){
	double zero=0.0;
	string q=tolower(t);
	if( q=="nan#" ){
		return 0.0/zero;
	}else if( q=="inf#" || q=="+inf#" ){
		return 1.0/zero;
	}else if( q=="-inf#" ){
		return -1.0/zero;
	}
	return atof(t.c_str());
}

string fromint( int64 n ){
//	Can't use %lld 'coz it doesn't work on mingw!
//	char buf[64];
//	sprintf( buf,"%lld",n );
//	return buf;
	char buf[64],*p=buf+64;
	int neg=n<0;
	if( neg ){
		n=-n;
		if( n<0 ) return "-9223372036854775808";
	}
	*--p=0;
	do{
		*--p=n%10+'0';
	}while(n/=10);
	if( neg ) *--p='-';
	return p;
}

string fromfloat( float n ){
	char buf[64];
	if( isnan(n) ){
		sprintf( buf,"nan" );
	}else if( isinf(n) ){
		if( n>0 ) sprintf( buf,"inf" );
		else sprintf( buf,"-inf" );
	}else{
		sprintf( buf,"%#.9g",n );
	}
	return buf;
}

string fromdouble( double n ){
	char buf[64];
	if( isnan(n) ){
		sprintf( buf,"nan" );
	}else if( isinf(n) ){
		if( n>0 ) sprintf( buf,"inf" );
		else sprintf( buf,"-inf" );
	}else{
		sprintf( buf,"%#.17lg",n );
	}
	return buf;
}

string tostring( bstring w ){
	string t;
	t.resize(w.size());
	for( int k=0;k<t.size();++k ) t[k]=w[k];
	return t;
}

bstring tobstring( string t ){
	bstring w;
	w.resize(t.size());
	for( int k=0;k<w.size();++k ) w[k]=t[k] & 0xff;
	return w;
}

bstring tobstring( const char *p ){
	bstring w;
	w.resize(strlen(p));
	for( int k=0;k<w.size();++k ) w[k]=p[k] & 0xff;
	return w;
}

string source_info;

void fail( const char *fmt,... ){

	char buf[256];

	va_list args;
	va_start( args,fmt );
	vsprintf( buf,fmt,args );
	
	cerr<<"Compile Error: "<<buf<<endl;
	if( source_info.size() ) cerr<<"["<<source_info<<"]"<<endl;

	exit(-1);
}

#if __APPLE__

#include <sys/sysctl.h>

static int sysctlbyname_with_pid (const char *name, pid_t pid, 
                            void *oldp, size_t *oldlenp, 
                            void *newp, size_t newlen)
{
	if (pid == 0) {
		if (sysctlbyname(name, oldp, oldlenp, newp, newlen) == -1) {
			return -1;
		}
	}else{
		int mib[CTL_MAXNAME];
		size_t len = CTL_MAXNAME;
		if (sysctlnametomib(name, mib, &len) == -1) {
			return -1;
		}
		mib[len] = pid;
		len++;
		if (sysctl(mib, len, oldp, oldlenp, newp, newlen) == -1)  {
			return -1;
		}
	}
	return 0;
}

int is_pid_native (pid_t pid)
{
	int ret = 0;
	size_t sz = sizeof(ret);
 
	if (sysctlbyname_with_pid("sysctl.proc_native", pid, &ret, &sz, NULL, 0) == -1) {
		if (errno == ENOENT) {
			// sysctl doesn't exist, which means that this version of Mac OS 
			// pre-dates Rosetta, so the application must be native.
			return 1;
		}
		return -1;
	}
	return ret;
}
#endif
