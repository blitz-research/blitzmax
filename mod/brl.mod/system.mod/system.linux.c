
#include "system.h"

#include <unistd.h>
#include <stdio.h>
#include <signal.h>
#include <pthread.h>

#include <sys/time.h>
#include <sys/sysinfo.h>
#include <sys/ioctl.h>
#include <sys/wait.h>

#include <X11/Xutil.h>
#include <X11/extensions/xf86vmode.h>

#define INTERLACE      0x010
#define DBLSCAN        0x020

typedef struct AsyncOp{
	struct AsyncOp *succ;
	BBSyncOp syncOp;
	BBObject *syncInfo;
	int asyncRet;
	BBAsyncOp asyncOp;
	int asyncInfo;
}AsyncOp;

static AsyncOp *asyncOps;
static pthread_mutex_t asyncMutex=PTHREAD_MUTEX_INITIALIZER;
static int async_pipe[2];

static Display *x_display;
static int x_fd;
static int x_window;
static Cursor x_cursor;

int (*xeventhandler)(XEvent *);

int getxkey(XEvent *event);

int brl_system_XKeyHandler(int type,int key,int mask);

static void postAsyncOp( AsyncOp *p ){
	int ch=0;
	XEvent event;
	AsyncOp **q=&asyncOps,*t;

	p->succ=0;

	pthread_mutex_lock( &asyncMutex );

	while( *q ) q=&(*q)->succ;
	*q=p;
	
	write( async_pipe[1],&ch,1 );

	pthread_mutex_unlock( &asyncMutex );
}

int bbSystemAsyncFD(){
	return async_pipe[0];
}

void bbSystemFlushAsyncOps(){
	int rd;
	AsyncOp *p;
	
	if( !asyncOps ) return;
	
	pthread_mutex_lock( &asyncMutex );
	
	p=asyncOps;
	asyncOps=0;
	
	if( !ioctl( async_pipe[0],FIONREAD,&rd ) ){
		static char *buf;
		static int buf_sz;
		if( rd>buf_sz ){
			free( buf );
			buf=(char*)malloc( rd );
			buf_sz=rd;
		}
		read( async_pipe[0],buf,rd );
	}
	
	pthread_mutex_unlock( &asyncMutex );

	while( p ){
		AsyncOp *t=p->succ;
		p->syncOp( p->syncInfo,p->asyncRet );
		if( p->asyncOp ){
			BBRELEASE( p->syncInfo );
		}
		free( p );
		p=t;
	}
}

void bbSystemShutdown(){
//	XCloseDisplay(x_display);	causes crash with fltk canvas usage
}

void bbSystemStartup(){
	atexit( bbSystemShutdown );
	
	XInitThreads();
	
	x_display=XOpenDisplay(0);
	
	x_fd=ConnectionNumber( x_display );
	
	pipe( async_pipe );
}

Display *bbSystemDisplay(){
	return x_display;
}

void bbSetSystemWindow(int window){
	x_window=window;
}

void bbMoveMouse(int x,int y){
	XWarpPointer(x_display,None,x_window,0,0,0,0,x,y);
}

void bbSetMouseVisible(visible){
	if (!x_window) return;

	if (visible)
	{
		XUndefineCursor(x_display,x_window);		
	}
	else
	{
		if (!x_cursor)
		{
			XColor black;
			char bm[]={0,0,0,0,0,0,0,0};
			Pixmap pix=XCreateBitmapFromData(x_display,x_window,bm,8,8);
			memset(&black,0,sizeof(XColor));
			black.flags=DoRed|DoGreen|DoBlue;
			x_cursor=XCreatePixmapCursor(x_display,pix,pix,&black,&black,0,0);
			XFreePixmap(x_display,pix);
		}
		XDefineCursor(x_display,x_window,x_cursor);
	}
}

void bbSystemEventHandler( int(*handler)(XEvent*) ){
	xeventhandler=handler;
}

