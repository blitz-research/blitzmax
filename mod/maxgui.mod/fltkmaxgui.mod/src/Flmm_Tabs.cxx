//
// "$Id:$"
//
// Flmm_Scalebar source file for the FLMM extension to FLTK.
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

/** \class Flmm_Tabs
 * Not yet documented.
 */

#include <FL/Fl.H>
#include <FL/Flmm_Tabs.H>
#include <FL/Fl_Menu_Item.H>
#include <FL/fl_draw.H>
#include <math.h>
#include <stdio.h>
#include <memory.h>


#define BORDER 2
#define EXTRASPACE 10

enum {LEFT, RIGHT, SELECTED};


Flmm_Tabs::Flmm_Tabs(int x, int y, int w, int h, const char *l) 
: Fl_Tabs(x, y, w, h, l)
{
  xoff = 0;
  overlapping = 0;
  tab_position_array = tab_width_array = 0;
  array_size = 0;
}

Flmm_Tabs::~Flmm_Tabs()
{
  delete[] tab_position_array;
  delete[] tab_width_array;
}

void Flmm_Tabs::allocate_arrays() {
  int nc = children()+2;
  if (nc<array_size) return;
  nc += 16;
  delete[] tab_position_array;
  delete[] tab_width_array;
  tab_position_array = new int[nc];
  tab_width_array = new int[nc];
  array_size = nc;
}

int Flmm_Tabs::handle(int event) {

  Fl_Widget *o;
  int i;

  switch (event) {

  case FL_PUSH: {
    int H = tab_height(), Habs = (H<0)?-H:H;
      if (H >= 0) {
        if (Fl::event_y() > y()+H) return Fl_Group::handle(event);
      } else {
        if (Fl::event_y() < y()+h()+H) return Fl_Group::handle(event);
      }
      if (Fl::event_x()>x()+w()-Habs) {
        int bx = x()+w()-Habs+2, by = y()+2, bw = Habs-4, bh = Habs-4;
        if (H<0) by = y()+h()-Habs+2;
        Fl_Menu_Item *menu, *picked;
        if (create_menu(menu, picked)) {
          const Fl_Menu_Item *sel = menu->pulldown(bx, by, bw, bh, picked);
          delete[] menu;
          if (sel) {
            Fl_Widget *w = child(sel - menu);
            if (value(w)) {
              set_changed();
              do_callback();
              if (Fl::visible_focus()) Fl::focus(this);
            }
          }
        }
        return 1;
      }
    }
  case FL_DRAG:
  case FL_RELEASE:
    o = which(Fl::event_x(), Fl::event_y());
    if (event == FL_RELEASE) {
      push(0);
      if (o && value(o)) {
        set_changed();
	do_callback();
      }
    } else push(o);
    if (Fl::visible_focus() && event == FL_RELEASE) Fl::focus(this);
    return 1;
  case FL_FOCUS:
  case FL_UNFOCUS:
    if (!Fl::visible_focus()) return Fl_Group::handle(event);
    if (Fl::event() == FL_RELEASE ||
	Fl::event() == FL_SHORTCUT ||
	Fl::event() == FL_KEYBOARD ||
	Fl::event() == FL_FOCUS ||
	Fl::event() == FL_UNFOCUS) {
      int H = tab_height();
      if (H >= 0) {
        H += Fl::box_dy(box());
	damage(FL_DAMAGE_SCROLL, x(), y(), w(), H);
      } else {
        H = Fl::box_dy(box()) - H;
        damage(FL_DAMAGE_SCROLL, x(), y() + h() - H, w(), H);
      }
      if (Fl::event() == FL_FOCUS || Fl::event() == FL_UNFOCUS) return 0;
      else return 1;
    } else return Fl_Group::handle(event);
  case FL_KEYBOARD:
    switch (Fl::event_key()) {
      case FL_Left:
        if (child(0)->visible()) return 0;
	for (i = 1; i < children(); i ++)
	  if (child(i)->visible()) break;
	value(child(i - 1));
	set_changed();
	do_callback();
        return 1;
      case FL_Right:
        if (child(children() - 1)->visible()) return 0;
	for (i = 0; i < children(); i ++)
	  if (child(i)->visible()) break;
	value(child(i + 1));
	set_changed();
	do_callback();
        return 1;
      case FL_Down:
        redraw();
        return Fl_Group::handle(FL_FOCUS);
      default:
        break;
    }
  case FL_SHOW:
    value(); // update visibilities and fall through
  default:
    return Fl_Group::handle(event);

  }
}

