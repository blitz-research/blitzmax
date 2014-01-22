// $Id: Flu_GL_Canvas.cpp,v 1.3 2004/09/23 20:16:13 jbryan Exp $

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



#include "FLU/Flu_GL_Canvas.h"

Flu_GL_Canvas :: Flu_GL_Canvas( int x, int y, int w, int h, const char *label )
  : Flu_GL_Window( x, y, w, h, label )
{
  setInitFunc( _initCB, this );
  setResizeFunc( _reshapeCB, this );
  setDrawFunc( _renderCB, this );
  setMouseWheelFunc( _mouse_wheelCB, this );
  setMouseDownFunc( _mouse_button_downCB, this );
  setMouseUpFunc( _mouse_button_upCB, this );
  setMouseDragFunc( _mouse_dragCB, this );
  setMouseMoveFunc( _mouse_moveCB, this );
  setMouseEnterFunc( _mouse_enterCB, this );
  setMouseExitFunc( _mouse_exitCB, this );
  setKeyboardFunc( _keyboardCB, this );
}

Flu_GL_Canvas :: ~Flu_GL_Canvas()
{
}
