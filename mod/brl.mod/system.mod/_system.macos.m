
#import <brl.mod/system.mod/system.h>

#include <AppKit/AppKit.h>

#include <Carbon/Carbon.h>

static unsigned char key_table[]={
	//0...
	KEY_A,		KEY_S,		KEY_D,		KEY_F,		KEY_H,		KEY_G,		KEY_Z,		KEY_X,
	KEY_C,		KEY_V,		0,			KEY_B,		KEY_Q,		KEY_W,		KEY_E,		KEY_R,
	KEY_Y,		KEY_T,		KEY_1,		KEY_2,		KEY_3,		KEY_4,		KEY_6,		KEY_5,
	KEY_EQUALS,	KEY_9,		KEY_7,		KEY_MINUS,	KEY_8,		KEY_0,		KEY_CLOSEBRACKET,KEY_O,
	//32...
	KEY_U,		KEY_OPENBRACKET,KEY_I,	KEY_P,		KEY_ENTER,  KEY_L,		KEY_J,		KEY_QUOTES,
	KEY_K,		KEY_SEMICOLON,KEY_BACKSLASH,KEY_COMMA,KEY_SLASH,KEY_N,		KEY_M,		KEY_PERIOD,
	KEY_TAB,	KEY_SPACE,  KEY_TILDE,	KEY_BACKSPACE,0,		KEY_ESC,	0,			0,
	0,			0,			0,			0,			0,			0,			0,			0,
	//64...
	0,			KEY_NUMDECIMAL,0,		KEY_NUMMULTIPLY,0,		KEY_NUMADD,	0,			0,
	0,			0,			0,			KEY_NUMDIVIDE,KEY_ENTER,0,			KEY_NUMSUBTRACT,0,
	//80...
	0,			0,			KEY_NUM0,	KEY_NUM1,	KEY_NUM2,	KEY_NUM3,	KEY_NUM4,	KEY_NUM5,
	KEY_NUM6,	KEY_NUM7,	0,			KEY_NUM8,	KEY_NUM9,	0,			0,			0,
	//96...
	KEY_F5,		KEY_F6,		KEY_F7,		KEY_F3,		KEY_F8,		KEY_F9,		0,			KEY_F11,
	0,			0,			0,			0,			0,			KEY_F10,	0,			KEY_F12,
	0,			0,			KEY_INSERT,	KEY_HOME,	KEY_PAGEUP,	KEY_DELETE,	KEY_F4,		KEY_END,
	KEY_F2,		KEY_PAGEDOWN,KEY_F1,	KEY_LEFT,	KEY_RIGHT,	KEY_DOWN,	KEY_UP,		0,
	//128...
};

void bbSystemPoll();
void bbFlushAutoreleasePool();

static int mods,deltaMods;
static NSDate *distantPast,*distantFuture;

static int mouseVisible=1;
static int displayCaptured=0;

static NSView *mouseView;
static BBObject *mouseSource;
static NSTrackingRectTag mouseTrackTag;

static NSEvent *anullEvent;
static NSView *capturedView;

static int appWaiting;
static NSWindow *keyWin;

#define LSHIFTMASK 0x2
#define RSHIFTMASK 0x4
#define LCTRLMASK 0x1
#define RCTRLMASK 0x2000
#define LSYSMASK 0x8
#define RSYSMASK 0x10
#define LALTMASK 0x20
#define RALTMASK 0x40

typedef struct AsyncOp{
	BBAsyncOp asyncOp;
	int asyncInfo;
	int asyncRet;
	BBSyncOp syncOp;
	BBObject *syncInfo;
}AsyncOp;

@interface BBSystemAppDelegate : NSObject{
}
@end

static BBSystemAppDelegate *appDelegate;

static NSString *tmpNSString( BBString *str ){
	return [NSString stringWithCharacters:str->buf length:str->length];
}

static BBString *stringFromNSString( NSString *nsstr ){
	return bbStringFromUTF8String( [nsstr UTF8String] );
}

static NSString *appTitle(){
	return tmpNSString( bbAppTitle );
}

