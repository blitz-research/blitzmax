// $Id: Flu_Spinner.cpp,v 1.20 2004/10/22 16:17:45 jbryan Exp $

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



#include <stdio.h>
#include <string.h>
#include <FL/Fl.H>
#include <FL/fl_draw.H>
#include <stdlib.h>
#include <FL/math.h>

#include "FLU/Flu_Spinner.h"

#define ABS( x ) ( (x)>0 ? (x) : -(x) )

Flu_Spinner :: NoTabInput :: NoTabInput( Flu_Spinner *s, int x, int y, int w, int h, const char *l )
  : Fl_Input( x, y, w, h, l )
{
  spinner = s;
}

int Flu_Spinner :: NoTabInput :: handle( int event )
{
  switch( event )
    {
    case FL_KEYDOWN:
      {
	switch( Fl::event_key() )
	  {
	  case FL_Tab:
	    redraw();
	    return 0;

	  case FL_Enter:
	  case FL_KP_Enter:
	    Fl_Input::handle( event );
	    spinner->value( spinner->clamp( atof( value() ) ) );
	    spinner->do_callback();
	    return 1;

	  case FL_Down:
	  case FL_Up:
	    spinner->handle( event );
	    return 1;
	  }
      }
      break;

    case FL_FOCUS:
    case FL_UNFOCUS:
      redraw();
      break;
    }

  return Fl_Input::handle( event );
}

void Flu_Spinner :: NoTabInput :: draw()
{
  if( spinner->active() )
    activate();
  else
    deactivate();

  if( spinner->_dragging )
    {
      if( (spinner->align() & FL_ALIGN_INSIDE) || !spinner->editable() )
	position( size() );
      else
	position( 0, size() );
    }

  Fl_Input::draw();
  if( Fl::focus() == this && ( (spinner->align() & FL_ALIGN_INSIDE) || !spinner->editable() ) )
    draw_focus( box(), x(), y(), w(), h() );
}

Flu_Spinner :: Flu_Spinner( int X, int Y, int W, int H, const char* l )
  : Fl_Valuator( X, Y, W, H, l ), _input( this, X, Y, W, H, 0 )
{
  // we always want the buttons to be square and half the height of the widget
  int wid = W*15/100;
  if( wid < H/2 )
    wid = H/2;

  _wrapRange = false;
  _dragging = false;
  _editable = true;
  _totalTime = 0.0f;
  _initialDelay = 0.5f;
  _repeatTime[0] = 0.1f;
  _repeatTime[1] = 0.02f;
  _rapidDelay = 2.0f;
  _doRepeat = true;
  _pushed = false;
  _valbox[0] = _valbox[1] = FL_UP_BOX;

  box( FL_DOWN_BOX );
  align( FL_ALIGN_LEFT );
  when( FL_WHEN_CHANGED );
  precision( 2 );
  range( 0, 1 );
  value( 0 );

  {
    _input.callback(input_cb, this);
    _input.resize( X, Y, W-wid-1, H );
    _input.color( FL_WHITE, FL_SELECTION_COLOR );
    _input.textfont( FL_HELVETICA );
    _input.textsize(  FL_NORMAL_SIZE );
    _input.textcolor( FL_FOREGROUND_COLOR );
    _input.type( FL_FLOAT_INPUT );
    value_damage();
  }
}

Flu_Spinner::~Flu_Spinner()
{
  Fl::remove_timeout(repeat_callback, this);
}

// taken from Fl_Counter.cxx
void Flu_Spinner :: input_cb( Fl_Widget*, void* v )
{
  Flu_Spinner& t = *(Flu_Spinner*)v;
  if( t.align() & FL_ALIGN_INSIDE )
    return;
  double nv;
  if ((t.step() - floor(t.step()))>0.0 || t.step() == 0.0)
    nv = strtod(t._input.value(), 0);
  else
    nv = strtol(t._input.value(), 0, 0);
  if( nv != t.value() || t._input.when() & FL_WHEN_NOT_CHANGED)
    {
      if( nv < t.minimum() )
	{
	  t.set_value(t.minimum());
	  t.value_damage();
	}
      else if( nv > t.maximum() )
	{
	  t.set_value(t.maximum());
	  t.value_damage();
	}
      else
	t.set_value(nv);

      if( t.when() )
	{
	  t.clear_changed();
	  t.do_callback();
	}
      else
	{
	  t.set_changed();
	}
    }

  t.value_damage();
}

