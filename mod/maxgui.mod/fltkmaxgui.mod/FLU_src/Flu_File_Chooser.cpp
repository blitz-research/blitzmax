// $Id: Flu_File_Chooser.cpp,v 1.98 2004/11/02 00:33:31 jbryan Exp $

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
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>

#define FLU_USE_REGISTRY

#ifdef WIN32
#include <windows.h>
#include <shlobj.h>
#include <shellapi.h>
#include <lmcons.h>
#endif

#if defined WIN32 && !defined CYGWIN
#include <direct.h>
#else
#include <unistd.h>
#endif

#include <FL/Fl.H>
#include <FL/fl_draw.H>
#include <FL/fl_ask.H>
#include <FL/math.h>
#include <FL/filename.H>
#include <FL/Fl_Pixmap.H>
#include <FL/Fl_Scroll.H>
#include <FL/Fl_Shared_Image.H>

#include "FLU/flu_pixmaps.h"
#include "FLU/Flu_Label.h"
#include "FLU/Flu_Tree_Browser.h"
#include "FLU/Flu_Separator.h"
#include "FLU/Flu_Enumerations.h"

#include "FLU/Flu_File_Chooser.h"
#include "FLU/flu_file_chooser_pixmaps.h"
#include "FLU/flu_pixmaps.h"

// set default language strings
FluSimpleString Flu_File_Chooser::favoritesTxt = "Favorites";
#ifdef WIN32
FluSimpleString Flu_File_Chooser::myComputerTxt = "My Computer";
FluSimpleString Flu_File_Chooser::myDocumentsTxt = "My Documents";
FluSimpleString Flu_File_Chooser::desktopTxt = "Desktop";
#else
FluSimpleString Flu_File_Chooser::myComputerTxt = "Home";
FluSimpleString Flu_File_Chooser::myDocumentsTxt = "Documents";
FluSimpleString Flu_File_Chooser::desktopTxt = "Desktop";
#endif

FluSimpleString Flu_File_Chooser::detailTxt[4] = { "Name", "Size", "Date", "Type" };
FluSimpleString Flu_File_Chooser::contextMenuTxt[3] = { "New Folder", "Rename", "Delete" };
FluSimpleString Flu_File_Chooser::diskTypesTxt[6] = { "Floppy Disk", "Removable Disk",
						      "Local Disk", "Compact Disk",
						      "Network Disk", "RAM Disk" };

FluSimpleString Flu_File_Chooser::filenameTxt = "Filename";
FluSimpleString Flu_File_Chooser::okTxt = "Ok";
FluSimpleString Flu_File_Chooser::cancelTxt = "Cancel";
FluSimpleString Flu_File_Chooser::locationTxt = "Location";
FluSimpleString Flu_File_Chooser::showHiddenTxt = "Show Hidden Files";
FluSimpleString Flu_File_Chooser::fileTypesTxt = "File Types";
FluSimpleString Flu_File_Chooser::directoryTxt = "Directory";
FluSimpleString Flu_File_Chooser::allFilesTxt = "All Files (*)";
FluSimpleString Flu_File_Chooser::defaultFolderNameTxt = "New Folder";

FluSimpleString Flu_File_Chooser::backTTxt = "Go back one directory in the history";
FluSimpleString Flu_File_Chooser::forwardTTxt = "Go forward one directory in the history";
FluSimpleString Flu_File_Chooser::upTTxt = "Go to the parent directory";
FluSimpleString Flu_File_Chooser::reloadTTxt = "Refresh this directory";
FluSimpleString Flu_File_Chooser::trashTTxt = "Delete file(s)";
FluSimpleString Flu_File_Chooser::newDirTTxt = "Create new directory";
FluSimpleString Flu_File_Chooser::addFavoriteTTxt = "Add this directory to my favorites";
FluSimpleString Flu_File_Chooser::previewTTxt = "Preview files";
FluSimpleString Flu_File_Chooser::listTTxt = "List mode";
FluSimpleString Flu_File_Chooser::wideListTTxt = "Wide list mode";
FluSimpleString Flu_File_Chooser::detailTTxt = "Detail mode";

FluSimpleString Flu_File_Chooser::createFolderErrTxt = "Could not create directory '%s'. You may not have permission to perform this operation.";
FluSimpleString Flu_File_Chooser::deleteFileErrTxt = "An error ocurred while trying to delete '%s'.";
FluSimpleString Flu_File_Chooser::fileExistsErrTxt = "File '%s' already exists!";
FluSimpleString Flu_File_Chooser::renameErrTxt = "Unable to rename '%s' to '%s'";

// just a string that no file could probably ever be called
#define FAVORITES_UNIQUE_STRING   "\t!@#$%^&*(Favorites)-=+"

#define DEFAULT_ENTRY_WIDTH 235

Fl_Pixmap up_folder_img( (char*const*)big_folder_up_xpm ),
  trash( (char*const*)trash_xpm ),
  new_folder( (char*const*)big_folder_new_xpm ),
  reload( (char*const*)reload_xpm ),
  preview_img( (char*const*)monalisa_xpm ),
  file_list_img( (char*const*)filelist_xpm ),
  file_listwide_img( (char*const*)filelistwide_xpm ),
  fileDetails( (char*const*)filedetails_xpm ),
  add_to_favorite_folder( (char*const*)folder_favorite_xpm ),
  home( (char*const*)bighome_xpm ),
  favorites( (char*const*)bigfavorites_xpm ),
  desktop( (char*const*)desktop_xpm ),
  folder_closed( (char*const*)folder_closed_xpm ),
  default_file( (char*const*)textdoc_xpm ),
  my_computer( (char*const*)my_computer_xpm ),
  computer( (char*const*)computer_xpm ),
  disk_drive( (char*const*)disk_drive_xpm ),
  cd_drive( (char*const*)cd_drive_xpm ),
  floppy_drive( (char*const*)floppy_drive_xpm ),
  removable_drive( (char*const*)removable_drive_xpm ),
  ram_drive( (char*const*)ram_drive_xpm ),
  network_drive( (char*const*)network_drive_xpm ),
  documents( (char*const*)filled_folder_xpm ),
  littlehome( (char*const*)home_xpm ),
  little_favorites( (char*const*)mini_folder_favorites_xpm ),
  little_desktop( (char*const*)mini_desktop_xpm ),
  bigdocuments( (char*const*)bigdocuments_xpm ),
  bigtemporary( (char*const*)bigtemporary_xpm );

#define streq(a,b) (strcmp(a,b)==0)

Flu_File_Chooser::FileTypeInfo* Flu_File_Chooser::types = NULL;
int Flu_File_Chooser::numTypes = 0;
int Flu_File_Chooser::typeArraySize = 0;
Flu_File_Chooser::ContextHandlerVector Flu_File_Chooser::contextHandlers;
Flu_File_Chooser::PreviewHandlerVector Flu_File_Chooser::previewHandlers;
Flu_File_Chooser::ImgTxtPreview* Flu_File_Chooser::imgTxtPreview = 0;
int (*Flu_File_Chooser::customSort)(const char*,const char*) = 0;
FluSimpleString Flu_File_Chooser::dArrow[4];
FluSimpleString Flu_File_Chooser::uArrow[4];

#ifndef WIN32
	#include "linux_path_info.c"
#endif

#ifdef WIN32
// Internationalized windows folder name access
// Fix suggested by Fabien Costantini
/*
  CSIDL_DESKTOPDIRECTORY -- desktop
  CSIDL_PERSONAL -- my documents
  CSIDL_PERSONAL and strip back to last "/" -> home
 */
static FluSimpleString flu_get_special_folder( int csidl )
{
  static char path[MAX_PATH+1];

#ifdef FLU_USE_REGISTRY
  HKEY key;
  DWORD size = MAX_PATH;
  const char *keyQuery = "";
  switch( csidl )
    {
    case CSIDL_DESKTOPDIRECTORY: keyQuery = "Desktop"; break;
    case CSIDL_PERSONAL: keyQuery = "Personal"; break;
    }

  if( RegOpenKeyEx( HKEY_CURRENT_USER,
		    "Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders",
		    0, KEY_QUERY_VALUE, &key ) != ERROR_SUCCESS )
    return "";

  if( RegQueryValueEx( key, keyQuery, 0, 0, (LPBYTE)path, &size ) != ERROR_SUCCESS )
    return "";

  RegCloseKey( key );

  return path;

#else

  path[0] = '\0';
  if( SUCCEEDED( SHGetSpecialFolderPath( NULL, path, csidl, FALSE ) ) )
    //if( SUCCEEDED( SHGetFolderPath( NULL, csidl, NULL, 0, path ) ) )
    {
      int len = strlen(path);
      if( len > 0 && path[len-1] != '/' && path[len-1] != '\\' )
	strcat( path, "/" );
      return path;
    }
  return "";
#endif
}
#endif

// taken explicitly from fltk/src/filename_match.cxx
// and changed to support case-sensitive matching
static int flu_filename_match(const char *s, const char *p)
{
  int matched;

  for (;;) {
    switch(*p++) {

    case '?' :	// match any single character
      if (!*s++) return 0;
      break;

    case '*' :	// match 0-n of any characters
      if (!*p) return 1; // do trailing * quickly
      while (!flu_filename_match(s, p)) if (!*s++) return 0;
      return 1;

    case '[': {	// match one character in set of form [abc-d] or [^a-b]
      if (!*s) return 0;
      int reverse = (*p=='^' || *p=='!'); if (reverse) p++;
      matched = 0;
      char last = 0;
      while (*p) {
	if (*p=='-' && last) {
	  if (*s <= *++p && *s >= last ) matched = 1;
	  last = 0;
	} else {
	  if (*s == *p) matched = 1;
	}
	last = *p++;
	if (*p==']') break;
      }
      if (matched == reverse) return 0;
      s++; p++;}
    break;

    case '{' : // {pattern1|pattern2|pattern3}
    NEXTCASE:
    if (flu_filename_match(s,p)) return 1;
    for (matched = 0;;) {
      switch (*p++) {
      case '\\': if (*p) p++; break;
      case '{': matched++; break;
      case '}': if (!matched--) return 0; break;
      case '|': case ',': if (matched==0) goto NEXTCASE;
      case 0: return 0;
      }
    }
    case '|':	// skip rest of |pattern|pattern} when called recursively
    case ',':
      for (matched = 0; *p && matched >= 0;) {
	switch (*p++) {
	case '\\': if (*p) p++; break;
	case '{': matched++; break;
	case '}': matched--; break;
	}
      }
      break;
    case '}':
      break;

    case 0:	// end of pattern
      return !*s;

    case '\\':	// quote next character
      if (*p) p++;
    default:
#ifdef WIN32
      if (tolower(*s) != tolower(*(p-1))) return 0;
#else
      if( *s != *(p-1) ) return 0;
#endif
      s++;
      break;
    }
  }
}

void Flu_File_Chooser :: add_context_handler( int type, const char *ext, const char *name,
					      void (*cb)(const char*,int,void*), void *cbd )
{
  if( cb == NULL )
    return;
  ContextHandler h;
  h.ext = ext ? ext : "";
  h.ext.downcase();
  h.type = type;
  h.name = name;
  h.callback = cb;
  h.callbackData = cbd;
  Flu_File_Chooser::contextHandlers.add( h );
}

void Flu_File_Chooser :: add_preview_handler( PreviewWidgetBase *w )
{
  if( w == NULL )
    return;
  Flu_File_Chooser::previewHandlers.add( w );
}

// extensions == NULL implies directories
void Flu_File_Chooser :: add_type( const char *extensions, const char *short_description, Fl_Image *icon )
{
  FluSimpleString ext;
  if( extensions )
    ext = extensions;
  else
    ext = "\t"; // indicates a directory
  ext.upcase();

  // are we overwriting an existing type?
  for( int i = 0; i < numTypes; i++ )
    {
      if( types[i].extensions == ext )
	{
	  types[i].icon = icon;
	  types[i].type = short_description;
	  return;
	}
    }

  if( numTypes == typeArraySize )
    {
      int newSize = ( typeArraySize == 0 ) ? 1 : typeArraySize*2; // double the size of the old list (same behavior as STL vector)
      // allocate the new list
      FileTypeInfo* newTypes = new FileTypeInfo[ newSize ];
      // copy the old list to the new list
      for( int i = 0; i < numTypes; i++ )
	{
	  newTypes[i].icon = types[i].icon;
	  newTypes[i].extensions = types[i].extensions;
	  newTypes[i].type = types[i].type;
	}
      // delete the old list and replace it with the new list
      delete[] types;
      types = newTypes;
      typeArraySize = newSize;
    }

  types[numTypes].icon = icon;
  types[numTypes].extensions = ext;
  types[numTypes].type = short_description;

  numTypes++;
}

Flu_File_Chooser::FileTypeInfo* Flu_File_Chooser :: find_type( const char *extension )
{
  FluSimpleString ext;
  if( extension )
    ext = extension;
  else
    ext = "\t"; // indicates a directory
  ext.upcase();

  // lookup the type based on the extension
  for( int i = 0; i < numTypes; i++ )
    {
      // check extension against every token
      FluSimpleString e = types[i].extensions;
      char *tok = strtok( (char*)e.c_str(), " ," );
      while( tok )
	{
	  if( ext == tok )
	    return &(types[i]);
	  tok = strtok( NULL, " ," );
	}
    }

  return NULL;
}

