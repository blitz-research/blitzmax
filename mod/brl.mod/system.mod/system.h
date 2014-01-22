
#ifndef BB_BRL_SYSTEM_H
#define BB_BRL_SYSTEM_H

#include <brl.mod/blitz.mod/blitz.h>

#include <brl.mod/event.mod/event.h>	//event enums

#include <brl.mod/keycodes.mod/keycodes.h>	//keycode enums

typedef int (*BBAsyncOp)( int asyncInfo );
typedef void (*BBSyncOp)( BBObject *syncInfo,int asyncRet );

void bbSystemPostSyncOp( BBSyncOp syncOp,BBObject *syncInfo,int asyncRet );
void bbSystemStartAsyncOp( BBAsyncOp asyncOp,int asyncInfo,BBSyncOp syncOp,BBObject *syncInfo );

#ifdef __cplusplus
extern "C"{
#endif

void bbSystemEmitEvent( int id,BBObject *source,int data,int mods,int x,int y,BBObject *extra );

#if _WIN32

#include <windows.h>

#define WM_BBRESERVED1 0x7001

void bbSystemEmitOSEvent( HWND hwnd,UINT msg,WPARAM wParam,LPARAM lParam,BBObject *source );
	
#elif __APPLE__

#define BB_RESERVEDEVENTSUBTYPE1 0x7001	//reserved event substype

#ifdef __OBJC__
#include <AppKit/AppKit.h>
#else
typedef void *NSView;
typedef void *NSEvent;
#endif

int bbSystemTranslateKey( int key );
int	bbSystemTranslateChar( int chr );
int	bbSystemTranslateMods( int mods );
void bbSystemViewClosed( NSView *view );
void bbSystemEmitOSEvent( NSEvent *event,NSView *view,BBObject *source );

BBString * brl_blitz_bbStringFromUTF8String(const char * text);

#elif __linux

#include <X11/Xlib.h>
void bbSystemEmitOSEvent( XEvent *event,BBObject *source );

#endif

#ifdef __cplusplus
}
#endif

#endif
