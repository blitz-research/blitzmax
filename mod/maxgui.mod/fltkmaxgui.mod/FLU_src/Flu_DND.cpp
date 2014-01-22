// $Id: Flu_DND.cpp,v 1.21 2004/08/18 11:06:38 jbryan Exp $

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



#include <stdio.h>
#include "FLU/Flu_DND.h"

Flu_DND_Event :: Flu_DND_Event()
{
  _text = _dataType = 0;
  clear();
}

Flu_DND_Event :: ~Flu_DND_Event()
{
  clear();
}

void Flu_DND_Event :: clear()
{
  // reset everything
  objUnderMouse = false;
  dragging = false;
  exit = false;
  if(_text) free(_text); _text = 0;
  if(_dataType) free(_dataType); _dataType = 0;
  _data = 0;
  _grab_x = _grab_y = _drop_x = _drop_y = 0;
}

Flu_DND_Event Flu_DND::dndEvent;

Flu_DND :: Flu_DND( const char *thisType )
{
  // initialize everything
  nTypes = 0;
  _thisType = strdup( thisType );
  dnd_allow_text( false );
  dnd_callback( 0 );
  allowDragging = allowDropping = true;
}

Flu_DND :: ~Flu_DND()
{
  // free all the stored types
  if( _thisType )
    free( _thisType );
  for( int i = 0; i < nTypes; i++ )
    free( allowedTypes[i] );
}

void Flu_DND :: dnd_allow_type( const char *t )
{
  if( nTypes >= FLU_DND_MAX_TYPES )
    return;
  allowedTypes[nTypes++] = strdup( t );
}

bool Flu_DND :: dnd_type_allowed( const char *t ) const
{
  for( int i = 0; i < nTypes; i++ )
    if( strcmp( allowedTypes[i], t ) == 0 )
      return true;
  return false;
}

void Flu_DND :: dnd_grab( void *data, const char *type )
{
  dndEvent.clear();
  if( !allowDragging || !data )
    return;
  // remember the event
  //printf( "dnd_grab %s %X\n", _thisType, this );
  dndEvent.dragging = true;
  dndEvent.exit = false;
  dndEvent.objUnderMouse = this;
  dndEvent._data = data;
  dndEvent._dataType = strdup( type );
  dndEvent._grab_x = Fl::event_x();
  dndEvent._grab_y = Fl::event_y();

  // start the fltk system-wide DND
  Fl::copy( " ", 1, 0 );
  Fl::dnd();
}

void Flu_DND :: on_dnd_enter()
{
}

void Flu_DND :: on_dnd_leave()
{
}

void Flu_DND :: on_dnd_drop( const Flu_DND_Event *e )
{
}

void Flu_DND :: on_dnd_release()
{
}

bool Flu_DND :: on_dnd_drag( int X, int Y )
{
  return true;
}

int Flu_DND :: dnd_handle( int event )
{
  // if dnd is on, then only DND events are generated
  // but, there appears to be a bug in fltk where an FL_NO_EVENT is generated if the mouse
  // is released when outside of any fltk widget. so, if we detect the NO_EVENT, and we are still
  // dragging, then we need to process it as a release
  if( dndEvent.dragging && event == FL_NO_EVENT )
    {
      if( dndEvent.exit ) // not in any widget
	{
	  // trash the event and return
	  //printf( "exit %s %X\n", _thisType, this );
	  dndEvent.clear();
	  return 1;
	}
      // otherwise the NO_EVENT is inside a widget. i don't know why a NO_EVENT is generated
      // since the event is inside a widget. but, whatever. at any rate, this object should process
      // it as a paste, only if it is the object the mouse is over (as tracked by dndEvent.objUnderMouse)
      if( dndEvent.objUnderMouse == this )
	{
	  //printf( "FL_NO_EVENT %s %X\n", _thisType, this );
	  event = FL_PASTE;
	}
    }

  //printf( "event %d %s %X\n", event, _thisType, this );

  switch( event )
    {
    case FL_DND_DRAG:
      {
	//printf( "FL_DND_DRAG %s %X\n", _thisType, this );

	// if we receive a drag event and we are not holding data, then it must be
	// from an fltk text widget

	// remember where the dragging occurs and check if it's ok for us
	// to drop the item here
	dndEvent.dragging = true;
	dndEvent.objUnderMouse = this;
	dndEvent._drop_x = Fl::event_x();
	dndEvent._drop_y = Fl::event_y();

	return ok2drop();
      }

    case FL_DND_RELEASE:
      //printf( "FL_DND_RELEASE %s %X\n", _thisType, this );
      on_dnd_release();
      return ok2drop();

      //case FL_UNFOCUS:
      //printf( "FL_UNFOCUS %s %X\n", _thisType, this );
      //return 1;

      //case FL_FOCUS:
      //printf( "FL_FOCUS %s %X\n", _thisType, this );
      //return 1;

    case FL_DND_ENTER:
      //printf( "FL_DND_ENTER %s %X\n", _thisType, this );
      dndEvent.exit = false;
      dndEvent.objUnderMouse = this;
      dndEvent._drop_x = Fl::event_x();
      dndEvent._drop_y = Fl::event_y();
      if( ok2drop() )  // if it's ok to drop, then it's ok to enter
	{
	  on_dnd_enter();
	  return 1;
	}
      else
	return 0;

    case FL_DND_LEAVE:
      //printf( "FL_DND_LEAVE %s %X\n", _thisType, this );
      dndEvent.exit = true;
      dndEvent.objUnderMouse = NULL;
      on_dnd_leave();
      return 1;

    case FL_PASTE:
      //printf( "FL_PASTE %s %X\n", _thisType, this );
      on_dnd_release();
      // if the mouse is not inside a DND widget, then there's nothing to do
      if( dndEvent.exit )
	{
	  dndEvent.clear();
	  return 0;
	}

      //if( dndEvent.objUnderMouse != this )
      //return 0;

      // if there's no data, then this paste is generated from an FLTK text DND event
      if( !dndEvent.data() )
	{
	  dndEvent.clear();
	  dndEvent._text = strdup( Fl::event_text() );
	}
      dndEvent._drop_x = Fl::event_x();
      dndEvent._drop_y = Fl::event_y();

      // if it's ok to drop, then call the drop processing members
      if( true )
	{
	  if( dndCallback )
	    dndCallback( &dndEvent, dndCallbackData );
	  on_dnd_drop(&dndEvent);
	  dndEvent.clear();
	  return 1;
	}
      else
	{
	  dndEvent.clear();
	  return 0;
	}

    default:
      // just in case
      //printf( "event: %d\n", event );
      if( dndEvent.exit )
	{
	  on_dnd_release();
	  dndEvent.clear();
	}
      break;
    }
  return 0;
}

bool Flu_DND :: ok2drop()
{
  if( !allowDropping )
    return false;

  if( dndEvent.data() )  // see if the dnd event is valid
    {
      // check if the source type is allowed by this class
      if( !dnd_type_allowed( dndEvent.data_type() ) )
	return false;
    }
  else if( !allowTextEvents ) // event is a normal FLTK text dnd event
    return false;

  return on_dnd_drag( Fl::event_x(), Fl::event_y() );
}
