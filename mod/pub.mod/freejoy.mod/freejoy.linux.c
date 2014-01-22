// freejoy.linux.c

#include "freejoy.h"

#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <pthread.h>
#include <sys/ioctl.h>
#include <linux/joystick.h>

struct linuxjoy
{
	pthread_t	thread;
	int		threadid;
	int		open,fd,fp;
	char		name[256];
	int		buttoncount,axiscount;
	int		button;
	float		axis[16];
};

typedef struct linuxjoy linuxjoy;
typedef struct js_event js_event;
typedef struct sched_param sched_param;

void *joythread(void *v)
{
	linuxjoy	*j;
	js_event 	js;
	int		n,b;
	
	int		policy;
	sched_param	sched;	
	
	pthread_getschedparam(pthread_self(),&policy,&sched);
	sched.sched_priority++;
	policy=SCHED_RR;
	pthread_setschedparam(pthread_self(),policy,&sched);
	
	j=(linuxjoy*)v;
	
	while (j->open)
	{
		b=sizeof(struct js_event)-j->fp;
		n=read(j->fd,&js,b);
		if (n<=0) break;
		if (n<b) {j->fp+=b;continue;}
		j->fp=0;
		switch (js.type & ~JS_EVENT_INIT)
		{
		case JS_EVENT_AXIS:
			n=js.number;
			if (n>=0 && n<16) j->axis[n]=js.value/32767.0;
			break;
		case JS_EVENT_BUTTON:
			n=1<<js.number;
			if (js.value) j->button|=n;else j->button&=~n;
			break;
		}
	}
	close(j->fd);
	j->fd=0;
	return 0;
}
						
linuxjoy *getjoy(int n)
{
	linuxjoy	*j;
	char		fname[16];
	int		fd;
	
	sprintf(fname,"/dev/js%d",n);
	fd=open(fname,O_RDONLY);
	if (fd==-1) return 0;
	j=(linuxjoy*)calloc(1,sizeof(struct linuxjoy));
	j->fd=fd;
	ioctl(fd,JSIOCGNAME(256),&j->name);
	ioctl(fd,JSIOCGAXES,&j->axiscount);
	ioctl(fd,JSIOCGBUTTONS,&j->buttoncount);
//	fcntl(fd,F_SETFL,O_NONBLOCK);	
	j->open=1;
	pthread_attr_t	attr;
	pthread_attr_init(&attr);
//		pthread_attr_setschedpolicy(&attr,SCHED_RR);
//		pthread_attr_getschedparam(&attr);
//		printf("mypid=%x\n",getpid());
//		pthread_attr_setschedparam(&attr,1);
	j->threadid=pthread_create(&j->thread,&attr,joythread,(void*)j);
		
	return j;
}

void updatejoy(linuxjoy *j,int *buttons,float *axis)
{
	*buttons=j->button;
	memcpy(axis,j->axis,16*4);
}

void freejoy(struct linuxjoy *j)
{
	int timeout=5;
	j->open=0;
	while (timeout-- && j->fd) sleep(1);
//	close(j->fd);
}

// standard freejoy interface

int		ljoyopen;
int		ljoycount;
linuxjoy	*ljoys[8];

int JoyCount()
{
	linuxjoy	*j;
	int		i,n;
	
	if (!ljoyopen)
	{
		n=0;
		for (i=0;i<8;i++)
		{
			j=getjoy(i);
			if (j) ljoys[n++]=j;
		}
		ljoycount=n;
		ljoyopen=1;
	}
	return ljoycount;
}

char *JoyCName(int port)
{
	if (port>=0 && port<ljoycount) return ljoys[port]->name;
	return 0;
}

int JoyButtonCaps(int port)
{
	if (port>=0 && port<ljoycount) return (1<<ljoys[port]->buttoncount)-1;
	return 0;
}

int JoyAxisCaps(int port)
{
	if (port>=0 && port<ljoycount) return (1<<ljoys[port]->axiscount)-1;
	return 0;
}

int ReadJoy(int port,int *buttons,float *axis)
{
	if (port<0 || port>=ljoycount) return 0;
	updatejoy (ljoys[port],buttons,axis);
	return 1;
}

void WriteJoy(int port,int channel,float value)
{
}
