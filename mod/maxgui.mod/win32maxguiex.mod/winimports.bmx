'Win32 Libraries
Import "-lcomctl32"
Import "-lole32"
Import "-loleaut32"
Import "-luuid"
Import "-lmsimg32"

Import "mshtmlview.cpp"
Import "tom.bmx"


' Custom Window Messages

	Const WM_MAXGUILISTREFRESH% = WM_APP + $100

'Error Codes
	
	Const S_OK = 0
	
	Const E_OUTOFMEMORY=$8007000E
	Const E_INVALIDARG=$80070057
	Const E_ACCESSDENIED=$80070005

' WM_SIZE message wParam values
	
	Const SIZE_RESTORED=0
	Const SIZE_MINIMIZED=1
	Const SIZE_MAXIMIZED=2
	Const SIZE_MAXSHOW=3
	Const SIZE_MAXHIDE=4
	
'Tool-tips
	
	Const TTS_ALWAYSTIP% = $1
	Const TTS_NOPREFIX% = $2
	Const TTS_NOANIMATE% = $10
	Const TTS_NOFADE% = $20
	Const TTS_BALLOON% = $40
	
	Const LPSTR_TEXTCALLBACK% = -1
	Const TTM_ADDTOOLW% = (WM_USER + 50)
	
'WM_MENUCHAR Return Constants
	
	Const MNC_IGNORE% = 0
	Const MNC_CLOSE% = 1
	Const MNC_EXECUTE% = 2
	Const MNC_SELECT% = 3
	
'MK Constants
	
	Const MK_CONTROL% = $8
	Const MK_LBUTTON% = $1
	Const MK_MBUTTON% = $10
	Const MK_RBUTTON% = $2
	Const MK_SHIFT% = $4
	Const MK_XBUTTON1% = $20
	Const MK_XBUTTON2% = $40
	
