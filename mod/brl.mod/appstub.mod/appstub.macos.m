
#include <brl.mod/blitz.mod/blitz.h>

#import <AppKit/AppKit.h>

void __bb_appstub_appstub();

static int app_argc;
static char **app_argv;

static NSMutableArray *_appArgs;
static NSAutoreleasePool *_globalPool;

static void createAppMenu( NSString *appName ){

	NSMenu *appMenu;
	NSMenuItem *item;
	NSString *title;
	
	[NSApp setMainMenu:[NSMenu new]];
	
	appMenu=[NSMenu new];
	
	title=[@"Hide " stringByAppendingString:appName];
	[appMenu addItemWithTitle:@"Hide" action:@selector(hide:) keyEquivalent:@"h"];

	item=(NSMenuItem*)[appMenu addItemWithTitle:@"Hide Others" action:@selector(hideOtherApplications:) keyEquivalent:@"h"];
	[item setKeyEquivalentModifierMask:(NSAlternateKeyMask|NSCommandKeyMask)];
	
	[appMenu addItemWithTitle:@"Show All" action:@selector(unhideAllApplications:) keyEquivalent:@""];
	
	[appMenu addItem:[NSMenuItem separatorItem]];

	title=[@"Quit " stringByAppendingString:appName];
	[appMenu addItemWithTitle:title action:@selector(terminate:) keyEquivalent:@"q"];
	
	item=[NSMenuItem new];
	[item setSubmenu:appMenu];
	[[NSApp mainMenu] addItem:item];
	
	[NSApp performSelector:NSSelectorFromString(@"setAppleMenu:") withObject:appMenu];
}

static void run(){

	signal( SIGPIPE,SIG_IGN );
	
	bbStartup( app_argc,app_argv,0,0 );

	__bb_appstub_appstub();
	
	exit( 0 );
}

void bbFlushAutoreleasePool(){
	[_globalPool release];
	_globalPool=[[NSAutoreleasePool alloc] init];
}

@interface BlitzMaxAppDelegate : NSObject{
}
@end

@implementation BlitzMaxAppDelegate
-(void)applicationWillTerminate:(NSNotification*)notification{
	exit(0);
}

-(NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication*)sender{
	return NSTerminateCancel;
}

-(BOOL)application:(NSApplication*)app openFile:(NSString*)path{
	[_appArgs addObject:path];
	return YES;
}

-(void)applicationDidFinishLaunching:(NSNotification*)notification{
	int i;
	app_argc=[_appArgs count];
	app_argv=(char**)malloc( (app_argc+1)*sizeof(char*) );
	for( i=0;i<app_argc;++i ){
		NSString *t=[_appArgs objectAtIndex:i];
		char *p=(char*)malloc( [t length]+1 );
		strcpy( p,[t cString] );
		app_argv[i]=p;
	}
	app_argv[i]=0;
	[_appArgs release];

	[NSApp activateIgnoringOtherApps:YES];
	
	run();
}
@end

int main( int argc,char *argv[] ){
	int i;
	CFURLRef url;
	char *app_file,*p;
	
	_globalPool=[[NSAutoreleasePool alloc] init];

	[NSApplication sharedApplication];
	
	app_argc=argc;
	app_argv=argv;
	
	url=CFBundleCopyExecutableURL( CFBundleGetMainBundle() );

	app_file=malloc( 4096 );
	CFURLGetFileSystemRepresentation( url,true,(UInt8*)app_file,4096 );
	
	if( strstr( app_file,".app/Contents/MacOS/" ) ){
		//GUI app!
		//
		p=strrchr( app_file,'/' );
		if( p ){
			++p;
		}else{
			 p=app_file;
		}
		createAppMenu( [NSString stringWithCString:p] );
		free( app_file );
	
		[NSApp setDelegate:[[BlitzMaxAppDelegate alloc] init]];
		
		_appArgs=[[NSMutableArray arrayWithCapacity:10] retain];
		[_appArgs addObject:[NSString stringWithCString:argv[0]] ];
			
		[NSApp run];
	}else{
		//Console app!
		//
		free( app_file );

		run();
	}
}
