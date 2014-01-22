// $Id: Flu_Collapsable_Group.h,v 1.8 2003/09/24 21:13:47 jbryan Exp $

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



#ifndef _FLU_COLLAPSABLE_GROUP_H
#define _FLU_COLLAPSABLE_GROUP_H

#include <stdio.h>
#include <string.h>

/* fltk includes */
#include <FL/Fl.H>
#include <FL/fl_draw.H>
#include <FL/Fl_Group.H>
#include <FL/Fl_Box.H>

#include "FLU/FluSimpleString.h"
#include "FLU/Flu_Button.h"

//! This widget implements a collapsable group with a configurable framerate
/*! This class is a group with a button and an \b Fl_Group inside (both publicly exposed). The \b Fl_Group
  contains the actual child widgets of this group.

  Most of the \b Fl_Group member functions are reimplemented here in a pass-through fashion to the
  internal group. This means that casual use of a descendent instance will be almost exactly the same
  as for a regular \b Fl_Group, with any additional access provided directly through member \b group.

  The goal of this class is to provide a dynamically collapsable group similar to those available in 
  other GUI toolkits.

  The callback is invoked whenever the button is pressed to open/close the group.
*/
class FLU_EXPORT Flu_Collapsable_Group : public Fl_Group
{

 public:

  //! Normal FLTK constructor
  Flu_Collapsable_Group( int x, int y, int w, int h, const char *l = 0 );

  //! Get the amount of time to take when animating a collapse
  inline float collapse_time() const
    { return _collapseTime; }

  //! Set the amount of time to take when animating a collapse
  inline void collapse_time( float t )
    { _collapseTime = t; }

  //! Get the frame rate to aim for during a collapse animation
  inline float frame_rate() const
    { return _fps; }

  //! Set the frame rate to aim for during a collapse animation
  inline void frame_rate( float f )
    { _fps = f; }

  //! Set the position of the controller widget along the top edge of the group. This only has an effect if fit() is not set. Default value is \c FL_ALIGN_LEFT
  /*! Accepted values are \c FL_ALIGN_LEFT, \c FL_ALIGN_CENTER, and \c FL_ALIGN_RIGHT */
  inline void align( unsigned char a )
    { _align = a; }

  //! Get the position of the controller widget along the top edge of the group
  inline unsigned char align() const
    { return _align; }

  //! Pass \c true to force the button to be the same width as the group, \c false to leave it its default size. Default value is \c false
  inline void fit( bool b )
    { _fit = b; }

  //! Get whether the button is being forced to fit the width of the group
  inline bool fit() const
    { return _fit; }

  //! Get whether the group is closed or open (i.e. collapsed or not)
  inline bool open() const
    { return _open; }

  //! Set whether the group is closed or open (i.e. collapsed or not). Default is \c true
  void open( bool o );

  //! Get whether the group is closed or open (i.e. collapsed or not)
  inline bool closed() const
    { return !_open; }

  //! Get whether the group is in the process of opening or closing
  inline bool changing() const
    { return _changing; }

  //! Override of Fl_Group::resize()
  void resize( int x, int y, int w, int h );

  //! Override of Fl_Group::label()
  inline void label( const char *l )
    { if( l ) _label = l; else _label = ""; }

  //! Override of Fl_Group::label()
  inline const char *label()
    { return _label.c_str(); }

  //////////////////////

  /*! \name Pass-through functions for the internal Fl_Group
   * These are strictly for convenience. Only the most commonly called functions have been re-implemented.
   * You can also explicitly access the group object for more control.
   */
  //@{

  inline void clear()
    { group.clear(); }

  inline Fl_Widget *child(int n) const
    { return group.child(n); }

  inline int children() const
    { return group.children(); }

  inline void begin()
    { group.begin(); }

  inline void end()
    { group.end(); Fl_Group::end(); }

  inline void resizable(Fl_Widget *box)
    { group.resizable(box); }

  inline void resizable(Fl_Widget &box) 
    { group.resizable(box); }

  inline Fl_Widget *resizable() const
    { return group.resizable(); }

  inline void add( Fl_Widget &w )
    { group.add( w ); }

  inline void add( Fl_Widget *w )
    { group.add( w ); }

  inline void insert( Fl_Widget &w, int n )
    { group.insert( w, n ); }

  inline void insert( Fl_Widget &w, Fl_Widget* beforethis )
    { group.insert( w, beforethis ); }

  inline void remove( Fl_Widget &w )
    { group.remove( w ); }

  inline void add_resizable( Fl_Widget &box )
    { group.add_resizable( box ); }

  //@}

  Flu_Button button;
  Fl_Group group;

 protected:

  //////////////////////////

  void draw();

  inline static void _collapseCB( Fl_Widget* w, void* arg )
    { ((Flu_Collapsable_Group*)arg)->open( !((Flu_Collapsable_Group*)arg)->open() ); }

  inline static void _updateCB( void *arg )
    { ((Flu_Collapsable_Group*)arg)->updateCB(); }
  void updateCB();

  void (*_callback)(Fl_Widget*,void*);
  void *_callbackData;

  void (*_collapseCallback)(void*);
  void *_collapseCallbackData;

  int _originalHeight, _newHeight;
  float _deltaHeight, _currentHeight, _collapseTime, _timeout, _fps;

  Fl_Widget *_oldResizable;

  bool _open, _changing, _fit;
  unsigned char _align;
  FluSimpleString _label;

};

#endif
