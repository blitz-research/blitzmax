//
// "$Id: Fl_Help_View.cxx 6091 2008-04-11 11:12:16Z matt $"
//
// Fl_Help_View widget routines.
//
// Copyright 1997-2007 by Easy Software Products.
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
// Contents:
//
//   Fl_Help_View::Fl_Help_View()    - Build a Fl_Help_View widget.
//   Fl_Help_View::add_block()       - Add a text block to the list.
//   Fl_Help_View::add_link()        - Add a new link to the list.
//   Fl_Help_View::add_target()      - Add a new target to the list.
//   Fl_Help_View::begin_selection() - Begin text selection.
//   Fl_Help_View::clear_global_selection() - Clear text selection.
//   Fl_Help_View::clear_selection() - Clear current text selection.
//   Fl_Help_View::cmp_targets()     - Compare two targets.
//   Fl_Help_View::do_align()        - Compute alignment for a line in a block.
//   Fl_Help_View::draw()            - Draw the Fl_Help_View widget.
//   Fl_Help_View::end_selection()   - End text selection.
//   Fl_Help_View::extend_selection()- Extend current text selection.
//   Fl_Help_View::fileislink()      - Was link clicked or nav button?
//   Fl_Help_View::filepath()        - Set value file path string.
//   Fl_Help_View::filepath()        - Get value file path string.
//   Fl_Help_View::find()            - Find the specified string.
//   Fl_Help_View::find_font()       - Find a font list index from a name.
//   Fl_Help_View::find_link()       - Find the link at the given position.
//   Fl_Help_View::follow_link()     - Follow the specified link.
//   Fl_Help_View::font_face()       - Get a font face from a list of names.
//   Fl_Help_View::font_style()      - Get a font style from a font list index.
//   Fl_Help_View::format()          - Format the help text.
//   Fl_Help_View::format_table()    - Format a table.
//   Fl_Help_View::free_data()       - Free memory used for the document.
//   Fl_Help_View::get_align()       - Get an alignment attribute.
//   Fl_Help_View::get_attr()        - Get an attribute value from the string.
//   Fl_Help_View::get_color()       - Get an alignment attribute.
//   Fl_Help_View::get_css_value()   - Outputs the value of a given css property to buffer.
//   Fl_Help_View::get_font_size()   - Get a height value for font-size.
//   Fl_Help_View::get_image()       - Get an inline image.
//   Fl_Help_View::get_length()      - Get a length value either absolute or %.
//   Fl_Help_View::get_length()      - Get a length value of a given width.
//   Fl_Help_View::gettopline()      - Get current topline in document.
//   Fl_Help_View::handle()          - Handle events in the widget.
//   Fl_Help_View::hv_draw()         - Draws text.
//   Fl_Help_View::initfont()        - Initialize font stack.
//   Fl_Help_View::leftline()        - Set the left line position.
//   Fl_Help_View::load()            - Load the specified file.
//   Fl_Help_View::load_css()        - Loads a css file.
//   Fl_Help_View::parse_css()       - Parses all supported css properties.
//   Fl_Help_View::popfont()         - Pop from font stack.
//   Fl_Help_View::pushfont()        - Push to font stack.
//   Fl_Help_View::resize()          - Resize the help widget.
//   Fl_Help_View::select_all()      - Select all text.
//   Fl_Help_View::setstyle() -      - Set the html style flag.
//   Fl_Help_View::topline()         - Set the top line to the named target.
//   Fl_Help_View::topline()         - Set the top line by number.
//   Fl_Help_View::value()           - Set the help text directly.
//   Fl_Help_View::~Fl_Help_View()   - Destroy a Fl_Help_View widget.
//
// Local:
//
//   command()                       - Convert a command with up to four letters into an uint.
//   quote_char()                    - Return the character code associated with a quoted char.
//   hscrollbar_callback()           - Callback for the horizontal scrollbar.
//   scrollbar_callback()            - Callback for the scrollbar.
//

/*
 mark: starting in July 2008 I have heavily modified this file and
 it's header. So since I have made so many changes, instead of plonking
 my name everywhere I have made original code comments start in
 uppercase and my code comments start in lowercase.

 List of currently supported HTML tags/elements with attributes:

 <a href name target></a>
 <b></b> <strong></strong>
 <blockquote type></blockquote>
  <dl compact></dl>  <dd> <dt>
  <ol type></ol> <li type></li>
  <ul type></ul> <li type></li>
 <body background bgcolor text link vlink alink></body>
 <br clear>
 <center></center>
 <code></code> <tt></tt>
 <div align id></div>
 <font face size color></font>
 <h1 align></h1>
 <head></head>
 <hr width size align clear>
 <html></html>
 <i></i> <em></em>
 <img src lowsrc alt align width height hspace vspace border usemap name>
 <kbd></kbd>
 <noscript></noscript>
 <p align></p>
 <pre></pre>
 <script language src></script>
 <table bgcolor background border cellpadding cellspacing width height></tab>
 <tr valign align bgcolor background></tr>
 <td valign align width height colspan rowspan bgcolor background></td>
 <th as td></th>
 <title></title>
 <u></u>
 <var></var>
*/

//
// Include necessary header files
//

#include <FL/Fl_Help_View.H>
#include <FL/Fl_Window.H>
#include <FL/Fl_Pixmap.H>
#include <FL/x.H>
#include <stdio.h>
#include <stdlib.h>
#include "flstring.h"
#include <ctype.h>
#include <errno.h>
#include <math.h>
#include "forms_timer.cxx" // for fl_gettime in resize()

#if defined(WIN32) && ! defined(__CYGWIN__)
#  include <io.h>
#  include <direct.h>
// Visual C++ 2005 incorrectly displays a warning about the use of
// POSIX APIs on Windows, which is supposed to be POSIX compliant...
#  define getcwd _getcwd
#else
#  include <unistd.h>
#endif // WIN32

//
// Define preprocessor constants and macros
//

#define HV_64 64 // Columns, was 200 but practically 64 is enough
#define HV_32 32 // medium array size
#define HV_16 16 // small array size

#define HV_DEFAULT 0 // html style flag
#define HV_NOCONTEXTMENU 1 // no right-click menu
#define HV_NONAVIGATE 2 // no user navigation

// 'ENC(ANSI/Unicode, Mac Roman)' - OS character encoding macro

#ifdef ENC
# undef ENC
#endif
#ifdef __APPLE__
# define ENC(a, b) b
#else
# define ENC(a, b) a
#endif

// 'CTRL(char)' - Shortcut key macro, get bits 0..4 of char

#define CTRL(x) ((x) & 0x1f)

// 'CMD(char[0], char[1], char[2], char[3])' - Fourcc macro, chars to int

#define CMD(a, b, c, d) ((a << 24) | (b << 16) | (c << 8) | d)

// 'CHR(int, charindex)' - char from int macro, used like a 4-char array

#define CHR(a, b) ((a & (255 << ((3-(b & 3)) << 3))) >> ((3-(b & 3)) << 3))

// 'MIL(sec, mil, sec2, mil2)' - difference in mil macro, using fl_gettime

#define MIL(a, b, c, d) ((c > a || (c == a && d > b)) ? \
                         (1000000 * (c - a)) - b + d : \
                         (1000000 * (a - c)) - d + b)

//
// Typedef the C API sort function type the only way I know how...
//

extern "C" // Compile qsort() in C style to avoid any compiler errors
{
  typedef int (*compare_func_t)(const void *, const void *);
}

//
// Declare local functions
//

static unsigned int command(const char *cmdp); // Used in end_selection
static int quote_char(const char *qp, int fc = 0); // added fc
static void hscrollbar_callback(Fl_Widget *s, void *);
static void scrollbar_callback(Fl_Widget *s, void *);

//
// Broken image
//

static const char *broken_xpm[] =
{
  "16 24 4 1",
  "@ c #000000", // Black
  "  c #ffffff", // White
  "+ c none", // Transparent
  "x c #ff0000", // Red
  // Pixels
  "@@@@@@@+++++++++",
  "@    @++++++++++",
  "@   @+++++++++++",
  "@   @++@++++++++",
  "@    @@+++++++++",
  "@     @+++@+++++",
  "@     @++@@++++@",
  "@ xxx  @@  @++@@",
  "@  xxx    xx@@ @",
  "@   xxx  xxx   @",
  "@    xxxxxx    @",
  "@     xxxx     @",
  "@    xxxxxx    @",
  "@   xxx  xxx   @",
  "@  xxx    xxx  @",
  "@ xxx      xxx @",
  "@              @",
  "@              @",
  "@              @",
  "@              @",
  "@              @",
  "@              @",
  "@              @",
  "@@@@@@@@@@@@@@@@",
  0 // nul-terminate - rem'd NULL
};
static Fl_Pixmap broken_image(broken_xpm);

//
// Simple margin stack for Fl_Help_View::format()
//

struct fl_margins
{
  int depth_; // Array index
  int margins_[100]; // Margins stack

  fl_margins() {
    clear();
  }

  int clear() { // Init margins
//  puts("fl_margins::clear()");

    depth_ = 0;
    return margins_[0] = 4; // Default indent
  }

  int current() { // Get current margin
    return margins_[depth_];
  }

  int pop() { // Get last margin

//printf("fl_margins::pop(): depth_=%d, xx=%d\n", depth_,
//  (depth_ > 0) ? margins_[depth_ - 1] : 4);

    if (depth_ > 0) {
      depth_ --;
      return margins_[depth_];
    }
    else
      return 4; // Default indent
  }

  int push(int indent) { // Set next margin
    int xx;

    xx = margins_[depth_] + indent; // New indent

//printf("fl_margins::push(indent=%d): depth_=%d, xx=%d\n", indent,
//  depth_ + 1, xx);

    if (depth_ < 99) {
      depth_ ++;
      margins_[depth_] = xx;
    }

    return xx;
  }
};

//
// All the stuff needed to implement text selection in Fl_Help_View
//

/* matt:
 We are trying to keep binary compatibility with previous versions
 of FLTK. This means that we are limited to adding static data members
 only to not enlarge the Fl_Help_View class. Lucky for us, only one
 text can be selected system wide, so we can remember the selection
 in a single set of values.

 Still to do:
 - &word; style characters mess up our count inside a word boundary
 - we can only select words, no individual characters
 - no dragging of the selection into another widget
 - selection must be cleared if another widget get focus!
 - write a comment for every new function

 mark: Static data members don't change the binary size or layout
 of a class because they are defined externally.
 For more info on binary compatibility (BC):
 http://techbase.kde.org/Policies/Binary_Compatibility_Issues_With_C++
 */

/*
 matt: The following functions are also used to draw stuff and should be
 replaced with local copies that are much faster when merely counting.
 fl_color(Fl_Color);
 fl_rectf(int, int, int, int);
 fl_push_clip(int, int, int, int);
 fl_xyline(int, int, int);
 fl_rect()
 fl_line()
 img->draw()

 mark: local functions more-so static are faster than class functions.
*/

// Text selection
// We don't put the offscreen buffer in the help view class because
// we'd need to include x.H in the header...

static Fl_Offscreen fl_help_view_buffer;

//
// Define and zero static data members
//

int Fl_Help_View::selection_first = 0;
int Fl_Help_View::selection_last = 0;
int Fl_Help_View::selection_push_first = 0;
int Fl_Help_View::selection_push_last = 0;
int Fl_Help_View::selection_drag_first = 0;
int Fl_Help_View::selection_drag_last = 0;
int Fl_Help_View::selected = 0;
int Fl_Help_View::draw_mode = 0;
int Fl_Help_View::mouse_x = 0;
int Fl_Help_View::mouse_y = 0;
int Fl_Help_View::current_pos = 0;
Fl_Help_View *Fl_Help_View::current_view = 0; // rem'd NULL
Fl_Color Fl_Help_View::hv_selection_color;
Fl_Color Fl_Help_View::hv_selection_text_color;

// new static class variables
int Fl_Help_View::serifont_ = 0; // default serif font
int Fl_Help_View::sansfont_ = 0; // default sans font
int Fl_Help_View::monofont_ = 0; // default monospace font
unsigned char Fl_Help_View::fontsize_ = 0; // default font size
short Fl_Help_View::face_[250][4]; // font face table [m,b,i,p]
unsigned char Fl_Help_View::flet_[30]; // first face for letter table
unsigned char Fl_Help_View::fref_[1000]; // face reference table

//
// Fl_Help_View::Fl_Help_View() - Build a Fl_Help_View widget.
//

Fl_Help_View::Fl_Help_View(int xx, // I - Left position
                           int yy, // I - Top position
                           int ww, // I - Width in pixels
                           int hh, // I - Height in pixels
                           const char *lp) // I - Label pointer, opt
: Fl_Group(xx, yy, ww, hh, lp),
  scrollbar_(xx + ww - Fl::scrollbar_size(), yy,
             Fl::scrollbar_size(), hh - Fl::scrollbar_size()),
  hscrollbar_(xx, yy + hh - Fl::scrollbar_size(),
              ww - Fl::scrollbar_size(), Fl::scrollbar_size())
{
  color(FL_WHITE, FL_SELECTION_COLOR); // Set bgcolor and selcolor of widget - rem'd FL_BACKGROUND2_COLOR

  title_[0] = '\0'; // Title string
  defcolor_ = FL_BLACK; // Default text color - rem'd FL_FOREGROUND_COLOR
  bgcolor_ = FL_WHITE; // Background color - rem'd FL_BACKGROUND_COLOR
  textcolor_ = defcolor_; // Text color
  linkcolor_ = FL_BLUE; // Link color - rem'd FL_SELECTION_COLOR
  serifont_ = FL_TIMES; // Default font, was textfont_
  fontsize_ = 12; // Default font size, was textsize_
  value_ = 0; // HTML text value - rem'd NULL
  ablocks_ = 0; // Allocated blocks
  nblocks_ = 0; // Number of blocks
  blocks_ = (Fl_Help_Block *)0; // Blocks

  nfonts_ = 0; // Number of fonts in stack - replaced

  link_ = (Fl_Help_Func *)0; // Link transform function

  alinks_ = 0; // Allocated links
  nlinks_ = 0; // Number of links
  links_ = (Fl_Help_Link *)0; // Links

  //targets_ = (Fl_Help_Target *)0; // rem'd
  atargets_ = 0; // Allocated targets
  ntargets_ = 0; // Number of targets

  directory_[0] = '\0'; // Directory for current file
  filename_[0] = '\0'; // Current filename

  topline_ = 0; // Top line in document
  leftline_ = 0; // Lefthand position
  size_ = 0; // Total document length
  hsize_ = 0; // Maximum document width

  scrollbar_.value(0, hh, 0, 1);
  scrollbar_.step(8.0);
  scrollbar_.show();
  scrollbar_.callback(scrollbar_callback);
  scrollbar_.linesize(32); // vertical scroll size, default is 16

  hscrollbar_.value(0, ww, 0, 1); // Set line position, window, top, total
  hscrollbar_.step(8.0); // Set mouse step rounding value
  hscrollbar_.show(); // Show widget
  hscrollbar_.callback(hscrollbar_callback); // Set callback func for widget
  hscrollbar_.type(FL_HORIZONTAL); // Set slider type, default is vertical
  end(); // End current Fl_Group widgets

  d = (Fl_Help_Target *)malloc(sizeof(Fl_Help_Target)); // d-pointer
  d->targets = (Fl_Help_Link *)0; // Targets
  d->linkp = (Fl_Help_Link *)0; // Currently clicked link
  d->ispush = 0; // link is pushed
  d->islink = 0; // link clicked
  d->resized = 0; // window resized
  d->ispath = 0; // is path used
  d->nstyle = 0; // navigation style flag
  d->isnew = 0; // is new page
  d->top = 0; // current topline
  d->ltop = 0; // last topline
  d->isnav = 0; // is nav link
  d->rwidth = w(); // resize width
  d->cssurllen = 0; // css url length
  d->csswordlen = 0; // css word length
  d->cssword = 0; // css word value
  d->rtime = 0; // resize time
  d->rsec = 0; // resize seconds
  d->rmil = 0; // resize millisecs
  d->csstextlen = 0; // css text length
  d->csstext = 0; // css text value
  d->cssurl = 0; // css url value
  d->path[0] = '\0'; // current file path
  d->lpath[0] = '\0'; // last file path
  d->fonts[0][0] = 0; // font stack
  d->nfonts = 0; // number of fonts in stack
  
  build_faces();

  // load new default fonts
  serifont_ = FL_TIMES; // default/serif font
  sansfont_ = FL_HELVETICA; // sans font
  monofont_ = FL_COURIER; // monospace font
  
  resize(xx, yy, ww, hh); // Resize widget

} // Fl_Help_View::Fl_Help_View()

//
// Fl_Help_View::add_block() - replaced, code moved
//

Fl_Help_Block * // O - Pointer to new block
Fl_Help_View::add_block(const char *sp, // I - Pointer to start
                        int xx, // I - X position
                        int yy, // I - Y position
                        int ww, // I - Right margin
                        int hh, // I - Height
                        unsigned char bc) // I - Draw border, opt
{
  return 0;

} // Fl_Help_View::add_block()

//
// Fl_Help_View::add_block() - Add a text block to the list.
//

Fl_Help_Block * // O - Pointer to new block
Fl_Help_View::add_block(const Fl_Help_Block &b, // I - block object
                        const char *sp, // I - Pointer to start
                        int ww) // I - Right margin
{
  Fl_Help_Block *block; // New block

  if (nblocks_ >= ablocks_) {
    ablocks_ += 16; // Allocated blocks, 16 blocks per allocation
    int size = sizeof(Fl_Help_Block) * ablocks_; // block size
    if (ablocks_ == 16) // Memory was freed
      blocks_ = (Fl_Help_Block *)malloc(size);
    else // First pass or resize resulted in a few new blocks
      blocks_ = (Fl_Help_Block *)realloc(blocks_, size);
  }

  block = blocks_ + nblocks_;
  memset(block, 0, sizeof(Fl_Help_Block));

  block->start = sp; // Start of text, varies so set by sp
  block->end = sp; // End of text, varies so set by sp
  block->x = b.x; // Starting X coordinate
  block->y = b.y; // Starting Y coordinate
  block->w = ww; // Width, varies so set by ww
  block->h = 0; // Height, always zero
  block->maxh = 0; // max image height
  block->imgy = 0; // image y position
  block->pre = b.pre; // pre text flag
  block->tag = b.tag; // tag/element fourcc int
  block->border = b.border; // Draw border?
  block->font = b.font; // current font
  block->fsize = b.fsize; // current font size
  block->bgcolor = b.bgcolor; // Background color
  block->cbi = nblocks_; // current block index

  nblocks_ ++; // Number of blocks
  
  return block;

} // Fl_Help_View::add_block()

//
// Fl_Help_View::add_link() - Add a new link to the list.
//

void Fl_Help_View::add_link(const char *np, // I - Name of link
                            int xx, // I - X position of link
                            int yy, // I - Y position of link
                            int ww, // I - Width of link text
                            int hh) // I - Height of link text
{
  Fl_Help_Link *link; // New link
  char *target; // Pointer to target name

  if (nlinks_ >= alinks_) {
    alinks_ += 16; // Allocated links, 16 blocks per allocation
    int size = sizeof(Fl_Help_Link) * alinks_; // block size
    if (alinks_ == 16)
      links_ = (Fl_Help_Link *)malloc(size);
    else
      links_ = (Fl_Help_Link *)realloc(links_, size);
  }

  link = links_ + nlinks_;
  link->x = xx; // X offset of link text
  link->y = yy; // Y offset of link text
  link->w = xx + ww; // Width of link text
  link->h = yy + hh; // Height of link text

  strlcpy(link->filename, np, sizeof(link->filename)); // nul-terminated

  if ((target = strrchr(link->filename, '#'))) { // Last '#' - rem'd != 0
    *(target ++) = '\0'; // Remove target from link->filename
    strlcpy(link->name, target, sizeof(link->name)); // Link target
  }
  else
    link->name[0] = '\0'; // Blank link target

  nlinks_ ++; // Number of links

} // Fl_Help_View::add_link()

//
// Fl_Help_View::add_target() - Add a new target to the list.
//

void Fl_Help_View::add_target(const char *np, // I - Name of target
                              int yy) // I - Y position of target
{
  Fl_Help_Link *target; // New target

  if (ntargets_ >= atargets_) {
    atargets_ += 16; // Allocated targets, 16 blocks per allocation
    int size = sizeof(Fl_Help_Link) * atargets_; // block size
    if (atargets_ == 16)
      d->targets = (Fl_Help_Link *)malloc(size);
    else
      d->targets = (Fl_Help_Link *)realloc(d->targets, size);
  }

  target = d->targets + ntargets_;
  target->y = yy; // Y offset
  strlcpy(target->name, np, sizeof(target->name)); // Target name

  ntargets_ ++; // Number of targets

} // Fl_Help_View::add_target()

//
// Fl_Help_View::begin_selection() - Begin text selection.
//

char // O - True if text selected
Fl_Help_View::begin_selection()
{
  clear_global_selection();

  if (!fl_help_view_buffer)
    fl_help_view_buffer = fl_create_offscreen(1, 1);

  mouse_x = Fl::event_x();
  mouse_y = Fl::event_y();
  draw_mode = 1; // Begin selection mode

  current_view = this;
  fl_begin_offscreen(fl_help_view_buffer);
  draw();
  fl_end_offscreen();

  draw_mode = 0;

  if (selection_push_last)
    return 1;
  else
    return 0;

} // Fl_Help_View::begin_selection()

//
// Fl_Help_View::build_faces() - build font face look-up tables.
//

unsigned char // O - number of font faces
Fl_Help_View::build_faces()
{
  char buf[100], namebuf[100], tbufs[100][100]; // buffers
  const char *namep; // pointer
  char *bufp, *namebufp; // r+w pointer
  int ti = 0, tj = 0, tk = 0, // temp loop vars
    tnum = 0, lnum = 0, fnum = 0, // temp/last/font counters
    tfi[100], tf[10],
    cbit = 0, fbit = 0, tbit = 0, // bits
    nfonts = 0, nfaces = 0, // number of fonts and faces
    temp = 0; // lengths

  strlcpy(buf, " ", sizeof(buf)); // init buffer
  memset(face_, 0, sizeof(face_)); // zero tables
  memset(flet_, 0, sizeof(flet_));
  memset(fref_, 0, sizeof(fref_));

  nfonts = Fl::set_fonts(0); // number of ISO8859-1 fonts in list

  for (ti = 0, nfaces = 0; ti < nfonts; ti ++) { // find base fonts
    namep = Fl::get_font_name((Fl_Font)ti, &temp); // fltk font name
    for (tk = 0; namep[tk] != '\0'; tk ++)
      namebuf[tk] = tolower(namep[tk]); // copy chars to lowercase
    namebuf[tk] = '\0'; // nul-terminate
    if (strstr(namebuf+1, "black") || strstr(namebuf+1, "bold") ||
        strstr(namebuf+1, "extra") || strstr(namebuf+1, "heavy") ||
        strstr(namebuf+1, "inclined") || strstr(namebuf+1, "italic") ||
        strstr(namebuf+1, "light") || strstr(namebuf+1, "oblique") ||
        strstr(namebuf+1, "slanted") || strstr(namebuf+1, "wide") ||
        strstr(namebuf+1, "ultra"))
      continue; // skip font styles
    if ((bufp = strstr(namebuf, "-"))) { // full font name
      if (strstr(bufp+1, "bd") || strstr(bufp+1, "cond") ||
          strstr(bufp+1, "cn") || strstr(bufp+1, "it") ||
          strstr(bufp+1, "obl") || strstr(bufp+1, "smbd"))
      continue; // skip font styles
    }
    temp = strlen(namebuf);
    if (temp < (int)strlen(buf)) temp = strlen(buf); // use bigger length
    if (!strncmp(namebuf, buf, temp)) continue; // same name as last
    if (nfaces < (int)sizeof(face_)/8) { // store next face
      face_[nfaces][2] = ti; // first font for face
      face_[nfaces][3] = (uchar)*namebuf; // first letter for face, a..z
      if (face_[nfaces][3] < 97 || face_[nfaces][3] > 123)
        face_[nfaces][3] = 123; // illegal char, z
      nfaces ++; // next face
    }
    strlcpy(buf, namebuf, sizeof(buf)); // last name in buffer
  }

  for (ti = 0, fnum = 0; ti < 27; ti ++) { // sort faces alphabetically
    for (tj = 0; tj < nfaces; tj ++) {
      tnum = face_[tj][3] - 97; // first letter, a = 0
      if (ti == tnum) { // current letter match
        face_[fnum][0] = face_[tj][2]; // first font index
        face_[fnum][1] = face_[tj][3]; // first letter
        fnum ++; // next face
      }
    }
  }

  for (ti = 0; ti < nfaces; ti ++) { // store all fonts in face table
    fnum = face_[ti][0]; // face index
    namep = Fl::get_font_name((Fl_Font)fnum, &temp);
    for (tk = 0; namep[tk] != '\0'; tk ++)
      buf[tk] = tolower(namep[tk]);
    buf[tk] = '\0'; // nul-terminate
    if (!(bufp = strstr(buf, "-"))) bufp = buf + tk;
    *bufp = '\0'; // shorten full name
    strlcpy(tbufs[0], buf, sizeof(tbufs[0]));
    face_[ti][1] = face_[ti][2] = face_[ti][3] = 0; // reset
    memset(tf, 0, sizeof(tf));

    for (tj = 0, tfi[0] = fnum, lnum = 1; tj < nfonts; tj ++) { // get all fonts of face
      namep = Fl::get_font_name((Fl_Font)tj, &temp); // fltk font name
      for (tk = 0; namep[tk] != '\0'; tk ++)
        namebuf[tk] = tolower(namep[tk]); // copy to lowercase
      namebuf[tk] = '\0'; // nul-terminate
      if (!isalpha(namebuf[0])) continue; // skip foreign chars
      if (!(namebufp = strstr(namebuf, "-"))) namebufp = namebuf; // full font name
      if (strstr(namebuf, " ") && namebufp == namebuf) { // basic font name
        namebufp = strstr(namebuf, " bold");
        if (!namebufp) namebufp = strstr(namebuf, " italic");
        if (!namebufp) namebufp = strstr(namebuf, " oblique");
      }
      if (!strncmp(buf, namebuf, bufp-buf) && (namebufp-namebuf == bufp-buf)) { // face name match
        strlcpy(tbufs[lnum], namebuf, sizeof(tbufs[lnum]));
        tfi[lnum] = tj; // font indexes
        lnum ++; // count fonts
        if (strstr(namebuf, "-")) { // abbreviations if full name
          if (strstr(namebufp+1, "bd")) tf[1] = 1;
          if (strstr(namebufp+1, "it")) tf[2] = 1;
        }
        if (strstr(namebufp+1, "bold")) tf[1] = 1; // set flags of current face
        if (strstr(namebufp+1, "italic")) tf[2] = 1;
        if (strstr(namebufp+1, "medium")) tf[3] = 1;
        if (strstr(namebufp+1, "plain")) tf[4] = 1;
        if (strstr(namebufp+1, "regular")) tf[5] = 1;
      }
    }

    for (tj = 0; tj < lnum; tj ++, tk = 0) { // sort fonts styles in face
      if (!(namebufp = strstr(tbufs[tj], "-"))) namebufp = tbufs[tj];
      if (tf[1] && strstr(namebufp+1, "black")) tk = 1; // favour bold, italic, etc
      else if (strstr(namebufp+1, "condensed")) tk = 1;
      else if (strstr(namebufp+1, "cond") && namebufp > tbufs[tj]) tk = 1;
      else if (strstr(namebufp+1, "cn") && namebufp > tbufs[tj]) tk = 1;
      else if (strstr(namebufp+1, "extra")) tk = 1;
      else if (tf[1] && strstr(namebufp+1, "heavy")) tk = 1;
      else if ((tf[3] || tf[4] || tf[5]) && strstr(namebufp+1, "light")) tk = 1;
      else if (tf[2] && strstr(namebufp+1, "light")) tk = 1;
      else if (tf[2] && strstr(namebufp+1, "oblique")) tk = 1;
      else if (tf[2] && strstr(namebufp+1, "obl") && namebufp > tbufs[tj]) tk = 1;
      else if (tf[2] && strstr(namebufp+1, "inclined")) tk = 1;
      else if (tf[1] && strstr(namebufp+1, "semibold")) tk = 1;
      else if (tf[1] && strstr(namebufp+1, "smbd") && namebufp > tbufs[tj]) tk = 1;
      else if (tf[2] && strstr(namebufp+1, "slanted")) tk = 1;
      else if (strstr(namebufp+1, "ultra")) tk = 1;
      if (lnum > 8 && tf[1] && tf[2]) { // simplify if too many variations
        tk = 1;
        if (!strncmp(namebufp+1, "bold", 4) && namebufp[5] == '\0') tk = 0;
        if (!strncmp(namebufp+1, "italic", 6) && namebufp[7] == '\0') tk = 0;
        if (!strncmp(namebufp+1, "bolditalic", 10) && namebufp[11] == '\0') tk = 0;
        if (!strncmp(namebufp+1, "medium", 6) && namebufp[7] == '\0') tk = 0;
        if (!strncmp(namebufp+1, "regular", 7) && namebufp[8] == '\0') tk = 0;
      }
      if (tk == 1) continue; // skip font
      cbit = fbit = tbit = 0; // set font styles
      if (strstr(namebufp+1, "medium") || strstr(namebufp+1, "plain") ||
          strstr(namebufp+1, "regular")) cbit = 1;
      if (strstr(namebufp+1, "roman") && namebufp > tbufs[tj]) cbit = 1;
      if (strstr(namebufp+1, "bold") || strstr(namebufp+1, "italic")) cbit = 0;
      if (strstr(namebufp+1, "black") || strstr(namebufp+1, "bold") ||
          strstr(namebufp+1, "heavy") || strstr(namebufp+1, "semibold") ||
          strstr(namebufp+1, "wide")) fbit = 1;
      else if ((strstr(namebufp+1, "bd") || strstr(namebufp+1, "smbd")) &&
               namebufp > tbufs[tj]) fbit = 1;
      if (strstr(namebufp+1, "oblique") || strstr(namebufp+1, "inclined") ||
          strstr(namebufp+1, "italic") || strstr(namebufp+1, "slanted")) tbit = 1;
      else if ((strstr(namebufp+1, "it") || strstr(namebufp+1, "obl")) &&
               namebufp > tbufs[tj]) tbit = 1;
      if (cbit) face_[ti][0] = tfi[tj];
      if (fbit && !tbit && !face_[ti][1]) face_[ti][1] = tfi[tj]; // bold
      if (!fbit && tbit && !face_[ti][2]) face_[ti][2] = tfi[tj]; // italic
      if (fbit && tbit && !face_[ti][3]) face_[ti][3] = tfi[tj]; // plus
    }
  }

  for (ti = 0; ti < nfaces; ti ++) { // remove duplicate fonts
    for (tj = ti+1; tj < nfaces; tj ++)
      if (face_[ti][1] == face_[tj][1]) face_[tj][1] = 0; // sort face loop does the rest
  }

  for (ti = 0; ti < nfaces; ti ++) { // sort face table
    if (!face_[ti][2]) face_[ti][2] = face_[ti][0]; // no italic
    if (!face_[ti][3]) face_[ti][3] = face_[ti][1]; // no plus
    if (face_[ti][1]) { // move face
      for (tk = 0; tk < ti; tk ++) {
        if (!face_[tk][1]) { // first empty face
          for (tj = 0; tj <= 3; tj ++) {
            face_[tk][tj] = face_[ti][tj];
            face_[ti][tj] = 0;
          }
          break;
        }
      }
    }
  }

  for (nfaces = 1; nfaces < (int)sizeof(face_)/8; nfaces ++)
    if (!face_[nfaces][1]) break; // recount faces

  for (ti = 0, lnum = 0; ti < nfaces; ti ++) { // sort letter lut
    fnum = face_[ti][0];
    namep = Fl::get_font_name((Fl_Font)fnum, &temp);
    tnum = (uchar)tolower(*namep) - 97; // current letter, a = 0
    if (tnum != lnum && tnum < 27) // first instance of letter a..z
      flet_[tnum] = ti; // store face index
    lnum = tnum; // last letter
  }
  flet_[27] = nfaces; // last face index

  for (ti = 0; ti < nfaces; ti ++) { // face reference table
    for (tj = 0; tj <= 3; tj ++) { // fonts in face
      fnum = face_[ti][tj]; // font index
      if (fnum < (int)sizeof(fref_)) fref_[fnum] = ti; // store face index
    }
  }

  return nfaces; // we're done

} // Fl_Help_View::build_faces()