void bbSystemEmitOSEvent( XEvent *xevent,BBObject *source ){

	XKeyEvent	*keyevent;
	BBObject 	*event;
	int 		id,data=0,x=0,y=0,mods=0;
	char		mybuffer[16];
	KeySym		mykeysym;
	int			i,n;

	if (xeventhandler){
		if (xeventhandler(xevent)) return;
	}
	
	x=xevent->xbutton.x;
	y=xevent->xbutton.y;
	
	switch( xevent->type ){
	case KeyPress:
		//
		data=getxkey(xevent);
		bbSystemEmitEvent( BBEVENT_KEYDOWN,source,data,mods,x,y,&bbNullObject );
		//
		//Mark swapped above/below - ie: keydown before keychar
		//
		n=XLookupString( xevent,mybuffer,15,&mykeysym,0 );
		for (i=0;i<n;i++){
			bbSystemEmitEvent( BBEVENT_KEYCHAR,source,mybuffer[i],0,0,0,&bbNullObject );
		}
		return;
	case KeyRelease:
		//
		data=getxkey(xevent);
		//
		//Mark's dodgy fix to generate key repeat events
		//Works with "Graphics" style apps - dunno about fltk stuff...
		//
		if( x_display && XPending( x_display ) ){
			XEvent event;
			XPeekEvent( x_display,&event );
			if( event.type==KeyPress && getxkey( &event )==data ){
				XNextEvent( x_display,&event );
				//
				//generate KEYREPEAT event...
				bbSystemEmitEvent( BBEVENT_KEYREPEAT,source,data,mods,x,y,&bbNullObject );
				//
				//generate KEYCHAR events...
				n=XLookupString( xevent,mybuffer,15,&mykeysym,0 );
				for (i=0;i<n;i++){
					bbSystemEmitEvent( BBEVENT_KEYCHAR,source,mybuffer[i],0,0,0,&bbNullObject );
				}
				return;
			}
		}
		id=BBEVENT_KEYUP;
		break;
	case ButtonPress:
		data=xevent->xbutton.button;
		if (data==4)
		{
			id=BBEVENT_MOUSEWHEEL;
			data=1;
			break;
		}
		if (data==5)
		{
			id=BBEVENT_MOUSEWHEEL;
			data=-1;
			break;
		}
		id=BBEVENT_MOUSEDOWN;
		if (data>1) data=5-data;
		break;
	case ButtonRelease:
		id=BBEVENT_MOUSEUP;
		data=xevent->xbutton.button;
		if (data>1) data=5-data;
		break;
	case MotionNotify:
		id=BBEVENT_MOUSEMOVE;
		break;
	case ClientMessage:
		if( xevent->xclient.data.l[0]==XInternAtom( x_display,"WM_DELETE_WINDOW",True ) ){
			id=BBEVENT_APPTERMINATE;
		}else{
			return;
		}
		break;
	default:
		return;
	}
	bbSystemEmitEvent( id,source,data,mods,x,y,&bbNullObject );
}

void bbSystemPoll(){
	if( !x_display ) return;
	
	while( XPending( x_display ) ){
		XEvent event;
		XNextEvent( x_display,&event );

		bbSystemEmitOSEvent(&event,&bbNullObject);
	}
	bbSystemFlushAsyncOps();
}

void bbSystemWait(){
	fd_set in_fds;
	struct timeval tv;
	
	if( !x_display ) return;
	
	FD_ZERO( &in_fds );
	FD_SET( x_fd,&in_fds );
	FD_SET( async_pipe[0],&in_fds );
	
  	tv.tv_sec=10;
    tv.tv_usec=0;

	select( (x_fd>async_pipe[0] ? x_fd : async_pipe[0]) + 1,&in_fds,0,0,&tv );
	
	bbSystemPoll();
}

