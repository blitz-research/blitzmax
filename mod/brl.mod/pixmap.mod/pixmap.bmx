
Strict

Rem
bbdoc: Graphics/Pixmaps
End Rem
Module BRL.Pixmap

ModuleInfo "Version: 1.07"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.07 Release"
ModuleInfo "History: Added ClearPixels"
ModuleInfo "History: 1.06 Release"
ModuleInfo "History: Added new GL compatible pixel formats"
ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Added _source:Object field"
ModuleInfo "History: Removed AddPixmapLoader function"

Import BRL.Math
Import BRL.Stream

Import "pixel.bmx"

Rem
bbdoc: The Pixmap type
end rem
Type TPixmap

	Method _pad()
	End Method

	Rem
	bbdoc: A byte pointer to the pixmap's pixels
	end rem
	Field pixels:Byte Ptr
	
	Rem
	bbdoc: The width, in pixels, of the pixmap
	end rem
	Field width
	
	Rem
	bbdoc: The height, in pixels, of the pixmap
	end rem
	Field height
	
	Rem
	bbdoc: The pitch, in bytes, of the pixmap
	end rem
	Field pitch
	
	Rem
	bbdoc: The pixel format of the pixmap
	end rem
	Field format
	
	Rem
	bbdoc: The capacity, in bytes, of the pixmap, or -1 for a static pixmap
	end rem
	Field capacity
	
	'Hack to provide robust PixmapWindow functionality
	Field _source:Object
	
	Method Delete()
		If capacity>=0 
			MemFree pixels
		EndIf
	End Method

	Rem
	bbdoc: Get memory address of a pixel
	returns: A byte pointer to the pixel at coordinates @x, @y
	End Rem
	Method PixelPtr:Byte Ptr( x,y )
		Return pixels+y*pitch+x*BytesPerPixel[format]
	End Method

	Rem
	bbdoc: Create a virtual window into a pixmap
	returns: A static pixmap that references the specified rectangle.
	End Rem
	Method Window:TPixmap( x,y,width,height )
		Assert..
		x>=0 And width>=0 And x+width<=Self.width And..
		y>=0 And height>=0 And y+height<=Self.height Else "Pixmap coordinates out of bounds"
		Local t:TPixmap=CreateStatic( PixelPtr(x,y),width,height,pitch,format )
		t._source=Self
		Return t
	End Method

	Rem
	bbdoc: Duplicate a pixmap
	returns: A new TPixmap object.
	end rem
	Method Copy:TPixmap()
		Local pixmap:TPixmap=Create( width,height,format )
		For Local y=0 Until height
			CopyPixels Self.PixelPtr(0,y),pixmap.PixelPtr(0,y),format,width
		Next
		Return pixmap
	End Method

	Rem
	bbdoc: Paste a pixmap
	end rem
	Method Paste( source:TPixmap,x,y )
		For Local h=0 Until source.height
			ConvertPixels source.PixelPtr(0,h),source.format,Self.PixelPtr(x,y+h),Self.format,source.width
		Next
	End Method
	
	Rem
	bbdoc: Convert a pixmap
	returns: A new TPixmap object in the specified format
	end rem
	Method Convert:TPixmap( format )
		Local pixmap:TPixmap=Create( width,height,format )
		For Local y=0 Until height
			ConvertPixels Self.PixelPtr(0,y),Self.format,pixmap.PixelPtr(0,y),pixmap.format,pixmap.width
		Next
		Return pixmap
	End Method
	
	Rem
	bbdoc: Read a pixel from a pixmap
	returns: The pixel at the specified coordinates packed into an integer
	end rem
	Method ReadPixel( x,y )
		Assert x>=0 And x<width And y>=0 And y<height Else "Pixmap coordinates out of bounds"
		Local p:Byte Ptr=PixelPtr(x,y)
		Select format
		Case PF_A8
			Return p[0] Shl 24 | $00ffffff
		Case PF_I8
			Return $ff000000 | p[0] Shl 16 | p[0] Shl 8 | p[0]
		Case PF_RGB888
			Return $ff000000 | p[0] Shl 16 | p[1] Shl 8 | p[2]
		Case PF_BGR888
			Return $ff000000 | p[2] Shl 16 | p[1] Shl 8 | p[0]
		Case PF_RGBA8888
			Return p[0] Shl 16 | p[1] Shl 8 | p[2] | p[3] Shl 24
		Case PF_BGRA8888
			Return p[2] Shl 16 | p[1] Shl 8 | p[0] | p[3] Shl 24
		End Select
	End Method

	Rem
	bbdoc: Write a pixel to a pixmap
	end rem
	Method WritePixel( x,y,argb )
		Assert x>=0 And x<width And y>=0 And y<height Else "Pixmap coordinates out of bounds"
		Local p:Byte Ptr=PixelPtr(x,y)
		Select format
		Case PF_A8
			p[0]=argb Shr 24
		Case PF_I8
			p[0]=( (argb Shr 16 & $ff)+(argb Shr 8 & $ff)+(argb & $ff) )/3
		Case PF_RGB888
			p[0]=argb Shr 16 ; p[1]=argb Shr 8 ; p[2]=argb
		Case PF_BGR888
			p[0]=argb ; p[1]=argb Shr 8 ; p[2]=argb Shr 16
		Case PF_RGBA8888
			p[0]=argb Shr 16 ; p[1]=argb Shr 8 ; p[2]=argb ; p[3]=argb Shr 24
		Case PF_BGRA8888
			p[0]=argb ; p[1]=argb Shr 8 ; p[2]=argb Shr 16 ; p[3]=argb Shr 24
		End Select
	End Method
	
	Rem
	bbdoc: Create a pixmap
	returns: A new TPixmap object
	end rem	
	Function Create:TPixmap( width,height,format,align=4 )
		Local pitch=width*BytesPerPixel[format]
		pitch=(pitch+(align-1))/align*align
		Local capacity=pitch*height
		Local pixmap:TPixmap=New TPixmap
		pixmap.pixels=MemAlloc( capacity )
		pixmap.width=width
		pixmap.height=height
		pixmap.pitch=pitch
		pixmap.format=format
		pixmap.capacity=capacity
		Return pixmap
	End Function

	Rem
	bbdoc: Create a static pixmap
	returns: A new TPixmap object
	end rem
	Function CreateStatic:TPixmap( pixels:Byte Ptr,width,height,pitch,format )
		Local pixmap:TPixmap=New TPixmap
		pixmap.pixels=pixels
		pixmap.width=width
		pixmap.height=height
		pixmap.pitch=pitch
		pixmap.format=format
		pixmap.capacity=-1
		Return pixmap
	End Function

	Rem
	bbdoc: Clear a pixmap
	End Rem	
	Method ClearPixels( argb )
		If Not argb And width*BytesPerPixel[format]=pitch
			MemClear pixels,pitch*height
			Return
		EndIf
		For Local y=0 Until height
			Local p:Byte Ptr=PixelPtr(0,y)
			If Not argb
				MemClear p,width*BytesPerPixel[format]
				Continue
			EndIf			
			Select format
			Case PF_A8
				For Local x=0 Until width
					p[x]=argb Shr 24
				Next
			Case PF_I8
				For Local x=0 Until width
					p[x]=( (argb Shr 16 & $ff)+(argb Shr 8 & $ff)+(argb & $ff) )/3
				Next
			Case PF_RGB888
				For Local x=0 Until width*3 Step 3
					p[x]=argb Shr 16 ; p[x+1]=argb Shr 8 ; p[x+2]=argb
				Next
			Case PF_BGR888
				For Local x=0 Until width*3 Step 3
					p[x]=argb ; p[x+1]=argb Shr 8 ; p[x+2]=argb Shr 16
				Next
			Case PF_RGBA8888
				For Local x=0 Until width*4 Step 4
					p[x]=argb Shr 16 ; p[x+1]=argb Shr 8 ; p[x+2]=argb ; p[x+3]=argb Shr 24
				Next
			Case PF_BGRA8888
				For Local x=0 Until width*4 Step 4
					p[x]=argb ; p[x+1]=argb Shr 8 ; p[x+2]=argb Shr 16 ; p[x+3]=argb Shr 24
				Next
			End Select
		Next
	End Method
	