//
// Fl_Help_View::clear_global_selection() - Clear text selection.
//

void Fl_Help_View::clear_global_selection()
{
  if (selected) redraw(); // Set widget to draw
  selection_push_first = selection_push_last = 0;
  selection_drag_first = selection_drag_last = 0;
  selection_first = selection_last = 0;
  selected = 0;

} // Fl_Help_View::clear_global_selection()

//
// Fl_Help_View::clear_selection() - Clear current text selection.
//

void Fl_Help_View::clear_selection()
{
  if (current_view == this) clear_global_selection();

} // Fl_Help_View::clear_selection()

//
// Fl_Help_View::cmp_targets() - Compare two targets.
//

int // O - Result of comparison
Fl_Help_View::cmp_targets(const Fl_Help_Link *t0, // I - First target
                          const Fl_Help_Link *t1) // I - Second target
{
  return strcasecmp(t0->name, t1->name); // Target names

} // Fl_Help_View::cmp_targets()

//
// Fl_Help_View::compare_targets() - replaced, struct used for d-pointer
//

int
Fl_Help_View::compare_targets(const Fl_Help_Target *t0,
                              const Fl_Help_Target *t1)
{
  return 0;

} // Fl_Help_View::compare_targets()

//
// Fl_Help_View::do_align() - Compute alignment for a line in a block.
//

int // O - New line
Fl_Help_View::do_align(Fl_Help_Block *b, // I - Block to add to
                       int li, // I - Current line - removed
                       int xx, // I - Current X position
                       int ca, // I - Current alignment
                       int &sl) // IO - Starting link
{
  int offset = 0; // Alignment offset

  switch (ca) {
    case RIGHT : // Right
      offset = b->w - xx;
      break;
    case CENTER : // Center
      offset = (b->w - xx) / 2;
      break;
    default : // Left
      offset = 0;
      break;
  }

  b->line = b->x + offset; // Left starting position for line

  //if (li < 31) li ++;

  while (sl < nlinks_) {
    links_[sl].x += offset; // X offset of link text
    links_[sl].w += offset; // Width of link text
    sl ++;
  }

  return li;

} // Fl_Help_View::do_align()

//
// Fl_Help_View::draw() - Draw the Fl_Help_View widget.
//

void Fl_Help_View::draw()
{
  char *sp, // Buffer search ptr
    //*tp, // temp buffer ptr - symbol font hack
    buf[1024], // Text buffer
    attr[1024], // Attribute buffer
    //tbuf[1024], // temp buffer - symbol font hack
    wattr[8], // Width attribute
    hattr[8], // Height attribute
    tag[4]; // tag/element 4-char buf
  const Fl_Help_Block *block; // Pointer to current block
  const char *ptr, // Pointer to text in block
    *attrptr, // Start of attributes ptr
    *tagptr; // Start of tag/element ptr
  int ti = 0, // temp loop var
    bi = 0, // Main loop var
    temp = 0, // temp var
    ss = 0, // Scrollbar size
    qch = 0, // Quote char
    baseh = 0, // baseline offset for images
    line = 0, // Current line
    xx = 0, yy = 0, ww = 0, hh = 0, // Current positions and sizes
    head = 0, // Head/body section flag
    pre = 0, // Pre text flag
    btag = 0, // tag/element fourcc int
    needspace = 0, // Do we need whitespace?
    underline = 0, // Underline text?
    tx = 0, ty = 0, tw = 0, th = 0, // Table cell positions and sizes
    linew = 0, // current line width
    imgw = 0, // Image width
    imgh = 0, // Image height
    brflag = 0, // br flag
	font = 0; // Current font
  unsigned char fsize; // Current font size
    //tfont, tempsize; // symbol font hack, not implemented
  Fl_Boxtype bt = (box()) ? box() : FL_DOWN_BOX; // Box to draw
  Fl_Shared_Image *img = 0; // Shared image - rem'd NULL

  // Draw the scrollbar/s and box first
  ww = w();
  hh = h();

  initfont(font, fsize);

  draw_box(bt, x(), y(), ww, hh, bgcolor_);

  ss = Fl::scrollbar_size();
  if (hscrollbar_.visible()) {
    draw_child(hscrollbar_);
    hh -= ss;
    ti ++;
  }
  if (scrollbar_.visible()) {
    draw_child(scrollbar_);
    ww -= ss;
    ti ++;
  }
  if (ti == 2) {
    fl_color(FL_GRAY);
    fl_rectf(x() + ww - Fl::box_dw(bt) + Fl::box_dx(bt),
             y() + hh - Fl::box_dh(bt) + Fl::box_dy(bt), ss, ss);
  }

  if (!value_) return;

  if (current_view == this && selected) {
    hv_selection_color = FL_SELECTION_COLOR;
    hv_selection_text_color = fl_contrast(textcolor_, FL_SELECTION_COLOR);
  }
  current_pos = 0;

  // Clip the drawing to the inside of the box
  fl_push_clip(x() + Fl::box_dx(bt), y() + Fl::box_dy(bt),
               ww - Fl::box_dw(bt), hh - Fl::box_dh(bt));
  fl_color(textcolor_);

//printf("hh=%d ss=%d h()=%d\n",hh,ss,h());

  // Draw all visible blocks
  for (bi = 0, block = blocks_; bi < nblocks_; bi ++, block ++)
    if ((block->y + block->h) >= topline_ && block->y < (topline_ + h()))
    {
      line = 0;
      xx = block->line;
      yy = block->y - topline_;
      pre = block->pre;
      //if (!pre) {
      popfont(font, fsize);
      font = block->font; // default font for block
      fsize = block->fsize;
      pushfont(font, fsize);
      //}
      hh = 0;
      needspace = 0;
      brflag = 0;
      linew = 0;

      for (ptr = block->start, sp = buf; ptr < block->end; )
      {
        if ((*ptr == '<' || isspace((*ptr) & 255)) && sp > buf)
        {
          if (!head && !pre) // Draw normal text
          {
            *sp = '\0'; // Nul-terminate
            sp = buf;

            ww = (int)fl_width(buf); // Width of word in buf
            /* symbol font hack
            if (ww == 0) ww = (int)fl_width("&"); // pad control chars
            */
			  if (needspace && xx > block->x)
				  xx += 4;//(int)fl_width(" ");

            baseh = 0; // add baseh offset for text
            if (block->maxh > 0 && block->imgy - topline_ == yy)
              baseh = block->maxh - fsize;
            //if (block->liney) baseh += block->liney;

            /* symbol font hack
            tfont = font; // store font

            while (sp < buf + strlen(buf)) {
            // extended chars use &# markup to change the font

              tp = tbuf; // reset tp
              while (sp < buf + strlen(buf)) {
                if (*sp == '&' && *(sp + 1) == '#') {
                  *(tp ++) = (char)atoi(sp + 2); // convert str to int
                  sp = strchr(sp, ';') + 1; // skip past semi-colon char
                  font = FL_SYMBOL;
                  if (!(*sp == '&' && *(sp + 1) == '#'))
                    break; // draw tbuf in Symbol font
                }
                else {
                  *(tp ++) = *(sp ++);
                  font = tfont;
                  if (*sp == '&' && *(sp + 1) == '#')
                    break; // draw tbuf in current font
                }
              }
              *tp = '\0'; // Nul-terminate

              pushfont(font, fsize); // pushfont

              // width of word in tbuf, pad any zero-length control chars
              for (ti = 0, ww = 0; ti < strlen(tbuf); ti ++) {
                temp = (int)fl_width(tbuf[ti]);
                if (temp == 0) temp = (int)fl_width("&"); // pad
                ww += temp;
              }

              hv_draw(tbuf, xx + x() - leftline_, yy + y() + baseh);

              popfont(font, fsize); // popfont
              */
              hv_draw(buf, xx + x() - leftline_, yy + y() + baseh); // replaces hv_draw(tbuf..

              if (underline) { // Add width for uline spaces after word
                temp = (isspace((*ptr) & 255)) ? (int)fl_width(" ") : 0;
                fl_xyline(xx + x() - leftline_, yy + y() + 1 + baseh,
                          xx + x() - leftline_ + ww + temp);
              }

              xx += ww;
            /* symbol font hack
            }

            sp = buf; // Reset sp
            font = tfont; // restore font
            */
            current_pos = ptr - value_;
            if ((fsize + 2) > hh) hh = fsize + 2; // Set hh
            needspace = 0;

          }
          else if (!head && pre) // Draw pre text
          {
            // this code is buggy and conflicts with other stuff
            // don't think it's needed but leaving it just in case
         /* while (isspace((*ptr) & 255)) {
              if (*ptr == '\n') {
                *sp = '\0';
                sp = buf;
                hv_draw("|", xx + x() - leftline_, yy + y());
                if (underline)
                  fl_xyline(xx + x() - leftline_, yy + y() + 1,
                            xx + x() - leftline_ + (int)fl_width(buf));
                current_pos = ptr - value_;
                //if (line < 31) line ++;
                xx = block->line;
                yy += hh;
                hh = fsize + 2;
              }
              else if (*ptr == '\t') {
                ti = linew / (int)fl_width(" "); // number of chars
                temp = 8 - (ti & 7); // number of tabs
                for (ti = 0; ti < temp; ti ++) // pre tabs width fix
                  *(sp ++) = ' ';
              }
              else
                *(sp ++) = ' ';
              if ((fsize + 2) > hh) hh = fsize + 2;
              ptr ++;
            }
            if (sp > buf) { the code below was in here */

            *sp = '\0'; // Nul-terminate
            sp = buf;

            ww = (int)fl_width(buf);

//printf("b->x=%d b->w=%d xx=%d ww=%d linew=%d ptr=%c buf=%s\n",
//  block->x,block->w,xx,ww,linew,*ptr,buf);

            baseh = 0; // add baseh offset for pre text
            if (block->maxh > 0 && block->imgy - topline_ == yy)
              baseh = block->maxh - fsize;

            hv_draw(buf, xx + x() - leftline_, yy + y() + baseh);
            if (underline)
              fl_xyline(xx + x() - leftline_, yy + y() + 1 + baseh,
                        xx + x() - leftline_ + ww);

            xx += ww;
            linew += ww;
            current_pos = ptr - value_;
          // } // if (sp > buf)

            needspace = 0;
          }
          else
          {
            sp = buf;
            while (isspace((*ptr) & 255)) ptr ++;
            current_pos = ptr - value_;
          }

          brflag = 0;
        }
        
        if (*ptr == '<')
        {
          tagptr = ptr; // Start of tag
          ptr ++;

          if (!strncmp(ptr, "!--", 3)) { // Found "!--"
           ptr += 3;
           if ((ptr = strstr(ptr, "-->"))) { // Skip comment - rem'd != 0
             ptr += 3;
             continue;
           }
           else
             break;
          }

          while (*ptr && *ptr != '>' && !isspace((*ptr) & 255))
            if (sp < (buf + sizeof(buf) - 1))
              *(sp ++) = *(ptr ++); // added ()
            else
              ptr ++;

          *sp = '\0'; // Nul-terminate
          sp = buf;

          attrptr = ptr; // Start of attributes
          while (*ptr && *ptr != '>') ptr ++;
          if (*ptr == '>') ptr ++;

          // Set the supposed start of printed eord here
          current_pos = ptr - value_;

          btag = strlen(buf); // store strlen
          if (btag > 4) btag = 4; // limit
          for (ti = 0; ti < btag; ti ++) // abbreviate tag, to uppercase
            tag[ti] = toupper(buf[ti]);
          for (ti = btag; ti < 4; ti ++) // set chars after to nul
            tag[ti] = 0;
          if (buf[0] != '/' && btag > 3) tag[3] = 0; // eg. HTML=HTM
          btag = CMD(tag[0],tag[1],tag[2],tag[3]); // tag fourcc int

          // End of command reached
          if (btag == CMD('A',0,0,0)) // 'A'
          {
            if (get_attr(attrptr, "HREF", attr, sizeof(attr))) {
              fl_color(linkcolor_);
              underline = 1;
            }
          }
          else if (btag == CMD('/','A',0,0)) // '/A'
          {
            fl_color(textcolor_);
            underline = 0;
          }
          else if (btag == CMD('B',0,0,0) ||
                   btag == CMD('S','T','R',0)) // 'B' 'STRONG'
          {
            font = font_style(font, FL_BOLD);
            pushfont(font, fsize);
          }
          else if (btag == CMD('/','B',0,0) ||
                   btag == CMD('/','S','T','R')) // '/B' '/STRONG'
          {
            popfont(font, fsize);
          }
          else if (btag == CMD('B','L','O',0) ||
                   btag == CMD('D','L',0,0) ||
                   btag == CMD('U','L',0,0) ||
                   btag == CMD('O','L',0,0) ||
                   btag == CMD('D','D',0,0) ||
                   btag == CMD('D','T',0,0)) // 'BLOCKQUOTE' 'DL'OL'UL'
          {
          }
          else if (btag == CMD('/','B','L','O') ||
                   btag == CMD('/','D','L',0) ||
                   btag == CMD('/','O','L',0) ||
                   btag == CMD('/','U','L',0)) // '/BLOCKQUOTE' '/DL'/OL'/UL'
          {
          }
          else if (btag == CMD('B','O','D',0)) // 'BODY'
          {
            head = 0;
          }
          else if (btag == CMD('B','R',0,0)) // 'BR'
          {
          }
          else if (btag == CMD('C','E','N',0)) // 'CENTER'
          {
          }
          else if (btag == CMD('C','O','D',0) ||
                   btag == CMD('T','T',0,0)) // 'CODE' 'TT'
          {
            font = monofont_;
            pushfont(font, fsize);
          }
          else if (btag == CMD('/','C','O','D') ||
                   btag == CMD('/','T','T',0)) // '/CODE' '/TT'
          {
            popfont(font, fsize);
          }
          else if (btag == CMD('D','I','V',0)) // 'DIV'
          {
          }
          else if (btag == CMD('F','O','N',0)) // 'FONT'
          {
            if (get_attr(attrptr, "COLOR", attr, sizeof(attr)))
              fl_color(get_color(attr, textcolor_));

            if (get_attr(attrptr, "FACE", attr, sizeof(attr)))
              font = font_face(attr);

            //tempsize = fsize;
            if (get_attr(attrptr, "SIZE", attr, sizeof(attr))) {
              if (isdigit(attr[0])) // Absolute size
                fsize = (int)(fontsize_ * pow(1.2, atof(attr) - 3.0));
              else // Relative size
                fsize = (int)(fsize * pow(1.2, atof(attr) - 3.0));
            }

            pushfont(font, fsize);
            if (fsize + 2 > hh) hh = fsize + 2; // set hh
          }
          else if (btag == CMD('/','F','O','N')) // '/FONT'
          {
            fl_color(textcolor_);
            //tempsize = fsize;
            popfont(font, fsize);
            if (fsize + 2 > hh) hh = fsize + 2; // set hh
          }
          else if (tag[0] == 'H' && isdigit(tag[1])) // 'H1'
          {
            if (tag[1] < '7') { // ignore if > h6
              font = font_style(font, FL_BOLD);
              switch (tag[1]) { // header sizes
                case '1' : fsize = 24; break;
                case '2' : fsize = 18; break;
                case '3' : fsize = 16; break;
                case '4' : fsize = 14; break;
                case '5' : fsize = 12; break;
                case '6' : fsize = 10; break;
              }
              pushfont(font, fsize);
            }
          }
          else if (btag == CMD('/','H',tag[2],0) && isdigit(tag[2])) // '/H1'
          {
            if (tag[2] < '7') // ignore if > h6
              popfont(font, fsize);
          }
          else if (btag == CMD('H','E','A',0)) // 'HEAD'
          {
            head = 1;
          }
          else if (btag == CMD('/','H','E','A')) // '/HEAD'
          {
            head = 0;
          }
          else if (btag == CMD('H','R',0,0)) // 'HR'
          { // rem'd new line, added hr shadow
            tx = x() - leftline_; // hr x
            ty = yy + y() - fsize; // hr y
            fl_color(FL_BLACK);
            fl_line(block->x + tx, ty, block->w + tx, ty);
            fl_color(224, 224, 224); // light grey
            fl_line(block->x + tx, ty + 1, block->w + tx, ty + 1); // shadow
            fl_color(textcolor_); // reset

            hh = fsize + 2; // set hh
          }
          else if (btag == CMD('H','T','M',0)) // 'HTML'
          {
          }
          else if (btag == CMD('I',0,0,0) ||
                   btag == CMD('E','M',0,0)) // 'I' 'EM'
          {
            font = font_style(font, FL_ITALIC);
            pushfont(font, fsize);
          }
          else if (btag == CMD('/','I',0,0) ||
                   btag == CMD('/','E','M',0)) // '/I' '/EM'
          {
            popfont(font, fsize);
          }
          else if (btag == CMD('I','M','G',0)) // 'IMG'
          {
            imgw = imgh = 0; // reset
            if (get_attr(attrptr, "WIDTH", wattr, sizeof(wattr)))
              imgw = get_length(wattr);
            if (get_attr(attrptr, "HEIGHT", hattr, sizeof(hattr)))
              imgh = get_length(hattr);

            img = 0; // rem'd NULL
            if (get_attr(attrptr, "SRC", attr, sizeof(attr))) {
              img = get_image(attr, imgw, imgh);
              if (!imgw) imgw = img->w();
              if (!imgh) imgh = img->h();
            }

            if (!imgw || !imgh) {
              if (!get_attr(attrptr, "ALT", attr, sizeof(attr))) // rem'd == 0
                strcpy(attr, "IMG");
            }

            ww = imgw;
            if (needspace && xx > block->x)
              xx += (int)fl_width(" ");

            if (img) {
              baseh = block->maxh - imgh; // add baseh offset
              img->draw(xx + x() - leftline_,
                        yy + y() - fl_height() + fl_descent() + baseh); // rem'd + 2
              // Seb was here - freeing broken_image causes an XServer XFreePixmap crash
              if ((void*)img != &broken_image) img->release();
            }

            xx += ww;
            if (imgh + 2 > hh) hh = imgh + 2; // Set img hh
            needspace = 0;
            brflag = 0;
          }
          else if (btag == CMD('K','B','D',0)) // 'KBD'
          {
            font = font_style(monofont_, FL_BOLD);
            pushfont(font, fsize);
          }
          else if (btag == CMD('/','K','B','D')) // '/KBD'
          {
            popfont(font, fsize);
          }
          else if (btag == CMD('L','I',0,0)) // 'LI'
          {
            // rem'd hv_draw and symbol font stuff
            tx = xx - fsize + x() - leftline_; // bullet x
            ty = yy + y() - 6; // bullet y

            get_attr(attrptr, "TYPE", attr, sizeof(attr)); // bullet type
            if (!strncasecmp(attr, "disc", 4) ||
                !strncasecmp(attr, "disk", 4)) { // li > ul > ul nest
              fl_arc(tx, ty, 5, 5, 0, 360);
              fl_rectf(tx + 1, ty + 1, 3, 3);
            }
            else if (!strncasecmp(attr, "circle", 6))
              fl_arc(tx, ty, 5, 5, 0, 360);
            else if (!strncasecmp(attr, "square", 6))
              fl_rectf(tx, ty, 5, 5);
            else if (block->type == 1) { // disc/disk
              fl_arc(tx, ty, 5, 5, 0, 360);
              fl_rectf(tx + 1, ty + 1, 3, 3);
            }
            else if (block->type == 2) // circle
              fl_arc(tx, ty, 5, 5, 0, 360);
            else if (block->type >= 3) // square
              fl_rectf(tx, ty, 5, 5);
            else { // default
              fl_arc(tx, ty, 5, 5, 0, 360);
              fl_rectf(tx + 1, ty + 1, 3, 3);
            }
          }
          else if (btag == CMD('/','L','I',0)) // '/LI'
          {
          }
          else if (btag == CMD('N','O','S',0)) // 'NOSCRIPT'
          { // we don't support scripting so we won't skip this
          }
          else if (btag == CMD('P',0,0,0)) // 'P'
          {
          }
          else if (btag == CMD('P','R','E',0)) // 'PRE'
          {
            linew = 0;
            pre = 1;
            //font = monofont_;
            //fsize = fontsize_;
            //pushfont(font, fsize);
            
            tx = block->x - leftline_;
            ty = block->y - topline_ - fsize;
            tw = block->w - block->x - 2;
            th = block->h + fsize + (fsize / 4);

            if (tx < 0) {
              tw += tx;
              tx = 0;
            }
            if (ty < 0) {
              th += ty;
              ty = 0;
            }
            tx += x();
            ty += y();
            
           if (block->bgcolor != bgcolor_) {
              fl_color(block->bgcolor);
              fl_rectf(tx, ty, tw, th);
              fl_color(textcolor_);
            }
            if (block->border)
              fl_rect(tx, ty, tw, th);
              
          }
          else if (btag == CMD('/','P','R','E')) // '/PRE'
          {
            //popfont(font, fsize);
            pre = 0;
          }
          else if (btag == CMD('S','C','R',0)) // 'SCRIPT'
          {
            while (ptr) { // skip scripting
              ptr = strstr(ptr, "</");
              if (!strncasecmp(ptr, "</SCRIPT>", 9)) break;
            }

            if (ptr) { // found </script>
              ptr += 9;
              continue;
            }
            else // not found
              break;
          }
          else if (btag == CMD('T','A','B',0)) // 'TABLE'
          {
          }
          else if (btag == CMD('T','D',0,0) ||
                   btag == CMD('T','H',0,0)) // 'TD' 'TH'
          {
            /*if (btag == CMD('T','H',0,0))
              font = serifont_ | FL_BOLD;
            else
              font = serifont_;
            fsize = fontsize_;
            pushfont(font, fsize);*/

            fl_color(textcolor_); // fixes /a td bug
            underline = 0;

            tx = block->x - 4 - leftline_;
            ty = block->y - topline_ - fsize - 3;
            tw = block->w - block->x + 7;
            th = block->h + fsize - 5;

            if (tx < 0) {
              tw += tx;
              tx = 0;
            }
            if (ty < 0) {
              th += ty;
              ty = 0;
            }
            tx += x();
            ty += y();

            if (block->bgcolor != bgcolor_) {
              fl_color(block->bgcolor);
              fl_rectf(tx, ty, tw, th);
              fl_color(textcolor_);
            }
            if (block->border)
              fl_rect(tx, ty, tw, th);
              
          }
          else if (btag == CMD('/','T','D',0) ||
                   btag == CMD('/','T','H',0)) // '/TD' '/TH'
          {
            //popfont(font, fsize);
          }
          else if (btag == CMD('T','I','T',0)) // 'TITLE'
          {
            head = 1;
          }
          else if (btag == CMD('T','R',0,0)) // 'TR'
          {
          }
          else if (btag == CMD('U',0,0,0)) // 'U'
          {
            underline = 1;
          }
          else if (btag == CMD('/','U',0,0)) // '/U'
          {
            underline = 0;
          }
          else if (btag == CMD('V','A','R',0)) // 'VAR'
          {
            font = font_style(monofont_, FL_ITALIC);
            pushfont(font, fsize);
          }
          else if (btag == CMD('/','V','A','R')) // '/VAR'
          {
            popfont(font, fsize);
          }
          else if (btag == CMD('A','B','B',0) || // 'ABBR'
                   btag == CMD('A','C','R',0) || // 'ACRONYM'
                   btag == CMD('A','D','D',0) || // 'ADDRESS'
                   btag == CMD('A','P','P',0) || // 'APPLET'
                   btag == CMD('A','R','E',0) || // 'AREA'
                   btag == CMD('B','A','S',0) || // 'BASE' 'BASEFONT'
                   btag == CMD('B','D','O',0) || // 'BDO'
                   btag == CMD('B','G','S',0) || // 'BGSOUND'
                   btag == CMD('B','I','G',0) || // 'BIG'
                   btag == CMD('B','L','I',0) || // 'BLINK'
                   btag == CMD('B','U','T',0) || // 'BUTTON'
                   btag == CMD('C','A','P',0) || // 'CAPTION'
                   btag == CMD('C','I','T',0) || // 'CITE'
                   btag == CMD('C','O','L',0) || // 'COL' 'COLGROUP'
                   btag == CMD('D','E','L',0) || // 'DEL'
                   btag == CMD('D','F','N',0) || // 'DFN'
                   btag == CMD('D','I','R',0) || // 'DIR'
                   btag == CMD('E','M','B',0) || // 'EMBED'
                   btag == CMD('F','I','E',0) || // 'FIELDSET'
                   btag == CMD('F','O','R',0) || // 'FORM'
                   btag == CMD('F','R','A',0) || // 'FRAME' 'FRAMESET'
                   btag == CMD('I','F','R',0) || // 'IFRAME'
                   btag == CMD('I','N','P',0) || // 'INPUT'
                   btag == CMD('I','N','S',0) || // 'INS'
                   btag == CMD('I','S','I',0) || // 'ISINDEX'
                   btag == CMD('L','A','B',0) || // 'LABEL'
                   btag == CMD('L','E','G',0) || // 'LEGEND'
                   btag == CMD('L','I','N',0) || // 'LINK'
                   btag == CMD('M','A','P',0) || // 'MAP'
                   btag == CMD('M','A','R',0) || // 'MARQUEE'
                   btag == CMD('M','E','N',0) || // 'MENU'
                   btag == CMD('M','E','T',0) || // 'META'
                   btag == CMD('M','U','L',0) || // 'MULTICOL'
                   btag == CMD('N','O','B',0) || // 'NOBR'
                   btag == CMD('N','O','F',0) || // 'NOFRAMES'
                   btag == CMD('O','B','J',0) || // 'OBJECT'
                   btag == CMD('O','P','T',0) || // 'OPTGROUP' 'OPTION'
                   btag == CMD('P','A','R',0) || // 'PARAM'
                   btag == CMD('Q',0,0,0) || // 'Q'
                   btag == CMD('S',0,0,0) || // 'S'
                   btag == CMD('S','A','M',0) || // 'SAMP'
                   btag == CMD('S','E','L',0) || // 'SELECT'
                   btag == CMD('S','M','A',0) || // 'SMALL'
                   btag == CMD('S','P','A',0) || // 'SPACER' 'SPAN'
                   btag == CMD('S','T','R',0) || // 'STRIKE'
                   btag == CMD('S','T','Y',0) || // 'STYLE'
                   btag == CMD('S','U','B',0) || // 'SUB'
                   btag == CMD('S','U','P',0) || // 'SUP'
                   btag == CMD('T','B','O',0) || // 'TBODY'
                   btag == CMD('T','E','X',0) || // 'TEXTAREA'
                   btag == CMD('T','F','O',0) || // 'TFOOT'
                   btag == CMD('T','H','E',0) || // 'THEAD'
                   btag == CMD('W','B','R',0) || // 'WBR'
                   btag == CMD('X','M','P',0)) // 'XMP'
            ; // unsupported tags
          else if (tag[0] == '!' && isalpha(tag[1])) // '!DOCTYPE' etc
            ;
          else if (tag[0] == '?' && isalpha(tag[1])) // '?XMP' etc
            ;
          else if (tag[0] == '/' && isalpha(tag[1])) // unrecognized end tag
            ;
          else if (!head) // unrecognized tag so draw it
          {
            hv_draw("<", xx + x() - leftline_, yy + y()); // draw '<' char
            xx += (int)fl_width("<"); // add width of '<' char
            linew += (int)fl_width("<");
            ptr = tagptr + 1; // start of tag + 1
          }
          
        } // if (*ptr == '<')

        else if (*ptr == '\n' && pre) // '\n' char in pre
        {
          *sp = '\0'; // Nul-terminate
          sp = buf;

          hv_draw(buf, xx + x() - leftline_, yy + y());

          //hh = fsize + 2; // Set hh
          linew = 0;
          needspace = 0;
          ptr ++;
          current_pos = ptr - value_;
        }
        else if (isspace((*ptr) & 255)) // ' ' '\t'\n'\v'\f'\r' chars
        {

          if (pre) {
            if (*ptr == ' ')
              *(sp ++) = ' '; // added ()
            else if (*ptr == '\t') {
              ti = linew / (int)fl_width(" "); // number of chars, monospace
              temp = 8 - (ti & 7); // number of tabs 1..8
              for (ti = 0; ti < temp; ti ++) // pre tabs width fix
                *(sp ++) = ' '; // added ()
            }
          }

          ptr ++;
          if (!pre) current_pos = ptr - value_;
          needspace = 1; // Set need space flag
        }
        else if (*ptr == '&') // '&' char ref
        {
          ptr ++;
          qch = quote_char(ptr);
          /* symbol font hack
          temp = quote_char(ptr, 1); // check font char uses
          */
          if (qch < 0) // Not char ref
            *(sp ++) = '&';
          /* symbol font hack
          else if (temp == 0) { // current font
          */
          else { // replaces else if (temp == 0)
            *(sp ++) = qch; // added ()
            ptr = strchr(ptr, ';') + 1; // skip past semi-colon char
          }
          /* symbol font hack
          else if (temp == 1) { // symbol font
            temp = sprintf(wattr, "&#%d", qch); // convert int to str
            for (ti = 0; ti < temp; ti ++)
              *(sp ++) = wattr[ti]; // set extended char &# markup
            ptr = strchr(ptr, ';'); // skip to semi-colon char
          }
          else
            *(sp ++) = '&';
          */
          if ((fsize + 2) > hh) hh = fsize + 2; // Set hh
        }
        else
        {
          *(sp ++) = *(ptr ++); // added ()
          if ((fsize + 2) > hh) hh = fsize + 2; // Set hh
        }
      } // for (ptr = block->start ...)

      *sp = '\0'; // Nul-terminate

      if (sp > buf) // Still something left to parse
      {
        ww = (int)fl_width(buf); // Width of word

        if (!head && !pre) { // Normal text
          if (needspace && xx > block->x)
            xx += (int)fl_width(" ");
        }

        if (!head) { // Draw text
          baseh = 0; // add baseh offset for missed text
          if (block->maxh > 0 && block->imgy - topline_ == yy)
            baseh = block->maxh - fsize;
          //if (block->liney) baseh += block->liney;

          hv_draw(buf, xx + x() - leftline_, yy + y() + baseh);

          if (underline)
            fl_xyline(xx + x() - leftline_, yy + y() + 1 + baseh,
                      xx + x() - leftline_ + ww);

          current_pos = ptr - value_;
        }
      }

    } // for (bi = 0 ...)

  fl_pop_clip();

} // Fl_Help_View::draw()

