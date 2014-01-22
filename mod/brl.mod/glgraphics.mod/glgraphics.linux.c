
#include <stdio.h>
#include <GL/gl.h>
#include <GL/glx.h>
#include <X11/extensions/xf86vmode.h>
#include <assert.h>

/* Added by BaH */
#include <brl.mod/blitz.mod/blitz.h>
#include <X11/Xutil.h>

extern void bbSystemPoll();
extern Display *bbSystemDisplay();
extern void bbSetSystemWindow(int window);

static XF86VidModeModeInfo **modes,*mode;
static Display *xdisplay;

static int xscreen,xwindow,xfullscreen;

typedef int (* GLXSWAPINTERVALEXT) (int);

GLXSWAPINTERVALEXT glXSwapIntervalEXT;

void *glXExtension(Display *dpy,int screen,const char *catagory,const char *name){
	const char *extensions;
	extensions=glXQueryExtensionsString(dpy,screen);
	if (strstr(extensions,catagory)) {
		return (void*)glXGetProcAddressARB(name);
	}
	return (void*)0;
}

enum{
	MODE_SHARED=0,
	MODE_WIDGET=1,
	MODE_WINDOW=2,
	MODE_DISPLAY=3
};

enum{
	FLAGS_BACKBUFFER=	0x2,
	FLAGS_ALPHABUFFER=	0x4,
	FLAGS_DEPTHBUFFER=	0x8,
	FLAGS_STENCILBUFFER=0x10,
	FLAGS_ACCUMBUFFER=	0x20,
	FLAGS_FULLSCREEN=0x80000000
};

typedef struct BBGLContext BBGLContext;

struct BBGLContext{
	int mode,width,height,depth,hertz,flags,sync;
	int window;
	GLXContext glContext;
};

// glgraphics.bmx interface

int bbGLGraphicsGraphicsModes( int *imodes,int maxcount );
BBGLContext *bbGLGraphicsAttachGraphics( int window,int flags );
BBGLContext *bbGLGraphicsCreateGraphics( int width,int height,int depth,int hz,int flags );
void bbGLGraphicsGetSettings( BBGLContext *context,int *width,int *height,int *depth,int *hz,int *flags );
void bbGLGraphicsClose( BBGLContext *context );
void bbGLGraphicsSetGraphics( BBGLContext *context );
void bbGLGraphicsFlip( int sync );
void bbGLExit();

static BBGLContext *_currentContext;
static BBGLContext *_activeContext;
static BBGLContext *_sharedContext;

#define INTERLACE      0x010
#define DBLSCAN        0x020

static XF86VidModeModeInfo _oldMode;

int _calchertz(XF86VidModeModeInfo *m){
	int	freq;
	freq=(m->dotclock*1000.0)/(m->htotal*m->vtotal)+.5;
	if (m->flags&INTERLACE) freq<<=1;
	if (m->flags&DBLSCAN) freq>>=1;
	return freq;
}

int _initDisplay(){
	int		major,minor;
	if (xdisplay) return 0;
	xdisplay=bbSystemDisplay();
	if (!xdisplay) return -1;
	if (glXQueryVersion(xdisplay,&major,&minor)==0) return -1;
	
//	printf("glXVersion=%d.%d\n",major,minor);fflush(stdout);

	XF86VidModeQueryVersion(xdisplay,&major,&minor);
	
//	printf("XF86VidModeExtension-Version %d.%d\n", major,minor);

	xscreen=DefaultScreen(xdisplay);
	
//	glXSwapIntervalEXT=(GLXSWAPINTERVALEXT)glXGetProcAddressARB("glXSwapIntervalSGI");

	glXSwapIntervalEXT=(GLXSWAPINTERVALEXT)glXExtension(xdisplay,xscreen,"GLX_SGI_swap_control","glXSwapIntervalSGI");
	atexit( bbGLExit );
	return 0;
}

int bbGLGraphicsGraphicsModes( int *imodes,int maxcount ){
	XF86VidModeModeInfo		**xmodes,*m;
	int						count,i;

	if (_initDisplay()) return 0;
	XF86VidModeGetAllModeLines(xdisplay,xscreen,&count,&xmodes);
	if (count>maxcount) count=maxcount;
	for (i=0;i<count;i++)
	{
		m=xmodes[i];
		*imodes++=m->hdisplay;	//width
		*imodes++=m->vdisplay;	//height;
		*imodes++=24;
		*imodes++=_calchertz(m);
	}
	XFree(xmodes);
	return count;
}

static void _swapBuffers( BBGLContext *context ){
	if( !context ) return;
	glXSwapBuffers(xdisplay,context->window);
	bbSystemPoll();
}

BBGLContext *bbGLGraphicsAttachGraphics( int window,int flags ){
	BBGLContext *context=(BBGLContext*)malloc( sizeof(BBGLContext) );
	memset( context,0,sizeof(BBGLContext) );
	context->mode=MODE_WIDGET;
	context->flags=flags;
	context->sync=-1;	
	context->window=window;
	return context;
}

