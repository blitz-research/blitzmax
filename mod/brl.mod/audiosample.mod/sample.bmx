
Strict

Const SF_MONO8=1
Const SF_MONO16LE=2
Const SF_MONO16BE=3

Const SF_STEREO8=4
Const SF_STEREO16LE=5
Const SF_STEREO16BE=6

Const SF_STDFORMAT=SF_STEREO16BE

Global BytesPerSample[]=[0,1,2,2,2,4,4]
Global ChannelsPerSample[]=[0,1,1,1,2,2,2]

Function CopySamples( in_buf:Byte Ptr,out_buf:Byte Ptr,format,count )
	MemCopy out_buf,in_buf,count*BytesPerSample[format]
End Function

Function ConvertSamples( in_buf:Byte Ptr,in_format,out_buf:Byte Ptr,out_format,count )
	If in_format=out_format
		CopySamples in_buf,out_buf,out_format,count
	Else If in_format=SF_STDFORMAT
		ConvertSamplesFromStdFormat in_buf,out_buf,out_format,count
	Else If out_format=SF_STDFORMAT
		ConvertSamplesToStdFormat in_buf,out_buf,in_format,count
	Else
		Local tmp_buf:Byte[count*BytesPerSample[SF_STDFORMAT]]
		ConvertSamplesToStdFormat in_buf,tmp_buf,in_format,count
		ConvertSamplesFromStdFormat tmp_buf,out_buf,out_format,count
	EndIf
End Function

Function ConvertSamplesToStdFormat( in_buf:Byte Ptr,out_buf:Byte Ptr,format,count )

	If format=SF_STDFORMAT
		CopySamples in_buf,out_buf,format,count
		Return
	EndIf

	Local in:Byte Ptr=in_buf,out:Byte Ptr=out_buf
	Local out_end:Byte Ptr=out+count*BytesPerSample[SF_STDFORMAT]

	Select format
	Case SF_MONO8
		While out<>out_end
			Local t=in[0]*257-$8000
			out[0]=t Shr 8
			out[1]=t
			out[2]=t Shr 8
			out[3]=t
			in:+1;out:+4
		Wend
	Case SF_MONO16LE
		While out<>out_end
			Local t=in[1] Shl 8 | in[0]
			out[0]=in[1]
			out[1]=in[0]
			out[2]=in[1]
			out[3]=in[0]
			in:+2;out:+4
		Wend
	Case SF_MONO16BE
		While out<>out_end
			out[0]=in[0]
			out[1]=in[1]
			out[2]=in[0]
			out[3]=in[1]
			in:+2;out:+4
		Wend
	Case SF_STEREO8
		While out<>out_end
			Local x=in[0]*257-$8000
			Local y=in[1]*257-$8000
			out[0]=x Shr 8
			out[1]=x
			out[2]=y Shr 8
			out[3]=y
			in:+2;out:+4
		Wend
	Case SF_STEREO16LE
		While out<>out_end
			out[0]=in[1]
			out[1]=in[0]
			out[2]=in[3]
			out[3]=in[2]
			in:+4;out:+4
		Wend
	Default
		RuntimeError "Unimplemented sample format conversion"
	End Select

End Function

Function ConvertSamplesFromStdFormat( in_buf:Byte Ptr,out_buf:Byte Ptr,format,count )

	If format=SF_STDFORMAT
		CopySamples in_buf,out_buf,format,count
		Return
	EndIf

	Local out:Byte Ptr=out_buf,in:Byte Ptr=in_buf
	Local in_end:Byte Ptr=in+count*BytesPerSample[SF_STDFORMAT]

	Select format
	Case SF_MONO8
		While in<>in_end
			Local x=in[0] Shl 8 | in[1]
			Local y=in[2] Shl 8 | in[3]
			If x & $8000 x:|$ffff0000
			If y & $8000 y:|$ffff0000
			Local t=(x+y)/2
			out[0]=(t+$8000)/257
			in:+4;out:+1
		Wend
	Case SF_MONO16LE
		While in<>in_end
			Local x=in[0] Shl 8 | in[1]
			Local y=in[2] Shl 8 | in[3]
			If x & $8000 x:|$ffff0000
			If y & $8000 y:|$ffff0000
			Local t=(x+y)/2
			out[0]=t
			out[1]=t Shr 8
			in:+4;out:+2
		Wend
	Case SF_MONO16BE
		While in<>in_end
			Local x=in[0] Shl 8 | in[1]
			Local y=in[2] Shl 8 | in[3]
			If x & $8000 x:|$ffff0000
			If y & $8000 y:|$ffff0000
			Local t=(x+y)/2
			out[0]=t Shr 8
			out[1]=t
			in:+4;out:+2
		Wend
	Case SF_STEREO8
		While in<>in_end
			Local x=in[0] Shl 8 | in[1]
			Local y=in[2] Shl 8 | in[3]
			If x & $8000 x:|$ffff0000
			If y & $8000 y:|$ffff0000
			out[0]=(x+$8000)/257
			out[1]=(y+$8000)/257
			in:+4;out:+2
		Wend
	Case SF_STEREO16LE
		While in<>in_end
			out[0]=in[1]
			out[1]=in[0]
			out[2]=in[3]
			out[3]=in[2]
			in:+4;out:+4
		Wend
	Default
		RuntimeError "Unimplemented sample format conversion"
	End Select

End Function
