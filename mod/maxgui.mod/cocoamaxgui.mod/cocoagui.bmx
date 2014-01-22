Strict

Import MaxGUI.MaxGUI
Import Pub.MacOs

Import "-framework WebKit"
Import "cocoa.macos.m"

Extern
	
	Function bbSystemEmitOSEvent( nsevent:Byte Ptr,nsview:Byte Ptr,source:Object )
	
	Function ScheduleEventDispatch()
	
	Function NSBegin()
	Function NSEnd()
	
	Function NSGetSysColor(colorindex,r:Int Ptr,g:Int Ptr, b:Int Ptr)
	Function NSColorRequester(r,g,b)
	Function NSSetPointer(shape)
	
	Function NSCharWidth(font,charcode)
	' create
	Function NSInitGadget(gadget:TNSGadget)
	' generic
	Function NSActiveGadget()
	Function NSFreeGadget(gadget:TNSGadget)
	Function NSClientWidth(gadget:TNSGadget)
	Function NSClientHeight(gadget:TNSGadget)
	Function NSRethink(gadget:TNSGadget)
	Function NSRedraw(gadget:TNSGadget)
	Function NSActivate(gadget:TNSGadget,code)
	Function NSState(gadget:TNSGadget)
	Function NSShow(gadget:TNSGadget,bool)
	Function NSEnable(gadget:TNSGadget,bool)
	Function NSCheck(gadget:TNSGadget,bool)
	Function NSSetNextView(gadget:TNSGadget,nextgadget:TNSGadget)
	Function NSSetHotKey(gadget:TNSGadget,hotkey,modifier)
	Function NSSetTooltip(gadget:TNSGadget,tip$)
	Function NSGetTooltip$(gadget:TNSGadget)
	Function NSSuperview(view:Int)
	' window
	Function NSSetStatus(gadget:TNSGadget,text$,pos)
	Function NSSetMinimumSize(gadget:TNSGadget,width,height)
	Function NSSetMaximumSize(gadget:TNSGadget,width,height)
	Function NSPopupMenu(gadget:TNSGadget,menu:TNSGadget)
	' font
	Function NSRequestFont(font)
	Function NSLoadFont(name$,size:Double,flags)
	Function NSGetDefaultFont()
	Function NSSetFont(gadget:TNSGadget,font)
	Function NSFontName$(font)
	Function NSFontStyle(font)
	Function NSFontSize:Double(font)
	' items
	Function NSClearItems(gadget:TNSGadget)
	Function NSAddItem(gadget:TNSGadget,index,text$,tip$,image,extra:Object)
	Function NSSetItem(gadget:TNSGadget,index,text$,tip$,image,extra:Object)
	Function NSRemoveItem(gadget:TNSGadget,index)
	Function NSSelectItem(gadget:TNSGadget,index,state)
	Function NSSelectedItem(gadget:TNSGadget,index)
	Function NSSelectedNode(gadget:TNSGadget)
	' text
	Function NSSetText(gadget:TNSGadget,text$)
	Function NSGetText$(gadget:TNSGadget)
	Function NSReplaceText(gadget:TNSGadget,pos,length,text$,units)
	Function NSAddText(gadget:TNSGadget,text$)
	Function NSAreaText$(gadget:TNSGadget,pos,length,units)
	Function NSAreaLen(gadget:TNSGadget,units)
	Function NSLockText(gadget:TNSGadget)
	Function NSUnlockText(gadget:TNSGadget)
	Function NSSetTabs(gadget:TNSGadget,tabwidth)
	Function NSSetMargins(gadget:TNSGadget,leftmargin)
	Function NSSetColor(gadget:TNSGadget,r,g,b)
	Function NSRemoveColor(gadget:TNSGadget)
	Function NSSetAlpha(gadget:TNSGadget,alpha#)
	Function NSSetTextColor(gadget:TNSGadget,r,g,b)
	Function NSGetCursorPos(gadget:TNSGadget,units)
	Function NSGetSelectionlength(gadget:TNSGadget,units)
	Function NSSetStyle(gadget:TNSGadget,r,g,b,flags,pos,length,units)	
	Function NSSetSelection(gadget:TNSGadget,pos,length,units)
	Function NSCharAt(gadget:TNSGadget,line)
	Function NSLineAt(gadget:TNSGadget,index)
	Function NSCharX(gadget:TGadget,char)
	Function NSCharY(gadget:TGadget,char)
	' prop
	Function NSSetValue(gadget:TNSGadget,value#)
	' slider
	Function NSSetSlider(gadget:TNSGadget,value:Double,small:Double,big:Double)
	Function NSGetSlider:Double(gadget:TNSGadget)
	' images for panels and nodes
	Function NSPixmapImage(image:TPixmap)
	Function NSSetImage(gadget:TNSGadget,nsimage,flags)
	Function NSSetIcon(gadget:TNSGadget,nsimage)
	Function NSCountKids(gadget:TNSGadget)
	' html
	Function NSRun$(gadget:TNSGadget,script$)
	' misc
	Function NSRelease(nsobject)
	' system
	Function NSGetUserName$()
	Function NSGetComputerName$()
	
EndExtern

Global GadgetMap:TMap=New TMap

maxgui_driver=New TCocoaMaxGuiDriver

Type TCocoaMaxGUIDriver Extends TMaxGUIDriver
	
	Global CocoaGuiFont:TCocoaGuiFont
	
	Method New()
		NSBegin
		atexit_ NSEnd
		If Not CocoaGuiFont Then CocoaGuiFont = TCocoaGuiFont(LibraryFont(GUIFONT_SYSTEM))
	End Method
	
	Method UserName$()
		Return NSGetUserName$()
	End Method
	
	Method ComputerName$()
		Return NSGetComputerName$()
	End Method
		
	Method CreateGadget:TGadget(internalclass,name$,x,y,w,h,group:TGadget,style)
		Local p,hotkey
		If internalclass=GADGET_MENUITEM
			name=name.Replace("&","")
		ElseIf internalclass=GADGET_BUTTON
			p=name.Find("&")
			If p>-1
'				hotkey=Asc(name[p..p+1]) 'to do - convert and call SetHotKey before return
				name=name[..p]+name[p+1..]
			EndIf
		ElseIf internalclass=GADGET_TOOLBAR
			Global _toolbarcount
			_toolbarcount:+1
			name="Toolbar"+_toolbarcount
		EndIf
		Local gadget:TNSGadget = TNSGadget.Create(internalclass,name,x,y,w,h,TNSGadget(group),style)
		If internalclass<>GADGET_WINDOW And internalclass<>GADGET_MENUITEM And internalclass<>GADGET_DESKTOP
			gadget.SetLayout EDGE_CENTERED,EDGE_CENTERED,EDGE_CENTERED,EDGE_CENTERED
		EndIf
		If group Then gadget._SetParent group
		gadget.SetTextColor(0,0,0)
		gadget.LinkView
		Return gadget	
	End Method
		
	Function CreateFont:TGuiFont(handle,flags=FONT_NORMAL)
		Local font:TGuiFont = New TCocoaGuiFont
		font.handle = handle
		font.name = NSFontName(handle)
		font.size = NSFontSize(handle)
		font.style = NSFontStyle(handle)|flags
		Return font
	EndFunction

	Method LoadFont:TGuiFont(name$,size,flags)
		Return CreateFont(NSLoadFont(name,Double(size),flags),flags)
	End Method
	
	Method LoadFontWithDouble:TGuiFont(name$,size:Double,flags)
		Return CreateFont(NSLoadFont(name,size,flags),flags)
	End Method
	
	Method LibraryFont:TGuiFont( pFontType% = GUIFONT_SYSTEM, pFontSize:Double = 0, pFontStyle% = FONT_NORMAL )
		If pFontType = GUIFONT_SYSTEM Then
			Local tmpHandle% = NSGetDefaultFont()
			If pFontSize <= 0 Then pFontSize = NSFontSize(tmpHandle)
			Return LoadFontWithDouble( NSFontName(tmpHandle), pFontSize, NSFontStyle(tmpHandle)|pFontStyle )
		Else
			Return Super.LibraryFont( pFontType, pFontSize, pFontStyle )
		EndIf
	EndMethod
	
	Method LookupColor( colorindex:Int, red:Byte Var, green:Byte Var, blue:Byte Var )
		
		Local r, g, b
		
		If NSGetSysColor( colorindex, Varptr r, Varptr g, Varptr b )
			red = r & $FF
			green = g & $FF
			blue = b & $FF
			Return True
		EndIf
		
		Return Super.LookupColor( colorindex, red, green, blue )
				
	EndMethod
	
	Method RequestColor(r,g,b)
		Return NSColorRequester(r,g,b)
	End Method
	
	Method RequestFont:TGuiFont(font:TGuiFont)
		Local	handle
		If font handle=font.handle
		handle=NSRequestFont(handle)
		If handle
			If font And handle=font.handle Return font
			Return CreateFont(handle)
		EndIf
	End Method
	
	Method SetPointer(shape)
		NSSetPointer shape
	End Method		
	
	Method ActiveGadget:TGadget()
		PollSystem()
		Local handle = NSActiveGadget()
		If handle Return GadgetFromHandle(handle)
	End Method
	
	Method LoadIconStrip:TIconStrip(source:Object)
		Return TCocoaIconStrip.Create(source)
	End Method
End Type

Function GadgetFromHandle:TNSGadget( handle )
	Return TNSGadget( GadgetMap.ValueForKey( TIntWrapper.Create(handle) ) )
End Function

Function EmitCocoaOSEvent( event:Byte Ptr,handle,gadget:Object = Null )
	Local owner:TGadget = TGadget(gadget)
	If Not owner Then owner = GadgetFromHandle( handle )
	If owner Then
		While owner.source
			owner = owner.source
		Wend
	EndIf
	bbSystemEmitOSEvent event,Byte Ptr(handle),owner
End Function

Function EmitCocoaMouseEvent( event:Byte Ptr, handle )
	Local gadget:TNSGadget
'	While handle
		gadget = GadgetFromHandle( handle )
		If gadget Then
			If (gadget.sensitivity & SENSITIZE_MOUSE) Then
				EmitCocoaOSEvent( event, handle, gadget )
				Return 1
			EndIf
			Return 0
		EndIf
'		handle = NSSuperview(handle)
'	Wend
End Function

Function EmitCocoaKeyEvent( event:Byte Ptr, handle )
	Local gadget:TNSGadget
	While handle
		gadget = GadgetFromHandle( handle )
		If gadget Then
			If (gadget.sensitivity & SENSITIZE_KEYS) Then
				EmitCocoaOSEvent( event, handle, gadget )
				Return 1
			EndIf
			Return 0
		EndIf
		handle = NSSuperview(handle)
	Wend
End Function

Function PostCocoaGuiEvent( id,handle,data,mods,x,y,extra:Object )
	
	Local gadget:TNSGadget
	
	DispatchGuiEvents()
	
	If handle Then
		
		gadget = GadgetFromHandle(handle)
		
		If gadget Then
			
			Select gadget.internalclass
				Case GADGET_TREEVIEW
					extra=GadgetFromHandle(data)
					data = 0
			EndSelect
			
			Select id
				Case EVENT_WINDOWSIZE
					If gadget.width <> x Or gadget.height <> y Then
						gadget.SetRect gadget.xpos,gadget.ypos,x,y
						gadget.LayoutKids
					Else
						Return
					EndIf
					
				Case EVENT_WINDOWMOVE
					If gadget.xpos <> x Or gadget.ypos <> y Then
						gadget.SetRect x,y,gadget.width,gadget.height
					Else
						Return
					EndIf
					
				Case EVENT_MENUACTION
					extra=TNSGadget.popupextra
					TNSGadget.popupextra=Null
					
				Case EVENT_GADGETACTION
					
					Select gadget.internalclass
						Case GADGET_SLIDER
							Local oldValue:Int = gadget.GetProp()
							If data Then
								Select (gadget.style&(SLIDER_SCROLLBAR|SLIDER_TRACKBAR|SLIDER_STEPPER))
									Case SLIDER_SCROLLBAR
										If data > 1 Then
											data = gadget.small
										ElseIf data < -1 Then
											data = -gadget.small
										EndIf
								EndSelect
								gadget.SetProp(oldValue+data)
								data=gadget.GetProp()
								If (data = oldValue) Then Return
							Else
								data=gadget.GetProp()
							EndIf
						Case GADGET_LISTBOX, GADGET_COMBOBOX, GADGET_TABBER
							If (data > -1 And data < gadget.items.length) extra=gadget.ItemExtra(data)
						Case GADGET_BUTTON
							Select (gadget.style&7)
								Case BUTTON_CHECKBOX
									If ButtonState(gadget) = CHECK_INDETERMINATE Then SetButtonState(gadget, CHECK_SELECTED )
								Case BUTTON_RADIO
									If (gadget.style&BUTTON_PUSH) Then SetButtonState(gadget,CHECK_SELECTED)
									gadget.ExcludeOthers()
							EndSelect
							data=ButtonState(gadget)
						Case GADGET_TOOLBAR
							If data>-1 Then
								extra=gadget.ItemExtra(data)
								If (gadget.ItemFlags(data)&GADGETITEM_TOGGLE) Then gadget.SelectItem(data,2)
							EndIf
					EndSelect
					
				Case EVENT_GADGETSELECT, EVENT_GADGETMENU
					Select gadget.internalclass
						Case GADGET_LISTBOX, GADGET_COMBOBOX, GADGET_TABBER
							If data>-1 Then extra=gadget.ItemExtra(data)
					EndSelect
					
				Case EVENT_GADGETLOSTFOCUS
				
					QueueGuiEvent id,gadget,data,mods,x,y,extra
					ScheduleEventDispatch()
					Return
					
			EndSelect
		EndIf
	
	EndIf
	
	PostGuiEvent id,gadget,data,mods,x,y,extra
	
EndFunction

Function FilterKeyDown( handle,key,mods )
	Local source:TNSGadget
	If handle
		source=GadgetFromHandle(handle)
	EndIf
	If source And source.eventfilter<>Null
		Local event:TEvent=CreateEvent(EVENT_KEYDOWN,source,key,mods)
		Return source.eventfilter(event,source.context)
	EndIf
	Return 1
End Function

Function FilterChar( handle,key,mods )
	Local source:TNSGadget
	Select key
		' Return true if they are arrow key characters
		Case 63232, 63233, 63234, 63235
			Return 1
	EndSelect
	If handle
		source=GadgetFromHandle(handle)
	EndIf
	If source And source.eventfilter<>Null 'Return source.charfilter(char,mods,source.context)
		Local event:TEvent=CreateEvent(EVENT_KEYCHAR,source,key,mods)
		Return source.eventfilter(event,source.context)
	EndIf
	Return 1
End Function

Type TNSGadget Extends TGadget
	
	Field internalclass, origclass	'internalclass: Class the Cocoa driver uses to draw the gadget, origclass: Expected class to be returned by Class() method
	Field handle
	Field view, textcolor	'view: NSView handle, textcolor: NSColor handle for Objective-C code
	Field intFontStyle	'Copy of font.style used by cocoa.macos.m to handle underlining/strikethrough etc. that isn't included in NSFont
	Field pixmap:TPixmap
	Field icons:TCocoaIconStrip
	Field small, big
	Field canvas:TGraphics
	Field font:TCocoaGuiFont
	Field enabled:Int = True, forceDisable:Int = False

' main factory command

	Function Create:TNSGadget(internalclass,text$,x,y,w,h,group:TGadget,style)
		
		Local gadget:TNSGadget = New TNSGadget
		gadget.origclass = internalclass
		gadget.internalclass = internalclass
		
		If Not group And internalclass<>GADGET_DESKTOP Then group = Desktop()
		gadget.parent = group
		
		gadget.name = text
		gadget.SetRect x,y,w,h	'setarea
		gadget.style = style
		gadget.font = TCocoaMaxGUIDriver.CocoaGUIFont
		
		If TNSGadget(group) Then
			gadget.forceDisable = Not (TNSGadget(group).enabled And Not TNSGadget(group).forceDisable)
		EndIf
		
		NSInitGadget gadget

		If internalclass<>GADGET_TOOLBAR 'toolbars retain name to key insertgadgetitem
			gadget.name = Null
		EndIf
		
		GadgetMap.Insert TIntWrapper.Create(gadget.handle),gadget
		If gadget.view And gadget.handle <> gadget.view Then
			GadgetMap.Insert TIntWrapper.Create(gadget.view),gadget
		EndIf
		
		If internalclass=GADGET_SLIDER Then gadget.SetRange(1,10)
		gadget.LockLayout()
		
		If (internalclass=GADGET_WINDOW) And (style&WINDOW_STATUS) Then
			If (style&WINDOW_CLIENTCOORDS) Then
				gadget.SetMinimumSize(25,0)
			Else
				gadget.SetMinimumSize(25,70)
			EndIf
		EndIf
		
		If LocalizationMode() & LOCALIZATION_OVERRIDE Then LocalizeGadget(gadget,text,"")
		
		gadget.SetEnabled(gadget.enabled)
		
		Return gadget
		
	End Function
	
	Method Class()
		Return origclass
	EndMethod
	
	Function ToView:TNSGadget(value:Object)
		Local	view:TNSGadget = TNSGadget(value)
		If Not view Return
		Select view.internalclass
			Case GADGET_DESKTOP,GADGET_WINDOW,GADGET_TOOLBAR,GADGET_LABEL,GADGET_PROGBAR,GADGET_MENUITEM,GADGET_NODE
				Return Null
		End Select
		Return view
	End Function
	
	Method LinkView()
		Local	First:TNSGadget
		Local	prev:TNSGadget
		Local	i,n

		If Not parent Return
		If Not ToView(Self) Return
		n=parent.kids.count()-1
		If n<0 Return
' find first view in family
		For i=0 Until  n
			First=ToView(parent.kids.ValueAtIndex(i))
			If First Exit
		Next
		If Not First Return
' find last view in family
		For i=n-1 To 0 Step -1
			prev=ToView(parent.kids.ValueAtIndex(i))
			If prev Exit
		Next
		If Not prev Return
		NSSetNextView(prev,Self)
		NSSetNextView(Self,First)
	End Method
	
	Method Delete()
		Free()
	End Method
	
' generic gadget commands

	Method Query(queryid)
		Select queryid
			Case QUERY_NSVIEW
				Return handle
			Case QUERY_NSVIEW_CLIENT
				Return view
		End Select				
	End Method

	Method Free()
		If handle Then
			
			If canvas Then canvas.close
			
			GadgetMap.Remove TIntWrapper.Create(handle)
			If view And handle <> view Then
				GadgetMap.Remove TIntWrapper.Create(view)
				view = Null
			EndIf
				
			If parent Then
				parent.kids.Remove Self
			End If
			
			NSFreeGadget Self
			font = Null
			
			handle = Null
			
		EndIf
	End Method

	Method Rethink()			'resize	- was recursive
		NSRethink( Self )
	End Method
		
	Method ClientWidth()
		Return Max(NSClientWidth(Self),0)
	End Method
	
	Method ClientHeight()
		Return Max(NSClientHeight(Self),0)
	End Method
	
	Method Activate(cmd)
		NSActivate( Self, cmd )
	End Method
	
	Method State()
		Local tmpState:Int = NSState(Self)&~STATE_DISABLED
		If Not enabled Then tmpState:|STATE_DISABLED
		Return tmpState
	End Method
	
	Method SetShow(bool)
		NSShow( Self, bool )
	End Method

	Method SetText(msg$)
		If internalclass=GADGET_HTMLVIEW
			Local	anchor$,a
			a=msg.Find("#")
			If a<>-1 anchor=msg[a..];msg=msg[..a]
			If msg[0..7].ToLower()<>"http://" And msg[0..7].ToLower()<>"file://"
				If FileType(msg)
					msg="file://"+msg
				Else
					msg="http://"+msg
				EndIf
			EndIf
			msg:+anchor
			msg=msg.Replace(" ","%20")
		ElseIf internalclass=GADGET_MENUITEM
			msg=msg.Replace("&", "")
		EndIf
		NSSetText Self,msg
	End Method
	
	Method Run$(msg$)
		If internalclass=GADGET_HTMLVIEW Return NSRun(Self,msg)
	End Method

	Method GetText$()
		Return NSGetText(Self)
	End Method

	Method SetFont(pFont:TGuiFont)
		If Not TCocoaGuiFont(pFont) Then pFont = TCocoaMaxGUIDriver.CocoaGuiFont
		font = TCocoaGuiFont(pFont)
		intFontStyle = font.style
		NSSetFont( Self, font.handle )
	End Method

	Method SetColor(r,g,b)
		NSSetColor Self,r,g,b
	End Method

	Method RemoveColor()
		NSRemoveColor Self
	End Method

	Method SetAlpha(alpha#)
		NSSetAlpha Self,alpha
	End Method
	
	Method SetTextColor(r,g,b)
		NSSetTextColor Self,r,g,b
	End Method
	
	Method SetPixmap(pixmap:TPixmap,flags)
		Local	nsimage, x
		If pixmap
			Select pixmap.format
				Case PF_I8,PF_BGR888
					pixmap=pixmap.Convert( PF_RGB888 )
				Case PF_A8,PF_BGRA8888
					pixmap=pixmap.Convert( PF_RGBA8888 )
			End Select
			
			If AlphaBitsPerPixel[ pixmap.format ]
				For Local y=0 Until pixmap.height
					For x=0 Until pixmap.width
						Local argb=pixmap.ReadPixel( x,y )
						pixmap.WritePixel x,y,premult(argb)
					Next
				Next
			EndIf
			nsimage=NSPixmapImage(pixmap)
		EndIf
		NSSetImage(Self,nsimage,flags)
	End Method
	
	Method SetTooltip(pTip$)
		Select internalclass
			Case GADGET_WINDOW, GADGET_DESKTOP, GADGET_LISTBOX, GADGET_MENUITEM, GADGET_TOOLBAR, GADGET_TABBER, GADGET_NODE
			Default;Return NSSetTooltip( Self, pTip )
		EndSelect
	EndMethod
	
	Method GetTooltip$()
		Select internalclass
			Case GADGET_WINDOW, GADGET_DESKTOP, GADGET_LISTBOX, GADGET_MENUITEM, GADGET_TOOLBAR, GADGET_TABBER, GADGET_NODE
			Default;Return NSGetTooltip( Self )
		EndSelect
	EndMethod
	
	Method ExcludeOthers()
		For Local g:TNSGadget = EachIn parent.kids
			If g<>Self And g.internalclass=GADGET_BUTTON And (g.style&7)=BUTTON_RADIO
				NSCheck g,False
			EndIf
		Next
	End Method

	Method SetSelected(bool)
		NSCheck Self,bool
		If internalclass=GADGET_BUTTON And (style&7)=BUTTON_RADIO And bool
			ExcludeOthers
		EndIf
	End Method
	
	Method SetEnabled(enable)
		Local old:Int = enabled And Not forceDisable
		enabled = enable
		If Class() = GADGET_WINDOW Then
			NSEnable Self, enable
		Else
			enable = enable And Not forceDisable
			NSEnable Self, enable
			If (enable <> old) Then
				For Local tmpGadget:TNSGadget = EachIn kids
					tmpGadget.forceDisable = Not enable
					If tmpGadget.Class() <> GADGET_WINDOW Then tmpGadget.SetEnabled(tmpGadget.enabled)
				Next
			EndIf
		EndIf
	End Method
	
	Method SetHotKey(hotkey,modifier)
		NSSetHotKey Self,hotkey,modifier
	End Method
	
' window commands
	
	Field _statustext$
	
	Method GetStatusText$()
		Return _statustext
	EndMethod
	
	Method SetStatusText(msg$)
		Local	t,m0$,m1$,m2$
		_statustext = msg
		m0=msg
		t=m0.find("~t");If t<>-1 m1=m0[t+1..];m0=m0[..t];
		t=m1.find("~t");If t<>-1 m2=m1[t+1..];m1=m1[..t];		
		NSSetStatus Self,m0,0
		NSSetStatus Self,m1,1
		NSSetStatus Self,m2,2
	End Method
	
	Method GetMenu:TGadget()
		Return Self
	End Method

	Global popupextra:Object
	
	Method PopupMenu(menu:TGadget,extra:Object)
		popupextra=extra
		NSPopupMenu Self,TNSGadget(menu)
	End Method
	
	Method UpdateMenu()
	End Method
	
	Method SetMinimumSize(w,h)
		NSSetMinimumSize Self,w,h
	End Method
	
	Method SetMaximumSize(w,h)
		NSSetMaximumSize Self,w,h
	End Method

	Method SetIconStrip(iconstrip:TIconStrip)
		icons=TCocoaIconStrip(iconstrip)
	End Method

' item handling commands

	Method ClearListItems()
		NSClearItems Self
	End Method

	Method InsertListItem(index,item$,tip$,icon,extra:Object)
		Local	image
		If internalclass=GADGET_TOOLBAR
			item=name+":"+index
		EndIf
		If icons And icon>=0 image=icons.images[icon]
		NSAddItem Self,index,item,tip,image,extra
	End Method
	
	Method SetListItem(index,item$,tip$,icon,extra:Object)
		Local	image
		If internalclass=GADGET_TOOLBAR
			item=name+":"+index
		EndIf
		If icons And icon>=0 image=icons.images[icon]
		NSSetItem Self,index,item,tip,image,extra
	End Method
	
	Method RemoveListItem(index)
		NSRemoveItem Self,index
	End Method
	
	Method SetListItemState(index,state)
		NSSelectItem Self,index,state
	End Method
	
	Method ListItemState(index)
 		Return NSSelectedItem(Self,index)
	End Method
	
' treeview commands	

	Method RootNode:TGadget()
		Return Self
	End Method
	
	Method SetIcon(icon)
		Local	p:TNSGadget
		p=Self
		While p
			If p.icons Exit
			p=TNSGadget(p.parent)
		Wend
		If p
			If icon>-1
				NSSetIcon Self,p.icons.images[icon]		
			Else
				NSSetIcon Self,Null		
			EndIf
		EndIf				
	End Method
	
	Method InsertNode:TGadget(index,text$,icon)
		Local	node:TNSGadget = Create(GADGET_NODE,text,0,0,0,0,Self,index)
		node.SetIcon icon
		node._SetParent Self
		Return node
	End Method
	
	Method ModifyNode(text$,icon)
		NSSetText Self,text
		SetIcon icon
	End Method

	Method SelectedNode:TGadget()
		Local	index = NSSelectedNode(Self)
		If (index) Return GadgetFromHandle(index)
	End Method

	Method CountKids()
		Return NSCountKids(Self)
	End Method

' textarea commands

	Method ReplaceText(pos,length,text$,units)
?debug
		If pos<0 Or pos+length>AreaLen(units) Throw "Illegal Range"
?	
		NSReplaceText Self,pos,length,text$,units
	End Method

	Method AddText(text$)
		NSAddText Self,text
	End Method

	Method AreaText$(pos,length,units)
?debug
		If pos<0 Or pos+length>AreaLen(units) Throw "Illegal Range"
?	
		Return NSAreaText(Self,pos,length,units)
	End Method

	Method AreaLen(units)
		Return NSAreaLen(Self,units)
	End Method

	Method LockText()
		NSLockText Self
	End Method

	Method UnlockText()
		NSUnlockText Self
	End Method

	Method SetTabs(tabwidth)
		NSSetTabs Self,tabwidth
	End Method

	Method SetMargins(leftmargin)
		NSSetMargins Self,leftmargin
	End Method

	Method GetCursorPos(units)
		Return NSGetCursorPos(Self,units)
	End Method

	Method GetSelectionLength(units)
		Return NSGetSelectionLength(Self,units)
	End Method

	Method SetStyle(r,g,b,flags,pos,length,units) 	
?debug
		If pos<0 Or pos+length>AreaLen(units) Throw "Illegal Range"
?	
		If length NSSetStyle Self,r,g,b,flags,pos,length,units
	End Method

	Method SetSelection(pos,length,units)
?debug
		If pos<0 Or pos+length>AreaLen(units) Throw "Illegal Range"
?	
		NSSetSelection Self,pos,length,units
	End Method

	Method CharAt(line)
?debug
		If line<0 Or line>AreaLen(TEXTAREA_LINES) Throw "Parameter Out Of Range"
?	
		Return NSCharAt(Self,line)
	End Method

	Method LineAt(index)
?debug
		If index<0 Or index>AreaLen(TEXTAREA_CHARS) Throw "Parameter Out Of Range"
?	
		Return NSLineAt(Self,index)
	End Method
	
	Method CharX(char)
		Return NSCharX(Self,char)
	EndMethod
	
	Method CharY(char)
		Return NSCharY(Self,char)
	EndMethod
	
' progbar
	
	Method SetValue(value#)
		NSSetValue Self,value
	End Method

' slider / scrollbar

	Method SetRange(_small,_big)
		small=_small
		big=_big
		NSSetSlider Self,GetProp(),small,big
	End Method
	
	Method SetProp(pos)
		NSSetSlider Self,pos,small,big
	End Method

	Method GetProp()
		Local value:Double = NSGetSlider(Self)
		If Not (style&(SLIDER_TRACKBAR|SLIDER_STEPPER))
			value:*(big-small)
			If value>big-small value=big-small
		EndIf
		Return Int(value+0.5:Double)
	End Method
	
' canvas

	Method AttachGraphics:TGraphics( flags )
		canvas=brl.Graphics.AttachGraphics( Query(QUERY_NSVIEW_CLIENT),flags )
	End Method
	
	Method CanvasGraphics:TGraphics()
		Return canvas
	End Method

End Type


Type TCocoaIconStrip Extends TIconStrip
	
	Field images[]
	
	Function IsNotBlank(pixmap:TPixmap)
		Local y, h = pixmap.height
		Local c = pixmap.ReadPixel(0,0) 			
		For Local x = 0 Until h
			For y = 0 Until h
				If pixmap.ReadPixel(x,y)<>c Return True
			Next
		Next
	End Function
		
	Function Create:TCocoaIconStrip(source:Object)
		Local	icons:TCocoaIconStrip
		Local	pixmap:TPixmap,pix:TPixmap
		Local	n,x,w,nsimage
		pixmap=TPixmap(source)
		If Not pixmap pixmap=LoadPixmap(source)
		If Not pixmap Return		
		Select pixmap.format
		Case PF_I8,PF_BGR888
			pixmap=pixmap.Convert( PF_RGB888 )
		Case PF_A8,PF_BGRA8888
			pixmap=pixmap.Convert( PF_RGBA8888 )
		End Select
		
		If AlphaBitsPerPixel[ pixmap.format ]
			For Local y=0 Until pixmap.height
				For x=0 Until pixmap.width
					Local argb=pixmap.ReadPixel( x,y )
					pixmap.WritePixel x,y,premult(argb)
				Next
			Next
		EndIf
		
		n=pixmap.width/pixmap.height;
		If n=0 Return		
		icons=New TCocoaIconStrip
		icons.pixmap=pixmap
		icons.count=n
		icons.images=New Int[n]
		w=pixmap.width/n			
		For x=0 Until n
			pix=pixmap.Window(x*w,0,w,pixmap.height)
			If IsNotBlank(pix) icons.images[x]=NSPixmapImage(pix)
		Next
		Return icons
	EndFunction	
	
EndType

Type TCocoaGuiFont Extends TGuiFont
	
	Method Delete()
		If handle Then
			NSRelease(handle)
			handle = 0
		EndIf
	EndMethod
	
	Method CharWidth(char)
		If handle
			Return NSCharWidth(handle,char)
		EndIf
		Return 0
	EndMethod 
		
EndType

Type TIntWrapper Final
	Field value:Int
	Function Create:TIntWrapper(value:Int)
		Local tmpWrapper:TIntWrapper = New TIntWrapper
		tmpWrapper.value = value
		Return tmpWrapper
	EndFunction
	Method Compare( o:Object )
		Local c:TIntWrapper = TIntWrapper(o)
		If c Then Return (value - c.value)
		Return Super.Compare(o)
	EndMethod
	Method ToString$()
		Return value
	EndMethod
EndType

Private

Function premult(argb)
	Local a = ((argb Shr 24) & $FF)
	Return ((((argb&$ff00ff)*a)Shr 8)&$ff00ff)|((((argb&$ff00)*a)Shr 8)&$ff00)|(a Shl 24)
End Function