Flu_File_Chooser :: Flu_File_Chooser( const char *pathname, const char *pat, int type, const char *title )
  : Fl_Double_Window( 600, 400, title ),
    filename( 70, h()-60, w()-70-85-10, 25, "", this ),
    ok( w()-90, h()-60, 85, 25 ),
    cancel( w()-90, h()-30, 85, 25 ),
    entryPopup( 0, 0, 0, 0 )
{
  int oldNormalSize = FL_NORMAL_SIZE;
  FL_NORMAL_SIZE = 12;

  _callback = 0;
  _userdata = 0;
  Fl_Double_Window::callback( _hideCB, this );

  Fl_Double_Window::size_range( 600, 400 );

  Fl_Group *g;

  filename.label( filenameTxt.c_str() );
  ok.label( okTxt.c_str() );
  ok.labelsize( FL_NORMAL_SIZE );
  cancel.label( cancelTxt.c_str() );
  cancel.labelsize( FL_NORMAL_SIZE );

  add_type( NULL, directoryTxt.c_str(), &folder_closed );

  for( int j = 0; j < 4; j++ )
    {
      dArrow[j] = "@-12DnArrow " + detailTxt[j];
      uArrow[j] = "@-18UpArrow " + detailTxt[j];
    }

  history = currentHist = NULL;
  walkingHistory = false;
  fileEditing = false;
#ifdef WIN32
  refreshDrives = true;
  caseSort = false;
#else
  caseSort = true;
#endif

  // determine the system paths for the user's home area, desktop, documents, app data, etc
#ifdef WIN32
  userDesktop = flu_get_special_folder( CSIDL_DESKTOPDIRECTORY );
  userDocs = flu_get_special_folder( CSIDL_PERSONAL );

  // get home area by stripping off to the last '/' from docs
  userHome = userDocs;
  {
    for( int i = userHome.size()-1; i > 0; i-- )
      {
	if( userHome[i] == '/' )
	  {
	    userHome[i] = '\0';
	    break;
	  }
      }
  }

  // construct the user desktop path
  //userDesktop = userHome + "/" + desktopTxt;

  win2unix( userDesktop );
  win2unix( userDocs );

  // make sure they don't end in '/'
  if( userDesktop[userDesktop.size()-1] == '/' )
    userDesktop[userDesktop.size()-1] = '\0';
  if( userDocs[userDocs.size()-1] == '/' )
    userDocs[userDocs.size()-1] = '\0';

  // get the actual name of the "My Documents" folder by pulling off the last name in the field
  // we do this because the actual name may vary from country to country
  {
    int slash = userDesktop.rfind( '/' );
    if( slash != -1 )
      desktopTxt = userDesktop.c_str() + slash + 1;
    slash = userDocs.rfind( '/' );
    if( slash != -1 )
      myDocumentsTxt = userDocs.c_str() + slash + 1;
  }

  // make sure they end in '/'
  userHome += "/";
  userDesktop += "/";
  userDocs += "/";

#else
  {
    char buf[1024];
    fl_filename_expand( buf, 1024, "~/" );
    userHome = buf;
    userDesktop = xdg_user_dir_lookup ("DESKTOP");
    userDocs = xdg_user_dir_lookup ("DOCUMENTS");
  }
#endif
  configFilename = userHome + ".Flu_File_Chooser.favorites";

  selectionType = type;
  filenameEnterCallback = filenameTabCallback = false;
  sortMethod = SORT_NAME;

  lastSelected = NULL;
  filename.labelsize( 12 );
  filename.when( FL_WHEN_ENTER_KEY_ALWAYS );
  filename.callback( _filenameCB, this );
  filename.value( "" );

  Fl_Group *quickIcons = new Fl_Group( 5, 5, 100, h()-10-60 );
  quickIcons->box( FL_DOWN_BOX );
  quickIcons->color( FL_DARK3 );

  Flu_Button *desktopBtn = new Flu_Button( 30, 18, 50, 48 );
  desktopBtn->box( FL_FLAT_BOX );
  desktopBtn->image( desktop );
  desktopBtn->enter_box( FL_THIN_UP_BOX );
  desktopBtn->color( FL_DARK3 );
  desktopBtn->callback( _desktopCB, this );
  { 
    Flu_Label *l = new Flu_Label( 5, 62, 100, 20, desktopTxt.c_str() );
    l->labelcolor( FL_WHITE );
    l->align( FL_ALIGN_CENTER );
  }

  Flu_Button *homeBtn = new Flu_Button( 30, 98, 50, 48 );
  homeBtn->box( FL_FLAT_BOX );
  homeBtn->enter_box( FL_THIN_UP_BOX );
  homeBtn->color( FL_DARK3 );
  homeBtn->callback( _homeCB, this );
  {
#ifdef WIN32
    Flu_Label *l = new Flu_Label( 5, 142, 100, 20, myComputerTxt.c_str() );
    homeBtn->image( my_computer );
#else
    Flu_Label *l = new Flu_Label( 5, 142, 100, 20, myComputerTxt.c_str() );
    homeBtn->image( home );
#endif
    l->labelcolor( FL_WHITE );
    l->align( FL_ALIGN_CENTER );
  }

  Flu_Button *documentsBtn = new Flu_Button( 30, 178, 50, 48 );
  documentsBtn->box( FL_FLAT_BOX );
  documentsBtn->enter_box( FL_THIN_UP_BOX );
  documentsBtn->labelcolor( FL_WHITE );
  documentsBtn->color( FL_DARK3 );
  documentsBtn->callback( _documentsCB, this );
  { 
#ifdef WIN32
    Flu_Label *l = new Flu_Label( 5, 222, 100, 20, myDocumentsTxt.c_str() );
    documentsBtn->image( &bigdocuments );
#else
    Flu_Label *l = new Flu_Label( 5, 222, 100, 20, myDocumentsTxt.c_str() );
    documentsBtn->image( &bigtemporary );
#endif
    l->labelcolor( FL_WHITE );
    l->align( FL_ALIGN_CENTER );
  }

  Flu_Button *favoritesBtn = new Flu_Button( 30, 258, 50, 48 );
  favoritesBtn->box( FL_FLAT_BOX );
  favoritesBtn->image( favorites );
  favoritesBtn->enter_box( FL_THIN_UP_BOX );
  favoritesBtn->color( FL_DARK3 );
  favoritesBtn->callback( _favoritesCB, this );
  { 
    Flu_Label *l = new Flu_Label( 5, 302, 100, 20, favoritesTxt.c_str() );
    l->labelcolor( FL_WHITE );
    l->align( FL_ALIGN_CENTER );
  }

  favoritesList = new Fl_Browser( 0, 0, 0, 0 );
  favoritesList->hide();

  {
    Fl_Group* dummy = new Fl_Group( 5, h()-10-61, 100, 1 );
    quickIcons->resizable( dummy );
  }
  quickIcons->end();

  Fl_Group *dummy = new Fl_Group( 110, 0, w()-110, 70 );

  locationQuickJump = new Fl_Group( 166, 5, w()-171, 8 );
  locationQuickJump->box( FL_NO_BOX );
  locationQuickJump->end();

  location = new Flu_Combo_Tree( 166, 15, w()-171, 22, locationTxt.c_str() );
  location->editable( false );
  location->pop_height( 200 );
  location->tree.all_branches_always_open( true );
#ifdef WIN32
  location->tree.show_root( false );
#endif
  location->tree.show_connectors( false );
  location->tree.horizontal_gap( -10 );
  location->tree.show_leaves( false );
  location->callback( _locationCB, this );

  ////////////////////////////////////////////////////////////////

  g = new Fl_Group( 110, 40, w()-110, 30 ); // group enclosing all the buttons at top

  hiddenFiles = new Fl_Check_Button( 110, 43, 130, 25, showHiddenTxt.c_str() );
  hiddenFiles->callback( reloadCB, this );
#ifdef WIN32
  hiddenFiles->hide();
#endif

  backBtn = new Flu_Button( 285, 43, 25, 25, "@<-" );
  backBtn->labelcolor( fl_rgb_color( 80, 180, 200 ) );
  backBtn->labelsize( 16 );
  backBtn->box( FL_FLAT_BOX );
  backBtn->enter_box( FL_THIN_UP_BOX );
  backBtn->callback( _backCB, this );
  backBtn->tooltip( backTTxt.c_str() );

  forwardBtn = new Flu_Button( 310, 43, 25, 25, "@->" );
  forwardBtn->labelcolor( fl_rgb_color( 80, 180, 200 ) );
  forwardBtn->labelsize( 16 );
  forwardBtn->box( FL_FLAT_BOX );
  forwardBtn->enter_box( FL_THIN_UP_BOX );
  forwardBtn->callback( _forwardCB, this );
  forwardBtn->tooltip( forwardTTxt.c_str() );

  upDirBtn = new Flu_Button( 335, 43, 25, 25 );
  upDirBtn->image( up_folder_img );
  upDirBtn->box( FL_FLAT_BOX );
  upDirBtn->enter_box( FL_THIN_UP_BOX );
  upDirBtn->callback( upDirCB, this );
  upDirBtn->tooltip( upTTxt.c_str() );

  reloadBtn = new Flu_Button( 360, 43, 25, 25 );
  reloadBtn->image( reload );
  reloadBtn->box( FL_FLAT_BOX );
  reloadBtn->enter_box( FL_THIN_UP_BOX );
  reloadBtn->callback( reloadCB, this );
  reloadBtn->tooltip( reloadTTxt.c_str() );

  {
    Flu_Separator *sep = new Flu_Separator( 385, 42, 10, 28 );
    sep->type( Flu_Separator::VERTICAL );
    sep->box( FL_ENGRAVED_BOX );
  }

  trashBtn = new Flu_Button( 395, 43, 25, 25 );
  trashBtn->image( trash );
  trashBtn->box( FL_FLAT_BOX );
  trashBtn->enter_box( FL_THIN_UP_BOX );
  trashBtn->callback( _trashCB, this );
  trashBtn->tooltip( trashTTxt.c_str() );

  newDirBtn = new Flu_Button( 420, 43, 25, 25 );
  newDirBtn->image( new_folder );
  newDirBtn->box( FL_FLAT_BOX );
  newDirBtn->enter_box( FL_THIN_UP_BOX );
  newDirBtn->callback( _newFolderCB, this );
  newDirBtn->tooltip( newDirTTxt.c_str() );

  addFavoriteBtn = new Flu_Button( 445, 43, 25, 25 );
  addFavoriteBtn->image( add_to_favorite_folder );
  addFavoriteBtn->box( FL_FLAT_BOX );
  addFavoriteBtn->enter_box( FL_THIN_UP_BOX );
  addFavoriteBtn->callback( _addToFavoritesCB, this );
  addFavoriteBtn->tooltip( addFavoriteTTxt.c_str() );

  {
    Flu_Separator *sep = new Flu_Separator( 470, 42, 10, 28 );
    sep->type( Flu_Separator::VERTICAL );
    sep->box( FL_ENGRAVED_BOX );
  }

  previewBtn = new Flu_Button( 482, 43, 23, 25 );
  previewBtn->type( FL_TOGGLE_BUTTON );
  previewBtn->image( preview_img );
  previewBtn->callback( _previewCB, this );
  previewBtn->tooltip( previewTTxt.c_str() );

  {
    Fl_Group *g2 = new Fl_Group( 511, 43, 81, 25 );
    fileListBtn = new Flu_Button( 511, 43, 25, 25 );
    fileListBtn->type( FL_RADIO_BUTTON );
    fileListBtn->value(1);
    fileListBtn->callback( _listModeCB, this );
    fileListBtn->image( file_list_img );
    fileListBtn->tooltip( listTTxt.c_str() );
    fileListWideBtn = new Flu_Button( 540, 43, 25, 25 );
    fileListWideBtn->type( FL_RADIO_BUTTON );
    fileListWideBtn->callback( _listModeCB, this );
    fileListWideBtn->image( file_listwide_img );
    fileListWideBtn->tooltip( wideListTTxt.c_str() );
    fileDetailsBtn = new Flu_Button( 569, 43, 25, 25 );
    fileDetailsBtn->type( FL_RADIO_BUTTON );
    fileDetailsBtn->image( fileDetails );
    fileDetailsBtn->callback( _listModeCB, this );
    fileDetailsBtn->tooltip( detailTTxt.c_str() );
    g2->end();
  }

  g->resizable( hiddenFiles );
  g->end();

  dummy->resizable( location );
  dummy->end();

  ////////////////////////////////////////////////////////////////

  previewTile = new PreviewTile( 110, 70, w()-110-5, h()-80-40-15, this );
  fileGroup = new Fl_Group( 110, 70, w()-120-5, h()-80-40-15 );
  {
    fileGroup->box( FL_DOWN_FRAME );
    filelist = new FileList( fileGroup->x()+2, fileGroup->y()+2, fileGroup->w()-4, fileGroup->h()-4, this );
    filelist->box( FL_FLAT_BOX );
    filelist->color( FL_WHITE );
    filelist->type( FL_HORIZONTAL );
    filelist->spacing( 4, 1 );
    filelist->scrollbar.linesize( DEFAULT_ENTRY_WIDTH+4 );
    filelist->end();

    fileDetailsGroup = new Fl_Group( fileGroup->x()+2, fileGroup->y()+2, fileGroup->w()-4, fileGroup->h()-4 );
    filecolumns = new FileColumns( fileGroup->x()+2, fileGroup->y()+2, fileGroup->w()-4, 20, this );
    filescroll = new Fl_Scroll( fileGroup->x()+2, fileGroup->y()+22, fileGroup->w()-4, fileGroup->h()-20-4 );
    filescroll->color( FL_WHITE );
    filescroll->scrollbar.linesize( 20 );
    filescroll->box( FL_FLAT_BOX );
    filescroll->type( Fl_Scroll::VERTICAL );
    {
      filedetails = new FileDetails( fileGroup->x()+2, fileGroup->y()+22, fileGroup->w()-4, fileGroup->h()-20-4, this );
      filedetails->end();
    }
    filescroll->end();
    fileDetailsGroup->end();
    fileDetailsGroup->resizable( filescroll );

    fileGroup->resizable( filelist );
  }
  fileGroup->end();

  previewGroup = new PreviewGroup( fileGroup->x()+fileGroup->w(), fileGroup->y(), previewTile->w()-fileGroup->w(), fileGroup->h(), this );
  previewGroup->end();
  {
    Fl_Box *b = new Fl_Box( previewTile->x()+250, previewTile->y(), previewTile->w()-350, previewTile->h() );
    previewTile->add_resizable( *b );
  }
  previewTile->end();
  previewTile->position( previewGroup->x(), previewGroup->y(), previewTile->x()+previewTile->w(), previewGroup->y() );
  previewTile->last = previewTile->x()+previewTile->w()-200;

  resizable( previewTile );

  filePattern = new Flu_Combo_List( 70, h()-30, w()-70-85-10, 25, fileTypesTxt.c_str() );
  filePattern->editable( false );
  filePattern->callback( reloadCB, this );
  filePattern->pop_height( 200 );

  ok.callback( _okCB, this );
  cancel.callback( _cancelCB, this );

  {
    g = new Fl_Group( 0, h()-60, w(), 30 );
    g->end();
    g->add( filename );
    g->add( ok );
    g->resizable( filename );
    g = new Fl_Group( 0, h()-30, w(), 30 );
    g->end();
    g->add( filePattern );
    g->add( cancel );
    g->resizable( filePattern );
  }

  end();

  FL_NORMAL_SIZE = oldNormalSize;

  char buf[1024];

  // try to load the favorites
  {
    FILE *f = fopen( configFilename.c_str(), "r" );
    if( f )
      {
	buf[0] = '\0';
	while( !feof(f) )
	  {
	    fgets( buf, 1024, f );
	    char *newline = strrchr( buf, '\n' );
	    if( newline )
	      *newline = '\0';
	    if( strlen( buf ) > 0 )
	      {
		// eliminate duplicates
		bool duplicate = false;
		for( int i = 1; i <= favoritesList->size(); i++ )
		  {
		    if( streq( buf, favoritesList->text(i) ) )
		      {
			duplicate = true;
			break;
		      }
		  }
		if( !duplicate )
		  favoritesList->add( buf );
	      }
	  }
	fclose( f );
      }
  }

  if( !imgTxtPreview )
    {
      imgTxtPreview = new ImgTxtPreview();
      // make the text previewer the first one
      Flu_File_Chooser::previewHandlers.insert( 0, imgTxtPreview );
    }

  pattern( pat );
  default_file_icon( &default_file );
  cd( NULL ); // prime with the current directory
  clear_history();
  cd( pathname );

  // if pathname does not start with "/" or "~", set the filename to it
  if( pathname && pathname[0] != '/' && pathname[1] != ':' && pathname[0] != '~' )
    filename.value( pathname );
}

Flu_File_Chooser :: ~Flu_File_Chooser()
{
  //Fl::remove_timeout( Entry::_editCB );
  Fl::remove_timeout( Flu_File_Chooser::delayedCdCB );
  Fl::remove_timeout( Flu_File_Chooser::selectCB );

  for( int i = 0; i < locationQuickJump->children(); i++ )
    free( (void*)locationQuickJump->child(i)->label() );

  filelist->clear();
  filedetails->clear();

  clear_history();
}

void Flu_File_Chooser :: hideCB()
{
  // the user hid the browser by pushing the "X"
  // this is the same as cancel
  cancelCB();
}

void Flu_File_Chooser :: cancelCB()
{ 
  filename.value("");
  filename.position( filename.size(), filename.size() );
  unselect_all();
  do_callback();
  hide();
}

void Flu_File_Chooser :: do_callback()
{
  if( _callback )
    _callback( this, _userdata );
}

void Flu_File_Chooser :: pattern( const char *p )
{
  // just like in Fl_File_Chooser, we accept tab, |, and ; delimited strings like this:
  // "Description (patterns)" or just "patterns" where patterns is 
  // of the form *.xxx or *.{xxx,yyy,zzz}}

  rawPattern = p;

  // clear out the old
  filePattern->list.clear();
  filePattern->input.value( "" );
  patterns.clear();

  if( p == 0 )
    p = "*";
  else if( p[0] == '\0' )
    p = "*";

  FluSimpleString pat = p, pattern;

  bool addedAll = false;
  const char *next = strtok( (char*)pat.c_str(), "\t|;" );
  const char *start;
  while( next )
    {
      if( next[0] == '\0' )
	break;

      // eat whitespace
      while( isspace( *next ) )
	next++;

      // degenerate check
      if( strcmp( next, "*" ) == 0 )
	{
	  addedAll = true;
	  filePattern->list.add( allFilesTxt.c_str() );
	  patterns.add( "*" );
	  next = strtok( NULL, "\t|;" );
	  continue;
	}

      // extract the patterns from the substring
      if( next[0] != '*' ) // starts with description
	{
	  // the pattern starts after the first '('
	  start = strchr( next, '(' );
	  if( !start ) // error: couldn't find the '('
	    {
	      next = strtok( NULL, "\t|;" );
	      continue;
	    }
	  start++; // skip the '('
	}
      else
	start = next;

      if( start[0] != '*' )
	{
	  next = strtok( NULL, "\t|;" );
	  continue;
	}
      start++; // skip the '*'

      if( start[0] != '.' )
	{
	  next = strtok( NULL, "\t|;" );
	  continue;
	}
      start++; // skip the '.'

      if( start[0] == '{' )
	{
	  // the pattern is between '{' and '}'
	  pattern = start+1;
	}
      else
	pattern = start;

      // remove the last '}'
      int brace = pattern.find( '}' );
      if( brace != -1 )
	pattern[brace] = '\0';

      // remove the last ')'
      int paren = pattern.find( ')' );
      if( paren != -1 )
	pattern[paren] = '\0';

      if( pattern.size() )
	{
	  // add the whole string to the list
	  filePattern->list.add( next );
	  patterns.add( pattern );
	}

      // advance to the pattern token
      next = strtok( NULL, "\t|;" );
   }

  // add all files
  if( !addedAll )
    {
      filePattern->list.add( allFilesTxt.c_str() );
      patterns.add( "*" );
    }

  // choose the first added item
  filePattern->value( filePattern->list.text(1) );
}