'Gadget Drawing and Color Constants
	
	Const WS_EX_COMPOSITED = $2000000
	
	'TextArea Gadget Printing
	Const MM_TEXT = 1
	
	Type FORMATRANGE
		Field hdc, hdcTarget
		Field rcLeft, rcTop, rcRight, rcBottom
		Field rcPageLeft, rcPageTop, rcPageRight, rcPageBottom
		Field CHARRANGE_cpMin, CHARRANGE_cpMax
	EndType
	
	Const PD_NOSELECTION = $4
	Const PD_DISABLEPRINTTOFILE = $80000
	Const PD_PRINTTOFILE = $20
	Const PD_RETURNDC = $100
	Const PD_RETURNDEFAULT = $400
	Const PD_RETURNIC = $200
	Const PD_SELECTION = $1
	Const PD_SHOWHELP = $800
	Const PD_NOPAGENUMS = $8
	Const PD_PAGENUMS = $2
	Const PD_ALLPAGES = $0
	Const PD_COLLATE = $10
	Const PD_HIDEPRINTTOFILE = $100000
	
	Type PRINTDLGW
		Field lStructSize = SizeOf(Self)
		Field hwndOwner, hDevMode, hDevNames, hdc
		Field flags, nFromPage:Short, nToPage:Short, nMinPage:Short, nMaxPage:Short, nCopies:Short
		Field padding:Short, padding2:Short, padding3:Short, padding4:Short, padding5:Short, padding6:Short
		Field padding7:Short, padding8:Short, padding9:Short, padding10:Short, padding11:Short, padding12:Short
		Field padding13:Short, padding14:Short, padding15:Short, padding16:Short
	EndType
	
	Type DOCINFOW
		Field cbSize = SizeOf(Self)
		Field lpszDocName:Short Ptr, lpszOutput:Short Ptr, lpszDatatype:Short Ptr
		Field fwType
	EndType
	
	'Button Image
	Const BCM_FIRST = $1600
	Const BCM_SETIMAGELIST% = BCM_FIRST+2
	
	Const BUTTON_IMAGELIST_ALIGN_LEFT%		= 0
	Const BUTTON_IMAGELIST_ALIGN_RIGHT%	= 1
	Const BUTTON_IMAGELIST_ALIGN_TOP%		= 2
	Const BUTTON_IMAGELIST_ALIGN_BOTTOM%	= 3
	Const BUTTON_IMAGELIST_ALIGN_CENTER%	= 4
	
	'ComboBox cue-banners
	Const CBM_FIRST = $1700
	Const CB_SETCUEBANNER = CBM_FIRST + 3
	
	'Progress bar colors
	Const PBM_SETBARCOLOR=WM_USER+9
	Const PBM_SETBKCOLOR=CCM_FIRST+1
	
	'SetBkMode() consts, etc.
	Const LWA_COLORKEY=1
	Const LWA_ALPHA=2
	Const LWA_BOTH=3
	Const TRANSPARENT=1
	Const OPAQUE = 2
	
	'RedrawWindow() flags
	Const RDW_FRAME = $500
	Const RDW_UPDATENOW = $100
	Const RDW_INVALIDATE = $1
	Const RDW_NOCHILDREN = $40
	Const RDW_ALLCHILDREN = $80
	Const RDW_ERASE = $4
	Const RDW_ERASENOW = $200
	
	'ScrollBar constants
	Const OBJID_HSCROLL = $FFFFFFFA
	Const OBJID_VSCROLL = $FFFFFFFB
	Const OBJID_CLIENT = $FFFFFFFC
	
	Const EM_GETSCROLLPOS = WM_USER + 221
	Const EM_SETSCROLLPOS = WM_USER + 222
	Const EM_SETZOOM = WM_USER + 225
	
	'GetDCEx Constants
	Const DCX_WINDOW = $1
	Const DCX_CACHE = $2
	Const DCX_NORESETATTRS = $4
	Const DCX_CLIPCHILDREN = $8
	Const DCX_CLIPSIBLINGS = $10
	Const DCX_PARENTCLIP = $20
	Const DCX_EXCLUDERGN = $40
	Const DCX_INTERSECTRGN = $80
	Const DCX_EXCLUDEUPDATE = $100
	Const DCX_INTERSECTUPDATE = $200
	Const DCX_LOCKWINDOWUPDATE = $400
	Const DCX_VALIDATE = $200000
	
	Const WM_THEMECHANGED = $31A
	
	'These functions are only supported by Win 2000+, therefore we dynamically link to the functions using DLLs.
	Global libUser32 = LoadLibraryW("user32.dll"), libUXTheme = LoadLibraryW("uxtheme.dll")
	Global SetLayeredWindowAttributes(hwnd,crKey,bAlpha:Byte,dwFlags) "win32" = GetProcAddress(libUser32, "SetLayeredWindowAttributes")
	Global SystemParametersInfoW%( uiAction%, uiParam%, pvParam, fWinIni% ) "win32" = GetProcAddress(libUser32,"SystemParametersInfoW")
	Global DrawThemeParentBackground(hwnd,hDC,pRect:Int Ptr) "win32" = GetProcAddress(libUXTheme, "DrawThemeParentBackground")
	Global SetWindowThemeW( pHwnd, pThemeStr:Short Ptr, pList:Short Ptr ) "win32" = GetProcAddress(libUXTheme, "SetWindowTheme")
	Global OpenThemeData%( hwnd%, lpszClassString:Short Ptr ) "win32" = GetProcAddress(libUXTheme, "OpenThemeData")
	Global GetThemeSysFont%( hTheme%, iFontID%, pLF:Byte Ptr ) "win32" = GetProcAddress(libUXTheme, "GetThemeSysFont")
	Global DrawThemeBackground( hTheme%, hdc%, iPartID%, iStateID%, pRect:Int Ptr, pClipRect:Int Ptr) "win32" = GetProcAddress(libUXTheme, "DrawThemeBackground")
	Global CloseThemeData( hTheme% ) "win32" = GetProcAddress(libUXTheme, "CloseThemeData")
	Global DrawThemeText( hTheme%, hDC%, iPartID%, iStateID%, pszText$w, iCharCount%, dwTextFlags%, dwTextFlags2%, pRect:Int Ptr ) "win32" = GetProcAddress(libUXTheme, "DrawThemeText")
	Global GetThemeBackgroundContentRect( hTheme%, hdc%, iPartId%, iStateId%, pBoundingRect:Int Ptr, pContentRect:Int Ptr ) "win32" = GetProcAddress(libUXTheme, "GetThemeBackgroundContentRect")
	Global IsThemeBackgroundPartiallyTransparent( hTheme%, iPartId%, iStateId% ) "win32" = GetProcAddress(libUXTheme, "IsThemeBackgroundPartiallyTransparent")
	
	'Theme Fonts
	Const TMT_CAPTIONFONT = 801
	Const TMT_SMALLCAPTIONFONT = 802
	Const TMT_MENUFONT = 803
	Const TMT_STATUSFONT = 804
	Const TMT_MSGBOXFONT = 805
	Const TMT_ICONTITLEFONT = 806
	
	Const SPI_GETWORKAREA = 48
	Const SPI_GETNONCLIENTMETRICS% = 41
	
	'WM_DRAWITEM States
	
	Const ODS_SELECTED = $1
	Const ODS_GRAYED = $2
	Const ODS_DISABLED = $4
	Const ODS_CHECKED = $8
	Const ODS_FOCUS = $10
	Const ODS_HOTLIGHT = $40
	Const ODS_INACTIVE = $80
	Const ODS_NOACCEL = $100
	Const ODS_NOFOCUSRECT = $200
	
	'DrawFrameControl Constants
	Const DFC_BUTTON = $4
	Const DFCS_BUTTONPUSH = $10
	Const DFCS_INACTIVE = $100
	Const DFCS_PUSHED = $200
	Const DFCS_CHECKED = $400
	Const DFCS_TRANSPARENT = $800
	Const DFCS_HOT = $1000
	Const DFCS_ADJUSTRECT = $2000
	Const DFCS_FLAT = $4000
	Const DFCS_MONO = $8000
	
	'DrawThemeBackground Button States
	Const BP_PUSHBUTTON = 1
	Const PBS_NORMAL = 1
	Const PBS_HOT = 2
	Const PBS_PRESSED = 3
	Const PBS_DISABLED = 4
	Const PBS_DEFAULTED = 5
	
	Type NONCLIENTMETRICSW
		Field cbSize = SizeOf(Self)
		Field iBorderWidth
		Field iScrollWidth
		Field iScrollHeight
		Field iCaptionWidth
		Field iCaptionHeight
		
		' lfCaptionFont:LOGFONTW
			
			Field lfCaptionFont_lfHeight, lfCaptionFont_lfWidth, lfCaptionFont_lfEscapement, lfCaptionFont_lfOrientation
			Field lfCaptionFont_lfWeight, lfCaptionFont_lfItalic:Byte, lfCaptionFont_lfUnderline:Byte, lfCaptionFont_lfStrikeOut:Byte
			Field lfCaptionFont_lfCharSet:Byte, lfCaptionFont_lfOutPrecision:Byte, lfCaptionFont_lfClipPrecision:Byte
			Field lfCaptionFont_lfQuality:Byte, lfCaptionFont_lfPitchAndFamily:Byte
			
			Field lfCaptionFont_lfFaceName00:Short, lfCaptionFont_lfFaceName01:Short, lfCaptionFont_lfFaceName02:Short, lfCaptionFont_lfFaceName03:Short, lfCaptionFont_lfFaceName04:Short
			Field lfCaptionFont_lfFaceName05:Short, lfCaptionFont_lfFaceName06:Short, lfCaptionFont_lfFaceName07:Short, lfCaptionFont_lfFaceName08:Short, lfCaptionFont_lfFaceName09:Short
			Field lfCaptionFont_lfFaceName0a:Short, lfCaptionFont_lfFaceName0b:Short, lfCaptionFont_lfFaceName0c:Short, lfCaptionFont_lfFaceName0d:Short, lfCaptionFont_lfFaceName0e:Short
			Field lfCaptionFont_lfFaceName0f:Short, lfCaptionFont_lfFaceName10:Short, lfCaptionFont_lfFaceName11:Short, lfCaptionFont_lfFaceName12:Short, lfCaptionFont_lfFaceName13:Short
			Field lfCaptionFont_lfFaceName14:Short, lfCaptionFont_lfFaceName15:Short, lfCaptionFont_lfFaceName16:Short, lfCaptionFont_lfFaceName17:Short, lfCaptionFont_lfFaceName18:Short
			Field lfCaptionFont_lfFaceName19:Short, lfCaptionFont_lfFaceName1a:Short, lfCaptionFont_lfFaceName1b:Short, lfCaptionFont_lfFaceName1c:Short, lfCaptionFont_lfFaceName1d:Short
			Field lfCaptionFont_lfFaceName1e:Short, lfCaptionFont_lfFaceName1f:Short
		
		Field iSmCaptionWidth
		Field iSmCaptionHeight
		
		' lfSmCaptionFont:LOGFONTW
			
			Field lfSmCaptionFont_lfHeight, lfSmCaptionFont_lfWidth, lfSmCaptionFont_lfEscapement, lfSmCaptionFont_lfOrientation
			Field lfSmCaptionFont_lfWeight, lfSmCaptionFont_lfItalic:Byte, lfSmCaptionFont_lfUnderline:Byte, lfSmCaptionFont_lfStrikeOut:Byte
			Field lfSmCaptionFont_lfCharSet:Byte, lfSmCaptionFont_lfOutPrecision:Byte, lfSmCaptionFont_lfClipPrecision:Byte
			Field lfSmCaptionFont_lfQuality:Byte, lfSmCaptionFont_lfPitchAndFamily:Byte
			
			Field lfSmCaptionFont_lfFaceName00:Short, lfSmCaptionFont_lfFaceName01:Short, lfSmCaptionFont_lfFaceName02:Short, lfSmCaptionFont_lfFaceName03:Short, lfSmCaptionFont_lfFaceName04:Short
			Field lfSmCaptionFont_lfFaceName05:Short, lfSmCaptionFont_lfFaceName06:Short, lfSmCaptionFont_lfFaceName07:Short, lfSmCaptionFont_lfFaceName08:Short, lfSmCaptionFont_lfFaceName09:Short
			Field lfSmCaptionFont_lfFaceName0a:Short, lfSmCaptionFont_lfFaceName0b:Short, lfSmCaptionFont_lfFaceName0c:Short, lfSmCaptionFont_lfFaceName0d:Short, lfSmCaptionFont_lfFaceName0e:Short
			Field lfSmCaptionFont_lfFaceName0f:Short, lfSmCaptionFont_lfFaceName10:Short, lfSmCaptionFont_lfFaceName11:Short, lfSmCaptionFont_lfFaceName12:Short, lfSmCaptionFont_lfFaceName13:Short
			Field lfSmCaptionFont_lfFaceName14:Short, lfSmCaptionFont_lfFaceName15:Short, lfSmCaptionFont_lfFaceName16:Short, lfSmCaptionFont_lfFaceName17:Short, lfSmCaptionFont_lfFaceName18:Short
			Field lfSmCaptionFont_lfFaceName19:Short, lfSmCaptionFont_lfFaceName1a:Short, lfSmCaptionFont_lfFaceName1b:Short, lfSmCaptionFont_lfFaceName1c:Short, lfSmCaptionFont_lfFaceName1d:Short
			Field lfSmCaptionFont_lfFaceName1e:Short, lfSmCaptionFont_lfFaceName1f:Short
		
		Field iMenuWidth
		Field iMenuHeight
		
		' lfMenuFont:LOGFONTW

			Field lfMenuFont_lfHeight, lfMenuFont_lfWidth, lfMenuFont_lfEscapement, lfMenuFont_lfOrientation
			Field lfMenuFont_lfWeight, lfMenuFont_lfItalic:Byte, lfMenuFont_lfUnderline:Byte, lfMenuFont_lfStrikeOut:Byte
			Field lfMenuFont_lfCharSet:Byte, lfMenuFont_lfOutPrecision:Byte, lfMenuFont_lfClipPrecision:Byte
			Field lfMenuFont_lfQuality:Byte, lfMenuFont_lfPitchAndFamily:Byte
			
			Field lfMenuFont_lfFaceName00:Short, lfMenuFont_lfFaceName01:Short, lfMenuFont_lfFaceName02:Short, lfMenuFont_lfFaceName03:Short, lfMenuFont_lfFaceName04:Short
			Field lfMenuFont_lfFaceName05:Short, lfMenuFont_lfFaceName06:Short, lfMenuFont_lfFaceName07:Short, lfMenuFont_lfFaceName08:Short, lfMenuFont_lfFaceName09:Short
			Field lfMenuFont_lfFaceName0a:Short, lfMenuFont_lfFaceName0b:Short, lfMenuFont_lfFaceName0c:Short, lfMenuFont_lfFaceName0d:Short, lfMenuFont_lfFaceName0e:Short
			Field lfMenuFont_lfFaceName0f:Short, lfMenuFont_lfFaceName10:Short, lfMenuFont_lfFaceName11:Short, lfMenuFont_lfFaceName12:Short, lfMenuFont_lfFaceName13:Short
			Field lfMenuFont_lfFaceName14:Short, lfMenuFont_lfFaceName15:Short, lfMenuFont_lfFaceName16:Short, lfMenuFont_lfFaceName17:Short, lfMenuFont_lfFaceName18:Short
			Field lfMenuFont_lfFaceName19:Short, lfMenuFont_lfFaceName1a:Short, lfMenuFont_lfFaceName1b:Short, lfMenuFont_lfFaceName1c:Short, lfMenuFont_lfFaceName1d:Short
			Field lfMenuFont_lfFaceName1e:Short, lfMenuFont_lfFaceName1f:Short

		' lfStatusFont:LOGFONTW
			
			Field lfStatusFont_lfHeight, lfStatusFont_lfWidth, lfStatusFont_lfEscapement, lfStatusFont_lfOrientation
			Field lfStatusFont_lfWeight, lfStatusFont_lfItalic:Byte, lfStatusFont_lfUnderline:Byte, lfStatusFont_lfStrikeOut:Byte
			Field lfStatusFont_lfCharSet:Byte, lfStatusFont_lfOutPrecision:Byte, lfStatusFont_lfClipPrecision:Byte
			Field lfStatusFont_lfQuality:Byte, lfStatusFont_lfPitchAndFamily:Byte
			
			Field lfStatusFont_lfFaceName00:Short, lfStatusFont_lfFaceName01:Short, lfStatusFont_lfFaceName02:Short, lfStatusFont_lfFaceName03:Short, lfStatusFont_lfFaceName04:Short
			Field lfStatusFont_lfFaceName05:Short, lfStatusFont_lfFaceName06:Short, lfStatusFont_lfFaceName07:Short, lfStatusFont_lfFaceName08:Short, lfStatusFont_lfFaceName09:Short
			Field lfStatusFont_lfFaceName0a:Short, lfStatusFont_lfFaceName0b:Short, lfStatusFont_lfFaceName0c:Short, lfStatusFont_lfFaceName0d:Short, lfStatusFont_lfFaceName0e:Short
			Field lfStatusFont_lfFaceName0f:Short, lfStatusFont_lfFaceName10:Short, lfStatusFont_lfFaceName11:Short, lfStatusFont_lfFaceName12:Short, lfStatusFont_lfFaceName13:Short
			Field lfStatusFont_lfFaceName14:Short, lfStatusFont_lfFaceName15:Short, lfStatusFont_lfFaceName16:Short, lfStatusFont_lfFaceName17:Short, lfStatusFont_lfFaceName18:Short
			Field lfStatusFont_lfFaceName19:Short, lfStatusFont_lfFaceName1a:Short, lfStatusFont_lfFaceName1b:Short, lfStatusFont_lfFaceName1c:Short, lfStatusFont_lfFaceName1d:Short
			Field lfStatusFont_lfFaceName1e:Short, lfStatusFont_lfFaceName1f:Short
			
		' lfMessageFont:LOGFONTW
			
			Field lfMessageFont_lfHeight, lfMessageFont_lfWidth, lfMessageFont_lfEscapement, lfMessageFont_lfOrientation
			Field lfMessageFont_lfWeight, lfMessageFont_lfItalic:Byte, lfMessageFont_lfUnderline:Byte, lfMessageFont_lfStrikeOut:Byte
			Field lfMessageFont_lfCharSet:Byte, lfMessageFont_lfOutPrecision:Byte, lfMessageFont_lfClipPrecision:Byte
			Field lfMessageFont_lfQuality:Byte, lfMessageFont_lfPitchAndFamily:Byte
			
			Field lfMessageFont_lfFaceName00:Short, lfMessageFont_lfFaceName01:Short, lfMessageFont_lfFaceName02:Short, lfMessageFont_lfFaceName03:Short, lfMessageFont_lfFaceName04:Short
			Field lfMessageFont_lfFaceName05:Short, lfMessageFont_lfFaceName06:Short, lfMessageFont_lfFaceName07:Short, lfMessageFont_lfFaceName08:Short, lfMessageFont_lfFaceName09:Short
			Field lfMessageFont_lfFaceName0a:Short, lfMessageFont_lfFaceName0b:Short, lfMessageFont_lfFaceName0c:Short, lfMessageFont_lfFaceName0d:Short, lfMessageFont_lfFaceName0e:Short
			Field lfMessageFont_lfFaceName0f:Short, lfMessageFont_lfFaceName10:Short, lfMessageFont_lfFaceName11:Short, lfMessageFont_lfFaceName12:Short, lfMessageFont_lfFaceName13:Short
			Field lfMessageFont_lfFaceName14:Short, lfMessageFont_lfFaceName15:Short, lfMessageFont_lfFaceName16:Short, lfMessageFont_lfFaceName17:Short, lfMessageFont_lfFaceName18:Short
			Field lfMessageFont_lfFaceName19:Short, lfMessageFont_lfFaceName1a:Short, lfMessageFont_lfFaceName1b:Short, lfMessageFont_lfFaceName1c:Short, lfMessageFont_lfFaceName1d:Short
			Field lfMessageFont_lfFaceName1e:Short, lfMessageFont_lfFaceName1f:Short
			
		
		'Field iPaddedBorderWidth
	EndType
	
	'DrawText Constants
	Const DT_BOTTOM= $8
	Const DT_CALCRECT= $400
	Const DT_CENTER= $1
	Const DT_EDITCONTROL= $2000
	Const DT_END_ELLIPSIS= $8000
	Const DT_EXPANDTABS = $40
	Const DT_EXTERNALLEADING = $200
	Const DT_HIDEPREFIX = $100000
	Const DT_INTERNAL = $1000
	Const DT_LEFT = $0
	Const DT_MODIFYSTRING = $10000
	Const DT_NOCLIP = $100
	Const DT_NOFULLWIDTHCHARBREAK = $80000
	Const DT_NOPREFIX = $800
	Const DT_NOT_SPECIFIC = $50000
	Const DT_PATH_ELLIPSIS = $4000
	Const DT_PREFIXONLY = $200000
	Const DT_RIGHT = $2
	Const DT_RTLREADING = $20000
	Const DT_SINGLELINE = $20
	Const DT_TABSTOP = $80
	Const DT_TOP = $0
	Const DT_VCENTER = $4
	Const DT_WORD_ELLIPSIS = $40000
	Const DT_WORDBREAK = $10
	
	'ExtTextOut
	Const ETO_GRAYED:Int = 1
	Const ETO_OPAQUE:Int = 2
	Const ETO_CLIPPED:Int = 4
	
	'DrawItemStruct
	Type DRAWITEMSTRUCT
		Field CtlType, CtlID, ItemID, ItemAction, ItemState
		Field hwndItem, hDC, rcItem_Left, rcItem_Top, rcItem_Right, rcItem_Bottom, itemData
	EndType
	
	'Button Image Constants
	Const IMAGE_BITMAP = 0
	Const IMAGE_ICON = 1
	
	'Menu Info
	Type MENUINFO
		Field cbSize% = SizeOf(Self)
		Field fMask%
		Field dwStyle%
		Field cyMax%
		Field hbrBack%
		Field dwContextHelpID%
		Field dwMenuData:Int Ptr
	EndType
	
	Const MIM_MAXHEIGHT = $1
	Const MIM_BACKGROUND = $2
	Const MIM_HELPID = $4
	Const MIM_MENUDATA = $8
	Const MIM_STYLE = $10
	Const MIM_APPLYTOSUBMENUS = $80000000
	
	Const MNS_NOCHECK = $80000000
	Const MNS_MODELESS = $40000000
	Const MNS_DRAGDROP = $20000000
	Const MNS_AUTODISMISS = $10000000
	Const MNS_NOTIFYBYPOS = $8000000
	Const MNS_CHECKORBMP = $4000000
	
	Const GA_PARENT = 1
	Const GA_ROOT = 2
	Const GA_ROOTOWNER = 3
	
	'External functions
	Extern "Win32"
		
