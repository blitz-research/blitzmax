// $Id: Flu_Choice_Group.cpp,v 1.18 2004/06/17 14:16:42 jbryan Exp $

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



#include "FLU/Flu_Choice_Group.h"
#include <stdlib.h>

#define MAX( x, y ) ( (x)>(y) ? (x) : (y) )
#define MIN( x, y ) ( (x)<(y) ? (x) : (y) )

Flu_Choice_Group :: Flu_Choice_Group( int x, int y, int w, int h, const char *l )
  : Fl_Group( x, y, w, h )
{
  selected = NULL;
  choice = new Fl_Choice( 0, 0, 0, 0 );
  choice->callback( _choiceCB, this );
  box( FL_EMBOSSED_BOX );
  align( FL_ALIGN_LEFT | FL_ALIGN_INSIDE );
}

void Flu_Choice_Group :: choiceCB()
{
  value( choice->value() );
  do_callback();
}

int Flu_Choice_Group :: value()
{
  if( children() == 1 )
    return -1;

  for( int i = 1; i < children(); i++ )
    if( child(i) == selected )
      return i-1;

  return -1;
}

void Flu_Choice_Group :: value( int v )
{
  v++;
  if( v >= 1 && v < children() )
    value( child(v) );
}

int Flu_Choice_Group :: value( Fl_Widget *newvalue )
{
  int ret = -1;
  selected = NULL;
  choice->clear();
  for( int i = 1; i < children(); i++ )
    {
      choice->add( child(i)->label() );
      child(i)->labeltype( FL_NO_LABEL );
      if( child(i) == newvalue )
	{
	  ret = i-1;
	  child(i)->show();
	  choice->value( ret );
	  selected = child(i);
	}
      else
	child(i)->hide();
      child(i)->redraw();
    }

  redraw();
  if( parent() )
    parent()->redraw();

  return ret;
}

void Flu_Choice_Group :: draw()
{
  int i;

  // make sure the selected child is still a child
  bool found = false;
  for( i = 1; i < children(); i++ )
    if( child(i) == selected )
      {
	found = true;
	break;
      }
  if( !found )
    selected = NULL;

  if( !selected && children() > 1 )
    value( child(1) );

  int lblW = 0, lblH = 0, X;

  for( i = 1; i < children(); i++ )
    {
      int W = 0, H;
      fl_measure( child(i)->label(), W, H );
      if( W > lblW )
	lblW = W;
      if( H > lblH )
	lblH = H;
    }

  lblW += 26;
  lblH += 6;

  // align the label
  if( align() & FL_ALIGN_LEFT )
    X = 4;
  else if( align() & FL_ALIGN_RIGHT )
    X = w() - lblW - 8;
  else
    X = w()/2 - lblW/2 - 2;

  // draw the main group box
  if( damage() & ~FL_DAMAGE_CHILD )
    fl_draw_box( box(), x(), y()+lblH/2, w(), h()-lblH/2, color() );

  // clip and draw the children
  choice->resize( choice->x(), choice->y(), 0, 0 );
  fl_clip( x()+2, y()+lblH+1, w()-4, h()-lblH-3 );
  draw_children();
  fl_pop_clip();

  // clear behind the button and draw it
  fl_color( color() );
  fl_rectf( x()+X, y(), lblW+4, lblH );
  fl_color( labelcolor() );
  choice->resize( x()+X+2, y(), lblW, lblH );
  draw_child( *choice );
}
