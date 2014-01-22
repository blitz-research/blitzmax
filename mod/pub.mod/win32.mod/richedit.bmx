Strict

Import "user32.bmx"

Const EN_MSGFILTER=$0700
Const EN_REQUESTRESIZE=$0701
Const EN_SELCHANGE=$0702
Const EN_DROPFILES=$0703
Const EN_PROTECTED=$0704
Const EN_CORRECTTEXT=$0705		' PenWin specific 
Const EN_STOPNOUNDO=$0706
Const EN_IMECHANGE=$0707			' East Asia specific 
Const EN_SAVECLIPBOARD=$0708
Const EN_OLEOPFAILED=$0709
Const EN_OBJECTPOSITIONS=$070a
Const EN_LINK=$070b
Const EN_DRAGDROPDONE=$070c
Const EN_PARAGRAPHEXPANDED=$070d
Const EN_PAGECHANGE=$070e
Const EN_LOWFIRTF=$070f
Const EN_ALIGNLTR=$0710			' BiDi specific notification
Const EN_ALIGNRTL=$0711			' BiDi specific notification

' Event notification masks 
Const ENM_NONE=0
Const ENM_CHANGE=1
Const ENM_UPDATE=2
Const ENM_SCROLL=4
Const ENM_SCROLLEVENTS=8
Const ENM_DRAGDROPDONE=$10
Const ENM_PARAGRAPHEXPANDED=$20
Const ENM_PAGECHANGE=$40
Const ENM_KEYEVENTS=$10000
Const ENM_MOUSEEVENTS=$20000
Const ENM_REQUESTRESIZE=$40000
Const ENM_SELCHANGE=$80000
Const ENM_DROPFILES=$100000
Const ENM_PROTECTED=$200000
Const ENM_CORRECTTEXT=$400000		' PenWin specific 
Const ENM_IMECHANGE=$800000		' Used by RE1.0 compatibility
Const ENM_LANGCHANGE=$1000000
Const ENM_OBJECTPOSITIONS=$2000000
Const ENM_LINK=$4000000
Const ENM_LOWFIRTF=$8000000

' events
Const WM_UNICHAR=$0109

' codepage defaults
Const CP_ACP=0	'Default to ANSI code page
Const CP_OEMCP=1	'Default to OEM  code page */

Rem
Const EM_GETLIMITTEXT=WM_USER+37
Const EM_POSFROMCHAR	=WM_USER+38
Const EM_CHARFROMPOS	=WM_USER+39
Const EM_SCROLLCARET=WM_USER+49

Const EM_CANPASTE=WM_USER+50
Const EM_DISPLAYBAND=WM_USER+51
Const EM_EXGETSEL=WM_USER+52
Const EM_EXLIMITTEXT=WM_USER+53
Const EM_EXLINEFROMCHAR=WM_USER+54
Const EM_EXSETSEL	=WM_USER+55
Const EM_FINDTEXT=WM_USER+56
Const EM_FORMATRANGE=WM_USER+57
Const EM_GETCHARFORMAT=WM_USER+58
Const EM_GETEVENTMASK=WM_USER+59
Const EM_GETOLEINTERFACE=WM_USER+60
Const EM_GETPARAFORMAT=WM_USER+61
Const EM_GETSELTEXT=WM_USER+62
Const EM_HIDESELECTION=WM_USER+63
Const EM_PASTESPECIAL=WM_USER+64
Const EM_REQUESTRESIZE=WM_USER+65
Const EM_SELECTIONTYPE=WM_USER+66
Const EM_SETBKGNDCOLOR=WM_USER+67
Const EM_SETCHARFORMAT=WM_USER+68
Const EM_SETEVENTMASK=WM_USER+69
Const EM_SETOLECALLBACK=WM_USER+70
Const EM_SETPARAFORMAT=WM_USER+71
Const EM_SETTARGETDEVICE=WM_USER+72
Const EM_STREAMIN=WM_USER+73
Const EM_STREAMOUT=WM_USER+74
Const EM_GETTEXTRANGE=WM_USER+75
Const EM_FINDWORDBREAK=WM_USER+76
Const EM_SETOPTIONS=WM_USER+77
Const EM_GETOPTIONS=WM_USER+78
Const EM_FINDTEXTEX=WM_USER+79

Const EM_GETWORDBREAKPROCEX=WM_USER+80
Const EM_SETWORDBREAKPROCEX=WM_USER+81

' RichEdit 2.0 messages 

Const EM_SETUNDOLIMIT=WM_USER+82
Const EM_REDO=WM_USER+84
Const EM_CANREDO	=WM_USER+85
Const EM_GETUNDONAME=WM_USER+86
Const EM_GETREDONAME=WM_USER+87
Const EM_STOPGROUPTYPING=WM_USER+88

Const EM_SETTEXTMODE=WM_USER+89
Const EM_GETTEXTMODE=WM_USER+90

' TEXTMODE enum for use with EM_GET/SETTEXTMODE 
Const TM_PLAINTEXT=1
Const TM_RICHTEXT=2			'Default behavior 
Const TM_SINGLELEVELUNDO=4
Const TM_MULTILEVELUNDO=8	' Default behavior 
Const TM_SINGLECODEPAGE=16
Const TM_MULTICODEPAGE=32	' Default behavior 

Const EM_AUTOURLDETECT=WM_USER+91
Const EM_GETAUTOURLDETECT=WM_USER+92
Const EM_SETPALETTE=WM_USER+93
Const EM_GETTEXTEX=WM_USER+94
Const EM_GETTEXTLENGTHEX=WM_USER+95
Const EM_SHOWSCROLLBAR=WM_USER+96
Const EM_SETTEXTEX=WM_USER+97
' East Asia specific messages 
Const EM_SETPUNCTUATION=WM_USER+100
Const EM_GETPUNCTUATION=WM_USER+101
Const EM_SETWORDWRAPMODE=WM_USER+102
Const EM_GETWORDWRAPMODE=WM_USER+103
Const EM_SETIMECOLOR=WM_USER+104
Const EM_GETIMECOLOR=WM_USER+105
Const EM_SETIMEOPTIONS=WM_USER+106
Const EM_GETIMEOPTIONS=WM_USER+107
Const EM_CONVPOSITION	=WM_USER+108
Const EM_SETLANGOPTIONS=WM_USER+120
Const EM_GETLANGOPTIONS=WM_USER+121
Const EM_GETIMECOMPMODE=WM_USER+122
Const EM_FINDTEXTW=WM_USER+123
Const EM_FINDTEXTEXW=WM_USER+124
' RE3.0 FE messages 
Const EM_RECONVERSION=WM_USER+125
Const EM_SETIMEMODEBIAS=WM_USER+126	
Const EM_GETIMEMODEBIAS=WM_USER+127
' BiDi specific messages 
Const EM_SETBIDIOPTIONS=WM_USER+200
Const EM_GETBIDIOPTIONS=WM_USER+201
Const EM_SETTYPOGRAPHYOPTIONS=WM_USER+202
Const EM_GETTYPOGRAPHYOPTIONS=WM_USER+203
' Extended edit style specific messages 
Const EM_SETEDITSTYLE=WM_USER+204
Const EM_GETEDITSTYLE=WM_USER+205
EndRem

Const GTL_DEFAULT=0	' Do default (return # of chars		
Const GTL_USECRLF=1	' Compute answer using CRLFs for paragraphs
Const GTL_PRECISE=2	' Compute a precise answer					
Const GTL_CLOSE=4		' Fast computation of a "close" answer		
Const GTL_NUMCHARS=8	' Return number of characters			
Const GTL_NUMBYTES=16	' Return number of _bytes_				

Const EM_GETSEL=$B0
Const EM_SETSEL=$B1
Const EM_GETRECT=$B2
Const EM_SETRECT=$B3
Const EM_SETRECTNP=$B4
Const EM_SCROLL=$B5
Const EM_LINESCROLL=$B6

Const EM_SCROLLCARET=$B7
Const EM_GETMODIFY=$B8
Const EM_SETMODIFY=$B9
Const EM_GETLINECOUNT=$BA
Const EM_LINEINDEX=$BB
Const EM_SETHANDLE=$BC
Const EM_GETHANDLE=$BD
Const EM_GETTHUMB=$BE
Const EM_LINELENGTH=$C1
Const EM_REPLACESEL=$C2
Const EM_GETLINE=$C4
Const EM_LIMITTEXT=$C5
Const EM_CANUNDO=$C6
Const EM_UNDO=$C7
Const EM_FMTLINES=$C8
Const EM_LINEFROMCHAR=$C9
Const EM_SETTABSTOPS=$CB
Const EM_SETPASSWORDCHAR=$CC
Const EM_EMPTYUNDOBUFFER=$CD
Const EM_GETFIRSTVISIBLELINE=$CE
Const EM_SETREADONLY=$CF
Const EM_SETWORDBREAKPROC=$D0
Const EM_GETWORDBREAKPROC=$D1
Const EM_GETPASSWORDCHAR=$D2

Const EM_SETMARGINS=$D3
Const EM_GETMARGINS=$D4
Const EM_SETLIMITTEXT=EM_LIMITTEXT
Const EM_GETLIMITTEXT=$D5
Const EM_POSFROMCHAR=$D6
Const EM_CHARFROMPOS=$D7

Const EM_SETIMESTATUS=$D8
Const EM_GETIMESTATUS=$D9

