
Strict

Rem
bbdoc: MaxGUI/MaxGUI
End Rem
Module MaxGUI.MaxGUI

ModuleInfo "Version: 1.35"
ModuleInfo "Author: Simon Armstrong, Mark Sibly"
ModuleInfo "License: zlib/libpng"

Import BRL.Map
Import BRL.LinkedList
Import BRL.FileSystem
Import BRL.StandardIO

Import "driver.bmx"
Import "event.bmx"
Import "gadget.bmx"
Import "guifont.bmx"
Import "iconstrip.bmx"

Global RequestedColor

Type THotKey
	Field succ:THotKey
	Field key,mods
	Field event:TEvent
	Field owner
End Type

Global hotKeys:THotKey

Rem
bbdoc: Set a hotkey event.
about:
When the specified hotkey combination is selected by the user, the specified
@event will be emitted using #EmitEvent.

If @event is #Null, an event with an @id equal to EVENT_HOTKEYHIT, @data equal
to @key and @mods equal to @mods will be emitted.

#SetHotKeyEvent will overwrite any existing hotkey event with the same @key, @mods and @owner.

Please refer to the #{Key Codes} module for valid key and modifier codes.
End Rem
Function SetHotKeyEvent:THotKey( key,mods,event:TEvent=Null,owner=0 )
	If Not event event=CreateEvent( EVENT_HOTKEYHIT,Null,key,mods )
	Local t:THotKey=hotKeys
	While t
		If t.key=key And t.mods=mods And t.owner=owner Then Exit
		t=t.succ
	Wend
	If Not t
		t=New THotKey
		t.key=key
		t.mods=mods
		t.succ=hotKeys
		t.owner=owner
		hotKeys=t
	EndIf
	t.event=event
	Return t
End Function

Rem
bbdoc: Remove a hotkey event.
about:
Clears a hotkey object created with #SetHotKeyEvent.
End Rem
Function RemoveHotKey(hotkey:THotKey)
	Local t:THotKey,tt:THotKey
	t=hotKeys
	While t
		If t=hotkey
			If tt tt.succ=t.succ Else hotkeys=t.succ
			t.succ=Null
			Return
		EndIf
		tt=t
		t=t.succ
	Wend
End Function

Function HotKeyEvent:TEvent( key,mods,owner )
	Local t:THotKey=hotKeys
	While t
		If t.key=key And t.mods=mods
			If t.owner And t.owner<>owner
			Else
				Return t.event
			EndIf
		EndIf
		t=t.succ
	Wend
	Return Null
End Function

Rem
bbdoc: Look-up a system defined color.
returns: #True if a matching color is retrieved from the system, #False if the hard-coded fall-back is used.
about:
@colorindex can be one of the following values:

[ @Constant | @Description | @{Fall Back} 
* GUICOLOR_WINDOWBG | Window/panel background color. | R: 240, G: 240, B: 240 
* GUICOLOR_GADGETBG | Gadget background color (e.g. textfield). | R: 255, G: 255, B: 255 
* GUICOLOR_GADGETFG | Gadget text color. | R: 0, G: 0, B: 0 
* GUICOLOR_SELECTIONBG | Text selection background color. | R: 50, G: 150, B: 255 
* GUICOLOR_LINKFG | Hyperlink text color. | R: 0, G: 0, B: 255 
] 

See Also: #LookupGuiFont, #RequestColor
EndRem
Function LookupGuiColor( colorindex, red:Byte Var, green:Byte Var, blue:Byte Var )
	Return maxgui_driver.LookupColor( colorindex, red, green, blue )
EndFunction

Rem
bbdoc: Prompts the user for a color.
returns: #True if a color is selected, #False if the requester was cancelled.
about:
The parameters @red, @green, @blue are the initial color to display in the requester,
with components in the range 0 to 255.

After a color is selected, use the #RequestedRed, #RequestedGreen and #RequestedBlue
functions to determine the color chosen by the user.

See Also: #LookupGuiColor
EndRem
Function RequestColor(r,g,b)
	Local	argb
	argb=maxgui_driver.RequestColor(Byte(r),Byte(g),Byte(b))
	If argb
		RequestedColor=argb
		Return True
	EndIf
End Function

Rem
bbdoc: Get the red component of the color previously chosen by the user.
about: See #RequestColor for more information.
EndRem
Function RequestedRed()
	Return (RequestedColor Shr 16) & $FF
End Function

Rem
bbdoc: Get the green component of the color previously chosen by the user.
about: See #RequestColor for more information.
EndRem
Function RequestedGreen()
	Return (RequestedColor Shr 8) & $FF
End Function

Rem
bbdoc: Get the blue component of the color previously chosen by the user.
about: See #RequestColor for more information.
EndRem
Function RequestedBlue()
	Return RequestedColor & $FF
End Function

Rem
bbdoc: Prompts the user to select a system font.
returns: A @TGuiFont object, or #Null if no font was selected.
about:
Prompts the user for a font and returns an object that can then be used with the #SetGadgetFont command.

See Also: #LoadGuiFont, #LookupGuiFont, #FontName, #FontSize and #FontStyle
EndRem
Function RequestFont:TGuiFont(font:TGuiFont=Null)
	Return maxgui_driver.RequestFont(font:TGuiFont)
End Function

Rem
bbdoc: Load a system font by name.
returns: A @TGuiFont object, or #Null if a suitable matching font was not found on the system.
about:
Loads a system font by name and returns an object that can then be used with the #SetGadgetFont command.

Depending on the platform, some gadgets may not respond to all or any of the attributes specified in the function
parameters.

See Also: #RequestFont, #LookupGuiFont, #FontName, #FontSize and #FontStyle
EndRem
Function LoadGuiFont:TGuiFont(name$,height:Double,bold=False,italic=False,underline=False,strikethrough=False)
	Local	flags = FONT_NORMAL
	If bold flags:|FONT_BOLD
	If italic flags:|FONT_ITALIC
	If underline flags:|FONT_UNDERLINE
	If strikethrough flags:|FONT_STRIKETHROUGH
	Return maxgui_driver.LoadFontWithDouble(name,height,flags)
End Function

Rem
bbdoc: Loads a suitable GUI font that best matches the supplied font characteristics.
returns: A new @TGuiFont instance chosen using the supplied parameters.
about: If the current MaxGUI driver doesn't return a suitable GUI font, then
a hard-coded fall-back font is returned instead, depending upon the platform.

@pFontType can take one of the following constants:

[ @Constant | @{Windows Fall-Back} | @{Mac OS X Fall-Back} | @{Linux Fall-Back} | @Description
* GUIFONT_SYSTEM | MS Shell Dlg | Lucida Grande | FreeSerif | Default font used to draw gadgets by the OS.
* GUIFONT_SERIF | Times New Roman | Times New Roman | FreeSerif | Serif font.
* GUIFONT_SANSSERIF | Arial | Helvetica | FreeSans | Sans Serif font.
* GUIFONT_SCRIPT | Comic Sans MS | Comic Sans MS | TSCu_Comic | Handwriting style font.
* GUIFONT_MONOSPACED | Consolas/Courier New | Courier | Courier | Fixed width font typically used for coding.
]

@pFontSize specifies the point size the font should be loaded with. If this value is less than or equal to 0, then
a suitable size is automatically chosen, or a hard-coded alternative is used (usually between 8-13pt).

@pFontStyle should specify any additional font styles that the font should be loaded with. A combination of any of the
following flags can be used:

[ @Constant | @{Font Style}
* FONT_BOLD | Bold
* FONT_ITALIC | Italic
* FONT_UNDERLINE | Underlined
* FONT_STRIKETHROUGH | *Strikethrough
]