void Flu_Spinner :: resize( int X, int Y, int W, int H )
{
  // we always want the buttons to be square and half the height of the widget
  Fl_Valuator::resize( X, Y, W, H );
}

void Flu_Spinner :: value_damage()
{
  char *buf;
  if( align() & FL_ALIGN_INSIDE )
    {
      int len = strlen(label());
      buf = (char*)malloc( len + 128 );
      sprintf( buf, "%s", label() );
      format( buf + len );
    }
  else
    {
      buf = (char*)malloc( 128 );
      format( buf );
    }
  _input.value(buf);

  if( align() == FL_ALIGN_INSIDE || !_editable )
    _input.position( _input.size() );
  else
    _input.position( 0, _input.size() );

  free( buf );
}

void Flu_Spinner::draw()
{
  int W = w()*15/100;
  if( W < h()/2 )
    W = h()/2;
  int X = x()+w()-W, Y = y();

  // fltk 2.0 behavior
  bool refresh;
  if( step() >= 1.0 )
    {
      refresh = ( _input.type() != FL_INT_INPUT );
      _input.type( FL_INT_INPUT );
    }
  else
    {
      refresh = ( _input.type() != FL_FLOAT_INPUT );
      _input.type( FL_FLOAT_INPUT );
    }
  if( refresh )
    value_damage();

  // draw the up/down arrow buttons
  fl_draw_box( (Fl_Boxtype)_valbox[0], X, Y, W, h()/2, color() );
  fl_draw_box( (Fl_Boxtype)_valbox[1], X, Y+h()/2, W, h()/2, color() );
  fl_color( active_r() ? FL_FOREGROUND_COLOR : fl_inactive(FL_FOREGROUND_COLOR) );
  fl_polygon( X+4, Y+h()/2-4, X+W/2, Y+4, X+W-4, Y+h()/2-4 );
  Y += h()/2;
  fl_polygon( X+4, Y+4, X+W/2, Y+h()/2-4, X+W-4, Y+4 );

  _input.resize( x(), y(), w()-h()/2-1, h() );
  _input.redraw();
}

void Flu_Spinner :: increment_cb()
{
  int oldWhen = when();
  int amt = Fl::event_state( FL_SHIFT | FL_CTRL | FL_ALT ) ? 10 : 1;
  if( _up )
    _setvalue(increment(value(),1*amt));
  else
    _setvalue(increment(value(),-1*amt));
  when( oldWhen );
  _lastValue = value();
}

void Flu_Spinner :: repeat_callback( void* arg )
{
  Flu_Spinner* c = (Flu_Spinner*)arg;
  c->increment_cb();

  float delay = c->_repeatTime[0];
  if( c->_pushed && c->_totalTime >= c->_rapidDelay )
    delay = c->_repeatTime[1];

  c->_totalTime += delay;

  Fl::repeat_timeout( delay, repeat_callback, c );
}

