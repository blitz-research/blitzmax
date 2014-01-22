
#include <brl.mod/blitz.mod/blitz.h>

#include <stdio.h>
#include <dirent.h>
#include <sys/stat.h>

#if _WIN32

#include <time.h>
#include <direct.h>

#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <winsock.h>

extern int _bbusew;

#else

#include <time.h>
#include <unistd.h>
#include <limits.h>	//PATH_MAX
#include <sys/time.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>

#endif
 
int stdin_;
int stdout_;
int stderr_;

#if _WIN32

int getchar_(){
	if( _bbusew ) return getwchar();
	return getchar();
}

int puts_( BBString *str ){
	if( _bbusew ) return _putws( bbTmpWString(str) );
	return puts( bbTmpCString(str) );
}

int putenv_( BBString *str ){
	if( _bbusew ) return _wputenv( bbTmpWString(str) );
	return putenv( bbTmpCString(str) );
}

BBString *getenv_( BBString *str ){
	if( _bbusew ) return bbStringFromWString( _wgetenv( bbTmpWString(str) ) );
	return bbStringFromCString( getenv( bbTmpCString(str) ) );
}

int fputs_( BBString *str,int file ){
	if( _bbusew ) return fputws( bbTmpWString(str),(FILE*)file );
	return fputs( bbTmpCString(str),(FILE*)file );
}

int chdir_( BBString *path ){
	if( _bbusew ) return _wchdir( bbTmpWString(path) );
	return _chdir( bbTmpCString(path) );
}

int fopen_( BBString *file,BBString *mode ){
	if( _bbusew ) return (int)_wfopen( bbTmpWString(file),bbTmpWString(mode) );
	return (int)fopen( bbTmpCString(file),bbTmpCString(mode) );
}

BBString *getcwd_(){
	if( _bbusew ){
		wchar_t buf[MAX_PATH];
		_wgetcwd( buf,MAX_PATH );
		return bbStringFromWString( buf );
	}else{
		char buf[MAX_PATH];
		_getcwd( buf,MAX_PATH );
		return bbStringFromCString( buf );
	}
	return &bbEmptyString;
}

int chmod_( BBString *path,int mode ){
	if( _bbusew ) return _wchmod( bbTmpWString(path),mode );
	return _chmod( bbTmpCString(path),mode );
}

int mkdir_( BBString *path,int mode ){
	if( _bbusew ) return _wmkdir( bbTmpWString(path) );
	return _mkdir( bbTmpCString(path) );
}

int rmdir_( BBString *path ){
	if( _bbusew ) return _wrmdir( bbTmpWString(path) );
	return _rmdir( bbTmpCString(path) );
}

int rename_( BBString *src,BBString *dst ){
	if( _bbusew ) return _wrename( bbTmpWString(src),bbTmpWString(dst) );
	return rename( bbTmpCString(src),bbTmpCString(dst) );
}

void remove_( BBString *path ){
	chmod_( path,0x1b6 );
	if( _bbusew ){
		_wremove( bbTmpWString(path) );
	}else{
		remove( bbTmpCString(path) );
	}
}

int opendir_( BBString *path ){
	if( _bbusew ) return (int)_wopendir( bbTmpWString(path) );
	return (int)opendir( bbTmpCString(path) );
}

int closedir_( int dir ){
	if( _bbusew ) return _wclosedir( (_WDIR*)dir );
	return closedir( (DIR*)dir );
}

BBString *readdir_( int dir ){
	if( _bbusew ){
		struct _wdirent *t=_wreaddir( (_WDIR*)dir );
		return t ? bbStringFromWString( t->d_name ) : &bbEmptyString;
	}
	struct dirent *t=readdir( (DIR*)dir );
	return t ? bbStringFromCString( t->d_name ) : &bbEmptyString;
}

int stat_( BBString *path,int *t_mode,int *t_size,int *t_mtime,int *t_ctime ){
	int i;
	struct _stat st;
	
	for( i=0;i<path->length;++i ){
		if( path->buf[i]=='<' || path->buf[i]=='>' ) return -1;
	}
	
	if( _bbusew ){
		if( _wstat( bbTmpWString(path),&st ) ) return -1;
	}else{
		if( _stat( bbTmpCString(path),&st ) ) return -1;
	}

	*t_mode=st.st_mode;
	*t_size=st.st_size;
	*t_mtime=st.st_mtime;
	*t_ctime=st.st_ctime;
	return 0;
}