int Flu_File_Chooser :: handle( int event )
{
  if( Fl_Double_Window::callback() != _hideCB )
    {
      _callback = Fl_Double_Window::callback();
      _userdata = Fl_Double_Window::user_data();
      Fl_Double_Window::callback( _hideCB, this );
    }

  if( Fl_Double_Window::handle( event ) )
    return 1;
  else if( event == FL_KEYDOWN && Fl::event_key(FL_Escape) )
    {
      cancel.do_callback();
      return 1;
    }
  else if( event == FL_KEYDOWN && Fl::event_key('a') && Fl::event_state(FL_CTRL) )
    {
      select_all();
      return 1;
    }
  else
    return 0;
}

void Flu_File_Chooser :: newFolderCB()
{
  // start with the name "New Folder". while the name exists, keep appending a number (1..2..etc)
  FluSimpleString newName = defaultFolderNameTxt.c_str(), path = currentDir + newName;
  int count = 1;
  int i;
  for(;;)
    {
      bool found = false;
      // see if any entry already has that name
      Fl_Group *g = getEntryGroup();
      for( i = 0; i < g->children(); i++ )
	{
	  if( ((Entry*)g->child(i))->filename == newName )
	    {
	      found = true;
	      break;
	    }
	}

      // since an entry already exists, change the name and try again
      if( found )
	{
	  char buf[16];
	  sprintf( buf, "%d", count++ );
	  newName = defaultFolderNameTxt.c_str() + FluSimpleString(buf);
	  path = currentDir + newName;
	}
      else
	break;
    }

  // try to create the folder
#if ( defined WIN32 || defined MINGW ) && !defined CYGWIN
  if( mkdir( path.c_str() ) != 0 )
#else
  if( mkdir( path.c_str(), S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH ) != 0 )
#endif
    {
      fl_alert( createFolderErrTxt.c_str(), newName.c_str() );
      return;
    }  

  // create a new entry with the name of the new folder. add to either the list or the details
  Entry *entry = new Entry( newName.c_str(), ENTRY_DIR, fileDetailsBtn->value(), this );
  if( !fileDetailsBtn->value() )
    filelist->add( *entry );
  else
    filedetails->add( *entry );

  // switch that entry to input mode and scroll the browser to it
  entry->editCB();
  /*
  entry->editMode = 2;
  entry->value( entry->filename.c_str() );
  entry->take_focus();
  entry->position( 0, entry->filename.size() );  
  entry->redraw();
  */
  if( !fileDetailsBtn->value() )
    filelist->scroll_to( entry );
  else
    filedetails->scroll_to( entry );
}

void Flu_File_Chooser :: recursiveScan( const char *dir, FluStringVector *files )
{
  dirent **e;
  char *name;
  FluSimpleString fullpath;
  int num = fl_filename_list( dir, &e );
  for( int i = 0; i < num; i++ )
    {
      name = e[i]->d_name;

      // if 'name' ends in '/' or '\', remove it
      if( name[strlen(name)-1] == '/' || name[strlen(name)-1] == '\\' )
	name[strlen(name)-1] = '\0';

      // ignore the "." and ".." names
      if( strcmp( name, "." ) == 0 || strcmp( name, ".." ) == 0 )
	continue;

      // file or directory?
      fullpath = dir;
      fullpath += "/";
      fullpath += name;
      if( fl_filename_isdir( fullpath.c_str() ) != 0 )
	recursiveScan( fullpath.c_str(), files );

      files->add( fullpath );
    }
  files->add( dir );
}

void Flu_File_Chooser :: trashCB( bool recycle )
{
  // linux doesn't have a recycle bin
#ifndef WIN32
  recycle = false;
#endif

  bool inFavorites = ( currentDir == FAVORITES_UNIQUE_STRING );
  if( inFavorites )
    recycle = false;

  // see how many files are selected
  FluSimpleString name;
  int selected = 0;
  int i;
  const char *first = "";
  Fl_Group *g = getEntryGroup();
  for( i = 0; i < g->children(); i++ )
    {
      if( ((Entry*)g->child(i))->selected )
	{
	  if( selected == 0 )
	    first = ((Entry*)g->child(i))->filename.c_str();
	  selected++;
	}
    }

   if( selected )
     {
       if( selected == 1 )
	 {
	   if( recycle )
	     {
	       if( !fl_ask( "Really send '%s' to the Recycle Bin?", first ) )
		 return;
	     }
	   else
	     {
	       if( !fl_ask( "Really delete '%s'?", first ) )
		 return;
	     }
	 }
       else
	 {
	   if( recycle )
	     {
	       if( !fl_ask( "Really send these %d files to the Recycle Bin?", selected ) )
		 return;
	     }
	   else
	     {
	       if( !fl_ask( "Really delete these %d files?", selected ) )
		 return;
	     }
	 }

       if( inFavorites )
	 {
	   for( i = 0; i < g->children(); )
	     {
	       Entry *e = ((Entry*)g->child(i));
	       if( e->selected )
		 {
		   favoritesList->remove(i+1);
		   g->remove( *e );
		   delete e;
		 }
	       else 
		 i++;
	     }
	   // save the favorites
	   FILE *f = fopen( configFilename.c_str(), "w" );
	   if( f )
	     {
	       for( i = 1; i <= favoritesList->size(); i++ )
		 fprintf( f, "%s\n", favoritesList->text(i) );
	       fclose( f );
	     }
	   cd( FAVORITES_UNIQUE_STRING );
	   return;
	 }

#ifdef WIN32
       SHFILEOPSTRUCT fileop;
       memset( &fileop, 0, sizeof(SHFILEOPSTRUCT) );
       fileop.fFlags = FOF_SILENT | FOF_NOERRORUI | FOF_NOCONFIRMATION;
       if( recycle )
	 fileop.fFlags |= FOF_ALLOWUNDO;
       fileop.wFunc = FO_DELETE;
       fileop.pTo = NULL;
#endif

       for( i = 0; i < g->children(); i++ )
	 {
	   if( ((Entry*)g->child(i))->selected )
	     {
	       int result = 0;

	       name = currentDir + ((Entry*)g->child(i))->filename;

	       // if directory, recursively remove
	       if( ((Entry*)g->child(i))->type == ENTRY_DIR )
		 {
		   // if we are recycling in windows, then the recursive part happens automatically
#ifdef WIN32
		   if( !recycle )
#endif
		     {
		       Fl_Group::current(0);
		       Fl_Window *win = new Fl_Window( 200, 100, "Notice" );
		       Flu_Label *label = new Flu_Label( 30, 30, 150, 30, "Preparing to delete..." );
		       win->end();
		       win->show();
		       Fl::check();
		       // recursively build a list of all files that will be deleted
		       FluStringVector files;
		       recursiveScan( name.c_str(), &files );
		       // delete all the files
		       label->label( "Deleting files..." );
		       for( unsigned int i = 0; i < files.size(); i++ )
			 {
			   if( ::remove( files[i].c_str() ) != 0 )
			     {
			       win->hide();
			       delete win;
			       cd( "./" );
			       return;
			     }
			 }
		       win->hide();
		       delete win;
		       Fl::check();
		       continue;
		     }
		 }

#ifdef WIN32
	       // this moves files to the recycle bin, depending on the value of 'recycle'
	       {
		 int len = name.size();
		 char *buf = (char*)malloc( len+2 );
		 strcpy( buf, name.c_str() );
		 buf[len+1] = '\0'; // have to have 2 '\0' at the end
		 fileop.pFrom = buf;
		 result = SHFileOperation( &fileop );
		 free( buf );
	       }
#else
	       result = ::remove( name.c_str() );
#endif

	       // if remove fails, report an error
	       if( result != 0 )
		 {
		   fl_alert( deleteFileErrTxt.c_str(), name.c_str() );
		   cd( "./" );
		   return;
		 }
	     }
	 }

       // refresh this directory
       cd( "./" );
    }
}

void Flu_File_Chooser :: updateLocationQJ()
{
  const char *path = location->value();
  for( int i = 0; i < locationQuickJump->children(); i++ )
    free( (void*)locationQuickJump->child(i)->label() );
  locationQuickJump->clear();
  fl_font( location->input.textfont(), location->input.textsize() );
  const char *next = path;
  const char *slash = strchr( next, '/' );
  char *blank = strdup( path );
  int offset = 0;
  while( slash )
    {
      memset( blank, 0, strlen(path) );
      slash++;
      memcpy( blank, next, slash-next );
      int w = 0, h = 0;
      fl_measure( blank, w, h );
      if( blank[0] == '/' )
	w += Fl::box_dx( location->box() );
      memset( blank, 0, strlen(path) );
      memcpy( blank, path, slash-path );
      Fl_Button *b = new Fl_Button( locationQuickJump->x()+offset, locationQuickJump->y(), w, locationQuickJump->h(), strdup(blank) );
      b->labeltype( FL_NO_LABEL );
      b->callback( _locationQJCB, this );
      offset += w;
      locationQuickJump->add( b );
      next = slash;
      slash = strchr( next, '/' );
    }
  Fl_Button *b = new Fl_Button( locationQuickJump->x()+offset, locationQuickJump->y(), 1, locationQuickJump->h(), strdup("") );
  b->box( FL_NO_BOX );
  b->labeltype( FL_NO_LABEL );
  locationQuickJump->add( b );
  locationQuickJump->resizable( b );
  free( blank );
}

void Flu_File_Chooser :: favoritesCB()
{ 
  cd( FAVORITES_UNIQUE_STRING );
}

void Flu_File_Chooser :: myComputerCB()
{ 
  cd( "/" );
}

void Flu_File_Chooser :: documentsCB()
{
  cd( userDocs.c_str() );
}

Flu_File_Chooser :: FileInput :: FileInput( int x, int y, int w, int h, const char *l, Flu_File_Chooser *c )
  : Fl_Input( x, y, w, h, l )
{
  chooser = c;
}

Flu_File_Chooser :: FileInput :: ~FileInput()
{
}

int Flu_File_Chooser :: FileInput :: handle( int event )
{
  if( event == FL_KEYDOWN )
    {
      if( Fl::event_key(FL_Tab) )
	{
	  chooser->filenameTabCallback = true;
	  FluSimpleString v(value());
#ifdef WIN32
	  // turn "C:" into "C:\"
	  if( v.size() >= 2 )
	    if( v[1] == ':' && v[2] == '\0' )
	      {
		v += "/";
		value( v.c_str() );
		position( size(), size() );
	      }
#endif
	  chooser->delayedCd = v + "*";
	  Fl::add_timeout( 0.0f, Flu_File_Chooser::delayedCdCB, chooser );
	  return 1;
	}
      else if( Fl::event_key(FL_Left) )
	{
	  if( Fl_Input::position() == 0 )
	    return 1;
	  else
	    return Fl_Input::handle( event );
	}
      else if( Fl::event_key(FL_Right) )
	{
	  if( Fl_Input::position() == (int)strlen(Fl_Input::value()) )
	    return 1;
	  else
	    return Fl_Input::handle( event );
	}
      else if( Fl::event_key(FL_Up) || Fl::event_key(FL_Down) )
	{
	  chooser->getEntryContainer()->take_focus();
	  if( !chooser->lastSelected )
	    {
	      if( chooser->getEntryGroup()->children() )
		{
		  Flu_File_Chooser::Entry *e = (Flu_File_Chooser::Entry*)chooser->getEntryGroup()->child(0);
		  e->selected = true;
		  chooser->lastSelected = e;
		  e->redraw();
		}
	    }
	  return chooser->getEntryContainer()->handle( event );
	}
    }

  return Fl_Input::handle( event );
}

Flu_File_Chooser :: PreviewTile :: PreviewTile( int x, int y, int w, int h, Flu_File_Chooser *c )
   : Fl_Tile( x, y, w, h )
{
  chooser = c;
}

int Flu_File_Chooser :: PreviewTile :: handle( int event )
{
  // if we're not in preview mode, then the user isn't allowed to resize the tile
  if( !chooser->previewBtn->value() )
    return Fl_Group::handle( event );
  if( event == FL_DRAG )
    {
      // the user is probably dragging to resize the columns
      // update the sizes for each entry
      chooser->updateEntrySizes();
      chooser->redraw();
    }
  return Fl_Tile::handle(event);
}

Flu_File_Chooser :: PreviewWidgetBase :: PreviewWidgetBase()
  : Fl_Group( 0, 0, 0, 0 )
{
}

Flu_File_Chooser :: PreviewWidgetBase :: ~PreviewWidgetBase()
{
}

Flu_File_Chooser :: PreviewGroup :: PreviewGroup( int x, int y, int w, int h, Flu_File_Chooser *c )
  : Fl_Group( x, y, w, h )
{
  box( FL_DOWN_BOX );
  align( FL_ALIGN_CENTER | FL_ALIGN_CLIP );
  labelsize( 60 );
  labelfont( FL_HELVETICA );
  chooser = c;
  handled = 0;
  lastFile = "";
}

void Flu_File_Chooser :: PreviewGroup :: draw()
{
  if( !chooser->previewBtn->value() )
    return;

  if( file.size() == 0 )
    return;

  FILE *f = fopen( file.c_str(), "rb" );
  if( !f )
    {
      label( "" );
      Fl_Group::draw();
      return;
    }
  fclose( f );

  if( lastFile != file )
    {
      lastFile = file;

      handled = 0;
      PreviewWidgetBase *next;
      for( int i = chooser->previewHandlers.size()-1; i >= 0; i-- )
	{
	  next = chooser->previewHandlers[i];
	  next->hide();
	  if( !handled )
	    {
	      Fl_Group *p = next->parent();
	      Fl_Group::add( next );
	      if( next->preview( file.c_str() ) != 0 )
		{
		  handled = next;
		}
	      Fl_Group::remove( *next );
	      if( p )
		p->add( next );
	    }
	}
    }

  if( handled == 0 )
    {
      label( "?" );
      Fl_Group::draw();
    }
  else
    {
      label( "" );
      Fl_Group *p = handled->parent();
      handled->show();
      Fl_Group::add( handled );
      handled->resize( x()+Fl::box_dx(box()), y()+Fl::box_dy(box()),
		       w()-Fl::box_dw(box()), h()-Fl::box_dh(box()) );
      Fl_Group::draw();
      Fl_Group::remove( *handled );
      handled->hide();
      if( p )
	p->add( handled );
    }
}

// adapted from Fl_File_Chooser2.cxx : update_preview()
int Flu_File_Chooser :: ImgTxtPreview ::  preview( const char *filename )
{
  Fl_Shared_Image	*img,		// New image
			*oldimg;	// Old image
  int			pbw, pbh;	// Width and height of preview box
  int			w, h;		// Width and height of preview image

  window()->cursor( FL_CURSOR_WAIT );
  Fl::check();

  img = Fl_Shared_Image::get( filename );
  if( img )
    {
      window()->cursor( FL_CURSOR_DEFAULT );
      Fl::check();
    }

  oldimg = (Fl_Shared_Image*)image();
  if( oldimg )
    oldimg->release();
  image(0);

  if( !img )
    {
      // Try reading the first 1k of data for a label...
      FILE *f = fopen( filename, "rb" );
      if( f )
	{
	  int bytes = fread( previewTxt, 1, sizeof(previewTxt) - 1, f );
	  previewTxt[bytes] = '\0';
	  fclose( f );
	} 
      else
	return 0;

      window()->cursor( FL_CURSOR_DEFAULT );
      Fl::check();

      // Scan the buffer for printable chars...
      unsigned char *ptr;
      for( ptr = previewTxt; *ptr && (isprint(*ptr) || isspace(*ptr)); ptr++ ) {}

      if( *ptr || ptr == previewTxt )
	{
	  // Non-printable file - can't handle
	  return 0;
	} 
      else
	{
	  // Show the first 1k of text...
	  label( (const char*)previewTxt );
	  align((Fl_Align)(FL_ALIGN_CLIP | FL_ALIGN_INSIDE | FL_ALIGN_LEFT | FL_ALIGN_TOP));
	  labelsize( 12 );
	  labelfont( FL_COURIER );
	}
    }
  else if( img->w() > 0 && img->h() > 0 )
    {

      pbw = this->w() - 20;
      pbh = this->h() - 20;
      pbw = (pbw < 10) ? 10 : pbw;
      pbh = (pbh < 10) ? 10 : pbh;

      if( img->w() > pbw || img->h() > pbh )
	{
	  w = pbw;
	  h = int(float(w*img->h()) / float(img->w()));

	  if( h > pbh )
	    {
	      h = pbh;
	      w = int(float(h*img->w()) / float(img->h()));
	    }

	  oldimg = (Fl_Shared_Image *)img->copy(w, h);
	  image((Fl_Image *)oldimg);

	  img->release();
	}
      else
	image((Fl_Image *)img);

      align( FL_ALIGN_CLIP );
      label(0);
    }

  redraw();

  return 1;
}

