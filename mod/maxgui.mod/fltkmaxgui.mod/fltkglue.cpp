//fltkglue.cpp

#include <stdlib.h>
#include <maxgui.mod/maxgui.mod/maxgui.h>

#include <config.h>
#include <maxgui_templates.h>

#include <FL/Fl.H>
#include <FL/gl.h>
#include <FL/Fl_Window.H>
#include <FL/Fl_Gl_Window.H>
#include <FL/Fl_Tooltip.H>
#include <FL/Fl_Box.H>
#include <FL/Fl_Tiled_Image.H>
#include <FL/Fl_Menu_Item.H>
#include <FL/Fl_Menu_Bar.H>
#include <FL/Fl_Menu_Window.H>
#include <FL/Fl_Text_Editor.H>
#include <FL/Fl_Text_Display.H>
#include <FL/Fl_File_Chooser.H>
#include <FLU/Flu_File_Chooser.h>
#include <FLU/Flu_Simple_Group.h>
#include <FL/Fl_Hold_Browser.H>
#include <FL/Fl_Multi_Browser.H>
#include <FL/Fl_Choice.H>
#include <FL/Fl_Tabs.H>
#include <FL/Fl_Pack.H>
#include <FL/Fl_Secret_Input.H>
#include <FL/Fl_Help_View.H>
#include <FL/Fl_Round_Button.H>
#include <FL/Fl_Color_Chooser.H>
#include <FL/Fl_Progress.H>
#include <FL/Fl_Slider.H>
#include <FL/Fl_Scrollbar.H>
#include <FL/Fl_Spinner.H>
#include <FL/Fl_Toggle_Button.H>
#include <FL/Fl_Input_Choice.H>
#include <FLU/Flu_Tree_Browser.h>

#include <FL/Flmm_Tabs.H>

#include <FL/x.H>

#if __linux
#include <GL/glx.h>
#define __usexpm 1

#if __usexpm
	#include <X11/xpm.h>
#endif

#endif

enum fltypes
{
	FLWINDOW,FLMENUBAR,FLBUTTON,FLCHECKBUTTON,FLROUNDBUTTON,FLTOGGLEBUTTON,FLRADIOPUSHBUTTON,
	FLRETURNBUTTON,FLPANEL,FLGROUPPANEL,FLINPUT,FLPASSWORD,
	FLTABS,FLGROUP,FLPACK,FLBROWSER,FLMULTIBROWSER,FLCHOICE,
	FLTEXTEDITOR,FLTEXTDISPLAY,FLHELPVIEW,FLBOX,FLTOOLBAR,FLPROGBAR,FLSLIDER,FLSCROLLBAR,
	FLSPINNER,FLCANVAS,FLINPUTCHOICE,FLUTREEBROWSER,FLREPEATBUTTON
};

class Fl_AWindow;
class Fl_Panel;
class Fl_Canvas;
class Fl_ATabs;

// system

const char *event_url = "none";
char *redirect_url = 0; // init to null - markcw

int eventid;

const char *viewcallback(Fl_Widget *view, const char *uri)
{
 free(redirect_url);
 redirect_url = 0;
 event_url = uri;
 view->do_callback();
 event_url = 0;
 return (const char *)redirect_url;
}

