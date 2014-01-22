// FLTK C++ Templates for MaxGUI
// Sebastian Hollington 2009

#include <FL/Fl.H>
#include <FL/Fl_Widget.H>

// Globals (from fltkglue.cpp)

extern int eventid;
extern int(*mousehandler)(Fl_Widget*,void*);
extern int(*keyhandler)(Fl_Widget*,void*);
extern int(*textfilter)(void*);

extern "C" int (flEventButton)();

// Wrap around an FLTK widget if you want widget to call mouse/keyhandlers.

template <class FLWidget> class MaxGUIEventListener : public FLWidget
{	
public:
	MaxGUIEventListener (int x, int y, int w, int h, char *title = 0) : FLWidget(x,y,w,h,title) {};
	int handle(int event){
		
		int res = FLWidget::handle(event);
		int active = this->active_r();
		
		if((!active) || (event==FL_FOCUS)) return active;
		
		Fl_Widget* blwmouse = Fl::belowmouse();
		Fl_Widget* focus = Fl::focus();
		
		// If a non-MaxGUI widget has snatched mouse tracking, snatch it back.
		if(!(blwmouse && blwmouse->user_data())){
			blwmouse = this;
			Fl::belowmouse(this);
		}
		
		// If a non-MaxGUI widget has keyboard focus, pretend we have it.
		if(!(focus && focus->user_data())) focus = this;
		
		eventid = event;
		
		switch(event){
		case FL_PUSH:
		case FL_ENTER:
		case FL_MOVE:
		case FL_LEAVE:
		case FL_MOUSEWHEEL:
		case FL_RELEASE:
		case FL_DRAG:
			// Only call if child gadget has handled event.
			if((blwmouse==this) || !res) mousehandler( this, this->user_data() );
			res = 1;
			break;
		case FL_KEYUP:
			// Return 1 from FL_KEYUP to avoid multiple events firing.
			res = 1;
		case FL_KEYDOWN:
			// Leave default return value for FL_KEYDOWN to allow tab/arrow key focus changing.
			if(focus==this) keyhandler( focus, focus->user_data() );
			break;
		default:
			res = 0;
		}
		eventid = 0;
		
		return res;
	}

};

// Wrap around an FLTK widget if you want keys to be filtered before handling using textfilter callback.

template <class FLWidget> class MaxGUIKeyFilter : public FLWidget
{	
public:
	MaxGUIKeyFilter (int x, int y, int w, int h, char *title = 0) : FLWidget(x,y,w,h,title) {};
	int handle(int event)
	{
		int should_callback = 0;
		switch (event){
		case FL_KEYDOWN:
			if (textfilter(this->user_data())==0) return 1;
			should_callback = 1;
			break;
		}
		int res = FLWidget::handle(event);
		if (should_callback) FLWidget::do_callback();
		return res;
	}

};

// Wrap around any text display widgets to make them behave more like TextArea's on other platforms

template <class FLTextDisplay> class MaxGUITextArea : public FLTextDisplay
{
public:
	MaxGUITextArea(int x,int y,int w,int h,const char *title=0):FLTextDisplay(x,y,w,h,title){}
	
	void pos_to_xy(int pos, int *x, int *y)
	{
		FLTextDisplay::position_to_xy(pos,x,y);
	}
	
	int handle(int event)
	{
		int should_callback = 0, should_ignore = 0, res = 0;
		
		switch (event)
		{
		case FL_PUSH:
		case FL_RELEASE:
			should_callback=1;
			if(flEventButton()!=FL_LEFT_MOUSE){should_ignore=1;res=1;}
			break;
		case FL_UNFOCUS:
			should_callback=1;
			break;
		}
		if (!should_ignore) res=FLTextDisplay::handle(event);
		if (should_callback) FLTextDisplay::do_callback();
		return res;
	}
};

// Wrap around an FLTK widget if you want widget background to lighten when hovered over.

template <class FLWidget> class MaxGUIHoverEffect : public FLWidget
{
private:
	Fl_Color defaultColor, selectionColor;
public:
	MaxGUIHoverEffect (int x, int y, int w, int h, char *title = 0):FLWidget(x,y,w,h,title)
	{
		defaultColor = FLWidget::color();
		selectionColor = FLWidget::selection_color();
	}
	
	Fl_Color color() {return defaultColor;}
	Fl_Color selection_color() {return selectionColor;}
	
	int handle(int event)
	{
		if( !this->active_r() )
			return FLWidget::handle( event );
		
		switch (event)
		{
		case FL_ENTER:
			
			defaultColor = FLWidget::color();
			FLWidget::color( fl_lighter( defaultColor ) );
			
			selectionColor = FLWidget::selection_color();
			FLWidget::selection_color( fl_lighter( selectionColor ) );
			
			this->redraw();
			return 1;
			break;
			
		case FL_LEAVE:
			
			FLWidget::color( defaultColor );
			FLWidget::selection_color( selectionColor );
			
			this->redraw();
			return 1;
			break;
			
		}
		return FLWidget::handle(event);
	}
};
