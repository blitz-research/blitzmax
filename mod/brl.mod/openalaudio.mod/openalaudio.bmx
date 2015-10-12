
Strict

Rem
bbdoc: Audio/OpenAL audio 
about:
The OpenAL audio module provide OpenAL drivers for use with the #audio module.
End Rem
Module BRL.OpenALAudio

ModuleInfo "Version: 1.05"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Fixed default channel volume,pan,rate"
ModuleInfo "History: Fixed behaviour of channel going out of scope"
ModuleInfo "History: 1.04 Release"
ModuleInfo "History: Fixed channel playing to return true if active (playing or paused)"
ModuleInfo "History: 1.03 Release"
ModuleInfo "History: Added (synced) alDeleteBuffers"
ModuleInfo "History: 1.02 Release"
ModuleInfo "History: Added EnableOpenALAudio"
ModuleInfo "History: 1.01 Initial Release"

Import BRL.Math
Import BRL.Audio
Import Pub.OpenAL

Private

Const CLOG=False

'list of all non-static sources
Global _sources:TOpenALSource

Function CheckAL()
	Local err$
	Select alGetError()
	Case AL_NO_ERROR
		Return True
	Case AL_INVALID_NAME
		err="INVALID_NAME"
	Case AL_INVALID_ENUM
		err="INVALID_ENUM"
	Case AL_INVALID_VALUE
		err="INVALID_VALUE"
	Case AL_INVALID_OPERATION
		err="INVALID_OPERATION"
	Case AL_OUT_OF_MEMORY
		err="OUT_OF_MEMORY"
	Default
		err="?????"
	End Select
	If CLOG WriteStdout "OpenAL Error: "+err+"~n"
	Return False
End Function

Function EnumOpenALDevices$[]()
	Local p:Byte Ptr=alcGetString( 0,ALC_DEVICE_SPECIFIER )
	If Not p Return
	Local devs$[100],n
	While p[0] And n<100
		Local sz
		Repeat
			sz:+1
		Until Not p[sz]
		devs[n]=String.FromBytes( p,sz )
		n:+1
		p:+sz+1
	Wend
	Return devs[..n]
End Function

Public

Type TOpenALSource

	Field _succ:TOpenALSource,_id,_seq,_sound:TOpenALSound,_avail
	
	Method Playing()
		Local st
		alGetSourcei _id,AL_SOURCE_STATE,Varptr st
		Return st=AL_PLAYING
	End Method
			
	Method Paused()
		Local st
		alGetSourcei _id,AL_SOURCE_STATE,Varptr st
		Return st=AL_PAUSED Or st=AL_INITIAL
	End Method
	
	Method Active()	
		Local st
		alGetSourcei _id,AL_SOURCE_STATE,Varptr st
		Return st=AL_PLAYING Or st=AL_PAUSED Or st=AL_INITIAL
	End Method
	
	Method LogState()
		Local st
		alGetSourcei _id,AL_SOURCE_STATE,Varptr st
		Select st
		Case AL_PAUSED WriteStdout "AL_PAUSED~n"
		Case AL_INITIAL WriteStdout "AL_INITIAL~n"
		Case AL_STOPPED WriteStdout "AL_STOPPED~n"
		Case AL_PLAYING WriteStdout "AL_PLAYING~n"
		Default WriteStdout "AL_DUNNO, st="+st+"~n"
		End Select
	End Method
	
End Type

Type TOpenALSound Extends TSound

	Method Delete()
		alDeleteBuffers 1,Varptr _buffer
		CheckAL
		If CLOG WriteStdout "Deleted OpenAL buffer "+_buffer+"~n"
	End Method

	Method Play:TOpenALChannel( alloced_channel:TChannel=Null )
		Local t:TOpenALChannel=Cue( alloced_channel )
		t.SetPaused False
		Return t
	End Method

	Method Cue:TOpenALChannel( alloced_channel:TChannel=Null )
		Local t:TOpenALChannel=TOpenALChannel( alloced_channel )
		If t
			Assert t._static
		Else
			t=TOpenALChannel.Create( False )
		EndIf
		t.Cue Self
		Return t
	End Method

	Function Create:TOpenALSound( sample:TAudioSample,flags )
		Local alfmt
		Select sample.format
		Case SF_MONO8
			alfmt=AL_FORMAT_MONO8
		Case SF_MONO16LE
			alfmt=AL_FORMAT_MONO16
?BigEndian
			sample=sample.Convert( SF_MONO16BE )
?
		Case SF_MONO16BE
			alfmt=AL_FORMAT_MONO16
?LittleEndian
			sample=sample.Convert( SF_MONO16LE )
?
		Case SF_STEREO8
			alfmt=AL_FORMAT_STEREO8
		Case SF_STEREO16LE
			alfmt=AL_FORMAT_STEREO16
?BigEndian
			sample=sample.Convert( SF_STEREO16BE )
?
		Case SF_STEREO16BE
			alfmt=AL_FORMAT_STEREO16
?LittleEndian
			sample=sample.Convert( SF_STEREO16LE )
?
		End Select
		
		Local buffer=-1
		alGenBuffers 1,Varptr buffer
		CheckAL
		
		If CLOG WriteStdout "Generated OpenAL buffer "+buffer+"~n"
		
		alBufferData buffer,alfmt,sample.samples,sample.length*BytesPerSample[sample.format],sample.hertz
		CheckAL
		
		Local t:TOpenALSound=New TOpenALSound
		t._buffer=buffer
		If (flags & 1) t._loop=1
		Return t
	End Function

	Field _buffer,_loop

End Type

