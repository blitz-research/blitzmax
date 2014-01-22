// $Id: Flu_Tree_Browser.cpp,v 1.126 2004/11/05 17:03:20 jbryan Exp $

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



#include <FL/Fl.H>
#include <FL/fl_draw.H>
#include <FL/math.h>
#include <stdlib.h>

#include "FLU/Flu_Tree_Browser.h"
#include "FLU/flu_pixmaps.h"

#define MAX( x, y ) ( (x)>(y) ? (x) : (y) )
#define MIN( x, y ) ( (x)<(y) ? (x) : (y) )
#define ABS( x ) ( (x)>0 ? (x) : -(x) )
#define LERP( t, x0, x1 ) ( (x0) + (t)*( (x1) - (x0) ) )

bool Flu_Tree_Browser::USE_FLU_WIDGET_CALLBACK = false;

#ifdef USE_FLU_DND
Flu_Tree_Browser :: DND_Object :: DND_Object() : Flu_DND( "DND_Object" )
{
}
#endif

Flu_Tree_Browser :: IntStack :: IntStack()
{
  _list = NULL;
  _size = _bufferSize = 0;
}

Flu_Tree_Browser :: IntStack :: IntStack( const Flu_Tree_Browser::IntStack& s )
{
  _list = NULL;
  _size = _bufferSize = 0;
  *this = s;
}

Flu_Tree_Browser :: IntStack :: ~IntStack()
{
  clear();
}

Flu_Tree_Browser::IntStack& Flu_Tree_Browser :: IntStack :: operator =( const Flu_Tree_Browser::IntStack& s )
{
  clear();
  if( s._size )
    {
      _list = (int*)malloc( s._size*sizeof(int) );
      memcpy( _list, s._list, s._size*sizeof(int) );
      _size = _bufferSize = s._size;
    }
  return *this;
}

void Flu_Tree_Browser :: IntStack :: push( int i )
{
  if( _size == _bufferSize )
    {
      // allocate a new list
      _bufferSize += 4;
      int *newList = (int*)malloc( _bufferSize*sizeof(int) );
      // copy the old list
      if( _size > 0 )
	memcpy( newList, _list, _size*sizeof(int) );
      if( _list )
	free( _list );
      _list = newList;
    }
  // add the new item
  _list[_size] = i;
  _size++;
}

int Flu_Tree_Browser :: IntStack :: pop()
{
  if( _size == 0 )
    return 0;
  int val = _list[_size];
  _size--;
  return val;
}

void Flu_Tree_Browser :: IntStack :: clear()
{
  if( _list )
    free( _list );
  _list = NULL;
  _size = _bufferSize = 0;
}

Flu_Tree_Browser :: NodeList :: NodeList()
{
  _nodes = NULL;
  _nNodes = _size = 0;
}

Flu_Tree_Browser :: NodeList :: ~NodeList()
{
  clear();
}

typedef Flu_Tree_Browser::Node* NodeP;

bool Flu_Tree_Browser :: NodeList :: search( const char *n, int &index )
{
  index = _nNodes;
  if( _nNodes == 0 )
    return false;

  // we know we have at least one node. so use it to get the RData struct to find out what
  // the insertion mode is
  int iMode = _nodes[0]->tree->insertion_mode();

  if( iMode == FLU_INSERT_SORTED || iMode == FLU_INSERT_SORTED_REVERSE )
    return( binSearch( n, index ) );
  else
    return( linSearch( n, index ) );
}

bool Flu_Tree_Browser :: NodeList :: search( Node *n, int &index )
{
  index = _nNodes;
  if( _nNodes == 0 )
    return false;

  // we know we have at least one node. so use it to get the RData struct to find out what
  // the insertion mode is
  int iMode = _nodes[0]->tree->insertion_mode();

  if( iMode == FLU_INSERT_SORTED || iMode == FLU_INSERT_SORTED_REVERSE )
    return( binSearch( n, index ) );
  else
    return( linSearch( n, index ) );
}

bool Flu_Tree_Browser :: NodeList :: linSearch( const char *n, int &index )
{
  index = _nNodes;
  for( int i = 0; i < _nNodes; i++ )
    {
      if( strcmp( n, _nodes[i]->label() ) == 0 )
	{
	  index = i;
	  return true;
	}
    }
  return false;
}

bool Flu_Tree_Browser :: NodeList :: linSearch( Node *n, int &index )
{
  index = _nNodes;
  for( int i = 0; i < _nNodes; i++ )
    {
      if( n == _nodes[i] )
	{
	  index = i;
	  return true;
	}
    }
  return false;
}

bool Flu_Tree_Browser :: NodeList :: binSearch( Node *n, int &index )
{
  if( binSearch( n->label(), index ) )
    {
      // the search found the first node with the label. since there are identical entries
      // allowed, it may not be the actual node we want. therefore search forward until we find it
      for( ; index < _nNodes; index++ )
	if( _nodes[index] == n )
	  return true;
      return false;
    }
  else
    return false;
}

bool Flu_Tree_Browser :: NodeList :: binSearch( const char *n, int &index )
{
  // do a binary search for a child with name == "n"
  // return true if the child is found, and store its index in "index"
  // return false if the child is not found, and store the index it would
  // be in in "index"

  // special case: no nodes
  if( _nNodes == 0 )
    {
      index = 0;
      return false;
    }

  // we know we have at least one node. so use it to get the RData struct to find out what
  // the insertion mode is
  int iMode = _nodes[0]->tree->insertion_mode();

  // special case: 1 node
  if( _nNodes == 1 )
    {
      int val = strcmp( n, _nodes[0]->label() );
      if( iMode == FLU_INSERT_SORTED_REVERSE )
	val *= -1;
      if( val == 0 )
	{
	  index = 0;
	  return true;
	}
      else if( val < 0 )
	index = 0;
      else
	index = 1;
      return false;
    }

  int first = 0, last = _nNodes - 1;
  int val1, val2, mVal;
  for(;;)
    {
      // the range is down to 2 nodes
      if( last == first + 1 )
	{
	  val1 = strcmp( n, _nodes[first]->label() );
	  if( iMode == FLU_INSERT_SORTED_REVERSE )
	    val1 = -val1;
	  if( val1 < 0 )
	    {
	      index = first;
	      return false;
	    }
	  else if( val1 == 0 )
	    {
	      index = first;
	      break;
	    }
	  val2 = strcmp( n, _nodes[last]->label() );
	  if( iMode == FLU_INSERT_SORTED_REVERSE )
	    val2 = -val2;
	  if( val2 < 0 )
	    {
	      index = last;
	      return false;
	    }
	  else if( val2 == 0 )
	    {
	      index = last;
	      break;
	    }
	  else
	    {
	      index = last+1;
	      return false;
	    }
	}

      // pick which half of the array to search next
      int midpoint = first + ((last-first)>>1);
      mVal = strcmp( n, _nodes[midpoint]->label() );
      if( iMode == FLU_INSERT_SORTED_REVERSE )
	mVal = -mVal;
      if( mVal < 0 )
	last = midpoint;
      else if( mVal > 0 )
	first = midpoint;
      else
	{
	  index = midpoint;
	  break;
	}
    }

  // we found *a* node equal to "n", now find the first node equal to "n"
  // by searching until we hit a node not equal to "n"
  for( first = index; first > 0; first-- )
    if( strcmp( n, _nodes[first-1]->label() ) != 0 )
      break;
  index = first;

  return true;
}

int Flu_Tree_Browser :: NodeList :: compareNodes( const void *arg1, const void* arg2 )
{
  Flu_Tree_Browser::Node *n1 = *((Flu_Tree_Browser::Node**)arg1), *n2 = *((Flu_Tree_Browser::Node**)arg2);
  return strcmp( n1->text.c_str(), n2->text.c_str() );
}

int Flu_Tree_Browser :: NodeList :: reverseCompareNodes( const void *arg1, const void* arg2 )
{
  Flu_Tree_Browser::Node *n1 = *((Flu_Tree_Browser::Node**)arg1), *n2 = *((Flu_Tree_Browser::Node**)arg2);
  return( -strcmp( n1->text.c_str(), n2->text.c_str() ) );
}

void Flu_Tree_Browser :: NodeList :: sort()
{
  if( _nNodes )
    {
      // we know we have at least one node. so use it to get the RData struct to find out what
      // the insertion mode is
      int iMode = _nodes[0]->tree->insertion_mode();
      if( iMode == FLU_INSERT_SORTED )
	qsort( _nodes, _nNodes, sizeof(Node*), compareNodes );
      else if( iMode == FLU_INSERT_SORTED_REVERSE )
	qsort( _nodes, _nNodes, sizeof(Node*), reverseCompareNodes );
    }
}

Flu_Tree_Browser::Node* Flu_Tree_Browser :: Node :: insert( const char* fullpath, int pos )
{
  // insert the new node at the back of the tree
  int imode = tree->insertion_mode();
  tree->insertion_mode( FLU_INSERT_BACK );
  Node *n = add( fullpath );
  tree->insertion_mode( imode );
  if( !n ) return NULL;
  // find the node at position "pos" and
  // move the new node before it, so it takes over position "pos"
  if( pos < 0 ) pos = 0;
  if( pos >= children() ) pos = children()-1;
  move( n, MOVE_BEFORE, child(pos) );
  return n;
}

Flu_Tree_Browser::Node* Flu_Tree_Browser :: Node :: insert_branch( const char* fullpath, int pos )
{
  FluSimpleString p( fullpath );
  if( p.size() && p[p.size()-1] != '/' && p[p.size()-1] != '\\' ) p += "/";
  return insert( p.c_str(), pos );
}

Flu_Tree_Browser::Node* Flu_Tree_Browser :: Node :: insert_leaf( const char* fullpath, int pos )
{
  FluSimpleString p( fullpath );
  if( p.size() && ( p[p.size()-1] == '/' || p[p.size()-1] == '\\' ) ) p[p.size()-1] = '\0';
  return insert( p.c_str(), pos );
}

bool Flu_Tree_Browser :: Node :: move( int pos )
{
  // get this node's position
  int i = index();
  if( i == -1 ) return false;
  // get the node in our parent at index "pos"
  if( !parent() ) return false;
  if( pos < 0 ) pos = 0;
  if( pos >= parent()->children() ) pos = parent()->children()-1;
  Node *n = parent()->child( pos );
  // move this node to be before its sibling, so it takes over position "pos"
  return move( this, MOVE_BEFORE, n );
}

bool Flu_Tree_Browser :: Node :: swap( Node* n1, Node* n2 )
{
  if( n1->tree != n2->tree ) return false;
  Node *p1 = n1->parent(), *p2 = n2->parent();
  if( !p1 || !p2 ) return false;
  int i, index1 = -1, index2 = -1;
  for( i = 0; i < p1->children(); i++ )
    {
      if( p1->child(i) == n1 )
	{
	  index1 = i;
	  break;
	}
    }
  if( index1 == -1 ) return false;
  for( i = 0; i < p2->children(); i++ )
    {
      if( p2->child(i) == n2 )
	{
	  index2 = i;
	  break;
	}
    }
  if( index2 == -1 ) return false;
  p1->_children._nodes[index1] = n2;
  p2->_children._nodes[index2] = n1;
  return true;
}

bool Flu_Tree_Browser :: Node :: move( Node* n1, int where, Node* n2 )
{
  if( isMoveValid( n1, where, n2 ) )
    return( NodeList::move( n1, where, n2 ) );
  else
    return false;
}

void Flu_Tree_Browser :: Node :: sort()
{
  _children.sort();
  for( int i = 0; i < _children.size(); i++ )
    _children.child(i)->sort();
}

bool Flu_Tree_Browser :: Node :: is_ancestor( Node* n )
{
  Node *p = parent();
  while( p )
    {
      if( p == n )
	return true;
      else
	p = p->parent();
    }
  return false;
}

bool Flu_Tree_Browser :: Node :: is_descendent( Node* n )
{
  return n->is_ancestor( this );
}

bool Flu_Tree_Browser :: NodeList :: move( Node* n1, int where, Node* n2 )
{
  if( !n1 || !n2 )
    return false;

  if( n1->tree )
    n1->tree->redraw();
  if( n2->tree )
    n2->tree->redraw();

  // try to move n1 to the first child position of n2
  if( where == MOVE_INSIDE )
    {
      if( !n2->is_branch() )
	return false;
      // get the parent of n1
      Node* p1 = n1->parent();
      if( p1 )
	// remove n1 from its parent's list
	p1->_children.erase( n1 );
      // insert into n2
      int iMode = n1->tree->insertion_mode();
      if( iMode == FLU_INSERT_SORTED || iMode == FLU_INSERT_SORTED_REVERSE )
	n2->_children.add( n1 );
      else
	n2->_children.add( n1, 0 );
      // update the parent of n1
      n1->_parent = n2;
      return true;
    }

  // find the position of n2 in its parent's list
  Node* p2 = n2->parent();
  if( !p2 )
    return false;
  int index = 0, removed = -1;
  if( p2->_children.search( n2, index ) )
    {
      // get the parent of n1
      Node* p1 = n1->parent();
      if( p1 )
	// remove n1 from its parent's list. remember the position it was removed from
	removed = p1->_children.erase( n1 );

      // if n1 and n2 have the same parent, and if n1 came before the spot where
      // n2 will be inserted, then our indexing is off by one because n1 has been removed
      if( p1 == p2 && removed <= index )
	index--;

      if( where == MOVE_AFTER )
       index++;

      // insert n1 at the proper position
      p2->_children.add( n1, index );

      // update the parent of n1
      n1->_parent = p2;
    }

  return true;
}

