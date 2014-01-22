
Strict

Rem
bbdoc: Audio/DirectSound audio
about:
The DirectSound audio module provides DirectSound drivers for use with the #audio module.
End Rem
Module BRL.DirectSoundAudio

ModuleInfo "Version: 1.05"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Added hardware caps checking"
ModuleInfo "History: 1.04 Release"
ModuleInfo "History: First batch of fixes!"
ModuleInfo "History: 1.02 Release"
ModuleInfo "History: Added volume,pan,rate states to channel"
ModuleInfo "History: 1.01 Initial Release"

?Win32

Import BRL.Math
Import BRL.Audio
Import Pub.DirectX

Private

Const CLOG=False

Global _driver:TDirectSoundAudioDriver

Type TBuf
	Field _succ:TBuf
	Field _buffer:IDirectSoundBuffer,_seq,_paused
	
	Method Playing()
		If _paused Return False
		Local status
		DSASS _buffer.GetStatus( status )
		Return (status & DSBSTATUS_PLAYING)<>0
	End Method
	
	Method Active()
		If _paused Return True
		Local status
		DSASS _buffer.GetStatus( status )
		Return (status & DSBSTATUS_PLAYING)<>0
	End Method

End Type

Function DSASS( n,t$="DirectSound" )
	If n>=0 Return
	Throw t+" failed ("+(n & 65535)+")"
End Function

Public

Type TDirectSoundSound Extends TSound

	Method Delete()
		If _seq=_driver._seq
			_driver.AddLonely _bufs
		EndIf
	End Method

	Method Play:TDirectSoundChannel( alloced_channel:TChannel=Null )
		Local t:TDirectSoundChannel=Cue( alloced_channel )
		t.SetPaused False
		Return t
	End Method

	Method Cue:TDirectSoundChannel( alloced_channel:TChannel=Null )
		Local t:TDirectSoundChannel=TDirectSoundChannel( alloced_channel )
		If t
			Assert t._static
		Else
			t=TDirectSoundChannel.Create( False )
		EndIf
		t.Cue Self
		Return t
	End Method
	
	Function Create:TDirectSoundSound( sample:TAudioSample,flags )
		_driver.FlushLonely
		
		Select sample.format
		Case SF_MONO16BE
			sample=sample.Convert( SF_MONO16LE )
		Case SF_STEREO16BE
			sample=sample.Convert( SF_STEREO16LE )
		End Select

		GCSuspend

		Local length=sample.length
		Local hertz=sample.hertz
		Local format=sample.format
		Local chans=ChannelsPerSample[format]
		Local bps=BytesPerSample[format]/chans
		Local size=length*chans*bps
		
		Local fmt:WAVEFORMATEX=New WAVEFORMATEX	
		fmt.wFormatTag=1
		fmt.nChannels=chans
		fmt.nSamplesPerSec=hertz
		fmt.wBitsPerSample=bps*8
		fmt.nBlockAlign=fmt.wBitsPerSample/8*fmt.nChannels
		fmt.nAvgBytesPerSec=fmt.nSamplesPerSec*fmt.nBlockAlign
		
		Local desc:DSBUFFERDESC=New DSBUFFERDESC
		desc.dwSize=SizeOf(DSBUFFERDESC)
		desc.dwFlags=DSBCAPS_GLOBALFOCUS|DSBCAPS_STATIC|DSBCAPS_CTRLPAN|DSBCAPS_CTRLVOLUME|DSBCAPS_CTRLFREQUENCY
		If _driver._mode=1 Or (flags & 2)<>2 desc.dwFlags:|DSBCAPS_LOCSOFTWARE
		desc.dwBufferBytes=size
		desc.lpwfxFormat=fmt
		
		Local buf:IDirectSoundBuffer
		DSASS _driver._dsound.CreateSoundBuffer( desc,buf,Null ),"CreateSoundBuffer"
		If CLOG WriteStdout "Created DirectSound buffer~n"
		
		Local ptr1:Byte Ptr,bytes1,ptr2:Byte Ptr,bytes2
		DSASS buf.Lock( 0,size,ptr1,bytes1,ptr2,bytes2,0 ),"Lock SoundBuffer"
		MemCopy ptr1,sample.samples,size
		DSASS buf.Unlock( ptr1,bytes1,ptr2,bytes2 ),"Unlock SoundBuffer"

		Local t:TDirectSoundSound=New TDirectSoundSound
		t._seq=_driver._seq
		t._buffer=buf
		t._hertz=hertz
		t._loop=flags & 1
		t._bufs=New TBuf
		t._bufs._buffer=buf
		
		GCResume

		Return t
	End Function
	
	Field _seq,_buffer:IDirectSoundBuffer,_hertz,_loop,_bufs:TBuf
	
End Type

