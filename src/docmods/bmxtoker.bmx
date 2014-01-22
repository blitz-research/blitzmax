Strict

Import BRL.Map
Import BRL.Stream

Private

Function ReadTextStream:TStream( url:Object )

	Local format,size,c,d,e
	Local stream:TStream=ReadStream( url )
	If Not stream Return

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

	If format Return TTextStream.Create( stream,format )
	
	stream.Close
	
	Return ReadStream( url )

End Function

Public

Function TPrint( t$ )
	Local p
	For Local i=0 Until t.length
		If t[i]<256 Continue
		'unicode char!
		StandardIOStream.WriteString t[p..i]
		StandardIOStream.WriteString "&#"+t[i]+";"
		p=i+1
	Next
	Print t[p..]
End Function

'----- Simple BMX Parser -----

Const T_EOF=		-1
Const T_EOL=		10

Const T_IDENT=		$10001
Const T_INTLIT=		$10002
Const T_FLOATLIT=	$10003
Const T_STRINGLIT=	$10004
Const T_STRINGERR=	$10005

Const T_REM=		$20001
Const T_ENDREM=		$20002
Const T_FUNCTION=	$20003
Const T_ENDFUNCTION=$20004
Const T_TYPE=		$20005
Const T_ENDTYPE=	$20006
Const T_CONST=		$20007
Const T_METHOD=		$20008
Const T_ENDMETHOD=	$20009
Const T_GLOBAL=		$2000a
Const T_INCLUDE=		$2000b ' Added by BaH - 01/06/2006
Const T_IMPORT=		$2000d
Const T_FIELD=		$2000e
Const T_EXTENDS=	$2000f
Const T_ABSTRACT=	$20010
Const T_FINAL=		$20011
Const T_MODULE=		$2000c
Const T_MODULEINFO=	$20012

Const T_DOTDOT=		$30001
Const T_ARRAYDECL=	$30002

Const T_KEYWORD=	$40000

Type TIntValue
	Field value:Int
End Type

Function IntValue:TIntValue( value )
	Local t:TIntValue=New TIntValue
	t.value=value
	Return t
End Function

Function IsSpace( char )
	Return char<=Asc(" ") And char<>Asc("~n")
End Function

Function IsAlpha( char )
	Return ( char>=Asc("a") And char<=Asc("z") ) Or ( char>=Asc("A") And char<=Asc("Z") )
End Function

Function IsNumeric( char )
	Return char>=Asc("0") And char<=Asc("9")
End Function

Function IsAlphaNumeric( char )
	Return IsAlpha( char ) Or IsNumeric( char )
End Function