void Flu_File_Chooser :: previewCB()
{
  if( previewBtn->value() )
    {
      fileGroup->resize( fileGroup->x(), fileGroup->y(), previewTile->last-fileGroup->x(), fileGroup->h() );
      previewGroup->resize( previewTile->last, previewGroup->y(), previewTile->w()-fileGroup->w(), previewGroup->h() );
      previewGroup->show();
    }
  else
    {
      previewTile->last = previewGroup->x();
      fileGroup->resize( fileGroup->x(), fileGroup->y(), previewTile->w(), fileGroup->h() );
      previewGroup->resize( previewTile->x()+previewTile->w(), previewGroup->y(), 0, previewGroup->h() );
      previewGroup->hide();
    }
  previewGroup->redraw();
  previewTile->init_sizes();
  fileDetailsGroup->parent()->init_sizes();
  updateEntrySizes();
  redraw();
  if( previewBtn->value() )
    {
      Fl::check();
      previewGroup->redraw();
    }
}

void Flu_File_Chooser :: sortCB( Fl_Widget *w )
{
  // if the sort method is already selected, toggle the REVERSE bit
  if( w == detailNameBtn )
    {
      if( sortMethod & SORT_NAME )
	sortMethod ^= SORT_REVERSE;
      else
	sortMethod = SORT_NAME;
    }
  else if( w == detailSizeBtn )
    {
      if( sortMethod & SORT_SIZE )
	sortMethod ^= SORT_REVERSE;
      else
	sortMethod = SORT_SIZE;
    }
  else if( w == detailDateBtn )
    {
      if( sortMethod & SORT_DATE )
	sortMethod ^= SORT_REVERSE;
      else
	sortMethod = SORT_DATE;
    }
  else if( w == detailTypeBtn )
    {
      if( sortMethod & SORT_TYPE )
	sortMethod ^= SORT_REVERSE;
      else
	sortMethod = SORT_TYPE;
    }

  bool reverse = ( sortMethod & SORT_REVERSE );
  detailNameBtn->label( detailTxt[0].c_str() );
  detailSizeBtn->label( detailTxt[1].c_str() );
  detailDateBtn->label( detailTxt[2].c_str() );
  detailTypeBtn->label( detailTxt[3].c_str() );
  switch( sortMethod & ~SORT_REVERSE )
    {
    case SORT_NAME: detailNameBtn->label( reverse ? dArrow[0].c_str() : uArrow[0].c_str() ); break;
    case SORT_SIZE: detailSizeBtn->label( reverse ? dArrow[1].c_str() : uArrow[1].c_str() ); break;
    case SORT_DATE: detailDateBtn->label( reverse ? dArrow[2].c_str() : uArrow[2].c_str() ); break;
    case SORT_TYPE: detailTypeBtn->label( reverse ? dArrow[3].c_str() : uArrow[3].c_str() ); break;
    }

  filelist->sort();
  filedetails->sort();
}

Flu_File_Chooser :: CBTile :: CBTile( int x, int y, int w, int h, Flu_File_Chooser *c )
   : Fl_Tile( x, y, w, h )
{
  chooser = c;
}

int Flu_File_Chooser :: CBTile :: handle( int event )
{
  if( event == FL_DRAG )
    {
      // the user is probably dragging to resize the columns
      // update the sizes for each entry
      chooser->updateEntrySizes();
      chooser->redraw();
    }
  return Fl_Tile::handle(event);
}

Flu_File_Chooser :: FileColumns :: FileColumns( int x, int y, int w, int h, Flu_File_Chooser *c )
  : Fl_Tile( x, y, w, h )
{
  chooser = c;

  W1 = int(float(w)*0.35f);
  W2 = int(float(w)*0.20f);
  W3 = int(float(w)*0.15f);
  W4 = w-W1-W2-W3;

  Fl_Box *box = new Fl_Box( x+50, y, w-200, h );
  add_resizable( *box );
  c->detailNameBtn = new Flu_Button( x, y, W1, h, detailTxt[0].c_str() );
  c->detailNameBtn->align( FL_ALIGN_CLIP );
  c->detailNameBtn->callback( Flu_File_Chooser::_sortCB, c );
  {
    CBTile *tile = new CBTile( x+W1, y, W2+W3+W4, h, c );
    Fl_Box *box = new Fl_Box( tile->x()+50, tile->y(), tile->w()-150, tile->h() );
    tile->add_resizable( *box );
    c->detailTypeBtn = new Flu_Button( x+W1, y, W2, h, detailTxt[3].c_str() );
    c->detailTypeBtn->align( FL_ALIGN_CLIP );
    c->detailTypeBtn->callback( Flu_File_Chooser::_sortCB, c );
    {
      CBTile *tile = new CBTile( x+W1+W2, y, W3+W4, h, c );
      Fl_Box *box = new Fl_Box( tile->x()+50, tile->y(), tile->w()-100, tile->h() );
      tile->add_resizable( *box );
      c->detailSizeBtn = new Flu_Button( x+W1+W2, y, W3, h, detailTxt[1].c_str() );
      c->detailSizeBtn->align( FL_ALIGN_CLIP );
      c->detailSizeBtn->callback( Flu_File_Chooser::_sortCB, c );
      c->detailDateBtn = new Flu_Button( x+W1+W2+W3, y, W4, h, detailTxt[2].c_str() );
      c->detailDateBtn->align( FL_ALIGN_CLIP );
      c->detailDateBtn->callback( Flu_File_Chooser::_sortCB, c );
      tile->end();
    }
    tile->end();
  }
  end();
}

Flu_File_Chooser :: FileColumns :: ~FileColumns()
{
}

void Flu_File_Chooser :: FileColumns :: resize( int x, int y, int w, int h )
{
  // TODO resize the buttons/tiles according to their stored relative sizes
  Fl_Tile::resize( x, y, w, h );
}

int Flu_File_Chooser :: FileColumns :: handle( int event )
{
  if( event == FL_DRAG )
    {
      // the user is probably dragging to resize the columns
      // update the sizes for each entry
      chooser->updateEntrySizes();
      chooser->redraw();
    }
  return Fl_Tile::handle(event);
}

void Flu_File_Chooser :: filenameCB()
{
  printf( "filenameCB\n" );
  filenameEnterCallback = true;
  //cd( filename.value() );
  okCB();
}

inline bool _isProbablyAPattern( const char *s )
{
  return( strpbrk( s, "*;|[]?" ) != NULL );
}

void Flu_File_Chooser :: okCB()
{
  // if exactly one directory is selected and we are not choosing directories,
  // cd to that directory.
  if( !( selectionType & DIRECTORY ) && !( selectionType & STDFILE ) )
    {
      Fl_Group *g = getEntryGroup();
      FluSimpleString dir;
      int count = 0;
      for( int i = 0; i < g->children(); i++ )
	{
	  if( ((Flu_File_Chooser::Entry*)g->child(i))->selected )
	    {
	      count++;
	      dir = ((Flu_File_Chooser::Entry*)g->child(i))->filename;
	    }
	}
      if( count == 1 )
	{
	  FluSimpleString path = currentDir + dir;
	  if( fl_filename_isdir( path.c_str() ) )
	    {
	      cd( dir.c_str() );
	      return;
	    }
	}
    }

  // only hide if the filename is not blank or the user is choosing directories,
  // in which case use the current directory

  if( selectionType & DIRECTORY ||
      ( (selectionType & STDFILE) && fl_filename_isdir( (currentDir+filename.value()).c_str() ) )
      )
    {
#ifdef WIN32
      if( myComputerTxt == filename.value() )
	{
	  myComputerCB();
	  return;
	}
#endif
      if( !(selectionType & MULTI ) )
	{
	  if( strlen( filename.value() ) != 0 )
	    cd( filename.value() );
	  filename.value( currentDir.c_str() );
	  filename.position( filename.size(), filename.size() );
	}
      do_callback();
      hide();
    }
  else
    {
      if( strlen( filename.value() ) != 0 )
	{
	  if( _isProbablyAPattern( filename.value() ) )
	    {
	      cd( filename.value() );
	      return;
	    }
#ifdef WIN32
	  if( filename.value()[1] == ':' )
#else
	  if( filename.value()[0] == '/' )
#endif
	    if( fl_filename_isdir( filename.value() ) )
	      {
		filename.value( "" );
		return;
	      }

	  // prepend the path
	  FluSimpleString path = currentDir + filename.value();
	  filename.value( path.c_str() );
	  filename.position( filename.size(), filename.size() );
	  do_callback();
	  hide();
	}
    }
}

void Flu_File_Chooser :: homeCB()
{
#ifdef WIN32
  cd( "/" );
#else
  cd( userHome.c_str() );
#endif
}

void Flu_File_Chooser :: desktopCB()
{
  cd( userDesktop.c_str() );
}

#define QSCANL( field ) \
      while( ((Flu_File_Chooser::Entry*)array[left])->field < \
             ((Flu_File_Chooser::Entry*)array[pivot])->field ) left++
#define QSCANR( field ) \
      while( ((Flu_File_Chooser::Entry*)array[right])->field > \
	     ((Flu_File_Chooser::Entry*)array[pivot])->field ) right--

#define RQSCANL( field ) \
      while( ((Flu_File_Chooser::Entry*)array[left])->field > \
             ((Flu_File_Chooser::Entry*)array[pivot])->field ) left++
#define RQSCANR( field ) \
      while( ((Flu_File_Chooser::Entry*)array[right])->field < \
	     ((Flu_File_Chooser::Entry*)array[pivot])->field ) right--

#define CASE_QSCANL( field ) \
      while( casecompare( ((Flu_File_Chooser::Entry*)array[left])->field, \
             ((Flu_File_Chooser::Entry*)array[pivot])->field ) < 0 ) left++
#define CASE_QSCANR( field ) \
      while( casecompare( ((Flu_File_Chooser::Entry*)array[right])->field, \
	     ((Flu_File_Chooser::Entry*)array[pivot])->field ) > 0 ) right--

#define CASE_RQSCANL( field ) \
      while( casecompare( ((Flu_File_Chooser::Entry*)array[left])->field, \
             ((Flu_File_Chooser::Entry*)array[pivot])->field ) > 0 ) left++
#define CASE_RQSCANR( field ) \
      while( casecompare( ((Flu_File_Chooser::Entry*)array[right])->field, \
	     ((Flu_File_Chooser::Entry*)array[pivot])->field ) < 0 ) right--

#define CUSTOM_QSCANL( field ) \
      while( customSort( ((Flu_File_Chooser::Entry*)array[left])->field, \
             ((Flu_File_Chooser::Entry*)array[pivot])->field ) < 0 ) left++
#define CUSTOM_QSCANR( field ) \
      while( customSort( ((Flu_File_Chooser::Entry*)array[right])->field, \
	     ((Flu_File_Chooser::Entry*)array[pivot])->field ) > 0 ) right--

#define CUSTOM_RQSCANL( field ) \
      while( customSort( ((Flu_File_Chooser::Entry*)array[left])->field, \
             ((Flu_File_Chooser::Entry*)array[pivot])->field ) > 0 ) left++
#define CUSTOM_RQSCANR( field ) \
      while( customSort( ((Flu_File_Chooser::Entry*)array[right])->field, \
	     ((Flu_File_Chooser::Entry*)array[pivot])->field ) < 0 ) right--

void Flu_File_Chooser :: _qSort( int how, bool caseSort, Fl_Widget **array, int low, int high )
{
  int left, right, pivot;
  Fl_Widget *temp;
  bool reverse = ( how & SORT_REVERSE );

  if( high > low )
    {
      left = low;
      right = high;
      pivot = low;

      while( right >= left )
	{
	  switch( how & ~SORT_REVERSE )
	    {
	    case SORT_NAME:
	      if( reverse )
		{
		  if( customSort )
		    {
		      CUSTOM_RQSCANL( filename.c_str() );
		      CUSTOM_RQSCANR( filename.c_str() );
		    }
		  else if( !caseSort )
		    {
		      CASE_RQSCANL( filename );
		      CASE_RQSCANR( filename );
		    }
		  else
		    {
		      RQSCANL( filename );
		      RQSCANR( filename );
		    }
		}
	      else
		{
		  if( customSort )
		    {
		      CUSTOM_QSCANL( filename.c_str() );
		      CUSTOM_QSCANR( filename.c_str() );
		    }
		  else if( !caseSort )
		    {
		      CASE_QSCANL( filename );
		      CASE_QSCANR( filename );
		    }
		  else
		    {
		      QSCANL( filename );
		      QSCANR( filename );
		    }
		}
	      break;
	    case SORT_SIZE:
	      if( reverse )
		{
		  RQSCANL( isize );
		  RQSCANR( isize );
		}
	      else
		{
		  QSCANL( isize );
		  QSCANR( isize );
		}
	      break;
	    case SORT_DATE:
	      if( reverse )
		{
		  RQSCANL( idate );
		  RQSCANR( idate );
		}
	      else
		{
		  QSCANL( idate );
		  QSCANR( idate );
		}
	      break;
	    case SORT_TYPE:
	      if( reverse )
		{
		  RQSCANL( description );
		  RQSCANR( description );
		}
	      else
		{
		  QSCANL( description );
		  QSCANR( description );
		}
	      break;
	    }

	  if( left > right )
	    break;

	  temp = array[left];
	  array[left] = array[right];
	  array[right] = temp;
	  left++;
	  right--;
	}

      _qSort( how, caseSort, array, low, right );
      _qSort( how, caseSort, array, left, high );
    }
}

Flu_File_Chooser :: FileList :: FileList( int x, int y, int w, int h, Flu_File_Chooser *c )
  : Flu_Wrap_Group( x, y, w, h )
{
  chooser = c;
  numDirs = 0;
}

Flu_File_Chooser :: FileList :: ~FileList()
{
}

void Flu_File_Chooser :: FileList :: sort( int n )
{
  if( n != -1 )
    numDirs = n;
  if( children() == 0 )
    return;
  // the directories are already first. sort the directories then the names lexigraphically
  Flu_File_Chooser::_qSort( chooser->sortMethod, chooser->caseSort, (Fl_Widget**)array(), 0, numDirs-1 );
  Flu_File_Chooser::_qSort( chooser->sortMethod, chooser->caseSort, (Fl_Widget**)array(), numDirs, children()-1 );
  chooser->redraw();
}

int Flu_File_Chooser :: FileList :: handle( int event )
{
  if( event == FL_FOCUS || event == FL_UNFOCUS )
    return 1;
  if( Flu_Wrap_Group::handle( event ) )
    return 1;
  // if push on no file, unselect all files and turn off editing mode
  if( event == FL_PUSH && !Fl::event_key( FL_SHIFT ) && !Fl::event_key( FL_CTRL ) )
    {
      chooser->unselect_all();
      chooser->filename.value( "" );
      chooser->filename.position( chooser->filename.size(), chooser->filename.size() );

      if( Fl::event_button3() )
	return chooser->popupContextMenu( NULL );

      return 1;
    }
  else if( event == FL_KEYDOWN )
    {
      if( Fl::event_key( FL_Delete ) )
	{
	  // recycle by default, unless the shift key is held down
	  chooser->trashCB( !Fl::event_state( FL_SHIFT ) );
	  return 1;
	}

      Flu_File_Chooser::Entry *e = chooser->lastSelected;
      if( !e )
	{
	  for( int i = 0; i < children(); i++ )
	    if( ((Flu_File_Chooser::Entry*)child(i))->selected )
	      {
		e = (Flu_File_Chooser::Entry*)child(i);
		break;
	      }
	}
      if( e )
	{
	  switch( Fl::event_key() )
	    {
	    case FL_Up: e = (Flu_File_Chooser::Entry*)previous( e );
	      if( !e && children() ) e = (Flu_File_Chooser::Entry*)child(0); break;
	    case FL_Down: e = (Flu_File_Chooser::Entry*)next( e );
	      if( !e && children() ) e = (Flu_File_Chooser::Entry*)child(children()-1); break;
	    case FL_Left: e = (Flu_File_Chooser::Entry*)left( e ); break;
	    case FL_Right: e = (Flu_File_Chooser::Entry*)right( e ); break;
	    case FL_Home: if( children() ) e = (Flu_File_Chooser::Entry*)child(0); break;
	    case FL_End: if( children() ) e = (Flu_File_Chooser::Entry*)child(children()-1); break;
	    case FL_Enter:
	      chooser->filenameEnterCallback = true;
	      //chooser->cd( e->filename.c_str() );
	      chooser->okCB();
	      return 1;
	    case ' ':
	      chooser->cd( e->filename.c_str() );
	      return 1;
	    default: e = 0; break;
	    }
	  if( e )
	    {
	      chooser->unselect_all();
	      e->selected = true;
	      chooser->lastSelected = e;
	      chooser->filename.value( e->filename.c_str() );
	      chooser->filename.position( chooser->filename.size(), chooser->filename.size() );
	      chooser->redraw();
	      if( e->type == ENTRY_FILE )
		chooser->previewGroup->file = chooser->currentDir + e->filename;
	      scroll_to( e );
	      return 1;
	    }
	}
    }

  return 0;
}

