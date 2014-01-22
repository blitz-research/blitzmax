
Strict

Rem
bbdoc: Miscellaneous/Banks
End Rem
Module BRL.Bank

ModuleInfo "Version: 1.06"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.06 Release"
ModuleInfo "History: Added Lock/Unlock to replace Buf"
ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Fixed Read/Write using ReadBytes/WriteBytes"

Import BRL.Stream

Rem
bbdoc: Memory bank
end rem
Type TBank

	Field _buf:Byte Ptr,_size,_capacity,_locked
	
	Method _pad()
	End Method
	
	Method Delete()
		Assert Not _locked
		If _capacity>=0 MemFree _buf
	End Method

	Rem
	bbdoc: Get a bank's memory pointer
	returns: A byte pointer to the memory block controlled by the bank
	about:
	Please use #Lock and #Unlock instead of this method.
	End Rem
	Method Buf:Byte Ptr()
		Return _buf
	End Method
	
	Rem
	bbdoc: Lock a bank's memory block
	returns: A byte pointer to the memory block controlled by the bank
	about:
	While locked, a bank cannot be resized.

	After you have finished with a bank's memory block, you must use #Unlock
	to return it to the bank.
	End Rem
	Method Lock:Byte Ptr()
		_locked:+1
		Return _buf
	End Method
	
	Rem
	bbdoc: Unlock a bank's memory pointer
	about:
	After you have finished with a bank's memory block, you must use #Unlock
	to return it to the bank.
	End Rem
	Method Unlock()
		_locked:-1
	End Method

	Rem
	bbdoc: Get a bank's size
	returns: The size, in bytes, of the memory block controlled by the bank
	End Rem
	Method Size()
		Return _size
	End Method

	Rem
	bbdoc: Get capacity of bank
	returns: The capacity, in bytes, of the bank's internal memory buffer
	end rem
	Method Capacity()
		Return _capacity
	End Method

	Rem
	bbdoc: Resize a bank
	end rem
	Method Resize( size )
		Assert _locked=0 Else "Locked banks cannot be resize"
		Assert _capacity>=0 Else "Static banks cannot be resized"
		If size>_capacity
			Local n=_capacity*3/2
			If n<size n=size
			Local tmp:Byte Ptr=MemAlloc(n)
			MemCopy tmp,_buf,_size
			MemFree _buf
			_capacity=n
			_buf=tmp
		EndIf
		_size=size
	End Method
	
	Rem
	bbdoc: Read bytes from a stream into a bank
	end rem
	Method Read( stream:TStream,offset,count )
		Assert offset>=0 And offset<=_size-count Else "Illegal bank offset"
		Return stream.Read( _buf+offset,count )
	End Method
	
	Rem
	bbdoc: Write bytes in a bank to a stream
	end rem
	Method Write( stream:TStream,offset,count )
		Assert offset>=0 And offset<=_size-count Else "Illegal bank offset"
		Return stream.Write( _buf+offset,count )
	End Method

	Rem
	bbdoc: Peek a byte from a bank
	returns: The byte value at the specified byte offset within the bank
	end rem
	Method PeekByte( offset )
		Assert offset>=0 And offset<_size Else "Illegal bank offset"
		Return _buf[offset]
	End Method

	Rem
	bbdoc: Poke a byte into a bank
	end rem
	Method PokeByte( offset,value )
		Assert offset>=0 And offset<_size Else "Illegal bank offset"
		_buf[offset]=value
	End Method

	Rem
	bbdoc: Peek a short from a bank
	returns: The short value at the specified byte offset within the bank
	end rem
	Method PeekShort( offset )
		Assert offset>=0 And offset<_size-1 Else "Illegal bank offset"
		Return (Short Ptr(_buf+offset))[0]
	End Method

	Rem
	bbdoc: Poke a short into a bank
	end rem
	Method PokeShort( offset,value )
		Assert offset>=0 And offset<_size-1 Else "Illegal bank offset"
		(Short Ptr(_buf+offset))[0]=value
	End Method

	Rem
	bbdoc: Peek an int from a bank
	returns: The int value at the specified byte offset within the bank
	end rem
	Method PeekInt( offset )
		Assert offset>=0 And offset<_size-3 Else "Illegal bank offset"
		Return (Int Ptr(_buf+offset))[0]
	End Method

	Rem
	bbdoc: Poke an int into a bank
	end rem
	Method PokeInt( offset,value )
		Assert offset>=0 And offset<_size-3 Else "Illegal bank offset"
		(Int Ptr(_buf+offset))[0]=value
	End Method

	Rem
	bbdoc: Peek a long from a bank
	returns: The long value at the specified byte offset within the bank
	end rem
	Method PeekLong:Long( offset )
		Assert offset>=0 And offset<_size-7 Else "Illegal bank offset"
		Return (Long Ptr(_buf+offset))[0]
	End Method

	Rem
	bbdoc: Poke a long value into a bank
	end rem
	Method PokeLong( offset,value:Long )
		Assert offset>=0 And offset<_size-7 Else "Illegal bank offset"
		(Long Ptr(_buf+offset))[0]=value
	End Method
	
	Rem
	bbdoc: Peek a float from a bank
	returns: The float value at the specified byte offset within the bank
	end rem
	Method PeekFloat#( offset )
		Assert offset>=0 And offset<_size-3 Else "Illegal bank offset"
		Return (Float Ptr(_buf+offset))[0]
	End Method

	Rem
	bbdoc: Poke a float value into a bank
	end rem
	Method PokeFloat( offset,value# )
		Assert offset>=0 And offset<_size-3 Else "Illegal bank offset"
		(Float Ptr(_buf+offset))[0]=value
	End Method

	Rem
	bbdoc: Peek a double from a bank
	returns: The double value at the specified byte offset within the bank
	end rem
	Method PeekDouble!( offset )
		Assert offset>=0 And offset<_size-7 Else "Illegal bank offset"
		Return (Double Ptr(_buf+offset))[0]
	End Method

	Rem
	bbdoc: Poke a double value into a bank
	end rem
	Method PokeDouble( offset,value! )
		Assert offset>=0 And offset<_size-7 Else "Illegal bank offset"
		(Double Ptr(_buf+offset))[0]=value
	End Method
	
	Rem
	bbdoc: Save a bank to a stream
	about:
	Return True if successful, otherwise False.
	end rem
	Method Save( url:Object )
		Local stream:TStream=WriteStream( url )
		If Not stream Return
		Local n=stream.WriteBytes( _buf,_size )
		stream.Close
		Return True
	End Method

	Rem
	bbdoc: Load a bank from a stream
	returns: A new TBank object
	about:
	Returns a new TBank object if successfull, otherwise Null.
	end rem
	Function Load:TBank( url:Object )
		Local stream:TStream=ReadStream( url )
		If Not stream Return
		Local data:Byte[]=LoadByteArray( stream )
		Local bank:TBank=Create( data.length )
		MemCopy bank.Buf(),data,data.length 
		stream.Close
		Return bank
	End Function

	Rem
	bbdoc: Create a bank
	returns: A new TBank object with an initial size of @size
	end rem
	Function Create:TBank( size )
		Assert size>=0 Else "Illegal bank size"
		Local bank:TBank=New TBank
		bank._buf=MemAlloc( size )
		bank._size=size
		bank._capacity=size
		Return bank
	End Function
	
	Rem
	bbdoc: Create a bank from an existing block of memory
	end rem
	Function CreateStatic:TBank( buf:Byte Ptr,size )
		Assert size>=0 Else "Illegal bank size"
		Local bank:TBank=New TBank
		bank._buf=buf
		bank._size=size
		bank._capacity=-1
		Return bank
	End Function

End Type

Rem
bbdoc: Create a bank
returns: A bank object with an initial size of @size bytes
about:
#CreateBank creates a Bank allocating a specified amount of memory that
can be used for storage of binary data using the various Poke and
Peek commands. 
End Rem
Function CreateBank:TBank( size=0 )
	Return TBank.Create( size )
End Function

Rem
bbdoc: Create a bank with existing data
returns: A bank object that references an existing block of memory
about:
The memory referenced by a static bank is not released when the bank is deleted.
A static bank cannot be resized.
End Rem
Function CreateStaticBank:TBank( buf:Byte Ptr,size )
	Return TBank.CreateStatic( buf,size )
End Function

Rem
bbdoc: Load a bank
returns: A bank containing the binary contents of @url, or null if @url could not be opened
about:
#LoadBank reads the entire contents of a binary file from a specified @url into a newly
created bank with a size matching that of the file.
end rem
Function LoadBank:TBank( url:Object )
	Return TBank.Load( url )
End Function

Rem
bbdoc: Save a bank
returns: True if successful.
about:
#SaveBank writes it's entire contents to a @url. If the @url is a file path a new
file is created.
end rem
Function SaveBank( bank:TBank,url:Object )
	Return bank.Save( url )
End Function

Rem
bbdoc: Get bank's memory buffer
returns: A byte pointer to the bank's internal memory buffer
about:
Please use #LockBank and #UnlockBank instead of this method.
End Rem
Function BankBuf:Byte Ptr( bank:TBank )
	Return bank.Buf()
End Function

Rem
bbdoc: Lock a bank's memory block
returns: A byte pointer to the memory block controlled by the bank.
about:
While locked, a bank cannot be resized.

After you have finished with a bank's memory block, you must use #UnlockBank
to return it to the bank.
End Rem
Function LockBank:Byte Ptr( bank:TBank )
	Return bank.Lock()
End Function

Rem
bbdoc: Unlock a bank's memory block
about:
After you have finished with a bank's memory block, you must use #UnlockBank
to return it to the bank.
End Rem
Function UnlockBank( bank:TBank )
	bank.Unlock
End Function

Rem
bbdoc: Get size of bank
returns: The size, in bytes, of the bank's internal memory buffer
end rem
Function BankSize( bank:TBank )
	Return bank.Size()
End Function

Rem
bbdoc: Get capacity of bank
returns: The capacity, in bytes, of the bank's internal memory buffer
about:
The capacity of a bank is the size limit before a bank must allocate
more memory due to a resize. Bank capacity may be increased due to a call
to #ResizeBank by either 50% or the requested amount, whichever is greater.
Capacity never decreases.
end rem
Function BankCapacity( bank:TBank )
	Return bank.Capacity()
End Function

Rem
bbdoc: Resize a bank
about:
#ResizeBank modifies the size limit of a bank. This may cause memory to be
allocated if the requested size is greater than the bank's current capacity,
see #BankCapacity for more information.
end rem
Function ResizeBank( bank:TBank,size )
	bank.Resize size
End Function

Rem
bbdoc: Copy bank contents
about:
#CopyBank copies @count bytes from @src_offset in @src_bank to @dst_offset
in @dst_bank.
end rem
Function CopyBank( src_bank:TBank,src_offset,dst_bank:TBank,dst_offset,count )
	Assert..
	count>=0 And..
	src_offset>=0 And..
	dst_offset>=0 And..
	src_offset+count<=src_bank.Size() And..
	dst_offset+count<=dst_bank.size() Else "Illegal range for CopyBank"
	MemCopy( dst_bank.Buf()+dst_offset,src_bank.Buf()+src_offset,count )
End Function

Rem
bbdoc: Peek a byte from a bank
returns: The byte value at the specified byte offset within the bank
about:
A byte is an unsigned 8 bit value with a range of 0..255.
end rem
Function PeekByte( bank:TBank,offset )
	Return bank.PeekByte( offset )
End Function

Rem
bbdoc: Poke a byte into a bank
end rem
Function PokeByte( bank:TBank,offset,value )
	bank.PokeByte offset,value
End Function

Rem
bbdoc: Peek a short from a bank
returns: The short value at the specified byte offset within the bank
about:
A short is an unsigned 16 bit (2 bytes) value with a range of 0..65535.
end rem
Function PeekShort( bank:TBank,offset )
	Return bank.PeekShort( offset )
End Function

Rem
bbdoc: Poke a short into a bank
about:
An short is an unsigned 16 bit value that requires 2 bytes of storage.
end rem
Function PokeShort( bank:TBank,offset,value )
	bank.PokeShort offset,value
End Function

Rem
bbdoc: Peek an int from a bank
returns: The int value at the specified byte offset within the bank
about:
An int is a signed 32 bit value (4 bytes).
end rem
Function PeekInt( bank:TBank,offset )
	Return bank.PeekInt( offset )
End Function

Rem
bbdoc: Poke an int into a bank
about:
An int is a signed 32 bit value that requires 4 bytes of storage.
end rem
Function PokeInt( bank:TBank,offset,value )
	bank.PokeInt offset,value
End Function

Rem
bbdoc: Peek a long integer from a bank
returns: The long integer value at the specified byte offset within the bank
about:
A long is a 64 bit integer that requires 8 bytes of memory.
end rem
Function PeekLong:Long( bank:TBank,offset )
	Return bank.PeekLong( offset )
End Function

Rem
bbdoc: Poke a long integer int into a bank
about:
A long is a 64 bit integer that requires 8 bytes of storage.
end rem
Function PokeLong( bank:TBank,offset,value:Long )
	bank.PokeLong offset,value
End Function

Rem
bbdoc: Peek a float from a bank
returns: The float value at the specified byte offset within the bank
about:
A float requires 4 bytes of storage
end rem
Function PeekFloat#( bank:TBank,offset )
	Return bank.PeekFloat( offset )
End Function

Rem
bbdoc: Poke a float into a bank
about:
A float requires 4 bytes of storage
end rem
Function PokeFloat( bank:TBank,offset,value# )
	bank.PokeFloat offset,value
End Function

Rem
bbdoc: Peek a double from a bank
returns: The double value at the specified byte offset within the bank
about:
A double requires 8 bytes of storage
end rem
Function PeekDouble!( bank:TBank,offset )
	Return bank.PeekDouble( offset )
End Function

Rem
bbdoc: Poke a double into a bank
about:
A double requires 8 bytes of storage
end rem
Function PokeDouble( bank:TBank,offset,value! )
	bank.PokeDouble offset,value
End Function

Rem
bbdoc: Read bytes from a Stream to a Bank
returns: The number of bytes successfully read from the Stream
end rem
Function ReadBank( bank:TBank,stream:TStream,offset,count )
	Return bank.Read( stream,offset,count )
End Function

Rem
bbdoc: Write bytes from a Bank to a Stream
returns: The number of bytes successfully written to the Stream
end rem
Function WriteBank( bank:TBank,stream:TStream,offset,count )
	Return bank.Write( stream,offset,count )
End Function
