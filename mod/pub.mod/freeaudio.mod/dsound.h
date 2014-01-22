// dsound.h

#ifndef dsound_h
#define dsound_h

#define DSBCAPS_PRIMARYBUFFER       0x00000001
#define DSBCAPS_STATIC              0x00000002
#define DSBCAPS_LOCHARDWARE         0x00000004
#define DSBCAPS_LOCSOFTWARE         0x00000008
#define DSBCAPS_CTRL3D              0x00000010
#define DSBCAPS_CTRLFREQUENCY       0x00000020
#define DSBCAPS_CTRLPAN             0x00000040
#define DSBCAPS_CTRLVOLUME          0x00000080
#define DSBCAPS_CTRLPOSITIONNOTIFY  0x00000100
#define DSBCAPS_CTRLFX              0x00000200
#define DSBCAPS_STICKYFOCUS         0x00004000
#define DSBCAPS_GLOBALFOCUS         0x00008000
#define DSBCAPS_GETCURRENTPOSITION2 0x00010000
#define DSBCAPS_MUTE3DATMAXDISTANCE 0x00020000
#define DSBCAPS_LOCDEFER            0x00040000

#define DSBPLAY_LOOPING             0x00000001
#define DSBPLAY_LOCHARDWARE         0x00000002
#define DSBPLAY_LOCSOFTWARE         0x00000004
#define DSBPLAY_TERMINATEBY_TIME    0x00000008
#define DSBPLAY_TERMINATEBY_DISTANCE    0x000000010
#define DSBPLAY_TERMINATEBY_PRIORITY    0x000000020

#define DSBLOCK_FROMWRITECURSOR     0x00000001
#define DSBLOCK_ENTIREBUFFER        0x00000002

#define DSSCL_NORMAL                0x00000001
#define DSSCL_PRIORITY              0x00000002
#define DSSCL_EXCLUSIVE             0x00000003
#define DSSCL_WRITEPRIMARY          0x00000004

struct DSCAPS{ 
  DWORD  dwSize; 
  DWORD  dwFlags;  
  DWORD  dwMinSecondarySampleRate; 
  DWORD  dwMaxSecondarySampleRate; 
  DWORD  dwPrimaryBuffers; 
  DWORD  dwMaxHwMixingAllBuffers; 
  DWORD  dwMaxHwMixingStaticBuffers; 
  DWORD  dwMaxHwMixingStreamingBuffers; 
  DWORD  dwFreeHwMixingAllBuffers; 
  DWORD  dwFreeHwMixingStaticBuffers; 
  DWORD  dwFreeHwMixingStreamingBuffers; 
  DWORD  dwMaxHw3DAllBuffers; 
  DWORD  dwMaxHw3DStaticBuffers; 
  DWORD  dwMaxHw3DStreamingBuffers; 
  DWORD  dwFreeHw3DAllBuffers; 
  DWORD  dwFreeHw3DStaticBuffers; 
  DWORD  dwFreeHw3DStreamingBuffers; 
  DWORD  dwTotalHwMemBytes; 
  DWORD  dwFreeHwMemBytes; 
  DWORD  dwMaxContigFreeHwMemBytes; 
  DWORD  dwUnlockTransferRateHwBuffers; 
  DWORD  dwPlayCpuOverheadSwBuffers; 
  DWORD  dwReserved1; 
  DWORD  dwReserved2; 
};
typedef DSCAPS *LPDSCAPS; 

struct DSBUFFERDESC{
    DWORD           dwSize;
    DWORD           dwFlags;
    DWORD           dwBufferBytes;
    DWORD           dwReserved;
    LPWAVEFORMATEX  lpwfxFormat;
    GUID            guid3DAlgorithm;
};
typedef DSBUFFERDESC *LPDSBUFFERDESC;
typedef const DSBUFFERDESC *LPCDSBUFFERDESC;

struct DSBPOSITIONNOTIFY{
    DWORD           dwOffset;
    HANDLE          hEventNotify;
};
typedef DSBPOSITIONNOTIFY *LPDSBPOSITIONNOTIFY;
typedef const DSBPOSITIONNOTIFY *LPCDSBPOSITIONNOTIFY;


typedef void *LPDSBCAPS;
typedef struct IDirectSound *LPDIRECTSOUND;
typedef struct IDirectSoundBuffer *LPDIRECTSOUNDBUFFER;

