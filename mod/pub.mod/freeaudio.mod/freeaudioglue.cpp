// freeaudioglue.cpp

#include "freeaudio.h"
#include "freeaudioglue.h"

//int BBCALL fa_Init(int deviceid){
//	audio=OpenSystemAudio();

int BBCALL fa_Reset(audiodevice *audiodevice){
	audio=audiodevice;
	if (audio==0) return -1;
	if (audio->reset()) {audio->close();return -1;}
	io=new systemio();
	return 0;
}

int BBCALL fa_Close(){
	if (io) delete io;
	if (audio) audio->close();
	audio=0;
	io=0;
	return 0;
}

int BBCALL fa_PlaySound( int sound,int paused,int ch ){
	output	*out;
	bool	recycle;
	if (audio && sound)
	{	
		recycle=(ch==0);
		if (ch)
		{
			out=io->getchannel(ch);
		}
		else
		{
			ch=io->allocchannel();
			out=0;
		}
		out=audio->play((sample*)sound,out,paused);
		io->setchannel(ch,out);	
		out->channel=ch;
		out->recycle=recycle;
	}
	return ch;
}

int BBCALL fa_AllocChannel(){
	if (io) return io->allocchannel(); 
	return 0;
}

void BBCALL fa_FreeChannel( int ch ){
	if (io) io->freechannel(ch);
}

int BBCALL fa_ChannelStatus( int channel ){
	output	*out;
	if (io==0) return 0;
	out=io->getchannel(channel);
	if (out) return out->status;
	return 0;
}

int BBCALL fa_ChannelPosition( int channel ){
	output	*out;
	if (io==0) return 0;
	out=io->getchannel(channel);
	if (out) return out->getposition();
	return 0;
}

int BBCALL fa_StopChannel( int channel ){
	output	*out;
	if (io==0) return 0;
	out=io->getchannel(channel);
	if (out) {
		out->stop(1);
		io->freechannel(channel);
	}
	return 0;
}

int BBCALL fa_SetChannelPaused( int channel,int paused ){
	output	*out;
	if (io==0) return 0;
	out=io->getchannel(channel);
	if (out) out->setpause(paused);
	return 0;
}

int BBCALL fa_SetChannelVolume( int channel,float volume ){
	output	*out;
	if (io==0) return 0;
	out=io->getchannel(channel);
	if (out) out->setvolume((short)(volume*VOLUMEONE));
	return 0;
}

int BBCALL fa_SetChannelRate( int channel,float hertz ){
	output	*out;
	if (io==0) return 0;
	out=io->getchannel(channel);
	if (out) out->setrate((int)(hertz*65536));
	return 0;
}

int BBCALL fa_SetChannelPan( int channel,float pan ){
	output	*out;
	if (io==0) return 0;
	out=io->getchannel(channel);
	if (out) out->setpan((short)(pan*4096));
	return 0;
}

int BBCALL fa_SetChannelDepth( int channel,float depth ){
	output	*out;
	if (io==0) return 0;
	out=io->getchannel(channel);
	if (out) out->setdepth((short)(depth*4096));
	return 0;
}

int BBCALL fa_CreateSound( int length,int bits,int channels,int freq,const char *samples,int loop ){
	sample		*sam;
  
	if (io==0) return 0;
	sam=new sample();
	if (loop==0x80000000){	//dynamic sounds stay in app memory
		sam->init(length,freq,channels,bits,(void*)samples);
	}else{
		sam->init(length,freq,channels,bits,0);
		if( samples ) sam->write((void*)samples,length,0);
	}
	sam->setloop(loop);
	return (int)sam;
}

int BBCALL fa_WriteSound( int sound, void *data, int samples){
	sample		*sam;

	if (io==0) return 0;
	sam=(sample*)sound;
	return sam->write(data,samples,0);
}

int BBCALL fa_FreeSound( int sound ){
	sample	*sam;
	if (io==0) return 0;
	sam=(sample*)sound;
	if (sam) sam->free();
	return 0;
}

