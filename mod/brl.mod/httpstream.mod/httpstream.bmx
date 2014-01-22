
Strict

Module BRL.HTTPStream

ModuleInfo "Version: 1.02"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.02 Release"

Import BRL.SocketStream

Type THTTPStreamFactory Extends TStreamFactory

	Method CreateStream:TStream( url:Object,proto$,path$,readable,writeable )
		If proto="http"

			Local i=path.Find( "/",0 ),server$,file$
			If i<>-1
				server=path[..i]
				file=path[i..]
			Else
				server=path
				file="/"
			EndIf
			
			Local stream:TStream=TSocketStream.CreateClient( server,80 )
			If Not stream Return

			stream.WriteLine "GET "+file+" HTTP/1.0"
			stream.WriteLine "Host: "+server
			stream.WriteLine ""

			While Not Eof( stream )
				If Not stream.ReadLine() Exit
			Wend

			Return stream
		EndIf
	End Method

End Type

New THTTPStreamFactory
