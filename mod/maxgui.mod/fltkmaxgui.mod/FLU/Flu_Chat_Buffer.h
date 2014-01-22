// $Id: Flu_Chat_Buffer.h,v 1.5 2003/08/20 16:29:40 jbryan Exp $

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



#ifndef _FLU_CHAT_BUFFER_H
#define _FLU_CHAT_BUFFER_H

/* fltk includes */
#include <FL/Fl.H>
#include <FL/Fl_Widget.H>
#include <FL/Fl_Scrollbar.H>
#include "FLU/Flu_Enumerations.h"

//! A class for drawing text messages in the style of a "chat buffer"
/*! This class is pretty much only useful for chatting. */
class FLU_EXPORT Flu_Chat_Buffer : public Fl_Widget
{

  class FLU_EXPORT MessageInfo
  {
  public:
    char type;
    char *handle;
    char *message;
    int handleW, messageW, height;
  };

 public:

  //! Normal FLTK widget constructor
  Flu_Chat_Buffer( int x, int y, int w, int h, const char *label = 0 );

  //! Default destructor
  virtual ~Flu_Chat_Buffer();

  //! Add a system message to the chat buffer using the system font and color
  void addSystemMessage( const char *msg );

  //! Add a message from a remote person to the chat buffer using the remote font and color
  void addRemoteMessage( const char *handle, const char *msg );

  //! Add a message from a local person to the chat buffer using the local font and color
  void addLocalMessage( const char *handle, const char *msg );

  //! Clear the contents of the buffer and set the maximum number of lines it can contain to \b maximumLines
  void clear( int maximumLines = 500 );

  //! Set the font and color to use when printing system messages
  /*! Default is FL_HELVETICA_ITALIC, FL_BLACK */
  inline void setSystemStyle( Fl_Font f, Fl_Color c )
    { systemFont = f; systemColor = c; }

  //! Set the font and color to use when printing the handle from a remote message
  /*! Default is FL_HELVETICA_BOLD, FL_RED  */
  inline void setRemoteHandleStyle( Fl_Font f, Fl_Color c )
    { remoteHandleFont = f; remoteHandleColor = c; }

  //! Set the font and color to use when printing the handle from a local message
  /*! Default is FL_HELVETICA_BOLD, FL_BLUE */
  inline void setLocalHandleStyle( Fl_Font f, Fl_Color c )
    { localHandleFont = f; localHandleColor = c; }

  //! Set the font and color to use when printing a remote message
  /*! Default is FL_HELVETICA, FL_RED */
  inline void setRemoteMessageStyle( Fl_Font f, Fl_Color c )
    { remoteMessageFont = f; remoteMessageColor = c; }

  //! Set the font and color to use when printing a local message
  //! Default is FL_HELVETICA, FL_BLUE */
  inline void setLocalMessageStyle( Fl_Font f, Fl_Color c )
    { localMessageFont = f; localMessageColor = c; }

  //! FLTK resize of this widget
  virtual void resize( int x, int y, int w, int h );

 protected:

  inline static void _scrollbarCB( Fl_Widget* w, void* arg )
    { ((Flu_Chat_Buffer*)arg)->scrollbarCB(); }
  void scrollbarCB();

  Fl_Font systemFont, remoteHandleFont, localHandleFont,
    remoteMessageFont, localMessageFont;
  Fl_Color systemColor, remoteHandleColor, localHandleColor,
    remoteMessageColor, localMessageColor;

  MessageInfo *buffer;
  int maxLines, totalLines, currentLine;
  bool recomputeFootprint;

  virtual void draw();

  Fl_Scrollbar *scrollbar;

  void _addMessage( char type, char *handle, char *msg );
  void _computeMessageFootprint();

};

#endif