Type TBmxToker

	Field _filename:String ' Added by BaH - 25/05/2006

	Field _spc
	Field _pos,_line$
	Field _toke,_text$
	Field _stream:TStream
	
	Global _keywords:TMap
	
	Method Delete()
		Close
	End Method

	Method Bump()
	
		If _toke=T_EOF Return _toke
	
		If _pos>=_line.length
			_pos=0
			If _stream.Eof()
				_toke=T_EOF
				_text=""
				Return
			EndIf
			_line=_stream.ReadLine().Trim()+"~n"
		EndIf
		
		Local from=_pos
		While _pos<_line.length And IsSpace( _line[_pos] )
			_pos:+1
		Wend
		
		If _spc And _pos<>from
			_text=_line[from.._pos]
			_toke=Asc(" ")
			Return _toke
		EndIf
		
		from=_pos
		Local char=_line[_pos]
		_pos:+1
		
		If char=Asc("'")
			_pos=_line.length
			_toke=T_EOL
		Else If char=Asc("~n")
			_toke=T_EOL
		Else If isAlpha(char) Or char=Asc("_")
			While IsAlphaNumeric(_line[_pos]) Or _line[_pos]=Asc("_")
				_pos:+1
			Wend
			_toke=T_IDENT
			Local id$=_line[from.._pos].ToLower()
			If id="end" And _line[_pos]=Asc(" ") And IsAlpha(_line[_pos+1])
				Local t_pos=_pos+2
				While IsAlphaNumeric(_line[t_pos]) Or _line[t_pos]=Asc("_")
					t_pos:+1
				Wend
				Local id$="end"+_line[_pos+1..t_pos].ToLower()
				Local v:TIntValue=TIntValue( _keywords.ValueForKey( id ) )
				If v
					_pos=t_pos
					_toke=v.value
				EndIf
			EndIf
			If _toke=T_IDENT
				Local v:TIntValue=TIntValue( _keywords.ValueForKey( id ) )
				If v _toke=v.value
				If _toke=T_REM
					_text=""
					Repeat
						If _stream.Eof()
							_pos=0
							_line=""
							Return _toke
						EndIf
						_line=_stream.ReadLine().Trim()+"~n"
						If _line[..6].ToLower()="endrem" Or _line[..7].ToLower()="end rem" Exit
						_text:+_line
					Forever
					_pos=_line.length
					Return _toke
				Else
					' Complete lines if they continue onto other lines - BaH 03/09/2006
					If _toke = T_FUNCTION Or _toke = T_METHOD Or _toke = T_CONST Or _toke = T_GLOBAL Or _toke = T_FIELD Then
						If _line.find("..") >= 0 Then
							_line = getFullLine()
						End If
					End If
				EndIf
			EndIf
		Else If IsNumeric(char)
			While IsNumeric(_line[_pos])
				_pos:+1
			Wend
			_toke=T_INTLIT
			If _line[_pos]=Asc(".")
				_pos:+1
				While IsNumeric(_line[_pos])
					_pos:+1
				Wend
				_toke=T_FLOATLIT
			EndIf
		Else If char=Asc("~q")
			While _line[_pos]<>Asc("~q") And _line[_pos]<>Asc("~n")
				_pos:+1
			Wend
			If _line[_pos]=Asc("~q")
				_pos:+1
				_toke=T_STRINGLIT
			Else
				_toke=T_STRINGERR
			EndIf
		Else
			_toke=char
		EndIf
		
		_text=_line[from.._pos]
		
		Return _toke
		
	End Method
	
	' Completes a line that takes up more than one actual line - BaH 03/09/2006
	Method getFullLine:String()
		Local first:Int = True
		Local fullline:String
		Local line:String = _line
		Local pos:Int = 0
		Local from:Int
		
		#loop
		Repeat
		
			If Not first Then
				If _stream.Eof()
					pos=0
					line=""
					Return line
				EndIf
				line = _stream.ReadLine().Trim()+"~n"
			End If
			
			first = False

			If line.tolower().Trim() = "rem" Then
				Repeat
					If _stream.Eof()
						pos=0
						line=""
						Return fullline
					EndIf
					line = _stream.ReadLine().Trim()+"~n"
					If line[..6].ToLower()="endrem" Or line[..7].ToLower()="end rem" Then
						Continue loop
					End If
				Forever
			End If

			pos = 0
			from = pos
			While pos < line.length And IsSpace( line[pos] )
				pos:+1
			Wend
			
			from = pos

			Local char:Int = line[pos]
			pos:+1
			While char <> Asc("~n")

				If char = Asc(".") And line[pos] = Asc(".") Then
					fullline:+ line[from..pos-1]
					Exit
				End If
				
				If char = Asc("'") Then
					Exit
				End If
				
				char=line[pos]
				pos:+1 
			Wend
			
			If char = Asc("~n") Then
				fullline :+ line[from..pos-1]
				Exit
			End If

		Forever

		Return fullline
	End Method
	
	Method Curr()
		Return _toke
	End Method
	
	Method Text$()
		Return _text
	End Method
	
	Method Line$()
		Return _line
	End Method
	
	Method Parse$( toke )
		If Curr()<>toke Throw "Unexpected token"
		Local t$=Text()
		Bump
		Return t
	End Method
	
	Method CParse$( toke )
		If Curr()<>toke Return
		Local t$=Text()
		Bump
		Return t
	End Method
	
	Method ParseUntil$( toke )
		Local t$
		While Curr()<>toke
			If Curr()=T_EOF Throw "Unexpected EOF"
			t:+Text()
			Bump
		Wend
		Bump
		Return t
	End Method
	
	Method Spaces( enable )
		If enable
			_spc:+1
		Else
			_spc:-1
		EndIf
	End Method
	
	Method Close()
		If _stream _stream.Close
		_stream=Null
	End Method
	
	Function CreateKeywords()
		If _keywords Return
		Function kw( id$,toke )
			_keywords.insert id,IntValue(toke)
		End Function
		_keywords=New TMap
		kw "rem",T_REM
		kw "endrem",T_ENDREM
		kw "function",T_FUNCTION
		kw "endfunction",T_ENDFUNCTION
		kw "method",T_METHOD
		kw "endmethod",T_ENDMETHOD
		kw "const",T_CONST
		kw "global",T_GLOBAL
		kw "include",T_INCLUDE ' Added by BaH - 01/06/2006
		kw "import",T_IMPORT
		kw "field",T_FIELD
		kw "type",T_TYPE
		kw "endtype",T_ENDTYPE
		kw "extends",T_EXTENDS
		kw "abstract",T_ABSTRACT
		kw "final",T_FINAL
		kw "module",T_MODULE
		kw "moduleinfo",T_MODULEINFO
	End Function	
	
	Function Create:TBmxToker( url:Object )
		CreateKeywords
		Local stream:TStream=ReadTextStream( url )
		If Not stream Throw "Unable to read stream: "+url.ToString()
		Local t:TBmxToker=New TBmxToker
		t._filename = url.ToString() ' Added by BaH - 25/05/2006
		t._stream=stream
		t.Bump
		Return t
	End Function

End Type