//
// Fl_Help_View::end_selection() - End text selection.
//

void Fl_Help_View::end_selection(int cb) // I - Set clipboard, opt
{
  if (!selected || current_view != this) return;

  // Convert the select part of our html text into some kind of
  // somewhat readable ASCII and store it in the selection buffer
  char spacec = 0, pre = 0, tempc = 0, endc = 0;
  int len = strlen(value_),
    in = 0, xx = 0;
  char *text = (char*)malloc(len + 1),
    *dp = text;
  const char *sp = value_,
    *cmdp,
    *srcp;

  while (true) // was for (;;)
  {
    tempc = *(sp ++); // added ()
    if (tempc == 0) break;
    if (tempc == '<') { // Begin of some html command. Skip until we find a '>'
      cmdp = sp;
      while (true) { // was for (;;)
        tempc = *(sp ++); // added ()
        if (tempc == 0 || tempc == '>') break;
      }
      if (tempc == 0) break;
      // Do something with this command, the replacement string must
      // not be longer that the command itself plus '<' and '>'
      srcp = 0; // rem'd NULL
      switch (command(cmdp)) {
        case CMD('p','r','e', 0 ): pre = 1; break;
        case CMD('/','p','r','e'): pre = 0; break;
        case CMD('t','d', 0 , 0 ):
        case CMD('p', 0 , 0 , 0 ):
        case CMD('/','p', 0 , 0 ):
        case CMD('b','r', 0 , 0 ): srcp = "\n"; break;
        case CMD('l','i', 0 , 0 ): srcp = "\n * "; break;
        case CMD('/','h','1', 0 ):
        case CMD('/','h','2', 0 ):
        case CMD('/','h','3', 0 ):
        case CMD('/','h','4', 0 ):
        case CMD('/','h','5', 0 ):
        case CMD('/','h','6', 0 ): srcp = "\n\n"; break;
        case CMD('t','r', 0 , 0 ):
        case CMD('h','1', 0 , 0 ):
        case CMD('h','2', 0 , 0 ):
        case CMD('h','3', 0 , 0 ):
        case CMD('h','4', 0 , 0 ):
        case CMD('h','5', 0 , 0 ):
        case CMD('h','6', 0 , 0 ): srcp = "\n\n"; break;
        case CMD('d','t', 0 , 0 ): srcp = "\n "; break;
        case CMD('d','d', 0 , 0 ): srcp = "\n - "; break;
      }
      in = sp - value_;
      if (srcp && in > selection_first && in <= selection_last) {
        while (*srcp)
          *(dp ++) = *(srcp ++); // added ()
        tempc = srcp[-1];
        spacec = (isspace(tempc & 255)) ? ' ' : tempc;
      }
      continue;
    }

    if (tempc == '&') { // Special characters
      xx = quote_char(sp);

      if (xx >= 0) {
        tempc = (char)xx;
        while (true) { // was for (;;)
          endc = *(sp ++); // added ()
          if (!endc || endc == ';') break;
        }
      }
    }

    in = sp - value_;
    if (in > selection_first && in <= selection_last) {
      if (!pre && isspace(tempc & 255)) tempc = ' ';
      if (spacec != ' ' || tempc != ' ')
        *(dp ++) = tempc; // added ()
      spacec = tempc;
    }
  }

  *dp = 0;
  Fl::copy(text, strlen(text), cb);
  free(text);

} // Fl_Help_View::end_selection()

//
// Fl_Help_View::extend_selection() - Extend current text selection.
//

char // O - True if text selection changed
Fl_Help_View::extend_selection()
{
  if (Fl::event_is_click()) return 0;

//printf("old selection_first=%d, selection_last=%d\n",
//  selection_first, selection_last);

  int sf = selection_first,
    sl = selection_last;

  selected = 1;
  mouse_x = Fl::event_x();
  mouse_y = Fl::event_y();
  draw_mode = 2; // End selection mode

  fl_begin_offscreen(fl_help_view_buffer);
  draw();
  fl_end_offscreen();

  draw_mode = 0;

  if (selection_push_first < selection_drag_first) {
    selection_first = selection_push_first;
  }
  else {
    selection_first = selection_drag_first;
  }

  if (selection_push_last > selection_drag_last) {
    selection_last = selection_push_last;
  }
  else {
    selection_last = selection_drag_last;
  }

//printf("new selection_first=%d, selection_last=%d\n",
//  selection_first, selection_last);

  if (sf != selection_first || sl != selection_last) { // was ! =
//  puts("REDRAW!!!\n");
    return 1;
  }
  else {
//  puts("");
    return 0;
  }

} // Fl_Help_View::extend_selection()

//
// Fl_Help_View::fileislink() - Was link clicked or nav button?
//

int Fl_Help_View::fileislink() // O - Link clicked
{
  return d->islink;
}

//
// Fl_Help_View::filepath() - Set value file path string.
//

void Fl_Help_View::filepath(const char *fp) // I - Current file path
{
  if (!fp) return; // null
  d->ispath = 1; // path is used

  if (!d->islink) // nav button
    strlcpy(d->lpath, d->path, sizeof(d->lpath)); // set last path
  strlcpy(d->path, fp, sizeof(d->path)); // set path
}

//
// Fl_Help_View::filepath() - Get value file path string.
//

char *Fl_Help_View::filepath() // O - Current file path
{
  return d->path;
}

//
// Fl_Help_View::find() - Find the specified string.
//

int // O - Matching position or -1 if not found
Fl_Help_View::find(const char *sp, // I - String to find
                   int pos) // I - Starting position, opt
{
  int ti = 0, // Temp looping var
    cref = 0; // Current char ref
  Fl_Help_Block *block; // Current block
  const char *bptr, // Block matching pointer
    *cptr, // Start of current comparison pointer
    *sptr; // Search string pointer

  // Range check input and value
  if (!sp || !value_) return -1;

  if (pos < 0 || pos >= (int)strlen(value_))
    pos = 0;
  else if (pos > 0)
    pos ++;

  // Look for the string
  for (ti = nblocks_, block = blocks_; ti > 0; ti --, block ++)
  {
    if (block->end < (value_ + pos))
      continue;

    if (block->start < (value_ + pos))
      bptr = value_ + pos;
    else
      bptr = block->start;

    for (sptr = sp, cptr = bptr; *sptr && *bptr && bptr < block->end; bptr ++)
    {
      if (*bptr == '<') { // Skip to end of element
        while (*bptr && bptr < block->end && *bptr != '>')
          bptr ++;
        continue;
      }
      else if (*bptr == '&') { // Decode HTML entity
        cref = quote_char(bptr + 1);

        if (cref < 0) // Not char ref
          cref = '&';
        else
          bptr = strchr(bptr + 1, ';') + 1;
      }
      else
        cref = *bptr;

      if (tolower(*sptr) == tolower(cref))
        sptr ++;
      else { // No match, so reset to start of search
        sptr = sp;
        cptr ++;
        bptr = cptr;
      }
    } // for (sptr = sp ...)

    if (!*sptr) { // Found a match!
      topline(block->y - block->h);
      return (block->end - value_);
    }
  } // for (ti = nblocks_ ...)

  return -1; // No match!

} // Fl_Help_View::find()

//
// Fl_Help_View::find_link() - Find the link at the given position.
//

Fl_Help_Link * // O - Link pointer
Fl_Help_View::find_link(int xx, // I - X position
                        int yy) // I - Y position
{
  int ti = 0;
  Fl_Help_Link *linkp;

  for (ti = nlinks_, linkp = links_; ti > 0; ti --, linkp ++) {
    if (xx >= linkp->x && xx < linkp->w &&
        yy >= linkp->y && yy < linkp->h)
      break;
  }
  return (ti) ? linkp : 0; // Was link found? - rem'd NULL

} // Fl_Help_View::find_link()

//
// Fl_Help_View::follow_link() - Follow the specified link.
//

void Fl_Help_View::follow_link(Fl_Help_Link *lp) // I - Link pointer
{
  char target[32], // Current target
    dir[1024], // Current directory
    temp[1024], // Temporary filename
    *tptr, *sptr, *dirp; // Pointer into temporary filename
  const char *namep = lp->filename; // link filename

  strlcpy(target, lp->name, sizeof(target));
  clear_selection(); // Clear text selection
  set_changed(); // Set widget value was changed

//printf(" follow_link namep=(%s)\n",namep);
//printf(" follow_link filename_=(%s)\n",filename_);

  if (namep[0] && strcmp(namep, filename_)) // Link not same as filename_
  {
    if (strchr(directory_, ':') && !strchr(namep, ':')) // rem'd != 0 and == 0
    { // dir is absolute, lp is relative
      if (namep[0] == '/') { // lp is absolute
        strlcpy(temp, directory_, sizeof(temp));
        if ((tptr = strrchr(strchr(directory_, ':') + 3, '/')) != 0) // ? - get filename
          strlcpy(tptr, namep, sizeof(temp)-(tptr - temp)); // ? - add filename
        else // ? - dir should never have a filename so why check?
          strlcat(temp, namep, sizeof(temp));
      }
      else // lp just filename
        snprintf(temp, sizeof(temp), "%s/%s", directory_, namep);
    }
    else if (namep[0] != '/' && !strchr(namep, ':')) // rem'd == 0
    { // Relative path
      if (directory_[0]) // Add filename
        snprintf(temp, sizeof(temp), "%s/%s", directory_, namep);
      else {
        dirp = getcwd(dir, sizeof(dir)); // ? - try cwd, may be wrong..
        snprintf(temp, sizeof(temp), "%s/%s", dir, namep); // ?
      }
    }
    else // Use lp
      strlcpy(temp, namep, sizeof(temp));

    if (d->ispath) { // path is used
      strlcpy(temp, d->path, sizeof(temp)); // ?
      if (namep[0] == '/' || namep[1] == ':' || // absolute or remote
          !strncmp(namep, "ftp:", 4) || !strncmp(namep, "http:", 5) ||
          !strncmp(namep, "https:", 6) || !strncmp(namep, "ipp:", 4) ||
          !strncmp(namep, "mailto:", 7) || !strncmp(namep, "news:", 5))
        strlcpy(temp, namep, sizeof(temp));
      else if (!strncasecmp(namep, "javascript:history", 18)) {
        strlcpy(temp, namep, sizeof(temp));
        if (!(d->nstyle & HV_NONAVIGATE)) { // user navigation
          strlcpy(temp, d->lpath, sizeof(temp)); // use last path
          if (!d->lpath[0]) // last path empty
            strlcpy(temp, d->path, sizeof(temp)); // use path
          d->isnav = 1; // set is nav link
        }
      }
      else if ((tptr = strrchr(temp, '/'))) // relative path, add filename
          strlcpy(tptr + 1, namep, sizeof(temp)-(tptr + 1 - temp));
    }

    if (target[0]) { // Add target
      strlcat(temp, "#", sizeof(temp)); // was snprintf(temp + strlen..
      strlcat(temp, target, sizeof(temp));
    }

    while ((tptr = strstr(temp, "/.."))) { // remove ../ from path
      for (sptr = tptr - 1; sptr > temp; sptr --)
        if (*sptr == '/') break; // seek back to last dir
      if (sptr == temp) break; // nothing to remove
      *sptr = '\0'; // nul-terminate
      strlcat(temp, tptr + 3, sizeof(temp)); // add rest of path
    }
    while ((tptr = strstr(temp, "/./"))) { // remove ./ from path
      *tptr = '\0';
      strlcat(temp, tptr + 2, sizeof(temp));
    }

    if (d->ispath) { // path is used
      if (!strncasecmp(temp, "javascript:history", 18)) { // store js
        strlcpy(d->lpath, d->path, sizeof(d->lpath)); // last path
        strlcpy(d->path, temp, sizeof(d->path)); // link for history
      }
      else if ((tptr = strrchr(temp, '/'))) { // store valid ext
        if (strstr(tptr, ".htm") || strstr(tptr, ".txt")) {
          strlcpy(d->lpath, d->path, sizeof(d->lpath)); // last path
          strlcpy(d->path, temp, sizeof(d->path)); // link for history
        }
      }
    }

//printf(" follow_link d->path=(%s)\n",d->path);
//printf(" follow_link temp=(%s)\n",temp);

    load(temp); // Load filename
  }
  else if (target[0]) // Target in link
  {
    if (d->ispath) { // path is used
      if ((tptr = strrchr(d->path, '#'))) *tptr = '\0'; // remove target
      strlcat(d->path, "#", sizeof(d->path));
      strlcat(d->path, target, sizeof(d->path));
      load(d->path); // load target for history
    }
    //topline(target); // rem'd
  }
  //else topline(0); leftline(0); // rem'd

/*printf("\nFl_Help_Target\n");
printf(" targets=%s\n",d->targets->filename);
printf(" linkp=%s\n",d->linkp->filename);
printf(" ispush=%d\n",d->ispush);
printf(" islink=%d\n",d->islink);
printf(" resized=%d\n",d->resized);
printf(" ispath=%d\n",d->ispath);
printf(" nstyle=%d\n",d->nstyle);
printf(" top=%d\n",d->top);
printf(" ltop=%d\n",d->ltop);
printf(" isnav=%d\n",d->isnav);
printf(" rwidth=%d\n",d->rwidth);
printf(" rtime=%d\n",d->rtime);
printf(" rsec=%d\n",d->rsec);
printf(" rmil=%d\n",d->rmil);
printf(" path=%s\n",d->path);
printf(" lpath=%s\n",d->lpath);*/

} // Fl_Help_View::follow_link()

//
// Fl_Help_View::font_face() - Get a font face from a list of names.
//

// Usage: parses a comma-separated string of font names in order of
// preference and returns the font face.

int // O - font face or base font list index
Fl_Help_View::font_face(const char *sp) // I - name of font to find
{
  char buf[100], namebuf[100]; // buffers
  const char *listp, *namep; // pointers
  int ti = 0, tj = 0, tk = 0, // temp loop vars
    tnum = 0, lnum = 0, fnum = 0, // temp/last/font counters
    nfonts = 0, nfaces = 0, // numbers
    temp = 0, slen = 0, dfont = 0; // misc
  unsigned char flen[10]; // font name lengths

  slen = strlen(sp); // string length
  if (!slen) return 0; // sp not valid
  if (slen > 255) slen = 255; // set max length

  for (ti = 0, listp = sp, nfaces = 0; ti < slen; ti ++, listp ++) {
    if (ti == slen - 1 || *listp == ',') { // end or ',' char
      if (nfaces < 8 && *(listp + 1) != ',') { // skip ",,"
        flen[nfaces] = ti; // store positions
        if (ti == slen - 1) flen[nfaces] = ti + 1;
        nfaces ++; // count faces
      }
    }
  }

  for (ti = nfaces - 1; ti > 0; ti --) { // calc string lengths
    temp = flen[ti] - flen[ti - 1] - 1;
    flen[ti] = temp;
  }

  nfonts = Fl::set_fonts(0); // get ISO8859-1 fonts, ignore rest

  for (ti = 0, listp = sp; ti < nfaces; ti ++) // main loop
  {
    while (*listp == ',') listp ++; // skip ',' chars
    if (flen[ti] > sizeof(buf)-1) flen[ti] = sizeof(buf)-1; // max buffer size

	  for (tj = 0, tk = 0; tj < flen[ti]; tj ++) { // remove spaces in font names
		  if (isspace(listp[tj])) continue;
		  else if (listp[tj] == '-') break;
		  buf[tk] = tolower(listp[tj]); // copy char to lowercase
		  tk ++;
    }
    buf[tj] = '\0'; // nul-terminate
	  
    fnum = (uchar)*buf - 97; // first letter index, a = 0
    if (fnum < 0 || fnum > 25) continue; // not a..z, assume font starts with letter
    tnum = flet_[fnum]; // current face index, loop start
    for (tj = fnum + 1; tj < 27; tj ++) {
      if (flet_[tj] > 0) {
        lnum = flet_[tj]; break; // last face index, loop end
      }
    }

    slen = strlen(buf); // first word length
    for (tj = tnum; tj < lnum; tj ++) { // find current font
      fnum = face_[tj][0]; // base font index
      namep = Fl::get_font_name((Fl_Font)fnum, &temp); // fltk font name
		for (tk = 0, temp = 0; namep[tk] != '\0'; tk ++) { // remove spaces in font name
			if (isspace(namep[tk])) continue;
			else if (namep[tk] == '-') break;
			namebuf[temp] = tolower(namep[tk]); // copy chars to lowercase
			temp ++;
		}
      namebuf[tk] = '\0'; // nul-terminate
		if (!strncmp(namebuf, buf, slen)) // found name
			return fnum;
    }
	
    if (!dfont) { // check default fonts
      if (!strncmp(buf, "courier", 7)) dfont = monofont_;
      if (!strncmp(buf, "times", 5)) dfont = serifont_;
      if (!strncmp(buf, "helvetica", 9)) dfont = sansfont_;
    }
  }
	return dfont;

} // Fl_Help_View::font_face()

//
// Fl_Help_View::font_style() - Get a font style from a font list index.
//

// Usage: the font style argument takes the values:
// medium as 0, bold as 1, italic as 2, plus as 3.

int // O - font list index
Fl_Help_View::font_style(int fi, // I - font list index
                         unsigned char fs) // I - font style 0..3
{
  int ti = 0; // temp loop var

  if (fs > 3 || fi >= (int)sizeof(fref_)) return 0; // avoid crash
  for (ti = 0; ti <= 3; ti ++) // find style
    if (fi == face_[fref_[fi]][ti]) break;
  ti |= fs; // combine bits
  return face_[fref_[fi]][ti];

} // Fl_Help_View::font_style()

//
// Fl_Help_View::format() - Format the help text.
//

