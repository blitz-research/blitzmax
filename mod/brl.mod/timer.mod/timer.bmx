
Strict

Rem
bbdoc: Events/Timers
End Rem
Module BRL.Timer

ModuleInfo "Version: 1.02"
ModuleInfo "Author: Simon Armstrong, Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

Rem
History:

Removed use of _cycle:TTimer field to keep timer's alive - didn't work with 'real' GC!
Replaced with BBRETAIN/BBRELEASE in C code.

Added check for OS timer creation failure

Added check for Win32 timer firing after timeKillEvent

Removed brl.standardio dependancy
End Rem

Import BRL.System

?Win32
Import "timer.win32.c"
?MacOS
Import "timer.macos.m"
?Linux
Import "timer.linux.c"
?

Extern
Function bbTimerStart( hertz#,timer:TTimer )
Function bbTimerStop( handle,timer:TTimer )
End Extern

Function _TimerFired( timer:TTimer )
	timer.Fire
End Function

Type TTimer

	Method Ticks()
		Return _ticks
	End Method
	
	Method Stop()
		If Not _handle Return
		bbTimerStop _handle,Self
		_handle=0
		_event=Null
'		_cycle=Null
	End Method
	
	Method Fire()
		If Not _handle Return
		_ticks:+1
		If _event
			EmitEvent _event
		Else
			EmitEvent CreateEvent( EVENT_TIMERTICK,Self,_ticks )
		EndIf
	End Method

	Method Wait()
		If Not _handle Return
		Local n
		Repeat
			WaitSystem
			n=_ticks-_wticks
		Until n
		_wticks:+n
		Return n
	End Method
	
	Function Create:TTimer( hertz#,event:TEvent=Null )
		Local t:TTimer=New TTimer
		Local handle=bbTimerStart( hertz,t )
		If Not handle Return
'		t._cycle=t
		t._event=event
		t._handle=handle
		Return t
	End Function

	Field _ticks
	Field _wticks
	Field _cycle:TTimer	'no longer used...see history
	Field _event:TEvent
	Field _handle

End Type

Rem
bbdoc: Create a timer
returns: A new timer object
about:
#CreateTimer creates a timer object that 'ticks' @hertz times per second.

Each time the timer ticks, @event will be emitted using #EmitEvent.

If @event is Null, an event with an @id equal to EVENT_TIMERTICK and 
@source equal to the timer object will be emitted instead.
End Rem
Function CreateTimer:TTimer( hertz#,event:TEvent=Null )
	Return TTimer.Create( hertz,event )
End Function

Rem
bbdoc: Get timer tick counter
returns: The number of times @timer has ticked over
End Rem
Function TimerTicks( timer:TTimer )
	Return timer.Ticks()
End Function

Rem
bbdoc: Wait until a timer ticks
returns: The number of ticks since the last call to #WaitTimer
End Rem
Function WaitTimer( timer:TTimer )
	Return timer.Wait()
End Function

Rem
bbdoc: Stop a timer
about:Once stopped, a timer can no longer be used.
End Rem
Function StopTimer( timer:TTimer )
	timer.Stop
End Function
