// dsounddevice.cpp

// changed to 4 x buffer spacing

#include "freeaudio.h"

#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <objbase.h>
#include <mmsystem.h>
#include <stdio.h>
#include "dsound.h"

#define DSOUNDFRAG 2048

extern "C" audiodevice *OpenDirectSoundDevice();

struct dsounddevice:audiodevice{

	int	running,playing;	//threadsafe state machine

	int reset(){
		int res;
		
		running=1;
		playing=0;
		mix=new mixer(DSOUNDFRAG*6);
		mix->freq=44100;
		mix->channels=2;
		res=initdevice(DSOUNDFRAG);
		if (res) {
			running=0;
		}
		return res;
	}
	
	int close(){	
		int		timeout;
		if (running){
//stop
			running=0;
			timeout=20;	//100ms timeout
			while (timeout-- && playing) {
				Sleep(5);
			}
			freedevice();
		}
		return 0;
	}

// private

	HINSTANCE dsoundlib;
	HRESULT WINAPI (*DirectSoundCreate)(LPGUID,LPDIRECTSOUND*,LPUNKNOWN);
	
	IDirectSound *directsound;
	IDirectSoundBuffer *primarybuffer;
	IDirectSoundBuffer *soundbuffer;
	IDirectSoundNotify *soundnotify;
	
	HANDLE soundevent;
	HANDLE soundthread;
	DWORD soundthreadid;

	int fragsize;	//in bytes
	int buffersize;	//4*fragsize

	int initdevice(int fragsamples){

		PCMWAVEFORMAT pcmwf; 
		DSBUFFERDESC dsbdesc; 
		DSCAPS dscaps;
		int res;
// init device
		directsound=0;
		primarybuffer=0;
		soundbuffer=0;
		soundnotify=0;		
		dsoundlib=LoadLibraryA("dsound");	
		DirectSoundCreate=(HRESULT WINAPI (*)(LPGUID,LPDIRECTSOUND*,LPUNKNOWN))GetProcAddress(dsoundlib,"DirectSoundCreate");
		res=DirectSoundCreate(0,&directsound,0);
		if (res) return res;		
		res=directsound->SetCooperativeLevel(GetDesktopWindow(),DSSCL_PRIORITY);
		if (res) return res;	
//		printf("dsoundlib=%d soundcreate=%d res=%d\n",dsoundlib,(int)DirectSoundCreate,res);	
//		fflush(stdout);
		dscaps.dwSize=sizeof(DSCAPS);
		res=directsound->GetCaps(&dscaps);	
		if (res) return res;	
// set primary buffer format
		memset(&dsbdesc,0,sizeof(DSBUFFERDESC)); 	// Zero it out. 
		dsbdesc.dwSize=sizeof(DSBUFFERDESC); 
		dsbdesc.dwFlags=DSBCAPS_PRIMARYBUFFER;
		res=directsound->CreateSoundBuffer(&dsbdesc,&primarybuffer,0); 
		if (res) return res;
		memset(&pcmwf, 0, sizeof(PCMWAVEFORMAT)); 
		pcmwf.wf.wFormatTag=WAVE_FORMAT_PCM; 
		pcmwf.wf.nChannels=2;
		pcmwf.wf.nSamplesPerSec=44100;
		pcmwf.wBitsPerSample=16; 
		pcmwf.wf.nBlockAlign=4;
		pcmwf.wf.nAvgBytesPerSec=pcmwf.wf.nSamplesPerSec * pcmwf.wf.nBlockAlign; 
		res=primarybuffer->SetFormat((LPWAVEFORMATEX)&pcmwf);
		if (res) return res;
// fragment size
		fragsize=fragsamples*4; //stereo 16bit=4 bytes per sample
		buffersize=fragsize*4;	//quad buffered
// format
		memset(&pcmwf, 0, sizeof(PCMWAVEFORMAT)); 
		pcmwf.wf.wFormatTag=WAVE_FORMAT_PCM; 
		pcmwf.wf.nChannels=2;
		pcmwf.wf.nSamplesPerSec=44100;
		pcmwf.wf.nBlockAlign=4;
		pcmwf.wf.nAvgBytesPerSec=pcmwf.wf.nSamplesPerSec * pcmwf.wf.nBlockAlign; 
		pcmwf.wBitsPerSample=16; 
// description	
		memset(&dsbdesc,0,sizeof(DSBUFFERDESC)); 	// Zero it out. 
		dsbdesc.dwSize=sizeof(DSBUFFERDESC); 
		dsbdesc.dwBufferBytes=buffersize;			//1 * pcmwf.wf.nAvgBytesPerSec; 
		dsbdesc.lpwfxFormat=(LPWAVEFORMATEX)&pcmwf; 
		dsbdesc.dwFlags=DSBCAPS_CTRLPOSITIONNOTIFY|DSBCAPS_GETCURRENTPOSITION2|DSBCAPS_GLOBALFOCUS;
// createbuffer
		res=directsound->CreateSoundBuffer(&dsbdesc,&soundbuffer,0); 
		if (res) return res;
// notifications
		soundevent=CreateEvent(0,0,0,"SOUNDEVENT");
		if (soundevent==0) return res;
		res=soundbuffer->QueryInterface(IID_IDirectSoundNotify,(void**)&soundnotify); 
		if (res) return res;	
		DSBPOSITIONNOTIFY notif[4];
		int n; 
		for (n=0;n<4;n++){
			notif[n].dwOffset=n*fragsize;
			notif[n].hEventNotify=soundevent;
		}
	 	res=soundnotify->SetNotificationPositions(4,notif);
		if (res) return res;
// thread
		soundthread=CreateThread(NULL,0,soundproc,this,REALTIME_PRIORITY_CLASS,&soundthreadid);
		return 0;
	}
	