int bbSystemTranslateKey( key ){
	return (key>=0 && key<128) ? key_table[key] : 0;
}

int bbSystemTranslateChar( chr ){
	switch(chr){
	case 127:return 8;
	case 63272:return 127;
	}
	return chr;
}

int bbSystemTranslateMods( mods ){
	int n=0;
	if( mods & NSShiftKeyMask ) n|=MODIFIER_SHIFT;
	if( mods & NSControlKeyMask ) n|=MODIFIER_CONTROL;
	if( mods & NSAlternateKeyMask ) n|=MODIFIER_OPTION;
	if( mods & NSCommandKeyMask ) n|=MODIFIER_SYSTEM;
	return n;
}

static void updateMouseVisibility(){
	static int cursorVisible=1;
	
	int visible=mouseVisible;

	if( !visible && !displayCaptured ){
		
		NSArray *windows=(NSArray*)[NSApp windows];
		int count=[windows count],i;
		
		visible=1;

		for( i=0;i<count;++i ){
			NSRect rect;
			NSPoint point;
			NSView *view;
			NSWindow *window;
		
			window=[windows objectAtIndex:i];
			view=[window contentView];
			if( !view ) continue;
		
			rect=[view bounds];
			point=[window mouseLocationOutsideOfEventStream];
			point=[view convertPoint:point fromView:nil];
			
			if( ![view isFlipped] ) point.y=rect.size.height-point.y;
			
			if( point.x<0 || point.y<0 || point.x>=rect.size.width || point.y>=rect.size.height ) continue;
		
			visible=0;
			break;
		}
	}
	if( visible ){
		if( !CGCursorIsVisible() ){
			CGDisplayShowCursor( kCGDirectMainDisplay );
		}
	}else{
		if( CGCursorIsVisible() ){
			CGDisplayHideCursor( kCGDirectMainDisplay );
		}
	}
}

static int mouseViewPos( NSView *view,int *x,int *y ){
	NSRect rect;
	NSPoint point;
	NSWindow *window;
	
	if( !view ){

		NSPoint point;
		NSRect frame;
		CGLContextObj gl;
		
		point=[NSEvent mouseLocation];
		frame=[[NSScreen mainScreen] frame];

		point.y=frame.size.height-point.y-1;
		
		//yurk...
		if( gl=CGLGetCurrentContext() ){

			GLint enabled=0;
			if( !CGLIsEnabled( gl,kCGLCESurfaceBackingSize,&enabled ) && enabled ){
			
				GLint size[2]={0,0};
				if( !CGLGetParameter( gl,kCGLCPSurfaceBackingSize,size ) ){
				
					point.x=point.x*size[0]/frame.size.width;
					point.y=point.y*size[1]/frame.size.height;
				}
			}
		}
		*x=point.x;
		*y=point.y;
		return 1;
	}
	
	window=[view window];
	point=[window mouseLocationOutsideOfEventStream];
	rect=[view bounds];
	point=[view convertPoint:point fromView:nil];
	if( ![view isFlipped] ) point.y=rect.size.height-point.y;
	*x=point.x;
	*y=point.y;
	return point.x>=0 && point.y>=0 && point.x<rect.size.width && point.y<rect.size.height;
}

static void setMouseView( NSView *view,int x,int y,BBObject *source ){
	if( view==mouseView ) return;

	if( mouseView ){
		int x,y;
		mouseViewPos( mouseView,&x,&y );
		bbSystemEmitEvent( BBEVENT_MOUSELEAVE,mouseSource,0,0,x,y,&bbNullObject );
		if( mouseSource ){
			BBRELEASE( mouseSource );
		}
		[mouseView removeTrackingRect:mouseTrackTag];
		[mouseView release];
	}

	mouseView=[view retain];

	if( mouseView ){
		mouseSource=source;
		if( mouseSource ){
			BBRETAIN( mouseSource );
		}
		bbSystemEmitEvent( BBEVENT_MOUSEENTER,mouseSource,0,0,x,y,&bbNullObject );
		mouseTrackTag=[mouseView addTrackingRect:[mouseView bounds] owner:appDelegate userData:0 assumeInside:YES];
	}
}

