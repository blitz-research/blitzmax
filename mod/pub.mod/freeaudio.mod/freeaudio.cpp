// freeaudio.cpp

// 2007.02.15 new dsound device, readpointer and tidy up SA
// 2006.05.26 overflow handling for winmmdevice waveOutGetPosition
// 2006.04.26 winmmdevice doubles latency for windows98
// 2006.04.26 fixed recycling of autostopped channels
// 2006.01.17 fixed recycling of stopped channels
// 2005.11.22 fixed freepool sounds not resetting parameters - thanks to Fetze
// 2005.09.13 new ALSA code for Linux - thanks to Craig Kiesau
// 2005.08.05 new single looped buffer with timer callback for win32mmdevice
// 2005.07.04 reduced audio latency
// 2005.06.17 fixed memory leak in sound allocation
// 2005.05.23 removed output transitions for queued/paused sounds
// 2005.04.05 added AudioOutputUnitStop call for apple close
// 2005.01.07 fixed up audio hardware failure handling
// 2004.08.16 fixed channelstatus, allocchannel now always returns unique handle
// 2004.06.04 added linux drivers
// 2004.03.19 new ,loop parameter support in loadsound(file,looping)
// 2004.03.02 dynamic sounds release temp channel when recycled SA
// 2004.02.06 initial single file release SA

#include "freeaudio.h"

#include <stdlib.h>
#include <stdio.h>
#include <memory.h>

//static audiodevice *audio=0;

mixer::mixer(int bufflen):output(0)
{
	int i;
	size=bufflen;
	playlist=0;
//	freelist=0;
	mbuff=new int[bufflen];
	for (i=0;i<size;i++) mbuff[i]=0;
	freq=0;channels=0;
}

sound *mixer::allocsound(output *out)
{
	sound	*s;

	s=freelist.pull();		//getfreesound();
	if (s){
		if (io && s->channel){
			io->freechannel(s->channel);
			s->channel=0;
		}
	}else{
		s=new sound(this);
	}
	if (out){
		s->resetrate(out->getrate(1));
		s->resetvolume(out->getvolume(1));
		s->resetpan(out->getpan(1));
		s->resetdepth(out->getdepth(1));
	}else{
		s->resetrate(65536);
		s->resetvolume(VOLUMEONE);
		s->resetpan(0);
		s->resetdepth(0);
	}
	return s;
}

sound *mixer::play(sample *sam,output *out,int state)
{
	sound	*s;

	if (!sam) return 0;
	if (sam->channels==0) return 0;
	if (freq==0) return 0;	
	
	s=allocsound(out);
	sam->refcount++;
	s->status=state;
	s->samp=sam;
	s->pos64=0;
	s->mix64=0;
	s->starttime=bbMilliSecs();
	startlist.push(s);
	return s;
}

sound::sound(output *p):output(p){
	status=STOPPED;
	next=0;
	resetrate(65536);
	resetvolume(VOLUMEONE);
	resetpan(0);
	resetdepth(0);
}

void sound::flush(){
	if (status==STREAMING && samp){
		int readpos=samp->writepos; 
		mix64=((i64)(readpos*samp->channels))<<32;
		pos64=((i64)((readpos%samp->samples)*samp->channels))<<32;
	}
}

// mix audio stream at rate,amplitude with linear interpolation

#define blend(a,b,c) (a+((((b)-(a))*((((int)(c))>>16)&65535))>>16))

#define ublend(a,b,c) ( ((a-128)<<8) + ((((b)-(a))*((((int)(c))>>16)&65535))>>8) )

/*
int ublend(u8 a,u8 b,int c)
{
	int a0=a-128;
	int b0=b-128;
	return blend(a0,b0,c);
}
*/

