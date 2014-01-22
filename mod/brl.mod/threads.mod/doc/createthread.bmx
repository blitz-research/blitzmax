
'Make sure to have 'Threaded build' enabled!
'
Strict

'Custom print that shows which thread is doing the printing
Function MyPrint( t$ )
	If CurrentThread()=MainThread() 
		Print "Main thread: "+t
	Else
		Print "Child thread: "+t
	EndIf
End Function

'Our thread function
Function MyThread:Object( data:Object )

	'show data we were passed
	Myprint data.ToString()

	'do some work
	For Local i=1 To 1000
		MyPrint "i="+i
	Next
	
	'return a value from the thread
	Return "Data returned from child thread."
	
End Function

MyPrint "About to start child thread."

'create a thread!
Local thread:TThread=CreateThread( MyThread,"Data passed to child thread." )

'wait for thread to finish and print value returned from thread
MyPrint WaitThread( Thread ).ToString()

