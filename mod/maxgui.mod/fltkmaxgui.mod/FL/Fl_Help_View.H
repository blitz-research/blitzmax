//
// "$Id: Fl_Help_View.H 5991 2007-12-15 16:08:23Z mike $"
//
// Help Viewer widget definitions.
//
// Copyright 1997-2005 by Easy Software Products.
// Image support donated by Matthias Melcher, Copyright 2000.
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
// Please report all bugs and problems on the following page:
//
//     http://www.fltk.org/str.php
//
// Inline:
//
//   Fl_Help_View::directory()  - Get the directory string.
//   Fl_Help_View::filename()   - Get the filename string.
//   Fl_Help_View::link()       - Set the link callback.
//   Fl_Help_View::size()       - Get the total document length.
//   Fl_Help_View::size()       - Set the document width and height.
//   Fl_Help_View::textcolor()  - Set the default text color.
//   Fl_Help_View::textcolor()  - Get the default text color.
//   Fl_Help_View::textsize()   - Set the default font size.
//   Fl_Help_View::textsize()   - Get the default font size.
//   Fl_Help_View::title()      - Get the title string.
//   Fl_Help_View::topline()    - Get the top line in document.
//   Fl_Help_View::leftline()   - Get the left line position.
//   Fl_Help_View::value()      - Get the HTML text value.
//   Fl_Help_View::monofont()   - Set the default mono font.
//   Fl_Help_View::monofont()   - Get the default mono font.
//   Fl_Help_View::reformat()   - Format the help text.
//   Fl_Help_View::sansfont()   - Set the default sans font.
//   Fl_Help_View::sansfont()   - Get the default sans font.
//   Fl_Help_View::serifont()   - Set the default serif font.
//   Fl_Help_View::serifont()   - Get the default serif font.
//

#ifndef Fl_Help_View_H
#  define Fl_Help_View_H

//
// Include necessary header files...
//

#  include <stdio.h>
#  include "Fl.H"
#  include "Fl_Group.H"
#  include "Fl_Scrollbar.H"
#  include "fl_draw.H"
#  include "Fl_Shared_Image.H"


//
// Fl_Help_Func type - link callback function for files...
//

typedef const char *(Fl_Help_Func)(Fl_Widget *, const char *);

//
// Fl_Help_Block structure
//

// note: we can change private structs accessed by pointers
struct Fl_Help_Block
{
  const char *start, // Start of text
    *end; // End of text
  unsigned char border; // Draw border?
  Fl_Color bgcolor; // Background color
  int x, // Indentation/starting X coordinate
    y, // Starting Y coordinate
    w, // Width
    h; // Height
  // new fields, removed int line[32];
  unsigned char fsize; // current font size
  int font, // current font
    maxh, // max image height
    imgy, // image y position
    pre, // pre text flag
    type, // blockquote/ol/ul/li type parameter
    tag, // tag/element fourcc int
    line, // Left starting position for each line
    cbi; // current block index
};

//
// Fl_Help_Link structure
//

struct Fl_Help_Link
{
  char filename[192], // Link reference filename
    name[32]; // Link target name, blank if none
  int x, // X offset of link text
    y, // Y offset of link text
    w, // Width of link text
    h; // Height of link text
};

//
// Fl_Help_Target structure
//

// note: hijacking this lets us add new data members via the d-pointer
struct Fl_Help_Target
{
  // new fields, removed char name[32]; int y;
  Fl_Help_Link *targets, // Targets
    *linkp; // Currently clicked link
  unsigned char ispush, // link is pushed
    islink, // link clicked
    resized, // window resized
    ispath, // is path used
    nstyle, // navigation style flag
    isnew, // is new page
    pad7, // 
    pad8; // 
  int top, // current topline
    ltop, // last topline
    isnav, // is nav link
    rwidth, // resize width
    cssurllen, // css url length
    csswordlen, // css word length
    *cssword; // css word value
  long rtime, // resize time
    rsec, // resize seconds
    rmil, // resize millisecs
    csstextlen; // css text length
  char *csstext, // css text value
    *cssurl, // css url value
    path[1024], // current file path
    lpath[1024]; // last file path
  int nfonts, // number of fonts in stack
    fonts[100][2]; // font stack
};