int Flu_Spinner::handle(int event)
{
  int W = w()*15/100;
  if( W < h()/2 )
    W = h()/2;
  int X = x()+w()-W, Y = y();

  if( (align() & FL_ALIGN_INSIDE) || !_editable )
    {
      _input.readonly( true );
      _input.cursor_color( FL_WHITE );
    }
  else
    {
      _input.readonly( false );
      _input.cursor_color( FL_BLACK );
    }

  switch( event )
    {
    case FL_PUSH:
      _dragging = true;
      if (Fl::visible_focus() && handle(FL_FOCUS)) Fl::focus(this);
      _lastValue = value();
      _lastY = Fl::event_y();
      Fl::remove_timeout( repeat_callback, this );
      if( Fl::event_inside( X, Y, W, h()/2 ) ) // up button
	{
	  _pushed = true;
	  _valbox[0] = FL_DOWN_BOX;
	  _up = true;
	}
      if( Fl::event_inside( X, Y+h()/2, W, h()/2 ) ) // down button
	{
	  _pushed = true;
	  _valbox[1] = FL_DOWN_BOX;
	  _up = false;
	}
      if( _pushed )
	{
	  increment_cb();
	  _totalTime = _initialDelay;
	  if( _doRepeat )
	    Fl::add_timeout( _initialDelay, repeat_callback, this);
	  handle_push();
	  take_focus();
	  redraw();
	  return 1;
	}
      break;

    case FL_DRAG:
      {
	// only do the dragging if the last Y differs from the current Y by more than 3 pixels
	if( ABS(_lastY-Fl::event_y()) < 3 )
	  break;
	_dragging = true;
	_pushed = false;
	Fl::remove_timeout( repeat_callback, this );
	int oldWhen = when();
	_setvalue(increment(_lastValue,(_lastY-Fl::event_y())*(Fl::event_state(FL_SHIFT|FL_CTRL|FL_ALT)?10:1)));
	_valbox[0] = _valbox[1] = FL_DOWN_BOX;
	when( oldWhen );
	fl_cursor((Fl_Cursor)22);
	_input.redraw();
	redraw();
      }
      break;

    case FL_RELEASE:
      {
	bool doCB = ( ( when() & FL_WHEN_RELEASE ) || ( when() & FL_WHEN_RELEASE_ALWAYS ) ) &&
	  ( _pushed || ( _valbox[0] == FL_DOWN_BOX ^ _valbox[1] == FL_DOWN_BOX ) );
	_pushed = false;
	_dragging = false;
	Fl::remove_timeout( repeat_callback, this );
	_valbox[0] = _valbox[1] = FL_UP_BOX;
	fl_cursor(FL_CURSOR_DEFAULT);
	redraw();
	handle_release();
	if( doCB )
	  do_callback();
	_input.take_focus();
      }
      break;

    case FL_FOCUS:
    case FL_UNFOCUS:
      redraw();
      _input.take_focus();
      return 0;

    case FL_ENTER:
      if( Fl::event_inside( &_input ) )
	return _input.handle(event);
      else if( active_r() )
	{
	  fl_cursor(FL_CURSOR_DEFAULT);
	  return 1;
	}
      break;

    case FL_LEAVE:
      if( Fl::event_inside( &_input ) )
	return _input.handle(event);
      else if( active_r() )
	{
	  fl_cursor(FL_CURSOR_DEFAULT);
	  return 1;
	}
      break;

    case FL_KEYBOARD:
      switch( Fl::event_key() )
	{
	case FL_Down:
	  {
	    int oldWhen = when(); when( FL_WHEN_CHANGED );
	    _setvalue(increment(value(),-1*(Fl::event_state(FL_SHIFT|FL_CTRL|FL_ALT)?10:1)));
	    when( oldWhen );
	    redraw();
	    return 1;
	  }
	case FL_Up:
	  {
	    int oldWhen = when(); when( FL_WHEN_CHANGED );
	    _setvalue(increment(value(),1*(Fl::event_state(FL_SHIFT|FL_CTRL|FL_ALT)?10:1)));
	    when( oldWhen );
	    redraw();
	    return 1;
	  }
	}
      break;
    }

  return _input.handle(event);
}

void Flu_Spinner :: _setvalue( double v )
{
  if( _wrapRange )
    {
      while( v > maximum() )
	v = minimum() + (v - maximum());
      while( v < minimum() )
	v = maximum() - (minimum() - v);
    }
  else
    {
      v = clamp(v);
    }
  handle_drag(v);
}