'		Function GetCharABCWidthsW(dc,firstcharcode,lastcharcode,widths:Int Ptr Ptr)
		Function GetCharABCWidthsW(dc,firstcharcode,lastcharcode,widths:Int Ptr)

		Function GetCharWidth32W(hdc,first,last,widths:Int Ptr)
		
		'BRL.System
		Function _TrackMouseEvent( trackmouseeventstrunct:Byte Ptr )
		
		'Imagelists and pixmap conversion
		Function ImageList_Add(himl,hbmImage,crMask)
		Function ImageList_Destroy( hImageList )
		Function ImageList_GetImageCount( hImageList )
		Function CreateDIBSection(hdc,bminfo:Byte Ptr,iUsage,bits:Byte Ptr Ptr,hSection,dwOffset)
		Function AlphaBlend_(hdc,dx,dy,dw,dh,hdc2,src,sry,srcw,srch,rop)="AlphaBlend@44"
		
		'WM_CTLCOLORXXXX handling
		Function SetBkMode( hdc, mode)
		Function SetBkColor( hdc, crColor )
		Function GetAncestor_( hwnd, gaFlags ) = "GetAncestor@8"
		Function SetTextColor_( hdc, crColor ) = "SetTextColor@8"
		
		'Drawing Contexts
		Function GetObjectW( hgdiobj, cbBuffer, lpvObject:Byte Ptr )
		Function SaveDC( hdc )
		Function RestoreDC( hdc, savestate )
		Function CreatePatternBrush( bitmap )
		Function GetDCEx( hwnd, hRgn, flags )
		Function ReleaseDC( hwnd, hdc )
		Function GetDCOrgEx( hdc, point:Int Ptr )
		Function GetWindowOrgEx( hdc, point:Int Ptr )
		Function GetWindowExtEx( hdc, size:Int Ptr )
		
		'Drawing
		Function DrawTextW( hdc, lpString$w, nCount, lpRect:Int Ptr, uFormat )
		Function DrawFocusRect( hdc, lprc:Int Ptr )
		Function DrawFrameControl( hdc, lprc:Int Ptr, uType%, uState% )
		Function ExtTextOutW( hdc, x, y, fuOptions, lpRc:Int Ptr, lpString$w, cbCount, lpDx:Int Ptr )
		
		'Resizing
		Function BeginDeferWindowPos( nCount )
		Function EndDeferWindowPos( hdwpStruct )
		Function DeferWindowPos( hWinPosInfo, hWnd, hWndInsertAfter, x, y, cx, cy, uFlags)
		
		'Position and regions
		Function IsRectEmpty( rect:Int Ptr )
		Function GetClipBox( hdc, rect:Int Ptr)
		Function GetUpdateRect( hwnd, rect:Int Ptr, pErase )
		Function ScreenToClient( hwnd, rect:Int Ptr )
		Function RedrawWindow(hwnd, lprcUpdate:Int Ptr, hrgnUpdate:Int Ptr, flags )
		Function FrameRect( hdc, rect:Int Ptr, hBrush )
		Function InflateRect( rect:Int Ptr, dx, dy )
		Function OffsetRect( rect:Int Ptr, dx, dy )
		Function IntersectRect( lprcDest:Int Ptr, lprcSrc1:Int Ptr, lprcSrc2:Int Ptr )
		Function CopyRect( dest:Int Ptr, src:Int Ptr )
		Function GDISetRect( rect:Int Ptr, xLeft, yTop, xRight, yBottom ) = "SetRect@20"
		
		'Menu Stuff
		Function GetMenu_( hwnd ) = "GetMenu@4"
		Function SetMenuItemBitmaps( hMenu, uPosition, uFlags, hBitmapUnchecked, hBitmapChecked )
		Function SetMenuInfo( hMenu, lpcMenuInfo:Byte Ptr )
		Function GetSysColor( hColor )
		
		'Scroll-bar fixes
		Function GetSystemMetrics( metric )
		Function GetScrollBarInfo( hwnd, idObject, pScrollBarInfo:Int Ptr )
		
		'Gadget text retrieval
		Function GetWindowTextLengthW( hwnd )
		Function GetWindowTextW( hwnd, lpString:Short Ptr, nMaxCount)
		
		'Missing misc. system functions
		Function GetCursor()
		Function GetClassNameW%( pHwnd%, pTextOut:Short Ptr, pTextLength% )
		Function GetLastError()
		Function FreeLibrary( hLibrary )
		
		'Printing functions for text-area GadgetPrint()
		Function PrintDlg( printDialogStruct:Byte Ptr ) = "PrintDlgW@4"
		Function StartDocW( hdc, pDocStruct:Byte Ptr )
		Function EndDoc( hdc )
		Function AbortDoc( hdc )
		Function StartPage( hdc )
		Function EndPage( hdc )
		Function SetMapMode( hdc, pMode )
		Function PrintWindow( hwnd, hdc, flags )
		
		'Icons
		Function CreateIconIndirect(IconInf:Byte Ptr)
		Function CopyImage(hImage , uType , xDesired , yDesired , flags)
		Function DestroyIcon(hIcon)
		
	EndExtern
	
