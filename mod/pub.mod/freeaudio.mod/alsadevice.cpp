// alsadevice.cpp

#ifdef __linux

#include "freeaudio.h"

#include <sys/ioctl.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/soundcard.h>
#include <pthread.h>

//#include <alsa/asoundlib.h>

extern "C" audiodevice *OpenALSADevice();

void *audiothread(void *dev);

#define LINUXFRAG 2048

struct alsaaudio:audiodevice{
	pthread_t	audiothread;
	int			threadid;
	int			running,playing;
	short		*buffer;
	int			buffersize;	//in bytes
	
	int reset(){
		running=1;
		playing=0;
		mix=new mixer(LINUXFRAG);
		mix->freq=44100;
		mix->channels=2;
		buffer=new short[LINUXFRAG];
		buffersize=LINUXFRAG*2;
		pthread_attr_t	attr;
		pthread_attr_init(&attr);
		threadid=pthread_create(&audiothread,&attr,audiothread,(void*)this);	
		return 0;
	}
	
	int close(){	
		int		timeout;
		running=0;
		timeout=5;
		while (timeout-- && playing) sleep(1);
		return 0;
	}
};


void *audiothread(void *v){
	int						policy;
	sched_param		sched;	
	int						err;
	alsaaudio 		*dev;
	
	pthread_getschedparam(pthread_self(),&policy,&sched);
	sched.sched_priority++;//policy=SCHED_RR;
	pthread_setschedparam(pthread_self(),policy,&sched);	
	dev=(alsaaudio*)v;

	unsigned int val;
	snd_pcm_t *fd;
	snd_pcm_uframes_t periodsize;
	snd_pcm_hw_params_t *hwparams;
	snd_pcm_hw_params_alloca(&hwparams);
	int output_rate;
	int channels;
	int fragment_size;
	int fragment_count;

	err=snd_pcm_open(&fd, strdup("default"), SND_PCM_STREAM_PLAYBACK, 0);
	if (err<0) return -1;

	fragment_size=LINUXFRAG;  //overall buffer size
	fragment_count=2; //2 - 16 fragment count - 2 minimum, the lower it is potentially the lower the latency

//configure device
	if (snd_pcm_hw_params_any(fd, hwparams) < 0) {
		//printf("linuxaudio failed at params any\n");
		return -1;
	}	
	if (snd_pcm_hw_params_set_access(fd, hwparams,SND_PCM_ACCESS_RW_INTERLEAVED) < 0) {
		//printf("linuxaudio failed at set access\n");
		return -1;
	}	
	
	if (snd_pcm_hw_params_set_format(fd, hwparams,SND_PCM_FORMAT_S16_LE) < 0) {
		//printf("linuxaudio failed at set format\n");
		return -1;
	}
	val = 44100;
	if (snd_pcm_hw_params_set_rate_near(fd, hwparams,&val, 0) < 0) {
		// Try 48KHZ too 
		//printf("linuxaudio - %d HZ not available, trying 48000HZ\n", output_rate);
		val = 48000;
		if (snd_pcm_hw_params_set_rate_near(fd, hwparams,&val, 0) < 0) {
			//printf("linuxaudio failed at setting output rate (%d)\n", output_rate);
			return -1;
		}
		dev->mix->freq=val;		
	}
	channels=2;
	if (snd_pcm_hw_params_set_channels(fd, hwparams, channels) < 0) {
		//printf("linuxaudio failed at set channels (%d)\n", channels);
		return -1;
	}
	periodsize = (fragment_size) / 4; // bytes -> frames for 16-bit,stereo - should be a minimum of 512
	if (snd_pcm_hw_params_set_period_size_near(fd, hwparams,&periodsize, 0) < 0) {
		//printf("linuxaudio failed at set period size (%d)\n", (int)periodsize);			
		return -1;
	}
	val = fragment_count;
	if (snd_pcm_hw_params_set_periods_near(fd, hwparams,&val, 0) < 0) {
		//printf("linuxaudio failed at set periods (%d)\n", val);			
		//should attempt a one by one period increase up to 16?
		return -1;
	}
	if (snd_pcm_hw_params(fd, hwparams) < 0) {
		//printf("linuxaudio failed at installing hw params\n");
		return -1;
	}
	//loop while playing sound
	dev->playing=1;
	while (dev->playing)
	{
		dev->mix->mix16(dev->buffer);
		if ((snd_pcm_writei (fd, dev->buffer,LINUXFRAG/2)) < 0) {	//Half buffer for two channels?
			//printf ("linuxaudio warning: buffer underrun occurred\n");
			if (snd_pcm_prepare(fd) < 0) {
				//printf ("linuxaudio failed at preparing pcm\n");
				dev->playing=0; //die gracefully
			}
		}	
	}
	snd_pcm_drop(fd);
	snd_pcm_close (fd);
	return 0;
}

audiodevice *OpenALSADevice(){
	return new alsaaudio();
}

#endif