int getxkey(XEvent *event)
{
	int key;
	key=XLookupKeysym(&event->xkey,0)&255;
	if (key>=97&&key<=126) return key+(65-97);		//a..z	
	if (key>=81&&key<=84) return key+(37-81);		//arrow keys
	if (key>=190 && key<=201) return key+(112-190);	//function keys
	if (key==99) return 45;		//insert
	if (key==227) return 162;	//lctrl
	if (key==233) return 164;	//lalt
	if (key==234) return 165;	//ralt
	if (key==228) return 163;	//rctrl
	if (key==225) return 160;	//lshift
	if (key==226) return 161;	//rshiftz
	if (key==127) return 144;	//numlock
	if (key==20) return 145;	//scroll
	if (key==158) return 96;	//numkeys 0..9
	if (key==156) return 97;
	if (key==153) return 98;
	if (key==155) return 99;
	if (key==150) return 100;
	if (key==157) return 101;
	if (key==152) return 102;
	if (key==149) return 103;
	if (key==151) return 104;
	if (key==154) return 105;
	if (key==235) return 91;	//left windows key
	if (key==236) return 92;	//right windows key
	if (key==103) return 93;	//startmenu windows key
	if (key==80) return 36;		//home
	if (key==85) return 33;		//pageup
	if (key==255) return 46;	//delete
	if (key==87) return 35;		//end
	if (key==86) return 34;		//pagedown
	if (key==97) return 42;		//print screen
	if (key==159) return 110;	//keypad .
	if (key==141) return 13;	//keypad enter
	if (key==171) return 107;	//keypad add
	if (key==173) return 109;	//keypad minus 
	if (key==170) return 106;	//keypad mult
	if (key==175) return 111;	//keypad divide
	if (key==96) return 192;	//tilde key
	if (key=='-') return 189;	//minus
	if (key=='=') return 187;	//equals
	if (key==91) return 219;	//[
	if (key==93) return 221;	//]
	if (key==92) return 226;	//backslash
	if (key==59) return 186;	//semicolon
	if (key==39) return 222;	//quotes
	if (key==44) return 188;	//comma key
	if (key==46) return 190;	//period key
	if (key==47) return 191;	//questionmark key		

	return key;
}

void *asyncOpThread( void *t ){
	AsyncOp *p=(AsyncOp*)t;
	p->asyncRet=p->asyncOp( p->asyncInfo );
	postAsyncOp( p );
	return 0;
}

void bbSystemPostSyncOp( BBSyncOp syncOp,BBObject *syncInfo,int asyncRet ){
	AsyncOp *p=(AsyncOp*)malloc( sizeof( AsyncOp ) );
	p->asyncOp=0;
	p->asyncRet=asyncRet;
	p->syncOp=syncOp;
	p->syncInfo=syncInfo;
	postAsyncOp( p );
}

void bbSystemStartAsyncOp( BBAsyncOp asyncOp,int asyncInfo,BBSyncOp syncOp,BBObject *syncInfo ){
	pthread_t thread;
	AsyncOp *p=(AsyncOp*)malloc( sizeof( AsyncOp ) );
	BBRETAIN( syncInfo );
	p->asyncOp=asyncOp;
	p->asyncInfo=asyncInfo;
	p->syncOp=syncOp;
	p->syncInfo=syncInfo;
	pthread_create( &thread,0,asyncOpThread,p );
	pthread_detach( thread );
}

static int _calchertz( XF86VidModeModeInfo *m ){
	int freq=( m->dotclock*1000.0 )/( m->htotal*m->vtotal )+.5;
	if( m->flags&INTERLACE ) freq<<=1;
	if( m->flags&DBLSCAN ) freq>>=1;
	return freq;
}

int bbSystemDesktopWidth(){
	int count=0,sz=0;
	XF86VidModeModeInfo **xmodes=0;
	XF86VidModeGetAllModeLines( x_display,DefaultScreen( x_display ),&count,&xmodes );
	sz=count>0 ? xmodes[0]->hdisplay : 640;
	XFree( xmodes );
	return sz;
}

int bbSystemDesktopHeight(){
	int count=0,sz=0;
	XF86VidModeModeInfo **xmodes=0;
	XF86VidModeGetAllModeLines( x_display,DefaultScreen( x_display ),&count,&xmodes );
	sz=count>0 ? xmodes[0]->vdisplay : 480;
	XFree( xmodes );
	return sz;
}

int bbSystemDesktopDepth(){
	return 24;
}

int bbSystemDesktopHertz(){
	int count=0,sz=0;
	XF86VidModeModeInfo **xmodes=0;
	XF86VidModeGetAllModeLines( x_display,DefaultScreen( x_display ),&count,&xmodes );
	sz=count>0 ? _calchertz( xmodes[0] ) : 60;
	XFree( xmodes );
	return sz;
}
