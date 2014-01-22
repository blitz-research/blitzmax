// $Id: Flu_Progress_Meter.cpp,v 1.16 2004/06/09 19:51:15 jbryan Exp $

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



#include "FLU/Flu_Progress_Meter.h"

#if !defined WIN32
  #define TSCALE (1.0 / 1.0e6)
#else
  #define TSCALE (1.0 / CLOCKS_PER_SEC)
#endif

Flu_Progress_Meter :: Flu_Progress_Meter( const char* t )
  : Fl_Double_Window( Fl::w()/2-350/2, Fl::h()/2-180/2, 350, 180, t )
{
  _cancelled = false;
  _cancelCB = NULL;
  _cancelCBD = NULL;
  _showETC = true;

  _label = new Flu_Label( 10, 10, 330, 50 );
  _label->align( _label->align() | FL_ALIGN_WRAP );
  etc = new Flu_Label( 10, 60, 330, 30 );
  etc->hide();
  progress = new Flu_Progress( 10, 100, 330, 30 );
  cancel = new Fl_Button( w()/2-30, h()-40, 60, 30, "Cancel" );
  end();

  Fl_Double_Window::hide();

  progress->align( FL_ALIGN_TOP | FL_ALIGN_LEFT );

  cancel->callback( _onCancelCB, this );
}

Flu_Progress_Meter :: ~Flu_Progress_Meter()
{
  Fl::remove_timeout( _secondTimerCB, this );
  hide();
}

inline void secs2HMS( double secs, int &H, int &M, int &S )
{
  S = (int)secs;
  M = S / 60; S -= M*60;
  H = M / 60; M -= H*60;
}

void Flu_Progress_Meter::reset()
{
  Fl::remove_timeout( _secondTimerCB, this );
  gettimeofday( &startT, 0 );
  Fl::add_timeout( 0.0f, _secondTimerCB, this );
  value(0);
}

void Flu_Progress_Meter :: secondTimerCB( bool repeatTimer )
{
  // get the current time and use it to compute the elapsed time, if necessary
  timeval now;
  gettimeofday( &now, 0 );

  if( _showETC && shown() )
    {
      // compute the elapsed time
      double elapsed = (now.tv_sec - startT.tv_sec) + ( (now.tv_usec - startT.tv_usec) * TSCALE );
      // estimate the remaining time based on the elapsed time and the current progress
      double remaining = elapsed / this->value() - elapsed + 1.0f;
      int es, em, eh, rs, rm, rh;

      secs2HMS( elapsed, eh, em, es );
      //if( elapsed < 1.0 )
      //rh = rm = rs = 0;
      //else
      secs2HMS( remaining, rh, rm, rs );

      char buf[128];
      sprintf( buf, "Elapsed Time: %03d:%02d:%02d\n"
	       "Remaining Time: %03d:%02d:%02d",
	       eh, em, es, rh, rm, rs );
      etc->label( buf );
      etc->show();
    }
  else
    etc->hide();

  if( repeatTimer )
    {
      Fl::repeat_timeout( 1.0f, _secondTimerCB, this );
      Fl::check();
    }
}

bool Flu_Progress_Meter :: value( float v )
{
  secondTimerCB( false );

  if( progress )
    progress->value( v );

  return _cancelled;
}

void Flu_Progress_Meter :: show( bool cancelBtnVisible )
{
  gettimeofday( &startT, 0 );

  _cancelled = false;
  if( _cancelCB || cancelBtnVisible )
    cancel->show();
  else
    cancel->hide();

  //set_modal();
  Fl_Double_Window::show();

  Fl::add_timeout( 0.0f, _secondTimerCB, this );
  Fl::flush();
}

void Flu_Progress_Meter :: hide()
{
  Fl::remove_timeout( _secondTimerCB, this );
  Fl_Double_Window::hide();
  Fl::flush();
}
