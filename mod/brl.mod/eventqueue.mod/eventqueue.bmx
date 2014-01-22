
Strict

Rem
bbdoc: Events/Event queue
End Rem
Module BRL.EventQueue

ModuleInfo "Version: 1.01"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.01 Release"
ModuleInfo "History: Fixed CurrentEvent being retained in queue array"
ModuleInfo "History: 1.00 Release"
ModuleInfo "History: Created module"

Import BRL.Event
Import BRL.System

Private

Const QUEUESIZE=256
Const QUEUEMASK=QUEUESIZE-1
Global queue:TEvent[QUEUESIZE],queue_put,queue_get

Function Hook:Object( id,data:Object,context:Object )
	Local ev:TEvent=TEvent( data )
	If Not ev Return
	
	Select ev.id
	Case EVENT_WINDOWMOVE,EVENT_WINDOWSIZE,EVENT_TIMERTICK,EVENT_GADGETACTION
		PostEvent ev,True
	Default
		PostEvent ev
	End Select
	
	Return data
End Function

AddHook EmitEventHook,Hook,Null,-10000

Global NullEvent:TEvent=New TEvent

Public

Rem
bbdoc: Current Event
about: The #CurrentEvent global variable contains the event most recently returned by
#PollEvent or #WaitEvent.
End Rem
Global CurrentEvent:TEvent=NullEvent

Rem
bbdoc: Examine the next event in the event queue
about:
#PeekEvent examines the next event in the event queue, without removing it from the 
event queue or modifying the #CurrentEvent global variable.

If there are no events in the event queue, #PeekEvent returns #Null.
End Rem
Function PeekEvent:TEvent()
	If queue_get=queue_put
		PollSystem
		If queue_get=queue_put Return Null
	EndIf
	Return queue[queue_get & QUEUEMASK]
End Function

Rem
bbdoc: Get the next event from the event queue
returns: The id of the next event in the event queue, or 0 if the event queue is empty
about:
#PollEvent removes an event from the event queue and updates the #CurrentEvent
global variable.

If there are no events in the event queue, #PollEvent returns 0.
End Rem
Function PollEvent()
	If queue_get=queue_put
		PollSystem
		If queue_get=queue_put
			CurrentEvent=NullEvent
			Return 0
		EndIf
	EndIf
	CurrentEvent=queue[queue_get & QUEUEMASK]
	queue[queue_get & QUEUEMASK]=Null
	queue_get:+1
	Return CurrentEvent.id
End Function

Rem
bbdoc: Get the next event from the event queue, waiting if necessary
returns: The id of the next event in the event queue
about:
#WaitEvent removes an event from the event queue and updates the #CurrentEvent
global variable.

If there are no events in the event queue, #WaitEvent halts program execution until
an event is available.
End Rem
Function WaitEvent()
	While queue_get=queue_put
		WaitSystem
	Wend
	CurrentEvent=queue[queue_get & QUEUEMASK]
	queue[queue_get & QUEUEMASK]=Null
	queue_get:+1
	Return CurrentEvent.id
End Function

Rem
bbdoc: Post an event to the event queue
about:#PostEvent adds an event to the end of the event queue.

The @update flag can be used to update an existing event. If @update is True
and an event with the same @id and @source is found in the event 
queue, the existing event will be updated instead of @event
being added to the event queue. This can be useful to prevent high frequency
events such as timer events from flooding the event queue.
End Rem
Function PostEvent( event:TEvent,update=False )
	If update
		Local i=queue_get
		While i<>queue_put
			Local t:TEvent=queue[i & QUEUEMASK ]
			If t.id=event.id And t.source=event.source
				t.data=event.data
				t.mods=event.mods
				t.x=event.x
				t.y=event.y
				t.extra=event.extra
				Return
			EndIf
			i:+1
		Wend
	EndIf
	If queue_put-queue_get=QUEUESIZE Return
	queue[queue_put & QUEUEMASK]=event
	queue_put:+1
End Function

Rem
bbdoc: Get current event id
returns: The @id field of the #CurrentEvent global variable
EndRem
Function EventID()
	Return CurrentEvent.id
End Function

Rem
bbdoc: Get current event data
returns: The @data field of the #CurrentEvent global variable
EndRem
Function EventData()
	Return CurrentEvent.data
End Function

Rem
bbdoc: Get current event modifiers
returns: The @mods field of the #CurrentEvent global variable
EndRem
Function EventMods()
	Return CurrentEvent.mods
End Function

Rem
bbdoc: Get current event x value
returns: The @x field of the #CurrentEvent global variable
EndRem
Function EventX()
	Return CurrentEvent.x
End Function

Rem
bbdoc: Get current event y value
returns: The @y field of the #CurrentEvent global variable
EndRem
Function EventY()
	Return CurrentEvent.y
End Function

Rem
bbdoc: Get current event extra value
returns: The @extra field of the #CurrentEvent global variable
EndRem
Function EventExtra:Object()
	Return CurrentEvent.extra
End Function

Rem
bbdoc: Get current event extra value converted to a string
returns: The @extra field of the #CurrentEvent global variable converted to a string
EndRem
Function EventText$()
	Return String( CurrentEvent.extra )
End Function

Rem
bbdoc: Get current event source object
returns: The @source field of the #CurrentEvent global variable
EndRem
Function EventSource:Object()
	Return CurrentEvent.source
End Function

Rem
bbdoc: Get current event source object handle
returns: The @source field of the #CurrentEvent global variable converted to an integer handle
EndRem
Function EventSourceHandle()
	Return HandleFromObject( CurrentEvent.source )
End Function
