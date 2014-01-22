// $Id: Flu_Helpers.cpp,v 1.4 2003/12/31 16:17:11 jbryan Exp $

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



#include "FLU/Flu_Helpers.h"
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#define streq(a,b) (strcmp(a,b)==0)

static int fl_Full_Find_In_Menu( const Fl_Menu_* menu, const Fl_Menu_Item* items, int &which, const char* fullname )
{
  if( fullname == NULL )
    return -1;

  if( fullname[0] == '\0' )
    return -1;

  char *name = strdup( fullname );
  bool submenu = false;

  // strip off the first part of the path
  char* slash = strchr( name, '/' );
  if( slash )
    {
      *slash = '\0';
      submenu = true; // if there is a slash, then the first part is a submenu
    }

  // search for the name
  for(;;)
    {
      // if we're at the end, quit searching
      if( which >= menu->size() )
	{
	  return -1;
	}

      bool match = false;
      if( items[which].label() )
	match = streq( name, items[which].label() );
      else
	match = false;

      // see if the name matches the next menu item
      if( match )
	{
	  // if the path indicates this is a submenu...
	  if( submenu )
	    {
	      // ...but the menu item does not indicate that it is a submenu, then we have a problem
	      if( !items[which].submenu() )
		{
		  free(name);
		  return -1;
		}
	      // ...the menu item agrees that it is a submenu, so recurse on the remaining items and path
	      else
		{
		  fullname += (slash-name) + 1;
		  which++;
		  free(name);
		  return fl_Full_Find_In_Menu( menu, items, which, fullname );
		}
	    }
	  // we have an exact match and the the path indicates the item is not a submenu
	  else
	    {
	      // if the item disagrees, then we have a problem
	      //if( items[which].submenu() )
	      //{
	      //  free(name);
	      //  return -1;
	      //}
	      // otherwise the path and the item are in agreement that this is the actual item
	      // being searched for, so return it
	      //else
		{
		  free(name);
		  return which;
		}
	    }
	}
      // the name doesn't match, so skip to the next item
      else
	{
	  // if the item is a submenu, skip all its children
	  if( items[which].submenu() )
	    {
	      while( items[which].label() != 0 )
		which++;
	      which++; // increment one more to eat the end-of-submenu marker
	    }
	  // otherwise just skip the item
	  else
	    which++;
	}
    }
}

int fl_Full_Find_In_Menu( const Fl_Menu_* menu, const char* fullname )
{
  if( menu == NULL )
    return -1;
  if( fullname == NULL )
    return -1;
  const Fl_Menu_Item *items = menu->menu();

  // remove any leading '/' (there shouldn't be one...but just in case)
  if( fullname[0] == '/' )
    fullname++;

  // delete any 'flag' characters
  char *correctedName = strdup( fullname );
  {
    int index = 0;
    for( int i = 0; i < (int)strlen( fullname ); i++ )
      {
	if( fullname[i] == '&' && fullname[i+1] == '&' )
	  correctedName[index++] = '&';
	else if( fullname[i] == '&' )
	  continue;
	else if( fullname[i] == '_' )
	  continue;
	else
	  correctedName[index++] = fullname[i];
      }
    correctedName[index] = '\0';
  }

  // find the menu entry
  int which = 0;
  while( items[which].label() != 0 && which != menu->size() )
    {
      int val = fl_Full_Find_In_Menu( menu, items, which, correctedName );
      if( val != -1 )
	{
	  free( correctedName );
	  return val;
	}
    }

  free( correctedName );
  return -1;
}

int fl_Find_In_Menu( const Fl_Menu_* menu, const char* name )
{
  if( menu == NULL )
    return -1;
  if( name == NULL )
    return -1;
  const Fl_Menu_Item *items = menu->menu();

  for( int i = 0; i < menu->size(); i++ )
    {
      if( items[i].label() == NULL )
	continue;
      if( strlen( items[i].label() ) == 0 )
	continue;
      if( strcmp( name, items[i].label() ) == 0 )
	return i;
    }
  return -1;
}
