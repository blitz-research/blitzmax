Strict

Import MaxGUI.MaxGUI
Import BRL.Graphics

Import "fltkfonts.bmx"
Import "fltksystem.bmx"

Extern "C"
Function bbStringToUTF8String:Byte Ptr ( str$ )
EndExtern 

Private
	
	Include "fltkdecls.bmx"
	
	Global FLDriver:TFLTKGUIDriver = New TFLTKGuiDriver
	maxgui_driver = FLDriver
	
	Type TFLGuiSystemDriver Extends TFLSystemDriver
		Field	gui:TFLTKGUIDriver
		
		Method Poll()
			gui.RefreshWidgets()
			flWait(0.0)
			gui.FreePointers()
			DispatchGuiEvents()
		End Method
			
		Method Wait()
			Poll()
			flWait(-1)
		End Method
				
		Function Create:TFLGuiSystemDriver(host:TFLTKGUIDriver)
			Local guisystem:TFLGuiSystemDriver = New TFLGuiSystemDriver
			guisystem.gui = host
			Return guisystem
		End Function
	End Type
	
Public

Type TFLTKGUIDriver Extends TMaxGUIDriver
	
	Global fntDefault:TFLGuiFont
	
	Field RefreshList:TList=New TList, PointerTrash:Byte Ptr[]
	Field fontRequester:TFLFontRequest

	?Linux
	Function _FlushAsyncOpsProc( fd,data:Byte Ptr ) "C" nodebug
		bbSystemFlushAsyncOps
	End Function
	?
	
	Method UserName$()
	End Method
	
	Method ComputerName$()
	End Method
	
	Method New()
		
		brl.System.Driver=TFLGuiSystemDriver.Create(Self)
		Local display

		?Linux
		display = bbSystemDisplay()
		?
		
		flReset(display,EventHandler,KeyFilter,TFLWidget.MouseHandler,TFLWidget.KeyHandler)
		
		?Linux
		flAddFd( bbSystemAsyncFD(),FL_READ,_FlushAsyncOpsProc,Null )
		?
		
		'Initialize FLTK font handler after flReset() call.
		TFLFontFamily.Initialize()
		fntDefault = TFLGuiFont(LibraryFont( GUIFONT_SYSTEM, 0, FONT_NORMAL ))
		
	End Method

	Function EventHandler:Int(flevent) "C" nodebug
		Local	key,state
		Local	event:TEvent	
		Select flevent
			Case FL_DND_RELEASE
				If TFLGadget.getDragDrop() Then flSetBelowMouse(TFLGadget.getDragDrop().WidgetHandle())
				Return 1
			Case FL_SHORTCUT
				key=flkeytovkey(flEventKey())
				state=flstatetomodifiers(flEventState())
				event=HotKeyEvent( key,state,flGetFocus() )
				If event Then
					event.emit()
					Return 1
				EndIf
		EndSelect
	End Function
	
	Function KeyFilter(obj:Int) "C" nodebug
		Local	source:TFLWidget
		Local	event:TEvent
		Local	key,mods,text$,i
		source=TFLWidget(HandleToObject(obj))
		
		If flEventKey()=FL_KEY_Control_R Return 0
		If source And (source.eventfilter<>Null) Then
			key=BlitzKeyFromFlConst(flEventKey())
			text$=fleventtext()
			mods=flstatetomodifiers(flEventState())
			If key
				event=CreateEvent(EVENT_KEYDOWN,source,key,mods)
				If Not source.eventfilter(event,source.context) Then Return 0
				'Unlike the other platforms, text isn't set by FLTK when combining tab with modifier keys
				If Not text And key = KEY_TAB Then text="~t"
			EndIf
			For i=0 Until text.length
				key=text[i]
				event=CreateEvent(EVENT_KEYCHAR,source,key,mods)
				If Not source.eventfilter(event,source.context) Then Return 0
			Next
		EndIf
		Return 1
	End Function
	
	Function BlitzKeyFromFlConst( pKey% )
		Select pKey
			Case FL_KEY_BackSpace;Return KEY_BACKSPACE
			Case FL_KEY_Tab;Return KEY_TAB
			Case FL_KEY_Enter;Return KEY_RETURN
			Case FL_KEY_Pause
			Case FL_KEY_Scroll_Lock
			Case FL_KEY_Escape;Return KEY_ESCAPE
			Case FL_KEY_Home;Return KEY_HOME
			Case FL_KEY_Left;Return KEY_LEFT
			Case FL_KEY_Up;Return KEY_UP
			Case FL_KEY_Right;Return KEY_RIGHT
			Case FL_KEY_Down;Return KEY_DOWN
			Case FL_KEY_Page_Up;Return KEY_PAGEUP
			Case FL_KEY_Page_Down;Return KEY_PAGEDOWN
			Case FL_KEY_End;Return KEY_END
			Case FL_KEY_Print;Return KEY_PRINT
			Case FL_KEY_Insert;Return KEY_INSERT
			Case FL_KEY_Menu
			Case FL_KEY_Help
			Case FL_KEY_Num_Lock
			Case FL_KEY_KP+0;Return KEY_NUM0
			Case FL_KEY_KP+1;Return KEY_NUM1
			Case FL_KEY_KP+2;Return KEY_NUM2
			Case FL_KEY_KP+3;Return KEY_NUM3
			Case FL_KEY_KP+4;Return KEY_NUM4
			Case FL_KEY_KP+5;Return KEY_NUM5
			Case FL_KEY_KP+6;Return KEY_NUM6
			Case FL_KEY_KP+7;Return KEY_NUM7
			Case FL_KEY_KP+8;Return KEY_NUM8
			Case FL_KEY_KP+9;Return KEY_NUM9
			Case FL_KEY_KP_Enter;Return KEY_ENTER
			Case FL_KEY_F+1;Return KEY_F1
			Case FL_KEY_F+2;Return KEY_F2
			Case FL_KEY_F+3;Return KEY_F3
			Case FL_KEY_F+4;Return KEY_F4
			Case FL_KEY_F+5;Return KEY_F5
			Case FL_KEY_F+6;Return KEY_F6
			Case FL_KEY_F+7;Return KEY_F7
			Case FL_KEY_F+8;Return KEY_F8
			Case FL_KEY_F+9;Return KEY_F9
			Case FL_KEY_F+10;Return KEY_F10
			Case FL_KEY_F+11;Return KEY_F11
			Case FL_KEY_F+12;Return KEY_F12
			Case FL_KEY_Shift_L;Return KEY_LSHIFT
			Case FL_KEY_Shift_R;Return KEY_RSHIFT
			Case FL_KEY_Control_L;Return KEY_LCONTROL
			Case FL_KEY_Control_R;Return KEY_RCONTROL
			Case FL_KEY_Caps_Lock
			Case FL_KEY_Meta_L;Return KEY_LSYS
			Case FL_KEY_Meta_R;Return KEY_RSYS
			Case FL_KEY_Alt_L;Return KEY_LALT
			Case FL_KEY_Alt_R;Return KEY_RALT
			Case FL_KEY_Delete;Return KEY_DELETE
			Default;Return flkeytovkey(pKey)
		EndSelect
	EndFunction

	Method RefreshWidget( widget:TFLWidget )
		RefreshList.AddLast widget
	End Method
	
	Method QueueFlDelete( pointer:Byte Ptr )
		PointerTrash:+[pointer]
	EndMethod
	
	Method RefreshWidgets()
		For Local w:TFLWidget = EachIn RefreshList
			w.Redraw()
		Next
		RefreshList.Clear()
	End Method
	
	Method FreePointers()
		For Local pointer:Byte Ptr = EachIn PointerTrash
			flDelete(pointer)
		Next
		PointerTrash = Null
	EndMethod
	
	Method CreateGadget:TGadget(class,name$,x,y,w,h,group:TGadget,style)
		
		Select class
			Case GADGET_DESKTOP
				Return New TFLDesktop.CreateDesktop()
			Case GADGET_WINDOW
				Return New TFLWindow.CreateGadget(name,x,y,w,h,TFLGadget(group),style)
			Case GADGET_PANEL
				Return New TFLPanel.CreateGadget(name,x,y,w,h,TFLGadget(group),style)
			Case GADGET_BUTTON
				Return New TFLButton.CreateGadget(name,x,y,w,h,TFLGadget(group),style)
			Case GADGET_TEXTFIELD
				Return New TFLTextField.CreateGadget(name,x,y,w,h,TFLGadget(group),style)
			Case GADGET_TEXTAREA
				Return New TFLTextArea.CreateGadget(name,x,y,w,h,TFLGadget(group),style)
			Case GADGET_COMBOBOX
				Return New TFLComboBox.CreateGadget(name,x,y,w,h,TFLGadget(group),style)
			Case GADGET_LISTBOX
				Return New TFLListBox.CreateGadget(name,x,y,w,h,TFLGadget(group),style)
			Case GADGET_TOOLBAR
				Return New TFLToolbar.CreateGadget(name,x,y,w,h,TFLGadget(group),style)
			Case GADGET_TABBER
				Return New TFLTabber.CreateGadget(name,x,y,w,h,TFLGadget(group),style)
			Case GADGET_TREEVIEW
				Return New TFLTreeview.CreateGadget(name,x,y,w,h,TFLGadget(group),style)
			Case GADGET_HTMLVIEW
				Return New TFLHTMLView.CreateGadget(name,x,y,w,h,TFLGadget(group),style)
			Case GADGET_LABEL
				Return New TFLLabel.CreateGadget(name,x,y,w,h,TFLGadget(group),style)
			Case GADGET_SLIDER
				Return New TFLSlider.CreateGadget(name,x,y,w,h,TFLGadget(group),style)
			Case GADGET_PROGBAR
				Return New TFLProgBar.CreateGadget(name,x,y,w,h,TFLGadget(group),style)
			Case GADGET_MENUITEM
				Return TFLMenu.CreateMenu(name,style,TFLMenu(group))
			Case GADGET_CANVAS
				Return New TFLCanvas.CreateGadget(name,x,y,w,h,TFLGadget(group),style)
		End Select

	End Method

	Method LoadFont:TGuiFont(name$,size,flags)
		Return TFLGUIFont.LoadFont(name,size,flags)
	End Method
		
	Method RequestColor( red,green,blue )
		Local r:Byte = red, g:Byte = green, b:Byte = blue
		If flChooseColor( "Choose Color", Varptr r, Varptr g, Varptr b )
			Return $ff000000 | (r Shl 16) | (g Shl 8) | b
		EndIf
		Return 0
	End Method
	
	Method RequestFont:TGuiFont(font:TGuiFont)
		If Not fontRequester Then fontRequester = New TFLFontRequest
		Return fontRequester.Request(TFLGUIFont(font))
	End Method

	Method SetPointer(shape)
		flSetCursor(shape)
	End Method
	
	Method ActiveGadget:TGadget()
		PollSystem
		Local handle:Int = flGetFocus()
		If handle Return TFLWidget(HandleToObject(flGetUser(handle)))
	End Method
	
	Method LoadIconStrip:TIconStrip(image:Object)
		Return TFLIconStrip.Create(image)
	End Method
	
	Method LookupColor( colorindex:Int, pRed:Byte Var, pGreen:Byte Var, pBlue:Byte Var )
		
		Select colorindex
			Case GUICOLOR_WINDOWBG
				colorindex = FL_BACKGROUND_COLOR
			Case GUICOLOR_GADGETBG
				colorindex = FL_BACKGROUND2_COLOR
			Case GUICOLOR_GADGETFG
				colorindex = FL_FOREGROUND_COLOR
			Case GUICOLOR_SELECTIONBG
				colorindex = FL_SELECTION_COLOR
			Default
				Return Super.LookupColor( colorindex, pRed, pGreen, pBlue )
		EndSelect
		
		Local color = flGetColor( colorindex )
		pRed  = color Shr 24
		pGreen  = (color Shr 16) & $FF
		pBlue  = (color Shr 8) & $FF
		
		Return True
		
	EndMethod
	
	Method LibraryFont:TGuiFont( pFontType% = GUIFONT_SYSTEM, pFontSize:Double = 0, pFontStyle% = FONT_NORMAL )
		Local tmpFont:TGuiFont
		Local tmpFontAttrib%
		
		?Win32
		If pFontSize <= 0 Then pFontSize = 10
		?Not Win32
		If pFontSize <= 0 Then pFontSize = 12
		?
		
		Select pFontType
			Case GUIFONT_MONOSPACED
				Return LoadFontWithDouble( TFLFontFamily.FriendlyNameFromID(FL_COURIER), pFontSize, pFontStyle )
			Case GUIFONT_SANSSERIF
				Return LoadFontWithDouble( TFLFontFamily.FriendlyNameFromID(FL_HELVETICA), pFontSize, pFontStyle )
			Case GUIFONT_SERIF
				Return LoadFontWithDouble( TFLFontFamily.FriendlyNameFromID(FL_TIMES), pFontSize, pFontStyle )
			Case GUIFONT_SCRIPT
				Return LoadFontWithDouble("Comic Sans MS",pFontSize,pFontStyle)
			Default	'GUIFONT_SYSTEM
				Return LoadFontWithDouble( TFLFontFamily.FriendlyNameFromID(FL_HELVETICA), pFontSize, pFontStyle )
		EndSelect
	EndMethod
	
End Type

