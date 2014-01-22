Strict

Import BRL.LinkedList
Import BRL.Graphics
Import BRL.Pixmap

Import "guifont.bmx"
Import "iconstrip.bmx"
Import "gadgetitem.bmx"

Const GADGET_DESKTOP=0
Const GADGET_WINDOW=1
Const GADGET_BUTTON=2
Const GADGET_PANEL=3
Const GADGET_TEXTFIELD=4
Const GADGET_TEXTAREA=5
Const GADGET_COMBOBOX=6
Const GADGET_LISTBOX=7
Const GADGET_TOOLBAR=8
Const GADGET_TABBER=9
Const GADGET_TREEVIEW=10
Const GADGET_HTMLVIEW=11
Const GADGET_LABEL=12
Const GADGET_SLIDER=13
Const GADGET_PROGBAR=14
Const GADGET_MENUITEM=15
Const GADGET_NODE=16
Const GADGET_CANVAS=17
Const GADGET_TIMER=18

Const ACTIVATE_FOCUS=0
Const ACTIVATE_CUT=1
Const ACTIVATE_COPY=2
Const ACTIVATE_PASTE=3
Const ACTIVATE_MINIMIZE=4
Const ACTIVATE_MAXIMIZE=5
Const ACTIVATE_RESTORE=6
Const ACTIVATE_SELECT=7
Const ACTIVATE_EXPAND=8
Const ACTIVATE_COLLAPSE=9
Const ACTIVATE_BACK=10
Const ACTIVATE_FORWARD=11
Const ACTIVATE_PRINT=12
Const ACTIVATE_REDRAW=13
Const ACTIVATE_UNDO=14
Const ACTIVATE_REDO=15

Const LAYOUT_NONE=0
Const LAYOUT_ABSOLUTE=1
Const LAYOUT_PROPORTIONAL=2

Const GUICOLOR_WINDOWBG = 0
Const GUICOLOR_GADGETBG = 1
Const GUICOLOR_GADGETFG = 2
Const GUICOLOR_SELECTIONBG = 3
Const GUICOLOR_LINKFG = 4

Const WINDOW_TITLEBAR=1
Const WINDOW_RESIZABLE=2
Const WINDOW_MENU=4
Const WINDOW_STATUS=8
Const WINDOW_TOOL=16
Const WINDOW_CLIENTCOORDS=32
Const WINDOW_HIDDEN=64
Const WINDOW_ACCEPTFILES=128
Const WINDOW_CHILD=256
Const WINDOW_CENTER=512

Const WINDOW_DEFAULT=WINDOW_TITLEBAR|WINDOW_RESIZABLE|WINDOW_MENU|WINDOW_STATUS

Const LABEL_LEFT=0
Const LABEL_FRAME=1
Const LABEL_SUNKENFRAME=2
Const LABEL_SEPARATOR=3
Const LABEL_RIGHT=8
Const LABEL_CENTER=16

Const BUTTON_PUSH=8
Const BUTTON_CHECKBOX=2
Const BUTTON_RADIO=3
Const BUTTON_OK=4
Const BUTTON_CANCEL=5


Const CHECK_CLEARED = 0
Const CHECK_SELECTED = 1
Const CHECK_INDETERMINATE = -1


Const PANEL_SUNKEN=1
Const PANEL_RAISED=2
Const PANEL_GROUP=3
Const PANEL_BORDER=PANEL_SUNKEN	'For backwards compatibility

Const PANEL_ACTIVE=4
Const PANEL_CANVAS=8
	
Const PANELPIXMAP_TILE=0
Const PANELPIXMAP_CENTER=1
Const PANELPIXMAP_FIT=2
Const PANELPIXMAP_STRETCH=3
Const PANELPIXMAP_FIT2=4

Const GADGETPIXMAP_BACKGROUND = 0
Const GADGETPIXMAP_ICON = 8
Const GADGETPIXMAP_NOTEXT = 16

Const TEXTAREA_ALL=-1

Const TEXTAREA_CHARS=1
Const TEXTAREA_LINES=2

