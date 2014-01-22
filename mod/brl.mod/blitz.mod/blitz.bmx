
Strict

NoDebug

Rem
bbdoc: BASIC/BlitzMax runtime
End Rem
Module BRL.Blitz

ModuleInfo "Version: 1.17"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.17 Release"
ModuleInfo "History: Added kludges for Lion llvm"
ModuleInfo "History: Removed Nan/Inf"
ModuleInfo "History: 1.16 Release"
ModuleInfo "History: String.Find now converts start index <0 to 0"
ModuleInfo "History: 1.15 Release"
ModuleInfo "History: Changed ReadStdin so it can handle any length input"
ModuleInfo "History: 1.14 Release"
ModuleInfo "History: Fixed leak in WriteStdout and WriteStderr"
ModuleInfo "History: 1.13 Release"
ModuleInfo "History: Added LibStartUp stub"
ModuleInfo "History: 1.12 Release"
ModuleInfo "History: Added GCSuspend and GCResume"
ModuleInfo "History: 1.11 Release"
ModuleInfo "History: Added experimental dll support"
ModuleInfo "History: 1.10 Release"
ModuleInfo "History: Added Nan and Inf keyword docs"
ModuleInfo "History: 1.09 Release"
ModuleInfo "History: BCC extern CString fix"
ModuleInfo "History: 1.08 Release"
ModuleInfo "History: Removed printf from 'Throw'"
ModuleInfo "History: 1.07 Release"
ModuleInfo "History: Added AppTitle$ global var"
ModuleInfo "History: 1.06 Release"
ModuleInfo "History: Restored ReadData"
ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Lotsa little tidyups"
ModuleInfo "History: 1.04 Release"
ModuleInfo "History: Fixed C Compiler warnings"

Import "blitz_app.c"
Import "blitz_types.c"
Import "blitz_cclib.c"
Import "blitz_memory.c"
Import "blitz_module.c"
Import "blitz_object.c"
Import "blitz_string.c"
Import "blitz_array.c"
Import "blitz_handle.c"
Import "blitz_debug.c"
Import "blitz_incbin.c"
Import "blitz_thread.c"
Import "blitz_ex.c"
Import "blitz_gc.c"

?Threaded
Import "blitz_gc_ms.c"
?Not Threaded
Import "blitz_gc_rc.c"
?

?Win32X86
Import "blitz_ex.win32.x86.s"
Import "blitz_gc.win32.x86.s"
Import "blitz_ftoi.win32.x86.s"
?LinuxX86
Import "blitz_ex.linux.x86.s"
Import "blitz_gc.linux.x86.s"
Import "blitz_ftoi.linux.x86.s"
?MacosX86
Import "blitz_ex.macos.x86.s"
Import "blitz_gc.macos.x86.s"
Import "blitz_ftoi.macos.x86.s"
?MacosPPC
Import "blitz_ex.macos.ppc.s"
Import "blitz_gc.macos.ppc.s"
?

Extern
Global OnDebugStop()="bbOnDebugStop"
Global OnDebugLog( message$ )="bbOnDebugLog"
End Extern

Type TBlitzException
End Type

Type TNullObjectException Extends TBlitzException
	Method ToString$()
		Return "Attempt to access field or method of Null object"
	End Method
End Type

Type TNullMethodException Extends TBlitzException
	Method ToString$()
		Return "Attempt to call abstract method"
	End Method
End Type

Type TNullFunctionException Extends TBlitzException
	Method ToString$()
		Return "Attempt to call uninitialized function pointer"
	End Method
End Type

Type TArrayBoundsException Extends TBlitzException
	Method ToString$()
		Return "Attempt to index array element beyond array length"
	End Method
End Type

Type TOutOfDataException Extends TBlitzException
	Method ToString$()
		Return "Attempt to read beyond end of data"
	End Method
End Type

Type TRuntimeException Extends TBlitzException
	Field error$
	Method ToString$()
		Return error
	End Method
	Function Create:TRuntimeException( error$ )
		Local t:TRuntimeException=New TRuntimeException
		t.error=error
		Return t
	End Function
End Type

Function NullObjectError()
	Throw New TNullObjectException
End Function

