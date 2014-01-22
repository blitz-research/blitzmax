
Strict

Rem
bbdoc: Audio/Audio playback
End Rem
Module BRL.Audio

ModuleInfo "Version: 1.07"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.07 Release"
ModuleInfo "History: Added flags to LoadSound"
ModuleInfo "History: Driver now set to Null if SetAudioDriver fails"
ModuleInfo "History: 1.06 Release"
ModuleInfo "History: Changed default device to FreeAudio"
ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Added driver list and SetAudioDriver"

Import BRL.AudioSample

Private

Global _nullDriver:TAudioDriver=New TAudioDriver

Global _driver:TAudioDriver,_drivers:TAudioDriver

Function Driver:TAudioDriver()
	If _driver Return _driver
?Win32
	If SetAudioDriver( "DirectSound" ) Return _driver
?Not Win32
	If SetAudioDriver( "FreeAudio" ) Return _driver
?
	SetAudioDriver "Null"
	Return _driver
End Function

Function Shutdown()
	If Not _driver Return
	_driver.Shutdown
	_driver=Null
End Function

atexit_ Shutdown

Public

Const SOUND_LOOP=1
Const SOUND_HARDWARE=2

Rem
bbdoc: Audio sound type
End Rem
Type TSound

	Rem 
	bbdoc: Play the sound
	returns: An audio channel object
	about:
	Starts a sound playing through an audio channel.
	If no channel is specified, #Play automatically allocates a channel for you.
	End Rem
	Method Play:TChannel( alloced_channel:TChannel=Null )
		Return New TChannel
	End Method
	
	Rem 
	bbdoc: Cue the sound for playback
	returns: An audio channel object
	about:
	Prepares an audio channel for playback of a sound. 
	To actually start the sound, you must use the channel's #SetPaused method.
	If no channel is specified, #Cue automatically allocates a channel for you.

	#Cue allows you to setup various audio channel states such as volume, pan, depth and rate before a sound
	actually starts playing.
	End Rem
	Method Cue:TChannel( alloced_channel:TChannel=Null )
		Return New TChannel
	End Method
	
	Rem
	bbdoc: Load sound
	returns: A sound object
	about:
	@url can be either a string, a stream or an audio sample object.
	The returned sound object can be played using #Play or #Cue.
	End Rem
	Function Load:TSound( url:Object,loop_flag )
		Local sample:TAudioSample
		sample=TAudioSample( url )
		If Not sample sample=LoadAudioSample( url )
		If sample Return Driver().CreateSound( sample,loop_flag )
	End Function

End Type