void Flmm_Tabs::draw() {
  Fl_Widget *v = value();
  int H = tab_height();

  if (damage() & FL_DAMAGE_ALL) { // redraw the entire thing:
    Fl_Color c = v ? v->color() : color();

    draw_box(box(), x(), y()+(H>=0?H:0), w(), h()-(H>=0?H:-H), c);

    if (selection_color() != c) {
      // Draw the top 5 lines of the tab pane in the selection color so
      // that the user knows which tab is selected...
      if (H >= 0) fl_push_clip(x(), y() + H, w(), 5);
      else fl_push_clip(x(), y() + h() - H - 4, w(), 5);

      draw_box(box(), x(), y()+(H>=0?H:0), w(), h()-(H>=0?H:-H),
               selection_color());

      fl_pop_clip();
    }
    if (v) draw_child(*v);
  } else { // redraw the child
    if (v) update_child(*v);
  }
  if (damage() & (FL_DAMAGE_SCROLL|FL_DAMAGE_ALL)) {
    int Habs = (H<0)?-H:H;
    fl_clip(x(), y(), w()-Habs, h());
    allocate_arrays();
    int *p = tab_position_array; int *wp = tab_width_array;
    int selected = tab_positions(p,wp);
    int i;
    Fl_Widget*const* a = array();
    for (i=0; i<selected; i++)
      draw_tab(x()+p[i], x()+p[i+1], wp[i], H, a[i], LEFT);
    for (i=children()-1; i > selected; i--)
      draw_tab(x()+p[i], x()+p[i+1], wp[i], H, a[i], RIGHT);
    if (v) {
      i = selected;
      draw_tab(x()+p[i], x()+p[i+1], wp[i], H, a[i], SELECTED);
    }
    fl_pop_clip();
    if (overlapping) { // pulldown menu box
      int bx = x()+w()-Habs+2, by = y()+2, bw = Habs-4, bh = Habs-4;
      if (H<0) by = y()+h()-Habs+2;
      draw_box(box(), bx, by, bw, bh, color());
      bh = bh / 2;
      bx = bx + bh/2;
      by = by + bh/2;
      fl_color(active_r() ? FL_DARK3 : fl_inactive(FL_DARK3));
      fl_line(bx+bh/2, by+bh, bx, by, bx+bh, by);
      fl_color(active_r() ? FL_LIGHT3 : fl_inactive(FL_LIGHT3));
      fl_line(bx+bh, by, bx+bh/2, by+bh);
    }
  }
}

/* Duplicate of Fl_Tabs since the original ist private. */
void Flmm_Tabs::draw_tab(int x1, int x2, int W, int H, Fl_Widget* o, int what) {
  x1 -= xoff; x2 -= xoff;
  int sel = (what == SELECTED);
  int dh = Fl::box_dh(box());
  int dy = Fl::box_dy(box());

  // compute offsets to make selected tab look bigger
  int yofs = sel ? 0 : BORDER;

  if ((x2 < x1+W) && what == RIGHT) x1 = x2 - W;

  if (H >= 0) {
    if (sel) fl_clip(x1, y(), x2 - x1, H + dh - dy);
    else fl_clip(x1, y(), x2 - x1, H);

    H += dh;

    Fl_Color c = sel ? selection_color() : o->selection_color();

    draw_box(box(), x1, y() + yofs, W, H + 10 - yofs, c);

    // Save the previous label color
    Fl_Color oc = o->labelcolor();

    // Draw the label using the current color...
    o->labelcolor(sel ? labelcolor() : o->labelcolor());    
    o->draw_label(x1, y() + yofs, W, H - yofs, FL_ALIGN_CENTER);

    // Restore the original label color...
    o->labelcolor(oc);

    if (Fl::focus() == this && o->visible())
      draw_focus(box(), x1, y(), W, H);

    fl_pop_clip();
  } else {
    H = -H;

    if (sel) fl_clip(x1, y() + h() - H - dy, x2 - x1, H + dy);
    else fl_clip(x1, y() + h() - H, x2 - x1, H);

    H += dh;

    Fl_Color c = sel ? selection_color() : o->selection_color();

    draw_box(box(), x1, y() + h() - H - 10, W, H + 10 - yofs, c);

    // Save the previous label color
    Fl_Color oc = o->labelcolor();

    // Draw the label using the current color...
    o->labelcolor(sel ? labelcolor() : o->labelcolor());
    o->draw_label(x1, y() + h() - H, W, H - yofs, FL_ALIGN_CENTER);

    // Restore the original label color...
    o->labelcolor(oc);

    if (Fl::focus() == this && o->visible())
      draw_focus(box(), x1, y() + h() - H, W, H);

    fl_pop_clip();
  }
}