void Flu_Tree_Browser :: NodeList :: add( Node* n, int position )
{
  int i, index;
  int mode = n->tree->insertion_mode();

  // if the list is out of room, allocate a new one that's bigger
  if( _nNodes == _size )
    {
      int newSize = ( _size == 0 ) ? 1 : _size*2; // double the size of the old list (same behavior as STL vector)
      // allocate the new list
      Node** newNodes = new NodeP[ newSize ];
      // copy the old list to the new list
      memcpy( newNodes, _nodes, _nNodes*sizeof(Node*) );
      // delete the old list and replace it with the new list
      delete[] _nodes;
      //n->tree->rdata.cbNode = NULL;
      _nodes = newNodes;
      _size = newSize;
    }

  if( position >= 0 )
    {
      if( position > _nNodes )
	index = _nNodes;
      else
	index = position;
    }
  else if( mode == FLU_INSERT_SORTED || mode == FLU_INSERT_SORTED_REVERSE )
    {
      // search through the list until we find where to insert the node
      binSearch( n->label(), index );
    }
  else if( mode == FLU_INSERT_FRONT )
    {
      index = 0;
    }
  else if( mode == FLU_INSERT_BACK )
    {
      index = _nNodes;
    }
  else
    return;

  // shift all entries from the new insertion point down one spot
  // to make room for the new node
  for( i = _nNodes - 1; i >= index; i-- )
    _nodes[i+1] = _nodes[i];

  // add the new node
  _nodes[index] = n;

  _nNodes++;
}

int Flu_Tree_Browser :: NodeList :: erase( Node *n )
{
  if( n == NULL )
    return -1;

  int index;
  if( search( n, index ) )
    {
      // move all the others down one spot to remove the node
      for( int i = index; i < _nNodes-1; i++ )
	_nodes[i] = _nodes[i+1];
      _nNodes--;

      return index;
    }
  return -1;
}

int Flu_Tree_Browser :: NodeList :: erase( const char* n )
{
  if( _nNodes == 0 )
    return -1;

  int index;
  if( search( n, index ) )
    {
      // move all the others down one spot to remove the node
      for( int i = index; i < _nNodes-1; i++ )
	_nodes[i] = _nodes[i+1];
      _nNodes--;
      return index;
    }
  return -1;
}

void Flu_Tree_Browser :: NodeList :: erase( int n )
{
  // make sure n is in range
  if( ( n < 0 ) || ( n >= _nNodes ) )
    return;

  // move all the others down one spot to remove the node
  for( int i = n; i < _nNodes-1; i++ )
    _nodes[i] = _nodes[i+1];

  _nNodes--;
}

void Flu_Tree_Browser :: NodeList :: clear()
{
  if( _nodes )
    {
      //if( _nNodes )
      //if( _nodes[0] )
      //  _nodes[0]->tree->rdata.cbNode = NULL;
      delete[] _nodes;
    }
  _nodes = NULL;
  _nNodes = _size = 0;
}

int Flu_Tree_Browser :: NodeList :: findNum( const char *n )
{
  if( ( _nNodes == 0 ) || ( n == 0 ) )
    return 0;

  // see if there is a first node equal to "n"
  int index, last;
  if( !search( n, index ) )
    return 0;

  // now search forward until we hit a node not equal to "n"
  for( last = index; last < _nNodes-1; last++ )
    if( strcmp( n, _nodes[last+1]->label() ) != 0 )
      break;

  return last - index + 1;
}

Flu_Tree_Browser::Node* Flu_Tree_Browser :: NodeList :: find( const char* n, int which )
{
  if( ( _nNodes == 0 ) || ( n == 0 ) || ( which == 0 ) )
    return NULL;

  // see if there is a first node equal to "n"
  int index, first;
  if( !search( n, first ) )
    return NULL;

  // now search forward and try to find the which'th node named "n"
  int total = 0;
  for( index = first; index < _nNodes; index++ )
    {
      if( strcmp( n, _nodes[index]->label() ) == 0 )
	{
	  total++;
	  if( total == which )
	    break;
	}
      else
	break;
    }
  if( total != which )
    return NULL;

  return _nodes[index];
}

#define SCROLL_SIZE 15

Flu_Tree_Browser :: Flu_Tree_Browser( int x, int y, int w, int h, const char *l )
  : Fl_Group( x, y, w, h )
#ifdef USE_FLU_DND
  , Flu_DND( "Flu_Tree_Browser" )
#endif
{
  //lastEvent = -1;
  autoScrollX = autoScrollY = 0.0f;
#ifdef USE_FLU_DND
  dnd_allow_type( "Flu_Tree_Browser" );
  dnd_allow_type( "DND_Object" );
  dnd_allow_text( true );
#endif

  // add some widgets
  _box = new Fl_Group( x, y, w-SCROLL_SIZE, h-SCROLL_SIZE );
  _box->resizable( NULL );
  _box->end();
  //_box->set_output();
  scrollV = new Fl_Scrollbar( x+w-SCROLL_SIZE, y, SCROLL_SIZE, h-SCROLL_SIZE );
  scrollV->type( FL_VERTICAL );
  scrollV->callback( _scrollCB, this );
  scrollV->value( 0, 1, 0, 0 );
  scrollH = new Fl_Scrollbar( x, y+h-SCROLL_SIZE, w-SCROLL_SIZE, SCROLL_SIZE );
  scrollH->type( FL_HORIZONTAL );
  scrollH->callback( _scrollCB, this );
  scrollH->value( 0, 1, 0, 0 );
  scrollBox = new Fl_Group( x+w-SCROLL_SIZE, y+h-SCROLL_SIZE, SCROLL_SIZE, SCROLL_SIZE );
  scrollBox->box( FL_UP_BOX );
  scrollBox->end();
  resizable( _box );

  // set up the recursive data structure
  memset( &rdata, 0, sizeof(rdata) );
  rdata.root = &root;
  root.tree = this;
  rdata.cbNode = NULL;
  rdata.cbReason = FLU_NOTHING;
  rdata.tree = this;
  rdata.dragging = false;
  rdata.forceResize = true;
  rdata.shiftSelect = false;
  rdata.shiftSelectAll = false;
  rdata.nextId = 1;
  rdata.searchIndex = 1;
  rdata.defaultCollapseIcons[0] = new Fl_Pixmap( (char*const*)plus_xpm );
  rdata.defaultCollapseIcons[1] = new Fl_Pixmap( (char*const*)minus_xpm );
  rdata.defaultBranchIcons[0] = new Fl_Pixmap( (char*const*)folder_closed_xpm );
  rdata.defaultBranchIcons[1] = new Fl_Pixmap( (char*const*)folder_open_xpm );

  end();

  // set the default values for the tree
  selection_follows_hilight( false );
  select_under_mouse( false );
  open_without_children( true );
  auto_branches( false );
  animate( false );
  collapse_time( 0.1f );
  double_click_opens( true );
  move_only_same_group( false );
  frame_rate( 100.0f );
  allow_leaf_duplication( true );
  shaded_entry_colors( FL_WHITE, FL_WHITE );
  collapse_icons( NULL, NULL );
  //branch_icons( NULL, NULL );
  rdata.branchIcons[0] = rdata.defaultBranchIcons[0];
  rdata.branchIcons[1] = rdata.defaultBranchIcons[1];
  leaf_icon( NULL );
  branch_text( FL_BLACK, FL_HELVETICA_BOLD, 12 );
  leaf_text( FL_BLACK, FL_HELVETICA, 12 );
  //callback( NULL );
  when( FL_WHEN_CHANGED );
  color( FL_WHITE );
  selection_color( FL_SELECTION_COLOR );
  box( FL_FLAT_BOX );
  connector_style( FL_DARK2, FL_DOT );
  selection_mode( FLU_MULTI_SELECT );
  selection_drag_mode( FLU_DRAG_TO_SELECT );
  insertion_mode( FLU_INSERT_SORTED );
  show_connectors( true );
  show_root( true );
  show_leaves( true );
  show_branches( true );
  open_on_select( false );
  //root_always_open( false );
  horizontal_gap( 2 );
  vertical_gap( 0 );
  widget_gap( 2 );
  set_root( l );

  resize( x, y, w, h );
}

Flu_Tree_Browser :: ~Flu_Tree_Browser()
{
  Fl::remove_timeout( _timerRedrawCB, this );
  Fl::remove_timeout( _timerScrollCB, this );

  delete rdata.defaultCollapseIcons[0];
  delete rdata.defaultCollapseIcons[1];

  delete rdata.defaultBranchIcons[0];
  delete rdata.defaultBranchIcons[1];
}

void Flu_Tree_Browser :: auto_branches( bool b )
{
  rdata.autoBranches = b;
}

void Flu_Tree_Browser :: collapse_icons( Fl_Image *closed, Fl_Image *open )
{
  if( closed )
    rdata.collapseIcons[0] = closed;
  else
    rdata.collapseIcons[0] = rdata.defaultCollapseIcons[0];

  if( open )
    rdata.collapseIcons[1] = open;
  else
    rdata.collapseIcons[1] = rdata.defaultCollapseIcons[1];
}

void Flu_Tree_Browser :: branch_icons( Fl_Image *closed, Fl_Image *open )
{
  //if( closed )
  rdata.branchIcons[0] = closed;
  //else
  //rdata.branchIcons[0] = rdata.defaultBranchIcons[0];

  //if( open )
  rdata.branchIcons[1] = open;
  //else
  //rdata.branchIcons[1] = rdata.defaultBranchIcons[1];
}

void Flu_Tree_Browser :: set_default_branch_icons()
{
  rdata.branchIcons[0] = rdata.defaultBranchIcons[0];
  rdata.branchIcons[1] = rdata.defaultBranchIcons[1];
}

void Flu_Tree_Browser :: leaf_icon( Fl_Image *icon )
{
  rdata.leafIcon = icon;
}

bool Flu_Tree_Browser :: inside_entry_area( int x, int y )
{
  if( scrollH->visible() && scrollV->visible() )
    return( x > _box->x() && y > _box->y() &&
	    x < (_box->x()+_box->w()-scrollV->w()) &&
	    y < (_box->y()+_box->h()-scrollH->h()) );
  else if( !scrollH->visible() && !scrollV->visible() )
    return( x > _box->x() && y > _box->y() &&
	    x < (_box->x()+_box->w()) &&
	    y < (_box->y()+_box->h()) );
  else if( scrollH->visible() )
    return( x > _box->x() && y > _box->y() &&
	    x < (_box->x()+_box->w()) &&
	    y < (_box->y()+_box->h()-scrollH->h()) );
  else
    return( x > _box->x() && y > _box->y() &&
	    x < (_box->x()+_box->w()-scrollV->w()) &&
	    y < (_box->y()+_box->h()) );
}

void Flu_Tree_Browser :: resize( int X, int Y, int W, int H )
{
  Fl_Group::resize( X, Y, W, H );

  int dx = Fl::box_dx(box()), dy = Fl::box_dy(box()), dw = Fl::box_dw(box()), dh = Fl::box_dh(box());

  rdata.x = X+dx; rdata.y = Y+dy; rdata.totalW = rdata.x;
  root.recurse( rdata, Node::MEASURE );
  rdata.totalW -= X-dx;
  rdata.totalH = rdata.y - Y-dy;

  // if the size of the tree is bigger than the window, turn on the scrollbars
  bool hOn = false, vOn = false;
  if( rdata.totalW > W-dw )
    hOn = true;
  if( rdata.totalH > H-dh )
    vOn = true;

  // check if turning on one scrollbar actually forces the other to turn on
  if( hOn && ( rdata.totalH > H-SCROLL_SIZE ) )
    vOn = true;
  if( vOn && ( rdata.totalW > W-SCROLL_SIZE ) )
    hOn = true;

  // now resize the other kids depending on the state of the scrollbars

  _box->resize( X, Y, W, H );
  if( hOn && vOn )  // both scrollbars on
    {
      scrollH->resize( X+dx, Y+H-SCROLL_SIZE-dy, W-SCROLL_SIZE-dw, SCROLL_SIZE );
      scrollH->show();
      scrollV->resize( X+W-SCROLL_SIZE-dx, Y+dy, SCROLL_SIZE, H-SCROLL_SIZE-dh );
      scrollV->show();
      scrollBox->resize( X+W-SCROLL_SIZE-dx, Y+H-SCROLL_SIZE-dy, SCROLL_SIZE, SCROLL_SIZE );
      scrollBox->show();

      // set the scrollbar sizes and values
      int hDelta = rdata.totalW - W+dw + SCROLL_SIZE, scrollHW = scrollH->w()-SCROLL_SIZE-SCROLL_SIZE;
      hDelta = MAX( hDelta, 0 );
      scrollH->value( MIN( scrollH->value(), hDelta ), 1, 0, hDelta );
      scrollH->slider_size( MAX( (float)SCROLL_SIZE/float(scrollHW), float(scrollHW-hDelta)/float(scrollHW) ) );

      int vDelta = rdata.totalH - H+dh + SCROLL_SIZE, scrollVH = scrollV->h()-SCROLL_SIZE-SCROLL_SIZE;
      vDelta = MAX( vDelta, 0 );
      scrollV->value( MIN( scrollV->value(), vDelta ), 1, 0, vDelta );
      scrollV->slider_size( MAX( (float)SCROLL_SIZE/float(scrollVH), float(scrollVH-vDelta)/float(scrollVH) ) );
      _box->resize( X, Y, W-SCROLL_SIZE, H-SCROLL_SIZE );
    }
  else if( !hOn && !vOn )  // neither on
    {
      scrollH->hide();
      scrollV->hide();
      scrollBox->hide();
    }
  else if( hOn )  // just horizontal on
    {
      scrollH->resize( X+dx, Y+H-SCROLL_SIZE-dy, W-dw, SCROLL_SIZE );
      scrollH->show();
      scrollV->hide();
      scrollBox->hide();

      // set the scrollbar size and value
      int hDelta = rdata.totalW - W+dw, scrollHW = scrollH->w()-SCROLL_SIZE-SCROLL_SIZE;
      hDelta = MAX( hDelta, 0 );
      scrollH->value( MIN( scrollH->value(), hDelta ), 1, 0, hDelta );
      scrollH->slider_size( MAX( (float)SCROLL_SIZE/float(scrollHW), float(scrollHW-hDelta)/float(scrollHW) ) );
      _box->resize( X, Y, W, H-SCROLL_SIZE );
    }
  else if( vOn )  // just vertical on
    {
      scrollH->hide();
      scrollV->resize( X+W-SCROLL_SIZE-dx, Y+dy, SCROLL_SIZE, H-dh );
      scrollV->show();
      scrollBox->hide();

      // set the scrollbar size and value
      int vDelta = rdata.totalH - H+dh, scrollVH = scrollV->h()-SCROLL_SIZE-SCROLL_SIZE;
      vDelta = MAX( vDelta, 0 );
      scrollV->value( MIN( scrollV->value(), vDelta ), 1, 0, vDelta );
      scrollV->slider_size( MAX( (float)SCROLL_SIZE/float(scrollVH), float(scrollVH-vDelta)/float(scrollVH) ) );
      _box->resize( X, Y, W-SCROLL_SIZE, H );
    }

  rdata.browserX = _box->x() + dx;
  rdata.browserY = _box->y() + dy;
  rdata.browserW = _box->w() - dw;
  rdata.browserH = _box->h() - dh;

  redraw();

  rdata.forceResize = true;  // weird hack to get the scrollbars to turn on right the first time
}

