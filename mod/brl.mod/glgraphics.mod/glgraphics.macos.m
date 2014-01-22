
#include <AppKit/AppKit.h>
#include <Carbon/Carbon.h>
#include <OpenGL/gl.h>
#include <OpenGL/OpenGL.h>

#include <brl.mod/system.mod/system.h>

enum{
	FLAGS_BACKBUFFER=	0x2,
	FLAGS_ALPHABUFFER=	0x4,
	FLAGS_DEPTHBUFFER=	0x8,
	FLAGS_STENCILBUFFER=0x10,
	FLAGS_ACCUMBUFFER=	0x20,
	FLAGS_FULLSCREEN=	0x80000000
};

enum{
	MODE_WIDGET=		1,
	MODE_WINDOW=		2,
	MODE_DISPLAY=		3
};

@interface BBGLWindow : NSWindow{
}
@end
@implementation BBGLWindow
-(void)sendEvent:(NSEvent*)event{
	bbSystemEmitOSEvent( event,[self contentView],&bbNullObject );
	switch( [event type] ){
	case NSKeyDown:case NSKeyUp:
		//prevent 'beeps'!
		return;
	}
	[super sendEvent:event];
}
-(BOOL)windowShouldClose:(id)sender{
	bbSystemEmitEvent( BBEVENT_APPTERMINATE,&bbNullObject,0,0,0,0,&bbNullObject );
	return NO;
}
- (BOOL)canBecomeKeyWindow{
	return YES;
}
@end

typedef struct BBGLContext BBGLContext;

struct BBGLContext{
	int mode,width,height,depth,hertz,flags,sync;

	NSView *view;
	BBGLWindow *window;
	NSOpenGLContext *glContext;
};

static BBGLContext *_currentContext;
static BBGLContext *_displayContext;

static CFDictionaryRef oldDisplayMode;

extern void bbFlushAutoreleasePool();

void bbGLGraphicsClose( BBGLContext *context );
void bbGLGraphicsGetSettings( BBGLContext *context,int *width,int *height,int *depth,int *hertz,int *flags );
void bbGLGraphicsSetGraphics( BBGLContext *context );

static int _initAttrs( CGLPixelFormatAttribute attrs[16],int flags ){
	int n=0;
	if( flags & FLAGS_BACKBUFFER ) attrs[n++]=kCGLPFADoubleBuffer;
	if( flags & FLAGS_ALPHABUFFER ){ attrs[n++]=kCGLPFAAlphaSize;attrs[n++]=1; }
	if( flags & FLAGS_DEPTHBUFFER ){ attrs[n++]=kCGLPFADepthSize;attrs[n++]=1; }
	if( flags & FLAGS_STENCILBUFFER ){ attrs[n++]=kCGLPFAStencilSize;attrs[n++]=1; }
	if( flags & FLAGS_ACCUMBUFFER ){ attrs[n++]=kCGLPFAAccumSize;attrs[n++]=1; }
	if( flags & FLAGS_FULLSCREEN ){
		attrs[n++]=kCGLPFAFullScreen;
		attrs[n++]=kCGLPFADisplayMask;
		attrs[n++]=CGDisplayIDToOpenGLDisplayMask( kCGDirectMainDisplay );
	}else{
		attrs[n++]=kCGLPFANoRecovery;
	}
	attrs[n]=0;
	return n;
}

static NSOpenGLContext *_sharedContext;

static void _validateSize( BBGLContext *context ){
	NSRect rect;
	
	if( !context || context->mode!=MODE_WIDGET ) return;
	
	rect=[context->view bounds];
	if( rect.size.width==context->width && rect.size.height==context->height ) return;
	
	context->width=rect.size.width;
	context->height=rect.size.height;

	if( context->glContext ) [context->glContext update];
}

