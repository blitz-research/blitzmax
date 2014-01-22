
Strict

Rem
bbdoc: Streams/Ram streams
End Rem
Module BRL.RamStream

ModuleInfo "Version: 1.01"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

Import BRL.Stream

Type TRamStream Extends TStream

	Field _pos,_size,_buf:Byte Ptr,_read,_write

	Method Pos()
		Return _pos
	End Method

	Method Size()
		Return _size
	End Method

	Method Seek( pos )
		If pos<0 pos=0 Else If pos>_size pos=_size
		_pos=pos
		Return _pos
	End Method

	Method Read( buf:Byte Ptr,count )
		If count<=0 Or _read=False Return 0
		If _pos+count>_size count=_size-_pos
		MemCopy buf,_buf+_pos,count
		_pos:+count
		Return count
	End Method

	Method Write( buf:Byte Ptr,count )
		If count<=0 Or _write=False Return 0
		If _pos+count>_size count=_size-_pos
		MemCopy _buf+_pos,buf,count
		_pos:+count
		Return count
	End Method

	Function Create:TRamStream( buf:Byte Ptr,size,readable,writeable )
		Local stream:TRamStream=New TRamStream
		stream._pos=0
		stream._size=size
		stream._buf=buf
		stream._read=readable
		stream._write=writeable
		Return stream
	End Function

End Type

Rem
bbdoc: Create a ram stream
returns: A ram stream object
about: A ram stream allows you to read and/or write data directly from/to memory.
A ram stream extends a stream object so can be used anywhere a stream is expected.

Be careful when working with ram streams, as any attempt to access memory
which has not been allocated to your application can result in a runtime crash.
End Rem
Function CreateRamStream:TRamStream( ram:Byte Ptr,size,readable,writeable )
	Return TRamStream.Create( ram,size,readable,writeable )
End Function

Type TRamStreamFactory Extends TStreamFactory
	Method CreateStream:TRamStream( url:Object,proto$,path$,readable,writeable )
		If proto="incbin" And writeable=False
			Local buf:Byte Ptr=IncbinPtr( path )
			If Not buf Return
			Local size=IncbinLen( path )
			Return TRamStream.Create( buf,size,readable,writeable )
		EndIf
	End Method
End Type

New TRamStreamFactory