Const TEXTAREA_WORDWRAP=1
Const TEXTAREA_READONLY=2

Const TEXTFIELD_PASSWORD=1

Const TEXTFORMAT_BOLD=1
Const TEXTFORMAT_ITALIC=2
Const TEXTFORMAT_UNDERLINE=4
Const TEXTFORMAT_STRIKETHROUGH=8

Const LISTBOX_MULTISELECT=1

Const COMBOBOX_EDITABLE=1

Const TREEVIEW_DRAGNDROP=1

Const SLIDER_HORIZONTAL=1
Const SLIDER_VERTICAL=2
Const SLIDER_SCROLLBAR=0
Const SLIDER_TRACKBAR=4
Const SLIDER_STEPPER=8
Const SLIDER_DIAL=12

Const HTMLVIEW_NOCONTEXTMENU=1
Const HTMLVIEW_NONAVIGATE=2

Const STATE_MINIMIZED=1
Const STATE_MAXIMIZED=2
Const STATE_DISABLED=4
Const STATE_HIDDEN=8
Const STATE_SELECTED=16
Const STATE_ACTIVE=32
Const STATE_INDETERMINATE=64|STATE_SELECTED

Const GADGETICON_SEPARATOR=-2
Const GADGETICON_BLANK=-1

Const GADGETITEM_NONE=-1
Const GADGETITEM_NORMAL=0
Const GADGETITEM_DEFAULT=1
Const GADGETITEM_TOGGLE=2
Const GADGETITEM_LOCALIZED=4

Const SENSITIZE_MOUSE=1
Const SENSITIZE_KEYS=2
Const SENSITIZE_ALL=SENSITIZE_MOUSE|SENSITIZE_KEYS

Const EDGE_CENTERED=0
Const EDGE_ALIGNED=1
Const EDGE_RELATIVE=2

Const QUERY_HWND=1
Const QUERY_HWND_CLIENT=2
Const QUERY_NSVIEW=3
Const QUERY_NSVIEW_CLIENT=4
Const QUERY_FLWIDGET=5
Const QUERY_FLWIDGET_CLIENT=6

Const EVENT_GADGETDRAG% = $200A, EVENT_GADGETDROP% = $200B
TEvent.RegisterId EVENT_GADGETDRAG, "GadgetDrag"
TEvent.RegisterId EVENT_GADGETDROP, "GadgetDrop"

' WARNING - struct nsgadget in brl.mod/cocoagui.mod/cocoa.macos.m must be modified if TGadget field count changes

Type TGadget
' event propagation
	Field	source:TGadget
' hierachy
	Field	parent:TGadget
	Field	kids:TList=New TList
' properties
	Field	xpos,ypos,width,height
	Field	name$, extra:Object	'See GadgetExtra() and SetGadgetExtra()
	Field	style, sensitivity
' slider vars
	Field	visible,total=1
' layout
	Field	lockl,lockr,lockt,lockb
	Field	lockx,locky,lockw,lockh,lockcw,lockch
' filters
	Field	eventfilter(event:TEvent,context:Object)
	Field	context:Object
' items
	Field	items:TGadgetItem[]

	Global dragGadget:TGadget[3]
	
	Global LocalizeString$( text$ ) 'set at the bottom of maxgui.mod/driver.bmx
	'Global LocalizeGadget( gadget:TGadget, text$ )
	Global DelocalizeGadget( gadget:TGadget )
	
