// $Id: Flu_Link_Button.h,v 1.3 2003/10/28 15:36:06 jbryan Exp $

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



#ifndef _FLU_LINK_BUTTON_H
#define _FLU_LINK_BUTTON_H

#include "FLU/Flu_Button.h"

//! This class extends Flu_Button to make a button that looks like a hyperlink
class FLU_EXPORT Flu_Link_Button : public Flu_Button
{
 public:

  //! Normal FLTK widget constructor
  Flu_Link_Button( int X,int Y,int W,int H,const char *l = 0 );

  //! Default destructor
  ~Flu_Link_Button();

  //! Set whether the link underline appears only when the mouse is over the button. Default is \c false
  inline void overlink( bool b )
    { overLink = b; }

  //! Get whether the link underline appears only when the mouse is over the button
  inline bool overlink() const
    { return overLink; }

};

#endif
