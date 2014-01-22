// $Id: Flu_Float_Input.cpp,v 1.4 2004/03/29 23:13:19 jbryan Exp $

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



#include "FLU/Flu_Float_Input.h"

Flu_Float_Input :: Flu_Float_Input( int X,int Y,int W,int H,const char *l )
  : Fl_Float_Input(X,Y,W,H,l)
{
  format( "%g" );
}

Flu_Float_Input :: ~Flu_Float_Input()
{
}