void Fl_Help_View::format()
{
  char *sp, // Pointer into buffer
    *tp, // temp char pointer
    *ap, // attribute pointer
    buf[1024], // Text buffer
    attr[1024], // Attribute buffer
    wattr[1024], // Width attribute buffer
    hattr[1024], // Height attribute buffer
    linkdest[1024], // Link destination
    tcss[1024], // temp css
    tchar[1024], // temp char buffer
    csstag[255], // css tag buffer
    tag[4]; // tag/element 4-char buf
  const char *ptr, // Pointer into block
    *attrptr, // Start of attributes ptr
    *tagptr; // Start of tag/element ptr
  int ti = 0, tj = 0, // Temp loop var
    done = 0, // Are we done yet?
    row = 0, // Current table row (block number)
    talign = 0, // Current alignment
    newalign = 0, // New alignment
    head = 0, // Head/body section flag
    needspace = 0, // Do we need whitespace?
    table_width = 0, // Width of table
    table_offset = 0, // Offset of table
    column = 0, // Current table column number
    line = 0, // Current line in block
    links = 0, // Links for current line
    trpop = 0, // tr popped flag
    pflag = 0, // p flag
    brflag = 0, // br flag
    liflag = 0, // li flag
    listnest = 0, // list nest
    tdline = 0, // td line
    colspan = 0, // COLSPAN attribute
    qch = 0, // Quote char
    dx = 0, dy = 0, // Boxtype position offsets
    dw = 0, dh = 0, // Boxtype sizes
    ss = 0, // Scrollbar size
    temph = 0, tempw = 0, // Temp scrollbar sizes
    tempx = 0, tempy = 0, // temp positions
    linew = 0, // current line width
    imgw = 0, // Image width
    imgh = 0, // Image height
    hwidth = 0, // horizontal window width
    ulnest = 0, // ul nest type
    ntables = 0, // number of nested tables
    fonty = 0;
  int columns[HV_64], // Column widths
    cells[HV_64], // Cells in the current row
    tcolumns[HV_64][HV_16], // nested table column widths
    tcells[HV_64][HV_16], // nested table cell blocks
    rowdata[3][HV_16], // row data - row,column,block
    tfonts[HV_16 + 1], // table fonts - d->nfonts
    ultype[HV_16]; // ul type array, 10 nesting levels should do
  unsigned char thsize, tfsize; // font sizes
  fl_margins margins; // Left margin stack
  Fl_Help_Block *block, // Current block
    *cell, // Current table cell
    b, // current block object
    *tempb = 0; // temp block
    //*cssb = 0; // current css block - not used
  Fl_Color tclr, rclr, // Table/row background color
    tbclr[2][HV_16]; // nested table/tr bgcolor
  Fl_Boxtype bt = (box()) ? box() : FL_DOWN_BOX; // Box to draw
  Fl_Shared_Image *img = 0; // Shared image - rem'd NULL

  // zero arrays
  memset(columns, 0, sizeof(columns));
  memset(cells, 0, sizeof(cells));
  memset(rowdata, 0, sizeof(rowdata));
  memset(tcolumns, 0, sizeof(tcolumns));
  memset(tcells, 0, sizeof(tcells));
  memset(tfonts, 0, sizeof(tfonts));
  memset(ultype, 0, sizeof(ultype));
  memset(tbclr, 0, sizeof(tbclr));

  // Reset document width
  ss = Fl::scrollbar_size();
  hsize_ = w() - ss - Fl::box_dw(bt);
  hwidth = hsize_; // used in add_block instead of hsize_

//printf("\n FORMAT\n%s",value_);

  done = 0;
  while (!done)
  {
  
    // Reset state variables
    done = 1;
    nblocks_ = 0;
    nlinks_ = 0;
    ntargets_ = 0;
    size_ = 0;
    bgcolor_ = color();
    textcolor_ = textcolor();
    linkcolor_ = fl_contrast(FL_BLUE, color());
    tclr = rclr = bgcolor_;
    for (ti = 0; ti < HV_16; ti ++)
      tbclr[0][ti] = tbclr[1][ti] = bgcolor_;
    strcpy(title_, "Untitled");

    if (!value_) return;

    // Setup for formatting
    initfont(b.font, b.fsize);
    line = 0;
    links = 0;
    column = 0;
    b.x = margins.clear();
    b.y = b.fsize + 2;
    b.w = 0;
    b.h = 0;
    b.border = 0;
    b.pre = 0;
    b.tag = 0;
    b.bgcolor = bgcolor_;
    block = add_block(b, value_, hwidth);
    row = 0;
    head = 0;
    talign = LEFT;
    newalign = LEFT;
    needspace = 0;
    linkdest[0] = '\0';
    table_offset = 0;
    trpop = 0;
    pflag = 1;
    brflag = 0;
    liflag = 0;
    listnest = 0;
    ulnest = 0;
    thsize = 0;
    tfsize = 0;
    ntables = -1;
    tdline = 0;
    linew = 0;

    for (ptr = value_, sp = buf; *ptr; ) // Parse from value_
    {
      if ((*ptr == '<' || isspace((*ptr) & 255)) && sp > buf)
      {
        *sp = '\0'; // Nul-terminate
        b.w = (int)fl_width(buf); // Get width

        if (!head && !b.pre) // Normal text
        {
          if (b.w > hsize_) { // Reformat
            hsize_ = b.w;
            done = 0; // rem'd break; in all reformat checks, not needed
          }

          if (needspace && b.x > block->x)
            b.w += (int)fl_width(" ");

          // no new line if word too long and no word before it
          if (!(b.x < 7 && b.w > block->w) && (b.x + b.w > block->w)) {
            block->end = ptr - strlen(buf); // end line on last word
            line = do_align(block, 0, b.x, newalign, links);
            b.x = block->x;
            block->h += b.h;
            b.y += b.h; //b.y = block->y + block->h;
            b.h = 0;
            line = 0;
            block = add_block(b, ptr - strlen(buf), (row) ? block->w : hwidth);
          }

          if (linkdest[0])
            add_link(linkdest, b.x, b.y - b.fsize, b.w, b.fsize);

          b.x += b.w;
          if (b.fsize + 2 > b.h) b.h = b.fsize + 2; // Set b.h
          needspace = 0;
        }
        else if (!head && b.pre) // Pre text
        {
          if (linkdest[0]) // Add a link as needed
            add_link(linkdest, b.x, b.y - b.h, b.w, b.h);
            
          b.x += b.w;
          linew += b.w;
          if (b.fsize + 2 > b.h) b.h = b.fsize + 2; // Set b.h
          
          while (isspace((*ptr) & 255)) // ' ' '\t'\n'\v'\f'\r' chars
          {
            if (*ptr == '\n') { // '\n' char
              if (b.x > hsize_) break;
              
              block->end = ptr;
              line = do_align(block, 0, b.x, newalign, links);
              b.x = block->x;
              block->h += b.h;
              b.y += b.h; //b.y = block->y + block->h;
              b.h = 0;
              line = 0;
              linew = 0;
              block = add_block(b, ptr, (row) ? block->w : hwidth);
              //b.h = b.fsize + 2; // Set b.h
            }
            else if (*ptr == '\t') {
              ti = linew / (int)fl_width(" "); // number of chars, monospace
              tempw = 8 - (ti & 7); // number of tabs 1..8
              b.x += tempw * (int)fl_width(" "); // pre tabs width fix
              linew += tempw * (int)fl_width(" ");
            }
            else {
              b.x += (int)fl_width(" ");
              linew += (int)fl_width(" ");
            }

            if (b.fsize + 2 > b.h) b.h = b.fsize + 2; // Set b.h
            ptr ++;
          }

          if (b.x > hsize_) { // Reformat
            hsize_ = b.x + 4;
            done = 0;
          }

          needspace = 0;
        }
        else // Handle normal text or stuff in the <HEAD> section
        {
          while (isspace((*ptr) & 255)) ptr ++;
        }

//printf("b->line=%d b.x=%d b.w=%d b->x=%d b->w=%d b->y=%d b->h=%d b.y=%d b.h=%d buf=%s\n",
//  block->line, b.x, b.w, block->x, block->w, block->y, block->h, b.y, b.h, buf);

        pflag = 0; // reset flags
        brflag = 0;
        sp = buf;
      }

      if (*ptr == '<')
      {
        tagptr = ptr; // Start of tag
        ptr ++;

        if (!strncmp(ptr, "!--", 3)) { // Found "!--"
          ptr += 3;
          if ((ptr = strstr(ptr, "-->"))) { // Skip comment - rem'd != 0
            ptr += 3;
            continue;
          }
          else
            break;
        }

        while (*ptr && *ptr != '>' && !isspace((*ptr) & 255))
          if (sp < (buf + sizeof(buf) - 1))
            *(sp ++) = *(ptr ++); // added ()
          else
            ptr ++;

        *sp = '\0'; // Nul-terminate
        sp = buf;

//  puts(buf);

        attrptr = ptr; // Start of attributes
        while (*ptr && *ptr != '>') ptr ++;
        if (*ptr == '>') ptr ++;
        
        b.tag = strlen(buf); // store strlen
        for (ti = 0; ti < b.tag; ti ++) // set css class tag
          csstag[ti] = buf[ti];
        csstag[ti] = '\0'; // nul-terminate
        if (get_attr(attrptr, "CLASS", tchar, sizeof(tchar))) {
          strlcat(csstag, ".", sizeof(csstag));
          strlcat(csstag, tchar, sizeof(csstag));
        }
        
        if (b.tag > 4) b.tag = 4; // limit
        for (ti = 0; ti < b.tag; ti ++) // set abbreviate tag, uppercase
          tag[ti] = toupper(buf[ti]);
        for (ti = b.tag; ti < 4; ti ++) // set chars after to nul
          tag[ti] = 0;
        if (buf[0] != '/' && b.tag > 3) tag[3] = 0; // eg. HTML=HTM
        b.tag = CMD(tag[0],tag[1],tag[2],tag[3]); // tag fourcc int

//printf("buf=%s len=%d tag=%c%c%c%c, \n",
//  buf,strlen(buf),tag[0],tag[1],tag[2],tag[3]);

        // End of command reached
        if (b.tag == CMD('A',0,0,0)) // 'A'
        {
          if (get_attr(attrptr, "NAME", attr, sizeof(attr)))
            add_target(attr, b.y - b.fsize - 2);

          if (get_attr(attrptr, "HREF", attr, sizeof(attr)))
            strlcpy(linkdest, attr, sizeof(linkdest));
        }
        else if (b.tag == CMD('/','A',0,0)) // '/A'
        {
          linkdest[0] = '\0';
        }
        else if (b.tag == CMD('B',0,0,0) ||
                 b.tag == CMD('S','T','R',0)) // 'B' 'STRONG'
        {
          b.font = font_style(b.font, FL_BOLD);
          pushfont(b.font, b.fsize);
        }
        else if (b.tag == CMD('/','B',0,0) ||
                 b.tag == CMD('/','S','T','R')) // '/B' '/STRONG'
        {
          popfont(b.font, b.fsize);
        }
        else if (b.tag == CMD('B','L','O',0) ||
                 b.tag == CMD('D','L',0,0) ||
                 b.tag == CMD('U','L',0,0) ||
                 b.tag == CMD('O','L',0,0) ||
                 b.tag == CMD('D','D',0,0) ||
                 b.tag == CMD('D','T',0,0)) // 'BLOCKQUOTE' 'DL'OL'UL'
        {
// todo: dd and dt need their own section, similar to li
          block->end = tagptr;
          line = do_align(block, line, b.x, newalign, links);
          b.x = block->x;
          if (liflag) { b.x = margins.pop(); liflag = 0; } // pop li
          block->h += b.h;
          b.y = block->y + block->h;
          newalign = LEFT;

          if (b.tag == CMD('U','L',0,0)) { // ul
            ulnest ++; // inc ul nest type
            if (ulnest < 10) {
              get_attr(attrptr, "TYPE", attr, sizeof(attr)); // bullet types
              if (!strncasecmp(attr, "disc", 4) ||
                  !strncasecmp(attr, "disk", 4))
                ultype[ulnest] = 1;
              else if (!strncasecmp(attr, "circle", 6))
                ultype[ulnest] = 2;
              else if (!strncasecmp(attr, "square", 6))
                ultype[ulnest] = 3;
            }
          }

          if (b.tag == CMD('B','L','O',0) ||
              b.tag == CMD('D','L',0,0) ||
              b.tag == CMD('O','L',0,0) ||
              b.tag == CMD('U','L',0,0)) { // blockquote, dl, ol, ul
            b.x = margins.push(40); // changed 4 * b.fsize
            if (!pflag && !listnest) {
              b.y += fontsize_ + 2; block->h += fontsize_ + 2; pflag = 1;
            }
            listnest ++; // inc list nest
          }

          block = add_block(b, tagptr, (row) ? block->w : hwidth);
          b.h = 0;
          needspace = 0;
          line = 0;
          newalign = get_align(attrptr, talign);
        }
        else if (b.tag == CMD('/','B','L','O') ||
                 b.tag == CMD('/','D','L',0) ||
                 b.tag == CMD('/','O','L',0) ||
                 b.tag == CMD('/','U','L',0)) // '/BLOCKQUOTE' '/DL'/OL'/UL'
        {
          line = do_align(block, line, b.x, newalign, links);
          block->end = ptr;
          b.x = block->x;
          if (liflag) { b.x = margins.pop(); liflag = 0; } // pop li
          block->h += b.h;
          b.y += b.h;

          if (b.tag == CMD('/','U','L',0)) { // /ul
            if (ulnest < 9) ultype[ulnest] = 0; // reset ul type
            if (ulnest > 0) ulnest --; // dec ul nest type
          }

          if (listnest > 0) listnest --; // dec list nest
          if (!pflag && !listnest) {
            b.y += fontsize_ + 2; block->h += fontsize_ + 2; pflag = 1;
          }
          b.x = margins.pop();

          while (isspace((*ptr) & 255)) ptr ++;
          block = add_block(b, ptr, (row) ? block->w : hwidth);
          b.h = 0;
          needspace = 0;
          line = 0;
          newalign = talign;
        }
        else if (b.tag == CMD('B','O','D',0)) // 'BODY'
        {
          if (get_attr(attrptr, "BGCOLOR", attr, sizeof(attr)))
            b.bgcolor = bgcolor_ = get_color(attr, color());

          if (get_attr(attrptr, "TEXT", attr, sizeof(attr)))
            textcolor_ = get_color(attr, textcolor());

          if (get_attr(attrptr, "LINK", attr, sizeof(attr)))
            linkcolor_ = get_color(attr, fl_contrast(FL_BLUE, color()));
            
          parse_css(b, csstag, tchar);
          if (b.fsize < fontsize_) b.fsize = fontsize_; // force min size
          pushfont(b.font, b.fsize);
          serifont_ = b.font; // body overrides default font but not size
        }
        else if (b.tag == CMD('B','R',0,0)) // 'BR'
        {
          block->end = tagptr;
          line = do_align(block, 0, b.x, newalign, links);
          b.x = block->x;
          if (liflag) { b.x = margins.pop(); liflag = 0; } // pop li
          if (brflag) b.h = b.fsize + 2; // set b.h
          block->h += b.h;
          b.y = block->y + block->h; //b.y += b.h;
          brflag = 1;

          block = add_block(b, tagptr, (row) ? block->w : hwidth);
          b.h = 0;
          needspace = 0;
          line = 0;
        }
        else if (b.tag == CMD('C','E','N',0)) // 'CENTER'
        {
          block->end = tagptr;
          line = do_align(block, line, b.x, newalign, links);
          b.x = block->x;
          if (liflag) { b.x = margins.pop(); liflag = 0; } // pop li
          block->h += b.h;
          b.y = block->y + block->h;
          newalign = CENTER;

          block = add_block(b, tagptr, (row) ? block->w : hwidth);
          b.h = 0;
          needspace = 0;
          line = 0;
          newalign = talign = CENTER;
        }
        else if (b.tag == CMD('/','C','E','N')) // '/CENTER'
        {
          line = do_align(block, line, b.x, newalign, links);
          block->end = ptr;
          b.x = block->x;
          if (liflag) { b.x = margins.pop(); liflag = 0; } // pop li
          block->h += b.h;
          b.y += b.h;
          talign = LEFT;

          while (isspace((*ptr) & 255)) ptr ++;
          block = add_block(b, ptr, (row) ? block->w : hwidth);
          b.h = 0;
          needspace = 0;
          line = 0;
          newalign = talign;
        }
        else if (b.tag == CMD('C','O','D',0) ||
                 b.tag == CMD('T','T',0,0)) // 'CODE' 'TT'
        {
          b.font = monofont_;
          pushfont(b.font, b.fsize);
        }
        else if (b.tag == CMD('/','C','O','D') ||
                 b.tag == CMD('/','T','T',0)) // '/CODE' '/TT'
        {
          popfont(b.font, b.fsize);
        }
        else if (b.tag == CMD('D','I','V',0)) // 'DIV'
        {
          if (get_attr(attrptr, "ID", attr, sizeof(attr)))
            add_target(attr, b.y - b.fsize - 2);

          block->end = tagptr;
          line = do_align(block, line, b.x, newalign, links);
          b.x = block->x;
          if (liflag) { b.x = margins.pop(); liflag = 0; } // pop li
          block->h += b.h;
          b.y = block->y + block->h;
          newalign = LEFT;

          if (!pflag) {
            b.y += fontsize_ + 2; block->h += fontsize_ + 2; pflag = 1;
          }

          block = add_block(b, tagptr, (row) ? block->w : hwidth);
          b.h = 0;
          needspace = 0;
          line = 0;
          newalign = get_align(attrptr, talign);
        }
        else if (b.tag == CMD('/','D','I','V')) // '/DIV'
        {
          line = do_align(block, line, b.x, newalign, links);
          block->end = ptr;
          b.x = block->x;
          if (liflag) { b.x = margins.pop(); liflag = 0; } // pop li
          block->h += b.h;
          b.y += b.h;
          talign = LEFT;

          while (isspace((*ptr) & 255)) ptr ++;
          block = add_block(b, ptr, (row) ? block->w : hwidth);
          b.h = 0;
          needspace = 0;
          line = 0;
          newalign = talign;
        }
        else if (b.tag == CMD('F','O','N',0)) // 'FONT'
        {
          if (get_attr(attrptr, "FACE", attr, sizeof(attr)))
            b.font = font_face(attr);

          tfsize = b.fsize; // store b.fsize
          if (get_attr(attrptr, "SIZE", attr, sizeof(attr))) {
            if (isdigit(attr[0])) // Absolute size
              b.fsize = (int)(fontsize_ * pow(1.2, atoi(attr) - 3.0));
            else // Relative size
              b.fsize = (int)(b.fsize * pow(1.2, atoi(attr)));
          }

          pushfont(b.font, b.fsize);
          //if (fonty != b.y && !block->maxh) {
            //block->liney = abs(b.fsize - tfsize);
            //b.h = b.fsize + 2; // set b.h
          //}
          fonty = b.y; // set font y
        }
        else if (b.tag == CMD('/','F','O','N')) // '/FONT'
        {
          tfsize = b.fsize; // store b.fsize
          popfont(b.font, b.fsize);
          //if (fonty != b.y && !block->maxh) {
            //block->liney = abs(b.fsize - tfsize);
            //b.h = b.fsize + 2; // set b.h
          //}
          fonty = b.y; // set font y
        }
        else if (tag[0] == 'H' && isdigit(tag[1])) // 'H1'
        {
          if (tag[1] < '7') { // ignore if > 6
            block->end = tagptr;
            line = do_align(block, line, b.x, newalign, links);
            b.x = block->x;
            if (liflag) { b.x = margins.pop(); liflag = 0; } // pop li
            block->h += b.h;
            b.y = block->y + block->h;
            newalign = LEFT;

            thsize = b.fsize; // store b.fsize
            b.font = font_style(b.font, FL_BOLD);
            switch (tag[1]) { // header sizes
              case '1' : b.fsize = 24; break;
              case '2' : b.fsize = 18; break;
              case '3' : b.fsize = 16; break;
              case '4' : b.fsize = 14; break;
              case '5' : b.fsize = 12; break;
              case '6' : b.fsize = 10; break;
            }
            pushfont(b.font, b.fsize);

            if (!pflag) {
              b.y += fontsize_ + 2; block->h += fontsize_ + 2; pflag = 1;
            }
            b.y += b.fsize - thsize + (thsize / 4); // add offset
            block->h += b.fsize - thsize + (thsize / 4);

            block = add_block(b, tagptr, (row) ? block->w : hwidth);
            b.h = 0;
            needspace = 0;
            line = 0;
            newalign = get_align(attrptr, talign);
          }
        }
        else if (b.tag == CMD('/','H',tag[2],0) && isdigit(tag[2])) // '/H1'
        {
          if (tag[2] < '7') { // ignore if > 6
            line = do_align(block, line, b.x, newalign, links);
            block->end = ptr;
            b.x = block->x;
            if (liflag) { b.x = margins.pop(); liflag = 0; } // pop li
            block->h += b.h;
            b.y += b.h;

            if (!pflag) {
              b.y += fontsize_ + 2; block->h += fontsize_ + 2; pflag = 1;
            }
            b.y -= b.fsize - thsize;// + (thsize / 4); // sub offset
            block->h -= b.fsize - thsize;// + (thsize / 4);

            popfont(b.font, b.fsize);

            while (isspace((*ptr) & 255)) ptr ++;
            block = add_block(b, ptr, (row) ? block->w : hwidth);
            b.h = 0;
            needspace = 0;
            line = 0;
            newalign = talign;
          }
        }
        else if (b.tag == CMD('H','E','A',0)) // 'HEAD'
        {
          head = 1;
        }
        else if (b.tag == CMD('/','H','E','A')) // '/HEAD'
        {
          head = 0;
        }
        else if (b.tag == CMD('H','R',0,0)) // 'HR'
        {
          block->end = tagptr;
          line = do_align(block, line, b.x, newalign, links);
          b.x = block->x;
          if (liflag) { b.x = margins.pop(); liflag = 0; } // pop li
          block->h += b.h;
          b.y = block->y + block->h;
          newalign = LEFT;

          if (!pflag) {
            b.y += fontsize_ + 2; block->h += fontsize_ + 2; pflag = 1;
          }

          block = add_block(b, tagptr, (row) ? block->w : hwidth);
          //block->y -= (b.fsize / 2); // hr line offset
          //b.y += fontsize_ + 2; // end paragraph
          //block->h += fontsize_ + 2;
          //pflag = 1;
          b.h = b.fsize + 2; // set b.h - rem: ??
          b.h = 0;
          needspace = 0;
          line = 0;
          newalign = get_align(attrptr, talign);
        }
        else if (b.tag == CMD('H','T','M',0)) // 'HTML'
        {
        }
        else if (b.tag == CMD('I',0,0,0) ||
                 b.tag == CMD('E','M',0,0)) // 'I' 'EM'
        {
          b.font = font_style(b.font, FL_ITALIC);
          pushfont(b.font, b.fsize);
        }
        else if (b.tag == CMD('/','I',0,0) ||
                 b.tag == CMD('/','E','M',0)) // '/I' '/EM'
        {
          popfont(b.font, b.fsize);
        }
        else if (b.tag == CMD('I','M','G',0)) // 'IMG'
        {
          imgw = imgh = 0; // reset
          if (get_attr(attrptr, "WIDTH", wattr, sizeof(wattr)))
            imgw = get_length(wattr);
          if (get_attr(attrptr, "HEIGHT", hattr, sizeof(hattr)))
            imgh = get_length(hattr);

          img = 0; // rem'd NULL
          if (get_attr(attrptr, "SRC", attr, sizeof(attr))) {
            img = get_image(attr, imgw, imgh);
            imgw = img->w();
            imgh = img->h();
          }

          b.w = imgw;
          if (b.w > hsize_) { // Reformat
            hsize_ = b.w;
            done = 0;
          }

          if (needspace && b.x > block->x)
            b.w += (int)fl_width(" ");

          if ((b.x + b.w) > block->w) {
            block->end = tagptr;
            line = do_align(block, line, b.x, newalign, links);
            b.x = block->x;
            block->h += b.h;
            b.y = block->y + block->h; //b.y += b.h;
            line = 0;

            block = add_block(b, tagptr, (row) ? block->w : hwidth);
            b.h = 0;
            needspace = 0;
          }

          if (linkdest[0])
            add_link(linkdest, b.x, b.y - imgh, b.w, imgh);

          b.x += b.w;
          if ((imgh + 2) > b.h) b.h = imgh + 2; // Set img b.h
          needspace = 0;

          if (imgh > block->maxh)
            block->maxh = imgh; // max image height
          block->imgy = b.y; // y position of image
          pflag = 0; // reset p flag
          brflag = 0;
        }
        else if (b.tag == CMD('K','B','D',0)) // 'KBD'
        {
          b.font = font_style(monofont_, FL_BOLD);
          pushfont(b.font, b.fsize);
        }
        else if (b.tag == CMD('/','K','B','D')) // '/KBD'
        {
          popfont(b.font, b.fsize);
        }
        else if (b.tag == CMD('L','I',0,0)) // 'LI'
        {
          block->end = tagptr;
          line = do_align(block, line, b.x, newalign, links);
          b.x = block->x;
          if (!liflag && !listnest) { // push li, if not nested
            b.x = margins.push(b.fsize);
            liflag = 1;
          }
          block->h += b.h;
          b.y = block->y + block->h;
          newalign = LEFT;
          block = add_block(b, tagptr, (row) ? block->w : hwidth);

          // li > ul > ul nest
          if (ulnest > 9) // square if out of bounds
            block->type = 3;
          else if (ultype[ulnest]) // ul type
            block->type = ultype[ulnest];
          else if (ulnest > 1) // ul nest type
            block->type = ulnest;
          else // none or ul nest type disc/disk
            block->type = 1;

          b.h = 0;
          needspace = 0;
          line = 0;
          newalign = get_align(attrptr, talign);
        }
        else if (b.tag == CMD('/','L','I',0)) // '/LI'
        {
          line = do_align(block, line, b.x, newalign, links);
          block->end = ptr;
          b.x = block->x;
          if (liflag) { b.x = margins.pop(); liflag = 0; } // pop li
          block->h += b.h;
          b.y += b.h;

          while (isspace((*ptr) & 255)) ptr ++;
          block = add_block(b, ptr, (row) ? block->w : hwidth);
          b.h = 0;
          needspace = 0;
          line = 0;
          newalign = talign;
        }
        else if (b.tag == CMD('L','I','N',0)) // 'LINK'
        {
          if (get_attr(attrptr, "HREF", tchar, sizeof(tchar)))
            strlcpy(tcss, tchar, sizeof(tcss));
            
          for (ti = 0; tcss[ti] != '\0'; ti ++) // replace '\' chars
            if (tcss[ti] == '\\') tcss[ti] = '/';
            
          if (tcss[0] == '/' || tcss[1] == ':') // absolute
            strlcpy(tchar, tcss, sizeof(tchar));
          else { // relative
            if (d->ispath) { // path is used
              strlcpy(tchar, d->path, sizeof(tchar));
              if ((tp = strrchr(tchar, '/'))) // replace filename
                strlcpy(tp + 1, tcss, sizeof(tchar)-(tp + 1 - tchar));
            }
            else { // use directory
              strlcpy(tchar, directory_, sizeof(tchar));
              strlcat(tchar, tcss, sizeof(tchar));
            }
          }
          
          while ((tp = strstr(tchar, "/.."))) { // remove ../ from path
            for (ap = tp - 1; ap > tchar; ap --)
              if (*ap == '/') break; // seek back to last dir
            if (ap == tchar) break; // nothing to remove
            *ap = '\0'; // nul-terminate
            strlcat(tchar, tp + 3, sizeof(tchar)); // add rest of path
          }
          while ((tp = strstr(tchar, "/./"))) { // remove ./ from path
            *tp = '\0';
            strlcat(tchar, tp + 2, sizeof(tchar));
          }
                    
          if ((tp = strrchr(tcss, '.'))) { // check valid ext
            if (strstr(tp, ".css")) load_css(tchar);
          }
          tcss[0] = '\0'; // reset
        }
        else if (b.tag == CMD('N','O','S',0)) // 'NOSCRIPT'
        { // we don't support scripting so we won't skip this
        }
        else if (b.tag == CMD('P',0,0,0)) // 'P'
        { // && !b.pre fixme?
          block->end = tagptr;
          line = do_align(block, line, b.x, newalign, links);
          b.x = block->x;
          if (liflag) { b.x = margins.pop(); liflag = 0; } // pop li
          block->h += b.h;
          b.y = block->y + block->h;
          newalign = LEFT;

          if (!pflag) {
            b.y += fontsize_ + 2; block->h += fontsize_ + 2; pflag = 1;
          }

          block = add_block(b, tagptr, (row) ? block->w : hwidth);
          b.h = 0;
          needspace = 0;
          line = 0;
          newalign = get_align(attrptr, talign);
        }
        else if (b.tag == CMD('/','P',0,0)) // '/P'
        {
          line = do_align(block, line, b.x, newalign, links);
          block->end = ptr;
          b.x = block->x;
          if (liflag) { b.x = margins.pop(); liflag = 0; } // pop li
          block->h += b.h;
          b.y = block->y + block->h;

          if (!pflag) {
            b.y += fontsize_ + 2; block->h += fontsize_ + 2; pflag = 1;
          }

          while (isspace((*ptr) & 255)) ptr ++;
          block = add_block(b, ptr, (row) ? block->w : hwidth);
          b.h = 0;
          needspace = 0;
          line = 0;
          newalign = talign;
        }
        else if (b.tag == CMD('P','R','E',0)) // 'PRE'
        {
          block->end = tagptr;
          line = do_align(block, line, b.x, newalign, links);
          b.x = block->x;
          if (liflag) { b.x = margins.pop(); liflag = 0; } // pop li
          block->h += b.h;
          b.y = block->y + block->h;
          newalign = LEFT;

          linew = 0;
          b.pre = 1;
          b.font = monofont_;
          b.fsize = fontsize_;
          parse_css(b, csstag, tchar);
          pushfont(b.font, b.fsize);

          if (!pflag) {
            b.y += fontsize_ + 2; block->h += fontsize_ + 2; pflag = 1;
          }

          block = add_block(b, tagptr, (row) ? block->w : hwidth);
          b.h = 0;
          needspace = 0;
          line = 0;
          newalign = get_align(attrptr, talign);
        }
        else if (b.tag == CMD('/','P','R','E')) // '/PRE'
        {
          line = do_align(block, line, b.x, newalign, links);
          block->end = ptr;
          b.x = block->x;
          if (liflag) { b.x = margins.pop(); liflag = 0; } // pop li
          block->h += b.h;
          b.y += b.h;
                    
          for (ti = nblocks_ - 1, tj = 0; ti > 0; ti --) { // find start block index
            tempb = blocks_ + ti;
            if (tempb->tag == CMD('P','R','E',0)) tj = 1; // pre line
            if (tj && tempb->tag != CMD('P','R','E',0)) {
              tempb = blocks_ + ti + 1; // + 1 gets first pre
              break;
            }
          }
          tempb->h = block->y - tempb->y; // recalculate h

          if (!pflag) {
            b.y += fontsize_ + 2; block->h += fontsize_ + 2; pflag = 1; }

          b.pre = 0;
          popfont(b.font, b.fsize);

          while (isspace((*ptr) & 255)) ptr ++;
          block = add_block(b, ptr, (row) ? block->w : hwidth);
          b.h = 0;
          needspace = 0;
          line = 0;
          newalign = talign;
        }
        else if (b.tag == CMD('S','C','R',0)) // 'SCRIPT'
        {
          while (ptr) { // skip scripting
            ptr = strstr(ptr, "</");
            if (!strncasecmp(ptr, "</SCRIPT>", 9)) break;
          }

          if (ptr) { // found </script>
            ptr += 9;
            continue;
          }
          else // not found
            break;
        }
        else if (b.tag == CMD('T','A','B',0)) // 'TABLE'
        {
          if (ntables >= 0) { // store row data
            rowdata[0][ntables] = row; // row
            rowdata[1][ntables] = column; // column
            rowdata[2][ntables] = block - blocks_; // block number
            tbclr[0][ntables] = tclr; // table bgcolor
            tbclr[1][ntables] = rclr; // tr bgcolor
            for (ti = 0; ti < HV_64; ti ++) {
              tcolumns[ti][ntables] = columns[ti]; // cell columns
              tcells[ti][ntables] = cells[ti]; // cell blocks
              if (columns[ti] == 0) break;
            }
          }
          if (ntables < HV_16) ntables ++; // max limit
          tfonts[ntables] = d->nfonts; // number of fonts

          block->end = tagptr;
          line = do_align(block, line, b.x, newalign, links);
          b.x = block->x;
          block->h += b.h + 8; // add tr gap offset, wrong line gaps
          b.y = block->y + block->h;
          newalign = LEFT;

          b.border = 0; // Reset
          if (get_attr(attrptr, "BORDER", attr, sizeof(attr)))
            b.border = atoi(attr);

          get_attr(attrptr, "BGCOLOR", attr, sizeof(attr));
          tclr = rclr = get_color(attr, bgcolor_);

          memset(columns, 0, sizeof(columns)); // zero for new table
          format_table(table_width, columns, tagptr, b.x, 0);

          if ((b.x + table_width) > hsize_) { // Reformat
          
//printf("\nb.x=%d, table_width=%d, hsize_=%d\n\n",
//  b.x, table_width, hsize_);

            hsize_ = b.x + table_width;
            for (ti = 0; ti < HV_64; ti ++)
              if (columns[ti] == 0) break; // num columns
            hsize_ += 6 * ti; // add internal borders
            done = 0;
          }

          switch (get_align(attrptr, talign)) {
            default :
              table_offset = 0; break;
            case CENTER :
              table_offset = ((hsize_ - table_width) / 2) - fontsize_; break;
            case RIGHT :
              table_offset = hsize_ - table_width - fontsize_; break;
          }

          block = add_block(b, tagptr, (row) ? block->w : hwidth);
          column = 0;
          b.h = 0;
          needspace = 0;
          line = 0;
          newalign = get_align(attrptr, talign);
        }
        else if (b.tag == CMD('/','T','A','B')) // '/TABLE'
        {
          if (row) { // no /tr
            line = do_align(block, line, b.x, newalign, links);
            if (tdline) { // td was popped
              block->line = tdline; tdline = 0; } // last line in td
            block->end = ptr;
            block->h += b.h;
            talign = LEFT;
            if (b.h == 0) b.h = b.fsize + 2; // empty td on end of row
            
            b.x = blocks_[row].x;
            b.y = blocks_[row].y + blocks_[row].h;
            
            for (cell = blocks_ + row + 1; cell <= block; cell ++)
              if (cell->y + cell->h > b.y) b.y = cell->y + cell->h;
              
            block = blocks_ + row; // current row block ptr
            block->h = b.y - block->y + 2;
            
            for (ti = 0; ti < column; ti ++)
              if (cells[ti]) { // cell block exists
                cell = blocks_ + cells[ti]; // get cell block ptr
                cell->h = block->h;
            }
            
            b.y = block->y + block->h - 4; // tr gap offset between rows
            block = add_block(b, ptr, hwidth);
            needspace = 0;
            row = 0; // reset row block number
            line = 0;
          }
          
          line = do_align(block, line, b.x, newalign, links);
          if (tdline) { block->line = tdline; tdline = 0; } // td popped
          block->end = ptr;
          b.x = block->x;
          b.h = 0; // reset b.h
          block->h += b.h; // may be needed if no /tr
          b.y += b.h + 8; // add tr gap offset, wrong line gaps

          if (!trpop) { b.x = margins.pop(); row = 0; } // pop tr indent
          trpop = 0; // reset tr popped
          b.x = margins.current();

          while (isspace((*ptr) & 255)) ptr ++;
          block = add_block(b, ptr, (row) ? block->w : hwidth);
          b.h = 0;
          needspace = 0;
          line = 0;
          newalign = talign;

          d->nfonts = tfonts[ntables] + 1; // number of fonts + 1 for pop
          popfont(b.font, b.fsize); // tables not popping last font fix

          if (ntables >= 0) ntables --; // min limit
          if (ntables >= 0) { // restore row data
            row = rowdata[0][ntables]; // row
            column = rowdata[1][ntables]; // column
            cell = blocks_ + rowdata[2][ntables] + 1; // table block
            b.x = block->x = cell->x; // nested table popping cell margin fix
            block->w = cell->w;
            tclr = tbclr[0][ntables]; // table bgcolor
            rclr = tbclr[1][ntables]; // tr bgcolor
            
            for (ti = 0; ti < HV_64; ti ++) {
              columns[ti] = tcolumns[ti][ntables]; // cell columns
              // nested table overwriting cell heights fix
              cells[ti] = tcells[ti][ntables]; // cell blocks
              if (tcolumns[ti][ntables] == 0) break;
            }
            
            // nested table drawn below row height fix
            cell->y -= 4; // table y offset
            tempy = cell->y; // table block y
            for (cell = cell; cell <= block; cell ++) // find tr, td, th
              if (cell->tag == CMD('T','R',0,0) ||
                  cell->tag == CMD('T','D',0,0) ||
                  cell->tag == CMD('T','H',0,0)) break;
            tempy = cell->y - tempy; // get row height
            for (cell = cell; cell <= block; cell ++)
              cell->y -= tempy; // move table up
            block->h -= 2; // /table h offset
          }

//printf("/table ntables=%d tempx=%d b.x=%d b->x=%d\n",
//  ntables,tempx,b.x,block->x);
        }
        else if (b.tag == CMD('T','D',0,0) ||
                 b.tag == CMD('T','H',0,0)) // 'TD' 'TH'
        {
          if (!row) { // no tr
            block->end = tagptr;
            line = do_align(block, line, b.x, newalign, links);
            b.x = block->x;
            block->h += b.h;
            
            memset(cells, 0, sizeof(cells)); // zero for new row
            b.y = block->y + block->h - 4; // tr gap offset between rows
            block = add_block(b, tagptr, hwidth);
            row = block - blocks_; // next row block number
            column = 0;
            b.h = 0;
            needspace = 0;
            line = 0;
            trpop = 0; // reset tr popped
          }
          
          if (row) {
            line = do_align(block, line, b.x, newalign, links);
            if (tdline) { block->line = tdline; tdline = 0; } // td popped
            block->end = tagptr;
            block->h += b.h;
            b.y = blocks_[row].y;
            pflag = 1;

            b.x = blocks_[row].x;
            if (liflag) { b.x = margins.pop(); liflag = 0; } // pop li
            b.x += 3 + table_offset; // rem'd + b.fsize

            for (ti = 0; ti < column; ti ++)
              b.x += columns[ti] + 6;
            margins.push(b.x - margins.current());

//printf("td ntables=%d tempx=%d b.x=%d b->x=%d\n",
//  ntables,tempx,b.x,block->x);

            colspan = 1; // Reset
            if (get_attr(attrptr, "COLSPAN", attr, sizeof(attr)))
              colspan = atoi(attr);

            for (ti = 0, b.w = -6; ti < colspan; ti ++)
              b.w += columns[column + ti] + 6;

            if (block->end == block->start && nblocks_ > 1) {
              nblocks_ --;
              block --;
            }

            if (ntables >= 0)
              d->nfonts = tfonts[ntables]; // pop number of fonts

            b.font = serifont_;
            b.fsize = fontsize_;
            parse_css(b, csstag, tchar);
            if (b.tag == CMD('T','H',0,0)) // th
              b.font = font_style(b.font, FL_BOLD);
            pushfont(b.font, b.fsize);
            
            block = add_block(b, tagptr, b.x + b.w);
            b.h = 0;
            needspace = 0;
            line = 0;
            newalign = get_align(attrptr, (tag[1] == 'H') ? CENTER : LEFT);
            talign = newalign;
            cells[column] = block - blocks_; // set cell block number
            column += colspan;
            
            if (get_attr(attrptr, "BGCOLOR", attr, sizeof(attr)))
              block->bgcolor = get_color(attr, rclr);
          }
        }
        else if (b.tag == CMD('/','T','D',0) ||
                 b.tag == CMD('/','T','H',0)) // '/TD' '/TH'
        {
          if (row) {
            line = do_align(block, 0, b.x, newalign, links);
            talign = LEFT;
            //popfont(b.font, b.fsize);
            tdline = block->line; // store td line
            b.x = margins.pop();
            pflag = 0; // reset p flag?

//printf("/td ntables=%d tempx=%d b.x=%d b->x=%d\n",
//  ntables,tempx,b.x,block->x);
          }
        }
        else if (b.tag == CMD('T','I','T',0)) // 'TITLE'
        {
          // Copy the title in the document
          tp = title_ + sizeof(title_) - 1;
          for (sp = title_; *ptr != '<' && *ptr && sp < tp; )
            *(sp ++) = *(ptr ++); // added ()
          *sp = '\0'; // Nul-terminate
          sp = buf;
        }
        else if (b.tag == CMD('T','R',0,0)) // 'TR'
        {
          for (ti = nblocks_ - 1; ti > 0; ti --) { // find last block index
            tempb = blocks_ + ti;
            if (tempb->tag == CMD('T','A','B',0) || tempb->tag == CMD('/','T','A','B') ||
                tempb->tag == CMD('T','D',0,0) || tempb->tag == CMD('T','H',0,0) ||
                tempb->tag == CMD('T','R',0,0) || tempb->tag == CMD('/','T','R',0))
              break; // found table/tr/td tag
          }
          
          tempx = 0; // no /tr flag
          if (row && tempb->tag != CMD('T','A','B',0)) { // skip first tr after table
            line = do_align(block, line, b.x, newalign, links);
            if (tdline) { // td was popped
              block->line = tdline; tdline = 0; } // last line in td
            block->end = ptr;
            block->h += b.h;
            talign = LEFT;
            if (b.h == 0) b.h = b.fsize + 2; // empty td on end of row
            
            tempx = b.x;
            b.x = blocks_[row].x;
            b.y = blocks_[row].y + blocks_[row].h;
            
            for (cell = blocks_ + row + 1; cell <= block; cell ++)
              if (cell->y + cell->h > b.y) b.y = cell->y + cell->h;
              
            block = blocks_ + row; // current row block ptr
            block->h = b.y - block->y + 2;
            
            for (ti = 0; ti < column; ti ++)
              if (cells[ti]) { // cell block exists
                cell = blocks_ + cells[ti]; // get cell block ptr
                cell->h = block->h;
            }
            
            if (tempx) block->x = tempx;
            b.y = block->y + block->h - 4; // tr gap offset between rows
            block = add_block(b, ptr, hwidth);
            needspace = 0;
            row = 0; // reset row block number
            line = 0;
          }
          
          block->end = tagptr;
          line = do_align(block, line, b.x, newalign, links);
          b.x = block->x;
          block->h += b.h;

          if (row) {
            b.y = blocks_[row].y + blocks_[row].h;

            for (cell = blocks_ + row + 1; cell <= block; cell ++)
              if (cell->y + cell->h > b.y) b.y = cell->y + cell->h;

            block = blocks_ + row; // current row block ptr
            block->h = b.y - block->y + 2;

            for (ti = 0; ti < column; ti ++)
              if (cells[ti]) { // cell block exists
                cell = blocks_ + cells[ti]; // get cell block ptr
                cell->h = block->h;
              }
          }

          memset(cells, 0, sizeof(cells)); // zero for new row
          b.y = block->y + block->h - 4; // tr gap offset between rows
          block = add_block(b, tagptr, hwidth);
          row = block - blocks_; // next row block number
          column = 0;
          b.h = 0;
          needspace = 0;
          line = 0;
          trpop = 0; // reset tr popped
          get_attr(attrptr, "BGCOLOR", attr, sizeof(attr));
          rclr = get_color(attr, tclr);
        }
        else if (b.tag == CMD('/','T','R',0)) // '/TR'
        {
          if (row) { // tr
            line = do_align(block, line, b.x, newalign, links);
            if (tdline) { // td was popped
              block->line = tdline; tdline = 0; } // last line in td
            block->end = ptr;
            block->h += b.h;
            talign = LEFT;
            if (b.h == 0) b.h = b.fsize + 2; // empty td on end of row
            
            b.x = blocks_[row].x;
            b.y = blocks_[row].y + blocks_[row].h;
            
            for (cell = blocks_ + row + 1; cell <= block; cell ++)
              if (cell->y + cell->h > b.y) b.y = cell->y + cell->h;
              
            block = blocks_ + row; // current row block ptr
            block->h = b.y - block->y + 2;
            
            for (ti = 0; ti < column; ti ++)
              if (cells[ti]) { // cell block exists
                cell = blocks_ + cells[ti]; // get cell block ptr
                cell->h = block->h;
            }
            
            b.y = block->y + block->h - 4; // tr gap offset between rows
            
//printf("/tr row=%d column=%d b.h=%d b->h=%d b->y=%d b.y=%d\n",
//  row,column,b.h,block->h,block->y,b.y);

            block = add_block(b, ptr, hwidth);
            needspace = 0;
            row = 0; // reset row block number
            line = 0;
          }
          else // start margins pop /tr - rem: nested table fix?
          {
            line = do_align(block, line, b.x, newalign, links);
            block->end = ptr;
            b.x = block->x;
            block->h += b.h;
            b.y += b.h;
            trpop = 1; // set tr popped
            b.x = margins.pop(); // pop tr

            while (isspace((*ptr) & 255)) ptr ++;
            block = add_block(b, ptr, hwidth);
            b.h = 0;
            needspace = 0;
            line = 0;
            newalign = talign;
          }
        }
        else if (b.tag == CMD('U',0,0,0)) // 'U'
        {
        }
        else if (b.tag == CMD('V','A','R',0)) // 'VAR'
        {
          b.font = font_style(monofont_, FL_ITALIC);
          pushfont(b.font, b.fsize);
        }
        else if (b.tag == CMD('/','V','A','R')) // '/VAR'
        {
          popfont(b.font, b.fsize);
        }
        else if (b.tag == CMD('A','B','B',0) || // 'ABBR'
                 b.tag == CMD('A','C','R',0) || // 'ACRONYM'
                 b.tag == CMD('A','D','D',0) || // 'ADDRESS'
                 b.tag == CMD('A','P','P',0) || // 'APPLET'
                 b.tag == CMD('A','R','E',0) || // 'AREA'
                 b.tag == CMD('B','A','S',0) || // 'BASE' 'BASEFONT'
                 b.tag == CMD('B','D','O',0) || // 'BDO'
                 b.tag == CMD('B','G','S',0) || // 'BGSOUND'
                 b.tag == CMD('B','I','G',0) || // 'BIG'
                 b.tag == CMD('B','L','I',0) || // 'BLINK'
                 b.tag == CMD('B','U','T',0) || // 'BUTTON'
                 b.tag == CMD('C','A','P',0) || // 'CAPTION'
                 b.tag == CMD('C','I','T',0) || // 'CITE'
                 b.tag == CMD('C','O','L',0) || // 'COL' 'COLGROUP'
                 b.tag == CMD('D','E','L',0) || // 'DEL'
                 b.tag == CMD('D','F','N',0) || // 'DFN'
                 b.tag == CMD('D','I','R',0) || // 'DIR'
                 b.tag == CMD('E','M','B',0) || // 'EMBED'
                 b.tag == CMD('F','I','E',0) || // 'FIELDSET'
                 b.tag == CMD('F','O','R',0) || // 'FORM'
                 b.tag == CMD('F','R','A',0) || // 'FRAME' 'FRAMESET'
                 b.tag == CMD('I','F','R',0) || // 'IFRAME'
                 b.tag == CMD('I','N','P',0) || // 'INPUT'
                 b.tag == CMD('I','N','S',0) || // 'INS'
                 b.tag == CMD('I','S','I',0) || // 'ISINDEX'
                 b.tag == CMD('L','A','B',0) || // 'LABEL'
                 b.tag == CMD('L','E','G',0) || // 'LEGEND'
                 b.tag == CMD('L','I','N',0) || // 'LINK'
                 b.tag == CMD('M','A','P',0) || // 'MAP'
                 b.tag == CMD('M','A','R',0) || // 'MARQUEE'
                 b.tag == CMD('M','E','N',0) || // 'MENU'
                 b.tag == CMD('M','E','T',0) || // 'META'
                 b.tag == CMD('M','U','L',0) || // 'MULTICOL'
                 b.tag == CMD('N','O','B',0) || // 'NOBR'
                 b.tag == CMD('N','O','F',0) || // 'NOFRAMES'
                 b.tag == CMD('O','B','J',0) || // 'OBJECT'
                 b.tag == CMD('O','P','T',0) || // 'OPTGROUP' 'OPTION'
                 b.tag == CMD('P','A','R',0) || // 'PARAM'
                 b.tag == CMD('Q',0,0,0) || // 'Q'
                 b.tag == CMD('S',0,0,0) || // 'S'
                 b.tag == CMD('S','A','M',0) || // 'SAMP'
                 b.tag == CMD('S','E','L',0) || // 'SELECT'
                 b.tag == CMD('S','M','A',0) || // 'SMALL'
                 b.tag == CMD('S','P','A',0) || // 'SPACER' 'SPAN'
                 b.tag == CMD('S','T','R',0) || // 'STRIKE'
                 b.tag == CMD('S','T','Y',0) || // 'STYLE'
                 b.tag == CMD('S','U','B',0) || // 'SUB'
                 b.tag == CMD('S','U','P',0) || // 'SUP'
                 b.tag == CMD('T','B','O',0) || // 'TBODY'
                 b.tag == CMD('T','E','X',0) || // 'TEXTAREA'
                 b.tag == CMD('T','F','O',0) || // 'TFOOT'
                 b.tag == CMD('T','H','E',0) || // 'THEAD'
                 b.tag == CMD('W','B','R',0) || // 'WBR'
                 b.tag == CMD('X','M','P',0)) // 'XMP'
          ; // unsupported tags
        else if (tag[0] == '!' && isalpha(tag[1])) // '!DOCTYPE' etc
          ;
        else if (tag[0] == '?' && isalpha(tag[1])) // '?XMP' etc
          ;
        else if (tag[0] == '/' && isalpha(tag[1])) // unrecognized end tag
          ;
        else if (!head) // unrecognized tag so draw it
        {
          b.x += (int)fl_width("<"); // add width of '<' char
          linew += (int)fl_width("<");
          ptr = tagptr + 1; // start of tag + 1
        }
        
      } // if (*ptr == '<')

      else if (*ptr == '\n' && b.pre) // '\n' in pre
      {
        if (linkdest[0])
          add_link(linkdest, b.x, b.y - b.h, b.w, b.h);

        if (b.x > hsize_) { // Reformat
          hsize_ = b.x + 4;
          done = 0;
        }

        block->end = ptr;
        line = do_align(block, 0, b.x, newalign, links);
        b.x = block->x;
        block->h += b.h;
        b.y += b.h; //b.y = block->y + block->h;
        line = 0;
        linew = 0;

        block = add_block(b, ptr, (row) ? block->w : hwidth);
        b.h = 0;
        needspace = 0;
        ptr ++;
      }
      else if (isspace((*ptr) & 255)) // ' ' '\t'\n'\v'\f'\r' chars
      {
        needspace = 1;
        ptr ++;
      }
      else if (*ptr == '&' && sp < (buf + sizeof(buf) - 1)) // '&' char ref
      {
        ptr ++;
        qch = quote_char(ptr);

        if (qch < 0)
          *(sp ++) = '&'; // added ()
        else {
          *(sp ++) = qch; // added ()
          ptr = strchr(ptr, ';') + 1;
        }

        if (b.fsize + 2 > b.h) b.h = b.fsize + 2; // Set b.h
      }
      else // Other char
      {
        if (sp < (buf + sizeof(buf) - 1))
          *(sp ++) = *(ptr ++); // added ()
        else
          ptr ++;

        if (b.fsize + 2 > b.h) b.h = b.fsize + 2; // Set b.h
      }

      //if (d->resized && block->y + block->h > topline_ + h())
        //break; // if resizing big page skip non-visible region

    } // for (ptr = value_ ...)

    if (sp > buf) // Still something left to parse
    {
      if (!head) // Normal text... b.pre fixme?
      {
        *sp = '\0'; // Nul-terminate
        b.w = (int)fl_width(buf);

//printf("line = %d, b.x = %d, b.w = %d, block->x = %d, block->w = %d\n",
//  line, b.x, b.w, block->x, block->w);

        if (b.w > hsize_) { // Reformat
          hsize_ = b.w;
          done = 0;
        }

        if (needspace && b.x > block->x)
          b.w += (int)fl_width(" ");

        // no new line if word too long and no word before it
        if (!(b.x < 7 && b.w > block->w) && (b.x + b.w) > block->w) {
          block->end = ptr - strlen(buf);
          line = do_align(block, 0, b.x, newalign, links);
          b.x = block->x;
          block->h += b.h;
          b.y += b.h; //b.y = block->y + block->h;
          b.h = 0;
          line = 0;

          block = add_block(b, ptr - strlen(buf), (row) ? block->w : hwidth);
        }

        if (linkdest[0])
          add_link(linkdest, b.x, b.y - b.fsize, b.w, b.fsize);

        b.x += b.w;
      }
    }

    do_align(block, line, b.x, newalign, links);
    block->end = ptr;
    size_ = b.y + b.h;

    //if (d->resized && block->y + block->h > topline_ + h())
      //break; // if resizing big page skip non-visible region

  } // while (!done)

  d->isnew = 0; // reset - so we know a repeat call to format per page, to stabilize malloc
  
//printf("margins.depth_=%d\n", margins.depth_);

  if (ntargets_ > 1)
    qsort(d->targets, ntargets_, sizeof(Fl_Help_Link),
          (compare_func_t)cmp_targets);

  dx = Fl::box_dw(bt) - Fl::box_dx(bt);
  dy = Fl::box_dh(bt) - Fl::box_dy(bt);
  ss = Fl::scrollbar_size();
  dw = Fl::box_dw(bt) + ss;
  dh = Fl::box_dh(bt);

  //if (d->resized && block->y + block->h > topline_ + h())
    //return; // if resizing big page skip resizing scrollbars

  if (hsize_ > (w() - dw))
  {
    hscrollbar_.show();
    dh += ss;

    if (size_ < (h() - dh)) {
      scrollbar_.hide();
      hscrollbar_.resize(x() + Fl::box_dx(bt), y() + h() - ss - dy,
                         w() - Fl::box_dw(bt), ss);
    }
    else {
      scrollbar_.show();
      scrollbar_.resize(x() + w() - ss - dx, y() + Fl::box_dy(bt),
                        ss, h() - ss - Fl::box_dh(bt));
      hscrollbar_.resize(x() + Fl::box_dx(bt), y() + h() - ss - dy,
                         w() - ss - Fl::box_dw(bt), ss);
    }
  }
  else // If hsize_ <= (w() - dw)
  {
    hscrollbar_.hide();

    if (size_ < (h() - dh))
     scrollbar_.hide();
    else {
      scrollbar_.resize(x() + w() - ss - dx, y() + Fl::box_dy(bt),
                        ss, h() - Fl::box_dh(bt));
      scrollbar_.show();
    }
  }

  // Reset scrolling if it needs to be
  if (scrollbar_.visible()) {
    temph = h() - Fl::box_dh(bt);
    if (hscrollbar_.visible()) temph -= ss;
    if ((topline_ + temph) > size_) topline(size_ - temph);
    else topline(topline_);
  }
  else
    topline(0);

  if (hscrollbar_.visible()) {
    tempw = w() - ss - Fl::box_dw(bt);
    if (leftline_ + tempw > hsize_)
      leftline(hsize_ - tempw);
    else
      leftline(leftline_);
  }
  else
    leftline(0);

} // Fl_Help_View::format()