Type TDirectSoundChannel Extends TChannel

	Method Delete()
		If Not _buf Or _seq<>_buf._seq Return
		If _buf._paused Stop
	End Method

	Method Stop()
		If Not _buf Or _seq<>_buf._seq Return
		_buf._buffer.Stop
		_buf._paused=False
		_buf._seq:+1
		_buf=Null
	End Method
	
	Method SetPaused( paused )
		If Not _buf Or _seq<>_buf._seq Return
		If Not _buf.Active()
			_buf._seq:+1
			_buf=Null
			Return
		EndIf
		If paused 
			_buf._buffer.Stop
		Else
			_buf._buffer.Play 0,0,_playFlags
		EndIf
		_buf._paused=paused
	End Method
	
	Method SetVolume( volume# )
		volume=Min(Max(volume,0),1)^.1
		_volume=volume
		If Not _buf Or _seq<>_buf._seq Return
		_buf._buffer.SetVolume (1-volume)*-10000
	End Method
	
	Method SetPan( pan# )
		pan=Min(Max(pan,-1),1)
		pan=Sgn(pan) * (1-(1-Abs(pan))^.1)		
		_pan=pan
		If Not _buf Or _seq<>_buf._seq Return
		_buf._buffer.SetPan pan*10000
	End Method
	
	Method SetDepth( depth# )
		If Not _buf Or _seq<>_buf._seq Return
	End Method
	
	Method SetRate( rate# )
		_rate=rate
		If Not _buf Or _seq<>_buf._seq Return
		_buf._buffer.SetFrequency _hertz * rate
	End Method
	
	Method Playing()
		If Not _buf Or _seq<>_buf._seq Return
		Return _buf.Playing()
	End Method

	Method Cue( sound:TDirectSoundSound )
		Stop
		Local t:TBuf=sound._bufs
		While t
			If Not t.Active()
				t._seq:+1
				Exit
			EndIf
			t=t._succ
		Wend
		If Not t
			_driver.FlushLonely
			Local buf:IDirectSoundBuffer
			If _driver._dsound.DuplicateSoundBuffer( sound._buffer,buf )<0 Return False
			If CLOG WriteStdout "Duplicated DirectSound buffer~n"
			t=New TBuf
			t._buffer=buf
			t._succ=sound._bufs
			sound._bufs=t
		EndIf
		_sound=sound
		_buf=t
		_seq=_buf._seq
		_hertz=sound._hertz
		If sound._loop _playFlags=DSBPLAY_LOOPING Else _playFlags=0
		_buf._paused=True
		_buf._buffer.SetCurrentPosition 0
		_buf._buffer.SetVolume (1-_volume)*-10000
		_buf._buffer.SetPan _pan * 10000
		_buf._buffer.SetFrequency _hertz * _rate
		Return True
	End Method
	
	Function Create:TDirectSoundChannel( static )
		Local t:TDirectSoundChannel=New TDirectSoundChannel
		t._static=static
		Return t
	End Function

	Field _volume#=1,_pan#=0,_rate#=1,_static
	Field _sound:TSound,_buf:TBuf,_seq,_hertz,_playFlags
	
End Type

Type TDirectSoundAudioDriver Extends TAudioDriver

	Method Name$()
		Return _name
	End Method
	
	Method Startup()
		If DirectSoundCreate( Null,_dsound,Null )>=0
			If _dsound.SetCooperativeLevel( GetDesktopWindow(),DSSCL_PRIORITY )>=0
				Rem
				'Never seen this succeed!
				'Apparently a NOP on Win2K/XP/Vista, and
				'probably best not to mess with it on Win98 anyway.
				Global primBuf:IDirectSoundBuffer
				Local desc:DSBUFFERDESC=New DSBUFFERDESC
				desc.dwSize=SizeOf(DSBUFFERDESC)
				desc.dwFlags=DSBCAPS_PRIMARYBUFFER
				If _dsound.CreateSoundBuffer( desc,primBuf,Null )>=0
				 	Local fmt:WAVEFORMATEX=New WAVEFORMATEX
					fmt.wFormatTag=1
					fmt.nChannels=2
					fmt.wBitsPerSample=16
					fmt.nSamplesPerSec=44100
					fmt.nBlockAlign=fmt.wBitsPerSample/8*fmt.nChannels
					fmt.nAvgBytesPerSec=fmt.nSamplesPerSec*fmt.nBlockAlign
					primBuf.SetFormat fmt
					primBuf.Release_
 				EndIf
				End Rem
				_driver=Self
				Return True
			EndIf
			_dsound.Release_
		EndIf
	End Method
	
	Method Shutdown()
		_seq:+1
		_driver=Null
		_lonely=Null
		_dsound.Release_
	End Method

	Method CreateSound:TDirectSoundSound( sample:TAudioSample,flags )
		Return TDirectSoundSound.Create( sample,flags )
	End Method
	
	Method AllocChannel:TDirectSoundChannel()
		Return TDirectSoundChannel.Create( True )
	End Method
	
	Function Create:TDirectSoundAudioDriver( name$,mode )
		Local t:TDirectSoundAudioDriver=New TDirectSoundAudioDriver
		t._name=name
		t._mode=mode
		Return t
	End Function

	Method AddLonely( bufs:TBuf )
		Local t:TBuf=bufs
		While t._succ
			t=t._succ
		Wend
		t._succ=_lonely
		_lonely=bufs
	End Method
	
	Method FlushLonely()
		Local t:TBuf=_lonely,p:TBuf
		While t
			If t.Active()
				p=t
			Else
				t._buffer.Release_
				If CLOG WriteStdout "Released DirectSound buffer~n"
				If p p._succ=t._succ Else _lonely=t._succ
			EndIf
			t=t._succ
		Wend
	End Method

	Field _name$,_mode,_dsound:IDirectSound,_lonely:TBuf

	Global _seq
		
End Type

If DirectSoundCreate TDirectSoundAudioDriver.Create "DirectSound",0
