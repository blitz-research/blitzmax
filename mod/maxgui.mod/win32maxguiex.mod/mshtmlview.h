
#ifndef MSHTMLVIEW_H
#define MSHTMLVIEW_H

extern "C"{

int msHtmlCreate( void *gadget,wchar_t *wndclass,int hwnd,int flags );

void msHtmlGo( int handle,wchar_t *url );
void msHtmlRun( int handle,wchar_t *script );

void msHtmlSetShape( int handle,int x,int y,int w,int h );
void msHtmlSetVisible( int handle,int visible );
void msHtmlSetEnabled( int handle,int enabled );

int msHtmlActivate(int handle,int cmd);
int msHtmlStatus(int handle);
int msHtmlHwnd( int handle );
void *msHtmlBrowser( int handle );

};

#endif
