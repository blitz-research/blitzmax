'This is *included* by fltkgui.bmx, fltkfont.bmx and fltksystem.bmx - the
'include statements are sandwiched between Private and Public keywords to
'avoid wasting namespaces outside of FLTKMaxGUI.

Extern "C"

Function flAddFd(fd,when,callback(fd:Int,user:Byte Ptr),user:Byte Ptr)
Function flReset(xdisplay,callback:Int(event),filter:Int(user:Int),mousehandler:Int(flwidget,user:Int),keyhandler:Int(flwidget,user:Int))
Function flCountFonts()

Function flBelowMouse()
Function flSetBelowMouse(widget)

Function flGetColor( index )
Function flChooseColor(title$z,r:Byte Ptr,g:Byte Ptr,b:Byte Ptr)

Function flFontName$z(i)
Function flFontSizes:Int(fontid, sizes Ptr)
Function flFriendlyFontName$z(i)
Function flFriendlyFontAttributes(i)

Function flRun()
Function flWait(timeout)
Function flFlush()
Function flHandle(xevent:Byte Ptr)

Function flAddTimeout(t:Double,callback(user:Object),user:Object=Null)
Function flRequest(text$z,flags)
Function flRequestFile$z(message$z,pattern$z,path$z,save)
Function flRequestDir$z(message$z,path$z,relative)

Function flWidget(x,y,w,h,label:Byte Ptr,fltype)
Function flFreeWidget(widget)
Function flFreePtr(data:Byte Ptr)
Function flUserData(widget)
Function flDelete(pointer:Byte Ptr)

Function flSetColor(widget,r,g,b)
Function flRemoveColor(widget)
Function flSetLabel(widget,name$z)
Function flSetLabelColor(widget,r,g,b)
Function flSetLabelFont(widget,font)
Function flSetLabelSize(widget,size)
Function flGetLabel$z(widget)
Function flSetBox(widget,boxtype,redrawifneeded)
Function flSetLabelType(widget,labeltype)
Function flSetAlign(widget,aligntype)
Function flAlign(widget)

Function flSetArea(widget,x,y,w,h)
Function flGetArea(widget,x Ptr,y Ptr,w Ptr,h Ptr)
Function flSetFocus(widget)
Function flGetFocus()
Function flSetWhen(widget,when)
Function flGetWhen(widget)
Function flGetUser:Int(widget)
Function flSetShow(widget,truefalse)
Function flSetCallback(widget,callback(flwidget,user:Int),user:Int=0)
Function flSetToolTip(widget,tip:Byte Ptr)
Function flSetActive(widget,truefalse)
Function flWidgetWindow(widget)

Function flPushed()
Function flSetPushed(widget)
Function flRedraw(widget)
Function flWidth(widget)
Function flHeight(widget)
Function flVisible(widget)
Function flChanged(widget)
Function flClearChanged(widget)

Function flShowWindow(window,truefalse)
Function flSetWindowIcon(window,icon:Byte Ptr)
Function flDestroyWindow(window)
Function flSetWindowLabel(window,name$z)
Function flClearBorder(window)
Function flSetMaxWindowSize(window,width,height)
Function flSetMinWindowSize(window,width,height)
Function flSetAcceptsFiles(window,enable)
Function flSetModal(window)
Function flSetNonModal(window)

Function flBegin(group)
Function flEnd(group)
Function flAddToGroup(group,widget)
Function flRemoveFromGroup(group,widget)

Function flSetInputChoice(inputchoicewidget,value)
Function flGetInputChoiceMenuWidget(inputchoicewidget)
Function flGetInputChoiceTextWidget(inputchoicewidget)

Function flSetChoice(choicewidget,value)
Function flGetChoice(choicewidget)

Function flSetInput(inputwidget,value$z)
Function flGetInput$z(inputwidget)
Function flActivateInput(inputwidget)
Function flSetInputFont(widget,font)
Function flSetInputSize(widget,size)

' panel

Function flImage(pix:Byte Ptr,w,h,d,span)
Function flFreeImage( image )
Function flSetImage(widget,image)
Function flSetPanelColor(panel,r,g,b)
Function flSetPanelImage(panel,image,pixmapflags)
Function flSetPanelActive(panel,yesno=True)
Function flSetPanelEnabled(panel,yesno=True)

