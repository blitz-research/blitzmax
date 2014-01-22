
'Make sure to have 'Threaded build' enabled!
'
Strict

'a global list that multiple threads want to modify
Global list:TList=New TList

'a mutex controlling access to the global list
Global listMutex:TMutex=CreateMutex()

Function MyThread:Object( data:Object )

	For Local item=1 To 10
		'simulate 'other' processing...
		Delay Rand( 10,50 )

		'lock mutex so we can safely modify global list
		LockMutex listMutex

		'modify list
		list.AddLast "Thread "+data.ToString()+" added item "+item

		'unlock mutex
		UnlockMutex listMutex
	Next
	
End Function

Local threads:TThread[10]

'Create worker threads
For Local i=0 Until 10
	threads[i]=CreateThread( MyThread,String( i+1 ) )
Next

Print "Waiting for worker threads..."

'Wait for worker threads to finish
For Local i=0 Until 10
	WaitThread threads[i]
Next

'Show the resulting list
'
'Note: We don't really have to lock the mutex here, as there are no other threads running.
'Still, it's a good habit to get into.
LockMutex listMutex
For Local t$=EachIn list
	Print t
Next
UnlockMutex listMutex

