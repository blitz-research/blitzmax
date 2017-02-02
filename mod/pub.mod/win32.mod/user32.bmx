Strict

Const MAX_PATH=260

Const DLGWINDOWEXTRA=30

' popupmenus

Const TPM_LEFTBUTTON=0
Const TPM_RIGHTBUTTON=2
Const TPM_LEFTALIGN=0
Const TPM_CENTERALIGN=4
Const TPM_RIGHTALIGN=8
Const TPM_TOPALIGN=0
Const TPM_VCENTERALIGN=16
Const TPM_BOTTOMALIGN=32
Const TPM_HORIZONTAL=0
Const TPM_VERTICAL=$40
Const TPM_NONOTIFY=$80
Const TPM_RETURNCMD=$100
Const TPM_RECURSE=1
Const TPM_HORPOSANIMATION=$400
Const TPM_HORNEGANIMATION=$800
Const TPM_VERPOSANIMATION=$1000
Const TPM_VERNEGANIMATION=$2000
Const TPM_NOANIMATION=$4000
Const TPM_LAYOUTRTL=$8000

' clipboard formats

Const CF_TEXT=1
Const CF_BITMAP=2
Const CF_METAFILEPICT=3
Const CF_SYLK=4
Const CF_DIF=5
Const CF_TIFF=6
Const CF_OEMTEXT=7
Const CF_DIB=8
Const CF_PALETTE=9
Const CF_PENDATA=10
Const CF_RIFF=11
Const CF_WAVE=12
Const CF_UNICODETEXT=13
Const CF_ENHMETAFILE=14
Const CF_HDROP=15
Const CF_LOCALE=16
Const CF_DIBV5=17

Const CF_OWNERDISPLAY=$0080
Const CF_DSPTEXT=$0081
Const CF_DSPBITMAP=$0082
Const CF_DSPMETAFILEPICT=$0083
Const CF_DSPENHMETAFILE=$008E

' "Private" formats don't get GlobalFree()'d
Const CF_PRIVATEFIRST=$0200
Const CF_PRIVATELAST=$02FF
' "GDIOBJ" formats do get DeleteObject()'d
Const CF_GDIOBJFIRST=$0300
Const CF_GDIOBJLAST=$03FF


' virtualkey modifiers

Const VK_SHIFT=$10
Const VK_CONTROL=$11
Const VK_MENU=$12
Const VK_LWIN=$5b
Const VK_RWIN=$5c

' windows hooks

Const WH_MSGFILTER=-1
Const WH_JOURNALRECORD=0
Const WH_JOURNALPLAYBACK=1
Const WH_KEYBOARD=2
Const WH_GETMESSAGE=3
Const WH_CALLWNDPROC=4
Const WH_CBT=5
Const WH_SYSMSGFILTER=6
Const WH_MOUSE=7
Const WH_HARDWARE=8
Const WH_DEBUG=9
Const WH_SHELL=10
Const WH_FOREGROUNDIDLE=11
Const WH_CALLWNDPROCRET=12
Const WH_KEYBOARD_LL=13
Const WH_MOUSE_LL=14

' wndclass styles

Const CS_BYTEALIGNCLIENT=4096
Const CS_BYTEALIGNWINDOW=8192
Const CS_KEYCVTWINDOW=4
Const CS_NOKEYCVT=256
Const CS_CLASSDC=64
Const CS_DBLCLKS=8
Const CS_GLOBALCLASS=16384
Const CS_HREDRAW=2
Const CS_NOCLOSE=512
Const CS_OWNDC=32
Const CS_PARENTDC=128
Const CS_SAVEBITS=2048
Const CS_VREDRAW=1

Const CW_USEDEFAULT=$80000000