//
// Fl_Help_View::format_table() - replaced, code moved
//

void Fl_Help_View::format_table(int *tw, // O - Total table width
                                int *maxcols, // O - Column widths
                                const char *tp) // I - Table start pointer
{
  return;

} // Fl_Help_View::format_table()

//
// Fl_Help_View::format_table() - Format a table.
//

const char * // O - table end pointer
Fl_Help_View::format_table(int &tw, // O - Total table width
                           int *maxcols, // O - Column widths
                           const char *tp, // I - Table start pointer
                           int xx, // I - x position of table
                           int rc) // I - recursive counter
{
  char *sp, // Pointer into buffer
    buf[1024], // Text buffer
    attr[1024], // Other attribute
    wattr[1024], // WIDTH attribute
    hattr[1024], // HEIGHT attribute
    tag[4]; // tag/element 4-char buf
  const char *ptr, // Pointer into table
    *attrptr, // Start of attributes ptr
    *tagptr, // Start of tag/element ptr
    *endp; // table end pointer
  int col = 0, // Current column
    numcells = 0, // Number of cells
    colspan = 0, // COLSPAN attribute
    linew = 0, // Current line width
    tempw = 0, // Temporary width
    maxlinew = 0, // Maximum width
    mincellw = 0, // minimum table width
    maxcellw = 0, // total width of cells
    colspanw = 0, // colspan width
    scalew = 0, // Table scaled width
    hwidth = 0, // horizontal window width
    tsize = 0, // table size
    incell = 0, // In a table cell?
    head = 0, // head/body section flag
    pre = 0, // Pre text flag
    btag = 0, // tag/element fourcc int
    needspace = 0, // Do we need whitespace?
    ti = 0, // temp loop var
    imgw = 0, // Image width
    imgh = 0, // Image height
    qch = 0, // Quote char
    nfonts = 0, // local font stack index
	font = 0; // Current font
  unsigned char fsize; // Current font size
  int mincols[HV_64], // Minimum widths for each column
    widths[HV_64], // td width attributes
    colspans[HV_64], // min width in colspan cells
    columns[HV_64], // nested table column widths
    fonts[HV_64][2]; // local font stack
  Fl_Shared_Image *img = 0; // Shared image - rem'd NULL
  Fl_Boxtype bt = (box()) ? box() : FL_DOWN_BOX; // Box size

  tw = 0; // Clear widths
  endp = 0; // rem'd NULL

  // zero arrays
  memset(mincols, 0, sizeof(mincols));
  memset(widths, 0, sizeof(widths));
  memset(colspans, 0, sizeof(colspans));
  memset(columns, 0, sizeof(columns));

  hwidth = w() - Fl::scrollbar_size() - Fl::box_dw(bt);

  font = fonts[nfonts][0] = serifont_; // initfont
  fsize = fonts[nfonts][1] = fontsize_;
  fl_font(font, fsize);

//printf("\nFORMAT_TABLE %d\n",tp - value_);

  col = -1;
  linew = 0;
  incell = 0;

  // Scan the table
  for (ptr = tp, sp = buf; *ptr; )
  {
    if ((*ptr == '<' || isspace((*ptr) & 255)) && sp > buf)
    {
      if (needspace) { // Check width
        *(sp ++) = ' '; // added ()
        needspace = 0;
      }

      *sp = '\0'; // Nul-terminate
      sp = buf;

      if (incell && !head && !pre) // Normal text
      {
        tempw = (int)fl_width(buf); // Width of current word
        if (tempw > mincols[col] && colspan <= 1)
          mincols[col] = tempw; // ignore if colspan > 1

        if (tempw > colspans[col] && colspan > 1) {
          colspans[col] = tempw; // colspans
          colspans[col] -= 6 * (colspan - 1); // sub internal borders
          if (colspans[col] < 6 * (colspan - 1))
            colspans[col] = tempw; // reset thin cell widths
          colspans[col + 1] = colspan;
        }

        linew += tempw;
        if (linew > maxlinew) maxlinew = linew;
      }
      else if (incell && !head && pre) // pre text
      {
        tempw = (int)fl_width(buf); // Width of current word
        linew += tempw; // pre text in tables not increasing cell width fix
        if (linew > maxlinew) maxlinew = linew;

//printf("ptr=%c head=%d pre=%d incell=%d tw=%d lw=%d %s\n",
//  *ptr,head,pre,incell,tempw,linew,buf);

        if (*ptr == '\n') { // newline char
          if (linew > mincols[col] && colspan <= 1)
            mincols[col] = linew; // ignore if colspan > 1

          if (linew > colspans[col] && colspan > 1) {
            colspans[col] = linew; // colspans
            colspans[col] -= 5 * (colspan - 1); // sub internal borders
            if (colspans[col] < 5 * (colspan - 1))
              colspans[col] = linew; // reset thin cell widths
            colspans[col + 1] = colspan;
          }
        }
        else if (*ptr == '\t') { // tab char
          ti = linew / (int)fl_width(" "); // number of chars, monospace
          tempw = 7 - (ti & 7); // number of tabs 0..7
          if (tempw) // pre tabs width fix
            linew += tempw * (int)fl_width(" ");
        }
      }
    }

    if (*ptr == '<')
    {
      tagptr = ptr; // Start of tag
      ptr ++; // inc ptr
      sp = buf; // reset sp

      if (!strncmp(ptr, "!--", 3)) { // Found "!--"
        ptr += 3;
        if ((ptr = strstr(ptr, "-->"))) { // Skip comment - rem'd != 0
          ptr += 3;
          continue;
        }
        else
          break;
      }

      while (*ptr && *ptr != '>' && !isspace((*ptr) & 255)) // was for loop
        if (sp < (buf + sizeof(buf) - 1))
          *(sp ++) = *(ptr ++); // added ()
        else
          ptr ++;

      *sp = '\0'; // Nul-terminate
      sp = buf;

      attrptr = ptr; // Start of attributes
      while (*ptr && *ptr != '>') ptr ++;
      if (*ptr == '>') ptr ++;

      btag = strlen(buf); // store strlen
      if (btag > 4) btag = 4; // limit
      for (ti = 0; ti < btag; ti ++) // abbreviate tag, to uppercase
        tag[ti] = toupper(buf[ti]);
      for (ti = btag; ti < 4; ti ++) // set chars after to nul
        tag[ti] = 0;
      if (buf[0] != '/' && btag > 3) tag[3] = 0; // eg. HTML=HTM
      btag = CMD(tag[0],tag[1],tag[2],tag[3]); // tag as int

      // End of command reached
      if (btag == CMD('A',0,0,0)) // 'A'
      {
      }
      else if (btag == CMD('B',0,0,0) ||
               btag == CMD('S','T','R',0)) // 'B' 'STRONG'
      {
        font = font_style(font, FL_BOLD);
        if (nfonts < HV_64 - 1) nfonts ++; // pushfont
        fl_font(fonts[nfonts][0] = font, fonts[nfonts][1] = fsize);
      }
      else if (btag == CMD('/','B',0,0) ||
               btag == CMD('/','S','T','R')) // '/B' '/STRONG'
      {
        if (nfonts > 0) nfonts --; // popfont
        fl_font(font = fonts[nfonts][0], fsize = fonts[nfonts][1]);
      }
      else if (btag == CMD('B','L','O',0) ||
               btag == CMD('D','L',0,0) ||
               btag == CMD('U','L',0,0) ||
               btag == CMD('O','L',0,0) ||
               btag == CMD('D','D',0,0) ||
               btag == CMD('D','T',0,0)) // 'BLOCKQUOTE' 'DL'OL'UL'
      {
        linew = 0;
        needspace = 0;
      }
      else if (btag == CMD('/','B','L','O') ||
               btag == CMD('/','D','L',0) ||
               btag == CMD('/','O','L',0) ||
               btag == CMD('/','U','L',0)) // '/BLOCKQUOTE' '/DL'/OL'/UL'
      {
        linew = 0;
        needspace = 0;
      }
      else if (btag == CMD('B','O','D',0)) // 'BODY'
      {
      }
      else if (btag == CMD('B','R',0,0)) // 'BR'
      {
        linew = 0;
        needspace = 0;
      }
      else if (btag == CMD('C','E','N',0)) // 'CENTER'
      {
        linew = 0;
        needspace = 0;
      }
      else if (btag == CMD('/','C','E','N')) // '/CENTER'
      {
        linew = 0;
        needspace = 0;
      }
      else if (btag == CMD('C','O','D',0) ||
               btag == CMD('T','T',0,0)) // 'CODE' 'TT'
      {
        font = monofont_;
        if (nfonts < HV_64 - 1) nfonts ++; // pushfont
        fl_font(fonts[nfonts][0] = font, fonts[nfonts][1] = fsize);
      }
      else if (btag == CMD('/','C','O','D') ||
               btag == CMD('/','T','T',0)) // '/CODE' '/TT'
      {
        if (nfonts > 0) nfonts --; // popfont
        fl_font(font = fonts[nfonts][0], fsize = fonts[nfonts][1]);
      }
      else if (btag == CMD('D','I','V',0)) // 'DIV'
      {
        linew = 0;
        needspace = 0;
      }
      else if (btag == CMD('/','D','I','V')) // '/DIV'
      {
        linew = 0;
        needspace = 0;
      }
      else if (btag == CMD('F','O','N',0)) // 'FONT'
      {
        if (get_attr(attrptr, "FACE", attr, sizeof(attr)))
          font = font_face(attr);

        if (get_attr(attrptr, "SIZE", attr, sizeof(attr))) {
          if (isdigit(attr[0])) // Absolute size
            fsize = (int)(fontsize_ * pow(1.2, atoi(attr) - 3.0));
          else // Relative size
            fsize = (int)(fsize * pow(1.2, atoi(attr)));
        }

        if (nfonts < HV_64 - 1) nfonts ++; // pushfont
        fl_font(fonts[nfonts][0] = font, fonts[nfonts][1] = fsize);
      }
      else if (btag == CMD('/','F','O','N')) // '/FONT'
      {
        if (nfonts > 0) nfonts --; // popfont
        fl_font(font = fonts[nfonts][0], fsize = fonts[nfonts][1]);
      }
      else if (tag[0] == 'H' && isdigit(tag[1])) // 'H1'
      {
        linew = 0;
        needspace = 0;
        font = font_style(font, FL_BOLD);
        switch (tag[1]) { // header sizes
          case '1' : fsize = 24; break;
          case '2' : fsize = 18; break;
          case '3' : fsize = 16; break;
          case '4' : fsize = 14; break;
          case '5' : fsize = 12; break;
          case '6' : fsize = 10; break;
          default : fsize = fontsize_; font = serifont_; break;
        }
        if (nfonts < HV_64 - 1) nfonts ++; // pushfont
        fl_font(fonts[nfonts][0] = font, fonts[nfonts][1] = fsize);
      }
      else if (btag == CMD('/','H',tag[2],0) && isdigit(tag[2])) // '/H1'
      {
        linew = 0;
        needspace = 0;
        if (nfonts > 0) nfonts --; // popfont
        fl_font(font = fonts[nfonts][0], fsize = fonts[nfonts][1]);
      }
      else if (btag == CMD('H','E','A',0)) // 'HEAD'
      {
        head = 1;
      }
      else if (btag == CMD('/','H','E','A')) // '/HEAD'
      {
        head = 0;
      }
      else if (btag == CMD('H','R',0,0)) // 'HR'
      {
        linew = 0;
        needspace = 0;
      }
      else if (btag == CMD('H','T','M',0)) // 'HTML'
      {
      }
      else if (btag == CMD('I',0,0,0) ||
               btag == CMD('E','M',0,0)) // 'I' 'EM'
      {
        font = font_style(font, FL_ITALIC);
        if (nfonts < HV_64 - 1) nfonts ++; // pushfont
        fl_font(fonts[nfonts][0] = font, fonts[nfonts][1] = fsize);
      }
      else if (btag == CMD('/','I',0,0) ||
               btag == CMD('/','E','M',0)) // '/I' '/EM'
      {
        if (nfonts > 0) nfonts --; // popfont
        fl_font(font = fonts[nfonts][0], fsize = fonts[nfonts][1]);
      }
      else if (btag == CMD('I','M','G',0)) // 'IMG'
      {
        if (incell) {
          imgw = imgh = 0; // reset
          if (get_attr(attrptr, "WIDTH", wattr, sizeof(wattr)))
            imgw = get_length(wattr);
          if (get_attr(attrptr, "HEIGHT", hattr, sizeof(hattr)))
            imgh = get_length(hattr);

          img = 0; // rem'd NULL
          if (get_attr(attrptr, "SRC", attr, sizeof(attr))) {
            img = get_image(attr, imgw, imgh); // Use src values
            imgw = img->w();
            imgh = img->h();
          }

          if (imgw > mincols[col]) mincols[col] = imgw;

          linew += imgw;
          if (needspace) {
            linew += (int)fl_width(" ");
            needspace = 0;
          }
          if (linew > maxlinew) maxlinew = linew;
        }
      }
      else if (btag == CMD('K','B','D',0)) // 'KBD'
      {
        font = font_style(monofont_, FL_BOLD);
        if (nfonts < HV_64 - 1) nfonts ++; // pushfont
        fl_font(fonts[nfonts][0] = font, fonts[nfonts][1] = fsize);
      }
      else if (btag == CMD('/','K','B','D')) // '/KBD'
      {
        if (nfonts > 0) nfonts --; // popfont
        fl_font(font = fonts[nfonts][0], fsize = fonts[nfonts][1]);
      }
      else if (btag == CMD('L','I',0,0)) // 'LI'
      {
        linew = 0;
        needspace = 0;
        linew += fsize; // changed 4 * fsize
      }
      else if (btag == CMD('/','L','I',0)) // '/LI'
      {
        linew = 0;
        needspace = 0;
      }
      else if (btag == CMD('N','O','S',0)) // 'NOSCRIPT'
      { // we don't support scripting so we won't skip this
      }
      else if (btag == CMD('P',0,0,0)) // 'P'
      {
        linew = 0;
        needspace = 0;
      }
      else if (btag == CMD('/','P',0,0)) // '/P'
      {
        linew = 0;
        needspace = 0;
      }
      else if (btag == CMD('P','R','E',0)) // 'PRE'
      {
        linew = 0;
        needspace = 0;
        pre = 1;
        font = monofont_;
        fsize = fontsize_;
        if (nfonts < HV_64 - 1) nfonts ++; // pushfont
        fl_font(fonts[nfonts][0] = font, fonts[nfonts][1] = fsize);
      }
      else if (btag == CMD('/','P','R','E')) // '/PRE'
      {
        linew = 0;
        needspace = 0;
        pre = 0;
        if (nfonts > 0) nfonts --; // popfont
        fl_font(font = fonts[nfonts][0], fsize = fonts[nfonts][1]);
      }
      else if (btag == CMD('S','C','R',0)) // 'SCRIPT'
      {
        while (ptr) { // skip scripting
          ptr = strstr(ptr, "</");
          if (!strncasecmp(ptr, "</SCRIPT>", 9)) break;
        }

        if (ptr) { // found </script>
          ptr += 9;
          continue;
        }
        else // not found
          break;
      }
      else if (btag == CMD('T','A','B',0)) // 'TABLE'
      {
        linew = 0; // cell width not reset before nested table fix
        needspace = 0;

        if (tagptr > tp) { // nested table
          if (rc < HV_16) // limit recursive function
            endp = format_table(scalew, columns, tagptr, xx, rc + 1);
          if (endp) ptr = endp; // to skip nested table

          for (ti = 0; ti < HV_64; ti ++)
            if (columns[ti] == 0) break; // num columns
          scalew += ti * 6; // add internal borders

          if (scalew > mincols[col]) // set nested width
            mincols[col] = scalew;

          linew += scalew;
          if (linew > maxlinew) maxlinew = linew;

          linew = 0; // cell width not reset after nested table fix
          needspace = 0;
        }
      }
      else if (btag == CMD('/','T','A','B')) // '/TABLE'
      {

//printf("%s col = %d, colspan = %d, numcells = %d\n",
//  buf, col, colspan, numcells);

        if (col >= 0) { // This is a hack to support COLSPAN
          ti = colspan; // ignore if colspan > 1
          maxlinew /= colspan;
          while (colspan > 0) {
            if (maxlinew > maxcols[col] && ti <= 1)
              maxcols[col] = maxlinew;
            col ++;
            colspan --;
          }
        }
        endp = ptr; // store nested table end ptr
        break; // exit for (ptr = tp ...) loop
      }
      else if (btag == CMD('T','D',0,0) ||
               btag == CMD('T','H',0,0)) // 'TD' 'TH'
      {

//printf("BEFORE col = %d, colspan = %d, numcells = %d\n",
//  col, colspan, numcells);

        if (col >= 0) { // This is a hack to support COLSPAN
          ti = colspan; // ignore if colspan > 1
          maxlinew /= colspan;
          while (colspan > 0) {
            if (maxlinew > maxcols[col] && ti <= 1)
              maxcols[col] = maxlinew;
            col ++;
            colspan --;
          }
        }
        else
          col ++;

        colspan = 1; // Reset
        if (get_attr(attrptr, "COLSPAN", attr, sizeof(attr)))
          colspan = atoi(attr);

//printf("AFTER col = %d, colspan = %d, numcells = %d\n",
//  col, colspan, numcells);

        if (col + colspan >= numcells)
          numcells = col + colspan;

        linew = 0;
        needspace = 0;
        incell = 1;

        if (btag == CMD('T','H',0,0)) // th
          font = font_style(serifont_, FL_BOLD);
        else
          font = serifont_;
        fsize = fontsize_;

        nfonts = 0; // pop all fonts off stack, no need for anything more
        if (nfonts < HV_64 - 1) nfonts ++; // pushfont
        fl_font(fonts[nfonts][0] = font, fonts[nfonts][1] = fsize);

        maxlinew = 0; // Reset
        if (get_attr(attrptr, "WIDTH", attr, sizeof(attr))) {
          maxlinew = get_length(attr, hsize_ - xx);
          if (maxlinew > widths[col])
            widths[col] = maxlinew; // store widths
        }

//printf("maxlinew = %d\n", maxlinew);

      }
      else if (btag == CMD('/','T','D',0) ||
               btag == CMD('/','T','H',0)) // '/TD' '/TH'
      {
        incell = 0;
      }
      else if (btag == CMD('T','I','T',0)) // 'TITLE'
      {
      }
      else if (btag == CMD('T','R',0,0)) // 'TR'
      {

//printf("%s col = %d, colspan = %d, numcells = %d\n",
//  buf, col, colspan, numcells);

        if (col >= 0) { // This is a hack to support COLSPAN
          ti = colspan; // ignore if colspan > 1
          maxlinew /= colspan;
          while (colspan > 0) {
            if (maxlinew > maxcols[col] && ti <= 1)
              maxcols[col] = maxlinew;
            col ++;
            colspan --;
          }
        }

        linew = 0;
        needspace = 0;
        incell = 0;
        col = -1;
        maxlinew = 0;
      }
      else if (btag == CMD('/','T','R',0)) // '/TR'
      {

//printf("%s col = %d, colspan = %d, numcells = %d\n",
//  buf, col, colspan, numcells);

        if (col >= 0) { // This is a hack to support COLSPAN
          ti = colspan; // ignore if colspan > 1
          maxlinew /= colspan;
          while (colspan > 0) {
            if (maxlinew > maxcols[col] && ti <= 1)
              maxcols[col] = maxlinew;
            col ++;
            colspan --;
          }
        }

        linew = 0;
        needspace = 0;
        incell = 0;
        col = -1;
        maxlinew = 0;
      }
      else if (btag == CMD('U',0,0,0)) // 'U'
      {
      }
      else if (btag == CMD('V','A','R',0)) // 'VAR'
      {
        font = font_style(monofont_, FL_ITALIC);
        if (nfonts < HV_64 - 1) nfonts ++; // pushfont
        fl_font(fonts[nfonts][0] = font, fonts[nfonts][1] = fsize);
      }
      else if (btag == CMD('/','V','A','R')) // '/VAR'
      {
        if (nfonts > 0) nfonts --; // popfont
        fl_font(font = fonts[nfonts][0], fsize = fonts[nfonts][1]);
      }
      else if (btag == CMD('A','B','B',0) || // 'ABBR'
               btag == CMD('A','C','R',0) || // 'ACRONYM'
               btag == CMD('A','D','D',0) || // 'ADDRESS'
               btag == CMD('A','P','P',0) || // 'APPLET'
               btag == CMD('A','R','E',0) || // 'AREA'
               btag == CMD('B','A','S',0) || // 'BASE' 'BASEFONT'
               btag == CMD('B','D','O',0) || // 'BDO'
               btag == CMD('B','G','S',0) || // 'BGSOUND'
               btag == CMD('B','I','G',0) || // 'BIG'
               btag == CMD('B','L','I',0) || // 'BLINK'
               btag == CMD('B','U','T',0) || // 'BUTTON'
               btag == CMD('C','A','P',0) || // 'CAPTION'
               btag == CMD('C','I','T',0) || // 'CITE'
               btag == CMD('C','O','L',0) || // 'COL' 'COLGROUP'
               btag == CMD('D','E','L',0) || // 'DEL'
               btag == CMD('D','F','N',0) || // 'DFN'
               btag == CMD('D','I','R',0) || // 'DIR'
               btag == CMD('E','M','B',0) || // 'EMBED'
               btag == CMD('F','I','E',0) || // 'FIELDSET'
               btag == CMD('F','O','R',0) || // 'FORM'
               btag == CMD('F','R','A',0) || // 'FRAME' 'FRAMESET'
               btag == CMD('I','F','R',0) || // 'IFRAME'
               btag == CMD('I','N','P',0) || // 'INPUT'
               btag == CMD('I','N','S',0) || // 'INS'
               btag == CMD('I','S','I',0) || // 'ISINDEX'
               btag == CMD('L','A','B',0) || // 'LABEL'
               btag == CMD('L','E','G',0) || // 'LEGEND'
               btag == CMD('L','I','N',0) || // 'LINK'
               btag == CMD('M','A','P',0) || // 'MAP'
               btag == CMD('M','A','R',0) || // 'MARQUEE'
               btag == CMD('M','E','N',0) || // 'MENU'
               btag == CMD('M','E','T',0) || // 'META'
               btag == CMD('M','U','L',0) || // 'MULTICOL'
               btag == CMD('N','O','B',0) || // 'NOBR'
               btag == CMD('N','O','F',0) || // 'NOFRAMES'
               btag == CMD('O','B','J',0) || // 'OBJECT'
               btag == CMD('O','P','T',0) || // 'OPTGROUP' 'OPTION'
               btag == CMD('P','A','R',0) || // 'PARAM'
               btag == CMD('Q',0,0,0) || // 'Q'
               btag == CMD('S',0,0,0) || // 'S'
               btag == CMD('S','A','M',0) || // 'SAMP'
               btag == CMD('S','E','L',0) || // 'SELECT'
               btag == CMD('S','M','A',0) || // 'SMALL'
               btag == CMD('S','P','A',0) || // 'SPACER' 'SPAN'
               btag == CMD('S','T','R',0) || // 'STRIKE'
               btag == CMD('S','T','Y',0) || // 'STYLE'
               btag == CMD('S','U','B',0) || // 'SUB'
               btag == CMD('S','U','P',0) || // 'SUP'
               btag == CMD('T','B','O',0) || // 'TBODY'
               btag == CMD('T','E','X',0) || // 'TEXTAREA'
               btag == CMD('T','F','O',0) || // 'TFOOT'
               btag == CMD('T','H','E',0) || // 'THEAD'
               btag == CMD('W','B','R',0) || // 'WBR'
               btag == CMD('X','M','P',0)) // 'XMP'
          ; // unsupported tags
        else if (tag[0] == '!' && isalpha(tag[1])) // '!DOCTYPE' etc
          ;
        else if (tag[0] == '?' && isalpha(tag[1])) // '?XMP' etc
          ;
        else if (tag[0] == '/' && isalpha(tag[1])) // unrecognized end tag
          ;
        else if (!head) // unrecognized tag so draw it
        {
          linew += (int)fl_width("<"); // add width of '<' char
          ptr = tagptr + 1; // start of tag + 1
        }
    } // if (*ptr == '<')

    else if (*ptr == '\n' && pre) // '\n' in pre
    {
      linew = 0;
      needspace = 0;
      ptr ++;
    }
    else if (isspace((*ptr) & 255)) // ' ' '\t'\n'\v'\f'\r' chars
    {
      needspace = 1;
      ptr ++;
    }
    else if (*ptr == '&' && sp < (buf + sizeof(buf) - 1)) // '&' char ref
    {
      ptr ++;
      qch = quote_char(ptr);

      if (qch < 0) // Not char ref
        *(sp ++) = '&'; // added ()
      else {
        *(sp ++) = qch; // added ()
        ptr = strchr(ptr, ';') + 1;
      }
    }
    else // Other char
    {
      if (sp < (buf + sizeof(buf) - 1))
        *(sp ++) = *(ptr ++); // added ()
      else
        ptr ++;
    }
  } // for (ptr = tp ...)

  // Now that we have scanned the entire table,
  // adjust the table and cell widths to fit on the screen
  if (numcells == 0) return endp;

  // colspan widths
  for (col = 0; col < numcells; col ++)
  {
    if (colspans[col] > 0) {  // check width of colspans
      colspanw = colspans[col]; // colspan width
      colspan = colspans[col + 1]; // colspan

      for (ti = col; ti < col + colspan; ti ++)
        mincellw += mincols[ti]; // total width of mincols

      if (colspans[col] > mincellw) { // pad columns with colspans
        for (ti = col, maxcellw = 0; ti < col + colspan; ti ++) {
          if (maxcols[ti] == 0) maxcols[ti] = 1; // set min width
          maxcellw += maxcols[ti]; // total width of cells
          colspanw -= mincols[ti]; // colspans remainder width
        }
        if (!maxcellw) maxcellw = 1; // avoid divide by zero
        for (ti = col; ti < col + colspan; ti ++) {
          tempw = (maxcols[ti] * 100) / maxcellw; // as percent
          scalew = (colspanw * tempw) / 100; // as value
          maxcols[ti] = mincols[ti] + scalew;
        }
      }
      col += colspan - 1; // skip past colspan
    }
  }

  // get min width of table from colspans
  for (col = 0, mincellw = 0; col < numcells; col ++) {
    if (colspans[col] > 0) {
      mincellw += colspans[col]; // min table width
      col += colspans[col + 1] - 1; // skip past colspan
    }
    else
      mincellw += mincols[col];
  }

  if (mincellw > hwidth) { // if table wider than window
    tsize = mincellw;
    tsize += 6 * numcells;
    tsize += xx + 4; // add 4 pixels in case width is hsize_
    if (tsize > hsize_) tsize = hsize_;
  }
  else
    tsize = hwidth;

  tw = 0; // Reset
  if (get_attr(tp + 6, "WIDTH", attr, sizeof(attr)))
    tw = get_length(attr, tsize - xx);

//printf("numcells = %d, tw = %d, tsize = %d\n", numcells, tw, tsize);

  if (tw == 0) // get max table width
    maxlinew = tsize - xx;
  else
    maxlinew = tw;

  maxlinew -= 6 * numcells; // sub internal borders
  tw -= 6 * numcells;
  if (tsize > hwidth) { // if table wider than window sub 4 pixels
    maxlinew -= 4; // this is needed
    tw -= 4;
  }
  if (tw < 0) tw = 0;

//printf(" tw = %d, maxlinew = %d, xx = %d, hsize_ = %d, mincellw = %d\n",
//  tw, maxlinew, xx, hsize_, mincellw);

  if (mincellw > maxlinew) // resize if colspans too wide
    tw = mincellw + xx;

  for (col = 0, linew = 0; col < numcells; col ++)
    linew += maxcols[col]; // Add up the widths
  if (!linew) linew = 1; // avoid divide by zero

//for (col = 0; col < numcells; col ++)
//  printf("    maxcols[%d] = %d, mincols[%d] = %d, widths[%d] = %d, colspans[%d] = %d\n",
//    col, maxcols[col], col, mincols[col],
//    col, widths[col], col, colspans[col]);
//printf("linew = %d, w() = %d\n", linew, w());

  scalew = tw;
  if (tw == 0) { // Adjust the width if needed
    if (linew > maxlinew)
      scalew = maxlinew;
    else
      scalew = linew;
  }

  if (linew < scalew) // Table width is too small
  {

//printf("Scaling table up to scalew %d from linew %d\n", scalew, linew);

    scalew -= linew; // get remainder width

//printf("adjusted scalew = %d\n", scalew);

    // scale table up
    for (col = 0; col < numcells; col ++) {
      tempw = (maxcols[col] * 100) / linew; // as percent
      maxcols[col] += (tempw * scalew) / 100; // as value
    }

    // td widths
    for (col = 0, ti = 0, tempw = 0; col < numcells; col ++) {
      if (widths[col] > 0 && mincols[col] > widths[col]) {
        tempw += maxcols[col] - mincols[col]; // remainder
        maxcols[col] = mincols[col]; // set to minwidth
      }
      if (!widths[col]) ti ++; // unspecified widths
    }
    if (!ti) ti = 1; // avoid divide by zero
    for (col = 0; col < numcells; col ++) {
      if (!widths[col])
        maxcols[col] += tempw / ti; // add remainder fractions
    }
  }
  else if (linew > scalew) // Table width is too big
  {

//printf("Scaling table down to scalew %d from linew %d\n", scalew, linew);

    for (col = 0; col < numcells; col ++) {
      linew -= mincols[col];
      scalew -= mincols[col];
    }
    if (!linew) linew = 1; // avoid divide by zero

//printf("adjusted linew = %d, scalew = %d\n", linew, scalew);

      for (col = 0; col < numcells; col ++) {
        maxcols[col] -= mincols[col];
        maxcols[col] = scalew * maxcols[col] / linew;
        maxcols[col] += mincols[col];
      }
  }
  else if (tw == 0) // Not sure if this is needed
    tw = linew;

  if (tw == 0) // tw still zero
    for (col = 0; col < numcells; col ++)
      tw += maxcols[col];

  for (col = 0, maxcellw = 0; col < numcells; col ++)
    maxcellw += maxcols[col]; // total width of cells

  if (tw > maxcellw) { // add remainder to last column
    tempw = tw - maxcellw;
    maxcols[numcells - 1] += tempw;
  }

//printf("FINAL tw = %d\n", tw);
//for (col = 0; col < numcells; col ++)
//  printf("    maxcols[%d] = %d\n", col, maxcols[col]);

  return endp; // table end pointer

} // Fl_Help_View::format_table()