Const EM_CANPASTE=WM_USER+50
Const EM_DISPLAYBAND=WM_USER+51
Const EM_EXGETSEL=WM_USER+52
Const EM_EXLIMITTEXT=WM_USER+53
Const EM_EXLINEFROMCHAR=WM_USER+54
Const EM_EXSETSEL=WM_USER+55
Const EM_FINDTEXT=WM_USER+56
Const EM_FORMATRANGE=WM_USER+57
Const EM_GETCHARFORMAT=WM_USER+58
Const EM_GETEVENTMASK=WM_USER+59
Const EM_GETOLEINTERFACE=WM_USER+60
Const EM_GETPARAFORMAT=WM_USER+61
Const EM_GETSELTEXT=WM_USER+62
Const EM_HIDESELECTION=WM_USER+63
Const EM_PASTESPECIAL=WM_USER+64
Const EM_REQUESTRESIZE=WM_USER+65
Const EM_SELECTIONTYPE=WM_USER+66
Const EM_SETBKGNDCOLOR=WM_USER+67
Const EM_SETCHARFORMAT=WM_USER+68
Const EM_SETEVENTMASK=WM_USER+69
Const EM_SETOLECALLBACK=WM_USER+70
Const EM_SETPARAFORMAT=WM_USER+71
Const EM_SETTARGETDEVICE=WM_USER+72
Const EM_STREAMIN=WM_USER+73
Const EM_STREAMOUT=WM_USER+74
Const EM_GETTEXTRANGE=WM_USER+75
Const EM_FINDWORDBREAK=WM_USER+76
Const EM_SETOPTIONS=WM_USER+77
Const EM_GETOPTIONS=WM_USER+78
Const EM_FINDTEXTEX=WM_USER+79
Const EM_GETWORDBREAKPROCEX=WM_USER+80
Const EM_SETWORDBREAKPROCEX=WM_USER+81
Const EM_SETUNDOLIMIT=WM_USER+82
Const EM_REDO=WM_USER+84
Const EM_CANREDO=WM_USER+85
Const EM_GETUNDONAME=WM_USER+86
Const EM_GETREDONAME=WM_USER+87
Const EM_STOPGROUPTYPING=WM_USER+88
Const EM_SETTEXTMODE=WM_USER+89
Const EM_GETTEXTMODE=WM_USER+90

Const TM_PLAINTEXT=1
Const TM_RICHTEXT=2			'Defaultbehavior
Const TM_SINGLELEVELUNDO=4
Const TM_MULTILEVELUNDO=8	'Defaultbehavior
Const TM_SINGLECODEPAGE=16
Const TM_MULTICODEPAGE=32	'Defaultbehavior

Const EM_AUTOURLDETECT=WM_USER+91
Const EM_GETAUTOURLDETECT=WM_USER+92
Const EM_SETPALETTE=WM_USER+93
Const EM_GETTEXTEX=WM_USER+94
Const EM_GETTEXTLENGTHEX=WM_USER+95
Const EM_SHOWSCROLLBAR=WM_USER+96
Const EM_SETTEXTEX=WM_USER+97

'EastAsiaspecificmessages
Const EM_SETPUNCTUATION=WM_USER+100
Const EM_GETPUNCTUATION=WM_USER+101
Const EM_SETWORDWRAPMODE=WM_USER+102
Const EM_GETWORDWRAPMODE=WM_USER+103
Const EM_SETIMECOLOR=WM_USER+104
Const EM_GETIMECOLOR=WM_USER+105
Const EM_SETIMEOPTIONS=WM_USER+106
Const EM_GETIMEOPTIONS=WM_USER+107
Const EM_CONVPOSITION=WM_USER+108

Const EM_SETLANGOPTIONS=WM_USER+120
Const EM_GETLANGOPTIONS=WM_USER+121
Const EM_GETIMECOMPMODE=WM_USER+122

Const EM_FINDTEXTW=WM_USER+123
Const EM_FINDTEXTEXW=WM_USER+124

'RE3.0FEmessages
Const EM_RECONVERSION=WM_USER+125
Const EM_SETIMEMODEBIAS=WM_USER+126
Const EM_GETIMEMODEBIAS=WM_USER+127

'BiDispecificmessages
Const EM_SETBIDIOPTIONS=WM_USER+200
Const EM_GETBIDIOPTIONS=WM_USER+201

Const EM_SETTYPOGRAPHYOPTIONS=WM_USER+202
Const EM_GETTYPOGRAPHYOPTIONS=WM_USER+203

'Extendededitstylespecificmessages
Const EM_SETEDITSTYLE=WM_USER+204
Const EM_GETEDITSTYLE=WM_USER+205

Const SCF_SELECTION=1
Const SCF_WORD=2
Const SCF_DEFAULT=0
Const SCF_ALL=4
Const SCF_USEUIRULES=8
Const SCF_ASSOCIATEFONT=16
Const SCF_NOKBUPDATE=32
Const SCF_ASSOCIATEFONT2=64

Const CFE_BOLD=1
Const CFE_ITALIC=2
Const CFE_UNDERLINE=4
Const CFE_STRIKEOUT=8
Const CFE_PROTECTED=16
Const CFE_LINK=32
Const CFE_AUTOCOLOR=$40000000

Const CFM_BOLD=1
Const CFM_ITALIC=2
Const CFM_UNDERLINE=4
Const CFM_STRIKEOUT=8
Const CFM_PROTECTED=16
Const CFM_LINK=32
Const CFM_SIZE=$80000000
Const CFM_COLOR=$40000000
Const CFM_FACE=$20000000
Const CFM_OFFSET=$10000000
Const CFM_CHARSET=$08000000

Const SF_TEXT=1
Const SF_RTF=2
Const SF_RTFNOOBJS=3
Const SF_TEXTIZED=4
Const SF_UNICODE=$10
Const SF_USECODEPAGE=$20
Const SF_NCRFORNONASCII=$40
Const SF_RTFVAL=$700

Const SFF_WRITEXTRAPAR=$80
Const SFF_SELECTION=$8000
Const SFF_PLAINRTF=$4000
Const SFF_PERSISTVIEWSCALE=$2000
Const SFF_KEEPDOCINFO=$1000
Const SFF_PWD=$800

Const PFM_STARTINDENT=1
Const PFM_RIGHTINDENT=2
Const PFM_OFFSET=4
Const PFM_ALIGNMENT=8
Const PFM_TABSTOPS=16
Const PFM_NUMBERING=32
Const PFM_OFFSETINDENT=$80000000

Const PFM_SPACEBEFORE=$40
Const PFM_SPACEAFTER=$80
Const PFM_LINESPACING=$100
Const PFM_STYLE=$400
Const PFM_BORDER=$800	
Const PFM_SHADING=$1000	
Const PFM_NUMBERINGSTYLE=$2000	
Const PFM_NUMBERINGTAB=$4000	
Const PFM_NUMBERINGSTART=$8000	

Const PFM_RTLPARA=$10000
Const PFM_KEEP=$20000	
Const PFM_KEEPNEXT=$40000	
Const PFM_PAGEBREAKBEFORE=$80000	
Const PFM_NOLINENUMBER=$100000	
Const PFM_NOWIDOWCONTROL=$200000	
Const PFM_DONOTHYPHEN=$400000	
Const PFM_SIDEBYSIDE=$800000	
Const PFM_TABLE=$40000000 
Const PFM_TEXTWRAPPINGBREAK=$20000000 
Const PFM_TABLEROWDELIMITER=$10000000 

Const PFM_COLLAPSED=$1000000
Const PFM_OUTLINELEVEL=$2000000
Const PFM_BOX=$4000000 
Const PFM_RESERVED2=$8000000

Const MAX_TAB_STOPS=32
Const lDefaultTab=720
Const MAX_TABLE_CELLS=63

Type EDITSTREAM
	Field	dwCookie:Byte Ptr Ptr
	Field	dwError
	Field	pfnCallback(cookie:Byte Ptr Ptr,buff:Byte Ptr,n,n_out:Int Ptr) "win32"
End Type

Type TEXTRANGEW
	Field	cpMin
	Field	cpMax
	Field	lpStrText:Short Ptr
End Type

Type CHARRANGE
	Field	cpMin
	Field	cpMax
End Type

Type CHARFORMATW
	Field	cbSize
	Field	dwMask
	Field	dwEffects
	Field	yHeight
	Field	yOffset
	Field	crTextColor
	Field	bCharSet:Byte
	Field	bPitchAndFamily:Byte
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
	Field	pad:Short
End Type

Type CHARFORMAT
	Field cbSize
	Field dwMask
	Field dwEffects
	Field yHeight
	Field yOffset
	Field crTextColor
	Field bCharSet:Byte
	Field bPitchAndFamily:Byte
	Field lfFaceName00:Byte
	Field lfFaceName01:Byte
	Field lfFaceName02:Byte
	Field lfFaceName03:Byte
	Field lfFaceName04:Byte
	Field lfFaceName05:Byte
	Field lfFaceName06:Byte
	Field lfFaceName07:Byte
	Field lfFaceName08:Byte
	Field lfFaceName09:Byte
	Field lfFaceName0a:Byte
	Field lfFaceName0b:Byte
	Field lfFaceName0c:Byte
	Field lfFaceName0d:Byte
	Field lfFaceName0e:Byte
	Field lfFaceName0f:Byte
	Field lfFaceName10:Byte
	Field lfFaceName11:Byte
	Field lfFaceName12:Byte
	Field lfFaceName13:Byte
	Field lfFaceName14:Byte
	Field lfFaceName15:Byte
	Field lfFaceName16:Byte
	Field lfFaceName17:Byte
	Field lfFaceName18:Byte
	Field lfFaceName19:Byte
	Field lfFaceName1a:Byte
	Field lfFaceName1b:Byte
	Field lfFaceName1c:Byte
	Field lfFaceName1d:Byte
	Field lfFaceName1e:Byte
	Field lfFaceName1f:Byte
	Field pad:Short
