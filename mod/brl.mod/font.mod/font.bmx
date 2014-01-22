
Strict

Module BRL.Font

ModuleInfo "Version: 1.05"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Modified interface for improved unicode support"

Const BOLDFONT=1
Const ITALICFONT=2
Const SMOOTHFONT=4

Type TGlyph
	
	Method Pixels:Object() Abstract

	Method Advance#() Abstract
	Method GetRect( x Var,y Var,width Var,height Var ) Abstract

End Type

Type TFont

	Method Style() Abstract
	Method Height() Abstract
	Method CountGlyphs() Abstract
	Method CharToGlyph( char ) Abstract
	Method LoadGlyph:TGlyph( index ) Abstract

End Type

Type TFontLoader
	Field _succ:TFontLoader

	Method LoadFont:TFont( url:Object,size,style ) Abstract

End Type

Private

Global _loaders:TFontloader

Public

Function AddFontLoader( loader:TFontLoader )
	If loader._succ Return
	loader._succ=_loaders
	_loaders=loader
End Function

Function LoadFont:TFont( url:Object,size,style=SMOOTHFONT )

	Local loader:TFontLoader=_loaders
	
	While loader
		Local font:TFont=loader.LoadFont( url,size,style )
		If font Return font
		loader=loader._succ
	Wend

End Function