Flu_File_Chooser :: FileDetails :: FileDetails( int x, int y, int w, int h, Flu_File_Chooser *c )
  : Fl_Pack( x, y, w, h )
{
  chooser = c;
  numDirs = 0;
}

Flu_File_Chooser :: FileDetails :: ~FileDetails()
{
}

void Flu_File_Chooser :: FileDetails :: scroll_to( Fl_Widget *w )
{
  // we know all the widgets are the same height
  // so just find this widget and scroll to the accumulated height
  int H = 0;
  for( int i = 0; i < children(); i++ )
    {
      if( child(i) == w )
	{
	  if( H > (int)chooser->filescroll->scrollbar.maximum() )
	    H = (int)chooser->filescroll->scrollbar.maximum();
	  chooser->filescroll->position( 0, H );
	  return;
	}
      H += w->h();
    }
}

void Flu_File_Chooser :: FileDetails :: sort( int n )
{
  if( n != -1 )
    numDirs = n;
  if( children() == 0 )
    return;
  // the directories are already first. sort the directories then the names lexigraphically
  Flu_File_Chooser::_qSort( chooser->sortMethod, chooser->caseSort, (Fl_Widget**)array(), 0, numDirs-1 );
  Flu_File_Chooser::_qSort( chooser->sortMethod, chooser->caseSort, (Fl_Widget**)array(), numDirs, children()-1 );
  chooser->redraw();
}

Fl_Widget* Flu_File_Chooser :: FileDetails :: next( Fl_Widget* w )
{
  for( int i = 0; i < children()-1; i++ )
    {
      if( w == child(i) )
	return child(i+1);
    }
  return NULL;
}

Fl_Widget* Flu_File_Chooser :: FileDetails :: previous( Fl_Widget* w )
{
  for( int i = 1; i < children(); i++ )
    {
      if( w == child(i) )
	return child(i-1);
    }
  return NULL;
}

int Flu_File_Chooser :: FileDetails :: handle( int event )
{
  if( event == FL_FOCUS || event == FL_UNFOCUS )
    return 1;
  if( Fl_Pack::handle( event ) )
    return 1;
  else if( event == FL_PUSH )
    return 1;

  else if( event == FL_KEYDOWN )
    {
      if( Fl::event_key( FL_Delete ) )
	{
	  // recycle by default, unless the shift key is held down
	  chooser->trashCB( !Fl::event_state( FL_SHIFT ) );
	  return 1;
	}

      Flu_File_Chooser::Entry *e = chooser->lastSelected;
      if( !e )
	{
	  for( int i = 0; i < children(); i++ )
	    if( ((Flu_File_Chooser::Entry*)child(i))->selected )
	      {
		e = (Flu_File_Chooser::Entry*)child(i);
		break;
	      }
	}
      if( e )
	{
	  switch( Fl::event_key() )
	    {
	    case FL_Up: e = (Flu_File_Chooser::Entry*)previous( e );
	      if( !e && children() ) e = (Flu_File_Chooser::Entry*)child(0); break;
	    case FL_Down: e = (Flu_File_Chooser::Entry*)next( e );
	      if( !e && children() ) e = (Flu_File_Chooser::Entry*)child(children()-1); break;
	    case FL_Home: if( children() ) e = (Flu_File_Chooser::Entry*)child(0); break;
	    case FL_End: if( children() ) e = (Flu_File_Chooser::Entry*)child(children()-1); break;
	    case FL_Enter:
	      chooser->filenameEnterCallback = true;
	      //chooser->cd( e->filename.c_str() );
	      chooser->okCB();
	      return 1;
	    case ' ':
	      chooser->cd( e->filename.c_str() );
	      return 1;
	    default: e = 0; break;
	    }
	  if( e )
	    {
	      chooser->unselect_all();
	      e->selected = true;
	      chooser->lastSelected = e;
	      chooser->filename.value( e->filename.c_str() );
	      chooser->filename.position( chooser->filename.size(), chooser->filename.size() );
	      chooser->redraw();
	      scroll_to( e );
	      return 1;
	    }
	}
    }

  return 0;
}

Flu_File_Chooser :: Entry :: Entry( const char* name, int t, bool d, Flu_File_Chooser *c )
  : Fl_Input( 0, 0, 0, 0 )
{
  resize( 0, 0, DEFAULT_ENTRY_WIDTH, 20 );
  textsize( 12 );
  box( FL_BORDER_BOX );
  when( FL_WHEN_RELEASE_ALWAYS | FL_WHEN_ENTER_KEY_ALWAYS );
  callback( _inputCB, this );
  filename = name;
  selected = false;
  chooser = c;
  details = d;
  type = t;
  icon = NULL;
  editMode = 0;
  description = "";

  if( type == ENTRY_FILE && (c->selectionType & DEACTIVATE_FILES) )
    {
      textcolor( FL_GRAY );
      deactivate();
    }

  updateSize();
  updateIcon();
}

void Flu_File_Chooser :: Entry :: updateIcon()
{
  Flu_File_Chooser::FileTypeInfo *tt = NULL;
  if( type==ENTRY_MYCOMPUTER )
    {
      icon = &computer;
      description = myComputerTxt;
    }
  else if( type==ENTRY_MYDOCUMENTS )
    {
      icon = &documents;
      description = myDocumentsTxt;
    }
  else if( type==ENTRY_DRIVE )
    {
      //icon = &disk_drive;
      //description = "";
    }
  else if( type==ENTRY_DIR || type==ENTRY_FAVORITE )
    tt = Flu_File_Chooser::find_type( NULL );
  else
    {
      const char *dot = strrchr( filename.c_str(), '.' );
      if( dot )
	{
	  tt = Flu_File_Chooser::find_type( dot+1 );
	  if( !tt )
	    description = dot+1;
	}
    }
  if( tt )
    {
      icon = tt->icon;
      description = tt->type;
    }
  // if there is no icon, assign a default one
  if( !icon && type==ENTRY_FILE && !(chooser->selectionType & DEACTIVATE_FILES) )
    icon = chooser->defaultFileIcon;
  if( type==ENTRY_FAVORITE )
    icon = &little_favorites;

  toolTip = detailTxt[0] + ": " + filename;
  if( type == ENTRY_FILE )
    toolTip += "\n" + detailTxt[1] +": " + filesize;
  toolTip += "\n" + detailTxt[3] + ": " + description;
  tooltip( toolTip.c_str() );

  redraw();
}

void Flu_File_Chooser :: resize( int x, int y, int w, int h )
{
  Fl_Double_Window::resize( x, y, w, h );
  if( fileListWideBtn->value() )
    filelist->scrollbar.linesize( filelist->w() );
  else if( fileListBtn->value() )
    filelist->scrollbar.linesize( DEFAULT_ENTRY_WIDTH+4 );
  // round position to nearest multiple of the linesize
  ((Fl_Valuator*)&(filelist->scrollbar))->value( filelist->w()*(filelist->scrollbar.value()/filelist->w()) );
  for( int i = 0; i < filelist->children(); i++ )
    ((Entry*)filelist->child(i))->updateSize();
}

void Flu_File_Chooser :: listModeCB()
{
  bool listMode = !fileDetailsBtn->value() || ( currentDir ==  FAVORITES_UNIQUE_STRING );
  if( listMode )
    {
      while( filedetails->children() )
	filelist->add( filedetails->child(0) );
    }
  else
    {
      while( filelist->children() )
	filedetails->add( filelist->child(0) );
    }

  resize( x(), y(), w(), h() );
  updateEntrySizes();
  if( listMode )
    {
      fileDetailsGroup->hide();
      filelist->show();
      filelist->redraw();
      filelist->parent()->resizable( filelist );
    }
  else
    {
      filelist->hide();
      fileDetailsGroup->show();
      fileDetailsGroup->parent()->resizable( fileDetailsGroup );
    }
  //redraw();
}

void Flu_File_Chooser :: Entry :: updateSize()
{
  if( type==ENTRY_FAVORITE || chooser->fileListWideBtn->value() )
    {
      resize( x(), y(), chooser->filelist->w()-4, 20 );
    }
  else
    resize( x(), y(), DEFAULT_ENTRY_WIDTH, 20 );

  details = chooser->fileDetailsBtn->value() && ( type != ENTRY_FAVORITE );

  if( details )
    {
      nameW = chooser->detailNameBtn->w();
      typeW = chooser->detailTypeBtn->w();
      sizeW = chooser->detailSizeBtn->w();
      dateW = chooser->detailDateBtn->w();
      resize( x(), y(), chooser->filedetails->w(), 20 );
    }
  else
    nameW = w();

  // how big is the icon?
  int iW = 0, iH = 0;
  if( icon )
    {
      iW = icon->w()+2;
      iH = icon->h();
    }

  fl_font( textfont(), textsize() );

  // measure the name and see if we need a truncated version
  int W = 0, H = 0;
  fl_measure( filename.c_str(), W, H );  
  if( W > nameW-iW )
    {
      // progressively strip characters off the end of the name until
      // it fits with "..." at the end
      if( altname[0] != '\0' )
	shortname = altname;
      else
	shortname = filename;
      int len = shortname.size();
      while( W > (nameW-iW) && len > 3 )
	{
	  shortname[len-3] = '.';
	  shortname[len-2] = '.';
	  shortname[len-1] = '.';
	  shortname[len] = '\0';
	  len--;
	  W = 0;
	  fl_measure( shortname.c_str(), W, H );  
	}
    }
  else
    shortname = "";

  // measure the description and see if we need a truncated version
  shortDescription = "";
  if( details )
    {
      W = 0; H = 0;
      fl_measure( description.c_str(), W, H );  
      if( W > typeW-4 )
	{
	  // progressively strip characters off the end of the description until
	  // it fits with "..." at the end
	  shortDescription = description;
	  int len = shortDescription.size();
	  while( W > typeW-4 && len > 3 )
	    {
	      shortDescription[len-3] = '.';
	      shortDescription[len-2] = '.';
	      shortDescription[len-1] = '.';
	      shortDescription[len] = '\0';
	      len--;
	      W = 0;
	      fl_measure( shortDescription.c_str(), W, H );  
	    }
	}
    }

  redraw();
}

Flu_File_Chooser :: Entry :: ~Entry()
{
}

void Flu_File_Chooser :: Entry :: inputCB()
{
  redraw();

  // if the user tried to change the string to nothing, restore the original name and turn off edit mode
  if( strlen( value() ) == 0 )
    {
      editMode = 0;
      return;
    }

  // if input text is different from filename, try to change the filename
  if( strcmp( value(), filename.c_str() ) != 0 )
    {
      // build the total old filename and new filename
      FluSimpleString oldName = chooser->currentDir + filename,
	newName = chooser->currentDir + value();
      // see if new name already exists
      struct stat s;
      int result = ::stat( newName.c_str(), &s );
      if( result == 0 )
	{
	  fl_alert( fileExistsErrTxt.c_str(), newName.c_str() );
	  return;  // leave editing on
	}

      if( rename( oldName.c_str(), newName.c_str() ) == -1 )
	{
	  fl_alert( renameErrTxt.c_str(), oldName.c_str(), newName.c_str() );
	  //return;  // leave editing on
	}
      else
	{
	  filename = value();
	  updateSize();
	  updateIcon();
	}
      // QUESTION: should we set the chooser filename to the modified name?
      //chooser->filename.value( filename.c_str() );
    }

  // only turn off editing if we have a successful name change
  editMode = 0;
}

Fl_Group* Flu_File_Chooser :: getEntryGroup()
{
  return (!fileDetailsBtn->value() || currentDir == FAVORITES_UNIQUE_STRING ) ? &(filelist->group) : filedetails;
}

Fl_Group* Flu_File_Chooser :: getEntryContainer()
{
  return (!fileDetailsBtn->value() || currentDir == FAVORITES_UNIQUE_STRING ) ? (Fl_Group*)filelist : filedetails;
}