void Flu_Tree_Browser :: on_dnd_leave()
{
#ifdef USE_FLU_DND
  rdata.isMoveValid = false;
  redraw();

  // X
  if( scrollH->visible() )
    {
      float max = 0.01f * (scrollH->maximum() - scrollH->minimum());
      if( max < 10.0f ) max = 10.0f;
      if( autoScrollX > 0.0f )
	autoScrollX = max;
      else
	autoScrollX = -max;
    }

  // Y
  if( scrollV->visible() )
    {
      float max = 0.01f * (scrollV->maximum() - scrollV->minimum());
      if( max < 10.0f ) max = 10.0f;
      if( autoScrollY > 0.0f )
	autoScrollY = max;
      else
	autoScrollY = -max;
    }
#endif
}

bool Flu_Tree_Browser :: on_dnd_drag( int X, int Y )
{
#ifdef USE_FLU_DND
  rdata.dragging = true;

  autoScrollX = autoScrollY = 0.0f;

  if( scrollH->visible() )
    {
      // auto-scroll the horizontal scrollbars based on how close to the left or right of the browser the mouse is
      float min = 1.0f, max = 0.01f * (scrollH->maximum() - scrollH->minimum());
      if( max < 10.0f ) max = 10.0f;
      if( X < (x()+30) ) // left
	{
	  float t = float((x()+30) - X) / 30.0f;
	  autoScrollX = -LERP( t*t, min, max );
	  if( !scrolledTimerOn )
	    Fl::add_timeout( 0.0, _timerScrollCB, this );
	}
      else if( X > (x()+w()-30) ) // right
	{
	  float t = float(X - (x()+w()-30)) / 30.0f;
	  autoScrollX = LERP( t*t, min, max );
	  if( !scrolledTimerOn )
	    Fl::add_timeout( 0.0, _timerScrollCB, this );
	}
    }

  if( scrollV->visible() )
    {
      // auto-scroll the vertical scrollbars based on how close to the top or bottom of the browser the mouse is
      float min = 1.0f, max = 0.01f * (scrollV->maximum() - scrollV->minimum());
      if( max < 10.0f ) max = 10.0f;
      if( Y < (y()+30) ) // top
	{
	  float t = float((y()+30) - Y) / 30.0f;
	  autoScrollY = -LERP( t*t, min, max );
	  if( !scrolledTimerOn )
	    Fl::add_timeout( 0.0, _timerScrollCB, this );
	}
      else if( Y > (y()+h()-30) ) // bottom
	{
	  float t = float(Y - (y()+h()-30)) / 30.0f;
	  autoScrollY = LERP( t*t, min, max );
	  if( !scrolledTimerOn )
	    Fl::add_timeout( 0.0, _timerScrollCB, this );
	}
    }

  if( autoScrollX == 0.0f && autoScrollY == 0.0f )
    {
      Fl::remove_timeout( _timerScrollCB, this );
      scrolledTimerOn = false;
    }

  int dx = Fl::box_dx(box()), dy = Fl::box_dy(box());
  rdata.x = x()+dx; rdata.y = y()+dy;
  if( scrollH->visible() )
    rdata.x -= scrollH->value();
  if( scrollV->visible() )
    rdata.y -= scrollV->value();
  rdata.delta = 0;
  root.recurse( rdata, Node::HANDLE, FL_DND_DRAG );
  rdata.isMoveValid = Fl::event_inside( this ) && Node::isMoveValid( rdata.grabbed, rdata.dragWhere, rdata.dragNode );

  redraw();
  Fl::flush();

  if( rdata.isMoveValid )
    return true;
  else
#endif
    return false;
}

void Flu_Tree_Browser :: on_dnd_release()
{
#ifdef USE_FLU_DND
  Fl::remove_timeout( _timerScrollCB, this );
  scrolledTimerOn = false;
  redraw();
  Fl::flush();
#endif
}

void Flu_Tree_Browser :: on_dnd_drop( const Flu_DND_Event *e )
{
#ifdef USE_FLU_DND
  bool newNode = false;

  if( !rdata.isMoveValid )
    rdata.grabbed = 0;

  else if( e->event_is_text() && rdata.dnd )
    {
      // create a new node with the text as the name and make it the grabbed node
      rdata.grabbed = new Node( true, e->text(), NULL, rdata, NULL, true );
      if( rdata.grabbed )
	newNode = true;
    }

  else
    {
      if( e->is_data_type( "Flu_Tree_Browser" ) )
	{
	  if( rdata.moveOnlySameGroup && ( rdata.grabbed->parent() != rdata.dragNode->parent() ) )
	    rdata.grabbed = NULL;
	}
      else if( e->is_data_type( "DND_Object" ) && rdata.dnd )
	{
	  // create a new node with the text as the name and make it the grabbed node
	  DND_Object *o = (DND_Object*)e->data();
	  rdata.grabbed = new Node( true, o->name(), NULL, rdata, NULL, true );
	  if( rdata.grabbed )
	    {
	      rdata.grabbed->user_data( e->data() );
	      newNode = true;
	    }
	}
      else
	rdata.grabbed = NULL;
    }

  // select only the new/moved node
  root.unselect_all( rdata.grabbed );
  set_hilighted( rdata.grabbed );
  if( rdata.grabbed )
    {
      rdata.grabbed->select( true );
  
      // move the node
      if( NodeList::move( rdata.grabbed, rdata.dragWhere, rdata.dragNode ) )
	{
	  if( newNode )
	    rdata.grabbed->do_callback( FLU_NEW_NODE );
	  else
	    rdata.grabbed->do_callback( FLU_MOVED_NODE );
	}
      rdata.forceResize = true;
    }
  Fl::focus(this);

  rdata.dragging = false;
  rdata.grabbed = 0;
  rdata.dragNode = 0;
  Fl::remove_timeout( _timerScrollCB, this );
  scrolledTimerOn = false;

  redraw();
#endif
}

int Flu_Tree_Browser :: handle( int event )
{
#ifdef USE_FLU_DND
  if( dnd_handle( event ) )
    return 1;
#endif

  if( event == FL_NO_EVENT )//|| event == FL_MOVE )
    return 0;

  if( event == FL_FOCUS )//&& rdata.lastHilighted )
    {
      //set_hilighted( rdata.lastHilighted );
      //lastEvent = event;
      //Fl_Group::handle( event );
      redraw();
      return 1;
    }

  if( event == FL_UNFOCUS )
    {
      //if( lastEvent != FL_LEAVE )
      //{
	  //rdata.lastHilighted = rdata.hilighted;
      //}
      //set_hilighted( NULL );
      //lastEvent = event;
      Fl_Group::handle( event );
      redraw();
      return 1;
    }

  if( !rdata.dragging && !( event == FL_MOVE && rdata.selectUnderMouse ) )
    {
      if( ! (event == FL_MOVE || event == FL_ENTER || event == FL_LEAVE ) )
	_box->redraw();

      if( Fl_Group::handle( event ) )
	{
	  //if( event == FL_KEYDOWN || event == FL_KEYUP )
	  // redraw();
	  return 1;
	}
      //if (scrollV && Fl::event_inside(scrollV) && scrollV->handle(event)) return 1;
      //if (scrollH && Fl::event_inside(scrollH) && scrollH->handle(event)) return 1;
    }

  if( event == FL_RELEASE )
    {
      //Fl::focus(this);
      rdata.dragging = false;
      rdata.grabbed = 0;
      rdata.dragNode = 0;
      //redraw();
    }

  int dx = Fl::box_dx(box()), dy = Fl::box_dy(box());

  // set some initial values for the recursive data structure
  // account for the scrollbar positions
  rdata.x = x()+dx; rdata.y = y()+dy;
  if( scrollH->visible() )
    rdata.x -= scrollH->value();
  if( scrollV->visible() )
    rdata.y -= scrollV->value();

  rdata.previous = NULL;
  rdata.delta = 0;
  rdata.visibilityChanged = false;

  // catch cursor keys for moving the hilighted entry or selecting all entries
  if( event == FL_KEYDOWN )
    {
      // move hilighted entry up
      if( Fl::event_key() == FL_Up )
	{
	  rdata.delta = -1;
	  Fl::focus(this);
	  redraw();
	}

      // move hilighted entry down
      else if( Fl::event_key() == FL_Down )
	{
	  rdata.delta = 1;
	  Fl::focus(this);
	  redraw();
	}

      // select all
      else if( Fl::event_state(FL_CTRL) && Fl::event_key() == 'a' )
	{
	  select_all();
	  Fl::focus(this);
	  redraw();
	  return 1;
	}

      // check for the Home key
      else if( Fl::event_key() == FL_Home )
	{
	  // set the hilighted entry to be the first entry
	  if( rdata.showRoot || ( rdata.root->_children.size() == 0 ) )
	    set_hilighted( rdata.root );
	  else if( rdata.root->_children.size() > 0 )
	    set_hilighted( rdata.root->_children.child(0) );
	  redraw();
	}

      // check for the End key
      else if( Fl::event_key() == FL_End )
	{
	  // set the hilighted entry to be the last visible entry
	  if( rdata.showRoot && ( rdata.root->_children.size() == 0 ) )
	    set_hilighted( rdata.root );
	  else
	    {
	      // find the last node by repeatedly looking for the last child until there are no more branches
	      Node *n = &root;
	      while( n->_children.size() && n->open() )
		n = n->_children.child( n->_children.size()-1 );
	      set_hilighted( n );
	    }
	  redraw();
	}
    }

  // pass the event down the tree
  int val = root.recurse( rdata, Node::HANDLE, event );
  if( val )
    {
      //redraw();
      if( rdata.visibilityChanged )
	root.determineVisibility();
      if( val == 1 )
	return 1;
    }
  // special case: if multi-select or single-select and user clicks on no items, unselect all items
  else if( (rdata.selectionMode != FLU_NO_SELECT) && (event == FL_PUSH) && (!Fl::event_state(FL_CTRL)) )
    {
      unselect_all();
      set_hilighted( NULL );
      rdata.forceResize = true;
      redraw();

      return 1;
    }

  if( event == FL_SHOW || event == FL_HIDE )
    root.determineVisibility();

  return Fl_Group::handle( event );
  //return 0;
}

void Flu_Tree_Browser :: insertion_mode( int m )
{
  rdata.insertionMode = m;
  root.sort();
}

void Flu_Tree_Browser :: set_hilighted( Flu_Tree_Browser::Node* n )
{
  if( rdata.hilighted == n  &&  when() != FL_WHEN_NOT_CHANGED )
    return;

  if( rdata.hilighted )
    rdata.hilighted->do_callback( FLU_UNHILIGHTED );
  rdata.hilighted = n;
  if( rdata.hilighted )
    rdata.hilighted->do_callback( FLU_HILIGHTED );

  if( rdata.hilighted )
    {
      if( rdata.selectionFollowsHilight )
	{
	  if( rdata.selectionMode == FLU_SINGLE_SELECT )
	    unselect_all();
	  rdata.hilighted->select( true );
	}

      int extraH = scrollH->visible() ? scrollH->h() : 0;

      // if the hilighted entry is below the visible bounds of the browser, move the vertical scrollbar
      // so the hilighted entry is the last visible entry
      if( rdata.hilighted->currentY-y()+rdata.hilighted->currentH > scrollV->value()+h()-extraH )
	((Fl_Valuator*)scrollV)->value( rdata.hilighted->currentY-y() - h()+extraH + rdata.hilighted->currentH );

      // if the hilighted entry is above the visible bounds of the browser, move the vertical scrollbar
      // so the hilighted entry is the first visible entry
      if( rdata.hilighted->currentY-y() < scrollV->value() )
	((Fl_Valuator*)scrollV)->value( rdata.hilighted->currentY-y() );
    }
  redraw();
}

int Flu_Tree_Browser :: num_selected()
{
  return root.recurse( rdata, Node::COUNT_SELECTED );
}

int Flu_Tree_Browser :: Node :: num_selected()
{
  return recurse( tree->rdata, COUNT_SELECTED );
}

Flu_Tree_Browser::Node* Flu_Tree_Browser :: get_selected( int index )
{
  return root.get_selected( index );
}

Flu_Tree_Browser::Node* Flu_Tree_Browser :: Node :: get_selected( int index )
{
  tree->rdata.counter = 0;
  tree->rdata.searchIndex = index;
  Node *n = modify( 0, GET_SELECTED, tree->rdata );
  tree->rdata.searchIndex = 1;
  return n;
}

Flu_Tree_Browser :: Node :: Node( const char *lbl )
{
  flags = 0;
  userData = 0;
  _parent = 0;
  _widget = 0;
  _group = 0;
  SET(ACTIVE);
  CLEAR(LEAF);
  _id = 0;
  CLEAR(ALWAYS_OPEN);
  SET(COLLAPSED);
  SET(MOVABLE);
  SET(DROPPABLE);
  currentY = currentH = 0;
  totalChildH = 0;
  CLEAR(SELECTED);
  CLEAR(EXPAND_TO_WIDTH);
  SET(SHOW_LABEL);
  if( lbl == 0 )
    text = "";
  else
    text = lbl;

  cIcon[0] = cIcon[1] = bIcon[0] = bIcon[1] = lIcon = 0;
}