Const COLOR_SCROLLBAR=0
Const COLOR_BACKGROUND=1
Const COLOR_ACTIVECAPTION=2
Const COLOR_INACTIVECAPTION=3
Const COLOR_MENU=4
Const COLOR_WINDOW=5
Const COLOR_WINDOWFRAME=6
Const COLOR_MENUTEXT=7
Const COLOR_WINDOWTEXT=8
Const COLOR_CAPTIONTEXT=9
Const COLOR_ACTIVEBORDER=10
Const COLOR_INACTIVEBORDER=11
Const COLOR_APPWORKSPACE=12
Const COLOR_HIGHLIGHT=13
Const COLOR_HIGHLIGHTTEXT=14
Const COLOR_BTNFACE=15
Const COLOR_BTNSHADOW=16
Const COLOR_GRAYTEXT=17
Const COLOR_BTNTEXT=18
Const COLOR_INACTIVECAPTIONTEXT=19
Const COLOR_BTNHIGHLIGHT=20
Const COLOR_3DDKSHADOW=21
Const COLOR_3DLIGHT=22
Const COLOR_INFOTEXT=23
Const COLOR_INFOBK=24
Const COLOR_HOTLIGHT=26
Const COLOR_GRADIENTACTIVECAPTION=27
Const COLOR_GRADIENTINACTIVECAPTION=28
Const COLOR_MENUHILIGHT=29
Const COLOR_MENUBAR=30

' window styles

Const WS_BORDER=$800000
Const WS_CAPTION=$c00000
Const WS_CHILD=$40000000
Const WS_CHILDWINDOW=$40000000
Const WS_CLIPCHILDREN=$2000000
Const WS_CLIPSIBLINGS=$4000000
Const WS_DISABLED=$8000000
Const WS_DLGFRAME=$400000
Const WS_GROUP=$20000
Const WS_HSCROLL=$100000
Const WS_ICONIC=$20000000
Const WS_MAXIMIZE=$1000000
Const WS_MAXIMIZEBOX=$10000
Const WS_MINIMIZE=$20000000
Const WS_MINIMIZEBOX=$20000
Const WS_OVERLAPPED=0
Const WS_OVERLAPPEDWINDOW=$cf0000
Const WS_POPUP=$80000000
Const WS_POPUPWINDOW=$80880000
Const WS_SIZEBOX=$40000
Const WS_SYSMENU=$80000
Const WS_TABSTOP=$10000
Const WS_THICKFRAME=$40000
Const WS_TILED=0
Const WS_TILEDWINDOW=$cf0000
Const WS_VISIBLE=$10000000
Const WS_VSCROLL=$200000

' windows extended styles

Const WS_EX_DLGMODALFRAME=$1
Const WS_EX_NOPARENTNOTIFY=$4
Const WS_EX_TOPMOST=$8
Const WS_EX_ACCEPTFILES=$10
Const WS_EX_TRANSPARENT=$20
Const WS_EX_MDICHILD=$40
Const WS_EX_TOOLWINDOW=$80
Const WS_EX_WINDOWEDGE=$100
Const WS_EX_CLIENTEDGE=$200
Const WS_EX_CONTEXTHELP=$400
Const WS_EX_RIGHT=$1000
Const WS_EX_LEFT=0
Const WS_EX_RTLREADING=$2000
Const WS_EX_LTRREADING=0
Const WS_EX_LEFTSCROLLBAR=$4000
Const WS_EX_RIGHTSCROLLBAR=0
Const WS_EX_CONTROLPARENT=$10000
Const WS_EX_STATICEDGE=$20000
Const WS_EX_APPWINDOW=$40000
Const WS_EX_OVERLAPPEDWINDOW=(WS_EX_WINDOWEDGE | WS_EX_CLIENTEDGE)
Const WS_EX_PALETTEWINDOW=(WS_EX_WINDOWEDGE | WS_EX_TOOLWINDOW | WS_EX_TOPMOST)
Const WS_EX_LAYERED=$80000
Const WS_EX_NOINHERITLAYOUT=$100000
Const WS_EX_LAYOUTRTL=$400000
Const WS_EX_COMPOSITED=$2000000
Const WS_EX_NOACTIVATE=$8000000

' windows messages