int Flu_File_Chooser :: Entry :: handle( int event )
{
  if( editMode )
    {
      // if user hits 'Escape' while in edit mode, restore the original name and turn off edit mode
      if( event == FL_KEYDOWN && Fl::event_key( FL_Escape ) )
	{
	  editMode = 0;
	  redraw();
	  if( selected )
	    chooser->trashBtn->activate();
	  return 1;
	}
      return Fl_Input::handle( event );
    }

  if( event == FL_FOCUS || event == FL_UNFOCUS )
    return 1;

  if( event == FL_ENTER || event == FL_LEAVE )
    return 1;

  Fl_Group *g = chooser->getEntryGroup();
  if( event == FL_PUSH )
    {
      if( Fl::event_clicks() > 0 )
	{
	  Fl::event_clicks(0);
	  // double-clicking a favorite cd's to it
	  if( type == ENTRY_FAVORITE )
	    {
	      chooser->delayedCd = filename;
	      Fl::add_timeout( 0.0f, Flu_File_Chooser::delayedCdCB, chooser );
	    }
	  // double-clicking a directory cd's to it
	  else if( type != ENTRY_FILE )
	    {
#ifdef WIN32
	      if( filename[1] == ':' )
		chooser->delayedCd = filename;
	      else
#endif
		chooser->delayedCd = chooser->currentDir + filename + "/";
	      Fl::add_timeout( 0.0f, Flu_File_Chooser::delayedCdCB, chooser );
	    }
	  // double-clicking a file chooses it if we are in file selection mode
	  else if( !(chooser->selectionType & DIRECTORY) || (chooser->selectionType & STDFILE) )
	    {
	      Fl::add_timeout( 0.0f, Flu_File_Chooser::selectCB, chooser );
	    }
	  if( selected )
	    chooser->trashBtn->activate();
	  return 1;
	}

      /*
      if( selected && !Fl::event_button3() && !Fl::event_state(FL_CTRL) && !Fl::event_state(FL_SHIFT) )
	{
	  // only allow editing of certain files and directories
	  if( chooser->fileEditing && ( type == ENTRY_FILE || type == ENTRY_DIR ) )
	    {
	      // if already selected, switch to input mode
	      Fl::add_timeout( 1.0, _editCB, this );
	      return 1;
	    }
	}

	else*/
      if( chooser->selectionType & MULTI )
	{
	  if( Fl::event_state(FL_CTRL) )
	    {
	      selected = !selected;  // toggle this item
	      chooser->lastSelected = this;
	      if( type == ENTRY_FILE )
		chooser->previewGroup->file = chooser->currentDir + filename;
	      chooser->redraw();
	      chooser->getEntryContainer()->take_focus();
	    }
	  else if( Fl::event_state(FL_SHIFT) )
	    {
	      // toggle all items from the last selected item to this one
	      if( chooser->lastSelected == NULL )
		{
		  selected = true;
		  chooser->lastSelected = this;
		  if( type == ENTRY_FILE )
		    chooser->previewGroup->file = chooser->currentDir + filename;
		  chooser->redraw();
		  chooser->getEntryContainer()->take_focus();
		}
	      else
		{
		  // get the index of the last selected item and this item
		  int lastindex = -1, thisindex = -1;
		  int i;
		  for( i = 0; i < g->children(); i++ )
		    {
		      if( g->child(i) == chooser->lastSelected )
			lastindex = i;
		      if( g->child(i) == this )
			thisindex = i;
		      if( lastindex >= 0 && thisindex >= 0 )
			break;
		    }
		  if( lastindex >= 0 && thisindex >= 0 )
		    {
		      // loop from this item to the last item, toggling each item except the last
		      int inc;
		      if( thisindex > lastindex )
			inc = -1;
		      else
			inc = 1;
		      Entry *e;
		      for( i = thisindex; i != lastindex; i += inc )
			{
			  e = (Entry*)g->child(i);
			  e->selected = !e->selected;
			  e->redraw();
			}
		      chooser->lastSelected = this;
		      if( type == ENTRY_FILE )
			chooser->previewGroup->file = chooser->currentDir + filename;
		      chooser->redraw();
		      chooser->getEntryContainer()->take_focus();
		    }
		}
	    }
	  else
	    {
	      chooser->unselect_all();
	      selected = true;
	      chooser->lastSelected = this;
	      if( type == ENTRY_FILE )
		chooser->previewGroup->file = chooser->currentDir + filename;
	      chooser->redraw();
	      chooser->getEntryContainer()->take_focus();
	    }


	  if( !((chooser->selectionType & Flu_File_Chooser::DIRECTORY) ||
		(chooser->selectionType & Flu_File_Chooser::STDFILE)) && 
	      ( Fl::event_state(FL_CTRL) || Fl::event_state(FL_SHIFT) ) )
	    {
	      // if we are only choosing multiple files, don't allow a directory
	      // to be selected
	      Fl_Group *g = chooser->getEntryGroup();
	      for( int i = 0; i < g->children(); i++ )
		{
		  Entry *e = (Entry*)g->child(i);
		  if( e->type == ENTRY_DIR )
		    e->selected = false;
		}
	    }
	}
      else
	{
	  chooser->unselect_all();
	  selected = true;
	  chooser->lastSelected = this;
	  if( type == ENTRY_FILE )
	    chooser->previewGroup->file = chooser->currentDir + filename;
	  chooser->redraw();
	  chooser->getEntryContainer()->take_focus();
	}

      //g->take_focus();

      redraw();
      if( selected )
	chooser->trashBtn->activate();

      if( Fl::event_button3() )
	return chooser->popupContextMenu( this );

      // don't put the filename into the box if we are a directory but we are not choosing directories
      // or if we are in SAVING mode
      if( (chooser->selectionType & Flu_File_Chooser::DIRECTORY) ||
	  (chooser->selectionType & Flu_File_Chooser::STDFILE) ||
	  type==ENTRY_FILE )
	chooser->filename.value( filename.c_str() );
      else if( !(chooser->selectionType & Flu_File_Chooser::SAVING ) )
	chooser->filename.value( "" );
      chooser->filename.position( chooser->filename.size(), chooser->filename.size() );

      return 1;
    }
  else if( event == FL_DRAG )
    {
      if( chooser->selectionType & MULTI )
	{
	  // toggle all items from the last selected item to this one
	  if( chooser->lastSelected != NULL )
	    {
	      selected = true;
	      // get the index of the last selected item and this item
	      int lastindex = -1, thisindex = -1;
	      int i;
	      for( i = 0; i < g->children(); i++ )
		{
		  if( g->child(i) == chooser->lastSelected )
		    lastindex = i;
		  if( g->child(i) == this )
		    thisindex = i;
		  if( lastindex >= 0 && thisindex >= 0 )
		    break;
		}
	      if( lastindex >= 0 && thisindex >= 0 )
		{
		  // loop from this item to the last item, toggling each item except the last
		  int inc;
		  if( thisindex > lastindex )
		    inc = -1;
		  else
		    inc = 1;
		  Entry *e;
		  for( i = thisindex; i != lastindex; i += inc )
		    {
		      e = (Entry*)g->child(i);
		      e->selected = !e->selected;
		      e->redraw();
		    }
		  chooser->lastSelected = this;
		  if( type == ENTRY_FILE )
		    chooser->previewGroup->file = chooser->currentDir + filename;
		  chooser->redraw();
		}
	      redraw();
	      chooser->getEntryContainer()->take_focus();
	      if( selected )
		chooser->trashBtn->activate();
	      return 1;
	    }
	}
    }
  return Fl_Widget::handle(event);
}

void Flu_File_Chooser :: Entry :: editCB()
{
  // if already selected, switch to input mode
  editMode = 2;
  value( filename.c_str() );
  take_focus();
  // select the text up to but not including the extension
  const char *dot = strrchr( filename.c_str(), '.' );
  if( dot )
    position( 0, dot-filename.c_str() );
  else
    position( 0, filename.size() );
  chooser->trashBtn->deactivate();
  redraw();
}

int Flu_File_Chooser :: popupContextMenu( Entry *entry )
{
  int type = entry ? entry->type : ENTRY_NONE;
  const char *filename = entry ? entry->filename.c_str() : NULL;
  char *ext = NULL;

  if( filename )
    ext = strrchr( (char*)filename, '.' );
  if( ext )
    {
      ext = strdup( ext+1 ); // skip the '.'
      for( unsigned int i = 0; i < strlen(ext); i++ )
	ext[i] = tolower( ext[i] );
    }

  enum { ACTION_NEW_FOLDER = -1, ACTION_RENAME = -2, ACTION_DELETE = -3 };

  entryPopup.clear();
  switch( type )
    {
    case ENTRY_NONE: // right click on nothing
      entryPopup.add( contextMenuTxt[0].c_str(), 0, 0, (void*)ACTION_NEW_FOLDER );
      break;

    case ENTRY_DIR:
      entryPopup.add( contextMenuTxt[1].c_str(), 0, 0, (void*)ACTION_RENAME );
      entryPopup.add( contextMenuTxt[2].c_str(), 0, 0, (void*)ACTION_DELETE );
      break;

    case ENTRY_FILE:
      entryPopup.add( contextMenuTxt[1].c_str(), 0, 0, (void*)ACTION_RENAME );
      entryPopup.add( contextMenuTxt[2].c_str(), 0, 0, (void*)ACTION_DELETE );
      break;

   case ENTRY_FAVORITE:
     entryPopup.add( contextMenuTxt[2].c_str(), 0, 0, (void*)ACTION_DELETE );
      break;

    case ENTRY_DRIVE:
      break;

    case ENTRY_MYDOCUMENTS:
      break;

    case ENTRY_MYCOMPUTER:
      break;
    }

  // add the programmable context handlers
  for( unsigned int i = 0; i < contextHandlers.size(); i++ )
    {
      if( !(contextHandlers[i].type & type) )
	continue;
      if( type == ENTRY_FILE )
	if( contextHandlers[i].ext.size() && contextHandlers[i].ext != ext )
	  continue;
      entryPopup.add( contextHandlers[i].name.c_str(), 0, 0, (void*)i );
    }
  if( ext )
    free( ext );

  entryPopup.position( Fl::event_x(), Fl::event_y() );
  const Fl_Menu_Item *selection = entryPopup.popup();
  if( selection )
    {
      int handler = (int)selection->user_data();
      switch( handler )
	{
	case ACTION_NEW_FOLDER:
	  newFolderCB();
	  break;
	case ACTION_RENAME:
	  entry->editCB();
	  /*
	  entry->editMode = 2;
	  entry->value( entry->filename.c_str() );
	  entry->take_focus();
	  entry->position( 0, entry->filename.size() );
	  trashBtn->deactivate();
	  */
	  break;
	case ACTION_DELETE:
	  // recycle by default, unless the shift key is held down
	  trashCB( !Fl::event_state( FL_SHIFT ) );
	  break;
	default:
	  contextHandlers[handler].callback( filename, type, contextHandlers[handler].callbackData );
	  break;
	}
    }
  else
    return handle( FL_PUSH );
  return 1;
}

void Flu_File_Chooser :: Entry :: draw()
{
  if( editMode )
    {
      if( editMode == 2 )
	{
	  editMode--;
	  fl_draw_box( FL_FLAT_BOX, x(), y(), w(), h(), FL_WHITE );
	  redraw();
	}
      Fl_Input::draw();
      return;
    }

  if( selected )
    {
      fl_draw_box( FL_FLAT_BOX, x(), y(), w(), h(), FL_SELECTION_COLOR );
      fl_color( FL_WHITE );
    }
  else
    {
      fl_draw_box( FL_FLAT_BOX, x(), y(), w(), h(), FL_WHITE );
      fl_color( FL_BLACK );
    }

  int X = x()+4;
  if( icon )
    {
      icon->draw( X, y()+h()/2-icon->h()/2 );
      X += icon->w()+2;
    }

  fl_font( textfont(), textsize() );
  //fl_color( textcolor() );

  if( shortname[0] != '\0' )
    fl_draw( shortname.c_str(), X, y(), nameW, h(), FL_ALIGN_LEFT );
  else if( altname[0] != '\0' )
    fl_draw( altname.c_str(), X, y(), nameW, h(), FL_ALIGN_LEFT );
  else
    fl_draw( filename.c_str(), X, y(), nameW, h(), FL_ALIGN_LEFT );

  X = x()+4 + nameW;

  if( details )
    {
      if( shortDescription[0] != '\0' )
	fl_draw( shortDescription.c_str(), X, y(), typeW-4, h(), Fl_Align(FL_ALIGN_LEFT | FL_ALIGN_CLIP) );
      else
	fl_draw( description.c_str(), X, y(), typeW-4, h(), Fl_Align(FL_ALIGN_LEFT | FL_ALIGN_CLIP) );

      X += typeW;

      fl_draw( filesize.c_str(), X, y(), sizeW-4, h(), Fl_Align(FL_ALIGN_RIGHT | FL_ALIGN_CLIP) );

      X += sizeW+4;

      fl_draw( date.c_str(), X, y(), dateW-4, h(), Fl_Align(FL_ALIGN_LEFT | FL_ALIGN_CLIP) );
    }
}

void Flu_File_Chooser :: unselect_all()
{
  Fl_Group *g = getEntryGroup();
  Entry *e;
  for( int i = 0; i < g->children(); i++ )
    {
      e = ((Entry*)g->child(i));
      e->selected = false;
      e->editMode = 0;
    }
  lastSelected = 0;
  previewGroup->file = "";
  previewGroup->redraw();
  trashBtn->deactivate();
  redraw();
}

void Flu_File_Chooser :: select_all()
{
  if( !( selectionType & MULTI ) )
    return;
  Fl_Group *g = getEntryGroup();
  Entry *e;
  previewGroup->file = "";
  for( int i = 0; i < g->children(); i++ )
    {
      e = ((Entry*)g->child(i));
      e->selected = true;
      e->editMode = 0;
      previewGroup->file = e->filename;
      filename.value( e->filename.c_str() );
    }
  lastSelected = 0;
  previewGroup->redraw();
  trashBtn->deactivate();
  redraw();
}

void Flu_File_Chooser :: updateEntrySizes()
{
  filecolumns->W1 = detailNameBtn->w();
  filecolumns->W2 = detailTypeBtn->w();
  filecolumns->W3 = detailSizeBtn->w();
  filecolumns->W4 = detailDateBtn->w();

  // update the size of each entry because the user changed the size of each column
  filedetails->resize( filedetails->x(), filedetails->y(), filescroll->w(), filedetails->h() );
  int i;
  for( i = 0; i < filedetails->children(); i++ )
    ((Entry*)filedetails->child(i))->updateSize();
  for( i = 0; i < filelist->children(); i++ )
    ((Entry*)filelist->child(i))->updateSize();
}

const char* Flu_File_Chooser :: value()
{
  if( filename.size() == 0 )
    return NULL;
  else
    {
#ifdef WIN32
      // on windows, be sure the drive letter is lowercase for
      // compatibility with fl_filename_relative()
      if( filename.size() > 1 && filename.value()[1] == ':' )
	((char*)(filename.value()))[0] = tolower( filename.value()[0] );
#endif
      return filename.value();
    }
}

int Flu_File_Chooser :: count()
{
  if( selectionType & MULTI )
    {
      int n = 0;
      Fl_Group *g = getEntryGroup();
      for( int i = 0; i < g->children(); i++ )
	{
#ifdef WIN32
	  if( ((Entry*)g->child(i))->filename == myComputerTxt )
	    continue;
#endif
	  if( ((Entry*)g->child(i))->selected )
	    n++;
	}
      return n;
    }
  else
    return (strlen(filename.value())==0)? 0 : 1;
}

void Flu_File_Chooser :: value( const char *v )
{
  cd( v );
  if( !v )
    return;
  // try to find the file and select it
  const char *slash = strrchr( v, '/' );
  if( slash )
    slash++;
  else
    {
      slash = strrchr( v, '\\' );
      if( slash )
	slash++;
      else
	slash = v;
    }
  filename.value( slash );
  filename.position( filename.size(), filename.size() );
  Fl_Group *g = getEntryGroup();
  for( int i = 0; i < g->children(); i++ )
    {
      if( ((Entry*)g->child(i))->filename == slash )
	{
	  ((Entry*)g->child(i))->selected = true;
	  filelist->scroll_to( (Entry*)g->child(i) );
	  filedetails->scroll_to( (Entry*)g->child(i) );
	  redraw();
	  return;
	}
    }
}

const char* Flu_File_Chooser :: value( int n )
{
  Fl_Group *g = getEntryGroup();
  for( int i = 0; i < g->children(); i++ )
    {
#ifdef WIN32
      if( ((Entry*)g->child(i))->filename == myComputerTxt )
	continue;
#endif
      if( ((Entry*)g->child(i))->selected )
	{
	  n--;
	  if( n == 0 )
	    {
	      FluSimpleString s = currentDir + ((Entry*)g->child(i))->filename;
	      filename.value( s.c_str() );
	      filename.position( filename.size(), filename.size() );
	      return value();
	    }
	}
    }
  return "";
}

void Flu_File_Chooser :: reloadCB()
{
#ifdef WIN32
  refreshDrives = true;
#endif
  cd( currentDir.c_str() );
}

void Flu_File_Chooser :: addToFavoritesCB()
{
  // eliminate duplicates
  bool duplicate = false;
  for( int i = 1; i <= favoritesList->size(); i++ )
    {
      if( streq( currentDir.c_str(), favoritesList->text(i) ) )
	{
	  duplicate = true;
	  break;
	}
    }
  if( !duplicate )
    favoritesList->add( currentDir.c_str() );

  // save the favorites
  FILE *f = fopen( configFilename.c_str(), "w" );
  if( f )
    {
      for( int i = 1; i <= favoritesList->size(); i++ )
	fprintf( f, "%s\n", favoritesList->text(i) );
      fclose( f );
    }
}

FluSimpleString Flu_File_Chooser :: formatDate( const char *d )
{
  if( d == 0 )
    {
      FluSimpleString s;
      return s;
    }

  // convert style "Wed Mar 19 07:23:11 2003" to "MM/DD/YY HH:MM AM|PM"

  int month, day, year, hour, minute, second;
  bool pm;
  char MM[16], dummy[64];

  sscanf( d, "%s %s %d %d:%d:%d %d", dummy, MM, &day, &hour, &minute, &second, &year );

  pm = ( hour >= 12 );
  if( hour == 0 )
    hour = 12;
  if( hour >= 13 )
    hour -= 12;

  if( strcmp(MM,"Jan")==0 ) month = 1;
  else if( strcmp(MM,"Feb")==0 ) month = 2;
  else if( strcmp(MM,"Mar")==0 ) month = 3;
  else if( strcmp(MM,"Apr")==0 ) month = 4;
  else if( strcmp(MM,"May")==0 ) month = 5;
  else if( strcmp(MM,"Jun")==0 ) month = 6;
  else if( strcmp(MM,"Jul")==0 ) month = 7;
  else if( strcmp(MM,"Aug")==0 ) month = 8;
  else if( strcmp(MM,"Sep")==0 ) month = 9;
  else if( strcmp(MM,"Oct")==0 ) month = 10;
  else if( strcmp(MM,"Nov")==0 ) month = 11;
  else month = 12;

  sprintf( dummy, "%d/%d/%02d %d:%02d %s", month, day, year, hour, minute, pm?"PM":"AM" );

  FluSimpleString formatted = dummy;

  return formatted;
}

void Flu_File_Chooser :: win2unix( FluSimpleString &s )
{
  int len = s.size();
  for( int i = 0; i < len; i++ )
    if( s[i] == '\\' )
      s[i] = '/';
}

