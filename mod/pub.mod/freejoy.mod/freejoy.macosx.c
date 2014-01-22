// freejoy.macosx.c

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <ctype.h>
#include <sys/errno.h>
#include <sysexits.h>
#include <mach/mach.h>
#include <mach/mach_error.h>

#include <IOKit/IOKitLib.h>
#include <IOKit/IOCFPlugIn.h>

#include <IOKit/hid/IOHIDLib.h>
#include <IOKit/hid/IOHIDUsageTables.h>
#include <IOKit/hid/IOHIDKeys.h>

#include <CoreFoundation/CoreFoundation.h>
#include <Carbon/Carbon.h>

#include "freejoy.h"

mach_port_t masterPort;

IOHIDDeviceInterface **OpenDevice(io_object_t device)
{
	IOHIDDeviceInterface	**handle;
	IOCFPlugInInterface 	**plug;
	SInt32 					score;
	io_name_t				class;
	IOReturn 				iores;
	HRESULT 				res;

	iores=IOObjectGetClass(device,class);
	if (iores) printf("Failed to get class name");
    iores=IOCreatePlugInInterfaceForService(device,kIOHIDDeviceUserClientTypeID,kIOCFPlugInInterfaceID,&plug,&score);
    if (iores!=kIOReturnSuccess) printf("IOCreatePlugInInterfaceForService failed");
	res=(*plug)->QueryInterface(plug,CFUUIDGetUUIDBytes(kIOHIDDeviceInterfaceID),(void *)&handle);
	if (res!= S_OK) printf("Couldn't query HID class device interface from plugInInterface\n");
	res=(*handle)->open(handle,0);
	if (res!= S_OK) printf("Couldn't open HID device\n");
	(*plug)->Release(plug);
    return handle;
}

struct macjoy
{
	struct macjoy			*link;
    IOHIDDeviceInterface	**device;
	IOHIDElementCookie		button[32];
	IOHIDElementCookie		axis[16];
	long					axismax[16],axismin[16];
	int					bcaps,acaps;
	char					name[256];
};

void freemacjoy(struct macjoy *j)
{
	int		res;
	res=IOObjectRelease( (int)j->device);
}

void readmacjoy(struct macjoy *j,int *buttons,float *axis)
{
    IOHIDEventStruct	event;
	IOHIDElementCookie	cookie;
	int					i,res,b;

	b=0;
	for (i=0;i<32;i++)
	{
		if (cookie=j->button[i])
		{
			res=(*j->device)->getElementValue(j->device,cookie,&event);
			if (event.value) b|=1<<i;
		}
	}
	*buttons=b;
	for (i=0;i<16;i++)
	{
		if (cookie=j->axis[i])
		{
			res=(*j->device)->getElementValue(j->device,cookie,&event);
			if (i==JOYHAT)
			{
				axis[i]=event.value/8.0;
				if (axis[i]==1.0) axis[i]=-1.0;
			}
			else
			{
//				axis[i]=(event.value-128)/128.0;
				axis[i]=event.value;
//				if (j->axismax[i]) axis[i]/=j->axismax[i];				          //32768.0;
				if (j->axismax[i]) {
					axis[i]=(((axis[i]-j->axismin[i])/j->axismax[i])-0.5)*2.0;				          //32768.0;
				}
			}
		}
	}
};

void macjoyelement(struct macjoy *j,CFDictionaryRef element)
{
	IOHIDElementCookie cookie;
	CFTypeRef object;
	long number,usage,page,axismax,axismin;
	int axis;

	object = CFDictionaryGetValue (element, CFSTR(kIOHIDElementCookieKey));
    if (object == 0 || CFGetTypeID (object) != CFNumberGetTypeID ()) return;
    if(!CFNumberGetValue ((CFNumberRef) object, kCFNumberLongType, &number)) return;
    cookie = (IOHIDElementCookie) number;

    object = CFDictionaryGetValue (element, CFSTR(kIOHIDElementUsageKey));
    if (object == 0 || CFGetTypeID (object) != CFNumberGetTypeID ()) return;
	if (!CFNumberGetValue ((CFNumberRef) object, kCFNumberLongType, &number)) return;
	usage = number;

	axismax=0;axismin=0;
	object=CFDictionaryGetValue(element,CFSTR(kIOHIDElementMaxKey));
	if (object && CFNumberGetValue(object, kCFNumberLongType, &number)){
		axismax=number;
//		printf("max=%d\n",number);fflush(stdout);
	}
	object=CFDictionaryGetValue(element,CFSTR(kIOHIDElementMinKey));
	if (object && CFNumberGetValue(object, kCFNumberLongType, &number)){
		axismin=number;
//		printf("min=%d\n",number);fflush(stdout);
	}

	object = CFDictionaryGetValue (element,CFSTR(kIOHIDElementUsagePageKey));
	if (object == 0 || CFGetTypeID (object) != CFNumberGetTypeID ()) return;
    if (!CFNumberGetValue ((CFNumberRef) object, kCFNumberLongType, &number)) return;
    page = number;

	switch (page)
	{
	case kHIDPage_GenericDesktop:
//		printf("page=kHIDPage_GenericDesktop usage=%d cookie=%d\n",usage,cookie); 
		axis=-1;
		switch (usage)
		{
			case kHIDUsage_GD_X:
				axis=JOYX;
				break;
			case kHIDUsage_GD_Y:
				axis=JOYY;
				break;
			case kHIDUsage_GD_Z:
				axis=JOYZ;
				break;
			case kHIDUsage_GD_Rz:
				axis=JOYR;
				break;
			case kHIDUsage_GD_Ry:
				axis=JOYU;
				break;
			case kHIDUsage_GD_Rx:
				axis=JOYV;
				break;
			case kHIDUsage_GD_Slider:
				axis=JOYYAW;
				break;
			case kHIDUsage_GD_Hatswitch:
				axis=JOYHAT;
				break;
			case kHIDUsage_GD_Wheel:
				axis=JOYWHEEL;
				break;
		}
		if (axis!=-1){
			j->axis[axis]=cookie;
			j->axismax[axis]=axismax-axismin;
			j->axismin[axis]=axismin;
		}
		break;
	case kHIDPage_Button:
//		printf("page=kHIDPage_Button usage=%d cookie=%d\n",usage,cookie);
		if (usage>0 && usage<=32)
		{
			usage--;
			if (!j->button[usage]) j->button[usage]=cookie;
		}
		break;
	}
}

