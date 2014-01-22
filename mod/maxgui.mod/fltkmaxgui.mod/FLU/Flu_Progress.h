// $Id: Flu_Progress.h,v 1.6 2004/04/10 22:10:56 jbryan Exp $

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



#ifndef _FLU_PROGRESS_H
#define _FLU_PROGRESS_H

#include <FL/Fl_Valuator.H>
#include <FL/Fl_Input.H>
#include <FL/Fl_Group.H>

#include "FLU/Flu_Enumerations.h"

//! This class provides a simple progress widget similar to the way Fl_Slider is used for progress, except it is just for progress reporting and displays the progress value inside the widget
class FLU_EXPORT Flu_Progress : public Fl_Valuator
{

public:

  //! Normal FLTK widget constructor
  Flu_Progress( int x, int y, int w, int h, const char *l = 0 );

  //! Default destructor
  ~Flu_Progress();

  //! Override of Fl_Valuator::value() which forces a redraw only if the new value causes the integral percent to change
  int value( float v );

  //! Pass-through of Fl_Valuator::value()
  inline float value() const
    { return Fl_Valuator::value(); }

protected:

  void draw();

};

#endif