Function NullMethodError()
	Throw New TNullMethodException
End Function

Function NullFunctionError()
	Throw New TNullFunctionException
End Function

Function ArrayBoundsError()
	Throw New TArrayBoundsException
End Function

Function OutOfDataError()
	Throw New TOutOfDataException
End Function

Rem
bbdoc: Generate a runtime error
about: Throws a TRuntimeException.
End Rem
Function RuntimeError( message$ )
	Throw TRuntimeException.Create( message )
End Function

Rem
bbdoc: Stop program execution and enter debugger
about: If there is no debugger present, this command is ignored.
end rem
Function DebugStop()
	OnDebugStop
End Function

Rem
bbdoc: Write a string to debug log
about: If there is no debugger present, this command is ignored.
end rem
Function DebugLog( message$ )
	OnDebugLog message
End Function

Extern

Rem
bbdoc: Application directory
about: The #AppDir global variable contains the fully qualified directory of the currently
executing application. An application's initial current directory is also set to #AppDir
when an application starts.
End Rem
Global AppDir$="bbAppDir"

Rem
bbdoc: Application file name
about: The #AppFile global variable contains the fully qualified file name of the currently
executing application.
End Rem
Global AppFile$="bbAppFile"

Rem
bbdoc: Application title
about: The #AppTitle global variable is used by various commands when a
default application title is required - for example, when opening simple 
windows or requesters.<br>
<br>
Initially, #AppTitle is set the value "BlitzMax Application". However, you may change
#AppTitle at any time with a simple assignment.
End Rem
Global AppTitle$="bbAppTitle"

Rem
bbdoc: Arguments passed to the application at startup
about: The #AppArgs global array contains the command line parameters sent to an application
when it was started. The first element of #AppArgs always contains the name of the 
application. However, the format of the name may change depending on how the application
was launched. Use #AppDir or #AppFile for consistent information about the applications name
or directory.
End Rem
Global AppArgs$[]="bbAppArgs"

Rem
bbdoc: Directory from which application was launched
about: The #LaunchDir global variable contains the current directory at the time the
application was launched. This is mostly of use to command line tools which may need to
access the 'shell' current directory as opposed to the application directory.
End Rem
Global LaunchDir$="bbLaunchDir"

Rem
bbdoc: Add a function to be called when the program ends
about: #OnEnd allows you to specify a function to be called when the program ends. OnEnd functions are called
in the reverse order to that in which they were added.
end rem
Function OnEnd( fun() )="bbOnEnd"

Rem
bbdoc: Read a string from stdin
returns: A string read from stdin. The newline terminator, if any, is included in the returned string.
end rem
Function ReadStdin$()="bbReadStdin"

Rem
bbdoc: Write a string to stdout
about: Writes @str to stdout and flushes stdout.
end rem
Function WriteStdout( str$ )="bbWriteStdout"

Rem
bbdoc: Write a string to stderr
about: Writes @str to stderr and flushes stderr.
end rem
Function WriteStderr( str$ )="bbWriteStderr"

Rem
bbdoc: Wait for a given number of milliseconds
about:
#Delay suspends program execution for at least @millis milliseconds.<br>
<br>
A millisecond is one thousandth of a second.
End Rem
Function Delay( millis )="bbDelay"

Rem
bbdoc: Get millisecond counter
returns: Milliseconds since computer turned on.
about:
#MilliSecs returns the number of milliseconds elapsed since the computer
was turned on.<br>
<br>
A millisecond is one thousandth of a second.
End Rem
Function MilliSecs()="bbMilliSecs"

Rem
bbdoc: Allocate memory
returns: A new block of memory @size bytes long
End Rem
Function MemAlloc:Byte Ptr( size )="bbMemAlloc"

Rem
bbdoc: Free allocated memory
about: The memory specified by @mem must have been previously allocated by #MemAlloc or #MemExtend.
End Rem
Function MemFree( mem:Byte Ptr )="bbMemFree"

Rem
bbdoc: Extend a block of memory
returns: A new block of memory @new_size bytes long
about: An existing block of memory specified by @mem and @size is copied into a new block
of memory @new_size bytes long. The existing block is released and the new block is returned. 
end rem
Function MemExtend:Byte Ptr( mem:Byte Ptr,size,new_size )="bbMemExtend"