' core methods
	
	Method SetFilter(callback(event:TEvent,context:Object),user:Object)
		eventfilter=callback
		context=user
	End Method
	
	Method HasDescendant(pGadget:TGadget)
		If pGadget = Self Then Return True
		For Local tmpGadget:TGadget = EachIn kids
			Local tmpResult = tmpGadget.HasDescendant(pGadget)
			If tmpResult Then Return tmpResult
		Next
	EndMethod
	
	Method _setparent(widget:TGadget,index=-1)	'private use setgroup
		If parent parent.kids.remove Self
		parent=widget
		If parent
			If index<0 Or index>=parent.kids.count()
				parent.kids.addlast Self
			Else
				If index=0
					parent.kids.addfirst Self
				Else
					Local link:TLink
					link=parent.kids.findlink(parent.kids.valueatindex(index))
					parent.kids.InsertBeforeLink Self,link
				EndIf
			EndIf
		EndIf
	End Method
	
	Field arrPrevSelection:Int[]
	
	'Private method for multi-select listbox event handling.
	'Returns first item whose state has changed or -1 if selection has stayed the same.
	
	Method SelectionChanged()
		Local i%, arrLastSelection:Int[] = arrPrevSelection, arrCurrSelection:Int[] = SelectedItems()
		arrPrevSelection = arrCurrSelection
		For i = 0 Until Min(arrLastSelection.length,arrCurrSelection.length)
			If arrCurrSelection[i] <> arrLastSelection[i] Then Return Min(arrCurrSelection[i],arrLastSelection[i])
		Next
		If i < arrLastSelection.length Then Return arrLastSelection[i] ElseIf i < arrCurrSelection.length Then Return arrCurrSelection[i]
		Return -1
	EndMethod
	
	Method Handle:TGadget()
		Return Self
	End Method
	
' layout
	
	Method GetXPos%()
		Return xpos
	EndMethod
	
	Method GetYPos%()
		Return ypos
	EndMethod
	
	Method GetWidth%()
		Return width
	EndMethod
	
	Method GetHeight%()
		Return height
	EndMethod
	
	Method GetGroup:TGadget()
		Return parent
	EndMethod
	
	Method SetShape(x,y,w,h)
		SetArea(x,y,w,h)
		LockLayout
	End Method

	Method SetArea(x,y,w,h)
		SetRect x,y,w,h
		Rethink()
		LayoutKids
	End Method

	Method SetRect(x,y,w,h)
		xpos=x;ypos=y;width=Max(w,0);height=Max(h,0)
	End Method

	Method LockLayout()
		lockx=xpos
		locky=ypos
		lockw=width
		lockh=height
		lockcw=1
		lockch=1
		If parent
			lockcw=Max(parent.ClientWidth(),1)
			lockch=Max(parent.ClientHeight(),1)
		EndIf
	End Method

	Method SetLayout( lft,rht,top,bot )
		lockl=lft
		lockr=rht
		lockt=top
		lockb=bot
		LockLayout
	End Method

	Method LayoutKids()
		For Local	 w:TGadget = EachIn kids
			w.DoLayout()
		Next
	End Method

	Method DoLayout()
		Local cw,ch,x,x2,y,y2

		If Not parent Or Class() = GADGET_WINDOW Or Class() = GADGET_MENUITEM Or Class() = GADGET_NODE Then Return
		
' horizontal
		cw=Max(parent.ClientWidth(),1)
		x=xpos
		x2=xpos+width
		If lockl Or lockr
			If lockl=LAYOUT_ABSOLUTE x=lockx Else If lockl=LAYOUT_PROPORTIONAL x=cw*lockx/lockcw
			If lockr=LAYOUT_ABSOLUTE x2=lockx+lockw-lockcw+cw Else If lockr=LAYOUT_PROPORTIONAL x2=cw*(lockx+lockw)/lockcw
			If Not lockl x=x2-lockw Else If Not lockr x2=x+lockw
		Else
			x=cw*(lockx+lockw/2)/lockcw-lockw/2
			x2=x+lockw
		EndIf
' vertical
		ch=Max(parent.ClientHeight(),1)		
		y=ypos
		y2=ypos+height
		If lockt Or lockb
			If lockt=LAYOUT_ABSOLUTE y=locky Else If lockt=LAYOUT_PROPORTIONAL y=ch*locky/lockch
			If lockb=LAYOUT_ABSOLUTE y2=locky+lockh-lockch+ch Else If lockb=LAYOUT_PROPORTIONAL y2=ch*(locky+lockh)/lockch
			If Not lockt y=y2-lockh Else If Not lockb y2=y+lockh
		Else
			y=ch*(locky+lockh/2)/lockch-lockh/2
			y2=y+lockh
		EndIf
		
		SetArea( x,y,x2-x,y2-y )
	End Method

