
Strict

Rem
bbdoc: Streams/Streams
End Rem
Module BRL.Stream

ModuleInfo "Version: 1.09"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.09 Release"
ModuleInfo "History: Fixed 'excpetion' typos"
ModuleInfo "History: 1.08 Release"
ModuleInfo "History: Fixed resource leak in CasedFileName"
ModuleInfo "History: 1.07 Release"
ModuleInfo "History: OpenStream protocol:: now case insensitive"
ModuleInfo "History: Fixed ReadString with 0 length strings"
ModuleInfo "History: Removed LoadStream - use LoadByteArray instead"
ModuleInfo "History: Removed AddStreamFactory function"
ModuleInfo "History: Added url parameter to TStreamFactory CreateStream method"
ModuleInfo "History: 1.06 Release"
ModuleInfo "History: Added checks to CStream for reading from write only stream and vice versa"
ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Fixed Eof bug"
ModuleInfo "History: 1.04 Release"
ModuleInfo "History: Added LoadString"
ModuleInfo "History: Added LoadByteArray"
ModuleInfo "History: Cleaned up docs a bit"

Import Pub.StdC

Rem
bbdoc: Base exception type thrown by streams
End Rem
Type TStreamException
End Type

Rem
bbdoc: Exception type thrown by streams in the event of read errors
about:
#TStreamReadException is usually thrown when a stream operation failed to read enough
bytes. For example, if the stream ReadInt method fails to read 4 bytes, it will throw
a #TStreamReadException.
End Rem
Type TStreamReadException Extends TStreamException
	Method ToString$()
		Return "Error reading from stream"
	End Method
End Type

Rem
bbdoc: Exception type thrown by streams in the event of write errors
about:
#TStreamWriteException is usually thrown when a stream operation failed to write enough
bytes. For example, if the stream WriteInt method fails to write 4 bytes, it will throw
a #TStreamWriteException.
End Rem
Type TStreamWriteException Extends TStreamException
	Method ToString$()
		Return "Error writing to stream"
	End Method
End Type

Rem
bbdoc: Base input/output type
about:
To create your own stream types, you should extend TStream and implement
at least these methods.

You should also make sure your stream can handle multiple calls to the Close method.
End Rem
Type TIO
	Rem
	bbdoc: Get stream end of file status
	returns: True for end of file reached, otherwise False
	about:
	For seekable streams such as file streams, Eof generally returns True if the file
	position equals the file size. This means that no more bytes can be read from the
	stream. However, it may still be possible to write bytes, in which case the file will
	 'grow'.
	
	For communication type streams such as socket streams, Eof returns True if the stream
	has been shut down for some reason - either locally or by the remote host. In this case,
	no more bytes can be read from or written to the stream.
	End Rem
	Method Eof()
		Return Pos()=Size()
	End Method

	Rem
	bbdoc: Get position of seekable stream
	returns: Stream position as a byte offset, or -1 if stream is not seekable
	End Rem
	Method Pos()
		Return -1
	End Method

	Rem
	bbdoc: Get size of seekable stream
	returns: Size, in bytes, of seekable stream, or 0 if stream is not seekable
	End Rem
 	Method Size()
		Return 0
	End Method

	Rem
	bbdoc: Seek to position in seekable stream
	returns: New stream position, or -1 if stream is not seekable
	End Rem
	Method Seek( pos )
		Return -1
	End Method

	Rem
	bbdoc: Flush stream
	about:
	Flushes any internal stream buffers.
	End Rem
	Method Flush()
	End Method

	Rem
	bbdoc: Close stream
	about:
	Closes the stream after flushing any internal stream buffers.
	End Rem
	Method Close()
	End Method

	Rem
	bbdoc: Read at least 1 byte from a stream
	returns: Number of bytes successfully read
	about:
	This method may 'block' if it is not possible to read at least one byte due to IO 
	buffering.
	
	If this method returns 0, the stream has reached end of file.
	End Rem
	Method Read( buf:Byte Ptr,count )
		RuntimeError "Stream is not readable"
		Return 0
	End Method

	Rem
	bbdoc: Write at least 1 byte to a stream
	returns: Number of bytes successfully written
	about:
	This method may 'block' if it is not possible to write at least one byte due to IO
	buffering.
	
	If this method returns 0, the stream has reached end of file.
	End Rem
	Method Write( buf:Byte Ptr,count )
		RuntimeError "Stream is not writeable"
		Return 0
	End Method

	Method Delete()
		Close
	End Method