void Flu_File_Chooser :: cleanupPath( FluSimpleString &s )
{
  // convert all '\' to '/'
  win2unix( s );

  FluSimpleString newS(s.size()+1);

  int oldPos, newPos;
  for( oldPos = 0, newPos = 0; oldPos < s.size(); oldPos++ )
    {
      // remove "./" 
      if( s[oldPos] == '.' && s[oldPos+1] == '/' )
	oldPos += 2;

      // convert "//" to "/"
      else if( s[oldPos] == '/' && s[oldPos+1] == '/' )
	oldPos++;

#ifdef WIN32
      // downcase "c:" to "C:"
      else if( s[oldPos+1] == ':' )
	s[oldPos] = toupper( s[oldPos] );
#endif

      // remove "../" by removing everything back to the last "/"
      if( oldPos+2 < s.size() ) // bounds check
	{
	  if( s[oldPos] == '.' && s[oldPos+1] == '.' && s[oldPos+2] == '/' && newS != "/" )
	    {
	      // erase the last character, which should be a '/'
	      newPos--;
	      newS[newPos] = '\0';
	      // look for the previous '/'
	      char *lastSlash = strrchr( (char*)newS.c_str(), '/' );
	      // make the new string position after the slash
	      newPos = (lastSlash-newS.c_str())+1;
	      oldPos += 3;
	    }
	}

      newS[newPos] = s[oldPos];
      newPos++;
    }

  newS[newPos] = '\0';
  s = newS;
}

void Flu_File_Chooser :: backCB()
{
  if( !currentHist ) return;
  if( currentHist->last )
    {
      currentHist = currentHist->last;
      walkingHistory = true;
      delayedCd = currentHist->path;
      Fl::add_timeout( 0.0f, Flu_File_Chooser::delayedCdCB, this );
    }
}

void Flu_File_Chooser :: forwardCB()
{
  if( !currentHist ) return;
  if( currentHist->next )
    {
      currentHist = currentHist->next;
      walkingHistory = true;
      delayedCd = currentHist->path;
      Fl::add_timeout( 0.0f, Flu_File_Chooser::delayedCdCB, this );
    }
}

bool Flu_File_Chooser :: correctPath( FluSimpleString &path )
{
  // the path may or may not be an alias, needing corrected
#ifdef WIN32
  // point to the correct desktop
  if( path == "/"+desktopTxt+"/" )
    {
      path = userDesktop;
      return true;
    }
  else if( path == userDesktop )
    return true;
  else if( path == "/"+desktopTxt+"/"+myComputerTxt+"/" ||
	   path == userDesktop+myComputerTxt+"/" )
    path = "/";
  else if( path == "/"+desktopTxt+"/"+myDocumentsTxt+"/" ||
	   path == userDesktop+myDocumentsTxt+"/" )
    path = userDocs;
#endif
  return false;
}

void Flu_File_Chooser :: locationCB( const char *path )
{
#ifdef WIN32
  FluSimpleString p = path;
  if( p == "/"+favoritesTxt+"/" )
    favoritesCB();
  else if( p == "/"+desktopTxt+"/"+myComputerTxt+"/" )
    myComputerCB();
  else if( p == "/"+desktopTxt+"/"+myDocumentsTxt+"/" )
    documentsCB();
  else if( p == "/"+desktopTxt+"/" )
    desktopCB();
  // if the path leads off with "/Desktop/My Computer", then strip that part off and cd
  // to the remaining
  else
    {
      FluSimpleString s = "/"+desktopTxt+"/"+myComputerTxt+"/";
      if( strstr( path, s.c_str() ) == path )
	{
	  // seach for '(' and if present, extract the drive name and cd to it
	  char *paren = strrchr( path, '(' );
	  if( paren )
	    {
	      char drive[] = "A:/";
	      drive[0] = toupper(paren[1]);
	      cd( drive );
	    }
	  else
	    {
	      cd( path+21 );
	    }
	}
    }
#else
  cd( path );
#endif
  updateLocationQJ();
}

void Flu_File_Chooser :: buildLocationCombo()
{
  // add all filesystems
  location->tree.clear();

#ifdef WIN32
  FluSimpleString s;
  char volumeName[1024];
  Flu_Tree_Browser::Node *n;
  s = desktopTxt+"/";
  n = location->tree.add( s.c_str() ); n->branch_icon( &little_desktop );
  s = desktopTxt+"/"+myDocumentsTxt+"/";
  n = location->tree.add( s.c_str() ); n->branch_icon( &documents );
  s = desktopTxt+"/"+myComputerTxt+"/";
  n = location->tree.add( s.c_str() ); n->branch_icon( &computer );
  // get the location and add them
  {
    if( refreshDrives )
      driveMask = GetLogicalDrives();
    DWORD mask = driveMask;

    for( int i = 0; i < 26; i++ )
      {
	drives[i] = "";
	driveIcons[i] = &disk_drive;
	if( mask & 1 )
	  {
	    s = desktopTxt+"/"+myComputerTxt+"/";
	    char drive[] = "A:";
	    char windrive[] = "A:\\";
	    windrive[0] = drive[0] = 'A' + i;
	    DWORD type;
	    if( refreshDrives )
	      {
		volumeName[0] = '\0';
		type = driveTypes[i] = GetDriveType( windrive );
		if( type != DRIVE_REMOVABLE && type != DRIVE_REMOTE )
		  GetVolumeInformation( windrive, volumeName, 1024, NULL, NULL, NULL, NULL, 0 );
		volumeNames[i] = volumeName;
	      }
	    else
	      {
		strncpy( volumeName, volumeNames[i].c_str(), 1024 );
		type = driveTypes[i];
	      }

	    //s += volume
	    const char *disk = "Disk";
	    switch( type )
	      {
	      case DRIVE_REMOVABLE: 
		disk = strlen(volumeName)?volumeName: ( 1 < 2 ? diskTypesTxt[0].c_str() : diskTypesTxt[1].c_str() );
		driveIcons[i] = &floppy_drive;
		break;
	      case DRIVE_FIXED: 
		disk = strlen(volumeName)?volumeName:diskTypesTxt[2].c_str();
		//driveIcons[i] = &disk_drive;
		break;
	      case DRIVE_CDROM: 
		disk = strlen(volumeName)?volumeName:diskTypesTxt[3].c_str();
		driveIcons[i] = &cd_drive;
		break;
	      case DRIVE_REMOTE: 
		disk = strlen(volumeName)?volumeName:diskTypesTxt[4].c_str();
		driveIcons[i] = &network_drive;
		break;
	      case DRIVE_RAMDISK: 
		disk = strlen(volumeName)?volumeName:diskTypesTxt[5].c_str();
		driveIcons[i] = &ram_drive;
		break;
	      }
	    drives[i] = FluSimpleString(disk) + " (" + FluSimpleString(drive) + ")/";
	    s += drives[i];
	    n = location->tree.add( s.c_str() ); n->branch_icon( driveIcons[i] );
	    // erase the trailing '/' to make things look nicer
	    drives[i][ drives[i].size()-1 ] = '\0';
	  }
	mask >>= 1;
      }
  }
  s = favoritesTxt+"/";
  n = location->tree.add( s.c_str() ); n->branch_icon( &little_favorites );
  refreshDrives = false;

#elif defined __APPLE__

  location->tree.label( "/" );

  // get all volume mount points and add to the location combobox
  dirent **e;
  char *name;
  int num = fl_filename_list( "/Volumes/", &e );
  if( num > 0 )
    {
      int i;
      for( i = 0; i < num; i++ )
	{
	  name = e[i]->d_name;

	  // ignore the "." and ".." names
	  if( strcmp( name, "." ) == 0 || strcmp( name, ".." ) == 0 ||
	      strcmp( name, "./" ) == 0 || strcmp( name, "../" ) == 0 ||
	      strcmp( name, ".\\" ) == 0 || strcmp( name, "..\\" ) == 0 )
	    continue;

	  // if 'name' ends in '/', remove it
	  if( name[strlen(name)-1] == '/' )
	    name[strlen(name)-1] = '\0';

	  FluSimpleString fullpath = "/Volumes/";
	  fullpath += name;
	  fullpath += "/";
	  location->tree.add( fullpath.c_str() );
	}
    }

#else

  location->tree.label( "/" );

  // get all mount points and add to the location combobox
  FILE	*fstab;		// /etc/mtab or /etc/mnttab file
  char	dummy[256], mountPoint[256], line[1024];	// Input line
  FluSimpleString mount;

  fstab = fopen( "/etc/fstab", "r" );	// Otherwise fallback to full list
  if( fstab )
    {
      while( fgets( line, 1024, fstab ) )
	{
	  if( line[0] == '#' || line[0] == '\n' )
	    continue;

	  // in fstab, mount point is second full string
	  sscanf( line, "%s %s", dummy, mountPoint );
	  mount = mountPoint;

	  // cull some stuff
	  if( mount[0] != '/' ) continue;
	  if( mount == "/" ) continue;
	  if( mount == "/boot" ) continue;
	  if( mount == "/proc" ) continue;

	  // now add the mount point
	  mount += "/";
	  location->tree.add( mount.c_str() );
	}

      fclose( fstab );
    }

#endif
}

void Flu_File_Chooser :: clear_history()
{
  currentHist = history;
  while( currentHist )
    {
      History *next = currentHist->next;
      delete currentHist;
      currentHist = next;
    }
  currentHist = history = NULL;
  backBtn->deactivate();
  forwardBtn->deactivate();
}

void Flu_File_Chooser :: addToHistory()
{
  // remember history
  // only store this path in the history if it is not the current directory
  if( currentDir.size() && !walkingHistory )
    {
      if( history == NULL )
	{
	  history = new History;
	  currentHist = history;
	  currentHist->path = currentDir;
	}
      else if( currentHist->path != currentDir )
	{
	  // since we are adding a new path, delete everything after this path
	  History *h = currentHist->next;
	  while( h )
	    {
	      History *next = h->next;
	      delete h;
	      h = next;
	    }
	  currentHist->next = new History;
	  currentHist->next->last = currentHist;
	  currentHist = currentHist->next;
	  currentHist->path = currentDir;
	}
      History * h = history;
      while( h )
	h = h->next;
    }
  walkingHistory = false;

  if( currentHist )
    {
      if( currentHist->last )
	backBtn->activate();
      else
	backBtn->deactivate();
      if( currentHist->next )
	forwardBtn->activate();
      else
	forwardBtn->deactivate();
    }
}

// treating the string as a '|' or ';' delimited sequence of patterns, strip them out and place in patterns
// return whether it is likely that "s" represents a regexp file-matching pattern
bool Flu_File_Chooser :: stripPatterns( FluSimpleString s, FluStringVector* patterns )
{
  if( s.size() == 0 )
    return false;

  char *tok = strtok( (char*)s.c_str(), "|;" );
  int tokens = 0;
  while( tok )
    {
      tokens++;
      if( tok[0] == ' ' )
	tok++; // skip whitespace
      patterns->add( tok );
      tok = strtok( NULL, "|;" );
    }

  // if there is just a single token and it looks like it's not a pattern,
  // then it is probably JUST a filename, in which case it should not be
  // treated as a pattern
  if( _isProbablyAPattern( s.c_str() ) )
    return true;
  else if( tokens == 1 )
    {
      patterns->clear();
      return false;
    }
  else
    return true;
}