' datasource
	Field datasource:Object
	Field datakeys$[]

'	Global	gadgetdatamap:TMap=New TMap	'need pollevent for automatic refresh

	Method SetDataSource(data:Object)
		Clear
		datasource=data
		datakeys=Null
'		gadgetdatamap.insert Self,data
		SyncDataSource
	End Method
	
	Function KeysFromList$[](list:TList)
		Local s:String[]
		Local o:Object
		Local i
		s=New String[list.count()]
		For o=EachIn list
			s[i]=o.ToString()
			i:+1
		Next	
		Return s
	End Function

	Function KeysFromObjectArray$[](list:Object[])
		Local s:String[]
		Local o:Object
		Local i
		s=New String[list.length]
		For o=EachIn list
			s[i]=o.ToString()
			i:+1
		Next	
		Return s
	End Function

	Method SyncDataSource()	'returns true if items modified
		Local newkeys$[]
		If Not datasource Return False
		Select True
			Case TList(datasource)<>Null
				newkeys=KeysFromList(TList(datasource))
			Case String[](datasource)<>Null
				newkeys=String[](datasource)
			Case Object[](datasource)<>Null
				newkeys=KeysFromObjectArray(Object[](datasource))
		End Select		
		If Not newkeys Or newkeys.length=0 'datasource is empty or unsupported
			If items.length
				Clear
				Return True
			EndIf
			Return False
		EndIf
'		If newkeys.compare(datakeys)=0 Return False
		SyncData newkeys
		datakeys=newkeys[..newkeys.length]
	End Method
	
' for each item
' if same move on
' if diff
'   see when next occurance is and how big a match will occur from remove
'   if deletes<newmatch do remove else do insert

	Method SyncData(newkeys$[])
		Local p1,p2,d1,d2,d3
		Local same,diff,icount
		Local item:TGadgetItem
		Local k$
		
		For p1=0 Until newkeys.length
			k$=newkeys[p1]

			If d1>=datakeys.length
				InsertItemFromKey(icount,k$)
				icount:+1
				Continue
			EndIf

			If k$=datakeys[d1]
				d1:+1
				icount:+1
				Continue
			EndIf
			
			diff=1
			For d2=d1+1 Until datakeys.length
				If k=datakeys[d2] Exit
				diff:+1
			Next
			same=1
			p2=p1+1
			For d3=d2+1 Until datakeys.length
				If p2>=newkeys.length Exit
				If newkeys[p2]<>datakeys[d3] Exit
				same:+1
				p2:+1
			Next
			
			If same>diff
				d1:+diff
				While diff
					RemoveItem icount
					diff:-1
				Wend
				d1:+1
				icount:+1
			Else
				InsertItemFromKey(icount,k$)
				icount:+1
			EndIf
		Next				
		While icount<items.length
			RemoveItem icount
		Wend
	End Method		
	
	Method InsertItemFromKey(index,key$)
		Return InsertItem(index,key,"",0,datasource,0)
	End Method

	
' item handlers
		
	Method Clear()
		ClearListItems()
		items=Null
	End Method

	Method InsertItem(index,text$,tip$,icon,extra:Object,flags)
?debug
		If index<0 Or index>items.length Throw "Gadget item index out of range."
?
		items=items[..items.length+1]
		For Local i=items.length-2 To index Step -1
			items[i+1]=items[i]
		Next
		items[index]=New TGadgetItem
		items[index].Set(text,tip,icon,extra,flags)
		If flags&GADGETITEM_LOCALIZED Then
			InsertListItem(index,LocalizeString(text),LocalizeString(tip),icon,extra)
		Else
			InsertListItem(index,text,tip,icon,extra)
		EndIf
		If flags&GADGETITEM_DEFAULT SelectItem(index)
	End Method
	
	
	Method SetItem(index,text$,tip$,icon,extra:Object,flags)
?debug
		If index<0 Or index>=items.length Throw "Gadget item index out of range."
