// $Id: Flu_GL_Canvas.h,v 1.3 2004/09/23 20:16:13 jbryan Exp $

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



#ifndef _FLU_GL_CANVAS_H
#define _FLU_GL_CANVAS_H

#include <stdio.h>
#include "FLU/Flu_GL_Window.h"

//! An easy to derive from class providing an OpenGL canvas for drawing
class FLU_EXPORT  Flu_GL_Canvas : public Flu_GL_Window
{

 public:

  //! Normal FLTK widget constructor
  Flu_GL_Canvas( int x, int y, int w, int h, const char *label = 0 );

  //! Default destructor
  virtual ~Flu_GL_Canvas();

  //! Called when the canvas is first created
  virtual void init() {}

  //! Called when the canvas is resized
  /*! \b width and \b height represent the new size of the OpenGL context */
  virtual void reshape( int width, int height ) {}

  //! Called when the canvas needs to be drawn
  virtual void render() {}

  //! Called when the mouse scrolly wheel is scrolled
  /*! \b dx and \b dy represent the amount of movement of the mouse wheel (usually 1 or -1),
    and \b x and \b y represent where in the OpenGL context the event ocurred. */
  virtual void mouse_wheel( int dx, int dy, int x, int y ) {}

  //! Called when a mouse button is pressed
  /*! \b button is which mouse button generated the event: { \c FL_LEFT_MOUSE | \c FL_RIGHT_MOUSE | \c FL_MIDDLE_MOUSE },
    and \b x and \b y represent where in the OpenGL context the event ocurred. */
  virtual void mouse_button_down( int button, int x, int y ) {}

  //! Called when a mouse button is released
  /*! \b button is which mouse button generated the event: { \c FL_LEFT_MOUSE | \c FL_RIGHT_MOUSE | \c FL_MIDDLE_MOUSE },
    and \b x and \b y represent where in the OpenGL context the event ocurred. */
  virtual void mouse_button_up( int button, int x, int y ) {}

  //! Called when the mouse is moved with a button pressed
  /*! \b x and \b y represent where in the OpenGL context the event ocurred. */
  virtual void mouse_drag( int x, int y ) {}

  //! Called when the mouse is moved without a button pressed
  /*! \b x and \b y represent where in the OpenGL context the event ocurred. */
  virtual void mouse_move( int x, int y ) {}

  //! Called when the mouse enters the canvas
  virtual void mouse_enter() {} 

  //! Called when the mouse leaves the canvas
  virtual void mouse_exit() {}

  //! Called when a key on the keyboard is pressed
  /*! \b key is which key generated the event,
    and \b x and \b y represent where in the OpenGL context the event ocurred. */
  virtual void keyboard( int key, int x, int y ) {}

 private:

  static inline void _initCB( void *arg )
    { ((Flu_GL_Canvas*)arg)->init(); }
  static inline void _reshapeCB( int width, int height, void *arg )
    { ((Flu_GL_Canvas*)arg)->reshape(width,height); }
  static inline void _renderCB( void *arg )
    { ((Flu_GL_Canvas*)arg)->render(); }
  static inline void _mouse_wheelCB( int dx, int dy, int x, int y, void *arg )
    { ((Flu_GL_Canvas*)arg)->mouse_wheel(dx,dy,x,y); }
  static inline void _mouse_button_downCB( int button, int x, int y, void *arg )
    { ((Flu_GL_Canvas*)arg)->mouse_button_down(button,x,y); }
  static inline void _mouse_button_upCB( int button, int x, int y, void *arg )
    { ((Flu_GL_Canvas*)arg)->mouse_button_up(button,x,y); }
  static inline void _mouse_dragCB( int x, int y, void *arg )
    { ((Flu_GL_Canvas*)arg)->mouse_drag(x,y); }
  static inline void _mouse_moveCB( int x, int y, void *arg )
    { ((Flu_GL_Canvas*)arg)->mouse_move(x,y); }
  static inline void _mouse_enterCB( void *arg )
    { ((Flu_GL_Canvas*)arg)->mouse_enter(); }
  static inline void _mouse_exitCB( void *arg )
    { ((Flu_GL_Canvas*)arg)->mouse_exit(); }
  static inline void _keyboardCB( int key, int x, int y, void *arg )
    { ((Flu_GL_Canvas*)arg)->keyboard(key,x,y); }

};

#endif
