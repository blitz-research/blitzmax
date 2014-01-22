// $Id: Flu_Dual_Slider.cpp,v 1.2 2004/06/11 13:02:56 jbryan Exp $

/***************************************************************
 *                FLU - FLTK Utility Widgets 
 *  Copyright (C) 2002 Ohio Supercomputer Center, Ohio State University
 *
 * This file and its content is protected by a software license.
 * You should have received a copy of this license with this file.
 * If not, please contact the Ohio Supercomputer Center immediately:
 * Attn: Jason Bryan Re: FLU 1224 Kinnear Rd, Columbus, Ohio 43212
 * 
 ***************************************************************/



#include "FLU/Flu_Dual_Slider.h"

Flu_Dual_Slider :: Flu_Dual_Slider( int x, int y, int w, int h, const char *l )
  : Fl_Valuator( x, y, w, h, l )
{
  _grab = 0;
  _overlap = false;
  _lFocus = true;
  _lVal = lowValue = 0.0f;
  _hVal = highValue = 1.0f;
  _lGrabbed = _hGrabbed = false;
  precision(2);
  box( FL_DOWN_BOX );
}

Flu_Dual_Slider :: ~Flu_Dual_Slider()
{
}

int Flu_Dual_Slider :: handle( int event )
{
  switch( event )
    {
    case FL_PUSH:
      if( Fl::visible_focus() ) Fl::focus(this);
      if( Fl::event_inside( _lHandle[0], _lHandle[1], _lHandle[2], _lHandle[3] ) )
	{
	  set_value( lowValue );
	  handle_push();
	  _lGrabbed = true;
	  _lFocus = true;
	  _grabDelta = _horizontal() ?
	    Fl::event_x()-_lHandle[0] :
	    Fl::event_y()-_lHandle[1];
	  redraw();
	  return 1;
	}
      else if( Fl::event_inside( _hHandle[0], _hHandle[1], _hHandle[2], _hHandle[3] ) )
	{
	  set_value( highValue );
	  handle_push();
	  _hGrabbed = true;
	  _lFocus = false;
	  _grabDelta = _horizontal() ?
	    Fl::event_x()-_hHandle[0] :
	    Fl::event_y()-_hHandle[1];
	  redraw();
	  return 1;
	}
     break;

    case FL_DRAG:
      {
	float min = minimum(), max = maximum();
	bool flip = false;
	if( min > max )
	  {
	    min = maximum();
	    max = minimum();
	    flip = true;
	    range( min, max );
	  }
	//int X = x()+Fl::box_dx(box()), Y = y()+Fl::box_dy(box()),
	int W = w()-Fl::box_dw(box()), H = h()-Fl::box_dh(box());
	int s = _horizontal() ? H/2 : W/2;
	int S = _horizontal() ? W : H;
	if( _nice() )
	  s += 4;

	if( _lGrabbed )
	  {
	    int diff = _horizontal() ?
	      (Fl::event_x() - _grabDelta) - x() :
	      (Fl::event_y() - _grabDelta) - y();
	    _lVal = float(diff)/float(S-s-s);
	    if( _lVal < 0.0f ) _lVal = 0.0f;
	    if( _lVal >= _hVal ) _lVal = _hVal;
	    redraw();
	    lowValue = min + _lVal*(max-min);
	    lowValue = round(lowValue);
	    if( lowValue >= highValue )
	      lowValue = _overlap ? highValue : clamp( increment( highValue, -1 ) );
	    lowValue = clamp(lowValue);
	    if( flip )
	      range( max, min );
	    handle_drag( lowValue );
	  }
	else if( _hGrabbed )
	  {
	    int diff = _horizontal() ?
	      (Fl::event_x() - _grabDelta - s) - x() :
	      (Fl::event_y() - _grabDelta - s) - y();
	    _hVal = float(diff)/float(S-s-s);
	    if( _hVal <= _lVal ) _hVal = _lVal;
	    if( _hVal > 1.0f ) _hVal = 1.0f;
	    redraw();
	    highValue = min + _hVal*(max-min);
	    highValue = round(highValue);
	    if( highValue <= lowValue )
	      highValue = _overlap ? lowValue : clamp( increment( lowValue, 1 ) );
	    highValue = clamp(highValue);
	    if( flip )
	      range( max, min );
	    handle_drag( highValue );
	  }
      }
      break;

    case FL_RELEASE:
      _lGrabbed = _hGrabbed = false;
       handle_release();
    break;

    case FL_KEYBOARD:
      switch( Fl::event_key() )
	{
	case FL_Up:
	  if( _horizontal() )
	    _lFocus = !_lFocus;
	  else
	    {
	      int inc = minimum() > maximum() ? 1 : -1;
	      if( _lFocus )
		{
		  set_value( lowValue );
		  lowValue = clamp( increment( lowValue, inc ) );
		  if( lowValue >= highValue )
		    lowValue = _overlap ? highValue : clamp( increment( highValue, inc ) );
		  handle_drag( lowValue );
		  handle_release();
		}
	      else
		{
		  set_value( highValue );
		  highValue = clamp( increment( highValue, inc ) );
		  if( highValue <= lowValue )
		    highValue = _overlap ? lowValue : clamp( increment( lowValue, -inc ) );
		  handle_drag( highValue );
		  handle_release();
		}
	    }
	  redraw();
	  return 1;
	case FL_Down:
	  if( _horizontal() )
	    _lFocus = !_lFocus;
	  else
	    {
	      int inc = minimum() > maximum() ? -1 : 1;
	      if( _lFocus )
		{
		  set_value( lowValue );
		  lowValue = clamp( increment( lowValue, inc ) );
		  if( lowValue >= highValue )
		    lowValue = _overlap ? highValue : clamp( increment( highValue, -inc ) );
		  handle_drag( lowValue );
		  handle_release();
		}
	      else
		{
		  set_value( highValue );
		  highValue = clamp( increment( highValue, inc ) );
		  if( highValue <= lowValue )
		    highValue = _overlap ? lowValue : clamp( increment( lowValue, inc ) );
		  handle_drag( highValue );
		  handle_release();
		}
	    }
	  redraw();
	  return 1;
	case FL_Left:
	  if( _horizontal() )
	    {
	      int inc = minimum() > maximum() ? 1 : -1;
	      if( _lFocus )
		{
		  set_value( lowValue );
		  lowValue = clamp( increment( lowValue, inc ) );
		  if( lowValue >= highValue )
		    lowValue = _overlap ? highValue : clamp( increment( highValue, inc ) );
		  handle_drag( lowValue );
		  handle_release();
		}
	      else
		{
		  set_value( highValue );
		  highValue = clamp( increment( highValue, inc ) );
		  if( highValue <= lowValue )
		    highValue = _overlap ? lowValue : clamp( increment( lowValue, -inc ) );
		  handle_drag( highValue );
		  handle_release();
		}
	    }
	  else
	    _lFocus = !_lFocus;
	  redraw();
	  return 1;
	case FL_Right:
	  if( _horizontal() )
	    {
	      int inc = minimum() > maximum() ? -1 : 1;
	      if( _lFocus )
		{
		  set_value( lowValue );
		  lowValue = clamp( increment( lowValue, inc ) );
		  if( lowValue >= highValue )
		    lowValue = _overlap ? highValue : clamp( increment( highValue, -inc ) );
		  handle_drag( lowValue );
		  handle_release();
		}
	      else
		{
		  set_value( highValue );
		  highValue = clamp( increment( highValue, inc ) );
		  if( highValue <= lowValue )
		    highValue = _overlap ? lowValue : clamp( increment( lowValue, inc ) );
		  handle_drag( highValue );
		  handle_release();
		}
	    }
	  else
	    _lFocus = !_lFocus;
	  redraw();
	  return 1;
	}
      break;

    case FL_FOCUS:
    case FL_UNFOCUS:
      if( Fl::visible_focus() )
	{
	  redraw();
	  return 1;
	}
      else
	return 0;

    case FL_ENTER :
    case FL_LEAVE :
      return 1;
    }
  return Fl_Valuator::handle(event);
}