Rem
bbdoc: Clear a block of memory to 0
end rem
Function MemClear( mem:Byte Ptr,size )="bbMemClear"

Rem
bbdoc: Copy a non-overlapping block of memory
end rem
Function MemCopy( dst:Byte Ptr,src:Byte Ptr,size )="bbMemCopy"

Rem
bbdoc: Copy a potentially overlapping block of memory
end rem
Function MemMove( dst:Byte Ptr,src:Byte Ptr,size )="bbMemMove"

Rem
bbdoc: Set garbage collector mode
about:
@mode can be one of the following:<br>
1 : automatic GC - memory will be automatically garbage collected<br>
2 : manual GC - no memory will be collected until a call to GCCollect is made<br>
<br>
The default GC mode is automatic GC.
End Rem
Function GCSetMode( mode )="bbGCSetMode"

Rem
bbdoc: Suspend garbage collector
about:
#GCSuspend temporarily suspends the garbage collector. No garbage
collection will be performed following a call to #GCSuspend.<br>
<br>
Use #GCResume to resume the garbage collector. Note that #GCSuspend
and #GCResume 'nest', meaning that each call to #GCSuspend must be 
matched by a call to #GCResume.
End Rem
Function GCSuspend()="bbGCSuspend"

Rem
bbdoc: Resume garbage collector
about:
#GCResume resumes garbage collection following a call to #GCSuspend.<br>
<br>
See #GCSuspend for more details.
End Rem
Function GCResume()="bbGCResume"

Rem
bbdoc: Run garbage collector
returns: The amount of memory, in bytes, collected.
about:
This function will have no effect if the garbage collector has been
suspended due to #GCSuspend.
End Rem
Function GCCollect()="bbGCCollect"

Rem
bbdoc: Memory allocated by application
returns: The amount of memory, in bytes, currently allocated by the application
about:
This function only returns 'managed memory'. This includes all objects, strings and
arrays in use by the application.
End Rem
Function GCMemAlloced()="bbGCMemAlloced"

Rem
bbdoc: Private: do not use
End Rem
Function GCEnter()="bbGCEnter"

Rem
bbdoc: Private: do not use
End Rem
Function GCLeave()="bbGCLeave"

Rem
bbdoc: Convert object to integer handle
returns: An integer object handle
about:
After converting an object to an integer handle, you must later
release it using the #Release command.
End Rem
Function HandleFromObject( obj:Object )="bbHandleFromObject"

Rem
bbdoc: Convert integer handle to object
returns: The object associated with the integer handle
End Rem
Function HandleToObject:Object( handle )="bbHandleToObject"

End Extern

'BlitzMax keyword definitions

Rem
bbdoc: Set strict mode
about:
See the <a href=../../../../doc/bmxlang/compatibility.html>BlitzMax Language Reference</a> for more information on Strict mode programming.
keyword: "Strict"
End Rem

Rem
bbdoc: Set SuperStrict mode
keyword: "SuperStrict"
End Rem

Rem
bbdoc: End program execution
keyword: "End"
End Rem

Rem
bbdoc: Begin a remark block
keyword: "Rem"
End Rem

Rem
bbdoc: End a remark block
keyword: "EndRem"
End Rem

Rem
bbdoc: Constant integer of value 1
keyword: "True"
End Rem

Rem
bbdoc: Constant integer of value 0
keyword: "False"
End Rem

Rem
bbdoc: Constant Pi value: 3.1415926535897932384626433832795
keyword: "Pi"
End Rem

Rem
bbdoc: Get Default Null value
keyword: "Null"
End Rem

Rem
bbdoc: Unsigned 8 bit integer Type
keyword: "Byte"
End Rem

Rem
bbdoc: Unsigned 16 bit integer Type
keyword: "Short"
End Rem

Rem
bbdoc: Signed 32 bit integer Type
keyword: "Int"
End Rem

Rem
bbdoc: Signed 64 bit integer Type
keyword: "Long"
End Rem

Rem
bbdoc: 32 bit Floating point Type
keyword: "Float"
End Rem