int sound::mix(int *b,int size) 			//returns 0=ok 1=releasechannel
{
	short	*s;
	u8		*c;
	int 	t,n;
	int 	count;
	short	pan,depth;
	short	right,left;
	int		amp0,amp1;	
	i64		freq0,freq1;
	i64 	len64,freq64;
	int 	p;

	if (status==STOPPED) return 1;
	if (status&PAUSED) return -2;
	if (status==FREE) return -1;
	count=size/2;
	
	if (delay)
	{
		if (delay>=count)
		{
			delay-=count;
			return 0;
		}
		if (delay>0)
		{
			count-=delay;
			b+=delay*2;
		}
		delay=0;
	}
	
	freq0=((i64)samp->freq*getrate(0))/44100;
	freq1=((i64)samp->freq*getrate(1))/44100;
	n=(freq0*count)>>16;
	int readpos=mix64>>32;
	if ((status&STREAMING) && (readpos+n>samp->writepos)) return 0;
	amp0=getvolume(0);	
	amp1=getvolume(1);		
	pan=getpan(1);
	depth=getdepth(1);
	len64=((i64)(samp->samples*samp->channels))<<32;

	if ((amp0==amp1) && (freq0==freq1))
	{
		freq64=(freq0*samp->channels)<<16;
		if (amp1==0)	//muted
		{
			currentvolume=0;
			pos64+=freq64*count;
			mix64+=freq64*count;
			while (pos64>=len64)
			{
				if (status&LOOPING) pos64-=len64;else return 1;
			}
			return 0;
		}
		right=left=amp0;
		if (pan>0) left=(left*(4096-pan))>>12;
		if (pan<0) right=(right*(4096+pan))>>12;
		if (depth<0) right=-right;
		if (samp->bits==8)
		{
			c=(u8 *)samp->data;
			if (samp->channels==1)
			{
				while (count-->0)
				{
					p=(int)(pos64>>32);
					t=ublend(c[p],c[p+1],pos64);
					mix64+=freq64;
					pos64+=freq64;
					*b+++=(t*left)>>8;
					*b+++=(t*right)>>8;
					while (pos64>=len64)
					{
						if (status&LOOPING) pos64-=len64;else return 1;
					}
				}
			}
			else
			{
				while (count-->0)
				{
					p=(int)(pos64>>32)&-2;
					*b+++=(ublend(c[p+0],c[p+2],pos64>>1)*left)>>8;
					*b+++=(ublend(c[p+1],c[p+3],pos64>>1)*right)>>8;
					pos64+=freq64;
					mix64+=freq64;
					while (pos64>=len64)
					{
						if (status&LOOPING) pos64-=len64;else return 1;
					}
				}
			}
		}
		else
		{
			s=(short *)samp->data;
			if (samp->channels==1)
			{
				while (count-->0)
				{
					p=(int)(pos64>>32);
					t=blend(s[p],s[p+1],pos64);
					mix64+=freq64;
					pos64+=freq64;
					*b+++=(t*left)>>8;
					*b+++=(t*right)>>8;
					while (pos64>=len64)
					{
						if (status&LOOPING) 
						{
							pos64-=len64;
						}
						else
						{
							return 1;
						}
					}
				}
			}
			else
			{
				while (count-->0)
				{
					p=(int)(pos64>>32)&-2;
					*b+++=(blend(s[p+0],s[p+2],pos64>>1)*left)>>8;
					*b+++=(blend(s[p+1],s[p+3],pos64>>1)*right)>>8;
					mix64+=freq64;
					pos64+=freq64;
					while (pos64>=len64)
					{
						if (status&LOOPING) pos64-=len64;else return 1;
					}
				}
			}
		}
		return 0;
	}
	else		//dynamice volume|frequency
	{
		int 	v1,v2,vd;
		i64		f1,f2,fd;

		v1=amp0<<8;
		v2=amp1<<8;
		vd=(v2-v1)/count;

		f1=(freq0*samp->channels)<<16;
		f2=(freq1*samp->channels)<<16;
		fd=(f2-f1)/count;
		
		currentvolume=targetvolume;
		currentrate=targetrate;
		
		if (samp->bits==8)
		{
			c=(u8 *)samp->data;
			if (samp->channels==1)
			{
				while (count-->0)
				{
					left=right=v1>>8;
					if (pan>0) left=(left*(4096-pan))>>12;
					if (pan<0) right=(right*(4096+pan))>>12;
					p=(int)(pos64>>32);
					t=ublend(c[p],c[p+1],pos64);					
					*b+++=(left*t)>>8;
					*b+++=(right*t)>>8;
					v1+=vd;
					pos64+=f1;
					mix64+=f1;
					f1+=fd;
					while (pos64>=len64)
					{
						if (status&LOOPING) pos64-=len64;else return 1;
					}
				}
			}
			else
			{
				while (count-->0)
				{
					left=right=v1>>8;
					if (pan>0) left=(left*(4096-pan))>>12;
					if (pan<0) right=(right*(4096+pan))>>12;
					if (depth<0) right=-right;
					p=(int)(pos64>>32)&-2;
					*b+++=(ublend(c[p+0],c[p+2],pos64>>1)*left)>>8;
					*b+++=(ublend(c[p+1],c[p+3],pos64>>1)*right)>>8;
					v1+=vd;
					pos64+=f1;
					mix64+=f1;
					f1+=fd;
					while (pos64>=len64)
					{
						if (status&LOOPING) pos64-=len64;else return 1;
					}
				}
			}
		}
		else
		{
			s=(short *)samp->data;
			if (samp->channels==1)
			{
				while (count-->0)
				{
					left=right=v1>>8;
					if (pan>0) left=(left*(4096-pan))>>12;
					if (pan<0) right=(right*(4096+pan))>>12;
					if (depth<0) right=-right;
					p=(int)(pos64>>32);
					t=blend(s[p],s[p+1],pos64);
					*b+++=(t*left)>>8;
					*b+++=(t*right)>>8;					
					v1+=vd;
					mix64+=f1;
					pos64+=f1;
					f1+=fd;
					while (pos64>=len64)
					{
						if (status&LOOPING) pos64-=len64;else return 1;
					}
				}
			}
			else
			{
				while (count-->0)
				{
					left=right=v1>>8;
					if (pan>0) left=(left*(4096-pan))>>12;
					if (pan<0) right=(right*(4096+pan))>>12;
					if (depth<0) right=-right;
					p=(int)(pos64>>32)&-2;
					*b+++=(blend(s[p+0],s[p+2],pos64>>1)*left)>>8;
					*b+++=(blend(s[p+1],s[p+3],pos64>>1)*right)>>8;
					v1+=vd;
					mix64+=f1;
					pos64+=f1;
					f1+=fd;
					while (pos64>=len64)
					{
						if (status&LOOPING) pos64-=len64;else return 1;
					}
				}
			}
		}
		return 0;
	}
}

