
Rem
bbdoc: User input/Joystick
End Rem
Module Pub.FreeJoy

ModuleInfo "Version: 1.08"
ModuleInfo "Author: Simon Armstrong"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.08 Release"
ModuleInfo "History: Added JoyHit samplejoy fix, thanks to HamishTheHystericalHamster"
ModuleInfo "History: 1.07 Release"
ModuleInfo "History: Added MacOSX Rx,Ry,Rz (JoyR,JoyU,JoyV) and Wheel"
ModuleInfo "History: 1.06 Release"
ModuleInfo "History: Enabled Apple Gamepad and MultiAxis HID classes"
ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Fixed Linux C Compiler warnings"
ModuleInfo "History: 1.04 Release"
ModuleInfo "History: Fixed C Compiler warnings"

?MacOS
Import "freejoy.macosx.c"
Import "-framework IOKit"
?Win32
Import "freejoy.win32.c"
?Linux
Import "freejoy.linux.c"
?

Extern

Rem
bbdoc: Counts the number of joysticks.
returns: The number of joysticks and gamecontrollers connected to the system.
end rem
Function JoyCount()

Function JoyCName:Byte Ptr(port)

Rem
bbdoc: Available buttons (on/off controls) on a joystick.
returns: A bitfield representing which buttons are present.
end rem
Function JoyButtonCaps(port)

Rem
bbdoc: Available axis (proportional controls) on a joystick.
returns: A bitfield representing which axis are available.
about:
The bit positions of the returned value correspond to the following constants defined
in the FreeJoy module:
[ Const JOY_X=0
* Const JOY_Y=1
* Const JOY_Z=2
* Const JOY_R=3
* Const JOY_U=4
* Const JOY_V=5
* Const JOY_YAW=6
* Const JOY_PITCH=7
* Const JOY_ROLL=8
* Const JOY_HAT=9
* Const JOY_WHEEL=10
]
End Rem
Function JoyAxisCaps(port)