'HTMLView C++ Functions (see mshtmlview.cpp)
	
	Extern "C"
		Function msHtmlCreate( owner:Object,wndclass:Short Ptr,hwnd,flags )
		Function msHtmlGo( handle,url$w )
		Function msHtmlRun( handle,script$w )
		Function msHtmlSetShape( handle,x,y,w,h )
		Function msHtmlSetVisible( handle,visible )
		Function msHtmlSetEnabled( handle,enabled )
		Function msHtmlActivate(handle,cmd)
		Function msHtmlStatus(handle)
		Function msHtmlHwnd(handle)
		Function msHtmlBrowser:IWebBrowser2(handle)
		Function mstmlDocument:IHTMLDocument2(handle)
	EndExtern

'Icon Stuff
	
	Const LR_DEFAULTSIZE = $40
	
	Type ICONINFO
	    Field fIcon
	    Field xHotspot
	    Field yHotspot
	    Field hbmMask
	    Field hbmColor
	EndType

'Treeview Consts
	
	Const TVM_FIRST = $1100
	Const TVS_EX_DOUBLEBUFFER = $4
	Const TVS_EX_FADEINOUTEXPANDOS = $40
	Const TVM_SETEXTENDEDSTYLE = TVM_FIRST + 44
	
	Const TTN_GETDISPINFOW = -530

'System State Contstants
	
	Const STATE_SYSTEM_UNAVAILABLE = $00000001
	Const STATE_SYSTEM_SELECTED = $00000002
	Const STATE_SYSTEM_FOCUSED = $00000004
	Const STATE_SYSTEM_PRESSED = $00000008
	Const STATE_SYSTEM_CHECKED = $00000010
	Const STATE_SYSTEM_MIXED = $00000020
	Const STATE_SYSTEM_READONLY = $00000040
	Const STATE_SYSTEM_HOTTRACKED = $00000080
	Const STATE_SYSTEM_DEFAULT = $00000100
	Const STATE_SYSTEM_EXPANDED = $00000200
	Const STATE_SYSTEM_COLLAPSED = $00000400
	Const STATE_SYSTEM_BUSY = $00000800
	Const STATE_SYSTEM_FLOATING = $00001000
	Const STATE_SYSTEM_MARQUEED = $00002000
	Const STATE_SYSTEM_ANIMATED = $00004000
	Const STATE_SYSTEM_INVISIBLE = $00008000
	Const STATE_SYSTEM_OFFSCREEN = $00010000
	Const STATE_SYSTEM_SIZEABLE = $00020000
	Const STATE_SYSTEM_MOVEABLE = $00040000
	Const STATE_SYSTEM_SELFVOICING = $00080000
	Const STATE_SYSTEM_FOCUSABLE = $00100000
	Const STATE_SYSTEM_SELECTABLE = $00200000
	Const STATE_SYSTEM_LINKED = $00400000
	Const STATE_SYSTEM_TRAVERSED = $00800000
	Const STATE_SYSTEM_MULTISELECTABLE = $01000000
	Const STATE_SYSTEM_EXTSELECTABLE = $02000000
	Const STATE_SYSTEM_ALERT_LOW = $04000000
	Const STATE_SYSTEM_ALERT_MEDIUM = $08000000
	Const STATE_SYSTEM_ALERT_HIGH = $10000000
	Const STATE_SYSTEM_VALID = $1FFFFFFF