//
// Fl_Help_View::free_data() - Free memory used for the document.
//

void Fl_Help_View::free_data()
{
  if (value_) // Release all images
  {
    const char *ptr, // Pointer into block
      *attrptr; // Start of attributes ptr
    char *sp, // Pointer into buffer
      buf[1024], // Text buffer
      attr[1024], // Attribute buffer
      wattr[1024], // Width attribute buffer
      hattr[1024]; // Height attribute buffer
    Fl_Shared_Image *img = 0; // Shared image - rem'd NULL
    int imgw = 0, // Image width
      imgh = 0; // Image height

    for (ptr = value_; *ptr; )
    {
      if (*ptr == '<')
      {
        ptr ++;

        if (!strncmp(ptr, "!--", 3)) { // Found "!--"
          ptr += 3;
          if ((ptr = strstr(ptr, "-->"))) { // Skip comment - rem'd != 0
            ptr += 3;
            continue;
          }
          else
            break;
        }

        sp = buf;

        while (*ptr && *ptr != '>' && !isspace((*ptr) & 255))
          if (sp < (buf + sizeof(buf) - 1))
            *(sp ++) = *(ptr ++); // added ()
          else
            ptr ++;

        *sp = '\0'; // Nul-terminate

        attrptr = ptr; // Start of attributes
        while (*ptr && *ptr != '>') ptr ++;
        if (*ptr == '>') ptr ++;

        if (!strcasecmp(buf, "IMG"))
        {
          imgw = imgh = 0; // reset
          if (get_attr(attrptr, "WIDTH", wattr, sizeof(wattr)))
            imgw = get_length(wattr);
          if (get_attr(attrptr, "HEIGHT", hattr, sizeof(hattr)))
            imgh = get_length(hattr);

          img = 0; // rem'd NULL
          if (get_attr(attrptr, "SRC", attr, sizeof(attr)))
          { // Release the image twice to free it from memory
            img = get_image(attr, imgw, imgh);
            // Seb was here - freeing a broken_image causes an XFreePixmap crash
            if((void*)img != &broken_image) {
              img->release();
              if(img->refcount() > 0) img->release();
            }
          }
        }
      } // if (*ptr == '<')
      else
        ptr ++;
    } // for (ptr = value_ ...)

    free((void *)value_);
    value_ = 0; // reset

  } // if (value_)
  
  if (!d->isnew) { // is new page
    free((void *)d->csstext); // values
    free((void *)d->cssword);
    free((void *)d->cssurl);
    d->csstext = 0;
    d->cssword = 0;
    d->cssurl = 0;
    d->cssurllen = 0; // lengths
    d->csswordlen = 0;
    d->csstextlen = 0;
    serifont_ = FL_TIMES; // default font
  }
  d->isnew = 1; // set
  
  // Free all of the arrays
  if (nblocks_) { // Free blocks
    free(blocks_);
    ablocks_ = 0;
    nblocks_ = 0;
    blocks_ = 0;
  }

  if (nlinks_) { // Free links
    free(links_);
    alinks_ = 0;
    nlinks_ = 0;
    links_ = 0;
  }

  if (ntargets_) { // Free targets
    free(d->targets);
    atargets_ = 0;
    ntargets_ = 0;
    d->targets = 0;
  }

} // Fl_Help_View::free_data()

//
// Fl_Help_View::get_align() - Get an alignment attribute.
//

int // O - Alignment
Fl_Help_View::get_align(const char *ap, // I - Start of attrs pointer
                        int da) // I - Default alignment
{
  char buf[255]; // Alignment value

  if (!get_attr(ap, "ALIGN", buf, sizeof(buf))) // rem'd == 0
    return da; // no align attribute

  if (!strcasecmp(buf, "CENTER"))
    return CENTER; // 0
  else if (!strcasecmp(buf, "RIGHT"))
    return RIGHT; // -1
  else
    return LEFT; // 1

} // Fl_Help_View::get_align()

//
// Fl_Help_View::get_attr() - Get an attribute value from the string.
//

const char * // O - Pointer to buf or NULL
Fl_Help_View::get_attr(const char *ap, // I - Start of attributes pointer
                       const char *np, // I - Name of attribute
                       char *buf, // O - Buffer for attribute value
                       int sb) // I - Sizeof buf
{
  char name[255], // Name from string
    *ptr, // Pointer into name or value
    quote; // Quote char

  buf[0] = '\0';

  while (*ap && *ap != '>')
  {
    while (isspace((*ap) & 255)) ap ++;

    if (*ap == '>' || !*ap) return 0; // rem'd NULL

    for (ptr = name; *ap && !isspace((*ap) & 255) && *ap != '=' && *ap != '>'; )
      if (ptr < (name + sizeof(name) - 1)) // Read in the attribute name
        *(ptr ++) = *(ap ++); // added ()
      else
        ap ++;

    *ptr = '\0';

    if (isspace((*ap) & 255) || !*ap || *ap == '>')
      buf[0] = '\0';
    else
    {
      if (*ap == '=') ap ++;

      for (ptr = buf; *ap && !isspace((*ap) & 255) && *ap != '>'; )
        if (*ap == '\'' || *ap == '\"') { // Read in the attribute value
        quote = *(ap ++); // added () same as quote=*ap;ap++;

        while (*ap && *ap != quote)
          if ((ptr - buf + 1) < sb) // Sizeof buf
            *(ptr ++) = *(ap ++); // added () same as *ptr=*ap;ptr++;ap++;
          else
            ap ++;

        if (*ap == quote) ap ++;
      }
      else if ((ptr - buf + 1) < sb) // Sizeof buf
        *(ptr ++) = *(ap ++); // added ()
      else
        ap ++;

      *ptr = '\0';
    }

    if (!strcasecmp(np, name)) // Name of attribute matches
      return buf;
    else
      buf[0] = '\0';

    if (*ap == '>') return 0; // rem'd NULL
  } // while (*ap ...)

  return 0; // rem'd NULL

} // Fl_Help_View::get_attr()

//
// Fl_Help_View::get_color() - Get an alignment attribute.
//

Fl_Color // O - Color value
Fl_Help_View::get_color(const char *np, // I - Color name
                        Fl_Color dc) // I - Default color value
{
  int ti = 0, // Looping var
    rgb = 0, red = 0, green = 0, blue = 0, // RGB values
    temp = 0; // temp var

  static const struct { // Color name table
    const char *name;
    int r, g, b; // Red, green, blue
  }
  colors[] = {
    { "black",   0x00, 0x00, 0x00 },
    { "red",     0xff, 0x00, 0x00 },
    { "green",   0x00, 0x80, 0x00 },
    { "yellow",  0xff, 0xff, 0x00 },
    { "blue",    0x00, 0x00, 0xff },
    { "magenta", 0xff, 0x00, 0xff },
    { "fuchsia", 0xff, 0x00, 0xff },
    { "cyan",    0x00, 0xff, 0xff },
    { "aqua",    0x00, 0xff, 0xff },
    { "white",   0xff, 0xff, 0xff },
    { "gray",    0x80, 0x80, 0x80 },
    { "grey",    0x80, 0x80, 0x80 },
    { "lime",    0x00, 0xff, 0x00 },
    { "maroon",  0x80, 0x00, 0x00 },
    { "navy",    0x00, 0x00, 0x80 },
    { "olive",   0x80, 0x80, 0x00 },
    { "purple",  0x80, 0x00, 0x80 },
    { "silver",  0xc0, 0xc0, 0xc0 },
    { "teal",    0x00, 0x80, 0x80 }
  };

  if (!np || !np[0]) return dc; // No name

  if (np[0] != '#') // check no hash
    for (ti = 0, rgb = 0; np[ti] != '\0'; ti ++) {
      if (isalpha(np[ti])) rgb |= 1; // name if 1
      if (isdigit(np[ti])) rgb |= 2; // decimal if 2
      if (rgb == 3) break; // hex with no hash
  }

  if (np[0] == '#' || rgb == 3) // Do hex color lookup
  {
    if (rgb == 3) temp = 0; else temp = 1; // set name offset
    rgb = strtol(np + temp, 0, 16); // rem'd NULL

    if (strlen(np) > 4) { // 24-bit
      red = rgb >> 16;
      green = (rgb >> 8) & 255;
      blue = rgb & 255;
    }
    else { // 16-bit?
      red = (rgb >> 8) * 17;
      green = ((rgb >> 4) & 15) * 17;
      blue = (rgb & 15) * 17;
    }
    return fl_rgb_color((uchar)red, (uchar)green, (uchar)blue);
  }
  else // Do color name lookup
  {
    temp = sizeof(colors) / sizeof(colors[0]);
    for (ti = 0; ti < temp; ti ++)
      if (!strcasecmp(np, colors[ti].name)) {
        return fl_rgb_color(colors[ti].r, colors[ti].g, colors[ti].b);
      }
    return dc; // Color not found
  }

} // Fl_Help_View::get_color()

//
// Fl_Help_View::get_css_value() - Outputs the value of a given css property to buffer.
//

int // O - true if value exists, false otherwise
Fl_Help_View::get_css_value(const char *sp, // I - selector
                          const char *pp, // I - property
                          char *vp) // O - value
{
  int ti = 0, tj = 0, tk = 0, tword = 0, tcount = 0, // temp vars
    issel = 0, isblock = 0, isclass = 0, order = 0, // misc vars
    si = 0, slen = 0, plen = 0, blen = 0, vlen = 0;
  char *tp = 0; // ptr

  if (strchr(pp, '-')) blen = strchr(pp, '-') - pp; // base property length
  plen = strlen(pp); // property length
  slen = strlen(sp); // selector length
  if (strstr(sp, ".")) isclass = 1; // class ptr
  
  while (tk < 2) { // find selector
  
    for (ti = 0; ti < d->csswordlen; ti ++) { // word loop
      tword = *(d->cssword + ti); // word offset
      tp = d->csstext + tword; // word ptr
      if (isblock && *tp == '}') { issel = 0; isblock = 0; break; } // close block
      
      if (isblock) {
        if (!strncasecmp(tp, pp, plen)) { // full property
          for (tj = *(d->cssword + ti + 1); tcount < 255; tj ++) { // value is next word
            if (*(d->csstext + tj) == ';') break; // end of value
            else {
              *(vp + tcount) = *(d->csstext + tj); // copy value
              tcount ++; // count word length
            }
          }
          *(vp + tcount) = '\0'; // nul-terminate
          return 1; // success
        }
        else if (blen) { // base property
          if (!strncasecmp(tp, pp, blen) && !si) si = ti; // store index
        }
      }
      
      if (issel && *tp == '{') isblock = 1; // open block
      if (!isblock && !strncasecmp(tp, sp, slen)) {
        if (isclass) // source has class
          issel = 2; // found match
        else if (*(tp + slen) != '.')
          issel = 1; // match if target no class
      }
    }
    
    if (!issel && isclass) { // class not found, find selector
      slen = strstr(sp, ".") - sp; // remove class name
      isclass = 0; // reset
    }
      
    tk ++; // second try without class name
  }

  if (si) { // found base but not full property
    for (tj = *(d->cssword + si + 1); tcount < 255; tj ++) { // value is next word
      if (*(d->csstext + tj) == ';') break; // end of value
      else {
        *(vp + tcount) = *(d->csstext + tj); // copy value
        if (isspace(*(vp + tcount))) *(vp + tcount) = '\0'; // split words
        tcount ++; // count word length
      }
    }
    *(vp + tcount) = '\0'; // nul-terminate
    
    for (tj = 0, ti = 0; tj < tcount; tj ++) { // shorthand recognition rules
      if (*(vp + tj) == '\0') ti = 0; else ti ++;
      if (ti == 1) { // first letter of word
        vlen = strlen(vp + tj); // word length
        if (!strncasecmp(pp, "background", 10)) // background shorthand
        {
          if (!strncasecmp(vp + tj, "none", 4) ||
              !strncasecmp(vp + tj, "left", 4) ||
              !strncasecmp(vp + tj, "right", 5) ||
              !strncasecmp(vp + tj, "inherit", 7)) order = 0; // nothing
          else if (*(vp + tj) == '#' ||
                   !strncasecmp(vp + tj, "rgb", 3) ||
                   !strncasecmp(vp + tj, "transparent", 11)) order = 1; // color
          else if (!strncasecmp(vp + tj, "url", 3)) order = 2; // image
          else if (!strncasecmp(vp + tj, "repeat", 6) ||
                   !strncasecmp(vp + tj, "no-repeat", 9)) order = 3; // repeat
          else if (!strncasecmp(vp + tj, "scroll", 6) ||
                   !strncasecmp(vp + tj, "fixed", 5)) order = 4; // attachment
          else if (isdigit(*(vp + tj)) ||
                   !strncasecmp(vp + tj, "top", 3) ||
                   !strncasecmp(vp + tj, "center", 6) ||
                   !strncasecmp(vp + tj, "bottom", 6)) { // position
            // todo: count words to ; if one then replace \0 with ' ' - or just replace next '\0'
            order = 5; }
          else if (!strncasecmp(vp + tj, "black", 5) ||
                   !strncasecmp(vp + tj, "red", 3) ||
                   !strncasecmp(vp + tj, "green", 5) ||
                   !strncasecmp(vp + tj, "yellow", 6) ||
                   !strncasecmp(vp + tj, "blue", 4) ||
                   !strncasecmp(vp + tj, "magenta", 7) ||
                   !strncasecmp(vp + tj, "fuchsia", 7) ||
                   !strncasecmp(vp + tj, "cyan", 4) ||
                   !strncasecmp(vp + tj, "aqua", 4) ||
                   !strncasecmp(vp + tj, "white", 5) ||
                   !strncasecmp(vp + tj, "gray", 4) ||
                   !strncasecmp(vp + tj, "grey", 4) ||
                   !strncasecmp(vp + tj, "lime", 4) ||
                   !strncasecmp(vp + tj, "maroon", 6) ||
                   !strncasecmp(vp + tj, "navy", 4) ||
                   !strncasecmp(vp + tj, "olive", 5) ||
                   !strncasecmp(vp + tj, "purple", 6) ||
                   !strncasecmp(vp + tj, "silver", 6) ||
                   !strncasecmp(vp + tj, "teal", 4)) order = 1; // color name
          if (!strncmp(pp, "background-color", 16) && order == 1) break;
          if (!strncmp(pp, "background-image", 16) && order == 2) break;
          if (!strncmp(pp, "background-repeat", 17) && order == 3) break;
          if (!strncmp(pp, "background-attachment", 21) && order == 4) break;
          if (!strncmp(pp, "background-position", 19) && order == 5) break;
          order = 0; // reset
        }
        else if (!strncasecmp(pp, "border", 6)) // border shorthand
        {
          // todo: border-width-style-color
        }
        else if (!strncasecmp(pp, "font", 4)) // font shorthand
        {
          if (isdigit(*(vp + tj))) { // number
            if (vlen == 3 && isdigit(*(vp + tj + 2))) order = 3; // weight
            else order = 4; // size
          }
          else if (isalpha(*(vp + tj))) { // word
            if (!strncasecmp(vp + tj, "normal", 6) ||
                !strncasecmp(vp + tj, "lighter", 7) || // weight
                !strncasecmp(vp + tj, "inherit", 7)) order = 0; // nothing
            else if (!strncasecmp(vp + tj, "italic", 6) ||
                     !strncasecmp(vp + tj, "oblique", 7)) order = 1; // style
            else if (!strncasecmp(vp + tj, "small-caps", 10)) order = 2; // variant
            else if (!strncasecmp(vp + tj, "bold", 4)) order = 3; // weight
            else if (!strncasecmp(vp + tj, "x-", 2) ||
                     !strncasecmp(vp + tj, "xx-", 3) ||
                     !strncasecmp(vp + tj, "small", 5) ||
                     !strncasecmp(vp + tj, "medium", 6) ||
                     !strncasecmp(vp + tj, "large", 5)) order = 4; // size
            else order = 5; // family
          }
          if (!strncmp(pp, "font-style", 10) && order == 1) break;
          if (!strncmp(pp, "font-variant", 12) && order == 2) break;
          if (!strncmp(pp, "font-weight", 11) && order == 3) break;
          if (!strncmp(pp, "font-size", 9) && order == 4) break;
          if (!strncmp(pp, "font-family", 11) && order == 5) break;
          order = 0; // reset
        }
        else if (!strncasecmp(pp, "margin", 6) ||
                 !strncasecmp(pp, "padding", 7)) // margin/padding shorthand
        {
          // todo: margin-top-right-bottom-left - padding has same keywords
        }
        else if (!strncasecmp(pp, "outline", 7)) // outline shorthand
        {
          // todo: outline-color-style-width
        }
      }
    }
    
    if (order && tj) { // copy word to start of buffer
      for (ti = 0; ti < vlen; ti ++) *(vp + ti) = *(vp + tj + ti);
      *(vp + vlen) = '\0'; // nul-terminate
    }
    return 1; // success
  }
  
  return 0; // failure
  
} // Fl_Help_View::get_css_value

