
Strict

Rem
bbdoc: Events/Events
End Rem
Module BRL.Event

ModuleInfo "Version: 1.03"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.03 Release"
ModuleInfo "History: Added missing EVENT_HOTKEY ToString case"
ModuleInfo "History: Added process events"
ModuleInfo "History: 1.02 Release"
ModuleInfo "History: Added EVENT_GADGETLOSTFOCUS"
ModuleInfo "History: 1.01 Release"
ModuleInfo "History: Added EVENT_KEYREPEAT"

Import BRL.Hook

Rem
bbdoc: Hook id for emitted events
about:
The #EmitEventHook global variable contains a hook id for use with #AddHook.

Each time #EmitEvent is called, the event is passed to all #EmitEventHook 
hook functions by means of the hook function @data parameter.
End Rem
Global EmitEventHook=AllocHookId()

Rem
bbdoc: Event object type
EndRem
Type TEvent

	Rem
	bbdoc: Event identifier
	End Rem
	Field id
	
	Rem
	bbdoc: Event source object
	End Rem
	Field source:Object
	
	Rem
	bbdoc: Event specific data
	End Rem
	Field data
	
	Rem
	bbdoc: Event specific modifiers
	End Rem
	Field mods
	
	Rem
	bbdoc: Event specific position data
	End Rem
	Field x
	
	Rem
	bbdoc: Event specific position data
	End Rem
	Field y
	
	Rem
	bbdoc: Event specific extra information
	End Rem
	Field extra:Object
	
	Rem
	bbdoc: Emit this event
	about:
	This method runs all #EmitEventHook hook function, passing @Self as
	the hook data.
	End Rem
	Method Emit()
		RunHooks EmitEventHook,Self
	End Method

	Rem
	bbdoc: Convert event to a string
	about:
	This method is mainly useful for debugging purposes.
	End Rem	
	Method ToString$()
		Local t$=DescriptionForId( id )
		If Not t
			If id & EVENT_USEREVENTMASK
				t="UserEvent"+(id-EVENT_USEREVENTMASK)
			Else
				t="Unknown Event, id="+id
			EndIf
		EndIf
		Return t+": data="+data+", mods="+mods+", x="+x+", y="+y+", extra=~q"+String(extra)+"~q"
	End Method
	
	Rem
	bbdoc: Create an event object
	returns: A new event object
	End Rem
	Function Create:TEvent( id,source:Object=Null,data=0,mods=0,x=0,y=0,extra:Object=Null )
		Local t:TEvent=New TEvent
		t.id=id
		t.source=source
		t.data=data
		t.mods=mods
		t.x=x
		t.y=y
		t.extra=extra
		Return t
	End Function
	
	Rem
	bbdoc: Allocate a user event id
	returns: A new user event id
	End Rem
	Function AllocUserId()
		Global _id=EVENT_USEREVENTMASK
		_id:+1
		Return _id
	End Function
	
	Function RegisterId( id,description$ )
		_regids:+String(id)+"{"+description+"}"
	End Function
	
	Function DescriptionForId$( id )
		Local t$="}"+String(id)+"{"
		Local i=_regids.Find( t )
		If i=-1 Return
		i:+t.length
		Local i2=_regids.Find( "}",i )
		If i2=-1 Return
		Return _regids[i..i2]
	End Function

	Global _regids$="}"
	
End Type

Const EVENT_APPMASK=$100
Const EVENT_APPSUSPEND=$101
Const EVENT_APPRESUME=$102
Const EVENT_APPTERMINATE=$103
Const EVENT_APPOPENFILE=$104
Const EVENT_APPIDLE=$105		'Reserved by Mark!
Const EVENT_KEYMASK=$200
Const EVENT_KEYDOWN=$201
Const EVENT_KEYUP=$202
Const EVENT_KEYCHAR=$203
Const EVENT_KEYREPEAT=$204
Const EVENT_MOUSEMASK=$400
Const EVENT_MOUSEDOWN=$401
Const EVENT_MOUSEUP=$402
Const EVENT_MOUSEMOVE=$403
Const EVENT_MOUSEWHEEL=$404
Const EVENT_MOUSEENTER=$405
Const EVENT_MOUSELEAVE=$406
Const EVENT_TIMERMASK=$800
Const EVENT_TIMERTICK=$801
Const EVENT_HOTKEYMASK=$1000
Const EVENT_HOTKEYHIT=$1001
Const EVENT_GADGETMASK=$2000
Const EVENT_GADGETACTION=$2001
Const EVENT_GADGETPAINT=$2002
Const EVENT_GADGETSELECT=$2003
Const EVENT_GADGETMENU=$2004
Const EVENT_GADGETOPEN=$2005
Const EVENT_GADGETCLOSE=$2006
Const EVENT_GADGETDONE=$2007
Const EVENT_GADGETLOSTFOCUS=$2008
Const EVENT_GADGETSHAPE=$2009	'reserved by Mark!
Const EVENT_WINDOWMASK=$4000
Const EVENT_WINDOWMOVE=$4001
Const EVENT_WINDOWSIZE=$4002
Const EVENT_WINDOWCLOSE=$4003
Const EVENT_WINDOWACTIVATE=$4004
Const EVENT_WINDOWACCEPT=$4005
Const EVENT_MENUMASK=$8000
Const EVENT_MENUACTION=$8001
Const EVENT_STREAMMASK=$10000
Const EVENT_STREAMEOF=$10001
Const EVENT_STREAMAVAIL=$10002
Const EVENT_PROCESSMASK=$20000
Const EVENT_PROCESSEXIT=$20001
Const EVENT_USEREVENTMASK=$80000000