//
// Fl_Help_View class...
//

class FL_EXPORT Fl_Help_View : public Fl_Group // Help viewer widget
{
private:

  enum { RIGHT = -1, CENTER, LEFT }; // Alignments

  char title_[1024]; // Title string
  Fl_Color defcolor_, // Default text color
    bgcolor_, // Background color
    textcolor_, // Text color
    linkcolor_; // Link color
  unsigned char textfont_, // Default font - replaced
    textsize_; // Default font size - replaced
  const char *value_; // HTML text value

  int nblocks_, // Number of blocks/lines
    ablocks_; // Allocated blocks
  Fl_Help_Block *blocks_; // Blocks

  int nfonts_; // Number of fonts in stack - replaced
  unsigned char fonts_[100][2]; // Font stack - replaced

  Fl_Help_Func *link_; // Link transform function

  int nlinks_, // Number of links
    alinks_; // Allocated links
  Fl_Help_Link *links_; // Links

  int ntargets_, // Number of targets
    atargets_; // Allocated targets
  Fl_Help_Target *d; // d-pointer struct - was *targets_
  // note: we can rename existing data members

  char directory_[1024], // Directory for current file
    filename_[1024]; // Current filename
  int topline_, // Top line in document
    leftline_, // Left line position
    size_, // Total document length
    hsize_; // Maximum document width
  Fl_Scrollbar scrollbar_, // Vertical scrollbar for document
    hscrollbar_; // Horizontal scrollbar

  static int selection_first; // Text selection
  static int selection_last;
  static int selection_push_first;
  static int selection_push_last;
  static int selection_drag_first;
  static int selection_drag_last;
  static int selected;
  static int draw_mode;
  static int mouse_x;
  static int mouse_y;
  static int current_pos;
  static Fl_Help_View *current_view;
  static Fl_Color hv_selection_color;
  static Fl_Color hv_selection_text_color;

  // new private static class variables
  static int serifont_; // default serif font
  static int sansfont_; // default sans font
  static int monofont_; // default monospace font
  static unsigned char fontsize_; // default font size
  static short face_[250][4]; // font face table [m,b,i,p]
  static unsigned char flet_[30]; // first face for letter table
  static unsigned char fref_[1000]; // face reference table

  Fl_Help_Block *add_block(const char *sp, int xx, int yy, int ww, int hh, unsigned char bc = 0);
  void add_link(const char *np, int xx, int yy, int ww, int hh);
  void add_target(const char *np, int yy);
  static int compare_targets(const Fl_Help_Target *t0, const Fl_Help_Target *t1);
  int do_align(Fl_Help_Block *b, int li, int xx, int ca, int &sl);
  void draw();
  void format();
  void format_table(int *tw, int *maxcols, const char *tp);
  void free_data();
  int get_align(const char *ap, int da);
  const char *get_attr(const char *ap, const char *np, char *buf, int sb);
  Fl_Color get_color(const char *np, Fl_Color dc);
  Fl_Shared_Image *get_image(const char *np, int iw, int ih);
  int get_length(const char *lp);
  //int handle(int event); // moved to public
  // note: you can remove private non-virtual functions if not called by inline functions

  void initfont(unsigned char &fi, unsigned char &fs) { // Reset stack - replaced, for when nfonts > 255
    nfonts_ = 0;
    fl_font(fi = fonts_[0][0] = serifont_, fs = fonts_[0][1] = fontsize_);
  }
  void pushfont(unsigned char fi, unsigned char fs) { // Push font - replaced
    if (nfonts_ < 99) nfonts_ ++;
    fl_font(fonts_[nfonts_][0] = fi, fonts_[nfonts_][1] = fs);
  }
  void popfont(unsigned char &fi, unsigned char &fs) { // Pop font - replaced
    if (nfonts_ > 0) nfonts_ --;
    fl_font(fi = fonts_[nfonts_][0], fs = fonts_[nfonts_][1]);
  }

