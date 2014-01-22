
#if _WIN32

#include <windows.h>

static HMODULE openAL;

int LoadOpenAL(){

	openAL=LoadLibrary( "OpenAL32.dll" );
	
	return openAL!=0;
}

void *GetOpenALFunction( const char *fname ){

	if( !openAL ) return 0;
	
	return GetProcAddress( openAL,fname );
}

#endif

#if __APPLE__

#import <CoreFoundation/CoreFoundation.h>

static CFBundleRef openAL;

static CFBundleRef OpenBundle( const char *path ){
	CFURLRef url;
	CFStringRef str;
	CFBundleRef bundle;
	str=CFStringCreateWithCString( kCFAllocatorDefault,path,kCFStringEncodingASCII );
	url=CFURLCreateWithFileSystemPath( kCFAllocatorDefault,str,kCFURLPOSIXPathStyle,true );
	bundle=CFBundleCreate( kCFAllocatorDefault,url );
	CFRelease( url );
	CFRelease( str );
	return bundle;
}

int LoadOpenAL(){

	openAL=OpenBundle( "/System/Library/Frameworks/OpenAL.framework" );
	if( !openAL ) openAL=OpenBundle( "/Library/Frameworks/OpenAL.framework" );
	
	return openAL!=0;
}

void *GetOpenALFunction( const char *fname ){
	void *p;
	CFStringRef str;
	
	if( !openAL ) return 0;
	
	str=CFStringCreateWithCString( kCFAllocatorDefault,fname,kCFStringEncodingASCII );
	
	p=CFBundleGetFunctionPointerForName( openAL,str );
	
	CFRelease( str );
	
	return p;
}

#endif

#if __linux

#include <dlfcn.h>

static void *openAL;

int LoadOpenAL(){

	openAL=dlopen( "libopenal.so",RTLD_NOW );
	if( !openAL ) openAL=dlopen( "libopenal.so.0",RTLD_NOW );
	if( !openAL ) openAL=dlopen( "libopenal.so.0.0.8",RTLD_NOW );

	return openAL!=0;
}

void *GetOpenALFunction( const char *fname ){

	if( !openAL ) return 0;

	return dlsym( openAL,fname );
}

#endif