?
		items[index].Set(text,tip,icon,extra,flags)
		If flags&GADGETITEM_LOCALIZED Then
			SetListItem(index,LocalizeString(text),LocalizeString(tip),icon,extra)
		Else
			SetListItem(index,text,tip,icon,extra)
		EndIf
		If flags&GADGETITEM_DEFAULT SelectItem(index)
	End Method
	
	Method RemoveItem(index)
?debug
		If index<0 Or index>=items.length Throw "Gadget item index out of range."
?
		For Local i=index Until items.length-1
			items[i]=items[i+1]
		Next
		items=items[..items.length-1]
		RemoveListItem(index)
	End Method
	
	Method ItemCount()
		Return items.length
	End Method

	Method ItemText$(index)
?debug
		If index<0 Or index>=items.length Throw "Gadget item index out of range."
?
		Return items[index].text		
	End Method

	Method ItemTip$(index)
?debug
		If index<0 Or index>=items.length Throw "Gadget item index out of range."
?
		Return items[index].tip
	End Method

	Method ItemFlags(index)
?debug
		If index<0 Or index>=items.length Throw "Gadget item index out of range."
?
		Return items[index].flags
	End Method

	Method ItemIcon(index)
?debug
		If index<0 Or index>=items.length Throw "Gadget item index out of range."
?
		Return items[index].icon
	End Method
	
	Method ItemExtra:Object(index)
		If index = -1 Then Return Null
?debug
		If index<0 Or index>=items.length Throw "Gadget item index out of range."
?
		Return items[index].extra
	End Method

	Method SetItemState(index,state)
?debug
		If index<0 Or index>=items.length Throw "Gadget item index out of range."
?
		SetListItemState(index,state)
	End Method
	
	Method ItemState(index)
?debug
		If index<0 Or index>=items.length Throw "Gadget item index out of range."
?
		Return ListItemState(index)
	End Method
	
	Method SelectItem(index,op=1)	'0=deselect 1=select 2=toggle
		Local	item:TGadgetItem
		Local	state,icon	
		Local	i
		If index=-1
			For i=0 Until items.length
				SelectItem i,op
			Next
			Return
		EndIf
?debug
		If index<0 Or index>=items.length Throw "Gadget item index out of range."
?
		state=ItemState(index)
		Select op
		Case 0
			state:&~STATE_SELECTED
		Case 1
			state:|STATE_SELECTED
		Case 2
			state:~STATE_SELECTED
		End Select
		item=items[index]
		icon=item.icon
		If icon>-1 And item.flags&GADGETITEM_TOGGLE
			If state&STATE_SELECTED	icon:+1
			SetListItem index,item.text,item.tip,icon,item.extra	'toggle icon
		EndIf
		SetItemState index,state
	End Method

	Method SelectedItem()
		Local selection:Int[] = SelectedItems()
		If selection.length = 1 Then Return selection[0] Else Return -1
	End Method

	Method SelectedItems[]()
		Local	index,count,array[items.length]
		For index=0 Until items.length
			If ListItemState(index)&STATE_SELECTED Then
				array[count] = index
				count:+1
			EndIf
		Next
		If count Then Return array[..count]
	End Method
			
