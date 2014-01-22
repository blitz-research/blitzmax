// freeaudioglue.h
// version 0.2

// freeware cross platform audio engine sponsored by Blitz Research Ltd

// 2004.02.07 initial 0.1 release SA
// 2004.03.02 channel management handling added SA

#ifndef freeaudioglue_h
#define freeaudioglue_h

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

int		fa_Reset(struct audiodevice *device);
int		fa_Close();

int		fa_CreateSound(int samples,int bits,int channels,int freq,const char *buf,int loop);
int		fa_WriteSound( int sound, void *data, int samples);
int		fa_FreeSound( int sound );
int		fa_PlaySound( int sound,int paused,int channel );

int		fa_AllocChannel();
void	fa_FreeChannel( int channel );

int		fa_ChannelStatus( int channel );
int		fa_StopChannel( int channel );
int		fa_SetChannelPaused( int channel,int paused );
int		fa_SetChannelVolume( int channel,float volume );
int		fa_SetChannelRate( int channel,float hertz );
int		fa_SetChannelPan( int channel,float pan );
int		fa_SetChannelDepth( int channel,float depth );
int		fa_ChannelPosition( int channel );

#ifdef __cplusplus
}
#endif

#endif
