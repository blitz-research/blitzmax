// $Id: Flu_Spinner.h,v 1.11 2004/10/22 16:17:45 jbryan Exp $

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



#ifndef _FLU_SPINNER_H
#define _FLU_SPINNER_H

#include <FL/Fl_Valuator.H>
#include <FL/Fl_Input.H>
#include <FL/Fl_Group.H>

#include "FLU/Flu_Enumerations.h"

//! This class provides a simple spinner widget similar to Fl_Counter, except the manipulator buttons are vertical and you can click, click and hold, or click and drag to change the value
class FLU_EXPORT Flu_Spinner : public Fl_Valuator
{

  class NoTabInput : public Fl_Input
    {
    public:
      NoTabInput( Flu_Spinner *s, int x, int y, int w, int h, const char *l = 0 );
      int handle( int event );
      void draw();
      Flu_Spinner *spinner;
    };

public:

  //! Normal FLTK widget constructor
  Flu_Spinner( int x, int y, int w, int h, const char *l = 0 );

  //! Default destructor
  ~Flu_Spinner();

  //! Get whether the spinner automatically changes when you hold the button down
  inline bool enable_repeating() const
    { return _doRepeat; }

  //! Set whether the spinner automatically changes when you hold the button down
  inline void enable_repeating( bool b )
    { _doRepeat = b; }

  //! Set the auto repeating parameters
  /*! \param initialDelay is how long to wait before repeating starts. Default is 0.5 seconds
    \param initialTime is how long to wait between value changes. Default is 0.1 seconds (i.e. 10x per second)
    \param rapidDelay is how long to wait before repeating more quickly. Default is 2 seconds
    \param rapidTime is how long to wait between rapid value changes. Default is 0.02 seconds (i.e. 50x per second)
  */
  inline void repeat( float initialDelay, float initialTime, float rapidDelay, float rapidTime )
    { _initialDelay = initialDelay; _repeatTime[0] = initialTime; _rapidDelay = rapidDelay;_repeatTime[1] = rapidTime; }

  //! Get when the input calls the callback
  inline int input_when() const
    { return _input.when(); }

  //! Set when the input calls the callback
  inline void input_when( int w )
    { _input.when(w); }

  //! Get whether the input field can be edited. Default is \c true
  inline bool editable() const
    { return _editable; }

  //! Set whether the input field can be edited.
  inline void editable( bool b )
    { _editable = b; }

  //! Override of Fl_Widget::handle()
  int handle( int );

  //! Override of Fl_Widget::resize()
  void resize( int X, int Y, int W, int H );

  //! The default range for Fl_Valuators is [0,1]. This function sets the range of the spinner to +/- infinity
  inline void unlimited_range()
    { range( -3.4e+38f, 3.4e+38f ); }

  //! Set whether the value "wraps" to the range during interaction
  inline void wrap_range( bool b )
    { _wrapRange = b; }

  //! Set whether the value "wraps" to the range during interaction
  inline bool wrap_range() const
    { return _wrapRange; }

  //! Override of Fl_Valuator::precision()
  inline void precision( int p )
    { Fl_Valuator::precision(p); value_damage(); }

  //! Override of Fl_Valuator::value_damage()
  void value_damage();

  //! Override of Fl_Valuator::hide()
  inline void hide()
    { Fl_Valuator::hide(); _input.hide(); }

  //! Override of Fl_Valuator::show()
  inline void show()
    { Fl_Valuator::show(); _input.show(); }

  //! Get the font for the widget value
  inline Fl_Font valuefont() const { return (Fl_Font)_input.textfont(); }

  //! Set the font for the widget value
  inline void valuefont( uchar s ) { _input.textfont(s); }

  //! Get the size of the font for the widget value
  inline uchar valuesize() const { return _input.textsize(); }

  //! Set the size of the font for the widget value
  inline void valuesize( uchar s ) { _input.textsize(s); }

  //! Get the background color of the widget value
  inline Fl_Color valuecolor() const { return (Fl_Color)_input.color(); }

  //! Set the background color for the widget value
  inline void valuecolor( unsigned s ) { _input.color(s); }

  //! Set the background and selection color for the widget value
  inline void valuecolor( unsigned s, unsigned s1 ) { _input.color(s,s1); }

  //! Get the color of the font for the widget value
  inline Fl_Color valuefontcolor() const { return (Fl_Color)_input.textcolor(); }

  //! Set the color of the font for the widget value
  inline void valuefontcolor( unsigned s ) { _input.textcolor(s); }

protected:

  void _setvalue( double v );

  friend class NoTabInput;

  NoTabInput _input;
  uchar _valbox[2];
  bool _up, _pushed, _editable, _dragging;
  float _totalTime;
  double _lastValue;
  int _lastY;
  float _initialDelay, _repeatTime[2], _rapidDelay;
  bool _doRepeat, _wrapRange;

  static void input_cb( Fl_Widget*, void* v );
  static void repeat_callback(void *);
  void increment_cb();

protected:

  void draw();

};

#endif