End Type

Private

Global pixmap_loaders:TPixmapLoader

Public

Rem
bbdoc: Abstract base type for pixmap loaders
about:
To create a new pixmap loader, you should extend TPixmapLoader and implement the #LoadPixmap method.

To install your pixmap loader, simply create an instance of it using #New</font>.
End Rem
Type TPixmapLoader
	Field _succ:TPixmapLoader
	
	Method New()
		_succ=pixmap_loaders
		pixmap_loaders=Self
	End Method
	
	Rem
	bbdoc: Load a pixmap
	about: This method must be implemented by extending types.
	end rem
	Method LoadPixmap:TPixmap( stream:TStream ) Abstract
	
End Type

Rem
bbdoc: Create a pixmap
returns: A new pixmap object of the specified @width and @height
about:
@format should be one of the following:

[ @Format | @Description
* PF_A8 | 8 bit alpha
* PF_I8 | 8 bit intensity
* PF_RGB888 | 24 bit big endian RGB
* PF_BGR888 | 24 bit little endian RGB
* PF_RGBA8888 | 32 bit big endian RGB with alpha
* PF_BGRA8888 | 32 bit little endian RGB with alpha
]

Note that the newly created pixmap will contain random data. #ClearPixels can
be used to set all pixels to a known value prior to use.
End Rem
Function CreatePixmap:TPixmap( width,height,format,align_bytes=4 )
	Return TPixmap.Create( width,height,format,align_bytes )
