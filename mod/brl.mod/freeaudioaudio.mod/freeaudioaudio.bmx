
Strict
Rem
bbdoc: Audio/FreeAudio audio
about:
The FreeAudio audio module provides FreeAudio drivers for use with the #audio module.
End Rem
Module BRL.FreeAudioAudio

ModuleInfo "Version: 1.13"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.13 Release"
ModuleInfo "History: Fixed bug in FreeChannel Playing()"
ModuleInfo "History: 1.12 Release"
ModuleInfo "History: Added call to fa_FreeChannel to TFreeAudioChannel destructor"
ModuleInfo "History: 1.11 Release"
ModuleInfo "History: Nudge"
ModuleInfo "History: 1.10 Release"
ModuleInfo "History: Bumped"
ModuleInfo "History: 1.08 Release"
ModuleInfo "History: Added src sample reference to TFreeAudioSound"
ModuleInfo "History: Channel playing now returns sample playback position"
ModuleInfo "History: 1.07 Release"
ModuleInfo "History: Added DirectSound driver"
ModuleInfo "History: 1.06 Release"
ModuleInfo "History: Added Method TFreeAudioChannel.Position"
ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Mono and 8 bit sample support added"

Import BRL.Audio
Import Pub.FreeAudio
Import Pub.DirectX

Private

Const CLOG=False

Public

Type TFreeAudioSound Extends TSound

	Field fa_sound
	
	Method Delete()
		fa_FreeSound fa_sound
		If CLOG WriteStdout "Deleted FreeAudio sound "+fa_sound+"~n"
	End Method

	Method Play:TFreeAudioChannel( alloced_channel:TChannel )
		Local channel:TFreeAudioChannel,fa_channel
		If alloced_channel
			channel=TFreeAudioChannel( alloced_channel )
			If Not channel Return
			fa_channel=channel.fa_channel
		EndIf		
		fa_channel=fa_PlaySound(fa_sound,False,fa_channel)
		If Not fa_channel Return
		If channel And channel.fa_channel=fa_channel Return channel
		Return TFreeAudioChannel.CreateWithChannel( fa_channel )
	End Method
	
	Method Cue:TFreeAudioChannel( alloced_channel:TChannel )
		Local channel:TFreeAudioChannel,fa_channel
		If alloced_channel
			channel=TFreeAudioChannel( alloced_channel )
			If Not channel Return
			fa_channel=channel.fa_channel
		EndIf
		fa_channel=fa_PlaySound( fa_sound,True,fa_channel )
		If Not fa_channel Return
		If channel And channel.fa_channel=fa_channel Return channel
		Return TFreeAudioChannel.CreateWithChannel( fa_channel )
	End Method

	Function CreateWithSound:TFreeAudioSound( fa_sound,src:TAudioSample )
		Local t:TFreeAudioSound=New TFreeAudioSound
		t.fa_sound=fa_sound
'		t.src=src
		Return t
	End Function
	
End Type

Type TFreeAudioChannel Extends TChannel

	Field fa_channel
	
	Method Delete()
		If fa_channel fa_FreeChannel fa_channel
	End Method

	Method Stop()
		fa_StopChannel fa_channel
		fa_channel=0
	End Method
	
	Method SetPaused( paused )
		fa_SetChannelPaused fa_channel,paused
	End Method
	
	Method SetVolume( volume# )
		fa_SetChannelVolume fa_channel,volume
	End Method
	
	Method SetPan( pan# )
		fa_SetChannelPan fa_channel,pan
	End Method
	
	Method SetDepth( depth# )
		fa_SetChannelDepth fa_channel,depth
	End Method
	
	Method SetRate( rate# )
		fa_SetChannelRate fa_channel,rate
	End Method
	
	Method Playing()
		Local status=fa_ChannelStatus( fa_channel ) 
		If status=FA_CHANNELSTATUS_FREE Return False
		If status&FA_CHANNELSTATUS_STOPPED Return False
		If status&FA_CHANNELSTATUS_PAUSED Return False
		Return True
	End Method
	
	Method Position()
		Return fa_ChannelPosition( fa_channel )
	End Method
	
	Function CreateWithChannel:TFreeAudioChannel( fa_channel )
		Local t:TFreeAudioChannel=New TFreeAudioChannel
		t.fa_channel=fa_channel
		Return t
	End Function
	
End Type

Type TFreeAudioAudioDriver Extends TAudioDriver

	Method Name$()
		Return _name
	End Method
	
	Method Startup()
		If _mode<>-1 Return fa_Init( _mode )<>-1
		If fa_Init( 0 )<>-1 Return True
?Win32
		Return fa_Init( 1 )<>-1
?
	End Method
	
	Method Shutdown()
		fa_Close
	End Method

	Method CreateSound:TFreeAudioSound( sample:TAudioSample,flags )
		Local channels,bits

		Select sample.format
?BigEndian
		Case SF_MONO16LE
			sample=sample.Convert(SF_MONO16BE)
		Case SF_STEREO16LE
			sample=sample.Convert(SF_STEREO16BE)
?LittleEndian
		Case SF_MONO16BE
			sample=sample.Convert(SF_MONO16LE)
		Case SF_STEREO16BE
			sample=sample.Convert(SF_STEREO16LE)
?
		End Select
		Local loop_flag
		If (flags & 1) loop_flag=-1
		channels=ChannelsPerSample[sample.format]
		If Not channels Return
		bits=8*BytesPerSample[sample.format]/channels
		Local fa_sound=fa_CreateSound( sample.length,bits,channels,sample.hertz,sample.samples,loop_flag )
		If CLOG WriteStdout "Generated FreeAudio sound "+fa_sound+"~n"
		Return TFreeAudioSound.CreateWithSound( fa_sound,sample )
	End Method
	
	Method AllocChannel:TFreeAudioChannel()
		Local fa_channel=fa_AllocChannel()
		If fa_channel Return TFreeAudioChannel.CreateWithChannel( fa_channel )
	End Method
		
	Function Create:TFreeAudioAudioDriver( name$,mode )
		Local t:TFreeAudioAudioDriver=New TFreeAudioAudioDriver
		t._name=name
		t._mode=mode
		Return t
	End Function
	
	Field _name$,_mode
	
End Type

?Win32
If DirectSoundCreate TFreeAudioAudioDriver.Create "FreeAudio DirectSound",1
TFreeAudioAudioDriver.Create "FreeAudio Multimedia",0
?MacOS
TFreeAudioAudioDriver.Create "FreeAudio CoreAudio",0
?Linux
TFreeAudioAudioDriver.Create "FreeAudio OpenSound System",0
'TFreeAudioAudioDriver.Create "FreeAudio ALSA System",1
?
TFreeAudioAudioDriver.Create "FreeAudio",-1