Type TFLWidget Extends TGadget
	
	Global initText:Byte Ptr = " ".ToCString()
	
	Field fltype, flhandle, flkey, tag, tooltip:Byte Ptr
	Field originx, originy, client:TFLWidget, dirty, objhandle:Int = HandleFromObject(Self)
	
	Method CreateWidget:TFLWidget( fltype, text$, x, y, w, h, group:TFLWidget, alignment = -1, boxtype = -1 )
		Self.fltype = fltype
		SetRect(x,y,w,h)
		parent = group
		InitWidget()
		If alignment > -1 Then flSetAlign( flhandle, alignment )
		If boxtype > -1 Then flSetBox( flhandle, boxtype, False  )
		If text Then SetText(text)
		Return Self	
	EndMethod
	
	Method WidgetHandle()
		?Debug
		Assert flhandle, "Attempt to access a NULL widget."
		?
		Return flhandle
	EndMethod
	
	Method InitWidget()
		If TFLWidget(parent) Then flBegin( TFLWidget(parent).Query(QUERY_FLWIDGET_CLIENT) )
		flhandle = flWidget(AbsoluteX(),AbsoluteY(),width,height,initText,fltype)
		flSetCallback(WidgetHandle(),CallbackHandler,objhandle )
		If TFLWidget(parent) Then
			flEnd( TFLWidget(parent).Query(QUERY_FLWIDGET_CLIENT) )
			TFLWidget(parent).AddChild(Self)
		Else
			LockLayout()
		EndIf
		If flkey Then flSetButtonKey(WidgetHandle(),flkey)
		SetTooltip("")
	EndMethod
	
	Method Rethink()
		flSetArea(WidgetHandle(),AbsoluteX(),AbsoluteY(),width,height)
	End Method
	
	Method Redraw()
		If flhandle Then
			flRedraw(WidgetHandle())
			dirty = False
		EndIf
	End Method
	
	Method SetText(text$)
		Return flSetLabel(WidgetHandle(),text)
	End Method

	Method GetText$()
		Return flGetLabel(WidgetHandle())
	End Method
	
	Method SetToolTip(tip$)
		If tooltip Then MemFree tooltip
		tooltip = tip.ToCString()
		flSetToolTip(WidgetHandle(),tooltip)
	End Method
	
	Method GetToolTip$()
		If tooltip Then Return String.FromCString(tooltip)
	EndMethod
	
	Method SetShape(x,y,w,h)
		Super.SetShape x,y,w,h
		If parent parent.activate ACTIVATE_REDRAW
	End Method
	
	Method SetColor( r,g,b )
		flSetColor(WidgetHandle(),r,g,b)
	End Method

	Method RemoveColor()
		flRemoveColor(WidgetHandle())
	End Method
	
	Method SetTextColor( r,g,b )
		flSetLabelColor(WidgetHandle(),r,g,b)
	EndMethod
	
	Method SetShow(truefalse)
		flSetShow(WidgetHandle(),truefalse)
	End Method
	
	Method ClientWidth()
		Local	w
		If client Then w=client.width Else w=width-originx
		Return Max(w,0)
	End Method
	
	Method ClientHeight()
		Local	h
		If client Then h=client.height Else h=height-originy
		Return Max(h,0)
	End Method
	
	Method RemoveChild(child:TFLWidget)
		kids.remove child
		child.parent=Null
		If child.flhandle Then
			flRemoveFromGroup Query(QUERY_FLWIDGET_CLIENT),child.flhandle
			SetDirty()
		EndIf
	End Method
	
	Method AddChild(child:TFLWidget)
		If child.parent TFLWidget(child.parent).RemoveChild(child)
		child.parent=Self
		kids.addlast(child)
		If child.flhandle Then
			flAddToGroup Query(QUERY_FLWIDGET_CLIENT),child.flhandle
			SetDirty()
		EndIf
		child.LockLayout
		child.Rethink()		
	End Method
	
	Method SetDirty()
		If Not dirty
			dirty=True
			FLDriver.RefreshWidget Self
		EndIf
	End Method
	
	Method Free()
		
		'Cleanup any client gadget first.
		If client Then
			client.CleanUp()
			client = Null
		EndIf
		
		'Then remove ourselves from our parent
		If TFLWidget(parent) Then TFLWidget(parent).RemoveChild(Self)
		
		'And free our widget in the FLTK toolkit.
		If flhandle Then
			flSetCallBack( WidgetHandle(), CallbackHandler, 0 )
			If objhandle Then
				Release objhandle
				objhandle= 0
			EndIf
			If fltype=FL_WINDOW Then flDestroyWindow flhandle Else flFreeWidget flhandle
		EndIf
		
		'Then any tooltip we may have.
		If tooltip Then
			MemFree tooltip
			tooltip = Null
		EndIf
		
		'And clear the widget handle and parent.
		flhandle=0
		parent = Null
		
	EndMethod
	
	Method CountKids()
		Return kids.count()
	End Method
	
	Method SetOrigin(x,y)
		originx=x
		originy=y
	End Method
	
	Method AbsoluteX()
		Local	p:TFLWidget = TFLWidget(parent)
		Local	x = xpos
		While p
			x:+p.originx
			If p.client And Self <> p.client x:+p.client.xpos+p.client.originx
			If p.fltype<>FL_WINDOW x:+p.xpos Else Exit
			p=TFLWidget(p.parent)
		Wend
		Return x
	End Method	
			
	Method AbsoluteY()
		Local	p:TFLWidget = TFLWidget(parent)
		Local	y = ypos
		While p
			y:+p.originy
			If p.client And Self <> p.client y:+p.client.ypos+p.client.originy
			If p.fltype<>FL_WINDOW y:+p.ypos Else Exit
			p=TFLWidget(p.parent)
		Wend
		Return y
	End Method
	
	Method Query(queryid)
		Select queryid
			Case QUERY_FLWIDGET
				Return flhandle
			Case QUERY_FLWIDGET_CLIENT
				If client Return client.flhandle Else Return flhandle
		End Select				
	End Method
	
	Method OnCallback()
	EndMethod
	
	Method OnMouse:Int()
	EndMethod
	
	Method OnKey:Int()
	EndMethod
	
	Function CallbackHandler(flwidget,obj:Int) "C" nodebug
		Local widget:TFLWidget = TFLWidget(HandleToObject(obj))
		If widget Then widget.OnCallback()
	EndFunction
	
	Function MouseHandler:Int(flwidget,obj:Int) "C" nodebug
		Local widget:TFLWidget = TFLWidget(HandleToObject(obj))
		Select flEvent()
			Case FL_LEAVE
				If TFLGadget.activepanel Then
					TFLGadget.activepanel.OnMouseLeave()
					TFLGadget.activepanel = Null
				EndIf
			Case FL_RELEASE
				Local tmpButton:Int = flEventButton()
				Local tmpX:Int = flEventX(), tmpY:Int = flEventY()
				Local tmpDropWidget:TFLWidget = TFLWidget(HandleToObject(flUserData(flWidgetWindow(flwidget))))
				
				If tmpDropWidget Then tmpDropWidget = tmpDropWidget.FindChildAtCoords(tmpX,tmpY)
				If tmpDropWidget And tmpDropWidget.fltype <> FL_WINDOW Then
					tmpX:-tmpDropWidget.AbsoluteX()
					tmpY:-tmpDropWidget.AbsoluteY()
				EndIf
				
				If dragGadget[tmpButton-1] Then
					PostGuiEvent EVENT_GADGETDROP, tmpDropWidget, tmpButton, flStateToModifiers(flEventState()), tmpX, tmpY, dragGadget[tmpButton-1]
					dragGadget[tmpButton-1] = Null
				EndIf
				
		EndSelect
		If widget Then Return widget.OnMouse()
	EndFunction
		
	Function KeyHandler:Int(flwidget,obj:Int) "C" nodebug
		Local widget:TFLWidget = TFLWidget(HandleToObject(obj))
		If widget Then Return widget.OnKey()
	EndFunction
	
	Function XPMFromPixmap:String[](pPixmap:TPixmap)
		
		Const charRange:Int = 26
		
		Local x:Int, y:Int, i:Int, j:Int, tmpColor:Int, chrctsPerPixel:Int, tmpString$
		Local width:Int = PixmapWidth(pPixmap), height:Int = PixmapHeight(pPixmap)
		Local colormap:Int[][] = New Int[][height], colors:Int[], colorstrings:String[]
		
		For y = 0 Until height
			colormap[y] = New Int[width]
			For x = 0 Until width
				'Read color from pixel
				tmpColor = ReadPixel(pPixmap,x,y)
				'If less than 50% alpha, set a standard transparent color.
				If (tmpColor Shr 24) < $80 Then tmpColor = $00000000
				'Find the color if it has been used before.
				For i = 0 Until colors.length
					If colors[i] = tmpColor Then Exit
				Next
				'If it hasn't been found, add it to the end of the array.
				If i = colors.length Then colors:+[tmpColor]
				'And finally, update the colormap with the color index.
				colormap[y][x] = i
			Next
		Next
		
		chrctsPerPixel = (colors.length / charRange) + 1
		colorstrings = New String[colors.length]
		
		Local tmpResult:String[] = [width + " " + height + " " + colors.length + " " + chrctsPerPixel]
		
		For i = 0 Until colors.length
			Local tmpI:Int = i
			For j = 0 Until chrctsPerPixel
				colorstrings[i]:+Chr$("a"[0]+(tmpI Mod charRange))
				tmpI:/charRange
			Next
			tmpString = colorstrings[i] + "~tc "
			If (colors[i] Shr 24) <> $FF Then tmpString:+"None" Else tmpString:+"#"+_RGBHex(colors[i]&$FFFFFF)
			tmpResult:+[tmpString]
		Next
		
		For y = 0 Until height
			tmpString = ""
			For x = 0 Until width
				tmpString:+colorstrings[colormap[y][x]]
			Next
			tmpResult:+[tmpString]
		Next
		
		Return tmpResult
		
	EndFunction
	
	Function _RGBHex$( rgb:Int )
		Local buf:Short[6]
		For Local k:Int=5 To 0 Step -1
			Local n:Int=(rgb&15)+Asc("0")
			If n>Asc("9") n=n+(Asc("A")-Asc("9")-1)
			buf[k]=n
			rgb:Shr 4
		Next
		Return String.FromShorts( buf,buf.length )
	End Function
	
	Method FindChildAtCoords:TFLWidget( pX, pY )
		If pX > 0 And pX < ClientWidth() And pY > 0 And pY < ClientHeight() Then
			For Local tmpChild:TFLWidget = EachIn kids
				tmpChild = tmpChild.FindChildAtCoords( pX - tmpChild.xpos, pY - tmpChild.ypos)
				If tmpChild Then Return tmpChild
			Next
			Return Self
		EndIf
	EndMethod
	
EndType

Type TFLGadget Extends TFLWidget
	
	Global activepanel:TFLGadget
	Global activex, activey, activekey
	
	Field menu:TFLMenu
	Field enabled = True, ignore
	Field font:TFLGUIFont
	Field pixmap:TPixmap, pixmapflags, image, icons:TFLIconStrip

	Method CreateGadget:TFLGadget(pText$, pX, pY, pW, pH, pGroup:TFLGadget, pStyle)
		
		style = pStyle
		SetRect(pX,pY,pW,pH)
		parent = pGroup
		InitGadget()
		
		If (LocalizationMode() & LOCALIZATION_OVERRIDE) Then
			LocalizeGadget(Self,pText)
		Else
			SetText(pText)
		EndIf
		
		SetFont(TFLTKGUIDriver.fntDefault)
		Return Self
		
	EndMethod
	
	Method InitGadget()
	EndMethod
	
	Method SetHotKey(keycode,modifier)
		Local	flkey
		flkey=flkeyfromvkey(keycode)
		If flkey flkey:+flstatefrommodifiers(modifier)
	End Method
	
	Method SetEnabled(truefalse)
		enabled=truefalse
		flSetActive WidgetHandle(),truefalse
	End Method
	
	Method SetFont( font:TGuiFont )
		Self.font = TFLGUIFont(font)
		flSetLabelFont WidgetHandle(),Self.font.handle
		flSetLabelSize WidgetHandle(),Self.font.GetSizeForFL()
		SetText(GetText())
		Redraw()
	End Method
	
	Method SetText(text$)
		Super.SetText(text.Replace("@","@@"))
	EndMethod
	
	Method GetText$()
		Return Super.GetText().Replace("@@","@")
	EndMethod
	
	Method State()
		Local flags
		If Not enabled Then flags:|STATE_DISABLED
		If Not flVisible(WidgetHandle()) flags:|STATE_HIDDEN
		Return flags
	End Method
	
	Method Activate(cmd)
		Select cmd
			Case ACTIVATE_FOCUS
				flSetFocus(WidgetHandle())
				PollSystem
			Case ACTIVATE_REDRAW
				Redraw
		End Select
	End Method
	
	Method SetPixmap(pPixmap:TPixmap,flags)
		Local	d
		SetFLImage 0
		If pixmap And image Then
			flFreeImage( image )
			image = 0
		EndIf
		pixmap = Null
		If pPixmap Then
			Select PixmapFormat(pPixmap)
				Case PF_RGB888, PF_BGR888, PF_I8
					d = 3
					pixmap = ConvertPixmap(pPixmap,PF_RGB888)
				Case PF_RGBA8888, PF_BGRA8888, PF_A8
					d = 4
					pixmap = ConvertPixmap(pPixmap,PF_RGBA8888)
				Default
					Return
			EndSelect
			If pixmap Then
				image = flImage(pixmap.pixels,pixmap.width,pixmap.height,d,pixmap.pitch)
			EndIf
		EndIf
		pixmapflags = flags
	 	SetFLImage image
	End Method
	
	Method SetFLImage(image)
	End Method
	
	Method SetIconStrip(iconstrip:TIconStrip)
		icons=TFLIconStrip(iconstrip)
	End Method
	
	Method ClearListItems()
		For Local i=items.length-1 To 0 Step -1
			RemoveListItem i
		Next
	End Method
	
	Method Free()
		Super.Free()
		pixmap = Null
		icons = Null
		If image Then flFreeImage(image);image = 0
	End Method
	
	Method GetMenu:TFLMenu()
		If Not menu Then
			menu = New TFLMenu
			menu.owner = Self
		EndIf
		Return menu
	End Method
	
	Method OnMouse:Int()
		Local x = flEventX()-AbsoluteX(), y = flEventY()-AbsoluteY()
		
		If activepanel And (activepanel<>Self) Then
			activepanel.OnMouseLeave()
			activepanel = Null
		EndIf
				
		If GetSensitivity() & SENSITIZE_MOUSE Then
			
			Select flevent()
				Case FL_DRAG, FL_MOVE
					Local data, state=flEventState()
					
					If state&FL_BUTTON1 data=MOUSE_LEFT
					If state&FL_BUTTON3 data=MOUSE_RIGHT
					If state&FL_BUTTON2 data=MOUSE_MIDDLE
					
					If (activepanel <> Self) Then
						PostGuiEvent(EVENT_MOUSEENTER,Self,data,0,x,y)
						activepanel=Self					
					Else
						If (x <> activex) Or (y <> activey) Then
							PostGuiEvent(EVENT_MOUSEMOVE,Self,data,0,x,y)
						EndIf
					EndIf
					activex=x;activey=y
					
				Case FL_PUSH, FL_RELEASE
					Local data, button=flEventButton(), id = EVENT_MOUSEDOWN
					Select button
						Case FL_LEFT_MOUSE data=MOUSE_LEFT
						Case FL_RIGHT_MOUSE data=MOUSE_RIGHT
						Case FL_MIDDLE_MOUSE data=MOUSE_MIDDLE
					EndSelect
					If flEvent() = FL_RELEASE Then id = EVENT_MOUSEUP
					PostGuiEvent(id,Self,data,0,x,y)
					
				Case FL_MOUSEWHEEL
					PostGuiEvent(EVENT_MOUSEWHEEL,Self,flEventdY(),0,x,y)
			EndSelect
			Return 1
		EndIf
	EndMethod
	
	Method OnMouseLeave()
		If GetSensitivity() & SENSITIZE_MOUSE Then
			PostGuiEvent(EVENT_MOUSELEAVE,Self,0,0,activex,activey)
		EndIf
	EndMethod
	
	Method OnKey:Int()
		Local key, mods
		If GetSensitivity() & SENSITIZE_KEYS Then
			Select flevent()
				Case FL_KEYDOWN
					key=TFLTKGUIDriver.BlitzKeyFromFlConst(flEventKey())
					mods=flstatetomodifiers(flEventState())
					If activekey=key
						PostGuiEvent(EVENT_KEYREPEAT,Self,key,mods)
					Else
						PostGuiEvent(EVENT_KEYDOWN,Self,key,mods)
					EndIf
					activekey=key
				Case FL_KEYUP
					key=TFLTKGUIDriver.BlitzKeyFromFlConst(flEventKey())
					mods=flstatetomodifiers(flEventState())
					PostGuiEvent(EVENT_KEYUP,Self,key,mods)
					activekey=0
			EndSelect
		EndIf
	EndMethod
	
	'For WINDOW_ACCEPTFILES drag n' drop event.
	Global _dragDrop:TFLGadget = Null
	
	Function setDragDrop( pGadget:TFLGadget )
		_dragDrop = pGadget
	EndFunction
	
	Function getDragDrop:TFLGadget()
		Return _dragDrop
	EndFunction
	