  void hv_draw(const char *tp, int xx, int yy);
  char begin_selection();
  char extend_selection();
  void end_selection(int cb = 0);
  void clear_global_selection();
  Fl_Help_Link *find_link(int xx, int yy);
  void follow_link(Fl_Help_Link *lp);

  // new private functions
  // note: for BC we can't modify existing function declarations
  Fl_Help_Block *add_block(const Fl_Help_Block &b, const char *sp, int ww);
  unsigned char build_faces();
  static int cmp_targets(const Fl_Help_Link *t0, const Fl_Help_Link *t1);
  const char *format_table(int &tw, int *maxcols, const char *tp, int xx, int rc);
  int get_css_value(const char *sp, const char *pp, char *vp);
  int get_font_size(const char *hp);
  int get_length(const char *lp, int hw);
  void initfont(int &fi, unsigned char &fs);
  int load_css(const char *fp);
  void parse_css(Fl_Help_Block &b, const char *sp, char *buf);
  void popfont(int &fi, unsigned char &fs);
  void pushfont(int fi, unsigned char fs);

public:

  Fl_Help_View(int xx, int yy, int ww, int hh, const char *lp = 0);
  ~Fl_Help_View();

  const char *directory() const { // Get the directory string
    if (directory_[0]) return directory_;
    else return (const char *)0;
  }
  const char *filename() const { // Get the filename string
    if (filename_[0]) return filename_;
    else return (const char *)0;
  }

  int find(const char *sp, int pos = 0);

  void link(Fl_Help_Func *fn) { // Set the link callback
    link_ = fn;
  }

  int load(const char *fp);
  void resize(int xx, int yy, int ww, int hh);

  int size() const { // Get the total document length
    return size_;
  }
  void size(int ww, int hh) { // Set the document width and height
    Fl_Widget::size(ww, hh);
  }
  void textcolor(Fl_Color tc) { // Set the default text color
    if (textcolor_ == defcolor_) textcolor_ = tc;
    defcolor_ = tc;
  }
  Fl_Color textcolor() const { // Get the default text color
    return defcolor_;
  }
  void textfont(unsigned char fi) { // Set the text font, obsolete
    textfont_ = fi;
    //format(); // removed
	// note: we can remove the contents of inline functions
  }
  unsigned char textfont() const { // Get the text font, obsolete
    return textfont_;
  }
  void textsize(unsigned char fs) { // Set the default font size
    fontsize_ = fs;
    //format(); // removed
  }
  unsigned char textsize() const { // Get the default font size
    return fontsize_;
  }
  const char *title() { // Get the title string
    return title_;
  }

  void topline(const char *np);
  void topline(int yy);
  int topline() const { // Get the top line in document
    return topline_;
  }

  void leftline(int xx);
  int leftline() const { // Get the left line position
    return leftline_;
  }

  void value(const char *tp);
  const char *value() const { // Get the HTML text value
    return value_;
  }

  void clear_selection();
  void select_all();

  // new public functions
  int fileislink();
  void filepath(const char *fp);
  char *filepath();
  int font_face(const char *sp);
  int font_style(int fi, unsigned char fs);
  int gettopline();
  int handle(int event); // moved from private

  void monofont(int fi) { // set the default mono font
    monofont_ = fi;
  }
  int monofont() const { // get the default mono font
    return monofont_;
  }
  void reformat() { // format the help text - wrapper function
    format();
  }
  void sansfont(int fi) { // set the default sans font
    sansfont_ = fi;
  }
  int sansfont() const { // get the default sans font
    return sansfont_;
  }
  void serifont(int fi) { // set the default serif font
    serifont_ = fi;
  }
  int serifont() const { // get the default serif font
    return serifont_;
  }

  void setstyle(int flag);

};

#endif // !Fl_Help_View_H

//
// End of "$Id: Fl_Help_View.H 5991 2007-12-15 16:08:23Z mike $".
//