Rem
bbdoc: 64 bit floating point Type
keyword: "Double"
End Rem

Rem
bbdoc: String Type
keyword: "String"
End Rem

Rem
bbdoc: Object Type
keyword: "Object"
End Rem

Rem
bbdoc: Composite Type specifier for 'by reference' types
keyword: "Var"
End Rem

Rem
bbdoc: Composite Type specifier for pointer types
keyword: "Ptr"
End Rem

Rem
bbdoc: Begin a conditional block.
keyword: "If"
End Rem

Rem
bbdoc: Optional separator between the condition and associated code in an If statement.
keyword: "Then"
End Rem

Rem
bbdoc: Else provides the ability For an If Then construct to execute a second block of code when the If condition is False.
keyword: "Else"
End Rem

Rem
bbdoc: ElseIf provides the ability to test and execute a section of code if the initial condition failed.
keyword: "ElseIf"
End Rem

Rem
bbdoc: Marks the End of an If Then block.
keyword: "EndIf"
End Rem

Rem
bbdoc: Marks the start of a loop that uses an iterator to execute a section of code repeatedly.
keyword: "For"
End Rem

Rem
bbdoc: Followed by a constant which is used to calculate when to exit a For..Next loop.
keyword: "To"
End Rem

Rem
bbdoc: Specifies an optional constant that is used to increment the For iterator.
keyword: "Step"
End Rem

Rem
bbdoc: End a For block
keyword: "Next"
End Rem

Rem
bbdoc: Iterate through an array or collection
keyword: "EachIn"
End Rem

Rem
bbdoc: Execute a block of code While a condition is True
keyword: "While"
End Rem

Rem
bbdoc: End a While block
keyword: "Wend"
End Rem

Rem
bbdoc: End a While block
keyword: "EndWhile"
End Rem

Rem
bbdoc: Execute a block of code Until a termination condition is met, or Forever
keyword: "Repeat"
End Rem

Rem
bbdoc: Conditionally continue a Repeat block
keyword: "Until"
End Rem

Rem
bbdoc: Continue a Repeat block Forever
keyword: "Forever"
End Rem

Rem
bbdoc: Begin a Select block
keyword: "Select"
End Rem

Rem
bbdoc: End a Select block
keyword: "EndSelect"
End Rem

Rem
bbdoc: Conditional code inside a Select block
keyword: "Case"
End Rem

Rem
bbdoc: Default code inside a Select block
keyword: "Default"
End Rem

Rem
bbdoc: Exit enclosing loop
keyword: "Exit"
End Rem

Rem
bbdoc: Continue execution of enclosing loop
keyword: "Continue"
End Rem

Rem
bbdoc: Declare a constant
keyword: "Const"
End Rem

Rem
bbdoc: Declare a Local variable
keyword: "Local"
End Rem

Rem
bbdoc: Declare a Global variable
keyword: "Global"
End Rem

Rem
bbdoc: Declare a Field variable
keyword: "Field"
End Rem

Rem
bbdoc: Begin a Function declaration
keyword: "Function"
End Rem

Rem
bbdoc: End a Function declaration
keyword: "EndFunction"
End Rem

Rem
bbdoc: Return from a Function
keyword: "Return"
End Rem

Rem
bbdoc: Begin a user defined Type declaration
keyword: "Type"
End Rem

Rem
bbdoc: End a user defined Type declaration
keyword: "EndType"
End Rem

Rem
bbdoc: Specify user defined Type supertype
keyword: "Extends"
End Rem

Rem
bbdoc: Begin a Method declaration
keyword: "Method"
End Rem

Rem
bbdoc: End a Method declaration
keyword: "EndMethod"
End Rem

Rem
bbdoc: Denote a Type or Method as Abstract
keyword: "Abstract"
End Rem

Rem
bbdoc: Denote a Type or Method as Final
keyword: "Final"
End Rem

Rem
bbdoc: Create an instance of a user defined Type
keyword: "New"
End Rem

Rem
bbdoc: Reference to this Method's Object instance
keyword: "Self"
End Rem

Rem
bbdoc: Reference to the Super Type Object instance
keyword: "Super"
End Rem