Flu_Tree_Browser :: Node :: Node( bool l, const char* n, Node *p, RData &rdata, Fl_Widget *w, bool showLbl )
{
  _group = 0;
  flags = 0;
  userData = 0;
  SET(LEAF,l);
  text = n;
  _id = 0;
  SET(ACTIVE);
  _parent = p;
  CLEAR(ALWAYS_OPEN);
  SET(COLLAPSED);
  CLEAR(SELECTED);
  CLEAR(EXPAND_TO_WIDTH);
  SET(MOVABLE);
  SET(DROPPABLE);
  _widget = 0;
  totalChildH = 0;
  currentY = currentH = 0;
  cIcon[0] = cIcon[1] = bIcon[0] = bIcon[1] = lIcon = 0;
  SET( SHOW_LABEL, showLbl );
  tree = rdata.tree;

  initType();

  _id = rdata.nextId++;
  widget( w );
}

void Flu_Tree_Browser :: Node :: initType()
{
  if( is_leaf() )
    {
      lIcon = tree->rdata.leafIcon;
      textColor = tree->rdata.defLeafColor;
      textFont = tree->rdata.defLeafFont;
      textSize = tree->rdata.defLeafSize;
    }
  else
    {
      cIcon[0] = tree->rdata.collapseIcons[0];
      cIcon[1] = tree->rdata.collapseIcons[1];
      bIcon[0] = tree->rdata.branchIcons[0];
      bIcon[1] = tree->rdata.branchIcons[1];
      textColor = tree->rdata.defBranchColor;
      textFont = tree->rdata.defBranchFont;
      textSize = tree->rdata.defBranchSize;
    }
}

Flu_Tree_Browser :: Node :: ~Node()
{
  // if this node is in a tree, make sure it isn't holding a reference to us
  if( tree )
    {
      if( tree->rdata.hilighted == this ) tree->rdata.hilighted = NULL;
      //if( tree->rdata.lastHilighted == this ) tree->rdata.lastHilighted = NULL;
      if( tree->rdata.grabbed == this ) tree->rdata.grabbed = NULL;
      if( tree->rdata.dragNode == this ) tree->rdata.dragNode = NULL;
    }
  clear();
}

Flu_Tree_Browser::Node* Flu_Tree_Browser :: Node :: first()
{
  return this;
}

Flu_Tree_Browser::Node* Flu_Tree_Browser :: Node :: first_branch()
{
  Node *n = first();
  while( n )
    {
      if( n->is_branch() )
	return n;
      else
	n = n->next();
    }
  return NULL;
}

Flu_Tree_Browser::Node* Flu_Tree_Browser :: Node :: first_leaf()
{
  Node *n = first();
  while( n )
    {
      if( n->is_leaf() )
	return n;
      else
	n = n->next();
    }
  return NULL;
}

Flu_Tree_Browser::Node* Flu_Tree_Browser :: Node :: last()
{
  if( children() == 0 )
    return this;
  else
    return( child( children() - 1 )->last() );
}

Flu_Tree_Browser::Node* Flu_Tree_Browser :: Node :: last_branch()
{
  Node *n = last();
  while( n )
    {
      if( n->is_branch() )
	return n;
      else
	n = n->previous();
    }
  return NULL;
}

Flu_Tree_Browser::Node* Flu_Tree_Browser :: Node :: last_leaf()
{
  Node *n = last();
  while( n )
    {
      if( n->is_leaf() )
	return n;
      else
	n = n->previous();
    }
  return NULL;
}

Flu_Tree_Browser::Node* Flu_Tree_Browser :: Node :: next_sibling()
{
  if( is_root() )
    return NULL;
  int index;
  for( index = 0; index < _parent->children(); index++ )
    if( _parent->child(index) == this )
      break;
  // if we are the last child of our parent, then we have no next sibling
  if( index == _parent->children()-1 )
    return NULL;
  // otherwise return our next sibling
  else
    return( _parent->child(index+1) );
}

Flu_Tree_Browser::Node* Flu_Tree_Browser :: Node :: previous_sibling()
{
  if( is_root() )
    return NULL;
  int index;
  for( index = 0; index < _parent->children(); index++ )
    if( _parent->child(index) == this )
      break;
  // if we are the first child of our parent, then we have no previous sibling
  if( index == 0 )
    return NULL;
  // otherwise return our previous sibling
  else
    return( _parent->child(index-1) );
}

int Flu_Tree_Browser :: Node :: index() const
{
  if( is_root() )
    return -1;
  int index;
  for( index = 0; index < _parent->children(); index++ )
    if( _parent->child(index) == this )
      return index;
  return -1;
}

Flu_Tree_Browser::Node* Flu_Tree_Browser :: Node :: next()
{
  // take care of the root node as a special case
  if( is_root() )
    {
      if( children() )
	return child(0);
      else
	return NULL;
    }

  // if we are a branch, then the next node is our first child, unless we don't have any children
  if( is_branch() && _children.size() )
    return _children.child(0);
  else
    {
      // otherwise, the next node is our next sibling. if there is no next sibling (because we
      // are the last child of our parent), then the next node is the next sibling of our parent (and so on...)
      Node *p = parent(), *n = next_sibling();
      while( p )
	{
	  if( n )
	    return n;
	  else
	    {
	      n = p->next_sibling();
	      p = p->parent();
	    }
	}
      return NULL;
    }
}

Flu_Tree_Browser::Node* Flu_Tree_Browser :: Node :: next_branch()
{
  Node *n = next();
  while( n )
    {
      if( n->is_branch() )
	return n;
      else
	n = n->next();
    }
  return NULL;
}

Flu_Tree_Browser::Node* Flu_Tree_Browser :: Node :: next_leaf()
{
  Node *n = next();
  while( n )
    {
      if( n->is_leaf() )
	return n;
      else
	n = n->next();
    }
  return NULL;
}

Flu_Tree_Browser::Node* Flu_Tree_Browser :: Node :: previous()
{
  // take care of the root node as a special case
  if( is_root() )
    return NULL;

  // the previous node is either our parent's
  // previous sibling (if that sibling exists and is a leaf or a branch with no children),
  // or the last child of our parent's previous sibling (if that sibling exists and is
  // a branch with children). if there is no previous sibling, then the previous node
  // is our parent
  Node *n = previous_sibling();
  if( !n )
    return _parent;
  else
    {
      if( n->is_leaf() )  // is leaf, so that is the previous node
	return n;
      else if( n->children() )  // is branch with some children, so previous node is last child
	return( n->last() );
      else  // is branch with no children, so that is the previous node
	return n;
    }
}

Flu_Tree_Browser::Node* Flu_Tree_Browser :: Node :: previous_branch()
{
  Node *n = previous();
  while( n )
    {
      if( n->is_branch() )
	return n;
      else
	n = n->previous();
    }
  return NULL;
}

Flu_Tree_Browser::Node* Flu_Tree_Browser :: Node :: previous_leaf()
{
  Node *n = previous();
  while( n )
    {
      if( n->is_leaf() )
	return n;
      else
	n = n->previous();
    }
  return NULL;
}

void Flu_Tree_Browser :: Node :: determineVisibility( bool parentVisible )
{
  if( _widget )
    {
      if( parentVisible )
	_widget->w->show();
      else
	_widget->w->hide();
    }
  for( int i = 0; i < _children.size(); i++ )
    _children.child(i)->determineVisibility( parentVisible && open() );
}

Flu_Tree_Browser::Node* Flu_Tree_Browser :: Node :: child( int i ) const
{
  if( i < 0 || i >= _children.size() )
    return 0;
  else
    return _children.child(i);
}

void Flu_Tree_Browser :: Node :: clear()
{
  widget(NULL);
  for( int i = 0; i < _children.size(); i++ )
    {
      //if( tree->rdata.cbNode == _children.child(i) )
      //tree->rdata.cbNode = NULL;
      delete _children.child(i);
    }
  _children.clear();
  if( _group )
    {
      if( _group->parent() )
	_group->parent()->remove( *_group );
      while( _group->children() )
	_group->remove( *_group->child(0) );
      delete _group;
      _group = NULL;
    }
}

void Flu_Tree_Browser :: Node :: print( int spaces )
{
  for( int s = 0; s < spaces; s++ )
    printf( " " );
  if( is_leaf() )
    printf( "  %s\n", text.c_str() );
  else
    printf( "[%s]\n", text.c_str() );

  for( int i = 0; i < _children.size(); i++ )
    _children.child(i)->print( spaces+2 );
}

void Flu_Tree_Browser :: draw()
{
  if( rdata.forceResize )
    {
      resize( x(), y(), w(), h() );
      rdata.forceResize = false;
    }

  // draw the background color
  //fl_draw_box( _box->box(), _box->x(), _box->y(), _box->w(), _box->h(), _box->color() );
  fl_draw_box( box(), x(), y(), w(), h(), color() );

  int dx = Fl::box_dx(box()), dy = Fl::box_dy(box()),
    dw = Fl::box_dw(box()), dh = Fl::box_dh(box());

  // set up the recursive data structure
  rdata.x = x()+dx; rdata.y = y()+dy;
  // account for the positions of the scrollbars
  if( scrollH->visible() )
    rdata.x -= scrollH->value();
  if( scrollV->visible() )
    rdata.y -= scrollV->value();

  rdata.last = true;
  rdata.bgColor = _box->color();
  rdata.shadedIndex = 0;

  // pick the connector line and selection colors depending on the active state
  if( active() )
    {
      rdata.lineColor = rdata.defLineColor;
      rdata.selectionColor = rdata.defSelectionColor;
    }
  else
    {
      rdata.lineColor = fl_inactive( rdata.defLineColor );
      rdata.selectionColor = fl_inactive( rdata.defSelectionColor );
    }

  // draw the tree
  fl_push_clip( x()+dx, y()+dy, w()-dw, h()-dh );
  root.recurse( rdata, Node::DRAW );

  // if dragging to move, draw a bar showing where the dragged node will be inserted
#ifdef USE_FLU_DND
  if( dnd_is_dragging() && rdata.isMoveValid && rdata.dragging )
    {
      bool drawLine = false;
      if( dnd_event_is_text() )
	drawLine = true;
      else if( dnd_is_data_type( "Flu_Tree_Browser" ) )
	{
	  if( !rdata.moveOnlySameGroup || ( rdata.grabbed->parent() == rdata.dragNode->parent() ) )
	    drawLine = true;
	}
      else if( dnd_is_data_type( "DND_Object" ) )
	drawLine = true;
      if( drawLine && rdata.dragWhere != MOVE_INSIDE )
	{
	  fl_color( FL_RED );
	  fl_line_style( FL_SOLID, 2 );
	  fl_line( _box->x(), rdata.dragPos, _box->x()+_box->w(), rdata.dragPos );
	  fl_line_style( 0 );
	}
    }
#endif

  fl_pop_clip();

  // draw the kids
  draw_child( *scrollBox );
  draw_child( *scrollH );
  draw_child( *scrollV );

  // draw the box last so it's on top
  //fl_draw_box( _box->box(), _box->x(), _box->y(), _box->w(), _box->h(), _box->color() );
}

inline void draw_T( int x, int y, int w, int h )
{
  int w2 = w >> 1;
  int h2 = h >> 1;
  fl_line( x+w2, y, x+w2, y+h );
  fl_line( x+w2, y+h2, x+w, y+h2 );
}

inline void draw_L( int x, int y, int w, int h )
{
  int w2 = w >> 1;
  int h2 = h >> 1;
  fl_line( x+w2, y, x+w2, y+h2 );
  fl_line( x+w2, y+h2, x+w, y+h2 );
}

inline void draw_Lflip( int x, int y, int w, int h )
{
  int w2 = w >> 1;
  int h2 = h >> 1;
  fl_line( x+w2, y+h, x+w2, y+h2 );
  fl_line( x+w2, y+h2, x, y+h2 );
}

inline void draw_Lflop( int x, int y, int w, int h )
{
  int w2 = w >> 1;
  int h2 = h >> 1;
  fl_line( x+w2, y+h, x+w2, y+h2 );
  fl_line( x+w2, y+h2, x+w, y+h2 );
}

inline void draw_Ldash( int x, int y, int w, int h )
{
  w = w >> 1;
  h = h >> 1;
  fl_line( x, y+h, x+w, y+h );
}

inline void draw_vert_dash( int x, int y, int w, int h )
{
  w = w >> 1;
  fl_line( x+w, y+(h>>1), x+w, y+h );
}

inline void draw_Rdash( int x, int y, int w, int h )
{
  h = h >> 1;
  fl_line( x+w, y+h, x+(w>>1), y+h );
}