Rem
bbdoc: Audio channel Type
End Rem
Type TChannel
	Rem
	bbdoc: Stop audio channel playback
	about:
	Shuts down the audio channel. Further commands on this audio channel will have no effect.
	End Rem
	Method Stop()
	End Method
	Rem
	bbdoc: Pause or unpause audio channel playback
	about:
	If @paused is True, the audio channel is paused. Otherwise, the audio channel is unpaused.
	End Rem
	Method SetPaused( paused )
	End Method
	Rem
	bbdoc: Set audio channel volume
	about:
	@volume should be in the range 0 (silence) to 1 (full volume).
	End Rem
	Method SetVolume( volume# )
	End Method
	Rem
	bbdoc: Set audio channel stereo pan
	about:
	@pan should be in the range -1 (full left) to 1 (full right).
	End Rem
	Method SetPan( pan# ) 
	End Method
	Rem
	bbdoc: Set audio channel depth
	about: 
	@depth should be in the range -1 (back) to 1 (front).
	End Rem
	Method SetDepth( depth# )
	End Method
	Rem
	bbdoc: Set audio channel playback rate
	about:
	@rate is a multiplier used to modify the audio channel's frequency.
	For example, a rate of .5 will cause the audio channel
	to play at half speed (ie: an octave down) while a rate of 2 will
	cause the audio channel to play at double speed (ie: an octave up).
	End Rem
	Method SetRate( rate# )
	End Method
	Rem
	bbdoc: Determine whether audio channel is playing
	returns: True if @channel is currently playing
	about:
	#Playing will return False if the audio channel is either paused, or has been stopped
	using #Stop.
	End Rem
	Method Playing()
	End Method

End Type

Type TAudioDriver

	Method New()
		_succ=_drivers
		_drivers=Self
	End Method
	
	Method Name$()
		Return "Null"
	End Method
	
	Method Startup()
		Return True
	End Method
	
	Method Shutdown()
	End Method

	Method CreateSound:TSound( sample:TAudioSample,loop_flag )
		Return New TSound
	End Method
	
	Method AllocChannel:TChannel() 
		Return New TChannel
	End Method

	Method LoadSound:TSound( url:Object, flags:Int = 0)
		Return TSound.Load(url, flags)
	End Method
	
	Field _succ:TAudioDriver

End Type

Rem
bbdoc: Load a sound
returns: A sound object
about:
@url can be either a string, a stream or a #TAudioSample object.
The returned sound can be played using #PlaySound or #CueSound.

The @flags parameter can be any combination of:

[ @{Flag value} | @Effect
* SOUND_LOOP | The sound should loop when played back.
* SOUND_HARDWARE | The sound should be placed in onboard soundcard memory if possible.
]

To combine flags, use the binary 'or' operator: '|'.
End Rem
Function LoadSound:TSound( url:Object,flags=0 )
	Return Driver().LoadSound( url,flags )
End Function

Rem
bbdoc: Play a sound
returns: An audio channel object
about:
#PlaySound starts a sound playing through an audio channel.
If no @channel is specified, #PlaySound automatically allocates a channel for you.
end rem
Function PlaySound:TChannel( sound:TSound,channel:TChannel=Null )
	Return sound.Play( channel )
End Function

Rem
bbdoc: Cue a sound
returns: An audio channel object
about:
Prepares a sound for playback through an audio channel. 
To actually start the sound, you must use #ResumeChannel.
If no @channel is specified, #CueSound automatically allocates a channel for you.

#CueSound allows you to setup various audio channel states such as volume, pan, depth 
and rate before a sound actually starts playing.
End Rem
Function CueSound:TChannel( sound:TSound,channel:TChannel=Null )
	Return sound.Cue( channel )
End Function

Rem
bbdoc: Allocate audio channel
returns: An audio channel object
about: 
Allocates an audio channel for use with #PlaySound and #CueSound.
Once you are finished with an audio channel, you should use #StopChannel.
end rem
Function AllocChannel:TChannel()
	Return Driver().AllocChannel()
End Function

Rem
bbdoc: Stop an audio channel
about:
Shuts down an audio channel. Further commands using this channel will have no effect.
end rem
Function StopChannel( channel:TChannel )
	channel.Stop
End Function

Rem
bbdoc: Determine whether an audio channel is playing
returns: #True if @channel is currently playing
about:
#ChannelPlaying will return #False if either the channel has been paused using #PauseChannel,
or stopped using #StopChannel.
end rem
Function ChannelPlaying( channel:TChannel )
	Return channel.Playing()
End Function

Rem
bbdoc: Set playback volume of an audio channel
about:
@volume should be in the range 0 (silent) to 1 (full volume)
end rem
Function SetChannelVolume( channel:TChannel,volume# )
	channel.SetVolume volume
End Function

Rem
bbdoc: Set stereo balance of an audio channel
about: 
@pan should be in the range -1 (left) to 1 (right)
end rem
Function SetChannelPan( channel:TChannel,pan# )
	channel.SetPan pan
End Function

Rem
bbdoc: Set surround sound depth of an audio channel
about: 
@depth should be in the range -1 (back) to 1 (front)
end rem
Function SetChannelDepth( channel:TChannel,depth# )
	channel.SetDepth depth
End Function

Rem
bbdoc: Set playback rate of an audio channel
about:
@rate is a multiplier used to modify the audio channel's frequency.
For example, a rate of .5 will cause the audio channel
to play at half speed (ie: an octave down) while a rate of 2 will
cause the audio channel to play at double speed (ie: an octave up).
end rem
Function SetChannelRate( channel:TChannel,rate# )
	channel.SetRate rate
End Function

Rem
bbdoc: Pause audio channel playback
about:
Pauses audio channel playback.
end rem
Function PauseChannel( channel:TChannel )
	channel.SetPaused True
End Function

Rem
bbdoc: Resume audio channel playback
about:
Resumes audio channel playback after it has been paused by #CueSound or #PauseChannel.
end rem
Function ResumeChannel( channel:TChannel )
	channel.SetPaused False
End Function

Rem
bbdoc: Get audio drivers
about:
Returns an array of strings, where each string describes an audio driver.
End Rem
Function AudioDrivers$[]()
	Local devs$[100],n
	Local t:TAudioDriver=_drivers
	While t And n<100
		devs[n]=t.Name()
		n:+1
		t=t._succ
	Wend
	Return devs[..n]
End Function

Rem
bbdoc: Determine if an audio driver exists
about:
Returns True if the audio drvier specified by @driver exists.
End Rem
Function AudioDriverExists( name$ )
	name=name.ToLower()
	Local t:TAudioDriver=_drivers
	While t
		If t.Name().ToLower()=name Return True
		t=t._succ
	Wend
End Function

Rem
bbdoc: Set current audio driver
about:
Returns true if the audio driver was successfully set.
End Rem
Function SetAudioDriver( name$ )
	name=name.ToLower()
	Shutdown
	_driver=_nullDriver
	Local t:TAudioDriver=_drivers
	While t
		If t.Name().ToLower()=name
			If t.Startup()
				_driver=t
				Return True
			EndIf
			Return False
		EndIf
		t=t._succ
	Wend
End Function
