// $Id: Flu_Toggle_Group.cpp,v 1.10 2004/09/16 01:32:25 jbryan Exp $

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



#include "FLU/Flu_Toggle_Group.h"
#include <stdlib.h>

Flu_Toggle_Group :: Flu_Toggle_Group( int x, int y, int w, int h, const char *l )
  : Fl_Group( x, y, w, h, l )
{
  chkBtn = new Fl_Check_Button( 0, 0, 0, 0 );
  chkBtn->callback( _toggleCB, this );
  box( FL_EMBOSSED_FRAME );
  align( FL_ALIGN_LEFT | FL_ALIGN_INSIDE );
}

void Flu_Toggle_Group :: toggleCB()
{
  do_callback();
  redraw();
}

void Flu_Toggle_Group :: draw()
{
  int lblW = 0, lblH, X, i;

  if( label() == 0 )
    lblW = lblH = 0;
  else if( strlen( label() ) == 0 )
    lblW = lblH = 0;
  else
    {
      measure_label( lblW, lblH );
      lblW += 18;
      lblH += 2;
    }

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

  unsigned char *active = 0;
  if( !chkBtn->value() )
    {
      active = (unsigned char*)malloc( children() );
      for( i = 1; i < children(); i++ )
	{
	  active[i-1] = child(i)->active();
	  child(i)->deactivate();
	}
    }

  // clip and draw the children
  chkBtn->resize( chkBtn->x(), chkBtn->y(), 0, 0 );
  fl_clip( x()+2, y()+lblH+1, w()-4, h()-lblH-3 );
  draw_children();
  fl_pop_clip();

  // clear behind the button and draw it
  fl_color( color() );
  fl_rectf( x()+X, y(), lblW+4, lblH );
  fl_color( labelcolor() );
  chkBtn->label( label() );
  chkBtn->resize( x()+X+2, y(), lblW, lblH );
  draw_child( *chkBtn );

  if( !chkBtn->value() )
    {
      for( i = 1; i < children(); i++ )
	{
	  if( active[i-1] )
	    child(i)->activate();
	  else
	    child(i)->deactivate();
	}
      free( active );
    }
}
