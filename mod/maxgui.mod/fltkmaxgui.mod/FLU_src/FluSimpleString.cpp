// $Id: FluSimpleString.cpp,v 1.8 2003/11/27 01:09:05 jbryan Exp $

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



#include "FLU/FluSimpleString.h"

FluSimpleString :: FluSimpleString()
{
  str = strdup("");
}

FluSimpleString :: FluSimpleString( unsigned int len )
{
  if( len > 0 )
    str = (char*)malloc( len );
  else
    str = strdup("");
}

FluSimpleString :: FluSimpleString( const char *s )
{
  str = strdup("");
  *this = s;
}

FluSimpleString :: FluSimpleString( const FluSimpleString& s )
{
  str = strdup("");
  *this = s.str;
}

FluSimpleString :: ~FluSimpleString()
{
  if(str)
    free(str);
}

void FluSimpleString :: copy( const char *s, unsigned int start, unsigned int len )
{
  if( len == 0 ) return;
  if( s == 0 ) return;
  if( start+len > strlen(s) ) return;
  if(str) free(str);
  str = (char*)malloc( len+1 );
  strncpy( str, s+start, len );
  str[len] = '\0';
}

int FluSimpleString :: compare( const FluSimpleString &s ) const
{
  return strcmp( str, s.str );
}

int FluSimpleString :: casecompare( const FluSimpleString &s ) const
{
  FluSimpleString s1(str), s2(s);
  s1.upcase();
  s2.upcase();
  return strcmp( s1.str, s2.str );
}

void FluSimpleString :: upcase()
{
  unsigned int l = strlen(str);
  for( unsigned int i = 0; i < l; i++ )
    str[i] = toupper( str[i] );
}

void FluSimpleString :: downcase()
{
  unsigned int l = strlen(str);
  for( unsigned int i = 0; i < l; i++ )
    str[i] = tolower( str[i] );
}

int FluSimpleString :: find( char c ) const
{
  const char *i = strchr( str, c );
  if( !i )
    return -1;
  else
    return i-str;
}

int FluSimpleString :: rfind( char c ) const
{
  const char *i = strrchr( str, c );
  if( !i )
    return -1;
  else
    return i-str;
}

FluSimpleString FluSimpleString :: substr( int pos, int len ) const
{
  if( (pos+len) <= 0 || (pos+len) > size() )
    return FluSimpleString("");
  else
    {
      char *buf = (char*)malloc( len+1 );
      strncpy( buf, str+pos, len );
      buf[len] = '\0';
      FluSimpleString s = buf;
      free( buf );
      return s;
    }
}

FluSimpleString& FluSimpleString :: operator =( const char *s )
{ 
  char* tmp;
  if(s==0)
    tmp = strdup("");
  else
    tmp = strdup(s);
  if(str)
    free(str);
  str = tmp;
  return *this;
}

FluSimpleString& FluSimpleString :: operator +=( const char *s )
{
  if( s==0 )
    s = "";
  char *old = strdup(str);
  int lold = strlen(old), ls = strlen(s);
  free(str);
  str = (char*)malloc( lold + ls + 1 );
  memcpy( str, old, lold );
  memcpy( str+lold, s, ls );
  str[lold+ls] = '\0';
  free(old);
  return *this;
}