void Flu_Dual_Slider :: draw()
{
  float min = minimum(), max = maximum();
  if( min > max )
    {
      min = maximum();
      max = minimum();
    }

  float lo = (lowValue - min)/(max-min),
    hi = (highValue - min)/(max-min);

  draw_box();

  int X = x()+Fl::box_dx(box()), Y = y()+Fl::box_dy(box()),
    W = w()-Fl::box_dw(box()), H = h()-Fl::box_dh(box());
  int s = _horizontal() ? h()/2 : w()/2;
  int S = _horizontal() ? W : H;
  if( _nice() )
    s += 4;
  int loOff = _horizontal() ?
    X + int(lo*float(S-s-s)) :
    Y + int(lo*float(S-s-s));
  int hiOff = _horizontal() ?
    X + s + int(hi*float(S-s-s)) :
    Y + s + int(hi*float(S-s-s));

  if( _nice() )
    {
      Fl_Color black = active_r() ? FL_FOREGROUND_COLOR : FL_INACTIVE_COLOR;
      if( _horizontal() )
	draw_box( FL_THIN_DOWN_BOX, X+2, Y+H/2-2, W-4, 4, black );
      else
	draw_box( FL_THIN_DOWN_BOX, X+W/2-2, Y+2, 4, H-4, black );
    }

  if( _horizontal() )
    {
      _lHandle[0] = loOff; _lHandle[1] = Y; _lHandle[2] = s; _lHandle[3] = H;
      _hHandle[0] = hiOff; _hHandle[1] = Y; _hHandle[2] = s; _hHandle[3] = H;
      draw_box( FL_UP_BOX, loOff, Y, s, H, FL_GRAY);
      draw_box( FL_UP_BOX, hiOff, Y, s, H, FL_GRAY);
      if( _nice() )
	{
	  draw_box( FL_THIN_DOWN_BOX, loOff+s/2-3, Y+2, 6, H-4, FL_GRAY);
	  draw_box( FL_THIN_DOWN_BOX, hiOff+s/2-3, Y+2, 6, H-4, FL_GRAY);
	}
    }
  else
    {
      _lHandle[0] = X; _lHandle[1] = loOff; _lHandle[2] = W; _lHandle[3] = s;
      _hHandle[0] = X; _hHandle[1] = hiOff; _hHandle[2] = W; _hHandle[3] = s;
      draw_box( FL_UP_BOX, X, loOff, W, s, FL_GRAY);
      draw_box( FL_UP_BOX, X, hiOff, W, s, FL_GRAY);
      if( _nice() )
	{
	  draw_box( FL_THIN_DOWN_BOX, X+2, loOff+s/2-3, W-4, 6, FL_GRAY);
	  draw_box( FL_THIN_DOWN_BOX, X+2, hiOff+s/2-3, W-4, 6, FL_GRAY);
	}
    }

  if( Fl::focus() == this )
    {
      if( _lFocus )
	{
	  if( _horizontal() )
	    draw_focus( FL_UP_BOX, loOff, Y, s, H );
	  else
	    draw_focus( FL_UP_BOX, X, loOff, W, s );
	}
      else
	{
	  if( _horizontal() )
	    draw_focus( FL_UP_BOX, hiOff, Y, s, H );
	  else
	    draw_focus( FL_UP_BOX, X, hiOff, W, s );
	}
    }
}
