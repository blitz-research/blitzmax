
Strict

Rem
bbdoc: Audio/OpenAL 1.1
about:
<table>
<tr><th>Constants</th><th>Description</th></tr>
<tr><td>AL_INVALID<br>AL_NONE</td><td>bad value</td></tr>
<tr><td>AL_FALSE</td><td>Boolean False.</td></tr>
<tr><td>AL_TRUE</td><td>Boolean True.</td></tr>
<tr><td>AL_SOURCE_RELATIVE</td><td>Indicate Source has relative coordinates.</td></tr>
<tr><td>AL_CONE_INNER_ANGLE</td><td>Directional source, inner cone angle, in degrees.<br>Range:    [0-360] <br>Default:  360</td></tr>
<tr><td>AL_CONE_OUTER_ANGLE</td><td>Directional source, outer cone angle, in degrees.<br>Range:    [0-360] <br>Default:  360</td></tr>
<tr><td>AL_PITCH</td><td>Specify the pitch to be applied, either at source,or on mixer results, at listener.<br>Range:   [0.5-2.0]<br>Default: 1.0</td></tr>
<tr><td>AL_POSITION</td><td>Specify the current location in three dimensional space.<br>OpenAL, like OpenGL, uses a right handed coordinate system, where in a frontal default view X (thumb) points right, Y points up (index finger), and Z points towards the viewer/camera (middle finger). <br>To switch from a left handed coordinate system, flip the sign on the Z coordinate.<br>Listener position is always in the world coordinate system.</td></tr>
<tr><td>AL_DIRECTION</td><td>Specify the current direction.</td></tr>
<tr><td>AL_VELOCITY</td><td>Specify the current velocity in three dimensional space.</td></tr>
<tr><td>AL_LOOPING</td><td>Indicate whether source is looping.<br>Type: ALboolean?<br>Range:   [AL_TRUE, AL_FALSE]<br>Default: FALSE.</td></tr>
<tr><td>AL_BUFFER</td><td>Indicate the buffer to provide sound samples. <br>Type: ALuint.<br>Range: any valid Buffer id.</td></tr>
<tr><td>AL_GAIN</td><td>Indicate the gain (volume amplification) applied. <br>Type:   ALfloat.<br>Range:  ]0.0-  ]<br>A value of 1.0 means un-attenuated/unchanged.<br>Each division by 2 equals an attenuation of -6dB.<br>Each multiplicaton with 2 equals an amplification of +6dB.<br>A value of 0.0 is meaningless with respect to a logarithmic scale; it is interpreted as zero volume - the channel is effectively disabled.</td></tr>
<tr><td>AL_MIN_GAIN</td><td>Indicate minimum source attenuation<br>Type: ALfloat<br>Range:  [0.0 - 1.0]</td></tr>
<tr><td>AL_MAX_GAIN</td><td>Indicate maximum source attenuation<br>Type: ALfloat<br>Range:  [0.0 - 1.0]</td></tr>
<tr><td>AL_ORIENTATION</td><td>Indicate listener orientation.</td></tr>
<tr><td>AL_CHANNEL_MASK</td><td>Specify the channel mask. (Creative)<br>Type: ALuint<br>Range: [0 - 255]</td></tr>
<tr><td>AL_SOURCE_STATE<br>AL_INITIAL<br>AL_PLAYING<br>AL_PAUSED<br>AL_STOPPED</td><td>Source state information.</td></tr>
<tr><td>AL_BUFFERS_QUEUED<br>AL_BUFFERS_PROCESSED</td><td>Buffer Queue params</td></tr>
<tr><td>AL_SEC_OFFSET<br>AL_SAMPLE_OFFSET<br>AL_BYTE_OFFSET</td><td>Source buffer position information</td></tr>
<tr><td>AL_SOURCE_TYPE</td><td>Source type (Static, Streaming or undetermined)</td></tr>
<tr><td>AL_STATIC</td><td>Source is Static if a Buffer has been attached using AL_BUFFER</td></tr>
<tr><td>AL_STREAMING</td><td>Source is Streaming if one or more Buffers have been attached using alSourceQueueBuffers</td></tr>
<tr><td>AL_UNDETERMINED</td><td>Source is undetermined when it has the NULL buffer attached</td></tr>
<tr><td>AL_FORMAT_MONO8<br>AL_FORMAT_STEREO8<br>AL_FORMAT_MONO16<br>AL_FORMAT_STEREO16</td><td>Sound samples: format specifier.</td></tr>
<tr><td>AL_REFERENCE_DISTANCE</td><td>source specific reference distance<br>Type: ALfloat<br>Range:  0.0 - +inf<br><br>at 0.0, no distance attenuation occurs.  Default is 1.0.</td></tr>
<tr><td>AL_ROLLOFF_FACTOR</td><td>source specific rolloff factor<br>Type: ALfloat<br>Range:  0.0 - +inf</td></tr>
<tr><td>AL_CONE_OUTER_GAIN</td><td>Directional source, outer cone gain.<br>Default:  0.0<br>Range:    [0.0 - 1.0]</td></tr>
<tr><td>AL_MAX_DISTANCE</td><td>Indicate distance above which sources are not attenuated using the inverse clamped distance model.<br>Default: +inf<br>Type: ALfloat</td></tr>
<tr><td>AL_FREQUENCY<br>AL_BITS<br>AL_CHANNELS<br>AL_SIZE</td><td>frequency, in units of Hertz [Hz].<br>This is the number of samples per second. Half of the sample frequency marks the maximum significant frequency component.</td></tr>
<tr><td>AL_UNUSED<br>AL_PENDING<br>AL_PROCESSED</td><td>Buffer state.<br>not supported for public use (yet).</td></tr>
<tr><td>AL_NO_ERROR</td><td>No Error</td></tr>
<tr><td>AL_INVALID_NAME</td><td>Invalid Name paramater passed to AL call.</td></tr>
<tr><td>AL_ILLEGAL_ENUM<br>AL_INVALID_ENUM</td><td>Invalid parameter passed to AL call.</td></tr>
<tr><td>AL_INVALID_VALUE</td><td>Invalid enum parameter value.</td></tr>
<tr><td>AL_ILLEGAL_COMMAND<br>AL_INVALID_OPERATION</td><td>Illegal call.</td></tr>
<tr><td>AL_OUT_OF_MEMORY</td><td>No mojo.</td></tr>
<tr><td>AL_VENDOR<br>AL_VERSION<br>AL_RENDERER<br>AL_EXTENSIONS</td><td>Context strings: Vendor Name.</td></tr>
<tr><td>AL_DOPPLER_FACTOR</td><td>Doppler scale.  Default 1.0</td></tr>
<tr><td>AL_DOPPLER_VELOCITY</td><td>Tweaks speed of propagation.</td></tr>
<tr><td>AL_SPEED_OF_SOUND</td><td>Speed of Sound in units per second</td></tr>
<tr><td>AL_DISTANCE_MODEL<br>AL_INVERSE_DISTANCE<br>AL_INVERSE_DISTANCE_CLAMPED<br>AL_LINEAR_DISTANCE<br>AL_LINEAR_DISTANCE_CLAMPED<br>AL_EXPONENT_DISTANCE<br>AL_EXPONENT_DISTANCE_CLAMPED</td><td>Distance models<br><br>used in conjunction with DistanceModel<br><br>implicit: NONE, which disances distance attenuation.</td></tr>
</table><br>
<table>
<tr><th>ALC constants</th><th>Description</th></tr>
<tr><td>ALC_FALSE</td><td>False</td></tr>
<tr><td>ALC_TRUE</td><td>True</td></tr>
<tr><td>ALC_FREQUENCY</td><td>Frequency for mixing output buffer, in units of Hz</td></tr>
<tr><td>ALC_REFRESH</td><td>Refresh intervals, in units of Hz</td></tr>
<tr><td>ALC_SYNC</td><td>Flag, indicating a synchronous context</td></tr>
<tr><td>ALC_MONO_SOURCES</td><td>A hint indicating how many sources should be capable of supporting mono data</td></tr>
<tr><td>ALC_STEREO_SOURCES</td><td>A hint indicating how many sources should be capable of supporting stereo data</td></tr>
<tr><td>ALC_NO_ERROR</td><td>There is no current error.</td></tr>
<tr><td>ALC_INVALID_DEVICE</td><td>The device handle or specifier names an accessible driver/server</td></tr>
<tr><td>ALC_INVALID_CONTEXT</td><td>The Context argument does not name a valid context.</td></tr>
<tr><td>ALC_INVALID_ENUM</td><td>A token used is not valid, or not applicable.</td></tr>
<tr><td>ALC_INVALID_VALUE</td><td>A value (e.g. Attribute) is not valid, or not applicable.</td></tr>
<tr><td>ALC_OUT_OF_MEMORY</td><td>Unable to allocate memory.</td></tr>
<tr><td>ALC_DEFAULT_DEVICE_SPECIFIER</td><td>The specifier string for the default device</td></tr>
<tr><td>ALC_DEVICE_SPECIFIER</td><td>The specifier string for the device</td></tr>
<tr><td>ALC_EXTENSIONS</td><td>A list of available context extensions separated by spaces.</td></tr>
<tr><td>ALC_MAJOR_VERSION</td><td>The specification revision for this implementation (major version). NULL is an acceptable device.</td></tr>
<tr><td>ALC_MINOR_VERSION</td><td>The specification revision for this implementation (minor version). NULL is an acceptable device.</td></tr>
<tr><td>ALC_ATTRIBUTES_SIZE</td><td>The size (number of ALCint values) required for a zero-terminated attributes list, for the current context. NULL is an invalid device.</td></tr>
<tr><td>ALC_ALL_ATTRIBUTES</td><td>Expects a destination of ALC_ATTRIBUTES_SIZE, and provides an attribute list for the current context of the specified device. NULL is an invalid device.</td></tr>
<tr><td>ALC_CAPTURE_DEVICE_SPECIFIER</td><td>The name of the specified capture device, or a list of all available capture devices if no capture device is specified.</td></tr>
<tr><td>ALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER</td><td>The name of the default capture device</td></tr>
<tr><td>ALC_CAPTURE_SAMPLES</td><td>The number of capture samples available. NULL is an invalid device.</td></tr>
</table><br>
End Rem
Module Pub.OpenAL

