
Strict

Rem
bbdoc: Graphics/PNG loader
about:
The PNG loader module provides the ability to load PNG format #pixmaps.
End Rem
Module BRL.PNGLoader

ModuleInfo "Version: 1.04"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.04"
ModuleInfo "History: libpng update to 1.2.12."
ModuleInfo "History: Extra load error handling."
ModuleInfo "History: 1.03 Release"
ModuleInfo "History: Added Gray/Alpha support"
ModuleInfo "History: 1.02 Release"
ModuleInfo "History: Fixed palettized/grayscale support"

Import BRL.Pixmap
Import Pub.LibPNG

Private

Global png_stream:TStream

Function png_read_fn( png_ptr,buf:Byte Ptr,size )
	Return png_stream.ReadBytes( buf,size )
End Function

Function png_write_fn( png_ptr,buf:Byte Ptr,size )
	Return png_stream.WriteBytes( buf,size )
End Function

Function png_flush_fn( png_ptr )
	png_stream.Flush
End Function

Public

Rem
bbdoc: Load a Pixmap in PNG format
about:
#LoadPixmapPNG loads a pixmap from @url in PNG format.

If the pixmap cannot be loaded, Null is returned.
End Rem
Function LoadPixmapPNG:TPixmap( url:Object )

	png_stream=ReadStream( url )
	If Not png_stream Return

	Local buf:Byte[8]
	
	If png_stream.ReadBytes( buf,8 )<>8 Or png_sig_cmp( buf,0,8 )<>0
		png_stream.Close
		png_stream=Null
		Return
	EndIf
	
	Try
		Local png_ptr=png_create_read_struct( "1.2.12",Null,Null,Null )
		
		' check for valid png_ptr
		If Not png_ptr Then
			png_stream.Close
			png_stream=Null
			Return
		End If
		
		Local info_ptr=png_create_info_struct( png_ptr )
		
		' check for valid info_ptr
		If Not info_ptr Then
			png_stream.Close
			png_stream=Null
			png_destroy_read_struct Varptr png_ptr,Null,Null
			Return
		End If
		
		png_set_sig_bytes png_ptr,8
	
		png_set_read_fn png_ptr,Null,png_read_fn
			
		png_read_png png_ptr,info_ptr,PNG_TRANSFORM_EXPAND|PNG_TRANSFORM_STRIP_16,0
	
		Local width,height,bit_depth,color_type,interlace_type,compression_type,filter_method
		png_get_IHDR png_ptr,info_ptr,width,height,bit_depth,color_type,interlace_type,compression_type,filter_method
					
		Local pixmap:TPixmap
				
		If bit_depth=8
			Local pf
			Select color_type
			Case PNG_COLOR_TYPE_GRAY
				pf=PF_I8
			Case PNG_COLOR_TYPE_RGB
				pf=PF_RGB888
			Case PNG_COLOR_TYPE_RGBA
				pf=PF_RGBA8888
			Case PNG_COLOR_TYPE_GRAY_ALPHA
				pixmap=CreatePixmap( width,height,PF_RGBA8888 )
				Local rows:Byte Ptr Ptr=png_get_rows( png_ptr,info_ptr )
				For Local y=0 Until height
					Local src:Byte Ptr=rows[y]
					Local dst:Byte Ptr=pixmap.PixelPtr(0,y)
					For Local x=0 Until width
						Local a=src[0]
						Local i=src[1]
						dst[0]=i
						dst[1]=i
						dst[2]=i
						dst[3]=a
						src:+2
						dst:+4
					Next
				Next
			End Select
			If pf
				pixmap=CreatePixmap( width,height,pf )
				Local rows:Byte Ptr Ptr=png_get_rows( png_ptr,info_ptr )
				For Local y=0 Until height
					CopyPixels rows[y],pixmap.PixelPtr(0,y),pf,width
				Next
			EndIf
		EndIf
			
		png_destroy_read_struct Varptr png_ptr,Varptr info_ptr,Null
	
		png_stream.Close
		png_stream=Null
		Return pixmap
		
	Catch ex:String
	
		If ex<>"PNG ERROR" Throw ex
	
	End Try

End Function

Rem
bbdoc: Save a Pixmap in PNG format
about:
#SavePixmapPNG saves @pixmap to @url in PNG format. If successful, #SavePixmapPNG returns
True, otherwise False.

The optional @compression parameter should be in the range 0 to 9, where
0 indicates no compression (fastest) and 9 indicates full compression (slowest).
End Rem
Function SavePixmapPNG( pixmap:TPixmap,url:Object,compression=5 )

	compression=Min( Max( compression,0 ),9 )

	png_stream:TStream=WriteStream( url )
	If Not png_stream Return
	
	Try
		Local png_ptr=png_create_write_struct( "1.2.12",Null,Null,Null )
		Local info_ptr=png_create_info_struct( png_ptr )
	
		png_set_write_fn png_ptr,Null,png_write_fn,png_flush_fn
	
		Local bitdepth,colortype,transform
		
		Select pixmap.format
		Case PF_I8
			colortype=PNG_COLOR_TYPE_GRAY
		Case PF_RGB888
			colortype=PNG_COLOR_TYPE_RGB
		Case PF_BGR888
			colortype=PNG_COLOR_TYPE_RGB
			transform=PNG_TRANSFORM_BGR
		Case PF_RGBA8888
			colortype=PNG_COLOR_TYPE_RGBA
		Case PF_BGRA8888
			colortype=PNG_COLOR_TYPE_RGBA
			transform=PNG_TRANSFORM_BGR
		Default
			colortype=PNG_COLOR_TYPE_RGBA
			pixmap=pixmap.Convert( PF_RGBA8888 )
		End Select
	
		png_set_compression_level png_ptr,compression
	
		png_set_IHDR png_ptr,info_ptr,pixmap.width,pixmap.height,8,colortype,PNG_INTERLACE_NONE,PNG_COMPRESSION_TYPE_DEFAULT,PNG_FILTER_TYPE_DEFAULT
		
		Local rows:Byte Ptr[pixmap.height]
		For Local i=0 Until pixmap.height
			rows[i]=pixmap.PixelPtr( 0,i )
		Next
		
		png_set_rows png_ptr,info_ptr,rows
	
		png_write_png png_ptr,info_ptr,transform,Null
	
		png_destroy_write_struct Varptr png_ptr,Varptr info_ptr,Null
		
		png_stream.Close
		png_stream=Null
		
		Return True
		
	Catch ex:String
	
		If ex<>"PNG ERROR" Throw ex
	
	End Try
		
End Function

Private

Type TPixmapLoaderPNG Extends TPixmapLoader

	Method LoadPixmap:TPixmap( stream:TStream )
	
		Return LoadPixmapPNG( stream )
	
	End Method
	
End Type

New TPixmapLoaderPNG