void Flu_Tree_Browser :: Node :: draw( RData &rdata, bool measure )
{
  int which = open(); // i.e. which icon: open or closed?
  bool skipCollapser = is_root() && rdata.showRoot && ( CHECK(ALWAYS_OPEN) || rdata.allBranchesAlwaysOpen );
  int halfHGap = rdata.hGap >> 1, halfVGap = rdata.vGap >> 1;
  bool doDraw = !measure;

  int X = rdata.x;
  int Y = rdata.y;

  Fl_Color bgColor = rdata.shadedColors[rdata.shadedIndex], tColor = textColor, hilightColor = rdata.selectionColor;

  // pick the text color depending on the active state
  if( !rdata.tree->active() || !CHECK(ACTIVE))
    tColor = fl_inactive( tColor );

  if( doDraw )
    {
      // draw the background for the entry using the entry background color
      fl_draw_box( FL_FLAT_BOX, rdata.browserX, Y, rdata.browserW, currentH, bgColor );

      // if dragging to the inside of a branch, hilight that branch
#ifdef USE_FLU_DND
      if( tree->dnd_is_dragging() && rdata.isMoveValid && rdata.dragWhere == MOVE_INSIDE && rdata.dragNode == this )
	{
	  bgColor = FL_RED;
	  tColor = fl_contrast( tColor, bgColor );
	  hilightColor = rdata.bgColor;
	  fl_draw_box( FL_FLAT_BOX, rdata.browserX, Y, rdata.browserW, currentH, bgColor );
	}
      // if selected, draw a filled selection box and reverse the normal draw colors
      else if( CHECK(SELECTED) )
#else
      if( CHECK(SELECTED) )
#endif
	{
	  bgColor = rdata.selectionColor;
	  tColor = fl_contrast( tColor, bgColor );
	  hilightColor = rdata.bgColor;
	  fl_draw_box( FL_FLAT_BOX, rdata.browserX, Y, rdata.browserW, currentH, bgColor );
	}

      fl_color( rdata.lineColor );
      fl_line_style( rdata.lineStyle, rdata.lineWidth );
    }

  if( is_leaf() ) // draw leaves one way...
    {
      // draw the connectors
      if( doDraw && rdata.showConnectors && rdata.showBranches )
	{
	  if( parent()->is_root() && !rdata.showRoot && rdata.first )
	    {
	      if( rdata.last )
		draw_Rdash( X-halfHGap, Y-halfVGap, rdata.branchIconW+rdata.hGap, currentH+rdata.vGap );
	      else
		draw_Lflop( X-halfHGap, Y-halfVGap, rdata.branchIconW+rdata.hGap, currentH+rdata.vGap );
	    }
	  else if( rdata.last )
	    draw_L( X-halfHGap, Y-halfVGap, rdata.branchIconW+rdata.hGap, currentH+rdata.vGap );
	  else
	    draw_T( X-halfHGap, Y-halfVGap, rdata.branchIconW+rdata.hGap, currentH+rdata.vGap );
	}

      // account for leaf icon spacing
      if( rdata.showBranches )
	{
	  if( lIcon )
	    X += rdata.collapseIcons[which]->w() + rdata.hGap;
	  else
	    X += rdata.collapseIcons[which]->w() + rdata.wGap;
	}
      else 
	X += rdata.wGap;

      // draw some more connectors
      if( doDraw && rdata.showConnectors && lIcon && rdata.showBranches )
	draw_Ldash( X-halfHGap, Y-halfVGap, lIcon->w()+rdata.hGap, currentH+rdata.vGap );

      // draw the leaf icon
      if( lIcon && !CHECK(ICON_AT_END) )
	{
	  if( doDraw )
	    lIcon->draw( X, Y+(currentH>>1)-(lIcon->h()>>1) );
	  X += lIcon->w() + rdata.wGap;
	}
    }
  else // ...and branches another
    {
      // force the root to the left if it has no visible children
      if( is_root() && !CHECK(SOME_VISIBLE_CHILDREN) )
	{
	  skipCollapser = true;
	  which = 0;
	}

      if( !CHECK(SOME_VISIBLE_CHILDREN) && !rdata.showLeaves )
	which = 0;

      // draw the connectors
      if( doDraw && !skipCollapser && rdata.showConnectors && rdata.showBranches )
	{
	  if( is_root() )
	    {
	      if( CHECK(SOME_VISIBLE_CHILDREN) )
		draw_Rdash( X-halfHGap, Y-halfVGap, rdata.collapseIcons[which]->w()+4+rdata.hGap, currentH+rdata.vGap );
	    }
	  else if( parent()->is_root() && !rdata.showRoot && rdata.first )
	    {
	      if( rdata.last )
		draw_Rdash( X-halfHGap, Y-halfVGap, rdata.branchIconW+rdata.hGap, currentH+rdata.vGap );
	      else
		draw_Lflop( X-halfHGap, Y-halfVGap, rdata.branchIconW+rdata.hGap, currentH+rdata.vGap );
	    }
	  else if( rdata.last )
	    draw_L( X-halfHGap, Y-halfVGap, rdata.branchIconW+rdata.hGap, currentH+rdata.vGap );
	  else
	    draw_T( X-halfHGap, Y-halfVGap, rdata.branchIconW+rdata.hGap, currentH+rdata.vGap );
	}

      // draw the collapsed icons
      if( doDraw && !skipCollapser && !CHECK(ALWAYS_OPEN) && !rdata.allBranchesAlwaysOpen )
	{
	  if( CHECK(SOME_VISIBLE_CHILDREN) || rdata.showLeaves )
	    {
	      if( !rdata.openWOChildren && !CHECK(SOME_VISIBLE_CHILDREN) )
		which = 0;
	      if( rdata.openWOChildren || CHECK(SOME_VISIBLE_CHILDREN) )
		{
		  if( _parent==0 )
		    cIcon[which]->draw( X, Y+(currentH>>1)-(cIcon[which]->h()>>1) );
		  else
		    cIcon[which]->draw( X+(rdata.branchIconW>>1)-(cIcon[which]->w()>>1), Y+(currentH>>1)-(cIcon[which]->h()>>1) );
		}
	    }
	}

      if( !skipCollapser )
	{
	  X += cIcon[which]->w();
	  if( bIcon[which] )
	    X += rdata.hGap;
	  else
	    X += rdata.wGap;
	}

      // draw some more connectors
      if( doDraw && rdata.showConnectors && rdata.showBranches )
	{
	  int hGap = rdata.hGap;
	  if( bIcon[which] )
	    hGap += bIcon[which]->w();
	  if( skipCollapser && CHECK(SOME_VISIBLE_CHILDREN) )
	    draw_vert_dash( X-halfHGap, Y-halfVGap, hGap, currentH+rdata.vGap );
	  else if( !which || !CHECK(SOME_VISIBLE_CHILDREN) )
	    draw_Ldash( X-halfHGap, Y-halfVGap, hGap, currentH+rdata.vGap );
	  else
	    draw_Lflip( X-halfHGap, Y-halfVGap, hGap, currentH+rdata.vGap );
	}

      // draw the branch icon
      if( bIcon[which] )
	{
	  if( doDraw )
	    bIcon[which]->draw( X, Y+(currentH>>1)-(bIcon[which]->h()>>1) );
	  X += bIcon[which]->w() + rdata.wGap;
	}
      else
	X += rdata.wGap;
    }

  if( doDraw )
    fl_line_style( 0 );

  // draw the entry
  if( CHECK(SHOW_LABEL) && !CHECK(SWAP_LABEL_AND_WIDGET) )
    {
      if( doDraw )
	{
	  fl_draw_box( FL_FLAT_BOX, X, Y+(currentH>>1)-(textH>>1), textW, textH, bgColor );
	  fl_color( tColor );
	  fl_font( textFont, textSize );
	  fl_draw( text.c_str(), X, Y+(currentH>>1)-(textH>>1), textW, textH, FL_ALIGN_LEFT );
	}
      X += textW;
    }

  if( _widget )
    {
      int widgetW = _widget->w->w();
      int widgetH = _widget->w->h();
      if( doDraw )
	{
	  if( CHECK(AUTO_COLOR) )
	    _widget->w->color( bgColor );
	  if( CHECK(AUTO_LABEL_COLOR) )
	    _widget->w->labelcolor( tColor );
	  if( CHECK(AUTO_LABEL) )
	    _widget->w->label( text.c_str() );
	  _widget->w->redraw();
	  _widget->w->position( X, Y+(currentH>>1)-(widgetH>>1) );
	  if( CHECK(EXPAND_TO_WIDTH) )
	    _widget->w->size( MAX( _widget->defaultW, rdata.browserW - (X-rdata.browserX) ), _widget->w->h() );
	  _widget->w->draw();
	}
      if( CHECK(EXPAND_TO_WIDTH) )
	{
	  if( _widget->w->w() == _widget->defaultW )
	    X += _widget->defaultW;
	}
      else
	X += widgetW;
    }

  if( CHECK(SHOW_LABEL) && CHECK(SWAP_LABEL_AND_WIDGET) )
    {
      if( doDraw )
	{
	  fl_draw_box( FL_FLAT_BOX, X, Y+(currentH>>1)-(textH>>1), textW, textH, bgColor );
	  fl_color( tColor );
	  fl_font( textFont, textSize );
	  fl_draw( text.c_str(), X, Y+(currentH>>1)-(textH>>1), textW, textH, FL_ALIGN_LEFT );
	}
      X += textW;
    }

  // draw the leaf icon to the right of the label and widget
  if( is_leaf() && lIcon && CHECK(ICON_AT_END) )
    {
      if( doDraw )
	lIcon->draw( X, Y+(currentH>>1)-(lIcon->h()>>1) );
      X += lIcon->w() + rdata.wGap;
    }

  // if hilighted, draw a box outlining the entry
  if( Fl::focus() == tree && rdata.hilighted == this && doDraw )
    {
      fl_color( hilightColor );
      fl_line_style( FL_DOT, 1 );
      fl_rect( rdata.browserX, Y, rdata.browserW, currentH, hilightColor );
      fl_line_style( 0 );
    }

  rdata.totalW = MAX( rdata.totalW, X );
}

void Flu_Tree_Browser :: Node :: select( bool b )
{
  if( (CHECK(SELECTED)==b) && (tree->when() != FL_WHEN_NOT_CHANGED) )
    return;
  SET(SELECTED,b);
  tree->redraw();
  if( tree->when() == FL_WHEN_RELEASE )
    return;
  if( b )
    do_callback( FLU_SELECTED );
  else
    do_callback( FLU_UNSELECTED );
}

void Flu_Tree_Browser :: timerScrollCB()
{
  bool doRedraw = false;

  float val = scrollV->value() + autoScrollY;
  if( val < 0.0f )
    val = 0.0f;
  if( val > scrollV->maximum() )
    val = scrollV->maximum();
  doRedraw |= ( val != scrollV->value() );
  ((Fl_Valuator*)scrollV)->value( val );

  val = scrollH->value() + autoScrollX;
  if( val < 0.0f )
    val = 0.0f;
  if( val > scrollH->maximum() )
    val = scrollH->maximum();
  doRedraw |= ( val != scrollH->value() );
  ((Fl_Valuator*)scrollH)->value( val );

  Fl::repeat_timeout( 0.02, _timerScrollCB, this );
  scrolledTimerOn = true;
  if( doRedraw )
    redraw();
}

void Flu_Tree_Browser :: timerRedrawCB()
{
  if( rdata.animating )
    Fl::repeat_timeout( 1.0f/rdata.fps, _timerRedrawCB, this );
  redraw();
}

void Flu_Tree_Browser :: Node :: open( bool b )
{
  if( is_leaf() )
    return;

  if( CHECK(ALWAYS_OPEN) || tree->rdata.allBranchesAlwaysOpen )
    return;

  if( (open() == b) && (tree->when() != FL_WHEN_NOT_CHANGED) )
    return;

  tree->rdata.justOpenedClosed = true;

  SET(COLLAPSED,!b);

  if( tree->rdata.animate && _children.size() )
    {
      // if we aren't yet animating a node, animate it!
      if( !tree->rdata.animating && !tree->rdata.animatedNode )
	{
	  // if we don't know how high all the children are, find out
	  // (this only happens once per node, the first time it is opened)
	  if( totalChildH == 0 )
	    {
	      RData r = tree->rdata;
	      r.x = r.y = r.totalW = 0;
	      recurse( r, Node::MEASURE_THIS_OPEN );
	    }
	  // set the initial offset based on whether the branch is open or closed
	  tree->rdata.animationOffset = b ? -totalChildH : -1;
	  // the delta is how much to change the offset each frame
	  tree->rdata.animationDelta = totalChildH / ( tree->rdata.collapseTime * tree->rdata.fps );
	  tree->rdata.animationDelta = b ? tree->rdata.animationDelta : -tree->rdata.animationDelta;
	  tree->rdata.animating = true;
	  tree->rdata.animatedNode = this;
	  Fl::add_timeout( 1.0f/tree->rdata.fps, _timerRedrawCB, tree );
	}
      // otherwise reverse the direction of the animation, only if we are animating this node
      else if( tree->rdata.animating && tree->rdata.animatedNode==this )
	{
	  if( b ^ (tree->rdata.animationDelta>0) )
	    tree->rdata.animationDelta = -tree->rdata.animationDelta;
	}
    }

  if( open() && (_parent != 0) ) // root node doesn't count as a single open branch
    {
      if( ( tree->rdata.lastOpenBranch != this ) && tree->rdata.singleBranchOpen )
	tree->rdata.lastOpenBranch->close();
      tree->rdata.lastOpenBranch = this;
    }

  tree->rdata.forceResize = true;
  tree->rdata.visibilityChanged = true;
  if( b )
    do_callback( FLU_OPENED );
  else
    do_callback( FLU_CLOSED );
}

void Flu_Tree_Browser :: Node :: active( bool b )
{
  if( CHECK(ACTIVE) == b  &&  tree->when() != FL_WHEN_NOT_CHANGED )
    return;
  SET( ACTIVE, b );
  if( _widget )
    {
      if( b )
	_widget->w->activate();
      else
	_widget->w->deactivate();
    }
  if( !CHECK(ACTIVE) )
    {
      if( tree->rdata.hilighted == this )
	tree->set_hilighted( NULL );
      select( false );
      open( false );
    }
}

void Flu_Tree_Browser :: Node :: unselect_all( Node* except )
{
  if( this != except )
    select( false );
  for( int i = 0; i < _children.size(); i++ )
    _children.child(i)->unselect_all( except );
}

void Flu_Tree_Browser :: Node :: select_all()
{
  select( true );
  for( int i = 0; i < _children.size(); i++ )
    _children.child(i)->select_all();
}