ModuleInfo "Version: 1.03"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.03 Release"
ModuleInfo "History: alGetProcAddress now returns Byte Ptr"
ModuleInfo "History: 1.02 Release"
ModuleInfo "History: Added missing func check"
ModuleInfo "History: Fixed mispelled funcs"
ModuleInfo "History: Added Redi's docs"
ModuleInfo "History: 1.01 Initial Release"

Import "openal.c"

' download openal runtime library from http://www.openal.org

Private

Extern
Function LoadOpenAL()
Function GetOpenALFunction:Byte Ptr( fname$z )
End Extern

Global _ok=LoadOpenAL()

Function P:Byte Ptr(t$)
	Return GetOpenALFunction( t )
End Function

Public

Rem
bbdoc: Check if OpenAL is installed.
returns: True if OpenAL is installed.
about:
This function allows you to determine whether OpenAL is installed on the current machine.
End Rem
Function OpenALInstalled()
	Return _ok
End Function

'***** alc *****
Const ALC_FALSE=0
Const ALC_TRUE=1
Const ALC_FREQUENCY=$1007
Const ALC_REFRESH=$1008
Const ALC_SYNC=$1009
Const ALC_MONO_SOURCES=$1010
Const ALC_STEREO_SOURCES=$1011
Const ALC_NO_ERROR=ALC_FALSE
Const ALC_INVALID_DEVICE=$a001
Const ALC_INVALID_CONTEXT=$a002
Const ALC_INVALID_ENUM=$a003
Const ALC_INVALID_VALUE=$a004
Const ALC_OUT_OF_MEMORY=$a005
Const ALC_DEFAULT_DEVICE_SPECIFIER=$1004
Const ALC_DEVICE_SPECIFIER=$1005
Const ALC_EXTENSIONS=$1006
Const ALC_MAJOR_VERSION=$1000
Const ALC_MINOR_VERSION=$1001
Const ALC_ATTRIBUTES_SIZE=$1002
Const ALC_ALL_ATTRIBUTES=$1003
Const ALC_CAPTURE_DEVICE_SPECIFIER=$310
Const ALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER=$311
Const ALC_CAPTURE_SAMPLES=$312

