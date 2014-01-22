
Strict

Rem
bbdoc: System/Threads 
End Rem
Module BRL.Threads

ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"

?Threaded

Import "threads.c"

Private

Extern

Function bbThreadAllocData()
Function bbThreadSetData( index,data:Object )
Function bbThreadGetData:Object( index )

Function bbAtomicCAS( target Var,old_value,new_value )
Function bbAtomicAdd( target Var,value )

Function threads_CreateThread( entry:Object( data:Object ),data:Object )
Function threads_DetachThread( thread )
Function threads_WaitThread:Object( thread )

Function threads_CreateMutex()
Function threads_CloseMutex( mutex )
Function threads_LockMutex( mutex )
Function threads_TryLockMutex( mutex )
Function threads_UnlockMutex( mutex )

Function threads_CreateSemaphore( count )
Function threads_CloseSemaphore( sema )
Function threads_WaitSemaphore( sema )
Function threads_PostSemaphore( sema )

Function threads_CreateCond()
Function threads_WaitCond( cond,mutex )
Function threads_SignalCond( cond )
Function threads_BroadcastCond( cond )
Function threads_CloseCond( cond )

End Extern

Global _mainThread:TThread=New TThread

Global _curThread:TThreadData=TThreadData.Create()

_curThread.SetValue _mainThread

Public

Rem
bbdoc: Thread type
End Rem
Type TThread

	Rem
	bbdoc: Detach this thread
	End Rem
	Method Detach()
		If Not _handle Return	'don't Assert, as Detach is a form of Close() which always works...
		threads_DetachThread _handle
		_handle=0
	End Method

	Rem
	bbdoc: Wait for this thread to finish
	returns: The object returned by the thread.
	End Rem	
	Method Wait:Object()
		If Not _handle Return _result	'don't Assert, as Wait is a form of Close() which always works...
		threads_WaitThread _handle
		_handle=0
		Return _result
	End Method
	
	Rem
	bbdoc: Check if this thread is running
	End Rem
	Method Running()
		Return _running
	End Method
	
	Rem
	bbdoc: Create a new thread
	End Rem
	Function Create:TThread( entry:Object( data:Object),data:Object )
		Local thread:TThread=New TThread
		thread._entry=entry
		thread._data=data
		thread._running=True
		thread._handle=threads_CreateThread( _EntryStub,thread )
		Return thread
	End Function
	
	Rem
	bbdoc: Get main thread
	returns: A thread object representing the main application thread.
	End Rem
	Function Main:TThread()
		Return _mainThread
	End Function
	
	Rem
	bbdoc: Get current thread
	returns: A thread object representing the current thread.
	End Rem
	Function Current:TThread()
		Return TThread( _curThread.GetValue() )
	End Function
	
	Function _EntryStub:Object( data:Object )
		Local thread:TThread=TThread( data )
		_curThread.SetValue thread
		thread._result=thread._entry( thread._data )
		thread._running=False
	End Function

	Method Delete()
		If _handle threads_DetachThread _handle
	End Method
	
	Field _running
	Field _handle
	Field _result:Object
	
	Field _entry:Object( data:Object )
	Field _data:Object
	
End Type

Rem
bbdoc: ThreadData type
End Rem
Type TThreadData

	Rem
	bbdoc: Set thread data value
	End Rem
	Method SetValue( value:Object )
		bbThreadSetData _handle,value
	End Method
	
	Rem
	bbdoc: Get thread data value
	End Rem
	Method GetValue:Object()
		Return bbThreadGetData( _handle )
	End Method
	
	Rem
	bbdoc: Create thread data
	End Rem
	Function Create:TThreadData()
		Local handle=bbThreadAllocData()
		If Not handle Return
		Local data:TThreadData=New TThreadData
		data._handle=handle
		Return data
	End Function

	Field _handle

End Type

