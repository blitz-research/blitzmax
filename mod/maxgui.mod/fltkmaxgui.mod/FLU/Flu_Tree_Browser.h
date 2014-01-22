// $Id: Flu_Tree_Browser.h,v 1.91 2004/11/05 17:03:20 jbryan Exp $

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



#ifndef _FLU_TREE_BROWSER_H
#define _FLU_TREE_BROWSER_H

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

//#define USE_FLU_DND

/* fltk includes */
#include <FL/Fl.H>
#include <FL/Fl_Box.H>
#include <FL/Fl_Pixmap.H>
#include <FL/Fl_Image.H>
#include <FL/Fl_Scrollbar.H>
#include <FL/Fl_Group.H>
#include <FL/Fl_Menu_Button.H>

/* flu includes */
#include "FLU/Flu_Enumerations.h"
#include "FLU/FluSimpleString.h"
#ifdef USE_FLU_DND
#include "FLU/Flu_DND.h"
#else
typedef struct { bool dummy; } Flu_DND_Event;  // for compatibilty when not compiling DND support
#endif

//! This class provides a browser for hierarchical data representation (i.e. a "tree")
#ifdef USE_FLU_DND
class FLU_EXPORT Flu_Tree_Browser : public Fl_Group, public Flu_DND
#else
class FLU_EXPORT Flu_Tree_Browser : public Fl_Group
#endif
{

  static bool USE_FLU_WIDGET_CALLBACK;

 public:

  class Node;
  friend class Node;

  //! Normal FLTK widget constructor
  Flu_Tree_Browser( int x, int y, int w, int h, const char *label = 0 );

  //! Default destructor
  virtual ~Flu_Tree_Browser();

  //! Add the entry specified by \b fullpath to the tree. If \b w is not \c NULL then that widget is the entry and its label is visible depending on the value of \b showLabel. Note that the widget is destroyed by the tree/node on clear() or the destructor
  /*! If \b fullpath ends in a slash ("/"), then the entry is added as a branch, else it is added as a leaf
    \return a pointer to the Node of the added entry or NULL if the add failed */
  Node* add( const char* fullpath, Fl_Widget *w = 0, bool showLabel = true );

  //! Convenience function that is the same as add() except \b path and \b name are concatenated (with a '/' added if necessary) to create the full path
  Node* add( const char* path, const char* name, Fl_Widget *w = 0, bool showLabel = true );

  //! Add entry \b name to node \b n. If \b w is not \c NULL then that widget is the entry and its label is visible depending on the value of \b showLabel. Note that the widget is destroyed by the tree/node on clear() or the destructor
  /*! If \b name ends in a slash ("/"), then the entry is added as a branch, else it is added as a leaf
    \return a pointer to the Node of the added entry or NULL if the add failed */
  inline Node* add( Node* n, const char* name, Fl_Widget *w = 0, bool showLabel = true )
    { return n->add( name, w, showLabel ); }

  //! Convenience function that is the same as add() except it appends a '/' to \b fullpath if one does not exist
  Node* add_branch( const char* fullpath, Fl_Widget *w = 0, bool showLabel = true );

  //! Convenience function that is the same as add() except \b path and \b name are concatenated (with a '/' added if necessary) to create the full path
  Node* add_branch( const char* path, const char* name, Fl_Widget *w = 0, bool showLabel = true );

  //! Convenience function that is the same as add() except it appends a '/' to \b name if one does not exist
  inline Node* add_branch( Node* n, const char* name, Fl_Widget *w = 0, bool showLabel = true )
    { return n->add_branch( name, w, showLabel ); }

  //! Convenience function that is the same as add() except it removes any '/' at the end of \b fullpath
  Node* add_leaf( const char* fullpath, Fl_Widget *w = 0, bool showLabel = true );

  //! Convenience function that is the same as add() except \b path and \b name are concatenated (with a '/' added if necessary) to create the full path
  Node* add_leaf( const char* path, const char* name, Fl_Widget *w = 0, bool showLabel = true );

  //! Convenience function that is the same as add() except it removes any '/' at the end of \b fullpath
  inline Node* add_leaf( Node* n, const char* name, Fl_Widget *w = 0, bool showLabel = true )
    { return n->add_leaf( name, w, showLabel ); }

  //! Set whether all branches are always open. Default value is \c false
  inline void all_branches_always_open( bool b )
    { rdata.allBranchesAlwaysOpen = b; }

  //! Get whether all branches are always open. Default value is \c false
  inline bool all_branches_always_open()
    { return rdata.allBranchesAlwaysOpen; }

  //! Set whether multiple leaves with the same path are allowed. Default value is \c true
  inline void allow_leaf_duplication( bool b )
    { rdata.allowDuplication = b; }

  //! Get whether multiple leaves with the same path are allowed.
  inline bool allow_leaf_duplication()
    { return rdata.allowDuplication; }

  //! \return \c true if drag and drop support has been compiled in, \c false otherwise
  inline bool have_dnd()
    {
#ifdef USE_FLU_DND
      return true;
#else
      return false;
#endif
    }

  //! Set whether drag and drop processing is enabled for the browser. Default is \c false
  /*! If DND is enabled, either text or instances of Flu_Tree_Browser::DND_Object from outside the tree can be dragged and dropped
    onto the tree to create a new node. Nodes within the tree can be dragged and dropped (only within the same tree) according to
    the value of selection_drag_mode(). */
  inline void allow_dnd( bool b )
    { rdata.dnd = b; }

  //! Get whether drag and drop processing is enabled for the browser.
  inline bool allow_dnd()
    { return rdata.dnd; }

  //! Set whether the root node is always open. Shortcut for \c get_root()->always_open(b). Default is \c false
  inline void always_open( bool b )
    { root.always_open( b ); }

  //! Get whether the root node is always open
  inline bool always_open()
    { return root.always_open(); }

  //! Set whether animations of opening/closing branches are enabled. Default is \c false
  inline void animate( bool b )
    { rdata.animate = b; }

  //! Get whether animations of opening/closing branches are enabled
  inline bool animate()
    { return rdata.animate; }

  //! Set whether the tree automatically determines whether a node is a branch or a leaf based on whether it has any children. Default is \c false
  void auto_branches( bool b );

  //! Get whether the tree automatically determines whether a node is a branch or a leaf based on whether it has any children
  inline bool auto_branches() const
    { return rdata.autoBranches; }

  //! Get the default branch text color 
  inline Fl_Color branch_color() const
    { return rdata.defBranchColor; }

  //! Get the default branch text font 
  inline Fl_Font branch_font() const
    { return rdata.defBranchFont; }

  //! Get the default branch text size 
  inline int branch_size() const
    { return rdata.defBranchSize; }

  //! Set the default color, font and size to use for the text of all subsequent branches added to the tree
  inline void branch_text( Fl_Color color, Fl_Font font, int size )
    { rdata.defBranchColor = color; rdata.defBranchFont = font; rdata.defBranchSize = size; }

  //! Set the default branch icons to use for all subsequent branches added to the tree
  /*! Passing in \c NULL for either icon will disable that icon for the branch */
  void branch_icons( Fl_Image *closed, Fl_Image *open );

  //! Get the type of box to draw the browser in
  inline Fl_Boxtype box() const
    { return _box->box(); }

  //! Set the type of box to draw the browser in. Default is FL_FLAT_BOX
  inline void box( Fl_Boxtype b )
    { _box->box( b ); }

  //! Override of Fl_Widget::callback
  //inline void callback( Fl_Callback *c, void *user_data = 0 )
  //{ rdata.cb = c; rdata.cbd = user_data; }

  //! Get the reason why the last callback happened. This can be one of FLU_UNHILIGHTED, FLU_HILIGHTED, FLU_SELECTED, FLU_UNSELECTED, FLU_OPENED, FLU_CLOSED, FLU_DOUBLE_CLICK, FLU_WIDGET_CALLBACK, FLU_MOVED_CALLBACK, FLU_NEW_NODE_CALLBACK
  inline int callback_reason() const
    { return rdata.cbReason; }

  //! Get the node on which the last callback happened.
  /*! \note this node is only guaranteed to be in the tree \b during the callback. If the callback adds/removes nodes, then this node may have changed */
  inline Node* callback_node() const
    { return rdata.cbNode; }

  //! Clear all entries from the tree
  void clear();

  //! Set the default collapse icons to use for all subsequent branches added to the tree
  void collapse_icons( Fl_Image *closed, Fl_Image *open );

  //! Get the amount of time to take when animating an open/close. Use in conjunction with frame_rate()
  inline float collapse_time() const
    { return rdata.collapseTime; }

  //! Set the amount of time to take when animating an open/close. Use in conjunction with frame_rate(). Default is 0.1 seconds
  inline void collapse_time( float t )
    { rdata.collapseTime = t; }

  //! Get the background color of the browser
  inline Fl_Color color() const
    { return _box->color(); }

  //! Set the background color of the browser. Default is FL_WHITE
  inline void color( Fl_Color c )
    { _box->color( c ); }

  //! Set the color, style, and width of the connector lines. Default is FL_DARK2, FL_DOT, 1
  inline void connector_style( Fl_Color color, int style, int width = 1 )
    { rdata.defLineColor = color; rdata.lineStyle = style; rdata.lineWidth = width; }

  //! Get the color of the connector lines
  inline Fl_Color connector_color() const
    { return rdata.defLineColor; }

  //! Get the style of the connector lines
  inline int connector_style() const
    { return rdata.lineStyle; }

  //! Get the width of the connector lines
  inline int connector_width() const
    { return rdata.lineWidth; }

  //! Set whether double-clicking a branch opens/closes it
  inline void double_click_opens( bool b )
    { rdata.doubleClickToOpen = b; }

  //! Get whether double-clicking a branch opens/closes it
  inline bool double_click_opens()
    { return rdata.doubleClickToOpen; }

  //! Get the color to use for shading even entries
  inline Fl_Color even_shaded_entry_color() const 
    { return rdata.shadedColors[0]; }

  //! Find the entry identified by \b fullpath
  /*! \return a pointer to the Node of the found entry, or NULL if no matching entry was found */
  inline Node* find( const char *fullpath )
    { return find_next( fullpath ); }

  //! Find entry \b name in path \b path
  /*! \return a pointer to the Node of the found entry, or NULL if no matching entry was found */
  Node* find( const char *path, const char *name );

  //! Find the entry identified by unique id \b id
  /*! \return a pointer to the Node of the found entry, or NULL if no matching entry was found */
  Node* find( unsigned int id );

  //! Search for Node \b n in the tree
  /*! \return a pointer to \b n if it is found, or NULL if it is not in the tree */
  inline Node* find( Node *n )
    { if( !n ) return NULL; else return find( n->id() ); }

  //! Find the entry containing the widget \b w
  /*! \return a pointer to the Node of the found entry, or NULL if no matching entry was found */
  Node* find( Fl_Widget *w );

  //! Find the next entry identified by \b fullpath after \b startNode
  /*! \return a pointer to the Node of the found entry, or NULL if no matching entry was found */
  Node* find_next( const char *fullpath, Node* startNode = NULL );

  //! Find the next entry \b name in path \b path after \b startNode
  /*! \return a pointer to the Node of the found entry, or NULL if no matching entry was found */
  Node* find_next( const char *path, const char *name );

  //! \return the number of discovered nodes matching path \b fullpath
  int find_number( const char *fullpath );

  //! \return the number of discovered nodes with name \b name in path \b path
  int find_number( const char *path, const char *name );

  //! \return the full path of the entry identified by unique id \b id, or the empty string if no matching entry was found
  /*! \note the returned value is only valid until the next time find_path() is called */
  const char* find_path( unsigned int id );

  //! \return the full path of the entry containing the widget \b w, or the empty string if no matching entry was found
  /*! \note the returned value is only valid until the next time find_path() is called */
  const char* find_path( Fl_Widget *w );

  //! \return the full path of Node \b n, or the empty string if \b n is not in the tree
  /*! \note the returned value is only valid until the next time find_path() is called */
  inline const char* find_path( Node *n )
    { if( !n ) return ""; else return find_path( n->id() ); }

  //! \return the first node in the tree (i.e. the root)
  inline Node* first() { return root.first(); }

  //! \return the first branch encountered in a depth-first traversal of the tree. NULL means there are no branches
  inline Node* first_branch() { return root.first_branch(); }

  //! \return the first leaf encountered in a depth-first traversal of the tree. NULL means there are no leaves
  inline Node* first_leaf() { return root.first_leaf(); }

  //! Get the frame rate to use during the open/close animation. Use in conjunction with collapse_time()
  inline float frame_rate() const
    { return rdata.fps; }

  //! Set the frame rate to use during the open/close animation. Use in conjunction with collapse_time(). Default is 100 frames per second
  inline void frame_rate( float f )
    { if( f <= 0.0f ) rdata.fps = 0.001f; else rdata.fps = f; }

  //! \return the currently highlighted node
  inline Node* get_hilighted()
    { return rdata.hilighted; }

  //! \return a pointer to the root node of the tree
  inline Node *get_root() { return &root; }

  //! \return the selected Node that is at \b index among all selected nodes, or \c NULL if no Node is selected
  /*! For example, \c get_selected(1) will return the first selected node. */
  Node* get_selected( int index );

  //! Override of Fl_Widget::handle
  int handle( int event );

  //! Set the horizontal icon gap for each entry. Default is 2
  inline void horizontal_gap( int g )
    { rdata.hGap = g; rdata.forceResize = true; }

  //! Get the horizontal icon gap for each entry
  inline int horizontal_gap() const
    { return rdata.hGap; }

  //! Set how entries are inserted into the tree. This can be one of FLU_INSERT_FRONT, FLU_INSERT_BACK, FLU_INSERT_SORTED, FLU_INSERT_SORTED_REVERSE. Default is FLU_INSERT_SORTED
  void insertion_mode( int m );

  //! Get how entries are inserted into the tree.
  inline int insertion_mode()
    { return rdata.insertionMode; }

  //! \return whether the point \c (x,y) is inside the entry area (not on the scrollbars)
  bool inside_entry_area( int x, int y );
//  bool Flu_Tree_Browser :: inside_entry_area( int x, int y );
//  Mark sibly was here! gcc something > 3.3 doesn't like the extra Flu_Tree_Browser:: bit (understandable!)

  //! Set the title of the Tree (also the label for the root entry)
  inline void label( const char *l )
    { root.text = l; }

  //! Get the title of the Tree (also the label for the root entry)
  inline const char* label() const
    { return root.text.c_str(); }

  //! \return the last node in the tree
  inline Node* last() { return root.last(); }

  //! \return the last branch encountered in a depth-first traversal of the tree. NULL means there are no branches
  inline Node* last_branch() { return root.last_branch(); }

  //! \return the last leaf encountered in a depth-first traversal of the tree. NULL means there are no leaves
  inline Node* last_leaf() { return root.last_leaf(); }

  //! Get the default leaf text color 
  inline Fl_Color leaf_color() const
    { return rdata.defLeafColor; }

  //! Get the default leaf text font 
  inline Fl_Font leaf_font() const
    { return rdata.defLeafFont; }

  //! Get the default leaf text size 
  inline int leaf_size() const
    { return rdata.defLeafSize; }

  //! Set the default leaf icon to use for all subsequent leaves added to the tree
  void leaf_icon( Fl_Image *icon );

  //! Set the default color, font and size to use for the text of all subsequent leaves added to the tree, Default is FL_BLACK, FL_HELVETICA, 12
  inline void leaf_text( Fl_Color color, Fl_Font font, int size )
    { rdata.defLeafColor = color; rdata.defLeafFont = font; rdata.defLeafSize = size; }

  //! Set whether items can be moved only within their group ( \c true ) or can be moved anywhere in the tree ( \c false ). Default is \c false. Used only when selection_drag_mode() is FLU_DRAG_TO_MOVE.
  inline void move_only_same_group( bool b )
    { rdata.moveOnlySameGroup = b; }

  //! Get whether items can be moved only within their group ( \c true ) or can be moved anywhere in the tree ( \c false ). Used only when selection_drag_mode() is FLU_DRAG_TO_MOVE.
  inline bool move_only_same_group()
    { return rdata.moveOnlySameGroup; }

  //! \return the number of selected entries
  int num_selected();

  //! Get the color to use for shading odd entries
  inline Fl_Color odd_shaded_entry_color() const 
    { return rdata.shadedColors[1]; }

  //! Set whether only a single branch (except the root branch) is allowed open at a time. Default is \c false
  inline void only_one_open_branch( bool b )
    { rdata.singleBranchOpen = b; }

  //! Get whether only a single branch (except the root branch) is allowed open at a time
  inline bool only_one_open_branch()
    { return rdata.singleBranchOpen; }

  //! Open or close the root node
  inline void open( bool b )
    { root.open( b ); }

  //! Is the root node open or closed?
  inline bool open() const
    { return root.open(); }

  //! Set whether you can open/close a branch even if it has no children. Default is \c false
  inline void open_without_children( bool b )
    { rdata.openWOChildren = b; }

  //! Get whether you can open/close a branch even if it has no children.
  inline bool open_without_children() const
    { return rdata.openWOChildren; }

  //! Set whether selecting a branch also opens it. Default is \c false
  inline void open_on_select( bool b )
    { rdata.openOnSelect = b; }

  //! Get whether selecting a branch also opens it
  inline bool open_on_select() const
    { return rdata.openOnSelect; }

  //! Print the tree to stdout
  void print();

  //! Remove the entry identified by path \b fullpath from the tree
  /*! \return the unique id of the removed entry, or \c 0 if no matching entry was found */
  unsigned int remove( const char *fullpath );

  //! Remove entry \b name in path \b path from the tree
  /*! \return the unique id of the removed entry, or \c 0 if no matching entry was found */
  unsigned int remove( const char *path, const char *name );

  //! Remove the entry identified by unique id \b id from the tree
  /*! \return the unique id of the removed entry, or \c 0 if no matching entry was found */
  unsigned int remove( unsigned int id );

  //! Remove the entry containing the widget \b w from the tree. Note that the widget is automatically destroyed
  /*! \return the unique id of the removed entry, or \c 0 if no matching entry was found */
  unsigned int remove( Fl_Widget *w );

  //! Remove Node \b n from the tree
  /*! \return the id of \b n on successful removal, or \c 0 if \b n is not in the tree */
  inline unsigned int remove( Node* n )
    { if( !n ) return 0; else return remove( n->id() ); }

  //! Override of Fl_Widget::resize
  void resize( int X, int Y, int W, int H );

  //! Convenience routine to set the root label color. See Flu_Tree_Browser::Node::label_color()
  inline void root_color( Fl_Color c )
    { get_root()->label_color( c ); }

  //! Convenience routine to set the root label color. See Flu_Tree_Browser::Node::label_color()
  inline Fl_Color root_color()
    { return get_root()->label_color(); }

  //! Convenience routine to set the root label font. See Flu_Tree_Browser::Node::label_font()
  inline void root_font( Fl_Font f )
    { get_root()->label_font( f ); }

  //! Convenience routine to set the root label font. See Flu_Tree_Browser::Node::label_font()
  inline Fl_Font root_font()
    { return get_root()->label_font(); }

  //! Convenience routine to set the root label size. See Flu_Tree_Browser::Node::label_size()
  inline void root_size( unsigned char s )
    { get_root()->label_size( s ); }

  //! Convenience routine to set the root label size. See Flu_Tree_Browser::Node::label_size()
  inline unsigned char root_size()
    { return get_root()->label_size(); }

  //! Select all entries in the tree
  inline void select_all()
    { root.select_all(); }

  //! Get the color to use when hilighting selected entries
  inline Fl_Color selection_color() const
    { return rdata.defSelectionColor; }

  //! Set the color to use when hilighting selected entries. Default is FL_SELECTION_COLOR
  inline void selection_color( Fl_Color c )
    { rdata.defSelectionColor = c; }

  //! Set how selection is affected when the mouse is dragged. This can be one of FLU_DRAG_IGNORE, FLU_DRAG_TO_SELECT, FLU_DRAG_TO_MOVE. Default is FLU_DRAG_TO_SELECT.
  inline void selection_drag_mode( int m )
    { rdata.selectionDragMode = m; }

  //! Get how selection is affected when the mouse is dragged
  inline int selection_drag_mode() const
    { return rdata.selectionDragMode; }

  //! Set whether the hilighted node is always selected. Default is \c false
  inline void selection_follows_hilight( bool b )
    { rdata.selectionFollowsHilight = b; if( b && rdata.hilighted ) rdata.hilighted->select(true); }

  //! Get whether the hilighted node is always selected
  inline bool selection_follows_hilight()
    { return rdata.selectionFollowsHilight; }

  //! Set how individual entries are selected using the mouse. This can be one of FLU_NO_SELECT, FLU_SINGLE_SELECT, FLU_MULTI_SELECT. Default is FLU_MULTI_SELECT
  inline void selection_mode( int m )
    { rdata.selectionMode = m; root.unselect_all(); }

  //! Get how individual entries are selected using the mouse
  inline int selection_mode() const
    { return rdata.selectionMode; }

  //! If selection_mode() is \c FLU_SINGLE_SELECT, then whichever node is under the mouse will always be selected, with all others unselected. Default is \c false
  inline void select_under_mouse( bool b )
    { rdata.selectUnderMouse = b; }

  //! If selection_mode() is \c FLU_SINGLE_SELECT, then whichever node is under the mouse will always be selected, with all others unselected. Default is \c false
  inline bool select_under_mouse() const
    { return rdata.selectUnderMouse; }

  //! Calling this will cause any newly added branches to use the default branch icon
  void set_default_branch_icons();

  //! Set which node is hilighted and ready to be selected or unselected. This also scrolls the browser so \b n is visible.
  void set_hilighted( Node* n );

  //! Set the title of the root of the tree to \b label. If \b w is not \c NULL then that widget is the entry and its label is visible depending on the value of \b showLabel. Note that the widget is destroyed by the tree/node on clear() or the destructor
  /*! The root icons, color, font and size are set to the current branch icons and text color, font and size */
  Node* set_root( const char *label, Fl_Widget *w = 0, bool showLabel = true );

  //! Set the colors to use for shading every other entry. Default is FL_WHITE, FL_WHITE
  inline void shaded_entry_colors( Fl_Color even, Fl_Color odd )
    { rdata.shadedColors[0] = even; rdata.shadedColors[1] = odd; }

  //! Set whether branch entries are visible. Default is \c true
  inline void show_branches( bool b )
    { rdata.showBranches = b; rdata.forceResize = true; }

  //! Get whether branch entries are visible
  inline bool show_branches() const
    { return rdata.showBranches; }

  //! Set whether the connectors between entries are visible. Default is \c true
  inline void show_connectors( bool b )
    { rdata.showConnectors = b; }

  //! Get whether the connectors between entries are visible
  inline bool show_connectors() const
    { return rdata.showConnectors; }

  //! Set whether the root branch (i.e. the name of the tree) is visible. Default is \c true
  inline void show_root( bool b )
    { rdata.showRoot = b; rdata.forceResize = true; }

  //! Get whether the root branch (i.e. the name of the tree) is visible
  inline bool show_root() const
    { return rdata.showRoot; }

  //! Set whether leaf entries are visible. Default is \c true
  inline void show_leaves( bool b )
    { rdata.showLeaves = b; rdata.forceResize = true; }

  //! Get whether leaf entries are visible
  inline bool show_leaves() const
    { return rdata.showLeaves; }

  //! Sort the tree according to insertion_mode()
  inline void sort()
    { root.sort(); }

  //! Unselect all entries in the tree
  inline void unselect_all()
    { root.unselect_all(); }

  inline static void use_FLU_WIDGET_CALLBACK( bool b )
    { USE_FLU_WIDGET_CALLBACK = b; }

  //! Set the vertical gap between tree entries. Default is 0
  inline void vertical_gap( int g )
    { rdata.vGap = g; rdata.forceResize = true; }

  //! Get the vertical gap between tree entries
  inline int vertical_gap() const
    { return rdata.vGap; }

  //! Override of Fl_Widget::when. Currently only FL_WHEN_NEVER, FL_WHEN_CHANGED, and FL_WHEN_NOT_CHANGED are supported. Default value is FL_WHEN_CHANGED
  /*! When the callback occurs, you can use callback_reason() to determine exactly what cause the callback and callback_node()
    to get the node that was affected. */
  //inline void when( unsigned int w )
  //{ rdata.when = w; }

  //! Override of Fl_Widget::when
  //inline unsigned int when() const
  //{ return rdata.when; }

  //! Set the gap between the widget and the icon that precedes it. Default is 2
  inline void widget_gap( int g )
    { rdata.wGap = g; rdata.forceResize = true; }

  //! Get the gap between the widget and the icon that precedes it 
  inline int widget_gap() const
    { return rdata.wGap; }

 protected:

  class RData;

  //! Internal class holding an (alphabetically) ordered list of nodes
  class FLU_EXPORT NodeList
    {
    public:
      NodeList();
      ~NodeList();
      void add( Node* n, int position = -1 );
      inline Node* child( int n ) const { return _nodes[n]; }
      int erase( Node* n );
      int erase( const char* n );
      void erase( int n );
      void clear();
      int findNum( const char *n );  // find the number of nodes in the list with name n
      Node* find( const char* n, int which = 1 );  // find the which'th node in the list with name n
      inline int size() const { return _nNodes; };
      void sort();
      static bool move( Node* n1, int where, Node* n2 );
    private:
      friend class Node;
      static int compareNodes( const void *arg1, const void* arg2 );
      static int reverseCompareNodes( const void *arg1, const void* arg2 );
      bool search( Node *n, int &index );
      bool search( const char *n, int &index );
      bool linSearch( Node *n, int &index );
      bool linSearch( const char *n, int &index );
      bool binSearch( Node *n, int &index );
      bool binSearch( const char *n, int &index );
      Node **_nodes;
      int _nNodes, _size;
    };

  //! Internal class holding a stack of integers
  class FLU_EXPORT IntStack
    {
    public:
      IntStack();
      IntStack( const IntStack& s );
      ~IntStack();
      void push( int i );
      int pop();
      void clear();
      inline int operator [](int i) { return _list[i]; }
      inline int size() { return _size; }
      IntStack& operator =( const IntStack& s );
    private:
      int *_list;
      int _size, _bufferSize;
    };

  public:
  enum { MOVE_BEFORE, MOVE_INSIDE, MOVE_AFTER }; // where to move a dragged node?
 protected:

  //! Recursive data structure passed down through the node tree
  class FLU_EXPORT RData {
  public:
    // volatile objects (from the perspective of each node during a recursive descent)
    int x, y, totalW, totalH;
    bool first, last, dragging, shiftSelect, shiftSelectAll, visibilityChanged, selectionFollowsHilight;
    Node *hilighted, /**lastHilighted, */ *previous, *grabbed, *dragNode, *animatedNode;
    int delta, shadedIndex, counter, searchIndex, branchIconW, dragPos, dragWhere;
    Fl_Color lineColor, bgColor, selectionColor;
    bool forceResize;  // force the browser to resize on the next draw (which forces a recalculation of the tree layout)
    unsigned int nextId;  // monotonically increasing id of each entry
    FluSimpleString path;  // used to construct the full path during a findPath() operation
    IntStack branchConnectors;

    // static objects (from the perspective of each node during a recursive descent)
    int insertionMode;
    Fl_Image *defaultCollapseIcons[2], *defaultBranchIcons[2];
    Fl_Image *collapseIcons[2], *branchIcons[2], *leafIcon;
    int hGap, vGap, wGap;
    int lineStyle, lineWidth, selectionMode, selectionDragMode;
    bool showRoot, showConnectors, showLeaves, showBranches, openOnSelect,
      allowDuplication, animate, animating, singleBranchOpen, moveOnlySameGroup, justOpenedClosed,
      isMoveValid, doubleClickToOpen, dnd, allBranchesAlwaysOpen, autoBranches, openWOChildren,
      selectUnderMouse;
    float collapseTime, fps, animationDelta, animationOffset;
    Fl_Color defLineColor, defSelectionColor, shadedColors[2];
    Fl_Color defLeafColor, defBranchColor;
    Fl_Font defLeafFont, defBranchFont;
    int defLeafSize, defBranchSize;
    int browserX, browserY, browserW, browserH;
    Node *root;
    Flu_Tree_Browser *tree;
    unsigned int cbReason;
    Node *cbNode, *lastOpenBranch;
  };

 public:

#ifdef USE_FLU_DND
  //! This class can be subclassed to make an object which can be dropped on a tree to make a new node
  /*! When the object is dropped, the tree will name the object according to what the function
    \b name() returns */
  class FLU_EXPORT DND_Object : public Flu_DND
    {
    public:

      //! Default constructor
      DND_Object();

      //! The descendent should call this when the user grabs the object to start dragging it (e.g. on the FL_PUSH event)
      inline void grab()
	{ dnd_grab( this, "DND_Object" ); }

      //! Descendents MUST implement this function to return the name of the dropped object
      virtual const char* name() = 0;

    };
#endif

  //! This class holds a single entry in the tree
  class FLU_EXPORT Node
    {

    protected:

      enum { ADD, REMOVE, FIND, FIND_NUMBER, GET_SELECTED };  // parameters for modify()
      enum { DRAW, MEASURE, MEASURE_THIS_OPEN, HANDLE, COUNT_SELECTED };  // parameters for recurse()

      // flags
      enum { SELECTED = 0x0001, COLLAPSED = 0x0002, LEAF = 0x0004, SHOW_LABEL = 0x0008,
	     ACTIVE = 0x0010, EXPAND_TO_WIDTH = 0x0020, ALWAYS_OPEN = 0x0040,
	     SOME_VISIBLE_CHILDREN = 0x0080, MOVABLE = 0x0100, DROPPABLE = 0x0200,
	     AUTO_LABEL_COLOR = 0x0400, AUTO_COLOR = 0x0800, AUTO_LABEL = 0x1000, 
	     SWAP_LABEL_AND_WIDGET = 0x2000, ICON_AT_END = 0x4000 };

      // flag manipulator functions
      inline bool CHECK( unsigned short flag ) const { return flags & flag; }
      inline void SET( unsigned short flag ) { flags |= flag; }
      inline void SET( unsigned short flag, bool b ) { if(b) SET(flag); else CLEAR(flag); }
      inline void CLEAR( unsigned short flag ) { flags &= ~flag; }

    public:

      //! Is this node currently active?
      inline bool active() const
	{ return CHECK(ACTIVE); }

      //! Activate or deactivate this node
      void active( bool b );

      //! Activate this node
      inline void activate()
	{ active(true); }

      //! Add the entry specified by \b fullpath to this node. If \b w is not \c NULL then that widget is the entry and the label (as specified in \b fullPath) is visible depending on the value of \b showLabel. Note that the widget is destroyed by the tree/node on clear() or the destructor
      /*! \return a pointer to the Node of the added entry or NULL if the add failed */
      inline Node* add( const char* fullpath, Fl_Widget *w = 0, bool showLabel = true )
	{ return( modify( fullpath, ADD, tree->rdata, w, showLabel ) ); }

      //! Convenience function that is the same as add() except it appends a '/' to \b fullpath if one does not exist
      Node* add_branch( const char* fullpath, Fl_Widget *w = 0, bool showLabel = true );

      //! Convenience function that is the same as add() except it removes any '/' at the end of \b fullpath
      Node* add_leaf( const char* fullpath, Fl_Widget *w = 0, bool showLabel = true );

      //! Convenience function that is the same as add() except \b path and \b name are concatenated (with a '/' added if necessary) to create the full path
      Node* add( const char* path, const char* name, Fl_Widget *w = 0, bool showLabel = true );

      //! Convenience function that is the same as add_branch() except \b path and \b name are concatenated (with a '/' added if necessary) to create the full path
      Node* add_branch( const char* path, const char* name, Fl_Widget *w = 0, bool showLabel = true );

      //! Convenience function that is the same as add_leaf() except \b path and \b name are concatenated (with a '/' added if necessary) to create the full path
      Node* add_leaf( const char* path, const char* name, Fl_Widget *w = 0, bool showLabel = true );

      //! Set whether a branch node is always open (only for branch nodes). Default is \c false
      inline void always_open( bool b )
	{ if( b ) open(true); SET(ALWAYS_OPEN,b); tree->rdata.forceResize = true; }

      //! Get whether this branch node is always open (only for branches)
      inline bool always_open() const
	{ return CHECK(ALWAYS_OPEN); }

      //! Set whether the color of the widget in this node tracks the color of the node itself. This is useful for changing the color of the widget when the node is selected. Default is \c false
      inline void auto_color( bool b )
	{ SET(AUTO_COLOR,b); }

      //! Get whether the color of the widget in this node tracks the color of the node itself
      inline bool auto_color()
	{ return CHECK(AUTO_COLOR); }

      //! Set whether the label of the widget in this node tracks the label of the node itself. This is useful for when the label of the node changes and you want the widget to reflect the change
      inline void auto_label( bool b )
	{ SET(AUTO_LABEL,b); }

      //! Set whether the label of the widget in this node tracks the label of the node itself.
      inline bool auto_label()
	{ return CHECK(AUTO_LABEL); }

      //! Set whether the label color of the widget in this node tracks the label color of the node itself. This is useful for changing the label color of the widget when the node is selected. Default is \c false
      inline void auto_label_color( bool b )
	{ SET(AUTO_LABEL_COLOR,b); }

      //! Get whether the label color of the widget in this node tracks the label color of the node itself
      inline bool auto_label_color()
	{ return CHECK(AUTO_LABEL_COLOR); }

      //! Set the branch icons to use for this node (only for branch nodes)
      void branch_icons( Fl_Image *closed, Fl_Image *open );

      //! Convenience routine to set both branch icons at once
      inline void branch_icon( Fl_Image *icon )
	{ branch_icons( icon, icon ); }

      //! \return child \b i of this node (base 0). Bounds checking is performed and NULL is returned if the child cannot be found
      Node* child( int i ) const;

      //! \return the number of child nodes beneath this node
      inline int children() const
	{ return _children.size(); }

      //! Clear all child entries from this node (does not change the entry of this node)
      void clear();

      //! Close this node (only for branches)
      inline void close()
	{ open( false ); }

      //! Is this node closed? (only for branches)
      inline bool closed()
	{ return !open(); }

       //! Set the collapse icons to use for this node (only for branch nodes)
      /*! \note if a NULL icon is passed, the default plus/minus icons are chosen */
      void collapse_icons( Fl_Image *closed, Fl_Image *open );

      //! Deactivate this node
      inline void deactivate()
	{ active(false); }

      //! Get the depth of this node in the tree
      unsigned short depth() const;

      //! Do the tree browser callback. \b reason should be one of FLU_HILIGHTED, FLU_UNHILIGHTED, FLU_SELECTED, FLU_UNSELECTED, FLU_OPENED, FLU_CLOSED, FLU_DOUBLE_CLICK, FLU_WIDGET_CALLBACK
      void do_callback( int reason );

      //! Set whether this node can receive new nodes as a result of dragging-and-dropping (only for branch nodes). Default is \c true
      inline void droppable( bool b )
	{ SET(DROPPABLE,b); }

      //! Get whether this node can receive new nodes as a result of dragging-and-dropping (only for branch nodes).
      inline bool droppable()
	{ return CHECK(DROPPABLE); }

      //! Set whether to force the size of the embedded widget to expand to fill the visible width of the browser. Default is \c false
      inline void expand_to_width( bool b )
	{ SET(EXPAND_TO_WIDTH,b); tree->rdata.forceResize = true; }

      //! Get whether to force the size of the embedded widget to expand to fill the visible width of the browser
      inline bool expand_to_width() const
	{ return CHECK(EXPAND_TO_WIDTH); }

      //! Find the entry identified by \b fullpath
      /*! \return a pointer to the Node of the found entry, or NULL if no matching entry was found */
      inline Node* find( const char *fullpath )
	{ return( modify( fullpath, FIND, tree->rdata ) ); }

      //! Find the entry identified by unique id \b id
      /*! \return a pointer to the Node of the found entry, or NULL if no matching entry was found */
      Node* find( unsigned int id );

      //! Find the entry containing the widget \b w
      /*! \return a pointer to the Node of the found entry, or NULL if no matching entry was found */
      Node* find( Fl_Widget *w );

      //! Search for Node \b n
      /*! \return a pointer to \b n if it is found, or NULL if it is not present */
      inline Node* find( Node *n )
	{ if( !n ) return NULL; else return find( n->id() ); }

      //! \return the full path of this node
      /*! \note the returned value is only valid until the next time find_path() is called */
      inline const char* find_path()
	{ return tree->find_path( this ); }

      //! \return the first node in this hierarchy (i.e. this node)
      Node* first();

      //! \return the first branch encountered in a depth-first traversal (or this node if it is a branch). NULL means there are no branches
      Node* first_branch();

      //! \return the first leaf encountered in a depth-first traversal (or this node if it is a leaf). NULL means there are no leaves
      Node* first_leaf();

      //! Set whether this node draws the label to the left of the widget (\c false, default) or to the right of the widget (\c true)
      inline void swap_label_and_widget( bool b )
	{ SET(SWAP_LABEL_AND_WIDGET,b); }

      //! Get whether this node draws the label to the left of the widget (\c false, default) or to the right of the widget (\c true)
      inline bool swap_label_and_widget()
	{ return CHECK(SWAP_LABEL_AND_WIDGET); }      

      //! \return the selected Node that is at \b index among all selected nodes, or \c NULL if no Node is selected
      /*! For example, \c get_selected(1) will return the first selected node. */
      Node* get_selected( int index );

      //! Set whether the icon for this node is drawn after the label and widget (\c true) or before (\c false, default) (only for leaf nodes)
      inline void icon_at_end( bool b )
	{ SET(ICON_AT_END,b); }

      //! Get whether the icon for this node is drawn after the label and widget (\c true) or before (\c false, default) (only for leaf nodes)
      inline bool icon_at_end()
	{ return CHECK(ICON_AT_END); }

      //! Get the unique ID of this node
      inline unsigned int id() const
	{ return _id; }

      //! Get the index this node is (as a child) in its parent's list
      /*! \return -1 if this node has no parent, else its index in its parent's list of children */
      int index() const;

      //! Insert a new node at position \b pos
      Node* insert( const char* fullpath, int pos );

      //! Insert a new branch at position \b pos
      Node* insert_branch( const char* fullpath, int pos );

      //! Insert a new leaf at position \b pos
      Node* insert_leaf( const char* fullpath, int pos );

      //! Is node \b n an ancestor of this node?
      bool is_ancestor( Node* n );

      //! Is this node a branch node?
      bool is_branch() const;

      //! Is node \b n a descendent of this node?
      bool is_descendent( Node* n );

      //! Is this node a leaf node?
      bool is_leaf() const;

      //! Is this node the root node?
      inline bool is_root() const
	{ return( _parent == 0 ); }

      //! Set the label for this node. Note that setting the label may invalidate a sorted tree. Fix by calling Flu_Tree_Browser::sort() 
      inline void label( const char *l )
	{ text = l; tree->redraw(); }

      //! Get the label for this node
      inline const char* label() const
	{ return text.c_str(); }

      //! Set the label color for this node
      inline void label_color( Fl_Color c )
	{ textColor = c; }

      //! Get the label color for this node
      inline Fl_Color label_color() const
	{ return textColor; }

      //! Set the label font for this node
      inline void label_font( Fl_Font f )
	{ textFont = f; tree->rdata.forceResize = true; }

      //! Get the label font for this node
      inline Fl_Font label_font() const
	{ return textFont; }

      //! Set the label size for this node
      inline void label_size( unsigned char s )
	{ textSize = s; tree->rdata.forceResize = true; }

      //! Get the label size for this node
      inline unsigned char label_size() const
	{ return textSize; }

      //! Is the label for this node visible?
      inline bool label_visible() const
	{ return CHECK(SHOW_LABEL); }

      //! Set whether the label for this node is visible
      inline void label_visible( bool b )
	{ SET(SHOW_LABEL,b); tree->rdata.forceResize = true; }

      //! \return the last node in this hierarchy
      Node* last();

      //! \return the last branch encountered in a depth-first traversal (or this node if it is a branch and has no children). NULL means there are no branches
      Node* last_branch();

      //! \return the last leaf encountered in a depth-first traversal (or this node if it is a leaf). NULL means there are no leaves
      Node* last_leaf();

      //! Set the leaf icon to use for this node (only for leaf nodes)
      void leaf_icon( Fl_Image *icon );

      //! Set whether this node can be moved (either via move() or by dragging with the mouse). Default is \c true
      inline void movable( bool b )
	{ SET(MOVABLE,b); }

      //! Get whether this node can be moved (either via move() or by dragging with the mouse)
      inline bool movable()
	{ return CHECK(MOVABLE); }

      //! Move this node to absolute position \b pos within its parent
      /*! \return \c true if the move was successful, or \c false if the move is not allowed
       */
      bool move( int pos );

      //! Move this node to a position before, after, or inside node \b n
      /*! \param where can be one of MOVE_BEFORE, MOVE_AFTER, or MOVE_INSIDE
	\return \c true if the move was successful, or \c false if the move is not allowed
       */
      inline bool move( int where, Node* n )
	{ return( move( this, where, n ) ); }

      //! Move node \b n1 to a position before, after, or inside node \b n2
      /*! \param where can be one of MOVE_BEFORE, MOVE_AFTER, or MOVE_INSIDE
	\return \c true if the move was successful, or \c false if the move is not allowed
       */
      static bool move( Node* n1, int where, Node* n2 );

      //! \return the next node (after this node) in this hierarchy (depth-first traversal)
      Node* next();

      //! \return the next branch (after this node) encountered in a depth-first traversal. NULL means there are no more branches
      Node* next_branch();

      //! \return the next leaf (after this node) encountered in a depth-first traversal. NULL means there are no more leaves
      Node* next_leaf();

      //! \return the next sibling (after this node) encountered in a depth-first traversal. NULL means this node is the last child w.r.t. its parent
      Node* next_sibling();

      //! \return the number of selected entries
      int num_selected();

      //! Is this node currently open? (only for branch nodes)
      inline bool open() const
	{ return( !CHECK(COLLAPSED) || tree->rdata.allBranchesAlwaysOpen ); }

      //! Open or close this node (only for branch nodes)
      void open( bool b );

      //! Get the node that is the parent of this node, or NULL if there is no parent
      inline Node* parent() const
	{ return _parent; }

      //! \return the previous node (before this node) in this hierarchy (depth-first traversal)
      Node* previous();

      //! \return the previous branch (before this node) encountered in a depth-first traversal. NULL means there are no more branches
      Node* previous_branch();

      //! \return the previous leaf (before this node) encountered in a depth-first traversal. NULL means there are no more leaves
      Node* previous_leaf();

      //! \return the previous sibling (before this node) encountered in a depth-first traversal. NULL means this node is the first child w.r.t. its parent
      Node* previous_sibling();

      //! Print this node and its children to stdout
      void print( int spaces = 0 );

      //! Remove the entry identified by path \b fullpath from this node
      /*! \return the unique id of the removed entry, or \c 0 if no matching entry was found */
      inline unsigned int remove( const char *fullpath )
	{ return( (unsigned int)modify( fullpath, REMOVE, tree->rdata ) ); }

      //! Remove the entry identified by unique id \b id from this node
      /*! \return the unique id of the removed entry, or \c 0 if no matching entry was found */
      unsigned int remove( unsigned int id );

      //! Remove the node containing the widget \b w from this node. Note that the widget is automatically destroyed
      /*! \return the unique id of the removed entry, or \c 0 if no matching entry was found */
      unsigned int remove( Fl_Widget *w );

      //! Remove Node \b n
      /*! \return the id of \b n on successful removal, or \c 0 if \b n is present */
      inline unsigned int remove( Node* n )
	{ if( !n ) return 0; else return remove( n->id() ); }

      //! Select this entry and all child entries
      void select_all();

      //! Is this node currently selected?
      inline bool selected() const
	{ return CHECK(SELECTED); }

      //! Select or unselect this node
      void select( bool b );

      //! Select only this node
      inline void select_only()
	{ tree->unselect_all(); select(true); }

      //! Sort this node's children according to Flu_Tree_Browser::insertion_mode()
      inline void sort_children()
	{ sort(); }

      //! Swap this node and node \b n in their respective trees
      /*! \return \c true if the swap was successful, else \c false */
      inline bool swap( Node* n )
	{ return swap( this, n ); }

      //! Swap nodes \b n1 and \b n2 in their respective trees
      /*! \return \c true if the swap was successful, else \c false */
      static bool swap( Node* n1, Node* n2 );

      //! Unselect this entry and all child entries (except for Node \b except )
      void unselect_all( Node* except = NULL );

      //! Get the user-specific data stored in this node
      inline void* user_data()
	{ return userData; }

      //! Set the user-specific data stored in this node
      inline void user_data( void *d )
	{ userData = d; }

      //! Get the widget in this node, or NULL if there is no widget. Note that the widget is destroyed by the tree/node on clear() or the destructor
      inline Fl_Widget* widget() const
	{ return( _widget ? _widget->w : NULL ); }

      //! Set the widget in this node. Note that the widget is destroyed by the tree/node on clear() or the destructor
      void widget( Fl_Widget *w );

    protected:

      friend class Flu_Tree_Browser;
      friend class NodeList;

      // Root node constructor
      Node( const char *lbl = 0 );

      // Non-root constructor
      Node( bool l, const char* n, Node *p, RData &rdata, Fl_Widget *w, bool showLabel );

      ~Node();

      // add/remove/find/get
      Node* modify( const char* path, int what, RData &rdata, Fl_Widget *w = 0, bool showLabel = true );

      void initType();

      void sort();

      void determineVisibility( bool parentVisible = true );

      static bool isMoveValid( Node* &n1, int &where, Node* &n2 );

      // handle/draw/measure/count
      int recurse( RData &rdata, int type, int event = 0 );

      void draw( RData &rdata, bool measure );

      // recursively finding the full path of the node identified by id
      bool findPath( unsigned int id, RData &rdata );

      // recursively finding the full path of the node containing w
      bool findPath( Fl_Widget *w, RData &rdata );

      class FLU_EXPORT WidgetInfo
	{
	public:
	  Fl_Widget *w;
	  int defaultW;  // the initial width of the widget
	  void (*CB)(Fl_Widget*,void*);
	  void *CBData;
	};

      unsigned int _id; // the unique id of this node
      unsigned short flags;
      NodeList _children;
      Node *_parent;
      Flu_Tree_Browser *tree;
      FluSimpleString text;
      WidgetInfo *_widget;  // memory overhead deferred to WidgetInfo. present only if widget is
      Fl_Group *_group;
      void *userData;
      int totalChildH; // needed for animation
      Fl_Image *cIcon[2], *bIcon[2], *lIcon;
      Fl_Color textColor;
      Fl_Font textFont;
      unsigned char textSize;  // the font size of the entry label text
      unsigned short textW, textH;  // how big the entry label actually is (stored within the node for performance reasons)
      int currentY; // needed for animation
      unsigned short currentH;

      inline static void _widgetCB( Fl_Widget* w, void* arg )
	{ ((Node*)arg)->widgetCB(); }
      void widgetCB();
     };

 protected:

  inline static void _scrollCB( Fl_Widget* w, void* arg )
    { ((Flu_Tree_Browser*)arg)->redraw(); }

  inline static void _timerRedrawCB( void *arg )
    { ((Flu_Tree_Browser*)arg)->timerRedrawCB(); }
  void timerRedrawCB();

  inline static void _timerScrollCB( void *arg )
    { ((Flu_Tree_Browser*)arg)->timerScrollCB(); }
  void timerScrollCB();

  void on_dnd_leave();

  void on_dnd_release();

  bool on_dnd_drag( int X, int Y );

  void on_dnd_drop( const Flu_DND_Event *e );

  /* override of Fl_Double_Window::draw() */
  void draw();

  Fl_Group *scrollBox;
  Fl_Scrollbar *scrollH, *scrollV;
  Fl_Group *_box;
  Node root;
  RData rdata;
  //int lastEvent;
  float autoScrollX, autoScrollY;
  bool scrolledTimerOn;

};

#endif