Rem
bbdoc: This function opens a device by name.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>devicename</td><td>a null-terminated string describing a device</td></tr></table><br>
The return value will be NULL if there is an error.<br><br>
Returns a pointer to the opened device. Will return NULL if a device can not be opened.
End Rem
Global alcOpenDevice( devicename$z )=P("alcOpenDevice")
Rem
bbdoc: This function closes a device by name.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>device</td><td>a pointer to an opened device</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>ALC_INVALID_DEVICE</td><td>The specified device name doesn't exist.</td></tr></table><br>
Any contexts and buffers within the device will be destroyed when the device is closed, and ALC_TRUE will be returned on success or ALC_FALSE on failure.
End Rem
Global alcCloseDevice( device )=P("alcCloseDevice")
Rem
bbdoc: This function retrieves the current context error state.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>device</td><td>a pointer to the device to retrieve the error state from</td></tr></table><br>
End Rem
Global alcGetError( device )=P("alcGetError")
Rem
bbdoc: This function returns pointers to strings related to the context.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>device</td><td>a pointer to the device to be queried</td></tr>
<tr><td>param</td><td>an attribute to be retrieved:<br>ALC_DEFAULT_DEVICE_SPECIFIER<br>ALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER<br>ALC_DEVICE_SPECIFIER<br>ALC_CAPTURE_DEVICE_SPECIFIER<br>ALC_EXTENSIONS</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>ALC_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr></table><br>
ALC_DEFAULT_DEVICE_SPECIFIER will return the name of the default output device.<br><br>
ALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER will return the name of the default capture device.<br><br>
ALC_DEVICE_SPECIFIER will return the name of the specified output device if a pointer is supplied, or will return a list of all available devices if a NULL device pointer is supplied. A list is a pointer to a series of strings separated by NULL characters, with the list terminated by two NULL characters.<br><br>
ALC_CAPTURE_DEVICE_SPECIFIER will return the name of the specified capture device if a pointer is supplied, or will return a list of all available devices if a NULL device pointer is supplied.<br><br>
ALC_EXTENSIONS returns a list of available context extensions, with each extension separated by a space and the list terminated by a NULL character.<br><br>
End Rem
Global alcGetString:Byte Ptr( device,param )=P("alcGetString")
Rem
bbdoc: This function returns integers related to the context.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>device</td><td>a pointer to the device to be queried</td></tr>
<tr><td>param</td><td>an attribute to be retrieved:<br>ALC_MAJOR_VERSION<br>ALC_MINOR_VERSION<br>ALC_ATTRIBUTES_SIZE<br>ALC_ALL_ATTRIBUTES</td></tr>
<tr><td>size</td><td>the size of the destination buffer provided</td></tr>
<tr><td>data</td><td>a pointer to the data to be returned</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>ALC_INVALID_VALUE</td><td>The specified data pointer or size is not valid.</td></tr>
<tr><td>ALC_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>ALC_INVALID_DEVICE</td><td>The specified device is not valid.</td></tr>
<tr><td>ALC_INVALID_CONTEXT</td><td>The specified context is not valid.</td></tr></table><br>
The versions returned refer to the specification version that the implementation meets.
End Rem
Global alcGetIntegerv( device,param,size,data:Int Ptr )=P("alcGetIntegerv")
Rem
bbdoc: This function creates a context using a specified device.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>device</td><td>a pointer to a device</td></tr>
<tr><td>attrlist</td><td>a pointer to a set of attributes:<br>ALC_FREQUENCY<br>ALC_REFRESH<br>ALC_SYNC</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>ALC_INVALID_VALUE</td><td>An additional context can not be created for this device.</td></tr>
<tr><td>ALC_INVALID_DEVICE</td><td>The specified device is not a valid output device.</td></tr></table><br>
returns: A pointer to the new context (NULL on failure).
End Rem
Global alcCreateContext( device,attrlist:Int Ptr )=P("alcCreateContext")
Rem
bbdoc: This function makes a specified context the current context.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>context</td><td>a pointer to the new context</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>ALC_INVALID_CONTEXT</td><td>The specified context is invalid.</td></tr></table><br>
Returns ALC_TRUE on success, or ALC_FALSE on failure.
End Rem
Global alcMakeContextCurrent( context )=P("alcMakeContextCurrent")
Rem
bbdoc: This function tells a context to begin processing.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>context</td><td>a pointer to the new context</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>ALC_INVALID_CONTEXT</td><td>The specified context is invalid.</td></tr></table><br>
When a context is suspended, changes in OpenAL state will be accepted but will not be processed. #alcSuspendContext can be used to suspend a context, and then all the OpenAL state changes can be applied at once, followed by a call to alcProcessContext to apply all the state changes immediately. In some cases, this procedure may be more efficient than application of properties in a non-suspended state. In some implementations, process and suspend calls are each a NOP.
End Rem
Global alcProcessContext( context )=P("alcProcessContext")
Rem
bbdoc: This function suspends processing on a specified context.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>context</td><td>a pointer to the context to be suspended</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>ALC_INVALID_CONTEXT</td><td>The specified context is invalid.</td></tr></table><br>
When a context is suspended, changes in OpenAL state will be accepted but will not be processed. A typical use of alcSuspendContext would be to suspend a context, apply all the OpenAL state changes at once, and then call #alcProcessContext to apply all the state changes at once. In some cases, this procedure may be more efficient than application of properties in a non-suspended state. In some implementations, process and suspend calls are each a NOP.
End Rem
Global alcSuspendContext( context )=P("alcSuspendContext")
Rem
bbdoc: This function destroys a context.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>context</td><td>a pointer to the new context</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>ALC_INVALID_CONTEXT</td><td>The specified context is invalid.</td></tr></table><br>
A context which is not current can be destroyed at any time (all sources within that context will also be deleted - buffers are not affected). #alcMakeContextCurrent should be used to make sure the context to be destroyed is not current (NULL is valid for #alcMakeContextCurrent).
End Rem
Global alcDestroyContext( context )=P("alcDestroyContext")
Rem
bbdoc: This function retrieves the current context.
returns: a pointer to the current context.
End Rem
Global alcGetCurrentContext()=P("alcGetCurrentContext")
Rem
bbdoc: This function retrieves a context's device pointer.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>context</td><td>a pointer to a context</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>ALC_INVALID_CONTEXT</td><td>The specified context is invalid.</td></tr></table><br>
Returns: a pointer to the specified context's device.
End Rem
Global alcGetContextsDevice( context )=P("alcGetContextsDevice")
Rem
bbdoc: This function queries if a specified context extension is available.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>device</td><td>a pointer to the device to be queried for an extension</td></tr>
<tr><td>extName</td><td>a null-terminated string describing the extension</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>ALC_INVALID_VALUE</td><td>The string pointer is not valid.</td></tr></table><br>
Returns ALC_TRUE if the extension is available, ALC_FALSE if the extension is not available.
End Rem
Global alcIsExtensionPresent( device,extName$z )=P("alcIsExtensionPresent")
Rem
bbdoc: This function retrieves the address of a specified context extension function.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>device</td><td>a pointer to the device to be queried for the function</td></tr>
<tr><td>funcName</td><td>a null-terminated string describing the function</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>ALC_INVALID_VALUE</td><td>The string pointer is not valid.</td></tr></table><br>
Returns the address of the function, or NULL if it is not found.
End Rem
Global alcGetProcAddress:Byte Ptr( device,funcName$z )=P("alcGetProcAddress")
Rem
bbdoc: This function retrieves the enum value for a specified enumeration name.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>device</td><td>a pointer to the device to be queried</td></tr>
<tr><td>enumName</td><td>a null terminated string describing the enum value</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>ALC_INVALID_VALUE</td><td>The string pointer is not valid.</td></tr></table><br>
Returns the enum value described by the enumName string. This is most often used for querying an enum value for an ALC extension.
End Rem
Global alcGetEnumValue( device,enumName$z )=P("alcGetEnumValue")
Rem
bbdoc: This function opens a capture device by name.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>devicename</td><td>a pointer to a device name string</td></tr>
<tr><td>frequency</td><td>the frequency that the data should be captured at</td></tr>
<tr><td>format</td><td>the requested capture buffer format</td></tr>
<tr><td>buffersize</td><td>the size of the capture buffer</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>ALC_INVALID_VALUE</td><td>One of the parameters has an invalid value.</td></tr>
<tr><td>ALC_OUT_OF_MEMORY</td><td>The specified device is invalid, or can not capture audio.</td></tr></table><br>
Returns the capture device pointer, or NULL on failure.
End Rem
Global alcCaptureOpenDevice( devicename$z,frequency,format,buffersize )=P("alcCaptureOpenDevice")
Rem
bbdoc: This function closes the specified capture device.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>device</td><td>a pointer to a capture device</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>ALC_INVALID_DEVICE</td><td>The specified device is not a valid capture device.</td></tr></table><br>
Returns ALC_TRUE if the close operation was successful, ALC_FALSE on failure.
End Rem
Global alcCaptureCloseDevice( device )=P("alcCaptureCloseDevice")
Rem
bbdoc: This function begins a capture operation.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>device</td><td>a pointer to a capture device</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>ALC_INVALID_DEVICE</td><td>The specified device is not a valid capture device.</td></tr></table><br>
alcCaptureStart will begin recording to an internal ring buffer of the size specified when opening the capture device. The application can then retrieve the number of samples currently available using the ALC_CAPTURE_SAPMPLES token with #alcGetIntegerv. When the application determines that enough samples are available for processing, then it can obtain them with a call to #alcCaptureSamples.
End Rem
Global alcCaptureStart( device )=P("alcCaptureStart")
Rem
bbdoc: This function stops a capture operation.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>device</td><td>a pointer to a capture device</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>ALC_INVALID_DEVICE</td><td>The specified device is not a valid capture device.</td></tr></table><br>
End Rem
Global alcCaptureStop( device )=P("alcCaptureStop")
Rem
bbdoc: This function completes a capture operation.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>device</td><td>a pointer to a capture device</td></tr>
<tr><td>buffer</td><td>a pointer to a data buffer, which must be large enough to accommodate samples number of samples</td></tr>
<tr><td>samples</td><td>the number of samples to be retrieved</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>ALC_INVALID_VALUE</td><td>The specified number of samples is larger than the number of available samples.</td></tr>
<tr><td>ALC_INVALID_DEVICE</td><td>The specified device is not a valid capture device.</td></tr></table><br>
End Rem
Global alcCaptureSamples( device,buffer:Byte Ptr,samples )=P("alcCaptureSamples")

Const AL_NONE=0
Const AL_FALSE=0
Const AL_TRUE=1
Const AL_SOURCE_RELATIVE=$202
Const AL_CONE_INNER_ANGLE=$1001
Const AL_CONE_OUTER_ANGLE=$1002
Const AL_PITCH=$1003
Const AL_POSITION=$1004
Const AL_DIRECTION=$1005
Const AL_VELOCITY=$1006
Const AL_LOOPING=$1007
Const AL_BUFFER=$1009
Const AL_GAIN=$100a
Const AL_MIN_GAIN=$100d
Const AL_MAX_GAIN=$100e
Const AL_ORIENTATION=$100f
Const AL_SOURCE_STATE=$1010
Const AL_INITIAL=$1011
Const AL_PLAYING=$1012
Const AL_PAUSED=$1013
Const AL_STOPPED=$1014
Const AL_BUFFERS_QUEUED=$1015
Const AL_BUFFERS_PROCESSED=$1016
Const AL_SEC_OFFSET=$1024
Const AL_SAMPLE_OFFSET=$1025
Const AL_BYTE_OFFSET=$1026
Const AL_SOURCE_TYPE=$1027
Const AL_STATIC=$1028
Const AL_STREAMING=$1029
Const AL_UNDETERMINED=$1030
Const AL_FORMAT_MONO8=$1100
Const AL_FORMAT_MONO16=$1101
Const AL_FORMAT_STEREO8=$1102
Const AL_FORMAT_STEREO16=$1103
Const AL_REFERENCE_DISTANCE=$1020
Const AL_ROLLOFF_FACTOR=$1021
Const AL_CONE_OUTER_GAIN=$1022
Const AL_MAX_DISTANCE=$1023
Const AL_FREQUENCY=$2001
Const AL_BITS=$2002
Const AL_CHANNELS=$2003
Const AL_SIZE=$2004
Const AL_UNUSED=$2010
Const AL_PENDING=$2011
Const AL_PROCESSED=$2012
Const AL_NO_ERROR=AL_FALSE
Const AL_INVALID_NAME=$a001
Const AL_INVALID_ENUM=$a002
Const AL_INVALID_VALUE=$a003
Const AL_INVALID_OPERATION=$a004
Const AL_OUT_OF_MEMORY=$a005
Const AL_VENDOR=$b001
Const AL_VERSION=$b002
Const AL_RENDERER=$b003
Const AL_EXTENSIONS=$b004
Const AL_DOPPLER_FACTOR=$c000
Const AL_DOPPLER_VELOCITY=$c001
Const AL_SPEED_OF_SOUND=$c003
Const AL_DISTANCE_MODEL=$d000
Const AL_INVERSE_DISTANCE=$d001
Const AL_INVERSE_DISTANCE_CLAMPED=$d002
Const AL_LINEAR_DISTANCE=$d003
Const AL_LINEAR_DISTANCE_CLAMPED=$d004
Const AL_EXPONENT_DISTANCE=$d005
Const AL_EXPONENT_DISTANCE_CLAMPED=$d006

