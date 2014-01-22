
Strict

Import BRL.Font

Import "image.bmx"

Incbin "blitzfont.bin"

Type TImageGlyph

	Field _image:TImage
	Field _advance#,_x,_y,_w,_h
	
	Method Pixels:TImage()
		Return _image
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

Type TImageFont

	Field _src_font:TFont
	Field _glyphs:TImageGlyph[]
	Field _imageFlags

	Method Style()
		If _src_font Return _src_font.Style()
		Return 0
	End Method

	Method Height()
		If _src_font Return _src_font.Height()
		Return 16
	End Method
	
	Method CountGlyphs()
		Return _glyphs.length
	End Method
	
	Method CharToGlyph( char )
		If _src_font Return _src_font.CharToGlyph( char )
		If char>=32 And char<128 Return char-32
		Return -1
	End Method
	
	Method LoadGlyph:TImageGlyph( index )

		Assert index>=0 And index<_glyphs.length

		Local glyph:TImageGlyph=_glyphs[index]
		If glyph Return glyph
		
		glyph:TImageGlyph=New TImageGlyph
		_glyphs[index]=glyph
		
		Local src_glyph:TGlyph=_src_font.LoadGlyph( index )
		
		glyph._advance=src_glyph.Advance()
		src_glyph.GetRect glyph._x,glyph._y,glyph._w,glyph._h
			
		Local pixmap:TPixmap=TPixmap( src_glyph.Pixels() )
		If Not pixmap Return glyph
			
		glyph._image=TImage.Load( pixmap.Copy(),_imageFlags,0,0,0 )
		
		Return glyph
		
	End Method
	
	Method Draw( text$,x#,y#,ix#,iy#,jx#,jy# )

		For Local i=0 Until text.length
		
			Local n=CharToGlyph( text[i] )
			If n<0 Continue
			
			Local glyph:TImageGlyph=LoadGlyph(n)
			Local image:TImage=glyph._image
			
			If image
				Local frame:TImageFrame=image.Frame(0)
				If frame
					Local tx#=glyph._x*ix+glyph._y*iy
					Local ty#=glyph._x*jx+glyph._y*jy			
					frame.Draw 0,0,image.width,image.height,x+tx,y+ty,0,0,image.width,image.height
				EndIf
			EndIf
			
			x:+glyph._advance*ix
			y:+glyph._advance*jx
		Next
		
	End Method
	
	Function Load:TImageFont( url:Object,size,style )
	
		Local src:TFont=LoadFont( url,size,style )
		If Not src Return
		
		Local font:TImageFont=New TImageFont
		font._src_font=src
		font._glyphs=New TImageGlyph[src.CountGlyphs()]
		If style & SMOOTHFONT font._imageFlags=FILTEREDIMAGE|MIPMAPPEDIMAGE
		
		Return font
		
	End Function
	
	Function CreateDefault:TImageFont()

		Local font:TImageFont=New TImageFont
		font._glyphs=New TImageGlyph[96]
		
		Local pixmap:TPixmap=TPixmap.Create( 96*8,16,PF_RGBA8888 )
		
		Local p:Byte Ptr=IncbinPtr( "blitzfont.bin" )
	
		For Local y=0 Until 16
			For Local x=0 Until 96
				Local b=p[x]
				For Local n=0 Until 8
					If b & (1 Shl n) 
						pixmap.WritePixel x*8+n,y,~0
					Else
						pixmap.WritePixel x*8+n,y,0
					EndIf
				Next
			Next
			p:+96
		Next

		For Local n=0 Until 96
			Local glyph:TImageGlyph=New TImageGlyph
			font._glyphs[n]=glyph
			glyph._advance=8
			glyph._w=8
			glyph._h=16
			glyph._image=TImage.Load( pixmap.Window(n*8,0,8,16).Copy(),0,0,0,0 )
		Next
	
		Return font
	End Function

End Type
