// $Id: Flu_Output.h,v 1.8 2003/08/20 16:29:42 jbryan Exp $

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



#ifndef _FLU_OUTPUT_H
#define _FLU_OUTPUT_H

#include <FL/Fl_Output.H>

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "FLU/Flu_Enumerations.h"

//! This class simply extends Fl_Output to allow getting/setting the widget value as integers and floats in addition to strings
class FLU_EXPORT Flu_Output : public Fl_Output
{
 public:

  //! Normal FLTK widget constructor
  Flu_Output( int X,int Y,int W,int H,const char *l = 0 );

  //! Default destructor
  ~Flu_Output();

  //! \return the value of the widget as an integer
  inline int ivalue() const { return atoi( value() ); }

  //! Set the value of the widget as an integer using the given \c printf style format string
  inline void ivalue( int v, const char *format = "%d" ) { char buf[32]; sprintf(buf,format,v); value(buf); }

  //! \return the value of the widget as a float
  inline float fvalue() const { return atof( value() ); }

  //! Set the value of the widget as a float using the given \c printf style format string
  inline void fvalue( float v, const char *format = "%.2f" ) { char buf[32]; sprintf(buf,format,v); value(buf); }

};

#endif