Const WM_DPICHANGED = $2E0
Const WM_APP=32768
Const WM_ACTIVATE=6
Const WM_ACTIVATEAPP=28
Const WM_AFXFIRST=864
Const WM_AFXLAST=895
Const WM_ASKCBFORMATNAME=780
Const WM_CANCELJOURNAL=75
Const WM_CANCELMODE=31
Const WM_CAPTURECHANGED=533
Const WM_CHANGECBCHAIN=781
Const WM_CHAR=258
Const WM_CHARTOITEM=47
Const WM_CHILDACTIVATE=34
Const WM_CLEAR=771
Const WM_CLOSE=16
Const WM_COMMAND=273
Const WM_COMMNOTIFY=68
Const WM_COMPACTING=65
Const WM_COMPAREITEM=57
Const WM_CONTEXTMENU=123
Const WM_COPY=769
Const WM_COPYDATA=74
Const WM_CREATE=1
Const WM_CTLCOLORBTN=309
Const WM_CTLCOLORDLG=310
Const WM_CTLCOLOREDIT=307
Const WM_CTLCOLORLISTBOX=308
Const WM_CTLCOLORMSGBOX=306
Const WM_CTLCOLORSCROLLBAR=311
Const WM_CTLCOLORSTATIC=312
Const WM_CUT=768
Const WM_DEADCHAR=259
Const WM_DELETEITEM=45
Const WM_DESTROY=2
Const WM_DESTROYCLIPBOARD=775
Const WM_DEVICECHANGE=537
Const WM_DEVMODECHANGE=27
Const WM_DISPLAYCHANGE=126
Const WM_DRAWCLIPBOARD=776
Const WM_DRAWITEM=43
Const WM_DROPFILES=563
Const WM_ENABLE=10
Const WM_ENDSESSION=22
Const WM_ENTERIDLE=289
Const WM_ENTERMENULOOP=529
Const WM_ENTERSIZEMOVE=561
Const WM_ERASEBKGND=20
Const WM_EXITMENULOOP=530
Const WM_EXITSIZEMOVE=562
Const WM_FONTCHANGE=29
Const WM_GETDLGCODE=135
Const WM_GETFONT=49
Const WM_GETHOTKEY=51
Const WM_GETICON=127
Const WM_GETMINMAXINFO=36
Const WM_GETTEXT=13
Const WM_GETTEXTLENGTH=14
Const WM_HANDHELDFIRST=856
Const WM_HANDHELDLAST=863
Const WM_HELP=83
Const WM_HOTKEY=786
Const WM_HSCROLL=276
Const WM_HSCROLLCLIPBOARD=782
Const WM_ICONERASEBKGND=39
Const WM_INITDIALOG=272
Const WM_INITMENU=278
Const WM_INITMENUPOPUP=279
Const WM_INPUTLANGCHANGE=81
Const WM_INPUTLANGCHANGEREQUEST=80
Const WM_KEYDOWN=256
Const WM_KEYUP=257
Const WM_KILLFOCUS=8
Const WM_MDIACTIVATE=546
Const WM_MDICASCADE=551
Const WM_MDICREATE=544
Const WM_MDIDESTROY=545
Const WM_MDIGETACTIVE=553
Const WM_MDIICONARRANGE=552
Const WM_MDIMAXIMIZE=549
Const WM_MDINEXT=548
Const WM_MDIREFRESHMENU=564
Const WM_MDIRESTORE=547
Const WM_MDISETMENU=560
Const WM_MDITILE=550
Const WM_MEASUREITEM=44
Const WM_MENURBUTTONUP=290
Const WM_MENUCHAR=288
Const WM_MENUSELECT=287
Const WM_NEXTMENU=531
Const WM_MOVE=3
Const WM_MOVING=534
Const WM_NCACTIVATE=134
Const WM_NCCALCSIZE=131
Const WM_NCCREATE=129
Const WM_NCDESTROY=130
Const WM_NCHITTEST=132
Const WM_NCLBUTTONDBLCLK=163
Const WM_NCLBUTTONDOWN=161
Const WM_NCLBUTTONUP=162
Const WM_NCMBUTTONDBLCLK=169
Const WM_NCMBUTTONDOWN=167
Const WM_NCMBUTTONUP=168
Const WM_NCMOUSEMOVE=160
Const WM_NCPAINT=133
Const WM_NCRBUTTONDBLCLK=166
Const WM_NCRBUTTONDOWN=164
Const WM_NCRBUTTONUP=165
Const WM_NEXTDLGCTL=40
Const WM_NOTIFY=78
Const WM_NOTIFYFORMAT=85
Const WM_NULL=0
Const WM_PAINT=15
Const WM_PAINTCLIPBOARD=777
Const WM_PAINTICON=38
Const WM_PALETTECHANGED=785
Const WM_PALETTEISCHANGING=784
Const WM_PARENTNOTIFY=528
Const WM_PASTE=770
Const WM_PENWINFIRST=896
Const WM_PENWINLAST=911
Const WM_POWER=72
Const WM_POWERBROADCAST=536
Const WM_PRINT=791
Const WM_PRINTCLIENT=792
Const WM_QUERYDRAGICON=55
Const WM_QUERYENDSESSION=17
Const WM_QUERYNEWPALETTE=783
Const WM_QUERYOPEN=19
Const WM_QUEUESYNC=35
Const WM_QUIT=18
Const WM_RENDERALLFORMATS=774
Const WM_RENDERFORMAT=773
Const WM_SETCURSOR=32
Const WM_SETFOCUS=7
Const WM_SETFONT=48
Const WM_SETHOTKEY=50
Const WM_SETICON=128
Const WM_SETREDRAW=11
Const WM_SETTEXT=12
Const WM_SETTINGCHANGE=26
Const WM_SHOWWINDOW=24
Const WM_SIZE=5
Const WM_SIZECLIPBOARD=779
Const WM_SIZING=532
Const WM_SPOOLERSTATUS=42
Const WM_STYLECHANGED=125
Const WM_STYLECHANGING=124
Const WM_SYSCHAR=262
Const WM_SYSCOLORCHANGE=21
Const WM_SYSCOMMAND=274
Const WM_SYSDEADCHAR=263
Const WM_SYSKEYDOWN=260
Const WM_SYSKEYUP=261
Const WM_TCARD=82
Const WM_TIMECHANGE=30
Const WM_TIMER=275
Const WM_UNDO=772
Const WM_USER=1024
Const WM_USERCHANGED=84
Const WM_VKEYTOITEM=46
Const WM_VSCROLL=277
Const WM_VSCROLLCLIPBOARD=778
Const WM_WINDOWPOSCHANGED=71
Const WM_WINDOWPOSCHANGING=70
Const WM_WININICHANGE=26
Const WM_KEYFIRST=256
Const WM_KEYLAST=264
Const WM_SYNCPAINT=136
Const WM_MOUSEACTIVATE=33
Const WM_MOUSEMOVE=512
Const WM_LBUTTONDOWN=513
Const WM_LBUTTONUP=514
Const WM_LBUTTONDBLCLK=515
Const WM_RBUTTONDOWN=516
Const WM_RBUTTONUP=517
Const WM_RBUTTONDBLCLK=518
Const WM_MBUTTONDOWN=519
Const WM_MBUTTONUP=520
Const WM_MBUTTONDBLCLK=521
Const WM_MOUSEWHEEL=522
Const WM_MOUSEFIRST=512
Const WM_MOUSELAST=522
Const WM_MOUSEHOVER=$2A1
Const WM_MOUSELEAVE=$2A3