EndType

Type TFLDesktop Extends TFLGadget

	Method Class()
		Return GADGET_DESKTOP
	EndMethod
	
	Method InitGadget()
		Local x, y, w, h
		flDisplayRect( Varptr x, Varptr y, Varptr w, Varptr h )
		SetRect( x, y, w, h )
	EndMethod
	
	Method CreateDesktop:TFLGadget()
		InitGadget()
		Return Self
	EndMethod
	
EndType

Type TFLWindow Extends TFLGadget
	
	Const MENU_HEIGHT = 25, STATUSBAR_HEIGHT = 22
	
	Global lastactivewindow:TFLWindow
	
	Field menubar:TFLWidget, statustext:TFLGadget[3]
	
	Method InitGadget()
		Local tmpParent:TGadget = parent;parent = Null
		fltype = FL_WINDOW
		InitWidget()
		If Not (style&WINDOW_TITLEBAR) Then flClearBorder(WidgetHandle())
		CreateWindowClient()
		If tmpParent Then
			flSetNonModal(WidgetHandle())
			parent = tmpParent
		EndIf
		Rethink()
		If Not (style&WINDOW_HIDDEN) Then SetShow(True) Else SetShow(False)
	EndMethod
	
	Method Class()
		Return GADGET_WINDOW
	EndMethod
	
	Method SetText(text$)
		flSetWindowLabel(WidgetHandle(),text)
	End Method
	
	Method SetColor(r,g,b)
		Super.SetColor(r,g,b)
		client.SetColor(r,g,b)
	EndMethod
	
	Method Activate(cmd)
		Select cmd
			Case ACTIVATE_MINIMIZE
				flShowWindow WidgetHandle(), 2
			Case ACTIVATE_MAXIMIZE
				flShowWindow WidgetHandle(), 3
				LayoutKids()
			Case ACTIVATE_RESTORE
				flShowWindow WidgetHandle(), 4
				LayoutKids()
			Default
				Super.Activate(cmd)
		End Select
	End Method
	
	Method SetShow(truefalse)
		flShowWindow(WidgetHandle(),truefalse=True)
	End Method
	
	Method SetEnabled(truefalse)
		Super.SetEnabled(truefalse)
		If client Then flSetActive client.WidgetHandle(),truefalse
		If menubar Then flSetActive menubar.WidgetHandle(),truefalse
	End Method
	
	Method OnCallback()
		Select flevent()
			Case FL_CLOSE
				PostGuiEvent EVENT_WINDOWCLOSE,Self
			Case FL_FOCUS, FL_ACTIVATE
				If lastactivewindow <> Self Then
					lastactivewindow = Self
					PostGuiEvent EVENT_WINDOWACTIVATE,Self
				EndIf
			
			'Drag 'n' drop events
			Case FL_DND_ENTER
				setDragDrop(Self)
			Case FL_DND_LEAVE
				setDragDrop(Null)
			Case FL_PASTE
				DropFiles()
				setDragDrop(Null)
			Default
				Local ax,ay,aw,ah,move,size
				flGetArea WidgetHandle(),Varptr ax,Varptr ay,Varptr aw,Varptr ah
				If (style&WINDOW_CLIENTCOORDS) Then
					ax:+originX;ay:+originY
					aw:-originX;ah:-originY
					If (style&WINDOW_MENU) Then
						ay:+MENU_HEIGHT
						ah:-MENU_HEIGHT
					EndIf
					If (style&WINDOW_STATUS) Then ah:-STATUSBAR_HEIGHT
				EndIf
				If ax<>xpos Or ay<>ypos move=True
				If aw<>width Or ah<>height size=True
				SetRect ax,ay,aw,ah
				If size RethinkWindow()
				If move PostGuiEvent(EVENT_WINDOWMOVE,Self,0,0,ax,ay)
				If size PostGuiEvent(EVENT_WINDOWSIZE,Self,0,0,aw,ah)
			End Select
	EndMethod

	Method CreateWindowClient()
		
		If style&WINDOW_RESIZABLE Then SetMinimumSize(64,64)
		If style&WINDOW_ACCEPTFILES Then flSetAcceptsFiles( WidgetHandle(), True )
		
		If style&WINDOW_MENU
			menubar = New TFLWidget.CreateWidget( FL_MENUBAR, "", -2, 0, width+4, MENU_HEIGHT, Self, -1, FL_THIN_UP_BOX )
			kids.Remove(menubar)
		EndIf
		
		If style&WINDOW_STATUS
			statustext[2] = New TFLLabel.CreateGadget("",0,height-STATUSBAR_HEIGHT,width,STATUSBAR_HEIGHT,Self,LABEL_RIGHT)
			statustext[1] = New TFLLabel.CreateGadget("",0,height-STATUSBAR_HEIGHT,width,STATUSBAR_HEIGHT,Self,LABEL_CENTER)
			statustext[0] = New TFLLabel.CreateGadget("",0,height-STATUSBAR_HEIGHT,width,STATUSBAR_HEIGHT,Self,LABEL_LEFT)
			For Local tmpStatusText:TFLGadget = EachIn statustext
				If tmpStatusText = statustext[2] Then flSetBox( tmpStatusText.WidgetHandle(), FL_EMBOSSED_BOX, False ) Else flSetBox( tmpStatusText.WidgetHandle(), FL_NO_BOX,False )
				flSetAlign( tmpStatusText.WidgetHandle(), flAlign(tmpStatusText.WidgetHandle())&~FL_ALIGN_WRAP );kids.Remove(tmpStatusText)
			Next
		EndIf
		
		client=New TFLPanel.CreateGadget("",0,0,1,1,Self,0)
		RemoveChild(client);client.parent = Self
		
		RethinkWindow()
		
	End Method
	
	Method Rethink()
		Local tmpX:Int = AbsoluteX(), tmpY:Int = AbsoluteY(), tmpW:Int = width, tmpH:Int = height
		If (style&WINDOW_CLIENTCOORDS) Then
			tmpX:-originX;tmpY:-originY
			tmpW:+originX;tmpH:+originY
			If (style&WINDOW_MENU) Then
				tmpY:-MENU_HEIGHT
				tmpH:+MENU_HEIGHT
			EndIf
			If (style&WINDOW_STATUS) Then tmpH:+STATUSBAR_HEIGHT
		EndIf
		flSetArea(WidgetHandle(),tmpX,tmpY,tmpW,tmpH)
		RethinkWindow()
	EndMethod
	
	Method RethinkWindow()
		Local x,y,w=width,h=height
		If menubar Then flSetArea(menubar.WidgetHandle(),-2,0,w+4,MENU_HEIGHT);h:-MENU_HEIGHT;y:+MENU_HEIGHT
		If statustext[0] Then
			If Not (style&WINDOW_CLIENTCOORDS) Then h:-STATUSBAR_HEIGHT
			For Local tmpStatusText:TFLWidget = EachIn statustext;flSetArea(tmpStatusText.WidgetHandle(),0,y+originY+ClientHeight(),w,STATUSBAR_HEIGHT);Next
		EndIf
		client.SetArea x,y,ClientWidth(),ClientHeight()
		LayoutKids()
	End Method
	
	Method DoLayout()
		'Don't do anything!
	EndMethod
	
	Method GetStatusText$()
		If statustext[0] Then
			Return "~t".Join([statustext[0].GetText(), statustext[1].GetText(), statustext[2].GetText()])
		EndIf
	EndMethod
	
	Method SetStatusText(text$)
		If statustext[0] Then
			Local tmpAlignments$[] = text.Split("~t")
			If tmpAlignments.length > 3 Then tmpAlignments = [tmpAlignments[0], tmpAlignments[1], "~t".Join(tmpAlignments[2..])]
			tmpAlignments = tmpAlignments[..3]
			For Local i = 0 Until 3
				statustext[i].SetText( tmpAlignments[i] )
			Next
		EndIf
	End Method
	
	Method ClientWidth()
		If (style&WINDOW_CLIENTCOORDS) Then Return width Else Return (width-originx)
	EndMethod
	
	Method ClientHeight()
		Local h:Int = height
		If Not(style&WINDOW_CLIENTCOORDS) Then
			h:-originY
			If menubar Then h:-MENU_HEIGHT
			If statustext[0] Then h:-STATUSBAR_HEIGHT
		EndIf
		Return h
	EndMethod
	
	Method SetMaximumSize( w,h )
		flSetMaxWindowSize(WidgetHandle(),w,h)
	End Method

	Method SetMinimumSize( w,h )
		flSetMinWindowSize(WidgetHandle(),w,h)
	End Method
	
	Method UpdateMenu()
		Local	count,flmenu Ptr
		If Not (menubar And menu) Return
		count=menu.count(-1)
		flmenu=flCreateMenu(count+2,CallbackHandler)
		menu.setflmenu(flmenu)
		flSetMenu(menubar.WidgetHandle(),flmenu)			
	End Method

	Method PopupMenu( menu0:TGadget,extra:Object )
		Local	menu:TFLMenu
		Local	count,flmenu Ptr
		menu=TFLMenu(menu0)
		count=menu.count(-1)
		flmenu=flCreateMenu(count+2,CallbackHandler)
		menu.setflmenu(flmenu)
		menu=TFLMenu(HandleToObject(flPopupMenu(flmenu)))
		If menu PostGuiEvent(EVENT_MENUACTION,menu,menu.tag,0,0,0,extra)
	End Method
	
	Method SetPixmap(pPixmap:TPixmap, pFlags)
		?Linux
		If (pFlags&GADGETPIXMAP_ICON) Then
			
			'Generate the strings which represent the pixmap in XPM format.
			Local tmpXPM$[] = XPMFromPixmap(pPixmap)
			
			'Create a new array of char* pointers to pass to flSetWindowIcon().
			'+1 is for terminating Null pointer.
			Local tmpStringPointers:Byte Ptr[tmpXPM.length+1]
			
			'Store char* pointers for each section inside the array.
			For Local i:Int = 0 Until tmpXPM.length
				tmpStringPointers[i] = tmpXPM[i].ToCString()
			Next
			
			'And end the array with a Null pointer.
			tmpStringPointers[tmpXPM.length] = Null
			
			'Set the window icon.
			flSetWindowIcon( WidgetHandle(), tmpStringPointers )
			
			'And then free all the char* pointers before we exit. We only need
			'to iterate through tmpXPM.length as tmpStringPointers.length will
			'include the terminating Null pointer array element.
			For Local i:Int = 0 Until tmpXPM.length
				MemFree tmpStringPointers[i]
			Next
			
		EndIf
		?
	EndMethod
	
	Method DropFiles()
		
		For Local tmpUrl$ = EachIn flEventText().Replace("file://","").Replace("~r","").Split("~n")
			
			If tmpUrl[..8].ToLower() = "https://" Then Continue
			If tmpUrl[..7].ToLower() = "http://" Then Continue
			If tmpUrl[..6].ToLower() = "ftp://" Then Continue
			
			tmpURL = DecodeURL(tmpURL)
			If Not tmpURL Then Continue
			
			'Creating and manipulating widgets inside an FL_PASTE event is considered dangerous.
			'Therefore we should queue this event so that it's dispatched safely after a call to
			'Poll/WaitSystem().
			
			QueueGuiEvent(EVENT_WINDOWACCEPT,Self,0,0,0,0,tmpURL)
			
		Next
		
	End Method
	
	'http://www.blitzbasic.com/codearcs/codearcs.php?code=1581
	
	Function DecodeURL:String(EncStr:String)
		Local Pos:Int = 0
		Local HexVal:String
		Local Result:String
	
		While Pos < EncStr.length
			If EncStr[Pos..Pos+1] = "%" Then
				HexVal = EncStr[Pos+1..Pos+3]
				Result :+ Chr(Int("$"+HexVal))
				Pos:+3
			ElseIf EncStr[Pos..Pos+1] = "+" Then
				Result :+ " "
				Pos:+1
			Else
				Result :+ EncStr[Pos..Pos+1]
				Pos:+1	
			EndIf
		Wend
		
		Return Result
	End Function
	
