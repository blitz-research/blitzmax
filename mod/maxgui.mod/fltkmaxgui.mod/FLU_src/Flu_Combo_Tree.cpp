// $Id: Flu_Combo_Tree.cpp,v 1.5 2004/08/02 14:18:16 jbryan Exp $

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
#include <FL/Fl.H>
#include <FL/fl_draw.H>
#include <string.h>
#include <stdlib.h>
#include <FL/math.h>

#include "FLU/Flu_Combo_Tree.h"

Flu_Combo_Tree :: Flu_Combo_Tree( int X, int Y, int W, int H, const char* l )
  : Flu_Combo_Box( X, Y, W, H, l ), tree(0,0,0,0)
{
  tree.callback( _cb, this );
  tree.selection_mode( FLU_SINGLE_SELECT );
  tree.when( FL_WHEN_RELEASE );
  set_combo_widget( &tree );
}

Flu_Combo_Tree :: ~Flu_Combo_Tree()
{
}

void Flu_Combo_Tree :: cb()
{
  if( tree.callback_reason() == FLU_SELECTED )
    selected( tree.callback_node()->find_path() );
}

void Flu_Combo_Tree :: _hilight( int x, int y )
{
  if( tree.inside_entry_area( x, y ) )
    tree.handle( FL_PUSH );
}

bool Flu_Combo_Tree :: _value( const char *v )
{
  // see if 'v' is in the tree, and if so, make it the current selection
  Flu_Tree_Browser::Node *n = tree.find( v );
  if( n )
    {
      tree.unselect_all();
      tree.set_hilighted( n );
      n->select( true );
      return true;
    }
  return false;
}

const char* Flu_Combo_Tree :: _next()
{
  Flu_Tree_Browser::Node *n = tree.get_selected( 1 );
  if( n )
    {
      Flu_Tree_Browser::Node *n2 = n->next();
      if( n2 )
	{
	  n->select( false );
	  n2->select( true );
	  tree.set_hilighted( n2 );
	  const char *path = n2->find_path();
	  return( strlen(path) ? path : NULL );
	}
    }
  return NULL;
}

const char* Flu_Combo_Tree :: _previous()
{
  Flu_Tree_Browser::Node *n = tree.get_selected( 1 );
  if( n )
    {
      Flu_Tree_Browser::Node *n2 = n->previous();
      if( n2 )
	{
	  if( n2->is_root() && !tree.show_root() )
	    return NULL;
	  n->select( false );
	  n2->select( true );
	  tree.set_hilighted( n2 );
	  const char *path = n2->find_path();
	  return( strlen(path) ? path : NULL );
	}
    }
  return NULL;
}