static NSEvent *appDefEvent( int subtype,int data1,int data2 ){
	return [NSEvent 
	otherEventWithType:NSApplicationDefined
	location:NSMakePoint(0,0)
	modifierFlags:0
	timestamp:0
	windowNumber:0
	context:0
	subtype:subtype
	data1:data1
	data2:data2];
}

@implementation BBSystemAppDelegate
-(void)applicationWillTerminate:(NSNotification*)notification{
	exit(0);
}
-(NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication*)sender{
	bbSystemEmitEvent( BBEVENT_APPTERMINATE,&bbNullObject,0,0,0,0,&bbNullObject );
	return NSTerminateCancel;
}
-(void)applicationDidBecomeActive:(NSNotification *)aNotification{
	bbSystemEmitEvent( BBEVENT_APPRESUME,&bbNullObject,0,0,0,0,&bbNullObject );
}
-(void)applicationDidResignActive:(NSNotification *)aNotification{
	bbSystemEmitEvent( BBEVENT_APPSUSPEND,&bbNullObject,0,0,0,0,&bbNullObject );
}
-(BOOL)application:(NSApplication*)app openFile:(NSString*)path{
	BBString *t=bbStringFromCString( [path cString] );
	bbSystemEmitEvent( BBEVENT_APPOPENFILE,&bbNullObject,0,0,0,0,(BBObject*)t );
	return YES;
}
-(void)mouseEntered:(NSEvent*)event{
	//Never gets here hopefully!
}
-(void)mouseExited:(NSEvent*)event{
	setMouseView( 0,0,0,0 );
}
-(void)asyncOpThread:(NSEvent*)event{
	AsyncOp *p=(AsyncOp*)[event data1];
	p->asyncRet=p->asyncOp( p->asyncInfo );
	[NSApp postEvent:event atStart:NO];
}
@end

static void updateDisplayCaptured(){
	displayCaptured=CGDisplayIsCaptured( kCGDirectMainDisplay );
}

static void updateEvents( NSDate *until ){
	NSEvent *event;

	updateDisplayCaptured();
	updateMouseVisibility();
	
	while( event=[NSApp nextEventMatchingMask:NSAnyEventMask untilDate:until inMode:NSDefaultRunLoopMode dequeue:YES] ){
		if( [event type]==NSApplicationDefined ){
			if( [event subtype]==BB_RESERVEDEVENTSUBTYPE1 ){
				AsyncOp *p=(AsyncOp*)[event data1];
				p->syncOp( p->syncInfo,p->asyncRet );
				if( p->asyncOp ){
					BBRELEASE( p->syncInfo );
				}
				free( p );
				continue;
			}
		}
		if( displayCaptured ){
			bbSystemEmitOSEvent( event,0,&bbNullObject );
		}else{
			[NSApp sendEvent:event];
		}
		until=distantPast;
	}

	bbFlushAutoreleasePool();
}

static void checkDisplay(){
	updateDisplayCaptured();
	if( displayCaptured ) bbExThrowCString( "GUI unavailable in fullscreen mode" );
}

static void beginPanel(){
	checkDisplay();
	keyWin=[NSApp keyWindow];
	if( !keyWin ) [NSApp activateIgnoringOtherApps:YES];
}

static void endPanel(){
	if( keyWin ) [keyWin makeKeyWindow];
}

static NSWindow *appMainWindow(){
	int i;
	if( ![[NSApp windows] count] ) return 0;
	for( i=0;i<10;++i ){
		NSWindow *window=[NSApp mainWindow];
		if( window ) return window;
		bbSystemPoll();
	}
	return 0;
}

void bbSystemPoll(){
	updateEvents( distantPast );
}

void bbSystemWait(){
	appWaiting=1;
	updateEvents( distantFuture );
	appWaiting=0;
}

void bbSystemIntr(){
	if( !appWaiting ) return;
	appWaiting=0;
	[NSApp postEvent:anullEvent atStart:NO];
}

