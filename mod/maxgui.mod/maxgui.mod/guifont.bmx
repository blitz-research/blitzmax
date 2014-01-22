Strict

Const FONT_NORMAL = 0
Const FONT_BOLD = 1
Const FONT_ITALIC = 2
Const FONT_UNDERLINE = 4
Const FONT_STRIKETHROUGH = 8	'Unsupported on some platforms

Const GUIFONT_SYSTEM% = 1
Const GUIFONT_MONOSPACED% = 2
Const GUIFONT_SANSSERIF% = 3
Const GUIFONT_SERIF% = 4
Const GUIFONT_SCRIPT% = 5

Type TGuiFont
	Field name$
	Field path$
	Field style
	Field size
	Field handle
	
	Method CharWidth(charcode) Abstract
End Type