void mixer::releaseall()
{
	sound	*s;
	
	while (s=playlist)
	{
		playlist=s->next;
		releasesound(s);
	}
}

void mixer::releasesound(sound *s)	// should only be called by mix
{
	s->samp->free();
	s->samp=0;
	freelist.push(s);
}

void mixer::mix(int count)
{
	sound	*sptr,*tptr,**lptr;
	
	while (sptr=startlist.pull())
	{
		sptr->next=playlist;
		playlist=sptr;
		int skip=20+sptr->starttime-bbMilliSecs();
		if (skip<0) skip=0;
		skip=(skip*freq)/1000;
		sptr->delay=skip;		
	}

	sptr=playlist;
	lptr=&playlist;
	while (sptr)
	{
		int res=sptr->mix(mbuff,count);	//,count
		switch (res)
		{
		case 0:
			lptr=&sptr->next;
			sptr=sptr->next;
			break;
		case 1:		//STOP
			if (sptr->recycle){
				sptr->status=output::FREE;	//dynamic
				tptr=sptr;
				*lptr=sptr=sptr->next;
				releasesound(tptr);
			}else{
				sptr->status=output::STOPPED;
				lptr=&sptr->next;
				sptr=sptr->next;
			}
			break;
		case -1:	//FREE
			tptr=sptr;
			*lptr=sptr=sptr->next;
			releasesound(tptr);
			break;
		case -2:	//PAUSED
			lptr=&sptr->next;
			sptr=sptr->next;
			break;
		}
	}
}