extern "C"
{
void flReset( void *display,int(*eventhandler)(int),int(*textfilter)(void*),int(*mousecallback)(Fl_Widget*,void*),int(*keycallback)(Fl_Widget*,void*));
void flAddFd( int fd, int when, void (*cb)(int, void*), void* argument = 0){return Fl::add_fd( fd, when, (*cb), argument);}
int flCountFonts();
int flRun() {return Fl::run();}
void flFlush() {Fl::check();}	//Seb was here - we should use check() instead of flush()
unsigned flGetColor( Fl_Color i ){return Fl::get_color( i );}
int flHandle(void *evt)  {
	#if __linux
		return fl_handle(*(XEvent*)evt);
	#endif
}
void flWait(int timeout)
{
	if (timeout<0) Fl::wait(); else Fl::wait(.001*timeout);
}

const char *flFontName(Fl_Font i);
int flFontSizes(int font,int *& size);
const char *flFriendlyFontName(Fl_Font i);
int flFriendlyFontAttributes(Fl_Font i);

int flChooseColor(const char *title, uchar &r, uchar &g, uchar &b) {return fl_color_chooser(title,r,g,b);}

void flSetBelowMouse(Fl_Widget* widget);

// requesters

int flRequest(const char *text,int flags);
char *flRequestFile(const char * message,const char *pattern,const char *path,int save);
char *flRequestDir(const char* message,const char *path,int relative);

void flAddTimeout(double t,void(*callback)(void*),void *user);

// widgets

Fl_Widget *flWidget(int x,int y,int w,int h,char *name,int type);
void flFreeWidget(Fl_Widget*widget);
void flDelete(void* pointer);
void flFreePtr(void* pointer);
void* flUserData(Fl_Widget*widget);
void flSetArea(Fl_Widget*widget,int x,int y,int w,int h);
void flGetArea(Fl_Widget*widget,int *x,int *y,int *w,int *h);
void flSetLabel(Fl_Widget*widget,char*label);
void flSetLabelColor(Fl_Widget*widget, int r, int g, int b);
void flSetLabelFont(Fl_Widget*widget,Fl_Font s);
void flSetLabelSize(Fl_Widget*widget,Fl_Fontsize s);
void flSetBox(Fl_Widget*widget,int boxtype,int redrawifneeded);
void flSetLabelType(Fl_Widget*widget,Fl_Labeltype labeltype);
const char *flGetLabel(Fl_Widget *widget);
void flSetAlign(Fl_Widget*widget,int aligntype);
int flAlign(Fl_Widget*widget);

void flSetColor(Fl_Widget*widget,int r,int g,int b);
void flRemoveColor(Fl_Widget*widget);
void flSetFocus(Fl_Widget*widget);
void *flGetFocus();
void flSetWhen(Fl_Widget*,Fl_When);
Fl_When flGetWhen(Fl_Widget*);
void *flGetUser(Fl_Widget*);
void flSetShow(Fl_Widget*widget,int truefalse);
void flSetCallback(Fl_Widget*,void(*callback)(Fl_Widget*,void*),void *user);
void flSetToolTip(Fl_Widget*widget, char* tip);

void flSetActive(Fl_Widget*widget,int truefalse);
Fl_Window* flWidgetWindow(Fl_Widget* widget);

Fl_Widget* flPushed();
void flSetPushed(Fl_Widget*widget);
void flRedraw(Fl_Widget*widget);
int flWidth(Fl_Widget*widget);
int flHeight(Fl_Widget*widget);
int flVisible(Fl_Widget*widget);
int flChanged(Fl_Widget*widget);
void flClearChanged(Fl_Widget*widget);

void flSetWindowLabel(Fl_Window*window,char*label);
void flSetWindowIcon(Fl_Window*window, char** icon);
void flClearBorder(Fl_Window*window);
void flShowWindow(Fl_Window*widget,int falsetrueiconize);
void flDestroyWindow(Fl_Window*widget);
void flSetMinWindowSize(Fl_AWindow*window,int w,int h);
void flSetMaxWindowSize(Fl_AWindow*window,int w,int h);
void flSetAcceptsFiles(Fl_AWindow*window, int enable );
void flSetNonModal(Fl_AWindow*window);
void flSetModal(Fl_AWindow*window);

void flBegin(Fl_Group*group);
void flEnd(Fl_Group*group);
void flAddToGroup(Fl_Group*group,Fl_Widget*widget);
void flRemoveFromGroup(Fl_Group*group,Fl_Widget*widget);

void flSetMenu(Fl_Menu_ *,void *menu);
void *flCreateMenu(int n,void(*callback)(Fl_Widget*,void*));
void flSetMenuItem(Fl_Menu_Item* menu,int item,char *name,int shortcut,void *user,int flags, Fl_Font fonthandle, Fl_Fontsize fontsize);
void *flPopupMenu(Fl_Menu_Item *menuitem,void *n);

void flSelectTab(Fl_Tabs*,Fl_Widget*);
int flGetTabPanel(Fl_Tabs *tab);
void *flGetTabPanelForEvent(Fl_ATabs *tab);

void flSetInputChoice(Fl_Input_Choice*,int value);
void *flGetInputChoiceTextWidget(Fl_Input_Choice*);
void *flGetInputChoiceMenuWidget(Fl_Input_Choice*);

void flSetChoice(Fl_Choice*,int value);
int flGetChoice(Fl_Choice*);

void flSetButton(Fl_Button*,bool value);
int flGetButton(Fl_Button*);
void flSetButtonKey(Fl_Button*,int key);

void flSetInput(Fl_Input*,char*value);
const char *flGetInput(Fl_Input*);
void flActivateInput(Fl_Input*);
void flSetInputFont(Fl_Input*input,Fl_Font s);
void flSetInputSize(Fl_Input*input,Fl_Fontsize s);

void flClearBrowser(Fl_Browser*);
void flAddBrowser(Fl_Browser*,const char *label,void *obj, Fl_Image* icon);
void flInsertBrowser(Fl_Browser*,int index,const char *label,void *obj, Fl_Image* icon);
void flShowBrowser(Fl_Browser*,int line,int show);
void flSelectBrowser(Fl_Hold_Browser*,int line);
void flMultiBrowserSelect(Fl_Multi_Browser *browse,int line,int select);
int flMultiBrowserSelected(Fl_Multi_Browser *browse,int line);
int flBrowserValue(Fl_Hold_Browser*);
void *flBrowserData(Fl_Hold_Browser*,int line);
const char *flBrowserItem(Fl_Hold_Browser*,int line);
void flSetBrowserItem(Fl_Hold_Browser*,int line,char *text,void *obj, Fl_Image* icon);
void flRemoveBrowserItem(Fl_Hold_Browser*,int line);
void flSetBrowserTextColor(Fl_Hold_Browser *browse,int r,int g,int b);
void flSetBrowserTextFont(Fl_Hold_Browser *browse,Fl_Font s);
void flSetBrowserTextSize(Fl_Hold_Browser *browse,Fl_Fontsize s);
int flBrowserCount(Fl_Hold_Browser *browse);

void flCharPosXY(Fl_Text_Display *textdisplay, int charpos, int *x, int *y);
int flLinePos(Fl_Text_Display *textdisplay,int line);
int flLineStart(Fl_Text_Display *textdisplay,int pos);
int flLineCount(Fl_Text_Display *textdisplay,int pos);
int flTextLength(Fl_Text_Display *textdisplay);
void flSetWrapMode(Fl_Text_Display *textdisplay, int mode, int col);

void flAddText(Fl_Text_Display *textdisplay,char *text);
void flReplaceText(Fl_Text_Display *textdisplay,int start,int count,char *text);
void flSelectText(Fl_Text_Display *textdisplay,int start,int count);
void flShowPosition(Fl_Text_Display *textdisplay);
void flSetText(Fl_Text_Display *textdisplay,char *text);
char *flGetText(Fl_Text_Display *textdisplay,int start,int count);
void flRedrawText(Fl_Text_Display *textdisplay,int start,int count);

void flSetEditTextColor(Fl_Text_Display *textdisplay,int r,int g,int b);
void flSetTextFont(Fl_Text_Display *textdisplay,Fl_Font s);
void flSetTextSize(Fl_Text_Display *textdisplay,Fl_Fontsize s);
void flSetTextCallback(Fl_Text_Display *textdisplay,void(*callback)(int,int,int,int,const char*,void*),void *user);
void flSetTextTabs(Fl_Text_Display *textdisplay,int tabs);
void flActivateText(Fl_Text_Display *textdisplay);

int flGetCursorPos(Fl_Text_Display *textdisplay);
int flGetSelectionLen(Fl_Text_Display *textdisplay);

int flGetTextStyleChar(Fl_Text_Display *textdisplay,int r,int g,int b,Fl_Font font,Fl_Fontsize size);
void flSetTextStyle(Fl_Text_Display *textdisplay,char *text);
void flAddTextStyle(Fl_Text_Display *textdisplay,char *text);
void flReplaceTextStyle(Fl_Text_Display *textdisplay,int start,int count,char *text);
void flInsertTextStyle(Fl_Text_Display *textdisplay,int start,char *text);
void flDeleteTextStyle(Fl_Text_Display *textdisplay,int start,int count);
void* flFreeTextDisplay(Fl_Text_Display *textdisplay);

void flCutText(Fl_Text_Editor *editor);
void flCopyText(Fl_Text_Editor *editor);
void flPasteText(Fl_Text_Editor *editor);

void flSetView(Fl_Help_View *view, const char *html);
void flSeekView(Fl_Help_View *view, const char *anchor);
void flRedirectView(Fl_Help_View *view, char *url);
void flSetLineView(Fl_Help_View *view, int line);
int flGetLineView(Fl_Help_View *view);
void flSetPathView(Fl_Help_View *view, const char *path);
char *flGetPathView(Fl_Help_View *view);
int flIsLinkView(Fl_Help_View *view);
void flSetStyleView(Fl_Help_View *view, int flag);

void flSetProgress(Fl_Progress*,float val);

Fl_RGB_Image *flImage(const unsigned char *pix,int w,int h,int d,int ld);
void flSetImage( Fl_Widget *widget, Fl_RGB_Image *image );
void flFreeImage( Fl_Image *image );
void flSetPanelColor(Fl_Panel *panel,int r,int g,int b);
void flSetPanelImage(Fl_Panel *panel,Fl_RGB_Image *image,int flags);
void flSetPanelActive(Fl_Panel *panel,int yesno);
void flSetPanelEnabled(Fl_Panel *panel,int yesno);

void flSetSliderType(Fl_Slider *slider,int type);
double flSliderValue(Fl_Slider *slider);
void flSetSliderValue(Fl_Slider *slider,double value);
void flSetSliderRange(Fl_Slider *slider,double low,double hi);

int flScrollbarValue(Fl_Scrollbar *scrollbar);
void flSetScrollbarValue(Fl_Scrollbar *scrollbar,int value,int visible,int top, int total);

void flSetSpinnerMin(Fl_Spinner* spinner, double min);
void flSetSpinnerMax(Fl_Spinner* spinner, double max);
void flSetSpinnerValue(Fl_Spinner* spinner, double value);
double flSpinnerValue(Fl_Spinner* spinner);

int flEvent() {if (eventid) return eventid;else return Fl::event();}
int flEventKey() {return Fl::event_key();}
int flEventX() {return Fl::event_x();}
int flEventY() {return Fl::event_y();}
int flEventdX() {return Fl::event_dx();}
int flEventdY() {return Fl::event_dy();}
int flEventState() {return Fl::event_state();}
int flEventKeys(int key) {return Fl::event_key(key);}
int flEventButtons() {return Fl::event_buttons()>>24;}
int flEventButton() {return Fl::event_button();}
int flEventClicks() {return Fl::event_clicks();}
const char *flEventText() {return Fl::event_text();}
int flCompose(int &del){return Fl::compose(del);}
const char *flEventURL() {return event_url;}

void flDisplayRect(int*x,int*y,int*w,int*h);
void flSetCursor(int shape);

int flCanvasWindow(Fl_Canvas *canvas);
void flSetCanvasMode(Fl_Canvas *canvas,int mode);

void* fluRootNode( Flu_Tree_Browser* tree );
void* fluSelectedNode( Flu_Tree_Browser* tree, int index );
void* fluInsertNode( Flu_Tree_Browser::Node* parent, int pos, const char* text );
void* fluAddNode( Flu_Tree_Browser::Node* parent, const char* text );
void fluRemoveNode( Flu_Tree_Browser* tree, Flu_Tree_Browser::Node* node );
void fluSetNode( Flu_Tree_Browser::Node* node, const char* text, Fl_RGB_Image* iconimage );
void fluSetNodeUserData( Flu_Tree_Browser::Node* node, void* user_data );
void* fluNodeUserData( Flu_Tree_Browser::Node* node );
void fluExpandNode( Flu_Tree_Browser::Node* node, int collapse );
void fluSelectNode( Flu_Tree_Browser::Node* node );
void* fluCallbackNode( Flu_Tree_Browser* tree );
int fluCallbackReason( Flu_Tree_Browser* tree );

};