%{Note: FONT_STRIKETHROUGH isn't fully supported by all gadgets/platforms.}

See Also: #LookupGuiColor, #RequestFont, #FontName, #FontSize and #FontStyle
EndRem
Function LookupGuiFont:TGuiFont( pFontType% = GUIFONT_SYSTEM, pFontSize:Double = 0, pFontStyle% = 0 )
	Return maxgui_driver.LibraryFont( pFontType, pFontSize, pFontStyle )
End Function

Rem
bbdoc: Retrieves the corresponding property from the @TGuiFont type instance.
returns: A string representing the name of the font.
about: See Also: #LoadGuiFont, #LookupGuiFont, #RequestFont, #FontSize and #FontStyle
EndRem
Function FontName$(font:TGuiFont)
	Return font.name	
End Function

Rem
bbdoc: Retrieves the corresponding property from the @TGuiFont type instance.
returns: A double representing the size (in points) of the font.
about: See Also: #LoadGuiFont, #LookupGuiFont, #RequestFont, #FontName and #FontStyle
EndRem
Function FontSize:Double(font:TGuiFont)
	Return font.size
End Function

Rem
bbdoc: Retrieves the corresponding property from the @TGuiFont type instance.
returns: An integer representing the style of the font (e.g. Bold, Underlined, Italics, Strikethrough).
about: The returned value will be a combination of the following bit flags:

[ @Constant | @{Font Style}
* FONT_BOLD | Bold
* FONT_ITALIC | Italic
* FONT_UNDERLINE | Underlined
* FONT_STRIKETHROUGH | *Strikethrough
]

%{Note: FONT_STRIKETHROUGH isn't fully supported by all gadgets/platforms.}

See Also: #LoadGuiFont, #RequestFont, #FontName and #FontSize
EndRem
Function FontStyle(font:TGuiFont)
	Return font.style
End Function

Const POINTER_DEFAULT=0
Const POINTER_ARROW=1
Const POINTER_IBEAM=2
Const POINTER_WAIT=3
Const POINTER_CROSS=4
Const POINTER_UPARROW=5
Const POINTER_SIZENWSE=6
Const POINTER_SIZENESW=7
Const POINTER_SIZEWE=8
Const POINTER_SIZENS=9
Const POINTER_SIZEALL=10
Const POINTER_NO=11
Const POINTER_HAND=12
Const POINTER_APPSTARTING=13
Const POINTER_HELP=14

Global lastPointer% = -1

Rem
bbdoc: Changes the applcation's mouse cursor.
about:
The shape of the system mouse pointer can be one of the following:

[ @Constant | @Description
* POINTER_DEFAULT | Default OS pointer.
* POINTER_ARROW | Arrow pointer.
* POINTER_IBEAM | Typically used when making text selections.
* POINTER_WAIT | Hourglass animation.
* POINTER_CROSS | Typically used for precise drawing.
* POINTER_UPARROW | Typically used for selections.
* POINTER_SIZENWSE | Typically used over sizing handles.
* POINTER_SIZENESW | Typically used over sizing handles.
* POINTER_SIZEWE | Typically used over sizing handles.
* POINTER_SIZENS | Typically used over sizing handles.
* POINTER_SIZEALL | Typically shown when moving an item.
* POINTER_NO | Typically shown when an action is prohibited.
* POINTER_HAND | Typically used for links.
* POINTER_APPSTARTING | Usually shows a pointer and miniature hourglass animation.
* POINTER_HELP | Usually shows an arrow pointer, with an adjacent question mark.
]

%{Note: Some pointers may not be supported on all platforms.}
EndRem
Function SetPointer(shape)
	If shape <> lastPointer Then
		lastPointer = shape
		maxgui_driver.SetPointer(shape)
	EndIf
End Function

Function 	UserName$()
	Return maxgui_driver.UserName()
End Function	

Function 	ComputerName$()
	Return maxgui_driver.ComputerName()
End Function

' gadget

Rem
bbdoc: Remove a gadget and free its resources.
EndRem
Function FreeGadget( gadget:TGadget )
	gadget.CleanUp()
End Function

Rem
bbdoc: Client area dimensions of a gadget.
returns: The width of the client area (in pixels) of the specified container gadget.
EndRem
Function ClientWidth( gadget:TGadget )
	Return gadget.ClientWidth()
End Function

Rem
bbdoc: Client area dimensions of a gadget.
returns: The height of the client area (in pixels) of the specified container gadget.
EndRem
Function ClientHeight( gadget:TGadget )
	Return gadget.ClientHeight()
End Function

Rem
bbdoc: Horizontal position of gadget.
returns: The horizontal position (in pixels) of a gadget relative to the top-left corner of the parent's client area.
EndRem
Function GadgetX( gadget:TGadget )
	Return gadget.GetXPos()
End Function

Rem
bbdoc: Vertical position of gadget.
returns: The vertical position (in pixels) of a gadget relative to the top-left corner of the parent's client area.
EndRem
Function GadgetY( gadget:TGadget )
	Return gadget.GetYPos()
End Function

Rem
bbdoc: Gadget width.
returns: The current width (in pixels) of a gadget.
EndRem
Function GadgetWidth( gadget:TGadget )
	Return gadget.GetWidth()
End Function

Rem
bbdoc: Gadget height.
returns: The current height (in pixels) of a gadget.
EndRem
Function GadgetHeight( gadget:TGadget )
	Return gadget.GetHeight()
End Function

Rem
bbdoc: Return a gadget's group or parent.
returns: The @TGadget instance of the parent or group gadget.
EndRem
Function GadgetGroup:TGadget( gadget:TGadget )
	Return gadget.GetGroup()
End Function

Rem
bbdoc: Returns an integer representing a gadget's class.
about: The returned integer will match one of the following constants:

[ @Constant | @{Corresponding Gadget Class}
* GADGET_DESKTOP | Desktop
* GADGET_WINDOW | Window
* GADGET_BUTTON | Button
* GADGET_PANEL | Panel
* GADGET_TEXTFIELD | TextField
* GADGET_TEXTAREA | TextArea
* GADGET_COMBOBOX | ComboBox
* GADGET_LISTBOX | ListBox
* GADGET_TOOLBAR | Toolbar
* GADGET_TABBER | Tabber
* GADGET_TREEVIEW | Treeview
* GADGET_HTMLVIEW | HtmlView
* GADGET_LABEL | Label
* GADGET_SLIDER | Slider
* GADGET_PROGBAR | Progress Bar
* GADGET_MENUITEM | Menu
* GADGET_NODE | Treeview Node
* GADGET_CANVAS | Canvas Gadget
]

EndRem
Function GadgetClass( gadget:TGadget )
	Return gadget.Class()
End Function

Rem
bbdoc: Make a gadget visible.
about: See Also: #HideGadget and #GadgetHidden.
EndRem
Function ShowGadget( gadget:TGadget )
	gadget.SetShow True
End Function

Rem
bbdoc: Hide a gadget.
about: See Also: #ShowGadget and #GadgetHidden.
EndRem
Function HideGadget( gadget:TGadget )
	gadget.SetShow False
End Function

Rem
bbdoc: Enable a gadget, allowing user interaction.
about: See Also: #DisableGadget and #GadgetDisabled.
EndRem
Function EnableGadget( gadget:TGadget )
	gadget.SetEnabled True
End Function

Rem
bbdoc: Disable a gadget, blocking user interaction.
about: See Also: #EnableGadget and #GadgetDisabled.
EndRem
Function DisableGadget( gadget:TGadget )
	gadget.SetEnabled False
End Function

Rem
bbdoc: Determines whether a gadget is marked as hidden.
returns: #True if the gadget is set to be hidden, #False otherwise.
about: If the optional @recursive parameter is set to #True, the function will only return #False
if the gadget and all of its ancestors are visible, otherwise the function simply returns the
property of the individual gadget.

See Also: #ShowGadget and #HideGadget.
EndRem
Function GadgetHidden( gadget:TGadget, recursive% = False )
	If recursive Then
		While Not (gadget.State()&STATE_HIDDEN)
			gadget = gadget.parent
			If Not gadget Return False
		Wend
		Return True
	EndIf	
	Return (gadget.State()&STATE_HIDDEN)
End Function

Rem
bbdoc: Determines whether a gadget is marked as enabled.
returns: #True if the gadget is set to be disabled, #False otherwise.
about: If the optional @recursive parameter is set to #True, the function will only return #False
if the gadget and all of its ancestors are enabled, otherwise the function simply returns the
property of the individual gadget.

See Also: #EnableGadget and #DisableGadget.
EndRem
Function GadgetDisabled( gadget:TGadget, recursive% = False )
	If recursive Then
		While Not (gadget.State()&STATE_DISABLED)
			gadget = gadget.parent
			If Not gadget Return False
		Wend
		Return True
	EndIf	
	Return (gadget.State()&STATE_DISABLED)
End Function

Rem
bbdoc: Set a gadget's size and position.
about: The position and size should be given in pixels, and are relative to the upper-left corner of its parent's client-area.

The @w and @h parameters set the gadget width or height, unless the gadget concerned is a window with the WINDOW_CLIENTCOORDS flag,
in which case, they represent the client-area dimensions.
EndRem
Function SetGadgetShape( gadget:TGadget,x,y,w,h )
	gadget.SetShape x,y,w,h
End Function

Rem
bbdoc: Set the layout rules for a gadget when its parent is resized.
about:
#SetGadgetLayout lets you control the automatic layout of a gadget in the event that its parent is resized.

This will happen either if a window is resized, or if #SetGadgetShape is called on a group gadget.

Each edge of a @Gadget has an alignment setting that fixes it in place in the following manner:

[ @Constant | @Description
* EDGE_CENTERED | The edge of the gadget is kept a fixed distance from the center of its parent.
* EDGE_ALIGNED | The edge of the gadget stays a fixed distance from its parent's corresponding edge.
* EDGE_RELATIVE | The edge of the gadget remains a proportional distance from both of its parent's edges.
]

The default behaviour may vary between platforms, so it is highly recommended that you set this for gadgets on resizable windows.
EndRem
Function SetGadgetLayout( gadget:TGadget,Left,Right,Top,Bottom )
	gadget.SetLayout Left,Right,Top,Bottom
End Function

Rem
bbdoc: Sets whether a standard MaxGUI gadget emits events from the keyboard or mouse.
about: This functions attempts to provide similar functionality for all gadgets to that of @Panels created with the PANEL_ACTIVE flag.

The @flags parameter can be any combination of the following:

SENSITIZE_MOUSE: The gadget will emit the following events:

[ @{Event ID} | @Description
* EVENT_MOUSEDOWN | Mouse button pressed. Event data contains mouse button code.
* EVENT_MOUSEUP | Mouse button released. Event data contains mouse button code.
* EVENT_MOUSEMOVE | Mouse moved. Event x and y contain mouse coordinates.
* EVENT_MOUSEWHEEL | Mouse wheel spun. Event data contains delta clicks.
* EVENT_MOUSEENTER | Mouse entered gadget area.
* EVENT_MOUSELEAVE | Mouse left gadget area.
]

SENSITIZE_KEYS: The gadget will emit the following events:

[ @{Event ID} | @Description
* EVENT_KEYDOWN | Key pressed. Event data contains keycode.
* EVENT_KEYUP | Key released. Event data contains keycode.
* EVENT_KEYREPEAT | Key is being held down. Event data contains keycode.
]

SENSITIZE_ALL: Exactly the same as combining SENSITIZE_MOUSE and SENSITIZE_KEYS.

Gadgets that have been disabled should not emit key events, although they may still emit mouse events.

Not all gadgets will be able to emit all of the events, particularly those that don't receive typical focus
such as labels or htmlviews, but even this may differ depending on the platform.

%{ @{Warning:} This is a powerful new function that possibly involves hooking into the system's message queue
to ask for mouse/key events before they are processed even by the OS's GUI library. As such, using this function
on certain controls may cause them to be behave differently. In addition, care should be taken when using
this function to avoid infinite loops, for example repositioning gadgets in an event hook that processes the
message as it is received.

It is therefore recommended that this function is only used by advanced MaxGUI users.}

See Also: #GadgetSensitivity
EndRem
Function SetGadgetSensitivity( gadget:TGadget, flags )
	Return gadget.SetSensitivity( flags )
End Function

Rem
bbdoc: Returns flags specifying whether a gadget emits events from the keyboard or mouse.
about: The function will return a combination of the following flags:

[
* SENSITIZE_MOUSE: The gadget will emit mouse events.
* SENSITIZE_KEYS: The gadget will emit keyboard events.
]

See #SetGadgetSensitivity for more information.
EndRem
Function GadgetSensitivity( gadget:TGadget )
	Return gadget.GetSensitivity()
End Function


Rem
bbdoc: Stores a pointer to a related object, that can later be retrieved using #GadgetExtra.
about:
This function has many uses - you may want to store a custom type instance to the treeview node that
represents it, or you may want to store a hidden string value that represents a gadget's action.

However, it is important to note that this function will result in a pointer being stored to that object
which will only be released when a new object or #Null is passed to this function, or when the gadget is freed
using #FreeGadget.
End Rem
Function SetGadgetExtra( gadget:TGadget, extra:Object )
	gadget.extra = extra
End Function

Rem
bbdoc: Retrieves the object instance previously stored using #SetGadgetExtra.
End Rem
Function GadgetExtra:Object( gadget:TGadget )
	Return gadget.extra
End Function

Rem
bbdoc: Request focus for a gadget.
about: See Also: #ActiveGadget()
EndRem
Function ActivateGadget( gadget:TGadget )
	gadget.Activate ACTIVATE_FOCUS
End Function

Rem
bbdoc: Return the currently active gadget.
returns: The gadget that currently has the keyboard focus. Returns #Null if no MaxGUI gadget has focus.
about: See Also: #ActivateGadget.
EndRem
Function ActiveGadget:TGadget()
	Return maxgui_driver.ActiveGadget()
End Function

Rem
bbdoc: Perform a cut operation on a gadget.
about: This is most commonly used on @TextAreas to cut text that is currently selected.
EndRem
Function GadgetCut( gadget:TGadget )
	gadget.Activate ACTIVATE_CUT
End Function

Rem
bbdoc: Perform a copy operation on a gadget.
about: This is most commonly used on @TextAreas to copy text that is currently selected.
EndRem
Function GadgetCopy( gadget:TGadget )
	gadget.Activate ACTIVATE_COPY
End Function

Rem
bbdoc: Perform a paste operation on a gadget.
about: This is most commonly used on @TextAreas to paste text into the gadget from the clipboard.
EndRem
Function GadgetPaste( gadget:TGadget )
	gadget.Activate ACTIVATE_PASTE
End Function

Rem
bbdoc: Perform a print operation on a gadget.
about: This function is currently only supported on @TextAreas and @HTMLViews.
EndRem
Function GadgetPrint( gadget:TGadget )
	gadget.Activate ACTIVATE_PRINT
End Function

Rem
bbdoc: Redraws a gadget.
about:
The RedrawGadget command requests that the gadget should be redrawn by the underlying
Operating System but is not necessarily guaranteed to happen immediately.

In the case of a @Canvas gadget an EVENT_GADGETPAINT event is emitted
when the Operating System begins the actual redraw. The following example
illustrates how to manage this feature:
EndRem
Function RedrawGadget( gadget:TGadget )
	gadget.Activate ACTIVATE_REDRAW
End Function

Rem
bbdoc: Set a gadget's pixmap.
about: This is a more generic form of old backwards-compatible #SetPanelPixmap function which now allows icons
to be set for other gadgets as well as just backgrounds for panels.

For setting background pixmaps on panels, @flags should still be one of the following:

[ @Flag | @Description
* PANELPIXMAP_TILE | The panel is filled with repeating tiles.
* PANELPIXMAP_CENTER | The pixmap is positioned at the center of the panel.
* PANELPIXMAP_FIT | The pixmap is scaled proportionally to best fit the panel size.
* PANELPIXMAP_FIT2 | A variant of PANELPIXMAP_FIT where clipping can occur to achieve a better fit.
* PANELPIXMAP_STRETCH | The pixmap is stretched to fit the entire panel.
]

Alternatively, to set a push-button or menu's icon, use the following constants:

[ @Flag | @Description
* GADGETPIXMAP_ICON | Places an icon-sized pixmap onto a push-button/menu.
* GADGETPIXMAP_NOTEXT | Removes text on buttons when used in conjunction with GADGETPIXMAP_ICON.
]

Each platform allows slightly different maximum icon sizes for their menus. Therefore, the recommended
size for menu icons is 12x12 pixels which appears to work well on all supported platforms.

Note: At present, OK buttons do not support icons as a cross-platform solution is unavailable. Icons
are also not supported for radio buttons or checkbox style buttons.

Passing #Null as the value for the @pixmap parameter will remove the pixmap from the gadget.
EndRem
Function SetGadgetPixmap( gadget:TGadget, pixmap:TPixmap, flags% = GADGETPIXMAP_ICON )
	Return gadget.SetPixmap( pixmap, flags )
End Function

Rem
bbdoc: Set the transparency of a gadget.
about: Alpha should be in the range 0.0 (invisible) to 1.0 (solid). Very few gadgets support this functionality,
but some Mac OS X gadgets do, in addition to @Windows when running Windows XP+. In certain circumstances, window
transparency may be disabled (for example, when a canvas is added to a window) to prevent redraw issues on some
platforms.

Using the function on windows with @Canvases on them may cause undesired effects, particularly on Windows 2000/XP
because of conflicts between the software based window manager and the hardware accelerated graphics contexts.
EndRem
Function SetGadgetAlpha( gadget:TGadget,alpha# )
	gadget.SetAlpha(alpha)
End Function

Rem
bbdoc: Sets a gadget's text.
about: For the @Label, @Button, @TextField, @ComboBox, @TextArea and Group @Panel gadgets, the contents
of the gadget are replaced with the new @text$.

For a @Window gadget, #SetGadgetText changes the title. For @{Window}s with a status bar, #SetStatusText
should be used to independently set the status bar text.

This command will automatically delocalize the gadget - to set localized gadget text, see #LocalizeGadget.
EndRem
Function SetGadgetText( gadget:TGadget,Text$ )
	maxgui_driver.DelocalizeGadget( gadget )
	gadget.SetText( Text )
End Function

Rem
bbdoc: Returns a gadget's text.
about: For the @Label, @Button, @TextField, @ComboBox, @TextArea and Group @Panel gadgets, the contents
of the gadget are returned with the new gadget's text.

For a @Window gadget, #GadgetText returns the title of the @Window.
EndRem
Function GadgetText$( gadget:TGadget )
	Return gadget.GetText()
End Function

Rem
bbdoc: Set a gadget's tooltip.
about: Sets the tooltip for a %{non-item based} positionable MaxGUI gadget. This function will have no effect on the following gadget types:

[
* Windows
* Menus
* Tree-view nodes
* List-boxes
* Toolbars
* Tabbers
* Desktops
]

This command will automatically delocalize the gadget - to set a localized gadget tooltip, see #LocalizeGadget.

See Also: #GadgetTooltip()
EndRem
Function SetGadgetToolTip( gadget:TGadget, tip$ )
	maxgui_driver.DelocalizeGadget( gadget )
	gadget.SetTooltip( tip )
End Function

Rem
bbdoc: Returns the gadget tooltip previously set with #SetGadgetTooltip.
about: Returns the tooltip for a %{non-item based} positionable MaxGUI gadget. As such, this function will have no effect on the following gadget types:

[
* Windows
* Menus
* Tree-view nodes
* List-boxes
* Toolbars
* Tabbers
* Desktops
]

See Also: #SetGadgetTooltip()
EndRem
Function GadgetTooltip$( gadget:TGadget )
	Return gadget.GetTooltip()
End Function

Rem
bbdoc: Set a gadget's font.
about: See #LoadGuiFont and #RequestFont for creating a @TGuiFont.
EndRem
Function SetGadgetFont( gadget:TGadget,font:TGuiFont )
	gadget.SetFont( font )
End Function

Rem
bbdoc: Set a gadget's foreground color.
about: The @{r}ed, @{g}reen and @{b}lue components should be in the range 0 to 255.
See Also: #SetGadgetColor()
EndRem
Function SetGadgetTextColor( gadget:TGadget,r,g,b )
	gadget.SetTextColor( r,g,b )
End Function

Rem
bbdoc: Set a gadget's background color.
about: The @{r}ed, @{g}reen and @{b}lue components should be in the range 0 to 255.
This command is not supported for all Gadget types on all platforms.
See Also: #SetGadgetTextColor() #SetGadgetAlpha #RemoveGadgetColor
EndRem
Function SetGadgetColor( gadget:TGadget,r,g,b,bg=True )
	If bg
		gadget.SetColor r,g,b
	Else
		gadget.SetTextColor( r,g,b )
	EndIf
End Function

Rem
bbdoc: Removes a gadget's background color.
about: Restores a gadget to it's default color.
See Also: #SetGadgetColor()
EndRem
Function RemoveGadgetColor( gadget:TGadget )
	gadget.RemoveColor
End Function


Rem
bbdoc: Set the hot-key combination for a gadget.
End Rem
Function SetGadgetHotKey( gadget:TGadget,hotkey,modifier )
	gadget.SetHotKey hotkey,modifier
End Function

Rem
bbdoc: Attaches an event filter function to a MaxGUI gadget.
about:
The filter function supplied is called by the gadget with a #TEvent
and optional user context object. If the function returns zero the event
is filtered and not processed further by the system whereas a non zero
return indicates event processing should proceed as normal.

The TextArea/TextField events currently supported:

[ @{Event ID} | @Description
* EVENT_KEYDOWN | Key pressed. Event data contains keycode.
* EVENT_KEYCHAR | Key character. Event data contains unicode value.
]

Currently only the EVENT_KEYDOWN, EVENT_KEYCHAR events produced by
TextArea and TextField gadgets can be filtered with the SetGadgetFilter
command.
End Rem
Function SetGadgetFilter( gadget:TGadget,callback(event:TEvent,context:Object),context:Object=Null )
	gadget.SetFilter callback,context
End Function


' localization (constants declared in maxgui.mod/driver.bmx)

Rem
bbdoc: Localize a gadget using the supplied localization strings.
about: The function will use the supplied localization strings to localize a gadget and its text.  The gadget
will also be marked so that changing the language will update the text.  Calling #DelocalizeGadget or
#SetGadgetText will disable this behaviour.

Localization strings and their structure are described in #LocalizeString function documentation.

Item-based gadgets should mark any items, whose strings are also wanted to be localized, with the
GADGETITEM_LOCALIZED flag.  See the @flags parameter of the #AddGadgetItem / #InsertGadgetItem
/ #ModifyGadgetItem calls.

See Also: #GadgetLocalized, #SetLocalizationMode and #SetLocalizationLanguage.
EndRem
Function LocalizeGadget( gadget:TGadget, localizationtext$, localizationtooltip$ = "" )
	maxgui_driver.SetGadgetLocalization( gadget, localizationtext, localizationtooltip )
EndFunction

Rem
bbdoc: Determines whether a gadget is registered as being 'localized'.
about: See #LocalizeGadget and #SetLocalizationMode for more information.
EndRem
Function GadgetLocalized:Int( gadget:TGadget )
	Return maxgui_driver.GadgetLocalized(gadget)
EndFunction

Rem
bbdoc: Delocalizes a gadget so that it's no longer updated if the localization language/mode changes.
about: See Also: #LocalizeGadget, #SetLocalizationLanguage and #SetLocalizationMode.
EndRem
Function DelocalizeGadget( gadget:TGadget )
	maxgui_driver.DelocalizeGadget( gadget )
EndFunction


' menus

Rem
bbdoc: Creates a new menu item.
about: Menu gadgets should be attached to either a #WindowMenu, other Menu gadgets
or used with the #PopupWindowMenu command. The tag field should be a unique identifier
that will be present in the #EventData field of EVENT_MENUACTION events.

Keyboard shortcuts can be associated with a Menu by using the optional hotKey and
modifier parameters.

Please refer to the #{key codes} module for valid key and modifier codes.
The MODIFIER_COMMAND value should be used instead of MODIFIER_CONTROL
with Menu hotkeys for best crossplatform compatability.

Menus now also support icons on most platforms through the use of #SetGadgetPixmap.

See Also: #FreeMenu, #SetMenuText, #CheckMenu, #UncheckMenu, #EnableMenu, #DisableMenu,
#MenuText, #MenuChecked, #MenuEnabled and #SetGadgetPixmap.
EndRem
Function CreateMenu:TGadget( Text$,tag,parent:TGadget,hotkey=0,modifier=0 )
	Local gadget:TGadget=maxgui_driver.CreateGadget(GADGET_MENUITEM,Text,0,0,0,0,GetGroup(parent),tag)
	If gadget And hotKey SetGadgetHotKey gadget,hotKey,modifier
	Return gadget
End Function

Rem
bbdoc: Remove a menu.
about: This function has been superseded by #FreeGadget, but is available for backwards compatability.
EndRem
Function FreeMenu( menu:TGadget )
	menu.CleanUp()
End Function

Rem
bbdoc: Modify a menu's text.
about: This function has been superseded by #SetGadgetText, but is available for backwards compatability.
EndRem
Function SetMenuText( menu:TGadget,Text$ )
	SetGadgetText( menu, Text )
End Function

Rem
bbdoc: Set a menu's checked state.
about: #UpdateWindowMenu should be called where appropriate after changing a menu's state for the changes
to become visible.
EndRem
Function CheckMenu( menu:TGadget )
	menu.SetSelected True
End Function

Rem
bbdoc: Clear a menu's checked state.
about: #UpdateWindowMenu should be called where appropriate after changing a menu's state for the changes
to become visible.
EndRem
Function UncheckMenu( menu:TGadget )
	menu.SetSelected False
End Function

Rem
bbdoc: Enable a menu for selection.
about: #UpdateWindowMenu should be called where appropriate after changing a menu's status for the changes
to become visible.
EndRem
Function EnableMenu( menu:TGadget )
	menu.SetEnabled True
End Function

Rem
bbdoc: Disable a menu so it cannot be selected.
about: #UpdateWindowMenu should be called where appropriate after changing a menu's status for the changes
to become visible.
EndRem
Function DisableMenu( menu:TGadget )
	menu.SetEnabled False
End Function

Rem
bbdoc: Return a menu's text.
about: This function has been superseded by #GadgetText, but is available for backwards compatability.
EndRem
Function MenuText$( menu:TGadget )
	Return menu.GetText()
End Function

Rem
bbdoc: Return a menu's checked state.
EndRem
Function MenuChecked( menu:TGadget )
	Return (menu.State()&STATE_SELECTED)<>0
End Function

Rem
bbdoc: Return a menu's enabled state.
EndRem
Function MenuEnabled( menu:TGadget )
	Return Not (menu.State()&STATE_DISABLED)
End Function

' desktop

Rem
bbdoc: Return a gadget representing the system's desktop.
about: This is particularly useful for finding the resolution of the desktop using #GadgetWidth / #ClientWidth or #GadgetHeight / #ClientHeight.
EndRem
Function Desktop:TGadget()
	Return maxgui_driver.CreateGadget(GADGET_DESKTOP,"",0,0,0,0,Null,0)
End Function

' window

Rem
bbdoc: Create a Window gadget.
about:
A Window is the primary gadget of MaxGUI. Windows should be used as the primary
group gadgets in MaxGUI applications to contain the gadgets that make up the program's
user interface.

The following style flags are supported when creating a Window. Any of the
style flags can be combined using the bitwise operator '|'.

[ @Style | @Meaning
* WINDOW_TITLEBAR | The Window has a titlebar that displays the @titletext$.
* WINDOW_RESIZABLE | The Window can be resized by the user.
* WINDOW_MENU | The Window has an associated window menu (retrieve menu handle using #WindowMenu).
* WINDOW_STATUS | The Window has a statusbar.
* WINDOW_TOOL | A window style commonly used for toolbars and other tool windows.
* WINDOW_CLIENTCOORDS | The dimensions specified relate to the client area as opposed to the window frame.
* WINDOW_CENTER | The x and y parameters are ignored, and the Window is positioned either in the middle of the screen or the middle of the parent gadget.
* WINDOW_HIDDEN | The Window is created in a hidden state and can be revealed later using #ShowGadget.
* WINDOW_ACCEPTFILES | Enable file drag and drop operations (emits the EVENT_WINDOWACCEPT events).
]

Note: For cross-platform projects, it is highly recommended that the WINDOW_CLIENTCOORDS style is used to maintain
similar layouts with different operating systems and window managers.

The default window style (WINDOW_DEFAULT) is equivalent to WINDOW_TITLEBAR | WINDOW_RESIZABLE | WINDOW_MENU | WINDOW_STATUS.

A Window emits the following events:

[ @{Event ID} | @Description
* EVENT_WINDOWMOVE | Window has been moved.
* EVENT_WINDOWSIZE | Window has been resized.
* EVENT_WINDOWCLOSE | Window close icon clicked.
* EVENT_WINDOWACTIVATE | Window has been activated.
* EVENT_WINDOWACCEPT | A file was dropped onto a Window with the WINDOW_ACCEPTFILES style. The event @Extra object holds the filepath.
]

See Also: #WindowMenu, #UpdateWindowMenu, #PopupWindowMenu, #ActivateWindow, #SetStatusText, #WindowStatusText, 
#SetMinWindowSize, #SetMaxWindowSize, #MinimizeWindow, #MaximizeWindow, #RestoreWindow, #WindowMinimized
and #WindowMaximized.
EndRem
Function CreateWindow:TGadget( titletext$,x,y,w,h,group:TGadget=Null,style=WINDOW_DEFAULT )
	If (style&WINDOW_CENTER) Then
		If group Then
			x = GadgetX(group) + (GadgetWidth(group)-w)/2
			y = GadgetY(group) + (GadgetHeight(group)-h)/2
		Else
			x = (Min(GadgetWidth(Desktop()), ClientWidth(Desktop()))-w)/2
			y = (Min(GadgetHeight(Desktop()), ClientHeight(Desktop()))-h)/2
		EndIf
	EndIf
	Return maxgui_driver.CreateGadget(GADGET_WINDOW,titletext,x,y,w,h,GetGroup(group),style)
End Function

Rem
bbdoc: Returns a window's main-menu handle.
about: Required when a root menu is to be added to a window using #CreateMenu. This function
should %not be used for sub-menus - the sub-menu should be parented directly to its parent menu.

It should also be mentioned that this function isn't required when creating popup menus - #Null should
instead be passed as the parent of the root menu.

To avoid any unexpected behavior, make sure that the window specified was created with the WINDOW_MENU
style flag.

See Also: #CreateMenu and #UpdateWindowMenu
EndRem
Function WindowMenu:TGadget( window:TGadget )
	Return window.GetMenu()
End Function

Rem
bbdoc: Update a window's menu hierachy.
about: Required after changing a window's menu properties/structure for the changes to become visible.

To avoid any unexpected behavior, make sure that the window specified was created with the WINDOW_MENU
style flag.

See Also: #WindowMenu and #CreateMenu
EndRem
Function UpdateWindowMenu( window:TGadget )
	window.UpdateMenu()
End Function

Rem
bbdoc: Display a popup menu.
about: A popup context-menu is displayed on the screen at the user's current mouse position.
See Also: #CreateMenu
EndRem
Function PopupWindowMenu( window:TGadget,menu:TGadget,extra:Object=Null )
	window.PopupMenu(menu,extra)
End Function

Rem
bbdoc: Activate a window gadget.
about: This function has been superseded by #ActivateGadget, but is available for backwards compatability.
EndRem
Function ActivateWindow( window:TGadget )
	window.Activate ACTIVATE_FOCUS
End Function

Rem
bbdoc: Retrieve a window's status-bar text.
about: Can only be used with windows created with the WINDOW_STATUS flag (see #CreateWindow). Tab characters
delimit between the three alignments of text.  See #SetStatusText for more information.
EndRem
Function WindowStatusText$( window:TGadget )
	Return window.GetStatusText()
End Function

Rem
bbdoc: Set a window's status bar text.
about: Can only be used with windows created with the WINDOW_STATUS flag (see #CreateWindow). Use tab characters
to delimit between the three alignments of text.  For example:

{{
SetStatusText( window, "Left Aligned Only" )
SetStatusText( window, "Left Aligned~tCenter Aligned~tRight Aligned" )
SetStatusText( window, "~tCenter Aligned Only" )
SetStatusText( window, "~t~tRight Aligned Only" )
}}

See Also: #WindowStatusText
EndRem
Function SetStatusText( window:TGadget,Text$ )
	window.SetStatusText Text
End Function

Rem
bbdoc: Set a window's minimum size.
about: Only useful for resizable windows (i.e. windows created with the WINDOW_RESIZABLE flag, see #CreateWindow).
EndRem
Function SetMinWindowSize( window:TGadget,w,h )
	window.SetMinimumSize( w,h )
End Function

Rem
bbdoc: Set a window's maximum size.
about: Only useful for resizable windows (i.e. windows created with the WINDOW_RESIZABLE flag, see #CreateWindow).

Calling this function will disable the Maximize button window hint on Windows, and will limit the window zoom size on Mac OS X.
EndRem
Function SetMaxWindowSize( window:TGadget,w,h )
	window.SetMaximumSize( w,h )
End Function

Rem
bbdoc: Minimize a window.
about: A minimized window can be restored by the user to its previous state, typically by clicking on the icon representation
of the window in the taskbar or dock.  The same effect can be obtained programatically by calling #RestoreWindow.

See Also: #WindowMinimized.
EndRem
Function MinimizeWindow( window:TGadget )
	window.Activate ACTIVATE_MINIMIZE
End Function

Rem
bbdoc: Maximize a window.
about:
Maximizing a window makes the window visible and sizes it to fill the current desktop.  #RestoreWindow can be used to
programatically restore a window to its previous unmaximized state, although the window will still remain unhidden.

See Also: #WindowMaximized.
EndRem
Function MaximizeWindow( window:TGadget )
	window.Activate ACTIVATE_MAXIMIZE
End Function

Rem
bbdoc: Restore a window from a minimized or maximized state.
about: See Also: #MinimizeWindow and #MaximizeWindow.
EndRem
Function RestoreWindow( window:TGadget )
	window.Activate ACTIVATE_RESTORE
End Function

Rem
bbdoc: Detect if a window is minimized.
returns: #True if the window is currently minimized, #False if not.
EndRem
Function WindowMinimized( window:TGadget )
	Return (window.State()&STATE_MINIMIZED)<>0
End Function

Rem
bbdoc: Detect if a window is maximized.
returns: #True if the window is currently maximized, #False if not.
about: A maximized window fills the entire desktop. A window may
be maximized with the #MaximizeWindow command or by the user if
#CreateWindow was called with the WINDOW_RESIZABLE flag.
EndRem
Function WindowMaximized( window:TGadget )
	Return (window.State()&STATE_MAXIMIZED)<>0
End Function

' button

Rem
bbdoc: Create a Button gadget.
about:
A Button generates an EVENT_GADGETACTION #TEvent whenever it is pushed.

[ @Style | @Meaning
* BUTTON_PUSH | Standard push button.
* BUTTON_CHECKBOX | A check box button that displays a tick when its state is #True.
* BUTTON_RADIO | A radio button is accompanied by a small circular indicator, filled when its state is #True.
* BUTTON_OK | Standard push button that is also activated when the user presses the RETURN key.
* BUTTON_CANCEL | Standard push button that is also activated when the user presses the ESCAPE key.
]

On certain platforms, the BUTTON_PUSH flag can be combined with either BUTTON_CHECKBOX or BUTTON_RADIO to obtain
a button looking similar to standard push-buttons, but mimicking the behaviour of the checkbox or radio button.

See Also: #SetGadgetText, #SetButtonState, #ButtonState and #SetGadgetPixmap.
EndRem
Function CreateButton:TGadget(label$,x,y,w,h,group:TGadget,style=BUTTON_PUSH)
	Return maxgui_driver.CreateGadget(GADGET_BUTTON,label,x,y,w,h,GetGroup(group),style)
End Function

Rem
bbdoc: Set a button's state.
about:
Buttons created with the BUTTON_CHECKBOX and BUTTON_RADIO styles are able to show a selected state.
In addition, the BUTTON_CHECKBOX style may also be able to distinguish an indeterminate state from that
of a checked state through the use of the CHECK_INDETERMINATE (-1) constant, depending on the platform.

See Also: #CreateButton, #SetGadgetText, #ButtonState and #SetGadgetPixmap.
EndRem
Function SetButtonState( button:TGadget,checked )
	button.SetSelected checked
End Function

Rem
bbdoc: Retrieve a button's state.
about:
Returns a non-zero value if a checkbox or radio button is selected or false if it isn't.
On certain platforms, if a checkbox is set using #SetButtonState to have an indeterminant
state (CHECK_INDETERMINATE), then this function will return CHECK_INDETERMINATE too.
See Also: #CreateButton, #SetGadgetText, #SetButtonState and #SetGadgetPixmap.
EndRem
Function ButtonState( button:TGadget )
	Local tmpResult% = button.State()&STATE_INDETERMINATE
	If (tmpResult&~STATE_SELECTED) Then Return -1 Else Return (tmpResult <> 0)
End Function

' panel

Rem
bbdoc: Create a Panel gadget.
about:
A Panel is a general purpose gadget that can be used to group other gadgets.

Background colours and images can be set using #SetGadgetColor and #SetPanelPixmap.

A panel can be created with any one of the following %optional styles:

[ @Style | @Meaning
* PANEL_SUNKEN | Panel is drawn with a sunken border (or just a simple border on OS X).
* PANEL_RAISED | Panel is drawn with a raised border (or just a simple border on OS X).
* PANEL_GROUP | Panel is drawn with a titled etched border.
]

The PANEL_ACTIVE flag can be combined with any other style flags, or specified on its own,
to generate mouse and key events (equivalent to calling #SetGadgetSensitivity immediately
after creation):

[ @{Event ID} | @Description
* EVENT_MOUSEDOWN | Mouse button pressed. Event data contains mouse button code.
* EVENT_MOUSEUP | Mouse button released. Event data contains mouse button code.
* EVENT_MOUSEMOVE | Mouse moved. Event x and y contain mouse coordinates.
* EVENT_MOUSEWHEEL | Mouse wheel spun. Event data contains delta clicks.
* EVENT_MOUSEENTER | Mouse entered gadget area.
* EVENT_MOUSELEAVE | Mouse left gadget area.
* EVENT_KEYDOWN | Key pressed. Event data contains keycode.
* EVENT_KEYUP | Key released. Event data contains keycode.
* EVENT_KEYCHAR | Key character. Event data contains unicode value.
]

%{Note: The PANEL_SUNKEN / PANEL_RAISED style flags cannot be used with PANEL_GROUP.}

See Also: #SetPanelColor and #SetPanelPixmap.
EndRem
Function CreatePanel:TGadget(x,y,w,h,group:TGadget,style=0,title$="")
	Return maxgui_driver.CreateGadget(GADGET_PANEL,title,x,y,w,h,GetGroup(group),style)
End Function

Rem
bbdoc: Set the color of a Panel.
about: This function has been superseded by #SetGadgetColor, but is available for backwards compatability.
See Also: #CreatePanel and #SetPanelPixmap
EndRem
Function SetPanelColor( panel:TGadget,r,g,b )
	panel.SetColor(r,g,b)
End Function

Rem
bbdoc: Set panel's background image to a pixmap.
about: This function has been superseded by #SetGadgetPixmap, but is available for backwards compatability.

[ @Flags | @Description
* PANELPIXMAP_TILE | The panel is filled with repeating tiles.
* PANELPIXMAP_CENTER | The pixmap is positioned at the center of the panel.
* PANELPIXMAP_FIT | The pixmap is scaled to best fit the panel size.
* PANELPIXMAP_FIT2 | A variant of PANELPIXMAP_FIT where clipping can occur to achieve a better fit.
* PANELPIXMAP_STRETCH | The pixmap is stretched to fit the entire panel.
]

The function can be passed 'Null' as the parameter for @pixmap, in which case the pixmap should be removed.

See Also: #CreatePanel and #SetPanelColor
EndRem
Function SetPanelPixmap( panel:TGadget,pixmap:TPixmap,flags=PANELPIXMAP_TILE)
	Return SetGadgetPixmap( panel,pixmap,flags)
End Function

' textfield

Rem
bbdoc: Create a TextField gadget.
about: A TextField is a single line text entry gadget and currently has only one style flag:

[ @Flags | @Description
* TEXTFIELD_PASSWORD | Masks characters being typed as a string as asterisks.
]

Irrespective of the flag used, the TextField gadget will emit the following event(s):

[ @{Event ID} | @Description
* EVENT_GADGETACTION | The user has edited the text in the TextField.
]

It is also possible to validate any typed input before it reaches the TextArea using
the #SetGadgetFilter command.

See Also: #GadgetText, #SetGadgetText, #SetGadgetFilter.
EndRem
Function CreateTextField:TGadget(x,y,w,h,group:TGadget,style=0)
	Return maxgui_driver.CreateGadget(GADGET_TEXTFIELD,"",x,y,w,h,GetGroup(group),style)
End Function

Rem
bbdoc: Get the current text in a TextField gadget.
about: This function has been superseded by #GadgetText, but is available for backwards compatability.
See Also: #CreateTextField and #SetGadgetText
EndRem
Function TextFieldText$( textfield:TGadget )
	Return textfield.GetText()
End Function

' textarea

Rem
bbdoc: Create a TextArea gadget.
about:
A TextArea gadget is a multiline text editor with commands that allow control
over the contents, style and selection of the text it contains.

A TextArea gadget may have the following optional styles:

[ @Style | @Meaning
* TEXTAREA_WORDWRAP | Long lines of text 'wrap round' onto the next lines.
* TEXTAREA_READONLY | The text cannot be edited by the user.
]

A TextArea gadget can generate the following events:

[ @{Event ID} | @Description
* EVENT_GADGETACTION | The user has modified the text in a TextArea.
* EVENT_GADGETSELECT | The text-cursor has moved or a selection of text is made by the user.
* EVENT_GADGETMENU | The user has right-clicked somewhere in the TextArea.
]

It is also possible to validate any typed input before it reaches the TextArea using
the #SetGadgetFilter command.

See Also: #SetTextAreaText, #AddTextAreaText, #TextAreaText, #TextAreaLen, #LockTextArea,
#UnlockTextArea, #SetTextAreaTabs, #SetGadgetFont, #SetGadgetColor, #TextAreaCursor,
#TextAreaSelLen, #FormatTextAreaText, #SelectTextAreaText, #TextAreaChar, #TextAreaLine,
#TextAreaCharX and #TextAreaCharY.
EndRem
Function CreateTextArea:TGadget(x,y,w,h,group:TGadget,style=0)
	Return maxgui_driver.CreateGadget(GADGET_TEXTAREA,"",x,y,w,h,GetGroup(group),style)
End Function

Rem
bbdoc: Set the contents of a TextArea gadget.
about:
See Also: #CreateTextArea, #AddTextAreaText and #SetGadgetText
EndRem
Function SetTextAreaText( textarea:TGadget,Text$,pos=0,length=TEXTAREA_ALL,units=TEXTAREA_CHARS )
	textarea.ReplaceText(pos,length,Text,units)
End Function

Rem
bbdoc: Append text to the contents of a TextArea gadget.
about:
See Also: #CreateTextArea, #SetTextAreaText and #SetGadgetText
EndRem
Function AddTextAreaText( textarea:TGadget,Text$ )
	textarea.AddText(Text)
End Function

Rem
bbdoc: Get the contents of a TextArea gadget.
about:
See Also: #CreateTextArea, #AddTextAreaText, #SetTextAreaText and #SetGadgetText
EndRem
Function TextAreaText$( textarea:TGadget,pos=0,length=TEXTAREA_ALL,units=TEXTAREA_CHARS )
	Return textarea.AreaText(pos,length,units)
End Function

Rem
bbdoc: Get the number of characters in a TextArea gadget.
about:
See Also: #CreateTextArea
EndRem
Function TextAreaLen( textarea:TGadget,units=TEXTAREA_CHARS )
	Return textarea.AreaLen(units)
End Function

Rem
bbdoc: Lock a TextArea gadget for improved performance when formatting.
about:
See Also: #UnlockTextArea and #CreateTextArea
EndRem
Function LockTextArea( textarea:TGadget )
	textarea.locktext
End Function

Rem
bbdoc: Unlock a previously locked TextArea gadget.
about:
See Also: #LockTextArea and #CreateTextArea
EndRem
Function UnlockTextArea( textarea:TGadget )
	textarea.unlocktext
End Function

Rem
bbdoc: Set the tab stops of a TextArea gadget measured in pixels.
about:
See Also: #CreateTextArea #SetIndents
EndRem
Function SetTextAreaTabs( textarea:TGadget,tabwidth )
	textarea.SetTabs tabwidth
End Function

Rem
bbdoc: Set left margin of a TextArea measured in pixels.
about:
See Also: #CreateTextArea and #SetTextAreaTabs
EndRem
Function SetMargins( textarea:TGadget,leftmargin )
	textarea.SetMargins leftmargin
End Function


Rem
bbdoc: Set the font of a TextArea gadget.
about: This function has been superseded by #SetGadgetFont, but is available for backwards compatability.
See Also: #CreateTextArea
EndRem
Function SetTextAreaFont( textarea:TGadget,font:TGuiFont )
	textarea.SetFont font
End Function

Rem
bbdoc: Set the background or foreground colors of a TextArea gadget.
about: This function has been superseded by #SetGadgetColor, but is available for backwards compatability.
See Also: #CreateTextArea
EndRem
Function SetTextAreaColor( textarea:TGadget,r,g,b,bg=False )
	If bg
		textarea.SetColor r,g,b
	Else
		textarea.SetTextColor r,g,b
	EndIf
End Function

Rem
bbdoc: Find the position of the cursor in a TextArea gadget.
about:
Use the default TEXTAREA_CHARS units argument to find out which character
(column) in the line the cursor is on and use TEXTAREA_LINES to find out
which line (row) the cursor is on.

See Also: #TextAreaSelLen and #CreateTextArea
EndRem
Function TextAreaCursor( textarea:TGadget,units=TEXTAREA_CHARS )
	Return textarea.GetCursorPos(units)
End Function

Rem
bbdoc: Find the size of the selected text in a TextArea gadget.
about:
The TEXTAREA_CHARS option returns the number of characters currently
highlighted by the user where as TEXTAREA_LINES will specify the
function returns the number of lines selected.

See Also: #TextAreaCursor and #CreateTextArea
EndRem
Function TextAreaSelLen( textarea:TGadget,units=TEXTAREA_CHARS )
	Return textarea.GetSelectionLength( units )
End Function

Rem
bbdoc: Format the color and style of some text in a TextArea gadget.
about:
The @r, @g and @b parameters represent the @{r}ed, @{g}reen and @{b}lue components (0..255)
which, when combined, represent the new text color for the the sepecified region
of characters.

The @flags parameter can be a combination of the following values:

[ @Constant | @Meaning
* TEXTFORMAT_BOLD | Bold
* TEXTFORMAT_ITALIC | Italic
* TEXTFORMAT_UNDERLINE | Underline
* TEXTFORMAT_STRIKETHROUGH | StrikeThrough
]

Depending on the value of the units parameter the position and length parameters specify
the character position and number of characters or the starting line and the number
of lines that FormatTextAreaText will modify.

See Also: #LockTextArea and #CreateTextArea
EndRem
Function FormatTextAreaText( textarea:TGadget,r,g,b,flags,pos=0,length=TEXTAREA_ALL,units=TEXTAREA_CHARS )
	textarea.SetStyle(r,g,b,flags,pos,length,units)	
End Function

Rem
bbdoc: Select a range of text in a TextArea gadget.
about:
Depending on the value of the units the position and length parameters specify
the character position and number of characters or the starting line and the number
of lines that SelextTextAreaText will highlight.

See Also: #TextAreaCursor, #TextAreaSelLen and #CreateTextArea
EndRem
Function SelectTextAreaText( textarea:TGadget,pos=0,length=TEXTAREA_ALL,units=TEXTAREA_CHARS )
	textarea.SetSelection(pos,length,units)	
End Function

Rem
bbdoc: Find the character position of a given line in a TextArea gadget.
endrem
Function TextAreaChar( textarea:TGadget,Line )
	Return textarea.CharAt(Line)
End Function

Rem
bbdoc: Find the line of a given character position in a TextArea gadget.
endrem
Function TextAreaLine( textarea:TGadget,index )
	Return textarea.LineAt(index)
End Function

Rem
bbdoc: Find the x-coordinate of a textarea character position, relative to the upper left corner of the gadget.
about: The returned value may be greater than the width of the gadget (or even negative) if the specified character
index is positioned outside the immediately visible area of a scrollable TextArea.
EndRem
Function TextAreaCharX( textarea:TGadget, char )
	Return textarea.CharX(char)
End Function

Rem
bbdoc: Find the y-coordinate of a textarea character position, relative to the upper left corner of the gadget.
about: The returned value may be greater than the height of the gadget (or even negative) if the specified character
index is positioned outside the immediately visible area of a scrollable TextArea.
EndRem
Function TextAreaCharY( textarea:TGadget, char )
	Return textarea.CharY(char)
End Function

' gadget lists

Rem
bbdoc: Create a ComboBox gadget.
about:
A ComboBox gadget provides a dropdown list of items to the user.

The ComboBox supports the following styles:

[ @Style | @Meaning
* COMBOBOX_EDITABLE | Allows the ComboBox to behave similar to a TextField, by allowing typed user input also.
]

And emits the following events:

[ @{Event ID} | @Description
* EVENT_GADGETACTION | The selection has been cleared, or the text has changed.
]

See Also: #AddGadgetItem, #ClearGadgetItems, #ModifyGadgetItem, #SelectGadgetItem,
#RemoveGadgetItem, #SelectedGadgetItem and #SetGadgetIconStrip.
EndRem
Function CreateComboBox:TGadget(x,y,w,h,group:TGadget,style=0)
	Return maxgui_driver.CreateGadget(GADGET_COMBOBOX,"",x,y,w,h,GetGroup(group),style)
End Function

Rem
bbdoc: Create a ListBox gadget.
about:
A ListBox gadget displays a scrollable list of items and generates the following events:

[ @{Event ID} | @Description
* EVENT_GADGETSELECT | An item has been selected, or the selection has been cleared.
* EVENT_GADGETACTION | An item has been double-clicked.
* EVENT_GADGETMENU | The user has right-clicked somewhere in the listbox.
]

See Also: #AddGadgetItem, #ClearGadgetItems, #ModifyGadgetItem, #SelectGadgetItem,
#RemoveGadgetItem, #SelectedGadgetItem, #SelectedGadgetItems and #SetGadgetIconStrip.
EndRem
Function CreateListBox:TGadget(x,y,w,h,group:TGadget,style=0)
	Return maxgui_driver.CreateGadget(GADGET_LISTBOX,"",x,y,w,h,GetGroup(group),style)
End Function

Rem
bbdoc: Create a Tabber gadget.
about:
A Tabber gadget shows a list of tabs above a client area, typically used for
handling multiple documents/panels.

[ @{Event ID} | @Description
* EVENT_GADGETACTION | A new tab has been selected. Event data contains the tab index.
* EVENT_GADGETMENU | A tab has been right-clicked. Event data contains the tab index.
]

Event extra for both events point to the #GadgetItemExtra object set for the corresponding tab item index in the latest call
to #AddGadgetItem / #InsertGadgetItem or #ModifyGadgetItem.

It is important to note also that, similar to #SelectedGadgetItem, either event may be emitted with the event
data set to '-1'. This either means that somehow the user has deselected a tab, or that the user
has right-clicked on an area of the tabber which doesn't represent a particular tab item index. As
such, your MaxGUI applications should check the value before proceeding to use it with any of the
standard #GadgetItemText, #GadgetItemExtra etc. commands.

See Also: #AddGadgetItem, #ClearGadgetItems, #ModifyGadgetItem, #SelectGadgetItem,
#RemoveGadgetItem, #SelectedGadgetItem and #SetGadgetIconStrip.
EndRem
Function CreateTabber:TGadget(x,y,w,h,group:TGadget,style=0)
	Return maxgui_driver.CreateGadget(GADGET_TABBER,"",x,y,w,h,GetGroup(group),style)
End Function

Rem
bbdoc: Remove all items added to a list based gadget.
about:
See Also: #CreateComboBox, #CreateListBox, #CreateToolbar and #CreateTabber
EndRem
Function ClearGadgetItems(gadget:TGadget)
	gadget.Clear()
End Function

Rem
bbdoc: Add an item to a list based gadget.
about:
An item can be added to the ComboBox, ListBox, Tabber and Toolbar list based gadgets.

Its @text parameter is used as its label.

The @flags parameter can be a combination of the following values:

[ @Flag | @Meaning
* GADGETITEM_NORMAL | A plain gadget item.
* GADGETITEM_DEFAULT | The item defaults to a selected state.
* GADGETITEM_TOGGLE | The item alternates between selected states when pressed.
* GADGETITEM_LOCALIZED | The item text and tooltip are localization strings.
]

The @tip$ parameter attaches an optional tooltip to the item.

The optional @icon parameter specifies an icon from the gadget's IconStrip (see #SetGadgetIconStrip).

The @extra parameter is supplied in the EventExtra field of any Event generated by the Item.

See Also: #InsertGadgetItem, #CreateComboBox, #CreateListBox, #CreateTabber, #CreateToolbar and #SetGadgetIconStrip.
EndRem
Function AddGadgetItem(gadget:TGadget,Text$,flags=0,icon=-1,tip$="",extra:Object=Null)
	gadget.InsertItem(gadget.ItemCount(),Text,tip,icon,extra,flags)
End Function

Rem
bbdoc: Inserts an item in a list based gadget at the specified index.
about:
An item can be inserted in a ComboBox, ListBox, Tabber and Toolbar list based gadgets.

See #AddGadgetItem for a description of the parameters.

See Also: #CreateComboBox, #CreateListBox, #CreateTabber and #CreateToolbar
EndRem
Function InsertGadgetItem(gadget:TGadget,index,Text$,flags=0,icon=-1,tip$="",extra:Object=Null)
	gadget.InsertItem(index,Text,tip,icon,extra,flags)
End Function

Rem
bbdoc: Modify the properties of a gadget-item.
about:
See #AddGadgetItem for a description of the parameters.

See Also: #CreateComboBox, #CreateListBox, #CreateTabber and #CreateToolbar
EndRem
Function ModifyGadgetItem( gadget:TGadget,index,Text$,flags=0,icon=-1,tip$="",extra:Object=Null )
	gadget.SetItem(index,Text,tip,icon,extra,flags)
End Function

Rem
bbdoc: Remove a gadget-item from a list based gadget.
about:
See Also: #CreateComboBox, #CreateListBox, #CreateTabber and #CreateToolbar
EndRem
Function RemoveGadgetItem( gadget:TGadget,index )
	gadget.RemoveItem index
End Function

Rem
bbdoc: Enable a particular item in a list based gadget.
about: Typically, this can only be used on toolbars.
See Also: #CreateToolbar
EndRem
Function EnableGadgetItem( gadget:TGadget,index )
	Local state=gadget.ItemState(index)&~STATE_DISABLED
	gadget.SetItemState(index,state)
End Function

Rem
bbdoc: Disable a particular item in a list based gadget.
about: Typically, this can only be used on toolbars.
See Also: #CreateToolbar
EndRem
Function DisableGadgetItem( gadget:TGadget,index )
	Local state=gadget.ItemState(index)|STATE_DISABLED
	gadget.SetItemState(index,state)
End Function

Rem
bbdoc: Select an item in a list based gadget.
about:
See Also: #DeselectGadgetItem, #ToggleGadgetItem, #CreateComboBox, #CreateListBox, #CreateToolbar and #CreateTabber
EndRem
Function SelectGadgetItem(gadget:TGadget,index)
	gadget.SelectItem(index,1)
End Function

Rem
bbdoc: Deselect an item in a list based gadget.
about:
See Also: #SelectGadgetItem, #ToggleGadgetItem, #CreateComboBox, #CreateListBox, #CreateToolbar and #CreateTabber
EndRem
Function DeselectGadgetItem(gadget:TGadget,index)
	gadget.SelectItem(index,0)
End Function

Rem
bbdoc: Invert the selected state of an item in a list based gadget.
about:
See Also: #SelectGadgetItem, #DeselectGadgetItem and #CreateToolbar
EndRem
Function ToggleGadgetItem(gadget:TGadget,index)
	gadget.SelectItem(index,2)
End Function


Rem
bbdoc: Get the index of the first selected item in a list based gadget.
about:
SelectedGadgetItem will return -1 if the list based gadget has no selected items.

See Also: #CreateComboBox, #CreateListBox and #CreateTabber
EndRem
Function SelectedGadgetItem(gadget:TGadget)
	Return gadget.SelectedItem()
End Function

Rem
bbdoc: Returns an integer array of the selected item indexes in a list based gadget.
about:
See Also: #CreateComboBox, #CreateListBox and #CreateTabber
EndRem
Function SelectedGadgetItems[](gadget:TGadget)
	Return gadget.SelectedItems()
End Function

Rem
bbdoc: Get the number of items in a list based gadget.
about:
See Also: #CreateComboBox, #CreateListBox, #CreateTabber and #CreateToolbar
EndRem
Function CountGadgetItems( gadget:TGadget )
	Return gadget.ItemCount()
End Function

Rem
bbdoc: Get the text of a given item in a list based gadget.
about:
See Also: #CreateComboBox, #CreateListBox, #CreateToolbar and #CreateTabber
EndRem
Function GadgetItemText$( gadget:TGadget,index )
	Return gadget.ItemText(index)
End Function

Rem
bbdoc: Get the tooltip of a given item in a list based gadget.
about:
See Also: #CreateComboBox, #CreateListBox, #CreateToolbar and #CreateTabber
EndRem
Function GadgetItemTooltip$( gadget:TGadget,index )
	Return gadget.ItemTip(index)
End Function

Rem
bbdoc: Get the icon of a given item in a list based gadget.
about:
See Also: #CreateComboBox, #CreateListBox, #CreateToolbar and #CreateTabber
EndRem
Function GadgetItemIcon( gadget:TGadget,index )
	Return gadget.ItemIcon(index)
End Function

Rem
bbdoc: Get the extra data of a given item in a list based gadget.
about:
See Also: #CreateComboBox, #CreateListBox, #CreateToolbar and #CreateTabber
EndRem
Function GadgetItemExtra:Object( gadget:TGadget,index )
	Return gadget.ItemExtra(index)
End Function

Rem
bbdoc: Get the flags parameter of a given item in a list based gadget.
about:
See Also: #AddGadgetItem
EndRem
Function GadgetItemFlags( gadget:TGadget,index )
	Return gadget.ItemFlags(index)
End Function



' toolbar

Rem
bbdoc: Creates a window toolbar.
about:
A Toolbar is created from an iconstrip - an image that contains a row of equally shaped icons.
Any images in the row left blank are treated as Toolbar separators.

Toolbars are positioned along the top of the @window and either the client-area and/or window frame will be
resized so that the client area of the window will begin just below the toolbar.

At present, MaxGUI windows only support one toolbar at a time.

A Toolbar generates the following events:

[ @{Event ID} | @Description
* EVENT_GADGETACTION | A toolbar item has been selected/clicked. Event data contains the item index.
]

The @source parameter can be a previously loaded @TIconStrip, a #TPixmap or a URL to an image
file which @CreateToolBar will attempt to load an icon-strip from automatically.

The recommended icon size is 24x24 pixels which seems to work well on most platforms. Using a
different icon size may result in the pixmaps being scaled before being set depending on the OS.

The @x, @y, @w, @h parameters are all ignored and are simply there to make the CreateToolbar() system call
consistent with the other @{CreateGadget()} calls.

The toolbar can be alterted during runtime using the #ClearGadgetItems, #InsertGadgetItem, #ModifyGadgetItem etc.
functions.  Use the GADGETICON_SEPARATOR constant as an item's icon if you want it to be a separator, or
GADGETICON_BLANK if you would like a blank square icon instead.

%{IMPORTANT: Toolbars should only be parented to window gadgets.  Parenting a toolbar to a panel is not
officially supported - users are strongly advised to instead use push-buttons with pixmap icons set.  Debug builds
will output a warning message to standard error if toolbars are parented otherwise.}

See Also: #AddGadgetItem, #EnableGadgetItem, #DisableGadgetItem and #SetToolbarTips.
EndRem
Function CreateToolbar:TGadget(source:Object,x,y,w,h,window:TGadget,style=0)
	Local flags:Int = 0
	Local iconstrip:TIconStrip = TIconStrip(source)
	?Debug
	If window.Class() <> GADGET_WINDOW Then
		DebugLog "WARNING: Toolbars should *only* be parented to window gadgets."
	EndIf
	?
	Local toolbar:TGadget = maxgui_driver.CreateGadget(GADGET_TOOLBAR,"",x,y,w,h,window,style)
	If toolbar
		If Not iconstrip Then iconstrip = LoadIconStrip(source)
		If (LocalizationMode()&LOCALIZATION_OVERRIDE) Then flags:|GADGETITEM_LOCALIZED
		If iconstrip
			toolbar.SetIconStrip iconstrip
			For Local icon=0 Until iconstrip.count
				AddGadgetItem toolbar,"",flags,icon
			Next
		EndIf
	EndIf
	Return toolbar
End Function

Rem
bbdoc: Attach a list of tips to a Toolbar gadget.
about: Simply provides a quick way to set the tooltips of a toolbar's items after them being added.
See Also: #CreateToolbar
EndRem
Function SetToolbarTips( toolbar:TGadget,tips$[] )
	Local Text$,icon,extra:Object,flags,index
	For Local tip$ = EachIn tips
		Text=GadgetItemText(toolbar,index)
		icon=GadgetItemIcon(toolbar,index)
		extra=GadgetItemExtra(toolbar,index)
		flags=GadgetItemFlags(toolbar,index)
		ModifyGadgetItem toolbar,index,Text,flags,icon,tip,extra
		index:+1
	Next
End Function
'index,text$,icon=-1,tip$,extra:Object=Null

' treeview

Rem
bbdoc: Create a TreeView gadget.
about:
A TreeView provides a view of an expandable list of nodes populated with the
#AddTreeViewNode command. TreeView nodes can themselves contain nodes providing
a flexible method of displaying a hierachy of information.

[ @{Event ID} | @Description
* EVENT_GADGETSELECT | The user has selected a node.
* EVENT_GADGETACTION | The user has double-clicked a node.
* EVENT_GADGETOPEN | The user has expanded a node, revealing its children.
* EVENT_GADGETCLOSE | The user has collapsed a node, hiding its children.
* EVENT_GADGETMENU | The user has right-clicked somewhere in the TreeView.
]

Each event will have the containing TreeView gadget as the event source and the concerned
node gadget in the EventExtra field of the #TEvent.

See Also: #AddTreeViewNode, #InsertTreeViewNode, #ModifyTreeViewNode, #TreeViewRoot,
#SelectedTreeViewNode and #CountTreeViewNodes, #SelectTreeViewNode, #ExpandTreeViewNode,
#CollapseTreeViewNode and #FreeTreeViewNode.
EndRem
Function CreateTreeView:TGadget(x,y,w,h,group:TGadget,style=0)
	Return maxgui_driver.CreateGadget(GADGET_TREEVIEW,"",x,y,w,h,GetGroup(group),style)
End Function

Rem
bbdoc: Add a node to a TreeView gadget.
about: The optional @extra parameter is for convenience and is equivalent to calling 
#SetGadgetExtra immediately after the node is created.

See Also: #CreateTreeView, #InsertTreeViewNode
EndRem
Function AddTreeViewNode:TGadget( Text$,node:TGadget,icon=-1,extra:Object=Null )
	Local tmpNode:TGadget = node.InsertNode(-1,Text,icon)
	SetGadgetExtra tmpNode, extra
	Return tmpNode
End Function

Rem
bbdoc: Insert a node at a given index in a TreeView gadget.
about: The optional @extra parameter is for convenience and is equivalent to calling 
#SetGadgetExtra immediately after the node is created.

See Also: #CreateTreeView, #AddTreeViewNode
EndRem
Function InsertTreeViewNode:TGadget( index,Text$,node:TGadget,icon=-1,extra:Object=Null )
	Local tmpNode:TGadget = node.InsertNode(index,Text,icon)
	SetGadgetExtra tmpNode, extra
	Return tmpNode
End Function

Rem
bbdoc: Modify a node.
about:
See Also: #CreateTreeView
EndRem
Function ModifyTreeViewNode( node:TGadget,Text$,icon=-1 )
	node.ModifyNode Text,icon
End Function

Rem
bbdoc: Frees all the nodes of a TreeView.
about:
See Also: #CreateTreeView
EndRem
Function ClearTreeView( treeview:TGadget )
	For Local tmpNode:TGadget=EachIn treeview.RootNode().kids.Copy()
		FreeGadget(tmpNode)
	Next
End Function

Rem
bbdoc: Get the root node of a TreeView gadget.
about: This is required to parent the first nodes of a blank treeview to.

A treeview's root node can also be used to deselect any currently selected
nodes (see #SelectTreeViewNode for more information).

See Also: #CreateTreeView
EndRem
Function TreeViewRoot:TGadget( treeview:TGadget )
	Return treeview.RootNode()
End Function

Rem
bbdoc: Get the node currently selected in a TreeView gadget.
about: Will return #Null if there aren't any nodes currently selected.

See Also: #CreateTreeView, #SelectTreeViewNode
EndRem
Function SelectedTreeViewNode:TGadget( treeview:TGadget )
	Return treeview.SelectedNode()
End Function

Rem
bbdoc: Get the number of children of a Node gadget.
about:
See Also: #CreateTreeView
EndRem
Function CountTreeViewNodes( node:TGadget )
	Return node.CountKids()
End Function

Rem
bbdoc: Selects/highlights a treeview node.
about: It is possible to deselect a selection by selecting a treeview's root node.
For example:

{{
SelectTreeViewNode( TreeViewRoot( myTree ) )
}}

See Also: #CreateTreeView, #SelectedTreeViewNode
EndRem
Function SelectTreeViewNode( node:TGadget )
	node.Activate ACTIVATE_SELECT
End Function

Rem
bbdoc: Expands a treeview node in a TreeView gadget.
about:
See Also: #CreateTreeView, #CollapseTreeViewNode
EndRem
Function ExpandTreeViewNode( node:TGadget )
	node.Activate ACTIVATE_EXPAND
End Function

Rem
bbdoc: Collapses a treeview node in a TreeView gadget.
about:
See Also: #CreateTreeView, #ExpandTreeViewNode
EndRem
Function CollapseTreeViewNode( node:TGadget )
	node.Activate ACTIVATE_COLLAPSE
End Function

Rem
bbdoc: Removes a treeview node from a TreeView gadget.
about: This function has been superseded by #FreeGadget, but is available for backwards compatability.

See Also: #CreateTreeView
EndRem
Function FreeTreeViewNode( node:TGadget )
	node.CleanUp
End Function

' htmlview

Rem
bbdoc: Create an HTMLView gadget.
about:
The HTMLView is a complete web browser object inside a MaxGUI gadget. The HTML
page displayed is controlled with the #HTMLViewGo command or from the user navigating
from within the currently viewed page.

#CreateHTMLView supports the following styles:

[ @Style | @Meaning
* HTMLVIEW_NOCONTEXTMENU | The webpage's default context menu is disabled.
* HTMLVIEW_NONAVIGATE | User navigation is disabled and EVENT_GADGETACTION is generated instead.
]

[ @{Event ID} | @Description
* EVENT_GADGETDONE | Generated when a webpage has finished loading or a page anchor has been scrolled to.
* EVENT_GADGETACTION | Generated when a user clicks a link. Event Text contains the requested URL.
]

%{Note: EVENT_GADGETACTION requires the HTMLVIEW_NONAVIGATE style flag.}

See Also: #HtmlViewGo, #HtmlViewBack, #HtmlViewForward, #HtmlViewStatus and #HtmlViewCurrentURL.
EndRem
Function CreateHTMLView:TGadget(x,y,w,h,group:TGadget,style=0)
	Return maxgui_driver.CreateGadget(GADGET_HTMLVIEW,"",x,y,w,h,GetGroup(group),style)
End Function

Rem
bbdoc: Direct the HTMLView gadget to a new URL.
about:
See Also: #CreateHTMLView
EndRem
Function HtmlViewGo( view:TGadget,url$ )
	view.SetText url
End Function

Rem
bbdoc: Go back a page in an HTMLView gadget.
about:
See Also: #CreateHTMLView
EndRem
Function HtmlViewBack( view:TGadget )
	view.Activate ACTIVATE_BACK
End Function

Rem
bbdoc: Go forward a page in an HTMLView gadget.
about:
See Also: #CreateHTMLView
EndRem
Function HtmlViewForward( view:TGadget )
	view.Activate ACTIVATE_FORWARD
End Function

Rem
bbdoc: Get the status of an HTMLView gadget.
about:
See Also: #CreateHTMLView
EndRem
Function HtmlViewStatus( view:TGadget )
	Return view.State()
End Function

Rem
bbdoc: Get the current URL of an HTMLView gadget.
about:
See Also: #CreateHTMLView
EndRem
Function HtmlViewCurrentURL$( view:TGadget )
	Return view.GetText()
End Function

Rem
bbdoc: Run a script in an HTMLView gadget.
about:
See Also: #CreateHTMLView
EndRem
Function HtmlViewRun$( view:TGadget,script$ )
	Return view.Run(script)
End Function

' label

Rem
bbdoc: Create a Label gadget.
about:
A Label gadget is used to place static text or frames in a MaxGUI user interface. They do not
generate any events.

Labels support these optional styles:

[ @Style | @Meaning
* LABEL_FRAME | The label has a simple border.
* LABEL_SUNKENFRAME | The label has a sunken border.
* LABEL_SEPARATOR | The label is an etched box with no text useful for drawing separators.
* LABEL_LEFT | The label's text is left-aligned. This is the default.
* LABEL_CENTER | The label's text is center-aligned.
* LABEL_RIGHT | The label's text is right-aligned.
]

See Also: #SetGadgetText, #SetGadgetTextColor, #SetGadgetFont and #SetGadgetColor.
EndRem
Function CreateLabel:TGadget( name$,x,y,w,h,group:TGadget,style=LABEL_LEFT )
	Return maxgui_driver.CreateGadget(GADGET_LABEL,name,x,y,w,h,GetGroup(group),style)
End Function

' slider

Rem
bbdoc: Create a Slider gadget.
about:
A Slider gadget supports the following styles:

[ @Style | @Meaning
* SLIDER_HORIZONTAL | The slider is moved left and right.
* SLIDER_VERTICAL | The  slider is moved up and down.
* SLIDER_SCROLLBAR | The slider uses a proportional size knob.
* SLIDER_TRACKBAR | The slider uses a fixed size knob.
* SLIDER_STEPPER | The slider has no knob, just arrow buttons.
]

A slider only emits one type of event:

[ @{Event ID} | @Description
* EVENT_GADGETACTION | The user has changed the slider's value. Event Data contains the SliderValue.
]

See Also: #SetSliderRange, #SetSliderValue and #SliderValue
EndRem
Function CreateSlider:TGadget( x,y,w,h,group:TGadget,style=0 )
	Return maxgui_driver.CreateGadget(GADGET_SLIDER,"",x,y,w,h,GetGroup(group),style)
End Function

Rem
bbdoc: Set the range of a Slider gadget.
about: For the default SLIDER_SCROLLBAR style the range0,range1 parameters are treated
as a visible / total ratio which dictates both the size of the knob and it's
maximum value. The default value is 1,10 which displays a Slider with a knob
that occupies 1/10th the area and with a #SliderValue range of 0..9.

For the SLIDER_TRACKBAR and SLIDER_STEPPER styles the range0,range1 parameters
are treated as the minimum and maximum #SliderValue range inclusive.

See Also: #CreateSlider, #SliderValue and #SetSliderValue
EndRem
Function SetSliderRange( slider:TGadget,range0,range1 )
	slider.SetRange(range0,range1)
End Function

Rem
bbdoc: Set the position of a Slider gadget.
about:
See Also: #CreateSlider, #SetSliderRange and #SliderValue
EndRem
Function SetSliderValue( slider:TGadget,value )
	slider.SetProp value
End Function

Rem
bbdoc: Get the position of a Slider gadget.
about:
See Also: #CreateSlider, #SetSliderRange and #SetSliderValue
EndRem
Function SliderValue( slider:TGadget )
	Return slider.GetProp()
End Function

' progress

Rem
bbdoc: Create a Progress Bar gadget.
about: Similar to Labels, Progress Bar gadgets do not generate any events themselves.
See Also: #UpdateProgBar
EndRem
Function CreateProgBar:TGadget( x,y,w,h,group:TGadget,style=0 )
	Return maxgui_driver.CreateGadget(GADGET_PROGBAR,"",x,y,w,h,GetGroup(group),style)
End Function

Rem
bbdoc: Update the display of a ProgressBar gadget.
about:
See Also: #CreateProgBar
EndRem
Function UpdateProgBar( progbar:TGadget,value# )
	progbar.SetValue value
End Function

Rem
bbdoc: Creates an icon strip from an image file.
about:
An icon strip is a series of small images that can be attached to item-based gadgets.

Icons must be square, and arranged in a single horizontal strip across the source image.

The number of icons in an iconstrip is determined by dividing the image width by its height. For example,
an iconstrip 64 wide by 8 high is assumed to contain 64/8=8 icons.

Once an icon strip has been loaded, it can be attached to item-based gadgets using #SetGadgetIconStrip.

See Also: #SetGadgetIconStrip and #PixmapFromIconStrip
EndRem
Function LoadIconStrip:TIconStrip( source:Object )
	Return maxgui_driver.LoadIconStrip(source)
End Function

Rem
bbdoc: Attaches an icon strip to an item-based gadget.
about: Once attached, icons can be specified when items are added or modified with the #AddGadgetItem,
#InsertGadgetItem and #ModifyGadgetItem commands.

This command may only be used with the @ComboBox, @ListBox, @Tabber and @TreeNode gadgets.

%{Note: It is highly recommended that icon-strips are set before any items are added to a gadget.}

See Also: #LoadIconStrip
EndRem
Function SetGadgetIconStrip( gadget:TGadget,iconstrip:TIconStrip )
	gadget.SetIconStrip(iconstrip)
End Function

Rem
bbdoc: Returns a pixmap containing either a copy of the original icon-strip or just the specified icon.
about: @iconstrip: The icon-strip to return a pixmap from.

@index: The index (base 0) of the icon to extract. If this is negative, a %copy of the
original pixmap used to create the iconstrip is returned.

This function will return #Null if no iconstrip is passed, or if the icon index is invalid.

See Also: #LoadIconStrip
EndRem
Function PixmapFromIconStrip:TPixmap( iconstrip:TIconStrip, index = -1 )
	If iconstrip Then Return iconstrip.ExtractIconPixmap(index)
End Function


Rem
bbdoc: Create a Canvas gadget.
about:
A Canvas provides a #Graphics interface for realtime drawing purposes.

Once a Canvas is created, the #CanvasGraphics() Function can be used with the
#SetGraphics command to direct #Max2D drawing commands to be
drawn directly on the Canvas.

An EVENT_GADGETPAINT event is generated whenever the gadget must be redrawn by either
the system (for instance when it is first shown) or due to the #RedrawGadget command.

An EVENT_GADGETPAINT handler should always call #SetGraphics
with the canvas's Max2D graphics context to ensure the viewport and similar
properties are in their correct state.

When a Canvas is active using either the #ActivateGadget command or clicking
on the Canvas when the application is running, the following events will also
be sent from the Canvas:

[ @{Event ID} | @Description
* EVENT_MOUSEDOWN | Mouse button pressed. Event data contains mouse button code.
* EVENT_MOUSEUP | Mouse button released. Event data contains mouse button code.
* EVENT_MOUSEMOVE | Mouse moved. Event x and y contain mouse coordinates.
* EVENT_MOUSEWHEEL | Mouse wheel spun. Event data contains delta clicks.
* EVENT_MOUSEENTER | Mouse entered gadget area.
* EVENT_MOUSELEAVE | Mouse left gadget area.
* EVENT_KEYDOWN | Key pressed. Event data contains keycode.
* EVENT_KEYUP | Key released. Event data contains keycode.
* EVENT_KEYCHAR | Key character. Event data contains unicode value.
]

See Also: #ActivateGadget, #RedrawGadget, #CanvasGraphics
EndRem
Function CreateCanvas:TGadget( x,y,w,h,group:TGadget,style=0 )
	Local t:TGadget=maxgui_driver.CreateGadget(GADGET_CANVAS,"",x,y,w,h,GetGroup(group),style)
	t.AttachGraphics DefaultGraphicsFlags()	'gfxFlags
	Return t
End Function

Rem
bbdoc: Retrieve a Canvas gadget's Graphics context.
about: The #RedrawGadget example shows an alternative method for drawing to Canvas
gadgets utilizing the EVENT_GADGETPAINT event.

See Also: #CreateCanvas
EndRem
Function CanvasGraphics:TGraphics( gadget:TGadget )
	Return gadget.CanvasGraphics()
End Function

Rem
bbdoc: Return internal gadget handle.
about: #QueryGadget retrieves system handles for use with API specific functions.

[ @Constant | @{Return Value}
* QUERY_HWND | A Windows API HWND handle.
* QUERY_HWND_CLIENT | A Windows API HWND handle representing a gadget's client area.
* QUERY_NSVIEW | A Cocoa NSView handle.
* QUERY_NSVIEW_CLIENT | A Cocoa NSView representing a gadget's client area.
* QUERY_FLWIDGET | An FL_WIDGET handle.
* QUERY_FLWIDGET_CLIENT | An FL_WIDGET handle representing a gadget's client area.
]
EndRem
Function QueryGadget( gadget:TGadget,queryid )
	Return gadget.Query(queryid)
End Function

Private

Function GetGroup:TGadget( gadget:TGadget )
	Local tmpProxy:TProxyGadget = TProxyGadget(gadget)
	If tmpProxy Then Return GetGroup(tmpProxy.proxy)
	Return gadget
EndFunction
