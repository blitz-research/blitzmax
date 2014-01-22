
Strict

Rem
bbdoc: Streams/Text streams
about:
The Text Stream module allows you to load and save text in a number
of formats: LATIN1, UTF8 and UTF16.

The LATIN1 format uses a single byte to represent each character, and 
is therefore only capable of manipulating 256 distinct character values.

The UTF8 and UTF16 formats are capable of manipulating up to 1114112
character values, but will generally use greater storage space. In addition,
many text processing applications are unable to handle UTF8 and UTF16 files.
End Rem
Module BRL.TextStream

ModuleInfo "Version: 1.03 "
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.03 Release"
ModuleInfo "History: Modified LoadText to handle stream URLs"
ModuleInfo "History: 1.02 Release"
ModuleInfo "History: Added LoadText, SaveText"
ModuleInfo "History: Fixed UTF16LE=4"
ModuleInfo "History: 1.01 Release"
ModuleInfo "History: 1.00 Release"
ModuleInfo "History: Added TextStream module"

Import BRL.Stream

Type TTextStream Extends TStreamWrapper

	'***** PUBLIC *****

	Const LATIN1=1
	Const UTF8=2
	Const UTF16BE=3
	Const UTF16LE=4

	Method Read( buf:Byte Ptr,count )
		For Local i=0 Until count
			If _bufcount=32 _FlushRead
			Local hi=_ReadByte()
			Local lo=_ReadByte()
			hi:-48;If hi>9 hi:-7
			lo:-48;If lo>9 lo:-7
			buf[i]=hi Shl 4 | lo
			_bufcount:+1
		Next
		Return count
	End Method
	
	Method Write( buf:Byte Ptr,count )
		For Local i=0 Until count
			Local hi=buf[i] Shr 4
			Local lo=buf[i] & $f
			hi:+48;If hi>57 hi:+7
			lo:+48;If lo>57 lo:+7
			_WriteByte hi
			_WriteByte lo
			_bufcount:+1
			If _bufcount=32 _FlushWrite
		Next
		Return count
	End Method
	
	Method ReadByte()
		_FlushRead
		Return Int( ReadLine() )
	End Method
	
	Method WriteByte( n )
		_FlushWrite
		WriteLine n
	End Method
	
	Method ReadShort()
		_FlushRead
		Return Int( ReadLine() )
	End Method
	
	Method WriteShort( n )
		_FlushWrite
		WriteLine n
	End Method
	
	Method ReadInt()
		_FlushRead
		Return Int( ReadLine() )
	End Method
	
	Method WriteInt( n )
		_FlushWrite
		WriteLine n
	End Method
	
	Method ReadLong:Long()
		_FlushRead
		Return Long( ReadLine() )
	End Method
	
	Method WriteLong( n:Long )
		_FlushWrite
		WriteLine n
	End Method
	
	Method ReadFloat:Float()
		_FlushRead
		Return Float( ReadLine() )
	End Method
	
	Method WriteFloat( n:Float )
		_FlushWrite
		WriteLine n
	End Method
	
	Method ReadDouble:Double()
		_FlushRead
		Return Double( ReadLine() )
	End Method
	
	Method WriteDouble( n:Double )
		_FlushWrite
		WriteLine n
	End Method
	
	Method ReadLine$()
		_FlushRead
		Local buf:Short[1024],i
		While Not Eof()
			Local n=ReadChar()
			If n=0 Exit
			If n=10 Exit
			If n=13 Continue
			If buf.length=i buf=buf[..i+1024]
			buf[i]=n
			i:+1
		Wend
		Return String.FromShorts(buf,i)
	End Method
	
	Method ReadFile$()
		_FlushRead
		Local buf:Short[1024],i
		While Not Eof()
			Local n=ReadChar()
			If buf.length=i buf=buf[..i+1024]
			buf[i]=n
			i:+1
		Wend
		Return String.FromShorts( buf,i )
	End Method
	
	Method WriteLine( str$ )
		_FlushWrite
		WriteString str
		WriteString "~r~n"
	End Method
	
	Method ReadString$( length )
		_FlushRead
		Local buf:Short[length]
		For Local i=0 Until length
			buf[i]=ReadChar()
		Next
		Return String.FromShorts(buf,length)
	End Method
	
	Method WriteString( str$ )
		_FlushWrite
		For Local i=0 Until str.length
			WriteChar str[i]
		Next
	End Method
	
	Method ReadChar()
		Local c=_ReadByte()
		Select _encoding
		Case LATIN1
			Return c
		Case UTF8
			If c<128 Return c
			Local d=_ReadByte()
			If c<224 Return (c-192)*64+(d-128)
			Local e=_ReadByte()
			If c<240 Return (c-224)*4096+(d-128)*64+(e-128)
		Case UTF16BE
			Local d=_ReadByte()
			Return c Shl 8 | d
		Case UTF16LE
			Local d=_ReadByte()
			Return d Shl 8 | c
		End Select
	End Method
	
	Method WriteChar( char )
		Assert char>=0 And char<=$ffff
		Select _encoding
		Case LATIN1
			_WriteByte char
		Case UTF8
			If char<128
				_WriteByte char
			Else If char<2048
				_WriteByte char/64 | 192
				_WriteByte char Mod 64 | 128
			Else
				_WriteByte char/4096 | 224
				_WriteByte char/64 Mod 64 | 128
				_WriteByte char Mod 64 | 128
			EndIf
		Case UTF16BE
			_WriteByte char Shr 8
			_WriteByte char
		Case UTF16LE
			_WriteByte char
			_WriteByte char Shr 8
		End Select
	End Method

	Function Create:TTextStream( stream:TStream,encoding )
		Local t:TTextStream=New TTextStream
		t._encoding=encoding
		t.SetStream stream
		Return t
	End Function

	'***** PRIVATE *****
	
	Method _ReadByte()
		Return Super.ReadByte()
	End Method
	
	Method _WriteByte( n )
		Super.WriteByte n
	End Method
	
	Method _FlushRead()
		If Not _bufcount Return
		Local n=_ReadByte()
		If n=13 n=_ReadByte()
		If n<>10 Throw "Malformed line terminator"
		_bufcount=0
	End Method
	
	Method _FlushWrite()
		If Not _bufcount Return
		_WriteByte 13
		_WriteByte 10
		_bufcount=0
	End Method
	
	Field _encoding,_bufcount
	