'System Metrics

	Const SM_CXSCREEN = 0
	Const SM_CYSCREEN = 1
	Const SM_CXVSCROLL = 2
	Const SM_CYHSCROLL = 3
	Const SM_CYCAPTION = 4
	Const SM_CXBORDER = 5
	Const SM_CYBORDER = 6
	Const SM_CXDLGFRAME = 7
	Const SM_CYDLGFRAME = 8
	Const SM_CYVTHUMB = 9
	Const SM_CXHTHUMB = 10
	Const SM_CXICON = 11
	Const SM_CYICON = 12
	Const SM_CXCURSOR = 13
	Const SM_CYCURSOR = 14
	Const SM_CYMENU = 15
	Const SM_CXFULLSCREEN = 16
	Const SM_CYFULLSCREEN = 17
	Const SM_CYKANJIWINDOW = 18
	Const SM_MOUSEPRESENT = 19
	Const SM_CYVSCROLL = 20
	Const SM_CXHSCROLL = 21
	Const SM_DEBUG = 22
	Const SM_SWAPBUTTON = 23
	Const SM_RESERVED1 = 24
	Const SM_RESERVED2 = 25
	Const SM_RESERVED3 = 26
	Const SM_RESERVED4 = 27
	Const SM_CXMIN = 28
	Const SM_CYMIN = 29
	Const SM_CXSIZE = 30
	Const SM_CYSIZE = 31
	Const SM_CXFRAME = 32
	Const SM_CYFRAME = 33
	Const SM_CXMINTRACK = 34
	Const SM_CYMINTRACK = 35
	Const SM_CXDOUBLECLK = 36
	Const SM_CYDOUBLECLK = 37
	Const SM_CXICONSPACING = 38
	Const SM_CYICONSPACING = 39
	Const SM_MENUDROPALIGNMENT = 40
	Const SM_PENWINDOWS = 41
	Const SM_DBCSENABLED = 42
	Const SM_CMOUSEBUTTONS = 43
	Const SM_CXFIXEDFRAME = SM_CXDLGFRAME
	Const SM_CYFIXEDFRAME = SM_CYDLGFRAME
	Const SM_CXSIZEFRAME = SM_CXFRAME
	Const SM_CYSIZEFRAME = SM_CYFRAME
	Const SM_SECURE = 44
	Const SM_CXEDGE = 45
	Const SM_CYEDGE = 46
	Const SM_CXMINSPACING = 47
	Const SM_CYMINSPACING = 48
	Const SM_CXSMICON = 49
	Const SM_CYSMICON = 50
	Const SM_CYSMCAPTION = 51
	Const SM_CXSMSIZE = 52
	Const SM_CYSMSIZE = 53
	Const SM_CXMENUSIZE = 54
	Const SM_CYMENUSIZE = 55
	Const SM_ARRANGE = 56
	Const SM_CXMINIMIZED = 57
	Const SM_CYMINIMIZED = 58
	Const SM_CXMAXTRACK = 59
	Const SM_CYMAXTRACK = 60
	Const SM_CXMAXIMIZED = 61
	Const SM_CYMAXIMIZED = 62
	Const SM_NETWORK = 63
	Const SM_CLEANBOOT = 67
	Const SM_CXDRAG = 68
	Const SM_CYDRAG = 69
	Const SM_SHOWSOUNDS = 70
	Const SM_CXMENUCHECK = 71
	Const SM_CYMENUCHECK = 72
	Const SM_SLOWMACHINE = 73
	Const SM_MIDEASTENABLED = 74
	Const SM_MOUSEWHEELPRESENT = 75
	Const SM_XVIRTUALSCREEN = 76
	Const SM_YVIRTUALSCREEN = 77
	Const SM_CXVIRTUALSCREEN = 78
	Const SM_CYVIRTUALSCREEN = 79
	Const SM_CMONITORS = 80
	Const SM_SAMEDISPLAYFORMAT = 81
	Const SM_CMETRICS = 83


Type DLLVERSIONINFO2
	Field cbSize = SizeOf(Self), dwMajorVersion, dwMinorVersion, dwBuildNo, dwPlatformID
	Field dwFlags, ulVersion:Long
EndType

Type NMLVGETINFOTIPW
	Field NMHDR_hwnd, NMHDR_idFrom, NMHDR_code
	Field dwFlags, pszText:Short Ptr, cchTextMax
	Field iItem, iSubItem, lParam
EndType

?Debug