Rem
bbdoc: This function enables a feature of the OpenAL driver.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>capability</td><td>the name of a capability to enable</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified capability is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
There are no capabilities defined in OpenAL 1.1 to be used with this function, but it may be used by an extension.
End Rem
Global alEnable( capability )=P("alEnable")
Rem
bbdoc: This function disables a feature of the OpenAL driver.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>capability</td><td>the name of a capability to disable</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified capability is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
There are no capabilities defined in OpenAL 1.1 to be used with this function, but it may be used by an extension.
End Rem
Global alDisable( capability )=P("alDisable")
Rem
bbdoc: This function returns a boolean indicating if a specific feature is enabled in the OpenAL
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>capability</td><td>the name of a capability to disable</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified capability is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
Returns AL_TRUE if the capability is enabled, AL_FALSE if the capability is disabled. There are no capabilities defined in OpenAL 1.1 to be used with this function, but it may be used by an extension.
End Rem
Global alIsEnabled( capability )=P("alIsEnabled")
Rem
bbdoc: This function retrieves an OpenAL string property.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>param</td><td>The property to be returned:<br>AL_VENDOR<br>AL_VERSION<br>AL_RENDERER<br>AL_EXTENSIONS</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr></table><br>
Returns a pointer to a null-terminated string.
End Rem
Global alGetString:Byte Ptr( param )=P("alGetString")
Rem
bbdoc: This function retrieves a boolean OpenAL state.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>param</td><td>the state to be returned:<br>AL_DOPPLER_FACTOR<br>AL_SPEED_OF_SOUND<br>AL_DISTANCE_MODEL</td></tr>
<tr><td>data</td><td>a pointer to the location where the state will be stored</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_VALUE</td><td>The specified data pointer is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
End Rem
Global alGetBooleanv( param,data:Byte Ptr )=P("alGetBooleanv")
Rem
bbdoc: This function retrieves an integer OpenAL state.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>param</td><td>the state to be returned:<br>AL_DOPPLER_FACTOR<br>AL_SPEED_OF_SOUND<br>AL_DISTANCE_MODEL</td></tr>
<tr><td>data</td><td>a pointer to the location where the state will be stored</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_VALUE</td><td>The specified data pointer is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
End Rem
Global alGetIntegerv( param,data:Int Ptr )=P("alGetIntegerv")
Rem
bbdoc: This function retrieves a floating point OpenAL state.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>param</td><td>the state to be returned:<br>AL_DOPPLER_FACTOR<br>AL_SPEED_OF_SOUND<br>AL_DISTANCE_MODEL</td></tr>
<tr><td>data</td><td>a pointer to the location where the state will be stored</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_VALUE</td><td>The specified data pointer is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
End Rem
Global alGetFloatv( param,data:Float Ptr )=P("alGetFloatv")
Rem
bbdoc: This function retrieves a double precision floating point OpenAL state.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>param</td><td>the state to be returned:<br>AL_DOPPLER_FACTOR<br>AL_SPEED_OF_SOUND<br>AL_DISTANCE_MODEL</td></tr>
<tr><td>data</td><td>a pointer to the location where the state will be stored</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_VALUE</td><td>The specified data pointer is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
End Rem
Global alGetDoublev( param,data:Double Ptr )=P("alGetDoublev")
Rem
bbdoc: This function returns a boolean OpenAL state.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>param</td><td>the state to be queried:<br>AL_DOPPLER_FACTOR<br>AL_SPEED_OF_SOUND<br>AL_DISTANCE_MODEL</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
The boolean state described by param will be returned.
End Rem
Global alGetBoolean( param )=P("alGetBoolean")
Rem
bbdoc: This function returns an integer OpenAL state.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>param</td><td>the state to be queried:<br>AL_DOPPLER_FACTOR<br>AL_SPEED_OF_SOUND<br>AL_DISTANCE_MODEL</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
The integer state described by param will be returned.
End Rem
Global alGetInteger( param )=P("alGetInteger")
Rem
bbdoc: This function returns a floating point OpenAL state.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>param</td><td>the state to be queried:<br>AL_DOPPLER_FACTOR<br>AL_SPEED_OF_SOUND<br>AL_DISTANCE_MODEL</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
The floating point state described by param will be returned.
End Rem
Global alGetFloat#( param )=P("alGetFloat")
Rem
bbdoc: This function returns a double precision floating point OpenAL state.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>param</td><td>the state to be queried:<br>AL_DOPPLER_FACTOR<br>AL_SPEED_OF_SOUND<br>AL_DISTANCE_MODEL</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
The double value described by param will be returned.
End Rem
Global alGetDouble!( param )=P("alGetDouble")
Rem
bbdoc: This function returns the current error state and then clears the error state.
about: Returns an Alenum representing the error state. When an OpenAL error occurs, the error state is set and will not be changed until the error state is retrieved using alGetError. Whenever alGetError is called, the error state is cleared and the last state (the current state when the call was made) is returned. To isolate error detection to a specific portion of code, alGetError should be called before the isolated section to clear the current error state.
End Rem
Global alGetError()=P("alGetError")
Rem
bbdoc: This function tests if a specific extension is available for the OpenAL driver.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>extname</td><td>a null-terminated string describing the desired extension</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_VALUE</td><td>The specified extension string is not a valid pointer.</td></tr></table><br>
Returns AL_TRUE if the extension is available, AL_FALSE if the extension is not available.
End Rem
Global alIsExtensionPresent( extname$z )=P("alIsExtensionPresent")
Rem
bbdoc: This function returns the address of an OpenAL extension function.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>fname</td><td>a null-terminated string containing the function name</td></tr></table><br>
The return value is a pointer to the specified function. The return value will be NULL if the function is not found.
End Rem
Global alGetProcAddress:Byte Ptr( fname$z )=P("alGetProcAddress")
Rem
bbdoc: This function returns the enumeration value of an OpenAL enum described by a string.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>ename</td><td>a null-terminated string describing an OpenAL enum</td></tr></table><br>
Returns the actual ALenum described by a string. Returns NULL if the string doesnt describe a valid OpenAL enum.
EndRem
Global alGetEnumValue( ename$z )=P("alGetEnumValue")