void enumprops(CFTypeRef object,struct macjoy *j)
{
	CFTypeID 	type;
	const void	**keys,**vals,*obj;
	CFTypeRef	key,val;
	int			n,k;
	const char 	*c;

	if (!object) return;

	type=CFGetTypeID(object);

	if (type==CFArrayGetTypeID())
	{
//		printf( "array!\n" );
		n=CFArrayGetCount( object );
		for( k=0;k<n;++k )
		{
			obj=CFArrayGetValueAtIndex( object,k );
			enumprops(obj,j);
		}
		return;
	}

	if (type==CFDictionaryGetTypeID())
	{
//		printf( "dictionery!\n" );
		macjoyelement(j,object);
		n=CFDictionaryGetCount( object );
		keys=(const void**)malloc( n*sizeof(void*) );
		vals=(const void**)malloc( n*sizeof(void*) );
		CFDictionaryGetKeysAndValues( object,keys,vals );
		for (k=0;k<n;++k)
		{
			key=keys[k];
			val=vals[k];
			type=CFGetTypeID(key);
			if (type==CFStringGetTypeID())
			{
				c=CFStringGetCStringPtr(key,CFStringGetSystemEncoding());
				if (c)
				{
//					printf("%s\n",c);
					enumprops(val,j);
				}
			}
			else
			{
//				printf( "<unknown keytype>\n");
			}
		}
		free( vals );
		free( keys );
		return;
	}
}


int macjoycount=0;
struct macjoy *joylist[16];

void enumhid(UInt32 page,UInt32 usage)
{
	CFMutableDictionaryRef	dic,props;
	CFNumberRef				rpage,rusage;
	CFTypeRef 				element;	
	IOHIDDeviceInterface	**device;
    io_iterator_t			it;
	io_object_t				obj;
	IOReturn				res;
	struct macjoy			*joy;
	int						i,m;

	dic=IOServiceMatching(kIOHIDDeviceKey);
    if (dic==0) {printf("No dictionary returned by IOServiceMatching");return;}
	rpage=CFNumberCreate(kCFAllocatorDefault,kCFNumberIntType,&page);
	rusage=CFNumberCreate(kCFAllocatorDefault,kCFNumberIntType,&usage);
	CFDictionarySetValue(dic,CFSTR(kIOHIDPrimaryUsagePageKey),rpage);
	CFDictionarySetValue(dic,CFSTR(kIOHIDPrimaryUsageKey),rusage);
	res=IOServiceGetMatchingServices(masterPort,dic,&it);
	if (res!=kIOReturnSuccess) {printf("IOServiceGetMatchingServices failed");return;}

	while (obj=IOIteratorNext(it))
	{
		device=OpenDevice(obj);
		if (device)
		{
//			printf("Got HID Device Handle\n");
			joy=calloc(1,sizeof (struct macjoy));
			joy->device=device;

			res=IORegistryEntryCreateCFProperties(obj,&props,kCFAllocatorDefault,kNilOptions);
			if (res!=kIOReturnSuccess) {printf("IORegistryEntryCreateCFProperties failed");return;}

//			MyShowObject(props);
			enumprops(props,joy);

			m=0;for (i=0;i<32;i++) {if (joy->button[i]) m|=1<<i;}
			joy->bcaps=m;

			m=0;for (i=0;i<16;i++) {if (joy->axis[i]) m|=1<<i;}
			joy->acaps=m;

			if (macjoycount<16) joylist[macjoycount++]=joy;
		}
	}
    IOObjectRelease(it);
}

int InitMacJoy()
{
    io_iterator_t 	it;
	IOReturn		res;

//	printf("enumerating hid devices\n");

	macjoycount=0;

	res=IOMasterPort (bootstrap_port, &masterPort);
	if (res) printf("IOMasterPort failed\n");

	enumhid(kHIDPage_GenericDesktop,kHIDUsage_GD_Joystick);
	enumhid(kHIDPage_GenericDesktop,kHIDUsage_GD_GamePad);
	enumhid(kHIDPage_GenericDesktop,kHIDUsage_GD_MultiAxisController);

//    if (masterPort) mach_port_deallocate(mach_task_self(),masterPort);
}

int JoyCount()
{
	if( !macjoycount ) InitMacJoy();
	return macjoycount;
}

char *JoyCName(int port)
{
	return "MacOSX Joystick";
}

int JoyButtonCaps(int port)
{
	if (port>=0 && port<macjoycount) return joylist[port]->bcaps;
	return 0;
}

int JoyAxisCaps(int port)
{
	if (port>=0 && port<macjoycount) return joylist[port]->acaps;
	return 0;
}

int ReadJoy(int port,int *buttons,float *axis)
{
	if (port>=0 && port<macjoycount) readmacjoy(joylist[port],buttons,axis);
	return 0;
}

void WriteJoy(int port,int channel,float value)
{
}
