// $Id: Flu_Float_Input.h,v 1.10 2004/03/29 23:13:19 jbryan Exp $

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



#ifndef _FLU_FLOAT_INPUT_H
#define _FLU_FLOAT_INPUT_H

#include <FL/Fl_Float_Input.H>

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "FLU/Flu_Enumerations.h"

//! This class simply extends Fl_Float_Input to allow getting/setting the widget value as floats instead of just strings
class FLU_EXPORT Flu_Float_Input : public Fl_Float_Input
{
 public:

  //! Normal FLTK widget constructor
  Flu_Float_Input( int X,int Y,int W,int H,const char *l = 0 );

  //! Default destructor
  ~Flu_Float_Input();

  //! Set the format to use when printing the value into the input area. Only the pointer to \b f is copied. Default is "%g"
  inline void format( const char *f )
    { _format = f; }

  //! Get the format to use when printing the value into the input area.
  inline const char *format() const
    { return _format; }

  //! \return the value of the widget as a float
  inline float fvalue() const { return atof( value() ); }

  //! Set the value of the widget as a float using the given \c printf style format string
  inline void fvalue( float v, const char *format = 0 )
    { char buf[32]; sprintf(buf,format?format:_format,v); value(buf); }

 private:
  const char *_format;

};

#endif
