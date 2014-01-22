
Strict

Const PF_I8=				1
Const PF_A8=				2
Const PF_BGR888=			3
Const PF_RGB888=			4
Const PF_BGRA8888=  		5
Const PF_RGBA8888=  		6

Const PF_STDFORMAT= 		PF_RGBA8888

'New pixel formats
'
'These are GL compatible - all are 8 bit versions.
'
'NOT FULLY IMPLEMENTED YET!!!!!
'
Const PF_RED=				7
Const PF_GREEN=				8
Const PF_BLUE=				9
Const PF_ALPHA=				10
Const PF_INTENSITY=			11
Const PF_LUMINANCE=			12
Const PF_RGB=				PF_RGB888
Const PF_BGR=				PF_BGR888
Const PF_RGBA=				PF_RGBA8888
Const PF_BGRA=				PF_BGRA8888

?BigEndian
Const PF_COLOR=				PF_RGB
Const PF_COLORALPHA=		PF_RGBA
?LittleEndian
Const PF_COLOR=				PF_BGR
Const PF_COLORALPHA=		PF_BGRA
?

Global BytesPerPixel[]=			[0,1,1,3,3,4,4 , 1,1,1,1,1,1]

Global RedBitsPerPixel[]=		[0,0,0,8,8,8,8, 8,0,0,0,0,0]
Global GreenBitsPerPixel[]=		[0,0,0,8,8,8,8, 0,8,0,0,0,0]
Global BlueBitsPerPixel[]=		[0,0,0,8,8,8,8, 0,0,8,0,0,0]
Global AlphaBitsPerPixel[]=		[0,0,8,0,0,8,8, 0,0,0,8,0,0]
Global IntensityBitsPerPixel[]=	[0,0,0,0,0,0,0, 0,0,0,0,8,0]
Global LuminanceBitsPerPixel[]=	[0,0,0,0,0,0,0, 0,0,0,0,0,8]

Global BitsPerPixel[]=			[0,8,8,24,24,32,32, 4,4,4,4,4,4]
Global ColorBitsPerPixel[]=		[0,0,0,24,24,24,24, 8,8,8,0,0,0]

Function CopyPixels( in_buf:Byte Ptr,out_buf:Byte Ptr,format,count )
	MemCopy out_buf,in_buf,count*BytesPerPixel[format]
End Function

Function ConvertPixels( in_buf:Byte Ptr,in_format,out_buf:Byte Ptr,out_format,count )
	If in_format=out_format
		CopyPixels in_buf,out_buf,out_format,count
	Else If in_format=PF_STDFORMAT
		ConvertPixelsFromStdFormat in_buf,out_buf,out_format,count
	Else If out_format=PF_STDFORMAT
		ConvertPixelsToStdFormat in_buf,out_buf,in_format,count
	Else
		Local tmp_buf:Int[count]
		ConvertPixelsToStdFormat in_buf,tmp_buf,in_format,count
		ConvertPixelsFromStdFormat tmp_buf,out_buf,out_format,count
	EndIf
End Function

Function ConvertPixelsToStdFormat( in_buf:Byte Ptr,out_buf:Byte Ptr,format,count )
	Local in:Byte Ptr=in_buf
	Local out:Byte Ptr=out_buf
	Local out_end:Byte Ptr=out+count*BytesPerPixel[PF_STDFORMAT]
	Select format
	Case PF_A8
		While out<>out_end
			out[0]=255
			out[1]=255
			out[2]=255
			out[3]=in[0]
			in:+1;out:+4
		Wend
	Case PF_I8
		While out<>out_end
			out[0]=in[0]
			out[1]=in[0]
			out[2]=in[0]
			out[3]=255
			in:+1;out:+4
		Wend
	Case PF_RGB888
		While out<>out_end
			out[0]=in[0]
			out[1]=in[1]
			out[2]=in[2]
			out[3]=255
			in:+3;out:+4
		Wend
	Case PF_BGR888
		While out<>out_end
			out[0]=in[2]
			out[1]=in[1]
			out[2]=in[0]
			out[3]=255
			in:+3;out:+4
		Wend
	Case PF_BGRA8888
		While out<>out_end
			out[0]=in[2]
			out[1]=in[1]
			out[2]=in[0]
			out[3]=in[3]
			in:+4;out:+4
		Wend
	Case PF_RED
		While out<>out_end
			out[0]=in[0]
			out[1]=0
			out[2]=0
			out[3]=1
			in:+1;out:+4
		Wend
	Case PF_GREEN
		While out<>out_end
			out[0]=0
			out[1]=in[0]
			out[2]=0
			out[3]=1
			in:+1;out:+4
		Wend
	Case PF_BLUE
		While out<>out_end
			out[0]=0
			out[1]=0
			out[2]=in[0]
			out[3]=1
			in:+1;out:+4
		Wend
	Case PF_ALPHA
		While out<>out_end
			out[0]=0
			out[1]=0
			out[2]=0
			out[3]=in[0]
			in:+1;out:+4
		Wend
	Case PF_INTENSITY
		While out<>out_end
			out[0]=in[0]
			out[1]=in[0]
			out[2]=in[0]
			out[3]=in[0]
			in:+1;out:+4
		Wend
	Case PF_LUMINANCE
		While out<>out_end
			out[0]=in[0]
			out[1]=in[0]
			out[2]=in[0]
			out[3]=1
			in:+1;out:+4
		Wend
	Case PF_STDFORMAT
		CopyPixels in_buf,out_buf,PF_STDFORMAT,count
	End Select
End Function

Function ConvertPixelsFromStdFormat( in_buf:Byte Ptr,out_buf:Byte Ptr,format,count )
	Local out:Byte Ptr=out_buf
	Local in:Byte Ptr=in_buf
	Local in_end:Byte Ptr=in+count*BytesPerPixel[PF_STDFORMAT]
	Select format
	Case PF_A8
		While in<>in_end
			out[0]=in[3]
			in:+4;out:+1
		Wend
	Case PF_I8
		While in<>in_end
			out[0]=(in[0]+in[1]+in[2])/3
			in:+4;out:+1
		Wend
	Case PF_RGB888
		While in<>in_end
			out[0]=in[0]
			out[1]=in[1]
			out[2]=in[2]
			in:+4;out:+3
		Wend
	Case PF_BGR888
		While in<>in_end
			out[0]=in[2]
			out[1]=in[1]
			out[2]=in[0]
			in:+4;out:+3
		Wend
	Case PF_BGRA8888
		While in<>in_end
			out[0]=in[2]
			out[1]=in[1]
			out[2]=in[0]
			out[3]=in[3]
			in:+4;out:+4
		Wend
	Case PF_RED
		While in<>in_end
			out[0]=in[0]
			in:+4;out:+1
		Wend
	Case PF_GREEN
		While in<>in_end
			out[0]=in[1]
			in:+4;out:+1
		Wend
	Case PF_BLUE
		While in<>in_end
			out[0]=in[2]
			in:+4;out:+1
		Wend
	Case PF_ALPHA
		While in<>in_end
			out[0]=in[3]
			in:+4;out:+1
		Wend
	Case PF_INTENSITY
		While in<>in_end
			out[0]=(in[0]+in[1]+in[2]+in[3])/4
			in:+4;out:+1
		Wend
	Case PF_LUMINANCE
		While in<>in_end
			out[0]=(in[0]+in[1]+in[2])/3
			in:+4;out:+1
		Wend
	Case PF_STDFORMAT
		CopyPixels in_buf,out_buf,PF_STDFORMAT,count
	End Select
End Function