Rem
bbdoc: Reserved for future expansion
keyword: "Delete"
End Rem

Rem
bbdoc: Release an integer Object handle
keyword: "Release"
End Rem

Rem
bbdoc: Public makes a Constant, Global variable or Function accessible from outside the current source file (Default)
keyword: "Public"
End Rem

Rem
bbdoc: Private makes a Constant, Global variable or Function only accessible from within the current source file
keyword: "Private"
End Rem

Rem
bbdoc: Extern marks the beginning of an external list of Function declarations
keyword: "Extern"
End Rem

Rem
bbdoc: EndExtern marks the End of an Extern section
keyword: "EndExtern"
End Rem

Rem
bbdoc: Declare Module scope and identifier
about:
See the <a href=../../../../doc/bmxlang/modules.html>BlitzMax Language Reference</a> for more information on BlitzMax Modules.
keyword: "Module"
End Rem

Rem
bbdoc: Define Module properties
keyword: "ModuleInfo"
End Rem

Rem
bbdoc: Embed a data file
keyword: "Incbin"
End Rem

Rem
bbdoc: Get start address of embedded data file
keyword: "IncbinPtr"
End Rem

Rem
bbdoc: Get length of embedded data file
keyword: "IncbinLen"
End Rem

Rem
bbdoc: Include effectively 'inserts' the specified file into the file being compiled.
keyword: "Include"
End Rem

Rem
bbdoc: Framework builds the BlitzMax application with only the Module specified rather than all modules installed.
keyword: "Framework"
End Rem

Rem
bbdoc: Import declarations from a Module or source file
keyword: "Import"
End Rem

Rem
bbdoc: Throw a RuntimeError if a condition is False
keyword: "Assert"
End Rem

Rem
bbdoc: Transfer program flow to specified label
keyword: "Goto"
End Rem

Rem
bbdoc: Begin declaration of a Try block
keyword: "Try"
End Rem

Rem
bbdoc: End declaration of a Try block
keyword: "EndTry"
End Rem

Rem
bbdoc: Catch an exception Object in a Try block
keyword: "Catch"
End Rem

Rem
bbdoc: Throw an exception Object to the enclosing Try block
keyword: "Throw"
End Rem

Rem
bbdoc: Define class BASIC style data
keyword: "DefData"
End Rem

Rem
bbdoc: Read classic BASIC style data
keyword: "ReadData"
End Rem

Rem
bbdoc: Restore classic BASIC style data
keyword: "RestoreData"
End Rem

Rem
bbdoc: Conditional 'And' binary operator
keyword: "And"
End Rem

Rem
bbdoc: Conditional 'Or' binary operator
keyword: "Or"
End Rem

Rem
bbdoc: Conditional 'Not' binary operator
keyword: "Not"
End Rem

Rem
bbdoc: Bitwise 'Shift left' binary operator
keyword: "Shl"
End Rem

Rem
bbdoc: Bitwise 'Shift right' binary operator
keyword: "Shr"
End Rem

Rem
bbdoc: Bitwise 'Shift arithmetic right' binary operator
keyword: "Sar"
End Rem

Rem
bbdoc: Number of characters in a String or elements in an array
keyword: "Len"
End Rem

Rem
bbdoc: Numeric 'absolute value' unary operator
keyword: "Abs"
End Rem

Rem
bbdoc: Numeric 'modulus' or 'remainder' binary operator
keyword: "Mod"
End Rem

Rem
bbdoc: Numeric 'sign' unary operator
keyword: "Sgn"
End Rem

Rem
bbdoc: Numeric 'minimum' builtin function
returns: The lesser of the two numeric arguments
keyword: "Min"
End Rem

Rem
bbdoc: Numeric 'maximum' builtin function
returns: The larger of the two numeric arguments
keyword: "Max"
End Rem

Rem
bbdoc: Find the address of a variable
keyword: "Varptr"
End Rem

Rem
bbdoc: Size, in bytes, occupied by a variable, string, array or object
keyword: "SizeOf"
End Rem

Rem
bbdoc: Get character value of the first character of a string
keyword: "Asc"
End Rem

Rem
bbdoc: Create a string of length 1 with a character code
keyword: "Chr"
End Rem