static void _validateContext( BBGLContext *context ){
	int flags;
	NSOpenGLContext *shared;
	NSOpenGLContext *glContext;
	NSOpenGLPixelFormat *glFormat;
	CGLPixelFormatAttribute attrs[16];
	
	if( !context || context->glContext ) return;

	flags=context->flags;
	
//	if( context->mode==MODE_DISPLAY ) flags|=FLAGS_FULLSCREEN;

	_initAttrs( attrs,flags );

	glFormat=[[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
	glContext=[[NSOpenGLContext alloc] initWithFormat:glFormat shareContext:_sharedContext];
	[glFormat release];

	if( !glContext ) bbExThrowCString( "Unable to create GL Context" );
	
	switch( context->mode ){
	case MODE_WIDGET:
		[glContext setView:context->view];
		break;
	case MODE_WINDOW:
	case MODE_DISPLAY:
		[glContext setView:[context->window contentView]];
		break;
	}

	context->glContext=glContext;
}

void bbGLGraphicsShareContexts(){
	NSOpenGLPixelFormat *glFormat;
	CGLPixelFormatAttribute attrs[16];
	
	if( _sharedContext ) return;

	_initAttrs( attrs,0 );
	glFormat=[[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
	_sharedContext=[[NSOpenGLContext alloc] initWithFormat:glFormat shareContext:0];
	[glFormat release];
}

int bbGLGraphicsGraphicsModes( int *modes,int count ){
	int i=0,n=0,sz;
	CFArrayRef displayModeArray;

	displayModeArray=CGDisplayAvailableModes( kCGDirectMainDisplay );
	sz=CFArrayGetCount( displayModeArray );
	
	while( i<sz && n<count ){

		CFNumberRef number;
		CFDictionaryRef displayMode;
		int width,height,depth,hertz;

		displayMode=(CFDictionaryRef)CFArrayGetValueAtIndex( displayModeArray,i++ );

		number=CFDictionaryGetValue( displayMode,kCGDisplayBitsPerPixel );
		CFNumberGetValue( number,kCFNumberLongType,&depth );

		if( depth<16 ) continue;

		number=CFDictionaryGetValue( displayMode,kCGDisplayWidth );
		CFNumberGetValue( number,kCFNumberLongType,&width );

		number=CFDictionaryGetValue( displayMode,kCGDisplayHeight );
		CFNumberGetValue( number,kCFNumberLongType,&height );

		number=CFDictionaryGetValue( displayMode,kCGDisplayRefreshRate );
		CFNumberGetValue( number,kCFNumberLongType,&hertz );

		*modes++=width;
		*modes++=height;
		*modes++=depth;
		*modes++=hertz;
		++n;
	}
	
	return n;
}

BBGLContext *bbGLGraphicsAttachGraphics( NSView *view,int flags ){
	NSRect rect;
	BBGLContext *context;

	rect=[view bounds];
	
	context=(BBGLContext*)malloc( sizeof(BBGLContext) );
	memset( context,0,sizeof(BBGLContext) );

	context->mode=MODE_WIDGET;	
	context->width=rect.size.width;
	context->height=rect.size.height;
	context->flags=flags;
	context->sync=-1;
	
	context->view=view;
	
	return context;
}

BBGLContext *bbGLGraphicsCreateGraphics( int width,int height,int depth,int hertz,int flags ){
	int mode;
	BBGLWindow *window=0;
	BBGLContext *context;
	int sysv=0;
	
	Gestalt( 'sysv',&sysv );

	if( depth ){
	
		CFDictionaryRef displayMode;
		CGCaptureAllDisplays();
		
		oldDisplayMode=CGDisplayCurrentMode( kCGDirectMainDisplay );
		CFRetain( (CFTypeRef)oldDisplayMode );

		if( !hertz ){
			displayMode=CGDisplayBestModeForParameters( kCGDirectMainDisplay,depth,width,height,0 );
		}else{
			displayMode=CGDisplayBestModeForParametersAndRefreshRate( kCGDirectMainDisplay,depth,width,height,hertz,0 );
		}
		if( CGDisplaySwitchToMode( kCGDirectMainDisplay,displayMode ) ){
			CFRelease( (CFTypeRef)oldDisplayMode );
			bbExThrowCString( "Unable to set display mode" );
		}
		HideMenuBar();

		window=[[NSWindow alloc]
			initWithContentRect:NSMakeRect( 0,0,width,height )
			styleMask:NSBorderlessWindowMask
			backing:NSBackingStoreBuffered
			defer:YES];
		
		[window setOpaque:YES];
		[window setBackgroundColor:[NSColor blackColor]];
		[window setLevel:CGShieldingWindowLevel()];

		[window makeKeyAndOrderFront:NSApp];
		
		mode=MODE_DISPLAY;
		
	}else{
		
		window=[[BBGLWindow alloc]
			initWithContentRect:NSMakeRect( 0,0,width,height )
			styleMask:NSTitledWindowMask|NSClosableWindowMask
			backing:NSBackingStoreBuffered
			defer:YES];

		if( !window ) return 0;
		
		[window setDelegate:window];
		[window setAcceptsMouseMovedEvents:YES];

		[window setTitle:[NSString stringWithUTF8String:bbTmpUTF8String(bbAppTitle)]];
		[window center];

		[window makeKeyAndOrderFront:NSApp];
		
		mode=MODE_WINDOW;
	}
	
	context=(BBGLContext*)malloc( sizeof(BBGLContext) );
	memset( context,0,sizeof(BBGLContext) );
	
	context->mode=mode;
	context->width=width;
	context->height=height;
	context->depth=depth;
	context->hertz=hertz;
	context->flags=flags;
	context->sync=-1;
	context->window=window;
	
	if( mode==MODE_DISPLAY ) _displayContext=context;
	
	return context;
}

void bbGLGraphicsGetSettings( BBGLContext *context,int *width,int *height,int *depth,int *hertz, int *flags ){
	_validateSize( context );
	*width=context->width;
	*height=context->height;
	*depth=context->depth;
	*hertz=context->hertz;
	*flags=context->flags;
}

void bbGLGraphicsClose( BBGLContext *context ){
	if( context==_currentContext ) bbGLGraphicsSetGraphics( 0 );

	[context->glContext clearDrawable];
	[context->glContext release];
	
	switch( context->mode ){
	case MODE_WINDOW:
	case MODE_DISPLAY:
		bbSystemViewClosed( [context->window contentView] );
		[context->window close];
		break;
	}
	if( context==_displayContext ){
		CGDisplaySwitchToMode( kCGDirectMainDisplay,oldDisplayMode );
		CFRelease( (CFTypeRef)oldDisplayMode );
		CGReleaseAllDisplays();
		CGDisplayShowCursor( kCGDirectMainDisplay );
		ShowMenuBar();
		_displayContext=0;
	}

	free( context );
}

void bbGLGraphicsSetGraphics( BBGLContext *context ){
	if( context ){
		_validateSize( context );
		_validateContext( context );
		[context->glContext makeCurrentContext];
	}else{
		[NSOpenGLContext clearCurrentContext];
	}
	_currentContext=context;
}

void bbGLGraphicsFlip( int sync ){
	if( !_currentContext ) return;
	
	sync=sync ? 1 : 0;
	
	static int _sync=-1;
	
	if( sync!=_currentContext->sync ){
		_currentContext->sync=sync;
		[_currentContext->glContext setValues:(long*)&sync forParameter:kCGLCPSwapInterval];
	}
	
	[_currentContext->glContext flushBuffer];
}