void Flu_File_Chooser :: cd( const char *path )
{
  Entry *entry;
  char cwd[1024];

  if( !path || path[0] == '\0' )
    {
      path = getcwd( cwd, 1024 );
      if( !path )
	path = "./";
    }

  if( path[0] == '~' )
    {
      if( path[1] == '/' || path[1] == '\\' )
	sprintf( cwd, "%s%s", userHome.c_str(), path+2 );
      else
	sprintf( cwd, "%s%s", userHome.c_str(), path+1 );
      path = cwd;
    }

  lastSelected = 0;
  previewGroup->file = "";
  previewGroup->redraw();

  filelist->scroll_to_beginning();
  filescroll->position( 0, 0 );

  bool listMode = !fileDetailsBtn->value() || streq( path, FAVORITES_UNIQUE_STRING );

#ifdef WIN32
  // refresh the drives if viewing "My Computer"
  if( strcmp( path, "/" ) == 0 )
    refreshDrives = true;
#endif
  buildLocationCombo();

  filename.take_focus();

  trashBtn->deactivate();
  reloadBtn->activate();
  newDirBtn->activate();
  previewBtn->activate();
  hiddenFiles->activate();
  addFavoriteBtn->activate();

  resize( x(), y(), w(), h() );
  if( listMode )
    {
      //filecolumns->hide();
      //filescroll->hide();
      fileDetailsGroup->hide();
      filelist->show();
      filelist->parent()->resizable( filelist );
    }
  else
    {
      filelist->hide();
      //filecolumns->show();
      //filescroll->show();
      //filescroll->parent()->resizable( filescroll );
      fileDetailsGroup->show();
      fileDetailsGroup->parent()->resizable( fileDetailsGroup );
      //updateEntrySizes();
    }

  FluSimpleString currentFile = filename.value();
  filescroll->position( 0, 0 );
  //Fl::focus( &filename );
  upDirBtn->activate();
  ok.activate();

  // check for favorites
  if( streq( path, FAVORITES_UNIQUE_STRING ) )
    {
      currentDir = FAVORITES_UNIQUE_STRING;
      addToHistory();

      newDirBtn->deactivate();
      previewBtn->deactivate();
      reloadBtn->deactivate();
      addFavoriteBtn->deactivate();
      hiddenFiles->deactivate();
      location->input.value( favoritesTxt.c_str() );
      updateLocationQJ();

      filelist->clear();
      filedetails->clear();
      if( listMode )
	filelist->begin();
      else
	filedetails->begin();
      for( int i = 1; i <= favoritesList->size(); i++ )
	{
	  entry = new Entry( favoritesList->text(i), ENTRY_FAVORITE, false/*fileDetailsBtn->value()*/, this );
	  entry->updateSize();
	  entry->updateIcon();
	}
      if( listMode )
	filelist->end();
      else
	filedetails->end();

      redraw();
      ok.deactivate();
      return;
    }
  // check for the current directory
  else if( streq( path, "." ) || streq( path, "./" ) || streq( path, ".\\" ) )
    {
      // do nothing. just rescan this directory
    }
  // check for parent directory
  else if( streq( path, ".." ) || streq( path, "../" ) || streq( path, "..\\" ) )
    {
      // if we are viewing the favorites and want to go back a directory, go to the previous directory
      if( currentDir == FAVORITES_UNIQUE_STRING )
	{
	  backCB();
	  return;
	}
#ifdef WIN32
      // if we are at the desktop already, then we cannot go back any further
      //if( currentDir == "/Desktop/" )
      //{
	  // do nothing
      //}
      //else if( currentDir == userHome+"Desktop/" )
      //currentDir = userHome;
      // if we are viewing "My Computer" and want to go back a directory, go to the desktop
      if( currentDir == "/" )
	{
	  //currentDir = userDesktop;//userHome + "Desktop";
	  // do nothing
	}
      // if we are at a top level drive, go to "My Computer" (i.e. "/")
      else if( currentDir[1] == ':' && currentDir[3] == '\0' )
	currentDir = "/";
      else
#else
	// if the current directory is already as far back as we can go, ignore
	if( currentDir != "/" )
#endif
	  {
	    // strip everything off the end to the next "/"
	    int end = currentDir.size()-1;
	    currentDir[end] = '\0';
	    while( currentDir[end] != '/' )
	      {
		currentDir[end] = '\0';
		end--;
	      }
	  }
    }
  // check for absolute path
#ifdef WIN32
  else if( path[1] == ':' || path[0] == '/' )
#else
  else if( path[0] == '/' )
#endif
    {
      currentDir = path;
    }
  // else relative path
  else
    {
      // concatenate currentDir with path to make an absolute path
      currentDir += path;
    }

  int numDirs = 0, numFiles = 0;
  filelist->clear();
  filedetails->clear();

  cleanupPath( currentDir );

#ifdef WIN32
  bool isTopDesktop = ( currentDir == ("/"+desktopTxt+"/") );
  bool isDesktop = correctPath( currentDir );
  if( isTopDesktop )
    upDirBtn->deactivate();
#else
  if( currentDir == "/" )
    upDirBtn->deactivate();
#endif

#ifdef WIN32
  bool root = false;
  // check for my computer
  if( currentDir == "/" )
    {
      ok.deactivate();
      root = true;
      if( listMode )
	filelist->begin();
      else
	filedetails->begin();
      for( int i = 0; i < 26; i++ )
	{
	  if( drives[i][0] != '\0' )
	    {
	      char drive[] = "A:/";
	      drive[0] = 'A' + i;
	      entry = new Entry( drive, ENTRY_DRIVE, fileDetailsBtn->value(), this );
	      switch( driveTypes[i] )
		{
		case DRIVE_REMOVABLE: entry->description = diskTypesTxt[0].c_str(); break;
		case DRIVE_FIXED: entry->description = diskTypesTxt[2].c_str(); break;
		case DRIVE_CDROM: entry->description = diskTypesTxt[3].c_str(); break;
		case DRIVE_REMOTE: entry->description = diskTypesTxt[4].c_str(); break;
		case DRIVE_RAMDISK: entry->description = diskTypesTxt[5].c_str(); break;
		}
	      entry->icon = driveIcons[i];
	      entry->altname = drives[i];
	      entry->updateSize();
	      entry->updateIcon();
	    }
	}
      if( listMode )
	filelist->end();
      else
	filedetails->end();

      redraw();
    }
  // check for desktop. if so, add My Computer and My Documents
  else if( isDesktop )
    {
      if( listMode )
	filelist->begin();
      else
	filedetails->begin();
      entry = new Entry( myDocumentsTxt.c_str(), ENTRY_MYDOCUMENTS, fileDetailsBtn->value(), this );
      entry->updateSize();     
      entry->updateIcon();
      entry = new Entry( myComputerTxt.c_str(), ENTRY_MYCOMPUTER, fileDetailsBtn->value(), this );
      entry->updateSize();
      entry->updateIcon();
      if( listMode )
	filelist->end();
      else
	filedetails->end();
      numDirs += 2;
    }
#endif

  // see if currentDir is in fact a directory
  // if so, make sure there is a trailing "/" and we're done
  if( fl_filename_isdir( currentDir.c_str() ) || currentDir=="/" )
    {
      if( currentDir[strlen(currentDir.c_str())-1] != '/' )
	currentDir += "/";
#ifdef WIN32
      if( filename.value()[1] != ':' )
#else
      if( filename.value()[0] != '/' )
#endif
	{
	  if( !(selectionType & SAVING ) )
	    filename.value( "" );
	}
      if( !(selectionType & SAVING ) )
	currentFile = "";
    }

  // now we have the current directory and possibly a file at the end
  // try to split into path and file
  if( currentDir[currentDir.size()-1] != '/' )
    {
      char *lastSlash = strrchr( (char*)currentDir.c_str(), '/' );
      if( lastSlash )
	{
	  currentFile = lastSlash+1;
	  lastSlash[1] = '\0';
	}
    }
  // make sure currentDir ends in '/'
  if( currentDir[currentDir.size()-1] != '/' )
    currentDir += "/";

#ifdef WIN32
  {
    FluSimpleString tmp = currentDir;
    if( isTopDesktop )
      currentDir = "/"+desktopTxt+"/";
    addToHistory();
    if( isTopDesktop )
      currentDir = tmp;
  }
#else
  addToHistory();
#endif

  delayedCd = "./";

#ifdef WIN32
  // set the location input value
  // check for drives
  if( currentDir[1] == ':' && currentDir[3] == '\0' )
    {
      location->input.value( currentDir.c_str() );
    }
  else if( currentDir == "/" )
    location->input.value( myComputerTxt.c_str() );
  else
#endif
    {
      location->input.value( currentDir.c_str() );
#ifdef WIN32
      FluSimpleString treePath = "/"+desktopTxt+"/"+myComputerTxt+"/"+currentDir;
      Flu_Tree_Browser::Node *n = location->tree.add( treePath.c_str() );
      if( currentDir == (userHome+desktopTxt+"/") )
	n->branch_icon( &little_desktop );
      if( currentDir == (userHome+myDocumentsTxt+"/") )
	n->branch_icon( &documents );
#else
      location->tree.add( currentDir.c_str() );
#endif
    }

  updateLocationQJ();

#ifdef WIN32
  if( root )
    return;
#endif

  FluSimpleString pathbase, fullpath;
  bool isDir, isCurrentFile = false;
  const char *lastAddedFile = NULL, *lastAddedDir = NULL;

  pathbase = currentDir;

  // take the current pattern and make a list of filter pattern strings
  FluStringVector currentPatterns;
  {
    FluSimpleString pat = patterns[filePattern->list.value()-1];
    while( pat.size() )
      {
	int p = pat.find( ',' );
	if( p == -1 )
	  {
	    if( pat != "*" )
	      pat = "*." + pat;
	    currentPatterns.add( pat );
	    break;
	  }
	else
	  {
	    FluSimpleString s = pat.c_str() + p + 1;
	    pat[p] = '\0';
	    if( pat != "*" )
	      pat = "*." + pat;
	    currentPatterns.add( pat );
	    pat = s;
	  }
      }
  }

  // add any user-defined patterns
  FluStringVector userPatterns;
  // if the user just hit <Tab> but the filename input area is empty,
  // then use the current patterns
  if( !filenameTabCallback || currentFile != "*" )
    stripPatterns( currentFile, &userPatterns );

  // read the directory
  dirent **e;
  char *name;
  int num = fl_filename_list( pathbase.c_str(), &e );
  if( num > 0 )
    {
      int i;
      for( i = 0; i < num; i++ )
	{
	  name = e[i]->d_name;

	  // ignore the "." and ".." names
	  if( strcmp( name, "." ) == 0 || strcmp( name, ".." ) == 0 ||
	      strcmp( name, "./" ) == 0 || strcmp( name, "../" ) == 0 ||
	      strcmp( name, ".\\" ) == 0 || strcmp( name, "..\\" ) == 0 )
	    continue;

	  // if 'name' ends in '/', remove it
	  if( name[strlen(name)-1] == '/' )
	    name[strlen(name)-1] = '\0';

	  // file or directory?
	  fullpath = pathbase + name;
	  isDir = ( fl_filename_isdir( fullpath.c_str() ) != 0 );

	  // was this file specified explicitly?
	  isCurrentFile = ( currentFile == name );

#ifndef WIN32
	  // filter hidden files
	  if( !isCurrentFile && !hiddenFiles->value() && ( name[0] == '.' ) )
	    continue;
#endif

	  // only directories?
	  if( (selectionType & DIRECTORY) &&
	      !isDir &&
	      !(selectionType & STDFILE) &&
	      !(selectionType & DEACTIVATE_FILES) )
	    continue;

	  //if( !isDir /*!isCurrentFile*/ )
	    {
	      // filter according to the user pattern in the filename input
	      if( userPatterns.size() )
		{
		  bool cull = true;
		  for( unsigned int i = 0; i < userPatterns.size(); i++ )
		    {
		      if( flu_filename_match( name, userPatterns[i].c_str() ) != 0 )
			{
			  cull = false;
			  break;
			}
		    }
		  if( cull )
		    {
		      // only filter directories if someone just hit <TAB>
		      if( !isDir || ( isDir && filenameTabCallback ) )
			continue;
		    }
		}
	      // filter files according to the current pattern
	      else
		{
		  bool cull = true;
		  for( unsigned int i = 0; i < currentPatterns.size(); i++ )
		    {
		      if( flu_filename_match( name, currentPatterns[i].c_str() ) != 0 )
			{
			  cull = false;
			  break;
			}
		    }
		  if( cull )
		    {
		      // only filter directories if someone just hit <TAB>
		      if( !isDir || ( isDir && filenameTabCallback ) )
			continue;
		    }
		}
	    }

	  // add directories at the beginning, and files at the end
	  entry = new Entry( name, isDir?ENTRY_DIR:ENTRY_FILE, fileDetailsBtn->value(), this );
	  if( isDir )
	    {
	      if( listMode )
		filelist->insert( *entry, 0 );
	      else
		filedetails->insert( *entry, 0 );
	      numDirs++;
	      lastAddedDir = entry->filename.c_str();
	    }
	  else
	    {
	      if( listMode )
		filelist->add( entry );
	      else
		filedetails->add( entry );
	      numFiles++;
	      lastAddedFile = entry->filename.c_str();
	    }

	  // get some information about the file
	  struct stat s;
	  ::stat( fullpath.c_str(), &s );

	  // store size as human readable and sortable integer
	  entry->isize = s.st_size;
	  if( isDir && entry->isize == 0 )
	    entry->filesize = "";
	  else
	    {
	      char buf[32];
	      /*
		if( (entry->isize >> 40) > 0 ) // terrabytes
		{
		double TB = double(entry->isize)/double(1<<40);
		sprintf( buf, "%.1f TB", TB );
		}
	      */
	      if( (entry->isize >> 30) > 0 ) // gigabytes
		{
		  double GB = double(entry->isize)/double(1<<30);
		  sprintf( buf, "%.1f GB", GB );
		}
	      else if( (entry->isize >> 20) > 0 ) // megabytes
		{
		  double MB = double(entry->isize)/double(1<<20);
		  sprintf( buf, "%.1f MB", MB );
		}
	      else if( (entry->isize >> 10) > 0 ) // kilabytes
		{
		  double KB = double(entry->isize)/double(1<<10);
		  sprintf( buf, "%.1f KB", KB );
		}
	      else // bytes
		{
		  sprintf( buf, "%d bytes", (int)entry->isize );
		}
	      entry->filesize = buf;
	    }

	  // store date as human readable and sortable integer
	  entry->date = formatDate( ctime( &s.st_mtime ) );//ctime( &s.st_mtime );
	  entry->idate = s.st_mtime;

	  // convert the permissions into UNIX style rwx-rwx-rwx (user-group-others)
	  /*
	    unsigned int p = s.st_mode;
	    entry->pU = bool(p&S_IRUSR)<<2 | bool(p&S_IWUSR)<<1 | bool(p&S_IXUSR);
	    entry->pG = bool(p&S_IRGRP)<<2 | bool(p&S_IWGRP)<<1 | bool(p&S_IXGRP);
	    entry->pO = bool(p&S_IROTH)<<2 | bool(p&S_IWOTH)<<1 | bool(p&S_IXOTH);
	    char* perms[8] = { "---", "--x", "-w-", "-wx", "r--", "r-x", "rw-", "rwx" };
	    entry->permissions = perms[entry->pU];
	    entry->permissions += perms[entry->pG];
	    entry->permissions += perms[entry->pO];
	  */

	  entry->updateSize();
	  entry->updateIcon();

	  if( isCurrentFile )
	    {
	      filename.value( name );
	      entry->selected = true;
	      lastSelected = entry;
	      if( entry->type == ENTRY_FILE )
		previewGroup->file = currentDir + name;
	      previewGroup->redraw();
	      filelist->scroll_to( entry );
	      filedetails->scroll_to( entry );
	      //break;
	    }
	}

      for( i = 0; i < num; i++ )
	free((void*)(e[i]));
      free((void*)e);
    }

  // sort the files: directories first, then files
  if( listMode )
    filelist->sort( numDirs );
  else
    filedetails->sort( numDirs );

  // see if the user pushed <Tab> in the filename input field
  if( filenameTabCallback )
    {
      filenameTabCallback = false;

      FluSimpleString prefix = commonStr();

      if( numDirs == 1 && 
	  currentFile == (FluSimpleString(lastAddedDir)+"*") )
	{
	  delayedCd = lastAddedDir;
	  Fl::add_timeout( 0.0f, Flu_File_Chooser::delayedCdCB, this );
	}

      if( numDirs == 1 && numFiles == 0 )
	{
#ifdef WIN32
	  if( filename.value()[1] == ':' )
#else
	  if( filename.value()[0] == '/' )
#endif
	    {
	      FluSimpleString s = currentDir + lastAddedDir + "/";
	      filename.value( s.c_str() );
	    }
	  else
	    filename.value( lastAddedDir );
	}
      else if( numFiles == 1 && numDirs == 0 )
	{
#ifdef WIN32
	  if( filename.value()[1] == ':' )
#else
	  if( filename.value()[0] == '/' )
#endif
	    {
	      FluSimpleString s = currentDir + lastAddedFile;
	      filename.value( s.c_str() );
	    }
	  else
	    filename.value( lastAddedFile );
	}
      else if( prefix.size() >= currentFile.size() )
	{
#ifdef WIN32
	  if( filename.value()[1] == ':' )
#else
	  if( filename.value()[0] == '/' )
#endif
	    {
	      FluSimpleString s = currentDir + prefix;
	      filename.value( s.c_str() );
	    }
	  else
	    filename.value( prefix.c_str() );
	}

      if( currentFile == "*" && 
#ifdef WIN32
	  filename.value()[1] != ':' )
#else
	  filename.value()[0] != '/' )
#endif
        {
	  filename.value( "" );
	}
    }

  // see if the user pushed <Enter> in the filename input field
  if( filenameEnterCallback )
    {
      printf( "filenameEnterCallback\n" );
      filenameEnterCallback = false;

#ifdef WIN32
      if( filename.value()[1] == ':' )
#else
      if( filename.value()[0] == '/' )
#endif
	filename.value( "" );

      //if( isCurrentFile && numFiles == 1 )
      if( !_isProbablyAPattern( filename.value() ) )
	okCB();
    }

  if( _isProbablyAPattern( filename.value() ) )
    filename.position( 0, filename.size() );
  else
    filename.position( filename.size(), filename.size() );
  filename.take_focus();

  redraw();
}

// find the prefix string that is common to all entries in the list
FluSimpleString Flu_File_Chooser :: commonStr()
{
  FluSimpleString common;
  int index = 0;
  const char* name;
  int len, i;
  Fl_Group *g = getEntryGroup();
  for(;;)
    {
      bool allSkipped = true;
      for( i = 0; i < g->children(); i++ )
	{
	  name = ((Entry*)g->child(i))->filename.c_str();
	  len = strlen( name );
	  if( index >= len )
	    continue;
	  allSkipped = false;
	  if( i == 0 )
	    common.push_back( name[index] );
	  else if( toupper(common[index]) != toupper(name[index]) )
	    {
	      common[index] = '\0';
	      return common;
	    }
	}
      if( allSkipped )
	break;
      index++;
    }
  return common;
}

static const char* _flu_file_chooser( const char *message, const char *pattern, const char *filename, int type,
	int *count = 0, FluStringVector *filelist = 0 )
{
  static Flu_File_Chooser *fc = NULL;
  static FluSimpleString retname;

  if( !fc )
    {
      fc = new Flu_File_Chooser( filename, pattern, type, message );
    }
  else
    {
      fc->type( type );
      fc->clear_history();
      fc->label( message );
      if( !filename || filename[0] == '\0' )
	{
	  if( (!pattern || !fc->filter() || strcmp(pattern,fc->filter())) && fc->value() )
	    {
	      // if pattern is different, remove name but leave old directory:
	      retname = fc->value();
	      char *p = strrchr( (char*)retname.c_str(), '/' );
	      if( p )
		{
		  // If the filename is "/foo", then the directory will be "/", not ""
		  if( p == retname.c_str() )
		    retname[1] = '\0';
		  else
		    p[1] = '\0';
		}
	    }
	  fc->filter( pattern );
	  fc->value( retname.c_str() );
	}
      else
	{
	  fc->filter( pattern );
	  fc->value( filename );
	}
    }

  fc->set_modal();
  fc->show();

  while( fc->shown() )
    Fl::wait( 0.01 );

  Fl_Group::current(0);

  if( fc->value() )
    {
      if( count && filelist )
	{
	  *count = fc->count();
	  for( int i = 1; i <= *count; i++ )
	    filelist->add( FluSimpleString(fc->value(i)) );
	}
      retname = fc->value();
      return retname.c_str();
    }
  else
    return 0;
}

int flu_multi_file_chooser( const char *message, const char *pattern, const char *filename, FluStringVector *filelist )
{
  int count = 0;
  _flu_file_chooser( message, pattern, filename, Flu_File_Chooser::MULTI, &count, filelist );
  return count;
}

const char* flu_file_chooser( const char *message, const char *pattern, const char *filename )
{
  return _flu_file_chooser( message, pattern, filename, Flu_File_Chooser::SINGLE );
}

const char* flu_save_chooser( const char *message, const char *pattern, const char *filename )
{
  return _flu_file_chooser( message, pattern, filename, Flu_File_Chooser::SINGLE | Flu_File_Chooser::SAVING );
}

const char* flu_dir_chooser( const char *message, const char *filename )
{
  return _flu_file_chooser( message, "*", filename, Flu_File_Chooser::DIRECTORY );
}

const char* flu_dir_chooser( const char *message, const char *filename, bool showFiles )
{
  if( showFiles )
    return _flu_file_chooser( message, "*", filename,
			      Flu_File_Chooser::DIRECTORY | Flu_File_Chooser::DEACTIVATE_FILES );
  else
    return( flu_dir_chooser( message, filename ) );
}

const char* flu_file_and_dir_chooser( const char *message, const char *filename )
{
  return _flu_file_chooser( message, "*", filename, Flu_File_Chooser::STDFILE );
}
