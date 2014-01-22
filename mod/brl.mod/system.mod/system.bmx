
Strict

Rem
bbdoc: System/System
End Rem
Module BRL.System

ModuleInfo "Version: 1.26"
ModuleInfo "Author: Mark Sibly, Simon Armstrong"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: Moved event enums from system.h to event.mod/event.h"
ModuleInfo "Histroy: Moved keycode enums from system.h to keycodes.mod/keycodes.h"
ModuleInfo "History: 1.26 Release"
ModuleInfo "History: Fixed win32 filerequester causing activewindow dramas"
ModuleInfo "History: 1.25 Release"
ModuleInfo "History: Fixed unretained object issue with mouse tracking"
ModuleInfo "History: 1.24 Release"
ModuleInfo "History: Fixed windowed mode HideMouse issue"
ModuleInfo "History: 1.23 Release"
ModuleInfo "History: Fixed win32 requestfile default extension bug#2"
ModuleInfo "History: 1.22 Release"
ModuleInfo "History: Fixed win32 requestfile default extension bug"
ModuleInfo "History: 1.21 Release"
ModuleInfo "History: New Linux implementation of OpenURL"
ModuleInfo "History: 1.20 Release"
ModuleInfo "History: RequestFile now adds extension to filename on Windows"
ModuleInfo "History: 1.19 Release"
ModuleInfo "History: Added EVENT_GADGETLOSTFOCUS handling"
ModuleInfo "History: 1.18 Release"
ModuleInfo "History: Added EVENT_KEYREPEAT handling"
ModuleInfo "History: 1.17 Release"
ModuleInfo "History: OpenURL now attempts to fully qualify file / http url supplied"
ModuleInfo "History: 1.16 Release"
ModuleInfo "History: Fixed MacOS RequestFile to respect wild card filter"
ModuleInfo "History: 1.15 Release"
ModuleInfo "History: Fixed mouse hidden by default"
ModuleInfo "History: 1.14 Release"
ModuleInfo "History: Fixed HideMouse causing mouse to disappear when in non-client areas"
ModuleInfo "History: 1.13 Release"
ModuleInfo "History: Fixed Linux MoveMouse to be relative to the origin of the current Graphics window"
ModuleInfo "History: 1.12 Release"
ModuleInfo "History: Added Linux X11 import to remove glgraphics.mod dependency"
ModuleInfo "History: Fixed linux middle button crash"
ModuleInfo "History: 1.11 Release"
ModuleInfo "History: Fixed win32 clipboard glitches with QS_ALLINPUT bbSystemWait mod"
ModuleInfo "History: 1.11 Release"
ModuleInfo "History: CGSetLocalEventsSuppressionInterval fix for MacOS bbSystemMoveMouse"
ModuleInfo "History: 1.10 Release"
ModuleInfo "History: Ripped out input stuff and added hook"
ModuleInfo "History: 1.09 Release"
ModuleInfo "History: Tweaked MacOS GetChar()"
ModuleInfo "History: 1.07 Release"
ModuleInfo "History: Added AppTitle support for requesters"
ModuleInfo "History: 1.06 Release"
ModuleInfo "History: Fixed MacOS RequestDir ignoring initial path"
ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Added RequestDir support for MacOS"
ModuleInfo "History: 1.04 Release"
ModuleInfo "History: Added mouse capture to Win32"
ModuleInfo "History: Fixed C Compiler warnings"

Import BRL.Event
Import BRL.KeyCodes
Import BRL.Hook
Import BRL.FileSystem
Import Pub.StdC

Import "driver.bmx"

Import "system.c"

?MacOS
Import "system.macos.bmx"
Driver=New TMacOSSystemDriver
?Win32
Import "system.win32.bmx"
Import "-lcomdlg32"
Driver=New TWin32SystemDriver
?Linux
Import "-lX11"
Import "system.linux.bmx"
Driver=New TLinuxSystemDriver
?

Private

Global _busy

Public

Rem
bbdoc: Poll operating system
about:
#PollSystem returns control back to the operating system, allowing such
events as keystrokes and gadget actions to be processed. Control is then
returned back to your program.

If #PollSystem encounters a key, mouse or app suspend/resume/terminate 
event, an equivalent #TEvent object event will be generated which may be intercepted using
the #EmitEventHook hook.
End Rem
Function PollSystem()
	If _busy Return
	_busy=True
	Driver.Poll
	_busy=False
End Function

Rem
bbdoc: Wait for operating system
about:
#WaitSystem returns control back to the operating system, waiting until 
an event such as a keystroke or gadget action occurs.

Note that #WaitSystem may wait indefinitely if there is no possibility
of any events occuring, so use with caution.

If #WaitSystem encounters a key, mouse or app suspend/resume/terminate 
event, an equivalent #TEvent object will be generated which may be intercepted using
the #EmitEventHook hook.
End Rem
Function WaitSystem()
	If _busy Return
	_busy=True
	Driver.Wait
	_busy=False
End Function

