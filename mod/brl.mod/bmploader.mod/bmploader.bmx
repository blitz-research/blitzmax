
Strict

Rem
bbdoc: Graphics/BMP loader
about:
The BMP loader module provides the ability to load BMP format #pixmaps.
End Rem
Module BRL.BMPLoader

ModuleInfo "Version: 1.07"
ModuleInfo "Author: Simon Armstrong"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.07 Release"
ModuleInfo "History: Added 32 bit alpha support"
ModuleInfo "History: 1.06 Release"
ModuleInfo "History: Fixed inverted 1 bit bitmaps"
ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Fixed palettized bitmaps failing when biClrUsed=0"

Import BRL.Pixmap
Import BRL.EndianStream

Type TPixmapLoaderBMP Extends TPixmapLoader

	Method LoadPixmap:TPixmap( stream:TStream )

		stream=LittleEndianStream( stream )
				
		Local	line:Int[],palette:Int[],pix:Byte[],buf:Byte[64]
		Local	pixmap:TPixmap
		Local	hsize,hoffset,pad
		Local	size,width,height
		Local	planes,bits,compression,isize,xpels,ypels,cols,inuse
		Local	w,x,y,c0,c1,p

		If stream.ReadBytes( buf,2 )=2
			If buf[0]=Asc("B") And buf[1]=Asc("M")			
				hsize=ReadInt(stream)
				pad=ReadInt(stream)
				hoffset=ReadInt(stream)
				size=ReadInt(stream)
				width=ReadInt(stream)
				height=ReadInt(stream)
				planes=ReadShort(stream)
				bits=ReadShort(stream)
				compression=ReadInt(stream)
				isize=ReadInt(stream)
				xpels=ReadInt(stream)
				ypels=ReadInt(stream)
				cols=ReadInt(stream)
				inuse=ReadInt(stream)
				hoffset:-54
				If Not cols cols=1 Shl bits
				If bits=32
					pixmap=TPixmap.Create( width,height,PF_BGRA8888 )
				Else
					pixmap=TPixmap.Create( width,height,PF_BGR888 )
				EndIf
				Select bits
					Case 1
						c0=ReadInt(stream)
						c1=ReadInt(stream)
						w=(width+7)/8
						w=(w+3)&$fffc
						pix=New Byte[w]
						For y=height-1 To 0 Step -1
							stream.ReadBytes(pix,w)	
							For x=0 Until width
								If pix[x Shr 3]&(128 Shr (x&7))
									ConvertPixels(Varptr c1,PF_BGR888,pixmap.pixelptr(x,y),pixmap.format,1)
								Else 
									ConvertPixels(Varptr c0,PF_BGR888,pixmap.pixelptr(x,y),pixmap.format,1)
								EndIf
							Next
						Next					
					Case 4
						palette=New Int[16]
						line=New Int[width]
						stream.ReadBytes(palette,cols*4)
						w=(width+1)/2
						w=(w+3)&$fffc
						pix=New Byte[w]
						For y=height-1 To 0 Step -1
							stream.ReadBytes(pix,w)	
							For x=0 Until width
								p=(pix[x Shr 1]Shr((1-x&1)*4))&15
								line[x]=palette[p]
							Next
							ConvertPixels(line,PF_BGRA8888,pixmap.pixelptr(0,y),pixmap.format,width)
						Next					
					Case 8
						palette=New Int[256]
						line=New Int[width]
						stream.ReadBytes(palette,cols*4)
						w=(width+3)&$fffc
						pix=New Byte[w]
						For y=height-1 To 0 Step -1
							stream.ReadBytes(pix,w)	
							For x=0 Until width
								line[x]=palette[pix[x]&255]
							Next
							ConvertPixels(line,PF_BGRA8888,pixmap.pixelptr(0,y),pixmap.format,width)
						Next					
					Case 24
						w=width*3
						w=(w+3)&$fffc
						pix=New Byte[w]
						For y=height-1 To 0 Step -1
							stream.ReadBytes(pix,w)		
							ConvertPixels(pix,PF_BGR888,pixmap.pixelptr(0,y),pixmap.format,width) 
						Next
					Case 32
						w=width*4
						pix=New Byte[w]
						For y=height-1 To 0 Step -1
							stream.ReadBytes(pix,w)
							ConvertPixels(pix,PF_BGRA8888,pixmap.pixelptr(0,y),pixmap.format,width)
						Next
					Default
						pixmap=Null
				End Select
				Return pixmap
			EndIf
		EndIf
	End Method

End Type

New TPixmapLoaderBMP

