// $Id: FluSimpleString.h,v 1.12 2003/11/27 01:09:04 jbryan Exp $

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



#ifndef _FLU_SIMPLE_STRING_H
#define _FLU_SIMPLE_STRING_H

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

#include "FLU/Flu_Enumerations.h"

//! A simple string object that works a lot like the STL string object
class FLU_EXPORT FluSimpleString
{

 public:

  //! Default constructor: sets to empty string ("")
  FluSimpleString();

  //! Allocates the string to be of length \b len. Does not set the buffer to any initial value
  FluSimpleString( unsigned int len );

  //! String copy constructor
  FluSimpleString( const char *s );

  //! Copy constructor
  FluSimpleString( const FluSimpleString& s );

  //! Default destructor
  ~FluSimpleString();

  //! \return a c-style nul terminated pointer to the string
  inline const char* c_str() const { return str; }

  //! \return how long the string is
  inline int size() const { return strlen(str); }

  //! Array operator
  inline char& operator [](int i) { return str[i]; }

  //! Array operator
  inline char operator [](int i) const { return str[i]; }

  //! \return the indicated substring of this string
  FluSimpleString substr( int pos, int len ) const;

  //! Convert this string to uppercase
  void upcase();

  //! Convert this string to lowercase
  void downcase();

  //! \return the first index of character \b c in this string, or -1 if \c is not in this string
  int find( char c ) const;

  //! \return the last index of character \b c in this string, or -1 if \c is not in this string
  int rfind( char c ) const;

  //! \return 0 if this string is equal to \b s, -1 if this string is lexigraphically less than \b s, 1 if this string is lexigraphically greater than \b s (uses c-std function \b strcmp )
  int compare( const FluSimpleString &s ) const;

  //! Same as compare(), except ignores the case of the string
  int casecompare( const FluSimpleString &s ) const;

  //! \return 0 if this string is equal to \b s, -1 if this string is lexigraphically less than \b s, 1 if this string is lexigraphically greater than \b s (uses c-std function \b strcmp )
  inline friend int compare( const FluSimpleString &s1, const FluSimpleString &s2 )
    { return s1.compare( s2 ); }

  //! Same as compare(), except ignores the case of the string
  inline friend int casecompare( const FluSimpleString &s1, const FluSimpleString &s2 )
    { return s1.casecompare( s2 ); }

  //! Add character \b c to the end of the string
  inline void push_back( char c )
    { char s[2] = { c, '\0' }; *this += s; }

  //! Alias for the \c = operator
  inline void copy( const FluSimpleString& s )
    { *this = s; }

  //! Alias for the \c = operator
  inline void copy( const char *s )
    { *this = s; }

  //! Copy the substring of \b s to this string
  inline void copy( const FluSimpleString& s, unsigned int start, unsigned int len )
    { copy( s.c_str(), start, len ); }

  //! Copy the substring of \b s to this string
  void copy( const char *s, unsigned int start, unsigned int len );

  //! Copy operator
  FluSimpleString& operator =( const char *s );

  //! Copy operator
  inline FluSimpleString& operator =( FluSimpleString s ) { return( *this = s.str ); }

  //! Less-than operator
  inline bool operator <( const FluSimpleString& s ) const { return( strcmp( str, s.str ) < 0 ); }

  //! Greater-than operator
  inline bool operator >( const FluSimpleString& s ) const { return( strcmp( str, s.str ) > 0 ); }

  //! Equality operator
  inline bool operator ==( const FluSimpleString& s ) const { return( strcmp( str, s.str ) == 0 ); }

  //! Inequality operator
  inline bool operator !=( const FluSimpleString& s ) const { return( strcmp( str, s.str ) != 0 ); }

  //! Concatenate operator
  inline friend FluSimpleString operator +( const char *s1, FluSimpleString s2 ) { FluSimpleString s = s1; s += s2; return s; }

  //! Concatenate operator
  inline friend FluSimpleString operator +( FluSimpleString s1, const char *s2 ) { FluSimpleString s = s1; s += s2; return s; }

  //! Concatenate operator
  inline friend FluSimpleString operator +( FluSimpleString s1, FluSimpleString s2 ) { FluSimpleString s = s1; s += s2; return s; }

  //! Concatenate assignment operator
  inline FluSimpleString& operator +=( const FluSimpleString& s ) { *this += s.str; return *this; }

  //! Concatenate assignment operator
  FluSimpleString& operator +=( const char *s );

 private:

  char *str;

};

#endif

