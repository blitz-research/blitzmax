
Strict

Type TUpperStream Extends TStreamWrapper

	Method Read( buf:Byte Ptr,count )
		'Read data from the underlying stream
		count=Super.Read( buf,count )
		'Convert the data to uppercase
		For Local i=0 Until count
			If buf[i]>=Asc("a") And Buf[i]<=Asc("z")
				buf[i]=buf[i]-Asc("a")+Asc("A")
			EndIf
		Next
		'Done!
		Return count
	End Method

	Method Write( buf:Byte Ptr,count )
		'Copy the data to a new buffer, converting to uppercase as we go
		Local tmp:Byte[count]
		For Local i=0 Until count
			If buf[i]>=Asc("a") And buf[i]<=Asc("z")
				tmp[i]=buf[i]-Asc("a")+Asc("A")
			Else
				tmp[i]=buf[i]
			EndIf
		Next
		'Write the data to the underlying stream
		Return Super.Write( tmp,count )
	End Method

	Function Create:TUpperStream( stream:TStream )
		Local t:TUpperStream=New TUpperStream
		'SetStream is a TStreamWrapper method that sets the underlying stream.
		t.SetStream stream
		Return t
	End Function

End Type

Type TUpperStreamFactory Extends TStreamFactory

	Method CreateStream:TUpperStream( url:Object,proto$,path$,readable,writeable )
		If proto$<>"uppercase" Return
		Local stream:TStream=OpenStream( path,readable,writeable )
		If stream Return TUpperStream.Create( stream )
	End Method
	
End Type

New TUpperStreamFactory

'Exmaple of manually creating a TUpperStream:

'Create a tmp file and write some text to it.
Local tmp:TStream=WriteStream( "tmp" )
tmp.WriteLine "A little example..."
tmp.WriteLine "of our cool TUpperStream!"
tmp.Close

'Open tmp file again, and wrap it with a TUpperStream
tmp:TStream=ReadStream( "tmp" ) 
Local upperizer:TUpperStream=TUpperStream.Create( tmp )

'Dump file contents
While Not upperizer.Eof()
	Print upperizer.ReadLine()
Wend

upperizer.Close
tmp.Close

'Example of automatically creating a TUpperStream:
Local tmp2:TStream=WriteStream( "uppercase::tmp" )
tmp2.WriteLine "Another little example..."
tmp2.WriteLine "of our even cooler TUpperStream!"
tmp2.Close

tmp2:TStream=ReadStream( "tmp" )
While Not tmp2.Eof()
	Print tmp2.ReadLine()
Wend
tmp2.Close