' setwindowpos flags

Const SWP_NOSIZE=1
Const SWP_NOMOVE=2
Const SWP_NOZORDER=4
Const SWP_NOREDRAW=8
Const SWP_NOACTIVATE=$10
Const SWP_FRAMECHANGED=$20
Const SWP_SHOWWINDOW=$40
Const SWP_HIDEWINDOW=$80
Const SWP_NOCOPYBITS=$100
Const SWP_NOOWNERZORDER=$200
Const SWP_NOSENDCHANGING=$400
Const SWP_DRAWFRAME=SWP_FRAMECHANGED
Const SWP_NOREPOSITION=SWP_NOOWNERZORDER
Const SWP_DEFERERASE=$2000
Const SWP_ASYNCWINDOWPOS=$4000

Const HWND_TOP=0
Const HWND_BOTTOM=1
Const HWND_TOPMOST=-1
Const HWND_NOTOPMOST=-2
Const HWND_BROADCAST=$ffff
Const HWND_DESKTOP=0
Const HWND_MESSAGE=-3

' scroll info

Const SB_HORZ=0
Const SB_VERT=1
Const SB_CTL=2
Const SB_BOTH=3
Const SB_LINEUP=0
Const SB_LINELEFT=0
Const SB_LINEDOWN=1
Const SB_LINERIGHT=1
Const SB_PAGEUP=2
Const SB_PAGELEFT=2
Const SB_PAGEDOWN=3
Const SB_PAGERIGHT=3
Const SB_THUMBPOSITION=4
Const SB_THUMBTRACK=5
Const SB_TOP=6
Const SB_LEFT=6
Const SB_BOTTOM=7
Const SB_RIGHT=7
Const SB_ENDSCROLL=8

