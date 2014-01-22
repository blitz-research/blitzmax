// $Id: Flu_Dual_Progress_Meter.h,v 1.6 2003/08/20 16:29:41 jbryan Exp $

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



#ifndef _FLU_DUAL_PROGRESS_METER_H
#define _FLU_DUAL_PROGRESS_METER_H

#include <stdio.h>

/* fltk includes */
#include <FL/Fl.H>
#include <FL/Fl_Double_Window.H>
#include <FL/Fl_Slider.H>
#include <FL/Fl_Button.H>

#include "FLU/Flu_Label.h"
#include "FLU/Flu_Enumerations.h"

//! This class provides a simple meter showing both current and total progress that also provides canceling behavior
class FLU_EXPORT Flu_Dual_Progress_Meter
{

 public:

  //! Constructor which makes the progress meter with the title \b t
  Flu_Dual_Progress_Meter( const char* t = NULL );

  //! Default destructor
  virtual ~Flu_Dual_Progress_Meter();

  //! Set the title of the progress meter to \b t
  inline void setTitle( const char* t )
    { if( window ) window->label( t ); }

  //! \return the title of this meter
  inline const char* getTitle() const
    { if( window ) return window->label(); else return ""; }

  //! Convenience routine combining setCurrentLabel() and setTotalLabel()
  inline void setLabel( const char* current, const char* total )
    { if( currentLabel ) currentLabel->label( current ); if( totalLabel ) totalLabel->label( total ); }

  //! Set the "current" label displayed during the operation
  inline void setCurrentLabel( const char* l )
    { if( currentLabel ) currentLabel->label( l ); }

  //! Set the "total" label displayed during the operation
  inline void setTotalLabel( const char* l )
    { if( totalLabel ) totalLabel->label( l ); }

  //! Get the label for the current progress
  inline const char* getCurrentLabel() const
    { if( currentLabel ) return currentLabel->label(); else return ""; }

  //! Get the label for the total progress
  inline const char* getTotalLabel() const
    { if( totalLabel ) return totalLabel->label(); else return ""; }

  //! Set the color of the progress bar
  /*! Default is FL_BLUE */
  inline void setColor( Fl_Color c )
    { if( currentSlider ) currentSlider->selection_color( c );if( totalSlider ) totalSlider->selection_color( c );  }

  //! \return the current color of the progress bar
  inline Fl_Color getColor() const
    { if( currentSlider ) return currentSlider->selection_color(); else return FL_BLUE; }

  //! Convenience routine combining setCurrentValue() and setTotalValue()
  inline bool setValue( float currentVal, float totalVal )
    { bool b = setCurrentValue(currentVal) | setTotalValue(totalVal); return b; }

  //! Set the value of the current progress bar. \b v should be on [0,1]
  /*! \return \c true if the cancel button has been pressed */
  bool setCurrentValue( float v );

  //! Set the value of the total progress bar. \b v should be on [0,1]
  /*! \return \c true if the cancel button has been pressed */
  bool setTotalValue( float v );

  //! This function can be registered to update the progress bar
  inline static void currentValueCallback( float v, void *arg )
    { ((Flu_Dual_Progress_Meter*)arg)->setCurrentValue( v ); }

  //! This function can be registered to update the progress bar
  inline static void totalValueCallbackd( double v, void *arg )
    { ((Flu_Dual_Progress_Meter*)arg)->setTotalValue( (float)v ); }

  //! \return the current value of the progress bar, on [0,1]
  inline float getCurrentValue() const
    { if( currentSlider ) return currentSlider->value(); else return 0.0f; }

  //! \return the current value of the progress bar, on [0,1]
  inline float getTotalValue() const
    { if( totalSlider ) return totalSlider->value(); else return 0.0f; }

  //! Show the meter. If \b cancelBtnVisible is \c true, then the "Cancel" button will be shown
  void show( bool cancelBtnVisible = false );

  //! Hide the meter
  inline void hide()
    { if( window ) window->hide(); Fl::flush(); }

  //! \return \c true if the meter is shown, \c false otherwise
  inline bool shown() const
    { if( window ) return window->shown(); else return false; }

  //! Set the function that will be called when the "Cancel" button is pressed
  inline void cancelCallback( void (*cb)(void*), void* cbd = NULL )
    { _cancelCB = cb; _cancelCBD = cbd; }

 protected:


 private:

  void (*_cancelCB)(void*);
  void* _cancelCBD;
  bool _cancelled;

  static void _onCancelCB( Fl_Widget* w, void* arg )
    { ((Flu_Dual_Progress_Meter*)arg)->onCancel(); }
  void onCancel()
    { _cancelled = true; if( _cancelCB ) _cancelCB( _cancelCBD ); }

  Fl_Double_Window* window;
  Fl_Slider *currentSlider, *totalSlider;
  Fl_Button* cancel;
  Flu_Label *currentLabel, *totalLabel;

};

#endif