XVisualInfo *_chooseVisual(flags){
	int glspec[32],*s;
	s=glspec;
	*s++=GLX_RGBA;
	if (flags&FLAGS_BACKBUFFER) *s++=GLX_DOUBLEBUFFER;
	if (flags&FLAGS_ALPHABUFFER) {*s++=GLX_ALPHA_SIZE;*s++=1;}
	if (flags&FLAGS_DEPTHBUFFER) {*s++=GLX_DEPTH_SIZE;*s++=1;}
	if (flags&FLAGS_STENCILBUFFER) {*s++=GLX_STENCIL_SIZE;*s++=1;}
	if (flags&FLAGS_ACCUMBUFFER)
	{
		*s++=GLX_ACCUM_RED_SIZE;*s++=1;
		*s++=GLX_ACCUM_GREEN_SIZE;*s++=1;
		*s++=GLX_ACCUM_BLUE_SIZE;*s++=1;
		*s++=GLX_ACCUM_ALPHA_SIZE;*s++=1;
	}
 	*s++=None;
	return glXChooseVisual(xdisplay,xscreen,glspec);	
}

void _makeCurrent(	BBGLContext *context ){
	glXMakeCurrent(xdisplay,context->window,context->glContext);	
	_currentContext=context;
}

static void _validateSize( BBGLContext *context ){
	Window			root_return;
	int				x,y;
	unsigned int	w,h,border,d;
	if( !context || context->mode!=MODE_WIDGET ) return;
	if (_initDisplay()) return;
	XGetGeometry(xdisplay,context->window,&root_return,&x,&y,&w,&h,&border,&d);
	context->width=w;
	context->height=h;
}

static void _validateContext( BBGLContext *context ){
	GLXContext		sharedcontext=0;
	XVisualInfo 	*vizinfo;

	if( !context || context->glContext ) return;

	if (_initDisplay()) return;

	//_initSharedContext();
	if( _sharedContext ) sharedcontext=_sharedContext->glContext;
	
	vizinfo=_chooseVisual(context->flags);
	context->glContext=glXCreateContext(xdisplay,vizinfo,sharedcontext,True);	
	glXMakeCurrent(xdisplay,context->window,context->glContext);	
	bbSetSystemWindow(context->window);
}

void bbGLGraphicsGetSettings( BBGLContext *context,int *width,int *height,int *depth,int *hertz,int *flags ){
	_validateSize( context );
	*width=context->width;
	*height=context->height;
	*depth=context->depth;
	*hertz=context->hertz;
	*flags=context->flags;
}

static Bool WaitForNotify(Display *display,XEvent *event,XPointer arg){
	return (event->type==MapNotify) && (event->xmap.window==(Window)arg);
}

void bbGLGraphicsShareContexts(){
	if( _sharedContext ) return;
	_sharedContext=bbGLGraphicsCreateGraphics(0,0,0,0,0);
}

