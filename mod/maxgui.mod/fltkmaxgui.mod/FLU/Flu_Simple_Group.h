// $Id: Flu_Simple_Group.h,v 1.7 2003/08/20 16:29:43 jbryan Exp $

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



#ifndef _FLU_SIMPLE_GROUP_H
#define _FLU_SIMPLE_GROUP_H

/* fltk includes */
#include <FL/Fl.H>
#include <FL/fl_draw.H>
#include <FL/Fl_Group.H>

#include "FLU/Flu_Enumerations.h"

//! This class provides a simple aesthetic alternative to Fl_Group
class FLU_EXPORT Flu_Simple_Group : public Fl_Group
{

 public:

  //! Normal FLTK constructor
  Flu_Simple_Group( int x, int y, int w, int h, const char *l = 0 );

  //! Override of Fl_Group::draw()
  void draw();

};

#endif