bool Flu_Tree_Browser :: Node :: isMoveValid( Node* &n1, int &where, Node* &n2 )
{
  // if n1 is NULL, then check it as if it were a node being moved from another tree

  if( n2 == NULL )
    return false;

  // check the validity of the move:
  // 1) the source and destination nodes can't be the same
  // 2) you can't move before the root node
  // 3) you can't move an unmovable node or move a branch node such that it would become a descendent of itself
  // 4) if moving only within the same group, check that the parents are the same
  // 5) if moving into a sorted tree, the destination node MUST be a branch
  // 6) a move AFTER an OPEN branch is a move BEFORE its first child
  // 7) you can't move a node into a non-droppable branch node

  if( n1 == n2 )
    return false;

  if( where==MOVE_BEFORE && n2->is_root() )
    return false;

  if( n1 )
    {
      if( !n1->movable() )
	return false;
      if( n1->is_branch() )
	if( n1->is_descendent( n2 ) )
	  return false;
    }

  bool sameGroup = n2->tree->move_only_same_group();
  if( sameGroup && n1 )
    {
      if( n1->parent() != n2->parent() || where==MOVE_INSIDE )
	return false;
    }

  int iMode = n2->tree->insertion_mode();
  if( iMode == FLU_INSERT_SORTED || iMode == FLU_INSERT_SORTED_REVERSE )
    {
      if( n2->is_branch() )
	{
	  where = MOVE_INSIDE;
	  return true;
	}
      else
	return false;
    }

  if( where==MOVE_AFTER && n2->is_branch() && n2->open() )
    {
      // can't move inside a branch if within the same group, unless the first node is dragged 
      // from outside the tree (in which case n1 is NULL)
      if( sameGroup && n1 )
	{
	  if( n2->_children.size() > 0 )
	    return false;
	}
      else if( n2->_children.size() > 0 )
	{
	  where = MOVE_BEFORE;
	  n2 = n2->_children.child(0);
	}
      else
	where = MOVE_INSIDE;
    }

  if( where==MOVE_INSIDE )
    {
      if( !n2->droppable() )
	return false;
    }
  else if( n2->parent() )
    if( !n2->parent()->droppable() )
      return false;

  return true;
}

int Flu_Tree_Browser :: Node :: recurse( RData &rdata, int type, int event )
{
  int i;

  if( is_root() )
    rdata.first = true;

  if( type == COUNT_SELECTED )
    {
      if( is_leaf() )
	return (int)CHECK(SELECTED);
      else
	{
	  int total = (int)CHECK(SELECTED);
	  for( i = 0; i < _children.size(); i++ )
	    total += _children.child(i)->recurse( rdata, type, event );
	  return total;
	}
    }

  // see if this entry is even visible
  if( rdata.y > rdata.browserY+rdata.browserH )
    {
      if( type == DRAW )
	return 1;
      else if( type == HANDLE )
	return 0;
    }

  int which = open();
  bool skipEntry = ( is_root() && !rdata.showRoot ) || ( is_leaf() && !rdata.showLeaves ) || ( is_branch() && !rdata.showBranches );
  bool skipCollapser = is_root() && rdata.showRoot && ( CHECK(ALWAYS_OPEN) || rdata.allBranchesAlwaysOpen );

  // find the size of the entry label
  if( (type == MEASURE) || (type == MEASURE_THIS_OPEN) )
    {
      if( CHECK(SHOW_LABEL) )
	{
	  int W = 0, H;
	  fl_font( textFont, textSize );
	  fl_measure( text.c_str(), W, H );
	  W += 4; H += 4;  // hack - it looks better
	  textW = W;
	  textH = H;
	}
      else
	{
	  textW = textH = 0;
	}

      // remember vertically where this node is w.r.t the browser
      currentY = rdata.y;

      currentH = textH;

      // find the total size of the entry, depending on if there's a widget
      if( _widget )
	currentH = MAX( _widget->w->h(), currentH );

      // find the total height of this entry by taking the max height of the entry and icons
      if( is_leaf() )
	{
	  if( lIcon )
	    currentH = MAX( currentH, lIcon->h() );
	}
      else
	{
	  currentH = MAX( currentH, cIcon[which]->h() );
	  if( bIcon[which] )
	    currentH = MAX( currentH, bIcon[which]->h() );
	}
    }

  bool skipAhead = (rdata.y + currentH) < rdata.browserY;

  // process the entry
  switch( type )
    {
    case DRAW:
      {
	if( skipEntry || skipAhead ) break;

	draw( rdata, false );

	// draw any vertical connectors connecting our parents, grandparents, etc.,
	if( rdata.showBranches )
	  {
	    int d = depth()-1;
	    for( i = 0; i < rdata.branchConnectors.size(); i++ )
	      {
		if( i != d )
		  {
		    fl_color( rdata.lineColor );
		    fl_line_style( rdata.lineStyle, rdata.lineWidth );
		    fl_line( rdata.branchConnectors[i], rdata.y, rdata.branchConnectors[i], rdata.y+currentH );
		    fl_line_style( 0 );
		  }
	      }
	  }

	rdata.shadedIndex = 1 - rdata.shadedIndex;  // toggle the even/odd entry for shading
      }
      break;

    case MEASURE:
      if( is_leaf() )
	CLEAR( SOME_VISIBLE_CHILDREN );
      else
	{
	  // find out whether the branch has any children that could be visible
	  bool someVisibleChildren = rdata.showLeaves && ( _children.size() > 0 );
	  for( i = 0; i < _children.size(); i++ )
	    {
	      if( _children.child(i)->is_branch() )
		{
		  someVisibleChildren = true;
		  break;
		}
	    }
	  SET( SOME_VISIBLE_CHILDREN, someVisibleChildren );
	}

    case MEASURE_THIS_OPEN:
      if( skipEntry ) break;
      draw( rdata, true );
      break;

    case HANDLE:
      {
	if( skipEntry || skipAhead || !CHECK(ACTIVE) ) break;

	if( event != FL_DRAG && event != FL_NO_EVENT )
	  rdata.justOpenedClosed = false;

	// if we are trying to select all entries between 2 widgets due to a shift-select...
	if( rdata.shiftSelect )
	  {
	    if( (rdata.hilighted == this) || (rdata.grabbed == this) )
	      {
		if( !rdata.shiftSelectAll )
		  {
		    rdata.shiftSelectAll = true;
		    select( true );
		    if( is_branch() && rdata.openOnSelect )
		      {
			open( true );
		      }
		  }
		else
		  {
		    rdata.shiftSelect = false;
		    rdata.shiftSelectAll = false;
		    rdata.grabbed = 0;
		    select( true );
		    if( is_branch() && rdata.openOnSelect )
		      {
			open( true );
		      }
		  }
	      }
	    else if( rdata.shiftSelectAll )
	      {
		select( true );
		if( is_branch() && rdata.openOnSelect )
		  {
		    open( true );
		  }
	      }
	    break;
	  }

	// check for the keyboard event
	if( event == FL_KEYDOWN )
	  {
	    // check for the spacebar selecting this entry
	    if( Fl::event_key() == ' ' && rdata.hilighted == this )
	      {
		if( Fl::event_state(FL_CTRL) )
		  select( !CHECK(SELECTED) );
		else
		  {
		    rdata.root->unselect_all( this );
		    select( true );
		  }
		if( is_branch() && rdata.openOnSelect )
		  {
		    open( true );
		  }
		return 1;		
	      }

	    // check for the enter key opening/closing this entry
	    else if( (Fl::event_key() == FL_Enter) && (rdata.hilighted == this) )
	      {
		open( !open() );
		return 1;
	      }

	    // check for the left/right cursor keys opening/closing this entry
	    else if( (Fl::event_key() == FL_Left) && (rdata.hilighted == this) )
	      {
		open( false );
		return 1;
	      }
	    else if( (Fl::event_key() == FL_Right) && (rdata.hilighted == this) )
	      {
		open( true );
		return 1;
	      }
	  }

	// check for the "up" cursor key moving the hilighted entry
	if( rdata.delta == -1 && rdata.hilighted == this && rdata.previous != NULL )
	  {
	    tree->set_hilighted( rdata.previous );
	    rdata.delta = 0;
	    return 1;
	  }

	// check for the "down" cursor key moving the hilighted entry
	if( rdata.delta == 1 && rdata.hilighted == rdata.previous )
	  {
	    tree->set_hilighted( this );
	    rdata.delta = 0;
	    return 1;
	  }

	rdata.previous = this;

	// the event is not ours to use
	//if( _widget && !rdata.dragging )
	//if( Fl::event_inside( _widget->w ) )
	//  return 2;

	bool inExpander = false;
	if( is_branch() )
	  {
	    int which = open();
	    if( _parent==0 )
	      inExpander = Fl::event_inside( rdata.x, rdata.y+(currentH>>1)-(cIcon[which]->h()>>1),
					     cIcon[which]->w(), cIcon[which]->h() );
	    else
	      inExpander = Fl::event_inside( rdata.x+(rdata.branchIconW>>1)-(cIcon[which]->w()>>1),
					     rdata.y+(currentH>>1)-(cIcon[which]->h()>>1),
					     cIcon[which]->w(), cIcon[which]->h() );
	  }

	if( event == FL_PUSH )
	  {	
	    // check for expand/collapse
	    if( Fl::event_button() == FL_LEFT_MOUSE && inExpander )
	      {
		if( rdata.openWOChildren || CHECK(SOME_VISIBLE_CHILDREN) )
		  {
		    open( !open() );
		    rdata.dragging = false;
		    rdata.dragNode = 0;
		    return 1;
		  }
	      }
	  }

	if( event == FL_DRAG && rdata.justOpenedClosed )
	  return 0;

	// if no selections, return
	if( rdata.selectionMode == FLU_NO_SELECT )
	  break;

	// if the event is not inside us, return
	if( !Fl::event_inside( rdata.browserX, rdata.y, rdata.browserW, currentH ) )
	  break;

#ifdef USE_FLU_DND
	// check for grabbing of a node for DND
	if( event == FL_DRAG && rdata.selectionDragMode == FLU_DRAG_TO_MOVE && !is_root() && rdata.grabbed &&
	    //rdata.insertionMode!=FLU_INSERT_SORTED && rdata.insertionMode!=FLU_INSERT_SORTED_REVERSE &&
	    !tree->dnd_is_dragging() && !rdata.justOpenedClosed && CHECK(MOVABLE) )
	  {
	    tree->dnd_grab( this, "Flu_Tree_Browser" );
	    return 1;
	  }

	// dragging to move a node
	if( event == FL_DND_DRAG )
	  {
	    rdata.dragNode = this; // remember which node to move the grabbed node before/after
	    if( is_root() )
	      {
		rdata.dragWhere = MOVE_AFTER;
		rdata.dragPos = rdata.y + currentH;
	      }
	    else
	      {
		// if this is a leaf or an open branch, then can only move before or after
		// otherwise can move inside
		if( is_branch() && !open() )
		  {
		    int t = MAX( currentH / 3, 1 );
		    if( (Fl::event_y()-rdata.y) <= t )
		      rdata.dragWhere = MOVE_BEFORE;
		    else if( (Fl::event_y()-rdata.y) <= (t<<1) )
		      rdata.dragWhere = MOVE_INSIDE;
		    else
		      rdata.dragWhere = MOVE_AFTER;
		  }
		else
		  {
		    if( (Fl::event_y()-rdata.y) <= (currentH>>1) )
		      rdata.dragWhere = MOVE_BEFORE;
		    else
		      rdata.dragWhere = MOVE_AFTER;
		  }

		// where to draw the insertion position?
		if( rdata.dragWhere == MOVE_BEFORE || rdata.dragWhere == MOVE_INSIDE )
		  rdata.dragPos = rdata.y;
		else
		  rdata.dragPos = rdata.y + currentH;
	      }
	    return 1;
	  }
#endif

	//if( _widget && _widget->w && Fl::event_inside(_widget->w) && _widget->w->handle(event))
	//return 1;

	// single selection
	if( rdata.selectionMode == FLU_SINGLE_SELECT )
	  {
	    if( event == FL_MOVE && rdata.selectUnderMouse )
	      {
		//select_only();
		rdata.root->unselect_all( this );
		SET(SELECTED,true);
		tree->redraw();
	      }
	    else if( event == FL_PUSH )
	      {
		//rdata.dragging = true;
		rdata.grabbed = this;

		if( rdata.selectUnderMouse )
		  rdata.root->unselect_all();
		else
		  rdata.root->unselect_all( this );
		tree->set_hilighted( this );
		if( Fl::event_state(FL_CTRL) )
		  select( !CHECK(SELECTED) );
		else
		  select( true );

		if( is_leaf() )
		  {
		    if( Fl::event_clicks() > 0 )
		      {
			Fl::event_clicks(0);
			do_callback( FLU_DOUBLE_CLICK );
		      }
		  }
		else
		  {
		    if( Fl::event_clicks() > 0 )
		      {
			Fl::event_clicks(0);
			if( rdata.doubleClickToOpen )
			  {
			    if( rdata.openWOChildren || CHECK(SOME_VISIBLE_CHILDREN) )
			      open( !open() );
			  }
			else
			  do_callback( FLU_DOUBLE_CLICK );
		      }
		    else if( rdata.openOnSelect )
		      {
			open( true );
		      }
		  }
		Fl::focus(tree);
		return 1;
	      }
	    else if( event == FL_DRAG )
	      {
		if( rdata.selectionDragMode == FLU_DRAG_IGNORE )
		  return 1;
		rdata.dragging = true;
		//if( ( rdata.selectionDragMode == FLU_DRAG_IGNORE || rdata.selectionDragMode == FLU_DRAG_TO_MOVE) && ( tree->insertion_mode() == FLU_INSERT_FRONT || tree->insertion_mode() == FLU_INSERT_BACK ) )
		//return 1;
		rdata.root->unselect_all( this );
		tree->set_hilighted( this );
		select( true );
		return 1;
	      }
	    else if( event == FL_RELEASE && tree->when() == FL_WHEN_RELEASE && selected() && !inExpander )
	      {
		do_callback( FLU_SELECTED );
		return 1;
	      }
	  }

	// multiple selection
	else if( rdata.selectionMode == FLU_MULTI_SELECT )
	  {
	    if( event == FL_PUSH )
	      {
		//rdata.dragging = true;
		rdata.grabbed = this;

		if( Fl::event_state(FL_CTRL) )
		  {
		    select( !CHECK(SELECTED) );
		    tree->set_hilighted( this );
		  }
		else if( Fl::event_state(FL_SHIFT) )
		  {
		    // select everything from the last selected entry to this one
		    if( rdata.hilighted == this )
		      {
			select( true );
			if( is_branch() )
			  {
			    if( Fl::event_clicks() > 0 )
			      {
				Fl::event_clicks(0);
				if( rdata.doubleClickToOpen )
				  {
				    if( rdata.openWOChildren || CHECK(SOME_VISIBLE_CHILDREN) )
				      open( !open() );
				  }
				else
				  do_callback( FLU_DOUBLE_CLICK );
			      }
			    else if( rdata.openOnSelect )
			      {
				open( !open() );
			      }
			  }
		      }
		    else
		      {
			rdata.shiftSelectAll = false;
			rdata.shiftSelect = true;
			rdata.grabbed = this;
			rdata.root->recurse( rdata, HANDLE, 0 );
			tree->set_hilighted( this );
		      }
		  }
		else
		  {
		    rdata.root->unselect_all( this );
		    select( true );
		    if( is_leaf() )
		      {
			if( Fl::event_clicks() > 0 )
			  {
			    Fl::event_clicks(0);
			    do_callback( FLU_DOUBLE_CLICK );
			  }
		      }
		    else
		      {
			if( Fl::event_clicks() > 0 )
			  {
			    Fl::event_clicks(0);
			    if( rdata.doubleClickToOpen )
			      {
				if( rdata.openWOChildren || CHECK(SOME_VISIBLE_CHILDREN) )
				  open( !open() );
			      }
			    else
			      do_callback( FLU_DOUBLE_CLICK );
			  }
			else if( rdata.openOnSelect )
			  {
			    open( true );
			  }
		      }
		    tree->set_hilighted( this );
		  }
		Fl::focus(tree);
		return 1;
	      }
	    else if( event == FL_DRAG )
	      {
		if( rdata.selectionDragMode == FLU_DRAG_IGNORE )
		  return 1;
		rdata.dragging = true;
		//if( ( rdata.selectionDragMode == FLU_DRAG_IGNORE || rdata.selectionDragMode == FLU_DRAG_TO_MOVE) && ( tree->insertion_mode() == FLU_INSERT_FRONT || tree->insertion_mode() == FLU_INSERT_BACK ) )
		//return 1;
		select( true );
		tree->set_hilighted( this );
		return 1;
	      }
	    else if( event == FL_RELEASE && tree->when() == FL_WHEN_RELEASE && selected() && !inExpander )
	      {
		do_callback( FLU_SELECTED );
		return 1;
	      }
	  }
      }
      break;
    }

  // advance the counters vertically to the next entry
  if( !skipEntry )
    rdata.y += currentH + rdata.vGap;

  if( !is_root() && rdata.first && !skipEntry )
    rdata.first = false;

  // if we're a leaf, no need to process further
  if( is_leaf() )
    return 0;

  // should we bail out already if we're done processing?
  if( closed() && !skipEntry && !skipCollapser && tree->rdata.animatedNode!=this && ( type != MEASURE_THIS_OPEN ) )
    return 0;

  if( !CHECK(SOME_VISIBLE_CHILDREN) )
    return 0;

  // advance the counters horizontally to the next entry
  if( rdata.showBranches )
    {
      if( !skipEntry && !skipCollapser )
	rdata.x += cIcon[which]->w() + rdata.hGap;
    }
  rdata.totalW = MAX( rdata.totalW, rdata.x );

  // the branchIconW is the width of the branch icon at this level
  // it is used to center all children icons under the branch icon
  int lastBranchIconW = rdata.branchIconW;
  if( rdata.showBranches )
    {
      if( bIcon[which] )
	rdata.branchIconW = bIcon[which]->w();
      else
	rdata.branchIconW = cIcon[which]->w();
    }
  else
    rdata.branchIconW = 0;

  // update the animation
  if( tree->rdata.animatedNode==this && ( type == DRAW ) )
    {
      // check for termination (if opening)
      if( (rdata.animationOffset+rdata.animationDelta) >= 0.0f )
	{
	  tree->rdata.animatedNode = NULL;
	  rdata.animating = false;
	  tree->rdata.forceResize = true;
	  Fl::remove_timeout( _timerRedrawCB, tree );
	}
      else
	{
	  // update the offset
	  rdata.animationOffset += rdata.animationDelta;
	  fl_push_clip( rdata.browserX, rdata.y, rdata.browserW, rdata.browserH );
	  rdata.y += (int)rdata.animationOffset;
	}
    }

  if( ( type == MEASURE ) || ( type == MEASURE_THIS_OPEN ) )
    totalChildH = rdata.y;

  // process all children
  int val;
  int tempW = rdata.branchIconW >> 1;
  for( i = 0; i < _children.size(); i++ )
    {
      // prepare the recursive data structure for the next level
      if( i == 0 )
	rdata.first = true;
      rdata.last = (i == _children.size()-1 );

      // if child "i" is not the last child,
      // then there is a long connector that needs drawn between this node and the last child.
      // push the horizontal position of the connector onto the stack
      if( (type == DRAW) && rdata.showConnectors && ( i < _children.size()-1 ) )
	{
	  rdata.branchConnectors.push( rdata.x+tempW );
	  val = _children.child(i)->recurse( rdata, type, event );
	  rdata.branchConnectors.pop();
	}
      else
	val = _children.child(i)->recurse( rdata, type, event );

      if( val )
	return val;
    }

  // set the branch icon width back to what it was before we changed it
  rdata.branchIconW = lastBranchIconW;

  if( ( type == MEASURE ) || ( type == MEASURE_THIS_OPEN ) )
    totalChildH = rdata.y - totalChildH;

  // update the animation
  if( tree->rdata.animatedNode==this && ( type == DRAW ) )
    {
      fl_pop_clip();
      // check for termination (if closing)
      if( rdata.animationOffset <= (float)(-totalChildH) )
	{
	  tree->rdata.animatedNode = NULL;
	  rdata.animating = false;
	  tree->rdata.forceResize = true;
	  Fl::remove_timeout( _timerRedrawCB, tree );
	}
    }

  // move back horizontally from the last entry
  if( rdata.showBranches )
    {
      if( !skipEntry && !skipCollapser )
	rdata.x -= cIcon[which]->w() + rdata.hGap;
    }

  return 0;
}

