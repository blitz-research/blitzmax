
Strict

Rem
bbdoc: Graphics/TGA loader
about:
The TGA loader module provides the ability to load TGA format #pixmaps.
End Rem
Module BRL.TGALoader

ModuleInfo "Version: 1.07"
ModuleInfo "Author: Simon Armstrong"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"
ModuleInfo "History: 1.07 Release"
ModuleInfo "History: Fixed memory error due to pointer based array reference"
ModuleInfo "History: 1.06 Release"
ModuleInfo "History: Support for Run Length Encoded compression"
ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Fixed 24 bit byte ordering"

Import BRL.Pixmap
Import BRL.EndianStream

Const TGA_NULL=0
Const TGA_MAP=1
Const TGA_RGB=2
Const TGA_MONO=3
Const TGA_RLEMAP=9
Const TGA_RLERGB=10
Const TGA_RLEMONO=11
Const TGA_COMPMAP=32
Const TGA_COMPMAP4=33

Type tgahdr
	Field	idlen:Byte,colourmaptype:Byte,imgtype:Byte,indexlo:Byte,indexhi:Byte,lenlo:Byte,lenhi:Byte,cosize:Byte
	Field	x0:Short,y0:Short,width:Short,height:Short
	Field	psize:Byte,attbits:Byte
End Type

Function makeargb(a,r,g,b)
?BigEndian
	Return (b Shl 24)|(g Shl 16)|(r Shl 8)|a
?
	Return (a Shl 24)|(r Shl 16)|(g Shl 8)|b
End Function

Type TPixmapLoaderTGA Extends TPixmapLoader

	Method LoadPixmap:TPixmap( stream:TStream )
		Local	hdr:tgahdr		
		Local	w,h,tgatype,bits
		Local	buffer[]
		Local	sbuffer:Short[]
		Local	bbuffer:Byte[]
		Local	i,x,y,t,a
		Local	pixmap:TPixmap
		
		stream=LittleEndianStream( stream )	
		hdr=New tgahdr
		If stream.ReadBytes( hdr,8 )<>8 Return Null
		hdr.x0=stream.ReadShort()
		hdr.y0=stream.ReadShort()
		hdr.width=stream.ReadShort()
		hdr.height=stream.ReadShort()
		hdr.psize=stream.ReadByte()
		hdr.attbits=stream.ReadByte()

		bits=hdr.psize
		w=hdr.width
		h=hdr.height
		tgatype=hdr.imgtype

		If hdr.colourmaptype Return Null
		If Not (tgatype=TGA_MAP Or tgatype=TGA_RGB Or tgatype=TGA_RLERGB) Return Null
		If Not (bits=15 Or bits=16 Or bits=24 Or bits=32) Return Null
		If w<1 Or w>4096 Return Null
		If h<1 Or h>4096 Return Null

		If bits=16 Or bits=32
			pixmap=CreatePixmap( w,h,PF_RGBA8888)
		Else
			pixmap=CreatePixmap( w,h,PF_RGB888)
		EndIf

		For i=1 To hdr.idlen
			stream.ReadByte
		Next

		buffer=New Int[w]
		bbuffer=New Byte[w*3]

		Select tgatype
			Case TGA_RGB
				For y=h-1 To 0 Step -1
					Select bits
						Case 15
							For x=0 Until w
								t=stream.ReadShort()
								buffer[x]=makeargb(255,(t Shr 7)&$f8,(t Shr 2)&$f8,(t Shl 3)&$f8)
							Next
						Case 16
							For x=0 Until w
								t=stream.ReadShort()
								a=255
								If (t&$8000) a=0
								buffer[x]=makeargb(a,(t Shr 7)&$f8,(t Shr 2)&$f8,(t Shl 3)&$f8)
							Next
						Case 24
							stream.readbytes(bbuffer,w*3)
							For x=0 Until w
								buffer[x]=makeargb(255,bbuffer[x*3+2],bbuffer[x*3+1],bbuffer[x*3+0])
							Next
						Case 32
							stream.readbytes(buffer,w*4)
					End Select
					ConvertPixels(buffer,PF_BGRA8888,pixmap.pixelptr(0,y),pixmap.format,w)
				Next
			Case TGA_RLERGB
				Local	n,argb
				For y=h-1 To 0 Step -1		
					x=0
					Select bits
						Case 15
							While x<w
								n=stream.ReadByte()
								If n&128
									n:-127
									t=stream.ReadShort()
									argb=makeargb(255,(t Shr 7)&$f8,(t Shr 2)&$f8,(t Shl 3)&$f8)
									While n
										buffer[x]=argb
										n:-1
										x:+1
									Wend
								Else
									n:+1
									For i=0 Until n
										t=stream.ReadShort()
										buffer[x]=makeargb(255,(t Shr 7)&$f8,(t Shr 2)&$f8,(t Shl 3)&$f8)
										x:+1
									Next
								EndIf
							Wend
						Case 16
							While x<w
								n=stream.ReadByte()
								If n&128
									n:-127
									t=stream.ReadShort()
									a=255
									If (t&$8000) a=0
									argb=makeargb(a,(t Shr 7)&$f8,(t Shr 2)&$f8,(t Shl 3)&$f8)
									While n
										buffer[x]=argb
										n:-1
										x:+1
									Wend
								Else
									n:+1
									For i=0 Until n
										t=stream.ReadShort()
										a=255
										If (t&$8000) a=0
										buffer[x]=makeargb(a,(t Shr 7)&$f8,(t Shr 2)&$f8,(t Shl 3)&$f8)
										x:+1
									Next
								EndIf
							Wend
						Case 24
							While x<w
								n=stream.ReadByte()
								If n&128
									n:-127
									stream.readbytes bbuffer,3
									argb=makeargb(255,bbuffer[2],bbuffer[1],bbuffer[0])
									While n
										buffer[x]=argb
										n:-1
										x:+1
									Wend
								Else
									n:+1
									stream.readbytes(bbuffer,n*3)
									For i=0 Until n
										buffer[x]=makeargb(255,bbuffer[i*3+2],bbuffer[i*3+1],bbuffer[i*3+0])
										x:+1
									Next
								EndIf
							Wend
						Case 32
							While x<w
								n=stream.ReadByte()
								If n&128
									n:-127
									stream.readbytes Varptr argb,4
									While n
										buffer[x]=argb
										n:-1
										x:+1
									Wend
								Else
									n:+1
									stream.readbytes(Byte Ptr(buffer)+x*4,n*4)
									x:+n
								EndIf
							Wend
					End Select
					ConvertPixels(buffer,PF_BGRA8888,pixmap.pixelptr(0,y),pixmap.format,w)
				Next		
		End Select
	
		Return pixmap
			
	End Method
End Type

New TPixmapLoaderTGA