	void freedevice(){
		int res;
		if (primarybuffer){
			res=primarybuffer->Release();
			primarybuffer=0;
		}		
		if (soundbuffer){
			res=soundbuffer->Release();
			soundbuffer=0;
		}		
		if(directsound) {
			res=directsound->Release();
			directsound=0;
		}	
	}

//thread entry point

	DWORD run(){	
		DWORD read,write;
		int lastread,loopcount;
		void *mem1,*mem2;
		DWORD size1,size2;
		int readpos,writepos;
		int res;
		writepos=0;
		lastread=0;
		loopcount=0;
		res=soundbuffer->Lock(0,4*fragsize,&mem1,&size1,&mem2,&size2,0);
		if (res) return 0;
//		printf("mem1=%d size1=%d mem2=%d size2=%d total=%d\n",mem1,size1,mem2,size2,size1+size2);
//		fflush(stdout);
		if (size1) memset(mem1,0,size1);
		if (size2) memset(mem2,0,size2);
		res=soundbuffer->Unlock(mem1,size1,mem2,size2);
		if (res) return 0;
// playsound
		soundbuffer->Play(0,0,DSBPLAY_LOOPING);
		playing=1;
//		printf("running=%d\n",running);
//		fflush(stdout);
		while (running){
			res=soundbuffer->GetCurrentPosition(&read,&write);
			if (read<lastread) loopcount++;
			lastread=read;
			readpos=loopcount*buffersize+read;
			int count=((readpos+fragsize*2-writepos)/fragsize);
//			printf("read=%d write=%d  %d,%d  count=%d\n",read,write,readpos,writepos,count);
//			fflush(stdout);
			if (count>0){		
				if (count>2) count=2;	//avoid overrun
				res=soundbuffer->Lock(writepos%buffersize,count*fragsize,&mem1,&size1,&mem2,&size2,0);
				if (res) break;
//				printf("mem1=%d size1=%d mem2=%d size2=%d total=%d\n",mem1,size1,mem2,size2,size1+size2);
//				fflush(stdout);
				if (size1) mix->mix16((short*)mem1,size1/2);
				if (size2) mix->mix16((short*)mem2,size2/2);
				res=soundbuffer->Unlock(mem1,size1,mem2,size2);
				if (res) break;
				writepos+=size1+size2;
			}
			res=WaitForSingleObject(soundevent,1000);
			if (res!=WAIT_OBJECT_0) break;				
		}
		playing=0;
		soundbuffer->Stop();
//		printf("done...\n");
//		fflush(stdout);
	}
	
	static DWORD WINAPI soundproc(LPVOID lpParam){
		dsounddevice *dsd;
		dsd=(dsounddevice*)lpParam;
		return dsd->run();
	}
};

audiodevice *OpenDirectSoundDevice(){
	return new dsounddevice();
}
