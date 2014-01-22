#include "src/Fl.cxx"

#import <Cocoa/Cocoa.h>

extern "C"{
	void* NSContentView(NSWindow*);
	void NSUpdateCanvas(NSWindow*);
}

void* NSContentView(NSWindow* window){
	return [window contentView];
}

void NSUpdateCanvas(NSWindow* window){
	NSRect rect = [window frame];
	int style = [window styleMask];
	rect = [window contentRectForFrameRect:rect];
	[window setContentSize:rect.size];
}

#include "src/Fl_Printer.cxx"

#include "src/Fl_Native_File_Chooser.cxx"