void bbSystemViewClosed( NSView *view ){
	if( view!=mouseView ) return;
	[mouseView removeTrackingRect:mouseTrackTag];
	mouseView=0;
}

void bbSystemEmitOSEvent( NSEvent *event,NSView *view,BBObject *source ){
	int inView;
	NSEventType type;
	NSString *characters;
	int ev=0,data=0,x=0,y=0,oldMods=mods,mask;
	float f;
	
	mods=[event modifierFlags];

	type=[event type];

	switch( type ){
	case NSKeyDown:
		if( data=bbSystemTranslateKey( [event keyCode] ) ){
			ev=[event isARepeat] ? BBEVENT_KEYREPEAT : BBEVENT_KEYDOWN;
			bbSystemEmitEvent( ev,source,data,bbSystemTranslateMods(mods),0,0,&bbNullObject );
		}
		characters=[event characters];
		if( [characters length]!=1 ) return;
		data=[characters characterAtIndex:0];
		if( data>=0xf700 && data<=0xf8ff ) return;
		ev=BBEVENT_KEYCHAR;
		data=bbSystemTranslateChar( data );
		break;
	case NSKeyUp:
		data=bbSystemTranslateKey( [event keyCode] );
		if( !data ) return;
		ev=BBEVENT_KEYUP;
		break;
	case NSFlagsChanged:
		deltaMods=mods^oldMods;
		if( deltaMods & (mask=LSHIFTMASK) ) data=KEY_LSHIFT;
		else if( deltaMods & (mask=RSHIFTMASK) ) data=KEY_RSHIFT;
		else if( deltaMods & (mask=LCTRLMASK) ) data=KEY_LCONTROL;
		else if( deltaMods & (mask=RCTRLMASK) ) data=KEY_RCONTROL;
		else if( deltaMods & (mask=LALTMASK) ) data=KEY_LALT;
		else if( deltaMods & (mask=RALTMASK) ) data=KEY_RALT;
		else if( deltaMods & (mask=LSYSMASK) ) data=KEY_LSYS;
		else if( deltaMods & (mask=RSYSMASK) ) data=KEY_RSYS;
		if( !data ) return;
		ev=(mods & mask) ? BBEVENT_KEYDOWN : BBEVENT_KEYUP;
		break;
	case NSLeftMouseDown:
	case NSRightMouseDown:
	case NSOtherMouseDown:
		inView=mouseViewPos( view,&x,&y );
		if( !inView ) return;
		setMouseView( view,x,y,source );
		capturedView=mouseView;
		ev=BBEVENT_MOUSEDOWN;
		data=(type==NSLeftMouseDown) ? 1 : (type==NSRightMouseDown ? 2 : 3);
		break;
	case NSLeftMouseUp:
	case NSRightMouseUp:
	case NSOtherMouseUp:
		inView=mouseViewPos( view,&x,&y );
		if( !inView && !capturedView ) return;
		capturedView=0;
		ev=BBEVENT_MOUSEUP;
		data=(type==NSLeftMouseUp) ? 1 : (type==NSRightMouseUp ? 2 : 3);
		break;
	case NSMouseMoved:
	case NSLeftMouseDragged:
	case NSRightMouseDragged:
	case NSOtherMouseDragged:
		inView=mouseViewPos( view,&x,&y );
		setMouseView( inView ? view : 0,x,y,source );
		if( !inView && !capturedView ) return;
		ev=BBEVENT_MOUSEMOVE;
		data=(type==NSLeftMouseDragged) ? 1 : (type==NSRightMouseDragged ? 2 : (type==NSOtherMouseDragged ? 3 : 0));
		break;
	case NSScrollWheel:
		inView=mouseViewPos( view,&x,&y );
		if( !inView && view!=capturedView ) return;
		ev=BBEVENT_MOUSEWHEEL;
		f=[event deltaY];
		data=f>0 ? ceil(f) : floor(f);
		break;
	default:
		return;
	}
	bbSystemEmitEvent( ev,source,data,bbSystemTranslateMods(mods),x,y,&bbNullObject );
}

