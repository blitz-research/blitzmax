



' -----------------------------------------------------------------------------
' MAKE SURE "Threaded Build" IS CHECKED IN THE Program -> Build Options menu!
' -----------------------------------------------------------------------------





' -----------------------------------------------------------------------------
' Simple thread demo...
' -----------------------------------------------------------------------------

' Mutexes are used to allow only one thread to access a variable or object in
' memory.

' A thread (including the main program's thread) can call LockMutex
' on a mutex, and if another thread has already locked the mutex, it will
' wait until the other thread has unlocked the mutex, then gain the lock. It's
' important that a thread calls UnlockMutex when it's done what it needs to do!

' The main program's thread and the spawned thread will both attempt to lock
' this mutex throughout, waiting on each other if they can't lock it...

Global Mutex = CreateMutex ()

' Try commenting out the above line, then scroll back through the output of
' the program, and you should see that the threads are fighting for access to
' the output console, creating intermeshing, gibberish text...

Print ""
Print "NOTE: Output of the two threads may not always alternate between 'Main' and 'Thread'..."
Print ""

' Create thread using Test () function and pass Null parameter...

thread:TThread = CreateThread (Test, Null)

' The new thread has now started. Do some stuff in the main program...

For a = 1 To 100

	' Other thread may be using the Print command (which isn't thread-friendly),
	' so LockMutex will wait until the thread has unlocked the mutex, and then
	' lock it so main program can call Print. It will then unlock the mutex so
	' the other thread can continue if it's ready (ie. waiting at its own
	' LockThread call)...
	
	If Mutex Then LockMutex (Mutex)
		Print "Main: " + a
	If Mutex Then UnlockMutex (Mutex)

	' Note: You'd normally just do this like the Rem'd out code below! The
	' "If Mutex" check here is to allow you to comment out the line
	' "Global Mutex = CreateMutex ()" to see why mutexes are needed...

	' You would also not normally use LockMutex so heavily, as it will
	' slow things down if over-used...
	
	Rem
	
		LockMutex (Mutex)
			Print "Main: " + a
		UnlockMutex (Mutex)
	
	End Rem
	
Next

' Other thread may still be running, so wait for it to end...

WaitThread (thread)

End

' -----------------------------------------------------------------------------
' Test function. Locks same mutex as main program, or waits until it
' can do so, calls Print, then unlocks the mutex so main program can
' lock it and proceed...
' -----------------------------------------------------------------------------

Function Test:Object (data:Object)

	For a = 1 To 100

		If Mutex Then LockMutex (Mutex)
			Print "--------> Thread: " + a
		If Mutex Then UnlockMutex (Mutex)

	Next

End Function