/* Duplicate of Fl_Tabs since the original ist private. */
int Flmm_Tabs::tab_height() {
  int H = h();
  int H2 = y();
  Fl_Widget*const* a = array();
  for (int i=children(); i--;) {
    Fl_Widget* o = *a++;
    if (o->y() < y()+H) H = o->y()-y();
    if (o->y()+o->h() > H2) H2 = o->y()+o->h();
  }
  H2 = y()+h()-H2;
  if (H2 > H) return (H2 <= 0) ? 0 : -H2;
  else return (H <= 0) ? 0 : H;
}

int Flmm_Tabs::tab_positions(int* p, int* wp) {
  int selected = 0;
  Fl_Widget*const* a = array();
  int i, H = tab_height(), Habs = (H<0)?-H:H, r = w()-Habs;
  leftmost = 0;
  rightmost = children()-1;
  p[0] = Fl::box_dx(box());
  for (i=0; i<children(); i++) {
    Fl_Widget* o = *a++;
    if (o->visible()) selected = i;

    int wt = 0; int ht = 0;
    o->measure_label(wt,ht);

    wp[i]  = wt+EXTRASPACE;
    p[i+1] = p[i]+wp[i]+BORDER;
    if (p[i]-xoff<8) leftmost = i+1;
    if (p[i+1]-xoff<r-8) rightmost = i;
  }
  overlapping = 1;
  if (p[i] <= r) {
    // all children are visible: no offset
    xoff = 0; 
    overlapping = 0;
  } else if (selected<2) {
    // first tab is selected: no offset
    xoff = 0;
  } else if (selected>=children()-2) {
    // last tab is selected: make last tab right aligned
    xoff = p[i]-r+Fl::box_dx(box());
  } else if (selected<=leftmost) {
    // selection is to the left of visible tabs: show selection plus half left aligned
    xoff = p[selected]-((p[selected]-p[selected-1])/2)-Fl::box_dx(box());
  } else if (selected>rightmost) {
    // selection is to the right of visible tabs: show selection plus half right aligned
    xoff = p[selected+2]+((p[selected+2]-p[selected+3])/2)+Fl::box_dx(box())-r;
  } else {
    // selection is currently visible: we are fine
  }
  return selected;
}

Fl_Widget *Flmm_Tabs::which(int event_x, int event_y) {
  int H = tab_height();
  if (H < 0) {
    if (event_y > y()+h() || event_y < y()+h()+H) return 0;
  } else {
    if (event_y > y()+H || event_y < y()) return 0;
  }
  if (event_x < x()) return 0;
  allocate_arrays();
  int *p = tab_position_array; int *wp = tab_width_array;
  tab_positions(p, wp);
  for (int i=0; i<children(); i++) {
    if (event_x < x()+p[i+1]-xoff) return child(i);
  }
  return 0;
}

char Flmm_Tabs::create_menu(Fl_Menu_Item *&menu, Fl_Menu_Item *&picked)
{
  int nc = children();
  menu = 0; 
  picked = 0;
  if (nc<2) return 0;
  allocate_arrays();
  int *p = tab_position_array; int *wp = tab_width_array;
  tab_positions(p, wp);
  struct Fl_Menu_Item *d = menu = new Fl_Menu_Item[nc+1];
  memset(d, 0, (nc+1)*sizeof(Fl_Menu_Item));
  for (int i =0; i<nc; i++) {
    Fl_Widget *c = child(i);
    if (c->visible()) picked = d;
    d->label(c->label());
    d->labeltype(c->labeltype());
    d->labelcolor(c->labelcolor());
    d->labelfont(c->labelfont());
    d->labelsize(c->labelsize());
    if (i==rightmost || i==leftmost-1)
      d->flags = FL_MENU_DIVIDER;
    d++;
  }
  return 1;
}

//
// End of "$Id: Fl_Tabs.cxx 4448 2005-07-23 12:21:58Z matt $".
//
