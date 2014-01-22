// freeaudio.h

// version 0.3
// freeware cross platform audio engine sponsored by Blitz Research Ltd

#ifndef freeaudio_h
#define freeaudio_h

extern "C" int bbMilliSecs();

typedef int (*ReadFunc)(void*,int);

#if _MSC_VER
	typedef __int64 i64;
#else
	typedef long long i64;
#endif

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;

#define MAXCHANNELS 4096

#define VOLUMEONE 4096

#define BBCALL

#define ABS(a) (((a)>0)?(a):-(a))
#define MAX(a,b) (((a)>(b))?(a):(b))
#define MIN(a,b) (((a)<(b))?(a):(b))
#define BND(a,b,c) MIN(MAX((a),(b)),(c))

struct control
{
	int		current,target;
};

struct output
{
	enum outputstates{FREE=0,STOPPED=1,SINGLESHOT=2,LOOPING=4,STREAMING=8,PAUSED=16};

	output		*parent;
	int 		status,channel,recycle;
		
	virtual void setrate(int r) {}
	virtual void setvolume(short v) {}
	virtual void setpan(short p) {}
	virtual void setdepth(short d) {}
	
	virtual int getrate(int t) {return 65536;}			//(status&PAUSED)?0:4096;}
	virtual short getvolume(int t) {return 4096;}
	virtual short getpan(int t) {return 0;}
	virtual short getdepth(int t) {return 0;}

	virtual	int getposition() {return 0;}
	
	output(output *p) {
		parent=p;
		status=FREE;
		channel=0;
		recycle=0;
	}
	
	void stop(int user) {
		if (user) recycle=1;
		if (status!=FREE) status=STOPPED;
	}
	
	void setpause(int pause)
	{
		if (pause)
		{
			status|=PAUSED;
		}
		else
		{
			status&=~PAUSED;
		}
	}
		
	void setloop(int loop)
	{
		if (loop)
		{
			if (status&SINGLESHOT) status=(status&~SINGLESHOT)|LOOPING;
		}
		else
		{
			if (status&LOOPING) status=(status&~LOOPING)|SINGLESHOT;
		}
	}
};

struct sample
{
	int 	freq,channels,bits;
	int 	loop0,loop1;
	int 	samples,samplesize,sizebytes;
	int 	writepos;
	int 	refcount;
	int		loop;
	void	*data,*buffer;
	int		capacity;

	sample() {freq=channels=bits=0;loop=0;capacity=0;}
	int init(int length,int freq,int channels,int bits,void *data);	//data=0 mallocs length in samples
	void free();
	int buffersize(int readpos);
	void write(int n);
	int write(void *mem,int bytes,int readpos=0);
	int peek(int t);
	void setloop(int flag);
};

struct sound:output
{
	sound	*next;
	sample	*samp;
	i64 	pos64;
	i64 	mix64;
	
	int		currentrate,targetrate;
	short	currentvolume,targetvolume;
	short	currentpan,targetpan;
	short	currentdepth,targetdepth;
	int		starttime,delay;

	virtual int getrate(int t) {return t?targetrate:currentrate;}
	virtual short getvolume(int t) {return t?targetvolume:currentvolume;}
	virtual short getpan(int t) {return t?targetpan:currentpan;}
	virtual short getdepth(int t) {return t?targetdepth:currentdepth;}
	virtual int getposition() {return (mix64>>32)/samp->channels;}
	
	virtual void setrate(int r) {targetrate=r;if (status&PAUSED) currentrate=r;}
	virtual void setvolume(short v) {targetvolume=v;if (status&PAUSED) currentvolume=v;}
	virtual void setpan(short p) {targetpan=p;if (status&PAUSED) currentpan=p;}
	virtual void setdepth(short d) {targetdepth=d;if (status&PAUSED) targetdepth=d;}
	
	void resetrate(int r) {currentrate=targetrate=r;}
	void resetvolume(short v) {currentvolume=targetvolume=v;}
	void resetpan(short p) {currentpan=targetpan=p;}
	void resetdepth(short d) {currentdepth=targetdepth=d;}

// private
	sound(output *p);
	void flush();
	int mix(int *b,int size);	//return 0 to remove from playlist
};

struct queue
{
	int		head,tail;
	sound	*que[MAXCHANNELS];
	
	queue() {head=tail=0;}
	
	void push(sound *s)
	{
		que[tail++]=s;
		if (tail>=MAXCHANNELS) tail=0;
	}

	sound *pull()
	{
		sound	*snd=0;
		if (head!=tail)
		{
			snd=que[head++];
			if (head>=MAXCHANNELS) head=0;
		}
		return snd;
	}
};

struct mixer:output
{
	int 	*mbuff,size;
	int 	freq,channels;
	sound	*playlist;
	queue	startlist;
	queue	freelist;	//multi threading friendly

	mixer(int size);
	
	sound *allocsound(output *out);
	sound *play(sample *s,output *out,int state);

	void releasesound(sound *s);
	void releaseall();

	void mix8(u8 *abuff,int count=0);
	void mix16(short *abuff,int count=0);
	void mix16s(short *abuff,int count=0);
	void mix(int count);
};

// freeaudio device 

struct audiodevice
{
	mixer		*mix;

// virtual OS dependent interface
	virtual int reset()=0;
	virtual int close()=0;
	
	audiodevice()
	{
		mix=0;
	}

	sound *play(sample *sam,output *out,int paused)
	{
		sound	*snd;
		int		freq,vol,state;

		if (mix==0) return 0; 
		state=sound::SINGLESHOT;
		if (sam->loop) state=sound::LOOPING;
		if (paused) state|=sound::PAUSED;			//freq=0;
		snd=mix->play(sam,out,state);
		return snd;
	}
};

// freeaudio standard C interface

static audiodevice *audio=0;

struct systemio
{
	output		**channels;
	int			*freelist;
	int			*cyclelist;

	systemio()
	{
		channels=new output*[MAXCHANNELS];
		freelist=new int[MAXCHANNELS];
		cyclelist=new int[MAXCHANNELS];
		for (int i=0;i<MAXCHANNELS;i++)
		{
			channels[i]=0;
			freelist[i]=i+1;
			cyclelist[i]=MAXCHANNELS;
		}
		freelist[MAXCHANNELS-1]=0;
	}

	~systemio()
	{
		delete channels;
		delete freelist;
	}

	int allocchannel()
	{	
		int ch=freelist[0];
		if (ch)
		{
			freelist[0]=freelist[ch];
			freelist[ch]=0;
			cyclelist[ch]+=MAXCHANNELS;
			ch|=cyclelist[ch];
		}
		return ch;
	}

	void freechannel(int ch)
	{
		if (ch==0) return;
		ch&=(MAXCHANNELS-1);
		if (freelist[ch]) return;
		if (channels[ch])
		{
//			channels[ch]->stop(0);
			channels[ch]=0;
		}
		freelist[ch]=freelist[0];
		freelist[0]=ch;
	}

	void setchannel(int ch,output *o)
	{
		output	*old;
		if (ch==0) return;
		old=getchannel(ch);
		if (old) old->stop(0);
		ch&=(MAXCHANNELS-1);
		channels[ch]=o;
	}

	output *getchannel(int ch)
	{
		if (ch==0) return 0;
		if (audio==0) return 0;
		int cycle=ch & (-MAXCHANNELS);
		ch&=(MAXCHANNELS-1);
		if (cyclelist[ch]==cycle)
		{
			if (!channels[ch]) channels[ch]=audio->mix->allocsound(0);
			return channels[ch];
		}
		return 0;
	}
};

static systemio *io=0;


#endif