void flSetCursor(int shape)
{
	Fl_Cursor cursor=FL_CURSOR_DEFAULT;
	switch (shape)
	{
	case POINTER_ARROW:cursor=FL_CURSOR_ARROW;break;
	case POINTER_IBEAM:cursor=FL_CURSOR_INSERT;break;
	case POINTER_WAIT:cursor=FL_CURSOR_WAIT;break;
	case POINTER_CROSS:cursor=FL_CURSOR_CROSS;break;
	case POINTER_UPARROW:cursor=FL_CURSOR_N;break;
	case POINTER_SIZENWSE:cursor=FL_CURSOR_NWSE;break;
	case POINTER_SIZENESW:cursor=FL_CURSOR_NESW;break;
	case POINTER_SIZEWE:cursor=FL_CURSOR_WE;break;
	case POINTER_SIZENS:cursor=FL_CURSOR_NS;break;
	case POINTER_SIZEALL:cursor=FL_CURSOR_MOVE;break;
	case POINTER_NO:cursor=FL_CURSOR_NONE;break;
	case POINTER_HAND:cursor=FL_CURSOR_HAND;break;
	case POINTER_APPSTARTING:cursor=FL_CURSOR_WAIT;break;
	case POINTER_HELP:cursor=FL_CURSOR_HELP;break;
	}
	fl_cursor(cursor);
}

char *stringcopy(const char *l)
{
	char	*c;
	int		n;
	if (!l) return 0;
	n=strlen(l);
	c=(char*)malloc(n+1);
	strcpy(c,l);
	return c;
}

int maxfonts;

int(*mousehandler)(Fl_Widget*,void*);
int(*keyhandler)(Fl_Widget*,void*);
int(*syshandler)(int);
int(*textfilter)(void*);

void flReset(void *display,int(*handler)(int),int(*filter)(void*),int(*msehandler)(Fl_Widget*,void*),int(*kyhandler)(Fl_Widget*,void*))
{
	Fl::visual(FL_RGB|FL_DOUBLE);
	
	#if __linux
		fl_open_display((Display*)display);
	#endif
	
	//Set default font sizes
	FL_NORMAL_SIZE = 12;
	fl_message_font( FL_HELVETICA, FL_NORMAL_SIZE );
	Fl_Tooltip::size( FL_NORMAL_SIZE );
	
	fl_register_images();
	Fl::scheme("gtk+");
	if (handler)
	{
		Fl::add_handler(handler);
		syshandler=handler;
	}
	textfilter=filter;
	mousehandler = msehandler;
	keyhandler = kyhandler;
	maxfonts=Fl::set_fonts(0);
	Fl::get_system_colors();
}

int flCountFonts() {return ((maxfonts < FL_FREE_FONT) ? FL_FREE_FONT-1 : maxfonts);}

const char *flFontName(Fl_Font i)
{
	if (i<0 || i>=maxfonts) return "";
	return Fl::get_font((Fl_Font)i);
}

const char *flFriendlyFontName(Fl_Font i)
{
	int attributes;
	if (i<0 || i>=maxfonts) return "";
	attributes = 0;
	return Fl::get_font_name(i, &attributes);
}

int flFriendlyFontAttributes(Fl_Font i)
{
	int attributes;
	if (i<0 || i>=maxfonts) return 0;
	attributes = 0;
	Fl::get_font_name(i, &attributes);
	return attributes;
}

int flFontSizes(Fl_Font font,int *& sizes)
{
	return Fl::get_font_sizes(font,*&sizes);
}

void flSetBelowMouse(Fl_Widget* widget){Fl::belowmouse(widget);};

void flDisplayRect(int*x,int*y,int*w,int*h)
{
	*x=Fl::x();
	*y=Fl::y();
	*w=Fl::w();
	*h=Fl::h();
}

void flAddTimeout(double t,void(*callback)(void*),void *user)
{
	Fl::add_timeout(t,callback,user);
}

int flRequest(const char *text,int flags)
{
	switch (flags)
	{
	case 0:
		fl_message(text);
		return 0;
	case 1:
		fl_alert(text);
		return 0;
	case 2:
		return fl_choice(text,"No","Yes",0);			//return fl_ask(text);
	case 3:
		return fl_choice(text,"Cancel","No","Yes");
	}
}

char *flRequestFile(const char * message,const char *pattern,const char *path,int save)
{
	if(save) return (char*)flu_save_chooser(message,pattern,path); else return (char*)flu_file_chooser(message,pattern,path);
}

char *flRequestDir(const char* message,const char *path,int relative)
{
 	return (char*)flu_dir_chooser(message,path,0);
}

int isboxaframe( int box ){
	switch(box){
		case FL_NO_BOX:
		case FL_UP_FRAME:
		case FL_DOWN_FRAME:
		case FL_THIN_UP_FRAME:
		case FL_THIN_DOWN_FRAME:
		case FL_ENGRAVED_FRAME:
		case FL_EMBOSSED_FRAME:
		case FL_BORDER_FRAME:
		case _FL_SHADOW_FRAME:
		case _FL_ROUNDED_FRAME:
		case _FL_OVAL_FRAME:
		case _FL_PLASTIC_UP_FRAME:
		case _FL_PLASTIC_DOWN_FRAME:
		case FL_FREE_BOXTYPE:
		return 1;
	}
	return 0;
}

class Fl_Panel:public Fl_Group
{
	Fl_Image	*origimage;
	Fl_Image	*img;
	int			pixmapflags;
	int			hascolor;
	int			active;
	int			enabled;
public:
	Fl_Panel(int x,int y,int w,int h,const char *title):Fl_Group(x,y,w,h,title)
	{
		box(FL_ENGRAVED_FRAME);align(FL_ALIGN_LEFT|FL_ALIGN_INSIDE);
		clip_children(true);resizable(NULL);
		img=NULL;origimage=NULL;pixmapflags=0;
		hascolor=0;active=0;enabled=1;
	}
	void setimage(Fl_RGB_Image *i,int flags)
	{
		pixmapflags = flags;
		if(origimage!=i){
			if(origimage) origimage = NULL;
			updateImage();
			origimage = i;
		}
		updateImage();
		redraw();
	}
	
	void setcolor(Fl_Color c)
	{
		if(!hascolor){
			hascolor=1;
			switch(box()){
				case FL_NO_BOX:
					box(FL_FLAT_BOX);
					break;
				case FL_DOWN_FRAME:
					box(FL_DOWN_BOX);
					break;
				case FL_UP_FRAME:
					box(FL_UP_BOX);
					break;
			}
		}
		color(c);
	}
	
	void setactive(int yesno){active=yesno;}
	
	void setenabled(int yesno){
		
		if(enabled!=yesno){
			enabled=(yesno ? 1 : 0);
			if(img){
				delete img;
				img = NULL;
			}
			updateImage();
		} else {
			enabled=(yesno ? 1 : 0);
		}
		
	}
	
	void updateImage(){
		
		if (origimage) {
			
			double scalew = (double)w()/origimage->w(), scaleh = (double)h()/origimage->h();
			
			switch (pixmapflags & (PANELPIXMAP_FIT|PANELPIXMAP_FIT2|PANELPIXMAP_STRETCH)){
				case PANELPIXMAP_FIT:
					if (scalew < scaleh) scaleh = scalew; else scalew = scaleh;
					break;
				case PANELPIXMAP_FIT2:
					if (scaleh < scalew) scaleh = scalew; else scalew = scaleh;
					break;
				case PANELPIXMAP_STRETCH:
					break;
				default:
					scalew = scaleh = 1.0;
			}
			
			int neww = scalew * origimage->w(), newh = scaleh * origimage->h();
			
			if (!img || (neww != img->w()) || (newh != img->h())){
				if (img) delete img;
				img = origimage->copy(neww,newh);
				if (!enabled) img->inactive();
			}
			
		} else {
			if (img) delete img;
			img = NULL;
		}
		
	}
	
