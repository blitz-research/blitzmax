// $Id: Flu_DND.h,v 1.17 2003/08/20 16:29:41 jbryan Exp $

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



#ifndef _FLU_DND_H
#define _FLU_DND_H

#include <FL/Fl.H>
#include <FL/fl_draw.H>

#include <stdlib.h>
#include <string.h>

#include "FLU/Flu_Enumerations.h"

#define FLU_DND_MAX_TYPES 32

//! This class encapsulates the event state for a single dragged object, and is designed to work exclusively with Flu_DND
class FLU_EXPORT Flu_DND_Event
{
  friend class Flu_DND;

 public:

  //! Default constructor
  Flu_DND_Event();

  //! Default destructor
  ~Flu_DND_Event();

  //! \return \c true if currently dragging an object, \c false otherwise
  inline bool event_is_valid() const
    { return dragging; }

  //! \return \c true if the dragged object is normal FLTK text (see Fl::copy() ), else \c false if it is an object derived from Flu_DND
  inline bool event_is_text() const
    { return( _text != 0 ); }

  //! \return \c true if the dragged object is an object derived from Flu_DND, else \c false if it is normal FLTK text (see Fl::copy() )
  inline bool event_is_other() const
    { return( _text == 0 ); }

  //! \return the text from Fl::copy() if this event is a text event (see event_is_text() )
  /*! \note This is valid only after the object has been dropped (i.e. in Flu_DND::on_dnd_drop() )*/
  inline const char* text() const
    { return _text; }

  //! \return the dragged object data as added in Flu_DND::dnd_grab() if this event is an "other" event (see event_is_other() )
  /*! \note This is valid only after the object has been dropped (i.e. in Flu_DND::on_dnd_drop() )*/
  inline void* data() const
    { return _data; }

  //! \return the type of the data object that was dropped. This is \c NULL for FLTK text events
  /*! \note This is valid only after the object has been dropped (i.e. in Flu_DND::on_dnd_drop() )*/
  inline const char* data_type() const
    { return _dataType; }

  //! \return \c true if the type of the data object that was dropped is equal to \b t, \c false otherwise
  inline bool is_data_type( const char *t ) const
    { if( !_dataType ) return 0; else return( strcmp( _dataType, t ) == 0 ); }

  //! \return the x coordinate (from Fl::event_x() ) of when the object was grabbed
  inline int grab_x() const
    { return _grab_x; }

  //! \return the y coordinate (from Fl::event_y() ) of when the object was grabbed
  inline int grab_y() const
    { return _grab_y; }

  //! \return the x coordinate (from Fl::event_x() ) of when the object was dropped
  inline int drop_x() const
    { return _drop_x; }

  //! \return the y coordinate (from Fl::event_y() ) of when the object was dropped
  inline int drop_y() const
    { return _drop_y; }

 private:

  bool dragging;
  void *objUnderMouse;
  char *_text, *_dataType;
  void *_data;
  int _grab_x, _grab_y, _drop_x, _drop_y;
  bool exit;

  void clear();
};

//! This class augments the existing FLTK drag-n-drop feature, working with Flu_DND_Event to achieve new functionality
/*! It adds the ability to create specific DND objects, allowing classes that handle
  DND to discriminate between which objects are "allowed" to be dropped on them.

  Almost all functions are protected, since only a derived class should be in charge of what kinds of events
  to handle and what kinds of objects to support.
*/
class FLU_EXPORT Flu_DND
{
 public:

  //! Set the function that is called when the dragged object is dropped. This is called in addition to the member function on_dnd_drop()
  inline void dnd_callback( void (*cb)(const Flu_DND_Event*,void*), void *cbd = 0 )
    { dndCallback = cb; dndCallbackData = cbd; }

 protected:

  //! Default constructor
  Flu_DND( const char *thisType );

  //! Default destructor
  virtual ~Flu_DND();

  //! See Flu_DND_Event::event_is_text()
  inline bool dnd_event_is_text() const
    { return( dndEvent.dragging && !dndEvent._data ); }

  //! See Flu_DND_Event::event_is_other()
  inline bool dnd_event_is_other() const
    { return( dndEvent.dragging && dndEvent._data ); }

  //! See Flu_DND_Event::event_is_valid()
  inline bool dnd_is_dragging() const
    { return dndEvent.dragging; }

  //! See Flu_DND_Event::is_data_type()
  inline bool dnd_is_data_type( const char *t ) const
    { return dndEvent.is_data_type( t ); }

  //! Set whether standard FLTK text events can be dropped on this object
  inline void dnd_allow_text( bool b )
    { allowTextEvents = b; }

  //! Get whether standard FLTK text events can be dropped on this object
  inline bool dnd_allow_text() const
    { return allowTextEvents; }

  //! Set whether this object can be dragged to another object
  inline void dnd_allow_dragging( bool b )
    { allowDragging = b; }

  //! Get whether this object can be dragged to another object
  inline bool dnd_allow_dragging() const
    { return allowDragging; }

  //! Set whether this object can have other objects dropped on it
  inline void dnd_allow_dropping( bool b )
    { allowDropping = b; }

  //! Get whether this object can have other objects dropped on it
  inline bool dnd_allow_dropping() const
    { return allowDropping; }

  //! Add type \b t to the list of types that are allowed to be dropped on this object (up to a compiled maximum of \c \b FLU_DND_MAX_TYPES)
  void dnd_allow_type( const char *t );

  //! \return \c true if type \b t is allowed to be dropped on this object, \c false otherwise
  bool dnd_type_allowed( const char *t ) const;

  //! Descendents should call this when they detect themselves being grabbed for a drag-n-drop
  void dnd_grab( void *data, const char *type );

  //! Descendents should call this at the start of their handle() method to handle DND processing
  int dnd_handle( int event );

  //! Descendents can override this to respond to when the mouse is let go during a drag-n-drop (regardless of whether the item was dropped on you)
  virtual void on_dnd_release();

  //! Descendents can override this to respond to when the mouse has entered you during a drag-n-drop
  virtual void on_dnd_enter();

  //! Descendents can override this to respond to when the mouse has left you during a drag-n-drop
  virtual void on_dnd_leave();

  //! Descendents should override this to respond to when the dragged object has been dropped on you
  virtual void on_dnd_drop( const Flu_DND_Event *e );

  //! Descendents should override this to indicate whether the currently dragged item is allowed to be dropped on you (for example, if the item can only be dropped at certain locations)
  virtual bool on_dnd_drag( int X, int Y );

 private:

  bool ok2drop();

  static Flu_DND_Event dndEvent;
  bool allowTextEvents, allowDragging, allowDropping;
  char* _thisType;
  char* allowedTypes[FLU_DND_MAX_TYPES];
  int nTypes;

  void (*dndCallback)(const Flu_DND_Event*,void*);
  void *dndCallbackData;

};

#endif
