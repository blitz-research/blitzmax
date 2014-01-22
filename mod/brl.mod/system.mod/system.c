
#include "system.h"

void brl_event_EmitEvent( BBObject *event );
BBObject *brl_event_CreateEvent( int id,BBObject *source,int data,int mods,int x,int y,BBObject *extra );

void bbSystemEmitEvent( int id,BBObject *source,int data,int mods,int x,int y,BBObject *extra ){
	BBObject *event=brl_event_CreateEvent( id,source,data,mods,x,y,extra );
	brl_event_EmitEvent( event );
}