	void draw()
	{
		
		int lblW = 0, lblH, X, dx, dy, dw, dh;
		uchar* pix;
		
		if( (label() == 0) )
		  lblW = lblH = 0;
		else if( strlen( label() ) == 0 )
		  lblW = lblH = 0;
		else
		  {
		    measure_label( lblW, lblH );
		    lblW += 4;
		    lblH += 2;
		  }
		
		// align the label
		if( align() & FL_ALIGN_LEFT )
		  X = 4;
		else if( align() & FL_ALIGN_RIGHT )
		  X = w() - lblW - 8;
		else
		  X = w()/2 - lblW/2 - 2;
		
		// save label background to an image in memory
		if(lblW && lblH) pix = fl_read_image(NULL,x()+X,y(),lblW+4,lblH,0); else pix = NULL;
		
		// draw the main group box
		if( damage() & ~FL_DAMAGE_CHILD ){
			dx=x();dy=y()+lblH/2;dw=w();dh=h()-lblH/2;
			fl_draw_box( box(), dx, dy, dw, dh, color() );
			if (img){
				if ((box()!=FL_NO_BOX) && (box()!=FL_FLAT_BOX)) {dx+=3;dy+=3;dw-=6;dh-=6;}
				fl_clip(dx,dy,dw,dh);
				switch(pixmapflags){
					case PANELPIXMAP_TILE:
						img = new Fl_Tiled_Image(img,dw,dh);
						break;
					default:
						dx = x()+w()/2-img->w()/2;dy = y()+h()/2-img->h()/2;
						break;
				}
				img->draw(dx,dy);
				fl_pop_clip();
			}
		}
		
		// clip and draw the children
		if((box()!=FL_NO_BOX) && (box()!=FL_FLAT_BOX)) fl_clip( x()+2, y()+lblH+1, w()-4, h()-lblH-3 );
		else fl_clip( x(), y()+lblH, w(), h()-lblH );
		draw_children();
		fl_pop_clip();
		
		if(lblW && lblH) {
			
			// clear behind the label and draw it
			if(pix) {
				fl_draw_image( pix,x()+X,y(),lblW+4,lblH,3,0);
				delete[] pix;
			} else {
				fl_color( color() );
				fl_rectf( x()+X,y(),lblW+4,lblH );
			}
			
			fl_color( labelcolor() );
			
			draw_label( x()+X+2, y(), lblW, lblH, FL_ALIGN_CENTER );
			
		}
		
	}
	
};

class Fl_AWindow:public Fl_Double_Window
{
private:
	int minw, minh, maxw, maxh, dragdrop;		//Used by setminsize() and setmaxsize()
	Fl_Widget* push_override;
public:
	Fl_AWindow(int x,int y,int w,int h,const char *title):Fl_Double_Window(w,h,title)
	{
		minw = 0; minh = 0; maxw = 0; maxh = 0;
		push_override = NULL;
		dragdrop = 0;position(x,y);
		#if __linux
			Fl_X::make_xid(this);
		#elif defined(WIN32)
			icon(LoadIcon(GetModuleHandle(NULL),MAKEINTRESOURCE(101)));
		#endif
	}
	void resize(int x,int y,int w,int h)
	{
		Fl_Double_Window::resize(x,y,w,h);
		do_callback();
	}
	void updatesizerange()
	{
		if ((minw == 0) && (minh == 0))
		{
			resizable(0);
			size_range(w(),h());
		}
		else
		{
			resizable(this);
			size_range(minw,minh,maxw,maxh);
		}
	}
	
	void setminsize( int w, int h ) {minw = w;minh = h;updatesizerange();}
	void setmaxsize( int w, int h ) {maxw = w;maxh = h;updatesizerange();}
	void setdragdrop( int enable ) {dragdrop = enable ? 1 : 0;}
	
	int handle(int event)
	{
		int res = 0, shouldignore = 0;
		eventid = event;
		
		switch (event)
		{
		case FL_DND_ENTER:
		case FL_DND_DRAG:
		case FL_DND_RELEASE:
		case FL_DND_LEAVE:
		case FL_PASTE:
			if (dragdrop) {
				do_callback();
				res = 1;
				shouldignore = 1;
			}
			break;
		}
		
		eventid = 0;
		
		if(!shouldignore) res = Fl_Double_Window::handle(event);
		
		return res;
	}
	
	void maximize() {
		
		// Rafał Maj proposed patch here: http://www.mail-archive.com/fltk-dev@easysw.com/msg00872.html
		
		#ifdef WIN32
			
			HWND hWnd = fl_xid(this);
			if(hWnd) ShowWindow(hWnd, SW_MAXIMIZE);
		
		#elif __linux
			
			XEvent xev;
			Atom wm_state = XInternAtom(fl_display, "_NET_WM_STATE", False);
			Atom maximizeV = XInternAtom(fl_display, "_NET_WM_STATE_MAXIMIZED_VERT", False);
			Atom maximizeH = XInternAtom(fl_display, "_NET_WM_STATE_MAXIMIZED_HORZ", False);
			
			memset(&xev, 0, sizeof(xev));
			xev.type = ClientMessage;
			xev.xclient.window = fl_xid(this);
			xev.xclient.message_type = wm_state;
			xev.xclient.format = 32;
			xev.xclient.data.l[0] = 1;
			xev.xclient.data.l[1] = maximizeV;
			xev.xclient.data.l[2] = maximizeH;
			xev.xclient.data.l[3] = 0;
			XSendEvent(fl_display, RootWindow(fl_display, fl_screen), 0, SubstructureNotifyMask|SubstructureRedirectMask, &xev);
			
		#endif
	
	}
	
	void restore() {
		
		#ifdef WIN32
			
			HWND hWnd = fl_xid(this);
			if(hWnd) ShowWindow(hWnd, SW_RESTORE);
		
		#elif __linux
			
			XEvent xev;
			Atom wm_state = XInternAtom(fl_display, "_NET_WM_STATE", False);
			
			memset(&xev, 0, sizeof(xev));
			xev.type = ClientMessage;
			xev.xclient.window = fl_xid(this);
			xev.xclient.message_type = wm_state;
			xev.xclient.format = 32;
			xev.xclient.data.l[0] = 1;
			xev.xclient.data.l[1] = 0;
			xev.xclient.data.l[2] = 0;
			xev.xclient.data.l[3] = 0;
			XSendEvent(fl_display, RootWindow(fl_display, fl_screen), 0, SubstructureNotifyMask|SubstructureRedirectMask, &xev);
			
		#endif
	
	}

	
};


enum{
	FLAGS_BACKBUFFER=	0x2,
	FLAGS_ALPHABUFFER=	0x4,
	FLAGS_DEPTHBUFFER=	0x8,
	FLAGS_STENCILBUFFER=0x10,
	FLAGS_ACCUMBUFFER=	0x20,
	FLAGS_FULLSCREEN=0x80000000
};

#if __linux

XVisualInfo *_chooseXVisual(int flags){
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
	return glXChooseVisual(fl_display,fl_screen,glspec);		//RootWindow(fl_display,
}


int glspec2[]={GLX_RGBA,GLX_DOUBLEBUFFER,GLX_DEPTH_SIZE,1,None};

#endif

class Fl_Canvas:public Fl_Window
{
	int enabled, mode;
	
	#if __linux
	XVisualInfo *visual;
	Colormap colormap;
	#endif

public:

	Fl_Canvas(int x,int y,int w,int h,const char *title):Fl_Window(x,y,w,h,title) {
		enabled=1;mode=0;
		#if __linux
			visual=0;
		#endif
		clip_children(true);
	}

	void setenabled(int yesno) {
		enabled=yesno;
	}

	void setmode(int gfxmode) {
		mode=gfxmode;
	}

	void show() {
		#if __linux
		if (window() && window()->shown()==0) return;	//parent is hidden so must defer
		if (shown()) {Fl_Window::show(); return;}  // you must do this!
		if (!visual)
		{
			visual=_chooseXVisual(mode);
			colormap=XCreateColormap(fl_display,RootWindow(fl_display,fl_screen),visual->visual,AllocNone);
		}
		Fl_X::make_xid(this,visual,colormap);
		#else
		Fl_Window::show();
		#endif
	}
	
	int handle(int event) {
		switch (event) {
			case FL_FOCUS:
				return (active_r() ? 1 : 0);
				break;
			default:
				return Fl_Window::handle(event);
		}
	}

	void draw() {		//fltk callback for lowlevel drawing
		eventid=FL_ACTIVATE;
		do_callback();
		eventid=0;
	}
};

int flCanvasWindow(Fl_Canvas *canvas)
{
	return (int)fl_xid(canvas);
}

