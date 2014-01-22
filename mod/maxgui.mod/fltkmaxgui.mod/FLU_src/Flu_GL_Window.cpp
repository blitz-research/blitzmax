// $Id: Flu_GL_Window.cpp,v 1.21 2004/07/27 19:34:29 jbryan Exp $

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



#include "FLU/Flu_GL_Window.h"

Flu_GL_Window::AllInitProto Flu_GL_Window::allInitCB = 0;
void* Flu_GL_Window::allInitCBD = 0;

Flu_GL_Window :: Flu_GL_Window( int x, int y, int w, int h, const char *label )
  : Fl_Gl_Window( x, y, w, h, label )
{
  cartesianInput( true );
  _drawCB = NULL; _drawCBD = NULL;
  _resizeCB = NULL; _resizeCBD = NULL;
  _initCB = NULL; _initCBD = NULL;
  _mouseWheelCB = NULL; _mouseWheelCBD = NULL;
  _mouseDownCB = NULL; _mouseDownCBD = NULL;
  _mouseUpCB = NULL; _mouseUpCBD = NULL;
  _mouseDragCB = NULL; _mouseDragCBD = NULL;
  _mouseMoveCB = NULL; _mouseMoveCBD = NULL;
  _keyboardCB = NULL; _keyboardCBD = NULL;
  _enterCB = NULL; _enterCBD = NULL;
  _exitCB = NULL; _exitCBD = NULL;
  _firstDraw = true;
  end();
}

Flu_GL_Window :: Flu_GL_Window( int w, int h, const char *label )
  : Fl_Gl_Window( w, h, label )
{
  cartesianInput( true );
  _drawCB = NULL; _drawCBD = NULL;
  _resizeCB = NULL; _resizeCBD = NULL;
  _initCB = NULL; _initCBD = NULL;
  _mouseWheelCB = NULL; _mouseWheelCBD = NULL;
  _mouseDownCB = NULL; _mouseDownCBD = NULL;
  _mouseUpCB = NULL; _mouseUpCBD = NULL;
  _mouseDragCB = NULL; _mouseDragCBD = NULL;
  _mouseMoveCB = NULL; _mouseMoveCBD = NULL;
  _keyboardCB = NULL; _keyboardCBD = NULL;
  _enterCB = NULL; _enterCBD = NULL;
  _exitCB = NULL; _exitCBD = NULL;
  _firstDraw = true;
  end();
}

Flu_GL_Window :: ~Flu_GL_Window()
{
}

void Flu_GL_Window :: redraw()
{
  Fl_Gl_Window::redraw();
}

int Flu_GL_Window :: handle( int event )
{
  if( !context() )
    _firstDraw = true;

  if( !context() || !visible() )
    return Fl_Gl_Window::handle( event );

  int x = Fl::event_x(), y = Fl::event_y();

  if( _cartesian )
    y = h() - 1 - y;

  switch( event )
    {
    case FL_MOVE:
      {
	// make sure the GL context is current in case the callback needs it
	Fl_Group *current = Fl_Group::current();
	make_current();
	if( _mouseMoveCB )
	  _mouseMoveCB( x, y, _mouseMoveCBD );
	Fl_Group::current( current );
	return 1;
      }

    case FL_DRAG:
      {
	// make sure the GL context is current in case the callback needs it
	Fl_Group *current = Fl_Group::current();
	make_current();
	if( _mouseDragCB )
	  _mouseDragCB( x, y, _mouseDragCBD );
	Fl_Group::current( current );
	return 1;
      }

    case FL_PUSH:
      {
	// make sure the GL context is current in case the callback needs it
	Fl_Group *current = Fl_Group::current();
	make_current();
	if( _mouseDownCB )
	  _mouseDownCB( Fl::event_button(), x, y, _mouseDownCBD );
	Fl_Group::current( current );
	return 1;
      }

    case FL_RELEASE:
      {
	// make sure the GL context is current in case the callback needs it
	Fl_Group *current = Fl_Group::current();
	make_current();
	if( _mouseUpCB )
	  _mouseUpCB( Fl::event_button(), x, y, _mouseUpCBD );
	Fl_Group::current( current );
	return 1;
      }

    case FL_MOUSEWHEEL:
      {
	// make sure the GL context is current in case the callback needs it
	Fl_Group *current = Fl_Group::current();
	make_current();
	if( _mouseWheelCB )
	  _mouseWheelCB( Fl::event_dx(), Fl::event_dy(), x, y, _mouseWheelCBD );
	Fl_Group::current( current );
	return 1;
      }

    case FL_FOCUS :
    case FL_UNFOCUS :
      return 1;

    case FL_ENTER:
      {
	// make sure the GL context is current in case the callback needs it
	Fl_Group *current = Fl_Group::current();
	make_current();
	if( _enterCB )
	  _enterCB( _enterCBD );
	Fl_Group::current( current );
	return 1;
      }

    case FL_LEAVE:
      {
	// make sure the GL context is current in case the callback needs it
	Fl_Group *current = Fl_Group::current();
	make_current();
	if( _exitCB )
	  _exitCB( _exitCBD );
	Fl_Group::current( current );
	return 1;
      }

    case FL_KEYUP:
      // make sure the GL context is current in case the callback needs it
      //make_current();
      if( _keyboardCB )
	_keyboardCB( Fl::event_key(), x, y, _keyboardCBD );
      return Fl_Gl_Window::handle( event );

    default:
      // pass other events to the base class...
      return Fl_Gl_Window::handle( event );
    }
}

void Flu_GL_Window :: draw()
{
  if( !context() )
    return;

  if( _firstDraw )
    {
      _firstDraw = false;
      if( allInitCB )
	allInitCB( allInitCBD );
      if( _initCB )
	_initCB( _initCBD );
    }
  if( !valid() )
    {
      if( _resizeCB )
	_resizeCB( w(), h(), _resizeCBD );
    }
  if( _drawCB )
    _drawCB( _drawCBD );
}