End Function

Rem
bbdoc: Create a pixmap with existing pixel data
returns: A new pixmap object that references an existing block of memory
about:
The memory referenced by a static pixmap is not released when the pixmap is deleted.

See #CreatePixmap for valid pixmap formats.
End Rem
Function CreateStaticPixmap:TPixmap( pixels:Byte Ptr,width,height,pitch,format )
	Return TPixmap.CreateStatic( pixels,width,height,pitch,format )
End Function

Rem
bbdoc: Copy a pixmap
returns: A new pixmap object
end rem
Function CopyPixmap:TPixmap( pixmap:TPixmap )
	Return pixmap.Copy()
End Function

Rem
bbdoc: Convert pixel format of a pixmap
returns: A new pixmap object with the specified pixel format
about:
See #CreatePixmap for valid pixmap formats.
end rem
Function ConvertPixmap:TPixmap( pixmap:TPixmap,format )
	Return pixmap.Convert( format )
End Function

Rem
bbdoc: Get pixmap width
returns: The width, in pixels, of @pixmap
end rem
Function PixmapWidth( pixmap:TPixmap )
	Return pixmap.width
End Function

Rem
bbdoc: Get pixmap width
returns: The height, in pixels, of @pixmap
end rem
Function PixmapHeight( pixmap:TPixmap )
	Return pixmap.height
End Function

Rem
bbdoc: Get pixmap pitch
returns: The pitch, in bytes, of @pixmap
about:
Pitch refers to the difference, in bytes, between the start of one row of pixels and the start of the next row.
end rem
Function PixmapPitch( pixmap:TPixmap )
	Return pixmap.pitch
End Function

Rem
bbdoc: Get pixmap format
returns: The format of the pixels stored in @pixmap
about:
See #CreatePixmap for supported formats.
End Rem
Function PixmapFormat( pixmap:TPixmap )
	Return pixmap.format
End Function

Rem
bbdoc: Get pixmap pixels
returns: A byte pointer to the pixels stored in @pixmap
end rem
Function PixmapPixelPtr:Byte Ptr( pixmap:TPixmap,x=0,y=0 )
	Return pixmap.PixelPtr( x,y )
End Function

Rem
bbdoc: Create a pixmap window
returns: A new pixmap object
about: #PixmapWindow creates a 'virtual' window into @pixmap.
end rem
Function PixmapWindow:TPixmap( pixmap:TPixmap,x,y,width,height )
	Return pixmap.Window( x,y,width,height )
End Function

Rem
bbdoc: Mask a pixmap
returns: A new pixmap object
about: @MaskPixmap builds a new pixmap with alpha components set to '0' wherever the pixel colors
in the original @pixmap match @mask_red, @mask_green and @mask_blue. @mask_red, @mask_green and @mask_blue
should be in the range 0 to 255.
end rem
Function MaskPixmap:TPixmap( pixmap:TPixmap,mask_red,mask_green,mask_blue ) NoDebug

	Local tmp:TPixmap=pixmap
	If tmp.format<>PF_RGBA8888 tmp=tmp.Convert( PF_RGBA8888 )
	
	Local out:TPixmap=CreatePixmap( tmp.width,tmp.height,PF_RGBA8888 )
	
	For Local y=0 Until pixmap.height
		Local t:Byte Ptr=tmp.PixelPtr( 0,y )
		Local o:Byte Ptr=out.PixelPtr( 0,y )
		For Local x=0 Until pixmap.width
			If t[0]<>mask_red Or t[1]<>mask_green Or t[2]<>mask_blue
				o[0]=t[0]
				o[1]=t[1]
				o[2]=t[2]
				o[3]=255
			Else
				Local r,g,b,n
				For Local ty=y-1 To y+1
					Local t:Byte Ptr=tmp.pixelptr( x-1,ty )
					For Local tx=x-1 To x+1
						If tx>=0 And tx<tmp.width And ty>=0 And ty<tmp.height
							If t[0]<>mask_red Or t[1]<>mask_green Or t[2]<>mask_blue
								r:+t[0]
								g:+t[1]
								b:+t[2]
								n:+1
							EndIf
						EndIf
						t:+4
					Next
				Next
				If n
					o[0]=r/n
					o[1]=g/n
					o[2]=b/n
				Else
					o[0]=0't[0]
					o[1]=0't[1]
					o[2]=0't[2]
				EndIf
				o[3]=0
			EndIf
			t:+4
			o:+4
		Next
	Next
	Return out
End Function