Const SIF_RANGE=$0001
Const SIF_PAGE=$0002
Const SIF_POS=$0004
Const SIF_DISABLENOSCROLL=$0008
Const SIF_TRACKPOS=$0010
Const SIF_ALL=(SIF_RANGE|SIF_PAGE|SIF_POS|SIF_TRACKPOS)

Type SCROLLINFO
	Field cbSize
	Field fMask
	Field nMin
	Field nMax
	Field nPage
	Field nPos
	Field nTrackPos
End Type

' loadcursor consts

Const IDC_ARROW=32512
Const IDC_IBEAM=32513
Const IDC_WAIT=32514
Const IDC_CROSS=32515
Const IDC_UPARROW=32516
Const IDC_SIZENWSE=32642
Const IDC_SIZENESW=32643
Const IDC_SIZEWE=32644
Const IDC_SIZENS=32645
Const IDC_SIZEALL=32646
Const IDC_NO=32648
Const IDC_HAND=32649
Const IDC_APPSTARTING=32650
Const IDC_HELP=32651
Const IDC_ICON=32641
Const IDC_SIZE=32640

' changedisplaysettings flags

Const CDS_UPDATEREGISTRY=1
Const CDS_TEST=2
Const CDS_FULLSCREEN=4
Const CDS_GLOBAL=8
Const CDS_SET_PRIMARY=16
Const CDS_RESET=$40000000
Const CDS_SETRECT=$20000000
Const CDS_NORESET=$10000000

' changedisplaysettings results

Const DISP_CHANGE_SUCCESSFUL=0
Const DISP_CHANGE_RESTART=1
Const DISP_CHANGE_BADFLAGS=-4
Const DISP_CHANGE_BADPARAM=-5
Const DISP_CHANGE_FAILED=-1
Const DISP_CHANGE_BADMODE=-2
Const DISP_CHANGE_NOTUPDATED=-3

' PeekMessage param wRemoveMsg

Const PM_NOREMOVE=0
Const PM_REMOVE=1
Const PM_NOYIELD=2

' MsgWaitForMultipleObjects param dwWakeMask

Const QS_ALLEVENTS=191
Const QS_ALLINPUT=255
Const QS_ALLPOSTMESSAGE=256
Const QS_HOTKEY=128
Const QS_INPUT=7
Const QS_KEY=1
Const QS_MOUSE=6
Const QS_MOUSEBUTTON=4
Const QS_MOUSEMOVE=2
Const QS_PAINT=32
Const QS_POSTMESSAGE=8
Const QS_SENDMESSAGE=64
Const QS_TIMER=16

' ShowWindow commands

Const SW_HIDE=0
Const SW_NORMAL=1
Const SW_SHOWNORMAL=1
Const SW_SHOWMINIMIZED=2
Const SW_MAXIMIZE=3
Const SW_SHOWMAXIMIZED=3
Const SW_SHOWNOACTIVATE=4
Const SW_SHOW=5
Const SW_MINIMIZE=6
Const SW_SHOWMINNOACTIVE=7
Const SW_SHOWNA=8
Const SW_RESTORE=9
Const SW_SHOWDEFAULT=10
Const SW_FORCEMINIMIZE=11
Const SW_MAX=11

' menu flags

Const MF_INSERT=0
Const MF_CHANGE=$80
Const MF_APPEND=$100
Const MF_DELETE=$200
Const MF_REMOVE=$1000
Const MF_BYCOMMAND=0
Const MF_BYPOSITION=$400
Const MF_SEPARATOR=$800
Const MF_ENABLED=0
Const MF_GRAYED=1
Const MF_DISABLED=2
Const MF_UNCHECKED=0
Const MF_CHECKED=8
Const MF_USECHECKBITMAPS=$200
Const MF_STRING=0
Const MF_BITMAP=4
Const MF_OWNERDRAW=$100
Const MF_POPUP=$10
Const MF_MENUBARBREAK=$20
Const MF_MENUBREAK=$40
Const MF_UNHILITE=0
Const MF_HILITE=$80
Const MF_DEFAULT=$1000
Const MF_SYSMENU=$2000
Const MF_HELP=$4000
Const MF_RIGHTJUSTIFY=$4000
Const MF_MOUSESELECT=$8000
Const MF_END=$80

