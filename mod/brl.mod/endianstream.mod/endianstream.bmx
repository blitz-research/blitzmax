
Strict

Rem
bbdoc: Streams/Endian streams
End Rem
Module BRL.EndianStream

ModuleInfo "Version: 1.01"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

Import BRL.Stream

Type TXEndianStream Extends TStreamWrapper

	Method Swap2( buf:Byte Ptr )
		Local t
		t=buf[0];buf[0]=buf[1];buf[1]=t
	End Method

	Method Swap4( buf:Byte Ptr )
		Local t
		t=buf[0];buf[0]=buf[3];buf[3]=t
		t=buf[1];buf[1]=buf[2];buf[2]=t
	End Method

	Method Swap8( buf:Byte Ptr )
		Local t
		t=buf[0];buf[0]=buf[7];buf[7]=t
		t=buf[1];buf[1]=buf[6];buf[6]=t
		t=buf[2];buf[2]=buf[5];buf[5]=t
		t=buf[3];buf[3]=buf[4];buf[4]=t
	End Method

	Method ReadShort()
		Local q:Short
		ReadBytes Varptr q,2
		Swap2 Varptr q
		Return q
	End Method

	Method WriteShort( n )
		Local q:Short=n
		Swap2 Varptr q
		WriteBytes Varptr q,2
	End Method

	Method ReadInt()
		Local q:Int
		ReadBytes Varptr q,4
		Swap4 Varptr q
		Return q
	End Method

	Method WriteInt( n )
		Local q:Int=n
		Swap4 Varptr q
		WriteBytes Varptr q,4
	End Method

	Method ReadLong:Long()
		Local q:Long
		ReadBytes Varptr q,8
		Swap8 Varptr q
		Return q
	End Method

	Method WriteLong( n:Long )
		Local q:Long=n
		Swap8 Varptr q
		WriteBytes Varptr q,8
	End Method
	
	Method ReadFloat#()
		Local q:Float
		ReadBytes Varptr q,4
		Swap4 Varptr q
		Return q
	End Method

	Method WriteFloat( n# )
		Local q:Float=n
		Swap4 Varptr q
		WriteBytes Varptr q,4
	End Method

	Method ReadDouble!()
		Local q:Double
		ReadBytes Varptr q,8
		Swap8 Varptr q
		Return q
	End Method

	Method WriteDouble( n! )
		Local q:Double=n
		Swap8 Varptr q
		WriteBytes Varptr q,8
	End Method

	Function Create:TStream( stream:TStream )
		If Not stream Return
		Local t:TXEndianStream=New TXEndianStream
		t.SetStream( stream )
		Return t
	End Function

	Function BigEndian:TStream( stream:TStream )
?LittleEndian
		Return Create( stream )
?BigEndian
		Return stream
?
	End Function

	Function LittleEndian:TStream( stream:TStream )
?BigEndian
		Return Create( stream )
?LittleEndian	
		Return stream
?
	End Function

End Type

Rem 
bbdoc: BigEndianStream
returns: A big endian stream
end rem
Function BigEndianStream:TStream( stream:TStream )
	Return TXEndianStream.BigEndian( stream )
End Function

Rem
bbdoc: LittleEndianStream
returns: A little endian stream
end rem
Function LittleEndianStream:TStream( stream:TStream )
	Return TXEndianStream.LittleEndian( stream )
End Function

Type TXEndianStreamFactory Extends TStreamFactory
	Method CreateStream:TStream( url:Object,proto$,path$,readable,writeable )
		Select proto$
		Case "bigendian"
			Return TXEndianStream.BigEndian( OpenStream(path,readable,writeable) )
		Case "littleendian"
			Return TXEndianStream.LittleEndian( OpenStream(path,readable,writeable) )
		End Select
	End Method
End Type

New TXEndianStreamFactory