void flSetCanvasMode(Fl_Canvas *canvas,int mode) {
	canvas->setmode(mode);
}

class Fl_ATabs:public Flmm_Tabs
{
public:
	Fl_ATabs(int x,int y,int w,int h,const char *title=0):Flmm_Tabs(x,y,w,h,title)
	{
		clip_children(true);
	}
	
	Fl_Widget* which(int event_x, int event_y) {
		return Flmm_Tabs::which(event_x,event_y);
	}
	
	int handle(int event)
	{
		int		should_callback, should_ignore, res;
		should_callback=0;should_ignore=0;
		switch (event)
		{
		case FL_PUSH:
		case FL_RELEASE:
			should_callback=1;
		case FL_DRAG:
			if (which(Fl::event_x(),Fl::event_y()) && (Fl::event_button()!=FL_LEFT_MOUSE)) should_ignore = 1;
		}
		if (!should_ignore) res=Flmm_Tabs::handle(event);
		if (should_callback) do_callback();
		return res;
	}
};


static int colwidths[]={14,14,14,14,14,14,14,14,14,14,0};	//16,16,16,16,0};

Fl_Widget *flWidget(int x,int y,int w,int h,char *label,int fltype)
{
	Fl_Window	*window;
	Fl_Group	*group;
	Fl_Menu_Bar	*menu;
	Fl_Browser	*browser;
	Fl_Text_Buffer	*text;
	Fl_Help_View	*help;
	Fl_Choice	*choice;
	Fl_Progress	*progbar;
	Fl_Panel	*panel;
	Fl_Slider	*slider;
	Fl_Spinner	*spinner;
	Fl_Canvas	*canvas;
	Flu_Tree_Browser *tree;

	//printf("flWidget %d,%d,%d,%d \"%s\" %d\n",x,y,w,h,label,fltype);
	//label=stringcopy(label);
	
	switch (fltype)
	{
	case FLWINDOW:
		window=new Fl_AWindow(x,y,w,h,label);
		window->end();
		return window;
	case FLMENUBAR:
		menu=new Fl_Menu_Bar(x,y,w,h);
		menu->clear();
		return menu;
	case FLBUTTON:
		return new MaxGUIEventListener< MaxGUIHoverEffect<Fl_Button> >(x,y,w,h,label);
	case FLCHECKBUTTON:
		return new MaxGUIEventListener<Fl_Check_Button>(x,y,w,h,label);
	case FLROUNDBUTTON:
		return new MaxGUIEventListener< MaxGUIHoverEffect<Fl_Round_Button> >(x,y,w,h,label);
	case FLRADIOPUSHBUTTON:
	case FLTOGGLEBUTTON:
		return new MaxGUIEventListener<Fl_Toggle_Button>(x,y,w,h,label);
	case FLRETURNBUTTON:
		return new MaxGUIEventListener< MaxGUIHoverEffect<Fl_Return_Button> >(x,y,w,h,label);
	case FLREPEATBUTTON:
		return new MaxGUIEventListener< MaxGUIHoverEffect<Fl_Repeat_Button> >(x,y,w,h,label);
	case FLGROUPPANEL:
	case FLPANEL:
		panel=new MaxGUIEventListener<Fl_Panel>(x,y,w,h,label);
		panel->end();
		return panel;
	case FLINPUT:
		return new MaxGUIEventListener< MaxGUIKeyFilter<Fl_Input> >(x,y,w,h,label);
	case FLPASSWORD:
		return new MaxGUIEventListener< MaxGUIKeyFilter<Fl_Secret_Input> >(x,y,w,h,label);
	case FLTABS:
		group=new MaxGUIEventListener<Fl_ATabs>(x,y,w,h,label);
		group->selection_color(fl_color_average(group->selection_color(),FL_SELECTION_COLOR,.80f));
		group->end();
		return group;
	case FLGROUP:
		group=new MaxGUIEventListener<Fl_Group>(x,y,w,h,label);
		group->clip_children(true);
		group->end();
		group->box(FL_NO_BOX);
		return group;
	case FLPACK:
		group=new MaxGUIEventListener<Fl_Pack>(x,y,w,h,label);
		group->clip_children(true);
		group->end();
		return group;
	case FLMULTIBROWSER:
	case FLBROWSER:
		if(fltype==FLBROWSER) browser=new MaxGUIEventListener<Fl_Hold_Browser>(x,y,w,h,label);
		else browser=new MaxGUIEventListener<Fl_Multi_Browser>(x,y,w,h,label);
		browser->column_widths(colwidths);
		return browser;
	case FLINPUTCHOICE:
		group= new MaxGUIEventListener<Fl_Input_Choice>(x,y,w,h,label);
		group->end();
		return group;
	case FLCHOICE:
		return new MaxGUIEventListener< MaxGUIHoverEffect<Fl_Choice> >(x,y,w,h,label);
	case FLTEXTEDITOR:
		Fl_Text_Editor *edit;
		text=new Fl_Text_Buffer;
		edit=new MaxGUIEventListener< MaxGUIKeyFilter< MaxGUITextArea<Fl_Text_Editor> > >(x,y,w,h,"");
		edit->buffer(text);
		edit->remove_key_binding('z',FL_CTRL);
		return edit;
	case FLTEXTDISPLAY:
		Fl_Text_Display *display;
		text=new Fl_Text_Buffer;
		display=new MaxGUIEventListener< MaxGUIKeyFilter< MaxGUITextArea<Fl_Text_Display> > >(x,y,w,h,"");
		display->buffer(text);
		return display;
	case FLHELPVIEW:
		help=new MaxGUIEventListener<Fl_Help_View>(x,y,w,h,label);
		help->link(viewcallback);
		return help;
	case FLBOX:
		return new MaxGUIEventListener<Fl_Box>(x,y,w,h,label);
	case FLTOOLBAR:
		group=new MaxGUIEventListener<Fl_Group>(x,y,w,h);
		group->clip_children(true);
		group->end();
		return group;
	case FLPROGBAR:
		progbar=new MaxGUIEventListener<Fl_Progress>(x,y,w,h,label);
		progbar->minimum(0.0);
		progbar->maximum(1.0);
		progbar->selection_color(FL_SELECTION_COLOR);
		return progbar;
	case FLSLIDER:
		slider=new MaxGUIEventListener<Fl_Slider>(x,y,w,h);
		slider->bounds(0,100);
		return slider;
	case FLSCROLLBAR:
		slider=new MaxGUIEventListener<Fl_Scrollbar>(x,y,w,h);
		return slider;
	case FLSPINNER:
		spinner=new MaxGUIEventListener<Fl_Spinner>(x,y,w,h);
		spinner->minimum(5);
		spinner->maximum(10);
		spinner->step(1);
		spinner->value(5);
		spinner->end();
		return spinner;
	case FLCANVAS:
		canvas=new MaxGUIEventListener<Fl_Canvas>(x,y,w,h,label);
		canvas->end();
		return canvas;
	case FLUTREEBROWSER:
		tree=new MaxGUIEventListener<Flu_Tree_Browser>(x,y,w,h,label);
		tree->auto_branches(true);
		tree->show_root(false);
		tree->selection_mode(FLU_SINGLE_SELECT);
		tree->insertion_mode(FLU_INSERT_BACK);
		tree->selection_drag_mode(FLU_DRAG_IGNORE);
		tree->branch_icons(NULL,NULL);
		tree->branch_text(FL_BLACK,FL_HELVETICA,12);
		tree->double_click_opens(false);
		tree->open_on_select(false);
		tree->animate(false);
		tree->end();
		return tree;
	}
	return 0;	
}

void flFreeWidget(Fl_Widget*widget)
{
	Fl_Group	*parent;
	parent=widget->parent();
	if (parent) parent->remove(widget);
	Fl::delete_widget(widget);
}

void flFreePtr( void* pointer )
{
	if(pointer) free(pointer);
}

void* flUserData( Fl_Widget* widget )
{
	if(widget) return widget->user_data();
}

void flDelete ( void* pointer )
{
	delete pointer;
}

Fl_Widget* flPushed()
{
	return Fl::pushed();
}

void flSetPushed(Fl_Widget* widget)
{
	Fl::pushed(widget);
}

