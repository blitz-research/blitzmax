
Const OUT_DEFAULT_PRECIS=0
Const OUT_STRING_PRECIS=1
Const OUT_CHARACTER_PRECIS=2
Const OUT_STROKE_PRECIS=3
Const OUT_TT_PRECIS=4
Const OUT_DEVICE_PRECIS=5
Const OUT_RASTER_PRECIS=6
Const OUT_TT_ONLY_PRECIS=7
Const OUT_OUTLINE_PRECIS=8
Const OUT_SCREEN_OUTLINE_PRECIS=9
Const OUT_PS_ONLY_PRECIS=10

Const CLIP_DEFAULT_PRECIS=0
Const CLIP_CHARACTER_PRECIS=1
Const CLIP_STROKE_PRECIS=2
Const CLIP_MASK=15
Const CLIP_LH_ANGLES=(1 Shl 4)
Const CLIP_TT_ALWAYS=(2 Shl 4)
Const CLIP_DFA_DISABLE=(4 Shl 4)
Const CLIP_EMBEDDED=(8 Shl 4)

' font constants

Const DEFAULT_QUALITY =0
Const DRAFT_QUALITY =1
Const PROOF_QUALITY =2
Const NONANTIALIASED_QUALITY=3
Const ANTIALIASED_QUALITY= 4
Const CLEARTYPE_QUALITY=5
Const CLEARTYPE_NATURAL_QUALITY=6

Const DEFAULT_PITCH =0
Const FIXED_PITCH =1
Const VARIABLE_PITCH=2
Const MONO_FONT =8

Const ANSI_CHARSET=0
Const DEFAULT_CHARSET =1
Const SYMBOL_CHARSET=2
Const SHIFTJIS_CHARSET=128
Const HANGEUL_CHARSET =129
Const HANGUL_CHARSET=129
Const GB2312_CHARSET=134
Const CHINESEBIG5_CHARSET =136
Const OEM_CHARSET =255

Const JOHAB_CHARSET =130
Const HEBREW_CHARSET=177
Const ARABIC_CHARSET=178
Const GREEK_CHARSET =161
Const TURKISH_CHARSET =162
Const VIETNAMESE_CHARSET=163
Const THAI_CHARSET=222
Const EASTEUROPE_CHARSET=238
Const RUSSIAN_CHARSET =204

Const MAC_CHARSET =77
Const BALTIC_CHARSET=186

Const FS_LATIN1 =$00000001
Const FS_LATIN2 =$00000002
Const FS_CYRILLIC =$00000004
Const FS_GREEK=$00000008
Const FS_TURKISH=$00000010
Const FS_HEBREW =$00000020
Const FS_ARABIC =$00000040
Const FS_BALTIC =$00000080
Const FS_VIETNAMESE =$00000100
Const FS_THAI =$00010000
Const FS_JISJAPAN =$00020000
Const FS_CHINESESIMP=$00040000
Const FS_WANSUNG=$00080000
Const FS_CHINESETRAD=$00100000
Const FS_JOHAB=$00200000
Const FS_SYMBOL =$80000000

Const FF_DONTCARE =(0 Shl 4)' Don't care or don't know. 
Const FF_ROMAN=(1 Shl 4)' Variable stroke width, serifed. 
' Times Roman, Century Schoolbook, etc. 
Const FF_SWISS=(2 Shl 4)' Variable stroke width, sans-serifed. 
 ' Helvetica, Swiss, etc. 
Const FF_MODERN =(3 Shl 4)' Constant stroke width, serifed Or sans-serifed. 
' Pica, Elite, Courier, etc. 
Const FF_SCRIPT =(4 Shl 4)' Cursive, etc. 
Const FF_DECORATIVE =(5 Shl 4)' Old English, etc. 

' Font Weights 

Const FW_DONTCARE =0
Const FW_THIN =100
Const FW_EXTRALIGHT =200
Const FW_LIGHT=300
Const FW_NORMAL =400
Const FW_MEDIUM =500
Const FW_SEMIBOLD =600
Const FW_BOLD =700
Const FW_EXTRABOLD=800
Const FW_HEAVY=900

Const FW_ULTRALIGHT =FW_EXTRALIGHT
Const FW_REGULAR=FW_NORMAL
Const FW_DEMIBOLD =FW_SEMIBOLD
Const FW_ULTRABOLD=FW_EXTRABOLD
Const FW_BLACK=FW_HEAVY



