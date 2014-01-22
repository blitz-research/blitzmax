
Strict

Rem
bbdoc: Audio/WAV loader
about:The WAV loader module provides the ability to load WAV format #{audio samples}.
End Rem
Module BRL.WAVLoader

ModuleInfo "Version: 1.02"
ModuleInfo "Author: Simon Armstrong"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

Import BRL.AudioSample
Import BRL.EndianStream

Private

Function ReadTag$( stream:TStream )
	Local tag:Byte[4]
	If stream.ReadBytes( tag,4 )<>4 Return
	Return Chr(tag[0])+Chr(tag[1])+Chr(tag[2])+Chr(tag[3])
End Function

Public

Type TAudioSampleLoaderWAV Extends TAudioSampleLoader

	Method LoadAudioSample:TAudioSample( stream:TStream )
	
		stream=LittleEndianStream(stream)
		
		If ReadTag( stream )<>"RIFF" Return

		Local w_len=stream.ReadInt()-8

		If ReadTag( stream )<>"WAVE" Return
		If ReadTag( stream )<>"fmt " Return

		Local w_len2=stream.ReadInt()
		
		Local w_comp=stream.ReadShort()
		If w_comp<>1 Return
		
		Local w_chans=stream.ReadShort()
		Local w_hz=stream.ReadInt()
		Local w_bytespersec=stream.ReadInt()
		Local w_pad=stream.ReadShort()
		Local w_bits=stream.ReadShort()
		
		Local format=0
		Select True
		Case w_bits=8 And w_chans=1 
			format=SF_MONO8
		Case w_bits=8 And w_chans=2 
			format=SF_STEREO8
		Case w_bits=16 And w_chans=1
			format=SF_MONO16LE
		Case w_bits=16 And w_chans=2
			format=SF_STEREO16LE
		Default
			Return
		End Select

		If w_len2>16 stream.SkipBytes( w_len2-16 )
		
		While Not stream.Eof()

			Local tag$=Readtag( stream )
			If tag<>"data"
				Local sz=stream.ReadInt()
				stream.SkipBytes( sz )
				Continue
			EndIf

			Local w_sizebytes=stream.ReadInt()
			Local length=w_sizebytes/BytesPerSample[format],hertz=w_hz
			Local t:TAudioSample=TAudioSample.Create( length,hertz,format )

			stream.ReadBytes t.samples,w_sizebytes

			Return t
			
		Wend

	End Method

End Type

AddAudioSampleLoader New TAudioSampleLoaderWAV
