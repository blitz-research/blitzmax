// $Id: Flu_Link_Button.cpp,v 1.3 2003/10/28 15:36:07 jbryan Exp $

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



#include "FLU/Flu_Link_Button.h"

Flu_Link_Button :: Flu_Link_Button( int X,int Y,int W,int H,const char *l )
  : Flu_Button( X,Y,W,H,l )
{
  box( FL_FLAT_BOX );
  linkBtn = true;
  overLink = false;
  labelcolor( FL_BLUE );
}

Flu_Link_Button :: ~Flu_Link_Button()
{
}
