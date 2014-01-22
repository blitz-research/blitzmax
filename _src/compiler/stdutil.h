
#ifndef STDUTIL_H
#define STDUTIL_H

#include <set>
#include <map>
#include <vector>
#include <string>
#include <fstream>
#include <iostream>

#include <math.h>
#include <time.h>
#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <stdlib.h>
#include <sys/stat.h>

#if _WIN32

#include <windows.h>
#include <direct.h>
#define mkdir(X,Y) mkdir(X)
#define _realpath(X,Y) _fullpath(Y,X,MAX_PATH)

#elif __APPLE__

#include <unistd.h>
#define _realpath realpath
#include <signal.h>
#include <ApplicationServices/ApplicationServices.h>
int is_pid_native (pid_t pid);

//only need these with gcc-3.3 : error with gcc4
#ifndef isnan
extern "C"{
int isnan( double n );
int isinf( double n );
}
#endif

#elif __linux

#include <unistd.h>
#define _realpath realpath

#endif

#include <dirent.h>

#ifndef MAX_PATH
#if PATH_MAX
#define MAX_PATH PATH_MAX
#else
#define MAX_PATH 4096
#endif
#endif

#ifdef NDEBUG
#undef NDEBUG
#include <assert.h>
#define NDEBUG
#else
#include <assert.h>
#endif

typedef long long int64;

//wchar_t and wstring a total nightmare to get going - roll our own for now!

typedef unsigned short bchar_t;

namespace std{
	template<> struct char_traits<bchar_t>{
	typedef bchar_t char_type;
	typedef int int_type;
	static void assign( char_type &c,char_type a ){
		c=a;
	}
	static size_t length( const char_type *s ){
		int n=0;
		while( *s++ ) ++n;
		return n;
	}
	static char_type *assign( char_type *s,size_t n,char_type a ){
		for( size_t k=0;k<n;++k ) s[k]=a;
		return s;
	}
	static char_type *copy( char_type *s1,const char_type *s2,size_t n ){
		return static_cast<char_type*>( memcpy(s1,s2,n*sizeof(char_type)) );
	}
	static char_type *move( char_type *s1,const char_type *s2,size_t n ){
		return static_cast<char_type*>( memmove(s1,s2,n*sizeof(char_type)) );
	}
	static const char_type *find( const char_type *s,size_t n,char_type c ){
		for( size_t k=0;k<n;++k ) if( s[k]==c ) return s+k;
		return 0;
	}
	static int compare( const char_type *s1,const char_type *s2,size_t n ){
		for( size_t k=0;k<n;++k ) if( int t=s1[k]-s2[k] ) return t;
		return 0;
	}
};
}

using namespace std;

typedef basic_string<bchar_t> bstring;

extern	bool	opt_trace;	//-z BMK0: trace dependancies
extern  string  opt_outfile;	//-o BMK0: output exe

extern  bool	opt_quiet;	//-q
extern  bool	opt_verbose;	//-v
extern  bool	opt_makeall;	//-a
extern  bool	opt_debug;	//-d
extern  bool	opt_release;	//-r
extern  bool	opt_threaded;	//-h
extern  string  opt_arch;	//-g x86/ppc
extern  string  opt_apptype;	//-t apptype
extern  string  opt_module;	//-m 'modname'
extern  string  opt_framework;//-f 'modname' or "*"
extern  string  opt_infile;

extern  set<string> env_config;
extern  string  env_blitzpath,env_platform,env_binpath,env_libpath,config_mung,global_mung;

void	stdutil_init( int argc,char *argv[] );

//convert a dotted mod name to a path
string  modulePath( string mod,bool create );

//split module components
void	splitModule( string mod,vector<string> &idents );

//extract last component of a dotted mod name
string  moduleIdent( string mod );

//return interface (.i) file for a module
string  moduleInterface( string mod );

//enumerate modules starting with 'mod'
void	enumModules( string mod,vector<string> &mods );

void	sys( string cmd );
string  getcwd();
void	setcwd( string dir );
time_t  ftime( string path );
string  getdir( string path );
string  getext( string path );
void	fixpath( string &path );
string  stripdir( string path );
string  stripext( string path );
string  stripall( string path );
string  realpath( string path );

int64   toint( string t );
double  tofloat( string t );
string  fromint( int64 n );
string  fromfloat( float n );
string  fromdouble( double n );
string  tolower( string str );
string  tostring( bstring w );
bstring tobstring( string t );
bstring tobstring( const char *p );

extern  string source_info;

void fail( const char *fmt,... );

#endif