End Type

Type PARAFORMAT
	Field	cbSize
	Field	dwMask
	Field	wNumbering:Short
	Field	wEffects:Short
	Field	dxStartIndent
	Field	dxRightIndent
	Field	dxOffset
	Field	wAlignment:Short
	Field	cTabCount:Short
	Field	rgxTabs00,rgxTabs01,rgxTabs02,rgxTabs03
	Field	rgxTabs10,rgxTabs11,rgxTabs12,rgxTabs13
	Field	rgxTabs20,rgxTabs21,rgxTabs22,rgxTabs23
	Field	rgxTabs30,rgxTabs31,rgxTabs32,rgxTabs33
	Field	rgxTabs40,rgxTabs41,rgxTabs42,rgxTabs43
	Field	rgxTabs50,rgxTabs51,rgxTabs52,rgxTabs53
	Field	rgxTabs60,rgxTabs61,rgxTabs62,rgxTabs63
	Field	rgxTabs70,rgxTabs71,rgxTabs72,rgxTabs73
End Type


Rem
/*
 *	RICHEDIT.H
 *	
 *	Purpose:
 *		RICHEDIT v2.0/3.0/4.0 public definitions
 *		functionality available for v2.0 and 3.0 that is not in the original
 *		Windows 95 release.
 *	
 *	Copyright (c Microsoft Corporation. All rights reserved.
 */

#ifndef _RICHEDIT_
const	_RICHEDIT_

#ifdef _WIN32
#include <pshpack4.h>
#elif !defined(RC_INVOKED
#pragma pack(4
#endif

