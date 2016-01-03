// cocoa.macos.m
// a maxgui cocoa interface 

#include <AppKit/AppKit.h>
#include <WebKit/WebView.h>
#include <WebKit/WebFrame.h>a
#include <WebKit/WebPolicyDelegate.h>
#include <WebKit/WebFrameLoadDelegate.h>
#include <WebKit/WebDataSource.h>
#include <ApplicationServices/ApplicationServices.h>

#include <brl.mod/blitz.mod/blitz.h>
#include <maxgui.mod/maxgui.mod/maxgui.h>
#include <pub.mod/macos.mod/macos.h>

#define STATUSBARHEIGHT 18

// Custom Cursor Stuff

const int curNoEntry = 0;
const int curHelp = 1;
const int curSizeAll = 2;
const int curNESW = 3;
const int curNWSE = 4;

typedef struct { short bits[16]; short mask[16]; short hitpoint[2]; } ArrayCursor;

ArrayCursor arrCursors[5] =
{{{0x0000, 0x07E0, 0x1FF0, 0x3838, 0x3C0C, 0x6E0E, 0x6706, 0x6386, 0x61C6, 0x60E6, 0x7076, 0x303C, 0x1C1C, 0x0FF8, 0x07E0, 0x0000},
{0x0540, 0x0FF0, 0x3FF8, 0x3C3C, 0x7E0E, 0xFF0F, 0x6F86, 0xE7C7, 0x63E6, 0xE1F7, 0x70FE, 0x707E, 0x3C3C, 0x1FFC, 0x0FF0, 0x0540},
{0x0007, 0x0007}},
{{0x0000, 0x4078, 0x60FC, 0x71CE, 0x7986, 0x7C06, 0x7E0E, 0x7F1C, 0x7FB8, 0x7C30, 0x6C30, 0x4600, 0x0630, 0x0330, 0x0300, 0x0000},
{0xC078, 0xE0FC, 0xF1FE, 0xFBFF, 0xFFCF, 0xFF8F, 0xFF1F, 0xFFBE, 0xFFFC, 0xFE78, 0xFF78, 0xEFF8, 0xCFF8, 0x87F8, 0x07F8, 0x0300},
{0x0001, 0x0001}},
{{0x0000, 0x0080, 0x01C0, 0x03E0, 0x0080, 0x0888, 0x188C, 0x3FFE, 0x188C, 0x0888, 0x0080, 0x03E0, 0x01C0, 0x0080, 0x0000, 0x0000},
{0x0080, 0x01C0, 0x03E0, 0x07F0, 0x0BE8, 0x1DDC, 0x3FFE, 0x7FFF, 0x3FFE, 0x1DDC, 0x0BE8, 0x07F0, 0x03E0, 0x01C0, 0x0080, 0x0000},
{0x0007, 0x0008}},
{{0x0000, 0x001E, 0x000E, 0x060E, 0x0712, 0x03A0, 0x01C0, 0x00E0, 0x0170, 0x1238, 0x1C18, 0x1C00, 0x1E00, 0x0000, 0x0000, 0x0000},
{0x007F, 0x003F, 0x0E1F, 0x0F0F, 0x0F97, 0x07E3, 0x03E1, 0x21F0, 0x31F8, 0x3A7C, 0x3C3C, 0x3E1C, 0x3F00, 0x3F80, 0x0000, 0x0000},
{0x0006, 0x0009}},
{{0x0000, 0x7800, 0x7000, 0x7060, 0x48E0, 0x05C0, 0x0380, 0x0700, 0x0E80, 0x1C48, 0x1838, 0x0038, 0x0078, 0x0000, 0x0000, 0x0000},
{0xFE00, 0xFC00, 0xF870, 0xF0F0, 0xE9F0, 0xC7E0, 0x87C0, 0x0F84, 0x1F8C, 0x3E5C, 0x3C3C, 0x387C, 0x00FC, 0x01FC, 0x0000, 0x0000},
{0x0006, 0x0006}}};

// End of Cursor Stuff


void brl_event_EmitEvent( BBObject *event );
BBObject *maxgui_maxgui_HotKeyEvent( int key,int mods );
void maxgui_maxgui_DispatchGuiEvents();
void maxgui_cocoamaxgui_EmitCocoaOSEvent( NSEvent *event,void *handle,BBObject *gadget );
int maxgui_cocoamaxgui_EmitCocoaMouseEvent( NSEvent *event,void *handle );
int maxgui_cocoamaxgui_EmitCocoaKeyEvent( NSEvent *event,void *handle );
void maxgui_cocoamaxgui_PostCocoaGuiEvent( int ev,void *handle,int data,int mods,int x,int y,BBObject *extra );

int maxgui_cocoamaxgui_FilterChar( void *handle,int key,int mods );
int maxgui_cocoamaxgui_FilterKeyDown( void *handle,int key,int mods );

static void EmitOSEvent( NSEvent *event,void *handle ){
	maxgui_cocoamaxgui_EmitCocoaOSEvent( event,handle,&bbNullObject );
}

int HaltMouseEvents;

static int EmitMouseEvent( NSEvent *event,void *handle ){
	if(([event type] == NSScrollWheel) && ([event deltaY] == 0)) return 0;
	if(!HaltMouseEvents) return maxgui_cocoamaxgui_EmitCocoaMouseEvent( event,handle );
}

static int EmitKeyEvent( NSEvent *event,void *handle ){
	return maxgui_cocoamaxgui_EmitCocoaKeyEvent( event,handle );
}

static void PostGuiEvent( int ev,void *handle,int data,int mods,int x,int y,BBObject *extra ){
	if (extra==0) extra=&bbNullObject;
	maxgui_cocoamaxgui_PostCocoaGuiEvent( ev,handle,data,mods,x,y,extra );
}

static int filterKeyDownEvent( NSEvent *event,id source ){
	int i,sz,res,key,mods;
	NSString *ch;
	key=bbSystemTranslateKey( [event keyCode] );
	mods=bbSystemTranslateMods( [event modifierFlags] );
	res=maxgui_cocoamaxgui_FilterKeyDown( source,key,mods );
	if (res==0) return 0;
	ch=[event characters];
	sz=[ch length];
	for( i=0;i<sz;++i ){
		key=[ch characterAtIndex:i];
		switch( key ){
			case 3:key=13;break;	//Brucey's numberpad enter-key hack
			case 127:key=8;break;
			case 63272:key=127;break;
		}
		res=maxgui_cocoamaxgui_FilterChar( source,key,mods );
		if (res==0) return 0;
	}
	return 1;
}

void NSRelease( NSObject *obj ){[obj release];}

typedef struct nsgadget nsgadget;

struct nsgadget{
// BBObject
	BBClass*	clas;
	int			refs;
// gadget
	BBObject	*target;	
	nsgadget	*group;
	BBObject	*kidlist;
	int			x,y,w,h;
	BBString		*textarg;
	void			*extra;
	int			style, sensitivity;
	int			visible,total;
	int			lockl,lockr,lockt,lockb;
	int			lockx,locky,lockw,lockh,lockcw,lockch;
	void			*filter,*context;
	void			*items;
	int			*arrPrevSelection;
	BBObject		*datasource;
	void			*datakeys;//$[]
// nsGadget
	int			internalclass, origclass;
	id			handle;		
	NSView		*view;
	NSColor		*textcolor;
	int 			intFontStyle;
};

// From S.O. for vertically text in cells...
//
@interface TreeViewCell : NSBrowserCell {
}

@end

@implementation TreeViewCell

- (NSRect)titleRectForBounds:(NSRect)theRect {
    NSRect titleFrame = [super titleRectForBounds:theRect];
    NSSize titleSize = [[self attributedStringValue] size];
    titleFrame.origin.y = theRect.origin.y - .5 + (theRect.size.height - titleSize.height) / 2.0;
    titleFrame.origin.x += (theRect.size.height - titleSize.height) / 2.0;
    return titleFrame;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    NSRect titleRect = [self titleRectForBounds:cellFrame];
    [[self attributedStringValue] drawInRect:titleRect];
}

@end
// prototypes

void NSClearItems(nsgadget *gadget);

void NSSetSelection(nsgadget *gadget,int pos,int length,int units);

@class CocoaApp;
@class FlippedView;
@class PanelView;
@class CanvasView;
@class ListView;
@class TreeView;
@class NodeItem;
@class TextView;
@class TabView;
@class WindowView;
@class ImageString;
@class TableView;
@class ToolView;
@class Scroller;