EndType

Type TFLLabel Extends TFLGadget
	
	Method InitGadget()
		fltype=FL_BOX
		InitWidget()
		Local tmpAlignment = FL_ALIGN_WRAP|FL_ALIGN_INSIDE|FL_ALIGN_CLIP
		Select style&24
			Case LABEL_LEFT tmpAlignment:|FL_ALIGN_LEFT
			Case LABEL_CENTER tmpAlignment:|FL_ALIGN_CENTER
			Case LABEL_RIGHT tmpAlignment:|FL_ALIGN_RIGHT
		EndSelect
		flSetAlign WidgetHandle(),tmpAlignment
		Local tmpBox
		Select style&7
			Case 0 tmpBox = FL_NO_BOX
			Case LABEL_FRAME tmpBox = FL_BORDER_BOX
			Case LABEL_SUNKENFRAME tmpBox = FL_THIN_DOWN_FRAME
			Case LABEL_SEPARATOR tmpBox = FL_EMBOSSED_FRAME
		End Select
		flSetBox WidgetHandle(),tmpBox,False
	EndMethod
	
	Method Class()
		Return GADGET_LABEL
	EndMethod
	
	Method SetColor( r, g, b )
		Local tmpBox = FL_FLAT_BOX
		Select style&7
			Case LABEL_FRAME tmpBox = FL_BORDER_BOX
			Case LABEL_SUNKENFRAME tmpBox = FL_THIN_DOWN_BOX
			Case LABEL_SEPARATOR tmpBox = FL_EMBOSSED_BOX
		End Select
		flSetBox WidgetHandle(),tmpBox,False
		Super.SetColor( r, g, b )
	EndMethod
	
	Method SetText(text$)
		Super.SetText(text)
		Redraw()
	EndMethod
	
	Method SetRect(x,y,w,h)
		If style&LABEL_SEPARATOR = LABEL_SEPARATOR Then
			If w > h Then h = 2 Else w = 2
		EndIf
		Super.SetRect(x,y,w,h)
	EndMethod
	
EndType

Type TFLButton Extends TFLGadget
	
	Method InitGadget()
		Local tmpAlignment = FL_ALIGN_INSIDE|FL_ALIGN_CLIP|FL_ALIGN_WRAP|FL_ALIGN_CENTER
		fltype = FL_BUTTON
		Select style&7
			Case 0
				style = BUTTON_PUSH
			Case BUTTON_CHECKBOX
				If (style&BUTTON_PUSH) Then
					fltype = FL_TOGGLEBUTTON
				Else
					fltype=FL_CHECKBUTTON
					tmpAlignment:&~FL_ALIGN_CENTER
					tmpAlignment:|FL_ALIGN_LEFT
				EndIf
			Case BUTTON_RADIO
				If (style&BUTTON_PUSH) Then
					fltype = FL_RADIOPUSHBUTTON
				Else
					fltype=FL_ROUNDBUTTON
					tmpAlignment:&~FL_ALIGN_CENTER
					tmpAlignment:|FL_ALIGN_LEFT
				EndIf
			Case BUTTON_OK
				fltype=FL_RETURNBUTTON
			Case BUTTON_CANCEL
				flkey=FL_KEY_ESCAPE
		End Select
		InitWidget()
		flSetAlign WidgetHandle(), tmpAlignment
		flSetWhen WidgetHandle(), FL_WHEN_RELEASE
	EndMethod
	
	Method Class()
		Return GADGET_BUTTON
	EndMethod
	
	Method State()
		Local flags = Super.State()
		If flGetButton(WidgetHandle()) Then flags:|STATE_SELECTED
		Return flags
	End Method
	
	Field currentText$
	
	Method SetText(text$)
		currentText = text
		If Not (pixmapflags&GADGETPIXMAP_NOTEXT) Then Super.SetText(text)
	EndMethod
	
	Method GetText$()
		Return currentText
	EndMethod
	
	Method SetFLImage(image)
		If Not (pixmapflags&GADGETPIXMAP_NOTEXT) Then Super.SetText(currentText)
		If (pixmapflags&GADGETPIXMAP_ICON) And( (Not (style&7)) Or (style&7=BUTTON_CANCEL)) Then
			If (pixmapflags&GADGETPIXMAP_NOTEXT) Then Super.SetText("")
			flSetImage(WidgetHandle(),image)
		EndIf
	End Method
	
	Method SetSelected(bool)
		If bool And (style&7=BUTTON_RADIO) Then ExcludeOthers()
		flSetButton WidgetHandle(),bool
	End Method
	
	Method SetHotKey(keycode,modifier)
		Super.SetHotKey(keycode,modifier)
		flSetButtonKey WidgetHandle(),flkey
	EndMethod
	
	Method OnCallback()
		If (style&7=BUTTON_RADIO) Then SetButtonState(Self,STATE_SELECTED)
		PostGuiEvent(EVENT_GADGETACTION,Self,State())
	EndMethod
	
	Method ExcludeOthers()
		Local w:TFLWidget
		For w=EachIn parent.kids
			If w<>Self And (w.fltype=FL_ROUNDBUTTON Or w.fltype=FL_RADIOPUSHBUTTON)
				flSetButton w.WidgetHandle(),False
			EndIf
		Next
	End Method
	
EndType

Type TFLTextField Extends TFLGadget
	
	Method InitGadget()
		If (style&TEXTFIELD_PASSWORD) Then fltype=FL_PASSWORD Else fltype=FL_INPUT
		InitWidget()
		flSetWhen( WidgetHandle(), FL_WHEN_CHANGED|FL_WHEN_RELEASE_ALWAYS)
	EndMethod
	
	Method Class()
		Return GADGET_TEXTFIELD
	EndMethod
	
	Method GetText$()
		Return flGetInput(WidgetHandle())
	End Method

	Method SetText(text$)
		flSetInput(WidgetHandle(),text)
	End Method
	
	Method SetFont(font:TGuiFont)
		Super.SetFont(font)
		flSetInputFont WidgetHandle(),Self.font.handle
		flSetInputSize WidgetHandle(),Self.font.GetSizeForFL()
	EndMethod
	
	Method Activate(cmd)
		Select cmd
			Case ACTIVATE_FOCUS
				Super.Activate(cmd)
				flActivateInput(WidgetHandle())
			Default
				Super.Activate(cmd)
		End Select
	End Method
	
	Method OnCallback()
		If flChanged(WidgetHandle()) Then
			PostGuiEvent(EVENT_GADGETACTION,Self)
			flClearChanged(WidgetHandle())
		EndIf
		Select flevent()
			Case FL_UNFOCUS
				PostGuiEvent(EVENT_GADGETLOSTFOCUS,Self)
		End Select
	EndMethod

EndType

Type TFLTextArea Extends TFLGadget

	Field	textr,textg,textb
	Field	locked,lockedpos,lockedlen

	Method InitGadget()
		If (style&TEXTAREA_READONLY) Then fltype=FL_TEXTDISPLAY Else fltype=FL_TEXTEDITOR
		InitWidget()
		flSetBox(WidgetHandle(),FL_THIN_DOWN_BOX,False)
		If (style&TEXTAREA_WORDWRAP) Then flSetWrapMode( WidgetHandle(), True, 0 )
		flSetTextCallback(WidgetHandle(),EditHandler,objhandle)	
	EndMethod
	
	Method Class()
		Return GADGET_TEXTAREA
	EndMethod
	
	Method GetText$()
		Return AreaText(0,-1,TEXTAREA_CHARS)
	End Method

	Method SetText(text$)
		ReplaceText(0,-1,text,TEXTAREA_CHARS)
	End Method
	
	Method Activate(cmd)
		Select cmd
			Case ACTIVATE_FOCUS
				Super.Activate(cmd)
				flActivateText(WidgetHandle())
			Case ACTIVATE_CUT
				flCutText(WidgetHandle())
			Case ACTIVATE_COPY
				flCopyText(WidgetHandle())
			Case ACTIVATE_PASTE
				flPasteText(WidgetHandle())
			Default
				Super.Activate(cmd)
		End Select
	End Method
	
	Method SetTabs(tabs)