Const MFT_STRING=MF_STRING
Const MFT_BITMAP=MF_BITMAP
Const MFT_MENUBARBREAK=MF_MENUBARBREAK
Const MFT_MENUBREAK=MF_MENUBREAK
Const MFT_OWNERDRAW=MF_OWNERDRAW
Const MFT_RADIOCHECK=$200
Const MFT_SEPARATOR=MF_SEPARATOR
Const MFT_RIGHTORDER=$2000
Const MFT_RIGHTJUSTIFY=MF_RIGHTJUSTIFY
Const MFS_GRAYED=3
Const MFS_DISABLED=MFS_GRAYED
Const MFS_CHECKED=MF_CHECKED
Const MFS_HILITE=MF_HILITE
Const MFS_ENABLED=MF_ENABLED
Const MFS_UNCHECKED=MF_UNCHECKED
Const MFS_UNHILITE=MF_UNHILITE
Const MFS_DEFAULT=MF_DEFAULT

' menu item info

Const MIIM_STATE=1
Const MIIM_ID=2
Const MIIM_SUBMENU=4
Const MIIM_CHECKMARKS=8
Const MIIM_TYPE=$10
Const MIIM_DATA=$20
Const MIIM_STRING=$40
Const MIIM_BITMAP=$80
Const MIIM_FTYPE=$100

Type MENUITEMINFOW
	Field	cbSize,fMask,fType,fState,wID
	Field	hSubMenu,hbmpChecked,hbmpUnchecked
	Field	dwItemData:Int Ptr
	Field	dwTypeData:Short Ptr
	Field	cch
	Field	hbmpItem
End Type

Const GWL_WNDPROC=-4
Const GWL_HINSTANCE=-6
Const GWL_HWNDPARENT=-8
Const GWL_STYLE=-16
Const GWL_EXSTYLE=-20
Const GWL_USERDATA=-21
Const GWL_ID=-12

Const GCL_MENUNAME=-8
Const GCL_HBRBACKGROUND=-10
Const GCL_HCURSOR=-12
Const GCL_HICON=-14
Const GCL_HMODULE=-16
Const GCL_CBWNDEXTRA=-18
Const GCL_CBCLSEXTRA=-20
Const GCL_WNDPROC=-24
Const GCL_STYLE=-26
Const GCW_ATOM=-32
Const GCL_HICONSM=-34

Const WA_INACTIVE=0
Const WA_ACTIVE=1
Const WA_CLICKACTIVE=2

Type MSG
	Field hwnd
	Field message
	Field wParam
	Field lParam
	Field time
	Field pt_x,pt_y
End Type

Type WNDCLASS
	Field style
	Field lpfnWndProc:Byte Ptr
	Field cbClsExtra
	Field cbWndExtra
	Field hInstance
	Field hIcon
	Field hCursor
	Field hbrBackground
	Field lpszMenuName:Byte Ptr
	Field lpszClassName:Byte Ptr
End Type

Type WNDCLASSW
	Field style
	Field lpfnWndProc:Byte Ptr
	Field cbClsExtra
	Field cbWndExtra
	Field hInstance
	Field hIcon
	Field hCursor
	Field hbrBackground
	Field lpszMenuName:Short Ptr
	Field lpszClassName:Short Ptr
End Type

Type MINMAXINFO
	Field reserved0,reserved1
	Field maxw,maxh
	Field maxx,maxy
	Field minw,minh
	Field minx,miny
End Type

Type WINDOWINFO
	Field cbSize
	Field rcWindowl,rcWindowt,rcWindowr,rcWindowb
	Field rcClientl,rcClientt,rcClientr,rcClientb	
	Field dwStyle
    Field dwExStyle
    Field dwWindowStatus
    Field cxWindowBorders
    Field cyWindowBorders
    Field atomWindowType
    Field wCreatorVersion:Short	
End Type

Type PAINTSTRUCT
	Field hdc
	Field fErase
	Field rcPaint_left
	Field rcPaint_top
	Field rcPaint_right
	Field rcPaint_bottom
	Field fRestore 
	Field fIncUpdate
	Field res0,res1,res2,res3
	Field res4,res5,res6,res7