void flRedraw(Fl_Widget*widget)
{
	widget->redraw();
	if((isboxaframe(widget->box())) && (widget->window()))
		widget->window()->damage(FL_DAMAGE_ALL,widget->x(),widget->y(),widget->w(),widget->h());
	if(widget->label())
		widget->redraw_label();
}

int flWidth(Fl_Widget*widget)
{
	return widget->w();
}

int flHeight(Fl_Widget*widget)
{
	return widget->h();
}

int flVisible(Fl_Widget*widget) {
	return widget->visible();
}

int flChanged(Fl_Widget*widget) {
	return widget->changed();
}

void flClearChanged(Fl_Widget*widget) {
	widget->clear_changed();
}

void flSetBox(Fl_Widget*widget,int boxtype,int redrawifneeded = 0)
{
	if(widget->box()!=boxtype){
		widget->box((Fl_Boxtype)boxtype);
		if(redrawifneeded) flRedraw(widget);
	}
}

void flSetLabelType(Fl_Widget*widget,Fl_Labeltype labeltype)
{
	widget->labeltype(labeltype);	
}

void flSetAlign(Fl_Widget*widget,int aligntype)
{
	widget->align(aligntype);
}

int flAlign(Fl_Widget*widget)
{
	return widget->align();
}

void flRemoveColor(Fl_Widget*widget){
	int	rr,gg,bb;
	widget->color(FL_BACKGROUND_COLOR);
}

void flSetColor(Fl_Widget*widget,int r,int g,int b)
{
	int	rr,gg,bb;
	widget->color(fl_rgb_color(r,g,b));
	widget->selection_color(FL_SELECTION_COLOR);
	if(fl_contrast(widget->selection_color(),widget->color())!=widget->selection_color()){
		rr=255-r;gg=255-g;bb=255-b;
		if (abs(rr-r)+abs(gg-g)+abs(bb-b)<64)
		{
			rr=r^0x80;gg=g^0x80;bb=b^0x80;
		}
		widget->selection_color(fl_rgb_color(rr,gg,bb));
	}
}

void flSetLabelColor(Fl_Widget*widget,int r,int g,int b)
{
	widget->labelcolor(fl_rgb_color(r,g,b));
}

void flSetLabelFont(Fl_Widget*widget,Fl_Font s)
{
	widget->labelfont(s);
}

void flSetLabelSize(Fl_Widget*widget,Fl_Fontsize s)
{
	widget->labelsize(s);
}

const char *flGetLabel(Fl_Widget*widget)
{
	return widget->label();
}

void flSetFocus(Fl_Widget*widget)
{
	widget->take_focus();
}

void *flGetFocus() {
	return Fl::focus();
}

Fl_When flGetWhen(Fl_Widget* widget) {
	return widget->when();
}


void flSetWhen(Fl_Widget* widget, Fl_When when) {
	widget->when(when);
}

void *flGetUser(Fl_Widget*widget) {
	return widget->user_data();
}

void flSetArea(Fl_Widget*widget,int x,int y,int w,int h)
{
	widget->damage_resize(x,y,w,h);
	widget->redraw_label();
}

void flGetArea(Fl_Widget*widget,int *x,int *y,int *w,int *h)
{
	*x=widget->x();
	*y=widget->y();
	*w=widget->w();
	*h=widget->h();
}

void flSetLabel(Fl_Widget*widget,char*label)
{
	widget->copy_label( label[0] ? label : 0 );
}

void flSetShow(Fl_Widget *widget,int truefalse)
{
	if (truefalse)
		widget->show();
	else
		widget->hide();
}

void flSetCallback(Fl_Widget *widget,void(*callback)(Fl_Widget*,void*),void *user)
{
	widget->user_data(user);
	widget->callback(callback);
}

void flSetToolTip(Fl_Widget*widget,char*tip)
{
	widget->tooltip(stringcopy(tip));
}

void flSetActive(Fl_Widget *widget,int truefalse)
{
	if (truefalse) widget->activate(); else widget->deactivate();
}

Fl_Window* flWidgetWindow(Fl_Widget* widget)
{
	return widget->window();
}

void flSetWindowLabel(Fl_Window*window,char*label)
{
	//For some reason Fl_Widget::copy_label() isn't virtual.
	window->copy_label(label);
}


void flSetWindowIcon(Fl_Window*window,char** icon)
{
	#if __usexpm
		Pixmap p, mask;
		XpmCreatePixmapFromData(fl_display, DefaultRootWindow(fl_display),icon, &p, &mask, NULL);
		window->icon((char *)p);
	#endif
}

void flClearBorder(Fl_Window *window)
{
	window->border(0);
}

void flShowWindow(Fl_Window *window,int falsetrueiconize){
	switch (falsetrueiconize){
	case 0:
		window->hide();
		break;
	case 1:
		window->show();
		break;
	case 2:
		window->iconize();
		break;
	case 3:
		window->show();
		((Fl_AWindow*)window)->maximize();
		break;
	case 4:
		window->show();
		((Fl_AWindow*)window)->restore();
		break;
	}	
}

void flDestroyWindow(Fl_Window *window) {
	delete window;
}

void flSetMaxWindowSize(Fl_AWindow*window,int w,int h)
{
	window->setmaxsize(w,h);
}

void flSetMinWindowSize(Fl_AWindow*window,int w,int h)
{
	window->setminsize(w,h);
}

void flSetAcceptsFiles(Fl_AWindow*window, int enable )
{
	window->setdragdrop(enable);
}

void flSetNonModal(Fl_AWindow*window)
{
	window->set_non_modal();
}

void flSetModal(Fl_AWindow*window)
{
	window->set_modal();
}

void flBegin(Fl_Group*group)
{
	group->begin();
}

void flEnd(Fl_Group*group)
{
	group->end();
}

void flAddToGroup(Fl_Group*group,Fl_Widget*child)
{
	if(group) group->add(child);
}

void flRemoveFromGroup(Fl_Group*group,Fl_Widget*child)
{
	if(group) group->remove(child);
}

void flSetInputChoice(Fl_Input_Choice *input_choice, int value){
	input_choice->value(value);
}

void* flGetInputChoiceTextWidget(Fl_Input_Choice *input_choice){
	return input_choice->input();
}

void* flGetInputChoiceMenuWidget(Fl_Input_Choice *input_choice){
	return input_choice->menubutton();
}

void flSetChoice(Fl_Choice *choice,int value) {
	choice->value(value);
}

int flGetChoice(Fl_Choice* choice) {
	return choice->value();
}


void flSetButton(Fl_Button*button,bool value)
{
	button->value(value);
}

int flGetButton(Fl_Button*button)
{
	return button->value();
}

void flSetButtonKey(Fl_Button*button,int key)
{
	button->shortcut(key);
}

Fl_RGB_Image *flImage(const unsigned char *pix,int w,int h,int d,int span)
{
	return new Fl_RGB_Image(pix,w,h,d,span);
}

void flSetImage(Fl_Widget *widget,Fl_RGB_Image *image)
{
	Fl_Image*	copy;
	if(widget->image()) delete widget->image();
	if(widget->deimage()) delete widget->deimage();
	if(image){
		widget->image(image->copy());
		copy = image->copy();
		copy->inactive();
		widget->deimage(copy);
	} else {
		widget->image(0);widget->deimage(0);
	}
}

void flFreeImage( Fl_Image *image )
{
	delete image;
}

void flSetPanelImage(Fl_Panel *panel,Fl_RGB_Image *image,int flags)
{
	panel->setimage(image,flags);
}

void flSetPanelColor(Fl_Panel *panel,int r,int g,int b)
{
	panel->setcolor(fl_rgb_color(r,g,b));
}

void flSetPanelActive(Fl_Panel *panel,int yesno)
{
	panel->setactive(yesno);
}

void flSetPanelEnabled(Fl_Panel *panel,int yesno)
{
	panel->setenabled(yesno);
}

void flSetSliderType(Fl_Slider *slider,int type)
{
	slider->type(type);
}

double flSliderValue(Fl_Slider *slider)
{
	return slider->value();
}

void flSetSliderValue(Fl_Slider *slider,double value)
{
	slider->value(value);
}

void flSetSliderRange(Fl_Slider *slider,double low,double hi)
{
	slider->bounds(low,hi);
}