void Flu_Tree_Browser :: print()
{
  root.print();
}

void Flu_Tree_Browser :: clear()
{
  root.clear();
  root.text = "";

  while( _box->children() )
    _box->remove( *_box->child(0) );

  rdata.cbNode = NULL;
  rdata.cbReason = FLU_NOTHING;
  rdata.hilighted = NULL;
  rdata.dragging = false;
  rdata.forceResize = true;
  rdata.lastOpenBranch = NULL;
  rdata.shiftSelect = false;
  rdata.shiftSelectAll = false;
  rdata.nextId = 1;
  rdata.searchIndex = 1;
}

Flu_Tree_Browser::Node* Flu_Tree_Browser :: set_root( const char *label, Fl_Widget *w, bool showLabel )
{
  if( label == 0 )
    label = "";
  root.text = label;
  root.widget( w );
  root.SET(Node::SHOW_LABEL,showLabel);
  root.cIcon[0] = rdata.collapseIcons[0];
  root.cIcon[1] = rdata.collapseIcons[1];
  root.bIcon[0] = rdata.branchIcons[0];
  root.bIcon[1] = rdata.branchIcons[1];
  root.textColor = rdata.defBranchColor;
  root.textFont = rdata.defBranchFont;
  root.textSize = rdata.defBranchSize;
  rdata.forceResize = true;

  return &root;
}

Flu_Tree_Browser::Node* Flu_Tree_Browser :: add( const char* fullpath, Fl_Widget *w, bool showLabel )
{
  return( root.modify( fullpath, Node::ADD, rdata, w, showLabel ) );
}

Flu_Tree_Browser::Node* Flu_Tree_Browser :: add( const char* path, const char* text, Fl_Widget *w, bool showLabel )
{
  // if the path does not end in '/', add it
  FluSimpleString s = path;
  if( path[strlen(path)-1] != '/' )
    s += "/";
  s += text;

  return add( s.c_str(), w, showLabel );
}

Flu_Tree_Browser::Node* Flu_Tree_Browser :: add_branch( const char* fullpath, Fl_Widget *w, bool showLabel )
{
  FluSimpleString p( fullpath );
  if( p.size() && p[p.size()-1] != '/' && p[p.size()-1] != '\\' ) p += "/";
  return add( p.c_str(), w, showLabel );
}

Flu_Tree_Browser::Node* Flu_Tree_Browser :: add_branch( const char* path, const char* name, Fl_Widget *w, bool showLabel )
{
  FluSimpleString p( name );
  if( p.size() && p[p.size()-1] != '/' && p[p.size()-1] != '\\' ) p += "/";
  return add( path, p.c_str(), w, showLabel );
}

Flu_Tree_Browser::Node* Flu_Tree_Browser :: add_leaf( const char* fullpath, Fl_Widget *w, bool showLabel )
{
  FluSimpleString p( fullpath );
  if( p.size() && ( p[p.size()-1] == '/' || p[p.size()-1] == '\\' ) ) p[p.size()-1] = '\0';
  return add( p.c_str(), w, showLabel );
}

Flu_Tree_Browser::Node* Flu_Tree_Browser :: add_leaf( const char* path, const char* name, Fl_Widget *w, bool showLabel )
{
  FluSimpleString p( name );
  if( p.size() && ( p[p.size()-1] == '/' || p[p.size()-1] == '\\' ) ) p[p.size()-1] = '\0';
  return add( path, p.c_str(), w, showLabel );
}

unsigned int Flu_Tree_Browser :: remove( const char *fullpath )
{
  return( (unsigned int)root.modify( fullpath, Node::REMOVE, rdata ) );
}

unsigned int Flu_Tree_Browser :: remove( const char *path, const char *text )
{
  // if the path does not end in '/', add it
  FluSimpleString s = path;
  if( path[strlen(path)-1] != '/' )
    s += "/";
  s += text;
  return remove( s.c_str() );
}

unsigned int Flu_Tree_Browser :: remove( unsigned int id )
{
  return root.remove( id );
}

unsigned int Flu_Tree_Browser :: Node :: remove( unsigned int id )
{
  if( id == 0 )
    return 0;

  for( int i = 0; i < _children.size(); i++ )
    {
      Node *n = _children.child(i);
      if( n->id() == id )
	{
	  _children.erase( i );
	  tree->rdata.forceResize = true;
	  //if( tree->rdata.cbNode == n )
	  //tree->rdata.cbNode = NULL;
	  delete n;
	  if( tree->rdata.autoBranches )
	    initType();
	  tree->redraw();
	  return id;
	}
      else if( n->remove( id ) )
	return id;
    }

  return 0;
}

unsigned int Flu_Tree_Browser :: remove( Fl_Widget *w )
{
  return root.remove( w );
}

unsigned int Flu_Tree_Browser :: Node :: remove( Fl_Widget *w )
{
  if( !w )
    return 0;
  for( int i = 0; i < _children.size(); i++ )
    {
      Node *n = _children.child(i);
      if( n->_widget )
	{
	  if( n->_widget->w == w )
	    {
	      int id = n->id();
	      _children.erase( i );
	      tree->rdata.forceResize = true;
	      //if( tree->rdata.cbNode == n )
	      //tree->rdata.cbNode = NULL;
	      delete n;
	      if( tree->rdata.autoBranches )
		initType();
	      tree->redraw();
	      return id;
	    }
	}

      int id = n->remove( w );
      if( id )
	return id;
    }

  return 0;
}

int Flu_Tree_Browser :: find_number( const char *fullpath )
{
  rdata.counter = 0;
  root.modify( fullpath, Node::FIND_NUMBER, rdata );
  return rdata.counter;
}

int Flu_Tree_Browser :: find_number( const char *path, const char *text )
{
  // if the path does not end in '/', add it
  FluSimpleString s = path;
  if( path[strlen(path)-1] != '/' )
    s += "/";
  s += text;
  return find_number( s.c_str() );
}

Flu_Tree_Browser::Node* Flu_Tree_Browser :: find_next( const char *fullpath, Node* startNode )
{
  // degenerate case: root node
  if( strcmp( fullpath, "/" ) == 0 )
    return &root;
  rdata.previous = startNode;
  return( root.modify( fullpath, Node::FIND, rdata ) );
}

Flu_Tree_Browser::Node* Flu_Tree_Browser :: find_next( const char *path, const char *text )
{
  // if the path does not end in '/', add it
  FluSimpleString s = path;
  if( path[strlen(path)-1] != '/' )
    s += "/";
  s += text;
  return find_next( s.c_str() );
}

Flu_Tree_Browser::Node* Flu_Tree_Browser :: find( const char *path, const char *text )
{
  // if the path does not end in '/', add it
  FluSimpleString s = path;
  if( path[strlen(path)-1] != '/' )
    s += "/";
  s += text;
  return find( s.c_str() );
}

Flu_Tree_Browser::Node* Flu_Tree_Browser :: find( unsigned int id )
{
  return root.find( id );
}

Flu_Tree_Browser::Node* Flu_Tree_Browser :: Node :: find( unsigned int id )
{
  if( id == 0 )
    return NULL;

  if( _id == id )
    return this;

  for( int i = 0; i < _children.size(); i++ )
    {
      Node *n = _children.child(i)->find( id );
      if( n )
	return n;
    }

  return NULL;
}

Flu_Tree_Browser::Node* Flu_Tree_Browser :: find( Fl_Widget *w )
{
  return root.find( w );
}

Flu_Tree_Browser::Node* Flu_Tree_Browser :: Node :: find( Fl_Widget *w )
{
  if( _widget )
    if( _widget->w == w )
      return this;

  for( int i = 0; i < _children.size(); i++ )
    {
      Node *n = _children.child(i)->find( w );
      if( n )
	return n;
    }

  return NULL;
}


