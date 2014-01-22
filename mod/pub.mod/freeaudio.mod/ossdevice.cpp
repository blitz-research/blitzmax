// ossdevice.cpp

#ifdef __linux

#include "freeaudio.h"

#include <sys/ioctl.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/soundcard.h>
#include <pthread.h>

extern "C" audiodevice *OpenOSSDevice();

void *ossaudiothread(void*dev);

#define LINUXFRAG 2048

void *ossaudiothread(void *arg);

struct ossdevice:audiodevice{
	pthread_t	audiothread;
	int			threadid;
	int			running,playing;
	short		*buffer;
	int			buffersize;	//in bytes
	int			fragsize,fragcount;
	int			fd,data,res;
	
	int reset(){
		running=0;
		playing=0;

		fd=open("/dev/dsp",O_WRONLY,0);
		if (fd==-1) return -1;

		mix=new mixer(LINUXFRAG);
		mix->freq=44100;
		mix->channels=2;
		buffer=new short[LINUXFRAG];
		buffersize=LINUXFRAG*2;
		pthread_attr_t	attr;
		pthread_attr_init(&attr);

		running=1;
		threadid=pthread_create(&audiothread,&attr,ossaudiothread,(void*)this);	
		return 0;
	}
	
	int close(){	
		int		timeout;
		running=0;
		timeout=500;
		while (timeout-- && playing) usleep( 10*1000 );
		::close(fd);
		return 0;
	}

	void run(){
	//	printf("linuxaudio started\n");
		data=0x03000c;		//2 fragments of 4096 samples
		res=ioctl(fd,SNDCTL_DSP_SETFRAGMENT,&data);		
	//	printf("res=%d\n",res);
		data=AFMT_S16_LE;
		res=ioctl(fd,SNDCTL_DSP_SETFMT,&data);
	//	printf("res=%d\n",res);
		data=2;
		res=ioctl(fd,SNDCTL_DSP_CHANNELS,&data);		
	//	printf("res=%d\n",res);
		data=44100;
		res=ioctl(fd,SNDCTL_DSP_SPEED,&data);
		playing=1;
		while (playing && running){
			mix->mix16(buffer);
			int n=write(fd,buffer,buffersize);
		}
		playing=0;
	}

};

void *ossaudiothread(void *arg){
	ossdevice*audio=(ossdevice*)arg;
	audio->run();
	return 0;
}

audiodevice *OpenOSSDevice(){
	return new ossdevice();
}

#endif