Rem
bbdoc: This function sets a floating point property for the listener. The relevant properties are listed in the table Listener Properties.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>param</td><td>the name of the attribute to be set: AL_GAIN</td></tr>
<tr><td>value</td><td>the ALfloat value to set the attribute to</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_VALUE</td><td>The value given is not valid.</td></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
End Rem
Global alListenerf( param,value# )=P("alListenerf")
Rem
bbdoc: This function sets a floating point property for the listener. The relevant properties are listed in the table Listener Properties.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>param</td><td>the name of the attribute to set:<br>AL_POSITION<br>AL_VELOCITY</td></tr>
<tr><td>v1, v2, v3</td><td>the value to set the attribute to</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_VALUE</td><td>The value given is not valid.</td></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
End Rem
Global alListener3f( param,value1#,value2#,value3# )=P("alListener3f")
Rem
bbdoc: This function sets a floating point-vector property of the listener. The relevant properties are listed in the table Listener Properties.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>param</td><td>the name of the attribute to be set:<br>AL_POSITION<br>AL_VELOCITY<br>AL_ORIENTATION</td></tr>
<tr><td>values</td><td>pointer to floating point-vector values</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_VALUE</td><td>The value given is not valid.</td></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
End Rem
Global alListenerfv( param,values:Float Ptr )=P("alListenerfv")
Rem
bbdoc: This function sets an integer property of the listener.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>param</td><td>the name of the attribute to be set</td></tr>
<tr><td>value</td><td>the integer value to set the attribute to</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_VALUE</td><td>The value given is not valid.</td></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
There are no integer listener attributes defined for OpenAL 1.1, but this function may be used by an extension.
End Rem
Global alListeneri( param,value )=P("alListeneri")
Rem
bbdoc: This function sets an integer property of the listener. The relevant properties are listed in the table Listener Properties.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>param</td><td>the name of the attribute to be set:<br>AL_POSITION<br>AL_VELOCITY</td></tr>
<tr><td>value1, value2, value3</td><td>the integer values to set the attribute to</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_VALUE</td><td>The value given is not valid.</td></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
End Rem
Global alListener3i( param,value1,value2,value3 )=P("alListener3i")
Rem
bbdoc: This function sets an integer property of the listener. The relevant properties are listed in the table Listener Properties.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>param</td><td>the name of the attribute to be set:<br>AL_POSITION<br>AL_VELOCITY<br>AL_ORIENTATION</td></tr>
<tr><td>values</td><td>pointer to the integer values to set the attribute to</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_VALUE</td><td>The value given is not valid.</td></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
End Rem
Global alListeneriv( param,values:Int Ptr )=P("alListeneriv")
Rem
bbdoc: This function retrieves a floating point property of the listener. The relevant properties are listed in the table Listener Properties.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>param</td><td>the name of the attribute to be retrieved: AL_GAIN</td></tr>
<tr><td>value</td><td>a pointer to the floating point value being retrieved</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_VALUE</td><td>The value pointer given is not valid.</td></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
End Rem
Global alGetListenerf( param,value:Float Ptr )=P("alGetListenerf")
Rem
bbdoc: This function retrieves a set of three floating point values from a property of the listener. The relevant properties are listed in the table Listener Properties.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>param</td><td>the name of the attribute to be retrieved:<br>AL_POSITION<br>AL_VELOCITY</td></tr>
<tr><td>value1, value2, value3</td><td>pointers to the three floating point being retrieved</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_VALUE</td><td>The value pointer given is not valid.</td></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
End Rem
Global alGetListener3f( param,value1:Float Ptr,value2:Float Ptr,value3:Float Ptr )=P("alGetListener3f")
Rem
bbdoc: This function retrieves a floating point-vector property of the listener. The relevant properties are listed in the table Listener Properties.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>param</td><td>the name of the attribute to be retrieved:<br>AL_POSITION<br>AL_VELOCITY<br>AL_ORIENTATION</td></tr>
<tr><td>values</td><td>a pointer to the floating point-vector value being retrieved</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_VALUE</td><td>The value pointer given is not valid.</td></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
End Rem
Global alGetListenerfv( param,values:Float Ptr )=P("alGetListenerfv")
Rem
bbdoc: This function retrieves an integer property of the listener.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>param</td><td>the name of the attribute to be retrieved</td></tr>
<tr><td>value</td><td>a pointer to the integer value being retrieved</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_VALUE</td><td>The value pointer given is not valid.</td></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
There are no integer listener attributes defined for OpenAL 1.1, but this function may be used by an extension.
End Rem
Global alGetListeneri( param,value:Int Ptr )=P("alGetListeneri")
Rem
bbdoc: This function retrieves an integer property of the listener. The relevant properties are listed in the table Listener Properties.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>param</td><td>the name of the attribute to be retrieved:<br>AL_POSITION<br>AL_VELOCITY</td></tr>
<tr><td>value1, value2, value3</td><td>pointers to the integer values being retrieved</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_VALUE</td><td>The value pointer given is not valid.</td></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
End Rem
Global alGetListener3i( param,value1:Int Ptr,value2:Int Ptr,value3:Int Ptr )=P("alGetListener3i")

Rem
bbdoc: This function retrieves an integer property of the listener. The relevant properties are listed in the table Listener Properties.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>param</td><td>the name of the attribute to be retrieved:<br>AL_POSITION<br>AL_VELOCITY<br>AL_ORIENTATION</td></tr>
<tr><td>values</td><td>a pointer to the integer values being retrieved</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_VALUE</td><td>The value pointer given is not valid.</td></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
End Rem
Global alGetListeneriv( param,values:Int Ptr )=P("alGetListeneriv")

Rem
bbdoc: This Function generates one or more buffers, which contain audio data (see #alBufferData). References To buffers are ALuint values, which are used wherever a buffer reference is needed (in calls such as #alDeleteBuffers, #alSourcei, #alSourceQueueBuffers, and #alSourceUnqueueBuffers).
about: 
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>n</td><td>the number of buffers To be generated</td></tr>
<tr><td>buffers</td><td>pointer To an array of ALuint values which will store the names of the New buffers</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_VALUE</td><td>The buffer array isn't large enough to hold the number of buffers requested.</td></tr>
<tr><td>AL_OUT_OF_MEMORY</td><td>There is not enough memory available To generate all the buffers requested.</td></tr></table><br>
If the requested number of buffers cannot be created, an error will be generated which can be detected with #alGetError. If an error occurs, no buffers will be generated. If n equals zero, #alGenBuffers does nothing and does not Return an error.
End Rem
Global alGenBuffers( n,buffers:Int Ptr )=P("alGenBuffers")
Rem
bbdoc: This function deletes one or more buffers, freeing the resources used by the buffer. Buffers which are attached to a source can not be deleted. See #alSourcei and #alSourceUnqueueBuffers for information on how to detach a buffer from a source.
about: 
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>n</td><td>the number of buffers to be deleted</td></tr>
<tr><td>buffers</td><td>pointer to an array of buffer names identifying the buffers to be deleted</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_OPERATION</td><td>The buffer is still in use and can not be deleted.</td></tr>
<tr><td>AL_INVALID_NAME</td><td>A buffer name is invalid.</td></tr>
<tr><td>AL_INVALID_VALUE</td><td>The requested number of buffers can not be deleted.</td></tr></table><br>
If the requested number of buffers cannot be deleted, an error will be generated which can be detected with #alGetError. If an error occurs, no buffers will be deleted. If n equals zero, #alDeleteBuffers does nothing and will not return an error.
End Rem
Global alDeleteBuffers( n,buffers:Int Ptr )=P("alDeleteBuffers")
Rem
bbdoc: This function tests if a buffer name is valid, returning AL_TRUE if valid, AL_FALSE if not.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>bid</td><td>a buffer name to be tested for validity</td></tr></table><br>
The NULL buffer is always valid (see #alSourcei for information on how the NULL buffer is used).
End Rem
Global alIsBuffer( bid )=P("alIsBuffer")
Rem
bbdoc: This function fills a buffer with audio data. All the pre-defined formats are PCM data, but this function may be used by extensions to load other data types as well.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>bid</td><td>buffer name to be filled with data</td></tr>
<tr><td>format</td><td>format type from among the following: AL_FORMAT_MONO8, AL_FORMAT_MONO16, AL_FORMAT_STEREO8, AL_FORMAT_STEREO16</td></tr>
<tr><td>data</td><td>pointer to the audio data</td></tr>
<tr><td>size</td><td>the size of the audio data in bytes</td></tr>
<tr><td>freq</td><td>the frequency of the audio data</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_OUT_OF_MEMORY</td><td>There is not enough memory available to create this buffer.</td></tr>
<tr><td>AL_INVALID_VALUE</td><td>The size parameter is not valid for the format specified, the buffer is in use, or the data is a NULL pointer.</td></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified format does not exist.</td></tr></table><br>
8-bit PCM data is expressed as an unsigned value over the range 0 to 255, 128 being an audio output level of zero. 16-bit PCM data is expressed as a signed value over the range -32768 to 32767, 0 being an audio output level of zero. Stereo data is expressed in interleaved format, left channel first. Buffers containing more than one channel of data will be played without 3D spatialization.
End Rem
Global alBufferData( bid,format,data:Byte Ptr,size,freq )=P("alBufferData")
Rem
bbdoc: This Function sets a floating point property of a buffer.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>bid</td><td>buffer name whose attribute is being retrieved</td></tr>
<tr><td>param</td><td>the name of the attribute To be set</td></tr>
<tr><td>value</td><td>the ALfloat value To be set</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_NAME</td><td>The specified buffer doesn't have parameters (the NULL buffer), or doesn't exist.</td></tr></table><br>
There are no relevant buffer properties defined in OpenAL 1.1 which can be affected by this call, but this Function may be used by OpenAL extensions.
End Rem
Global alBufferf( bid,param,value# )=P("alBufferf")
Rem
bbdoc: This function sets a floating point property of a buffer.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>bid</td><td>buffer name whose attribute is being retrieved</td></tr>
<tr><td>param</td><td>the name of the attribute to be set</td></tr>
<tr><td>value1, value2, value3</td><td>the ALfloat values to be set</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_NAME</td><td>The specified buffer doesn't have parameters (the NULL buffer), or doesn't exist.</td></tr></table><br>
There are no relevant buffer properties defined in OpenAL 1.1 which can be affected by this call, but this function may be used by OpenAL extensions.
End Rem
Global alBuffer3f( bid,param,value1#,value2#,value3# )=P("alBuffer3f")
Rem
bbdoc: This function sets a floating point property of a buffer.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>bid</td><td>buffer name whose attribute is being retrieved</td></tr>
<tr><td>param</td><td>the name of the attribute to be set</td></tr>
<tr><td>values</td><td>a pointer to the ALfloat values to be set</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_NAME</td><td>The specified buffer doesn't have parameters (the NULL buffer), or doesn't exist.</td></tr></table><br>
There are no relevant buffer properties defined in OpenAL 1.1 which can be affected by this call, but this function may be used by OpenAL extensions.
End Rem
Global alBufferfv( bid,param,values:Float Ptr )=P("alBufferfv")
Rem
bbdoc: This Function sets a floating point property of a buffer.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>bid</td><td>buffer name whose attribute is being retrieved</td></tr>
<tr><td>param</td><td>the name of the attribute To be set</td></tr>
<tr><td>value</td><td>the ALint value To be set</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_NAME</td><td>The specified buffer doesn't have parameters (the NULL buffer), or doesn't exist.</td></tr></table><br>
There are no relevant buffer properties defined in OpenAL 1.1 which can be affected by this call, but this Function may be used by OpenAL extensions.
End Rem
Global alBufferi( bid,param,value )=P("alBufferi")
Rem
bbdoc: This Function sets a floating point property of a buffer.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>bid</td><td>buffer name whose attribute is being retrieved</td></tr>
<tr><td>param</td><td>the name of the attribute To be set</td></tr>
<tr><td>value1, value2, value3</td><td>the ALint values To be set</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_NAME</td><td>The specified buffer doesn't have parameters (the NULL buffer), or doesn't exist.</td></tr></table><br>
There are no relevant buffer properties defined in OpenAL 1.1 which can be affected by this call, but this Function may be used by OpenAL extensions.
End Rem
Global alBuffer3i( bid,param,value1,value2,value3 )=P("alBuffer3i")
Rem
bbdoc: This Function sets a floating point property of a buffer.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>bid</td><td>buffer name whose attribute is being retrieved</td></tr>
<tr><td>param</td><td>the name of the attribute To be set</td></tr>
<tr><td>values</td><td>a pointer To the ALint values To be set</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_NAME</td><td>The specified buffer doesn't have parameters (the NULL buffer), or doesn't exist.</td></tr></table><br>
There are no relevant buffer properties defined in OpenAL 1.1 which can be affected by this call, but this Function may be used by OpenAL extensions.
End Rem
Global alBufferiv( bid,param,values:Int Ptr )=P("alBufferiv")
Rem
bbdoc: This Function retrieves a floating point property of a buffer.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>bid</td><td>buffer name whose attribute is being retrieved</td></tr>
<tr><td>pname</td><td>the name of the attribute To be retrieved</td></tr>
<tr><td>value</td><td>a pointer to an ALfloat To hold the retrieved data</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_NAME</td><td>The specified buffer doesn't have parameters (the NULL buffer), or doesn't exist.</td></tr>
<tr><td>AL_INVALID_VALUE</td><td>The specified value pointer is not valid.</td></tr></table><br>
There are no relevant buffer properties defined in OpenAL 1.1 which can be retrieved by this call, but this Function may be used by OpenAL extensions.
End Rem
Global alGetBufferf( bid,param,value:Float Ptr )=P("alGetBufferf")
Rem
bbdoc: This Function retrieves a floating point property of a buffer.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>bid</td><td>buffer name whose attribute is being retrieved</td></tr>
<tr><td>pname</td><td>the name of the attribute To be retrieved</td></tr>
<tr><td>value1, value2, value3</td><td>pointers to a ALfloat values To hold the retrieved data</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_NAME</td><td>The specified buffer doesn't have parameters (the NULL buffer), or doesn't exist.</td></tr>
<tr><td>AL_INVALID_VALUE</td><td>The specified value pointer is not valid.</td></tr></table><br>
There are no relevant buffer properties defined in OpenAL 1.1 which can be retrieved by this call, but this Function may be used by OpenAL extensions.
End Rem
Global alGetBuffer3f( bid,param,value1:Float Ptr,value2:Float Ptr,value3:Float Ptr )=P("alGetBuffer3f")
Rem
bbdoc: This Function retrieves a floating point property of a buffer.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>bid</td><td>buffer name whose attribute is being retrieved</td></tr>
<tr><td>pname</td><td>the name of the attribute to be retrieved</td></tr>
<tr><td>values</td><td>pointer To an ALfloat vector To hold the retrieved data</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_NAME</td><td>The specified buffer doesn't have parameters (the NULL buffer), or doesn't exist.</td></tr>
<tr><td>AL_INVALID_VALUE</td><td>The specified value pointer is not valid.</td></tr></table><br>
There are no relevant buffer properties defined in OpenAL 1.1 which can be retrieved by this call, but this Function may be used by OpenAL extensions.
End Rem
Global alGetBufferfv( bid,param,values:Float Ptr )=P("alGetBufferfv")
Rem
bbdoc: This Function retrieves a floating point property of a buffer.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>bid</td><td>buffer name whose attribute is being retrieved</td></tr>
<tr><td>pname</td><td>the name of the attribute to be retrieved: AL_FREQUENCY, AL_BITS, AL_CHANNELS, AL_SIZE, AL_DATA</td></tr>
<tr><td>value</td><td>a pointer To an ALint To hold the retrieved data</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_NAME</td><td>The specified buffer doesn't have parameters (the NULL buffer), or doesn't exist.</td></tr>
<tr><td>AL_INVALID_VALUE</td><td>The specified value pointer is not valid.</td></tr></table><br>
There are no relevant buffer properties defined in OpenAL 1.1 which can be retrieved by this call, but this Function may be used by OpenAL extensions.
End Rem
Global alGetBufferi( bid,param,value:Int Ptr )=P("alGetBufferi")
Rem
bbdoc: This Function retrieves a floating point property of a buffer.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>bid</td><td>buffer name whose attribute is being retrieved</td></tr>
<tr><td>pname</td><td>the name of the attribute To be retrieved</td></tr>
<tr><td>value1, value2, value3</td><td>pointers To ALint values To hold the retrieved data</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_NAME</td><td>The specified buffer doesn't have parameters (the NULL buffer), or doesn't exist.</td></tr>
<tr><td>AL_INVALID_VALUE</td><td>The specified value pointer is not valid.</td></tr></table><br>
There are no relevant buffer properties defined in OpenAL 1.1 which can be retrieved by this call, but this Function may be used by OpenAL extensions.
End Rem
Global alGetBuffer3i( bid,param,value1:Int Ptr,value2:Int Ptr,value3:Int Ptr )=P("alGetBuffer3i")
Rem
bbdoc: This Function retrieves a floating point property of a buffer. The relevant properties are listed in the table Buffer Properties.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>bid</td><td>buffer name whose attribute is being retrieved</td></tr>
<tr><td>pname</td><td>the name of the attribute To be retrieved</td></tr>
<tr><td>values</td><td>pointer to an ALint vector To hold the retrieved data</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_NAME</td><td>The specified buffer doesn't have parameters (the NULL buffer), or doesn't exist.</td></tr>
<tr><td>AL_INVALID_VALUE</td><td>The specified value pointer is not valid.</td></tr></table><br>
There are no relevant buffer properties defined in OpenAL 1.1 which can be retrieved by this call, but this function may be used by OpenAL extensions.
End Rem
Global alGetBufferiv( bid,param,values:Int Ptr )=P("alGetBufferiv")

Rem
bbdoc: This Function generates one or more sources. References To sources are ALuint values, which are used wherever a source reference is needed (in calls such as #alDeleteSources and #alSourcei).
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>n</td><td>the number of sources To be generated</td></tr>
<tr><td>sources</td><td>pointer To an array of ALuint values which will store the names of the New sources</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_OUT_OF_MEMORY</td><td>There is not enough memory To generate all the requested sources.</td></tr>
<tr><td>AL_INVALID_VALUE</td><td>There are not enough non-memory resources To create all the requested sources, or the array pointer is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no context To create sources in.</td></tr></table><br>
If the requested number of sources cannot be created, an error will be generated which can be detected with #alGetError. If an error occurs, no sources will be generated. If n equals zero, #alGenSources does nothing and does not Return an error.
End Rem
Global alGenSources( n,sources:Int Ptr )=P("alGenSources")
Rem
bbdoc: This function deletes one or more sources.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>n</td><td>the number of sources to be deleted</td></tr>
<tr><td>sources</td><td>pointer to an array of source names identifying the sources to be deleted</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_NAME</td><td>at least one specified source is not valid, or an attempt is being made to delete more sources than exist.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
If the requested number of sources cannot be deleted, an error will be generated which can be detected with #alGetError. If an error occurs, no sources will be deleted. If n equals zero, #alDeleteSources does nothing and will not return an error.<p>
A playing source can be deleted - the source will be stopped and then deleted.
End Rem
Global alDeleteSources( n,sources:Int Ptr )=P("alDeleteSources")
Rem
bbdoc: This function tests if a source name is valid, returning AL_TRUE if valid and AL_FALSE if not.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>sid</td><td>a source name to be tested for validity</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr>
<tr><td></td><td></td></tr></table><br>
End Rem
Global alIsSource( sid )=P("alIsSource")
Rem
bbdoc: This function sets a floating point property of a source. The relevant properties are listed in the table Source Properties.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>sid</td><td>source name whose attribute is being set</td></tr>
<tr><td>param</td><td>the name of the attribute to set:<br>AL_PITCH<br>AL_GAIN<br>AL_MAX_DISTANCE<br>AL_ROLLOFF_FACTOR<br>AL_REFERENCE_DISTANCE<br>AL_MIN_GAIN<br>AL_MAX_GAIN<br>AL_CONE_OUTER_GAIN</td></tr>
<tr><td>value</td><td>the value to set the attribute t</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_VALUE</td><td>The value given is out of range.</td></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_NAME</td><td>The specified source name is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
End Rem
Global alSourcef( sid,param,value# )=P("alSourcef")
Rem
bbdoc: This function sets a source property requiring three floating point values. The relevant properties are listed in the table Source Properties.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>sid</td><td>source name whose attribute is being set</td></tr>
<tr><td>param</td><td>the name of the attribute to set:<br>AL_POSITION<br>AL_VELOCITY<br>AL_DIRECTION</td></tr>
<tr><td>v1, v2, v3</td><td>the three ALfloat values which the attribute will be set to</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_VALUE</td><td>The value given is out of range.</td></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_NAME</td><td>The specified source name is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
This function is an alternative to alSourcefv.
End Rem
Global alSource3f( sid,param,value1#,value2#,value3# )=P("alSource3f")
Rem
bbdoc: This function sets a source property requiring three floating point values. The relevant properties are listed in the table Source Properties.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>sid</td><td>source name whose attribute is being set</td></tr>
<tr><td>param</td><td>the name of the attribute to set:<br>AL_POSITION<br>AL_VELOCITY<br>AL_DIRECTION</td></tr>
<tr><td>values</td><td>a pointer to the vector to set the attribute to</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_VALUE</td><td>The value given is out of range.</td></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_NAME</td><td>The specified source name is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
This function is an alternative to alSource3f.
End Rem
Global alSourcefv( sid,param,values:Float Ptr )=P("alSourcefv")
Rem
bbdoc: This function sets an integer property of a source. The relevant properties are listed in the table Source Properties.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>sid</td><td>source name whose attribute is being set</td></tr>
<tr><td>param</td><td>the name of the attribute to set:<br>AL_SOURCE_RELATIVE<br>AL_CONE_INNER_ANGLE<br>AL_CONE_OUTER_ANGLE<br>AL_LOOPING<br>AL_BUFFER<br>AL_SOURCE_STATE</td></tr>
<tr><td>value</td><td>a pointer to the vector to set the attribute to</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_VALUE</td><td>The value given is out of range.</td></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_NAME</td><td>The specified source name is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
The buffer name zero is reserved as a "NULL Buffer" and is accepted by alSourcei(..., AL_BUFFER, ...) as a valid buffer of zero length. The NULL Buffer is extremely useful for detaching buffers from a source which were attached using this call or with alSourceQueueBuffers.
End Rem
Global alSourcei( sid,param,value )=P("alSourcei")
Rem
bbdoc: This function sets an integer property of a source. The relevant properties are listed in the table Source Properties.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>sid</td><td>source name whose attribute is being set</td></tr>
<tr><td>param</td><td>the name of the attribute to set:<br>AL_POSITION<br>AL_VELOCITY<br>AL_DIRECTION</td></tr>
<tr><td>value1, value2, value3</td><td>the values to set the attribute to</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_VALUE</td><td>The value given is out of range.</td></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_NAME</td><td>The specified source name is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
End Rem
Global alSource3i( sid,param,value1,value2,value3 )=P("alSource3i")
Rem
bbdoc: This function sets an integer property of a source. The relevant properties are listed in the table Source Properties.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>sid</td><td>source name whose attribute is being set</td></tr>
<tr><td>param</td><td>the name of the attribute to set:<br>AL_POSITION<br>AL_VELOCITY<br>AL_DIRECTION</td></tr>
<tr><td>values</td><td>the values to set the attribute to</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_VALUE</td><td>The value given is out of range.</td></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_NAME</td><td>The specified source name is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
End Rem
Global alSourceiv( sid,param,values:Int Ptr )=P("alSourceiv")
Rem
bbdoc: This function retrieves a floating point property of a source. The relevant properties are listed in the table Source Properties.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>sid</td><td>source name whose attribute is being retrieved</td></tr>
<tr><td>param</td><td>the name of the attribute to retrieve:<br>AL_PITCH<br>AL_GAIN<br>AL_MIN_GAIN<br>AL_MAX_GAIN<br>AL_MAX_DISTANCE<br>AL_ROLLOFF_FACTOR<br>AL_CONE_OUTER_GAIN<br>AL_CONE_INNER_ANGLE<br>AL_CONE_OUTER_ANGLE<br>AL_REFERENCE_DISTANCE</td></tr>
<tr><td>value</td><td>a pointer to the floating point value being retrieved</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_VALUE</td><td>The value given is out of range.</td></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_NAME</td><td>The specified source name is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
End Rem
Global alGetSourcef( sid,param,value:Float Ptr )=P("alGetSourcef")
Rem
bbdoc: This function retrieves three floating point values representing a property of a source. The relevant properties are listed in the table Source Properties.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>sid</td><td>source name whose attribute is being retrieved</td></tr>
<tr><td>param</td><td>the name of the attribute to retrieve:<br>AL_POSITION<br>AL_VELOCITY<br>AL_DIRECTION</td></tr>
<tr><td>value1,value2,value3</td><td>pointers to the values to retrieve</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_VALUE</td><td>The value given is out of range.</td></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_NAME</td><td>The specified source name is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
End Rem
Global alGetSource3f( sid,param,value1:Float Ptr,value2:Float Ptr,value3:Float Ptr )=P("alGetSource3f")
Rem
bbdoc: This function retrieves a floating point-vector property of a source. The relevant properties are listed in the table Source Properties.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>sid</td><td>source name whose attribute is being retrieved</td></tr>
<tr><td>param</td><td>the name of the attribute to retrieve:<br>AL_POSITION<br>AL_VELOCITY<br>AL_DIRECTION</td></tr>
<tr><td>values</td><td>a pointer to the vector to retrieve</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_VALUE</td><td>The value given is out of range.</td></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_NAME</td><td>The specified source name is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
End Rem
Global alGetSourcefv( sid,param,values:Float Ptr )=P("alGetSourcefv")
Rem
bbdoc: This function retrieves an integer property of a source. The relevant properties are listed in the table Source Properties.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>sid</td><td>source name whose attribute is being retrieved</td></tr>
<tr><td>pname</td><td>the name of the attribute to retrieve:<br>AL_SOURCE_RELATIVE<br>AL_BUFFER<br>AL_SOURCE_STATE<br>AL_BUFFERS_QUEUED<br>AL_BUFFERS_PROCESSED</td></tr>
<tr><td>value</td><td>a pointer to the integer value being retrieved</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_VALUE</td><td>The value given is out of range.</td></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_NAME</td><td>The specified source name is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
End Rem
Global alGetSourcei( sid,param,value:Int Ptr )=P("alGetSourcei")
Rem
bbdoc: This function retrieves an integer property of a source. The relevant properties are listed in the table Source Properties.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>sid</td><td>source name whose attribute is being retrieved</td></tr>
<tr><td>pname</td><td>the name of the attribute to retrieve:<br>AL_POSITION<br>AL_VELOCITY<br>AL_DIRECTION</td></tr>
<tr><td>value1, value2, value3</td><td>pointers to the integer values being retrieved</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_VALUE</td><td>The value given is out of range.</td></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_NAME</td><td>The specified source name is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
End Rem
Global alGetSource3i( sid,param,value1:Int Ptr,value2:Int Ptr,value3:Int Ptr )=P("alGetSource3i")
Rem
bbdoc: This function retrieves an integer property of a source. The relevant properties are listed in the table Source Properties.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>sid</td><td>source name whose attribute is being retrieved</td></tr>
<tr><td>pname</td><td>the name of the attribute to retrieve:<br>AL_POSITION<br>AL_VELOCITY<br>AL_DIRECTION</td></tr>
<tr><td>values</td><td>pointers to the integer values being retrieved</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_VALUE</td><td>The value given is out of range.</td></tr>
<tr><td>AL_INVALID_ENUM</td><td>The specified parameter is not valid.</td></tr>
<tr><td>AL_INVALID_NAME</td><td>The specified source name is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
End Rem
Global alGetSourceiv( sid,param,values:Int Ptr )=P("alGetSourceiv")

Rem
bbdoc: This function plays a set of sources.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>ns</td><td>the number of sources to be played</td></tr>
<tr><td>sids</td><td>a pointer to an array of sources to be played</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_VALUE</td><td>The value pointer given is not valid.</td></tr>
<tr><td>AL_INVALID_NAME</td><td>The specified source name is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
The playing sources will have their state changed to AL_PLAYING. When called on a source which is already playing, the source will restart at the beginning. When the attached buffer(s) are done playing, the source will progress to the AL_STOPPED state.
End Rem
Global alSourcePlayv( ns,sids:Int Ptr )=P("alSourcePlayv")
Rem
bbdoc: This function stops a set of sources.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>ns</td><td>the number of sources to stop</td></tr>
<tr><td>sids</td><td>a pointer to an array of sources to be stopped</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_VALUE</td><td>The value pointer given is not valid.</td></tr>
<tr><td>AL_INVALID_NAME</td><td>The specified source name is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
The stopped sources will have their state changed to AL_STOPPED.
End Rem
Global alSourceStopv( ns,sids:Int Ptr )=P("alSourceStopv")
Rem
bbdoc: This function stops a set of sources and sets all their states to AL_INITIAL.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>ns</td><td>the number of sources to be rewound</td></tr>
<tr><td>sids</td><td>a pointer to an array of sources to be rewound</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_VALUE</td><td>The value pointer given is not valid.</td></tr>
<tr><td>AL_INVALID_NAME</td><td>The specified source name is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
End Rem
Global alSourceRewindv( ns,sids:Int Ptr )=P("alSourceRewindv")
Rem
bbdoc: This function pauses a set of sources.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>ns</td><td>the number of sources to be paused</td></tr>
<tr><td>sids</td><td>a pointer to an array of sources to be paused</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_VALUE</td><td>The value pointer given is not valid.</td></tr>
<tr><td>AL_INVALID_NAME</td><td>The specified source name is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
The paused sources will have their state changed to AL_PAUSED.
End Rem
Global alSourcePausev( ns,sids:Int Ptr )=P("alSourcePausev")
Rem
bbdoc: This function plays a source.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>sid</td><td>the name of the source to be played</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_NAME</td><td>The specified source name is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
The playing source will have its state changed to AL_PLAYING. When called on a source which is already playing, the source will restart at the beginning. When the attached buffer(s) are done playing, the source will progress to the AL_STOPPED state.
End Rem
Global alSourcePlay( sid )=P("alSourcePlay")
Rem
bbdoc: This function stops a source.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>sid</td><td>the name of the source to be stopped</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_NAME</td><td>The specified source name is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
The stopped source will have its state changed to AL_STOPPED.
End Rem
Global alSourceStop( sid )=P("alSourceStop")
Rem
bbdoc: This function stops the source and sets its state to AL_INITIAL.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>sid</td><td>the name of the source to be rewound</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_NAME</td><td>The specified source name is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
End Rem
Global alSourceRewind( sid )=P("alSourceRewind")
Rem
bbdoc: This function pauses a source.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>sid</td><td>the name of the source to be paused</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_NAME</td><td>The specified source name is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
The paused source will have its state changed to AL_PAUSED.
End Rem
Global alSourcePause( sid )=P("alSourcePause")
Rem
bbdoc: This function queues a set of buffers on a source. All buffers attached to a source will be played in sequence, and the number of processed buffers can be detected using an #alSourcei call to retrieve AL_BUFFERS_PROCESSED.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>sid</td><td>the name of the source to queue buffers onto</td></tr>
<tr><td>numEntries</td><td>the number of buffers to be queued</td></tr>
<tr><td>bids</td><td>a pointer to an array of buffer names to be queued</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_NAME</td><td>at least one specified buffer name is not valid, or the specified source name is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context, an attempt was made to add a new buffer which is not the same format as the buffers already in the queue, or the source already has a static buffer attached.</td></tr></table><br>
When first created, a source will be of type AL_UNDETERMINED. A successful #alSourceQueueBuffers call will change the source type to AL_STREAMING.
End Rem
Global alSourceQueueBuffers( sid,numEntries,bids:Int Ptr )=P("alSourceQueueBuffers")
Rem
bbdoc: This function unqueues a set of buffers attached to a source. The number of processed buffers can be detected using an #alSourcei call to retrieve AL_BUFFERS_PROCESSED, which is the maximum number of buffers that can be unqueued using this call.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>sid</td><td>the name of the source to unqueue buffers from</td></tr>
<tr><td>numEntries</td><td>the number of buffers to be unqueued</td></tr>
<tr><td>bids</td><td>a pointer to an array of buffer names that were removed</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_VALUE</td><td>at least one buffer can not be unqueued because it has not been processed yet.</td></tr>
<tr><td>AL_INVALID_NAME</td><td>The specified source name is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
The unqueue operation will only take place if all n buffers can be removed from the queue.
End Rem
Global alSourceUnqueueBuffers( sid,numEntries,bids:Int Ptr )=P("alSourceUnqueueBuffers")

Rem
bbdoc: This function selects the OpenAL Doppler factor value.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>value</td><td>the Doppler scale value to set</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_VALUE</td><td>The specified value is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
The default Doppler factor value is 1.0.
End Rem
Global alDopplerFactor( value# )=P("alDopplerFactor")
Rem
bbdoc: This function selects the speed of sound for use in Doppler calculations.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>value</td><td>the speed of sound value to set</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_VALUE</td><td>The specified value is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
The default speed of sound value is 343.3.
End Rem
Global alDopplerVelocity( value# )=P("alDopplerVelocity")
Rem
bbdoc: This function selects the speed of sound for use in Doppler calculations.
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>value#</td><td>the speed of sound value to set</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_VALUE</td><td>The specified value is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
The default speed of sound value is 343.3.
End Rem
Global alSpeedOfSound( value# )=P("alSpeedOfSound")
Rem
bbdoc:This function selects the OpenAL distance model.<br><br>The AL_INVERSE_DISTANCE model works according to the following formula:<br><br>G_dB = AL_GAIN - 20log10(1 + AL_ROLLOFF_FACTOR*(distance - AL_REFERENCE_DISTANCE)/AL_REFERENCE_DISTANCE));<br>G_dB = min(G_dB, AL_MAX_GAIN);<br>G_dB = max(G_dB, AL_MIN_GAIN);<br><br>The AL_INVERSE_DISTANCE_CLAMPED model works according to the following formula:<br><br>distance = max(distance, AL_REFERENCE_DISTANCE);<br>distance = min(distance, AL_MAX_DISTANCE);<br>G_dB = AL_GAIN - 20log10(1 + AL_ROLLOFF_FACTOR*(distance - AL_REFERENCE_DISTANCE)/AL_REFERENCE_DISTANCE));<br>G_dB = min(G_dB, AL_MAX_GAIN);<br>G_dB = max(G_dB, AL_MIN_GAIN);<br><br>The AL_NONE model works according to the following formula:<br><br>G_db = AL_GAIN;<br>	
about:
<table><tr><th>Parameters</th><th>Description</th></tr>
<tr><td>distanceModel</td><td>the distance model to be set:<br>AL_NONE<br>AL_INVERSE_DISTANCE<br>AL_INVERSE_DISTANCE_CLAMPED</td></tr></table><br>
<table><tr><th>Possible Error States</th><th>Description</th></tr>
<tr><td>AL_INVALID_VALUE</td><td>The specified distance model is not valid.</td></tr>
<tr><td>AL_INVALID_OPERATION</td><td>There is no current context.</td></tr></table><br>
The default distance model in OpenAL is AL_INVERSE_DISTANCE_CLAMPED.
End Rem
Global alDistanceModel( distanceModel )=P("alDistanceModel")
