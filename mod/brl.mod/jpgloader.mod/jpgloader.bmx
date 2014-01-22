
Strict

Rem
bbdoc: Graphics/JPG loader
about:
The JPG loader module provides the ability to load JPG format #pixmaps.
End Rem
Module BRL.JPGLoader

ModuleInfo "Version: 1.05"
ModuleInfo "Author: Simon Armstrong, Jeffrey D. Panici"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Fixed SavePixmapJPeg"
ModuleInfo "History: 1.04 Release"
ModuleInfo "History: Removed print"
ModuleInfo "History: 1.03 Release"
ModuleInfo "History: Changed ReadBytes to Read for loader"
ModuleInfo "History: Added SaveJPEG function, thanks to Jeffrey D. Panici for the writefunc `fix'"
ModuleInfo "History: 1.02 Release"
ModuleInfo "History: Added support for monochrome / single channel"

Import BRL.Pixmap
Import Pub.LibJPEG

Private

Function readfunc%( buf:Byte Ptr,count,src:Object )
	Local stream:TStream
	stream=TStream(src)
	Local n=stream.Read( buf,count )
	Return n
End Function

Function writefunc%( buf:Byte Ptr,count,src:Object )
	Local stream:TStream
	stream=TStream(src)
	Local n=stream.Write( buf,count )
	Return n
End Function

Public

Rem
bbdoc: Load a Pixmap in JPeg format
about:
#LoadPixmapJPeg loads a pixmap from @url in JPeg format.

If the pixmap cannot be loaded, Null is returned.
End Rem
Function LoadPixmapJPeg:TPixmap( url:Object )

	Local	jpg,width,height,depth,y
	Local	pix:Byte Ptr	
	Local	pixmap:TPixmap
	Local	stream:TStream
	
	stream=ReadStream( url )
	If Not stream Return
	
	Local res=loadjpg(stream,readfunc,width,height,depth,pix)
	stream.Close
	If res Return Null
	
	If width=0 Return
	Select depth
	Case 1
		pixmap=CreatePixmap( width,height,PF_I8 )
		For y=0 Until height
			CopyPixels pix+y*width,pixmap.PixelPtr(0,y),PF_I8,width
		Next
	Case 3
		pixmap=CreatePixmap( width,height,PF_RGB888 )
		For y=0 Until height
			CopyPixels pix+y*width*3,pixmap.PixelPtr(0,y),PF_RGB888,width
		Next
	End Select
	free_ pix			
	Return pixmap
End Function

Rem
bbdoc: Save a Pixmap in JPeg format
about:
Saves @pixmap to @url in JPeg format. If successful, #SavePixmapJPeg returns
True, otherwise False.

The optional @quality parameter should be in the range 0 to 100, where
0 indicates poor quality (smallest) and 100 indicates best quality (largest).
End Rem
Function SavePixmapJPeg( pixmap:TPixmap,url:Object,quality=75 )

	Assert quality>=1 And quality<=100

	Local stream:TStream=WriteStream( url )
	If Not stream Return
	
	pixmap=pixmap.convert(PF_RGB888)

	Local pix:Byte Ptr=pixmap.PixelPtr( 0,0 )

	savejpg(stream,writefunc,pixmap.width,pixmap.height,pixmap.pitch,pix,quality)

	stream.Close
	Return True
End Function

Private

Type TPixmapLoaderJPG Extends TPixmapLoader
	Method LoadPixmap:TPixmap( stream:TStream )
		Return LoadPixmapJPeg( stream )
	End Method
End Type

New TPixmapLoaderJPG
