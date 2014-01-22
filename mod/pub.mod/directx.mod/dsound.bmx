
Strict

Import Pub.Win32

Const DIRECTSOUND_VERSION=$0700

Const DSSCL_NORMAL=$00000001
Const DSSCL_PRIORITY=$00000002
Const DSSCL_EXCLUSIVE=$00000003
Const DSSCL_WRITEPRIMARY=$00000004

Const DSCAPS_PRIMARYMONO=$00000001
Const DSCAPS_PRIMARYSTEREO=$00000002
Const DSCAPS_PRIMARY8BIT=$00000004
Const DSCAPS_PRIMARY16BIT=$00000008
Const DSCAPS_CONTINUOUSRATE=$00000010
Const DSCAPS_EMULDRIVER=$00000020
Const DSCAPS_CERTIFIED=$00000040
Const DSCAPS_SECONDARYMONO=$00000100
Const DSCAPS_SECONDARYSTEREO=$00000200
Const DSCAPS_SECONDARY8BIT=$00000400
Const DSCAPS_SECONDARY16BIT=$00000800

Const DSSPEAKER_HEADPHONE=$00000001
Const DSSPEAKER_MONO=$00000002
Const DSSPEAKER_QUAD=$00000003
Const DSSPEAKER_STEREO=$00000004
Const DSSPEAKER_SURROUND=$00000005
Const DSSPEAKER_5POINT1=$00000006
Const DSSPEAKER_GEOMETRY_MIN=$00000005
Const DSSPEAKER_GEOMETRY_NARROW=$0000000A
Const DSSPEAKER_GEOMETRY_WIDE=$00000014
Const DSSPEAKER_GEOMETRY_MAX=$000000B4

Const DSBCAPS_PRIMARYBUFFER=$00000001
Const DSBCAPS_STATIC=$00000002
Const DSBCAPS_LOCHARDWARE=$00000004
Const DSBCAPS_LOCSOFTWARE=$00000008
Const DSBCAPS_CTRL3D=$00000010
Const DSBCAPS_CTRLFREQUENCY=$00000020
Const DSBCAPS_CTRLPAN=$00000040
Const DSBCAPS_CTRLVOLUME=$00000080
Const DSBCAPS_CTRLPOSITIONNOTIFY=$00000100
Const DSBCAPS_STICKYFOCUS=$00004000
Const DSBCAPS_GLOBALFOCUS=$00008000
Const DSBCAPS_GETCURRENTPOSITION2=$00010000
Const DSBCAPS_MUTE3DATMAXDISTANCE=$00020000
Const DSBCAPS_LOCDEFER=$00040000

Const DSBPLAY_LOOPING=$00000001
Const DSBPLAY_LOCHARDWARE=$00000002
Const DSBPLAY_LOCSOFTWARE=$00000004
Const DSBPLAY_TERMINATEBY_TIME=$00000008
Const DSBPLAY_TERMINATEBY_DISTANCE=$000000010
Const DSBPLAY_TERMINATEBY_PRIORITY=$000000020

Const DSBSTATUS_PLAYING=$00000001
Const DSBSTATUS_BUFFERLOST=$00000002
Const DSBSTATUS_LOOPING=$00000004
Const DSBSTATUS_LOCHARDWARE=$00000008
Const DSBSTATUS_LOCSOFTWARE=$00000010
Const DSBSTATUS_TERMINATED=$00000020

Const DSBLOCK_FROMWRITECURSOR=$00000001
Const DSBLOCK_ENTIREBUFFER=$00000002

Type DSCAPS
	Field dwSize
	Field dwFlags
	Field dwMinSecondarySampleRate
	Field dwMaxSecondarySampleRate
	Field dwPrimaryBuffers
	Field dwMaxHwMixingAllBuffers
	Field dwMaxHwMixingStaticBuffers
	Field dwMaxHwMixingStreamingBuffers
	Field dwFreeHwMixingAllBuffers
	Field dwFreeHwMixingStaticBuffers
	Field dwFreeHwMixingStreamingBuffers
	Field dwMaxHw3DAllBuffers
	Field dwMaxHw3DStaticBuffers
	Field dwMaxHw3DStreamingBuffers
	Field dwFreeHw3DAllBuffers
	Field dwFreeHw3DStaticBuffers
	Field dwFreeHw3DStreamingBuffers
	Field dwTotalHwMemBytes
	Field dwFreeHwMemBytes
	Field dwMaxContigFreeHwMemBytes
	Field dwUnlockTransferRateHwBuffers
	Field dwPlayCpuOverheadSwBuffers
	Field dwReserved1
	Field dwReserved2
End Type

Type DSBCAPS
	Field dwSize
	Field dwFlags
	Field dwBufferBytes
	Field dwUnlockTransferRate
	Field dwPlayCpuOverhead
End Type

Type WAVEFORMATEX
	Field wFormatTag:Short
	Field nChannels:Short
	Field nSamplesPerSec
	Field nAvgBytesPerSec
	Field nBlockAlign:Short
	Field wBitsPerSample:Short
	Field cbSize:Short
End Type

Type DSBUFFERDESC
	Field dwSize
	Field dwFlags
	Field dwBufferBytes
	Field dwReserved
	Field lpwfxFormat:Byte Ptr
	Field guid3DAlgorithm0
	Field guid3DAlgorithm1
	Field guid3DAlgorithm2
	Field guid3DAlgorithm3
End Type

Extern "win32"

Type IDirectSound Extends IUnknown
	Method CreateSoundBuffer( desc:Byte Ptr,buf:IDirectSoundBuffer Var,unk:Byte Ptr )
	Method GetCaps( caps:Byte Ptr )
	Method DuplicateSoundBuffer( in:IDirectSoundBuffer,out:IDirectSoundBuffer Var )
	Method SetCooperativeLevel( hwnd,coop )
	Method Compact()
	Method GetSpeakerConfig( config Var )
	Method SetSpeakerConfig( config )
	Method Initialize( guid:Byte Ptr )
End Type

Type IDirectSoundBuffer Extends IUnknown
	Method GetCaps( caps:Byte Ptr )
	Method GetCurrentPosition( pos Var,writePos Var )
	Method GetFormat( format:WAVEFORMATEX,sizein,sizeout Var )
	Method GetVolume( volume Var )
	Method GetPan( pan Var )
	Method GetFrequency( freq Var )
	Method GetStatus( status Var )
	Method Initialize( dsound:IDirectSound,desc:Byte Ptr )
	Method Lock( writeCursor,writeBytes,ptr1:Byte Ptr Var,bytes1 Var,ptr2:Byte Ptr Var,bytes2 Var,flags )
	Method Play( reserved,priority,flags )
	Method SetCurrentPosition( pos )
	Method SetFormat( format:WAVEFORMATEX )
	Method SetVolume( volume )
	Method SetPan( pan )
	Method SetFrequency( freq )
	Method Stop()
	Method Unlock( ptr1:Byte Ptr,bytes1,ptr2:Byte Ptr,bytes2 )
	Method Restore()
End Type

End Extern

Private

Global _ds=LoadLibraryA( "dsound" )

Public

Global DirectSoundCreate( guid:Byte Ptr,dsound:IDirectSound Var,unk:Byte Ptr )"win32"=GetProcAddress( _ds,"DirectSoundCreate" )