Type TWindowsDebug

	Const WM_ACTIVATE% = $6
	Const WM_ACTIVATEAPP% = $1C
	Const WM_AFXFIRST% = $360
	Const WM_AFXLAST% = $37F
	Const WM_APP% = $8000
	Const WM_ASKCBFORMATNAME% = $30C
	Const WM_CANCELJOURNAL% = $4B
	Const WM_CANCELMODE% = $1F
	Const WM_CAPTURECHANGED% = $215
	Const WM_CHANGECBCHAIN% = $30D
	Const WM_CHANGEUISTATE% = $127
	Const WM_CHAR% = $102
	Const WM_CHARTOITEM% = $2F
	Const WM_CHILDACTIVATE% = $22
	Const WM_CLEAR% = $303
	Const WM_CLOSE% = $10
	Const WM_COMMAND% = $111
	Const WM_COMPACTING% = $41
	Const WM_COMPAREITEM% = $39
	Const WM_CONTEXTMENU% = $7B
	Const WM_COPY% = $301
	Const WM_COPYDATA% = $4A
	Const WM_CREATE% = $1
	Const WM_CTLCOLORBTN% = $135
	Const WM_CTLCOLORDLG% = $136
	Const WM_CTLCOLOREDIT% = $133
	Const WM_CTLCOLORLISTBOX% = $134
	Const WM_CTLCOLORMSGBOX% = $132
	Const WM_CTLCOLORSCROLLBAR% = $137
	Const WM_CTLCOLORSTATIC% = $138
	Const WM_CUT% = $300
	Const WM_DEADCHAR% = $103
	Const WM_DELETEITEM% = $2D
	Const WM_DESTROY% = $2
	Const WM_DESTROYCLIPBOARD% = $307
	Const WM_DEVICECHANGE% = $219
	Const WM_DEVMODECHANGE% = $1B
	Const WM_DISPLAYCHANGE% = $7E
	Const WM_DRAWCLIPBOARD% = $308
	Const WM_DRAWITEM% = $2B
	Const WM_DROPFILES% = $233
	Const WM_ENABLE% = $A
	Const WM_ENDSESSION% = $16
	Const WM_ENTERIDLE% = $121
	Const WM_ENTERMENULOOP% = $211
	Const WM_ENTERSIZEMOVE% = $231
	Const WM_ERASEBKGND% = $14
	Const WM_EXITMENULOOP% = $212
	Const WM_EXITSIZEMOVE% = $232
	Const WM_FONTCHANGE% = $1D
	Const WM_GETDLGCODE% = $87
	Const WM_GETFONT% = $31
	Const WM_GETHOTKEY% = $33
	Const WM_GETICON% = $7F
	Const WM_GETMINMAXINFO% = $24
	Const WM_GETOBJECT% = $3D
	Const WM_GETTEXT% = $D
	Const WM_GETTEXTLENGTH% = $E
	Const WM_HANDHELDFIRST% = $358
	Const WM_HANDHELDLAST% = $35F
	Const WM_HELP% = $53
	Const WM_HOTKEY% = $312
	Const WM_HSCROLL% = $114
	Const WM_HSCROLLCLIPBOARD% = $30E
	Const WM_ICONERASEBKGND% = $27
	Const WM_IME_CHAR% = $286
	Const WM_IME_COMPOSITION% = $10F
	Const WM_IME_COMPOSITIONFULL% = $284
	Const WM_IME_CONTROL% = $283
	Const WM_IME_ENDCOMPOSITION% = $10E
	Const WM_IME_KEYDOWN% = $290
	Const WM_IME_KEYLAST% = $10F
	Const WM_IME_KEYUP% = $291
	Const WM_IME_NOTIFY% = $282
	Const WM_IME_REQUEST% = $288
	Const WM_IME_SELECT% = $285
	Const WM_IME_SETCONTEXT% = $281
	Const WM_IME_STARTCOMPOSITION% = $10D
	Const WM_INITDIALOG% = $110
	Const WM_INITMENU% = $116
	Const WM_INITMENUPOPUP% = $117
	Const WM_INPUTLANGCHANGE% = $51
	Const WM_INPUTLANGCHANGEREQUEST% = $50
	Const WM_KEYDOWN% = $100
	Const WM_KEYFIRST% = $100
	Const WM_KEYLAST% = $108
	Const WM_KEYUP% = $101
	Const WM_KILLFOCUS% = $8
	Const WM_LBUTTONDBLCLK% = $203
	Const WM_LBUTTONDOWN% = $201
	Const WM_LBUTTONUP% = $202
	Const WM_MBUTTONDBLCLK% = $209
	Const WM_MBUTTONDOWN% = $207
	Const WM_MBUTTONUP% = $208
	Const WM_MDIACTIVATE% = $222
	Const WM_MDICASCADE% = $227
	Const WM_MDICREATE% = $220
	Const WM_MDIDESTROY% = $221
	Const WM_MDIGETACTIVE% = $229
	Const WM_MDIICONARRANGE% = $228
	Const WM_MDIMAXIMIZE% = $225
	Const WM_MDINEXT% = $224
	Const WM_MDIREFRESHMENU% = $234
	Const WM_MDIRESTORE% = $223
	Const WM_MDISETMENU% = $230
	Const WM_MDITILE% = $226
	Const WM_MEASUREITEM% = $2C
	Const WM_MENUCHAR% = $120
	Const WM_MENUCOMMAND% = $126
	Const WM_MENUDRAG% = $123
	Const WM_MENUGETOBJECT% = $124
	Const WM_MENURBUTTONUP% = $122
	Const WM_MENUSELECT% = $11F
	Const WM_MOUSEACTIVATE% = $21
	Const WM_MOUSEFIRST% = $200
	Const WM_MOUSEHOVER% = $2A1
	Const WM_MOUSELAST% = $20D
	Const WM_MOUSELEAVE% = $2A3
	Const WM_MOUSEMOVE% = $200
	Const WM_MOUSEWHEEL% = $20A
	Const WM_MOUSEHWHEEL% = $20E
	Const WM_MOVE% = $3
	Const WM_MOVING% = $216
	Const WM_NCACTIVATE% = $86
	Const WM_NCCALCSIZE% = $83
	Const WM_NCCREATE% = $81
	Const WM_NCDESTROY% = $82
	Const WM_NCHITTEST% = $84
	Const WM_NCLBUTTONDBLCLK% = $A3
	Const WM_NCLBUTTONDOWN% = $A1
	Const WM_NCLBUTTONUP% = $A2
	Const WM_NCMBUTTONDBLCLK% = $A9
	Const WM_NCMBUTTONDOWN% = $A7
	Const WM_NCMBUTTONUP% = $A8
	Const WM_NCMOUSEMOVE% = $A0
	Const WM_NCPAINT% = $85
	Const WM_NCRBUTTONDBLCLK% = $A6
	Const WM_NCRBUTTONDOWN% = $A4
	Const WM_NCRBUTTONUP% = $A5
	Const WM_NEXTDLGCTL% = $28
	Const WM_NEXTMENU% = $213
	Const WM_NOTIFY% = $4E
	Const WM_NOTIFYFORMAT% = $55
	Const WM_NULL% = $0
	Const WM_PAINT% = $F
	Const WM_PAINTCLIPBOARD% = $309
	Const WM_PAINTICON% = $26
	Const WM_PALETTECHANGED% = $311
	Const WM_PALETTEISCHANGING% = $310
	Const WM_PARENTNOTIFY% = $210
	Const WM_PASTE% = $302
	Const WM_PENWINFIRST% = $380
	Const WM_PENWINLAST% = $38F
	Const WM_POWER% = $48
	Const WM_POWERBROADCAST% = $218
	Const WM_PRINT% = $317
	Const WM_PRINTCLIENT% = $318
	Const WM_QUERYDRAGICON% = $37
	Const WM_QUERYENDSESSION% = $11
	Const WM_QUERYNEWPALETTE% = $30F
	Const WM_QUERYOPEN% = $13
	Const WM_QUEUESYNC% = $23
	Const WM_QUIT% = $12
	Const WM_RBUTTONDBLCLK% = $206
	Const WM_RBUTTONDOWN% = $204
	Const WM_RBUTTONUP% = $205
	Const WM_RENDERALLFORMATS% = $306
	Const WM_RENDERFORMAT% = $305
	Const WM_SETCURSOR% = $20
	Const WM_SETFOCUS% = $7
	Const WM_SETFONT% = $30
	Const WM_SETHOTKEY% = $32
	Const WM_SETICON% = $80
	Const WM_SETREDRAW% = $B
	Const WM_SETTEXT% = $C
	Const WM_SETTINGCHANGE% = $1A
	Const WM_SHOWWINDOW% = $18
	Const WM_SIZE% = $5
	Const WM_SIZECLIPBOARD% = $30B
	Const WM_SIZING% = $214
	Const WM_SPOOLERSTATUS% = $2A
	Const WM_STYLECHANGED% = $7D
	Const WM_STYLECHANGING% = $7C
	Const WM_SYNCPAINT% = $88
	Const WM_SYSCHAR% = $106
	Const WM_SYSCOLORCHANGE% = $15
	Const WM_SYSCOMMAND% = $112
	Const WM_SYSDEADCHAR% = $107
	Const WM_SYSKEYDOWN% = $104
	Const WM_SYSKEYUP% = $105
	Const WM_TCARD% = $52
	Const WM_THEMECHANGED% = $31A
	Const WM_TIMECHANGE% = $1E
	Const WM_TIMER% = $113
	Const WM_UNDO% = $304
	Const WM_UNINITMENUPOPUP% = $125
	Const WM_USER% = $400
	Const WM_USERCHANGED% = $54
	Const WM_VKEYTOITEM% = $2E
	Const WM_VSCROLL% = $115
	Const WM_VSCROLLCLIPBOARD% = $30A
	Const WM_WINDOWPOSCHANGED% = $47
	Const WM_WINDOWPOSCHANGING% = $46
	Const WM_WININICHANGE% = $1A
	Const WM_XBUTTONDBLCLK% = $20D
	Const WM_XBUTTONDOWN% = $20B
	Const WM_XBUTTONUP% = $20C
	
	Function ReverseLookupMsg$( msg% )
		
		Select msg
			Case WM_ACTIVATE;Return "WM_ACTIVATE ($6)"
			Case WM_ACTIVATEAPP;Return "WM_ACTIVATEAPP ($1C)"
			Case WM_AFXFIRST;Return "WM_AFXFIRST ($360)"
			Case WM_AFXLAST;Return "WM_AFXLAST ($37F)"
			Case WM_APP;Return "WM_APP ($8000)"
			Case WM_ASKCBFORMATNAME;Return "WM_ASKCBFORMATNAME ($30C)"
			Case WM_CANCELJOURNAL;Return "WM_CANCELJOURNAL ($4B)"
			Case WM_CANCELMODE;Return "WM_CANCELMODE ($1F)"
			Case WM_CAPTURECHANGED;Return "WM_CAPTURECHANGED ($215)"
			Case WM_CHANGECBCHAIN;Return "WM_CHANGECBCHAIN ($30D)"
			Case WM_CHANGEUISTATE;Return "WM_CHANGEUISTATE ($127)"
			Case WM_CHAR;Return "WM_CHAR ($102)"
			Case WM_CHARTOITEM;Return "WM_CHARTOITEM ($2F)"
			Case WM_CHILDACTIVATE;Return "WM_CHILDACTIVATE ($22)"
			Case WM_CLEAR;Return "WM_CLEAR ($303)"
			Case WM_CLOSE;Return "WM_CLOSE ($10)"
			Case WM_COMMAND;Return "WM_COMMAND ($111)"
			Case WM_COMPACTING;Return "WM_COMPACTING ($41)"
			Case WM_COMPAREITEM;Return "WM_COMPAREITEM ($39)"
			Case WM_CONTEXTMENU;Return "WM_CONTEXTMENU ($7B)"
			Case WM_COPY;Return "WM_COPY ($301)"
			Case WM_COPYDATA;Return "WM_COPYDATA ($4A)"
			Case WM_CREATE;Return "WM_CREATE ($1)"
			Case WM_CTLCOLORBTN;Return "WM_CTLCOLORBTN ($135)"
			Case WM_CTLCOLORDLG;Return "WM_CTLCOLORDLG ($136)"
			Case WM_CTLCOLOREDIT;Return "WM_CTLCOLOREDIT ($133)"
			Case WM_CTLCOLORLISTBOX;Return "WM_CTLCOLORLISTBOX ($134)"
			Case WM_CTLCOLORMSGBOX;Return "WM_CTLCOLORMSGBOX ($132)"
			Case WM_CTLCOLORSCROLLBAR;Return "WM_CTLCOLORSCROLLBAR ($137)"
			Case WM_CTLCOLORSTATIC;Return "WM_CTLCOLORSTATIC ($138)"
			Case WM_CUT;Return "WM_CUT ($300)"
			Case WM_DEADCHAR;Return "WM_DEADCHAR ($103)"
			Case WM_DELETEITEM;Return "WM_DELETEITEM ($2D)"
			Case WM_DESTROY;Return "WM_DESTROY ($2)"
			Case WM_DESTROYCLIPBOARD;Return "WM_DESTROYCLIPBOARD ($307)"
			Case WM_DEVICECHANGE;Return "WM_DEVICECHANGE ($219)"
			Case WM_DEVMODECHANGE;Return "WM_DEVMODECHANGE ($1B)"
			Case WM_DISPLAYCHANGE;Return "WM_DISPLAYCHANGE ($7E)"
			Case WM_DRAWCLIPBOARD;Return "WM_DRAWCLIPBOARD ($308)"
			Case WM_DRAWITEM;Return "WM_DRAWITEM ($2B)"
			Case WM_DROPFILES;Return "WM_DROPFILES ($233)"
			Case WM_ENABLE;Return "WM_ENABLE ($A)"
			Case WM_ENDSESSION;Return "WM_ENDSESSION ($16)"
			Case WM_ENTERIDLE;Return "WM_ENTERIDLE ($121)"
			Case WM_ENTERMENULOOP;Return "WM_ENTERMENULOOP ($211)"
			Case WM_ENTERSIZEMOVE;Return "WM_ENTERSIZEMOVE ($231)"
			Case WM_ERASEBKGND;Return "WM_ERASEBKGND ($14)"
			Case WM_EXITMENULOOP;Return "WM_EXITMENULOOP ($212)"
			Case WM_EXITSIZEMOVE;Return "WM_EXITSIZEMOVE ($232)"
			Case WM_FONTCHANGE;Return "WM_FONTCHANGE ($1D)"
			Case WM_GETDLGCODE;Return "WM_GETDLGCODE ($87)"
			Case WM_GETFONT;Return "WM_GETFONT ($31)"
			Case WM_GETHOTKEY;Return "WM_GETHOTKEY ($33)"
			Case WM_GETICON;Return "WM_GETICON ($7F)"
			Case WM_GETMINMAXINFO;Return "WM_GETMINMAXINFO ($24)"
			Case WM_GETOBJECT;Return "WM_GETOBJECT ($3D)"
			Case WM_GETTEXT;Return "WM_GETTEXT ($D)"
			Case WM_GETTEXTLENGTH;Return "WM_GETTEXTLENGTH ($E)"
			Case WM_HANDHELDFIRST;Return "WM_HANDHELDFIRST ($358)"
			Case WM_HANDHELDLAST;Return "WM_HANDHELDLAST ($35F)"
			Case WM_HELP;Return "WM_HELP ($53)"
			Case WM_HOTKEY;Return "WM_HOTKEY ($312)"
			Case WM_HSCROLL;Return "WM_HSCROLL ($114)"
			Case WM_HSCROLLCLIPBOARD;Return "WM_HSCROLLCLIPBOARD ($30E)"
			Case WM_ICONERASEBKGND;Return "WM_ICONERASEBKGND ($27)"
			Case WM_IME_CHAR;Return "WM_IME_CHAR ($286)"
			Case WM_IME_COMPOSITION;Return "WM_IME_COMPOSITION ($10F)"
			Case WM_IME_COMPOSITIONFULL;Return "WM_IME_COMPOSITIONFULL ($284)"
			Case WM_IME_CONTROL;Return "WM_IME_CONTROL ($283)"
			Case WM_IME_ENDCOMPOSITION;Return "WM_IME_ENDCOMPOSITION ($10E)"
			Case WM_IME_KEYDOWN;Return "WM_IME_KEYDOWN ($290)"
			Case WM_IME_KEYLAST;Return "WM_IME_KEYLAST ($10F)"
			Case WM_IME_KEYUP;Return "WM_IME_KEYUP ($291)"
			Case WM_IME_NOTIFY;Return "WM_IME_NOTIFY ($282)"
			Case WM_IME_REQUEST;Return "WM_IME_REQUEST ($288)"
			Case WM_IME_SELECT;Return "WM_IME_SELECT ($285)"
			Case WM_IME_SETCONTEXT;Return "WM_IME_SETCONTEXT ($281)"
			Case WM_IME_STARTCOMPOSITION;Return "WM_IME_STARTCOMPOSITION ($10D)"
			Case WM_INITDIALOG;Return "WM_INITDIALOG ($110)"
			Case WM_INITMENU;Return "WM_INITMENU ($116)"
			Case WM_INITMENUPOPUP;Return "WM_INITMENUPOPUP ($117)"
			Case WM_INPUTLANGCHANGE;Return "WM_INPUTLANGCHANGE ($51)"
			Case WM_INPUTLANGCHANGEREQUEST;Return "WM_INPUTLANGCHANGEREQUEST ($50)"
			Case WM_KEYDOWN;Return "WM_KEYDOWN ($100)"
			Case WM_KEYFIRST;Return "WM_KEYFIRST ($100)"
			Case WM_KEYLAST;Return "WM_KEYLAST ($108)"
			Case WM_KEYUP;Return "WM_KEYUP ($101)"
			Case WM_KILLFOCUS;Return "WM_KILLFOCUS ($8)"
			Case WM_LBUTTONDBLCLK;Return "WM_LBUTTONDBLCLK ($203)"
			Case WM_LBUTTONDOWN;Return "WM_LBUTTONDOWN ($201)"
			Case WM_LBUTTONUP;Return "WM_LBUTTONUP ($202)"
			Case WM_MBUTTONDBLCLK;Return "WM_MBUTTONDBLCLK ($209)"
			Case WM_MBUTTONDOWN;Return "WM_MBUTTONDOWN ($207)"
			Case WM_MBUTTONUP;Return "WM_MBUTTONUP ($208)"
			Case WM_MDIACTIVATE;Return "WM_MDIACTIVATE ($222)"
			Case WM_MDICASCADE;Return "WM_MDICASCADE ($227)"
			Case WM_MDICREATE;Return "WM_MDICREATE ($220)"
			Case WM_MDIDESTROY;Return "WM_MDIDESTROY ($221)"
			Case WM_MDIGETACTIVE;Return "WM_MDIGETACTIVE ($229)"
			Case WM_MDIICONARRANGE;Return "WM_MDIICONARRANGE ($228)"
			Case WM_MDIMAXIMIZE;Return "WM_MDIMAXIMIZE ($225)"
			Case WM_MDINEXT;Return "WM_MDINEXT ($224)"
			Case WM_MDIREFRESHMENU;Return "WM_MDIREFRESHMENU ($234)"
			Case WM_MDIRESTORE;Return "WM_MDIRESTORE ($223)"
			Case WM_MDISETMENU;Return "WM_MDISETMENU ($230)"
			Case WM_MDITILE;Return "WM_MDITILE ($226)"
			Case WM_MEASUREITEM;Return "WM_MEASUREITEM ($2C)"
			Case WM_MENUCHAR;Return "WM_MENUCHAR ($120)"
			Case WM_MENUCOMMAND;Return "WM_MENUCOMMAND ($126)"
			Case WM_MENUDRAG;Return "WM_MENUDRAG ($123)"
			Case WM_MENUGETOBJECT;Return "WM_MENUGETOBJECT ($124)"
			Case WM_MENURBUTTONUP;Return "WM_MENURBUTTONUP ($122)"
			Case WM_MENUSELECT;Return "WM_MENUSELECT ($11F)"
			Case WM_MOUSEACTIVATE;Return "WM_MOUSEACTIVATE ($21)"
			Case WM_MOUSEFIRST;Return "WM_MOUSEFIRST ($200)"
			Case WM_MOUSEHOVER;Return "WM_MOUSEHOVER ($2A1)"
			Case WM_MOUSELAST;Return "WM_MOUSELAST ($20D)"
			Case WM_MOUSELEAVE;Return "WM_MOUSELEAVE ($2A3)"
			Case WM_MOUSEMOVE;Return "WM_MOUSEMOVE ($200)"
			Case WM_MOUSEWHEEL;Return "WM_MOUSEWHEEL ($20A)"
			Case WM_MOUSEHWHEEL;Return "WM_MOUSEHWHEEL ($20E)"
			Case WM_MOVE;Return "WM_MOVE ($3)"
			Case WM_MOVING;Return "WM_MOVING ($216)"
			Case WM_NCACTIVATE;Return "WM_NCACTIVATE ($86)"
			Case WM_NCCALCSIZE;Return "WM_NCCALCSIZE ($83)"
			Case WM_NCCREATE;Return "WM_NCCREATE ($81)"
			Case WM_NCDESTROY;Return "WM_NCDESTROY ($82)"
			Case WM_NCHITTEST;Return "WM_NCHITTEST ($84)"
			Case WM_NCLBUTTONDBLCLK;Return "WM_NCLBUTTONDBLCLK ($A3)"
			Case WM_NCLBUTTONDOWN;Return "WM_NCLBUTTONDOWN ($A1)"
			Case WM_NCLBUTTONUP;Return "WM_NCLBUTTONUP ($A2)"
			Case WM_NCMBUTTONDBLCLK;Return "WM_NCMBUTTONDBLCLK ($A9)"
			Case WM_NCMBUTTONDOWN;Return "WM_NCMBUTTONDOWN ($A7)"
			Case WM_NCMBUTTONUP;Return "WM_NCMBUTTONUP ($A8)"
			Case WM_NCMOUSEMOVE;Return "WM_NCMOUSEMOVE ($A0)"
			Case WM_NCPAINT;Return "WM_NCPAINT ($85)"
			Case WM_NCRBUTTONDBLCLK;Return "WM_NCRBUTTONDBLCLK ($A6)"
			Case WM_NCRBUTTONDOWN;Return "WM_NCRBUTTONDOWN ($A4)"
			Case WM_NCRBUTTONUP;Return "WM_NCRBUTTONUP ($A5)"
			Case WM_NEXTDLGCTL;Return "WM_NEXTDLGCTL ($28)"
			Case WM_NEXTMENU;Return "WM_NEXTMENU ($213)"
			Case WM_NOTIFY;Return "WM_NOTIFY ($4E)"
			Case WM_NOTIFYFORMAT;Return "WM_NOTIFYFORMAT ($55)"
			Case WM_NULL;Return "WM_NULL ($0)"
			Case WM_PAINT;Return "WM_PAINT ($F)"
			Case WM_PAINTCLIPBOARD;Return "WM_PAINTCLIPBOARD ($309)"
			Case WM_PAINTICON;Return "WM_PAINTICON ($26)"
			Case WM_PALETTECHANGED;Return "WM_PALETTECHANGED ($311)"
			Case WM_PALETTEISCHANGING;Return "WM_PALETTEISCHANGING ($310)"
			Case WM_PARENTNOTIFY;Return "WM_PARENTNOTIFY ($210)"
			Case WM_PASTE;Return "WM_PASTE ($302)"
			Case WM_PENWINFIRST;Return "WM_PENWINFIRST ($380)"
			Case WM_PENWINLAST;Return "WM_PENWINLAST ($38F)"
			Case WM_POWER;Return "WM_POWER ($48)"
			Case WM_POWERBROADCAST;Return "WM_POWERBROADCAST ($218)"
			Case WM_PRINT;Return "WM_PRINT ($317)"
			Case WM_PRINTCLIENT;Return "WM_PRINTCLIENT ($318)"
			Case WM_QUERYDRAGICON;Return "WM_QUERYDRAGICON ($37)"
			Case WM_QUERYENDSESSION;Return "WM_QUERYENDSESSION ($11)"
			Case WM_QUERYNEWPALETTE;Return "WM_QUERYNEWPALETTE ($30F)"
			Case WM_QUERYOPEN;Return "WM_QUERYOPEN ($13)"
			Case WM_QUEUESYNC;Return "WM_QUEUESYNC ($23)"
			Case WM_QUIT;Return "WM_QUIT ($12)"
			Case WM_RBUTTONDBLCLK;Return "WM_RBUTTONDBLCLK ($206)"
			Case WM_RBUTTONDOWN;Return "WM_RBUTTONDOWN ($204)"
			Case WM_RBUTTONUP;Return "WM_RBUTTONUP ($205)"
			Case WM_RENDERALLFORMATS;Return "WM_RENDERALLFORMATS ($306)"
			Case WM_RENDERFORMAT;Return "WM_RENDERFORMAT ($305)"
			Case WM_SETCURSOR;Return "WM_SETCURSOR ($20)"
			Case WM_SETFOCUS;Return "WM_SETFOCUS ($7)"
			Case WM_SETFONT;Return "WM_SETFONT ($30)"
			Case WM_SETHOTKEY;Return "WM_SETHOTKEY ($32)"
			Case WM_SETICON;Return "WM_SETICON ($80)"
			Case WM_SETREDRAW;Return "WM_SETREDRAW ($B)"
			Case WM_SETTEXT;Return "WM_SETTEXT ($C)"
			Case WM_SETTINGCHANGE;Return "WM_SETTINGCHANGE ($1A)"
			Case WM_SHOWWINDOW;Return "WM_SHOWWINDOW ($18)"
			Case WM_SIZE;Return "WM_SIZE ($5)"
			Case WM_SIZECLIPBOARD;Return "WM_SIZECLIPBOARD ($30B)"
			Case WM_SIZING;Return "WM_SIZING ($214)"
			Case WM_SPOOLERSTATUS;Return "WM_SPOOLERSTATUS ($2A)"
			Case WM_STYLECHANGED;Return "WM_STYLECHANGED ($7D)"
			Case WM_STYLECHANGING;Return "WM_STYLECHANGING ($7C)"
			Case WM_SYNCPAINT;Return "WM_SYNCPAINT ($88)"
			Case WM_SYSCHAR;Return "WM_SYSCHAR ($106)"
			Case WM_SYSCOLORCHANGE;Return "WM_SYSCOLORCHANGE ($15)"
			Case WM_SYSCOMMAND;Return "WM_SYSCOMMAND ($112)"
			Case WM_SYSDEADCHAR;Return "WM_SYSDEADCHAR ($107)"
			Case WM_SYSKEYDOWN;Return "WM_SYSKEYDOWN ($104)"
			Case WM_SYSKEYUP;Return "WM_SYSKEYUP ($105)"
			Case WM_TCARD;Return "WM_TCARD ($52)"
			Case WM_THEMECHANGED;Return "WM_THEMECHANGED ($31A)"
			Case WM_TIMECHANGE;Return "WM_TIMECHANGE ($1E)"
			Case WM_TIMER;Return "WM_TIMER ($113)"
			Case WM_UNDO;Return "WM_UNDO ($304)"
			Case WM_UNINITMENUPOPUP;Return "WM_UNINITMENUPOPUP ($125)"
			Case WM_USER;Return "WM_USER ($400)"
			Case WM_USERCHANGED;Return "WM_USERCHANGED ($54)"
			Case WM_VKEYTOITEM;Return "WM_VKEYTOITEM ($2E)"
			Case WM_VSCROLL;Return "WM_VSCROLL ($115)"
			Case WM_VSCROLLCLIPBOARD;Return "WM_VSCROLLCLIPBOARD ($30A)"
			Case WM_WINDOWPOSCHANGED;Return "WM_WINDOWPOSCHANGED ($47)"
			Case WM_WINDOWPOSCHANGING;Return "WM_WINDOWPOSCHANGING ($46)"
			Case WM_WININICHANGE;Return "WM_WININICHANGE ($1A)"
			Case WM_XBUTTONDBLCLK;Return "WM_XBUTTONDBLCLK ($20D)"
			Case WM_XBUTTONDOWN;Return "WM_XBUTTONDOWN ($20B)"
			Case WM_XBUTTONUP;Return "WM_XBUTTONUP ($20C)"
			Default;Return "Unknown Message (" + msg + ")"
		EndSelect
		
	EndFunction

EndType
?