End Type

Const RECT_LEFT=0
Const RECT_TOP=1
Const RECT_RIGHT=2
Const RECT_BOTTOM=3

Const POINT_X=0
Const POINT_Y=1

Extern "Win32"

Function SetCapture( hwnd )
Function ReleaseCapture()

Function RegisterClassA( lpWndClass:Byte Ptr )
Function RegisterClassW( lpWndClass:Byte Ptr )
Function CreateWindowExA( dwExStyle,lpClassName:Byte Ptr,lpWindowName:Byte Ptr,dwStyle,x,y,nWidth,nHeight,hWndParent,hMenu,hInstance,lpParam:Byte Ptr )
Function CreateWindowExW( dwExStyle,lpClassName$w,lpWindowName$w,dwStyle,x,y,nWidth,nHeight,hWndParent,hMenu,hInstance,lpParam:Byte Ptr )
Function DefWindowProcA( hWnd,MSG,wParam,lParam )
Function DefWindowProcW( hWnd,MSG,wParam,lParam )
Function DispatchMessageA( lpMsg:Byte Ptr )
Function DispatchMessageW( lpMsg:Byte Ptr )
Function GetMessageA( lpMsg:Byte Ptr,hWnd,wMsgFilterMin,wMsgFilterMax )
Function GetMessageW( lpMsg:Byte Ptr,hWnd,wMsgFilterMin,wMsgFilterMax )
Function PeekMessageA( lpMsg:Byte Ptr,hWnd,wMsgFilterMin,wMsgFilterMax,wRemoveMsg )
Function PeekMessageW( lpMsg:Byte Ptr,hWnd,wMsgFilterMin,wMsgFilterMax,wRemoveMsg )
Function PostMessageA( hWnd,MSG,wParam,lParam )
Function PostMessageW( hWnd,MSG,wParam,lParam )
Function SendMessageA( hWnd,MSG,wParam,lParam )
Function SendMessageW( hWnd,MSG,wParam,lParam )
Function PostThreadMessageA( idThread,Msg,wParam,lParam )
Function PostThreadMessageW( idThread,Msg,wParam,lParam )
Function GetDC( hWnd )
Function ReleaseDC( hwnd, hdc )
Function PostQuitMessage( nExitCode )
Function TranslateMessage( lpMsg:Byte Ptr )
Function DestroyWindow( hWnd )
Function MsgWaitForMultipleObjects( nCount,pHandles:Byte Ptr,fWaitAll,dwMilliseconds,dwWakeMask )
Function MsgWaitForMultipleObjectsEx( nCount,pHandles:Byte Ptr,dwMilliseconds,dwWakeMask,dwFlags )
Function ChangeDisplaySettingsA( lpDevMode:Byte Ptr,dwFlags )
Function ChangeDisplaySettingsW( lpDevMode:Byte Ptr,dwFlags )
Function LoadCursorA( hInstance,lpCursorName:Byte Ptr )
Function LoadCursorW( hInstance,lpCursorName:Short Ptr )
Function ShowCursor( visible )
Function SetCursor( hCursor )
Function LoadIconA( resourceid,lpIconName:Byte Ptr )
Function LoadIconW( resourceid,lpIconName:Short Ptr )
Function LoadLibraryA( dll$z )
Function GetProcAddress:Byte Ptr( libhandle,func$z )
Function LoadLibraryW( dll$w )
Function GetClientRect( hWnd,lpRect:Int Ptr )
Function GetWindowRect( hWnd,lpRect:Int Ptr )
Function GetDesktopWindow()
Function AdjustWindowRect( rect:Int Ptr,style,menu )
Function AdjustWindowRectEx( rect:Int Ptr,style,menu,exstyle )
Function ClientToScreen( hwnd,point:Byte Ptr )
Function ShowWindow( hwnd,nCmdShow )
Function SetMenu( hwnd,hmenu )
Function DrawMenuBar( hwnd )
Function CreateMenu_()="CreateMenu@0"
Function CreatePopupMenu()
Function TrackPopupMenu(hMenu,uFLags,x,y,nReserved,hWnd,prcRect)
Function DestroyMenu(hMenu)
Function EnableMenuItem(hMenu,uIDEnableItem,uEnable)
Function CheckMenuItem(hMenu,uIDCheckItem,uCheck)

