// $Id: Flu_GL_Window.h,v 1.12 2004/09/23 19:24:39 jbryan Exp $

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



#ifndef _FLU_GL_WINDOW_H
#define _FLU_GL_WINDOW_H

#include <stdio.h>

/* fltk includes */
#include <FL/Fl.H>
#include <FL/Fl_Gl_Window.H>

#include "FLU/Flu_Enumerations.h"

//! A class designed to supply an easier, more functional FLTK GL window, with callback functionality similar to GLUT.
class FLU_EXPORT  Flu_GL_Window : public Fl_Gl_Window
{

 public:

  //! Normal FLTK widget constructor
  Flu_GL_Window( int x, int y, int w, int h, const char *label = 0 );

  //! Top-level window constructor
  Flu_GL_Window( int w, int h, const char *label = 0 );

  //! Default destructor
  virtual ~Flu_GL_Window();

  //! Force this window to redraw
  void redraw();

  //! \return \c true if the OpenGL context managed by this window is valid to take OpenGL calls, \c false otherwise
  /*! \note This does not mean this context is the current one taking OpenGL calls, only that it *can* take calls
    when it becomes current. */
  inline bool is_context_valid()
    { return( can_do() > 0 ); }

  //! Setting this to \c true will report mouse input in cartesian coordinates instead of window coordinates.
  /*! Default is \c true */
  inline void cartesianInput( bool b )
    { _cartesian = b; }

  //! \return \c true if mouse input is reported in cartesian coordinates, \c false otherwise
  inline bool cartesianInput() const
    { return _cartesian; }

  /*! \name Drawing/Input Callback Registration
   * The registered functions will be called on the indicated event.
   */
  //@{

  //! The passed function must have the following signature: (void *user_data)
  inline void setInitFunc( void (*cb)(void*), void* cbd = NULL )
    { _initCB = cb; _initCBD = cbd; }

  //! The passed function must have the following signature: (int width, int height, void *user_data)
  /*! \b width and \b height represent the new size of the OpenGL context */
  inline void setResizeFunc( void (*cb)(int, int, void*), void* cbd = NULL )
    { _resizeCB = cb; _resizeCBD = cbd; }

  //! The passed function must have the following signature: (void *user_data)
  inline void setDrawFunc( void (*cb)(void*), void* cbd = NULL )
    { _drawCB = cb; _drawCBD = cbd; }

  //! The passed function must have the following signature: (int dx, int dy, int x, int y)
  /*! \b dx and \b dy represent the amount of movement of the mouse wheel (usually 1 or -1),
    and \b x and \b y represent where in the OpenGL context the event ocurred. */
  inline void setMouseWheelFunc( void (*cb)(int, int, int, int, void*), void* cbd = NULL )
    { _mouseWheelCB = cb; _mouseWheelCBD = cbd; }

  //! The passed function must have the following signature: (int button, int x, int y, void *user_data)
  /*! \b button is which mouse button generated the event: { \c FL_LEFT_MOUSE | \c FL_RIGHT_MOUSE | \c FL_MIDDLE_MOUSE },
    and \b x and \b y represent where in the OpenGL context the event ocurred. */
  inline void setMouseDownFunc( void (*cb)(int, int, int, void*), void* cbd = NULL )
    { _mouseDownCB = cb; _mouseDownCBD = cbd; }

  //! The passed function must have the following signature: (int button, int x, int y, void *user_data)
  /*! \b button is which mouse button generated the event: { \c FL_LEFT_MOUSE | \c FL_RIGHT_MOUSE | \c FL_MIDDLE_MOUSE },
    and \b x and \b y represent where in the OpenGL context the event ocurred. */
  inline void setMouseUpFunc( void (*cb)(int, int, int, void*), void* cbd = NULL )
    { _mouseUpCB = cb; _mouseUpCBD = cbd; }

  //! The passed function must have the following signature: (int x, int y, void *user_data)
  /*! \b x and \b y represent where in the OpenGL context the event ocurred. */
  inline void setMouseDragFunc( void (*cb)(int, int, void*), void* cbd = NULL )
    { _mouseDragCB = cb; _mouseDragCBD = cbd; }

  //! The passed function must have the following signature:(int x, int y, void *user_data)
  /*! \b x and \b y represent where in the OpenGL context the event ocurred. */
  inline void setMouseMoveFunc( void (*cb)(int, int, void*), void* cbd = NULL )
    { _mouseMoveCB = cb; _mouseMoveCBD = cbd; }

  //! The passed function must have the following signature: (void *user_data)
  inline void setMouseEnterFunc( void (*cb)(void*), void* cbd = NULL )
    { _enterCB = cb; _enterCBD = cbd; }

  //! The passed function must have the following signature: (void *user_data)
  inline void setMouseExitFunc( void (*cb)(void*), void* cbd = NULL )
    { _exitCB = cb; _exitCBD = cbd; }

  //! The passed function must have the following signature: (int key, int x, int y, void *user_data)
  /*! \b key is which key generated the event,
    and \b x and \b y represent where in the OpenGL context the event ocurred. */
  inline void setKeyboardFunc( void (*cb)(int, int, int, void*), void* cbd = NULL )
    { _keyboardCB = cb; _keyboardCBD = cbd; }

  //@}

  //! Set a function that will be called each time a new OpenGL context is created
  /*! This is useful for doing something globally specific for all contexts, such as
    loading OpenGL API entrypoints under Windows. */
  inline static void setAllInitFunc( void (*cb)(void*), void* cbd = NULL )
    { allInitCB = cb; allInitCBD = cbd; }

 protected:

  void (*_drawCB)(void*);
  void* _drawCBD;

  void (*_resizeCB)(int, int, void*);
  void* _resizeCBD;

  void (*_initCB)(void*);
  void* _initCBD;

  void (*_mouseWheelCB)(int, int, int, int, void*);
  void* _mouseWheelCBD;

  void (*_mouseDownCB)(int, int, int, void*);
  void* _mouseDownCBD;

  void (*_mouseUpCB)(int, int, int, void*);
  void* _mouseUpCBD;

  void (*_mouseDragCB)(int, int, void*);
  void* _mouseDragCBD;

  void (*_mouseMoveCB)(int, int, void*);
  void* _mouseMoveCBD;

  void (*_keyboardCB)(int, int, int, void*);
  void* _keyboardCBD;

  void (*_enterCB)(void*);
  void* _enterCBD;

  void (*_exitCB)(void*);
  void* _exitCBD;

 private:

  typedef void (*AllInitProto)(void*);

  static AllInitProto allInitCB;
  static void* allInitCBD;

  bool _firstDraw;
  bool _cartesian;

  /* overridden from Fl_Gl_Window */
  int handle( int event );
  void draw();

};

#endif
