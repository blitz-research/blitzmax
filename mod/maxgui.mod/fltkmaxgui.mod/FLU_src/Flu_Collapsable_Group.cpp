// $Id: Flu_Collapsable_Group.cpp,v 1.8 2004/06/17 14:16:42 jbryan Exp $

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
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include <FL/Fl_Window.H>
#include "FLU/Flu_Collapsable_Group.h"

Flu_Collapsable_Group :: Flu_Collapsable_Group( int x, int y, int w, int h, const char *l )
  : Fl_Group( x, y, w, h ), button( x, y, w, 20 ), group( x, y+20, w, h-20 )
{
  _originalHeight = h;
  _changing = false;
  _collapseTime = 0.25f;
  _fps = 60.0f;
  _fit = false;
  _open = true;
  _currentHeight = h;
  label( l );

  box( FL_EMBOSSED_BOX );
  align( FL_ALIGN_LEFT );

  // the group label is actually used by the button. so since we don't want this group's label
  // to show up, draw it under everything
  Fl_Group::align( FL_ALIGN_CENTER );

  Fl_Group::add( &button );
  button.callback( _collapseCB, this );
  button.align( FL_ALIGN_CENTER | FL_ALIGN_CLIP );

  Fl_Group::add( &group );
  Fl_Group::resizable( group );
  Fl_Group::end();
  group.begin();
}

void Flu_Collapsable_Group :: resize( int x, int y, int w, int h )
{
  // skip over our parent's resize since we don't want it to mess with the children
  Fl_Widget::resize( x, y, w, h );
  button.resize( x, y, w, 20 );
  group.resize( x, y+20, w, h-20 );
}

void Flu_Collapsable_Group :: open( bool o )
{
  _open = o;

  do_callback();

  if( !_changing )
    {
      _oldResizable = group.resizable();
      group.resizable( NULL );
    }

  if( _open )
    {
      group.show();
      _newHeight = _originalHeight;
    }
  else
    {
      _newHeight = button.h()+5;
      if( !_changing )
	_originalHeight = h();
    }

  _currentHeight = float(h());
  if( !_changing )
    {
      _timeout = 1.0f / _fps;
      _deltaHeight = ( float(_newHeight) - _currentHeight ) / ( _collapseTime * _fps );
      _changing = true;
      Fl::add_timeout( _timeout, _updateCB, this );
    }
}

void Flu_Collapsable_Group :: updateCB()
{
  // update the height
  _currentHeight += _deltaHeight;

  // see if we're done with the animation
  if( ( _deltaHeight == 0.0f ) || 
      ( ( _deltaHeight > 0.0f ) && ( _currentHeight >= float(_newHeight) ) ) ||
      ( ( _deltaHeight < 0.0f ) && ( _currentHeight <= float(_newHeight) ) ) )
    {
      resize( x(), y(), w(), _newHeight );

      if( !_open )
	group.hide();
      _changing = false;
      group.resizable( _oldResizable );
    }
  else
    {
      resize( x(), y(), w(), int(_currentHeight) );
      Fl::repeat_timeout( _timeout, _updateCB, this );
    }

  // redraw the group
  redraw();
  group.redraw();

  // wierd hack to get parent to redraw everything (necessary since our size has changed)
  if( parent() )
    parent()->init_sizes();
  if( this->window() )
    this->window()->redraw();
}

void Flu_Collapsable_Group :: draw()
{
  int X;

  FluSimpleString l = open() ? "- " : "+ ";
  l += label();
  button.label( l.c_str() );

  // force fit the button if necessary
  if( _fit )
    button.size( w()-12, button.labelsize()+6 );
  else
    {
      // otherwise make it as big as its label
      int W = 0, H = 0;
      fl_font( button.labelfont(), button.labelsize() );
      fl_measure( button.label(), W, H );
      button.size( W+6, button.h() );
    }

  // align the button
  if( align() & FL_ALIGN_LEFT )
    X = 4;
  else if( align() & FL_ALIGN_RIGHT )
    X = w() - button.w() - 8;
  else
    X = w()/2 - button.w()/2 - 2;

  // draw the main group box
  if( damage() & ~FL_DAMAGE_CHILD )
    fl_draw_box( box(), x(), y()+button.h()/2, w(), h()-button.h()/2, color() );

  // clip and draw the internal group
  fl_clip( x()+2, y()+button.h()+1, w()-4, h()-button.h()-3 );
  if( _changing )
    {
      if( !_open )
	group.resize( x(), y()-_originalHeight+(int)_currentHeight+20, w(), _originalHeight );
      else
	group.resize( x(), y()-_newHeight+(int)_currentHeight+20, w(), _newHeight );
    }
  draw_child( group );
  fl_pop_clip();

  // clear behind the button, resize, and draw
  fl_color( color() );
  fl_rectf( x()+X, y(), button.w()+4, button.h() );
  button.position( x()+X+2, y() );
  draw_child( button );

  button.label( 0 );
}