' Device Parameters for GetDeviceCaps()

Const DRIVERVERSION =0 ' Device driver version
Const TECHNOLOGY=2 ' Device classification
Const HORZSIZE=4 ' Horizontal size in millimeters 
Const VERTSIZE=6 ' Vertical size in millimeters 
Const HORZRES =8 ' Horizontal width in pixels 
Const VERTRES =10' Vertical height in pixels
Const BITSPIXEL =12' Number of bits per pixel 
Const PLANES=14' Number of planes 
Const NUMBRUSHES=16' Number of brushes the device has 
Const NUMPENS =18' Number of pens the device has
Const NUMMARKERS=20' Number of markers the device has 
Const NUMFONTS=22' Number of fonts the device has 
Const NUMCOLORS =24' Number of colors the device supports 
Const PDEVICESIZE =26' Size required For device descriptor
Const CURVECAPS =28' Curve capabilities 
Const LINECAPS=30' Line capabilities
Const POLYGONALCAPS =32' Polygonal capabilities 
Const TEXTCAPS=34' Text capabilities
Const CLIPCAPS=36' Clipping capabilities
Const RASTERCAPS=38' Bitblt capabilities
Const ASPECTX =40' Length of the X leg
Const ASPECTY =42' Length of the Y leg
Const ASPECTXY=44' Length of the hypotenuse 

Const LOGPIXELSX=88' Logical pixels/inch in X 
Const LOGPIXELSY=90' Logical pixels/inch in Y 

Const SIZEPALETTE=104' Number of entries in physical palette
Const NUMRESERVED=106' Number of reserved entries in palette
Const COLORRES =108' Actual color resolution

' Printing related DeviceCaps. These Replace the appropriate Escapes

Const PHYSICALWIDTH =110 ' Physical Width in device units 
Const PHYSICALHEIGHT=111 ' Physical Height in device units
Const PHYSICALOFFSETX =112 ' Physical Printable Area x margin 
Const PHYSICALOFFSETY =113 ' Physical Printable Area y margin 
Const SCALINGFACTORX=114 ' Scaling factor x 
Const SCALINGFACTORY=115 ' Scaling factor y 

' Display driver specific

Const VREFRESH=116' Current vertical refresh rate of the display device (For displays only) in Hz
Const DESKTOPVERTRES=117' Horizontal width of entire Desktop in pixels 
Const DESKTOPHORZRES=118' Vertical height of entire Desktop in pixels
Const BLTALIGNMENT=119' Preferred blt alignment 
Const SHADEBLENDCAPS=120' Shading And blending caps 
Const COLORMGMTCAPS =121' Color Management caps 

Const WHITE_BRUSH=0
Const LTGRAY_BRUSH=1
Const GRAY_BRUSH=2
Const DKGRAY_BRUSH=3
Const BLACK_BRUSH=4
Const HOLLOW_BRUSH=5
Const NULL_BRUSH=5
Const WHITE_PEN=6
Const BLACK_PEN=7
Const NULL_PEN=8
Const OEM_FIXED_FONT=10
Const ANSI_FIXED_FONT=11
Const ANSI_VAR_FONT=12
Const SYSTEM_FONT=13
Const DEVICE_DEFAULT_FONT=14
Const DEFAULT_PALETTE=15
Const SYSTEM_FIXED_FONT=16
Const DEFAULT_GUI_FONT=17
Const DC_BRUSH=18
Const DC_PEN=19

Const ROP_SRCCOPY=$00CC0020
Const ROP_SRCPAINT=$00EE0086
Const ROP_SRCAND=$008800C6
Const ROP_SRCINVERT=$00660046
Const ROP_SRCERASE=$00440328
Const ROP_NOTSRCCOPY=$00330008
Const ROP_NOTSRCERASE=$001100A6
Const ROP_MERGECOPY=$00C000CA
Const ROP_MERGEPAINT=$00BB0226
Const ROP_PATCOPY=$00F00021
Const ROP_PATPAINT=$00FB0A09
Const ROP_PATINVERT=$005A0049
Const ROP_DSTINVERT=$00550009
Const ROP_BLACKNESS=$00000042
Const ROP_WHITENESS=$00FF0062