End Type

Rem
bbdoc: Data stream type
about:
#TStream extends #TIO to provide methods for reading and writing various types of values
to and from a stream.

Note that methods dealing with strings - ReadLine, WriteLine, ReadString and WriteString -
assume that strings are represented by bytes in the stream. In future, a more powerful
TextStream type will be added capable of decoding text streams in multiple formats.
End Rem
Type TStream Extends TIO

	Rem
	bbdoc: Reads bytes from a stream
	about:
	#ReadBytes reads @count bytes from the stream into the memory block specified by @buf.
	
	If @count bytes were not successfully read, a #TStreamReadException is thrown. This typically
	occurs due to end of file.
	End Rem
	Method ReadBytes( buf:Byte Ptr,count )
		Local t=count
		While count>0
			Local n=Read( buf,count )
			If Not n Throw New TStreamReadException
			count:-n
			buf:+n
		Wend
		Return t
	End Method

	Rem
	bbdoc: Writes bytes to a stream
	about:
	#WriteBytes writes @count bytes from the memory block specified by @buf to the stream.
	
	If @count bytes were not successfully written, a #TStreamWriteException is thrown. This typically
	occurs due to end of file.
	End Rem
	Method WriteBytes( buf:Byte Ptr,count )
		Local t=count
		While count>0
			Local n=Write( buf,count )
			If Not n Throw New TStreamWriteException
			count:-n
			buf:+n
		Wend
		Return t
	End Method

	Rem
	bbdoc: Skip bytes in a stream
	about:
	#SkipBytes read @count bytes from the stream and throws them away.
	
	If @count bytes were not successfully read, a #TStreamReadException is thrown. This typically
	occurs due to end of file.
	End Rem
	Method SkipBytes( count )
		Local t=count
		Local buf:Byte[1024]
		While count>0
			Local n=Read( buf,Min(count,buf.length) )
			If Not n Throw New TStreamReadException
			count:-n
		Wend
		Return t
	End Method

	Rem
	bbdoc: Read a byte from the stream
	returns: The read value
	about:
	If a value could not be read (possibly due to end of file), a #TStreamReadException is thrown.
	End Rem
	Method ReadByte()
		Local n:Byte
		ReadBytes Varptr n,1
		Return n
	End Method

	Rem
	bbdoc: Write a byte to the stream
	about:
	If the value could not be written (possibly due to end of file), a #TStreamWriteException is thrown.
	End Rem
	Method WriteByte( n )
		Local q:Byte=n
		WriteBytes Varptr q,1
	End Method

	Rem
	bbdoc: Read a short (two bytes) from the stream
	returns: The read value
	about:
	If a value could not be read (possibly due to end of file), a #TStreamReadException is thrown.
	End Rem
	Method ReadShort()
		Local n:Short
		ReadBytes Varptr n,2
		Return n
	End Method

	Rem
	bbdoc: Write a short (two bytes) to the stream
	about:
	If the value could not be written (possibly due to end of file), a #TStreamWriteException is thrown.
	End Rem
	Method WriteShort( n )
		Local q:Short=n
		WriteBytes Varptr q,2
	End Method

	Rem
	bbdoc: Read an int (four bytes) from the stream
	returns: The read value
	about:
	If a value could not be read (possibly due to end of file), a #TStreamReadException is thrown.
	End Rem
	Method ReadInt()
		Local n
		ReadBytes Varptr n,4
		Return n
	End Method
	
	Rem
	bbdoc: Write an int (four bytes) to the stream
	about:
	If the value could not be written (possibly due to end of file), a #TStreamWriteException is thrown.
	End Rem
	Method WriteInt( n )
		Local q:Int=n
		WriteBytes Varptr q,4
	End Method
	
	Rem
	bbdoc: Read a long (eight bytes) from the stream
	returns: The read value
	about:
	If a value could not be read (possibly due to end of file), a #TStreamReadException is thrown.
	End Rem
	Method ReadLong:Long()
		Local n:Long
		ReadBytes Varptr n,8
		Return n
	End Method
	
	Rem
	bbdoc: Write a long (eight bytes) to the stream
	about:
	If the value could not be written (possibly due to end of file), a #TStreamWriteException is thrown.
	End Rem
	Method WriteLong( n:Long )
		Local q:Long=n
		WriteBytes Varptr q,8
	End Method
	
	Rem
	bbdoc: Read a float (four bytes) from the stream
	returns: The read value
	about:
	If a value could not be read (possibly due to end of file), a #TStreamReadException is thrown.
	End Rem
	Method ReadFloat#()
		Local n#
		ReadBytes Varptr n,4
		Return n
	End Method

	Rem
	bbdoc: Write a float (four bytes) to the stream
	about:
	If the value could not be written (possibly due to end of file), a #TStreamWriteException is thrown.
	End Rem
	Method WriteFloat( n# )
		Local q#=n
		WriteBytes Varptr q,4
	End Method

	Rem
	bbdoc: Read a double (eight bytes) from the stream
	returns: The read value
	about:
	If a value could not be read (possibly due to end of file), a #TStreamReadException is thrown.
	End Rem
	Method ReadDouble!()
		Local n!
		ReadBytes Varptr n,8
		Return n
	End Method

	Rem
	bbdoc: Write a double (eight bytes) to the stream
	about:
	If the value could not be written (possibly due to end of file), a #TStreamWriteException is thrown.
	End Rem
	Method WriteDouble( n! )
		Local q!=n
		WriteBytes Varptr q,8
	End Method
	
	Rem
	bbdoc: Read a line of text from the stream
	about: 
	Bytes are read from the stream until a newline character (ascii code 10) or null
	character (ascii code 0) is read, or end of file is detected.
	
	Carriage return characters (ascii code 13) are silently ignored.
	
	The bytes read are returned in the form of a string, excluding any terminating newline
	or null character.
	End Rem
	Method ReadLine$()
		Local buf:Byte[1024],sz
		Repeat
			Local ch:Byte
			If Read( Varptr ch,1 )<>1 Or ch=0 Or ch=10 Exit
			If ch=13 Continue
			If sz=buf.length buf=buf[..sz*2]
			buf[sz]=ch
			sz:+1
		Forever
		Return String.FromBytes( buf,sz )
	End Method

	Rem
	bbdoc: Write a line of text to the stream
	returns: True if line successfully written, else False
	about: A sequence of bytes is written to the stream (one for each character in @str)
	followed by the line terminating sequence "~r~n".
	End Rem
	Method WriteLine( str$ )
		Local buf:Byte Ptr=str.ToCString()
		Local ok=Write( buf,str.length )=str.length And Write( [13:Byte,10:Byte],2 )=2
		MemFree buf
		Return ok
	End Method

	Rem
	bbdoc: Read characters from the stream
	returns: A string composed of @length bytes read from the stream
	about:
	A #TStreamReadException is thrown if not all bytes could be read.
	End Rem
	Method ReadString$( length )
		Assert length>=0 Else "Illegal String length"
		Local buf:Byte[length]
		Readbytes buf,length
		Return String.FromBytes( buf,length )
	End Method
	
	Rem
	bbdoc: Write characters to the stream
	about:
	A #TStreamWriteException is thrown if not all bytes could be written.
	End Rem
	Method WriteString( str$ )
		Local buf:Byte Ptr=str.ToCString()
		WriteBytes buf,str.length
		MemFree buf
	End Method
	
	Method ReadObject:Object()
		Throw "Unable to read object"
	End Method
	
	Method WriteObject( obj:Object )
		Throw "Unable to write object"
	End Method

End Type

Rem
bbdoc: Utility stream wrapper type
about:
#TStreamWrapper 'wraps' an existing stream, redirecting all TIO method calls to the wrapped
stream.

This can be useful for writing stream 'filters' that modify the behaviour of existing
streams.

Note that the Close method causes the underlying stream to be closed, which may not always
be desirable. If necessary, you should override Close with a NOP version.
End Rem
Type TStreamWrapper Extends TStream
	Field _stream:TStream

	Rem
	bbdoc: Set underlying stream
	about:
	Sets the stream to be 'wrapped'. All calls to TIO methods of this stream will be
	redirected to @stream.
	end rem
	Method SetStream( stream:TStream )
		_stream=stream
	End Method

	Method Eof()
		Return _stream.Eof()
	End Method

	Method Pos()
		Return _stream.Pos()
	End Method

	Method Size()
		Return _stream.Size()
	End Method
	
	Method Seek( pos )
		Return _stream.Seek( pos )
	End Method

	Method Flush()
		_stream.Flush
	End Method

	Method Close()
		_stream.Close
	End Method

	Method Read( buf:Byte Ptr,count )
		Return _stream.Read( buf,count )
	End Method

	Method Write( buf:Byte Ptr,count )
		Return _stream.Write( buf,count )
	End Method
	
	Method ReadByte()
		Return _stream.ReadByte()
	End Method
	
	Method WriteByte( n )
		_stream.WriteByte n
	End Method
	
	Method ReadShort()
		Return _stream.ReadShort()
	End Method
	
	Method WriteShort( n )
		_stream.WriteShort n
	End Method
	
	Method ReadInt()
		Return _stream.ReadInt()
	End Method
	
	Method WriteInt( n )
		_stream.WriteInt n
	End Method
	
	Method ReadFloat:Float()
		Return _stream.ReadFloat()
	End Method
	
	Method WriteFloat( n:Float )
		_stream.WriteFloat n
	End Method
	
	Method ReadDouble:Double()
		Return _stream.ReadDouble()
	End Method
	
	Method WriteDouble( n:Double )
		_stream.WriteDouble n
	End Method
	
	Method ReadLine$()
		Return _stream.ReadLine()
	End Method
	
	Method WriteLine( t$ )
		Return _stream.WriteLine( t )
	End Method
	
	Method ReadString$( n )
		Return _stream.ReadString( n )
	End Method
	
	Method WriteString( t$ )
		_stream.WriteString t
	End Method
	
	Method ReadObject:Object()
		Return _stream.ReadObject()
	End Method
	
	Method WriteObject( obj:Object )
		_stream.WriteObject obj
	End Method
	
End Type	

Type TStreamStream Extends TStreamWrapper

	Method Close()
		SetStream Null
	End Method

	Function Create:TStreamStream( stream:TStream )
		Local t:TStreamStream=New TStreamStream
		t.SetStream stream
		Return t
	End Function
	
End Type

Rem
bbdoc: Standard C file stream type
about:
End Rem
Type TCStream Extends TStream

	Const MODE_READ=1
	Const MODE_WRITE=2
	
	Field _pos,_size,_cstream,_mode

	Method Pos()
		Return _pos
	End Method

	Method Size()
		Return _size
	End Method

	Method Seek( pos )
		Assert _cstream Else "Attempt to seek closed stream"
		fseek_ _cstream,pos,SEEK_SET_
		_pos=ftell_( _cstream )
		Return _pos
	End Method

	Method Read( buf:Byte Ptr,count )
		Assert _cstream Else "Attempt to read from closed stream"
		Assert _mode & MODE_READ Else "Attempt to read from write-only stream"
		count=fread_( buf,1,count,_cstream )	
		_pos:+count
		Return count
	End Method

	Method Write( buf:Byte Ptr,count )
		Assert _cstream Else "Attempt to write to closed stream"
		Assert _mode & MODE_WRITE Else "Attempt to write to read-only stream"
		count=fwrite_( buf,1,count,_cstream )
		_pos:+count
		If _pos>_size _size=_pos
		Return count
	End Method

	Method Flush()
		If _cstream fflush_ _cstream
	End Method

	Method Close()
		If Not _cstream Return
		Flush
		fclose_ _cstream
		_pos=0
		_size=0
		_cstream=0
	End Method
	
	Method Delete()
		Close
	End Method

	Rem
	bbdoc: Create a TCStream from a 'C' filename
	End Rem
	Function OpenFile:TCStream( path$,readable,writeable )
		Local mode$,_mode
		If readable And writeable
			mode="r+b"
			_mode=MODE_READ|MODE_WRITE
		Else If writeable
			mode="wb"
			_mode=MODE_WRITE
		Else
			mode="rb"
			_mode=MODE_READ
		EndIf
		path=path.Replace( "\","/" )
		Local cstream=fopen_( path,mode )
?Linux
		If (Not cstream) And (Not writeable)
			path=CasedFileName(path)
			If path cstream=fopen_( path,mode )
		EndIf
?
		If cstream Return CreateWithCStream( cstream,_mode )
	End Function

	Rem
	bbdoc: Create a TCStream from a 'C' stream handle
	end rem
	Function CreateWithCStream:TCStream( cstream,mode )
		Local stream:TCStream=New TCStream
		stream._cstream=cstream
		stream._pos=ftell_( cstream )
		fseek_ cstream,0,SEEK_END_
		stream._size=ftell_( cstream )
		fseek_ cstream,stream._pos,SEEK_SET_
		stream._mode=mode
		Return stream
	End Function

End Type

Private
Global stream_factories:TStreamFactory
Public

Rem
bbdoc: Base stream factory type
about:
Stream factories are used by the #OpenStream, #ReadStream and #WriteStream functions
to create streams based on a 'url object'.

Url objects are usually strings, in which case the url is divided into 2 parts - a 
protocol and a path. These are separated by a double colon string - "::".

To create your own stream factories, you should extend the TStreamFactory type and
implement the CreateStream method.

To install your stream factory, simply create an instance of it using 'New'.
End Rem
Type TStreamFactory
	Field _succ:TStreamFactory
	
	Method New()
		_succ=stream_factories
		stream_factories=Self
	End Method

	Rem
	bbdoc: Create a stream based on a url object
	about:
	Types which extends TStreamFactory must implement this method.
	
	@url contains the original url object as supplied to #OpenStream, #ReadStream or 
	#WriteStream.
	
	If @url is a string, @proto contains the url protocol - for example, the "incbin" part
	of "incbin::myfile".
	
	If @url is a string, @path contains the remainder of the url - for example, the "myfile"
	part of "incbin::myfile".
	
	If @url is not a string, both @proto and @path will be Null.
	End Rem
	Method CreateStream:TStream( url:Object,proto$,path$,readable,writeable ) Abstract

End Type

Rem
bbdoc: Open a stream for reading/writing
returns: A stream object
about: All streams created by #OpenStream, #ReadStream or #WriteStream should eventually be
closed using #CloseStream.
End Rem
Function OpenStream:TStream( url:Object,readable=True,writeable=True )

	Local stream:TStream=TStream( url )
	If stream
		Return TStreamStream.Create( stream )
	EndIf

	Local str$=String( url ),proto$,path$
	If str
		Local i=str.Find( "::",0 )
		If i=-1 Return TCStream.OpenFile( str,readable,writeable )
		proto$=str[..i].ToLower()
		path$=str[i+2..]
	EndIf

	Local factory:TStreamFactory=stream_factories
	
	While factory
		Local stream:TStream=factory.CreateStream( url,proto,path,readable,writeable )
		If stream Return stream
		factory=factory._succ
	Wend
End Function

Rem
bbdoc: Open a stream for reading
returns: A stream object
about: All streams created by #OpenStream, #ReadStream or #WriteStream should eventually
be closed using #CloseStream.
End Rem
Function ReadStream:TStream( url:Object )
	Return OpenStream( url,True,False )
End Function

Rem
bbdoc: Open a stream for writing
returns: A stream object
about: All streams created by #OpenStream, #ReadStream or #WriteStream should eventually
be closed using #CloseStream.
End Rem
Function WriteStream:TStream( url:Object )
	Return OpenStream( url,False,True )
End Function

Rem
bbdoc: Get stream end of file status
returns: True If stream is at end of file
End Rem
Function Eof( stream:TStream )
	Return stream.Eof()
End Function

Rem
bbdoc: Get current position of seekable stream
returns: Current stream position, or -1 If stream is not seekable
End Rem
Function StreamPos( stream:TStream )
	Return stream.Pos()
End Function

Rem
bbdoc: Get current size of seekable stream
returns: Current stream size in bytes, or -1 If stream is not seekable
End Rem
Function StreamSize( stream:TStream )
	Return stream.Size()
End Function

Rem
bbdoc: Set stream position of seekable stream
returns: New stream position, or -1 If stream is not seekable
End Rem
Function SeekStream( stream:TStream,pos )
	Return stream.Seek( pos )
End Function

Rem
bbdoc: Flush a stream
about: #FlushStream writes any outstanding buffered data to @stream.
End Rem
Function FlushStream( stream:TStream )
	stream.Flush
End Function

Rem
bbdoc: Close a stream
about: 
All streams should be closed when they are no longer required. 
Closing a stream also flushes the stream before it closes.
End Rem
Function CloseStream( stream:TStream )
	stream.Close
End Function

Rem
bbdoc: Read a Byte from a stream
returns: A Byte value
about: #ReadByte reads a single Byte from @stream.
A TStreamReadException is thrown If there is not enough data available.
End Rem
Function ReadByte( stream:TStream )
	Return stream.ReadByte()
End Function

Rem
bbdoc: Read a Short from a stream
returns: A Short value
about: #ReadShort reads 2 bytes from @stream.
A TStreamReadException is thrown If there is not enough data available.
End Rem
Function ReadShort( stream:TStream )
	Return stream.ReadShort()
End Function

Rem
bbdoc: Read an Int from a stream
returns: An Int value
about: #ReadInt reads 4 bytes from @stream.
A TStreamReadException is thrown If there is not enough data available.
End Rem
Function ReadInt( stream:TStream )
	Return stream.ReadInt()
End Function

Rem
bbdoc: Read a Long from a stream
returns: A Long value
about: #ReadLong reads 8 bytes from @stream.
A TStreamReadException is thrown If there is not enough data available.
End Rem
Function ReadLong:Long( stream:TStream )
	Return stream.ReadLong()
End Function

Rem
bbdoc: Read a Float from a stream
returns: A Float value
about: #ReadFloat reads 4 bytes from @stream.
A TStreamReadException is thrown If there is not enough data available.
End Rem
Function ReadFloat#( stream:TStream )
	Return stream.ReadFloat()
End Function

Rem
bbdoc: Read a Double from a stream
returns: A Double value
about: #ReadDouble reads 8 bytes from @stream.
A TStreamWriteException is thrown If there is not enough data available.
End Rem
Function ReadDouble!( stream:TStream )
	Return stream.ReadDouble()
End Function

Rem
bbdoc: Write a Byte to a stream
about: #WriteByte writes a single Byte to @stream.
A TStreamWriteException is thrown If the Byte could Not be written
End Rem
Function WriteByte( stream:TStream,n )
	stream.WriteByte n
End Function

Rem
bbdoc: Write a Short to a stream
about: #WriteShort writes 2 bytes to @stream.
A TStreamWriteException is thrown if not all bytes could be written
End Rem
Function WriteShort( stream:TStream,n )
	stream.WriteShort n
End Function

Rem
bbdoc: Write an Int to a stream
about: #WriteInt writes 4 bytes to @stream.
A TStreamWriteException is thrown if not all bytes could be written
End Rem
Function WriteInt( stream:TStream,n )
	stream.WriteInt n
End Function

Rem
bbdoc: Write a Long to a stream
about: #WriteLong writes 8 bytes to @stream.
A TStreamWriteException is thrown if not all bytes could be written
End Rem
Function WriteLong( stream:TStream,n:Long )
	stream.WriteLong n
End Function

Rem
bbdoc: Write a Float to a stream
about: #WriteFloat writes 4 bytes to @stream.
A TStreamWriteException is thrown if not all bytes could be written
End Rem
Function WriteFloat( stream:TStream,n# )
	stream.WriteFloat n
End Function

Rem
bbdoc: Write a Double to a stream
about: #WriteDouble writes 8 bytes to @stream.
A TStreamWriteException is thrown if not all bytes could be written
End Rem
Function WriteDouble( stream:TStream,n! )
	stream.WriteDouble n
End Function

Rem
bbdoc: Read a String from a stream
returns: A String of length @length
about:
A #TStreamReadException is thrown if not all bytes could be read.
end rem
Function ReadString$( stream:TStream,length )
	Return stream.ReadString( length )
End Function

Rem
bbdoc: Write a String to a stream
about:
Each character in @str is written to @stream.

A #TStreamWriteException is thrown if not all bytes could be written.
End Rem
Function WriteString( stream:TStream,str$ )
	stream.WriteString str
End Function

Rem
bbdoc: Read a line of text from a stream
returns: A string
about: 
Bytes are read from @stream until a newline character (ascii code 10) or null
character (ascii code 0) is read, or end of file is detected.

Carriage Return characters (ascii code 13) are silently ignored.

The bytes read are returned in the form of a string, excluding any terminating newline
or null character.
End Rem
Function ReadLine$( stream:TStream )
	Return stream.ReadLine()
End Function

Rem
bbdoc: Write a line of text to a stream
returns: True if line successfully written, else False
about:
A sequence of bytes is written to the stream (one for each character in @str)
followed by the line terminating sequence "~r~n".
End Rem
Function WriteLine( stream:TStream,str$ )
	Return stream.WriteLine( str )
End Function

Rem
bbdoc: Load a String from a stream
returns: A String
about:
The specified @url is opened for reading, and each byte in the resultant stream 
(until eof of file is reached) is read into a string.

A #TStreamReadException is thrown if the stream could not be read.
End Rem
Function LoadString$( url:Object )
	Local t:Byte[]=LoadByteArray(url)
	Return String.FromBytes( t,t.length )
End Function

Rem
bbdoc: Save a String to a stream
about:
The specified @url is opened For writing, and each character of @str is written to the
resultant stream.

A #TStreamWriteException is thrown if not all bytes could be written.
End Rem
Function SaveString( str$,url:Object )
	Local stream:TStream=WriteStream( url )
	If Not stream Throw New TStreamWriteException
	Local t:Byte Ptr=str.ToCString()
	stream.WriteBytes t,str.length	'Should be in a try block...or t is leaked!
	MemFree t
	stream.Close
End Function

Function LoadObject:Object( url:Object )
	Local stream:TStream=ReadStream( url )
	If Not stream Throw New TStreamReadException
	Local obj:Object=stream.ReadObject()
	stream.Close
	Return obj
End Function

Function SaveObject( obj:Object,url:Object )
	Local stream:TStream=WriteStream( url )
	If Not stream Throw New TStreamWriteException
	stream.WriteObject obj
	stream.Close
End Function

Rem
bbdoc: Load a Byte array from a stream
returns: A Byte array
about:
The specified @url is opened for reading, and each byte in the resultant stream 
(until eof of reached) is read into a byte array.
End Rem
Function LoadByteArray:Byte[]( url:Object )
	Local stream:TStream=ReadStream( url )
	If Not stream Throw New TStreamReadException
	Local data:Byte[1024],size
	While Not stream.Eof()
		If size=data.length data=data[..size*3/2]
		size:+stream.Read( (Byte Ptr data)+size,data.length-size )
	Wend
	stream.Close
	Return data[..size]
End Function

Rem
bbdoc: Save a Byte array to a stream
about:
The specified @url is opened For writing, and each element of @byteArray is written to the
resultant stream.

A #TStreamWriteException is thrown if not all bytes could be written.
End Rem
Function SaveByteArray( byteArray:Byte[],url:Object )
	Local stream:TStream=WriteStream( url )
	If Not stream Throw New TStreamWriteException
	stream.WriteBytes byteArray,byteArray.length
	stream.Close
End Function

Rem
bbdoc: Copy stream contents to another stream
about: 
#CopyStream copies bytes from @fromStream to @toStream Until @fromStream reaches end
of file.

A #TStreamWriteException is thrown if not all bytes could be written.
End Rem
Function CopyStream( fromStream:TStream,toStream:TStream,bufSize=4096 )
	Assert bufSize>0
	Local buf:Byte[bufSize]
	While Not fromStream.Eof()
		toStream.WriteBytes buf,fromStream.Read( buf,bufSize )
	Wend
End Function

Rem
bbdoc: Copy bytes from one stream to another
about:
#CopyBytes copies @count bytes from @fromStream to @toStream.

A #TStreamReadException is thrown if not all bytes could be read, and a
#TStreamWriteException is thrown if not all bytes could be written.
End Rem
Function CopyBytes( fromStream:TStream,toStream:TStream,count,bufSize=4096 )
	Assert count>=0 And bufSize>0
	Local buf:Byte[bufSize]
	While count
		Local n=Min(count,bufSize)
		fromStream.ReadBytes buf,n
		toStream.WriteBytes buf,n
		count:-n
	Wend
End Function

Rem
bbdoc: Returns a case sensitive filename if it exists from a case insensitive file path.
End Rem
Function CasedFileName$(path$)
	Local	dir,sub$,s$,f$,folder$,p
	Local	mode,size,mtime,ctime
        
	If stat_( path,mode,size,mtime,ctime )=0
		mode:&S_IFMT_
		If mode=S_IFREG_ Or mode=S_IFDIR_ Return path
	EndIf
	folder$="."
	For p=Len(path)-2 To 0 Step -1
		If path[p]=47 Exit
	Next
	If p>0
		sub=path[0..p]
		sub$=CasedFileName(sub$)
		If Not sub$ Return
		path=path$[Len(sub)+1..]
		folder$=sub
	EndIf
	s=path.ToLower()
	dir=opendir_(folder)
	If dir
		While True
			f=readdir_(dir)
			If Not f Exit
			If s=f.ToLower()
				If sub f=sub+"/"+f
				closedir_(dir)
				Return f
			EndIf
		Wend
		closedir_(dir)
	EndIf
End Function
