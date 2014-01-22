Strict

Import BRL.Event

Import "gadget.bmx"

Function PostGuiEvent( id,source:TGadget=Null,data=0,mods=0,x=0,y=0,extra:Object=Null )

	If source Then
		While source.source
			source=source.source
		Wend
	EndIf

	EmitEvent CreateEvent( id,source,data,mods,x,y,extra )
		
End Function

Function QueueGuiEvent( id,source:TGadget=Null,data=0,mods=0,x=0,y=0,extra:Object=Null )

	If source Then
		While source.source
			source=source.source
		Wend
	EndIf

	eventQueue.AddLast CreateEvent( id,source,data,mods,x,y,extra )
		
End Function

Function DispatchGuiEvents()

	For Local tmpEvent:TEvent = EachIn eventQueue
		EmitEvent tmpEvent
	Next
	
	eventQueue.Clear()
	
End Function

Private

Global eventQueue:TList = New TList
