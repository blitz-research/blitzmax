// $Id: Flu_Dual_Slider.h,v 1.9 2004/10/14 18:59:36 jbryan Exp $

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



#ifndef _FLU_DUAL_SLIDER_H
#define _FLU_DUAL_SLIDER_H

#include <FL/Fl.H>
#include <FL/Fl_Valuator.H>
#include <FL/Fl_Slider.H>

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "FLU/Flu_Enumerations.h"

//! This class is essentially an Fl_Slider but with two handles. type() can be one of FL_HOR_SLIDER, FL_HOR_NICE_SLIDER, FL_VERT_SLIDER, FL_VERT_NICE_SLIDER
class FLU_EXPORT Flu_Dual_Slider : public Fl_Valuator
{
public:

  //! Normal FLTK widget constructor
  Flu_Dual_Slider( int x, int y, int w, int h, const char *l = 0 );

  //! Default destructor
  ~Flu_Dual_Slider();

  //! Override of Fl_Valuator::handle
  int handle( int event );

  //! Override of Fl_Valuator::handle
  void draw();

  //! Set whether the low and high values can be the same (\c true), or whether they are exclusive (\c false). Default is \c false
  inline void overlap( bool b )
    { _overlap = b; }

  //! Get whether the low and high values can be the same
  inline bool overlap() const
    { return _overlap; }

  //! Set the low value of the slider
  inline void low_value( float v )
  { lowValue = v; _lVal = (lowValue-minimum())/(maximum()-minimum()); Fl_Valuator::value(v); }

  //! Get the low value of the slider
  inline float low_value() const
  { return minimum()>maximum() ? (minimum()+maximum()-highValue) : lowValue; }

  //! Set the high value of the slider
  inline void high_value( float v )
  { highValue = v; _hVal = (highValue-minimum())/(maximum()-minimum()); Fl_Valuator::value(v); }

  //! Get the high value of the slider
  inline float high_value() const
  { return minimum()>maximum() ? (minimum()+maximum()-lowValue) : highValue; }

  //! Convenience routine to set low_value() and high_value() at once
  inline void value( float lo, float hi )
    { low_value(lo); high_value(hi); }

  //! \return \b true if the low value slider is currently grabbed by the mouse, \c false otherwise
  inline bool low_grabbed() const
    { return _lGrabbed; }

  //! \return \b true if the high value slider is currently grabbed by the mouse, \c false otherwise
  inline bool high_grabbed() const
    { return _hGrabbed; }

protected:

  inline bool _horizontal()
  { return( type() == FL_HOR_NICE_SLIDER || type() == FL_HOR_SLIDER ); }
  inline bool _nice()
  { return( type() == FL_HOR_NICE_SLIDER || type() == FL_VERT_NICE_SLIDER ); }

  float highValue, lowValue;

  bool _lFocus, _flip, _overlap;
  int _grab, _delta;
  float _lVal, _hVal;
  int _lHandle[4], _hHandle[4];
  bool _lGrabbed, _hGrabbed;
  int _grabDelta;
};

#endif