End Type
	
Type TTextStreamFactory Extends TStreamFactory

	Method CreateStream:TStream( url:Object,proto$,path$,readable,writeable )
		Local encoding
		Select proto$
		Case "latin1"
			encoding=TTextStream.LATIN1
		Case "utf8"
			encoding=TTextStream.UTF8
		Case "utf16be"
			encoding=TTextStream.UTF16BE
		Case "utf16le"
			encoding=TTextStream.UTF16LE
		End Select
		If Not encoding Return
		Local stream:TStream=OpenStream( path,readable,writeable )
		If stream Return TTextStream.Create( stream,encoding )
	End Method
End Type

New TTextStreamFactory

Rem
bbdoc: Load text from a stream
returns: A string containing the text
about:
#LoadText loads LATIN1, UTF8 or UTF16 text from @url.

The first bytes read from the stream control the format of the text:
[ &$fe $ff | Text is big endian UTF16
* &$ff $fe | Text is little endian UTF16
* &$ef $bb $bf | Text is UTF8
]

If the first bytes don't match any of the above values, the stream
is assumed to contain LATIN1 text.

A #TStreamReadException is thrown if not all bytes could be read.
End Rem
Function LoadText$( url:Object )

	Local stream:TStream=ReadStream( url )
	If Not stream Throw New TStreamReadException

	Local format,size,c,d,e

	If Not stream.Eof()
		c=stream.ReadByte()
		size:+1
		If Not stream.Eof()
			d=stream.ReadByte()
			size:+1
			If c=$fe And d=$ff
				format=TTextStream.UTF16BE
			Else If c=$ff And d=$fe
				format=TTextStream.UTF16LE
			Else If c=$ef And d=$bb
				If Not stream.Eof()
					e=stream.ReadByte()
					size:+1
					If e=$bf format=TTextStream.UTF8
				EndIf
			EndIf
		EndIf
	EndIf

	If Not format
		Local data:Byte[1024]
		data[0]=c;data[1]=d;data[2]=e
		While Not stream.Eof()
			If size=data.length data=data[..size*2]
			size:+stream.Read( (Byte Ptr data)+size,data.length-size )
		Wend
		stream.Close
		Return String.FromBytes( data,size )
	EndIf
	
	Local TStream:TTextStream=TTextStream.Create( stream,format )
	Local str$=TStream.ReadFile()
	TStream.Close
	stream.Close
	Return str

End Function

Rem
bbdoc: Save text to a stream
about:
#SaveText saves the characters in @str to @url.

If @str contains any characters with a character code greater than 255,
then @str is saved in UTF16 format. Otherwise, @str is saved in LATIN1 format.

A #TStreamWriteException is thrown if not all bytes could be written.
End Rem
Function SaveText( str$,url:Object )

	Local format
	For Local i=0 Until str.length
		If str[i]>255
?BigEndian
			format=TTextStream.UTF16BE
?LittleEndian
			format=TTextStream.UTF16LE
?
			Exit
		EndIf
	Next
	
	If Not format
		SaveString str,url
		Return True
	EndIf

	Local stream:TStream=WriteStream( url )
	If Not stream Throw New TStreamWriteException
	
	Select format
	Case TTextStream.UTF8
		stream.WriteByte $ef
		stream.WriteByte $bb
	Case TTextStream.UTF16BE
		stream.WriteByte $fe
		stream.WriteByte $ff
	Case TTextStream.UTF16LE
		stream.WriteByte $ff
		stream.WriteByte $fe
	End Select
	
	Local TStream:TTextStream=TTextStream.Create( stream,format )
	TStream.WriteString str
	TStream.Close
	stream.Close
	Return True

End Function