Rem
bbdoc: Mutex type
End Rem
Type TMutex

	Rem
	bbdoc: Close the mutex
	End Rem
	Method Close()
		If Not _handle Return
		threads_CloseMutex _handle
		_handle=0
	End Method

	Rem
	bbdoc: Lock the mutex
	End Rem
	Method Lock()
		Assert _handle
		threads_LockMutex _handle
	End Method
	
	Rem
	bbdoc: Try to lock the mutex
	returns: #True if mutex was successfully locked; #False if mutex was already locked by another thread.
	End Rem
	Method TryLock()
		Assert _handle
		Return threads_TryLockMutex( _handle )
	End Method

	Rem
	bbdoc: Unlock the mutex
	End Rem	
	Method Unlock()
		Assert _handle
		threads_UnlockMutex _handle
	End Method
	
	Rem
	bbdoc: Create a new mutex
	End Rem
	Function Create:TMutex()
		Local handle=threads_CreateMutex()
		If Not handle Return
		Local mutex:TMutex=New TMutex
		mutex._handle=handle
		Return mutex
	End Function

	Method Delete()
		If _handle threads_CloseMutex _handle
	End Method
	
	Field _handle
	
End Type

Rem
bbdoc: Semaphore type
End Rem
Type TSemaphore

	Rem
	bbdoc: Close the semaphore
	End Rem
	Method Close()
		If Not _handle Return
		threads_CloseSemaphore _handle
		_handle=0
	End Method

	Rem
	bbdoc: Wait for the semaphore
	End Rem
	Method Wait()
		Assert _handle
		threads_WaitSemaphore _handle
	End Method
	
	Rem
	bbdoc: Post the semaphore
	End Rem
	Method Post()
		Assert _handle
		threads_PostSemaphore _handle
	End Method
	
	Rem
	bbdoc: Create a new semaphore
	End Rem
	Function Create:TSemaphore( count )
		Local handle=threads_CreateSemaphore( count )
		If Not handle Return
		Local semaphore:TSemaphore=New TSemaphore
		semaphore._handle=handle
		Return semaphore
	End Function

	Method Delete()
		If _handle threads_CloseSemaphore _handle
	End Method
	
	Field _handle
	
End Type

Rem
bbdoc: CondVar type
End Rem
Type TCondVar

	Rem
	bbdoc: Close the condvar
	End Rem
	Method Close()
		If Not _handle Return
		threads_CloseCond _handle
		_handle=0
	End Method

	Rem
	bbdoc: Wait for the condvar
	End Rem	
	Method Wait( mutex:TMutex )
		Assert _handle
		threads_WaitCond _handle,mutex._handle
	End Method
	
	Rem 
	bbdoc: Signal the condvar
	End Rem
	Method Signal()
		Assert _handle
		threads_SignalCond _handle
	End Method
	
	Rem
	bbdoc: Broadcast the condvar
	End Rem
	Method Broadcast()
		Assert _handle
		threads_BroadcastCond _handle
	End Method
	
	Rem
	bbdoc: Create a new condvar
	End Rem
	Function Create:TCondVar()
		Local handle=threads_CreateCond()
		If Not handle Return
		Local condvar:TCondVar=New TCondVar
		condvar._handle=handle
		Return condvar
	End Function
	
	Method Delete()
		If _handle threads_CloseCond _handle
	End Method
	
	Field _handle

End Type

Rem
bbdoc: Create a thread
returns: A new thread object.
about:
Creates a thread and returns a thread object.

The value returned by the thread @entry routine can be later retrieved using #WaitThread.

To 'close' a thread, call either #DetachThread or #WaitThread. This isn't strictly
necessary as the thread will eventually be closed when it is garbage collected, however, it
may be a good idea if you are creating many threads very often, as some operating systems have
a limit on the number of threads that can be allocated at once.
End Rem
Function CreateThread:TThread( entry:Object( data:Object ),data:Object )
	Return TThread.Create( entry,data )
End Function

Rem
bbdoc: Get main thread
returns: A thread object representing the main application thread.
End Rem
Function MainThread:TThread()
	Return _mainThread
End Function

Rem
bbdoc: Get current thread
returns: A thread object representing the current thread.
End Rem
Function CurrentThread:TThread()
	Return TThread( _curThread.GetValue() )
End Function

Rem
bbdoc: Detach a thread
about:
#DetachThread closes a thread's handle, but does not halt or otherwise affect the target thread.

Once one a thread has been detached, it wil no longer be possible to use #WaitThread to get its return value.

