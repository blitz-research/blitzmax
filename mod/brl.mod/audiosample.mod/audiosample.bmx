
Strict

Rem
bbdoc: Audio/Audio samples
End Rem
Module BRL.AudioSample

ModuleInfo "Version: 1.04"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.04 Release"
ModuleInfo "History: ChannelsPerSample array added"

Import BRL.Stream

Import "sample.bmx"

Rem
bbdoc: Audio sample type
end rem
Type TAudioSample

	Rem
	bbdoc: Byte pointer to sample data
	end rem
	Field samples:Byte Ptr
	
	Rem
	bbdoc: Length, in samples, of the sample data
	end rem
	Field length
	
	Rem
	bbdoc: Sample rate
	end rem
	Field hertz
	
	Rem
	bbdoc: Sample format
	end rem
	Field format
	
	Field capacity

	Method Delete()
		If capacity>=0 MemFree samples
	End Method

	Rem
	bbdoc: Copy audio sample
	returns: A new audio sample object
	end rem
	Method Copy:TAudioSample()
		Local t:TAudioSample=Create( length,hertz,format )
		CopySamples samples,t.samples,format,length
		Return t
	End Method

	Rem
	bbdoc: Convert audio sample
	returns: A new audio sample object in the specified format
	end rem
	Method Convert:TAudioSample( to_format )
		Local t:TAudioSample=Create( length,hertz,to_format )
		ConvertSamples samples,format,t.samples,to_format,length
		Return t
	End Method

	Rem
	bbdoc: Create an audio sample
	returns: A new audio sample object
	end rem
	Function Create:TAudioSample( length,hertz,format )
		Local t:TAudioSample=New TAudioSample
		Local capacity=length*BytesPerSample[format]
		t.samples=MemAlloc( capacity )
		t.length=length
		t.hertz=hertz
		t.format=format
		t.capacity=capacity
		Return t
	End Function

	Rem
	bbdoc: Create a static audio sample
	returns: A new audio sample object that references an existing block of memory
	end rem
	Function CreateStatic:TAudioSample( samples:Byte Ptr,length,hertz,format )
		Local t:TAudioSample=New TAudioSample
		t.samples=samples
		t.length=length
		t.hertz=hertz
		t.format=format
		t.capacity=-1
		Return t
	End Function

End Type

Private
Global sample_loaders:TAudioSampleLoader
Public

'deprecated
Function AddAudioSampleLoader( loader:TAudioSampleLoader )
'	If( loader._succ ) Return
'	loader._succ=sample_loaders
'	sample_loaders=loader
End Function

Rem
bbdoc: Audio sample loader type
about: To create your own audio sample loaders, you should extend this type and
provide a @LoadAudioSample method. To add your audio sample loader to the system,
simply create an instance of it using @New.
end rem
Type TAudioSampleLoader
	Field _succ:TAudioSampleLoader
	
	Method New()
		_succ=sample_loaders
		sample_loaders=Self
	End Method
	
	Rem
	bbdoc: Load an audio sample
	returns: A new audio sample object, or Null if sample could not be loaded
	about: Extending types must implement this method.
	end rem
	Method LoadAudioSample:TAudioSample( stream:TStream ) Abstract

End Type

Rem
bbdoc: Create an audio sample
returns: An audio sample object
about:
@length is the number of samples to allocate for the sample. @hertz is the frequency in samples per second (hz)
the audio sample will be played. @format should be one of:

[ @Format | @Description

* &SF_MONO8 | Mono unsigned 8 bit

* &SF_MONO16LE | Mono signed 16 bit little endian

* &SF_MONO16BE | Mono signed 16 bit big endian

* &SF_STEREO8 | Stereo unsigned 8 bit

* &SF_STEREO16LE | Stereo signed 16 bit little endian

* &SF_STEREO16BE | Stereo signed 16 bit big endian
]
End Rem
Function CreateAudioSample:TAudioSample( length,hertz,format )
	Return TAudioSample.Create( length,hertz,format )
End Function

Rem
bbdoc: Create an audio sample with existing data
returns: An audio sample object that references an existing block of memory
about:
The memory referenced by a static audio sample is not released when the audio sample is 
deleted.

See #CreateAudioSample for possile @format values.
End Rem
Function CreateStaticAudioSample:TAudioSample( samples:Byte Ptr,length,hertz,format )
	Return TAudioSample.CreateStatic( samples,length,hertz,format )
End Function

Rem
bbdoc: Load an audio sample
returns: An audio sample object
end rem
Function LoadAudioSample:TAudioSample( url:Object )

	Local stream:TStream=ReadStream( url )
	If Not stream Return

	Local pos=stream.Pos()
	If pos=-1 RuntimeError "Stream is not seekable"

	Local sample:TAudioSample
	Local loader:TAudioSampleLoader=sample_loaders
	
	While loader
		stream.Seek pos
		Try
			sample=loader.LoadAudioSample( stream )
		Catch ex:TStreamException
		End Try
		If sample Exit
		loader=loader._succ
	Wend
	stream.Close
	Return sample
End Function