' maxgui interface
	Method Insert(group:TGadget,index=-1)
	End Method
	Method Query(queryid)
	End Method
	Method CleanUp()
		For Local tmpChild:TGadget = EachIn kids.Copy()
			tmpChild.CleanUp()
		Next
		Free()
		
		DelocalizeGadget( Self )
		kids.Clear();parent = Null;extra = Null
		eventfilter = Null;context = Null;items = Null
		
		For Local i% = 0 Until dragGadget.length
			If dragGadget[i] = Self Then dragGadget[i] = Null
		Next
	End Method
	Method Free()
	End Method
	Method Rethink()	'resize
	End Method		
	Method ClientWidth()
	End Method
	Method ClientHeight()
	End Method
	Method Activate(command)
	End Method
	Method State()
	End Method
	Method SetText(text$)
	End Method
	Method GetText$()
	End Method
	Method SetFont(font:TGuiFont)
	End Method
	Method SetColor(r,g,b)
	End Method
	Method RemoveColor()
	End Method
	Method SetAlpha(a#)
	End Method
	Method SetTextColor(r,g,b)
	End Method
	Method SetTooltip( pTip$ )
	EndMethod
	Method GetTooltip$()
	EndMethod
	Method SetPixmap(pixmap:TPixmap,flags)
	End Method
	Method SetIconStrip(iconstrip:TIconStrip)
	End Method
	Method SetShow(bool)
	End Method
	Method SetEnabled(bool)
	End Method
	Method SetSelected(bool)
	End Method
	Method SetHotKey(keycode,modifier)
	End Method
	Method SetSensitivity( flags )
		sensitivity = flags
	EndMethod
	Method GetSensitivity()
		Return sensitivity
	EndMethod
	Method Class()
	EndMethod
' window commands
	Method GetStatusText$()
	End Method
	Method SetStatusText(text$)
	End Method
	Method GetMenu:TGadget()
	End Method
	Method PopupMenu(menu:TGadget,extra:Object=Null)
	End Method
	Method UpdateMenu()
	End Method
	Method SetMinimumSize(w,h)
	End Method
	Method SetMaximumSize(w,h)
	End Method
' list commands
	Method ClearListItems()
	End Method
	Method InsertListItem(index,text$,tip$,icon,tag:Object)
	End Method
	Method SetListItem(index,text$,tip$,icon,tag:Object)
	End Method
	Method RemoveListItem(index)
	End Method
	Method SetListItemState(index,state)
	End Method
	Method ListItemState(index)
	End Method
' treeview commands
	Method RootNode:TGadget()
	End Method
	Method InsertNode:TGadget(index,text$,icon)
	End Method
	Method ModifyNode(text$,icon)
	End Method
	Method SelectedNode:TGadget()
	End Method
	Method CountKids()
	End Method
' textarea commands
	Method ReplaceText(pos,length,text$,units)
	End Method
	Method AddText(text$)
	End Method
	Method AreaText$(pos,length,units)
	End Method
	Method AreaLen(units)
	End Method
	Method LockText()
	End Method
	Method UnlockText()
	End Method
	Method SetTabs(tabwidth)
	End Method
	Method SetMargins(leftmargin)
	End Method
	Method GetCursorPos(units)
	End Method
	Method GetSelectionLength(units)
	End Method
	Method SetStyle(r,g,b,flags,pos,length,units)
	End Method	
	Method SetSelection(pos,length,units)
	End Method
	Method CharX(char)
	EndMethod
	Method CharY(char)
	EndMethod
	Method CharAt(line)
	End Method
	Method LineAt(index)
	End Method
' progbar
	Method SetValue(value#)
	End Method	
' slider
	Method SetRange(visible,total)
	End Method
	Method SetProp(value)
	End Method
	Method GetProp()
	End Method
' canvas
	Method AttachGraphics:TGraphics( flags )
	End Method
	Method CanvasGraphics:TGraphics()
	End Method
' htmlview
	Method Run$(script$)
	End Method
End Type

Global NullProxy:TGadget=New TGadget

Type TProxyGadget Extends TGadget
	Field	proxy:TGadget=NullProxy
	
	Method SetProxy(gadget:TGadget)
		If proxy And proxy.source = Self Then proxy.source = Null
		proxy=gadget
		If proxy Then proxy.source = Self
	End Method
	
	Method GetProxy:TGadget()
		Return proxy
	End Method
	
' maxgui interface
	Method GetXPos%()
		Return proxy.GetXPos()
	EndMethod
	Method GetYPos%()
		Return proxy.GetYPos()
	EndMethod
	Method GetWidth%()
		Return proxy.GetWidth()
	EndMethod
	Method GetHeight%()
		Return proxy.GetHeight()
	EndMethod
	Method GetGroup:TGadget()
		Return proxy.GetGroup()
	EndMethod
	Method HasDescendant(pGadget:TGadget)
		Return proxy.HasDescendant(pGadget)
	EndMethod
	Method Query(queryid)
		Return proxy.Query(queryid)
	End Method
	Method CleanUp()
		Return proxy.CleanUp()
	End Method
	Method Free()
		Return proxy.Free()
	End Method
	Method SetShape(x,y,w,h)
		proxy.SetShape(x,y,w,h)
	End Method
	Method Rethink()	'resize
		Return proxy.Rethink()
	End Method		
	Method ClientWidth()
		Return proxy.ClientWidth()
	End Method
	Method ClientHeight()
		Return proxy.ClientHeight()
	End Method
	Method Activate(command)
		Return proxy.Activate(command)
	End Method
	Method State()
		Return proxy.State()
	End Method
	Method SetText(text$)
		Return proxy.SetText(text)
	End Method
	Method GetText$()
		Return proxy.GetText()
	End Method
	Method SetTooltip( pTip$ )
		Return proxy.SetTooltip( pTip )
	EndMethod
	Method GetTooltip$()
		Return proxy.GetTooltip()
	EndMethod
	Method SetFont(font:TGuiFont)
		Return proxy.SetFont(font)
	End Method
	Method SetColor(r,g,b)
		Return proxy.SetColor(r,g,b)
	End Method
	Method RemoveColor()
		Return proxy.RemoveColor()
	End Method
	Method SetAlpha(a#)
		Return proxy.SetAlpha(a)
	End Method
	Method SetTextColor(r,g,b)
		Return proxy.SetTextColor(r,g,b)
	End Method
	Method SetShow(bool)
		Return proxy.SetShow(bool)
	End Method
	Method SetSelected(bool)
		Return proxy.SetSelected(bool)
	End Method
	Method SetEnabled(bool)
		Return proxy.SetEnabled(bool)
	End Method
	Method SetSensitivity( flags )
		Return proxy.SetSensitivity(flags)
	EndMethod
	Method GetSensitivity()
		Return proxy.GetSensitivity()
	EndMethod
	Method SetHotKey(keycode,modifier)
		Return proxy.SetHotKey(keycode,modifier)
	End Method
	Method SetIconStrip(iconstrip:TIconStrip)
		Return proxy.SetIconStrip(iconstrip)
	End Method
	Method SetLayout( lft,rht,top,bot )
		proxy.SetLayout lft,rht,top,bot
	End Method
	Method Class()
		Return proxy.Class()
	EndMethod
' window commands
	Method GetStatusText$()
	End Method
	Method SetStatusText(text$)
		Return proxy.SetStatusText(text)
	End Method
	Method SetStatus(text$)
		Return Self.SetStatusText(text)
	EndMethod
	Method GetMenu:TGadget()
		Return proxy.GetMenu()
	End Method
	Method PopupMenu(menu:TGadget,extra:Object)
		Return proxy.PopupMenu(menu,extra)
	End Method
	Method UpdateMenu()
		Return proxy.UpdateMenu()
	End Method
	Method SetMinimumSize(w,h)
		Return proxy.SetMinimumSize(w,h)
	End Method
	Method SetMaximumSize(w,h)
		Return proxy.SetMaximumSize(w,h)
	End Method
' list commands
	Method ClearListItems()
		Return proxy.ClearListItems()
	End Method
	Method InsertListItem(index,text$,tip$,icon,extra:Object)
		Return proxy.InsertListItem(index,text,tip,icon,extra)
	End Method
	Method SetListItem(index,text$,tip$,icon,extra:Object)
		Return proxy.SetListItem(index,text,tip,icon,extra)
	End Method
	Method RemoveListItem(index)
		Return proxy.RemoveListItem(index)
	End Method
	Method SetListItemState(index,state)
		Return proxy.SetListItemState(index,state)
	End Method
	Method ListItemState(index)
		Return proxy.ListItemState(index)
	End Method
' treeview commands
	Method RootNode:TGadget()
		Return proxy.RootNode()
	End Method
	Method InsertNode:TGadget(index,text$,icon)
		Return proxy.InsertNode(index,text,icon)
	End Method
	Method ModifyNode(text$,icon)
		Return proxy.ModifyNode(text,icon)
	End Method
	Method SelectedNode:TGadget()
		Return proxy.SelectedNode()
	End Method
	Method CountKids()
		Return proxy.CountKids()
	End Method
' textarea commands
	Method ReplaceText(pos,length,text$,units)
		Return proxy.ReplaceText(pos,length,text,units)
	End Method
	Method AddText(text$)
		Return proxy.AddText(text)
	End Method
	Method AreaText$(pos,length,units)
		Return proxy.AreaText(pos,length,units)
	End Method
	Method AreaLen(units)
		Return proxy.AreaLen(units)
	End Method
	Method LockText()
		Return proxy.LockText()
	End Method
	Method UnlockText()
		Return proxy.UnlockText()
	End Method
	Method SetTabs(tabwidth)
		Return proxy.SetTabs(tabwidth)
	End Method
	Method SetMargins(leftmargin)
		Return proxy.SetMargins(leftmargin)
	End Method
	Method GetCursorPos(units)
		Return proxy.GetCursorPos(units)
	End Method
	Method GetSelectionLength(units)
		Return proxy.GetSelectionLength(units)
	End Method
	Method SetStyle(r,g,b,flags,pos,length,units)
		Return proxy.SetStyle(r,g,b,flags,pos,length,units)
	End Method	
	Method SetSelection(pos,length,units)
		Return proxy.SetSelection(pos,length,units)
	End Method
	Method CharX(char)
		Return proxy.CharX(char)
	End Method
	Method CharY(char)
		Return proxy.CharY(char)
	End Method
	Method CharAt(line)
		Return proxy.CharAt(line)
	End Method
	Method LineAt(index)
		Return proxy.LineAt(index)
	End Method
' progbar
	Method SetValue(value#)
		Return proxy.SetValue(value)
	End Method	
' slider
	Method SetRange(visible,total)
		Return proxy.SetRange(visible,total)
	End Method
	Method SetProp(value)
		Return proxy.SetProp(value)
	End Method
	Method GetProp()
		Return proxy.GetProp()
	End Method
' panel
	Method SetPixmap(pixmap:TPixmap,flags)
		Return proxy.SetPixmap(pixmap,flags)
	End Method
' canvas
	Method AttachGraphics:TGraphics( flags )
		Return proxy.AttachGraphics( flags )
	End Method
	Method CanvasGraphics:TGraphics()
		Return proxy.CanvasGraphics()
	End Method
' htmlview
	Method Run$(script$)
		Return proxy.Run(script)
	End Method
'items	
	Method Clear()
		Return proxy.Clear()
	End Method
	Method InsertItem(index,text$,tip$,icon,extra:Object,flags)
		Return proxy.InsertItem(index,text,tip,icon,extra,flags)
	End Method
	Method SetItem(index,text$,tip$,icon,extra:Object,flags)
		Return proxy.SetItem(index,text,tip,icon,extra,flags)
	End Method
	Method RemoveItem(index)
		Return proxy.RemoveItem(index)
	End Method
	Method ItemCount()
		Return proxy.ItemCount()
	End Method
	Method ItemText$(index)
		Return proxy.ItemText(index)	
	End Method
	Method ItemTip$(index)
		Return proxy.ItemTip(index)
	End Method
	Method ItemFlags(index)
		Return proxy.ItemFlags(index)
	End Method
	Method ItemIcon(index)
		Return proxy.ItemIcon(index)
	End Method
	Method ItemExtra:Object(index)
		Return proxy.ItemExtra(index)
	End Method
	Method SetItemState(index,state)
		Return proxy.SetItemState(index,state)
	End Method
	Method ItemState(index)
		Return proxy.ItemState(index)
	End Method
	Method SelectItem(index,op=1)	'0=deselect 1=select 2=toggle
		Return proxy.SelectItem(index,op)
	End Method
	Method SelectedItem()
		Return proxy.SelectedItem()
	End Method
	Method SelectedItems[]()
		Return proxy.SelectedItems()
	End Method
End Type