int system_( BBString *cmd ){
	int res;
	PROCESS_INFORMATION pi={0};
	
	if( _bbusew ){
		STARTUPINFOW si={sizeof(si)};
		wchar_t *tmp=bbTmpWString(cmd);
	
		if( CreateProcessW( 0,tmp,0,0,1,CREATE_DEFAULT_ERROR_MODE,0,0,&si,&pi ) ){
			WaitForSingleObject( pi.hProcess,INFINITE );
	
			res=GetExitCodeProcess( pi.hProcess,(DWORD*)&res ) ? res : -1;
	
			CloseHandle( pi.hProcess );
			CloseHandle( pi.hThread );
		}else{
			res=GetLastError();
		}
		
	} else {
		STARTUPINFO si={sizeof(si)};
		char *tmp=bbTmpCString(cmd);
	
		if( CreateProcessA( 0,tmp,0,0,1,CREATE_DEFAULT_ERROR_MODE,0,0,&si,&pi ) ){
			WaitForSingleObject( pi.hProcess,INFINITE );
	
			res=GetExitCodeProcess( pi.hProcess,(DWORD*)&res ) ? res : -1;
	
			CloseHandle( pi.hProcess );
			CloseHandle( pi.hThread );
		}else{
			res=GetLastError();
		}
	}
	return res;
}

#else

int getchar_(){
	return getchar();
}

int puts_( BBString *str ){
	return puts( bbTmpUTF8String( str ) );
}

int putenv_( BBString *str ){
	char *t=bbTmpUTF8String( str );
	char *p=(char*)malloc( strlen(t)+1 );
	strcpy( p,t );
	return putenv( p );
}

BBString *getenv_( BBString *str ){
	return bbStringFromUTF8String( getenv( bbTmpUTF8String(str) ) );
}

int fopen_( BBString *file,BBString *mode ){
	return fopen( bbTmpUTF8String(file),bbTmpUTF8String(mode) );
}

int fputs_( BBString *str,int file ){
	return fputs( bbTmpUTF8String(str),(FILE*)file );
}

int chdir_( BBString *path ){
	return chdir( bbTmpUTF8String(path) );
}

BBString *getcwd_(){
	char buf[PATH_MAX];
	getcwd( buf,PATH_MAX );
	return bbStringFromUTF8String( buf );
}

int chmod_( BBString *path,int mode ){
	return chmod( bbTmpUTF8String(path),mode );
}

int mkdir_( BBString *path,int mode ){
	return mkdir( bbTmpUTF8String(path),mode );
}

int rmdir_( BBString *path ){
	return rmdir( bbTmpUTF8String(path) );
}

int rename_( BBString *src,BBString *dst ){
	return rename( bbTmpUTF8String(src),bbTmpUTF8String(dst) );
}

int remove_( BBString *path ){
	return remove( bbTmpUTF8String(path) );
}

int opendir_( BBString *path ){
	return opendir( bbTmpUTF8String(path) );
}

BBString *readdir_( int dir ){
	struct dirent *t=readdir( (DIR*)dir );
	return t ? bbStringFromUTF8String( t->d_name ) : &bbEmptyString;
}

int closedir_( int dir ){
	return closedir( (DIR*)dir );
}

int stat_( BBString *path,int *t_mode,int *t_size,int *t_mtime,int *t_ctime ){
	struct stat st;
	if( stat( bbTmpUTF8String(path),&st ) ) return -1;
	*t_mode=st.st_mode;
	*t_size=st.st_size;
	*t_mtime=st.st_mtime;
	*t_ctime=st.st_ctime;
	return 0;
}

int system_( BBString *cmd ){
	return system( bbTmpUTF8String(cmd) );
}

#endif


int htons_( int n ){
	return htons( n );
}

int ntohs_( int n ){
	return ntohs( n );
}

int htonl_( int n ){
	return htonl( n );
}

int ntohl_( int n ){
	return ntohl( n );
}

int socket_( int addr_type,int comm_type,int protocol ){
	return socket( addr_type,comm_type,protocol );
}

void closesocket_( int s ){
#if _WIN32
	closesocket( s );
#else
	close( s );
#endif
}

int bind_( int socket,int addr_type,int port ){
	int r;
	struct sockaddr_in sa;
	
	if( addr_type!=AF_INET ) return -1;

	memset( &sa,0,sizeof(sa) );
	sa.sin_family=addr_type;
	sa.sin_addr.s_addr=htonl(INADDR_ANY);
	sa.sin_port=htons( port );
	
	return bind( socket,(void*)&sa,sizeof(sa) );
}

char *gethostbyaddr_( void *addr,int addr_len,int addr_type ){
	struct hostent *e=gethostbyaddr( addr,addr_len,addr_type );
	return e ? e->h_name : 0;
}

char **gethostbyname_( BBString *name,int *addr_type,int *addr_len ){
	struct hostent *e=gethostbyname( bbTmpCString( name ) );
	if( !e ) return 0;
	*addr_type=e->h_addrtype;
	*addr_len=e->h_length;
	return e->h_addr_list;
}

