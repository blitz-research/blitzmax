
Strict

Rem
bbdoc: Streams/Socket streams
End Rem
Module BRL.SocketStream

ModuleInfo "Version: 1.05"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.05 Release"
ModuleInfo "History: CreateStream port handling fix documented"
ModuleInfo "History: 1.04 Release"
ModuleInfo "History: TSocketStream now just wraps a TSocket"

Import BRL.Socket
Import BRL.Stream

Type TSocketStream Extends TStream

	Method Read( buf:Byte Ptr,count )
		Return _socket.Recv( buf,count )
	End Method

	Method Write( buf:Byte Ptr,count )
		Return _socket.Send( buf,count )
	End Method

	Method Eof()
		If Not _socket Return True
		If _socket.Connected() Return False
		Close
		Return True
	End Method

	Method Close()
		If Not _socket Return
		If _autoClose _socket.Close
		_socket=Null
	End Method
	
	Method Socket:TSocket()
		Return _socket
	End Method
	
	Function Create:TSocketStream( socket:TSocket,autoClose=True )
		Local t:TSocketStream=New TSocketStream
		t._socket=socket
		t._autoClose=autoClose
		Return t
	End Function
	
	Function CreateClient:TSocketStream( remoteHost$,remotePort )
		Local remoteIp=HostIp( remoteHost )
		If Not remoteIp Return
		
		Local socket:TSocket=TSocket.CreateTCP()
		If socket
			If socket.Connect( remoteIp,remotePort ) 
				Return Create( socket,True )
			EndIf
			socket.Close
		EndIf

	End Function
	
	Field _socket:TSocket,_autoClose
	
End Type

Type TSocketStreamFactory Extends TStreamFactory
	Method CreateStream:TSocketStream( url:Object,proto$,path$,readable,writeable )
		If proto$="tcp"
			Local i=path.Find( ":",0 ),server$,port
			If i>=0 Return TSocketStream.CreateClient( path[..i],Int(path[i+1..]) )
			Return TSocketStream.CreateClient( path,80 )
		EndIf
	End Method
End Type

New TSocketStreamFactory

Rem
bbdoc: Create a socket stream
returns: A new socket stream
about:
A socket stream allows you to treat a socket as if it were a stream.

If @autoClose is true, @socket will be automatically closed when the socket
stream is closed. Otherwise, it is up to you to somehow close @socket at
a later time.
End Rem
Function CreateSocketStream:TSocketStream( socket:TSocket,autoClose=True )
	Return TSocketStream.Create( socket,autoClose )
End Function

Rem
bbdoc: Get underlying socket from a socket stream
returns: The socket used to create the socket stream
End Rem
Function SocketStreamSocket:TSocket( stream:TSocketStream )
	Return stream.Socket()
End Function
