// $Id: Flu_Toggle_Group.h,v 1.8 2003/08/20 16:29:43 jbryan Exp $

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



#ifndef _FLU_TOGGLE_GROUP_H
#define _FLU_TOGGLE_GROUP_H

#include <stdio.h>
#include <string.h>

/* fltk includes */
#include <FL/Fl.H>
#include <FL/Fl_Check_Button.H>
#include <FL/fl_draw.H>
#include <FL/Fl_Group.H>

#include "FLU/Flu_Enumerations.h"

//! This class provides a group that can be toggled active or inactive
class FLU_EXPORT Flu_Toggle_Group : public Fl_Group
{

 public:

  //! Default FLTK constructor
  Flu_Toggle_Group( int x, int y, int w, int h, const char *l = 0 );

  //! Activate the group
  inline void activate()
    { value(1); }

  //! Deactivate the group
  inline void deactivate()
    { value(0); }

  //! Get the activation state of this group.
  inline int active() const
    { return value(); }

  //! Set the activation state of this group. 0 deactivates the group, anything else activates it.
  inline void value( int v )
    { chkBtn->value(v); redraw(); }

  //! Get the activation state of this group.
  inline int value() const
    { return chkBtn->value(); }

  //! Override of Fl_Group::draw()
  void draw();

 protected:

  static void _toggleCB( Fl_Widget *w, void *arg )
    { ((Flu_Toggle_Group*)arg)->toggleCB(); }
  void toggleCB();

  Fl_Check_Button *chkBtn;

};

#endif