Const DM_SPECVERSION=800
Const DM_GRAYSCALE=1
Const DM_INTERLACED=2
Const DM_UPDATE=1
Const DM_COPY=2
Const DM_PROMPT=4
Const DM_MODIFY=8
Const DM_IN_BUFFER=DM_MODIFY
Const DM_IN_PROMPT=DM_PROMPT
Const DM_OUT_BUFFER=DM_COPY
Const DM_OUT_DEFAULT=DM_UPDATE
Const DM_ORIENTATION=1
Const DM_PAPERSIZE=2
Const DM_PAPERLENGTH=4
Const DM_PAPERWIDTH=8
Const DM_SCALE=16
Const DM_COPIES=256
Const DM_DEFAULTSOURCE=512
Const DM_PRINTQUALITY=1024
Const DM_COLOR=2048
Const DM_DUPLEX=4096
Const DM_YRESOLUTION=8192
Const DM_TTOPTION=16384
Const DM_COLLATE=32768
Const DM_FORMNAME=65536
Const DM_LOGPIXELS=$20000
Const DM_BITSPERPEL=$40000
Const DM_PELSWIDTH=$80000
Const DM_PELSHEIGHT=$100000
Const DM_DISPLAYFLAGS=$200000
Const DM_DISPLAYFREQUENCY=$400000
Const DM_ICMMETHOD=$800000
Const DM_ICMINTENT=$1000000
Const DM_MEDIATYPE=$2000000
Const DM_DITHERTYPE=$4000000

Const PFD_TYPE_RGBA=0
Const PFD_TYPE_COLORINDEX=1
Const PFD_MAIN_PLANE=0
Const PFD_OVERLAY_PLANE=1
Const PFD_UNDERLAY_PLANE=-1
Const PFD_DOUBLEBUFFER=1
Const PFD_STEREO=2
Const PFD_DRAW_TO_WINDOW=4
Const PFD_DRAW_TO_BITMAP=8
Const PFD_SUPPORT_GDI=16
Const PFD_SUPPORT_OPENGL=32
Const PFD_GENERIC_FORMAT=64
Const PFD_NEED_PALETTE=128
Const PFD_NEED_SYSTEM_PALETTE=$00000100
Const PFD_SWAP_EXCHANGE=$00000200
Const PFD_SWAP_COPY=$00000400
Const PFD_SWAP_LAYER_BUFFERS=$00000800
Const PFD_GENERIC_ACCELERATED=$00001000
Const PFD_DEPTH_DONTCARE=$20000000
Const PFD_DOUBLEBUFFER_DONTCARE=$40000000
Const PFD_STEREO_DONTCARE=$80000000

Const BI_RGB=0
Const BI_RLE8=1
Const BI_RLE4=2
Const BI_BITFIELDS=3
Const BI_JPEG=4
Const BI_PNG=5

Const DIB_RGB_COLORS=0
Const DIB_PAL_COLORS=1

Const BLACKONWHITE=1
Const WHITEONBLACK=2
Const COLORONCOLOR=3
Const HALFTONE=4

