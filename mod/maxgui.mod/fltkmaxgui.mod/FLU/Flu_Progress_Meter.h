// $Id: Flu_Progress_Meter.h,v 1.12 2004/06/30 00:18:00 jbryan Exp $

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



#ifndef _FLU_PROGRESS_METER_H
#define _FLU_PROGRESS_METER_H

#include <stdio.h>

/* fltk includes */
#include <FL/Fl.H>
#include <FL/Fl_Double_Window.H>
#include <FL/Fl_Button.H>

#include "FLU/Flu_Label.h"
#include "FLU/Flu_Progress.h"
#include "FLU/Flu_Enumerations.h"

#ifdef WIN32
#include <winsock.h>
#include <time.h>
#else
#include <sys/time.h>
#endif

//! This class provides a simple progress meter with elapsed time, estimated time to completion, and optional canceling behavior
class FLU_EXPORT Flu_Progress_Meter : public Fl_Double_Window
{

 public:

  //! Constructor which makes the progress meter with the title \b t
  Flu_Progress_Meter( const char* t = NULL );

  //! Default destructor
  virtual ~Flu_Progress_Meter();

  //! Set the title of the progress meter to \b t
  inline void title( const char* t )
    { Fl_Double_Window::label( t ); }

  //! \return the title of this meter
  inline const char* title() const
    { return Fl_Double_Window::label(); }

  //! Set the label that is displayed during the operation to \b l
  inline void label( const char* l )
    { if( _label ) _label->label( l ); }

  //! Get the label that is currently displayed
  inline const char* label() const
    { if( _label ) return _label->label(); else return ""; }

  //! Set the color of the progress bar. Default is FL_BLUE
  inline void color( Fl_Color c )
    { if( progress ) progress->selection_color( c ); }

  //! \return the current color of the progress bar
  inline Fl_Color color() const
    { if( progress ) return progress->selection_color(); else return FL_BLUE; }

  //! Set the value of the progress bar. \b v should be on [0,1]
  /*! \return \c true if the cancel button has been pressed */
  bool value( float v );

  //! \return the current value of the progress bar, on [0,1]
  inline float value() const
    { if( progress ) return progress->value(); else return 0.0f; }

  //! This function can be registered to update the progress bar
  inline static void value_callback( float v, void *arg )
    { ((Flu_Progress_Meter*)arg)->value( v ); }

  //! This function can be registered to update the progress bar
  inline static void value_callbackd( double v, void *arg )
    { ((Flu_Progress_Meter*)arg)->value( (float)v ); }

  //! This function can be registered to update the progress bar
  inline static bool cvalue_callback( float v, void *arg )
    { return ((Flu_Progress_Meter*)arg)->value( v ); }

  //! This function can be registered to update the progress bar
  inline static bool cvalue_callbackd( double v, void *arg )
    { return ((Flu_Progress_Meter*)arg)->value( (float)v ); }

  //! Set whether to show the estimated time to completion of the operation. Default is \c true
  inline void show_completion_time( bool b )
    { _showETC = b; }

  //! Get whether to show the estimated time to completion of the operation
  inline bool show_completion_time() const
    { return _showETC; }

  //! Show the meter. If \b withCancelButton is \c true, then the "Cancel" button will be shown
  void show( bool withCancelButton = false );

  void reset();

  //! Hide the meter
  void hide();

  //! Set the function that will be called when the "Cancel" button is pressed
  inline void cancel_callback( void (*cb)(void*), void* cbd = NULL )
    { _cancelCB = cb; _cancelCBD = cbd; }

 protected:


 private:

#ifdef WIN32
  inline void gettimeofday( struct timeval *t, void* )
    {
      t->tv_sec = 0;
      t->tv_usec = clock();
    }
#endif

  timeval startT;

  inline static void _secondTimerCB( void *arg )
    { ((Flu_Progress_Meter*)arg)->secondTimerCB(); }
  void secondTimerCB( bool repeatTimer = true );

  void (*_cancelCB)(void*);
  void* _cancelCBD;
  bool _cancelled, _showETC;

  static void _onCancelCB( Fl_Widget* w, void* arg )
    { ((Flu_Progress_Meter*)arg)->onCancel(); }
  void onCancel()
    { _cancelled = true; if( _cancelCB ) _cancelCB( _cancelCBD ); }

  Flu_Progress* progress;
  Fl_Button* cancel;
  Flu_Label *_label, *etc;

};

#endif