TEvent.RegisterId EVENT_APPSUSPEND,"AppSuspend"
TEvent.RegisterId EVENT_APPRESUME,"AppResume"
TEvent.RegisterId EVENT_APPTERMINATE,"AppTerminate"
TEvent.RegisterId EVENT_APPOPENFILE,"AppOpenFile"
TEvent.RegisterId EVENT_APPIDLE,"AppIdle"
TEvent.RegisterId EVENT_KEYDOWN,"KeyDown"
TEvent.RegisterId EVENT_KEYUP,"KeyUp"
TEvent.RegisterId EVENT_KEYCHAR,"KeyChar"
TEvent.RegisterId EVENT_KEYREPEAT,"KeyRepeat"
TEvent.RegisterId EVENT_MOUSEDOWN,"MouseDown"
TEvent.RegisterId EVENT_MOUSEUP,"MouseUp"
TEvent.RegisterId EVENT_MOUSEMOVE,"MouseMove"
TEvent.RegisterId EVENT_MOUSEWHEEL,"MouseWheel"
TEvent.RegisterId EVENT_MOUSEENTER,"MouseEnter"
TEvent.RegisterId EVENT_MOUSELEAVE,"MouseLeave"
TEvent.RegisterId EVENT_TIMERTICK,"TimerTick"
TEvent.RegisterId EVENT_HOTKEYHIT,"HotkeyHit"
TEvent.RegisterId EVENT_GADGETACTION,"GadgetAction"
TEvent.RegisterId EVENT_GADGETPAINT,"GadgetPaint"
TEvent.RegisterId EVENT_GADGETSELECT,"GadgetSelect"
TEvent.RegisterId EVENT_GADGETMENU,"GadgetMenu"
TEvent.RegisterId EVENT_GADGETOPEN,"GadgetOpen"
TEvent.RegisterId EVENT_GADGETCLOSE,"GadgetClose"
TEvent.RegisterId EVENT_GADGETDONE,"GadgetDone"
TEvent.RegisterId EVENT_GADGETLOSTFOCUS,"GadgetLostFocus"
TEvent.RegisterId EVENT_GADGETSHAPE,"GadgetShape"
TEvent.RegisterId EVENT_WINDOWMOVE,"WindowMove"
TEvent.RegisterId EVENT_WINDOWSIZE,"WindowSize"
TEvent.RegisterId EVENT_WINDOWCLOSE,"WindowClose"
TEvent.RegisterId EVENT_WINDOWACTIVATE,"WindowActivate"
TEvent.RegisterId EVENT_WINDOWACCEPT,"WindowAccept"
TEvent.RegisterId EVENT_MENUACTION,"MenuAction"
TEvent.RegisterId EVENT_STREAMEOF,"StreamEof"
TEvent.RegisterId EVENT_STREAMAVAIL,"StreamAvail"
TEvent.RegisterId EVENT_PROCESSEXIT,"ProcessExit"

Rem
bbdoc: Emit an event
about:
Runs all #EmitEventHook hooks, passing @event as the hook data.
End Rem
Function EmitEvent( event:TEvent )
	event.Emit
End Function

Rem
bbdoc: Create an event object
returns: A new event object
End Rem
Function CreateEvent:TEvent( id,source:Object=Null,data=0,mods=0,x=0,y=0,extra:Object=Null )
	Return TEvent.Create( id,source,data,mods,x,y,extra )
End Function

Rem
bbdoc: Allocate a user event id
returns: A new user event id
End Rem
Function AllocUserEventId( description$="" )
	Local id=TEvent.AllocUserId()
	If description TEvent.RegisterId id,description
	Return id
End Function