Rem
bbdoc: Flip a pixmap horizontally
returns: A new pixmap object
end rem
Function XFlipPixmap:TPixmap( pixmap:TPixmap ) NoDebug
	Local out:TPixmap=CreatePixmap( pixmap.width,pixmap.height,pixmap.format )
	For Local x=0 Until pixmap.width
		out.Paste pixmap.Window(pixmap.width-x-1,0,1,pixmap.height),x,0
	Next
	Return out
End Function

Rem
bbdoc: Flip a pixmap vertically
returns: A new pixmap object
end rem
Function YFlipPixmap:TPixmap( pixmap:TPixmap ) NoDebug
	Local out:TPixmap=CreatePixmap( pixmap.width,pixmap.height,pixmap.format )
	For Local y=0 Until pixmap.height
		out.paste pixmap.Window(0,pixmap.height-y-1,pixmap.width,1),0,y
	Next
	Return out
End Function

Rem
bbdoc: Resize a pixmap
returns: A new pixmap object of the specified @width and @height
end rem
Function ResizePixmap:TPixmap( pixmap:TPixmap,width,height ) NoDebug
	Local in_pixmap:TPixmap=pixmap
	If in_pixmap.format<>PF_STDFORMAT in_pixmap=pixmap.Convert( PF_STDFORMAT )
	Local tmp:Byte[width*4]
	Local x_sc#=Float(in_pixmap.width)/width
	Local y_sc#=Float(in_pixmap.height)/height
	Local out_pixmap:TPixmap=CreatePixmap( width,height,pixmap.format )
	For Local y=0 Until height
		Local ty#=(y+.5)*y_sc-.5
		Local iy#=Floor(ty),fy#=ty-iy
		Local in_pitch=in_pixmap.pitch
		If iy<0
			iy=0;fy=0;in_pitch=0
		Else If iy>=in_pixmap.height-1
			iy=in_pixmap.height-1;fy=0;in_pitch=0
		EndIf
		Local src:Byte Ptr=in_pixmap.PixelPtr(0,iy),dst:Byte Ptr=tmp
		For Local x=0 Until width
			Local tx#=(x+.5)*x_sc-.5
			Local ix#=Floor(tx),fx#=tx-ix
			Local in_off=4
			If ix<0
				ix=0;fx=0;in_off=0
			Else If ix>=in_pixmap.width-1
				ix=in_pixmap.width-1;fx=0;in_off=0
			EndIf
			Local p:Byte Ptr=src+Int(ix)*4
			For Local n=0 Until 4
				Local v0#=p[n],v1#=p[n+in_off]
				Local v2#=p[n+in_pitch],v3#=p[n+in_pitch+in_off]
				Local va#=(v1-v0)*fx+v0,vb#=(v3-v2)*fx+v2,vt#=(vb-va)*fy+va
				dst[n]=vt
			Next
			dst:+4
		Next
		ConvertPixels tmp,PF_STDFORMAT,out_pixmap.Pixelptr(0,y),out_pixmap.format,width
	Next
	Return out_pixmap
End Function

Rem
bbdoc: Load a pixmap
returns: A pixmap object
end rem
Function LoadPixmap:TPixmap( url:Object )
	Local stream:TStream=ReadStream( url )
	If Not stream Return

	Local pos=stream.Pos()
	If pos=-1
		stream.Close
		Return
	EndIf

	Local pixmap:TPixmap
	Local loader:TPixmapLoader=pixmap_loaders

	While loader
		stream.Seek pos
		Try
			pixmap=loader.LoadPixmap( stream )
		Catch ex:TStreamException
		End Try
		If pixmap Exit
		loader=loader._succ
	Wend
	stream.Close
	Return pixmap
End Function

Rem
bbdoc: Read a pixel from a pixmap
returns: A 32 bit pixel value
about:
The returned 32 bit value contains the following components:

[ bits 24-31 | pixel alpha
* bits 16-23 | pixel red
* bits 8-15 | pixel green
* bits 0-7 | pixel blue
]
End Rem
Function ReadPixel( pixmap:TPixmap,x,y )
	Return pixmap.ReadPixel( x,y )
End Function

Rem
bbdoc: Write a pixel to a pixmap
about:
The 32 bit @argb value contains the following components:

[ bits 24-31 | pixel alpha
* bits 16-23 | pixel red
* bits 8-15 | pixel green
* bits 0-7 | pixel blue
]
End Rem
Function WritePixel( pixmap:TPixmap,x,y,argb )
	pixmap.WritePixel x,y,argb
End Function

Rem
bbdoc: Clear a pixmap
about:
Sets all pixels in a pixmap to a 32 bit pixel value.

The 32 bit @argb value contains the following components:

[ bits 24-31 | pixel alpha
* bits 16-23 | pixel red
* bits 8-15 | pixel green
* bits 0-7 | pixel blue
]
End Rem
Function ClearPixels( pixmap:TPixmap,argb=0 )
	pixmap.ClearPixels argb
End Function
