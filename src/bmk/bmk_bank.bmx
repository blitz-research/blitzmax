
Strict

Import "bmk_config.bmx"

Import Pub.ZLib

Function CompressBank:TBank( bank:TBank )

	Local size=bank.Size()
	Local out_size=size+size/10+32
	Local out:TBank=TBank.Create( out_size )
	compress out.Buf()+4,out_size,bank.Buf(),size
	out.PokeByte 0,size
	out.PokeByte 1,size Shr 8
	out.PokeByte 2,size Shr 16
	out.PokeByte 3,size Shr 24
	out.Resize out_size+4
	Return out

End Function

Function UncompressBank:TBank( bank:TBank )

	Local out_size
	out_size:|bank.PeekByte(0)
	out_size:|bank.PeekByte(1) Shl 8
	out_size:|bank.PeekByte(2) Shl 16
	out_size:|bank.PeekByte(3) Shl 24
	Local out:TBank=TBank.Create( out_size )
	uncompress out.Buf(),out_size,bank.Buf()+4,bank.Size()-4
	Return out
	
End Function

Function SplitUrl( url$,server$ Var,file$ Var )
	Local i=url.Find( "/",0 )
	If i<>-1
		server=url[..i]
		file=url[i..]
	Else
		server=url
		file="/"
	EndIf
End Function

Function HTTPGetBank:TBank( url$ )

	Local server$,file$
	SplitUrl url,server,file
	
	Local t_server$=server
	If opt_proxy t_server=opt_proxy

	Local t_port=80
	If opt_proxyport t_port=opt_proxyport
	
	Local stream:TStream=TSocketStream.CreateClient( t_server,t_port )
	If Not stream Return
	
	stream.WriteLine "GET http://"+url+" HTTP/1.0"
	stream.WriteLine "Host: "+server
	stream.WriteLine ""
		
	While Not stream.Eof()
		Local t$=stream.ReadLine()
		If Not t Exit
	Wend
	
	Local bank:TBank=TBank.Create(0)
	Local bank_stream:TStream=TBankStream.Create( bank )
	
	CopyStream stream,bank_stream
	
	bank_stream.Close
	stream.Close
	
	Return bank
	
End Function

Function HTTPPostBank$( bank:TBank,url$ )

	Local server$,file$
	SplitUrl url,server,file
		
	Local t_server$=server
	If opt_proxy t_server=opt_proxy

	Local t_port=80
	If opt_proxyport t_port=opt_proxyport

	Local stream:TStream=TSocketStream.CreateClient( t_server,t_port )
	If Not stream Return
		
	stream.WriteLine "POST http://"+url+" HTTP/1.0"
	stream.WriteLine "Host: "+server
	stream.WriteLine "Content-Type: application/octet-stream"
	stream.WriteLine "Content-Length: "+bank.Size()
	stream.WriteLine ""
	
	Local bank_stream:TStream=TBankStream.Create( bank )
	CopyStream bank_stream,stream
	bank_stream.Close
	
	While Not stream.Eof()
		Local t$=stream.ReadLine()
		If Not t Exit
	Wend
	
	Local r$
	While Not stream.Eof()
		Local t$=stream.ReadLine()
		r:+t+"~n"
	Wend
	
	stream.Close
	
	Return r

End Function

