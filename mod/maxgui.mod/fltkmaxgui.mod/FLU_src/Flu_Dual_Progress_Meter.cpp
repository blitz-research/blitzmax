// $Id: Flu_Dual_Progress_Meter.cpp,v 1.4 2003/08/20 16:29:45 jbryan Exp $

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



#include "FLU/Flu_Dual_Progress_Meter.h"

Flu_Dual_Progress_Meter :: Flu_Dual_Progress_Meter( const char* t )
{
  window = new Fl_Double_Window( 350, 250, t );
  currentLabel = new Flu_Label( 10, 5, 330, 65 );
  currentLabel->align( currentLabel->align() | FL_ALIGN_WRAP );
  currentSlider = new Fl_Slider( 10, 70, 330, 30 );
  totalLabel = new Flu_Label( 10, 105, 330, 65 );
  totalLabel->align( totalLabel->align() | FL_ALIGN_WRAP );
  totalSlider = new Fl_Slider( 10, 170, 330, 30 );
  cancel = new Fl_Button( window->w()/2-30, window->h()-40, 60, 30, "Cancel" );
  window->end();

  window->hide();

  currentSlider->deactivate();
  currentSlider->align( FL_ALIGN_TOP | FL_ALIGN_LEFT );
  currentSlider->type( FL_HOR_FILL_SLIDER );
  currentSlider->range( 0, 1 );
  currentSlider->selection_color( FL_BLUE );

  totalSlider->deactivate();
  totalSlider->align( FL_ALIGN_TOP | FL_ALIGN_LEFT );
  totalSlider->type( FL_HOR_FILL_SLIDER );
  totalSlider->range( 0, 1 );
  totalSlider->selection_color( FL_BLUE );

  cancel->callback( _onCancelCB, this );
  _cancelled = false;

  _cancelCB = NULL;
  _cancelCBD = NULL;
}

Flu_Dual_Progress_Meter :: ~Flu_Dual_Progress_Meter()
{
  if( window )
    window->hide();
}

bool Flu_Dual_Progress_Meter :: setCurrentValue( float v )
{
  if( currentSlider )
    {
      currentSlider->value( v );
      if( window->visible() )
	currentSlider->redraw();
      Fl::wait(0);
    }
  return _cancelled;
}

bool Flu_Dual_Progress_Meter :: setTotalValue( float v )
{
  if( totalSlider )
    {
      totalSlider->value( v );
      if( window->visible() )
	totalSlider->redraw();
      Fl::wait(0);
    }
  return _cancelled;
}

void Flu_Dual_Progress_Meter :: show( bool cancelBtnVisible )
{
  _cancelled = false;
  if( _cancelCB || cancelBtnVisible )
    cancel->show();
  else
    cancel->hide();

  if( window )
    {
      window->set_modal();
      window->show();
    }

  Fl::flush();
}