' tabs

Function flSelectTab(tabber,panel)
Function flGetTabPanel(tabber)
Function flGetTabPanelForEvent(tabber)

' menubar

Function flCreateMenu Ptr(maxitems,callback(flwidget,user:Int))
Function flSetMenuItem(menu Ptr,item,label$z,shortcut,user:Int,flags,fonthandle,pfontsize)
Function flSetMenu(menubar,menu Ptr)
Function flPopupMenu:Int(menu Ptr,nil:Int=0)

' button

Function flSetButton(button,value)
Function flGetButton(button)
Function flSetButtonKey(button,key)

' browser

Function flClearBrowser(browser)
Function flAddBrowser(browser,label$z,obj:Object=Null,img = 0)
Function flInsertBrowser(browser,index,label$z,obj:Object=Null,img = 0)
Function flShowBrowser(browser,line,show)
Function flSelectBrowser(browser,line)
Function flMultiBrowserSelect(browser,line,seldesel)
Function flMultiBrowserSelected(browser,line)
Function flBrowserValue(browser)
Function flBrowserItem$z(browser,line)
Function flBrowserData:Object(browser,line)
Function flSetBrowserItem(browser,line,text$z,obj:Object=Null,img = 0)
Function flRemoveBrowserItem(browser,line)
Function flSetBrowserTextColor(browser,r,g,b)
Function flSetBrowserTextFont(browser,font)
Function flSetBrowserTextSize(browser,size)
Function flBrowserCount(browser)

' editor

Function flCharPosXY(textdisplay,char,x Ptr,y Ptr)

Function flLinePos(textdisplay,line)
Function flLineStart(textdisplay,pos)
Function flLineCount(textdisplay,pos)
Function flTextLength(textdisplay)

Function flSetWrapMode(textdisplay,bool,column)

Function flSetText(textdisplay,text:Byte Ptr)
Function flSetEditTextColor(textdisplay,r,g,b)
Function flSetTextFont(editor,font)
Function flSetTextSize(editor,size)
Function flAddText(textdisplay,text:Byte Ptr)
Function flReplaceText(textdisplay,start,count,text:Byte Ptr)
Function flSelectText(textdisplay,start,count)
Function flFreeTextDisplay(textdisplay)
Function flShowPosition(textdisplay)
Function flRedrawText(textdisplay,start,count)
Function flGetText:Byte Ptr(textdisplay,start=0,count=-1)
Function flSetTextCallback(textdisplay,callback(pos,inserted,deleted,restyled,text:Byte Ptr,obj:Int),user:Int)
Function flSetTextTabs(textdisplay,tabs)

Function flGetCursorPos(textdisplay)
Function flGetSelectionLen(textdisplay)

Function flGetTextStyleChar(textdisplay,r,g,b,font,size)
Function flSetTextStyle(textdisplay,text$z)
Function flAddTextStyle(textdisplay,text$z)
Function flReplaceTextStyle(textdisplay,start,count,text$z)
Function flInsertTextStyle(textdisplay,start,text$z)
Function flDeleteTextStyle(textdisplay,start,count)

Function flActivateText(textdisplay)

Function flCutText(editor)
Function flCopyText(editor)
Function flPasteText(editor)

'htmlview

Function flSetView(view,html$z)
Function flSeekView(view,anchor$z)
Function flRedirectView(view,url$z)
Function flSetLineView(view,line) ' markcw
Function flGetLineView(view) ' markcw
Function flSetPathView(view,path$z)
Function flGetPathView$z(view)
Function flIsLinkView(view)
Function flSetStyleView(view,flag)

' progbar