int connect_( int socket,const char *addr,int addr_type,int addr_len,int port ){
	struct sockaddr_in sa;

	if( addr_type!=AF_INET ) return -1;
	
	memset( &sa,0,sizeof(sa) );
	sa.sin_family=addr_type;
	sa.sin_port=htons( port );
	memcpy( &sa.sin_addr,addr,addr_len );
	
	return connect( socket,(void*)&sa,sizeof(sa) );
}

int listen_( int socket,int backlog ){
	return listen( socket,backlog );
}

int accept_( int socket,const char *addr,unsigned int *addr_len ){
	return accept( socket,(void*)addr,addr_len );
}

int select_( int n_read,int *r_socks,int n_write,int *w_socks,int n_except,int *e_socks,int millis ){

	int i,n,r;
	struct timeval tv,*tvp;
	fd_set r_set,w_set,e_set;
	
	n=-1;
	
	FD_ZERO( &r_set );
	for( i=0;i<n_read;++i ){
		FD_SET( r_socks[i],&r_set );
		if( r_socks[i]>n ) n=r_socks[i];
	}
	FD_ZERO( &w_set );
	for( i=0;i<n_write;++i ){
		FD_SET( w_socks[i],&w_set );
		if( w_socks[i]>n ) n=w_socks[i];
	}
	FD_ZERO( &e_set );
	for( i=0;i<n_except;++i ){
		FD_SET( e_socks[i],&e_set );
		if( e_socks[i]>n ) n=e_socks[i];
	}
	
	if( millis<0 ){
		tvp=0;
	}else{
		tv.tv_sec=millis/1000;
		tv.tv_usec=(millis%1000)*1000;
		tvp=&tv;
	}
	
	r=select( n+1,&r_set,&w_set,&e_set,tvp );
	if( r<0 ) return r;
	
	for( i=0;i<n_read;++i ){
		if( !FD_ISSET(r_socks[i],&r_set) ) r_socks[i]=0;
	}
	for( i=0;i<n_write;++i ){
		if( !FD_ISSET(w_socks[i],&w_set) ) w_socks[i]=0;
	}
	for( i=0;i<n_except;++i ){
		if( !FD_ISSET(e_socks[i],&e_set) ) e_socks[i]=0;
	}
	return r;
}

int send_( int socket,const char *buf,int size,int flags ){
	return send( socket,buf,size,flags );
}

int sendto_( int socket,const char *buf,int size,int flags,int dest_ip,int dest_port ){
	struct	sockaddr_in sa;
	memset( &sa,0,sizeof(sa) );
	sa.sin_family=AF_INET;
	sa.sin_addr.s_addr=htonl( dest_ip );
	sa.sin_port=htons( dest_port );
	return sendto( socket,buf,size,flags,(void*)&sa,sizeof(sa));
}

int recv_( int socket,char *buf,int size,int flags ){
	return recv( socket,buf,size,flags );
}

int recvfrom_( int socket,char *buf,int size,int flags,int *_ip,int *_port){
	struct	sockaddr_in sa;
	int		sasize;
	int		count;
	memset( &sa,0,sizeof(sa) );
	sasize=sizeof(sa);
	count=recvfrom(socket,buf,size,flags,(void*)&sa,&sasize);
	*_ip=ntohl_(sa.sin_addr.s_addr);
	*_port=ntohs_(sa.sin_port);
	return count;
}

int setsockopt_( int socket,int level,int optname,const void *optval,int count){
	return setsockopt( socket,level,optname,optval,count);
}

int getsockopt_( int socket,int level,int optname,void *optval,int *count){
	return getsockopt( socket,level,optname,optval,count);
}

int shutdown_( int socket,int how ){
	return shutdown( socket,how );
}

int getsockname_( int socket,void *addr,int *len ){
	return getsockname( socket,addr,len );
}

int getpeername_( int socket,void *addr,int *len ){
	return getpeername( socket,addr,len );
}

void time_( void *ttime ){
	time( (time_t*)ttime );
}

void *localtime_( void *ttime ){
	return localtime( (time_t*)ttime );
}

int strftime_( char *buf,int size,BBString *fmt,void *ttime ){
	return strftime( buf,size,bbTmpCString(fmt),ttime );
}

#if _WIN32

static void CleanupWSA(){
	WSACleanup();
}

#endif

void bb_stdc_Startup(){

#if _WIN32

	WSADATA ws;
	
	WSAStartup( 0x101,&ws );
	atexit( CleanupWSA );

#endif

	stdin_=(int)stdin;
	stdout_=(int)stdout;
	stderr_=(int)stderr;
}