'''''		flSetTextTabs( WidgetHandle(),tabs )	'FIXME one of these days...
	End Method

	Method CharAt(line)
		Return flLinePos(WidgetHandle(),line)
	End Method

	Method LineAt(index)
		Return flLineCount(WidgetHandle(),index)
	End Method
	
	Method CharX(char)
		Local x%, y%
		flCharPosXY(WidgetHandle(),char,Varptr x,Varptr y)
		If x Then Return x Else Return -1
	EndMethod
	
	Method CharY(char)
		Local x%, y%
		flCharPosXY(WidgetHandle(),char,Varptr x,Varptr y)
		If y Then Return y Else Return -1
	EndMethod
	
	Field intLastCursorPos = -1, intLastCursorLen = -1
	
	Method CheckCursorPos(pEmitEvent% = True,pOverridePos% = -1)
		Local tmpCursorPos
		If pOverridePos < 0 Then tmpCursorPos = GetCursorPos(TEXTAREA_CHARS) Else tmpCursorPos = pOverridePos
		Local tmpCursorLen = GetSelectionLength(TEXTAREA_CHARS)
		If intLastCursorPos <> tmpCursorPos Or intLastCursorLen <> tmpCursorLen Then
			intLastCursorPos = tmpCursorPos;intLastCursorLen = tmpCursorLen
			If pEmitEvent Then PostGuiEvent(EVENT_GADGETSELECT,Self)
		EndIf
	EndMethod
	
	Method LockText()
		locked:+1
		If locked=1
			lockedpos=GetCursorPos(TEXTAREA_CHARS)
			lockedlen=GetSelectionLength(TEXTAREA_CHARS)
			SetSelection(0,-1,TEXTAREA_CHARS)
		EndIf
	End Method

	Method UnlockText()
		If Not locked Return
		If locked=1
			SetSelection(lockedpos,lockedlen,TEXTAREA_CHARS)
			flRedrawText WidgetHandle(),0,flTextLength(WidgetHandle())
		EndIf
		locked:-1
	End Method
	
	Method flstyle()
		Return flGetTextStyleChar(WidgetHandle(),textr,textg,textb,font.handle,font.GetSizeForFL())
	End Method
		
	Method SetTextColor( r,g,b )
		textr=r;textg=g;textb=b
		flSetEditTextColor(WidgetHandle(),r,g,b)
		flRedrawText WidgetHandle(),0,flTextLength(WidgetHandle())
	End Method

	Method SetFont( font:TGuiFont )
		Self.font=TFLGUIFont(font)
		LockText()
		flSetTextSize WidgetHandle(),Self.font.GetSizeForFL()
		flSetTextFont WidgetHandle(),Self.font.handle
		UnlockText()
	End Method

	Method AreaText$(pos,count,units)
		If units=TEXTAREA_LINES
			count=flLinePos(WidgetHandle(),pos+count)
			pos=flLinePos(WidgetHandle(),pos)
			count:-pos
		EndIf
		Local tmpTextPtr:Byte Ptr = flGetText(WidgetHandle(),pos,count)
		Local tmpText$ = String.FromCString(tmpTextPtr)
		flFreePtr(tmpTextPtr)
		Return tmpText
	End Method
	
	Method AreaLen(units)
		Local count=flTextLength(WidgetHandle())
		If units=TEXTAREA_LINES count=flLineCount(WidgetHandle(),count)
		Return count
	End Method
		
	Method AddText(text$)
		ignore:+1
		Local utf8text:Byte Ptr=text.ToUTF8String()
		flAddText(WidgetHandle(),utf8text)
		MemFree utf8text
		flSelectText WidgetHandle(),flTextLength(WidgetHandle()),0
		CheckCursorPos(False)
		If Not locked flShowPosition(WidgetHandle())		
	End Method

	Method ReplaceText(pos,count,text$,units)
		If units=TEXTAREA_LINES
			count=flLinePos(WidgetHandle(),pos+count)
			pos=flLinePos(WidgetHandle(),pos)
			count:-pos
		EndIf
		ignore:+1
		Local utf8text:Byte Ptr=text.ToUTF8String()
		flReplaceText(WidgetHandle(),pos,count,utf8text)
		MemFree utf8text
		CheckCursorPos(False)
	End Method
	
	Method GetCursorPos(units)
		Local pos=flgetcursorpos(WidgetHandle())
		If units=TEXTAREA_LINES pos=flLineCount(WidgetHandle(),pos)
		Return pos
	End Method
	
	Method GetSelectionLength(units)
		Local n=flgetselectionlen(WidgetHandle())
		If units=TEXTAREA_LINES
			n=flLineCount(WidgetHandle(),flgetcursorpos(WidgetHandle())+n-1)+1-GetCursorPos(TEXTAREA_LINES)
		EndIf
		Return n		
	End Method
	
	Method SetStyle(r,g,b,flags,pos,count,units)	
		Local	style,stext$
		
		LockText()
		style=flGetTextStyleChar(WidgetHandle(),r,g,b,font.flfamily.GetFontID(flags),font.GetSizeForFL())
		If Not style Then RuntimeError "SetStyle failed"
		If units=TEXTAREA_LINES
			count=flLinePos(WidgetHandle(),pos+count)
			pos=flLinePos(WidgetHandle(),pos)
			count:-pos
		EndIf
		If count<0 count=flTextLength(WidgetHandle())-pos
		If count<=0 Return
		stext=rept$(style,count)		
		flReplaceTextStyle WidgetHandle(),pos,count,stext
		UnlockText()
		
	End Method

	Method SetSelection(pos,count,units)	
		If units=TEXTAREA_LINES
			count=flLinePos(WidgetHandle(),pos+count)
			pos=flLinePos(WidgetHandle(),pos)
			count:-pos
			If count<0 count=0
		EndIf
		If count<0 count=flTextLength(WidgetHandle())-pos
		If count<0 Return
		intLastCursorPos = pos;intLastCursorLen = count
		flSelectText WidgetHandle(),pos,count
		CheckCursorPos(False)
		If Not locked flShowPosition(WidgetHandle())
	EndMethod
	
	Method Free()
		Local textbuff:Byte Ptr = Byte Ptr(flFreeTextDisplay( WidgetHandle() ))
		Super.Free()
		If textbuff Then FLDriver.QueueFLDelete(textbuff)
	EndMethod
	
	Method OnCallback()
		
		Local x = fleventx()-AbsoluteX(), y = fleventy()-AbsoluteY()
		
		Select flevent()
			Case FL_PUSH
				If flEventButton()=FL_LEFT_MOUSE Or Not GetSelectionLength(TEXTAREA_CHARS) Then CheckCursorPos()	'EVENT_GADGETSELECT if cursor moved...
			Case FL_RELEASE
				CheckCursorPos()	'EVENT_GADGETSELECT if cursor moved...
				If flEventButton()=FL_RIGHT_MOUSE PostGuiEvent(EVENT_GADGETMENU,Self,0,0,x,y)		'menu button
			Case FL_KEYDOWN
				If Not (style&TEXTAREA_READONLY) And flChanged(WidgetHandle()) Then
					PostGuiEvent(EVENT_GADGETACTION,Self)
				EndIf
				CheckCursorPos()
			Case FL_UNFOCUS
				PostGuiEvent(EVENT_GADGETLOSTFOCUS,Self)
		End Select
	EndMethod
	
	Function EditHandler(pos,inserted,deleted,restyled,ctext:Byte Ptr,obj:Int) "C"
		Local	text$=String.FromCString(ctext)
		Local	textarea:TFLTextArea = TFLTextArea(HandleToObject(obj))
		If textarea Then
			If deleted
				flDeleteTextStyle textarea.WidgetHandle(),pos,pos+deleted
			EndIf
			If inserted
				flInsertTextStyle textarea.WidgetHandle(),pos,rept$(textarea.flstyle(),inserted)
			EndIf
			If textarea.ignore Then textarea.ignore:-1;Return
			If (inserted Or deleted)
				textarea.CheckCursorPos(True,pos+inserted)
				PostGuiEvent(EVENT_GADGETACTION,textarea)
			EndIf
		EndIf
	End Function

	Function Rept$(c,n)
		Local	b:Byte[n]
		memset_ b,c,n
		Return String.FromBytes(b,n)
	End Function

EndType

Type TFLListBox Extends TFLGadget
	
	Field Current = -1
	
	Method InitGadget()
		If (style&LISTBOX_MULTISELECT) Then fltype=FL_MULTIBROWSER Else fltype=FL_BROWSER
		InitWidget()
	EndMethod
	
	Method Class()
		Return GADGET_LISTBOX
	EndMethod
	
	Method SetFont(font:TGuiFont)
		Self.font = TFLGUIFont(font)
		flSetBrowserTextFont WidgetHandle(),Self.font.handle
		flSetBrowserTextSize WidgetHandle(),Self.font.GetSizeForFL()
		Local tmpItem:TGadgetItem
		For Local i% = 0 Until items.length
			tmpItem = TGadgetItem(items[i])
			SetListItem(i,tmpItem.text,tmpItem.tip,tmpItem.icon,tmpItem.extra)
		Next
	EndMethod
	
	Method InsertListItem(index,text$,tip$,icon,extra:Object)
		If icons Then icon  = icons.GetFLImage(icon) Else icon = 0
		flInsertBrowser(WidgetHandle(),index+1,BrowserFormatString()+text,extra,icon)
	End Method
	
	Method SetListItem(index,text$,tip$,icon,extra:Object)
		If icons Then icon = icons.GetFLImage(icon) Else icon = 0
		flSetBrowserItem(WidgetHandle(),index+1,BrowserFormatString()+text,extra,icon)
	End Method
	
	Method RemoveListItem(index)
		flRemoveBrowserItem(WidgetHandle(),index+1)
	End Method
	
	Method SetListItemState(item,state)
		If Not(style&LISTBOX_MULTISELECT) Then
			If state&STATE_SELECTED
				Current=item
				flSelectBrowser(WidgetHandle(),item+1)
			Else
				If Current=item Current=-1
				flSelectBrowser(WidgetHandle(),0)
			EndIf
		Else
			flMultiBrowserSelect(WidgetHandle(),item+1,(state&STATE_SELECTED<>0))
			SelectionChanged()
		EndIf
	End Method

	Method ListItemState(index)
		Local state
		If Not(style&LISTBOX_MULTISELECT) Then
			If flBrowserValue(WidgetHandle())-1=index state:|STATE_SELECTED
		Else
			If flMultiBrowserSelected(WidgetHandle(),index+1) state:|STATE_SELECTED
		EndIf
		Return state
	End Method
	
	Method OnCallback()
		Local x = fleventx()-AbsoluteX(), y = fleventy()-AbsoluteY()
		Local extra:Object, i
		If style&LISTBOX_MULTISELECT <> LISTBOX_MULTISELECT Then
			i=SelectedItem()
			If i>-1 extra=ItemExtra(i)
			If i<>Current
				PostGuiEvent(EVENT_GADGETSELECT,Self,i,0,0,0,extra)
				Current=i
			EndIf
			If flEventButton()=FL_RIGHT_MOUSE
				PostGuiEvent(EVENT_GADGETMENU,Self,i,0,x,y,extra)
			ElseIf flEventButton()=FL_LEFT_MOUSE And flEventClicks() Mod 2
				If i>-1 Then
					PostGuiEvent(EVENT_GADGETACTION,Self,i,0,0,0,extra)
				EndIf
			EndIf
		Else
			i = SelectionChanged()
			If i > -1 Then
				extra = ItemExtra(i)
				PostGuiEvent(EVENT_GADGETSELECT,Self,i,0,0,0,extra)
			ElseIf flEventButton()=FL_LEFT_MOUSE And flEventClicks() Mod 2 Then
				i = flBrowserValue(WidgetHandle())-1
				If i > -1 Then PostGuiEvent(EVENT_GADGETACTION,Self,i,0,0,0,ItemExtra(i))
			EndIf
			If flEventButton()=FL_RIGHT_MOUSE Then
				i = flBrowserValue(WidgetHandle())-1;extra = Null
				If i > -1 Then extra = ItemExtra(i)
				PostGuiEvent(EVENT_GADGETMENU,Self,i,0,x,y,extra)
			EndIf
		EndIf
	EndMethod
	
	Method BrowserFormatString$()
		Local tmpResult$
		Select fltype
			Case FL_BROWSER, FL_MULTIBROWSER
				If font.style&FONT_UNDERLINE Then tmpResult:+"@u"
				If font.style&FONT_STRIKETHROUGH Then tmpResult:+"@-"
				tmpResult:+"@."
		EndSelect
		Return tmpResult
	EndMethod
	
EndType

Type TFLComboBox Extends TFLGadget
	
	Field _lastchoice = -1
	
	Method InitGadget()
		If (style&COMBOBOX_EDITABLE) Then fltype=FL_INPUTCHOICE Else fltype=FL_CHOICE
		InitWidget()
	EndMethod
	
	Method Class()
		Return GADGET_COMBOBOX
	EndMethod
	
	Method GetText$()
		If (style&COMBOBOX_EDITABLE) Then
			Return flGetInput(flGetInputChoiceTextWidget(WidgetHandle()))
		Else
			If _lastchoice > -1 Then Return GadgetItemText(Self,_lastchoice)
		EndIf
	EndMethod
	
	Method SetText(text$)
		If style&COMBOBOX_EDITABLE Then flSetInput(flGetInputChoiceTextWidget(WidgetHandle()),text)
	EndMethod
	
	Method InsertListItem(index,text$,tip$,icon,extra:Object)
		Local m:TFLMenu = New TFLMenu
		GetMenu()
		menu.owner=Self
		m.text=text
		menu.addmenu m
		Local count,flmenu Ptr
		count=menu.count(-1)
		flmenu=flCreateMenu(count+2,CallbackHandler)
		menu.setflmenu(flmenu)
		If style&COMBOBOX_EDITABLE Then flSetMenu(flGetInputChoiceMenuWidget(WidgetHandle()),flmenu) Else flSetMenu(WidgetHandle(),flmenu)
	End Method
	
	Method SetListItem(index,text$,tip$,icon,extra:Object)
		'Save current selection
		Local selection = SelectedGadgetItem(Self)
		GetMenu()
		'Update item
		Local m:TFLMenu = menu.mkids[index]
		m.text=text
		'Create a new menu
		Local count,flmenu Ptr
		count=menu.count(-1)
		flmenu=flCreateMenu(count+2,CallbackHandler)
		menu.setflmenu(flmenu)
		'Apply new menu
		If style&COMBOBOX_EDITABLE Then flSetMenu(flGetInputChoiceMenuWidget(WidgetHandle()),flmenu) Else flSetMenu(WidgetHandle(),flmenu)
		'Restore selection
		If selection > -1 Then SelectGadgetItem(Self, selection)
	End Method
	
	Method RemoveListItem(index)
		Local m:TFLMenu
		GetMenu()
		menu.owner=Self
		menu.removemenu index
		Local count,flmenu Ptr
		count=menu.count(-1)
		flmenu=flCreateMenu(count+2,CallbackHandler)
		menu.setflmenu(flmenu)
		If style&COMBOBOX_EDITABLE Then flSetMenu(flGetInputChoiceMenuWidget(WidgetHandle()),flmenu) Else flSetMenu(WidgetHandle(),flmenu)
	End Method
	
	Method SetListItemState(item,state)
		If Not(style&COMBOBOX_EDITABLE) Then
			If state&STATE_SELECTED Then flSetChoice(WidgetHandle(),item)
		Else
			If state&STATE_SELECTED Then flSetInputChoice(WidgetHandle(),item)
		EndIf
	End Method

	Method ListItemState(index)
		Local state
		If Not(Style&COMBOBOX_EDITABLE) Then
			If flGetChoice(WidgetHandle())=index state:|STATE_SELECTED
		Else
			If _lastchoice=index state:|STATE_SELECTED
		EndIf
		Return state
	End Method
	
	Method OnCallback()
		Select flevent()
			Case FL_KEYDOWN
				Local text$ = fleventtext()
				If text Then
					_lastchoice = -1
					PostGuiEvent(EVENT_GADGETACTION,Self,_lastchoice)
				EndIf
			Case FL_UNFOCUS
				PostGuiEvent(EVENT_GADGETLOSTFOCUS,Self)
		End Select
	EndMethod
	
EndType

Type TFLTabber Extends TFLGadget
	
	Const TABBODY_SPACING = 5
	
	Field	tabpanels:TFLWidget[]
	Field	selectedtab = -1
	
	'WARNING: TFLTabber is in a very fragile state in order to acquire the correct positioning
	'of gadgets.
	
	Method InitGadget()
		
		fltype = FL_TABS
		InitWidget()
		
		SetOrigin(1,20+TABBODY_SPACING)
		
		client=New TFLPanel.CreateGadget("",0,0,ClientWidth(),ClientHeight(),Self,0)
		client.SetLayout EDGE_ALIGNED,EDGE_ALIGNED,EDGE_ALIGNED,EDGE_ALIGNED
		
		RemoveChild(client)
		
	EndMethod
	
	Method Class()
		Return GADGET_TABBER
	EndMethod
	
	Method ClientWidth()
		Return Max(width-originx,0)
	EndMethod
	
	Method ClientHeight()
		Return Max(height-originy,0)
	EndMethod
	
	Method OnCallback()
		Local selhandle=flGetTabPanel(WidgetHandle())
		Local eventhandle=flGetTabPanelForEvent(WidgetHandle())
		Local x = fleventx()-AbsoluteX(), y = fleventy()-AbsoluteY()
		For Local panel:TFLWidget=EachIn tabpanels
			If panel.WidgetHandle()=selhandle Then
				If panel.tag<>selectedtab
					SetListItemState panel.tag, STATE_SELECTED
					PostGuiEvent(EVENT_GADGETACTION,Self,panel.tag,0,0,0,ItemExtra(panel.tag))
				EndIf
			EndIf
			If panel.WidgetHandle()=eventhandle
				Select flevent()
					Case FL_PUSH
						If flEventButton() = FL_RIGHT_MOUSE Then
							PostGuiEvent(EVENT_GADGETMENU,Self,panel.tag,0,x,y,ItemExtra(panel.tag))
						EndIf
				EndSelect
			EndIf
		Next
	EndMethod
	
	Method InsertListItem(index,text$,tip$,icon,extra:Object)
		Local panel:TFLWidget,x,y,w,h,client:TFLWidget = Self.client
		'Make sure that we attach the tab panel to the tabber (not the client).
		Self.client = Null
		panel=TFLWidget(New TFLWidget.CreateWidget(FL_GROUP,text,0,-TABBODY_SPACING,ClientWidth(),ClientHeight()+TABBODY_SPACING,Self,-1,FL_NO_BOX))
		'Make sure tab panels are resized first by LayoutKids().
		'If we don't do this, and children are added before tab panels,
		'the children don't may not drawn correctly (if at all).
		kids.Remove(panel);kids.AddFirst(panel)
		'After creating the tab panel, we can restore the client area for user gadgets.
		Self.client = client
		'Set the tabpanel options
		If tooltip Then panel.SetTooltip tip$
		panel.SetOrigin(0,TABBODY_SPACING)
		panel.SetLayout EDGE_ALIGNED,EDGE_ALIGNED,EDGE_ALIGNED,EDGE_ALIGNED
		panel.tag=index
		'Position the tab panel in the indexed array
		tabpanels = tabpanels[..index]+[panel]+tabpanels[index..]
		For Local i% = index+1 Until tabpanels.length
			tabpanels[i].tag:+1
		Next
		'And update the selected tab if necessary
		If selectedtab < 0 Then selectedtab = index ElseIf index < selectedtab Then selectedtab:+1
		Local tmpSelection% = selectedtab
		'Select new tab so that is correctly handled by Fl_Tabs
		selectedtab = -1;SetListItemState index,STATE_SELECTED
		'And then restore selection to the previous tab
		SetListItemState tmpSelection,STATE_SELECTED
	End Method

	Method SetListItemState(index,state)
		If state&STATE_SELECTED Then
			Local indextab:TFLWidget = tabpanels[index]
			If selectedtab<>index
				selectedtab=index
				indextab.AddChild client
				client.SetShape( 0, 0, ClientWidth(), ClientHeight() )
				LayoutKids()
				flSelectTab WidgetHandle(),indextab.WidgetHandle()
			EndIf
		EndIf
	End Method
	
	Method ListItemState(index)
		Local tmpState
		If index = selectedtab Then tmpState:|STATE_SELECTED
		Return tmpState
	End Method
	
	Method SetListItem(index,text$,tip$,icon,extra:Object)
		Local indextab:TFLWidget = tabpanels[index]
		If indextab Then
			indextab.SetText(text)
			indextab.SetTooltip(tip)
			'If icon>0 Then
			'	indextab.SetPixmap(PixmapFromIconStrip(icons,icon),GADGETPIXMAP_ICON)
			'Else
			'	indextab.SetPixmap(Null,GADGETPIXMAP_ICON)
			'EndIf
			SetDirty()
		EndIf
	End Method
	
	Method RemoveListItem(index)
		Local	indextab:TFLWidget
		Local	panels:TFLWidget[]
		Local	i
		indextab=tabpanels[index]
		If Not indextab Then Return
		If index = selectedtab Then indextab.RemoveChild client
		' free widget
		indextab.free()
		' remove from array
		panels=tabpanels
		tabpanels=tabpanels[..tabpanels.length-1]
		For i=index Until tabpanels.length
			tabpanels[i]=panels[i+1]
			tabpanels[i].tag=i
		Next
		index=Min(index,tabpanels.length-1)
		If index<>-1 SetListItemState index, STATE_SELECTED
		If parent RedrawGadget parent 'parent.Redraw'SetDirty
	End Method
	
EndType

Type TFLTreeview Extends TFLGadget

	Field	root:TFLNode
	
	Method InitGadget()
		fltype = FLU_TREEBROWSER
		InitWidget()
	EndMethod
	
	Method Class()
		Return GADGET_TREEVIEW
	EndMethod
	
	Method RootNode:TFLNode()	
		If Not root
			root=New TFLNode
			root.owner=Self
			root.nodehandle = fluRootNode(WidgetHandle())
			kids.AddLast root
		EndIf
		Return root
	End Method
	
	Method SelectNode(node:TFLNode)
		fluSelectNode(node.nodehandle)
	End Method
	
	Method SelectedNode:TGadget()
		Local tmpNodeHandle:Int = fluSelectedNode(WidgetHandle(),1)	'Base 1 for some reason
		If tmpNodeHandle Then
			Local tmpNode:TFLNode = TFLNode.FromHandle(tmpNodeHandle)
			If tmpNode <> RootNode() Then Return tmpNode
		EndIf
	End Method
	
	Field _lastButtonPressed:Int
	
	Method OnMouse:Int()
		Local tmpButton:Int = flEventButton()
		Select flEvent()
				Case FL_PUSH
					_lastButtonPressed = tmpButton
					If tmpButton = FL_RIGHT_MOUSE Then
						PostGuiEvent EVENT_GADGETMENU, Self, tmpButton-1, flStateToModifiers(flEventState()), flEventX()-AbsoluteX(), flEventY()-AbsoluteY(), SelectedNode()
					EndIf
				Case FL_DRAG
					If (style&TREEVIEW_DRAGNDROP) And Not dragGadget[_lastButtonPressed-1] Then
						dragGadget[_lastButtonPressed-1] = SelectedNode()
						PostGuiEvent EVENT_GADGETDRAG, Self, _lastButtonPressed, flStateToModifiers(flEventState()), flEventX()-AbsoluteX(), flEventY()-AbsoluteY(), dragGadget[_lastButtonPressed-1]
					EndIf
		EndSelect

		Super.OnMouse()
	EndMethod
	
	Method OnCallback()
		Local intReason% = fluCallbackReason( WidgetHandle() )
		Local tmpNode:TFLNode = TFLNode.FromHandle(fluCallbackNode( WidgetHandle() ))
		Select intReason
			Case FLU_OPENED;PostGuiEvent EVENT_GADGETOPEN, Self, 0, 0, 0, 0, tmpNode
			Case FLU_CLOSED;PostGuiEvent EVENT_GADGETCLOSE, Self, 0, 0, 0, 0, tmpNode
			Case FLU_SELECTED, FLU_DOUBLE_CLICK
				If intReason = FLU_SELECTED Then
					PostGuiEvent EVENT_GADGETSELECT, Self, 0, 0, 0, 0, tmpNode
				Else
					PostGuiEvent EVENT_GADGETACTION, Self, 0, 0, 0, 0, tmpNode
				EndIf
		EndSelect
	EndMethod
	
EndType


Type TFLNode Extends TFLWidget

	Field owner:TFLTreeview, nodehandle%
	Field text$, icon = -1, textmem:Byte Ptr

	Method Delete()
		Free()
	End Method

	Method GetText$()
		Return text
	End Method

	Method SetText(newtext$)
		Local tmpIcon
		If textmem Then MemFree textmem;textmem = Null
		text = newtext
		textmem = text.ToCString()
		If icon >= 0 And owner.icons Then tmpIcon = owner.icons.images[icon] Else tmpIcon = 0
		If nodehandle Then fluSetNode( nodehandle, textmem, tmpicon )
	End Method

	Method InsertNode:TGadget(pos,text$,icon)
		
		Local	n:TFLNode, l:TLink
		
		If pos >= 0 And pos < kids.count()
			n=TFLNode(kids.ValueAtIndex(pos))
			l=kids.FindLink(n)
		EndIf
		
		n=New TFLNode
		n.parent=Self
		n.owner=owner
		n.icon=icon
		
		If l Then
			n.nodehandle = fluInsertNode( nodehandle, pos, inittext )
			fluSetNodeUserData( n.nodehandle, n.objhandle )
			kids.InsertBeforeLink n,l
		Else
			n.nodehandle = fluAddNode( nodehandle, inittext )
			fluSetNodeUserData( n.nodehandle, n.objhandle )
			kids.AddLast n
		EndIf
		
		If LocalizationMode() & LOCALIZATION_OVERRIDE Then
			LocalizeGadget(n,text)
		Else
			n.SetText(text)
		EndIf
		
		Return n
		
	End Method

	Method Free()
		If Not nodehandle Then Return	'Make sure we don't free twice
		Super.Free()
		fluSetNodeUserData( nodehandle, 0 )
		fluRemoveNode( owner.WidgetHandle(), nodehandle )
		If textmem Then MemFree textmem;textmem = Null
		If owner And owner.root <> Self Then	'If not TreeViewRoot()
			owner = Null;nodehandle = 0
		EndIf
	End Method
	
	Method ModifyNode(text$,icon)
		Self.icon = icon;SetText(text)
	End Method

	Method Activate(cmd)
		Select cmd
			Case ACTIVATE_SELECT
				Local tmpParent:TFLNode = TFLNode(parent)
				While tmpParent
					tmpParent.Activate(ACTIVATE_EXPAND)
					tmpParent = TFLNode(tmpParent.parent)
				Wend
				fluSelectNode( nodehandle )
			Case ACTIVATE_EXPAND
				fluExpandNode( nodehandle, False )
			Case ACTIVATE_COLLAPSE
				fluExpandNode( nodehandle, True )
		End Select
	End Method
	
	Method Class()
		Return GADGET_NODE
	EndMethod
	
	Function FromHandle:TFLNode(nodehandle)
		If nodehandle Then Return TFLNode(HandleToObject(fluNodeUserData( nodehandle )))
	EndFunction
	
	Method SetTooltip(tooltip$)
		'Do nothing - nodes don't support tooltips (yet).
	EndMethod
	
End Type


Type TFLSlider Extends TFLGadget
	
	'Spinner controls
	Field minimum = 1, maximum = 10
	Field spinval = minimum
	Field up:TFLWidget, down:TFLWidget
	
	Method InitGadget()
		If (style&SLIDER_TRACKBAR) = SLIDER_TRACKBAR Then
			fltype = FL_SLIDER
		ElseIf (style&SLIDER_STEPPER) = SLIDER_STEPPER Then
			fltype = FL_GROUP
		Else
			fltype = FL_SCROLLBAR
		EndIf
		InitWidget()
		If (style&SLIDER_STEPPER) = SLIDER_STEPPER Then
			If (style&SLIDER_HORIZONTAL)
				up = New TFLSpinButton.CreateWidget(FL_REPEATBUTTON,"@#>",width/2,0,width/2,height,Self)
				SetGadgetLayout up,EDGE_RELATIVE,EDGE_ALIGNED,EDGE_ALIGNED,EDGE_ALIGNED
				down = New TFLSpinButton.CreateWidget(FL_REPEATBUTTON,"@#<",0,0,width/2,height,Self)
				SetGadgetLayout down,EDGE_ALIGNED,EDGE_RELATIVE,EDGE_ALIGNED,EDGE_ALIGNED
			Else
				up = New TFLSpinButton.CreateWidget(FL_REPEATBUTTON,"@#2<",0,0,width,height/2,Self)
				SetGadgetLayout up,EDGE_ALIGNED,EDGE_ALIGNED,EDGE_ALIGNED,EDGE_RELATIVE
				down = New TFLSpinButton.CreateWidget(FL_REPEATBUTTON,"@#2>",0,height/2,width,height/2,Self)
				SetGadgetLayout down,EDGE_ALIGNED,EDGE_ALIGNED,EDGE_RELATIVE,EDGE_ALIGNED
			EndIf
		Else
			If (style&SLIDER_HORIZONTAL) Then flSetSliderType WidgetHandle(),FL_HOR_SLIDER
		EndIf
	EndMethod
	
	Method Class()
		Return GADGET_SLIDER
	EndMethod
	
	Method SetRange(small,big)
		If (style&SLIDER_STEPPER) = SLIDER_STEPPER Then
			minimum = small
			maximum = big
			SetProp(spinval)
		ElseIf fltype=FL_SCROLLBAR Then
			flSetScrollbarValue WidgetHandle(), GetProp(), small, 0, big
		Else
			flSetSliderRange WidgetHandle(),small,big
		EndIf
	End Method
	
	Method SetProp(value)
		If (style&SLIDER_STEPPER) = SLIDER_STEPPER Then
			spinval = Min( Max( value, minimum ), maximum )
		Else
			flSetSliderValue WidgetHandle(),value
		EndIf
	End Method
	
	Method GetProp()
		If (style&SLIDER_STEPPER) = SLIDER_STEPPER Then
			Return spinval
		Else
			Return flSliderValue(WidgetHandle())
		EndIf
	End Method
	
	Method OnSpin(pSource:TFLWidget)
		Local tmpNewVal = spinval
		Select pSource
			Case up;tmpNewVal:+1
			Case down;tmpNewVal:-1
		EndSelect
		tmpNewVal = Min( Max( tmpNewVal, minimum ), maximum )
		If tmpNewVal <> spinval Then
			spinval = tmpNewVal
			OnCallback()
		EndIf
	EndMethod
	
	Method OnCallback()
		PostGuiEvent(EVENT_GADGETACTION,Self,GetProp())
	EndMethod
	
EndType

Type TFLSpinButton Extends TFLWidget
	
	Method Class()
		Return GADGET_SLIDER
	EndMethod
	
	Method OnCallback()
		TFLSlider(parent).OnSpin(Self)
	EndMethod
	
	Const SYMBOL_WIDTH% = 13, SYMBOL_HEIGHT = 7
	
	Method Rethink()
		'Attempts to resizes arrow heads in line with dimensions
		Local scaletxt$, text$ = GetText()[2..]
		'Strip current size info from arrow label string
		If text[..1] = "+" Or text[..1] = "-" Then text = text[2..]
		'Calculate the most suitable scaling
		Local scale# = Min( width, height )
		scale:/ Max( SYMBOL_WIDTH, SYMBOL_HEIGHT )
		'Sort out the sign of the scaling
		If Int(scale) < 1 Then
			scale = 1/scale
			scaletxt = "-"
		ElseIf Int(scale) > 1 Then
			scale:-1
			scaletxt = "+"
		Else
			scale = 0
		EndIf
		'And clamp the value to a single digit
		scale = Min(scale,9)
		'Then, if we need to scale, lets set the label accordingly
		If Int(scale) >= 1 Then text = scaletxt + Int(scale) + text
		SetText( "@#"+text )
		Super.Rethink()
	EndMethod
	
EndType

Type TFLProgBar Extends TFLGadget
	
	Method InitGadget()
		fltype=FL_PROGBAR
		InitWidget()
	EndMethod
	
	Method Class()
		Return GADGET_PROGBAR
	EndMethod
	
	Method SetValue(value#)
		flSetProgress WidgetHandle(),value
		parent.activate ACTIVATE_REDRAW
	End Method
	
EndType

Type TFLPanel Extends TFLGadget
'TFLCanvas, TFLToolbar and TFLToolbarItem extend TFLPanel
	
	Method InitGadget()
		fltype = FL_PANEL
		InitWidget()
		Select style&(PANEL_GROUP|PANEL_SUNKEN|PANEL_RAISED)
			Case 0;flSetBox WidgetHandle(), FL_NO_BOX, False
			Case PANEL_SUNKEN;flSetBox WidgetHandle(), FL_DOWN_FRAME, False
			Case PANEL_RAISED;flSetBox WidgetHandle(), FL_UP_FRAME, False
			Default;SetOrigin(4,18)
		EndSelect
		If (style&PANEL_ACTIVE) Then SetSensitivity(SENSITIZE_ALL)
	EndMethod
	
	Method Class()
		Return GADGET_PANEL
	EndMethod
	
	Method SetEnabled(truefalse)
		Super.SetEnabled(truefalse)
		flSetPanelEnabled WidgetHandle(),truefalse
	EndMethod
	
	Method Rethink()
		SetFLImage(image)
		Super.Rethink()
	EndMethod
	
	Method SetFLImage(image)
		Self.image = image
		flSetPanelImage(WidgetHandle(),image,pixmapflags)
	End Method
	
	Method SetColor( r,g,b )
		flSetPanelColor(WidgetHandle(),r,g,b)
		Redraw()
	End Method
	
	Method SetSensitivity(pSensitivity%)
		Super.SetSensitivity(pSensitivity)
		flSetPanelActive WidgetHandle(), (GetSensitivity()<>0)
	EndMethod
	
	Method OnMouse()
		Select flevent()
			Case FL_PUSH
				flSetFocus(Query(QUERY_FLWIDGET_CLIENT))
		EndSelect
		Super.OnMouse()
	EndMethod
	
EndType

Type TFLCanvas Extends TFLPanel
	
	Field driver$
	Field canvas:TGraphics
	Field canvasflags
	
	Method InitGadget()
		fltype=FL_CANVAS
		InitWidget()
		flSetCanvasMode WidgetHandle(),DefaultGraphicsFlags()
		SetSensitivity(SENSITIZE_ALL)
		SetShow(True)
	EndMethod
	
	Method Class()
		Return GADGET_CANVAS
	EndMethod
	
	Method SetText(text$)
		driver=text
	EndMethod
	
	Method GetText$()
		Return driver
	EndMethod
	
	Method AttachGraphics:TGraphics( flags )
		canvasflags=flags
		?MacOS
		canvas=brl.Graphics.AttachGraphics( NSContentView(flCanvasWindow(WidgetHandle())),flags )
		?Not MacOS
		canvas=brl.Graphics.AttachGraphics( flCanvasWindow(WidgetHandle()),flags )
		?
	End Method
	
	Method CanvasGraphics:TGraphics()
		Return canvas
	End Method
	
	Method SetShow(truefalse)
		flSetShow(WidgetHandle(),truefalse)
	End Method
	
	Method Free()
		Super.Free()
		If canvas
			canvas.Close()
			canvas=Null
		EndIf
	EndMethod
	
	Method SetFLImage(image)
	EndMethod
	
	Method SetColor(r,g,b)
	EndMethod
	
	Method OnCallback()
		Select flevent()
			Case FL_ACTIVATE
				?MacOS
				NSUpdateCanvas(flCanvasWindow(WidgetHandle()))
				?
				PostGuiEvent EVENT_GADGETPAINT,Self
		End Select
		Super.OnCallback()
	EndMethod
			
End Type

Type TFLToolbar Extends TFLGadget
	
	Method InitGadget()
		Local tmpClient:TFLWidget = TFLWidget(parent).client
		TFLWidget(parent).client = Null
		fltype=FL_TOOLBAR
		InitWidget()
		TFLWidget(parent).client = tmpClient
		flSetBox(WidgetHandle(),FL_NO_BOX,False)
		LayoutToolbar()
		SetLayout(EDGE_ALIGNED,EDGE_CENTERED,EDGE_ALIGNED,EDGE_CENTERED)
	EndMethod
	
	Method Class()
		Return GADGET_TOOLBAR
	EndMethod
	
	Method AbsoluteX()
		Local tmpValue:Int = Super.AbsoluteX()
		If TFLWidget(parent) Then tmpValue:-TFLWidget(parent).originx
		Return tmpValue
	End Method	
			
	Method AbsoluteY()
		Local tmpValue:Int = Super.AbsoluteY()
		If TFLWidget(parent) Then tmpValue:-TFLWidget(parent).originy
		Return tmpValue
	End Method	
	
	Method SetShow(truefalse)
		If truefalse ~ ((State() & STATE_HIDDEN) = 0) Then
			Super.SetShow(truefalse)
			LayoutToolbar()
		EndIf
	EndMethod
	
	Method SetLayout(Left,Right,top,bottom)
		Super.SetLayout(EDGE_ALIGNED,EDGE_CENTERED,EDGE_ALIGNED,EDGE_CENTERED)
	EndMethod
	
' toolbar specific
	
	Method SetListItemState(index,state)
		Local item:TFLToolbarItem = ToolPanel(index)
		If item Then
			If state&STATE_SELECTED Then item.toggled = True Else item.toggled = False
			item.SetEnabled( Not (state&STATE_DISABLED) )
			item.Redraw()
		EndIf
	End Method

	Method ListItemState(index)
		Local state, item:TFLToolbarItem = ToolPanel(index)
		If item
			If item.State() & STATE_DISABLED Then state:|STATE_DISABLED
			If item.toggled Then state:|STATE_SELECTED			
		EndIf
		Return state
	End Method

	Method InsertListItem(index,text$,tip$,icon,extra:Object)
		' bump button panel indexes
		For Local item:TFLToolbarItem = EachIn kids	
			If item.tag>=index item.tag:+1
		Next
		SetListItem index,text,tip,icon,extra
	End Method
	
	Method RemoveListItem(index)
		Local item:TFLToolbarItem = ToolPanel(index)
		If item Then
			item.CleanUp()
			For Local tmpToolPanel:TFLToolbarItem = EachIn kids
				If tmpToolPanel.tag > index Then tmpToolPanel.tag:-1
			Next
			LayoutToolBar()
		EndIf
	EndMethod
	
	Method GetBestHeight()
		If icons Then Return icons.pixmap.height+6
	EndMethod
	
	Method SetListItem(index,text$,tip$,icon,extra:Object)
		
		Local image, item:TFLToolbarItem = ToolPanel(index)
		
		If icons Then image = icons.GetFLImage(icon)
		
		If Not item Then
			item=TFLToolbarItem(New TFLToolbarItem.CreateGadget("",0,0,TFLToolbarItem.DIVIDER_WIDTH,GetBestHeight(),Self,PANEL_ACTIVE))
			item.SetLayout EDGE_ALIGNED,EDGE_CENTERED,EDGE_ALIGNED,EDGE_CENTERED
			item.tag=index
		EndIf
		
		item.SetFLImage image
		item.SetToolTip tip
		
		If image Then item.MakeIcon() Else item.MakeDivider()
		
		LayoutToolBar()
		
	End Method
	
	Method ToolPanel:TFLToolbarItem(index)
		For Local panel:TFLToolbarItem=EachIn kids
			If panel.tag=index Return panel
		Next
	End Method
	
	Method SetIconStrip( iconstrip:TIconStrip )
		Super.SetIconStrip(iconstrip)
		For Local i:Int = 0 Until items.length
			ModifyGadgetItem( Self, i, items[i].text, items[i].flags, items[i].icon, items[i].tip, items[i].extra )
		Next
		LayoutToolbar()
	EndMethod
	
	Method SetShape(x,y,w,h)
		LayoutToolbar()
	EndMethod
	
	Method Free()
		SetShow(False)
		Super.Free()
	EndMethod
	
	Method LayoutToolBar()
		Local	item:TGadgetItem
		Local	x = 4, y= 4, w, h = GetBestHeight(), index
		Local	panel:TFLToolbarItem
		For item=EachIn items
			panel=ToolPanel(index)
			If panel
				w=panel.width
				panel.SetShape x+1,y,w,h
				x:+w+2
			EndIf
			index:+1
		Next
		If (State() & STATE_HIDDEN) Then h = 0 Else If items h:+8
		If height <> h Then
			TFLWidget(parent).SetOrigin(TFLWidget(parent).originx,TFLWidget(parent).originy-height+h)
			parent.Rethink()
		EndIf
		Super.SetShape 0,0,x+60,h
	End Method
	
EndType

Type TFLToolbarItem Extends TFLPanel
	
	Const DIVIDER_WIDTH:Int = 2
	
	Field toggled = False
	
	Method AbsoluteX()
		Return TFLWidget(parent).AbsoluteX() + xpos
	End Method	
	
	Method AbsoluteY()
		Return TFLWidget(parent).AbsoluteY() + ypos
	End Method
	
	Method Class()
		Return GADGET_TOOLBAR
	EndMethod
	
	Method SetEnabled(bool)
		Super.SetEnabled(bool)
		If Not bool Then flSetBox( WidgetHandle(), FL_NO_BOX, False )
	EndMethod
	
	Method Free()
		'Stop Super.Free() from deleting an image that belongs to an icon-strip.
		image = 0
		'Now we can safely call Super.Free()
		Super.Free()
	EndMethod
	
	Method SetFLImage(image)
		pixmapflags = PANELPIXMAP_CENTER
		Super.SetFLImage(image)
	EndMethod
	
	Method IsDivider()
		Return (width <= DIVIDER_WIDTH)
	EndMethod
	
	Method MakeDivider()
		SetRect(xpos,ypos,DIVIDER_WIDTH,height)
		flSetBox( WidgetHandle(), FL_EMBOSSED_FRAME, False)
	EndMethod
	
	Method MakeIcon()
		SetRect(xpos,ypos,height,height)
		flSetBox( WidgetHandle(), FL_NO_BOX, False)
	EndMethod
	
	Method OnMouse()
		
		Local x = fleventx()-AbsoluteX(), y = fleventy()-AbsoluteY()
		
		If activepanel And (activepanel<>Self) Then
			activepanel.OnMouseLeave()
			activepanel = Null
		EndIf
		
		If Not ((State()&STATE_DISABLED) Or IsDivider()) And flEventButton() = FL_LEFT_MOUSE Then	'Not disabled
			Select flevent()
				Case FL_PUSH
					flSetBox( WidgetHandle(), FL_THIN_DOWN_BOX, True )
				Case FL_MOVE
					If activepanel <> Self Then
						flSetBox( WidgetHandle(), FL_THIN_UP_BOX, True )
						activePanel = Self
					EndIf
				Case FL_DRAG
					If x < width And y < height And x > 0 And y > 0 Then
						flSetBox( WidgetHandle(), FL_THIN_DOWN_BOX, True )
					Else
						flSetBox( WidgetHandle(), FL_NO_BOX, True )
					EndIf
				Case FL_RELEASE
					If x < width And y < height And x > 0 And y > 0 Then
						Local item=tag&$ffff, flags=parent.ItemFlags(item)
						If flags&GADGETITEM_TOGGLE Then parent.SelectItem(item,2)
						PostGuiEvent(EVENT_GADGETACTION,parent,item,0,0,0)
					EndIf
					flSetBox( WidgetHandle(), FL_THIN_UP_BOX, True )
				Default
					Return
			EndSelect
		EndIf
		
	EndMethod
	
	Method OnMouseLeave()
		flSetBox( WidgetHandle(), FL_NO_BOX, True )
	EndMethod
	
EndType

Type TFLHTMLView Extends TFLGadget
	
	Field currenturl$
	Field history:TList
	Field historylink:TLink
	Field hpos:TList
	Field hposlink:TLink
	
	Method InitGadget()
		fltype=FL_HELPVIEW
		InitWidget()
		flSetBox( WidgetHandle(), FL_THIN_DOWN_BOX, False )
		flSetStyleView( WidgetHandle(), style )
	EndMethod
	
	Method Class()
		Return GADGET_HTMLVIEW
	EndMethod
	
	Method GetText$()
		Return currenturl$
	EndMethod
	
	Method SetText(text$)
		SetURL(text)
	EndMethod
	
	Method Activate(cmd)
		Select cmd
			Case ACTIVATE_FORWARD
				ForwardURL()
			Case ACTIVATE_BACK
				BackURL()
			Default
				Super.Activate(cmd)
		End Select
	End Method
	
	Method OnCallback()
		RequestURL(flEventURL())
	EndMethod
		
	Method CleanHTML$(src$)
		Return src
	End Method
	
	Method RequestURL(path$)
		Local	curr$, lpath$
		
		If Not path Return
		path=path.Replace("\","/")		
		curr="file:"+CurrentDir()
		If path[..curr.length]=curr
			path=ExtractDir(currenturl)+path[curr.length..]
		EndIf
		
		lpath = path.ToLower()
		
		Select ExtractExt$(lpath)
			Case "png","jpg","jpeg","gif","bmp"
				flRedirectView WidgetHandle(),path
			Default
				PostGuiEvent(EVENT_GADGETACTION,Self,0,0,0,0,path)
				If Not (style & HTMLVIEW_NONAVIGATE) ' markcw
					If lpath.StartsWith("ftp:") Or lpath.StartsWith("http:")..
					Or lpath.StartsWith("https:") Or lpath.StartsWith("ipp:")..
					Or lpath.StartsWith("mailto:") Or lpath.StartsWith("news:")
						OpenURL path
					EndIf
				EndIf
		End Select
	End Method

	Method BackURL()
		If historylink And historylink.PrevLink()
			historylink=historylink.PrevLink()
			If hposlink
				hposlink._value=String(flGetLineView(flhandle))
				If hposlink.PrevLink() hposlink=hposlink.PrevLink()
				SetURL String(historylink.Value()),False
			EndIf
		EndIf
	End Method
	
	Method ForwardURL()
		If historylink And historylink.NextLink()
			historylink=historylink.NextLink()
			If hposlink
				hposlink._value=String(flGetLineView(flhandle))
				If hposlink.NextLink() hposlink=hposlink.NextLink()
				SetURL String(historylink.Value()),False
			EndIf
		EndIf
	End Method

	Method SetURL(path$,addhistory=True)
		Local	stream:TStream
		Local	hash,anchor$
		Local	html$,script=0

		If addhistory
			currenturl=flGetPathView(flhandle)
			If Not flIsLinkView(flhandle) currenturl=path
			If currenturl.find("#")<>-1 path=currenturl
			If hposlink hposlink._value=String(flGetLineView(flhandle))
			If currenturl.StartsWith("javascript:history.back()")
				If historylink And historylink.PrevLink()
					historylink=historylink.PrevLink()
					hposlink=hposlink.PrevLink()
				EndIf
				If historylink path=String(historylink.Value())
				script=1
			ElseIf currenturl.StartsWith("javascript:history.forward()")
				If historylink And historylink.NextLink()
					historylink=historylink.NextLink()
					hposlink=hposlink.NextLink()
				EndIf
				If historylink path=String(historylink.Value())
				script=1
			ElseIf currenturl.StartsWith("javascript:history.go(")
				If currenturl[22..23] = "-"
					If historylink And historylink.PrevLink()
						historylink=historylink.PrevLink()
						hposlink=hposlink.PrevLink()
					EndIf
				Else
					If historylink And historylink.NextLink()
						historylink=historylink.NextLink()
						hposlink=hposlink.NextLink()
					EndIf
				EndIf
				If historylink path=String(historylink.Value())
				script=1
			EndIf
			If Not path Return False
		EndIf
		
		currenturl=path
		flSetPathView(flhandle,currenturl)
		If path[..5]="file:" path=path[5..]
		hash=path.find("#")
		If hash<>-1
			anchor=path[hash+1..]
			path=path[..hash]
		EndIf
		stream=ReadStream(path)
		If stream
			html=LoadString(stream)
			CloseStream stream
			html=CleanHTML(html)
		EndIf
		
		flSetView(flhandle,html)
		If addhistory And (Not script)
			If anchor flSeekView(flhandle,anchor)
			If Not history history=New TList
			While historylink And historylink.NextLink()
				historylink.NextLink().Remove
			Wend
			historylink=history.AddLast(currenturl)
			If Not hpos hpos=New TList
			While hposlink And hposlink.NextLink()
				hposlink.NextLink().Remove
			Wend
			hposlink=hpos.AddLast(String(flGetLineView(flhandle)))
		Else
			flSetLineView(flhandle,Int(String(hposlink.Value())))
		EndIf
		Return True
	End Method
	
	Function ViewHandler:Byte Ptr(flhandle,uri:Byte Ptr) "C"
		Return Null
	End Function
	
EndType

Type TFLMenu Extends TFLWidget
	
	Field text$
	Field owner:TFLGadget
	Field mparent:TFLMenu
	Field mkids:TFLMenu[]
	Field checked,disabled,divider,check
	Field index
	Field flshortcut
	
	Method Delete()
		Free()
	EndMethod
	
	Method Class()
		Return GADGET_MENUITEM
	EndMethod
	
	Function CreateMenu:TFLMenu( text$,tag,parent:TFLMenu )
		Local	m:TFLMenu = New TFLMenu
		m.text=text
		m.tag=tag
		If parent
			m.parent=parent
			parent.AddMenu m
		EndIf
		If LocalizationMode() & LOCALIZATION_OVERRIDE Then LocalizeGadget(m,text)
		Return m
	End Function
	
	Method OnCallback()
		Local m:TFLMenu = Self
' choice menu
		While (m)
			If TFLComboBox(m.owner)
				TFLComboBox(m.owner)._lastchoice = index
				m.owner.SetText(text)
				PostGuiEvent(EVENT_GADGETACTION,m.owner,index)
				Return
			EndIf
			m=m.mparent
		Wend
' window menu		
		If check Then checked = Not checked
		PostGuiEvent(EVENT_MENUACTION,Self,tag)
	End Method
	
	Method Free()
		Local k:TFLMenu = mparent
		If k And k.mkids
			For Local i:Int = 0 Until k.mkids.length
				If k.mkids[i]=Self
					k.mkids=k.mkids[..i] + k.mkids[i+1..]
					Exit
				EndIf
			Next
		EndIf
		owner = Null;mkids = Null;mparent = Null;parent = Null
		If objhandle Then
			Release objhandle
			objhandle = 0
		EndIf
	End Method

	Method count(id)	'recursively assign unique index to each node in tree, skips number for pop
		index=id
		id:+1
		If mkids
			For Local m:TFLMenu = EachIn mkids
				id=m.count(id)
			Next
			id:+1
		EndIf
		Return id
	End Method	
	
	Method SetFLMenu(flmenu Ptr)	'recursively set hosts menuitem slots
		Local	m:TFLMenu,mm:TFLMenu
		Local	flags, pfnthandle, pfntsize
		
		m=Self
		While (m)
			If m.owner
				pfnthandle = m.owner.font.handle
				pfntsize = m.owner.font.GetSizeForFL()
			EndIf
			m=m.mparent
		Wend
		
		If Not pfnthandle Then pfnthandle = TFLTKGUIDriver.fntDefault.handle
		If Not pfntsize Then pfntsize = TFLTKGUIDriver.fntDefault.GetSizeForFL()
		
		If mkids
			If index>-1 flSetMenuItem(flmenu,index,text,flshortcut,objhandle,FL_SUBMENU,pfnthandle,pfntsize)	'message
			For m=EachIn mkids
				m.divider=False
				If m.text="" And mm mm.divider=True
				mm=m
			Next
			For m=EachIn mkids
				m.SetFLMenu(flmenu)
			Next
		Else
			flags=0
			If text="" flags:|FL_MENU_INVISIBLE
			If divider flags:|FL_MENU_DIVIDER
			If check
				flags:|FL_MENU_TOGGLE
				If checked flags:|FL_MENU_VALUE
			EndIf
			If disabled flags:|FL_MENU_INACTIVE
			If index>-1 flSetMenuItem(flmenu,index,text,flshortcut,objhandle,flags,pfnthandle,pfntsize)		'message		
		EndIf
	End Method

	Method SetHotKey(keycode,modifier)
		Local flkey = flkeyfromvkey(keycode)
		If flkey flkey:+flstatefrommodifiers(modifier)
		flshortcut=flkey
	End Method
		
	Method AddMenu( child:TFLMenu )
		child.mparent=Self
		child.owner = owner
		mkids:+[child]
	End Method
		
	Method RemoveMenu( index )
	?debug
		Assert index < mkids.length, "FLTK child menu index out of range."
	?
		mkids[index].Free()
	End Method

	Method State()
		Local t
		If checked t:|STATE_SELECTED
		If disabled t:|STATE_DISABLED
		Return t
	End Method
		
	Method SetSelected(truefalse)
		check=True
		checked=truefalse
	End Method
	
	Method SetEnabled(bool)
		disabled=Not bool
	End Method

	Method SetText(label$)
		text=label
	End Method

	Method GetText$()
		Return text
	End Method
	
	Method SetTooltip(tooltip$)
		'Do nothing - menus don't support tooltips (yet).
	EndMethod

End Type


Type TFLIconStrip Extends TIconStrip
	
	Field images[]
	Field iconpixmaps:TPixmap[]
	
	Method GetFLImage:Int(index:Int)
		If index>=0 And index < images.length Then Return images[index]
	EndMethod
	
	Function IsNotBlank(pixmap:TPixmap)
		Local x,y
		Local w=pixmap.width
		Local h=pixmap.height
		Local c=pixmap.ReadPixel(0,0) 			
		For x=0 Until h*h
			If pixmap.ReadPixel(x / h,x Mod h)<>c Return True
		Next
	End Function
	
	Function RemoveMask(pixmap:TPixmap)
		Local x,y,c
		If pixmap.format<>( PF_RGBA8888 ) And pixmap.format<>( PF_BGRA8888 ) Return
		Local w=pixmap.width
		Local h=pixmap.height
		For x=0 Until w
			For y=0 Until h
				c=pixmap.ReadPixel(x,y) 			
				If c>=0 pixmap.WritePixel x,y,-1
			Next
		Next
	End Function

	Function Create:TFLIconStrip(source:Object)
		
		Local pixmap:TPixmap,pix:TPixmap,winpix:TPixmap
		Local n,d
		
		pix=TPixmap(source)
		If Not pix pix=LoadPixmap(source)
		If Not pix Return		
		n=pix.width/pix.height
		If n=0 Return

		Select PixmapFormat(pix)
			Case PF_RGB888, PF_BGR888, PF_I8
				d = 3
				pixmap = ConvertPixmap(pix,PF_RGB888)
			Case PF_RGBA8888, PF_BGRA8888, PF_A8
				d = 4
				pixmap = ConvertPixmap(pix,PF_RGBA8888)
			Default
				Return Null
		EndSelect

		Local icons:TFLIconStrip = New TFLIconStrip
		icons.pixmap=pixmap
		icons.count=n
		icons.images=New Int[n]
		icons.iconpixmaps=New TPixmap[n]
		
		Local w = pixmap.height, h = w
		
		For Local x:Int = 0 Until n
			winpix=pixmap.Window(x*w,0,w,pixmap.height)
			If IsNotBlank(winpix) Then
				icons.iconpixmaps[x]=winpix
				icons.images[x]=FLImage(icons.iconpixmaps[x].pixels,w,h,d,icons.iconpixmaps[x].pitch)
			EndIf
		Next
		Return icons
	End Function
	
	Method Delete()
		For Local tmpImage:Int = EachIn images
			flFreeImage(tmpImage)
		Next
		images = Null;iconpixmaps = Null;pixmap = Null
	EndMethod
		
End Type

Private

Function flkeyfromvkey(k)
	If k>=48 And k<58 Return k
	If k>=65 And k<95 Return k+32		
	If k>=KEY_F1 And k<=KEY_F12 Return 65470+k-KEY_F1
	Select k
		Case KEY_OPENBRACKET Return 91
		Case KEY_CLOSEBRACKET Return 93
		Case KEY_BACKSLASH Return 92
		Case KEY_TAB Return FL_KEY_Tab
		Case KEY_ENTER Return FL_KEY_Enter
		Case KEY_ESCAPE Return FL_KEY_Escape
		Case KEY_HOME Return FL_KEY_Home
		Case KEY_LEFT Return FL_KEY_Left
		Case KEY_UP Return FL_KEY_Up
		Case KEY_RIGHT Return FL_KEY_Right
		Case KEY_DOWN Return FL_KEY_Down
		Case KEY_PAGEUP Return FL_KEY_Page_Up
		Case KEY_PAGEDOWN Return FL_KEY_Page_Down
		Case KEY_END Return FL_KEY_End
		Case KEY_PRINT Return FL_KEY_Print
		Case KEY_INSERT Return FL_KEY_Insert
		Case KEY_BACKSPACE Return FL_KEY_Backspace
		Case KEY_DELETE Return FL_KEY_Delete		
	End Select
	Return k
End Function

Function flstatefrommodifiers(m)
	Local	state
	If m&MODIFIER_SHIFT state:|FL_SHIFT
	If m&MODIFIER_CONTROL state:|FL_CTRL
	If m&MODIFIER_OPTION state:|FL_ALT
	If m&MODIFIER_SYSTEM state:|FL_META
	Return state
End Function

Function flkeytovkey(k)
	If k>=48 And k<58 Return k
	If k>=97 And k<127 Return KEY_A+k-97
	If k>=65361 And k<65365 Return KEY_LEFT+k-65361
	If k>=65470 And k<65470+13 Return KEY_F1+k-65470
	If k=65307 Return KEY_ESCAPE
	If k=65289 Return KEY_TAB
	If k=65056 Return KEY_TAB
	If k=91 Return KEY_OPENBRACKET
	If k=93 Return KEY_CLOSEBRACKET
	If k=92 Return KEY_BACKSLASH
	Return k
End Function

Function flstatetomodifiers(state)
	Local m
	If (state & FL_SHIFT) m:|MODIFIER_SHIFT
	If (state & FL_CTRL)  m:|MODIFIER_CONTROL
	If (state & FL_ALT)   m:|MODIFIER_OPTION
	If (state & FL_META)  m:|MODIFIER_SYSTEM
	Return m
End Function