@interface CocoaApp:NSObject{
	NSMutableDictionary	*toolbaritems;
	NSMutableArray		*menuitems;
}
-(id)init;
+(void)delayedGadgetAction:(NSNotification*)n;
+(void)dispatchGuiEvents;
-(BOOL)windowShouldClose:(id)sender;
-(void)windowDidResize:(NSNotification *)aNotification;
-(void)windowDidMove:(NSNotification *)aNotification;
-(BOOL)windowShouldZoom:(NSWindow *)sender toFrame:(NSRect)newFrame;
-(void)windowDidBecomeKey:(NSNotification *)aNotification;
-(void)menuSelect:(id)sender;
-(void)iconSelect:(id)sender;
-(void)sliderSelect:(id)sender;
-(void)scrollerSelect:(id)sender;
-(void)buttonPush:(id)sender;
-(void)textEdit:(id)sender;
-(void)comboBoxSelectionDidChange:(NSNotification *)notification;
-(void)addToolbarItem:(NSToolbarItem *)item;
-(NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag;
-(NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar;
-(NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar;
-(BOOL)validateToolbarItem:(NSToolbarItem *)theItem;
-(void)addMenuItem:(NSMenuItem *)item;
-(void)removeMenuItem:(NSMenuItem *)item;
@end

void ScheduleEventDispatch(){
	[CocoaApp performSelector:@selector(dispatchGuiEvents) withObject:nil afterDelay:0.0];
}

@interface Scroller:NSScroller{
}
-(id)init;
//-(id)initWithFrame:(NSRect)rect;
//-(void)drawParts;
//-(void)drawKnob;
//-(void)drawKnobSlotInRect:(NSRect)slotRect highlight:(BOOL)flag;
//-(void)drawArrow:(NSScrollerArrow)arrow highlight:(BOOL)flag;
//-(void)highlight:(BOOL)flag;
@end

@interface FlippedView:NSView{
}
-(BOOL)isFlipped;
-(BOOL)mouseDownCanMoveWindow;
@end

@interface PanelView:NSBox{
	int			style;
	int			enabled;
	nsgadget		*gadget;
}
-(BOOL)isFlipped;
-(BOOL)mouseDownCanMoveWindow;
-(void)setColor:(NSColor*)rgb;
-(void)setAlpha:(float)alpha;
-(void)setGadget:(nsgadget*)_gadget;
-(void)setStyle:(int)s;
-(void)setImage:(NSImage *)image withFlags:(int)flags;
-(BOOL)acceptsFirstResponder;
-(BOOL)becomeFirstResponder;

-(void)setEnabled:(BOOL)flag;
-(BOOL)isEnabled;
@end

@interface PanelViewContent:NSView{
	NSColor		*color;
	NSImage		*image;
	int			imageflags;
	float		alpha;
}
-(BOOL)isFlipped;
-(BOOL)mouseDownCanMoveWindow;
-(void)setColor:(NSColor*)rgb;
-(void)setAlpha:(float)alpha;
-(void)setImage:(NSImage *)image withFlags:(int)flags;
-(void)drawRect:(NSRect)rect;
@end

@interface CanvasView:PanelView{
}
-(void)drawRect:(NSRect)rect;
-(BOOL)acceptsFirstResponder;
-(BOOL)becomeFirstResponder;
@end

@interface ListView:NSScrollView{
	TableView *table;
	NSTableColumn *column;
	NSBrowserCell *cell;
	NSMutableArray *items;
	NSDictionary	*textstyle;
}
-(id)initWithFrame:(NSRect)rect;
-(id)table;
-(id)items;
-(void)removeItemAtIndex:(int)index;
-(void)setColor:(NSColor*)color;
-(void)setTextColor:(NSColor*)color;
-(int)numberOfRowsInTableView:(NSTableView *)aTableView;
-(id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
-(BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(int)rowIndex;
-(void)clear;
-(void)addItem:(NSString*)text atIndex:(unsigned)index withImage:(NSImage*)image withTip:(NSString*)tip withExtra:(BBObject*)extra;
-(void)setItem:(NSString*)text atIndex:(unsigned)index withImage:(NSImage*)image withTip:(NSString*)tip withExtra:(BBObject*)extra;
-(void)selectItem:(unsigned)index;
-(void)deselectItem:(unsigned)index;
-(void)tableViewSelectionDidChange:(NSNotification *)aNotification;
-(void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
-(void)setEnabled:(BOOL)flag;
-(BOOL)isEnabled;
-(void)updateWidthForString:(ImageString *) string;
-(void)updateWidth;
-(void)queueWidthUpdate;
-(void)dealloc;
-(void)setFont:(NSFont*)font;
-(NSString *)view:(NSView *)view stringForToolTip:(NSToolTipTag)tag point:(NSPoint)point userData:( void  *)data;
@end

@interface TableView:NSTableView{
}
-(NSMenu*)menuForEvent:(NSEvent *)theEvent;
@end

@interface OutlineView:NSOutlineView{
}
-(NSMenu*)menuForEvent:(NSEvent *)theEvent;
@end

@interface NodeItem:NSObject{
	TreeView		*owner;
	NodeItem		*parent;
	NSMutableArray *kids;
	NSString		*title;
	NSImage		*icon;
}
-(void)dealloc;
-(id)initWithTitle:(NSString*)text;
-(void)updateWidth;
-(void)setOwner:(TreeView*)treeview;
-(id)getOwner;
-(void)show;
-(void)attach:(NodeItem*)parent_ atIndex:(unsigned)index_;
-(void)remove;
-(BOOL)canExpand;
-(NSMutableArray*)kids;
-(NSString *)value;
-(NSImage *)icon;
-(void)setTitle:(NSString*)text;
-(void)setIcon:(NSImage*)image;
-(unsigned)count;
@end

@interface TreeView:NSScrollView{
@public
	NSOutlineView	*outline;
	NSTableColumn	*column;//,*colin;
	NSBrowserCell	*cell;
	NodeItem		*rootNode;
	NSDictionary	*textstyle;
}
-(id)initWithFrame:(NSRect)rect;
-(void)reloadItem:(id)item;
-(void)refresh;
-(int)outlineView:(NSOutlineView*)outlineView numberOfChildrenOfItem:(id)item;
-(id)outlineView:(NSOutlineView*)outlineView child:(int)index ofItem:(id)item;
-(BOOL)outlineView:(NSOutlineView*)outlineView isItemExpandable:(id)item;
-(id)outlineView:(NSOutlineView*)outlineView objectValueForTableColumn:(NSTableColumn*)tableColumn byItem:(id)item;
-(unsigned)count;
-(id)rootNode;
-(id)selectedNode;
-(void)selectNode:(id)node;
-(void)expandNode:(id)node;
-(void)collapseNode:(id)node;
-(void)outlineViewItemDidExpand:(NSNotification *)notification;
-(void)outlineViewItemDidCollapse:(NSNotification *)notification;
-(void)outlineViewSelectionDidChange:(NSNotification *)notification;
-(BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item;
-(void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)dcell forTableColumn:(NSTableColumn *)tableColumn item:(id)item;
-(void)setColor:(NSColor*)color;
-(void)setTextColor:(NSColor*)color;
-(void)setFont:(NSFont*)font;
-(void)setEnabled:(BOOL)e;
-(BOOL)isEnabled;
-(void)dealloc;
@end

@interface TextView:NSTextView{
@public
	NSScrollView	*scroll;
	NSMutableParagraphStyle *style;
	NSMutableDictionary *styles;
	NSTextStorage *storage;
	int lockedNest;
	NSRange lockedRange;
}
-(NSSize)contentSize;
-(id)storage;
-(id)initWithFrame:(NSRect)rect;
-(id)getScroll;
-(void)setHidden:(BOOL)flag;
-(void)setWordWrap:(BOOL)flag;
-(void)setTabs:(int)tabs;
-(void)setMargins:(int)leftmargin;
-(void)setText:(NSString*)text;
-(void)addText:(NSString*)text;
-(void)setScrollFrame:(NSRect)rect;
-(void)setTextColor:(NSColor*)color;
-(void)setColor:(NSColor*)color;
-(void)setFont:(NSFont*)font;
-(NSMenu *)menuForEvent:(NSEvent*)theEvent;
-(void)textDidChange:(NSNotification*)aNotification;
-(void)textDidEndEditing:(NSNotification*)aNotification;
-(void)textViewDidChangeSelection:(NSNotification *)aNotification;
-(void)textStorageDidProcessEditing:(NSNotification *)aNotification;
-(void)textStorageWillProcessEditing:(NSNotification *)aNotification;
-(void)updateDragTypeRegistration;
-(NSArray *)acceptableDragTypes;
-(void)free;
@end

@interface TabView:NSTabView{
	id		client;
	int		user;
}
-(id)initWithFrame:(NSRect)rect;
-(id)clientView;
-(void)setFrame:(NSRect)frameRect;
-(void)selectTabViewItemAtIndex:(int)index;
-(BOOL)tabView:(NSTabView *)tabView shouldSelectTabViewItem:(NSTabViewItem *)tabViewItem;
-(void)dealloc;
@end

@interface WindowView:NSWindow{
	id	view;
	id	label[3];
	nsgadget *gadget;
	int enabled;
	int zooming;
	NSView *dragging;
}
-(id)textFirstResponder;
-(id)initWithContentRect:(NSRect)rect styleMask:(unsigned int)mask backing:(NSBackingStoreType)backing defer:(BOOL)flag withGadget:(nsgadget*)_gadget ;
-(id)clientView;
-(void)setStatus:(NSString*)text align:(int)pos;
-(void)sendEvent:(NSEvent*)event;
-(NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender;
-(BOOL)performDragOperation:(id <NSDraggingInfo>)sender;
-(void)didResize;
-(void)didMove;
-(void)zoom;
-(NSRect)localRect;
-(BOOL)canBecomeKeyWindow;
-(BOOL)canBecomeMainWindow;
-(BOOL)becomeFirstResponder;
-(void)setEnabled:(BOOL)flag;
-(BOOL)isEnabled;
-(void)dealloc;
@end

@interface ToolView:NSPanel{
	id	view;
	id	label[3];
	nsgadget *gadget;
	int enabled;
	int zooming;
	NSView *dragging;
}
-(id)textFirstResponder;
-(id)initWithContentRect:(NSRect)rect styleMask:(unsigned int)mask backing:(NSBackingStoreType)backing defer:(BOOL)flag withGadget:(nsgadget*)_gadget ;
-(id)clientView;
-(void)setStatus:(NSString*)text align:(int)pos;
-(void)sendEvent:(NSEvent*)event;
-(NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender;
-(BOOL)performDragOperation:(id <NSDraggingInfo>)sender;
-(void)didResize;
-(void)didMove;
-(void)zoom;
-(NSRect)localRect;
-(BOOL)canBecomeKeyWindow;
-(BOOL)canBecomeMainWindow;
-(BOOL)becomeFirstResponder;
-(void)setEnabled:(BOOL)flag;
-(BOOL)isEnabled;
-(void)dealloc;
@end

static CocoaApp *GlobalApp;

@class HTMLView;
@interface HTMLView:WebView{
	int		_state, _style;
}
-(id)initWithFrame:(NSRect)rect;
-(int)loaded;
-(void)setStyle:(int)style;
-(void)setAddress:(NSString*)address;
-(NSString*)address;
@end
@implementation HTMLView
-(id)initWithFrame:(NSRect)rect{
	self=[super initWithFrame:rect];
	[self setAutoresizingMask:NSViewNotSizable];
	[self setPolicyDelegate:self];
	[self setFrameLoadDelegate:self];
	[self setUIDelegate:self];
	[self unregisterDraggedTypes];
	_state=0;
	return self;
}
-(int)loaded{
	return _state;
}
-(void)setStyle:(int)style{
	_style = style;
}
-(NSString*)address{
	WebDataSource		*datasource;
	datasource = [[self mainFrame] provisionalDataSource];
	if(datasource==nil) datasource = [[self mainFrame] dataSource];
	if(datasource==nil) return [[NSString alloc] initWithString:@""];
	return [[[datasource request] URL] absoluteString];
}
-(void)setAddress:(NSString*)address{
	NSURL			*url;
	NSURLRequest		*request;
	WebFrame			*frame;
		
	url=[NSURL URLWithString:address];
	if (url==nil) url=[NSURL fileURLWithPath:address];
	if (url==nil) return;
	_state=1;
	request=[NSURLRequest requestWithURL:url];
	frame=[self mainFrame];
	[frame loadRequest:request];
}
- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame{
	int oldstate = _state;
	NSURLRequest *url;
	BBString*text;
	
	_state=0;
	
	url=[[frame dataSource]initialRequest];
	text=bbStringFromCString((char*)[[[url URL] relativePath] cString]);
	
	if(oldstate)
		PostGuiEvent( BBEVENT_GADGETDONE,sender,0,0,0,0,(BBObject*)text );
}
- (void)webView:(WebView *)sender didChangeLocationWithinPageForFrame:(WebFrame *)frame{
	int oldstate = _state;
	NSURLRequest *url;
	BBString*text;
	
	_state=0;
	
	url=[[frame dataSource]initialRequest];
	text=bbStringFromCString((char*)[[[url URL] relativePath] cString]);
	
	if(oldstate)
		PostGuiEvent( BBEVENT_GADGETDONE,sender,0,0,0,0,(BBObject*)text );
}
- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)url frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener{
	BBString*text;
	int	key;
	key=(int)[[actionInformation objectForKey:WebActionNavigationTypeKey] intValue];
	switch (key){
	case WebNavigationTypeOther:
	case WebNavigationTypeLinkClicked:
		if ((_state==0) && (_style & HTMLVIEW_NONAVIGATE)) {
			[listener ignore];
			text=bbStringFromCString((char*)[[[url URL] absoluteString] cString]);
			PostGuiEvent( BBEVENT_GADGETACTION,sender,0,0,0,0,(BBObject*)text );
		}else{
			[listener use];
		}
	default:
		[listener use];
	}
}
- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems{
	if(_style&HTMLVIEW_NOCONTEXTMENU)
		return [NSArray array];
	else
		return defaultMenuItems;
}
@end


//Toolbar

@class Toolbar;
@interface Toolbar:NSToolbar{
	NSMutableDictionary	*items;
}
-(id)initWithIdentifier:(NSString *)string;
-(void)addToolbarItem:(NSToolbarItem *)item;
-(NSArray *)toolbarAllowedItemIdentifiers;
-(NSArray *)toolbarDefaultItemIdentifiers;
@end
@implementation Toolbar
-(id)initWithIdentifier:(NSString *)string{
	self=[super initWithIdentifier:string];
	items=[[NSMutableDictionary dictionaryWithCapacity:10] retain];
	return self;
}
-(void)addToolbarItem:(NSToolbarItem *)item{
	[items setObject:item forKey:[item itemIdentifier]];
}
-(NSArray *)toolbarAllowedItemIdentifiers{
	return [items allValues];
}
-(NSArray *)toolbarDefaultItemIdentifiers{
	return [items allValues];
}
@end


// CocoaApp
@implementation CocoaApp
+(void)dispatchGuiEvents{
	maxgui_maxgui_DispatchGuiEvents();
}
+(void)delayedGadgetAction:(NSObject*)o{  // See controlTextDidChange
	PostGuiEvent( BBEVENT_GADGETACTION, 
	              o, 
	              [o respondsToSelector:@selector(indexOfSelectedItem)] ? [o indexOfSelectedItem] : 0,
	              0,0,0,0 );
}
-(void)controlTextDidEndEditing:(NSNotification*)n{
	PostGuiEvent( BBEVENT_GADGETLOSTFOCUS,[n object],0,0,0,0,0 );
}
-(void)controlTextDidChange:(NSNotification*)n{
	NSObject *o = [n object];
	[CocoaApp performSelector:@selector(delayedGadgetAction:) withObject:o afterDelay:0.0];
}

-(id)init{
	toolbaritems=[[NSMutableDictionary dictionaryWithCapacity:10] retain];
	menuitems=[[NSMutableArray arrayWithCapacity:10] retain];
	return self;
}
-(BOOL)windowShouldClose:(id)sender{
	PostGuiEvent( BBEVENT_WINDOWCLOSE,sender,0,0,0,0,0 );
	return NO;
}
-(void)windowDidResize:(NSNotification *)aNotification{
	WindowView *window;
	ToolView * panel;
	if ([[aNotification object] isKindOfClass:[WindowView class]]) {
		window=(WindowView*)[aNotification object];
		[window didResize];
	} else {
		panel =(ToolView*)[aNotification object];
		[panel didResize];
	}
}
-(void)windowDidMove:(NSNotification *)aNotification{
	WindowView *window;
	ToolView * panel;
	if ([[aNotification object] isKindOfClass:[WindowView class]]) {
		window=(WindowView*)[aNotification object];
		[window didMove];
	} else {
		panel =(ToolView*)[aNotification object];
		[panel didMove];
	}
}
-(BOOL)windowShouldZoom:(NSWindow *)sender toFrame:(NSRect)newFrame{
	[(WindowView*)sender zoom];
	return YES;
}
-(void)windowDidBecomeKey:(NSNotification *)aNotification{
	NSWindow *window;
	window=(NSWindow*)[aNotification object];
	PostGuiEvent( BBEVENT_WINDOWACTIVATE,window,0,0,0,0,0 );
}
-(void)menuSelect:(id)sender{
	PostGuiEvent( BBEVENT_MENUACTION,sender,[sender tag],0,0,0,0 );
}
-(void)iconSelect:(id)sender{
	NSToolbar	*toolbar;
	int			index;
	toolbar=[sender toolbar];
	index=[[toolbar items] indexOfObject:sender];
	PostGuiEvent( BBEVENT_GADGETACTION,toolbar,index,0,0,0,0 );
}
-(void)sliderSelect:(id)sender{
	PostGuiEvent( BBEVENT_GADGETACTION,sender,0,0,0,0,0 );
}
-(void)scrollerSelect:(id)sender{
	NSScroller *scroller;
	int delta=0;
	scroller=(NSScroller *)sender;
	switch([scroller hitPart]){
	case NSScrollerDecrementLine:
		delta=-1;
		break;
	case NSScrollerDecrementPage:
		delta=-2;
		break;
	case NSScrollerIncrementLine:
		delta=1;
		break;
	case NSScrollerIncrementPage:
		delta=2;
		break;	
	}
	PostGuiEvent( BBEVENT_GADGETACTION,sender,delta,0,0,0,0 );
}
-(void)buttonPush:(id)sender{
	if([sender allowsMixedState]) [sender setAllowsMixedState:NO];
	PostGuiEvent( BBEVENT_GADGETACTION,sender,0,0,0,0,0 );
}
-(void)textEdit:(id)sender{
	PostGuiEvent( BBEVENT_GADGETACTION,sender,0,0,0,0,0 );
}
-(void)comboBoxSelectionDidChange:(NSNotification *)notification{
	NSControl *o=(NSComboBox*)[notification object];
	[CocoaApp performSelector:@selector(delayedGadgetAction:) withObject:o afterDelay:0.0];
}
-(void)comboBoxSelectionIsChanging:(NSNotification *)notification{
	
}
-(void)comboBoxWillPopUp:(NSNotification *)notification{
	HaltMouseEvents = 1;
}
-(void)comboBoxWillDismiss:(NSNotification *)notification{
	HaltMouseEvents = 0;
}
-(void)addToolbarItem:(NSToolbarItem *)item{
	[toolbaritems setObject:item forKey:[item itemIdentifier]];
}
-(NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag{
	return [toolbaritems objectForKey:itemIdentifier];
}
-(NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar{
	Toolbar *mytoolbar=(Toolbar*)toolbar;
	return [mytoolbar toolbarAllowedItemIdentifiers];
}
-(NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar{
	Toolbar *mytoolbar=(Toolbar*)toolbar;
	return [mytoolbar toolbarDefaultItemIdentifiers];
}
-(BOOL)validateToolbarItem:(NSToolbarItem *)item{
	return [item isEnabled];
}
-(void)addMenuItem:(NSMenuItem *)item{
	[menuitems addObject:item];
}
-(void)removeMenuItem:(NSMenuItem *)item{
	[menuitems removeObject:item];
}

@end

// Scroller

@implementation Scroller
-(id)init{
	[super init];
	[self setAlphaValue:.5f];		
	return self;
}
//-(void)drawKnob{}
//-(void)drawParts{}
//-(void)drawKnobSlotInRect:(NSRect)slotRect highlight:(BOOL)flag{}
//-(void)drawArrow:(NSScrollerArrow)arrow highlight:(BOOL)flag{}
//-(void)highlight:(BOOL)flag{}
@end

// FlippedView

@implementation FlippedView
-(BOOL)isFlipped{
	return YES;
}
-(BOOL)mouseDownCanMoveWindow{
	return YES;
}
@end

// PanelView

@implementation PanelView
- (BOOL)acceptsFirstResponder{
	return YES;
}
-(BOOL)becomeFirstResponder{
	return [self isEnabled];
}
-(void)setColor:(NSColor *)rgb{
	[[self contentView] setColor:rgb];
}
-(void)setAlpha:(float)al{
	[[self contentView] setAlpha:al];
}
-(void)setImage:(NSImage *)img withFlags:(int)flags{
	[[self contentView] setImage:img withFlags:flags];
}
-(void)setEnabled:(BOOL)e{
	enabled=e;
}
-(BOOL)isEnabled{
	return (enabled)?YES:NO;
}
-(void)setStyle:(int)s{
	
	gadget->sensitivity |= (s & PANEL_ACTIVE) ? (SENSITIZE_MOUSE|SENSITIZE_KEYS) : 0;
	
	switch ( s & (PANEL_SUNKEN|PANEL_RAISED|PANEL_GROUP) ){
		case PANEL_GROUP:
			[self setContentViewMargins: NSMakeSize(4.0,4.0)];
			[self setBoxType:NSBoxPrimary];
			[self setBorderType: NSBezelBorder];
			[self setTitlePosition: NSAtTop];
			break;
		case PANEL_RAISED:
		case PANEL_SUNKEN:
			[self setContentViewMargins: NSMakeSize(0.0,0.0)];
			[self setBoxType: NSBoxOldStyle];
			[self setBorderType: NSLineBorder];
			[self setTitlePosition: NSNoTitle];
			break;
		default:
			[self setContentViewMargins: NSMakeSize(0.0,0.0)];
			[self setBorderType: NSNoBorder];
			[self setTitlePosition: NSNoTitle];
	}
	
	style=s;
}
-(void)setGadget:(nsgadget*)_gadget{
	gadget=_gadget;
}
-(BOOL)mouseDownCanMoveWindow{
	return NO;
}
@end

//PanelViewContent
@implementation PanelViewContent
-(BOOL)isFlipped{
	return YES;
}
-(BOOL)mouseDownCanMoveWindow{
	return NO;
}
-(void)setColor:(NSColor *)rgb{
	if (color){
		[color release];
		color=0;
	}
	if(rgb){
		color=[rgb colorWithAlphaComponent:1.0];
		[color retain];
	}
	[self setNeedsDisplay:YES];
}
-(void)setImage:(NSImage *)img withFlags:(int)flags{
	if (img) [img retain];
	if (image) [image release];
	image=img;
	imageflags=flags;
	[self setNeedsDisplay:YES];
}
-(void)setAlpha:(float)al{
	alpha=al;
	if (color){
		[color release];
		color=[color colorWithAlphaComponent:alpha];
		[color retain];
	}
	[self setNeedsDisplay:YES];
}
-(void)drawRect:(NSRect)rect{
	
	NSRect dest = NSUnionRect(rect,[self frame]);
	
	if (color){
		[color set];
		if (alpha<1.0)
			NSRectFillUsingOperation( dest,NSCompositeSourceOver );
		else
			NSRectFill( dest );
	}
	
	if (image){
		int		op,x,y,w,h;
		float	a;
		float	m,mm;
		NSRect	src,tile;

		a=alpha;
		op=NSCompositeSourceOver;
		src.origin.x=0;
		src.origin.y=0;
		src.size=[image size];
		[image setFlipped:YES];

		switch (imageflags&(GADGETPIXMAP_ICON-1)){
		case PANELPIXMAP_TILE:
			tile.size=[image size];
			for (y=0;y<dest.size.height;y+=src.size.height){
				tile.origin.y=y;
				for (x=0;x<dest.size.width;x+=src.size.width){
					tile.origin.x=x;
					[image drawInRect:tile fromRect:src operation:op fraction:a];
				}
			}					
			break;
		case PANELPIXMAP_CENTER:
			dest.origin.x=(dest.size.width-src.size.width)/2;
			dest.origin.y=(dest.size.height-src.size.height)/2;
			dest.size=src.size;
			[image drawInRect:dest fromRect:src operation:op fraction:a];
			break;
		case PANELPIXMAP_FIT:
			m=dest.size.width/src.size.width;
			mm=dest.size.height/src.size.height;
			if (m>mm) m=mm;
			dest.origin.x+=(dest.size.width-src.size.width*m)/2;
			dest.origin.y+=(dest.size.height-src.size.height*m)/2;
			dest.size.width=src.size.width*m;
			dest.size.height=src.size.height*m;
			[image drawInRect:dest fromRect:src operation:op fraction:a];
			break;
		case PANELPIXMAP_STRETCH:
			[image drawInRect:dest fromRect:src operation:op fraction:a];
			break;
		case PANELPIXMAP_FIT2:
			m = dest.size.width/dest.size.height;
			
			if ((dest.size.width/src.size.width)<(dest.size.height/src.size.height)){
				src.origin.x = (src.size.width-(src.size.height*m))/2;
				src.size.width = src.size.height*m;
			} else {
				src.origin.y = (src.size.height-(src.size.width/m))/2;
				src.size.height = src.size.width/m;
			}
			
			[image drawInRect:dest fromRect:src operation:op fraction:a];
			break;
		}
		[image setFlipped:NO];
	}
	
	[super drawRect:rect];
} 
@end

// CanvasView
@implementation CanvasView
-(void)drawRect:(NSRect)rect{
	[super drawRect:rect];
	PostGuiEvent( BBEVENT_GADGETPAINT,self,0,0,0,0,0 );
} 
- (BOOL)acceptsFirstResponder{
	return YES;
}
-(BOOL)becomeFirstResponder{
	return [self isEnabled];
}
@end

// ImageString

@class ImageString;
@interface ImageString:NSObject{
	NSString	*_string;
	NSImage	*_image;
	NSString	*_tip;
	BBObject	*_extra;
}
-(id)initWithString:(NSString *)text image:(NSImage *)image tip:(NSString *)tip extra:(BBObject*)extra;
-(void)dealloc;
-(id)copyWithZone:(NSZone *)zone;
-(NSString*)string;
-(NSImage*)image;
-(NSString*)description;
-(BBObject*)extra;
@end
@implementation ImageString
-(id)initWithString:(NSString *)string image:(NSImage *)image tip:(NSString*)tip extra:(BBObject*)extra{
	_string=string;
	_image=image;
	_tip=tip;
	_extra=extra;
	if (string) [string retain];
	if (image) [image retain];
	if (tip) [tip retain];
	return self;
}
-(void)dealloc{
	if (_string) [_string release];
	if (_image) [_image release];
	if (_tip) [_tip release];
	[super dealloc];
}
-(id)copyWithZone:(NSZone *)zone{
	ImageString *copy=[[[self class] allocWithZone:zone] initWithString:_string image:_image tip:_tip extra:_extra];
	return copy;
}
-(NSString*)string{return _string;}
-(NSImage*)image{return _image;}
-(NSString*)description{return _tip;}
-(BBObject*)extra{return _extra;}
@end

// ListView

@implementation ListView
-(id)initWithFrame:(NSRect)rect{
	[super initWithFrame:rect];
	[self setBorderType:NSNoBorder];
	[self setHasVerticalScroller:YES];
	[self setHasHorizontalScroller:YES];
	[self setAutohidesScrollers:YES];
	column=[[NSTableColumn alloc] init];
	cell=[[NSBrowserCell alloc] init];
	[cell setLeaf:YES];
	[column setDataCell:cell];
	NSSize contentSize = [self contentSize];	
	table=[[TableView alloc] initWithFrame:NSMakeRect(0, 0,contentSize.width, contentSize.height)];
	[table setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
	items=[[NSMutableArray alloc] initWithCapacity:10];
	[table setHeaderView:nil];	
	[table setDataSource:self];
	[table setDelegate:self];
	[self setDocumentView:table];
	[table addTableColumn:column];
	[table sizeLastColumnToFit];
	return self;
}
-(id)table{
	return table;
}
-(id)items{
	return items;
}
-(void)removeItemAtIndex:(int)index{
	ImageString *item=(ImageString*)[items objectAtIndex:index];
	[items removeObjectAtIndex:index];
	[item release];
	[table reloadData];
	[self queueWidthUpdate];
}
-(void)setColor:(NSColor*)color{
	[table setBackgroundColor:color];
}
-(void)setEnabled:(BOOL)e{
	[table setEnabled:e];
}
-(BOOL)isEnabled{
	return [table isEnabled];
}
-(void)setTextColor:(NSColor*)color{
	if (textstyle) {[textstyle release];textstyle=nil;}
	if (color){
		textstyle=[NSDictionary dictionaryWithObjectsAndKeys:color,NSForegroundColorAttributeName,nil];
		[textstyle retain];	
	}
}
-(int)numberOfRowsInTableView:(NSTableView *)aTableView{
	return [items count];
}
-(id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex{
	return [items objectAtIndex:rowIndex];
}
-(BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(int)rowIndex{ /*new from BAH*/
	PostGuiEvent( BBEVENT_GADGETACTION,self,rowIndex,0,0,0,0 );
	return NO;
}
-(void)clear{
	[table setDelegate:nil];

	ImageString *item;
	int count,i;
	count=[items count];
	for (i=0;i<count;i++){
		item=(ImageString*)[items objectAtIndex:i];
		[item release];
	}

	[items removeAllObjects];
	[table reloadData];
	[table setDelegate:self];
	[self queueWidthUpdate];
}
-(void)addItem:(NSString*)text atIndex:(unsigned)index withImage:(NSImage*)image withTip:(NSString*)tip withExtra:(BBObject*)extra{
	ImageString *item;
	item=[[ImageString alloc] initWithString:text image:image tip:tip extra:extra];
	[items insertObject:item atIndex:index];
	[self updateWidthForString:item];
	[table noteNumberOfRowsChanged];
}
-(void)setItem:(NSString*)text atIndex:(unsigned)index withImage:(NSImage*)image withTip:(NSString*)tip withExtra:(BBObject*)extra{
	ImageString *item;
	item=(ImageString*)[items objectAtIndex:index];
	[item release];
	item=[[ImageString alloc] initWithString:text image:image tip:tip extra:extra];
	[items replaceObjectAtIndex:index withObject:item];
	[table reloadData];
	[self queueWidthUpdate];
}
-(void)selectItem:(unsigned)index{
	[table setDelegate:nil];
	[table selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
	[table setDelegate:self];
}
-(void)deselectItem:(unsigned)index{
	[table setDelegate:nil];
	[table deselectRow:index];
	[table setDelegate:self];
}
-(void)tableViewSelectionDidChange:(NSNotification *)aNotification{/*new from BAH*/
        int index=[table selectedRow];
        ImageString *item=nil;
        if (index>=0) item=(ImageString*)[items objectAtIndex:index]; else index=-1;
        if (item){
                PostGuiEvent( BBEVENT_GADGETSELECT,self,index,0,0,0,[item extra]);
        }else{
                PostGuiEvent( BBEVENT_GADGETSELECT,self,-1,0,0,0,&bbNullObject);
        }
}
-(void)tableView:(NSTableView *)table willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex{
	NSString *text=[[items objectAtIndex:rowIndex] string];
	if (textstyle){
		NSAttributedString *atext=[[[NSAttributedString alloc] initWithString:text attributes:textstyle] autorelease];
		[aCell setAttributedStringValue:atext];
	}else{
		[aCell setStringValue:text];
	}
	[aCell setImage:[[items objectAtIndex:rowIndex] image]];
}
-(void)updateWidthForString:(ImageString *) imgstring{
	
	NSCell*	dcell;
	float	cellWidth;
	
	dcell = [column dataCell];
	[dcell setStringValue:[imgstring string]];
	[dcell setImage:[imgstring image]];
	cellWidth = ((NSSize)[dcell cellSize]).width;

	if([column minWidth] < cellWidth){
		[column setMinWidth:cellWidth];
		[column setWidth:cellWidth];
		[table setNeedsDisplay:YES];
	}
	
}
-(void)updateWidth{
	int i, count;
	count = [items count];
	[column setMinWidth:0];
	for (i=0;i<count;i++)
		[self updateWidthForString:(ImageString*)[items objectAtIndex:i]];
}
-(void)queueWidthUpdate{
	[NSObject cancelPreviousPerformRequestsWithTarget: self selector:@selector(updateWidth) object:nil];
	[self performSelector:@selector(updateWidth) withObject:nil afterDelay:0.0];
}
-(void)dealloc{
	ImageString *item;
	int count,i;
	count=[items count];
	for (i=0;i<count;i++){
		item=(ImageString*)[items objectAtIndex:i];
		[item release];
	}

	[table release];
	[column release];
	[cell release];
	[items release];
	if (textstyle) {
		[textstyle release];
	}
	[super dealloc];
}
-(void)setFont:(NSFont*)font{
	if (font) {
		[table setRowHeight:[font defaultLineHeightForFont]+2];
		[[column dataCell] setFont:font];
		[table reloadData];
		[self updateWidth];
	}
}

- (NSString *)tableView:(NSTableView *)aTableView toolTipForCell:(NSCell *)aCell rect:(NSRectPointer)rect 
tableColumn:(NSTableColumn *)aTableColumn row:(int)row mouseLocation:(NSPoint)mouseLocation{
	
	return [[items objectAtIndex:row] description];
}

@end

// TableView

@implementation TableView
-(NSMenu*)menuForEvent:(NSEvent *)theEvent{
	int		row = -1;
	NSPoint p=[self convertPoint:[theEvent locationInWindow] fromView:nil];
	row = [self rowAtPoint:p];

	if (row < [self numberOfRows]) {
		[self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
		PostGuiEvent( BBEVENT_GADGETMENU,[self dataSource],row,0,0,0,0 );
	}

	return nil;
}
@end

// OutlineView

@implementation OutlineView
-(NSMenu*)menuForEvent:(NSEvent *)theEvent{
	id		node;
	NSPoint p=[self convertPoint:[theEvent locationInWindow] fromView:nil];
	int i=[self rowAtPoint:p];
	if (i>-1 && i<[self numberOfRows]){
		node=[self itemAtRow:i];
		PostGuiEvent( BBEVENT_GADGETMENU,[self dataSource],(int)node,0,0,0,0 );	//[self superview]
	}
	return nil;
}
@end

// TreeView

@implementation TreeView
-(id)initWithFrame:(NSRect)rect{
	[super initWithFrame:rect];
	[self setBorderType:NSNoBorder];
	[self setHasVerticalScroller:YES];
	[self setHasHorizontalScroller:YES];
	[self setAutohidesScrollers:YES];
	rootNode=[[NodeItem alloc] initWithTitle:@"root"];
	[rootNode setOwner:self];
	NSSize contentSize = [self contentSize];	
	outline=[[OutlineView alloc] initWithFrame:NSMakeRect(0, 0,contentSize.width, contentSize.height)];
	[outline setHeaderView:nil];	
	[outline setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
	[outline setDataSource:self];
	[outline setDelegate:self];
	column=[[NSTableColumn alloc] init];
	[outline addTableColumn:column];
	[outline setOutlineTableColumn:column];
	
//	cell=[[NSBrowserCell alloc] init];
//	[cell setLeaf:YES];
//	[cell setScrollable:YES];
//	[column setDataCell:cell];

	cell=[[TreeViewCell alloc] init];
	[cell setLeaf:YES];
	[cell setScrollable:YES];
	[column setDataCell:cell];
	
	[self setDocumentView:outline];
	[outline sizeLastColumnToFit];
	
	
	
	return self;
}
-(void)dealloc{
	[outline autorelease];
	[column autorelease];
	[cell autorelease];
	if (textstyle) {
		[textstyle release];
	}
	[super dealloc];
}
-(void)refresh{
	[rootNode updateWidth];
	[outline reloadData];
}
-(int)outlineView:(NSOutlineView*)outlineView numberOfChildrenOfItem:(id)item{
	if( !item ) item=rootNode;
	return [[item kids] count];
}
-(id)outlineView:(NSOutlineView*)outlineView child:(int)index ofItem:(id)item{
	if( !item ) item=rootNode;
	if (index>=[[item kids] count]) return 0;
	return [[item kids] objectAtIndex:index];
}
-(BOOL)outlineView:(NSOutlineView*)outlineView isItemExpandable:(id)item{
	if( !item ) item=rootNode;
	return [item canExpand];
}
-(id)outlineView:(NSOutlineView*)outlineView objectValueForTableColumn:(NSTableColumn*)tableColumn byItem:(id)item{
//	if (tableColumn==colin) return @"";	
	if( !item ) item=rootNode;
	return [item value];
}
-(unsigned)count{
	return [rootNode count];
}
-(id)rootNode{
	return rootNode;
}
-(id)selectedNode{
	int		index;
	index=[outline selectedRow];
	if (index==-1) return nil;
	return [outline itemAtRow:index];
}
-(void)selectNode:(id)node{
	int index;
	[node show];
	[outline setDelegate:nil];
	index = [outline rowForItem:node];
	[outline selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
	[outline setDelegate:self];
	[outline scrollRowToVisible:index];	
}
-(void)expandNode:(id)node{
	[outline setDelegate:nil];
	[outline expandItem:node];
	[outline tile];
	[outline setDelegate:self];
	[node queueWidthUpdate];
}
-(void)collapseNode:(id)node{
	[outline setDelegate:nil];
	[outline collapseItem:node];
	[outline tile];
	[outline setDelegate:self];
	[column setMinWidth:0];
	[rootNode queueWidthUpdate];
}
-(void)outlineViewItemDidExpand:(NSNotification *)notification{
	id		node;
	node=[[notification userInfo] objectForKey:@"NSObject"];
	[node queueWidthUpdate];
	PostGuiEvent( BBEVENT_GADGETOPEN,self,(int)node,0,0,0,0 );
}
-(void)outlineViewItemDidCollapse:(NSNotification *)notification{
	id		node;
	node=[[notification userInfo] objectForKey:@"NSObject"];
	[column setMinWidth:0];
	[rootNode queueWidthUpdate];
	PostGuiEvent( BBEVENT_GADGETCLOSE,self,(int)node,0,0,0,0 );
}
-(void)outlineViewSelectionDidChange:(NSNotification *)notification{
	id		node;
	node=[self selectedNode];
	PostGuiEvent( BBEVENT_GADGETSELECT,self,(int)node,0,0,0,0 );
}
-(BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item{
	PostGuiEvent( BBEVENT_GADGETACTION,self,(int)item,0,0,0,0 );
	return NO;
}
-(void)setColor:(NSColor*)color{
	[outline setBackgroundColor:color];
}
-(void)setTextColor:(NSColor*)color{
	if (textstyle) {[textstyle release];textstyle=nil;}
	if (color){
		textstyle=[NSDictionary dictionaryWithObjectsAndKeys:color,NSForegroundColorAttributeName,nil];
		[textstyle retain];	
	}
}
- (void)setFont:(NSFont*)font{
	if (font) {
		NSLayoutManager* layoutManager = [[[NSLayoutManager alloc] init] autorelease];
		int i;
		NSArray *columnsArray = [outline tableColumns];
		for (i= 0; i < [columnsArray count]; i++)
		[[[columnsArray objectAtIndex:i] dataCell] setFont:font];
		[outline setRowHeight: [layoutManager defaultLineHeightForFont:font]+1];
		[rootNode queueWidthUpdate];
	}
}
- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)dcell forTableColumn:(NSTableColumn *)tableColumn item:(id)node{
	if (textstyle){
		NSAttributedString *atext=[[[NSAttributedString alloc] initWithString:[node value] attributes:textstyle] autorelease];
		[dcell setAttributedStringValue:atext];
	}
	else{
		[dcell setStringValue:[node value]];
	}
	[dcell setImage:[node icon]];
}
-(void)setEnabled:(BOOL)e{
	[outline setEnabled:e];
}
-(BOOL)isEnabled{
	return [outline isEnabled];
}
@end

// NodeItem

@implementation NodeItem
-(void)dealloc{}
-(id)initWithTitle:(NSString*)text{
	owner=nil;
	parent=nil;
	title=text;
	icon=nil;
	[title retain];
	kids=[[NSMutableArray alloc] initWithCapacity:10];
	[kids retain];
	return self;
}
-(void)updateWidth{
	int 		i;
	float       cellWidth;
	float       indentationWidth;
	
	NSCell*	dcell;
	NSArray*	columnsArray;
	
	if(owner==nil) return;
	
	NSOutlineView*	outline = owner->outline;
	NSTableColumn*	tableColumn = owner->column;
	
	if(tableColumn!=nil){
		dcell = [tableColumn dataCell];
		[dcell setStringValue:title];
		[dcell setImage:icon];
		cellWidth = ((NSSize)[dcell cellSize]).width;
		indentationWidth = [outline levelForItem: self];
		if(isnan(indentationWidth)) indentationWidth = 0; else indentationWidth=([outline indentationPerLevel]*(indentationWidth+1));
		if((owner->rootNode == self) || [outline isItemExpanded:self])
			for (i= 0; i < [kids count]; i++) [[kids objectAtIndex:i] updateWidth];
		if([tableColumn minWidth] < (cellWidth+indentationWidth)){
			[tableColumn setMinWidth:(cellWidth+indentationWidth)];
			[tableColumn setWidth:(cellWidth+indentationWidth)];
		}
	}
}
-(void)queueWidthUpdate{
	[NSObject cancelPreviousPerformRequestsWithTarget: self selector:@selector(updateWidth) object:nil];
	[self performSelector:@selector(updateWidth) withObject:nil afterDelay:0.0];
}
-(void)setOwner:(TreeView*)treeview{
	owner=treeview;
}
-(id)getOwner{
	return owner;
}
-(void)show{
	if (parent){
		[parent show];
		[owner expandNode:parent];
	}
}
-(void)attach:(NodeItem*)parent_ atIndex:(unsigned)index_{
	parent=parent_;
	if( parent ){
		owner=parent->owner;
		[[parent kids] insertObject:self atIndex:index_];
		[self release];
	}
	if (owner) [owner refresh];
}
-(void)remove{
	if( parent ) [[parent kids] removeObject:self];
	if (owner) [owner refresh];
}
-(BOOL)canExpand{
	return [kids count]>0;
}
-(NSMutableArray*)kids{
	return kids;
}
-(NSString *)value{return title;}
-(NSImage *)icon{return icon;}
-(void)setTitle:(NSString*)text{
	[title release];
	title=text;
	[title retain];
	if (owner){
		[owner->outline reloadItem:self];
		[owner->rootNode queueWidthUpdate];
	}
}
-(void)setIcon:(NSImage*)image{
	if (icon) [icon release];
	icon=image;
	if (icon) [icon retain];
	if (owner){
		[owner->outline reloadItem:self];
		[(icon ? self : owner->rootNode) queueWidthUpdate];
	}
}
-(unsigned)count{
	return [kids count];
}
@end

// TextView

@implementation TextView
-(id)initWithFrame:(NSRect)rect{
	
	scroll=[[NSScrollView alloc] initWithFrame:rect];

//	[scroll setVerticalScroller:[[Scroller alloc] init]];
//	[scroll setHorizontalScroller:[[Scroller alloc] init]];

	[scroll setHasVerticalScroller:YES];
	[scroll setHasHorizontalScroller:YES];

	[scroll setDrawsBackground:NO];
	[scroll setRulersVisible:NO];
	[scroll setBorderType:NSNoBorder];
	[scroll setAutohidesScrollers:YES];
				
	NSSize contentSize = [scroll contentSize];	

	self=[super initWithFrame:NSMakeRect(0, 0,contentSize.width,contentSize.height)];
	[self setMinSize:NSMakeSize(contentSize.width, contentSize.height)];
	[self setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
	[self setVerticallyResizable:YES];
	[self setHorizontallyResizable:YES];
	[self setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
	[[self textContainer] setContainerSize:NSMakeSize(FLT_MAX,FLT_MAX)];
	[[self textContainer] setWidthTracksTextView:NO];	
	[self setDelegate:self];
	[self setUsesRuler:NO];

	[scroll setDocumentView:self];

	style=[[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[style setLineBreakMode:NSLineBreakByClipping];
	
	styles=[NSMutableDictionary dictionaryWithObject:style forKey:NSParagraphStyleAttributeName];
	[styles retain];
	storage=[self textStorage];
	[storage setDelegate:self];
	
	lockedNest=0;
	
	[self setTabs: 4];
	if ([self respondsToSelector: @selector(setDefaultParagraphStyle:)])
		[self setDefaultParagraphStyle: style];
	
	if ([self respondsToSelector: @selector(setAutomaticLinkDetectionEnabled:)])
		[self setAutomaticLinkDetectionEnabled: NO];
	if ([self respondsToSelector: @selector(setAutomaticQuoteSubstitutionEnabled:)])
		[self setAutomaticQuoteSubstitutionEnabled: NO];
	if ([self respondsToSelector: @selector(setAutomaticDashSubstitutionEnabled:)])
		[self setAutomaticDashSubstitutionEnabled: NO];
	if ([self respondsToSelector: @selector(setAutomaticSpellingCorrectionEnabled:)])
		[self setAutomaticSpellingCorrectionEnabled: NO];
	if ([self respondsToSelector: @selector(setAutomaticTextReplacementEnabled:)])
		[self setAutomaticTextReplacementEnabled: NO];
	if ([self respondsToSelector: @selector(setAutomaticDataDetectionEnabled:)])
		[self setAutomaticDataDetectionEnabled: NO];
		
	[self setContinuousSpellCheckingEnabled:NO];
	
	return self;
}
-(void)free{
	[scroll setDocumentView:nil];
	[scroll release];
	[style release];
	[styles release];
	[storage release];
}
//prevent 'word completion' popup when esc key hit with selected text...
-(NSArray*)textView:
		(NSTextView*)textView
		completions:(NSArray*)words
		forPartialWordRange:(NSRange)charRange
		indexOfSelectedItem:(NSInteger*)index{
	return nil;
}
-(void)setHidden:(BOOL)flag{
	[scroll setHidden:flag];
}
-(id)storage{
	return storage;
}
-(NSSize)contentSize{
	return [scroll contentSize];
}
-(id)getScroll{
	return scroll;
}
-(void)setWordWrap:(BOOL)flag{
	NSSize contentSize=[self contentSize];
	if (flag){
		[scroll setHasHorizontalScroller:NO];
		[self setHorizontallyResizable:NO];
		[self setAutoresizingMask:NSViewWidthSizable];
		[[self textContainer] setContainerSize:NSMakeSize(contentSize.width, FLT_MAX)];
		[[self textContainer] setWidthTracksTextView:YES];
		[style setLineBreakMode:NSLineBreakByWordWrapping];
	}
	else{
		[scroll setHasHorizontalScroller:YES];
		[self setHorizontallyResizable:YES];
		[self setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
		[[self textContainer] setContainerSize:NSMakeSize(FLT_MAX, FLT_MAX)];
		[[self textContainer] setWidthTracksTextView:NO];
		[style setLineBreakMode:NSLineBreakByClipping];
	}
	[storage addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0,[storage length])];	
}

-(void)setTabs:(int)tabs{	
	[style setTabStops:[NSArray array]];	//Clear any TabStops
	[style setDefaultTabInterval: tabs];	//Set recurring TabStops remembering to convert from twips->pixels
	[storage addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0,[storage length])];
}

-(void)setMargins:(int)leftmargin{

	[self setTextContainerInset:NSMakeSize( leftmargin, 0) ];
//	[style setFirstLineHeadIndent: leftmargin*8];
//	[style setHeadIndent: leftmargin*8];
//	[storage addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0,[storage length])];	
}

-(void)setText:(NSString*)text{
	NSAttributedString	*astring;
	astring=[[NSAttributedString alloc] initWithString:text attributes:styles];
	if (lockedNest) [storage endEditing];
	[storage setAttributedString:astring];
	if (lockedNest) [storage beginEditing]; else [self setSelectedRange:NSMakeRange(0,0)];
}
-(void)addText:(NSString*)text{
	NSAttributedString	*astring;
	astring=[[NSAttributedString alloc] initWithString:text attributes:styles];
	if (lockedNest) [storage endEditing];
	[storage appendAttributedString:astring];
	if (lockedNest) [storage beginEditing];
}
-(void)setScrollFrame:(NSRect)rect{
	[scroll setFrame:rect];
}
-(void)setTextColor:(NSColor*)color{
	[styles setObject:color forKey:NSForegroundColorAttributeName];
	[storage addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0,[storage length])];
	[self setInsertionPointColor:color];	
}
-(void)setColor:(NSColor*)color{
	if(color){
		[self setBackgroundColor:color];	
		[self setDrawsBackground:true];
		[scroll setBackgroundColor:color];
		[scroll setDrawsBackground:true];
	}else{
		[self setDrawsBackground:false];
		[scroll setDrawsBackground:false];
	}
}
-(void)setFont:(NSFont*)font{
	[styles setObject:font forKey:NSFontAttributeName];
	[storage setFont:font];	
	[super setFont:font];	
}
-(NSMenu *)menuForEvent:(NSEvent *)event{
	NSPoint	p;
	int		x,y;
	p=[event locationInWindow];	
	x=(int)p.x;y=(int)p.y;
	PostGuiEvent( BBEVENT_GADGETMENU,self,0,0,x,y,0 );
	return nil;
}
-(void)updateDragTypeRegistration{
}
-(NSArray *)acceptableDragTypes{
	return nil;
}
-(void)textDidBeginEditing:(NSNotification*)n{
//	printf( "textDidBeginEditing:%p\n",_textEditor );fflush(stdout);
}
-(void)textDidChange:(NSNotification*)n{
	PostGuiEvent( BBEVENT_GADGETACTION,self,0,0,0,0,0 );
}
-(void)textDidEndEditing:(NSNotification*)n{
//	printf( "textDidEndEditing:%p\n",_textEditor );fflush(stdout);
	PostGuiEvent( BBEVENT_GADGETLOSTFOCUS,[n object],0,0,0,0,0 );
}
-(void)textViewDidChangeSelection:(NSNotification *)aNotification{
	PostGuiEvent( BBEVENT_GADGETSELECT,self,0,0,0,0,0 );
}
-(void)textStorageDidProcessEditing:(NSNotification *)aNotification{

}
-(void)textStorageWillProcessEditing:(NSNotification *)aNotification{
	[storage removeAttribute:NSLinkAttributeName range:[storage editedRange]];
}
@end


// TabViewItem

@class TabViewItem;
@interface TabViewItem:NSTabViewItem{
	NSImage	*_image;
}
-(id)initWithIdentifier:(NSString *)text;
-(void)setImage:(NSImage*)image;
-(id)copyWithZone:(NSZone *)zone;
-(NSImage*)image;
-(NSSize)sizeOfLabel:(BOOL)shouldTruncateLabel;
-(void)drawLabel:(BOOL)shouldTruncateLabel inRect:(NSRect)tabRect;
@end
@implementation TabViewItem
-(id)initWithIdentifier:(NSString *)string{
	self=[super initWithIdentifier:string];
	_image=nil;
	return self;
}
-(void)setImage:(NSImage*)image{
	_image=image;
	if (_image) [_image setScalesWhenResized:YES];
}
-(id)copyWithZone:(NSZone *)zone{
	TabViewItem *copy=[[[self class] allocWithZone:zone] initWithIdentifier:[self identifier]];
	return copy;
}
-(NSImage*)image{
	return _image;
}
-(NSSize)sizeOfLabel:(BOOL)shouldTruncateLabel{
	NSSize	size;
	NSSize	imageDimensions;
	float		ratio;
	size=[super sizeOfLabel:shouldTruncateLabel];
	
	if (_image) {
		imageDimensions = [_image size];
		if (imageDimensions.height > size.height){
			ratio = size.height/imageDimensions.height;
			imageDimensions.width*=ratio;imageDimensions.height*=ratio;
			[_image setSize: imageDimensions];
		}
		size.width += imageDimensions.height;
	}
	return size;
}
-(void)drawLabel:(BOOL)shouldTruncateLabel inRect:(NSRect)content{
	NSSize	imageDimensions;
	NSPoint	point;
	if (_image){
		imageDimensions = [_image size];
		point = NSMakePoint(content.origin.x,content.origin.y+imageDimensions.height);
		[_image compositeToPoint:point operation:NSCompositeSourceOver];
		content.origin.x+=imageDimensions.width;content.size.width-=imageDimensions.width;		
	}
	[super drawLabel:shouldTruncateLabel inRect:content];
}
@end

// TabView

@implementation TabView
-(id)initWithFrame:(NSRect)rect{
	rect.size.height+=8;
	self=[super initWithFrame:rect];
	[super setControlSize:NSSmallControlSize];
	[super setFont:[NSFont labelFontOfSize:[NSFont smallSystemFontSize]]];	
	client=[[FlippedView alloc] initWithFrame:[self contentRect]];
	[client setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];	
	[client retain];
	user=1;	
	[self setDelegate:self];
	return self;
}
-(id)clientView{
	return client;
}
-(void)selectTabViewItemAtIndex:(int)index{
	user=0;
	[super selectTabViewItemAtIndex:index];
	user=1;
} 
-(void)setFrame:(NSRect)rect{
	rect.size.height+=8;
	[super setFrame:rect];
}
-(BOOL)tabView:(NSTabView *)tabView shouldSelectTabViewItem:(NSTabViewItem *)tabViewItem{
	int		index;
	[tabViewItem setView:client];
	[client setFrame:[self contentRect]];
	if (user){
		index=[self indexOfTabViewItem:tabViewItem];
		PostGuiEvent( BBEVENT_GADGETACTION,self,index,0,0,0,0);
	}
	return YES;
}
-(void)dealloc{
	NSArray			*items;
	int				i,n;
	
	items=[self tabViewItems];
	n=[items count];
	for (i=0;i<n;i++) [self removeTabViewItem:[items objectAtIndex:0]];

	[client release];
	[super dealloc];
}
-(NSMenu *)menuForEvent:(NSEvent *)event{
	int	index;
	NSTabViewItem*	tabItem;
	tabItem = [self tabViewItemAtPoint:[self convertPoint:[event locationInWindow] fromView:nil]];
	if (tabItem) index = [self indexOfTabViewItem:tabItem]; else index = -1;
	PostGuiEvent( BBEVENT_GADGETMENU,self,index,0,0,0,0);
	return [super menuForEvent:event];
}
@end

// WindowView

@implementation WindowView
-(id)textFirstResponder{
	id r=[self firstResponder];
	//if ([r isKindOfClass:[PanelView class]]) return r;
	if ([r isKindOfClass:[NSTextView class]]){
		id d=[r delegate];
		if( [d isKindOfClass:[NSTextField class]] ) return d;
	}
	return r;
}
-(id)initWithContentRect:(NSRect)rect styleMask:(unsigned int)mask backing:(NSBackingStoreType)backing defer:(BOOL)flag withGadget:(nsgadget*)_gadget{
//withStatus:(BOOL)status{
	id		client;
	int		i;
	NSText	*l;
	NSBox	*box;
	dragging = nil;
	self=[super initWithContentRect:rect styleMask:mask backing:backing defer:flag];
	gadget=_gadget;
	view=[[FlippedView alloc] init];
	enabled=true;
	[self setContentView:view];
	[self setAcceptsMouseMovedEvents:YES];
	[self disableCursorRects];	//Fixes NSSetPointer not sticking.
	if (gadget->style&WINDOW_STATUS){
		rect.origin.x=rect.origin.y=0;
		rect.size.height-=STATUSBARHEIGHT;
		client=[[FlippedView alloc] initWithFrame:rect];
		[client setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];	
		[view addSubview:client];
// label for window status
		rect.origin.y=rect.size.height+3;
		rect.size.height=STATUSBARHEIGHT-4;		
		rect.size.width-=[NSScroller scrollerWidth];
		for (i=0;i<3;i++){
			l=[[NSText alloc] initWithFrame:rect];
			[l setDrawsBackground:NO];
			[l setEditable:NO];
			[l setSelectable:NO];
			[l setAutoresizingMask:NSViewWidthSizable|NSViewMinYMargin];
			switch (i){
				case 0:[l setAlignment:NSLeftTextAlignment];break;
				case 1:[l setAlignment:NSCenterTextAlignment];break;
				case 2:[l setAlignment:NSRightTextAlignment];break;
			}
			if (view) [view addSubview:l];
			label[i]=l;
		}
		
		rect.origin.y-=3;
		rect.size.height=2;
		rect.size.width+=[NSScroller scrollerWidth];
		
		box=[[NSBox alloc] initWithFrame:rect];
		[box setBoxType:NSBoxSeparator];
		[box setTitlePosition:NSNoTitle];
		[box setAutoresizingMask:NSViewWidthSizable|NSViewMinYMargin];
		if (view) [view addSubview:box];
		
// set clientview to inner view
		view=client;		
	}
	return self;
}
-(id)clientView{
	return view;
}
-(void)setStatus:(NSString*)text align:(int)pos{
	if (label[pos]) [label[pos] setString:text];
}
-(void)sendEvent:(NSEvent*)event{
	
	static int lastHotKey;
	int key;
	id source;
	
	// Handling of Generic Key/Mouse Events
	
	switch( [event type] ){
	case NSMouseEntered:
		[self disableCursorRects];
	case NSLeftMouseDown:
	case NSRightMouseDown:
	case NSOtherMouseDown:
		if( [event type] != NSMouseEntered ){
			dragging = [[self contentView] hitTest:[event locationInWindow]];
			[self makeFirstResponder:dragging];
		}
	case NSMouseMoved:
	case NSMouseExited:
	case NSScrollWheel:
	{
		NSView *hitView = [[self contentView] hitTest:[event locationInWindow]];
		if (hitView) EmitMouseEvent( event, hitView );
		if(![self isEnabled]) return;
		break;
	}
	case NSLeftMouseUp:
	case NSRightMouseUp:
	case NSOtherMouseUp:
	{
		//fire event for the dragged view
		if (dragging) {
			EmitMouseEvent( event, dragging );
			dragging = nil;
		} else {
			//fire the event for the recieving view (if it exists)
			NSView *hitView = [[self contentView] hitTest:[event locationInWindow]];
			if (hitView) EmitMouseEvent( event, hitView );
		}
		
		if(![self isEnabled]) return;
		break;
	}
	case NSLeftMouseDragged:
	case NSRightMouseDragged:
	case NSOtherMouseDragged:
	{
		if( dragging == nil ) dragging = [[self contentView] hitTest:[event locationInWindow]];
		if( dragging ) EmitMouseEvent( event, dragging );
		if(![self isEnabled]) return;
		break;
	}
	case NSKeyDown:
	case NSKeyUp:
	case NSFlagsChanged:
	{
		NSResponder *handle=(NSResponder*)NSActiveGadget();
		if( handle && EmitKeyEvent( event, handle )) return;
		break;
	}
	}
	
	// End of Generic Key/Mouse Events
	
	// Gadget Filterkey Processing
	
	switch( [event type] ){
	case NSKeyDown:
		if( key=bbSystemTranslateKey( [event keyCode] ) ){
			int mods=bbSystemTranslateMods( [event modifierFlags] );
			BBObject *event=maxgui_maxgui_HotKeyEvent( key,mods );
			if( event!=&bbNullObject ){
				lastHotKey=key;
				brl_event_EmitEvent( event );
				return;
			}
		}
		source=[self textFirstResponder];
		if( source && !filterKeyDownEvent( event,source ) ) return;		
		if(![self isEnabled]) return;
		break;
	case NSKeyUp:
		key=bbSystemTranslateKey([event keyCode]);
		if( lastHotKey && (key==lastHotKey ) ){
			lastHotKey=0;
			return;
		}
		if(![self isEnabled]) return;
		break;
	}
	lastHotKey=0;
	
	// End of FilterKey Processing
	
	[super sendEvent:event];
}
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender{
//	printf("windowview got dragenter\n");fflush(stdout);
	return YES;
}
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender{
	NSPasteboard *pboard = [sender draggingPasteboard];
	if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
		NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
		int numberOfFiles = [files count];
		// Perform operation using the list of files
		// printf("windowview got drag\n");fflush(stdout);
		int i;
		for (i=0;i<numberOfFiles;i++)
		{
			BBString *name=bbStringFromNSString([files objectAtIndex:i]);
			maxgui_cocoamaxgui_PostCocoaGuiEvent( BBEVENT_WINDOWACCEPT,self,0,0,0,0,(BBObject*)name );
		}
		
	}
	return YES;
}
-(void)didResize{
	NSRect rect=[self localRect];
	[self didMove];
	PostGuiEvent( BBEVENT_WINDOWSIZE,self,0,0,rect.size.width,rect.size.height,0 );
}
-(void)didMove{
	NSRect rect=[self localRect];
	PostGuiEvent( BBEVENT_WINDOWMOVE,self,0,0,rect.origin.x,rect.origin.y,0 );		
}
-(void)zoom{
	zooming = 1;
}
-(NSRect)localRect{
	NSRect rect,vis;
	int style;

	rect=[self frame];
	style=gadget->style;
	if (style&WINDOW_CLIENTCOORDS){
		rect=[self contentRectForFrameRect:rect];
		if (style&WINDOW_STATUS) {
			rect.size.height-=STATUSBARHEIGHT;		
			rect.origin.y+=STATUSBARHEIGHT;		
		}
	}
	vis=[[NSScreen deepestScreen] visibleFrame];
	rect.origin.x-=vis.origin.x;
	rect.origin.y=vis.size.height-(rect.origin.y-vis.origin.y)-rect.size.height;	
	return rect;
}
-(BOOL)canBecomeKeyWindow{
	return ([self isEnabled]);
}
-(BOOL)canBecomeMainWindow{
	return ([self isEnabled] && [self isVisible] && ([self parentWindow]==nil));
}
-(BOOL)becomeFirstResponder{
	return ([self isEnabled] && [self isVisible]);
}
-(void)setEnabled:(BOOL)e{
	enabled=e;
	if (enabled) [self makeKeyWindow];
}
-(BOOL)isEnabled{
	return (enabled)?YES:NO;
}
-(void)dealloc{
	int i;
	id sview;
	if (gadget->style&WINDOW_STATUS) {
		for (i = 0; i < 3; i++) {
			if (label[i]) {
				[label[i] removeFromSuperview];
				[label[i] release];
			}
		}
		
		sview = [view superview];
		[view removeFromSuperview];
		[view release];

		[sview removeFromSuperview];
		[sview release];
	} else {
		[view removeFromSuperview];
		[view release];
	}

	[super dealloc];
}
@end

// ToolView

@implementation ToolView
-(id)textFirstResponder{
	id r=[self firstResponder];
	//if ([r isKindOfClass:[PanelView class]]) return r;
	if ([r isKindOfClass:[NSTextView class]]){
		id d=[r delegate];
		if( [d isKindOfClass:[NSTextField class]] ) return d;
	}
	return r;
}
-(id)initWithContentRect:(NSRect)rect styleMask:(unsigned int)mask backing:(NSBackingStoreType)backing defer:(BOOL)flag withGadget:(nsgadget*)_gadget{
//withStatus:(BOOL)status{
	id		client;
	int		i;
	NSText	*l;
	NSBox	*box;
	dragging = nil;
	self=[super initWithContentRect:rect styleMask:mask backing:backing defer:flag];
	gadget=_gadget;
	view=[[FlippedView alloc] init];
	enabled=true;
	[self setContentView:view];
	[self setAcceptsMouseMovedEvents:YES];
	[self disableCursorRects];	//Fixes NSSetPointer not sticking.
	if (gadget->style&WINDOW_STATUS){			//status){	//mask&NSTexturedBackgroundWindowMask)
		rect.origin.x=rect.origin.y=0;
		rect.size.height-=STATUSBARHEIGHT;
		client=[[FlippedView alloc] initWithFrame:rect];
		[client setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];	
		[view addSubview:client];
// label for window status
		rect.origin.y=rect.size.height+3;
		rect.size.height=STATUSBARHEIGHT-4;		
		rect.size.width-=[NSScroller scrollerWidth];
		for (i=0;i<3;i++){
			l=[[NSText alloc] initWithFrame:rect];
			[l setDrawsBackground:NO];
			[l setEditable:NO];
			[l setSelectable:NO];
			[l setAutoresizingMask:NSViewWidthSizable|NSViewMinYMargin];
			switch (i){
				case 0:[l setAlignment:NSLeftTextAlignment];break;
				case 1:[l setAlignment:NSCenterTextAlignment];break;
				case 2:[l setAlignment:NSRightTextAlignment];break;
			}
			if (view) [view addSubview:l];
			label[i]=l;
		}
		
		rect.origin.y-=3;
		rect.size.height=2;
		rect.size.width+=[NSScroller scrollerWidth];
		
		box=[[NSBox alloc] initWithFrame:rect];
		[box setBoxType:NSBoxSeparator];
		[box setTitlePosition:NSNoTitle];
		[box setAutoresizingMask:NSViewWidthSizable|NSViewMinYMargin];
		if (view) [view addSubview:box];
		
// set clientview to inner view
		view=client;		
	}
	if ([self respondsToSelector: @selector(setShowsToolbarButton:)]) [self setShowsToolbarButton: NO];
	return self;
}
-(id)clientView{
	return view;
}
-(void)setStatus:(NSString*)text align:(int)pos{
	if (label[pos]) [label[pos] setString:text];
}
-(void)sendEvent:(NSEvent*)event{
	
	static int lastHotKey;
	int key;
	id source;
	
	// Handling of Generic Key/Mouse Events
	
	switch( [event type] ){
	case NSMouseEntered:
		[self disableCursorRects];
	case NSLeftMouseDown:
	case NSRightMouseDown:
	case NSOtherMouseDown:
	{
		if( [event type] != NSMouseEntered ){
			dragging = [[self contentView] hitTest:[event locationInWindow]];
			[self makeFirstResponder:dragging];
		}
	}
	case NSMouseMoved:
	case NSMouseExited:
	case NSScrollWheel:
	{
		NSView *hitView = [[self contentView] hitTest:[event locationInWindow]];
		if (hitView) EmitMouseEvent( event, hitView );
		if(![self isEnabled]) return;
		break;
	}
	case NSLeftMouseUp:
	case NSRightMouseUp:
	case NSOtherMouseUp:
	{
		//fire event for the dragged view
		if (dragging) {
			EmitMouseEvent( event, dragging );
			dragging = nil;
		} else {
			//fire the event for the recieving view (if it exists)
			NSView *hitView = [[self contentView] hitTest:[event locationInWindow]];
			if (hitView) EmitMouseEvent( event, hitView );
		}
		
		if(![self isEnabled]) return;
		break;
	}
	case NSLeftMouseDragged:
	case NSRightMouseDragged:
	case NSOtherMouseDragged:
	{
		if( dragging == nil ) dragging = [[self contentView] hitTest:[event locationInWindow]];
		if( dragging ) EmitMouseEvent( event, dragging );
		if(![self isEnabled]) return;
		break;
	}
	case NSKeyDown:
	case NSKeyUp:
	case NSFlagsChanged:
	{
		NSResponder *handle=(NSResponder*)NSActiveGadget();
		if( handle && EmitKeyEvent( event, handle )) return;
		break;
	}
	}
	
	// End of Generic Key/Mouse Events
	
	// Gadget Filterkey Processing
	
	switch( [event type] ){
	case NSKeyDown:
		if( key=bbSystemTranslateKey( [event keyCode] ) ){
			int mods=bbSystemTranslateMods( [event modifierFlags] );
			BBObject *event=maxgui_maxgui_HotKeyEvent( key,mods );
			if( event!=&bbNullObject ){
				lastHotKey=key;
				brl_event_EmitEvent( event );
				return;
			}
		}
		source=[self textFirstResponder];
		if( source && !filterKeyDownEvent( event,source ) ) return;		
		if(![self isEnabled]) return;
		break;
	case NSKeyUp:
		key=bbSystemTranslateKey([event keyCode]);
		if( lastHotKey && (key==lastHotKey ) ){
			lastHotKey=0;
			return;
		}
		if(![self isEnabled]) return;
		break;
	}
	lastHotKey=0;
	
	// End of FilterKey Processing
	
	[super sendEvent:event];
}
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender{
//	printf("windowview got dragenter\n");fflush(stdout);
	return YES;
}
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender{
	NSPasteboard *pboard = [sender draggingPasteboard];
	if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
		NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
		int numberOfFiles = [files count];
		// Perform operation using the list of files
		// printf("windowview got drag\n");fflush(stdout);
		int i;
		for (i=0;i<numberOfFiles;i++)
		{
			BBString *name=bbStringFromNSString([files objectAtIndex:i]);
			maxgui_cocoamaxgui_PostCocoaGuiEvent( BBEVENT_WINDOWACCEPT,self,0,0,0,0,(BBObject*)name );
		}
		
	}
	return YES;
}
-(void)didResize{
	if (zooming) {
		zooming = 0;
		[self didMove];
	}
	NSRect rect=[self localRect];
	PostGuiEvent( BBEVENT_WINDOWSIZE,self,0,0,rect.size.width,rect.size.height,0 );
}
-(void)didMove{
	NSRect rect=[self localRect];
	PostGuiEvent( BBEVENT_WINDOWMOVE,self,0,0,rect.origin.x,rect.origin.y,0 );		
}
-(void)zoom{
	zooming = 1;
}
-(NSRect)localRect{
	NSRect rect,vis;
	int style;

	rect=[self frame];
	style=gadget->style;
	if (style&WINDOW_CLIENTCOORDS){
		rect=[self contentRectForFrameRect:rect];
		if (style&WINDOW_STATUS) {
			rect.size.height-=STATUSBARHEIGHT;		
			rect.origin.y+=STATUSBARHEIGHT;		
		}
	}
	vis=[[NSScreen deepestScreen] visibleFrame];
	rect.origin.x=rect.origin.x-vis.origin.x;
	rect.origin.y=vis.size.height-(rect.origin.y-vis.origin.y)-rect.size.height;	
	return rect;
}
-(BOOL)canBecomeKeyWindow{
	return ([self isEnabled]);
}
-(BOOL)canBecomeMainWindow{
	return ([self isEnabled] && [self isVisible] && ([self parentWindow]==nil));
}
-(BOOL)becomeFirstResponder{
	return ([self isEnabled] && [self isVisible]);
}
-(void)setEnabled:(BOOL)e{
	enabled=e;
	if (enabled) [self makeKeyWindow];
}
-(BOOL)isEnabled{
	return (enabled)?YES:NO;
}
-(void)dealloc{
	int i;
	id sview;
	if (gadget->style&WINDOW_STATUS) {
		for (i = 0; i < 3; i++) {
			if (label[i]) {
				[label[i] removeFromSuperview];
				[label[i] release];
			}
		}
		
		sview = [view superview];
		[view removeFromSuperview];
		[view release];

		[sview removeFromSuperview];
		[sview release];
	} else {
		[view removeFromSuperview];
		[view release];
	}

	[super dealloc];
}
@end

// global app stuff

void NSBegin(){
	GlobalApp=[[CocoaApp alloc] init];
	HaltMouseEvents=0;
}

void NSEnd(){
	[GlobalApp release];
}

int NSActiveGadget(){
	NSWindow	*window;
	NSResponder *responder;
	window=[NSApp keyWindow];
	if (!window) return 0;
	responder=[window firstResponder];
	if (!responder) return (int)window;
	if ([responder isKindOfClass:[NSTextView class]] && 
   		[window fieldEditor:NO forObject:nil] != nil ) { 
			NSTextView *view=(NSTextView*)responder;
			return (int)[view delegate];
		}
	return (int)responder;
}

void NSInitGadget(nsgadget *gadget){
	NSRect 				rect,vis;
	NSString 			*text;
	NSView				*view;
	NSWindow		*window;
	NSButton			*button;
	NSTextField			*textfield;
	TextView			*textarea;
	NSControl 		*combobox;
	Toolbar			*toolbar;
	TabView				*tabber;
	TreeView			*treeview;
	HTMLView			*htmlview;
	PanelView			*panel;
	PanelViewContent		*pnlcontent;
	CanvasView			*canvas;
	ListView				*listbox;
	NSText				*label;
	NSBox				*box;
	NSSlider				*slider;
	NSScroller			*scroller;
	NSStepper				*stepper;
	NSProgressIndicator	*progbar;
	NSMenu				*menu;
	NSMenuItem			*menuitem;
	NodeItem			*node,*parent;
	nsgadget				*group;
	int 					style,flags;
	NSImage			*image;
		
	rect=NSMakeRect(gadget->x,gadget->y,gadget->w,gadget->h);
	text=NSStringFromBBString(gadget->textarg);
	style=gadget->style;flags=0;
	group=gadget->group;
	if (group==(nsgadget*)&bbNullObject) group=0;
	if (group) view=gadget->group->view;
	
	switch (gadget->internalclass){
	case GADGET_DESKTOP:
		rect=[[NSScreen deepestScreen] frame];
		gadget->x=rect.origin.x;
		gadget->y=rect.origin.y;
		gadget->w=rect.size.width;
		gadget->h=rect.size.height;
		break;
	case GADGET_WINDOW:
		vis=[[NSScreen deepestScreen] visibleFrame];
		rect.origin.x+=vis.origin.x;
		rect.origin.y=vis.origin.y+vis.size.height-rect.origin.y-rect.size.height;
		if (style&WINDOW_TITLEBAR) flags|=NSTitledWindowMask|NSClosableWindowMask;
		if (style&WINDOW_RESIZABLE){
			flags|=NSResizableWindowMask;
			if (!(group && (group->internalclass==GADGET_WINDOW))) flags |=NSMiniaturizableWindowMask;
		}
		if (style&WINDOW_TOOL) flags|=NSUtilityWindowMask;
		[NSApp activateIgnoringOtherApps:YES];
		if (!(style&WINDOW_CLIENTCOORDS)){
			rect=[NSWindow contentRectForFrameRect:rect styleMask:flags];
		}else{
			if (style&WINDOW_STATUS) {
				rect.origin.y-=STATUSBARHEIGHT;		
				rect.size.height+=STATUSBARHEIGHT;		
			}
		}
		if (!(style&WINDOW_TOOL)) {
			window=[[WindowView alloc] initWithContentRect:rect styleMask:flags backing:NSBackingStoreBuffered defer:YES withGadget:gadget];
		} else {
			window=[[ToolView alloc] initWithContentRect:rect styleMask:flags backing:NSBackingStoreBuffered defer:YES withGadget:gadget];
		}
		[window setOpaque:NO];
		[window setAlphaValue:.999f];	
		
		if (style&WINDOW_HIDDEN) [window orderOut:window]; else [window makeKeyAndOrderFront:NSApp];
		
		if (group && (group->internalclass==GADGET_WINDOW)){
			NSWindow	*parent;
			parent=(NSWindow*)group->handle;
			if(!(style&WINDOW_HIDDEN)) [parent addChildWindow:window ordered:NSWindowAbove];
			[window setParentWindow:parent];
		}
		
		if (style&WINDOW_ACCEPTFILES)
			[window registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]]; 
		
		[window setTitle:text];	
		[window setDelegate:GlobalApp];
		gadget->handle=window;
		gadget->view=[window clientView];
		break;
		
	case GADGET_BUTTON:
		button=[[NSButton alloc] initWithFrame:rect];
		[button setTitle:text];
		
		[button setBezelStyle:NSRoundedBezelStyle];
		
		switch (style&7){
			case 0:
				// Push Button Size Hack
				if (gadget->h > 30) {
					[button setBezelStyle:NSRegularSquareBezelStyle];
				} else {
					if (gadget->h < 24) [button setBezelStyle:NSShadowlessSquareBezelStyle];
					else [button setBezelStyle:NSRoundedBezelStyle];
				}
				break;
			case BUTTON_CHECKBOX:
				if (style&BUTTON_PUSH){
					[button setBezelStyle:NSShadowlessSquareBezelStyle];
					[button setButtonType:NSPushOnPushOffButton];
				} else {
					[button setButtonType:NSSwitchButton];
				}
				break;
			case BUTTON_RADIO:
				if (style&BUTTON_PUSH){
					[button setBezelStyle:NSShadowlessSquareBezelStyle];
					[button setButtonType:NSPushOnPushOffButton];
				} else {
					[button setButtonType:NSRadioButton];
				}
				break;
			case BUTTON_OK:
				[button setKeyEquivalent:@"\r"];
				break;
			case BUTTON_CANCEL:
				[button setKeyEquivalent:@"\x1b"];
				break;
		}
		[button setTarget:GlobalApp];
		[button setAction:@selector(buttonPush:)];
		if (view) [view addSubview:button];		
		gadget->handle=button;
		gadget->view=button;
		break;
	case GADGET_PANEL:
		panel=[[PanelView alloc] initWithFrame:rect];
		[panel setContentViewMargins:NSMakeSize(0.0,0.0)];
		pnlcontent=[[PanelViewContent alloc] initWithFrame:[[panel contentView] frame]];
		[pnlcontent setAutoresizesSubviews:NO];
		[panel setContentView:pnlcontent];
		[panel setGadget:gadget];
		[panel setStyle:style];
		[panel setEnabled:true];
		[panel setTitle:text];
		[pnlcontent setAlpha:1.0];
		if (view) [view addSubview:panel];
		gadget->view=pnlcontent;
		gadget->handle=panel;
		break;
	case GADGET_CANVAS:
		canvas=[[CanvasView alloc] initWithFrame:rect];
		[canvas setAutoresizesSubviews:NO];
		[canvas setGadget:gadget];
		if (view) [view addSubview:canvas];
		[canvas setStyle:style|PANEL_ACTIVE];
		[canvas setEnabled:true];
		gadget->view=[canvas contentView];
		gadget->handle=canvas;
		break;	
	case GADGET_TEXTFIELD:
		if (style==TEXTFIELD_PASSWORD){
			textfield=[[NSSecureTextField alloc] initWithFrame:rect];
		}else{
			textfield=[[NSTextField alloc] initWithFrame:rect];
		}
		[textfield setDelegate:GlobalApp];
		[textfield setEditable:YES];
		[[textfield cell] setWraps:NO];
		[[textfield cell] setScrollable:YES];
		if (view) [view addSubview:textfield];		
		gadget->handle=textfield;
		gadget->view=textfield;
		break;
	case GADGET_TEXTAREA://http://developer.apple.com/documentation/Cocoa/Conceptual/TextUILayer/Tasks/TextInScrollView.html
		textarea=[[TextView alloc] initWithFrame:rect];
		if (style&TEXTAREA_READONLY) [textarea setEditable:NO];
		if (style&TEXTAREA_WORDWRAP) [textarea setWordWrap:YES];
		if (view) [view addSubview:[textarea getScroll]];
		gadget->handle=textarea;
		gadget->view=[textarea getScroll];// simon was here textarea;
		break;		
	case GADGET_COMBOBOX:
		if (rect.size.height > 26) rect.size.height = 26;
		combobox=[[NSComboBox alloc] initWithFrame:rect];
		[combobox setUsesDataSource:NO];
		[combobox setCompletes:YES];
		[combobox setDelegate:GlobalApp];		
		[combobox setEditable:(style&COMBOBOX_EDITABLE)?YES:NO];			
		[combobox setSelectable:YES];			
		if (view) [view addSubview:combobox];		
		gadget->handle=combobox;
		gadget->view=combobox;
		break;
	case GADGET_LISTBOX:
		listbox=[[ListView alloc] initWithFrame:rect];
		if (view) [view addSubview:listbox];		
		gadget->handle=listbox;
		gadget->view=listbox;
		break;
	case GADGET_TOOLBAR:
		toolbar=[[Toolbar alloc] initWithIdentifier:text];
		[toolbar setSizeMode:NSToolbarSizeModeSmall];
		[toolbar setDisplayMode:NSToolbarDisplayModeIconOnly];
		[toolbar setDelegate:GlobalApp];
		window=(WindowView*)group->handle;
		[window setToolbar:toolbar];
		gadget->handle=toolbar;
		gadget->view=[window clientView];
		break;
	case GADGET_TABBER:
		tabber=[[TabView alloc] initWithFrame:rect];
		[tabber setAutoresizesSubviews:NO];
		if (view) [view addSubview:tabber];		//[tabber hostView]];		
		gadget->handle=tabber;
		gadget->view=[tabber clientView];
		break;
	case GADGET_TREEVIEW:
		treeview=[[TreeView alloc] initWithFrame:rect];	//NSOutlineView
		if (view) [view addSubview:treeview];		
		gadget->handle=treeview;
		gadget->view=treeview;
		break;
	case GADGET_HTMLVIEW:
		htmlview=[[HTMLView alloc] initWithFrame:rect];
		if (view) [view addSubview:htmlview];
		[htmlview setStyle: style];
		gadget->handle=htmlview;
		gadget->view=htmlview;
		break;
    case GADGET_LABEL: /* BaH */
		switch (style&3) {
		case LABEL_SEPARATOR:
			
			box=[[NSBox alloc] initWithFrame:rect];
			
			[box setTitle:text];
			[box setBoxType:NSBoxSeparator];
			[box setTitlePosition:NSNoTitle];
			
			[box setContentView:[[FlippedView alloc] init]];
			
			if (view) [view addSubview:box];
			gadget->handle=box;
			gadget->view=[box contentView];
			
			break;
			
		default:
			
			textfield = [[NSTextField alloc] initWithFrame:rect];
			
			[textfield setEditable:NO];
			[textfield setDrawsBackground:NO];
			
			if ((style&3)==LABEL_SUNKENFRAME) {
				[textfield setBezeled:YES];
				[textfield setBezelStyle:NSTextFieldSquareBezel];
			} else {
				[textfield setBezeled:NO];
				if ((style&3)==LABEL_FRAME)
				        [textfield setBordered:YES];
				else
				        [textfield setBordered:NO];
			}
			
			[[textfield cell] setWraps:YES];
			[[textfield cell] setScrollable:NO];
			[textfield setStringValue:text];
			
			switch (style&24){
				case LABEL_LEFT:[textfield setAlignment:NSLeftTextAlignment];break;
				case LABEL_RIGHT:[textfield setAlignment:NSRightTextAlignment];break;
				case LABEL_CENTER:[textfield setAlignment:NSCenterTextAlignment];break;
			}               
			
			if (view) [view addSubview: textfield];
			gadget->handle=textfield;
			gadget->view=textfield;
			
			break;
		}
		break;			
	case GADGET_SLIDER:
		switch (style&12){
		case SLIDER_SCROLLBAR:
			if (rect.size.width>rect.size.height)		{
				rect.size.height=[NSScroller scrollerWidth];
			}
			else{
				rect.size.width=[NSScroller scrollerWidth];
			}
			scroller=[[NSScroller alloc] initWithFrame:rect];
			[scroller setEnabled:YES];
			[scroller setArrowsPosition:NSScrollerArrowsDefaultSetting];
			[scroller setAction:@selector(scrollerSelect:)];
			if (view) [view addSubview:scroller];		
			gadget->handle=scroller;
			gadget->view=scroller;
			break;
		case SLIDER_TRACKBAR:
			slider=[[NSSlider alloc] initWithFrame:rect];
			[slider setEnabled:YES];
			[slider setAction:@selector(sliderSelect:)];
			if (view) [view addSubview:slider];
			gadget->handle=slider;
			gadget->view=slider;
			break;
		case SLIDER_STEPPER:
			stepper=[[NSStepper alloc] initWithFrame:rect];
			[stepper setEnabled:YES];
			[stepper setAction:@selector(sliderSelect:)];
			[stepper setValueWraps:NO];
			if (view) [view addSubview:stepper];
			gadget->handle=stepper;
			gadget->view=stepper;
			break;
		}
		break;
	case GADGET_PROGBAR:
		progbar=[[NSProgressIndicator alloc] initWithFrame:rect];
		[progbar setStyle:NSProgressIndicatorBarStyle];		
		[progbar setIndeterminate:NO];
		[progbar setMaxValue:1.0];
		if (view) [view addSubview:progbar];		
		gadget->handle=progbar;
		gadget->view=progbar;
		break;
	case GADGET_MENUITEM:
		// Allows a popup-menu to be created with no text without crashing.
		if ([text length] || (group->internalclass == GADGET_DESKTOP)) {
			menuitem=[[NSMenuItem alloc] initWithTitle:text action:@selector(menuSelect:) keyEquivalent:@""];
			[menuitem setTag:style];
			[GlobalApp addMenuItem:menuitem];
		}
		else{
			menuitem=(NSMenuItem*)[NSMenuItem separatorItem];
		}
		if (group){
			switch (group->internalclass){
				case GADGET_WINDOW:		
					menu=[[NSMenu alloc] initWithTitle:text];
					[menu setAutoenablesItems:NO];
					[menu setSubmenu:menu forItem:menuitem];
					[menu release];
					menu=[NSApp mainMenu];
					[menu addItem:menuitem];
					if ([text length]){
						[menuitem release];
					}
					break;
				case GADGET_MENUITEM:
					menu=(NSMenu*)[group->handle submenu];
					if (!menu){
						menu=(NSMenu*)[[NSMenu alloc] initWithTitle:text];
						[menu setAutoenablesItems:NO];
						[group->handle setSubmenu:menu];
						[menu addItem:menuitem];
						[menu release];
					} else {
						[menu addItem:menuitem];
					}
					if ([text length]){
						[menuitem release];
					}
					break;
			}
		}
		gadget->handle=menuitem;
		break;
	case GADGET_NODE:
		if (!group) break;
		parent=0;
		switch (group->internalclass){
			case GADGET_TREEVIEW:
				parent=[((TreeView*)group->handle) rootNode];
				break;
			case GADGET_NODE:
				parent=(NodeItem*)group->handle;
				break;
		}
		if (!parent) break;
		node=[[NodeItem alloc] initWithTitle:text];
		int index=style;
		if (index==-1) index=[parent count];
		if (index>[parent count]) index=[parent count];
		[node attach:parent atIndex:index];
		gadget->handle=node;
		break;
	}
}

@class color_delegate;
@interface color_delegate:NSObject{}
@end
@implementation color_delegate
- (void)windowWillClose:(NSNotification *)aNotification{[NSApp stopModal];}
@end

int NSColorRequester(int r,int g,int b){
	NSColorPanel	*panel;
	NSColor			*color;
	color_delegate	*dele;
	dele=[[color_delegate alloc] init];
	color=[NSColor colorWithCalibratedRed:r/255.0L green:g/255.0L blue:b/255.0L alpha:1.0];
	panel=[NSColorPanel sharedColorPanel];
	[panel setColor:color];
	[panel setDelegate:dele];
	[NSApp runModalForWindow:panel];
	color=[panel color];
	if (color){
		color=[color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
		r=(int)((255*[color redComponent])+0.5);
		g=(int)((255*[color greenComponent])+0.5);
		b=(int)((255*[color blueComponent])+0.5);
	}
	return 0xff000000|(r<<16)|(g<<8)|b;
}

@class font_delegate;
@interface font_delegate:NSObject{
	NSFont		*_font;
}
-(id)initWithFont:(NSFont*)font;
-(void)changeFont:(id)sender;
-(id)font;
-(void)windowWillClose:(NSNotification *)aNotification;
-(unsigned int)validModesForFontPanel:(NSFontPanel *)fontPanel;
@end
@implementation font_delegate
-(id)initWithFont:(NSFont*)font{
	_font=font;
	return self;
}
-(id)font{
	return _font;
}
-(void)changeFont:(id)sender{
	_font=[sender convertFont:_font];
	return; 
}
- (void)windowWillClose:(NSNotification *)aNotification{
	[NSApp stopModal];
}
-(unsigned int)validModesForFontPanel:(NSFontPanel *)fontPanel{
	return NSFontPanelFaceModeMask|NSFontPanelSizeModeMask|NSFontPanelCollectionModeMask;//|NSFontPanelUnderlineEffectModeMask;
}
@end

int NSGetSysColor( int colorindex, int* red, int* green, int* blue ){
	
	float r, g, b;
	NSColor* c;
	NSWindow* w;
	
	switch(colorindex){
		case GUICOLOR_WINDOWBG:
			w = [[NSWindow alloc] initWithContentRect:NSZeroRect styleMask:NSTitledWindowMask backing:NSBackingStoreBuffered defer:YES];
			c = [w backgroundColor];
			[w release];
			break;
		case GUICOLOR_GADGETBG:
			c = [NSColor controlBackgroundColor];
			break;
		case GUICOLOR_GADGETFG:
			c = [NSColor controlTextColor];
			break;
		case GUICOLOR_SELECTIONBG:
			c = [NSColor selectedTextBackgroundColor];
			break;
		default:
			return 0;
			break;
	}
	
	[[c colorUsingColorSpaceName:NSCalibratedRGBColorSpace] getRed:&r green:&g blue:&b alpha:NULL];
	*red = (int)(255 * r);
	*green = (int)(255 * g);
	*blue = (int)(255 * b);
	
	return 1;
}

NSFont *NSRequestFont(NSFont *font){
	NSFontPanel		*panel;
	font_delegate		*dele;
	if (!font) font=[NSFont userFontOfSize:0];
	dele=[[font_delegate alloc] initWithFont:font];
	panel=[NSFontPanel sharedFontPanel];
	if (font) [panel setPanelFont:font isMultiple:NO];
	[panel setEnabled:YES];
	[panel setDelegate:dele];
	[NSApp runModalForWindow:panel];
	return [dele font];
}

NSFont *NSLoadFont(BBString *name,double size,int flags){
	NSString			*text;
	NSFont				*font;
	NSFontManager		*manager;

	text=NSStringFromBBString(name);
	font=[NSFont fontWithName:text size:size];
	if (!font) font=[NSFont systemFontOfSize:size];
	if (flags){
		manager=[NSFontManager sharedFontManager];
		if (flags&FONT_BOLD) font=[manager convertFont:font toHaveTrait:NSBoldFontMask];
		if (flags&FONT_ITALIC) font=[manager convertFont:font toHaveTrait:NSItalicFontMask];
	}
	[font retain];
	return font;
}

NSFont *NSGetDefaultFont(){
	return [NSFont systemFontOfSize:[NSFont systemFontSize]];
}

BBString *NSFontName(NSFont *font){
	return bbStringFromNSString([font displayName]);	
}

int NSFontStyle(NSFont *font){
	int	intBBStyleFlags;
	int	intCocoaFontTraits;
	NSFontManager *manager;
	
	manager = [NSFontManager sharedFontManager];
	intCocoaFontTraits = [manager traitsOfFont: font];
	
	intBBStyleFlags = 0;
	if (intCocoaFontTraits & NSBoldFontMask) intBBStyleFlags|=FONT_BOLD;
	if (intCocoaFontTraits & NSItalicFontMask) intBBStyleFlags|=FONT_ITALIC;
	
	return intBBStyleFlags;
}

double NSFontSize(NSFont *font){
	return (double)[font pointSize];
}

void* NSSuperview(NSView* handle){
	if(handle) return [handle superview];
	return 0;
}

// generic gadget commands

void NSFreeGadget(nsgadget *gadget){
	nsgadget *group;
	NSWindow *parent;
	TextView *textview;
	FlippedView * flipped;
	if (gadget->textcolor){
		[gadget->textcolor release];
		gadget->textcolor = 0;
	}
	if (gadget->handle){
		switch (gadget->internalclass){
		case GADGET_WINDOW:
			if ([gadget->handle parentWindow]!=nil){			
				[[gadget->handle parentWindow] removeChildWindow:(NSWindow*)gadget->handle];
			}			
			[gadget->handle close];
			break;
		case GADGET_NODE:
			[gadget->handle remove];
			[gadget->handle autorelease];
			break;
		case GADGET_MENUITEM:
			[GlobalApp removeMenuItem:gadget->handle];
			[[gadget->handle menu] removeItem:gadget->handle];
			break;
		case GADGET_TEXTAREA:
			textview=(TextView*)gadget->handle;					
			[gadget->view removeFromSuperview];
			[textview free];
			[textview autorelease];
			break;
		case GADGET_LABEL:
			switch (gadget->style&3) {
			case LABEL_SEPARATOR:
				flipped=(FlippedView*)gadget->view;
				[flipped removeFromSuperview];
				[gadget->handle removeFromSuperview];
				[flipped release];
				break;
			default:
				[gadget->view removeFromSuperview];
				break;
			}
			[gadget->handle autorelease];
			break;
		case GADGET_TABBER:
			flipped=(FlippedView*)gadget->view;
			[flipped removeFromSuperview];
			[gadget->handle removeFromSuperview];
			[flipped release];
			//Cocoa throws an exception if items exist when handle is autoreleased.
			NSClearItems(gadget);
			[gadget->handle autorelease];
			break;
		case GADGET_PANEL:
			[gadget->handle setColor:nil];
			[gadget->handle removeFromSuperview];
			[gadget->handle autorelease];
			break;
		default:
			[[gadget->view superview] setNeedsDisplayInRect:[gadget->view frame]];
			[gadget->view removeFromSuperview];
			[gadget->handle autorelease];
			break;
		}	
	}
	gadget->handle=0;
}

void NSEnable(nsgadget *gadget,int state){
	switch (gadget->internalclass){
	case GADGET_WINDOW:
	case GADGET_SLIDER:
	case GADGET_TEXTFIELD:
	case GADGET_MENUITEM:
	case GADGET_BUTTON:
	case GADGET_LISTBOX:
	case GADGET_COMBOBOX:
	case GADGET_TREEVIEW:
	case GADGET_PANEL:
	case GADGET_CANVAS:
		[gadget->handle setEnabled:state];
		break;
	case GADGET_TEXTAREA:
		[gadget->handle setSelectable:state];
		if (!(gadget->style&TEXTAREA_READONLY)) [gadget->handle setEditable:state];
		break;
	}
}

void NSShow(nsgadget *gadget,int state){
	switch (gadget->internalclass){
	case GADGET_WINDOW:
		if (state==[gadget->handle isVisible]) return;
		if (state) {
			if((gadget->group!=&bbNullObject) && (gadget->group->internalclass==GADGET_WINDOW) &&
			([gadget->handle parentWindow]==nil)) [gadget->group->handle addChildWindow: gadget->handle ordered:NSWindowAbove];
			[gadget->handle makeKeyAndOrderFront:NSApp];
		} else {
			if([gadget->handle parentWindow]!=nil) [[gadget->handle parentWindow] removeChildWindow:(NSWindow*)gadget->handle];
			[gadget->handle orderOut:NSApp];
		}
		break;
	case GADGET_TOOLBAR:
		[gadget->handle setVisible:state];
		break;
	default:
		[gadget->handle setHidden:!state];
	}
}

void NSCheck(nsgadget *gadget,int state){
	NSButton			*button;
	switch (gadget->internalclass){
	case GADGET_MENUITEM:
		[gadget->handle setState:state];
		break;
	case GADGET_BUTTON:
		button=(NSButton *)gadget->handle;
		if(state==NSMixedState) [button setAllowsMixedState:YES]; else [button setAllowsMixedState:NO];
		[button setState:state];
		break; 
	}
}

void NSPopupMenu(nsgadget *gadget,nsgadget *menugadget){
	NSView			*view;
	NSWindow			*window;
	NSMenuItem		*menuitem;
	NSEvent			*event;
	NSPoint			loc;
	
	window=(NSWindow*)gadget->handle;
	view=gadget->view;
	menuitem=(NSMenuItem*)menugadget->handle;
	event=[NSEvent 
		mouseEventWithType:NSRightMouseUp 
		location:[window convertScreenToBase:[NSEvent mouseLocation]]
		modifierFlags:nil 
		timestamp:0 
		windowNumber:[window windowNumber] 
     	context:nil
		eventNumber:nil
		clickCount:1 
		pressure:0];
	[NSMenu popUpContextMenu:[menuitem submenu] withEvent:event forView:view];		
//	[event release];
}

int NSState(nsgadget *gadget){
	NSWindow		*window;
	TextView		*textview;
	NSButton		*button;
	NSView		*view;
	Toolbar		*toolbar;
	HTMLView		*browser;
	NSMenuItem 	*menuItem;
	int			state;

	state=0;

	switch (gadget->internalclass){
	case GADGET_TEXTAREA:
		textview=(TextView*)gadget->handle;
		if ([textview isHidden]) state|=STATE_HIDDEN;
		if ((!(gadget->style&TEXTAREA_READONLY)) && (![textview isEditable])) state|=STATE_DISABLED;
		break;
	case GADGET_HTMLVIEW:
		browser=(HTMLView*)gadget->handle;
		return [browser loaded];
	case GADGET_WINDOW:
		window=(NSWindow*)gadget->handle;
		if ([window isMiniaturized]) state|=STATE_MINIMIZED;
		if ([window isZoomed]) state|=STATE_MAXIMIZED;
		if (![window isVisible]) state|=STATE_HIDDEN;
		break;
	case GADGET_MENUITEM:
		menuItem=(NSMenuItem*)gadget->handle;
		if ([menuItem state]==NSOnState) state|=STATE_SELECTED;
		if (![menuItem isEnabled]) state|=STATE_DISABLED;
		break;
	case GADGET_BUTTON:
		button=(NSButton *)gadget->handle;
		switch (gadget->style&7){
			case BUTTON_RADIO: case BUTTON_CHECKBOX:
			if ([button state]==NSOnState) state|=STATE_SELECTED;
			if ([button state]==NSMixedState) state|=STATE_INDETERMINATE;
		}
		if ([button isHidden]) state|=STATE_HIDDEN;
		if (![button isEnabled]) state|=STATE_DISABLED;
		break;
	case GADGET_TOOLBAR:
		toolbar=(Toolbar*)gadget->handle;
		if ([toolbar isVisible]==NO) state|=STATE_HIDDEN;
		break;		
	case GADGET_PROGBAR:
		view=(NSView*)gadget->handle;
		if ([view isHidden]) state|=STATE_HIDDEN;
		break;
	default:
		view=(NSView*)gadget->handle;
		if ([view isHidden]) state|=STATE_HIDDEN;
		if (![view isEnabled]) state|=STATE_DISABLED;
		break;
	}
	return state;
}

void NSSetMinimumSize(nsgadget *gadget,int width,int height){
	NSWindow	*window;
	NSRect	rect;
	int		style;
	window=(NSWindow*)gadget->handle;
	rect.origin.x=0;
	rect.origin.y=0;
	rect.size.width=width;
	rect.size.height=height;
	style=gadget->style;
	if (!(style&WINDOW_CLIENTCOORDS)){
		rect=[window contentRectForFrameRect:rect];
		rect.size.width-=rect.origin.x;
		rect.size.height-=rect.origin.y;
	}else{
		if (style&WINDOW_STATUS) rect.size.height+=STATUSBARHEIGHT;		
	}
	[window setContentMinSize:rect.size];
}

void NSSetMaximumSize(nsgadget *gadget,int width,int height){
	NSWindow	*window;
	NSRect	rect;
	int		style;
	window=(NSWindow*)gadget->handle;
	rect.origin.x=0;
	rect.origin.y=0;
	rect.size.width=width;
	rect.size.height=height;
	style=gadget->style;
	if (!(style&WINDOW_CLIENTCOORDS)){
		rect=[window contentRectForFrameRect:rect];
		rect.size.width-=rect.origin.x;
		rect.size.height-=rect.origin.y;
	}else{
		if (style&WINDOW_STATUS) rect.size.height+=STATUSBARHEIGHT;		
	}
	[window setContentMaxSize:rect.size];
}


void NSSetStatus(nsgadget *gadget,BBString *data,int pos){
	NSString			*text;
	WindowView			*window;
	ToolView			*toolview;

	text=NSStringFromBBString(data);
	if ((gadget->style&WINDOW_TOOL) == 0) {
		window=(WindowView*)gadget->handle;
		[window setStatus:text align:pos];
	} else {
		toolview =(ToolView*)gadget->handle;
		[toolview setStatus:text align:pos];
	}
}

int NSClientWidth(nsgadget *gadget){
	NSRect		frame;	
	if (gadget->internalclass==GADGET_DESKTOP){
		frame=[[NSScreen deepestScreen] visibleFrame];
		return frame.size.width;
	}
	if (!gadget->view) return gadget->w;
	frame=[gadget->view frame]; 
	return frame.size.width;
}

int NSClientHeight(nsgadget *gadget){
	NSRect		frame;
	if (gadget->internalclass==GADGET_DESKTOP){
		frame=[[NSScreen deepestScreen] visibleFrame];
		return frame.size.height;
	}
	if (!gadget->view) return gadget->h;
	frame=[gadget->view frame]; 
	return frame.size.height;
}

void NSRedraw(nsgadget *gadget){
	NSView	*view;
	
	view=(NSView*)gadget->handle;
	[view display];	//Can just call the display method
}

void NSActivate(nsgadget *gadget,int code){
	NSWindow	*window;
	NSView		*view;
	NSRect		frame;
	NodeItem	*node;
	TreeView	*treeview;
	HTMLView	*browser;
	TextView	*textview;
	NSTextField *textfield;
	NSText *text;
	NSComboBox *combo;

// generic commands

	switch (code){
	case ACTIVATE_REDRAW:
		NSRedraw(gadget);
		return;
	}
	
// gadget specific	

	switch (gadget->internalclass){
	case GADGET_WINDOW:
		window=(NSWindow*)gadget->handle;
		switch (code){
		case ACTIVATE_FOCUS:
			if([window isVisible]) [window makeKeyAndOrderFront:NSApp];		
			break;
		case ACTIVATE_CUT:
			break;
		case ACTIVATE_COPY:
			break;
		case ACTIVATE_PASTE:
			break;
		case ACTIVATE_MINIMIZE:
			NSShow(gadget,true);
			[window miniaturize:window];
			break;
		case ACTIVATE_MAXIMIZE:
			if ([window isMiniaturized]) [window deminiaturize:window];
			if ([window isZoomed]==NO) [window performZoom:window];
			NSShow(gadget,true);
			break;
		case ACTIVATE_RESTORE:
			if ([window isMiniaturized]) [window deminiaturize:window];
			if ([window isZoomed]) [window performZoom:window];
			NSShow(gadget,true);
			break;
		}
		break;

	case GADGET_TEXTFIELD:
		textfield=(NSTextField*)gadget->handle;
		window=[textfield window];
		if (window) 
		switch (code){
		case ACTIVATE_FOCUS:
			[window makeFirstResponder:textfield];
			break;
		case ACTIVATE_CUT:
			text=[[textfield window] fieldEditor:YES forObject:textfield];
			[text cut:textfield];
			break;	
		case ACTIVATE_COPY:
			text=[[textfield window] fieldEditor:YES forObject:textfield];
			[text copy:textfield];
			break;	
		case ACTIVATE_PASTE:
			text=[[textfield window] fieldEditor:YES forObject:textfield];
			[text paste:textfield];
			break;
		}
		break;

	case GADGET_TEXTAREA:
		textview=(TextView*)gadget->handle;
		switch (code){
		case ACTIVATE_FOCUS:
			window=[textview window];
			if (window) [window makeFirstResponder:textview];
			break;
		case ACTIVATE_CUT:
			[textview cut:textview];
			break;	
		case ACTIVATE_COPY:
			[textview copy:textview];
			break;	
		case ACTIVATE_PASTE:
			[textview pasteAsPlainText:textview];//paste:textview];
			break;		
		case ACTIVATE_PRINT:
			[textview print:textview];
			break;
		}
		break;

	case GADGET_NODE:
		node=(NodeItem*)gadget->handle;
		treeview=[node getOwner];
		switch (code){	
		case ACTIVATE_SELECT:
			[treeview selectNode:node];			
			break;
		case ACTIVATE_EXPAND:
			[treeview expandNode:node];
			break;
		case ACTIVATE_COLLAPSE:
			[treeview collapseNode:node];
			break;
		}
		break;
				
	case GADGET_COMBOBOX:
		switch (code){
		case ACTIVATE_FOCUS:
			combo=(NSComboBox*)gadget->handle;
			[combo selectText:nil];
			break;	
		}
		break;

	case GADGET_HTMLVIEW:
		browser=(HTMLView*)gadget->handle;
		switch(code){
		case ACTIVATE_COPY:
			[browser copy:browser];
			break;	
		case ACTIVATE_BACK:
			[browser goBack:browser];
			break;
		case ACTIVATE_FORWARD:
			[browser goForward:browser];
			break;
		case ACTIVATE_PRINT:
			view = [[[browser mainFrame] frameView] documentView];
			if (view != nil) [view print:view];
			break;
		}
						
	default:
		switch (code){
		case ACTIVATE_FOCUS:
			window=[gadget->handle window];
			if (window) [window makeFirstResponder:gadget->handle];
			break;
		}
	}
}

void NSRethink(nsgadget *gadget){
	NSView		*view;
	NSRect		rect,vis;
	TextView	*textview;
	TabView		*tabber;
	NSButton		*button;
	NSControl 	*combobox;
	int			shouldhide;
	
	view=(NSView*)gadget->handle;
	rect=NSMakeRect(gadget->x,gadget->y,gadget->w,gadget->h);
	
	shouldhide = FALSE;
	
	switch(gadget->internalclass){
	case GADGET_WINDOW:
		vis=[[NSScreen deepestScreen] visibleFrame];
		rect.origin.x+=vis.origin.x;
		rect.origin.y=vis.origin.y+vis.size.height-rect.origin.y-rect.size.height;
		if ((gadget->style&WINDOW_CLIENTCOORDS)!=0){
			if (gadget->style&WINDOW_STATUS) {
				rect.origin.y-=STATUSBARHEIGHT;		
				rect.size.height+=STATUSBARHEIGHT;		
			}
			rect = [(NSWindow*)view frameRectForContentRect:rect];
		}
		
		if(![view isVisible]) shouldhide = TRUE;
		[view setFrame:rect display:YES];
		if(shouldhide) [view orderOut:view];
		return;
	case GADGET_NODE:
	case GADGET_MENUITEM:
	case GADGET_TOOLBAR:
 		return;
	case GADGET_TEXTAREA:
		textview=(TextView*)view;
		[textview setScrollFrame:rect];
		return;
	case GADGET_COMBOBOX:
		if (rect.size.height > 26) rect.size.height = 26;
		break;
	case GADGET_BUTTON:
		button=(NSButton*)view;
		// Push Button Size Hack
		if ((gadget->style&7)==0){
			if (gadget->h > 30) {
				[button setBezelStyle:NSRegularSquareBezelStyle];
			} else {
				if (gadget->h < 24) { 
					[button setBezelStyle:NSShadowlessSquareBezelStyle];
				} else {
					[button setBezelStyle:NSRoundedBezelStyle];
				}
			}	
		}
		break;
	case GADGET_SLIDER:
		switch (gadget->style&12){
			case SLIDER_SCROLLBAR:
				if (gadget->style & SLIDER_HORIZONTAL)
					rect.size.height = [NSScroller scrollerWidth];
				else
					rect.size.width = [NSScroller scrollerWidth];		
				break;
		}
	}
	[[view superview] setNeedsDisplayInRect:[view frame]];
	[view setFrame:rect];
	[view setNeedsDisplay:YES];	
}

void NSRemoveColor(nsgadget *gadget){
	switch (gadget->internalclass){
	case GADGET_BUTTON:
		if ([[gadget->handle cell] respondsToSelector:@selector(setDrawsBackground:)]){
			[[gadget->handle cell] setDrawsBackground:false];
		}
		break;
	case GADGET_WINDOW:
		[gadget->handle setBackgroundColor:nil];
		[gadget->handle display];
		break;
	case GADGET_LABEL:
		if((gadget->style&3)==LABEL_SEPARATOR) break;
	case GADGET_COMBOBOX:
	case GADGET_TEXTFIELD:
		[gadget->handle setDrawsBackground:false];
		break;
	case GADGET_LISTBOX:
	case GADGET_TREEVIEW:
	case GADGET_PANEL:
	case GADGET_TEXTAREA:
		[gadget->handle setColor:nil];
		break;	
	}
}

void NSSetColor(nsgadget *gadget,int r,int g,int b){
	NSColor				*color;

	color=[NSColor colorWithDeviceRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];
	
	switch (gadget->internalclass){
	case GADGET_BUTTON:
		if ([[gadget->handle cell] respondsToSelector:@selector(setBackgroundColor:)]) [[gadget->handle cell] setBackgroundColor:color];
		break;
	case GADGET_COMBOBOX:
	case GADGET_WINDOW:
		[gadget->handle setBackgroundColor:color];
		[gadget->handle display];
		break;
	case GADGET_LABEL:
		if((gadget->style&3)==LABEL_SEPARATOR) break;
		[gadget->handle setDrawsBackground:YES];
	case GADGET_TEXTFIELD:
		[gadget->handle setBackgroundColor:color];
		break;
	case GADGET_LISTBOX:
	case GADGET_TREEVIEW:
	case GADGET_PANEL:
	case GADGET_TEXTAREA:
		[gadget->handle setColor:color];
		break;	
	}
}

void NSSetAlpha(nsgadget *gadget,float alpha){
	NSWindow	*window;
	PanelView	*panel;
	
	switch (gadget->internalclass){
	case GADGET_WINDOW:
		window=(NSWindow*)gadget->handle;
		[window setAlphaValue:alpha];
		break;		
	case GADGET_PANEL:
		panel=(PanelView*)gadget->handle;
		[panel setAlpha:alpha];
		break;	
	}
}

BBString *NSGetUserName(){
	return bbStringFromNSString(CSCopyUserName(true));
}

BBString *NSGetComputerName(){
	return bbStringFromNSString(CSCopyMachineName());
}

BBString *NSRun(nsgadget *gadget,BBString *text){
	HTMLView			*htmlview;
	NSString			*script;
	BBString			*result;

	result=&bbEmptyString;
	switch (gadget->internalclass){
	case GADGET_HTMLVIEW:
		htmlview=(HTMLView*)gadget->handle;
		script=NSStringFromBBString(text);
		script=[htmlview stringByEvaluatingJavaScriptFromString:script];
		result=bbStringFromNSString(script);
		break;
	}
	return result;
}

void NSSetText(nsgadget *gadget,BBString *data){
	NSString				*text;
	NSMutableDictionary	*textAttributes;
	NSMutableParagraphStyle *parastyle;
	NSAttributedString		*attribtext;
	NSObject				*nsobject;
	
	attribtext = nil;
	
	if(data == nil) data = &bbEmptyString;
	
	text = NSStringFromBBString(data);
	
	nsobject = (NSObject*)gadget->handle;
	
	//printf( "data->length: %d\n", data->length );fflush(stdout);
	
	switch (gadget->internalclass){
	case GADGET_TEXTAREA:
		[nsobject setText:text];
		break;
	case GADGET_HTMLVIEW:
		[nsobject setAddress:text];
		break;
	case GADGET_LABEL: /* BaH */
		switch (gadget->style&3) {
		case LABEL_SEPARATOR:
			return;
		default:
			[nsobject setStringValue:text];
			return;
		}
		break;
	case GADGET_BUTTON:
		
		//if ([nsobject respondsToSelector:@selector(setAttributedTitle:)] /*&& [nsobject respondsToSelector:@selector(font)]*/){
			
			// Create attribute dictionary (autorelease'd)
			textAttributes = [NSMutableDictionary dictionary];
			
			// Font
			[textAttributes setObject: [nsobject font] forKey:NSFontAttributeName];
	
	 		// Paragraph style
			parastyle = [[NSMutableParagraphStyle alloc] init];
			[parastyle setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
			
			if(gadget->internalclass == GADGET_BUTTON){
				if(((gadget->style & BUTTON_PUSH) == BUTTON_PUSH) ||
				  (((gadget->style & 7) != BUTTON_RADIO) &&
				   ((gadget->style & 7) != BUTTON_CHECKBOX)))
					[parastyle setAlignment:NSCenterTextAlignment];
			}
			
			[textAttributes setObject: parastyle forKey:NSParagraphStyleAttributeName];
			[parastyle release];
			
			// Text color
			if(gadget->textcolor) [textAttributes setObject: gadget->textcolor forKey: NSForegroundColorAttributeName];
			
			// Underline / strikethrough
			[textAttributes setObject: [NSNumber numberWithInt:0] forKey: NSUnderlineStyleAttributeName];
			[textAttributes setObject: [NSNumber numberWithInt:0] forKey: NSStrikethroughStyleAttributeName];
			
			if ((gadget->intFontStyle&FONT_UNDERLINE)!=0) [textAttributes setObject: [NSNumber numberWithInt:(NSUnderlineStyleSingle|NSUnderlinePatternSolid)] forKey: NSUnderlineStyleAttributeName];
			if ((gadget->intFontStyle&FONT_STRIKETHROUGH)!=0) [textAttributes setObject: [NSNumber numberWithInt:(NSUnderlineStyleSingle|NSUnderlinePatternSolid)] forKey: NSStrikethroughStyleAttributeName];
			
			// Create attibuted text
			attribtext = [[NSAttributedString alloc] initWithString: text attributes: textAttributes];
			
			[nsobject setAttributedTitle:attribtext];
			break;
		//}
	case GADGET_MENUITEM:
		[nsobject setTitle:text];
		// Required otherwise root window menus aren't updated.
		[[nsobject submenu] setTitle:text];
		break;
	case GADGET_PANEL:
	case GADGET_NODE:
	case GADGET_WINDOW:
		[nsobject setTitle:text];
		break;
	case GADGET_COMBOBOX:
		if(!(gadget->style & COMBOBOX_EDITABLE)) break;
	case GADGET_TEXTFIELD:
		[nsobject setStringValue:text];
		break;
	}
}

BBString *NSGetText(nsgadget *gadget){
	
	NSObject		*nsobject;
	BBString		*result;

	result=&bbEmptyString;
	nsobject=(NSObject*)gadget->handle;
	
	switch (gadget->internalclass){
	case GADGET_TEXTAREA:
		result=bbStringFromNSString([[nsobject storage] string]);
		break;
	case GADGET_TEXTFIELD:
	case GADGET_COMBOBOX:
		result=bbStringFromNSString([nsobject stringValue]);
		break;	
	case GADGET_HTMLVIEW:
		result=bbStringFromNSString([nsobject address]);
		break;
	case GADGET_NODE:
		result=bbStringFromNSString([nsobject value]);
		break;
	case GADGET_LABEL: /* BaH */
		switch (gadget->style&3) {
		case 0:
		case LABEL_FRAME:
		case LABEL_SUNKENFRAME:
			result=bbStringFromNSString([nsobject stringValue]);
		}
		break;
	case GADGET_PANEL:
	case GADGET_WINDOW:
	case GADGET_BUTTON:
	case GADGET_MENUITEM:
		result=bbStringFromNSString([nsobject title]);
		break;
	}
	return result;
}

int NSCharWidth(NSFont *font,int charcode){	
	NSSize size=[font advancementForGlyph:charcode];
	return (int)size.width;
}

void NSSetFont(nsgadget *gadget,NSFont *font){
	NSView			*view;
	
	view = (NSView*)gadget->handle;
	
	switch (gadget->internalclass){
		case GADGET_LABEL:
			if ((gadget->style&3)==LABEL_SEPARATOR) break;
		case GADGET_BUTTON:
			[view setFont:font];
			NSSetText(gadget, NSGetText(gadget));		//Apply underline/strikethough formatting as attributed text in NSSetText().
			break;
		case GADGET_LISTBOX:
		case GADGET_TREEVIEW:
		case GADGET_COMBOBOX:
		case GADGET_TEXTAREA:
		case GADGET_TEXTFIELD:
		case GADGET_TABBER:
			[view setFont:font];
			break;
		
	}
}

BBString * NSGetTooltip(nsgadget *gadget){

	BBString			*result;
	NSView			*view;
	
	result=&bbEmptyString;
	view=(NSView*)gadget->handle;
	
	if(view) result=bbStringFromNSString([view toolTip]);
	
	return result;
}

int NSSetTooltip(nsgadget *gadget,BBString *data){
	
	NSString			*text;
	NSView			*view;
	
	view =(NSView*)gadget->handle;
	text=NSStringFromBBString(data);
	
	if(view){
		[view setToolTip:text];
		return 1;
	}
	
	return 0;
}

// gadgetitem commands

void NSClearItems(nsgadget *gadget)
{
	ListView			*listbox;
	NSControl 		*combo;
	NSTabView			*tabber;
	Toolbar			*toolbar;
	NSToolbarItem		*item;
	NSArray			*items;
	int				i,n;
		
	switch (gadget->internalclass){
	case GADGET_LISTBOX:
		listbox=(ListView*)gadget->handle;
		[listbox clear];
		break;
	case GADGET_COMBOBOX:
		combo=(NSControl*)gadget->handle;
		[combo removeAllItems];
		break;
	case GADGET_TABBER:
		tabber=(NSTabView*)gadget->handle;
		items=[tabber tabViewItems];
		n=[tabber numberOfTabViewItems];
		for (i=0;i<n;i++) [tabber removeTabViewItem:[tabber tabViewItemAtIndex:0]];
		break;
	case GADGET_TOOLBAR:
		toolbar=(Toolbar*)gadget->handle;
		items=[toolbar items];
		n=[items count];
		for (i=0;i<n;i++) 	[toolbar removeItemAtIndex:0];
		break;
	}
}

void NSAddItem(nsgadget *gadget,int index,BBString *data,BBString *tip,NSImage *image,BBObject *extra){
	NSString			*text,*tiptext;
	NSControl 		*combo;
	NSTabView			*tabber;
	TabViewItem		*tabitem;
	ListView			*listbox;
	Toolbar			*toolbar;
	NSToolbarItem		*item;

	text=NSStringFromBBString(data);
	tiptext=NSStringFromBBString(tip);
	switch (gadget->internalclass){
	case GADGET_LISTBOX:
		listbox=(ListView*)gadget->handle;
		[listbox addItem:text atIndex:index withImage:image withTip:tiptext withExtra:extra];
		break;
	case GADGET_COMBOBOX:
		combo=(NSControl*)gadget->handle;
		[combo insertItemWithObjectValue:text atIndex:index];
//		[[combo itemAtIndex:index] setImage:image];
		break;
	case GADGET_TABBER:
		tabber=(NSTabView*)gadget->handle;	
		tabitem=[[TabViewItem alloc] initWithIdentifier:text];
		[tabitem setLabel:text];
		[tabitem setImage:image];
		[tabber insertTabViewItem:tabitem atIndex:index];	
		[tabitem release];
		break;
	case GADGET_TOOLBAR:	
		toolbar=(Toolbar*)gadget->handle;
		if (image==0){			
			int v;
			Gestalt( 'sysv',&v );
			if( v>=0x1070 ){
				[toolbar insertItemWithItemIdentifier:NSToolbarSpaceItemIdentifier atIndex:index];
			}else{
				[toolbar insertItemWithItemIdentifier:NSToolbarSeparatorItemIdentifier atIndex:index];
			}
		}
		else{
			item=[[NSToolbarItem alloc] initWithItemIdentifier:text];
			[item setImage:image];
//			[item setLabel:text];
			[item setAction:@selector(iconSelect:)];
			[item setTarget:GlobalApp];
			[item setToolTip:tiptext];
			[item setTag:0];
			[GlobalApp addToolbarItem:item];
			[toolbar addToolbarItem:item];
			[toolbar insertItemWithItemIdentifier:text atIndex:index];								
		}
		break;
	}
}

NSToolbarItem *FindToolbarItem(NSToolbar *toolbar,int index){
	return (NSToolbarItem*)[[toolbar items] objectAtIndex:index];
}

void NSSetItem(nsgadget *gadget,int index,BBString *data,BBString *tip,NSImage *image,BBObject *extra){
	NSString			*text,*tiptext;
	NSControl 		*combo;
	NSTabView			*tabber;
	TabViewItem		*tabitem;
	ListView			*listbox;
	Toolbar			*toolbar;
	NSToolbarItem		*item;

	text=NSStringFromBBString(data);
	tiptext=NSStringFromBBString(tip);

	switch (gadget->internalclass){
	case GADGET_LISTBOX:
		listbox=(ListView*)gadget->handle;
		[listbox setItem:text atIndex:index withImage:image withTip:tiptext withExtra:extra];
		break;
	case GADGET_COMBOBOX:
		combo=(NSControl*)gadget->handle;
		[combo removeItemAtIndex:index];
		[combo insertItemWithObjectValue:text atIndex:index];
//		[[combo itemAtIndex:index] setImage:image];
		break;
	case GADGET_TABBER:
		tabber=(NSTabView*)gadget->handle;
		tabitem=(TabViewItem*)[tabber tabViewItemAtIndex:index];
		[tabitem setLabel:text];
		[tabitem setImage:image];
		break;
	case GADGET_TOOLBAR:	
		toolbar=(Toolbar*)gadget->handle;
		item=FindToolbarItem(toolbar,index);
		if (item)	{
//			[item setLabel:text];
			[item setImage:image];
			[item setToolTip:tiptext];
			[item setTag:0];
		}
		break;
	}
}

void NSRemoveItem(nsgadget *gadget,int index){
	ListView		*listbox;
	NSControl 	*combo;
	NSTabView		*tabber;
	TabViewItem	*tabitem;
	Toolbar		*toolbar;

	switch (gadget->internalclass){
	case GADGET_LISTBOX:
		listbox=(ListView*)gadget->handle;
		[listbox removeItemAtIndex:index];
		break;
	case GADGET_COMBOBOX:
		combo=(NSControl*)gadget->handle;
		[combo removeItemAtIndex:index];
		break;
	case GADGET_TABBER:
		tabber=(NSTabView*)gadget->handle;
		tabitem=(TabViewItem*)[tabber tabViewItemAtIndex:index];
		[tabber removeTabViewItem:tabitem];
		break;
	case GADGET_TOOLBAR:
		toolbar=(Toolbar*)gadget->handle;
		[toolbar removeItemAtIndex:(int)index];
		break;
	}
}

void NSSelectItem(nsgadget *gadget,int index,int state){
	NSControl 		*combo;
	NSTabView			*tabber;
	ListView			*listbox;
	Toolbar			*toolbar;
	NSToolbarItem		*item;

	switch (gadget->internalclass){
	case GADGET_LISTBOX:
		listbox=(ListView*)gadget->handle;
		if(state) [listbox selectItem:index]; else [listbox deselectItem:index];
		break;
	case GADGET_COMBOBOX:
		combo=(NSControl*)gadget->handle;
		[combo setDelegate:nil];
		[combo selectItemAtIndex:index];
		[combo setObjectValue:[combo objectValueOfSelectedItem]];
		[combo setDelegate:GlobalApp];
		break;
	case GADGET_TABBER:
		tabber=(NSTabView*)gadget->handle;
		[tabber selectTabViewItemAtIndex:index];
		break;
	case GADGET_TOOLBAR:	
		toolbar=(Toolbar*)gadget->handle;
		item=FindToolbarItem(toolbar,index);
		BOOL enable=(state&STATE_DISABLED)?false:true;
		[item setEnabled:enable];
		int pressed=(state&STATE_SELECTED)?1:0;
		[item setTag:pressed];
		break;
	}
}

int NSSelectedItem(nsgadget *gadget,int index){
	NSComboBox		*combo;
	NSTabView			*tabber;
	ListView			*listbox;
	Toolbar			*toolbar;
	NSToolbarItem		*item;
	int				state;

	state=0;
	switch (gadget->internalclass){
	case GADGET_LISTBOX:
		listbox=(ListView*)gadget->handle;
		if ([[listbox table] selectedRow]==index) state|=STATE_SELECTED;
		break;
	case GADGET_COMBOBOX:
		combo=(NSControl*)gadget->handle;
		if ([combo indexOfSelectedItem]==index) state|=STATE_SELECTED;
		break;
	case GADGET_TABBER:
		tabber=(NSTabView*)gadget->handle;
		if ([tabber indexOfTabViewItem:[tabber selectedTabViewItem]]==index) state|=STATE_SELECTED;
		break;
	case GADGET_TOOLBAR:	
		toolbar=(Toolbar*)gadget->handle;
		item=FindToolbarItem(toolbar,index);
		if (![item isEnabled]) state|=STATE_DISABLED;
		if ([item tag]!=0) state|=STATE_SELECTED;
		break;
	}
	return state;
}

// treeview commands

int NSCountKids(nsgadget *gadget){
	TreeView		*treeview;
	NodeItem		*node;

	switch (gadget->internalclass){
	case GADGET_TREEVIEW:
		treeview=(TreeView*)gadget->handle;
		return [treeview count];
	case GADGET_NODE:
		node=(NodeItem*)gadget->handle;
		return [node count];
	}
	return 0;
}

int NSSelectedNode(nsgadget *gadget){
	TreeView		*treeview;

	switch (gadget->internalclass){
	case GADGET_TREEVIEW:
		treeview=(TreeView*)gadget->handle;
		return (int)[treeview selectedNode];		
	}
	return -1;
}

// textarea commands

int LinePos(NSString *text,int pos){
	int			line,i;

	line=0;
	for (i=0;i<pos;i++) {if ([text characterAtIndex:i]=='\n' ) line++;}
	return line;
}

int CharPos(NSString *text,int line){
	int			pos,n;

	pos=0;
	n=[text length];
	while (pos<n && line>0){
		if ([text characterAtIndex:pos]=='\n') line--;
		pos++;
	}
	return pos;
}

NSRange GetRange(NSTextStorage *storage,int pos,int count,int units){
	
	NSString	*text;
	unsigned int max;
	
	if (units==TEXTAREA_LINES){
		text=[storage string];
		if (count==TEXTAREA_ALL)
			count=[storage length];
		else
			count=CharPos(text,pos+count);
		pos=CharPos(text,pos);
		max = [storage length]-pos;
		count-=pos;
	}
	else{
		max = [storage length]-pos;
		if (count==TEXTAREA_ALL) count=max;
	}
	
	if (count > max) count = max;
	if (count<0) count=0;
	
	//NSLog(@"GetRange() pos: %d,  count: %d,  length: %d\n", pos, count, [storage length]);
	
	return NSMakeRange(pos,count);
	
}

void NSReplaceText(nsgadget *gadget,int pos,int count,BBString *data,int units){
	NSString			*text;
	TextView			*textarea;
	NSRange			range,snap;
	NSTextStorage		*storage;
	unsigned int			size;
	
	text=NSStringFromBBString(data);
	textarea=(TextView*)gadget->handle;
	
	if(([[textarea string] length] == 0) || ((pos == 0) && (count == TEXTAREA_ALL))){
		
		[textarea setText:text];
		
	} else {
		
		snap=[textarea selectedRange];
		range=GetRange([textarea storage],pos,count,units);
		storage=[textarea storage];
		[storage replaceCharactersInRange:range withString:text];	
		size=[storage length];
		if (snap.location>size) snap.location=size;
		if (snap.location+snap.length>size) snap.length=size-snap.location;	
		[textarea setSelectedRange:snap];
		
	}
	
}

void NSAddText(nsgadget *gadget,BBString *data){
	NSString			*text;
	TextView			*textarea;
	NSRange			range;

	text=NSStringFromBBString(data);
	textarea=(TextView*)gadget->handle;
	[textarea addText:text];
	range=GetRange([textarea textStorage],[[textarea string] length],0,0);
	[textarea setSelectedRange:range];
	[textarea scrollRangeToVisible:range];
}

BBString *NSAreaText(nsgadget *gadget,int pos,int length,int units){
	TextView			*textarea;
	NSRange			range;
	NSAttributedString	*astring;
	BBString				*bstring;

	textarea=(TextView*)gadget->handle;
	range=GetRange([textarea storage],pos,length,units);
	astring=[[textarea storage] attributedSubstringFromRange:range];	
	bstring=bbStringFromNSString([astring string]);
	return bstring;
}

int NSAreaLen(nsgadget *gadget,int units){
	TextView			*textarea;
	NSTextStorage		*storage;
	unsigned			ulen;

	textarea=(TextView*)gadget->handle;
	storage=[textarea storage];
	ulen=[storage length];
	if (units==TEXTAREA_LINES) ulen=LinePos([storage string],ulen)+1;
	return ulen;	
}

void NSSetSelection(nsgadget *gadget,int pos,int length,int units){
	TextView			*textarea;
	NSRange			range;

	textarea=(TextView*)gadget->handle;	
	range=GetRange([textarea textStorage],pos,length,units);
	[textarea setSelectedRange:range];
	if( !textarea->lockedNest ) [textarea scrollRangeToVisible:range];
}

void NSLockText(nsgadget *gadget){
	TextView			*textarea;

	textarea=(TextView*)gadget->handle;
	
	if( !textarea->lockedNest ){
		textarea->lockedRange=[textarea rangeForUserTextChange];
		[textarea->storage beginEditing];
	}

	++textarea->lockedNest;
}

void NSUnlockText(nsgadget *gadget){
	TextView			*textarea;
	
	textarea=(TextView*)gadget->handle;
	
	--textarea->lockedNest;

	if( !textarea->lockedNest ){
		NSRange range=textarea->lockedRange;
		[textarea->storage endEditing];
		if( range.location+range.length>[textarea->storage length] ) range=NSMakeRange( 0,0 );
		[textarea setSelectedRange:range];
	}
}

void NSSetTabs(nsgadget *gadget,int tabwidth){
	TextView *textarea;
	textarea=(TextView*)gadget->handle;	
	[textarea setTabs:tabwidth];
}

void NSSetMargins(nsgadget *gadget,int leftmargin){
	TextView *textarea;
	textarea=(TextView*)gadget->handle;	
	[textarea setMargins:leftmargin];
}

int NSCharAt(nsgadget *gadget,int line){
	TextView		*textarea;
	NSString		*text;
	int				n,i;

	textarea=(TextView*)gadget->handle;	
	text=[[textarea storage] string];
	n=[text length];i=0;
	while (line){
		if (i==n) break;
		if ([text characterAtIndex:i]=='\n' ) line--;
		i++;
	}
	return i;
}

int NSLineAt(nsgadget *gadget,int pos){
	TextView			*textarea;
	textarea=(TextView*)gadget->handle;	
	return LinePos([[textarea storage] string],pos);
}

int NSCharX(nsgadget *gadget,int pos){
	unsigned int rectCount;
	NSRectArray rectArray;
	TextView	*textarea = (TextView*)gadget->handle;
	NSRange range = GetRange([textarea textStorage],pos,0,TEXTAREA_CHARS);
	rectArray = [[textarea layoutManager] rectArrayForCharacterRange:range withinSelectedCharacterRange:range inTextContainer: [textarea textContainer] rectCount:&rectCount];
	if(rectCount > 0) return (int)(((NSRect)rectArray[0]).origin.x-([textarea visibleRect].origin.x-[textarea textContainerOrigin].x));
}

int NSCharY(nsgadget *gadget,int pos){
	unsigned int rectCount;
	NSRectArray rectArray;
	TextView	*textarea = (TextView*)gadget->handle;
	NSRange range = GetRange([textarea textStorage],pos,0,TEXTAREA_CHARS);
	rectArray = [[textarea layoutManager] rectArrayForCharacterRange:range withinSelectedCharacterRange:range inTextContainer: [textarea textContainer] rectCount:&rectCount];
	if(rectCount > 0) return (int)(((NSRect)rectArray[0]).origin.y-([textarea visibleRect].origin.y-[textarea textContainerOrigin].y));
}

int NSGetCursorPos(nsgadget *gadget,int units){
	TextView			*textarea;
	NSRange			range;

	textarea=(TextView*)gadget->handle;	
	range=[textarea rangeForUserTextChange];
	if (range.location == NSNotFound) return 0; //KORIOLIS (avoids read-only text-area crash)
	if (units==TEXTAREA_LINES) return NSLineAt(gadget,range.location);
	return range.location;
}

int NSGetSelectionlength(nsgadget *gadget,int units){
	TextView			*textarea;
	NSRange			range;

	textarea=(TextView*)gadget->handle;	
	range=[textarea rangeForUserTextChange];
	if (range.location == NSNotFound) return 0; //KORIOLIS (avoids read-only text-area crash)
	if (range.length == 0) return 0;
	if (units == TEXTAREA_LINES){
		int l0=NSLineAt(gadget,range.location);
		int l1=NSLineAt(gadget,range.location+range.length-1);
		return (l1-l0+1);
	}
	return range.length;
}

void NSSetTextColor(nsgadget *gadget,int r,int g,int b){
	
	if(gadget->textcolor) [gadget->textcolor release];
	gadget->textcolor = [[NSColor colorWithDeviceRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0] retain];
	
	switch (gadget->internalclass){
	case GADGET_LABEL:
		switch (gadget->style&3) {
			case LABEL_SEPARATOR:
				return;
		}
	case GADGET_TEXTFIELD:
	case GADGET_LISTBOX:
	case GADGET_TREEVIEW:
	case GADGET_TEXTAREA:
		[gadget->handle setTextColor:gadget->textcolor];
		break;
	default:
		NSSetText(gadget, NSGetText(gadget));	//Attempt to reset text with NSAttributedString
		break;
	}
}

void NSSetStyle(nsgadget *gadget,int r,int g,int b,int flags,int pos,int length,int units)	{
	TextView			*textarea;
	NSRange			_range;
	NSColor				*color;
	int traits = 0;

	textarea=(TextView*)gadget->handle;	
	_range=GetRange([textarea storage],pos,length,units);
	color=[NSColor colorWithDeviceRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];
	
	[[textarea storage] removeAttribute:NSLinkAttributeName range:_range];
	[[textarea storage] addAttribute:NSForegroundColorAttributeName value:color range:_range];
	[[textarea storage] addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:(flags & 4)?NSUnderlineStyleSingle:NSUnderlineStyleNone] range:_range];
	[[textarea storage] addAttribute:NSStrikethroughStyleAttributeName value:[NSNumber numberWithInt:(flags & 8)?NSUnderlineStyleSingle:NSUnderlineStyleNone] range:_range];

	traits |= (flags & 1)?NSBoldFontMask:NSUnboldFontMask;
	traits |= (flags & 2)?NSItalicFontMask:NSUnitalicFontMask;

	[[textarea storage] applyFontTraits: traits range:_range];
}

void NSSetValue(nsgadget *gadget,float value){
	NSProgressIndicator	*progbar;
	NSDate				*date;
	NSValue				*info;
	NSRunLoop			*runloop;
	
	switch (gadget->internalclass){
	case GADGET_PROGBAR:
		progbar=(NSProgressIndicator*)gadget->handle;
		[progbar setDoubleValue:value];
		break;
	}
}

// slider / scrollbar

void NSSetSlider(nsgadget *gadget,double value,double small,double big){
	NSScroller		*scroller;
	NSSlider			*slider;
	NSStepper			*stepper;
	NSRect			frame;
	float			size;
	
	switch (gadget->style&12){
	case SLIDER_SCROLLBAR:
		scroller=(NSScroller*)gadget->handle;
		if(value > (big-small))
			value = 1.0L;
		else if(big-small)
			value/=(big-small);
		else
			value = 0.0L;
		[scroller setKnobProportion:(small/big)];
		[scroller setDoubleValue:value];
		break;
	case SLIDER_TRACKBAR:
		slider=(NSSlider*)gadget->handle;
		[slider setMinValue:small];
		[slider setMaxValue:big];
		[slider setDoubleValue:value];
		break;
	case SLIDER_STEPPER:
		stepper=(NSStepper*)gadget->handle;
		[stepper setMinValue:small];
		[stepper setMaxValue:big];
		[stepper setDoubleValue:value];
		break;
	}
}

double NSGetSlider(nsgadget *gadget){
	NSControl	*control;
	control = (NSControl*)gadget->handle;
	return [control doubleValue];
}


NSCursor* NSCursorCreateStock(short sIndex)
{

    // Adapted from wxWidgets - if you believe this contravenes wxWidget's licensing
    // agreements, please let the BRL team know and it will be removed.
    
    int i;
    ArrayCursor* tmpCursor = &arrCursors[sIndex];
    NSImage *tmpImage = [[NSImage alloc] initWithSize:NSMakeSize(16.0,16.0)];
    
    NSBitmapImageRep *tmpRep = [[NSBitmapImageRep alloc]
        initWithBitmapDataPlanes: NULL
        pixelsWide: 16
        pixelsHigh: 16
        bitsPerSample: 1
        samplesPerPixel: 2
        hasAlpha: YES
        isPlanar: YES
        colorSpaceName: NSCalibratedWhiteColorSpace
        bytesPerRow: 2
        bitsPerPixel: 1];
    
    unsigned char *planes[5];
    [tmpRep getBitmapDataPlanes:planes];
    
    for(i=0; i<16; ++i)
    {
        planes[0][2*i  ] = (~tmpCursor->bits[i] & tmpCursor->mask[i]) >> 8 & 0xff;
        planes[1][2*i  ] = tmpCursor->mask[i] >> 8 & 0xff;
        planes[0][2*i+1] = (~tmpCursor->bits[i] & tmpCursor->mask[i]) & 0xff;
        planes[1][2*i+1] = tmpCursor->mask[i] & 0xff;
    }
    
    [tmpImage addRepresentation:tmpRep];
    
    NSCursor* tmpNSCursor =  [[NSCursor alloc]  initWithImage:tmpImage hotSpot:NSMakePoint(tmpCursor->hitpoint[1], tmpCursor->hitpoint[0])];
    
    [tmpRep release];[tmpImage release];
    
    return tmpNSCursor;
}

void NSSetPointer(int shape){
	NSCursor *cursor;
	cursor=[NSCursor arrowCursor];
	
	switch (shape){
//	case POINTER_DEFAULT:cursor=[NSCursor ];break;
	case POINTER_ARROW:cursor=[NSCursor arrowCursor];break;
	case POINTER_IBEAM:cursor=[NSCursor IBeamCursor];break;
//	case POINTER_WAIT:cursor=[NSCursor ];break;
	case POINTER_CROSS:cursor=[NSCursor crosshairCursor];break;
	case POINTER_UPARROW:cursor=[NSCursor resizeUpCursor];break;
	case POINTER_SIZENWSE:cursor=NSCursorCreateStock(curNWSE);break;
	case POINTER_SIZENESW:cursor=NSCursorCreateStock(curNESW);break;
	case POINTER_SIZEWE:cursor=[NSCursor resizeLeftRightCursor];break;
	case POINTER_SIZENS:cursor=[NSCursor resizeUpDownCursor];break;
	case POINTER_SIZEALL:cursor=NSCursorCreateStock(curSizeAll);break;
	case POINTER_NO:cursor=NSCursorCreateStock(curNoEntry);break;
	case POINTER_HAND:cursor=[NSCursor pointingHandCursor];break;
//	case POINTER_APPSTARTING:cursor=[NSCursor ];break;
	case POINTER_HELP:cursor=NSCursorCreateStock(curHelp);break;
	}
	[cursor set];
}

typedef struct bbpixmap bbpixmap;

struct bbpixmap{
// BBObject
	void		*class;
	int		refs;
// pixmap
	unsigned char *pixels;
	int		width,height,pitch,format,capacity;
};


#define PF_I8 1
#define PF_A8 2
#define PF_BGR888 3
#define PF_RGB888 4
#define PF_BGRA8888 5
#define PF_RGBA8888 6
#define PF_STDFORMAT PF_RGBA8888

const static char BytesPerPixel[]={0,1,1,3,3,4,4};
const static char BitsPerPixel[]={0,8,8,24,24,32,32};
const static char RedBitsPerPixel[]={0,0,0,8,8,8,8};
const static char GreenBitsPerPixel[]={0,0,0,8,8,8,8};
const static char BlueBitsPerPixel[]={0,0,0,8,8,8,8};
const static char AlphaBitsPerPixel[]={0,0,8,0,0,8,8};

NSImage *NSPixmapImage(bbpixmap *pix){
	NSImage *image;
	NSBitmapImageRep *bitmap;
	int spp,bpp,i;
	int bytesperrow;
	BOOL	alpha;
	unsigned char * data;
		
	alpha=AlphaBitsPerPixel[pix->format]?YES:NO;
	spp=BytesPerPixel[pix->format];
	bpp=BitsPerPixel[pix->format];
	bytesperrow=pix->width*spp;
	
	bitmap=[[[NSBitmapImageRep alloc] 
		initWithBitmapDataPlanes:NULL
		pixelsWide:pix->width
		pixelsHigh:pix->height
		bitsPerSample:8 
		samplesPerPixel:spp 
		hasAlpha:alpha 
		isPlanar:NO 
		colorSpaceName:NSDeviceRGBColorSpace 
//		bitmapFormat:NSAlphaNonpremultipliedBitmapFormat
		bytesPerRow:bytesperrow 
		bitsPerPixel:bpp] autorelease];
		
	data = [bitmap bitmapData];
	
	for( i = 0; i < pix->height; i++) {
		memcpy( data + ( i * bytesperrow ), pix->pixels + ( i * pix->pitch ), bytesperrow );
	}

	image=[[NSImage alloc] initWithSize:NSMakeSize(pix->width,  pix->height)];
	[image addRepresentation:bitmap];
	[image retain];
	return image;
}

void NSSetImage(nsgadget *gadget,NSImage *image,int flags){
	PanelView *panel;
	NSButton *button;
	NSMenuItem *menu;
	
	switch (gadget->internalclass){
	case GADGET_PANEL:
		panel=(PanelView*)gadget->handle;
		[panel setImage:image withFlags:flags];
		break;
	case GADGET_BUTTON:
		if ((flags & GADGETPIXMAP_ICON) && (gadget->style <= BUTTON_PUSH)){ 
			button=(NSButton *)gadget->handle;
			[button setImage:image];
			if (flags & GADGETPIXMAP_NOTEXT) {
				[button setImagePosition:NSImageOnly];
			} else {
				[button setImagePosition:NSImageLeft];
			}
		}
		break; 
	case GADGET_MENUITEM:
		if (flags & GADGETPIXMAP_ICON){
			menu=(NSMenuItem*)gadget->handle;
			[menu setImage:image];
		}
		break;
	}
}

void NSSetIcon(nsgadget *gadget,NSImage *image){
	NodeItem	*node;
		
	switch (gadget->internalclass){
	case GADGET_NODE:
		node=(NodeItem*)gadget->handle;
		[node setIcon:image];
		break;
	}
}

void NSSetNextView(nsgadget *gadget,nsgadget *nextgadget){
	NSView		*view,*nextview;
	view=(NSView*)gadget->handle;
	nextview=(NSView*)nextgadget->handle;
	[view setNextKeyView:nextview];
}

static int keyToChar( int key ){
	if( key>=KEY_A && key<=KEY_Z ) return key-KEY_A+'a';
	if( key>=KEY_F1 && key<=KEY_F12 ) return key-KEY_F1+NSF1FunctionKey;
	
	switch( key ){
	case KEY_BACKSPACE:return 8;
	case KEY_TAB:return 9;
	case KEY_ESC:return 27;
	case KEY_SPACE:return 32;
	case KEY_PAGEUP:return NSPageUpFunctionKey;
	case KEY_PAGEDOWN:return NSPageDownFunctionKey;
	case KEY_END:return NSEndFunctionKey;
	case KEY_HOME:return NSHomeFunctionKey;
	case KEY_UP:return NSUpArrowFunctionKey;
	case KEY_DOWN:return NSDownArrowFunctionKey;
	case KEY_LEFT:return NSLeftArrowFunctionKey;
	case KEY_RIGHT:return NSRightArrowFunctionKey;
	case KEY_INSERT:return NSInsertFunctionKey;
	case KEY_DELETE:return NSDeleteFunctionKey;
	case KEY_TILDE:return '~';
	case KEY_MINUS:return '-';
	case KEY_EQUALS:return '=';
	case KEY_OPENBRACKET:return '[';
	case KEY_CLOSEBRACKET:return ']';
	case KEY_BACKSLASH:return '\\';
	case KEY_SEMICOLON:return ';';
	case KEY_QUOTES:return '\'';
	case KEY_COMMA:return ',';
	case KEY_PERIOD:return '.';
	case KEY_SLASH:return '/';
	}
	return 0;
}

void NSSetHotKey(nsgadget *gadget,int key,int modifier){
	int chr;
	unichar uchar[1];
	NSString *keyStr;
	int modMask;
	NSMenuItem *menuItem;
	if( gadget->internalclass!=GADGET_MENUITEM ) return;
	modMask=0;
	if( modifier & 1 ) modMask|=NSShiftKeyMask;
	if( modifier & 2 ) modMask|=NSControlKeyMask;
	if( modifier & 4 ) modMask|=NSAlternateKeyMask;
	if( modifier & 8 ) modMask|=NSCommandKeyMask;
	menuItem=(NSMenuItem*)gadget->handle;
	chr=keyToChar( key );
	if( !chr ) {
		[menuItem setKeyEquivalent:@""];
		[menuItem setKeyEquivalentModifierMask:0];
		return;
	}
	uchar[0]=chr;
	keyStr=[NSString stringWithCharacters:uchar length:1];
	[menuItem setKeyEquivalent:keyStr];
	[menuItem setKeyEquivalentModifierMask:modMask];
}