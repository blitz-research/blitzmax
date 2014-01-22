// $Id: Flu_Chat_Buffer.cpp,v 1.7 2003/08/20 16:29:44 jbryan Exp $

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



#include <FL/fl_draw.H>
#include "FLU/Flu_Chat_Buffer.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define X_OFFSET 5

Flu_Chat_Buffer :: Flu_Chat_Buffer( int x, int y, int w, int h, const char *label )
  : Fl_Widget( x, y, w, h, label )
{
  buffer = NULL;
  scrollbar = new Fl_Scrollbar( x+w-22, y+2, 20, h-4 );
  scrollbar->linesize( 1 );
  scrollbar->callback( _scrollbarCB, this );

  box( FL_DOWN_BOX );
  color( FL_WHITE );

  setSystemStyle( FL_HELVETICA_ITALIC, FL_BLACK );
  setRemoteHandleStyle( FL_HELVETICA_BOLD, FL_RED );
  setLocalHandleStyle( FL_HELVETICA_BOLD, FL_BLUE );
  setRemoteMessageStyle( FL_HELVETICA, FL_RED );
  setLocalMessageStyle( FL_HELVETICA, FL_BLUE );

  clear();
}

Flu_Chat_Buffer :: ~Flu_Chat_Buffer()
{
  clear( 0 );
}

void Flu_Chat_Buffer :: draw()
{
  if( recomputeFootprint )
    _computeMessageFootprint();

  // draw the background box
  draw_box();

  // resize the scrollbar to be a constant width
  scrollbar->resize( x()+w()-22, y()+2, 20, h()-4 );
  scrollbar->redraw();

  int height = h()-4;

  int line;
  if( ( currentLine == 0 ) && ( totalLines == 0 ) )
    return;

  line = currentLine - 1 - scrollbar->value();

  fl_push_clip( x()+2, y()+2, w()-4, h()-4 );
  while( height >= 0 )
    {
      switch( buffer[line].type )
	{

	case 'S':
	  {
	    height -= buffer[line].height;
	    fl_color( systemColor );
	    fl_font( systemFont, FL_NORMAL_SIZE );
	    fl_draw( buffer[line].message, x()+X_OFFSET, y()+height,
		     buffer[line].messageW, buffer[line].height, (Fl_Align)(FL_ALIGN_TOP_LEFT | FL_ALIGN_WRAP), NULL, 0 );
	  }
	  break;

	case 'R':
	  {
	    height -= buffer[line].height;
	    fl_color( remoteHandleColor );
	    fl_font( remoteHandleFont, FL_NORMAL_SIZE );
	    fl_draw( buffer[line].handle, x()+X_OFFSET, y()+height,
		     buffer[line].handleW, buffer[line].height, (Fl_Align)(FL_ALIGN_TOP_LEFT | FL_ALIGN_WRAP), NULL, 0 );
	    fl_color( remoteMessageColor );
	    fl_font( remoteMessageFont, FL_NORMAL_SIZE );
	    fl_draw( buffer[line].message, x()+X_OFFSET+buffer[line].handleW, y()+height,
		     buffer[line].messageW, buffer[line].height, (Fl_Align)(FL_ALIGN_TOP_LEFT | FL_ALIGN_WRAP), NULL, 0 );
	  }
	  break;

	case 'L':
	  {
	    height -= buffer[line].height;
	    fl_color( localHandleColor );
	    fl_font( localHandleFont, FL_NORMAL_SIZE );
	    fl_draw( buffer[line].handle, x()+X_OFFSET, y()+height,
		     buffer[line].handleW, buffer[line].height, (Fl_Align)(FL_ALIGN_TOP_LEFT | FL_ALIGN_WRAP), NULL, 0 );
	    fl_color( localMessageColor );
	    fl_font( localMessageFont, FL_NORMAL_SIZE );
	    fl_draw( buffer[line].message, x()+X_OFFSET+buffer[line].handleW, y()+height,
		     buffer[line].messageW, buffer[line].height, (Fl_Align)(FL_ALIGN_TOP_LEFT | FL_ALIGN_WRAP), NULL, 0 );
	  }
	  break;

	}

      if( ( line == 0 ) && ( totalLines < maxLines ) )
	break;

      if( line == 0 )
	line = totalLines - 1;
      else
	line--;
    }
  fl_pop_clip();
}

void Flu_Chat_Buffer :: scrollbarCB()
{
  redraw();
}

void Flu_Chat_Buffer :: _addMessage( char type, char *handle, char *msg )
{
  buffer[currentLine].type = type;
  buffer[currentLine].handle = handle;
  buffer[currentLine].message = msg;

  // increment the current line, and wrap to the beginning of the buffer
  // if necessary
  currentLine = (currentLine+1) % maxLines;

  // increment the total lines (no more than maxLines)
  totalLines = ( totalLines < maxLines ) ? totalLines+1 : maxLines;

  recomputeFootprint = true;

  redraw();
}