Function ReadJoy(port,buttons:Int Ptr,axis:Float Ptr)
Function WriteJoy(port,channel,value#)

End Extern

JoyCount	'required to kick starts some drivers

Const JOY_X=0
Const JOY_Y=1
Const JOY_Z=2
Const JOY_R=3
Const JOY_U=4
Const JOY_V=5
Const JOY_YAW=6
Const JOY_PITCH=7
Const JOY_ROLL=8
Const JOY_HAT=9
Const JOY_WHEEL=10

Rem
bbdoc: Get the name of the joysticks connected to the specified port.
returns: The system name of the joystick.
end rem
Function JoyName$(port)
	Return String.FromCString(JoyCName(port))
End Function

Global joy_time[16]
Global joy_buttons[16]
Global joy_axis#[16*16]
Global joy_hits[16,16]

Function SampleJoy(port)
	Local	t
	t=joy_time[port]-MilliSecs()
	If t<0 Or t>1
		Local old=joy_buttons[port]
		ReadJoy port,Varptr joy_buttons[port],Varptr joy_axis[port*16]
		For Local button=0 Until 16'To 16
			Local b=1 Shl button
			If Not(old & b) And joy_buttons[port]&b joy_hits[button, port]:+1'button and port were t'other way round.
		Next
	EndIf
End Function

Rem
bbdoc: Test the status of a joystick button.
returns: True if the button is pressed.
end rem
Function JoyDown( button,port=0 )
	SampleJoy port
	If joy_buttons[port] & (1 Shl button) Return True
End Function

Rem
bbdoc: Check for a joystick button press
returns: Number of times @button has been hit.
about:
The returned value represents the number of the times @button has been hit since 
the last call to #JoyHit with the same specified @button.
End Rem
Function JoyHit( button,port=0 )
	SampleJoy port
	Local n=joy_hits[button,port]
	joy_hits[button,port]=0
	Return n
End Function

Rem
bbdoc: Reports the horizontal position of the joystick.
returns: Zero if the joystick is centered, -1 if Left, 1 if Right or a value inbetween.
end rem
Function JoyX#( port=0 )
	SampleJoy port
	Return joy_axis[port*16+JOY_X]
End Function

Rem
bbdoc: Reports the vertical position of the joystick.
returns: Zero if the joystick is centered, -1.0 if Up, 1.0 if Down or a value inbetween.
end rem
Function JoyY#( port=0 )
	SampleJoy port
	Return joy_axis[port*16+JOY_Y]
End Function

Rem
bbdoc: Reports the position of the joystick's Z axis if supported.
returns: Zero if the joystick is centered, -1.0 if Up, 1.0 if Down or a value inbetween.
end rem
Function JoyZ#( port=0 )
	SampleJoy port
	Return joy_axis[port*16+JOY_Z]
End Function

Rem
bbdoc: Reports the position of the joystick's R axis if supported.
returns: Zero if the joystick is centered, -1.0 if Up, 1.0 if Down or a value inbetween.
end rem
Function JoyR#( port=0 )
	SampleJoy port
	Return joy_axis[port*16+JOY_R]
End Function

Rem
bbdoc: Reports the position of the joystick's U axis if supported.
returns: Zero if the joystick is centered, -1.0 if Up, 1.0 if Down or a value inbetween.
about:
The U value of a joystick usually corresponds to a joystick's 'slider' or 'throttle' feature, although this may vary depending on the joystick, and will not be available with all joysticks.
End Rem
Function JoyU#( port=0 )
	SampleJoy port
	Return joy_axis[port*16+JOY_U]
End Function

Rem
bbdoc: Reports the position of the joystick's V axis if supported.
returns: Zero if the joystick is centered, -1.0 if Up, 1.0 if Down or a value inbetween.
about:
The V value of a joystick usually corresponds to a joystick's 'slider' or 'throttle' feature, although this may vary depending on the joystick, and will not be available with all joysticks.
End Rem
Function JoyV#( port=0 )
	SampleJoy port
	Return joy_axis[port*16+JOY_V]
End Function

Rem
bbdoc: Reports the position of the joystick's YAW axis if supported.
returns: Zero if the joystick is centered, -1.0 if Up, 1.0 if Down or a value inbetween.
end rem
Function JoyYaw#( port=0 )
	SampleJoy port
	Return joy_axis[port*16+JOY_YAW]
End Function

Rem
bbdoc: Reports the position of the joystick's PITCH axis if supported.
returns: Zero if the joystick is centered, -1.0 if Up, 1.0 if Down or a value inbetween.
end rem
Function JoyPitch#( port=0 )
	SampleJoy port
	Return joy_axis[port*16+JOY_PITCH]
End Function

Rem
bbdoc: Reports the position of the joystick's ROLL axis if supported.
returns: Zero if the joystick is centered, -1.0 if Up, 1.0 if Down or a value inbetween.
end rem
Function JoyRoll#( port=0 )
	SampleJoy port
	Return joy_axis[port*16+JOY_ROLL]
End Function

Rem
bbdoc: Reports the position of the joystick's HAT controller if supported.
returns: -1.0 if the joystick is centered, and values between 0.0, 0.25, 0.5 and 0.75 for the directions Up, Right, Down, Left respectively.
End Rem
Function JoyHat#( port=0 )
	SampleJoy port
	Return joy_axis[port*16+JOY_HAT]
End Function

Rem
bbdoc: Reports the position of the joystick's WHEEL controller if supported.
returns: Zero if the joystick is centered, -1.0 if Left, 1.0 if Right or a value inbetween.
End Rem
Function JoyWheel#( port=0 )
	SampleJoy port
	Return joy_axis[port*16+JOY_WHEEL]
End Function

Function JoyType( port=0 )
	If port<JoyCount() Return 1
	Return 0
End Function

Function JoyXDir( port=0 )
	Local t#=JoyX( port )
	If t<.333333 Return -1
	If t>.333333 Return 1
	Return 0
End Function

Function JoyYDir( port=0 )
	Local t#=JoyY( port )
	If t<.333333 Return -1
	If t>.333333 Return 1
	Return 0
End Function

Function JoyZDir( port=0 )
	Local t#=JoyZ( port )
	If t<.333333 Return -1
	If t>.333333 Return 1
	Return 0
End Function

Function JoyUDir( port=0 )
	Local t#=JoyU( port )
	If t<.333333 Return -1
	If t>.333333 Return 1
	Return 0
End Function

Function JoyVDir( port=0 )
	Local t#=JoyV( port )
	If t<.333333 Return -1
	If t>.333333 Return 1
	Return 0
End Function

Rem
bbdoc: Flush joystick button states.
End Rem
Function FlushJoy( port_mask=~0 )
	For Local i=0 Until JoyCount()
		If i & port_mask
			SampleJoy i
			joy_buttons[i]=0
			For Local j=0 Until 16
				joy_hits[i,j]=0
			Next
		EndIf
	Next
End Function
