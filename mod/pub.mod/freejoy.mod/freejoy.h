// freejoy.h

#ifndef freejoy_h
#define freejoy_h

enum axisbits {JOYX,JOYY,JOYZ,JOYR,JOYU,JOYV,JOYYAW,JOYPITCH,JOYROLL,JOYHAT,JOYWHEEL};

int JoyCount();
char *JoyCName(int port);
int JoyButtonCaps(int port);
int JoyAxisCaps(int port);
int ReadJoy(int port,int *buttons,float *axis);
void WriteJoy(int port,int channel,float value);

#endif