Type TOpenALChannel Extends TChannel

	Method Delete()
		If _seq<>_source._seq Return
		
		If _static	'LEAKED!
			Stop	'Just in case...		
			Return
		EndIf
		
		If Not _source.Playing()
			alSourceStop _source._id
			alSourcei _source._id,AL_BUFFER,0
			_source._sound=Null
		EndIf

	End Method

	Method Stop()
		If _seq<>_source._seq Return
	
		_source._seq:+1

		alSourceStop _source._id
		alSourcei _source._id,AL_BUFFER,0
		_source._sound=Null
		
		If _static
			_source._avail=True
			_source._succ=_sources
			_sources=_source
		EndIf
	End Method
	
	Method SetPaused( paused )
		If _seq<>_source._seq Return

		If paused
			alSourcePause _source._id
		Else
			If _source.Paused() alSourcePlay _source._id
		EndIf
	End Method
	
	Method SetVolume( volume# )
		If _seq<>_source._seq Return

		alSourcef _source._id,AL_GAIN,volume
	End Method
	
	Method SetPan( pan# )
		If _seq<>_source._seq Return

		pan:*90
		alSource3f _source._id,AL_POSITION,Sin(pan),0,-Cos(pan)
	End Method
	
	Method SetDepth( depth# )
		If _seq<>_source._seq Return
	End Method
	
	Method SetRate( rate# )
		If _seq<>_source._seq Return

		alSourcef _source._id,AL_PITCH,rate
	End Method
	
	Method Playing()
		If _seq<>_source._seq Return

		Return _source.Playing()
	End Method

	Method Cue( sound:TOpenALSound )	
		If _seq<>_source._seq Return

		_source._sound=sound
		alSourceRewind _source._id
		alSourcei _source._id,AL_LOOPING,sound._loop
		alSourcei _source._id,AL_BUFFER,sound._buffer
	End Method
	
	Function Create:TOpenALChannel( static )
	
		Local source:TOpenALSource=_sources,pred:TOpenALSource
		While source
			If source._avail Or Not source.Active()
				source._seq:+1
				If pred pred._succ=source._succ Else _sources=source._succ
				If CLOG WriteStdout "Recycling OpenAL source "+source._id+"~n"
				If CLOG source.LogState
				alSourceRewind source._id	'return to FA_INITIAL state
				If CLOG source.LogState
				alSourcei source._id,AL_BUFFER,0
				source._sound=Null
				Exit
			EndIf
			pred=source
			source=source._succ
		Wend
		
		If Not source
			source=New TOpenALSource

			alGenSources 1,Varptr source._id
			CheckAL

			If source._id
				If CLOG WriteStdout "Generated OpenAL source "+source._id+"~n"
			Else
				If CLOG WriteStdout "Failed to generate OpenAL source~n"
			EndIf
		EndIf
		
		Local t:TOpenALChannel=New TOpenALChannel
		t._source=source
		t._seq=source._seq
		t._static=static
		If source._id
			alSourcei source._id,AL_SOURCE_RELATIVE,True
			alSourcef source._id,AL_GAIN,1
			alSourcef source._id,AL_PITCH,1
			alSource3f source._id,AL_POSITION,0,0,1
			If Not static
				source._avail=False
				source._succ=_sources
				_sources=source
			EndIf
		Else
			t._seq:+1
		EndIf
		Return t
	End Function
	
	Field _source:TOpenALSource,_seq,_static
	
End Type

Type TOpenALAudioDriver Extends TAudioDriver

	Method Name$()
		Return _name
	End Method
	
	Method Startup()
		_device=0
		If _devname
			_device=alcOpenDevice( _devname )
		Else If OpenALInstalled()
			_device=alcOpenDevice( Null )
			If Not _device
				_device=alcOpenDevice( "Generic Hardware" )
				If Not _device
					_device=alcOpenDevice( "Generic Software" )
				EndIf
			EndIf
		EndIf
		If _device
			_context=alcCreateContext( _device,Null )
			If _context
				alcMakeContextCurrent _context
				alDistanceModel AL_NONE
				Return True
			EndIf
			alcCloseDevice( _device )
		EndIf
	End Method
	
	Method Shutdown()
		_sources=Null
		alcDestroyContext _context
		alcCloseDevice _device
	End Method

	Method CreateSound:TOpenALSound( sample:TAudioSample,flags )
		Return TOpenALSound.Create( sample,flags )
	End Method
	
	Method AllocChannel:TOpenALChannel()
		Return TOpenALChannel.Create( True )
	End Method
	
	Function Create:TOpenALAudioDriver( name$,devname$ )
		Local t:TOpenALAudioDriver=New TOpenALAudioDriver
		t._name=name
		t._devname=devname
		Return t
	End Function
	
	Field _name$,_devname$,_device,_context

End Type

If OpenALInstalled() TOpenALAudioDriver.Create "OpenAL",""

Rem
bbdoc: Enable OpenAL Audio
returns: True if successful
about:
After successfully executing this command, OpenAL audio drivers will be added
to the array of drivers returned by #AudioDrivers.
End Rem
Function EnableOpenALAudio()
	Global done,okay
	If done Return okay
	If OpenALInstalled() And alcGetString
		For Local devname$=EachIn EnumOpenALDevices()
			TOpenALAudioDriver.Create( "OpenAL "+devname,devname )
		Next
		TOpenALAudioDriver.Create "OpenAL Default",String.FromCString( alcGetString( 0,ALC_DEFAULT_DEVICE_SPECIFIER ) )
		okay=True
	EndIf
	done=True
	Return okay
End Function