Function AppendMenuA(hMenu,uFlags,uIDNewItem,lpNewItem:Byte Ptr)
Function AppendMenuW(hMenu,uFlags,uIDNewItem,lpNewItem:Byte Ptr)
Function SetMenuItemInfoA( hMenu,item,fByPosition,info:Byte Ptr )
Function SetMenuItemInfoW( hMenu,item,fByPosition,info:Byte Ptr )
Function GetMenuItemCount( hMenu )
Function SetWindowTextA( hwnd,text$z )
Function SetWindowTextW( hwnd,text$w )
Function SetWindowPos( hwnd,hwndInsertAfter,x,y,cx,cy,uFlags )
Function GetForegroundWindow()
Function SetForegroundWindow(hwnd)
Function IsIconic(hwnd)
Function GetParent_(hwnd)="GetParent@4"
Function GetWindowLongA( hwnd,index )
Function SetWindowLongA( hwnd,index,newlong )
Function GetWindowLongW( hwnd,index )
Function SetWindowLongW( hwnd,index,newlong )
Function GetClassLongA( hwnd,index )
Function SetClassLongA( hwnd,index,newlong )
Function GetClassLongW( hwnd,index )
Function SetClassLongW( hwnd,index,newlong )
Function IsZoomed( hwnd )
Function CallWindowProcA( proc:Byte Ptr,hwnd,msg,wp,lp )
Function CallWindowProcW( proc:Byte Ptr,hwnd,msg,wp,lp )
Function OleInitialize(pvReserved:Byte Ptr)
Function OleUninitialize()
Function InitCommonControlsEx(controlsex:Byte Ptr)
Function SetScrollPos( hwnd,nBar,nPos,bRedraw )
Function GetScrollPos( hwnd,nBar )
Function SetScrollRange( hwnd,nBar,nMinPos,nMaxPos,bRedraw )
Function GetScrollRange( hwnd,nBar,lpMinPos:Int Ptr,lpMaxPos:Int Ptr )
Function ShowScrollBar( hwnd,wBar,bShow )
Function EnableScrollBar( hwnd,wSBflags,wArrows )
Function SetScrollInfo( hwnd,nBar,lpsi:SCROLLINFO,redraw )
Function GetScrollInfo( hwnd,nBar,lpsi:SCROLLINFO )
Function InvalidateRect( hWnd,lpRect:Int Ptr,bErase )
Function ValidateRect( hWnd,lpRect:Int Ptr )
Function BeginPaint( hWnd,lpPaint:Byte Ptr )
Function FillRect( hdc,lpRect:Int Ptr,hbr )
Function EndPaint( hWnd,lpPaint:Byte Ptr )
Function SetFocus( hWnd )
Function GetFocus()
Function GetActiveWindow()
Function SetActiveWindow( hWnd )
Function MoveWindow( hWnd,x,y,w,h,bRepaint )
Function SetParent_( hWnd,hWnd2 )="SetParent@8"
Function WindowFromPoint( point:Int Ptr )
Function GetKeyState(vkey)

Function SetWindowsHookExW(idHook,lpfn:Byte Ptr,hmod,dwThreadId)
Function CallNextHookEx(hhk,ncode,wparam,lparam)
Function UnhookWindowsHookEx(hhk)

Function EnableWindow( hWnd,enable )
Function IsWindowEnabled( hWnd )
Function IsWindowVisible( hWnd )
Function GetWindowInfo( hWnd,winfo:Byte Ptr )
Function GetCursorPos_( lpPoint:Int Ptr)="GetCursorPos@4"

Function EnumChildWindows( hWnd,lpfn:Byte Ptr,lp )

Function OpenClipboard(hWnd)
Function CloseClipboard()
Function SetClipboardData(uFormat,hMem)
Function GetClipboardData(uFormat)
Function EmptyClipboard()
Function IsClipboardFormatAvailable(format)

Function DefDlgProcW(hDlg,Msg,wParam,lParam)

'shellapi

Function DragAcceptFiles(hWnd,fAccept)
Function DragQueryPoint(hDrop,lpPoint:Int Ptr)
Function DragQueryFileW(hDrop,iFile,lpszFile:Short Ptr,cch)
Function DragFinish(hDrop)

End Extern