#undef INTERFACE
#define INTERFACE IDirectSoundBuffer

DECLARE_INTERFACE_(IDirectSoundBuffer, IUnknown){
    STDMETHOD(QueryInterface)       (THIS_ REFIID, LPVOID FAR *) PURE;
    STDMETHOD_(ULONG,AddRef)        (THIS) PURE;
    STDMETHOD_(ULONG,Release)       (THIS) PURE;
    
    STDMETHOD(GetCaps)              (THIS_ LPDSBCAPS) PURE;
    STDMETHOD(GetCurrentPosition)   (THIS_ LPDWORD, LPDWORD) PURE;
    STDMETHOD(GetFormat)            (THIS_ LPWAVEFORMATEX, DWORD, LPDWORD) PURE;
    STDMETHOD(GetVolume)            (THIS_ LPLONG) PURE;
    STDMETHOD(GetPan)               (THIS_ LPLONG) PURE;
    STDMETHOD(GetFrequency)         (THIS_ LPDWORD) PURE;
    STDMETHOD(GetStatus)            (THIS_ LPDWORD) PURE;
    STDMETHOD(Initialize)           (THIS_ LPDIRECTSOUND, LPCDSBUFFERDESC) PURE;
    STDMETHOD(Lock)                 (THIS_ DWORD, DWORD, LPVOID *, LPDWORD, LPVOID *, LPDWORD, DWORD) PURE;
    STDMETHOD(Play)                 (THIS_ DWORD, DWORD, DWORD) PURE;
    STDMETHOD(SetCurrentPosition)   (THIS_ DWORD) PURE;
    STDMETHOD(SetFormat)            (THIS_ LPCWAVEFORMATEX) PURE;
    STDMETHOD(SetVolume)            (THIS_ LONG) PURE;
    STDMETHOD(SetPan)               (THIS_ LONG) PURE;
    STDMETHOD(SetFrequency)         (THIS_ DWORD) PURE;
    STDMETHOD(Stop)                 (THIS) PURE;
    STDMETHOD(Unlock)               (THIS_ LPVOID, DWORD, LPVOID, DWORD) PURE;
    STDMETHOD(Restore)              (THIS) PURE;
};

#undef INTERFACE
#define INTERFACE IDirectSound

DECLARE_INTERFACE_(IDirectSound, IUnknown){

    STDMETHOD(QueryInterface)       (THIS_ REFIID, LPVOID FAR *) PURE;
    STDMETHOD_(ULONG,AddRef)        (THIS) PURE;
    STDMETHOD_(ULONG,Release)       (THIS) PURE;
    
    STDMETHOD(CreateSoundBuffer)    (THIS_ LPCDSBUFFERDESC, LPDIRECTSOUNDBUFFER *, LPUNKNOWN) PURE;
    STDMETHOD(GetCaps)              (THIS_ LPDSCAPS) PURE;
    STDMETHOD(DuplicateSoundBuffer) (THIS_ LPDIRECTSOUNDBUFFER, LPDIRECTSOUNDBUFFER *) PURE;
    STDMETHOD(SetCooperativeLevel)  (THIS_ HWND, DWORD) PURE;
    STDMETHOD(Compact)              (THIS) PURE;
    STDMETHOD(GetSpeakerConfig)     (THIS_ LPDWORD) PURE;
    STDMETHOD(SetSpeakerConfig)     (THIS_ DWORD) PURE;
    STDMETHOD(Initialize)           (THIS_ LPGUID) PURE;
};


#undef INTERFACE
#define INTERFACE IDirectSoundNotify

DECLARE_INTERFACE_(IDirectSoundNotify, IUnknown)
{
    // IUnknown methods
    STDMETHOD(QueryInterface)           (THIS_ REFIID, LPVOID *) PURE;
    STDMETHOD_(ULONG,AddRef)            (THIS) PURE;
    STDMETHOD_(ULONG,Release)           (THIS) PURE;

    // IDirectSoundNotify methods
    STDMETHOD(SetNotificationPositions) (THIS_ DWORD dwPositionNotifies, LPCDSBPOSITIONNOTIFY pcPositionNotifies) PURE;
};

const IID IID_IDirectSoundNotify={0xb0210783,0x89cd,0x11d0,{0xaf,0x8,0x0,0xa0,0xc9,0x25,0xcd,0x16}};

#endif
