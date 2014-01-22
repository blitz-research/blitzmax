
'Make sure to have 'Threaded build' enabled!
'
Strict

'a simple queue
Global queue$[100],put,get

'a counter semaphore
Global counter:TSemaphore=CreateSemaphore( 0 )

Function MyThread:Object( data:Object )

	'process 100 items
	For Local item=1 To 100
	
		'add an item to the queue
		queue[put]="Item "+item
		put:+1
		
		'increment semaphore count.
		PostSemaphore counter
	
	Next
		
End Function

'create worker thread
Local thread:TThread=CreateThread( MyThread,Null )

'receive 100 items
For Local i=1 To 100

	'Wait for semaphore count to be non-0, then decrement.
	WaitSemaphore counter
	
	'Get an item from the queue
	Local item$=queue[get]
	get:+1
	
	Print item

Next