Const WGL_ARB_pixel_format				=$0001
Const WGL_NUMBER_PIXEL_FORMATS_ARB		=$2000
Const WGL_DRAW_TO_WINDOW_ARB			=$2001
Const WGL_DRAW_TO_BITMAP_ARB			=$2002
Const WGL_ACCELERATION_ARB				=$2003
Const WGL_NEED_PALETTE_ARB				=$2004
Const WGL_NEED_SYSTEM_PALETTE_ARB		=$2005
Const WGL_SWAP_LAYER_BUFFERS_ARB		=$2006
Const WGL_SWAP_METHOD_ARB				=$2007
Const WGL_NUMBER_OVERLAYS_ARB			=$2008
Const WGL_NUMBER_UNDERLAYS_ARB			=$2009
Const WGL_TRANSPARENT_ARB				=$200A
Const WGL_TRANSPARENT_RED_VALUE_ARB		=$2037
Const WGL_TRANSPARENT_GREEN_VALUE_ARB	=$2038
Const WGL_TRANSPARENT_BLUE_VALUE_ARB	=$2039
Const WGL_TRANSPARENT_ALPHA_VALUE_ARB	=$203A
Const WGL_TRANSPARENT_INDEX_VALUE_ARB	=$203B
Const WGL_SHARE_DEPTH_ARB				=$200C
Const WGL_SHARE_STENCIL_ARB				=$200D
Const WGL_SHARE_ACCUM_ARB				=$200E
Const WGL_SUPPORT_GDI_ARB				=$200F
Const WGL_SUPPORT_OPENGL_ARB			=$2010
Const WGL_DOUBLE_BUFFER_ARB				=$2011
Const WGL_STEREO_ARB					=$2012
Const WGL_PIXEL_TYPE_ARB				=$2013
Const WGL_COLOR_BITS_ARB				=$2014
Const WGL_RED_BITS_ARB					=$2015
Const WGL_RED_SHIFT_ARB					=$2016
Const WGL_GREEN_BITS_ARB				=$2017
Const WGL_GREEN_SHIFT_ARB				=$2018
Const WGL_BLUE_BITS_ARB					=$2019
Const WGL_BLUE_SHIFT_ARB				=$201A
Const WGL_ALPHA_BITS_ARB				=$201B
Const WGL_ALPHA_SHIFT_ARB				=$201C
Const WGL_ACCUM_BITS_ARB				=$201D
Const WGL_ACCUM_RED_BITS_ARB			=$201E
Const WGL_ACCUM_GREEN_BITS_ARB			=$201F
Const WGL_ACCUM_BLUE_BITS_ARB			=$2020
Const WGL_ACCUM_ALPHA_BITS_ARB			=$2021
Const WGL_DEPTH_BITS_ARB				=$2022
Const WGL_STENCIL_BITS_ARB				=$2023
Const WGL_AUX_BUFFERS_ARB				=$2024
Const WGL_NO_ACCELERATION_ARB			=$2025
Const WGL_GENERIC_ACCELERATION_ARB		=$2026
Const WGL_FULL_ACCELERATION_ARB			=$2027
Const WGL_SWAP_EXCHANGE_ARB				=$2028
Const WGL_SWAP_COPY_ARB					=$2029
Const WGL_SWAP_UNDEFINED_ARB			=$202A
Const WGL_TYPE_RGBA_ARB					=$202B
Const WGL_TYPE_COLORINDEX_ARB			=$202C
Const WGL_SAMPLE_BUFFERS_ARB			=$2041
Const WGL_SAMPLES_ARB					=$2042

Type DEVMODE
	Field pad0,pad1,pad2,pad3,pad4,pad5,pad6,pad7			'dmDeviceName[32] - eek!
	Field dmSpecVersion:Short
	Field dmDriverVersion:Short
	Field dmSize:Short
	Field dmDriverExtra:Short
	Field dmFields
	Field dmPostition_x,dmPosition_y						'actually a gnarly union
	Field dmScale:Short
	Field dmCopies:Short
	Field dmDefaultSource:Short
	Field dmPrintQuality:Short
	Field dmColor:Short
	Field dmDuplex:Short
	Field dmYResolution:Short
	Field dmTTOption:Short
	Field dmCollate:Short
	Field pad8:Short,pad9,pad10,pad11,pad12,pad13,pad14,pad15,pad16:Short		'dmFormName[32]
	Field dmLogPixels:Short
	Field dmBitsPerPel
	Field dmPelsWidth
	Field dmPelsHeight
	Field dmDisplayFlags
	Field dmDisplayFrequency
	Field dmICMMethod
	Field dmICMIntent
	Field dmMediaType
	Field dmDitherType
	Field dmReserved1
	Field dmReserved2
	Field dmPanningWidth
	Field dmPanningHeight
End Type 

Type PIXELFORMATDESCRIPTOR
	Field nSize:Short
	Field nVersion:Short
	Field dwFlags
	Field iPixelType:Byte
	Field cColorBits:Byte
	Field cRedBits:Byte
	Field cRedShift:Byte
	Field cGreenBits:Byte
	Field cGreenShift:Byte
	Field cBlueBits:Byte
	Field cBlueShift:Byte
	Field cAlphaBits:Byte
	Field cAlphaShift:Byte
	Field cAccumBits:Byte
	Field cAccumRedBits:Byte
	Field cAccumGreenBits:Byte
	Field cAccumBlueBits:Byte
	Field cAccumAlphaBits:Byte
	Field cDepthBits:Byte
	Field cStencilBits:Byte
	Field cAuxBuffers:Byte
	Field iLayerType:Byte
	Field bReserved:Byte
	Field dwLayerMask 
	Field dwVisibleMask 
	Field dwDamageMask 
End Type

Type BITMAPINFOHEADER
	Field biSize
	Field biWidth
	Field biHeight
	Field biPlanes:Short
	Field biBitCount:Short
	Field biCompression
	Field biSizeImage
	Field biXPelsPerMeter
	Field biYPelsPerMeter
	Field biClrUsed
	Field biClrImportant