int flScrollbarValue(Fl_Scrollbar *scrollbar)
{
	return scrollbar->value();
}

void flSetScrollbarValue(Fl_Scrollbar *scrollbar,int value,int visible,int top,int total)
{
	scrollbar->value(value,visible,top,total);
}

void flSetInput(Fl_Input*input,char*value)
{
	input->value(value);
	input->position(0,strlen(value));
}

const char *flGetInput(Fl_Input*input)
{
	return input->value();
}

void flActivateInput(Fl_Input*input)
{
	input->position(input->size(),0);
}

void flSetInputFont(Fl_Input*input,Fl_Font s)
{
	input->labelfont(s);
}

void flSetInputSize(Fl_Input*input,Fl_Fontsize s)
{
	input->labelsize(s);
}

void flSetSpinnerMin(Fl_Spinner* spinner, double min)
{
	spinner->minimum(min);
}
void flSetSpinnerMax(Fl_Spinner* spinner, double max)
{
	spinner->maximum(max);
}
void flSetSpinnerValue(Fl_Spinner* spinner, double value)
{
	spinner->value(value);
}
double flSpinnerValue(Fl_Spinner* spinner)
{
	return spinner->value();
}

void flClearBrowser(Fl_Browser*browse)
{
	browse->clear();
}

void flAddBrowser(Fl_Browser*browse,const char *label,void *object, Fl_Image* icon)
{
	browse->add(label,object);
	browse->icon(browse->size(), icon);
}

void flInsertBrowser(Fl_Browser*browse,int index,const char *label,void *object, Fl_Image* icon)
{
	browse->insert(index,label,object);
	browse->icon(index,icon);
}

void flShowBrowser(Fl_Browser*browse,int line,int show)
{
	if (show)
		browse->show(line);	
	else
		browse->hide(line);
}

void flSelectBrowser(Fl_Hold_Browser*browse,int line)
{
	browse->deselect();
	if (line) browse->select(line);	
}

void flMultiBrowserSelect(Fl_Multi_Browser *browse,int line,int select)
{
	if(select) browse->select(line); else browse->deselect(line);
}

int flMultiBrowserSelected(Fl_Multi_Browser *browse,int line)
{
	return browse->selected(line);
}

int flBrowserValue(Fl_Hold_Browser *browse)
{
	return browse->value();
}

void *flBrowserData(Fl_Hold_Browser *browse,int line)
{
	return browse->data(line);
}

const char *flBrowserItem(Fl_Hold_Browser *browse,int line)
{
	return browse->text(line);
}

void flSetBrowserItem(Fl_Hold_Browser *browse,int line,char *text,void *object, Fl_Image* icon)
{
	browse->text(line,text);
	browse->data((int)object);
	browse->icon(line,icon);
}

void flRemoveBrowserItem(Fl_Hold_Browser *browse,int line)
{
	browse->remove(line);
}

void flSetBrowserTextColor(Fl_Hold_Browser *browse,int r,int g,int b)
{
	browse->textcolor(fl_rgb_color(r,g,b));
}

void flSetBrowserTextFont(Fl_Hold_Browser *browse,Fl_Font s)
{
	browse->textfont(s);
}

void flSetBrowserTextSize(Fl_Hold_Browser *browse,Fl_Fontsize s)
{
	browse->textsize(s);
}

int flBrowserCount(Fl_Hold_Browser *browse)
{
	return browse->size();
}

void flSelectTab(Fl_Tabs *tab,Fl_Widget *widget)
{
	tab->value(widget);
}

int flGetTabPanel(Fl_Tabs *tab)
{
	return (int)tab->value();
}

void *flGetTabPanelForEvent(Fl_ATabs *tab)
{
	return tab->which(Fl::event_x(),Fl::event_y());
}

void flSetText(Fl_Text_Display *textdisplay,char *text)
{
	Fl_Text_Buffer *buff;
	buff=textdisplay->buffer();
	buff->remove(1,buff->length());
	buff->append(text);	
}

void flSetEditTextColor(Fl_Text_Display *textdisplay,int r,int g,int b)
{
	textdisplay->textcolor(fl_rgb_color(r,g,b));
	textdisplay->cursor_color(fl_rgb_color(r,g,b));
}

void flRedrawText(Fl_Text_Display *textdisplay,int start,int count)
{
	textdisplay->redisplay_range(start,start+count);
}

void flAddText(Fl_Text_Display *textdisplay,char *text)
{
	Fl_Text_Buffer *buff;
	buff=textdisplay->buffer();
	buff->append(text);	
//	edit->show_insert_position();
}

char *flGetText(Fl_Text_Display *textdisplay,int start,int count)
{
	Fl_Text_Buffer *buff;
	buff=textdisplay->buffer();
	if (count<0) count=buff->length()-start;
	return buff->text_range(start,start+count);	
}

int flLinePos(Fl_Text_Display *textdisplay,int line)
{
	Fl_Text_Buffer 	*buff;
	buff=textdisplay->buffer();
	return buff->skip_lines(0,line);	
}

int flLineCount(Fl_Text_Display *textdisplay,int pos)
{
	Fl_Text_Buffer 	*buff;
	buff=textdisplay->buffer();
	return buff->count_lines(0,pos);	
}

int flLineStart(Fl_Text_Display *textdisplay,int pos)
{
	Fl_Text_Buffer 	*buff;
	buff=textdisplay->buffer();
	return buff->line_start(pos);	
}

int flTextLength(Fl_Text_Display *textdisplay)
{
	Fl_Text_Buffer *buff;
	buff=textdisplay->buffer();
	return buff->length();
}

void flCharPosXY(Fl_Text_Display *textdisplay, int charpos, int *x, int *y)
{
	((MaxGUITextArea< Fl_Text_Display >*)textdisplay)->pos_to_xy(charpos,x,y);
}

void flSetWrapMode(Fl_Text_Display *textdisplay, int mode, int col)
{
	textdisplay->wrap_mode(mode,col);
}

void flReplaceText(Fl_Text_Display *textdisplay,int start,int count,char *text)
{
	Fl_Text_Buffer 	*buff;
	buff=textdisplay->buffer();
	if (count<0) count=buff->length()-start;
	buff->replace(start,start+count,text);
}

void flSelectText(Fl_Text_Display *textdisplay,int start,int count)
{
	Fl_Text_Buffer *buff;
	buff=textdisplay->buffer();
	if (count<0) count=buff->length()-start;
	buff->select(start,start+count);
	textdisplay->insert_position(start+count);
}

void flShowPosition(Fl_Text_Display *textdisplay)
{
	textdisplay->show_insert_position();
}

void flSetTextCallback(Fl_Text_Display *textdisplay,void(*callback)(int,int,int,int,const char*,void*),void *user)
{
	Fl_Text_Buffer *buff;
	buff=textdisplay->buffer();
	buff->add_modify_callback(callback,user);
	textdisplay->when(FL_WHEN_NOT_CHANGED|FL_WHEN_CHANGED|FL_WHEN_ENTER_KEY_ALWAYS|FL_WHEN_RELEASE);
}

int flGetCursorPos(Fl_Text_Display *textdisplay)
{
	int start,endpos;
	Fl_Text_Buffer *buff;
	buff=textdisplay->buffer();
	if (buff->selection_position(&start,&endpos)){
		if (endpos>start) return start;	
	}
	return textdisplay->insert_position();
}

int flGetSelectionLen(Fl_Text_Display *textdisplay)
{
	int start,endpos;
	Fl_Text_Buffer *buff;
	buff=textdisplay->buffer();
	if (buff->selection_position(&start,&endpos)){
		return endpos-start;
	}
	return 0;
}

void flSetTextTabs(Fl_Text_Display *textdisplay,int tabs)
{
	Fl_Text_Buffer *buff;
	buff=textdisplay->buffer();
	buff->tab_distance(tabs);
}

void flActivateText(Fl_Text_Display *textdisplay)
{
	textdisplay->show_cursor(1);
}

void flCutText(Fl_Text_Editor *editor)
{
	Fl_Text_Editor::kf_cut(0,editor);
}

void flCopyText(Fl_Text_Editor *editor)
{
	Fl_Text_Editor::kf_copy(0,editor);
}

void flPasteText(Fl_Text_Editor *editor)
{
	Fl_Text_Editor::kf_paste(0,editor);
}

