// freejoy.win32.c

#define WIN32_LEAN_AND_MEAN

#include <windows.h>
#include <mmsystem.h>
#include "freejoy.h"

int joyhandle[256];

int JoyCount()
{
	JOYINFO		j;
	int			n,i,t,res;

	n=joyGetNumDevs();
	t=0;
	for (i=0;i<n;i++)
	{
		res=joyGetPos(i,&j);
		if (res==JOYERR_NOERROR && t<256) joyhandle[t++]=i;
	}
	return t;
}

char *JoyCName(int port)
{
	static JOYCAPS joycaps;
	int		res;

	port=joyhandle[port];
	res=joyGetDevCaps(port,&joycaps,sizeof(JOYCAPS));
	if (res!=JOYERR_NOERROR) return 0;
	return joycaps.szPname;
}

int JoyButtonCaps(int port)
{
	JOYCAPS	caps;
	int		res,mask;

	port=joyhandle[port];
	res=joyGetDevCaps(port,&caps,sizeof(JOYCAPS));
	if (res!=JOYERR_NOERROR) return 0;
	mask=(1<<caps.wNumButtons)-1;
	return mask;
}

int JoyAxisCaps(int port)
{
	JOYCAPS	caps;
	int		res,mask;

	port=joyhandle[port];
	res=joyGetDevCaps(port,&caps,sizeof(JOYCAPS));
	if (res!=JOYERR_NOERROR) return 0;
	mask=(1<<caps.wNumAxes)-1;
	if (caps.wCaps&JOYCAPS_HASPOV) mask|=(1<<JOYHAT);
	return mask;
}

int ReadJoy(int port,int *buttons,float *axis)
{
	JOYCAPS		caps;
	JOYINFOEX	j;
	int			res,f,pov;

	port=joyhandle[port];
	res=joyGetDevCaps(port,&caps,sizeof(JOYCAPS));
	if (res!=JOYERR_NOERROR) return 0;
	j.dwSize=sizeof(JOYINFOEX);
	j.dwFlags=JOY_RETURNALL;
	res=joyGetPosEx(port,&j);
	if (res!=JOYERR_NOERROR) return 0;
	*buttons=j.dwButtons;
	f=j.dwFlags;
	if (f&JOY_RETURNX) axis[JOYX]=-1.0+2.0*(j.dwXpos-caps.wXmin)/caps.wXmax;
	if (f&JOY_RETURNY) axis[JOYY]=-1.0+2.0*(j.dwYpos-caps.wYmin)/caps.wYmax;
	if (f&JOY_RETURNZ) axis[JOYZ]=-1.0+2.0*(j.dwZpos-caps.wZmin)/caps.wZmax;
	if (f&JOY_RETURNR) axis[JOYR]=-1.0+2.0*(j.dwRpos-caps.wRmin)/caps.wRmax;
	if (f&JOY_RETURNU) axis[JOYU]=-1.0+2.0*(j.dwUpos-caps.wUmin)/caps.wUmax;
	if (f&JOY_RETURNV) axis[JOYV]=-1.0+2.0*(j.dwVpos-caps.wVmin)/caps.wVmax;
	if (f&JOY_RETURNPOV) 
	{
		pov=j.dwPOV;
		if (pov<0 || pov>36000) axis[JOYHAT]=-1.0;else axis[JOYHAT]=pov/36000.0;
	}
	return 1;
}

void WriteJoy(int port,int channel,float value)
{
	port=joyhandle[port];
}