BBGLContext *bbGLGraphicsCreateGraphics( int width,int height,int depth,int hz,int flags ){
	XSetWindowAttributes swa;
	XVisualInfo *vizinfo;
	XEvent event;
	GLXContext context;
	int window;
	int count,i;
	int displaymode;
	int initingShared=0;
	GLXContext sharedcontext=0;
	char *appTitle;

	if (_initDisplay()) return 0;
	
	if( width==0 && height==0 )
	{
		width=100;
		height=100;
		initingShared=1;
	}
	else
	{
		if( _sharedContext ) sharedcontext=_sharedContext->glContext;
		
		//_initSharedContext();
		//sharedcontext=_sharedContext->glContext;
	}

	vizinfo=_chooseVisual(flags);

	if (depth)
	{
		XF86VidModeGetModeLine(xdisplay,xscreen,&_oldMode.dotclock,(XF86VidModeModeLine*)&_oldMode.hdisplay );

		XF86VidModeGetAllModeLines(xdisplay,xscreen,&count,&modes);
		mode=0;
		for (i=0;i<count;i++)
		{
			if (width==modes[i]->hdisplay && height==modes[i]->vdisplay && hz==_calchertz(modes[i]))
			{
				mode=modes[i];
				break;
			}
		}	
		if (mode==0)
		{
			for (i=0;i<count;i++)
			{
				if (width==modes[i]->hdisplay && height==modes[i]->vdisplay)
				{
					mode=modes[i];
					break;
				}
			}	
		}
		if (mode==0) return;
		width=mode->hdisplay;
		height=mode->vdisplay;
		vizinfo=_chooseVisual(flags);
		
		swa.border_pixel=0;
		swa.event_mask=StructureNotifyMask;
		swa.colormap=XCreateColormap(xdisplay,RootWindow(xdisplay,0),vizinfo->visual,AllocNone);
		swa.override_redirect=True;	

		XF86VidModeSwitchToMode(xdisplay,xscreen,mode);
		XF86VidModeSetViewPort(xdisplay,xscreen,0,0);

		window=XCreateWindow(
			xdisplay,
			RootWindow(xdisplay,xscreen),
			0,
			0,
			width,height,
			0,
			vizinfo->depth,
			InputOutput,
			vizinfo->visual,
			CWBorderPixel|CWEventMask|CWColormap|CWOverrideRedirect,
			&swa
		);

		xfullscreen=1;
		displaymode=MODE_DISPLAY;
	}
	else
	{		
		Atom atom;
		XSizeHints *hints;
		
		swa.border_pixel=0;
		swa.event_mask=StructureNotifyMask;
		swa.colormap=XCreateColormap( xdisplay,RootWindow(xdisplay,0),vizinfo->visual,AllocNone );

		window=XCreateWindow(
			xdisplay,
			RootWindow(xdisplay,xscreen),
			0,
			0,  
			width,height,
			0,
			vizinfo->depth,
			InputOutput,
			vizinfo->visual,
			CWBorderPixel|CWColormap|CWEventMask,
			&swa
		);

		//Tell window to send us 'close window events'		
		atom=XInternAtom( xdisplay,"WM_DELETE_WINDOW",True );
		XSetWMProtocols( xdisplay,window,&atom,1 );

		//Set window min/max size		
		hints=XAllocSizeHints();
		hints->flags=PMinSize|PMaxSize;
		hints->min_width=hints->max_width=width;
		hints->min_height=hints->max_height=height;
		XSetWMNormalHints( xdisplay,window,hints );
		
		displaymode=MODE_WINDOW;
	}
	
	context=glXCreateContext(xdisplay,vizinfo,sharedcontext,True);
		
	if( !initingShared )
	{	
		XMapRaised(xdisplay,window);	
		if (xfullscreen)
		{
			XWarpPointer(xdisplay,None,window,0,0,0,0,0,0);
			XGrabKeyboard(xdisplay,window,True,GrabModeAsync,GrabModeAsync,CurrentTime);
			XGrabPointer(xdisplay,window,True,ButtonPressMask,GrabModeAsync,GrabModeAsync,window,None,CurrentTime);
		}
		glXMakeCurrent(xdisplay,window,context);	
		XIfEvent(xdisplay,&event,WaitForNotify,(XPointer)window);	     
		XSelectInput(xdisplay,window,ResizeRedirectMask|PointerMotionMask|ButtonPressMask|ButtonReleaseMask|KeyPressMask|KeyReleaseMask);	
		xwindow=window;
		bbSetSystemWindow(xwindow);
	}

	appTitle=bbTmpUTF8String( bbAppTitle );
	
	XChangeProperty( xdisplay,window,
	XInternAtom( xdisplay,"_NET_WM_NAME",True ),
	XInternAtom( xdisplay,"UTF8_STRING",True ),
	8,PropModeReplace,appTitle,strlen( appTitle ) );

//	XStoreName( xdisplay,window,appTitle );
	
	bbSystemPoll();

	BBGLContext *bbcontext=(BBGLContext*)malloc( sizeof(BBGLContext) );
	memset( bbcontext,0,sizeof(BBGLContext) );
	bbcontext->mode=displaymode;	
	bbcontext->width=width;	
	bbcontext->height=height;	
	bbcontext->depth=24;	
	bbcontext->hertz=hz;
	bbcontext->flags=flags;
	bbcontext->sync=-1;	
	bbcontext->window=window;
	bbcontext->glContext=context;
	return bbcontext;
}

void bbGLGraphicsSetGraphics( BBGLContext *context ){
	if( context ){
		_validateSize( context );
		_validateContext( context );
	}
	if( !context || context==_currentContext ) return;
	_makeCurrent(context);
	_activeContext=context;
}

void bbGLGraphicsFlip( int sync ){
	if( !_currentContext ) return;
	sync=sync ? 1 : 0;
	if( sync!=_currentContext->sync ){
		_currentContext->sync=sync;
		if ( glXSwapIntervalEXT ) {
			 glXSwapIntervalEXT( sync );
		}
	}
	_swapBuffers( _currentContext );
}

void bbGLGraphicsClose( BBGLContext *context ){
	if (context){
		if (_currentContext==context) _currentContext=0;
		if (context->glContext) 
		{
			glXMakeCurrent(xdisplay,None,NULL);
			glXDestroyContext(xdisplay,context->glContext);	
		}
		if (context->window && context->mode!=MODE_WIDGET){
			XDestroyWindow(xdisplay,context->window);
		}
		if (context->mode==MODE_DISPLAY){
			XF86VidModeSwitchToMode(xdisplay,xscreen,&_oldMode);
			XF86VidModeSetViewPort(xdisplay,xscreen,0,0);
			XFlush(xdisplay);
			XFree(modes);
			modes=0;
			mode=0;
			xfullscreen=0;
		}
		free( context );
	}
}

void bbGLExit(){
	bbGLGraphicsClose( _currentContext );
	bbGLGraphicsClose( _sharedContext );
	_currentContext=0;
	_sharedContext=0;
}