#ifdef __cplusplus
extern "C" {
#endif ' __cplusplus

' To mimic older RichEdit behavior, set _RICHEDIT_VER to appropriate value
'		Version 1.0		=$0100	
'		Version 2.0		=$0200	
'		Version 2.1		=$0210	
#ifndef _RICHEDIT_VER
const _RICHEDIT_VER	=$0300
#endif

const cchTextLimitDefault 32767

const MSFTEDIT_CLASS		L"RICHEDIT50W"
' NOTE:MSFTEDIT.DLL only registers MSFTEDIT_CLASS.If an application wants
' to use the following Richedit classes, it needs to load the riched20.dll.
' Otherwise, CreateWindow with RICHEDIT_CLASS would fail.
' This also applies to any dialog that uses RICHEDIT_CLASS, 

' RichEdit 2.0 Window Class 
' On Windows CE, avoid possible conflicts on Win95
const CERICHEDIT_CLASSA	"RichEditCEA"
const CERICHEDIT_CLASSW	L"RichEditCEW"

const RICHEDIT_CLASSA		"RichEdit20A"
const RICHEDIT_CLASS10A	"RICHEDIT"			' Richedit 1.0

#ifndef MACPORT
const RICHEDIT_CLASSW		L"RichEdit20W"
#else	'----------------------MACPORT 
const RICHEDIT_CLASSW		TEXT("RichEdit20W"	' MACPORT change 
#endif ' MACPORT

#if (_RICHEDIT_VER >==$0200 
#ifdef UNICODE
const RICHEDIT_CLASS		RICHEDIT_CLASSW
#else
const RICHEDIT_CLASS		RICHEDIT_CLASSA
#endif ' UNICODE 
#else
const RICHEDIT_CLASS		RICHEDIT_CLASS10A
#endif ' _RICHEDIT_VER >==$0200 

' RichEdit messages 

#ifndef WM_CONTEXTMENU
const WM_CONTEXTMENU			=$007B
#endif

#ifndef WM_UNICHAR
const WM_UNICHAR				=$0109
#endif

#ifndef WM_PRINTCLIENT
const WM_PRINTCLIENT			=$0318
#endif

#ifndef EM_GETLIMITTEXT
const EM_GETLIMITTEXT			=WM_USER+37
#endif

#ifndef EM_POSFROMCHAR	
const EM_POSFROMCHAR			=WM_USER+38
const EM_CHARFROMPOS			=WM_USER+39
#endif

#ifndef EM_SCROLLCARET
const EM_SCROLLCARET			=WM_USER+49
#endif
const EM_CANPASTE				=WM_USER+50
const EM_DISPLAYBAND			=WM_USER+51
const EM_EXGETSEL				=WM_USER+52
const EM_EXLIMITTEXT			=WM_USER+53
const EM_EXLINEFROMCHAR		=WM_USER+54
const EM_EXSETSEL				=WM_USER+55
const EM_FINDTEXT				=WM_USER+56
const EM_FORMATRANGE			=WM_USER+57
const EM_GETCHARFORMAT		=WM_USER+58
const EM_GETEVENTMASK			=WM_USER+59
const EM_GETOLEINTERFACE		=WM_USER+60
const EM_GETPARAFORMAT		=WM_USER+61
const EM_GETSELTEXT			=WM_USER+62
const EM_HIDESELECTION		=WM_USER+63
const EM_PASTESPECIAL			=WM_USER+64
const EM_REQUESTRESIZE		=WM_USER+65
const EM_SELECTIONTYPE		=WM_USER+66
const EM_SETBKGNDCOLOR		=WM_USER+67
const EM_SETCHARFORMAT		=WM_USER+68
const EM_SETEVENTMASK			=WM_USER+69
const EM_SETOLECALLBACK		=WM_USER+70
const EM_SETPARAFORMAT		=WM_USER+71
const EM_SETTARGETDEVICE		=WM_USER+72
const EM_STREAMIN				=WM_USER+73
const EM_STREAMOUT			=WM_USER+74
const EM_GETTEXTRANGE			=WM_USER+75
const EM_FINDWORDBREAK		=WM_USER+76
const EM_SETOPTIONS			=WM_USER+77
const EM_GETOPTIONS			=WM_USER+78
const EM_FINDTEXTEX			=WM_USER+79
#ifdef _WIN32
const EM_GETWORDBREAKPROCEX	=WM_USER+80
const EM_SETWORDBREAKPROCEX	=WM_USER+81
#endif

' RichEdit 2.0 messages 
const	EM_SETUNDOLIMIT			=WM_USER+82
const EM_REDO					=WM_USER+84
const EM_CANREDO				=WM_USER+85
const EM_GETUNDONAME			=WM_USER+86
const EM_GETREDONAME			=WM_USER+87
const EM_STOPGROUPTYPING		=WM_USER+88

const EM_SETTEXTMODE			=WM_USER+89
const EM_GETTEXTMODE			=WM_USER+90

' enum for use with EM_GET/SETTEXTMODE 
typedef enum tagTextMode
{
	TM_PLAINTEXT			=1,
	TM_RICHTEXT				=2,	' Default behavior 
	TM_SINGLELEVELUNDO		=4,
	TM_MULTILEVELUNDO		=8,	' Default behavior 
	TM_SINGLECODEPAGE		=16,
	TM_MULTICODEPAGE		=32	' Default behavior 
} TEXTMODE;

const EM_AUTOURLDETECT		=WM_USER+91
const EM_GETAUTOURLDETECT		=WM_USER+92
const EM_SETPALETTE			=WM_USER+93
const EM_GETTEXTEX			=WM_USER+94
const EM_GETTEXTLENGTHEX		=WM_USER+95
const EM_SHOWSCROLLBAR		=WM_USER+96
const EM_SETTEXTEX			=WM_USER+97

' East Asia specific messages 
const EM_SETPUNCTUATION		=WM_USER+100
const EM_GETPUNCTUATION		=WM_USER+101
const EM_SETWORDWRAPMODE		=WM_USER+102
const EM_GETWORDWRAPMODE		=WM_USER+103
const EM_SETIMECOLOR			=WM_USER+104
const EM_GETIMECOLOR			=WM_USER+105
const EM_SETIMEOPTIONS		=WM_USER+106
const EM_GETIMEOPTIONS		=WM_USER+107
const EM_CONVPOSITION 		=WM_USER+108

const EM_SETLANGOPTIONS		=WM_USER+120
const EM_GETLANGOPTIONS		=WM_USER+121
const EM_GETIMECOMPMODE		=WM_USER+122

const EM_FINDTEXTW			=WM_USER+123
const EM_FINDTEXTEXW			=WM_USER+124

' RE3.0 FE messages 
const EM_RECONVERSION			=WM_USER+125
const EM_SETIMEMODEBIAS		=WM_USER+126	
const EM_GETIMEMODEBIAS		=WM_USER+127

' BiDi specific messages 
const EM_SETBIDIOPTIONS		=WM_USER+200
const EM_GETBIDIOPTIONS		=WM_USER+201

const EM_SETTYPOGRAPHYOPTIONS	=WM_USER+202
const EM_GETTYPOGRAPHYOPTIONS	=WM_USER+203

' Extended edit style specific messages 
const EM_SETEDITSTYLE			=WM_USER+204
const EM_GETEDITSTYLE			=WM_USER+205

' Extended edit style masks 
const	SES_EMULATESYSEDIT		1
const SES_BEEPONMAXTEXT		2
const	SES_EXTENDBACKCOLOR		4
const SES_MAPCPS				8
const SES_EMULATE10			16
const	SES_USECRLF				32
const SES_USEAIMM				64
const SES_NOIME				128

const SES_ALLOWBEEPS			256
const SES_UPPERCASE			512
const	SES_LOWERCASE			1024
const SES_NOINPUTSEQUENCECHK	2048
const SES_BIDI				4096
const SES_SCROLLONKILLFOCUS	8192
const	SES_XLTCRCRLFTOCR		16384
const SES_DRAFTMODE			32768

const	SES_USECTF				=$0010000
const SES_HIDEGRIDLINES		=$0020000
const SES_USEATFONT			=$0040000
const SES_CUSTOMLOOK			=$0080000
const SES_LBSCROLLNOTIFY		=$0100000
const SES_CTFALLOWEMBED		=$0200000
const SES_CTFALLOWSMARTTAG	=$0400000
const SES_CTFALLOWPROOFING	=$0800000

' Options for EM_SETLANGOPTIONS and EM_GETLANGOPTIONS 
const IMF_AUTOKEYBOARD		=$0001
const IMF_AUTOFONT			=$0002
const IMF_IMECANCELCOMPLETE	=$0004	' High completes comp string when aborting, low cancels
const IMF_IMEALWAYSSENDNOTIFY =$0008
const IMF_AUTOFONTSIZEADJUST	=$0010
const IMF_UIFONTS				=$0020
const IMF_DUALFONT			=$0080

' Values for EM_GETIMECOMPMODE 
const ICM_NOTOPEN				=$0000
const ICM_LEVEL3				=$0001
const ICM_LEVEL2				=$0002
const ICM_LEVEL2_5			=$0003
const ICM_LEVEL2_SUI			=$0004
const ICM_CTF					=$0005

' Options for EM_SETTYPOGRAPHYOPTIONS 
const	TO_ADVANCEDTYPOGRAPHY	1
const	TO_SIMPLELINEBREAK		2
const TO_DISABLECUSTOMTEXTOUT	4
const TO_ADVANCEDLAYOUT		8

' Pegasus outline mode messages (RE 3.0 

' Outline mode message
const EM_OUTLINE=WM_USER+220
' Message for getting and restoring scroll pos
const EM_GETSCROLLPOS =WM_USER+221
const EM_SETSCROLLPOS =WM_USER+222
' Change fontsize in current selection by wParam
const EM_SETFONTSIZE=WM_USER+223
const EM_GETZOOM				=WM_USER+224
const EM_SETZOOM				=WM_USER+225
const EM_GETVIEWKIND			=WM_USER+226
const EM_SETVIEWKIND			=WM_USER+227

' RichEdit 4.0 messages
const EM_GETPAGE				=WM_USER+228
const EM_SETPAGE				=WM_USER+229
const EM_GETHYPHENATEINFO		=WM_USER+230
const EM_SETHYPHENATEINFO		=WM_USER+231
const EM_GETPAGEROTATE		=WM_USER+235
const EM_SETPAGEROTATE		=WM_USER+236
const EM_GETCTFMODEBIAS		=WM_USER+237
const EM_SETCTFMODEBIAS		=WM_USER+238
const EM_GETCTFOPENSTATUS		=WM_USER+240
const EM_SETCTFOPENSTATUS		=WM_USER+241
const EM_GETIMECOMPTEXT		=WM_USER+242
const EM_ISIME				=WM_USER+243
const EM_GETIMEPROPERTY		=WM_USER+244

' These messages control what rich edit does when it comes accross
' OLE objects during RTF stream in.Normally rich edit queries the client
' application only after OleLoad has been called.With these messages it is possible to
' set the rich edit control to a mode where it will query the client application before
' OleLoad is called
const EM_GETQUERYRTFOBJ		=WM_USER+269
const EM_SETQUERYRTFOBJ		=WM_USER+270

' EM_SETPAGEROTATE wparam values
const EPR_0					0		' Text flows left to right and top to bottom
const EPR_270					1		' Text flows top to bottom and right to left
const EPR_180					2		' Text flows right to left and bottom to top
const	EPR_90					3		' Text flows bottom to top and left to right

' EM_SETCTFMODEBIAS wparam values
const CTFMODEBIAS_DEFAULT					=$0000
const CTFMODEBIAS_FILENAME				=$0001
const CTFMODEBIAS_NAME					=$0002
const CTFMODEBIAS_READING					=$0003
const CTFMODEBIAS_DATETIME				=$0004
const CTFMODEBIAS_CONVERSATION			=$0005
const CTFMODEBIAS_NUMERIC					=$0006
const CTFMODEBIAS_HIRAGANA				=$0007
const CTFMODEBIAS_KATAKANA				=$0008
const CTFMODEBIAS_HANGUL					=$0009
const CTFMODEBIAS_HALFWIDTHKATAKANA		=$000A
const CTFMODEBIAS_FULLWIDTHALPHANUMERIC	=$000B
const CTFMODEBIAS_HALFWIDTHALPHANUMERIC	=$000C

' EM_SETIMEMODEBIAS lparam values
const IMF_SMODE_PLAURALCLAUSE	=$0001
const IMF_SMODE_NONE			=$0002

' EM_GETIMECOMPTEXT wparam structure
typedef struct _imecomptext {
	LONG	cb;			' count of bytes in the output buffer.
	DWORD	flags;		' value specifying the composition string type.
						'	Currently only support ICT_RESULTREADSTR
} IMECOMPTEXT;
const ICT_RESULTREADSTR		1

' Outline mode wparam values
const EMO_EXIT0 ' Enter normal mode,lparam ignored
const EMO_ENTER 1 ' Enter outline mode, lparam ignored
const EMO_PROMOTE 2 ' LOWORD(lparam ==0 ==>
'promoteto body-text
' LOWORD(lparam !=0 ==>
'promote/demote current selection
'by indicated number of levels
const EMO_EXPAND3 ' HIWORD(lparam =EMO_EXPANDSELECTION
'-> expands selection to level
'indicated in LOWORD(lparam
'LOWORD(lparam =-1/+1 corresponds
'to collapse/expand button presses
'in winword (other values are
'equivalent to having pressed these
'buttons more than once
'HIWORD(lparam =EMO_EXPANDDOCUMENT
'-> expands whole document to
'indicated level
const EMO_MOVESELECTION 4 ' LOWORD(lparam !=0 -> move current
'selection up/down by indicated amount
const EMO_GETVIEWMODE			5		' Returns VM_NORMAL or VM_OUTLINE

' EMO_EXPAND options
const EMO_EXPANDSELECTION 0
const EMO_EXPANDDOCUMENT1

const VM_NORMAL				4		' Agrees with RTF \viewkindN
const VM_OUTLINE				2
const VM_PAGE					9		' Screen page view (not print layout

' New notifications 
const EN_MSGFILTER			=$0700
const EN_REQUESTRESIZE		=$0701
const EN_SELCHANGE			=$0702
const EN_DROPFILES			=$0703
const EN_PROTECTED			=$0704
const EN_CORRECTTEXT			=$0705			' PenWin specific 
const EN_STOPNOUNDO			=$0706
const EN_IMECHANGE			=$0707			' East Asia specific 
const EN_SAVECLIPBOARD		=$0708
const EN_OLEOPFAILED			=$0709
const EN_OBJECTPOSITIONS		=$070a
const EN_LINK					=$070b
const EN_DRAGDROPDONE			=$070c
const EN_PARAGRAPHEXPANDED	=$070d
const EN_PAGECHANGE			=$070e
const EN_LOWFIRTF				=$070f
const EN_ALIGNLTR				=$0710			' BiDi specific notification
const EN_ALIGNRTL				=$0711			' BiDi specific notification

' Event notification masks 
const ENM_NONE				=$00000000
const ENM_CHANGE				=$00000001
const ENM_UPDATE				=$00000002
const ENM_SCROLL				=$00000004
const ENM_SCROLLEVENTS		=$00000008
const ENM_DRAGDROPDONE		=$00000010
const ENM_PARAGRAPHEXPANDED	=$00000020
const ENM_PAGECHANGE			=$00000040
const ENM_KEYEVENTS			=$00010000
const ENM_MOUSEEVENTS			=$00020000
const ENM_REQUESTRESIZE		=$00040000
const ENM_SELCHANGE			=$00080000
const ENM_DROPFILES			=$00100000
const ENM_PROTECTED			=$00200000
const ENM_CORRECTTEXT			=$00400000		' PenWin specific 
const ENM_IMECHANGE			=$00800000		' Used by RE1.0 compatibility
const ENM_LANGCHANGE			=$01000000
const ENM_OBJECTPOSITIONS		=$02000000
const ENM_LINK				=$04000000
const ENM_LOWFIRTF			=$08000000


' New edit control styles 
const ES_SAVESEL				=$00008000
const ES_SUNKEN				=$00004000
const ES_DISABLENOSCROLL		=$00002000
' Same as WS_MAXIMIZE, but that doesn't make sense so we re-use the value 
const ES_SELECTIONBAR			=$01000000
' Same as ES_UPPERCASE, but re-used to completely disable OLE drag'n'drop 
const ES_NOOLEDRAGDROP		=$00000008

' New edit control extended style 
#if (_WIN32_WINNT > =$0400 || (WINVER > =$0400
const ES_EX_NOCALLOLEINIT		=$00000000		' Not supported in RE 2.0/3.0 
#else
#ifdef	_WIN32
const ES_EX_NOCALLOLEINIT		=$01000000
#endif	
#endif

' These flags are used in FE Windows 
const ES_VERTICAL				=$00400000		' Not supported in RE 2.0/3.0 
const	ES_NOIME				=$00080000
const ES_SELFIME				=$00040000

' Edit control options 
const ECO_AUTOWORDSELECTION	=$00000001
const ECO_AUTOVSCROLL			=$00000040
const ECO_AUTOHSCROLL			=$00000080
const ECO_NOHIDESEL			=$00000100
const ECO_READONLY			=$00000800
const ECO_WANTRETURN			=$00001000
const ECO_SAVESEL				=$00008000
const ECO_SELECTIONBAR		=$01000000
const ECO_VERTICAL			=$00400000		' FE specific 


' ECO operations 
const ECOOP_SET				=$0001
const ECOOP_OR				=$0002
const ECOOP_AND				=$0003
const ECOOP_XOR				=$0004

' New word break function actions 
const WB_CLASSIFY			3
const WB_MOVEWORDLEFT		4
const WB_MOVEWORDRIGHT	5
const WB_LEFTBREAK		6
const WB_RIGHTBREAK		7

' East Asia specific flags 
const WB_MOVEWORDPREV		4
const WB_MOVEWORDNEXT		5
const WB_PREVBREAK		6
const WB_NEXTBREAK		7

const PC_FOLLOWING		1
const	PC_LEADING			2
const	PC_OVERFLOW			3
const	PC_DELIMITER		4
const WBF_WORDWRAP		=$010
const WBF_WORDBREAK		=$020
const	WBF_OVERFLOW		=$040	
const WBF_LEVEL1			=$080
const	WBF_LEVEL2			=$100
const	WBF_CUSTOM			=$200

' East Asia specific flags 
const IMF_FORCENONE =$0001
const IMF_FORCEENABLE =$0002
const IMF_FORCEDISABLE=$0004
const IMF_CLOSESTATUSWINDOW =$0008
const IMF_VERTICAL=$0020
const IMF_FORCEACTIVE =$0040
const IMF_FORCEINACTIVE =$0080
const IMF_FORCEREMEMBER =$0100
const IMF_MULTIPLEEDIT=$0400

' Word break flags (used with WB_CLASSIFY 
const WBF_CLASS			((BYTE =$0F
const WBF_ISWHITE			((BYTE =$10
const WBF_BREAKLINE		((BYTE =$20
const WBF_BREAKAFTER		((BYTE =$40


' Data types 

#ifdef _WIN32
' Extended edit word break proc (character set aware 
typedef LONG (*EDITWORDBREAKPROCEX(char *pchText, LONG cchText, BYTE bCharSet, INT action;
#endif

' All character format measurements are in twips 
typedef struct _charformat
{
	UINT		cbSize;
	DWORD		dwMask;
	DWORD		dwEffects;
	LONG		yHeight;
	LONG		yOffset;
	COLORREF	crTextColor;
	BYTE		bCharSet;
	BYTE		bPitchAndFamily;
	char		szFaceName[LF_FACESIZE];
} CHARFORMATA;

typedef struct _charformatw
{
	UINT		cbSize;
	DWORD		dwMask;
	DWORD		dwEffects;
	LONG		yHeight;
	LONG		yOffset;
	COLORREF	crTextColor;
	BYTE		bCharSet;
	BYTE		bPitchAndFamily;
	WCHAR		szFaceName[LF_FACESIZE];
} CHARFORMATW;

#if (_RICHEDIT_VER >==$0200
#ifdef UNICODE
const CHARFORMAT CHARFORMATW
#else
const CHARFORMAT CHARFORMATA
#endif ' UNICODE 
#else
const CHARFORMAT CHARFORMATA
#endif ' _RICHEDIT_VER >==$0200 

' CHARFORMAT2 structure 

#ifdef __cplusplus

struct CHARFORMAT2W : _charformatw
{
	WORD		wWeight;			' Font weight (LOGFONT value
	SHORT		sSpacing;			' Amount to space between letters
	COLORREF	crBackColor;		' Background color
	LCID		lcid;				' Locale ID
	DWORD		dwReserved;			' Reserved. Must be 0
	SHORT		sStyle;				' Style handle
	WORD		wKerning;			' Twip size above which to kern char pair
	BYTE		bUnderlineType;		' Underline type
	BYTE		bAnimation;			' Animated text like marching ants
	BYTE		bRevAuthor;			' Revision author index
};

struct CHARFORMAT2A : _charformat
{
	WORD		wWeight;			' Font weight (LOGFONT value
	SHORT		sSpacing;			' Amount to space between letters
	COLORREF	crBackColor;		' Background color
	LCID		lcid;				' Locale ID
	DWORD		dwReserved;			' Reserved. Must be 0
	SHORT		sStyle;				' Style handle
	WORD		wKerning;			' Twip size above which to kern char pair
	BYTE		bUnderlineType;		' Underline type
	BYTE		bAnimation;			' Animated text like marching ants
	BYTE		bRevAuthor;			' Revision author index
};

#else	' regular C-style

typedef struct _charformat2w
{
	UINT		cbSize;
	DWORD		dwMask;
	DWORD		dwEffects;
	LONG		yHeight;
	LONG		yOffset;			' > 0 for superscript, < 0 for subscript 
	COLORREF	crTextColor;
	BYTE		bCharSet;
	BYTE		bPitchAndFamily;
	WCHAR		szFaceName[LF_FACESIZE];
	WORD		wWeight;			' Font weight (LOGFONT value		
	SHORT		sSpacing;			' Amount to space between letters	
	COLORREF	crBackColor;		' Background color					
	LCID		lcid;				' Locale ID						
	DWORD		dwReserved;			' Reserved. Must be 0				
	SHORT		sStyle;				' Style handle						
	WORD		wKerning;			' Twip size above which to kern char pair
	BYTE		bUnderlineType;		' Underline type					
	BYTE		bAnimation;			' Animated text like marching ants	
	BYTE		bRevAuthor;			' Revision author index			
	BYTE		bReserved1;
} CHARFORMAT2W;

typedef struct _charformat2a
{
	UINT		cbSize;
	DWORD		dwMask;
	DWORD		dwEffects;
	LONG		yHeight;
	LONG		yOffset;			' > 0 for superscript, < 0 for subscript 
	COLORREF	crTextColor;
	BYTE		bCharSet;
	BYTE		bPitchAndFamily;
	char		szFaceName[LF_FACESIZE];
	WORD		wWeight;			' Font weight (LOGFONT value		
	SHORT		sSpacing;			' Amount to space between letters	
	COLORREF	crBackColor;		' Background color					
	LCID		lcid;				' Locale ID						
	DWORD		dwReserved;			' Reserved. Must be 0				
	SHORT		sStyle;				' Style handle						
	WORD		wKerning;			' Twip size above which to kern char pair
	BYTE		bUnderlineType;		' Underline type					
	BYTE		bAnimation;			' Animated text like marching ants	
	BYTE		bRevAuthor;			' Revision author index			
} CHARFORMAT2A;

#endif ' C++ 

#ifdef UNICODE
const CHARFORMAT2	CHARFORMAT2W
#else
const CHARFORMAT2 CHARFORMAT2A
#endif

const CHARFORMATDELTA		(sizeof(CHARFORMAT2 - sizeof(CHARFORMAT


' CFM_COLOR mirrors CFE_AUTOCOLOR, a little hack to easily deal with autocolor

' CHARFORMAT masks 
const CFM_BOLD		=$00000001
const CFM_ITALIC		=$00000002
const CFM_UNDERLINE	=$00000004
const CFM_STRIKEOUT	=$00000008
const CFM_PROTECTED	=$00000010
const CFM_LINK		=$00000020			' Exchange hyperlink extension 
const CFM_SIZE		=$80000000
const CFM_COLOR		=$40000000
const CFM_FACE		=$20000000
const CFM_OFFSET		=$10000000
const CFM_CHARSET		=$08000000

' CHARFORMAT effects 
const CFE_BOLD		=$0001
const CFE_ITALIC		=$0002
const CFE_UNDERLINE	=$0004
const CFE_STRIKEOUT	=$0008
const CFE_PROTECTED	=$0010
const CFE_LINK		=$0020
const CFE_AUTOCOLOR	=$40000000			' NOTE: this corresponds to 
											' CFM_COLOR, which controls it 
' Masks and effects defined for CHARFORMAT2 -- an (* indicates
' that the data is stored by RichEdit 2.0/3.0, but not displayed
const CFM_SMALLCAPS		=$0040			' (*	
const	CFM_ALLCAPS			=$0080			' Displayed by 3.0	
const	CFM_HIDDEN			=$0100			' Hidden by 3.0 
const	CFM_OUTLINE			=$0200			' (*	
const	CFM_SHADOW			=$0400			' (*	
const	CFM_EMBOSS			=$0800			' (*	
const	CFM_IMPRINT			=$1000			' (*	
const CFM_DISABLED		=$2000
const	CFM_REVISED			=$4000

const CFM_BACKCOLOR		=$04000000
const CFM_LCID			=$02000000
const	CFM_UNDERLINETYPE	=$00800000		' Many displayed by 3.0 
const	CFM_WEIGHT			=$00400000
const CFM_SPACING			=$00200000		' Displayed by 3.0	
const CFM_KERNING			=$00100000		' (*	
const CFM_STYLE			=$00080000		' (*	
const CFM_ANIMATION		=$00040000		' (*	
const CFM_REVAUTHOR		=$00008000

const CFE_SUBSCRIPT		=$00010000		' Superscript and subscript are 
const CFE_SUPERSCRIPT		=$00020000		'mutually exclusive			 

const CFM_SUBSCRIPT		CFE_SUBSCRIPT | CFE_SUPERSCRIPT
const CFM_SUPERSCRIPT		CFM_SUBSCRIPT

' CHARFORMAT "ALL" masks
const CFM_EFFECTS (CFM_BOLD | CFM_ITALIC | CFM_UNDERLINE | CFM_COLOR | \
					 CFM_STRIKEOUT | CFE_PROTECTED | CFM_LINK
const CFM_ALL (CFM_EFFECTS | CFM_SIZE | CFM_FACE | CFM_OFFSET | CFM_CHARSET

const	CFM_EFFECTS2 (CFM_EFFECTS | CFM_DISABLED | CFM_SMALLCAPS | CFM_ALLCAPS \
					| CFM_HIDDEN| CFM_OUTLINE | CFM_SHADOW | CFM_EMBOSS \
					| CFM_IMPRINT | CFM_DISABLED | CFM_REVISED \
					| CFM_SUBSCRIPT | CFM_SUPERSCRIPT | CFM_BACKCOLOR

const CFM_ALL2	 (CFM_ALL | CFM_EFFECTS2 | CFM_BACKCOLOR | CFM_LCID \
					| CFM_UNDERLINETYPE | CFM_WEIGHT | CFM_REVAUTHOR \
					| CFM_SPACING | CFM_KERNING | CFM_STYLE | CFM_ANIMATION

const	CFE_SMALLCAPS		CFM_SMALLCAPS
const	CFE_ALLCAPS			CFM_ALLCAPS
const	CFE_HIDDEN			CFM_HIDDEN
const	CFE_OUTLINE			CFM_OUTLINE
const	CFE_SHADOW			CFM_SHADOW
const	CFE_EMBOSS			CFM_EMBOSS
const	CFE_IMPRINT			CFM_IMPRINT
const	CFE_DISABLED		CFM_DISABLED
const	CFE_REVISED			CFM_REVISED

' CFE_AUTOCOLOR and CFE_AUTOBACKCOLOR correspond to CFM_COLOR and
' CFM_BACKCOLOR, respectively, which control them
const CFE_AUTOBACKCOLOR	CFM_BACKCOLOR

' Underline types. RE 1.0 displays only CFU_UNDERLINE
const CFU_CF1UNDERLINE	=$FF	' Map charformat's bit underline to CF2
const CFU_INVERT			=$FE	' For IME composition fake a selection
const CFU_UNDERLINETHICKLONGDASH		18	' (* display as dash
const CFU_UNDERLINETHICKDOTTED		17	' (* display as dot
const CFU_UNDERLINETHICKDASHDOTDOT	16	' (* display as dash dot dot
const CFU_UNDERLINETHICKDASHDOT		15	' (* display as dash dot
const CFU_UNDERLINETHICKDASH			14	' (* display as dash
const CFU_UNDERLINELONGDASH			13	' (* display as dash
const CFU_UNDERLINEHEAVYWAVE			12	' (* display as wave
const CFU_UNDERLINEDOUBLEWAVE			11	' (* display as wave
const CFU_UNDERLINEHAIRLINE			10	' (* display as single	
const CFU_UNDERLINETHICK				9
const CFU_UNDERLINEWAVE				8
const	CFU_UNDERLINEDASHDOTDOT			7
const	CFU_UNDERLINEDASHDOT			6
const	CFU_UNDERLINEDASH				5
const	CFU_UNDERLINEDOTTED				4
const	CFU_UNDERLINEDOUBLE				3	' (* display as single
const CFU_UNDERLINEWORD				2	' (* display as single	
const CFU_UNDERLINE					1
const CFU_UNDERLINENONE				0

const yHeightCharPtsMost 1638

' EM_SETCHARFORMAT wParam masks 
const SCF_SELECTION		=$0001
const SCF_WORD			=$0002
const SCF_DEFAULT			=$0000	' Set default charformat or paraformat
const SCF_ALL				=$0004	' Not valid with SCF_SELECTION or SCF_WORD
const SCF_USEUIRULES		=$0008	' Modifier for SCF_SELECTION; says that
									'format came from a toolbar, etc., and
									'hence UI formatting rules should be
									'used instead of literal formatting
const SCF_ASSOCIATEFONT	=$0010	' Associate fontname with bCharSet (one
									'possible for each of Western, ME, FE,
									'Thai
const SCF_NOKBUPDATE		=$0020	' Do not update KB layput for this change
									'even if autokeyboard is on
const SCF_ASSOCIATEFONT2	=$0040	' Associate plane-2 (surrogate font

typedef struct _charrange
{
	LONG	cpMin;
	LONG	cpMax;
} CHARRANGE;

typedef struct _textrange
{
	CHARRANGE chrg;
	LPSTR lpstrText;	' Allocated by caller, zero terminated by RichEdit 
} TEXTRANGEA;

typedef struct _textrangew
{
	CHARRANGE chrg;
	LPWSTR lpstrText;	' Allocated by caller, zero terminated by RichEdit 
} TEXTRANGEW;

#if (_RICHEDIT_VER >==$0200
#ifdef UNICODE
const TEXTRANGE 	TEXTRANGEW
#else
const TEXTRANGE	TEXTRANGEA
#endif ' UNICODE 
#else
const TEXTRANGE	TEXTRANGEA
#endif ' _RICHEDIT_VER >==$0200 

typedef DWORD (CALLBACK *EDITSTREAMCALLBACK(DWORD_PTR dwCookie, LPBYTE pbBuff, LONG cb, LONG *pcb;

typedef struct _editstream
{
	DWORD_PTR dwCookie;		' User value passed to callback as first parameter 
	DWORD	dwError;		' Last error 
	EDITSTREAMCALLBACK pfnCallback;
} EDITSTREAM;

' Stream formats. Flags are all in low word, since high word
' gives possible codepage choice. 
const SF_TEXT			=$0001
const SF_RTF			=$0002
const SF_RTFNOOBJS	=$0003		' Write only 
const SF_TEXTIZED		=$0004		' Write only 

const SF_UNICODE		=$0010		' Unicode file (UCS2 little endian 
const SF_USECODEPAGE	=$0020		' CodePage given by high word 
const SF_NCRFORNONASCII =$40		' Output /uN for nonASCII 
const	SFF_WRITEXTRAPAR=$80		' Output \par at end

' Flag telling stream operations to operate on selection only 
' EM_STREAMINreplaces current selection 
' EM_STREAMOUT streams out current selection 
const SFF_SELECTION	=$8000

' Flag telling stream operations to ignore some FE control words 
' having to do with FE word breaking and horiz vs vertical text. 
' Not used in RichEdit 2.0 and later	
const SFF_PLAINRTF	=$4000

' Flag telling file stream output (SFF_SELECTION flag not set to persist 
' \viewscaleN control word. 
const SFF_PERSISTVIEWSCALE =$2000

' Flag telling file stream input with SFF_SELECTION flag not set not to 
' close the document 
const SFF_KEEPDOCINFO	=$1000

' Flag telling stream operations to output in Pocket Word format 
const SFF_PWD			=$0800

' 3-bit field specifying the value of N - 1 to use for \rtfN or \pwdN 
const SF_RTFVAL		=$0700

typedef struct _findtext
{
	CHARRANGE chrg;
	LPCSTR lpstrText;
} FINDTEXTA;

typedef struct _findtextw
{
	CHARRANGE chrg;
	LPCWSTR lpstrText;
} FINDTEXTW;

#if (_RICHEDIT_VER >==$0200
#ifdef UNICODE
const FINDTEXT	FINDTEXTW
#else
const FINDTEXT	FINDTEXTA
#endif	' UNICODE 
#else
const FINDTEXT	FINDTEXTA
#endif ' _RICHEDIT_VER >==$0200 

typedef struct _findtextexa
{
	CHARRANGE chrg;
	LPCSTR	lpstrText;
	CHARRANGE chrgText;
} FINDTEXTEXA;

typedef struct _findtextexw
{
	CHARRANGE chrg;
	LPCWSTR	lpstrText;
	CHARRANGE chrgText;
} FINDTEXTEXW;

#if (_RICHEDIT_VER >==$0200
#ifdef UNICODE
const FINDTEXTEX	FINDTEXTEXW
#else
const FINDTEXTEX	FINDTEXTEXA
#endif ' UNICODE 
#else
const FINDTEXTEX	FINDTEXTEXA
#endif ' _RICHEDIT_VER >==$0200 


typedef struct _formatrange
{
	HDC hdc;
	HDC hdcTarget;
	RECT rc;
	RECT rcPage;
	CHARRANGE chrg;
} FORMATRANGE;

' All paragraph measurements are in twips 

const MAX_TAB_STOPS 32
const lDefaultTab 720
const MAX_TABLE_CELLS 63

' This is a hack to make PARAFORMAT compatible with RE 1.0 
const	wReserved	wEffects

typedef struct _paraformat
{
	UINT	cbSize;
	DWORD	dwMask;
	WORD	wNumbering;
	WORD	wEffects;
	LONG	dxStartIndent;
	LONG	dxRightIndent;
	LONG	dxOffset;
	WORD	wAlignment;
	SHORT	cTabCount;
	LONG	rgxTabs[MAX_TAB_STOPS];
} PARAFORMAT;

#ifdef __cplusplus
struct PARAFORMAT2 : _paraformat
{
	LONG	dySpaceBefore;			' Vertical spacing before para
	LONG	dySpaceAfter;			' Vertical spacing after para
	LONG	dyLineSpacing;			' Line spacing depending on Rule
	SHORT	sStyle;					' Style handle
	BYTE	bLineSpacingRule;		' Rule for line spacing (see tom.doc
	BYTE	bOutlineLevel;			' Outline level
	WORD	wShadingWeight;			' Shading in hundredths of a per cent
	WORD	wShadingStyle;			' Nibble 0: style, 1: cfpat, 2: cbpat
	WORD	wNumberingStart;		' Starting value for numbering
	WORD	wNumberingStyle;		' Alignment, roman/arabic, (, , ., etc.
	WORD	wNumberingTab;			' Space bet FirstIndent & 1st-line text
	WORD	wBorderSpace;			' Border-text spaces (nbl/bdr in pts
	WORD	wBorderWidth;			' Pen widths (nbl/bdr in half pts
	WORD	wBorders;				' Border styles (nibble/border
};

#else	' Regular C-style	

typedef struct _paraformat2
{
	UINT	cbSize;
	DWORD	dwMask;
	WORD	wNumbering;
	WORD	wReserved;
	LONG	dxStartIndent;
	LONG	dxRightIndent;
	LONG	dxOffset;
	WORD	wAlignment;
	SHORT	cTabCount;
	LONG	rgxTabs[MAX_TAB_STOPS];
 	LONG	dySpaceBefore;			' Vertical spacing before para			
	LONG	dySpaceAfter;			' Vertical spacing after para			
	LONG	dyLineSpacing;			' Line spacing depending on Rule		
	SHORT	sStyle;					' Style handle							
	BYTE	bLineSpacingRule;		' Rule for line spacing (see tom.doc	
	BYTE	bOutlineLevel;			' Outline Level						
	WORD	wShadingWeight;			' Shading in hundredths of a per cent	
	WORD	wShadingStyle;			' Byte 0: style, nib 2: cfpat, 3: cbpat
	WORD	wNumberingStart;		' Starting value for numbering				
	WORD	wNumberingStyle;		' Alignment, Roman/Arabic, (, , ., etc.
	WORD	wNumberingTab;			' Space bet 1st indent and 1st-line text
	WORD	wBorderSpace;			' Border-text spaces (nbl/bdr in pts	
	WORD	wBorderWidth;			' Pen widths (nbl/bdr in half twips	
	WORD	wBorders;				' Border styles (nibble/border		
} PARAFORMAT2;

#endif ' C++	


' PARAFORMAT mask values 
const PFM_STARTINDENT			=$00000001
const PFM_RIGHTINDENT			=$00000002
const PFM_OFFSET				=$00000004
const PFM_ALIGNMENT			=$00000008
const PFM_TABSTOPS			=$00000010
const PFM_NUMBERING			=$00000020
const PFM_OFFSETINDENT		=$80000000

' PARAFORMAT 2.0 masks and effects 
const PFM_SPACEBEFORE			=$00000040
const PFM_SPACEAFTER			=$00000080
const PFM_LINESPACING			=$00000100
const	PFM_STYLE				=$00000400
const PFM_BORDER				=$00000800	' (*	
const PFM_SHADING				=$00001000	' (*	
const PFM_NUMBERINGSTYLE		=$00002000	' RE 3.0	
const PFM_NUMBERINGTAB		=$00004000	' RE 3.0	
const PFM_NUMBERINGSTART		=$00008000	' RE 3.0	

const PFM_RTLPARA				=$00010000
const PFM_KEEP				=$00020000	' (*	
const PFM_KEEPNEXT			=$00040000	' (*	
const PFM_PAGEBREAKBEFORE		=$00080000	' (*	
const PFM_NOLINENUMBER		=$00100000	' (*	
const PFM_NOWIDOWCONTROL		=$00200000	' (*	
const PFM_DONOTHYPHEN			=$00400000	' (*	
const PFM_SIDEBYSIDE			=$00800000	' (*	
const PFM_TABLE				=$40000000	' RE 3.0 
const PFM_TEXTWRAPPINGBREAK	=$20000000	' RE 3.0 
const PFM_TABLEROWDELIMITER	=$10000000	' RE 4.0 

' The following three properties are read only
const PFM_COLLAPSED			=$01000000	' RE 3.0 
const PFM_OUTLINELEVEL		=$02000000	' RE 3.0 
const PFM_BOX					=$04000000	' RE 3.0 
const PFM_RESERVED2			=$08000000	' RE 4.0 


' PARAFORMAT "ALL" masks
const	PFM_ALL (PFM_STARTINDENT | PFM_RIGHTINDENT | PFM_OFFSET	| \
				 PFM_ALIGNMENT | PFM_TABSTOPS| PFM_NUMBERING | \
				 PFM_OFFSETINDENT| PFM_RTLPARA

' Note: PARAFORMAT has no effects (BiDi RichEdit 1.0 does have PFE_RTLPARA
const PFM_EFFECTS (PFM_RTLPARA | PFM_KEEP | PFM_KEEPNEXT | PFM_TABLE \
					| PFM_PAGEBREAKBEFORE | PFM_NOLINENUMBER\
					| PFM_NOWIDOWCONTROL | PFM_DONOTHYPHEN | PFM_SIDEBYSIDE \
					| PFM_TABLE | PFM_TABLEROWDELIMITER

const PFM_ALL2	(PFM_ALL | PFM_EFFECTS | PFM_SPACEBEFORE | PFM_SPACEAFTER \
					| PFM_LINESPACING | PFM_STYLE | PFM_SHADING | PFM_BORDER \
					| PFM_NUMBERINGTAB | PFM_NUMBERINGSTART | PFM_NUMBERINGSTYLE

const PFE_RTLPARA				(PFM_RTLPARA		 >> 16
const PFE_KEEP				(PFM_KEEP			 >> 16	' (*	
const PFE_KEEPNEXT			(PFM_KEEPNEXT		 >> 16	' (*	
const PFE_PAGEBREAKBEFORE		(PFM_PAGEBREAKBEFORE >> 16	' (*	
const PFE_NOLINENUMBER		(PFM_NOLINENUMBER	 >> 16	' (*	
const PFE_NOWIDOWCONTROL		(PFM_NOWIDOWCONTROL	 >> 16	' (*	
const PFE_DONOTHYPHEN			(PFM_DONOTHYPHEN 	 >> 16	' (*	
const PFE_SIDEBYSIDE			(PFM_SIDEBYSIDE		 >> 16	' (*	
const PFE_TEXTWRAPPINGBREAK	(PFM_TEXTWRAPPINGBREAK>>16 ' (*	

' The following four effects are read only
const PFE_COLLAPSED			(PFM_COLLAPSED		 >> 16	' (+	
const PFE_BOX					(PFM_BOX			 >> 16	' (+	
const PFE_TABLE				(PFM_TABLE			 >> 16	' Inside table row. RE 3.0 
const PFE_TABLEROWDELIMITER	(PFM_TABLEROWDELIMITER>>16	' Table row start. RE 4.0 

' PARAFORMAT numbering options 
const PFN_BULLET		1		' tomListBullet

' PARAFORMAT2 wNumbering options 
const PFN_ARABIC		2		' tomListNumberAsArabic: 0, 1, 2,	...
const PFN_LCLETTER	3		' tomListNumberAsLCLetter: a, b, c,	...
const	PFN_UCLETTER	4		' tomListNumberAsUCLetter: A, B, C,	...
const	PFN_LCROMAN		5		' tomListNumberAsLCRoman:i, ii, iii,	...
const	PFN_UCROMAN		6		' tomListNumberAsUCRoman:I, II, III,	...

' PARAFORMAT2 wNumberingStyle options 
const PFNS_PAREN		=$000	' default, e.g.,				1	
const	PFNS_PARENS		=$100	' tomListParentheses/256, e.g., (1	
const PFNS_PERIOD		=$200	' tomListPeriod/256, e.g.,		1.	
const PFNS_PLAIN		=$300	' tomListPlain/256, e.g.,		1		
const PFNS_NONUMBER	=$400	' Used for continuation w/o number

const PFNS_NEWNUMBER	=$8000	' Start new number with wNumberingStart		
								' (can be combined with other PFNS_xxx
' PARAFORMAT alignment options 
const PFA_LEFT			 1
const PFA_RIGHT			 2
const PFA_CENTER			 3

' PARAFORMAT2 alignment options 
const	PFA_JUSTIFY			 4	' New paragraph-alignment option 2.0 (* 
const PFA_FULL_INTERWORD	 4	' These are supported in 3.0 with advanced
const PFA_FULL_INTERLETTER 5	'typography enabled
const PFA_FULL_SCALED		 6
const	PFA_FULL_GLYPHS		 7
const	PFA_SNAP_GRID		 8


' Notification structures 
#ifndef WM_NOTIFY
const WM_NOTIFY		=$004E

typedef struct _nmhdr
{
	HWND	hwndFrom;
	UINT	idFrom;
	UINT	code;
} NMHDR;
#endif' !WM_NOTIFY 

typedef struct _msgfilter
{
	NMHDR	nmhdr;
	UINT	msg;
	WPARAM	wParam;
	LPARAM	lParam;
} MSGFILTER;

typedef struct _reqresize
{
	NMHDR nmhdr;
	RECT rc;
} REQRESIZE;

typedef struct _selchange
{
	NMHDR nmhdr;
	CHARRANGE chrg;
	WORD seltyp;
} SELCHANGE;


const SEL_EMPTY		=$0000
const SEL_TEXT		=$0001
const SEL_OBJECT		=$0002
const SEL_MULTICHAR	=$0004
const SEL_MULTIOBJECT	=$0008

' Used with IRichEditOleCallback::GetContextMenu, this flag will be
' passed as a "selection type".It indicates that a context menu for
' a right-mouse drag drop should be generated.The IOleObject parameter
' will really be the IDataObject for the drop
const GCM_RIGHTMOUSEDROP=$8000

typedef struct _endropfiles
{
	NMHDR nmhdr;
	HANDLE hDrop;
	LONG cp;
	BOOL fProtected;
} ENDROPFILES;

typedef struct _enprotected
{
	NMHDR nmhdr;
	UINT msg;
	WPARAM wParam;
	LPARAM lParam;
	CHARRANGE chrg;
} ENPROTECTED;

typedef struct _ensaveclipboard
{
	NMHDR nmhdr;
	LONG cObjectCount;
LONG cch;
} ENSAVECLIPBOARD;

#ifndef MACPORT
typedef struct _enoleopfailed
{
	NMHDR nmhdr;
	LONG iob;
	LONG lOper;
	HRESULT hr;
} ENOLEOPFAILED;
#endif

const	OLEOP_DOVERB	1

typedef struct _objectpositions
{
NMHDR nmhdr;
LONG cObjectCount;
LONG *pcpPositions;
} OBJECTPOSITIONS;

typedef struct _enlink
{
NMHDR nmhdr;
UINT msg;
WPARAM wParam;
LPARAM lParam;
CHARRANGE chrg;
} ENLINK;

typedef struct _enlowfirtf
{
NMHDR nmhdr;
	char *szControl;
} ENLOWFIRTF;

' PenWin specific 
typedef struct _encorrecttext
{
	NMHDR nmhdr;
	CHARRANGE chrg;
	WORD seltyp;
} ENCORRECTTEXT;

' East Asia specific 
typedef struct _punctuation
{
	UINT	iSize;
	LPSTR	szPunctuation;
} PUNCTUATION;

' East Asia specific 
typedef struct _compcolor
{
	COLORREF crText;
	COLORREF crBackground;
	DWORD dwEffects;
}COMPCOLOR;


' Clipboard formats - use as parameter to RegisterClipboardFormat( 
const CF_RTF 			TEXT("Rich Text Format"
const CF_RTFNOOBJS 	TEXT("Rich Text Format Without Objects"
const CF_RETEXTOBJ 	TEXT("RichEdit Text and Objects"

' Paste Special 
typedef struct _repastespecial
{
	DWORD		dwAspect;
	DWORD_PTR	dwParam;
} REPASTESPECIAL;

'	UndoName info 
typedef enum _undonameid
{
UID_UNKNOWN =0,
	UID_TYPING		=1,
	UID_DELETE 		=2,
	UID_DRAGDROP	=3,
	UID_CUT			=4,
	UID_PASTE		=5,
	UID_AUTOCORRECT =6
} UNDONAMEID;

' Flags for the SETEXTEX data structure 
const ST_DEFAULT		0
const ST_KEEPUNDO		1
const ST_SELECTION	2
const ST_NEWCHARS 	4

' EM_SETTEXTEX info; this struct is passed in the wparam of the message 
typedef struct _settextex
{
	DWORD	flags;			' Flags (see the ST_XXX defines			
	UINT	codepage;		' Code page for translation (CP_ACP for sys default,
						'1200 for Unicode, -1 for control default	
} SETTEXTEX;

' Flags for the GETEXTEX data structure 
const GT_DEFAULT		0
const GT_USECRLF		1
const GT_SELECTION	2
const GT_RAWTEXT		4
const GT_NOHIDDENTEXT	8

' EM_GETTEXTEX info; this struct is passed in the wparam of the message 
typedef struct _gettextex
{
	DWORD	cb;				' Count of bytes in the string				
	DWORD	flags;			' Flags (see the GT_XXX defines			
	UINT	codepage;		' Code page for translation (CP_ACP for sys default,
						'1200 for Unicode, -1 for control default	
	LPCSTR	lpDefaultChar;	' Replacement for unmappable chars			
	LPBOOL	lpUsedDefChar;	' Pointer to flag set when def char used	
} GETTEXTEX;

' Flags for the GETTEXTLENGTHEX data structure							
const GTL_DEFAULT		0	' Do default (return # of chars		
const GTL_USECRLF		1	' Compute answer using CRLFs for paragraphs
const GTL_PRECISE		2	' Compute a precise answer					
const GTL_CLOSE		4	' Fast computation of a "close" answer		
const GTL_NUMCHARS	8	' Return number of characters			
const GTL_NUMBYTES	16	' Return number of _bytes_				

' EM_GETTEXTLENGTHEX info; this struct is passed in the wparam of the msg 
typedef struct _gettextlengthex
{
	DWORD	flags;			' Flags (see GTL_XXX defines				
	UINT	codepage;		' Code page for translation (CP_ACP for default,
							'1200 for Unicode							
} GETTEXTLENGTHEX;
	
' BiDi specific features 
typedef struct _bidioptions
{
	UINT	cbSize;
	WORD	wMask;
	WORD	wEffects; 
} BIDIOPTIONS;

' BIDIOPTIONS masks 
#if (_RICHEDIT_VER ===$0100
const BOM_DEFPARADIR			=$0001	' Default paragraph direction (implies alignment (obsolete 
const BOM_PLAINTEXT			=$0002	' Use plain text layout (obsolete 
#endif ' _RICHEDIT_VER ===$0100 
const BOM_NEUTRALOVERRIDE		=$0004	' Override neutral layout (obsolete 
const BOM_CONTEXTREADING		=$0008	' Context reading order 
const BOM_CONTEXTALIGNMENT	=$0010	' Context alignment 

' BIDIOPTIONS effects 
#if (_RICHEDIT_VER ===$0100
const BOE_RTLDIR				=$0001	' Default paragraph direction (implies alignment (obsolete 
const BOE_PLAINTEXT			=$0002	' Use plain text layout (obsolete 
#endif ' _RICHEDIT_VER ===$0100 
const BOE_NEUTRALOVERRIDE		=$0004	' Override neutral layout (obsolete 
const BOE_CONTEXTREADING		=$0008	' Context reading order 
const BOE_CONTEXTALIGNMENT	=$0010	' Context alignment 

' Additional EM_FINDTEXT[EX] flags 
const FR_MATCHDIAC=$20000000
const FR_MATCHKASHIDA =$40000000
const FR_MATCHALEFHAMZA =$80000000
	
' UNICODE embedding character 
#ifndef WCH_EMBEDDING
const WCH_EMBEDDING (WCHAR=$FFFC
#endif ' WCH_EMBEDDING 
		
' khyph - Kind of hyphenation
typedef enum tagKHYPH
{
	khyphNil,				' No Hyphenation
	khyphNormal,			' Normal Hyphenation
	khyphAddBefore,			' Add letter before hyphen
	khyphChangeBefore,		' Change letter before hyphen
	khyphDeleteBefore,		' Delete letter before hyphen
	khyphChangeAfter,		' Change letter after hyphen
	khyphDelAndChange		' Delete letter before hyphen and change
							'letter preceding hyphen
} KHYPH;

typedef struct hyphresult
{
	KHYPH khyph;			' Kind of hyphenation
	longichHyph;			' Character which was hyphenated
	WCHAR chHyph;			' Depending on hyphenation type, character added, changed, etc.
} HYPHRESULT;

void WINAPI HyphenateProc(WCHAR *pszWord, LANGID langid, long ichExceed, HYPHRESULT *phyphresult;
typedef struct tagHyphenateInfo
{
	SHORT cbSize;			' Size of HYPHENATEINFO structure
	SHORT dxHyphenateZone;	' If a space character is closer to the margin
							'than this value, don't hyphenate (in TWIPs
	void (WINAPI* pfnHyphenate(WCHAR*, LANGID, long, HYPHRESULT*;
} HYPHENATEINFO;

#ifdef _WIN32
#include <poppack.h>
#elif !defined(RC_INVOKED
#pragma pack(
#endif

#ifdef __cplusplus
}
#endif' __cplusplus 

#endif ' !_RICHEDIT_ 
EndRem
