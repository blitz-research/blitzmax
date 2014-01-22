// $Id: Flu_Choice_Group.h,v 1.9 2003/08/20 16:29:40 jbryan Exp $

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



#ifndef _FLU_CHOICE_GROUP_H
#define _FLU_CHOICE_GROUP_H

#include <stdio.h>
#include <string.h>

/* fltk includes */
#include <FL/Fl.H>
#include <FL/Fl_Choice.H>
#include <FL/fl_draw.H>
#include <FL/Fl_Group.H>

#include "FLU/Flu_Enumerations.h"

//! This class provides an alternative group to Fl_Tabs. It provides an Fl_Choice menu that is used to determine which child Fl_Group is visible
class FLU_EXPORT Flu_Choice_Group : public Fl_Group
{

 public:

  //! Default FLTK constructor
  Flu_Choice_Group( int x, int y, int w, int h, const char *l = 0 );

  //! Get the currently visible child Fl_Group widget
  /*! \return \c NULL if there are no child Fl_Groups, else the currently selected group */
  inline Fl_Widget* wvalue()
    { return selected; }

  //! Get the index of the currently visible child Fl_Group widget
  /*! \return \c -1 if there are no child Fl_Groups, else the index of the group */
  int value();

  //! Set the currently visible child Fl_Group widget
  /*! \return the index of the child Fl_Group widget that is currently selected, or \c -1 if \b newvalue cannot be found. */
  int value( Fl_Widget *newvalue );

  //! Set the currently visible child Fl_Group widget
  void value( int v );

  //! Override of Fl_Group::draw()
  void draw();

  //! \return the number of entries able to be selected with value(int)
  inline int size()
    { return children()-1; }

 protected:

  static void _choiceCB( Fl_Widget *w, void *arg )
    { ((Flu_Choice_Group*)arg)->choiceCB(); }
  void choiceCB();

  Fl_Choice *choice;
  Fl_Widget *selected;

};

#endif
