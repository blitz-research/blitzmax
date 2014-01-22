// $Id: Flu_Helpers.h,v 1.6 2004/07/14 21:10:04 jbryan Exp $

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



#ifndef _FLU_HELPERS_H
#define _FLU_HELPERS_H

#include <FL/Fl.H>
#include <FL/Fl_Window.H>
#include <FL/Fl_Button.H>
#include <FL/Fl_Valuator.H>
#include <FL/Fl_Menu_.H>
#include <FL/Fl_Menu_Item.H>
#include "FLU/Flu_Enumerations.h"

/* Convenience routine to hide all open windows. This will (eventually) cause FLTK to exit() */
inline static void fl_exit()
{ while( Fl::first_window() ) Fl::first_window()->hide(); }

/* Return the index of the full menu entry 'fullname' in the menu 'menu', or
   -1 if 'fullname' does not exist in 'menu'.
*/
FLU_EXPORT int fl_Full_Find_In_Menu( const Fl_Menu_* menu, const char* fullname );
inline int fl_Full_Find_In_Menu( const Fl_Menu_& menu, const char* fullname )
{ return fl_Full_Find_In_Menu( &menu, fullname ); }

/* Return the menu item at the full menu entry 'fullname' in the menu 'menu', or
   NULL if 'fullname' does not exist in 'menu'.
*/
inline const Fl_Menu_Item *fl_Full_Find_Item_In_Menu( const Fl_Menu_* menu, const char* fullname )
{
  int index = fl_Full_Find_In_Menu( menu, fullname );
  return (index != -1) ? &(((Fl_Menu_Item*)menu->menu())[index]) : 0;
}
inline const Fl_Menu_Item *fl_Full_Find_Item_In_Menu( const Fl_Menu_& menu, const char* fullname )
{ return fl_Full_Find_Item_In_Menu( &menu, fullname ); }

/* Return the index of the menu entry 'name' in the menu 'menu', or
   -1 if 'name' does not exist in 'menu'.
*/
FLU_EXPORT int fl_Find_In_Menu( const Fl_Menu_* menu, const char* name );
inline int fl_Find_In_Menu( const Fl_Menu_& menu, const char* name )
{ return fl_Find_In_Menu( &menu, name ); }

/* Convenience callback for an Fl_Widget to show an Fl_Window. "arg" MUST be a descendent of Fl_Window */
inline static void fl_Show_Window_Callback( Fl_Widget* w, void* arg )
{ ((Fl_Window*)arg)->show(); }

/* Convenience callback for an Fl_Widget to hide an Fl_Window. "arg" MUST be a descendent of Fl_Window */
inline static void fl_Hide_Window_Callback( Fl_Widget* w, void* arg )
{ ((Fl_Window*)arg)->hide(); }

/* Convenience callback for an Fl_Widget to hide an Fl_Window. "arg" MUST be a descendent of Fl_Window.
   Before the window is hidden, its user_data() field is set to the widget that invoked the callback.
   The user_data() can then be used to determine which widget closed the window.
*/
inline static void fl_Hide_Window_And_Set_User_Data_Callback( Fl_Widget* w, void* arg )
{ ((Fl_Window*)arg)->user_data( w ); ((Fl_Window*)arg)->hide(); }

/* Convenience callback to get the value of an Fl_Button and store it (as an int) into "arg". ONLY use this for an Fl_Button and "arg" MUST point to an int. */
inline static void fl_Get_Button_Value_Callback( Fl_Widget* w, void* arg )
{ *((int*)arg) = ((Fl_Button*)w)->value(); }

/* Convenience callback to get the value of an Fl_Valuator and store it (as a float) into "arg". ONLY use this for an Fl_Valuator and "arg" MUST point to a float. */
inline static void fl_Get_Valuator_Value_Callback( Fl_Widget* w, void* arg )
{ *((float*)arg) = ((Fl_Valuator*)w)->value(); }

#endif