void mixer::mix8(u8 *abuff,int count)
{
	int 	i,j;
	int 	*tptr;

	if (count==0) count=size;
	mix(count);
	tptr=mbuff;
	for (i=0;i<count;i++)
	{
		j=((*tptr)>>16)+0x80;
		if (j & 0xffffff00) {if (j<0) j=0;else j=0xff;}
		*abuff++=j;
		*tptr++=0;
	}
}

void mixer::mix16(short *d,int count)
{
	int *tptr;

	if (count==0) count=size;
	mix(count);
	tptr=mbuff;
	for (int i=0;i<count;i++)
	{
		*d++=BND(*tptr>>4,-32768,32767);
		*tptr++=0;
	}
}

void mixer::mix16s(short *dd,int count)
{
	int	*d,*tptr;
	if (count==0) count=size;
	mix(count);
	d=(int*)dd;
	tptr=mbuff;
	for (int i=0;i<count;i++)		//ll;i++)
	{
		int t=*tptr>>8;
		int p=*d;
		short s1=p;
		u32 p1=BND(s1+t,-32768,32767);
		u32 p2=BND((p>>16)+t,-32768,32767);
		*d++=(p1&0xffff)+(p2<<16);
		*tptr++=0;
	}
}

int sample::init(int n,int f,int c,int b,void *_data)
{
	freq=f;
	channels=c;
	bits=b;
	refcount=1;
	if (b<8) b=8;	//single bit handler
	samplesize=channels*b/8;
	samples=n;//size/samplesize;
	sizebytes=n*samplesize;
	if (_data){
		capacity=0;
		data=_data;
	}else{
		capacity=sizebytes+samplesize;
		data=malloc(capacity);
	}
	buffer=data;
	writepos=0;
	return 0;
};


void sample::setloop(int l)
{
	char	*p;
	
	loop=l;
	p=(char*)data;
	if (loop)
		memcpy(p+sizebytes,p,samplesize);
	else
		memcpy(p+sizebytes,p+sizebytes-samplesize,samplesize);
}

void sample::free()
{
	if (--refcount==0)
	{
		if (capacity) ::free(data);
		delete this;
	}
}

void sample::write(int n)
{
	writepos+=n;
	buffer=(char *)data+(writepos%samples)*samplesize;
}

int sample::write( void *src,int samples,int readpos)
{
	int 	n,t,nn; 	//,bytes;

	t=0;
	while (samples)
	{
		n=buffersize(readpos);
		if (n==0) break;
		if (n>samples) n=samples;
		nn=n*samplesize;
		memcpy(buffer,src,nn);
		src=(char*)src+nn;
		samples-=n;t+=n;write(n);
	}
	return t;
}

int sample::buffersize(int readpos)
{
	int 	inuse,rpos,wpos;
	inuse=writepos-readpos;
	if (inuse>=samples) return 0;	//buffer full!
	wpos=writepos%samples;
	rpos=readpos%samples;
	if (rpos>wpos) return rpos-wpos;
	return samples-wpos;
}

int sample::peek(int t)
{
	int 	s;

	if (t<0||t>=samples) return 0;

	switch (samplesize)
	{
		case 1:
			s=((u8*)data)[t]<<8;
			break;
		case 2:
			if (channels==1) s=((u16*)data)[t];else s=((u8*)data)[t*2]<<8;
			break;
		case 4:
			s=((u16*)data)[t*2];
			break;
	}
	return s-32768;
}