Rem
bbdoc: Get current date
returns: The current date as a string
about:
Returns the current date in the format: DD MON YYYY (i.e. 10 DEC 2000).
End Rem
Function CurrentDate$()
	Local	time[256],buff:Byte[256]
	time_(time)
	strftime_(buff,256,"%d %b %Y",localtime_( time ))
	Return String.FromCString(buff)
End Function

Rem
bbdoc: Get current time
returns: The current time as a string
about:
Returns the current time in the format: HH:MM:SS (i.e. 14:31:57).
End Rem
Function CurrentTime$()
	Local	time[256],buff:Byte[256]
	time_(time)
	strftime_( buff,256,"%H:%M:%S",localtime_( time ) );
	Return String.FromCString(buff)
End Function

Rem
bbdoc: Move mouse pointer
about:
#MoveMouse positions the mouse cursor at a specific location within
the current window or graphics display.
End Rem
Function MoveMouse( x,y )
	Driver.MoveMouse x,y
End Function

Rem
bbdoc: Make the mouse pointer visible
End Rem
Function ShowMouse()
	Driver.SetMouseVisible True
End Function

Rem
bbdoc: Make the mouse pointer invisible
End Rem
Function HideMouse()
	Driver.SetMouseVisible False
End Function

Rem
bbdoc: Notify user
about:
#Notify activates a simple user interface element informing the user of an event.
The optional @serious flag can be used to indicate a 'critical' event.

Note that a user interface may not be available when in graphics mode on some platforms.
End Rem
Function Notify( text$,serious=False )
	Driver.Notify text,serious
End Function

Rem
bbdoc: Request user confirmation.
returns: True or False depending on the user's selection
about:
#Confirm activates a simple user interface element requesting the user to select between
YES and NO options. If the user selects YES, then #Confirm returns True. Otherwise,
False is returned.

Note that a user interface may not be available when in graphics mode on some platforms.
End Rem
Function Confirm( text$,serious=False )
	Return Driver.Confirm( text,serious )
End Function

Rem
bbdoc: Request user confirmation or cancellation.
returns: 1, 0 or -1 depending on the user's selection
about:
#Proceed activates a simple user interface element requesting the user to select between
YES, NO and CANCEL options. If the user selects YES, then #Proceed return 1. If the user
selects NO, then #Proceed returns 0. Otherwise, #Proceed returns -1.

Note that a user interface may not be available when in graphics mode on some platforms.
End Rem
Function Proceed( text$,serious=False )
	Return Driver.Proceed( text,serious )
End Function

Rem
bbdoc: Display system file requester.
returns: The path of the selected file or an empty string if the operation was cancelled.
about:
@text is used as the title of the file requester.

The optional @extensions string can either be a comma separated list of 
file extensions or as in the following example groups of extensions
that begin with a "group:" and separated by a semicolon. 
@save_flag can be True to create a save-style requester, or False to create a load-style requester.

@initial_path is the initial path for the file requester.

Note that a user interface may not be available when in graphics mode on some platforms.
End Rem
Function RequestFile$( text$,extensions$="",save_flag=False,initial_path$="" )
	Return Driver.RequestFile( text,extensions,save_flag,initial_path )
End Function

Rem
bbdoc: Display system folder requester.
returns: The path of the selected folder or an empty string if the operation was cancelled.
about:
@text is used as the title of the file requester.

@initial_path is the initial path for the folder requester.

Note that a user interface may not be available when in graphics mode on some platforms.
End Rem
Function RequestDir$( text$,initial_path$="" )
	Return Driver.RequestDir( text,initial_path )
End Function

Rem
bbdoc: Opens a URL with the system's default web browser.
about: Note that a user interface may not be available when in graphics mode on some platforms.
End Rem
Function OpenURL( url$ )
	Local dev$,anchor$

	dev=url[..5].toLower()
	If dev<>"http:" And dev<>"file:" And url[..6].ToLower()<>"https:"
		Local h=url.find("#")
		If h>-1
			anchor=url[h..]
			url=url[..h]
		EndIf
		Local f$=RealPath(url)
		If FileType(f) 
			url="file:"+f +anchor
		Else
			url="http:"+url+anchor
		EndIf
	EndIf
	Return Driver.OpenURL( url )
End Function

Extern

Rem
bbdoc: Get desktop width
returns: Width of the desktop, in pixels
End Rem
Function DesktopWidth()="bbSystemDesktopWidth"

Rem
bbdoc: Get desktop height
returns: Height of the desktop, in pixels
End Rem
Function DesktopHeight()="bbSystemDesktopHeight"

Rem
bbdoc: Get desktop depth
returns: Bits per pixel depth of the desktop
about:
The depth of the desktop is the number of bits per pixel.

Note that on some platforms this function may return 0 if the desktop depth cannot be determined.
End Rem
Function DesktopDepth()="bbSystemDesktopDepth"

Rem
bbdoc: Get desktop refresh rate
returns: Refresh rate, in cycles per second, of the desktop
about:
Note that on some platforms this function may return 0 if the desktop refresh rate cannot be determined.
End Rem
Function DesktopHertz()="bbSystemDesktopHertz"

End Extern