void Flu_Chat_Buffer :: addSystemMessage( const char *msg )
{
  if( !buffer || !msg )
    return;
  if( strlen( msg ) == 0 )
    return;

  _addMessage( 'S', NULL, strdup(msg) );
}

void Flu_Chat_Buffer :: addRemoteMessage( const char *handle, const char *msg )
{
  if( !buffer || !handle || !msg )
    return;
  if( ( strlen( handle ) == 0 ) || ( strlen( msg ) == 0 ) )
    return;

  _addMessage( 'R', strdup(handle), strdup(msg) );
}

void Flu_Chat_Buffer :: addLocalMessage( const char *handle, const char *msg )
{
  if( !buffer || !handle || !msg )
    return;
  if( ( strlen( handle ) == 0 ) || ( strlen( msg ) == 0 ) )
    return;

  _addMessage( 'L', strdup(handle), strdup(msg) );
}

void Flu_Chat_Buffer :: clear( int maximumLines )
{
  recomputeFootprint = true;

  if( buffer )
    {
      for( int i = 0; i < maxLines; i++ )
	{
	  if( buffer[i].handle )
	    free( buffer[i].handle );
	  if( buffer[i].message )
	    free( buffer[i].message );
	}
      free( buffer );
      buffer = NULL;
    }

  maxLines = maximumLines;
  if( maxLines == 0 )
    return;

  buffer = (MessageInfo*)malloc( maxLines * sizeof(MessageInfo) );
  for( int i = 0; i < maxLines; i++ )
    {
      buffer[i].handle = buffer[i].message = NULL;
      buffer[i].type = 0; // empty
    }
  totalLines = currentLine = 0;
}

void Flu_Chat_Buffer :: _computeMessageFootprint()
{
  recomputeFootprint = false;

  // restrict the width calculation to account for the scrollbar
  int width = w() - scrollbar->w() - X_OFFSET;
  int linesPastHeight = 0;
  int totalHeight = 0;
  for( int i = 0; i < totalLines; i++ )
    {
      switch( buffer[i].type )
	{

	case 'S':
	  {
	    int tw = width, th;

	    // set the font and color for system messages
	    fl_color( systemColor );
	    fl_font( systemFont, FL_NORMAL_SIZE );

	    // measure how big the message is
	    fl_measure( buffer[i].message, tw, th );
	    buffer[i].messageW = tw;
	    buffer[i].height = th;

	    totalHeight += buffer[i].height;
	    if( totalHeight > h() )
	      linesPastHeight++;
	  }
	  break;

	case 'R':
	  {
	    int tw = width, hh, mh;

	    // set the font and color for remote handles
	    fl_color( remoteHandleColor );
	    fl_font( remoteHandleFont, FL_NORMAL_SIZE );

	    // measure how big the handle is
	    fl_measure( buffer[i].handle, tw, hh );
	    buffer[i].handleW = tw;

	    // set the font and color for remote messages, and adjust the width so the message
	    // is aligned with the end of the handle
	    fl_color( remoteMessageColor );
	    fl_font( remoteMessageFont, FL_NORMAL_SIZE );
	    tw = width - tw;

	    // measure how big the message is
	    fl_measure( buffer[i].message, tw, mh );
	    buffer[i].messageW = tw;

	    // increase total height by max of handle height and message height
	    buffer[i].height = ( mh > hh ) ? mh : hh;
	    totalHeight += buffer[i].height;
	    if( totalHeight > h() )
	      linesPastHeight++;
	  }
	  break;

	case 'L':
	  {
	    int tw = width, hh, mh;

	    // set the font and color for local handles
	    fl_color( localHandleColor );
	    fl_font( localHandleFont, FL_NORMAL_SIZE );

	    // measure how big the handle is
	    fl_measure( buffer[i].handle, tw, hh );
	    buffer[i].handleW = tw;

	    // set the font and color for local messages, and adjust the width so the message
	    // is aligned with the end of the handle
	    fl_color( localMessageColor );
	    fl_font( localMessageFont, FL_NORMAL_SIZE );
	    tw = width - tw;

	    // measure how big the message is
	    fl_measure( buffer[i].message, tw, mh );
	    buffer[i].messageW = tw;

	    // increase total height by max of handle height and message height
	    buffer[i].height = ( mh > hh ) ? mh : hh;
	    totalHeight += buffer[i].height;
	    if( totalHeight > h() )
	      linesPastHeight++;
	  }
	  break;

	}
      
    }

  scrollbar->range( linesPastHeight, 0 );
  float size = float(h()) / float(totalHeight);
  if( size > 1.0f )
    size = 1.0f;
  if( size < 0.08f )
    size = 0.08f;
  scrollbar->slider_size( size );

  redraw();
}

void Flu_Chat_Buffer :: resize( int x, int y, int w, int h )
{
  Fl_Widget::resize( x, y, w, h );
  recomputeFootprint = true;
}
