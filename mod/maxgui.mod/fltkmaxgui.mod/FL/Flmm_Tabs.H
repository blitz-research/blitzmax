//
// "$Id$"
//
// Flmm_Tabs header file for the FLMM extension to FLTK.
//
// Copyright 2002-2004 by Matthias Melcher.
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Library General Public
// License as published by the Free Software Foundation; either
// version 2 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Library General Public License for more details.
//
// You should have received a copy of the GNU Library General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
// USA.
//
// Please report all bugs and problems to "flmm@matthiasm.com".
//

#ifndef Flmm_Tabs_H
#define Flmm_Tabs_H

#include <FL/Fl_Tabs.H>

struct Fl_Menu_Item;

class FL_EXPORT Flmm_Tabs : public Fl_Tabs {
  int xoff;
  int leftmost, rightmost;
  int *tab_position_array, *tab_width_array, array_size;
  char overlapping;
  void allocate_arrays();
protected:
  char create_menu(Fl_Menu_Item *&menu, Fl_Menu_Item *&picked);
  void draw_tab(int x1, int x2, int W, int H, Fl_Widget* o, int sel=0);
  int tab_positions(int*, int*);
  int tab_height();
  int handle(int);
  void draw();
public:
  Flmm_Tabs(int x, int y, int w, int h, const char *l=0);
  ~Flmm_Tabs();
  Fl_Widget *which(int event_x, int event_y);
};

#endif

//
// End of "$Id: Fl_Tabs.H 4288 2005-04-16 00:13:17Z mike $".
//