typedef Fl_Text_Display::Style_Table_Entry style;

#define FLSTYLE_TABLELENGTH 128

struct flStyle
{
	flStyle			*next;
	Fl_Text_Display	*owner;
	Fl_Text_Buffer	*buffer;
	int				count;
	style			table[128];
	flStyle			*prev;
};

static flStyle *stylelist = NULL;

flStyle *GetStyle(Fl_Text_Display *e)
{
	flStyle	*s;
	for (s=stylelist;s;s=s->next)
	{
		if (s->owner==e) return s;
	}
	if (!s)
	{
		s=new flStyle;
		if(stylelist) stylelist->prev=s;
		s->next=stylelist;
		stylelist=s;
		s->prev = NULL;
		s->owner=e;
		s->buffer=new Fl_Text_Buffer;
		memset(s->table,0,sizeof(s->table));
		s->count=0;
		e->highlight_data(s->buffer,s->table,FLSTYLE_TABLELENGTH,'A',0,0);	//stylecallback,s);
	}
	return s;
}

void* flFreeTextDisplay(Fl_Text_Display *textdisplay)
{
	flStyle	*s;
	Fl_Text_Buffer* buff;
	
	for (s=stylelist;s;s=s->next)
	{
		if (s->owner==textdisplay){
			if(s->prev){
				s->prev->next = s->next;
				if(s->next) s->next->prev = s->prev;
			} else {
				stylelist = s->next;
				stylelist->prev = NULL;
			}
			break;
		}
	}
	
	if (s){
		delete s->buffer;
		delete s;
	}
	
	return textdisplay->buffer();
}

void flSetTextFont(Fl_Text_Display *textdisplay,Fl_Font s)
{
	flStyle		*style;
	int			i;
	textdisplay->textfont(s);
	style=GetStyle(textdisplay);
	for (i=0;i<FLSTYLE_TABLELENGTH;i++)
	{
		style->table[i].font=(Fl_Font)s;
	}
}

void flSetTextSize(Fl_Text_Display *textdisplay,Fl_Fontsize s)
{
	flStyle		*style;
	int			i;
	textdisplay->textsize(s);
	style=GetStyle(textdisplay);
	for (i=0;i<FLSTYLE_TABLELENGTH;i++)
	{
		style->table[i].size=s;
	}
}

int flGetTextStyleChar(Fl_Text_Display *textdisplay,int r,int g,int b,Fl_Font font,Fl_Fontsize size)
{
	flStyle		*s;
	style		*e;
	int			i;
	Fl_Color	rgb;
	
	s=GetStyle(textdisplay);
	rgb=fl_rgb_color(r,g,b);
	for (i=0;i<s->count;i++)
	{
		e=&s->table[i];
		if (e->color==rgb && e->size==size && e->font==font) return 'A'+i;
	}
	if (s->count==FLSTYLE_TABLELENGTH) return 0;
	e=&s->table[s->count];
	e->color=rgb;
	e->font=(Fl_Font)font;
	e->size=size;
	return 'A'+s->count++;
}

void flSetTextStyle(Fl_Text_Display *textdisplay,char *text)
{
	Fl_Text_Buffer	*buff;
	flStyle			*s;	
	s=GetStyle(textdisplay);
	buff=s->buffer;
	buff->remove(0,buff->length());
	buff->append(text);	
}

void flAddTextStyle(Fl_Text_Display *textdisplay,char *text)
{
	Fl_Text_Buffer	*buff;
	flStyle			*s;	
	s=GetStyle(textdisplay);
	buff=s->buffer;
	buff->append(text);	
}

void flReplaceTextStyle(Fl_Text_Display *textdisplay,int start,int count,char *text)
{
	Fl_Text_Buffer	*buff;
	flStyle			*s;	
	s=GetStyle(textdisplay);
	buff=s->buffer;
	if (count<0) count=buff->length()-start;	
	buff->replace(start,start+count,text);
}

void flInsertTextStyle(Fl_Text_Display *textdisplay,int start,char *text)
{
	Fl_Text_Buffer	*buff;
	flStyle			*s;	
	s=GetStyle(textdisplay);
	buff=s->buffer;
	if (buff) buff->insert(start,text);
}

void flDeleteTextStyle(Fl_Text_Display *textdisplay,int start,int count)
{
	Fl_Text_Buffer	*buff;
	flStyle			*s;	
	s=GetStyle(textdisplay);
	buff=s->buffer;
	if (buff)
	{
		if (count<0) count=buff->length()-start;
		buff->remove(start,count);
	}
}

void flSetView(Fl_Help_View *view, const char *html)
{
 view->value(html);
}

void flSeekView(Fl_Help_View *view, const char *anchor)
{
 view->topline(anchor);
}

void flRedirectView(Fl_Help_View *view, char *url)
{
 redirect_url=stringcopy(url); // Seb was here, not freed by Fl_Help_View
}

void flSetLineView(Fl_Help_View *view, int line)
{
 view->topline(line);
}

int flGetLineView(Fl_Help_View *view)
{
 return view->gettopline();
}

void flSetPathView(Fl_Help_View *view, const char *path)
{
 view->filepath(path);
}

char *flGetPathView(Fl_Help_View *view)
{
 return view->filepath();
}

int flIsLinkView(Fl_Help_View *view)
{
 return view->fileislink();
}

void flSetStyleView(Fl_Help_View *view, int flag)
{
 view->setstyle(flag);
}

void flSetProgress(Fl_Progress *progbar,float val)
{
	progbar->value(val);
}

void (*menucallback)(Fl_Widget*,void*);

void *flCreateMenu(int n,void (*callback)(Fl_Widget*,void*))
{
	menucallback=callback;
	return calloc(n,sizeof(Fl_Menu_Item));
}

void flSetMenuItem(Fl_Menu_Item* menu,int item,char *name,int shortcut,void *user,int flags, Fl_Font fonthandle, Fl_Fontsize fontsize)
{
	if((item<0) || (item>=menu->size())) return;
	Fl_Menu_Item *p=&menu[item];
	p->text=stringcopy(name);
	p->shortcut_=shortcut;
	p->callback_=menucallback;
	p->user_data_=user;
	p->flags=flags;
	p->labeltype_=0;
	p->labelfont_=fonthandle;
	p->labelsize_=fontsize;
	p->labelcolor_=0;
}

void *flPopupMenu(Fl_Menu_Item *menuitem,void *n)
{
	const Fl_Menu_Item *result;
	result=menuitem->popup( Fl::event_x(),Fl::event_y() );
	if (result) return result->user_data_;
	return n;
}

void flSetMenu(Fl_Menu_ *menu,void *stack)
{
	menu->copy((Fl_Menu_Item *)stack);
	free((Fl_Menu_Item*)stack);
}

void* fluRootNode( Flu_Tree_Browser* tree ){
	return (void*) tree->get_root();
}
void* fluSelectedNode( Flu_Tree_Browser* tree, int index ){
	return (void*) tree->get_selected( index );
}
void* fluCallbackNode( Flu_Tree_Browser* tree ){
	return (void*) tree->callback_node();
}
int fluCallbackReason( Flu_Tree_Browser* tree ){
	return tree->callback_reason();
}
void* fluInsertNode( Flu_Tree_Browser::Node* parent, int pos, const char* text ){
	return (void*) parent->insert( text, pos );
}
void* fluAddNode( Flu_Tree_Browser::Node* parent, const char* text ){
	return (void*) parent->add( text );
}
void fluRemoveNode( Flu_Tree_Browser* tree, Flu_Tree_Browser::Node* node ){
	tree->remove( node );
}
void fluSetNode( Flu_Tree_Browser::Node* node, const char* text, Fl_RGB_Image* iconimage ){
	node->label( text );node->leaf_icon( iconimage );node->branch_icon( iconimage );
}
void fluSetNodeUserData( Flu_Tree_Browser::Node* node, void* user_data ){
	node->user_data( user_data );
}
void* fluNodeUserData( Flu_Tree_Browser::Node* node ){
	return node->user_data();
}
void fluExpandNode( Flu_Tree_Browser::Node* node, int collapse ){
	node->open( (collapse ? false:true) );
}
void fluSelectNode( Flu_Tree_Browser::Node* node ){
	node->select_only();
}
