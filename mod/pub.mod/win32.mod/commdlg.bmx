

Const CC_RGBINIT=1
Const CC_FULLOPEN=2
Const CC_PREVENTFULLOPEN=4
Const CC_SHOWHELP=8
Const CC_ENABLEHOOK=16
Const CC_ENABLETEMPLATE=32
Const CC_ENABLETEMPLATEHANDLE=64
Const CC_SOLIDCOLOR=128
Const CC_ANYCOLOR=256

Type CHOOSECOLOR
	Field lStructSize
	Field hwndOwner
	Field hInstance
	Field rgbResult
	Field lpCustColors:Byte Ptr
	Field Flags
	Field lCustData
	Field lpfnHook:Byte Ptr
	Field lpTemplateName:Short Ptr
End Type

Const CF_SCREENFONTS=$1
Const CF_PRINTERFONTS=$2
Const CF_SHOWHELP=$4
Const CF_ENABLEHOOK=$8
Const CF_ENABLETEMPLATE=$10
Const CF_ENABLETEMPLATEHANDLE=$20
Const CF_INITTOLOGFONTSTRUCT=$40
Const CF_USESTYLE=$80
Const CF_EFFECTS=$100
Const CF_APPLY=$200
Const CF_ANSIONLY=$400
Const CF_NOVECTORFONTS=$0800
Const CF_NOSIMULATIONS=$1000
Const CF_LIMITSIZE=$2000
Const CF_FIXEDPITCHONLY=$4000
Const CF_WYSIWYG=$8000
Const CF_FORCEFONTEXIST=$10000
Const CF_SCALABLEONLY=$20000
Const CF_TTONLY=$40000
Const CF_NOFACESEL=$80000
Const CF_NOSTYLESEL=$100000
Const CF_NOSIZESEL=$200000
Const CF_SELECTSCRIPT=$400000
Const CF_NOSCRIPTSEL=$800000
Const CF_NOVERTFONTS=$1000000

Const CF_BOTH=CF_SCREENFONTS|CF_PRINTERFONTS
Const CF_SCRIPTSONLY=CF_ANSIONLY
Const CF_NOOEMFONTS=CF_NOVECTORFONTS

Type CHOOSEFONT
	Field lStructSize
	Field hwndOwner
	Field hDC
	Field lpLogFont:Byte Ptr
	Field iPointSize
	Field Flags
	Field rgbColors
	Field lCustData
	Field lpfnHook:Byte Ptr
	Field lpTemplateName:Short Ptr
	Field hInstance
	Field lpszStyle:Short Ptr
	Field nFontType:Short
	Field _align_:Short
	Field nSizeMin
	Field nSizeMax
End Type

Extern "Win32"

Function ChooseColorW( lpcc:Byte Ptr )
Function ChooseFontW( lpcc:Byte Ptr )


End Extern