//
// Fl_Help_View::get_font_size() - Get a height value for font-size.
//

int // O - height value
Fl_Help_View::get_font_size(const char *hp) // I - height pointer
{
  int ti = 0, // temp var
    upos = 0, // unit position - %,in,cm,mm,em,ex,pt,pc,px
    slen = 0, // src length
    val = 0; // integer value
  char buf[8]; // buffer
  
  if (!hp || !hp[0]) return 0; // no height

  slen = strlen(hp);
  if (slen > 8) slen = 8; // max length
  for (val = 0; val < slen; val ++) {
    if (isalpha(*(hp + val)) || *(hp + val) == '%') {
      upos = val;
      break; // unit position
    }
  }
  if (!upos) val = slen; // no unit
  for (ti = 0; ti < val; ti ++)
    buf[ti] = *(hp + ti); // copy value to buffer
    
  val = atoi(buf); // to int
  if (*(hp + upos) == '%') { // percent
    if (val > 100) val = 100;
    else if (val < 0) val = 0;
    val = (val * fontsize_) / 100;
  }
  else if (!strncmp(hp + upos, "em", 2)) // em
    val = val * fontsize_;
  else if (!strncasecmp(hp + upos, "ex", 2)) // ex
    val = fontsize_ / val;
  // note: pt, pica, cm, mm, in are all relative to screen size
  // currently they equate to px - http://hsivonen.iki.fi/units
  
  if (val > 48) val = 48; // max
  else if (val < 8) val = 8; // min
  return val;
  
} // Fl_Help_View::get_font_size()

//
// Fl_Help_View::get_image() - Get an inline image.
//

Fl_Shared_Image * // O - Image pointer
Fl_Help_View::get_image(const char *np, // Image filename
                        int iw, // Image width
                        int ih) // Image height
{
  const char *namep; // Local filename
  char dir[1024], // Current directory
    temp[1024], // Temporary filename
    *tptr, *dirp; // Pointer into temporary name
  Fl_Shared_Image *imgp; // Image pointer

  // See if the image can be found
  if (strchr(directory_, ':') && !strchr(np, ':')) // rem'd != 0 and == 0
  { // dir has ':' char and np doesn't
    if (np[0] == '/') { // Has sub-path
      strlcpy(temp, directory_, sizeof(temp));
      if ((tptr = strrchr(strchr(temp, ':') + 3, '/')) != 0) // ?
        strlcpy(tptr, np, sizeof(temp)-(tptr - temp)); // ?
      else // ? - dir shouldn't have a filename..
        strlcat(temp, np, sizeof(temp));
    }
    else // Just filename
      snprintf(temp, sizeof(temp), "%s/%s", directory_, np);

    if (link_)
      namep = (*link_)(this, temp);
    else
      namep = temp;
  }
  else if (np[0] != '/' && !strchr(np, ':')) // rem'd == 0
  {
    if (directory_[0])
      snprintf(temp, sizeof(temp), "%s/%s", directory_, np);
    else {
      dirp = getcwd(dir, sizeof(dir)); // No end '/' char - can be wrong..
      snprintf(temp, sizeof(temp), "%s/%s", dir, np);
    }

    if (link_)
      namep = (*link_)(this, temp);
    else
      namep = temp;
  }
  else if (link_)
    namep = (*link_)(this, np);
  else
    namep = np;

//if (namep) printf(" get_image namep=(%s)\n",namep);
//printf(" get_image d->path=(%s)\n",d->path);

  if (d->ispath) { // path is used
    strlcpy(temp, d->path, sizeof(temp));
    if ((tptr = strrchr(temp, '/'))) // tptr valid, add filename
      strlcpy(tptr + 1, np, sizeof(temp)-(tptr + 1 - temp));
    namep = temp;
  }

  if (!namep) return 0;

  if (!strncmp(namep, "file:", 5)) namep += 5; // Adjust for file:

  if (!(imgp = Fl_Shared_Image::get(namep, iw, ih))) // rem'd == 0
    imgp = (Fl_Shared_Image *)&broken_image;

  return imgp;

} // Fl_Help_View::get_image()

//
// Fl_Help_View::get_length() - Get a length value either absolute or %.
//

int // O - Length value
Fl_Help_View::get_length(const char *lp) // I - Length pointer
{
  int val = 0; // Integer value

  if (!lp || !lp[0]) return 0; // No length

  val = atoi(lp);
  if (lp[strlen(lp) - 1] == '%') { // Calc percent
    if (val > 100) val = 100;
    else if (val < 0) val = 0;
    val = val * (hsize_ - Fl::scrollbar_size()) / 100; // val from hsize_
  }

  return val;

} // Fl_Help_View::get_length()

//
// Fl_Help_View::get_length() - Get a length value of a given width.
//

int // O - Length value
Fl_Help_View::get_length(const char *lp, // I - Length pointer
                         int hw) // I - horizontal width
{
  int val = 0; // Integer value

  if (!lp || !lp[0]) return 0; // No length

  val = atoi(lp);
  if (lp[strlen(lp) - 1] == '%') { // Calc percent
    if (val > 100) val = 100;
    else if (val < 0) val = 0;
    val = val * hw / 100; // get value from hw
  }

  return val;

} // Fl_Help_View::get_length()

//
// Fl_Help_View::gettopline() - Get current topline in document.
//

int Fl_Help_View::gettopline() // O - Current topline
{
  return d->top;
}

//
// Fl_Help_View::handle() - Handle events in the widget.
//

int // O - True if we handled it, false otherwise
Fl_Help_View::handle(int event) // I - Event to handle
{
  int xx = 0, yy = 0, // Mouse positions
    hh = 0; // window height
  Fl_Boxtype bt = (box()) ? box() : FL_DOWN_BOX; // Box type

  xx = Fl::event_x() - x() + leftline_; // Get mouse
  yy = Fl::event_y() - y() + topline_;

  if (d->resized && !Fl::event_buttons()) { // mouse up outside window
    d->resized = 0; // reset d->resized
    format(); // make sure text is wrapped to window
  }

  switch (event)
  {
    case FL_FOCUS: // Set keyboard focus
      redraw(); // Set widget to draw
      return 1;

    case FL_UNFOCUS: // Reset keyboard focus
      clear_selection(); // Clear text selection
      redraw(); // Set widget to draw
      return 1;

    case FL_ENTER : // Mouse pointer entered widget
      Fl_Group::handle(event);
      return 1;

    case FL_LEAVE : // Mouse pointer left widget
      d->top = topline(); // set top
      fl_cursor(FL_CURSOR_DEFAULT); // Default icon, usually arrow
      break;

    case FL_MOVE: // Mouse pointer was moved with no button pushed
      hh = h() + topline_ - Fl::box_dy(bt); // get bottom of window
      if (hscrollbar_.visible()) hh -= Fl::scrollbar_size();
      if (yy > hh) hh = -1; // mouse over hscrollbar so no active link
      if (find_link(xx, yy) && hh > 0) // mouse y in bounds
        fl_cursor(FL_CURSOR_HAND); // Hand icon
      else
        fl_cursor(FL_CURSOR_DEFAULT);
      return 1;

    case FL_PUSH: // Mouse button was pushed
      if (Fl_Group::handle(event)) return 1;
      d->linkp = find_link(xx, yy);
      if (d->linkp) {
        d->ispush = 1; // set link is pushed
        fl_cursor(FL_CURSOR_HAND);
        return 1;
      }
      if (begin_selection()) {
        fl_cursor(FL_CURSOR_INSERT); // I-beam icon
        return 1;
      }
      fl_cursor(FL_CURSOR_DEFAULT);
      return 1;

    case FL_DRAG: // Mouse pointer was moved with button pushed
      if (d->ispush) { // link is pushed
        if (Fl::event_is_click()) {
          fl_cursor(FL_CURSOR_HAND);
        } else {
          fl_cursor(FL_CURSOR_DEFAULT); // Should be "FL_CURSOR_CANCEL" if we had it
        }
        return 1;
      }
      if (current_view == this && selection_push_last) {
        if (extend_selection()) redraw(); // Set widget to draw
        fl_cursor(FL_CURSOR_INSERT);
        return 1;
      }
      fl_cursor(FL_CURSOR_DEFAULT);
      return 1;

    case FL_RELEASE: // Mouse button was released
      if (d->ispush) { // link is pushed
        if (Fl::event_is_click()) {
          d->top = topline(); // set top
          d->islink = 1; // set islink
          follow_link(d->linkp);
        }
        fl_cursor(FL_CURSOR_DEFAULT);
        d->ispush = 0; // reset link is pushed - was d->linkp = 0;
        return 1;
      }
      if (current_view == this && selection_push_last) {
        end_selection();
        return 1;
      }
      return 1;

    case FL_SHORTCUT: { // Shortcut key was pushed
      char ascii = Fl::event_text()[0];
      switch (ascii) {
        case CTRL('A'): select_all(); redraw(); return 1; // Set widget to draw
        case CTRL('C'):
        case CTRL('X'): end_selection(1); return 1;
      }
      break; }
  }

  return Fl_Group::handle(event);

} // Fl_Help_View::handle()

//
// Fl_Help_View::hv_draw() - Draws text.
//
// Note: This function must be optimized for speed!

void Fl_Help_View::hv_draw(const char *tp, // I - Text to draw
                           int xx, // I - X position of text
                           int yy) // I - Y position of text
{
  int width = 0, // Width of text
    first = 0, // First selected position
    last = 0; // Last selected position

  if (selected && current_view == this &&
      current_pos < selection_last &&
      current_pos >= selection_first) { // Selected text
    Fl_Color clr = fl_color();
    fl_color(hv_selection_color);
    width = (int)fl_width(tp);
    if (current_pos + (int)strlen(tp) < selection_last)
      width += (int)fl_width(" ");
    fl_rectf(xx, yy + fl_descent() - fl_height(), width, fl_height());
    fl_color(hv_selection_text_color);
    fl_draw(tp, xx, yy);
    fl_color(clr);
  }
  else { // Normal text
    fl_draw(tp, xx, yy);
  }

  if (draw_mode) // Text is being selected
  {
    width = (int)fl_width(tp);
    if (mouse_x >= xx && mouse_x < xx + width) {
      if (mouse_y >= yy - fl_height() + fl_descent() &&
          mouse_y <= yy + fl_descent()) {
        first = current_pos;
        // use 'quote_char' to calculate true length of HTML string
        last = first + strlen(tp);
        if (draw_mode == 1) { // Begin selection mode
          selection_push_first = first;
          selection_push_last = last;
        }
        else { // End selection mode
          selection_drag_first = first;
          selection_drag_last = last;
        }
      }
    }
  }

} // Fl_Help_View::hv_draw()

//
// Fl_Help_View::initfont() - Initialize font stack.
//

void Fl_Help_View::initfont(int &fi, 
                            unsigned char &fs) { // reset stack
	d->nfonts = 0;
	fl_font(fi = d->fonts[0][0] = serifont_, fs = d->fonts[0][1] = fontsize_);
}

//
// Fl_Help_View::leftline() - Set the left line position.
//

void Fl_Help_View::leftline(int xx) // I - Left line position
{
  if (!value_) return;

  if (hsize_ < w() - Fl::scrollbar_size() || xx < 0)
    xx = 0;
  else if (xx > hsize_)
    xx = hsize_;

  leftline_ = xx;
  hscrollbar_.value(leftline_, w() - Fl::scrollbar_size(), 0, hsize_);
  redraw(); // Set widget to draw

} // Fl_Help_View::leftline()

//
// Fl_Help_View::load() - Load the specified file.
//

int // O - 0 on success, -1 on error
Fl_Help_View::load(const char *fp) // I - File to load, may have target
{
  FILE *filep; // File to read from
  size_t fsize; // file size
  long len = 0; // Length of file
  char *target, // Target in file
    *slash; // Directory separator
  const char *namep; // Local filename
  char error[1024]; // Error buffer
  char newname[1024]; // New filename buffer

  clear_selection(); // Clear text selection
  strlcpy(newname, fp, sizeof(newname));
  if ((target = strrchr(newname, '#'))) // Last '#' char - rem'd != 0
    *(target ++) = '\0'; // Remove target - added ()

  if (link_)
    namep = (*link_)(this, newname); // Link transform
  else
    namep = filename_; // Current filename

//printf(" load namep=(%s) d->nstyle=%d\n",namep,d->nstyle);

  if (!(d->nstyle & HV_NONAVIGATE)) // user navigation, continue load
    namep = newname;
  if (!newname[0]) // avoid error
    strlcpy(newname, "(null)", sizeof(newname));

  if (!namep) return -1; // No file was loaded, fail

  if (!strncmp(newname, "ftp:", 4) || !strncmp(newname, "http:", 5) ||
      !strncmp(newname, "https:", 6) || !strncmp(newname, "ipp:", 4) ||
      !strncmp(newname, "mailto:", 7) || !strncmp(newname, "news:", 5))
    return -1; // last path is remote link, fail

  if (!d->ispath) { // path not used
    strlcpy(d->lpath, filename_, sizeof(d->lpath)); // last path
    strlcpy(filename_, newname, sizeof(filename_)); // dir + filename
    strlcpy(directory_, newname, sizeof(directory_)); // dir, no end '/'
  }

  // Note: We do not support Windows backslashes,
  // since they are illegal in URLs
  if (!(slash = strrchr(directory_, '/'))) // rem'd == 0
    directory_[0] = '\0'; // No '/' char
  else if (slash > directory_ && slash[-1] != '/')
    *slash = '\0'; // Remove filename, assumes filename exists

  //if (value_) { free((void *)value_); value_ = 0; } // rem'd
  free_data(); // free last document

  if (!strncmp(namep, "ftp:", 4) || !strncmp(namep, "http:", 5) ||
      !strncmp(namep, "https:", 6) || !strncmp(namep, "ipp:", 4) ||
      !strncmp(namep, "mailto:", 7) || !strncmp(namep, "news:", 5))
  { // Remote link
    snprintf(error, sizeof(error),
             "<HTML><HEAD><TITLE>Error - %s</TITLE></HEAD>"
             "<BODY><H2>Error - %s</H2>"
             "<P>Unable to find the address at <A HREF=\"%s\">%s</A></P>"
             "<P><LI>No handler exists for this URI scheme</LI></P>",
             strerror(errno), strerror(errno), namep, namep);
    value_ = strdup(error); // Duplicate
  }
  else // Local link
  {
    if (!strncmp(namep, "file:", 5)) namep += 5; // Adjust for file:

    if ((filep = fopen(namep, "rb"))) { // Binary - rem'd != 0
      fseek(filep, 0, SEEK_END);
      len = ftell(filep);
      rewind(filep); // like fseek(fp, 0, SEEK_SET)

      value_ = (const char *)calloc(len + 1, 1); // malloc but zero'd
      fsize = fread((void *)value_, 1, len, filep);
      fclose(filep);
    }
    else { // File not opened
      snprintf(error, sizeof(error),
               "<HTML><HEAD><TITLE>Error - File not found</TITLE></HEAD>"
               "<BODY><H2>Error - File not found</H2>"
               "<P>Unable to find the file at %s</P>"
               "<P><LI><A HREF=\"javascript:history.back()\">Back</A></LI></P>",
               namep);
      value_ = strdup(error); // Duplicate
    }
  }

//printf(" load d->ltop=%d d->top=%d topline()=%d\n",d->ltop,d->top,topline());

  if (!(!(d->nstyle & HV_NONAVIGATE) && d->isnav) && d->islink)
    d->ltop = d->top; // leave if user nav and nav link, link clicked
  format();
  if (target) // Target in link
    topline(target);
  else
    topline(0);

  if (!(d->nstyle & HV_NONAVIGATE) && d->isnav) {
    topline(d->ltop); // user navigation and is nav link
    d->isnav = 0; // reset isnav
  }
  if (!strcmp(d->path, d->lpath)) topline(d->ltop); // remote link
  if (d->islink) d->top = topline(); // link clicked, set top
  leftline(0); // added

  return 0; // File was loaded, success

} // Fl_Help_View::load()

//
// Fl_Help_View::load_css() - Loads a css file.
//

int // O - 0 if file loaded, -1 if error
Fl_Help_View::load_css(const char *fp) // I - file to load
{
  FILE *filep; // file to read from
  size_t fsize; // file size
  int ti = 0, tj = 0,
    isblock = 0, isstr = 0,
    tcount = 0, tstart = 0,
    *tpi; // temp vars
  long len = 0; // length of file
  const char *namep; // local filename
  char *tp; // temp ptr
  
  namep = fp;
  if (!namep) return -1; // no file handle, fail

  if (!d->cssurl) { // first url
    d->cssurllen = 1;
    d->cssurl = (char *)calloc(1024, 1); // init zero'd
    strlcpy(d->cssurl, namep, 1024);
  }
  else { // next url
    for (ti = 0; ti < d->cssurllen; ti ++) {
      tp = d->cssurl + (ti * 1024);
      if (!strcmp(tp, namep)) len = 1; // url match
    }
    if (len != 1) { // no match, add new url
      d->cssurl = (char *)realloc((void *)d->cssurl, (d->cssurllen + 1) * 1024);
      tp = d->cssurl + (d->cssurllen * 1024);
      strlcpy(tp, namep, 1024);
      d->cssurllen ++;
    }
  }

  if (len == 1) return -1; // url match, fail
  
  if (!strncmp(namep, "ftp:", 4) || !strncmp(namep, "http:", 5) ||
      !strncmp(namep, "https:", 6))
  {
    return -1; // remote link, fail
  }
  else // local link
  {
    if (!strncmp(namep, "file:", 5)) namep += 5; // adjust for file:

    if ((filep = fopen(namep, "rb"))) { // binary - rem'd != 0
      fseek(filep, 0, SEEK_END);
      len = ftell(filep);
      rewind(filep); // like fseek(fp, 0, SEEK_SET)

      if (!d->csstext) { // first file
        d->csstext = (char *)calloc(len + 1, 1); // init zero'd
        tp = d->csstext;
        d->csstextlen = len;
      }
      else { // next file
        d->csstext = (char *)realloc((void *)d->csstext, d->csstextlen + len + 1);
        tp = d->csstext + d->csstextlen;
        tstart = d->csstextlen; // start of file
        d->csstextlen += len; // total file length
      }
      
      *(tp + len) = '\0'; // nul-terminate file
      fsize = fread((void *)tp, 1, len, filep);
      fclose(filep);

      for (ti = 0; ti < len; ti ++) { // count words
        if (isspace(*(tp + ti))) tj = 0; // no word
        else tj ++; // letter count
        if (*(tp + ti) == '{') { tj = 1; isblock = 1; } // block
        if (*(tp + ti) == '"') { if (isstr) isstr = 0; else isstr = 1; } // string
        if (!isblock) { // outside block
          if (*(tp + ti) == ',') { // special char
            tj = 1; ti ++;
            while (isspace(*(tp + ti)) && ti < len) ti ++; // skip space
          }
        }
        else if (!isstr) { // inside block - ignore if in string
          if (*(tp + ti) == ':' || *(tp + ti) == ';') { // special char
            tj = 1; ti ++;
            while (isspace(*(tp + ti)) && ti < len) ti ++; // skip space
          }
        }
        if (*(tp + ti) == '}') { tj = 1; isblock = 0; } // block
        if (tj == 1) tcount ++; // next word
        if (*(tp + ti) == '{' || *(tp + ti) == '}') tj = 0; // single char word
      }
      
      if (!d->cssword) { // first file
        d->cssword = (int *)calloc(tcount + 1, sizeof(int)); // init zero'd
        tpi = d->cssword;
        d->csswordlen = tcount;
      }
      else { // next file
        d->cssword = (int *)realloc((void *)d->cssword, (d->csswordlen + tcount + 1) * sizeof(int));
        tpi = d->cssword + d->csswordlen;
        d->csswordlen += tcount; // total word count
      }
      *(tpi + tcount) = d->csstextlen; // set last int
      
      for (ti = 0, isblock = 0, isstr = 0, tcount = 0; ti < len; ti ++) { // store word offsets
        if (isspace(*(tp + ti))) tj = 0; // no word
        else tj ++; // letter count
        if (*(tp + ti) == '{') { tj = 1; isblock = 1; } // block
        if (*(tp + ti) == '"') { if (isstr) isstr = 0; else isstr = 1; } // string
        if (!isblock) { // outside block
          if (*(tp + ti) == ',') { // special char
            tj = 1; ti ++;
            while (isspace(*(tp + ti)) && ti < len) ti ++; // skip space
          }
        }
        else if (!isstr) { // inside block - ignore if in string
          if (*(tp + ti) == ':' || *(tp + ti) == ';') { // special char
            tj = 1; ti ++;
            while (isspace(*(tp + ti)) && ti < len) ti ++; // skip space
          }
        }
        if (*(tp + ti) == '}') { tj = 1; isblock = 0; } // block
        if (tj == 1) {
          *(tpi + tcount) = ti + tstart; // word offset
          tcount ++; // next word
          if (*(tp + ti) == '{' || *(tp + ti) == '}') tj = 0; // single char word
        }
      }

    }
    else
      return -1; // file not opened, failure   
  }

  return 0; // file was loaded, success

} // Fl_Help_View::load_css()

//
// Fl_Help_View::parse_css() - Parses all supported css properties.
//

void Fl_Help_View::parse_css(Fl_Help_Block &b, // O - current block
          const char *sp, // I - selector ptr
          char *buf) // O - text buffer
{
  if (get_css_value(sp, "background-color", buf)) // background
    b.bgcolor = get_color(buf, color());
  // todo: image/repeat/attachment/position
  
  if (get_css_value(sp, "font-family", buf)) // font
    b.font = font_face(buf); // altered by style & weight
  if (get_css_value(sp, "font-style", buf)) {
    if (!strncasecmp(buf, "italic", 6) ||
        !strncasecmp(buf, "oblique", 7))
      b.font = font_style(b.font, FL_ITALIC);
  }
  if (get_css_value(sp, "font-weight", buf)) {
    if (!strncasecmp(buf, "bold", 4))
      b.font = font_style(b.font, FL_BOLD);
  }
  if (get_css_value(sp, "font-size", buf)) {
    b.fsize = get_font_size(buf) + 2;
  }
  return;
  
} // Fl_Help_View::parse_css()

//
// Fl_Help_View::popfont() - Pop from font stack.
//

void Fl_Help_View::popfont(int &fi, 
                           unsigned char &fs) { // pop font
	if (d->nfonts > 0) d->nfonts --;
	fl_font(fi = d->fonts[d->nfonts][0], fs = d->fonts[d->nfonts][1]);
}

//
// Fl_Help_View::pushfont() - Push to font stack.
//

void Fl_Help_View::pushfont(int fi, 
                            unsigned char fs) { // push font
	if (d->nfonts < 99) d->nfonts ++;
	fl_font(d->fonts[d->nfonts][0] = fi, d->fonts[d->nfonts][1] = fs);
}

//
// Fl_Help_View::resize() - Resize the help widget.
//

void Fl_Help_View::resize(int xx, // I - New left position
                          int yy, // I - New top position
                          int ww, // I - New width
                          int hh) // I - New height
{
  int ss = Fl::scrollbar_size(); // Scrollbar width
  long time = 0, sec = 0, mil = 0; // timer vars
  Fl_Boxtype bt = (box()) ? box() : FL_DOWN_BOX; // box to draw

  Fl_Widget::resize(xx, yy, ww, hh); // Resize help widget

  scrollbar_.resize(x() + w() - ss - Fl::box_dw(bt) + Fl::box_dx(bt),
                    y() + Fl::box_dy(bt), ss, h() - ss - Fl::box_dh(bt));
  hscrollbar_.resize(x() + Fl::box_dx(bt),
                     y() + h() - ss - Fl::box_dh(bt) + Fl::box_dy(bt),
                     w() - ss - Fl::box_dw(bt), ss);

  // delay calls to format to avoid hangs on very large pages
  if (abs(w() - d->rwidth) > 2) { // moved more than 2 pixels
    fl_gettime(&sec, &mil); // find how long since last format
    time = MIL(d->rsec, d->rmil, sec, mil);
    if (time > d->rtime || !d->resized) { // enough time has passed
      d->resized = 1; // set d->resized
      format();
      fl_gettime(&d->rsec, &d->rmil); // find how long this format took
      d->rtime = MIL(d->rsec, d->rmil, sec, mil);
      d->rtime /= 2; // wait half the time format took
      d->rwidth = w(); // store window width
    }
  }

} // Fl_Help_View::resize()

//
// Fl_Help_View::select_all() - Select all text.
//

void Fl_Help_View::select_all()
{
  clear_global_selection();
  if (!value_) return;
  current_view = this;
  selection_drag_last = selection_last = strlen(value_);
  selected = 1;

} // Fl_Help_View::select_all()

//
// Fl_Help_View::setstyle() - set the html style flag
//

void Fl_Help_View::setstyle(int flag) // I - style flag to set
{
  d->nstyle = flag; // wasn't working as a method..
}

//
// Fl_Help_View::topline() - Set the top line to the named target.
//

void Fl_Help_View::topline(const char *np) // I - Target name
{
  Fl_Help_Link key, // Target name key
    *target; // Pointer to matching target

  if (ntargets_ == 0) return;

  strlcpy(key.name, np, sizeof(key.name));

  target = (Fl_Help_Link *)bsearch(&key, d->targets, ntargets_,
                                   sizeof(Fl_Help_Link),
                                   (compare_func_t)cmp_targets);

  if (target) topline(target->y); // Target found - rem'd != 0

} // Fl_Help_View::topline()

//
// Fl_Help_View::topline() - Set the top line by number.
//

void Fl_Help_View::topline(int yy) // I - Top line number
{
  if (!value_) return;

  if (size_ < h() - Fl::scrollbar_size() || yy < 0)
    yy = 0;
  else if (yy > size_)
    yy = size_;

  topline_ = yy;
  scrollbar_.value(topline_, h() - Fl::scrollbar_size(), 0, size_);
  do_callback();
  redraw(); // Set widget to draw
  d->top = topline_; // set top

} // Fl_Help_View::topline()

//
// Fl_Help_View::value() - Set the help text directly.
//
// Note: called by nav buttons, also after follow_link