void bbSystemMoveMouse( int x,int y ){
	NSEvent *event;
	CGPoint cgPoint={x,y};

	CGSetLocalEventsSuppressionInterval(0.0);

	if( !CGDisplayIsCaptured(kCGDirectMainDisplay) ){
		NSPoint nsPoint={x,y};
	
		NSWindow *window=appMainWindow();
		
		if( !window ) return;

		nsPoint.y=[[window contentView] bounds].size.height-1-nsPoint.y;
		nsPoint=[window convertBaseToScreen:nsPoint];

		cgPoint.x=nsPoint.x;
		cgPoint.y=CGDisplayPixelsHigh(kCGDirectMainDisplay)-nsPoint.y;
	}

	CGDisplayMoveCursorToPoint( kCGDirectMainDisplay,cgPoint );

	bbSystemEmitEvent( BBEVENT_MOUSEMOVE,&bbNullObject,0,bbSystemTranslateMods(mods),x,y,&bbNullObject );
}

void bbSystemSetMouseVisible( int visible ){
	mouseVisible=visible;
	updateDisplayCaptured();
	updateMouseVisibility();
}

void bbSystemStartup(){
	anullEvent=[appDefEvent( -1,0,0 ) retain];
	distantPast=[[NSDate distantPast] retain];
	distantFuture=[[NSDate distantFuture] retain];
	appDelegate=[[BBSystemAppDelegate alloc] init];
	[NSApp setDelegate:appDelegate];
}

typedef int (*AlertPanel)( 
	NSString *title,
	NSString *msg,
	NSString *defaultButton,
	NSString *alternateButton,
	NSString *otherButton );

void bbSystemNotify( BBString *text,int serious ){
	AlertPanel panel=serious ? (void*)NSRunCriticalAlertPanel : (void*)NSRunAlertPanel;
	
	beginPanel();
	panel(
		appTitle(),
		tmpNSString(text),
		@"OK",0,0 );
	
	endPanel();
}

int bbSystemConfirm( BBString *text,int serious ){
	int n;
	AlertPanel panel=serious ? (void*)NSRunCriticalAlertPanel : (void*)NSRunAlertPanel;
	
	beginPanel();
	n=panel(
		appTitle(),
		tmpNSString(text),
		@"OK",@"Cancel",0 );

	endPanel();
	
	switch( n ){
	case NSAlertDefaultReturn:return 1;
	}
	return 0;
}

int bbSystemProceed( BBString *text,int serious ){
	int n;
	AlertPanel panel=serious ? (void*)NSRunCriticalAlertPanel : (void*)NSRunAlertPanel;
	
	beginPanel();
	n=panel(
		appTitle(),
		tmpNSString(text),
		@"Yes",@"No",@"Cancel" );
	endPanel();
	
	switch( n ){
	case NSAlertDefaultReturn:return 1;
	case NSAlertAlternateReturn:return 0;
	}
	return -1;
}

BBString *bbSystemRequestFile( BBString *title,BBString *exts,int save,BBString *file,BBString *dir ){

	NSString *nsdir=0;
	NSString *nsfile=0;
	NSString *nstitle=0;
	NSMutableArray *nsexts=0;

	BBString *str=&bbEmptyString;
	
	if( dir->length ){
		char tmp[PATH_MAX];
		realpath( bbTmpUTF8String(dir),tmp );
		nsdir=[NSString stringWithUTF8String:tmp];
	}
	
	if( file->length ){
		nsfile=tmpNSString(file);
	}
	
	if( title->length ){
		nstitle=tmpNSString(title);
	}
	
	if( exts->length ){
		char *p=bbTmpUTF8String(exts),*t;
		nsexts=[NSMutableArray arrayWithCapacity:10];
		while( t=strchr(p,',') ){
			*t=0;
			[nsexts addObject:[NSString stringWithUTF8String:p]];
			p=t+1;
		}
		if( *p ) [nsexts addObject:[NSString stringWithUTF8String:p]];
	}

	beginPanel();

	if( save ){
		NSSavePanel *panel=[NSSavePanel savePanel];
		
		if( nstitle ) [panel setTitle:nstitle];
		
		if( nsexts ){
			[panel setAllowedFileTypes:nsexts];
			[panel setAllowsOtherFileTypes:YES];
		}
		
		if( [panel runModalForDirectory:nsdir file:nsfile]==NSFileHandlingPanelOKButton ){
			str=stringFromNSString([panel filename]);
		}

	}else{
		NSOpenPanel *panel=[NSOpenPanel openPanel];

		if( nstitle ) [panel setTitle:nstitle];
		
		if( [panel runModalForDirectory:nsdir file:nsfile types:nsexts]==NSFileHandlingPanelOKButton ){
			str=stringFromNSString([panel filename]);
		}
	}
	endPanel();

	return str;
}