End Type

Type LOGFONTW
	Field lfHeight
	Field lfWidth
	Field lfEscapement
	Field lfOrientation
	Field lfWeight
	Field lfItalic:Byte
	Field lfUnderline:Byte
	Field lfStrikeOut:Byte
	Field lfCharSet:Byte
	Field lfOutPrecision:Byte
	Field lfClipPrecision:Byte
	Field lfQuality:Byte
	Field lfPitchAndFamily:Byte
	Field lfFaceName00:Short
	Field lfFaceName01:Short
	Field lfFaceName02:Short
	Field lfFaceName03:Short
	Field lfFaceName04:Short
	Field lfFaceName05:Short
	Field lfFaceName06:Short
	Field lfFaceName07:Short
	Field lfFaceName08:Short
	Field lfFaceName09:Short
	Field lfFaceName0a:Short
	Field lfFaceName0b:Short
	Field lfFaceName0c:Short
	Field lfFaceName0d:Short
	Field lfFaceName0e:Short
	Field lfFaceName0f:Short
	Field lfFaceName10:Short
	Field lfFaceName11:Short
	Field lfFaceName12:Short
	Field lfFaceName13:Short
	Field lfFaceName14:Short
	Field lfFaceName15:Short
	Field lfFaceName16:Short
	Field lfFaceName17:Short
	Field lfFaceName18:Short
	Field lfFaceName19:Short
	Field lfFaceName1a:Short
	Field lfFaceName1b:Short
	Field lfFaceName1c:Short
	Field lfFaceName1d:Short
	Field lfFaceName1e:Short
	Field lfFaceName1f:Short
End Type

Type TEXTMETRIC
	Field tmHeight
	Field tmAscent
	Field tmDescent
	Field tmInternalLeading
	Field tmExternalLeading
	Field tmAveCharWidth
	Field tmMaxCharWidth
	Field tmWeight
	Field tmOverhang
	Field tmDigitizedAspectX
	Field tmDigitizedAspectY
	Field tmFirstChar:Short
	Field tmLastChar:Short
	Field tmDefaultChar:Short
	Field tmBreakChar:Short
	Field tmItalic:Byte
	Field tmUnderlined:Byte
	Field tmStruckOut:Byte
	Field tmPitchAndFamily:Byte
	Field tmCharSet:Byte
	Field pad0:Byte
	Field pad1:Byte
	Field pad2:Byte
End Type


Extern "Win32"

Function GetStockObject( fnObject )
Function ChoosePixelFormat( hdc,ppfd:Byte Ptr )
Function SetPixelFormat( hdc,iPixelFormat,ppfd:Byte Ptr )
Function SwapBuffers( hdc )

Function wglCreateContext( hdc )
Function wglDeleteContext( hglrc )
Function wglMakeCurrent( hdc,hglrc )

Function BitBlt(hdc,x,y,w,h,src_dc,src_x,src_y,dwrop)

Function GetDeviceCaps(hdc,indec)


Function CreateFontA(cHeight,cWidth,cEscapement,cOrientation,cWeight,bItalic,bUnderline,bStrikeOut,..
	iCharSet,iOutPrecision,iClipPrecision,iQuality,iPitchAndFamily,pszFaceName:Byte Ptr)
	
Function CreateFontW(cHeight,cWidth,cEscapement,cOrientation,cWeight,bItalic,bUnderline,bStrikeOut,..
	iCharSet,iOutPrecision,iClipPrecision,iQuality,iPitchAndFamily,pszFaceName:Short Ptr)

Function SelectObject(hdc,obj)

Function DeleteObject( hObject )

Function CreateSolidBrush( crColor )

Function CreateCompatibleDC( hdc )
Function CreateCompatibleBitmap( hdc,nWidth,nHeight )

Function SetDIBits( hdc,hbmp,uStartScan,cScanLines,lpvBits:Byte Ptr,lpbmi:Byte Ptr,fuColorUse )
Function DeleteDC( hdc )

Function SetStretchBltMode( hdc,iStretchMode )

Function StretchBlt( hdcDest,dx,dy,dw,dh,hdcSrc,sx,sy,sw,sh,dwRop )

Function CreateFontIndirectW( lplf:Byte Ptr )
Function GetTextMetricsW( hdc,lptm:Byte Ptr )
Function GetTextFaceW( hdc,nCount,lpFaceName:Short Ptr )

End Extern