void Fl_Help_View::value(const char *tp) // I - Text to view
{

  if (!tp) return; // Null

  char target[32]; // current target
  target[0] = '\0';

  if (d->islink) { // link clicked
    if (d->linkp) // link exists
      strlcpy(target, d->linkp->name, sizeof(target));
    d->islink = 0; // reset islink
    if (!(d->nstyle & HV_NONAVIGATE)) return; // file was loaded
  }

  if (!tp[0]) { // text buffer empty
    char error[1024]; // error buffer
    const char *namep = 0; // local filename
    if (d->ispath) namep = d->path; // path is used
    else if (filename_[0]) namep = filename_;
    if (!namep[0]) namep = "(null)";

    if (!strncmp(namep, "ftp:", 4) || !strncmp(namep, "http:", 5) ||
        !strncmp(namep, "https:", 6) || !strncmp(namep, "ipp:", 4) ||
        !strncmp(namep, "mailto:", 7) || !strncmp(namep, "news:", 5)) {
      snprintf(error, sizeof(error),
               "<HTML><HEAD><TITLE>Error - Server not found</TITLE></HEAD>"
               "<BODY><H2>Error - Server not found</H2>"
               "<P>Unable to find the address at <A HREF=\"%s\">%s</A></P>"
               "<P><LI>No handler exists for this URI scheme</LI></P>",
               namep, namep);
    }
    else {
      snprintf(error, sizeof(error),
               "<HTML><HEAD><TITLE>Error - File not found</TITLE></HEAD>"
               "<BODY><H2>Error - File not found</H2>"
               "<P>Unable to find the file at %s</P>", namep);
      if (d->lpath[0]) // last path exists
        snprintf(error + strlen(error), sizeof(error) - strlen(error),
                 "<P><LI><A HREF=\"javascript:history.back()\">Back</A></P>");
    }
    clear_selection(); // clear text selection
    set_changed(); // set widget value was changed
    free_data(); // free last document
    value_ = strdup(error); // duplicate
    format();
    topline(0);
    leftline(0);
    return; // we're done
  }

//printf(" value target=(%s) d->ispath=%d\n",target,d->ispath);
//printf(" value d->path=(%s) d->islink=%d\n",d->path,d->islink);

  clear_selection(); // Clear text selection
  set_changed(); // Set widget value was changed
  free_data(); // Free last document
  value_ = strdup(tp); // Duplicate
  if (d->islink) d->ltop = d->top; // link clicked, last top
  format();

  if (target[0]) // new link with target
    topline(target); // set position on page
  else // no target
    topline(0);

  if (d->islink) d->top = topline(); // link clicked, set top
  leftline(0);

} // Fl_Help_View::value()

//
// Fl_Help_View::~Fl_Help_View() - Destroy a Fl_Help_View widget.
//

Fl_Help_View::~Fl_Help_View()
{
  clear_selection(); // Clear text selection
  free_data(); // Free last document
  free(d); // free d-pointer

} // Fl_Help_View::~Fl_Help_View()

//
// 'command()' - Convert a command with up to four letters into an uint.
//

static unsigned int // O - Fourcc int
command(const char *cmdp) // I - Command pointer
{
  unsigned int ret = (tolower(cmdp[0]) << 24);
  char cc = cmdp[1];

  if (cc == '>' || cc == ' ' || cc == 0) return ret;
  ret |= (tolower(cc) << 16);
  cc = cmdp[2];
  if (cc == '>' || cc == ' ' || cc == 0) return ret;
  ret |= (tolower(cc) << 8);
  cc = cmdp[3];
  if (cc == '>' || cc == ' ' || cc == 0) return ret;
  ret |= tolower(cc);
  cc = cmdp[4];
  if (cc == '>' || cc == ' ' || cc == 0) return ret;
  return 0;

} // command()

//
// 'quote_char()' - Return the character code associated with a quoted char.
//

static int // O - Code or -1 on error
quote_char(const char *qp, // I - Quoted string
           int fc) // I - true to return what font char uses, opt
{
  int ti = 0, // Temp loop var
    num = 0, // number of elements
    temp = 0; // temp var

  // updated table to HTML 4
  // http://www.alanwood.net/demos/ansi.html
  static struct {
    const char *name; // str pointer
    int namelen; // str length
    int cdata; // character reference data
    int code; // ANSI/Unicode char code
    int mac; // Mac Roman char code
    int sym; // what font does char use? 0 = current, 1 = Symbol
  }
  *namep, // pointer into names array
  names[] = { // quoting names
    // special escape chars
    { "quot;",   5,   34, '\"','\"',ENC(0,0) }, // quotation mark
    { "amp;",    4,   38, '&', '&', ENC(0,0) }, // ampersand
    { "lt;",     3,   60, '<', '<', ENC(0,0) }, // less-than sign
    { "gt;",     3,   62, '>', '>', ENC(0,0) }, // greater-than sign
    // reserved chars * means no equivalent in Mac Roman
    // 128-159 are control chars in Unicode but are chars in ANSI
    { "euro;",   5, 8364, 'C', 219, ENC(0,0) }, // euro sign
    { "thinsp;", 7, 8201, ' ', ' ', ENC(0,0) }, // thin space - NA
    { "sbquo;",  6, 8218, 130, 226, ENC(0,0) }, // single low-9 quotation mark
    { "fnof;",   5,  402, 166, 196, ENC(1,0) }, // Latin small f hook
    { "bdquo;",  6, 8222, 132, 227, ENC(0,0) }, // double low-9 quotation mark
    { "hellip;", 7, 8230, 188, 201, ENC(1,0) }, // horizontal ellipsis
    { "dagger;", 7, 8224, 134, 160, ENC(0,0) }, // dagger
    { "Dagger;", 7, 8225, 135, 224, ENC(0,0) }, // double dagger
    { "circ;",   5,  710, 136, 246, ENC(0,0) }, // modifier circumflex accent
    { "permil;", 7, 8240, 137, 228, ENC(0,0) }, // per mille sign
    { "Scaron;", 7,  352, 138, 223, ENC(0,1) }, // Latin capital S caron *
    { "lsaquo;", 7, 8249, 225, 220, ENC(1,0) }, // single left angle quotation
    { "OElig;",  6,  338, 140, 206, ENC(0,0) }, // Latin capital ligature OE
    { "zwnj;",   5, 8204, ' ', ' ', ENC(0,0) }, // nzero width non-joiner - NA
    { "zwj;",    4, 8205, ' ', ' ', ENC(0,0) }, // zero width joiner - NA
    { "lrm;",    4, 8206, ' ', ' ', ENC(0,0) }, // left-to-right mark - NA
    { "rlm;",    4, 8207, ' ', ' ', ENC(0,0) }, // right-to-left mark - NA
    { "lsquo;",  6, 8216, 145, 212, ENC(0,0) }, // left single quotation mark
    { "rsquo;",  6, 8217, 146, 213, ENC(0,0) }, // right single quotation mark
    { "ldquo;",  6, 8220, 147, 210, ENC(0,0) }, // left double quotation mark
    { "rdquo;",  6, 8221, 148, 211, ENC(0,0) }, // right double quotation mark
    { "bull;",   5, 8226, 183, 165, ENC(1,0) }, // bullet
    { "ndash;",  6, 8211, '-', 208, ENC(1,0) }, // en dash
    { "mdash;",  6, 8212, 190, 209, ENC(1,0) }, // em dash
    { "tilde;",  6,  732, 152, 247, ENC(0,0) }, // small tilde
    { "trade;",  6, 8482, 228, 170, ENC(1,0) }, // trade mark sign
    { "scaron;", 7,  353, 154, 222, ENC(0,1) }, // Latin small s caron *
    { "rsaquo;", 7, 8250, 241, 221, ENC(1,0) }, // single right angle quotation
    { "oelig;",  6,  339, 156, 207, ENC(0,0) }, // Latin small ligature oe
    { "ensp;",   5, 8194, ' ', ' ', ENC(0,0) }, // en space - NA
    { "emsp;",   5, 8195, ' ', ' ', ENC(0,0) }, // em space - NA
    { "Yuml;",   5,  376, 159, 217, ENC(0,0) }, // Latin capital Y umlaut
    // Latin-1 Supplement
    { "nbsp;",   5,  160, ' ', ' ', ENC(0,0) }, // no-break space, 160/202
    { "iexcl;",  6,  161, 161, 193, ENC(0,0) }, // inverted exclamation mark
    { "cent;",   5,  162, 162, 162, ENC(0,0) }, // cent sign
    { "pound;",  6,  163, 163, 163, ENC(0,0) }, // pound sign
    { "curren;", 7,  164, 164, 251, ENC(0,1) }, // currency sign *
    { "yen;",    4,  165, 165, 180, ENC(0,0) }, // yen sign
    { "brvbar;", 7,  166, 166, 240, ENC(0,1) }, // broken bar *
    { "sect;",   5,  167, 167, 164, ENC(0,0) }, // section sign
    { "uml;",    4,  168, 168, 172, ENC(0,0) }, // diaeresis/umlaut
    { "copy;",   5,  169, 169, 169, ENC(0,0) }, // copyright sign
    { "ordf;",   5,  170, 170, 187, ENC(0,0) }, // feminine ordinal indicator
    { "laquo;",  6,  171, 171, 199, ENC(0,0) }, // left double angle quotation
    { "not;",    4,  172, 172, 194, ENC(0,0) }, // not sign
    { "shy;",    4,  173, 173, '-', ENC(0,0) }, // soft hyphen
    { "reg;",    4,  174, 174, 168, ENC(0,0) }, // registered sign
    { "macr;",   5,  175, 175, 248, ENC(0,0) }, // macron
    { "deg;",    4,  176, 176, 161, ENC(0,0) }, // degree sign
    { "plusmn;", 7,  177, 177, 177, ENC(0,0) }, // plus-minus sign
    { "sup2;",   5,  178, 178, 253, ENC(0,1) }, // superscript two *
    { "sup3;",   5,  179, 179, 249, ENC(0,1) }, // superscript three *
    { "acute;",  6,  180, 180, 171, ENC(0,0) }, // acute accent
    { "micro;",  6,  181, 181, 181, ENC(0,0) }, // micro sign
    { "para;",   5,  182, 182, 166, ENC(0,0) }, // pilcrow sign
    { "middot;", 7,  183, 183, 225, ENC(0,0) }, // middle dot
    { "cedil;",  6,  184, 184, 252, ENC(0,0) }, // cedilla
    { "sup1;",   5,  185, 185, 245, ENC(0,1) }, // superscript one *
    { "ordm;",   5,  186, 186, 188, ENC(0,0) }, // masculine ordinal indicator
    { "raquo;",  6,  187, 187, 200, ENC(0,0) }, // right double angle quotation
    { "frac14;", 7,  188, 188, 254, ENC(0,1) }, // vulgar fraction 1/4 *
    { "frac12;", 7,  189, 189, 255, ENC(0,1) }, // vulgar fraction 1/2 *
    { "frac34;", 7,  190, 190, 250, ENC(0,1) }, // vulgar fraction 3/4 *
    { "iquest;", 7,  191, 191, 192, ENC(0,0) }, // inverted question mark
    { "Agrave;", 7,  192, 192, 203, ENC(0,0) }, // Latin capital A grave
    { "Aacute;", 7,  193, 193, 231, ENC(0,0) }, // Latin capital A acute
    { "Acirc;",  6,  194, 194, 229, ENC(0,0) }, // Latin capital A circumflex
    { "Atilde;", 7,  195, 195, 204, ENC(0,0) }, // Latin capital A tilde
    { "Auml;",   5,  196, 196, 128, ENC(0,0) }, // Latin capital A umlaut
    { "Aring;",  6,  197, 197, 129, ENC(0,0) }, // Latin capital A ring above
    { "AElig;",  6,  198, 198, 174, ENC(0,0) }, // Latin capital AE
    { "Ccedil;", 7,  199, 199, 130, ENC(0,0) }, // Latin capital C cedilla
    { "Egrave;", 7,  200, 200, 233, ENC(0,0) }, // Latin capital E grave
    { "Eacute;", 7,  201, 201, 131, ENC(0,0) }, // Latin capital E acute
    { "Ecirc;",  6,  202, 202, 230, ENC(0,0) }, // Latin capital E circumflex
    { "Euml;",   5,  203, 203, 232, ENC(0,0) }, // Latin capital E umlaut
    { "Igrave;", 7,  204, 204, 237, ENC(0,0) }, // Latin capital I grave
    { "Iacute;", 7,  205, 205, 234, ENC(0,0) }, // Latin capital I acute
    { "Icirc;",  6,  206, 206, 235, ENC(0,0) }, // Latin capital I circumflex
    { "Iuml;",   5,  207, 207, 236, ENC(0,0) }, // Latin capital I umlaut
    { "ETH;",    4,  208, 208, 198, ENC(0,1) }, // Latin capital ETH *
    { "Ntilde;", 7,  209, 209, 132, ENC(0,0) }, // Latin capital N tilde
    { "Ograve;", 7,  210, 210, 241, ENC(0,0) }, // Latin capital O grave
    { "Oacute;", 7,  211, 211, 238, ENC(0,0) }, // Latin capital O acute
    { "Ocirc;",  6,  212, 212, 239, ENC(0,0) }, // Latin capital O circumflex
    { "Otilde;", 7,  213, 213, 205, ENC(0,0) }, // Latin capital O tilde
    { "Ouml;",   5,  214, 214, 133, ENC(0,0) }, // Latin capital O umlaut
    { "times;",  6,  215, 215, 'x', ENC(0,0) }, // multiplication sign
    { "Oslash;", 7,  216, 216, 175, ENC(0,0) }, // Latin capital O stroke
    { "Ugrave;", 7,  217, 217, 244, ENC(0,0) }, // Latin capital U grave
    { "Uacute;", 7,  218, 218, 242, ENC(0,0) }, // Latin capital U acute
    { "Ucirc;",  6,  219, 219, 243, ENC(0,0) }, // Latin capital U circumflex
    { "Uuml;",   5,  220, 220, 134, ENC(0,0) }, // Latin capital U umlaut
    { "Yacute;", 7,  221, 221, 217, ENC(0,1) }, // Latin capital Y acute *
    { "THORN;",  6,  222, 222, 167, ENC(0,1) }, // Latin capital THORN *
    { "szlig;",  6,  223, 223, 167, ENC(0,0) }, // Latin small sharp s
    { "agrave;", 7,  224, 224, 136, ENC(0,0) }, // Latin small a grave
    { "aacute;", 7,  225, 225, 135, ENC(0,0) }, // Latin small a acute
    { "acirc;",  6,  226, 226, 137, ENC(0,0) }, // Latin small a circumflex
    { "atilde;", 7,  227, 227, 139, ENC(0,0) }, // Latin small a tilde
    { "auml;",   5,  228, 228, 138, ENC(0,0) }, // Latin small a umlaut
    { "aring;",  6,  229, 229, 140, ENC(0,0) }, // Latin small a ring above
    { "aelig;",  6,  230, 230, 190, ENC(0,0) }, // Latin small ae
    { "ccedil;", 7,  231, 231, 141, ENC(0,0) }, // Latin small c cedilla
    { "egrave;", 7,  232, 232, 143, ENC(0,0) }, // Latin small e grave
    { "eacute;", 7,  233, 233, 142, ENC(0,0) }, // Latin small e acute
    { "ecirc;",  6,  234, 234, 144, ENC(0,0) }, // Latin small e circumflex
    { "euml;",   5,  235, 235, 145, ENC(0,0) }, // Latin small e umlaut
    { "igrave;", 7,  236, 236, 147, ENC(0,0) }, // Latin small i grave
    { "iacute;", 7,  237, 237, 146, ENC(0,0) }, // Latin small i acute
    { "icirc;",  6,  238, 238, 148, ENC(0,0) }, // Latin small i circumflex
    { "iuml;",   5,  239, 239, 149, ENC(0,0) }, // Latin small i umlaut
    { "eth;",    4,  240, 240, 182, ENC(0,1) }, // Latin small eth *
    { "ntilde;", 7,  241, 241, 150, ENC(0,0) }, // Latin small n tilde
    { "ograve;", 7,  242, 242, 152, ENC(0,0) }, // Latin small o grave
    { "oacute;", 7,  243, 243, 151, ENC(0,0) }, // Latin small o acute
    { "ocirc;",  6,  244, 244, 153, ENC(0,0) }, // Latin small o circumflex
    { "otilde;", 7,  245, 245, 155, ENC(0,0) }, // Latin small o tilde
    { "ouml;",   5,  246, 246, 154, ENC(0,0) }, // Latin small o umlaut
    { "divide;", 7,  247, 247, 214, ENC(0,0) }, // division sign
    { "oslash;", 7,  248, 248, 191, ENC(0,0) }, // Latin small o stroke
    { "ugrave;", 7,  249, 249, 157, ENC(0,0) }, // Latin small u grave
    { "uacute;", 7,  250, 250, 156, ENC(0,0) }, // Latin small u acute
    { "ucirc;",  6,  251, 251, 158, ENC(0,0) }, // Latin small u circumflex
    { "uuml;",   5,  252, 252, 159, ENC(0,0) }, // Latin small u umlaut
    { "yacute;", 7,  253, 253, 216, ENC(0,1) }, // Latin small y acute *
    { "thorn;",  6,  254, 254, 164, ENC(0,1) }, // Latin small thorn *
    { "yuml;",   5,  255, 255, 216, ENC(0,0) }, // Latin small y umlaut
    // Greek # means no equivalent in ANSI/Unicode
    { "Alpha;",  6,  913, 'A', 'A', ENC(1,1) }, // Greek capital Alpha
    { "Beta;",   5,  914, 'B', 'B', ENC(1,1) }, // Greek capital Beta
    { "Gamma;",  6,  915, 'G', 'G', ENC(1,1) }, // Greek capital Gamma
    { "Delta;",  6,  916, 'D', 'D', ENC(1,1) }, // Greek capital Delta
    { "Epsilon;",8,  917, 'E', 'E', ENC(1,1) }, // Greek capital Epsilon
    { "Zeta;",   5,  918, 'Z', 'Z', ENC(1,1) }, // Greek capital Zeta
    { "Eta;",    4,  919, 'H', 'H', ENC(1,1) }, // Greek capital Eta
    { "Theta;",  6,  920, 'Q', 'Q', ENC(1,1) }, // Greek capital Theta
    { "Iota;",   5,  921, 'I', 'I', ENC(1,1) }, // Greek capital Iota
    { "Kappa;",  6,  922, 'K', 'K', ENC(1,1) }, // Greek capital Kappa
    { "Lambda;", 7,  923, 'L', 'L', ENC(1,1) }, // Greek capital Lambda
    { "Mu;",     3,  924, 'M', 'M', ENC(1,1) }, // Greek capital Mu
    { "Nu;",     3,  925, 'N', 'N', ENC(1,1) }, // Greek capital Nu
    { "Xi;",     3,  926, 'X', 'X', ENC(1,1) }, // Greek capital Xi
    { "Omicron;",8,  927, 'O', 'O', ENC(1,1) }, // Greek capital Omicron
    { "Pi;",     3,  928, 'P', 'P', ENC(1,1) }, // Greek capital Pi
    { "Rho;",    4,  929, 'R', 'R', ENC(1,1) }, // Greek capital Rho
    { "Sigma;",  6,  931, 'S', 'S', ENC(1,1) }, // Greek capital Sigma
    { "Tau;",    4,  932, 'T', 'T', ENC(1,1) }, // Greek capital Tau
    { "Upsilon;",8,  933, 'U', 'U', ENC(1,1) }, // Greek capital Upsilon
    { "Phi;",    4,  934, 'F', 'F', ENC(1,1) }, // Greek capital Phi
    { "Chi;",    4,  935, 'C', 'C', ENC(1,1) }, // Greek capital Chi
    { "Psi;",    4,  936, 'Y', 'Y', ENC(1,1) }, // Greek capital Psi
    { "Omega;",  6,  937, 'W', 'W', ENC(1,1) }, // Greek capital Omega # 189 in Mac Roman
    { "alpha;",  6,  945, 'a', 'a', ENC(1,1) }, // Greek small alpha
    { "beta;",   5,  946, 'b', 'b', ENC(1,1) }, // Greek small beta
    { "gamma;",  6,  947, 'g', 'g', ENC(1,1) }, // Greek small gamma
    { "delta;",  6,  948, 'd', 'd', ENC(1,1) }, // Greek small delta
    { "epsilon;",8,  949, 'e', 'e', ENC(1,1) }, // Greek small epsilon
    { "zeta;",   5,  950, 'z', 'z', ENC(1,1) }, // Greek small zeta
    { "eta;",    4,  951, 'h', 'h', ENC(1,1) }, // Greek small eta
    { "theta;",  6,  952, 'q', 'q', ENC(1,1) }, // Greek small theta
    { "iota;",   5,  953, 'i', 'i', ENC(1,1) }, // Greek small iota
    { "kappa;",  6,  954, 'k', 'k', ENC(1,1) }, // Greek small kappa
    { "lambda;", 7,  955, 'l', 'l', ENC(1,1) }, // Greek small lambda
    { "mu;",     3,  956, 'm', 'm', ENC(1,1) }, // Greek small mu
    { "nu;",     3,  957, 'n', 'n', ENC(1,1) }, // Greek small nu
    { "xi;",     3,  958, 'x', 'x', ENC(1,1) }, // Greek small xi
    { "omicron;",8,  959, 'o', 'o', ENC(1,1) }, // Greek small omicron
    { "pi;",     3,  960, 'p', 'p', ENC(1,1) }, // Greek small pi # 185 in Mac Roman
    { "rho;",    4,  961, 'r', 'r', ENC(1,1) }, // Greek small rho
    { "sigma;",  6,  962, 's', 's', ENC(1,1) }, // Greek small sigma
    { "sigmaf;", 7,  963, 'V', 'V', ENC(1,1) }, // Greek small sigma final variant
    { "tau;",    4,  964, 't', 't', ENC(1,1) }, // Greek small tau
    { "upsilon;",8,  965, 'u', 'u', ENC(1,1) }, // Greek small upsilon
    { "phi;",    4,  966, 'j', 'j', ENC(1,1) }, // Greek small phi, 'f' is phi variant
    { "chi;",    4,  967, 'c', 'c', ENC(1,1) }, // Greek small chi
    { "psi;",    4,  968, 'y', 'y', ENC(1,1) }, // Greek small psi
    { "omega;",  6,  969, 'w', 'w', ENC(1,1) }, // Greek small omega
    { "thetasym;",9, 977,'J', 'J', ENC(1,1) }, // Greek small theta variant
    { "upsih;",  6,  978, 161, 111, ENC(1,1) }, // Greek capital upsilon hook variant
    { "piv;",    4,  982, 'v', 'v', ENC(1,1) }, // Greek small pi variant
    // General Punctuation, Letterlike Symbols and Arrows
    { "prime;",  6, 8242, 162, 162, ENC(1,1) }, // prime
    { "Prime;",  6, 8243, 178, 178, ENC(1,1) }, // double prime
    { "oline;",  6, 8254, '_', '_', ENC(1,1) }, // overline
    { "frasl;",  6, 8260, 164, 218, ENC(1,0) }, // fraction slash #
    { "weierp;", 7, 8472, 195, 195, ENC(1,1) }, // script capital P, power set
    { "image;",  6, 8465, 193, 193, ENC(1,1) }, // blackletter capital I, imaginary part
    { "real;",   5, 8476, 194, 194, ENC(1,1) }, // blackletter capital R, real part
    { "alefsym;",8, 8501, 192, 192, ENC(1,1) }, // alef symbol
    { "larr;",   5, 8592, 172, 172, ENC(1,1) }, // left arrow
    { "uarr;",   5, 8593, 173, 173, ENC(1,1) }, // up arrow
    { "rarr;",   5, 8594, 174, 174, ENC(1,1) }, // right arrow
    { "darr;",   5, 8595, 175, 175, ENC(1,1) }, // down arrow
    { "harr;",   5, 8596, 171, 171, ENC(1,1) }, // horizontal arrow
    { "crarr;",  6, 8629, 191, 191, ENC(1,1) }, // carriage return arrow
    { "lArr;",   5, 8656, 220, 220, ENC(1,1) }, // left double arrow
    { "uArr;",   5, 8657, 221, 221, ENC(1,1) }, // up double arrow
    { "rArr;",   5, 8658, 222, 222, ENC(1,1) }, // right double arrow
    { "dArr;",   5, 8659, 223, 223, ENC(1,1) }, // down double arrow
    { "hArr;",   5, 8660, 219, 219, ENC(1,1) }, // horizontal double arrow
    // Mathematical Operators
    { "forall;", 7, 8704, '\"','\"',ENC(1,1) }, // for all
    { "part;",   5, 8706, 182, 182, ENC(1,0) }, // partial differential #
    { "exist;",  6, 8707, '$', '$', ENC(1,1) }, // there exists
    { "empty;",  6, 8709, 198, 198, ENC(1,1) }, // empty set
    { "nabla;",  6, 8711, 209, 209, ENC(1,1) }, // nabla
    { "isin;",   5, 8712, 206, 206, ENC(1,1) }, // element of
    { "notin;",  6, 8713, 207, 207, ENC(1,1) }, // not an element of
    { "ni;",     3, 8715, '\'','\'',ENC(1,1) }, // contains as member
    { "prod;",   5, 8719, 213, 184, ENC(1,0) }, // n-ary product #
    { "sum;",    4, 8721, 229, 183, ENC(1,0) }, // n-ary summation #
    { "minus;",  6, 8722, 190, 190, ENC(1,1) }, // minus sign
    { "lowast;", 7, 8727, '*', '*', ENC(1,1) }, // asterisk operator
    { "radic;",  6, 8730, 214, 195, ENC(1,0) }, // square root #
    { "prop;",   5, 8733, 181, 181, ENC(1,1) }, // proportional to
    { "infin;",  6, 8734, 165, 176, ENC(1,0) }, // infinity #
    { "ang;",    4, 8736, 208, 208, ENC(1,1) }, // angle
    { "and;",    4, 8743, 217, 217, ENC(1,1) }, // logical and
    { "or;",     3, 8744, 218, 218, ENC(1,1) }, // logical or
    { "cap;",    4, 8745, 199, 199, ENC(1,1) }, // intersection
    { "cup;",    4, 8746, 200, 200, ENC(1,1) }, // union
    { "int;",    4, 8747, 242, 186, ENC(1,0) }, // integral #
    { "there4;", 7, 8756, '\\','\\',ENC(1,1) }, // therefore
    { "sim;",    4, 8764, '~', '~', ENC(1,1) }, // tilde operator
    { "cong;",   5, 8773, '@', '@', ENC(1,1) }, // approximately equal to
    { "asymp;",  6, 8776, 187, 197, ENC(1,0) }, // almost equal to #
    { "ne;",     3, 8800, 185, 173, ENC(1,0) }, // not equal to #
    { "equiv;",  6, 8801, 186, 186, ENC(1,1) }, // identical to
    { "le;",     3, 8804, 163, 178, ENC(1,0) }, // less-than or equal to #
    { "ge;",     3, 8805, 179, 179, ENC(1,0) }, // greater-than or equal to #
    { "sub;",    4, 8834, 204, 204, ENC(1,1) }, // subset of
    { "sup;",    4, 8835, 201, 201, ENC(1,1) }, // superset of
    { "nsub;",   5, 8836, 203, 203, ENC(1,1) }, // not a subset of
    { "sube;",   5, 8838, 205, 205, ENC(1,1) }, // subset of or equal to
    { "supe;",   5, 8839, 202, 202, ENC(1,1) }, // superset of or equal to
    { "oplus;",  6, 8853, 197, 197, ENC(1,1) }, // circled plus
    { "otimes;", 7, 8855, 196, 196, ENC(1,1) }, // circled times
    { "perp;",   5, 8869, '^', '^', ENC(1,1) }, // up tack
    // Miscellaneous Technical and Miscellaneous Symbols
    { "sdot;",   5, 8901, 215, 215, ENC(1,1) }, // dot operator
    { "lceil;",  6, 8968, 233, 233, ENC(1,1) }, // left ceiling
    { "rceil;",  6, 8969, 249, 249, ENC(1,1) }, // right ceiling
    { "lfloor;", 7, 8970, 235, 235, ENC(1,1) }, // left floor
    { "rfloor;", 7, 8971, 251, 251, ENC(1,1) }, // right floor
    { "lang;",   5, 9001, 225, 225, ENC(1,1) }, // left-pointing angle bracket
    { "rang;",   5, 9002, 241, 241, ENC(1,1) }, // right-pointing angle bracket
    { "loz;",    4, 9674, 224, 215, ENC(1,0) }, // lozenge #
    { "spades;", 7, 9824, 170, 170, ENC(1,1) }, // black spade suit
    { "clubs;",  6, 9827, 167, 167, ENC(1,1) }, // black club suit
    { "hearts;", 7, 9829, 169, 169, ENC(1,1) }, // black heart suit
    { "diams;",  6, 9830, 168, 168, ENC(1,1) }  // black diamond suit
  };

  if (!strchr(qp, ';')) return -1; // No semi-colon char

  num = sizeof(names) / sizeof(names[0]); // array size / element size

  if (*qp == '#') { // Numeric character reference
    if (*(qp + 1) == 'x' || *(qp + 1) == 'X') // Hexadecimal number
      temp = strtol(qp + 2, 0, 16); // Base-16 str to long - rem'd NULL
    else // Decimal number
      temp = atoi(qp + 1); // Convert str to int

    if (fc) { // check font char arg
      for (ti = num, namep = names; ti > 0; ti --, namep ++)
        if (namep->cdata == temp) return namep->sym;
      return 0; // cdata not found, use current font
    }
    return temp;
  }

  for (ti = num, namep = names; ti > 0; ti --, namep ++)
    if (!strncmp(qp, namep->name, namep->namelen)) { // If qp equals name
      if (fc) return namep->sym;
      return ENC(namep->code, namep->mac);
    }

  return -1; // Entity character reference not found

} // quote_char()

//
// 'hscrollbar_callback()' - Callback for the horizontal scrollbar.
//

static void hscrollbar_callback(Fl_Widget *s, // I - Scrollbar handle
                                void *)
{
  ((Fl_Help_View *)(s->parent()))->leftline(int(((Fl_Scrollbar*)s)->value()));

} // hscrollbar_callback()

//
// 'scrollbar_callback()' - Callback for the scrollbar.
//

static void scrollbar_callback(Fl_Widget *s, // I - Scrollbar handle
                               void *)
{
  ((Fl_Help_View *)(s->parent()))->topline(int(((Fl_Scrollbar*)s)->value()));

} // scrollbar_callback()

//
// End of "$Id: Fl_Help_View.cxx 6091 2008-04-11 11:12:16Z matt $".
//