BBString *bbSystemRequestDir( BBString *title,BBString *dir ){

	NSString *nsdir=0;
	NSString *nstitle=0;
	NSOpenPanel *panel;

	BBString *str=&bbEmptyString;

	if( dir->length ){
		char tmp[PATH_MAX];
		realpath( bbTmpUTF8String(dir),tmp );
		nsdir=[NSString stringWithUTF8String:tmp];
	}
	
	if( title->length ){
		nstitle=tmpNSString(title);
	}

	panel=[NSOpenPanel openPanel];
	
	[panel setCanChooseFiles:NO];
	[panel setCanChooseDirectories:YES];
	[panel setCanCreateDirectories:YES];
	
	if( title ) [panel setTitle:nstitle];
	
	beginPanel();
	if( [panel runModalForDirectory:nsdir file:0 types:0]==NSFileHandlingPanelOKButton ){
		str=stringFromNSString([panel filename]);
	}
	endPanel();
	
	return str;
}

int bbOpenURL( BBString *bburl ){
	NSURL	*url;
	NSString *loc;
	int		res=0;

	checkDisplay();
	loc=tmpNSString(bburl);
	url=[NSURL URLWithString:[loc stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	if( url ) res=[[NSWorkspace sharedWorkspace] openURL:url];
	return res;
}

void bbSystemPostSyncOp( BBSyncOp syncOp,BBObject *syncInfo,int asyncRet ){
	AsyncOp *p=(AsyncOp*)malloc( sizeof(AsyncOp) );
	NSEvent *event=appDefEvent( BB_RESERVEDEVENTSUBTYPE1,(int)p,0 );
	p->asyncOp=0;
	p->asyncRet=asyncRet;
	p->syncOp=syncOp;
	p->syncInfo=syncInfo;
	[NSApp postEvent:event atStart:NO];
}

void bbSystemStartAsyncOp( BBAsyncOp asyncOp,int asyncInfo,BBSyncOp syncOp,BBObject *syncInfo ){
	AsyncOp *p=(AsyncOp*)malloc( sizeof( AsyncOp ) );
	NSEvent *event=appDefEvent( BB_RESERVEDEVENTSUBTYPE1,(int)p,0 );
	BBRETAIN( syncInfo );
	p->asyncOp=asyncOp;
	p->asyncInfo=asyncInfo;
	p->syncOp=syncOp;
	p->syncInfo=syncInfo;
	[NSThread detachNewThreadSelector:@selector(asyncOpThread:) toTarget:appDelegate withObject:event];
}

static NSScreen *DesktopScreen(){
	NSArray *screens;
	if( screens=[NSScreen screens] ){
		if( [screens count] ) return [screens objectAtIndex:0];
	}
	return 0;
}

int bbSystemDesktopWidth(){
	NSScreen *screen=DesktopScreen();
	if( screen ) return [screen frame].size.width;
	return 640;
}

int bbSystemDesktopHeight(){
	NSScreen *screen=DesktopScreen();
	if( screen ) return [screen frame].size.height;
	return 480;
}

int bbSystemDesktopDepth(){
	NSScreen *screen=DesktopScreen();
	if( screen ) return NSBitsPerPixelFromDepth( [screen depth] );
	return 32;
}

int bbSystemDesktopHertz(){
	return 60;
}
