// apple core audio device

#include "freeaudio.h"

#ifdef __APPLE__

#include <AudioToolbox/AudioToolbox.h>

extern "C" audiodevice *OpenCoreAudioDevice();

OSStatus FeedSound(void *ref,AudioUnitRenderActionFlags *flags,const AudioTimeStamp *time,UInt32 bus,UInt32 frames,AudioBufferList *data);

struct coreaudio:audiodevice{
	AudioUnit				out;
	AudioConverterRef		conv;
	AURenderCallbackStruct	callback;
	short					*buffer;
	int 					tcount;

	int reset(){
		int 	res;
		
		mix=new mixer(8192);
		mix->freq=44100;
		mix->channels=2;

		out=0;
		res=initoutput();
		if (res) return res;
		
		callback.inputProc=FeedSound;
		callback.inputProcRefCon=this;

		buffer=new short[8192];
		
		res=AudioUnitSetProperty(out,kAudioUnitProperty_SetRenderCallback,kAudioUnitScope_Input,0,&callback,sizeof(callback));
		if (res) return res;		
		
		res=AudioOutputUnitStart(out);
		if (res) return res;			
			
		return 0;
	}

	int close(){
		int	res;

		if (out){
			res=AudioOutputUnitStop(out);
			if (res) return res;
			out=0;
		}
		return 0;
	}

	int initoutput(){
		AudioComponentDescription desc;  
		AudioComponent comp;
		OSStatus err;
		UInt32 size;
		Boolean canwrite;
		
		AudioStreamBasicDescription 	inputdesc,outputdesc;

		desc.componentType=kAudioUnitType_Output;
		desc.componentSubType=kAudioUnitSubType_DefaultOutput;
		desc.componentManufacturer=kAudioUnitManufacturer_Apple;
		desc.componentFlags=0;
		desc.componentFlagsMask=0;

		comp=AudioComponentFindNext(NULL,&desc);
		if (comp==NULL) return -1;

		err= AudioComponentInstanceNew(comp,&out);
		if (err) return err;				

		err=AudioUnitInitialize(out);if (err) return err;
		
		err=AudioUnitGetPropertyInfo(out,kAudioUnitProperty_StreamFormat,kAudioUnitScope_Output,0,&size,&canwrite);
		if (err) return err;

		err=AudioUnitGetProperty(out,kAudioUnitProperty_StreamFormat,kAudioUnitScope_Input,0,&outputdesc,&size);
		if (err) return err;		
		
//		dumpdesc(&outputdesc);
		
		inputdesc.mSampleRate=44100.0;
		inputdesc.mFormatID='lpcm';
#if __BIG_ENDIAN__
		inputdesc.mFormatFlags=0x0e;
#else
		inputdesc.mFormatFlags=0x0c;
#endif
		inputdesc.mBytesPerPacket=4;
		inputdesc.mFramesPerPacket=1;
		inputdesc.mBytesPerFrame=4;
		inputdesc.mChannelsPerFrame=2;
		inputdesc.mBitsPerChannel=16;
		inputdesc.mReserved=0;

//		dumpdesc(&inputdesc);
		
		err=AudioConverterNew(&inputdesc,&outputdesc,&conv);
		if (err) {
//			printf("AudioConvertNew failed %.*s\n",4,(char*)&err);
			return err;
		}

		return err;
	}

	int read(AudioConverterRef conv,UInt32 *count,AudioBufferList *blist,AudioStreamPacketDescription **outdesc){
		if (*count>4096) *count=4096;
//		printf("ac read count=%d\n",*count);fflush(stdout);
		mix->mix16(buffer,*count*2);
		blist->mBuffers[0].mData=buffer;
		blist->mBuffers[0].mDataByteSize=*count*4;
		return 0;
	}
};

OSStatus Feed(AudioConverterRef conv,UInt32 *count,AudioBufferList *blist,AudioStreamPacketDescription **outdesc,void *ref){
	coreaudio	*audio;
	audio=(coreaudio*)ref;
	return audio->read(conv,count,blist,outdesc);
}

OSStatus FeedSound(void *ref,AudioUnitRenderActionFlags *flags,const AudioTimeStamp *time,UInt32 bus,UInt32 count,AudioBufferList *blist){
	coreaudio	*audio;
	audio=(coreaudio*)ref;
	return AudioConverterFillComplexBuffer(audio->conv,Feed,ref,&count,blist,0);
}

audiodevice *OpenCoreAudioDevice(){
	return new coreaudio();
}

#endif