bool Flu_Tree_Browser :: Node :: findPath( unsigned int id, RData &rdata )
{
  if( _id == id )
    {
      if( is_leaf() )
	rdata.path += text;
      else
	{
	  rdata.path += text;
	  rdata.path += "/";
	}
      return true;
    }

  if( is_leaf() )
    return false;

  char *oldPath = strdup( rdata.path.c_str() );
  if( _parent != 0 )
    {
      rdata.path += text;
      rdata.path += "/";
    }

  for( int i = 0; i < _children.size(); i++ )
    {
      if( _children.child(i)->findPath( id, rdata ) )
	{
	  free( oldPath );
	  return true;
	}
    }

  rdata.path = oldPath;
  free( oldPath );

  return false;
}

bool Flu_Tree_Browser :: Node :: findPath( Fl_Widget *w, RData &rdata )
{
  if( _widget )
    if( _widget->w == w )
      {
	if( is_leaf() )
	  rdata.path += text;
	else
	  {
	    rdata.path += text;
	    rdata.path += "/";
	  }
	return true;
      }

  if( is_leaf() )
    return false;

  char *oldPath = strdup( rdata.path.c_str() );
  if( _parent != 0 )
    {
      rdata.path += text;
      rdata.path += "/";
    }

  for( int i = 0; i < _children.size(); i++ )
    {
      if( _children.child(i)->findPath( w, rdata ) )
	{
	  free( oldPath );
	  return true;
	}
    }

  rdata.path = oldPath;
  free( oldPath );

  return false;
}

const char* Flu_Tree_Browser :: find_path( unsigned int id )
{
  // degenerate case: the root is always id==0
  if( id == 0 )
    return "/";
  rdata.path = "/";
  if( root.findPath( id, rdata ) )
    return rdata.path.c_str();
  else
    return "";
}

const char* Flu_Tree_Browser :: find_path( Fl_Widget *w )
{
  rdata.path = "/";
  if( root.findPath( w, rdata ) )
    return rdata.path.c_str();
  else
    return "";
}

static char* remove_escape_chars( const char *str )
{
  // remove any escape characters
  char *text = strdup( str );
  int tIndex = 0;
  for( int pIndex = 0; pIndex < (int)strlen( str ); pIndex++ )
    {
      if( str[pIndex] != '\\' )
	text[tIndex++] = str[pIndex];
    }
  text[tIndex] = '\0';

  return text;
}

void Flu_Tree_Browser :: Node :: do_callback( int reason )
{
  //if( tree->rdata.when == FL_WHEN_NEVER )
  if( tree->when() == FL_WHEN_NEVER )
    return;
  //if( tree->rdata.cb )
    {
      tree->rdata.cbReason = reason;
      tree->rdata.cbNode = this;
      //tree->rdata.cb( tree, tree->rdata.cbd );
      ((Fl_Widget*)tree)->do_callback();
    }
}

unsigned short Flu_Tree_Browser :: Node :: depth() const
{
  int d = 0;
  Node *p = _parent;
  while( p )
    {
      d++;
      p = p->_parent;
    }
  return d;
}

Flu_Tree_Browser::Node* Flu_Tree_Browser :: Node :: add_branch( const char* fullpath, Fl_Widget *w, bool showLabel )
{
  FluSimpleString p( fullpath );
  if( p.size() && p[p.size()-1] != '/' && p[p.size()-1] != '\\' ) p += "/";
  return add( p.c_str(), w, showLabel );
}

Flu_Tree_Browser::Node* Flu_Tree_Browser :: Node :: add_leaf( const char* fullpath, Fl_Widget *w, bool showLabel )
{
  FluSimpleString p( fullpath );
  if( p.size() && ( p[p.size()-1] == '/' || p[p.size()-1] == '\\' ) ) p[p.size()-1] = '\0';
  return add( p.c_str(), w, showLabel );
}

Flu_Tree_Browser::Node* Flu_Tree_Browser :: Node :: add( const char* path, const char* name, Fl_Widget *w, bool showLabel )
{
  FluSimpleString p( path );
  if( p.size() && p[p.size()-1] != '/' && p[p.size()-1] != '\\' ) p += "/";
  p += name;
  return add( p.c_str(), w, showLabel );
}

Flu_Tree_Browser::Node* Flu_Tree_Browser :: Node :: add_branch( const char* path, const char* name, Fl_Widget *w, bool showLabel )
{
  FluSimpleString p( path );
  if( p.size() && p[p.size()-1] != '/' && p[p.size()-1] != '\\' ) p += "/";
  p += name;
  return add_branch( p.c_str(), w, showLabel );
}

Flu_Tree_Browser::Node* Flu_Tree_Browser :: Node :: add_leaf( const char* path, const char* name, Fl_Widget *w, bool showLabel )
{
  FluSimpleString p( path );
  if( p.size() && p[p.size()-1] != '/' && p[p.size()-1] != '\\' ) p += "/";
  p += name;
  return add_leaf( p.c_str(), w, showLabel );
}

Flu_Tree_Browser::Node* Flu_Tree_Browser :: Node :: modify( const char* path, int what, RData &rdata, Fl_Widget *w, bool showLabel )
{
  // find the selected entry at rdata.searchIndex among all selected entries
  if( what == GET_SELECTED )
    {
      if( CHECK(SELECTED) )
	{
	  rdata.counter++;
	  if( rdata.counter == rdata.searchIndex )
	    return this;
	}
      for( int i = 0; i < _children.size(); i++ )
	{
	  Node *n = _children.child(i)->modify( path, what, rdata, w );
	  if( n )
	    return n;
	}
      return NULL;
    }

  // trivial test for a bogus empty path
  if( path == 0 )
    return NULL;

  // if the path starts with '/', skip the '/'
  if( path[0] == '/' )
    path++;

  // trivial test for a bogus empty path
  if( path[0] == '\0' )
    return NULL;

  const char *remainingPath;
  char *nodeName;
  bool lastNode, branchNode;
  Node *retNode = NULL;

  ///////////// extract the next node name from the path ///////////////////

  // find the next '/' that is not preceded by the escape character '\'
  const char *slash = strchr( path, '/' );
  for(;;)
    {
      // find the next '/'
      if( slash == NULL ) // there isn't one, so we're done
	break;
      // test for escape character
      else if( slash[-1] == '\\' ) // path[0] can never be '/', so this is a safe test
	slash = strchr( slash+1, '/' );
      // we have it
      else
	break;
    }

  // if there is no slash, then the node name is the path and it is a leaf and the last node in the path
  if( slash == NULL )
    {
      branchNode = false;
      char *name = strdup( path ); // copy the path
      nodeName = remove_escape_chars( name ); // remove the escape characters
      free( name );
      lastNode = true;
      remainingPath = NULL;
    }
  // otherwise the node name is the path up to the slash, it is also a branch and may not be the last node in the path
  else
    {
      branchNode = true;
      char *name = (char*)malloc( slash-path+1 );
      strncpy( name, path, slash-path );
      name[slash-path] = '\0';
      nodeName = remove_escape_chars( name ); // remove the escape characters
      free( name );
      lastNode = ( slash[1] == '\0' ); // this is the last node if there is nothing after the slash
      if( lastNode )
	{
	  //if( rdata.autoBranches )
	  //branchNode = false;
	  remainingPath = NULL;
	}
      else
	remainingPath = slash+1;
    }

  ///////////// process the node ///////////////////

  switch( what )
    {
    case ADD:
      {
	// if the new node is a leaf node, add the string as a leaf and return
	if( !branchNode )
	  {
	    // is there already a node with this name?
	    Node *n = _children.find( nodeName );
	    if( n )
	      {
		// if that node is a branch node, we can't add a new one with the same name
		if( n->is_branch() )
		  break;

		// if we are not allowed to add multiple nodes with the same name,
		// then just return
		if( !rdata.allowDuplication )
		  break;
	      }

	    // add a new node
	    retNode = new Node( true, nodeName, this, rdata, w, showLabel );
	    _children.add( retNode );
	    rdata.forceResize = true;
	    rdata.visibilityChanged = true;

	    if( tree->rdata.autoBranches )
	      initType();
	  }
	// otherwise make sure the node name exists as a branch and recurse on it
	else
	  {
	    // if there is already a node with this name, just use it
	    Node *n = NULL;
	    n = _children.find( nodeName );
	    if( n )
	      {
		// make sure it is a branch
		if( n->is_leaf() )
		  break;
	      }

	    // else add a new node
	    if( n == NULL )
	      {
		// only add the widget for the last node
		n = new Node( false, nodeName, this, rdata, lastNode?w:NULL, lastNode?showLabel:true );
		_children.add( n );
		rdata.forceResize = true;
		rdata.visibilityChanged = true;
	      }

	    if( tree->rdata.autoBranches )
	      initType();

	    // recurse on the remainder of the path, if not the last node
	    if( lastNode )
	      retNode = n;
	    else
	      retNode = n->modify( remainingPath, what, rdata, w, showLabel );
	  }
      }
      break;

    case REMOVE:
      {
	// try to find the indicated node. if we can't find it, just return
	Node *n = _children.find( nodeName );
	if( !n )
	  break;

	// if this is the last node, remove it.
	if( lastNode )
	  {
	    int ID = n->id();
	    _children.erase( n );
	    //if( tree->rdata.cbNode == n )
	    //tree->rdata.cbNode = NULL;
	    delete n;
	    retNode = (Node*)ID; // non-null return value means remove was successful
	    rdata.forceResize = true;
	    rdata.visibilityChanged = true;

	    if( tree->rdata.autoBranches )
	      initType();
	    tree->redraw();
	  }
	// otherwise recurse on the remainder of the path
	else
	  retNode = n->modify( remainingPath, what, rdata, w, showLabel );
      }
      break;

    case FIND:
      {
	// if this node equals the starting node for a find_next,
	// then by clearing rdata.previous we flag that we are allowed to return the next match
	if( rdata.previous == this )
	  rdata.previous = NULL;

	Node *n = NULL;

	if( !lastNode )
	  {
	    // if, according to the path, this is not the last node, then just recursively
	    // search for the named node
	    n = _children.find( nodeName );
	    if( !n )
	      break;
	    retNode = n->modify( remainingPath, what, rdata, w, showLabel );
	  }
	else
	  {
	    // otherwise, according to the path, this is the last node (i.e. a leaf).
	    // since only leaves can have multiple identical entries,
	    // try to find the indicated node, accounting for the possibility
	    // that it may not be the one we're after
	    int next = 1;
	    for(;;)
	      {
		// look for the named node
		n = _children.find( nodeName, next++ );

		// if we can't find it, just return, because it's not here
		if( !n )
		  break;

		// we are only allowed to return a match if the previous node is NULL,
		// indicating we have passed the starting node for a find_next
		if( rdata.previous == NULL )
		  {
		    retNode = n;
		    break;
		  }

		// if the found node equals the starting node for a find_next,
		// then by clearing rdata.previous we flag that we are allowed to return the next match
		if( rdata.previous == n )
		  rdata.previous = NULL;
	      }
	  }
      }
      break;

    case FIND_NUMBER:
      {
	if( lastNode )  // can only match multiple leaves if the path says this is the last node
	  {
	    rdata.counter += _children.findNum( nodeName );
	  }
	else  // otherwise recurse down the remaining path
	  {
	    Node *n = _children.find( nodeName );
	    n->modify( remainingPath, what, rdata, w, showLabel );
	  }
      }
      break;
    }

  free( nodeName );

  return retNode;
}

void Flu_Tree_Browser :: Node :: widgetCB()
{
  if( _widget )
    {
      if( _widget->CB )
	_widget->CB( _widget->w, _widget->CBData );
    }
  do_callback( FLU_WIDGET_CALLBACK );
}

void Flu_Tree_Browser :: Node :: widget( Fl_Widget *w )
{
  tree->rdata.forceResize = true;

  if( _widget )
    {
      Fl_Group *p = _widget->w->parent();
      if( p )
	p->remove( *(_widget->w) );
      delete _widget->w;
      delete _widget;
      _widget = NULL;
    }

  if( !w )
    return;

  _widget = new WidgetInfo;
  _widget->w = w;
  _widget->defaultW = _widget->w->w();
  if( USE_FLU_WIDGET_CALLBACK )
    {
      _widget->CB = _widget->w->callback();
      _widget->CBData = _widget->w->user_data();
      _widget->w->callback( _widgetCB, this );
    }

  {
    Fl_Group *p = w->parent();
    if( p )
      p->remove( *w );
  }

  if( is_root() )
    tree->_box->add( w );
  else
    {
      Node *p = parent();
      if( !p->_group )
	{
	  p->_group = new Fl_Group( tree->_box->x(), tree->_box->y(), tree->_box->w(), tree->_box->h() );
	  p->_group->end();
	  tree->_box->add( p->_group );
	}
      p->_group->add( w );
    }
}

void Flu_Tree_Browser :: Node :: branch_icons( Fl_Image *closed, Fl_Image *open )
{
  if( is_branch() )
    {
      bIcon[0] = closed;
      bIcon[1] = open;
      tree->rdata.forceResize = true;
    }
}

void Flu_Tree_Browser :: Node :: collapse_icons( Fl_Image *closed, Fl_Image *open )
{
  if( is_branch() )
    {
      if( !closed || !open )
	{
	  cIcon[0] = tree->rdata.defaultCollapseIcons[0];
	  cIcon[1] = tree->rdata.defaultCollapseIcons[1];
	}
      else
	{
	  cIcon[0] = closed;
	  cIcon[1] = open;
	}
      tree->rdata.forceResize = true;
    }
}

void Flu_Tree_Browser :: Node :: leaf_icon( Fl_Image *icon )
{
  if( is_leaf() )
    {
      lIcon = icon;
      tree->rdata.forceResize = true;
    }
}

bool Flu_Tree_Browser :: Node :: is_branch() const
{
  if( tree->rdata.autoBranches )
    return( _children.size() != 0 );
  else
    return !CHECK(LEAF);
}

bool Flu_Tree_Browser :: Node :: is_leaf() const
{
  if( tree->rdata.autoBranches )
    return( _children.size() == 0 && !is_root() );
  else
    return CHECK(LEAF);
}
