Strict

Import BRL.Stream
Import BRL.EndianStream

Type PNGHeader

	Field signiture:String
	Field chunksize:Int
	Field chunkID:String
	Field width:Int
	Field height:Int
	Global PNG_ID:String = Chr($89) + Chr($50) + Chr($4E) + Chr($47) + Chr($0D) + Chr($0A) + Chr($1A) + Chr($0A)

	Function fromFile:PNGHeader( url:Object )
		Local myStream:TStream = ReadStream( url )
		Local temp:PNGHeader
		If StreamSize (myStream) > 24
			temp = New PNGHeader
			Local eStream:TStream = BigEndianStream(myStream)
			temp.signiture = ReadString (eStream , 8)
			temp.chunksize = Readint (eStream)
			temp.chunkID = ReadString (eStream , 4)
			temp.width = Readint (eStream)
			temp.height = Readint (eStream)
			CloseStream eStream
		EndIf
		CloseStream myStream
		Return temp
	EndFunction	

	Function fromPtr:PNGHeader( Pointer:Byte Ptr )
		Local temp:PNGHeader = New PNGHeader
		temp.signiture = Chr(Pointer[0]) + Chr(Pointer[1]) + Chr(Pointer[2]) + Chr(Pointer[3]) + Chr(Pointer[4]) + Chr(Pointer[5]) + Chr(Pointer[6]) + Chr(Pointer[7])
		temp.chunksize = Pointer[8] Shl 24 | Pointer[9] Shl 16 | Pointer[10] Shl 8 | Pointer[11]
		temp.chunkID = Chr(Pointer[12]) + Chr(Pointer[13]) + Chr(Pointer[14]) + Chr(Pointer[15])
		temp.width = Pointer[16] Shl 24 | Pointer[17] Shl 16 | Pointer[18] Shl 8 | Pointer[19]
		temp.height = Pointer[20] Shl 24 | Pointer[21] Shl 16 | Pointer[22] Shl 8 | Pointer[23]
		Return temp
	EndFunction

	Method isPNG:Int()
		If signiture = PNG_ID
			Return True
		EndIf
		Return False
	EndMethod
	
	Method toString:String()
		Local temp:String = "isPng: "
		If isPNG()
			temp:+"True "
		Else
			temp:+"False "
		EndIf
		temp:+"Width: " + width + " Height: " + height
		
		Return temp
	EndMethod
EndType 