This allows the thread to run without your program having to continually check whether it has completedin order to close it.
End Rem
Function DetachThread( thread:TThread )
	Return thread.Detach()
End Function

Rem
bbdoc: Wait for a thread to finish
returns: The object returned by the thread entry routine.
about:
#WaitThread causes the calling thread to block until the target thread has completed execution.

If the target thread has already completed execution, #WaitThread returns immediately.

The returned object is the object returned by the thread's entry routine, as passed to #CreateThread.
End Rem
Function WaitThread:Object( thread:TThread )
	Return thread.Wait()
End Function

Rem
bbdoc: Check if a thread is running
returns: #True if @thread is still running, otherwise #False.
End Rem
Function ThreadRunning( thread:TThread )
	Return thread.Running()
End Function

Rem
bbdoc: Create thread data
returns: A new thread data object.
End Rem
Function CreateThreadData:TThreadData()
	Return TThreadData.Create()
End Function

Rem
bbdoc: Set thread data value
End Rem
Function SetThreadDataValue( data:TThreadData,value:Object )
	data.SetValue value
End Function

Rem
bbdoc: Get thread data value
End Rem
Function GetThreadDataValue:Object( data:TThreadData )
	Return data.Getvalue()
End Function

Rem
bbdoc: Create a mutex
returns: A new mutex object
End Rem
Function CreateMutex:TMutex()
	Return TMutex.Create()
End Function

Rem
bbdoc: Close a mutex
End Rem
Function CloseMutex( mutex:TMutex )
	mutex.Close
End Function

Rem 
bbdoc: Lock a mutex
End Rem
Function LockMutex( mutex:TMutex )
	mutex.Lock
End Function

Rem
bbdoc: Try to lock a mutex
returns: #True if @mutex was successfully locked; #False if @mutex was already locked by another thread.
End Rem
Function TryLockMutex( mutex:TMutex )
	Return mutex.TryLock()
End Function

Rem
bbdoc: Unlock a mutex
End Rem
Function UnlockMutex( mutex:TMutex )
	mutex.Unlock
End Function

Rem
bbdoc: Create a semaphore
returns: A new semaphore object
End Rem
Function CreateSemaphore:TSemaphore( count )
	Return TSemaphore.Create( count )
End Function

Rem
bbdoc: Close a semaphore
End Rem
Function CloseSemaphore( semaphore:TSemaphore )
	semaphore.Close
End Function

Rem
bbdoc: Wait for a semaphore
End Rem
Function WaitSemaphore( semaphore:TSemaphore )
	semaphore.Wait
End Function

Rem
bbdoc: Post a semaphore
End Rem
Function PostSemaphore( semaphore:TSemaphore )
	semaphore.Post
End Function

Rem
bbdoc: Create a condvar
returns: A new condvar object
End Rem
Function CreateCondVar:TCondVar()
	Return TCondVar.Create()
End Function

Rem
bbdoc: Close a condvar
End Rem
Function CloseCondVar( condvar:TCondVar )
	condvar.Close
End Function

Rem
bbdoc: Wait for a condvar
End Rem
Function WaitCondVar( condvar:TCondVar,mutex:TMutex )
	condvar.Wait mutex
End Function

Rem
bbdoc: Signal a condvar
End Rem
Function SignalCondVar( condvar:TCondVar )
	condvar.Signal
End Function

Rem
bbdoc: Broadcast a condvar
End Rem
Function BroadcastCondVar( condvar:TCondVar )
	condvar.Broadcast
End Function

Rem
bbdoc: Compare and swap
returns: @True if target was updated
about:
Atomically replace @target with @new_value if @target equals @old_value.
End Rem
Function CompareAndSwap( target Var,oldValue,newValue )
	Return bbAtomicCAS( target,oldValue,newValue )
End Function

Rem
bbdoc: Atomic add
returns: Previuous value of target
about:
Atomically add @value to @target.
End Rem
Function AtomicAdd( target Var,value )
	Return bbAtomicAdd( target,value )
End Function

Rem
bbdoc: Atomically swap values
returns: The old value of @target
End Rem
Function AtomicSwap( target Var,value )
	Repeat
		Local oldval=target
		If CompareAndSwap( target,oldval,value ) Return oldval
	Forever
End Function

?
