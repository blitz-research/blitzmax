
Strict

Module BRL.FreeTypeFont

ModuleInfo "Version: 1.09"
ModuleInfo "Author: Simon Armstrong, Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.09 Release"
ModuleInfo "History: Offset glyph rect to allow for smooth font border"
ModuleInfo "History: 1.08 Release"
ModuleInfo "History: Fixed freetypelib being reopened per font"
ModuleInfo "History: 1.07 Release"
ModuleInfo "History: Added one pixel blank border around SMOOTHFONT glyphs for ultra smooth subpixel positioning."
ModuleInfo "History: 1.06 Release"
ModuleInfo "History: Fixed memory (incbin::) fonts"
ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Improved unicode support"
ModuleInfo "History: Replaced stream hooks with New_Memory_Face"
ModuleInfo "History: 1.04 Release"
ModuleInfo "History: Added stream hooks"

Import BRL.Font
Import BRL.Pixmap
Import Pub.FreeType

Private

Function PadPixmap:TPixmap( p:TPixmap )
	Local t:TPixmap=TPixmap.Create( p.width+2,p.height+2,p.format )
	MemClear t.pixels,t.capacity
	t.Paste p,1,1
	Return t
End Function

Public

Type TFreeTypeGlyph Extends TGlyph

	Field _pixmap:TPixmap
	Field _advance#,_x,_y,_w,_h
	
	Method Pixels:TPixmap()
		If _pixmap Return _pixmap
		
		Return _pixmap
	End Method
	
	Method Advance#()
		Return _advance
	End Method
	
	Method GetRect( x Var,y Var,w Var,h Var )
		x=_x
		y=_y
		w=_w
		h=_h
	End Method

End Type

Type TFreeTypeFont Extends BRL.Font.TFont

	Field _face:FTFace
	Field _ft_face:Byte Ptr
	Field _style,_height
	Field _ascend,_descend
	Field _glyphs:TFreeTypeGlyph[]
	Field _buf:Byte Ptr,_buf_size
	
	Method Delete()
		FT_Done_Face _ft_face
		MemFree _buf
	End Method

	Method Style()
		Return _style
	End Method

	Method Height()
		Return _height
	End Method
	
	Method CountGlyphs()
		Return _glyphs.length
	End Method
	
	Method CharToGlyph( char )
		Return FT_Get_Char_Index( _ft_face,char )-1
	End Method
	
	Method LoadGlyph:TFreeTypeGlyph( index )
	
		Local glyph:TFreeTypeGlyph=_glyphs[index]
		If glyph Return glyph

		glyph=New TFreeTypeGlyph
		_glyphs[index]=glyph
		
		If FT_Load_Glyph( _ft_face,index+1,FT_LOAD_RENDER ) Return glyph
			
		Local slot:FTGlyph=New FTGlyph
		MemCopy slot,_face.glyphslot,SizeOf slot

		glyph._x=slot.bitmap_left
		glyph._y=-slot.bitmap_top+_ascend
		glyph._w=slot.width
		glyph._h=slot.rows
		glyph._advance=slot.advancex Sar 6
		
		If slot.width=0 Return glyph
	
		Local pixmap:TPixmap
			
		If slot.numgreys
			pixmap=TPixmap.CreateStatic( slot.buffer,slot.width,slot.rows,slot.pitch,PF_A8 ).Copy()
		Else
			pixmap=CreatePixmap( slot.width,slot.rows,PF_A8 )
			Local b
			For Local y=0 Until slot.rows
				Local dst:Byte Ptr=pixmap.PixelPtr(0,y)
				Local src:Byte Ptr=slot.buffer+y*slot.pitch
				For Local x=0 Until slot.width
					If (x&7)=0 b=src[x/8]
					If b & $80 dst[x]=$ff Else dst[x]=0
					b:+b
				Next
			Next
		EndIf
		
		If _style & SMOOTHFONT
			glyph._x:-1
			glyph._y:-1
			glyph._w:+2
			glyph._h:+2
			pixmap=PadPixmap(pixmap)
		EndIf
		
		glyph._pixmap=pixmap
		
		Return glyph

	End Method
	
	Function Load:TFreeTypeFont( src$,size,style )

		Global ft_lib:Byte Ptr
		
		If Not ft_lib
			If FT_Init_FreeType( Varptr ft_lib ) Return
		EndIf

		Local buf:Byte Ptr,buf_size
				
		Local ft_face:Byte Ptr

		If src.Find( "::" )>0
			Local tmp:Byte[]=LoadByteArray( src )
			buf_size=tmp.length
			If Not buf_size Return
			buf=MemAlloc( buf_size )
			MemCopy buf,tmp,buf_size
			If FT_New_Memory_Face( ft_lib,buf,buf_size,0,Varptr ft_face )
				MemFree buf
				Return
			EndIf
		Else
			If FT_New_Face( ft_lib,src$,0,Varptr ft_face ) Return
		EndIf
		
		While size
			If Not FT_Set_Pixel_Sizes( ft_face,0,size ) Exit
			size:-1
		Wend
		If Not size 
			FT_Done_Face ft_face
			Return
		EndIf
		
		Local face:FTFace=New FTFace
		MemCopy face,ft_face,SizeOf face
		
		Local metrics:FTMetrics=New FTMetrics
		MemCopy metrics,face.metrics,SizeOf metrics
		
		Local font:TFreeTypeFont=New TFreeTypeFont
		font._face=face
		font._ft_face=ft_face
		font._style=style
		font._height=metrics.height Sar 6
		font._ascend=metrics.ascend Sar 6
		font._descend=metrics.descend Sar 6
		font._glyphs=New TFreeTypeGlyph[face.numglyphs]
		font._buf=buf
		font._buf_size=buf_size
		
		Return font
	
	End Function

End Type

Type TFreeTypeFontLoader Extends TFontLoader

	Method LoadFont:TFreeTypeFont( url:Object,size,style )
	
		Local src$=String( url )
		
		If src Return TFreeTypeFont.Load( src,size,style )
	
	End Method

End Type

AddFontLoader New TFreeTypeFontLoader