Function flSetProgress(progbar,value#)

' slider

Function flSetSliderType(slider,slidertype)

Function flSliderValue:Double(slider)
Function flSetSliderValue(slider,value:Double)
Function flSetSliderRange(slider,low:Double,hi:Double)

Function flScrollbarValue(scrollbar)
Function flSetScrollbarValue(scrollbar,value,visible,lowest,total)

Function flSetSpinnerMin(spinner,minimum:Double)
Function flSetSpinnerMax(spinner,maximum:Double)
Function flSetSpinnerValue(spinner,value:Double)
Function flSpinnerValue:Double(spinner)

' canvas

Function flCanvasWindow(canvas)
Function flSetCanvasMode(canvas,mode)

'Function flBeginPaint(canvas)
'Function flEndPaint(canvas)

' event

Function flEvent()
Function flEventKey()
Function flEventdX()
Function flEventdY()
Function flEventX()
Function flEventY()
Function flEventState()
Function flEventKeys(key)
Function flEventButtons()
Function flEventButton()
Function flEventClicks()
Function flEventText$z()
Function flEventURL$z()
Function flCompose(del Ptr)

Function flDisplayRect(x Ptr,y Ptr,w Ptr,h Ptr)

' pointer

Function flSetCursor(shape)

' nodes

Function fluRootNode( tree )
Function fluSelectedNode( tree, index )
Function fluInsertNode( parent, pos, text:Byte Ptr )
Function fluAddNode( parent, text:Byte Ptr )
Function fluRemoveNode( tree, node )
Function fluSetNode( node, text:Byte Ptr, iconimage )
Function fluSetNodeUserData( node, user_data )
Function fluNodeUserData( node )
Function fluExpandNode( node, collapse )
Function fluSelectNode( node )
Function fluCallbackNode( tree )
Function fluCallbackReason( tree )

End Extern

?MacOS
Extern
	Function NSContentView(window)
	Function NSUpdateCanvas(window)
EndExtern
?

Const FL_READ=1
Const FL_WRITE=4
Const FL_EXCEPT=8

Const FL_FOREGROUND_COLOR = 0
Const FL_BACKGROUND_COLOR = 49
Const FL_BACKGROUND2_COLOR = 7
Const FL_INACTIVE_COLOR = 8
Const FL_SELECTION_COLOR = 15

Const FL_WINDOW=0
Const FL_MENUBAR=1
Const FL_BUTTON=2
Const FL_CHECKBUTTON=3
Const FL_ROUNDBUTTON=4
Const FL_TOGGLEBUTTON=5
Const FL_RADIOPUSHBUTTON=6
Const FL_RETURNBUTTON=7
Const FL_PANEL=8
Const FL_GROUP_PANEL=9
Const FL_INPUT=10
Const FL_PASSWORD=11
Const FL_TABS=12
Const FL_GROUP=13
Const FL_PACK=14
Const FL_BROWSER=15
Const FL_MULTIBROWSER=16
Const FL_CHOICE=17
Const FL_TEXTEDITOR=18
Const FL_TEXTDISPLAY=19
Const FL_HELPVIEW=20
Const FL_BOX=21
Const FL_TOOLBAR=22
Const FL_PROGBAR=23
Const FL_SLIDER=24
Const FL_SCROLLBAR=25
Const FL_SPINNER=26
Const FL_CANVAS=27
Const FL_INPUTCHOICE=28
Const FLU_TREEBROWSER=29
Const FL_REPEATBUTTON=30
Const FL_MENUITEM=50
Const FL_DESKTOP=51
Const FL_TIMER=52

Const FL_HELVETICA=0
Const FL_COURIER=4
Const FL_TIMES=8
Const FL_SYMBOL=12
Const FL_SCREEN=13
Const FL_SCREEN_BOLD=14
Const FL_ZAPF_DINGBATS=15

Const FL_BOLD=1
Const FL_ITALIC=2

Const FL_MENU_INACTIVE=$1
Const FL_MENU_TOGGLE= $2
Const FL_MENU_VALUE=$4
Const FL_MENU_RADIO=$8
Const FL_MENU_INVISIBLE=$10
Const FL_SUBMENU_POINTER=$20
Const FL_SUBMENU=$40
Const FL_MENU_DIVIDER=$80
Const FL_MENU_HORIZONTAL=$100

Const FL_NO_EVENT=0
Const FL_PUSH=1
Const FL_RELEASE=2
Const FL_ENTER=3
Const FL_LEAVE=4
Const FL_DRAG=5
Const FL_FOCUS=6
Const FL_UNFOCUS=7
Const FL_KEYDOWN=8
Const FL_KEYUP=9
Const FL_CLOSE=10
Const FL_MOVE=11
Const FL_SHORTCUT=12
Const FL_DEACTIVATE=13
Const FL_ACTIVATE=14
Const FL_HIDE=15
Const FL_SHOW=16
Const FL_PASTE=17
Const FL_SELECTIONCLEAR=18
Const FL_MOUSEWHEEL=19
Const FL_DND_ENTER=20
Const FL_DND_DRAG=21
Const FL_DND_LEAVE=22
Const FL_DND_RELEASE=23

Const FL_WHEN_NEVER=0
Const FL_WHEN_CHANGED=1
Const FL_WHEN_RELEASE=4
Const FL_WHEN_RELEASE_ALWAYS=6
Const FL_WHEN_ENTER_KEY=8
Const FL_WHEN_ENTER_KEY_ALWAYS=10
Const FL_WHEN_ENTER_KEY_CHANGED=11
Const FL_WHEN_NOT_CHANGED=2			'modifierbittodisablechanged()test

' box types

Const FL_NO_BOX=0
Const FL_FLAT_BOX=1
Const FL_UP_BOX=2
Const FL_DOWN_BOX=3
Const FL_UP_FRAME=4
Const FL_DOWN_FRAME=5
Const FL_THIN_UP_BOX=6
Const FL_THIN_DOWN_BOX=7
Const FL_THIN_UP_FRAME=8
Const FL_THIN_DOWN_FRAME=9
Const FL_ENGRAVED_BOX=10
Const FL_EMBOSSED_BOX=11
Const FL_ENGRAVED_FRAME=12
Const FL_EMBOSSED_FRAME=13
Const FL_BORDER_BOX=14
Const FL_SHADOW_BOX=15
Const FL_BORDER_FRAME=16
Const FL_SHADOW_FRAME=17
Const FL_ROUNDED_BOX=18
Const FL_RSHADOW_BOX=19
Const FL_ROUNDED_FRAME=20
Const FL_RFLAT_BOX=21
Const FL_ROUND_UP_BOX=22
Const FL_ROUND_DOWN_BOX=23
Const FL_DIAMOND_UP_BOX=24
Const FL_DIAMOND_DOWN_BOX=25
Const FL_OVAL_BOX=26
Const FL_OSHADOW_BOX=27
Const FL_OVAL_FRAME=28
Const FL_OFLAT_BOX=29
Const FL_PLASTIC_UP_BOX=30
Const FL_PLASTIC_DOWN_BOX=31
Const FL_PLASTIC_UP_FRAME=32
Const FL_PLASTIC_DOWN_FRAME=33
Const FL_PLASTIC_THIN_UP_BOX=34
Const FL_PLASTIC_THIN_DOWN_BOX=35
Const FL_FREE_BOXTYPE=36

' alignment flags

Const FL_ALIGN_CENTER=0
Const FL_ALIGN_TOP=1
Const FL_ALIGN_BOTTOM=2
Const FL_ALIGN_LEFT=4
Const FL_ALIGN_RIGHT=8
Const FL_ALIGN_INSIDE=16
Const FL_TEXT_OVER_IMAGE=32
Const FL_IMAGE_OVER_TEXT=0
Const FL_ALIGN_CLIP=64
Const FL_ALIGN_WRAP=128
Const FL_ALIGN_TOP_LEFT		= FL_ALIGN_TOP | FL_ALIGN_LEFT
Const FL_ALIGN_TOP_RIGHT	= FL_ALIGN_TOP | FL_ALIGN_RIGHT
Const FL_ALIGN_BOTTOM_LEFT	= FL_ALIGN_BOTTOM | FL_ALIGN_LEFT
Const FL_ALIGN_BOTTOM_RIGHT	= FL_ALIGN_BOTTOM | FL_ALIGN_RIGHT
Const FL_ALIGN_LEFT_TOP		= FL_ALIGN_TOP_LEFT
Const FL_ALIGN_RIGHT_TOP	= FL_ALIGN_TOP_RIGHT
Const FL_ALIGN_LEFT_BOTTOM	= FL_ALIGN_BOTTOM_LEFT
Const FL_ALIGN_RIGHT_BOTTOM	= FL_ALIGN_BOTTOM_RIGHT
Const FL_ALIGN_NOWRAP		= 0

'labeltype flags

Const FL_NORMAL_LABEL = 0
Const FL_NO_LABEL = 1
Const FL_SHADOW_LABEL = 2
Const FL_ENGRAVED_LABEL = 3
Const FL_EMBOSSED_LABEL = 4
Const FL_ICON_LABEL = 5
Const FL_IMAGE_LABEL = 6

' mouse event buttons

Const FL_LEFT_MOUSE=1
Const FL_MIDDLE_MOUSE=2
Const FL_RIGHT_MOUSE=3

' event states

Const FL_SHIFT=$00010000
Const FL_CAPS_LOCK=$00020000
Const FL_CTRL=$00040000
Const FL_ALT=$00080000
Const FL_NUM_LOCK=$00100000			'mostXserversdothis?
Const FL_META=$00400000				'correctforXFree86
Const FL_SCROLL_LOCK=$00800000		'correctforXFree86
Const FL_BUTTON1=$01000000
Const FL_BUTTON2=$02000000
Const FL_BUTTON3=$04000000
Const FL_BUTTONS=$7f000000			'Allpossiblebuttons

' extended keys

Const FL_KEY_Button=$fee8				'useFL_KEY_Button+FL_KEY_*_MOUSE
Const FL_KEY_BackSpace=$ff08
Const FL_KEY_Tab=$ff09
Const FL_KEY_Enter=$ff0d
Const FL_KEY_Pause=$ff13
Const FL_KEY_Scroll_Lock=$ff14
Const FL_KEY_Escape=$ff1b
Const FL_KEY_Home=$ff50
Const FL_KEY_Left=$ff51
Const FL_KEY_Up=$ff52
Const FL_KEY_Right=$ff53
Const FL_KEY_Down=$ff54
Const FL_KEY_Page_Up=$ff55
Const FL_KEY_Page_Down=$ff56
Const FL_KEY_End=$ff57
Const FL_KEY_Print=$ff61
Const FL_KEY_Insert=$ff63
Const FL_KEY_Menu=$ff67					'the"menu/apps"keyonXFree86
Const FL_KEY_Help=$ff68					'the'help'keyonMackeyboards
Const FL_KEY_Num_Lock=$ff7f
Const FL_KEY_KP=$ff80					'useFL_KEY_KP+'x'for'x'onnumerickeypad
Const FL_KEY_KP_Enter=$ff8d				'sameasFL_KEY_KP+'\r'
Const FL_KEY_KP_Last=$ffbd				'usetorange-checkkeypad
Const FL_KEY_F=$ffbd					'useFL_KEY_F+nforfunctionkeyn
Const FL_KEY_F_Last=$ffe0				'usetorange-checkfunctionkeys
Const FL_KEY_Shift_L=$ffe1
Const FL_KEY_Shift_R=$ffe2
Const FL_KEY_Control_L=$ffe3
Const FL_KEY_Control_R=$ffe4
Const FL_KEY_Caps_Lock=$ffe5
Const FL_KEY_Meta_L=$ffe7				'theleftMSWindowskeyonXFree86
Const FL_KEY_Meta_R=$ffe8				'therightMSWindowskeyonXFree86
Const FL_KEY_Alt_L=$ffe9
Const FL_KEY_Alt_R=$ffea
Const FL_KEY_Delete=$ffff

' slider types

Const FL_VERT_SLIDER=0
Const FL_HOR_SLIDER=1
Const FL_VERT_FILL_SLIDER=2
Const FL_HOR_FILL_SLIDER=3
Const FL_VERT_NICE_SLIDER=4
Const FL_HOR_NICE_SLIDER=5

' flu constants

Const FLU_NO_SELECT = 0
Const FLU_SINGLE_SELECT = 1
Const FLU_MULTI_SELECT = 2

Const FLU_INSERT_FRONT = 0
Const FLU_INSERT_BACK = 1
Const FLU_INSERT_SORTED = 2
Const FLU_INSERT_SORTED_REVERSE = 3

Const FLU_DRAG_IGNORE = 0
Const FLU_DRAG_TO_SELECT = 1
Const FLU_DRAG_TO_MOVE = 2

Const FLU_HILIGHTED = 0
Const FLU_UNHILIGHTED = 1
Const FLU_SELECTED = 2
Const FLU_UNSELECTED = 3
Const FLU_OPENED = 4
Const FLU_CLOSED = 5
Const FLU_DOUBLE_CLICK = 6
Const FLU_WIDGET_CALLBACK = 7
Const FLU_MOVED_NODE = 8
Const FLU_NEW_NODE = 9
Const FLU_NOTHING = 10
