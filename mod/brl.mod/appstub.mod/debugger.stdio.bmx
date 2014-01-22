
Strict

NoDebug

Private

?Win32
Extern "Win32"
Const SW_SHOW=5
Const SW_RESTORE=9
Function IsIconic( hwnd )
Function GetForegroundWindow()
Function SetForegroundWindow( hwnd )
Function ShowWindow( hwnd,cmdShow )
Function GetCurrentThreadId()
End Extern
?

?MacOS
Extern
Function CGDisplayIsCaptured( displayId )
End Extern
?

Extern
Global bbStringClass:Byte
Global bbArrayClass:Byte
Global bbNullObject:Byte
Global bbEmptyArray:Byte
Global bbEmptyString:Byte
Global brl_blitz_NullFunctionError:Byte Ptr
Function bbIsMainThread()="bbIsMainThread"
Function bbGCValidate:Int( mem:Int ) = "bbGCValidate"
End Extern

Function ToHex$( val )
	Local buf:Short[8]
	For Local k=7 To 0 Step -1
		Local n=(val&15)+Asc("0")
		If n>Asc("9") n=n+(Asc("A")-Asc("9")-1)
		buf[k]=n
		val:Shr 4
	Next
	Return String.FromShorts( buf,8 ).ToLower()
End Function

Function IsAlpha( ch )
	Return (ch>=Asc("a") And ch<=Asc("z")) Or (ch>=Asc("A") And ch<=Asc("Z"))
End Function

Function IsNumeric( ch )
	Return ch>=Asc("0") And ch<=Asc("9")
End Function

Function IsAlphaNumeric( ch )
	Return IsAlpha(ch) Or IsNumeric(ch)
End Function

Function IsUnderscore( ch )
	Return ch=Asc("_")
End Function

Function Ident$( tag$ Var )
	If Not tag Return ""
	If Not IsAlpha( tag[0] ) And Not IsUnderscore( tag[0] ) Return ""
	Local i=1
	While i<tag.length And (IsAlphaNumeric(tag[i]) Or IsUnderscore(tag[i]))
		i:+1
	Wend
	Local id$=tag[..i]
	tag=tag[i..]
	Return id
End Function

Function TypeName$( tag$ Var )

	Local t$=tag[..1]
	tag=tag[1..]

	Select t
	Case "b"
		Return "Byte"
	Case "s"
		Return "Short"
	Case "i"
		Return "Int"
	Case "l"
		Return "Long"
	Case "f"
		Return "Float"
	Case "d"
		Return "Double"
	Case "$"
		Return "String"
	Case "z"
		Return "CString"
	Case "w"
		Return "WString"
	Case ":","?"
		Local id$=Ident( tag )
		While tag And tag[0]=Asc(".")
			tag=tag[1..]
			id=Ident( tag )
		Wend
		If Not id DebugError "Invalid object typetag"
		Return id
	Case "*"
		Return TypeName( tag )+" Ptr"
	Case "["
		While tag[..1]=","
			tag=tag[1..]
			t:+","
		Wend
		If tag[..1]<>"]" DebugError "Invalid array typetag"
		tag=tag[1..]
		Return TypeName( tag )+t+"]"
	Case "("
		If tag[..1]<>")"
			t:+TypeName( tag )
			While tag[..1]=","
				tag=tag[1..]
				t:+","+TypeName( tag )
			Wend
			If tag[..1]<>")" DebugError "Invalid function typetag"
		EndIf
		tag=tag[1..]
		Return TypeName( tag )+t+")"
	End Select

	DebugError "Invalid debug typetag:"+t

End Function

'int offsets into 12 byte DebugStm struct
Const DEBUGSTM_FILE=0
Const DEBUGSTM_LINE=1
Const DEBUGSTM_CHAR=2

'int offsets into 16 byte DebugDecl struct
Const DEBUGDECL_KIND=0
Const DEBUGDECL_NAME=1
Const DEBUGDECL_TYPE=2
Const DEBUGDECL_ADDR=3

'DEBUGDECL_KIND values
Const DEBUGDECLKIND_END=0
Const DEBUGDECLKIND_CONST=1
Const DEBUGDECLKIND_LOCAL=2
Const DEBUGDECLKIND_FIELD=3
Const DEBUGDECLKIND_GLOBAL=4
Const DEBUGDECLKIND_VARPARAM=5
Const DEBUGDECLKIND_TYPEMETHOD=6
Const DEBUGDECLKIND_TYPEFUNCTION=7

'int offsets into 12+n_decls*4 byte DebugScope struct
Const DEBUGSCOPE_KIND=0
Const DEBUGSCOPE_NAME=1
Const DEBUGSCOPE_DECLS=2

'DEBUGSCOPE_KIND values
Const DEBUGSCOPEKIND_FUNCTION=1
Const DEBUGSCOPEKIND_TYPE=2
Const DEBUGSCOPEKIND_LOCAL=3

Function DebugError( t$ )
	WriteStderr "Debugger Error:"+t+"~n"
	End
End Function

Function DebugStmFile$( stm:Int Ptr )
	Return String.FromCString( Byte Ptr stm[DEBUGSTM_FILE] )
End Function

Function DebugStmLine( stm:Int Ptr )
	Return stm[DEBUGSTM_LINE]
End Function

Function DebugStmChar( stm:Int Ptr )
	Return stm[DEBUGSTM_CHAR]
End Function

Function DebugDeclKind$( decl:Int Ptr )
	Select decl[DEBUGDECL_KIND]
	Case DEBUGDECLKIND_CONST Return "Const"
	Case DEBUGDECLKIND_LOCAL Return "Local"
	Case DEBUGDECLKIND_FIELD Return "Field"
	Case DEBUGDECLKIND_GLOBAL Return "Global"
	Case DEBUGDECLKIND_VARPARAM Return "Local"
	End Select
	DebugError "Invalid decl kind"
End Function

Function DebugDeclName$( decl:Int Ptr )
	Return String.FromCString( Byte Ptr decl[DEBUGDECL_NAME] )
End Function

Function DebugDeclType$( decl:Int Ptr )
	Local t$=String.FromCString( Byte Ptr decl[DEBUGDECL_TYPE] )
	Local ty$=TypeName( t )
	Return ty
End Function

Function DebugDeclSize( decl:Int Ptr )

	Local tag=(Byte Ptr Ptr(decl+DEBUGDECL_TYPE))[0][0]

	Select tag
	Case Asc("b") Return 1
	Case Asc("s") Return 2
	Case Asc("l") Return 8
	Case Asc("d") Return 8
	End Select
	
	Return 4

End Function

Function DebugEscapeString$( s$ )
	s=s.Replace( "~~","~~~~")
	s=s.Replace( "~0","~~0" )
	s=s.Replace( "~t","~~t" )
	s=s.Replace( "~n","~~n" )
	s=s.Replace( "~r","~~r" )
	s=s.Replace( "~q","~~q" )
	Return "~q"+s+"~q"
End Function

Function DebugDeclValue$( decl:Int Ptr,inst:Byte Ptr )
	If decl[DEBUGDECL_KIND]=DEBUGDECLKIND_CONST
		Local p:Byte Ptr=Byte Ptr decl[DEBUGDECL_ADDR]
		Return DebugEscapeString(String.FromShorts( Short Ptr(p+12),(Int Ptr (p+8))[0] ))
	EndIf

	Local p:Byte Ptr
	Select decl[DEBUGDECL_KIND]
	Case DEBUGDECLKIND_GLOBAL
		p=Byte Ptr decl[DEBUGDECL_ADDR]
	Case DEBUGDECLKIND_LOCAL,DEBUGDECLKIND_FIELD
		p=Byte Ptr (inst+decl[DEBUGDECL_ADDR])
	Case DEBUGDECLKIND_VARPARAM
		p=Byte Ptr (inst+decl[DEBUGDECL_ADDR])
		p=Byte Ptr ( (Int Ptr p)[0] )
	Default
		DebugError "Invalid decl kind"
	End Select
	
	Local tag=(Byte Ptr Ptr(decl+DEBUGDECL_TYPE))[0][0]
	
	Select tag
	Case Asc("b")
		Return String.FromInt( (Byte Ptr p)[0] )
	Case Asc("s")
		Return String.FromInt( (Short Ptr p)[0] )
	Case Asc("i")
		Return String.FromInt( (Int Ptr p)[0] )
	Case Asc("l")
		Return String.FromLong( (Long Ptr p)[0] )
	Case Asc("f")
		Return String.FromFloat( (Float Ptr p)[0] )
	Case Asc("d")
		Return String.FromDouble( (Double Ptr p)[0] )
	Case Asc("$")
		p=(Byte Ptr Ptr p)[0]
		Local sz=Int Ptr(p+8)[0]
		Local s$=String.FromShorts( Short Ptr(p+12),sz )
		Return DebugEscapeString( s )
	Case Asc("z")
		p=(Byte Ptr Ptr p)[0]
		If Not p Return "Null"
		Local s$=String.FromCString( p )
		Return DebugEscapeString( s )
	Case Asc("w")
		p=(Byte Ptr Ptr p)[0]
		If Not p Return "Null"
		Local s$=String.FromWString( Short Ptr p )
		Return DebugEscapeString( s )
	Case Asc("*"),Asc("?")
		Return "$"+ToHex( (Int Ptr p)[0] )
	Case Asc("(")
		p=(Byte Ptr Ptr p)[0]
		If p=brl_blitz_NullFunctionError Return "Null"
	Case Asc(":")
		p=(Byte Ptr Ptr p)[0]
		If p=Varptr bbNullObject Return "Null"
		If p=Varptr bbEmptyArray Return "Null[]"
		If p=Varptr bbEmptyString Return "Null$"
	Case Asc("[")
		p=(Byte Ptr Ptr p)[0]
		If Not p Return "Null"
		If Not (Int Ptr (p+20))[0] Return "Null"
	Default
		DebugError "Invalid decl typetag:"+Chr(tag)
	End Select
	
	Return "$"+ToHex( Int p )

End Function

Function DebugScopeKind$( scope:Int Ptr )
	Select scope[DEBUGSCOPE_KIND]
	Case DEBUGSCOPEKIND_FUNCTION Return "Function"
	Case DEBUGSCOPEKIND_TYPE Return "Type"
	Case DEBUGSCOPEKIND_LOCAL Return "Local"
	End Select
	DebugError "Invalid scope kind"
End Function

Function DebugScopeName$( scope:Int Ptr )
	Return String.FromCString( Byte Ptr scope[DEBUGSCOPE_NAME] )
End Function

Function DebugScopeDecls:Int Ptr[]( scope:Int Ptr )
	Local n,p:Int Ptr=scope+DEBUGSCOPE_DECLS
	While p[n]<>DEBUGDECLKIND_END
		n:+1
	Wend
	Local decls:Int Ptr[n]
	For Local i=0 Until n
		decls[i]=p+i*4
	Next
	Return decls
End Function

Function DebugObjectScope:Int Ptr( inst:Byte Ptr )
	Local clas:Int Ptr Ptr=(Int Ptr Ptr Ptr inst)[0]
	Return clas[2]
End Function

Extern
Global bbOnDebugStop()
Global bbOnDebugLog( message$ )
Global bbOnDebugEnterStm( stm:Int Ptr )
Global bbOnDebugEnterScope( scope:Int Ptr,inst:Byte Ptr )
Global bbOnDebugLeaveScope()
Global bbOnDebugPushExState()
Global bbOnDebugPopExState()
Global bbOnDebugUnhandledEx( ex:Object )
End Extern

bbOnDebugStop=OnDebugStop
bbOnDebugLog=OnDebugLog
bbOnDebugEnterStm=OnDebugEnterStm
bbOnDebugEnterScope=OnDebugEnterScope
bbOnDebugLeaveScope=OnDebugLeaveScope
bbOnDebugPushExState=OnDebugPushExState
bbOnDebugPopExState=OnDebugPopExState
bbOnDebugUnhandledEx=OnDebugUnhandledEx

?Win32
Global _ideHwnd=GetForegroundWindow();
Global _appHwnd
?

'********** Debugger code here **********

Const MODE_RUN=0
Const MODE_STEP=1
Const MODE_STEPIN=2
Const MODE_STEPOUT=3

Type TScope
	Field scope:Int Ptr,inst:Byte Ptr,stm:Int Ptr
End Type

Type TExState
	Field scopeStackTop
End Type

Global mode,debugLevel,funcLevel
Global currentScope:TScope=New TScope
Global scopeStack:TScope[],scopeStackTop
Global exStateStack:TExState[],exStateStackTop

Function ReadDebug$()
	Return ReadStdin()
End Function

Function WriteDebug( t$ )
	WriteStderr "~~>"+t
End Function

Function DumpScope( scope:Int Ptr,inst:Byte Ptr )

	Local decl:Int Ptr=scope+DEBUGSCOPE_DECLS
	
	Local kind$=DebugScopeKind( scope ),name$=DebugScopeName( scope )
	
	If Not name name="<local>"
	
	WriteDebug kind+" "+name+"~n"
	
	While decl[DEBUGDECL_KIND]<>DEBUGDECLKIND_END
	
		Select decl[DEBUGDECL_KIND]
		Case DEBUGDECLKIND_TYPEMETHOD,DEBUGDECLKIND_TYPEFUNCTION
			decl:+4
			Continue
		End Select

		Local kind$=DebugDeclKind( decl )
		Local name$=DebugDeclname( decl )
		Local tipe$=DebugDeclType( decl )
		Local value$=DebugDeclValue( decl,inst )
		
		WriteDebug kind+" "+name+":"+tipe+"="+value+"~n"

		decl:+4	
	Wend
End Function

Function DumpClassScope( clas:Int Ptr,inst:Byte Ptr )

	Local supa:Int Ptr=Int Ptr clas[0]
	
	If Not supa Return
	
	DumpClassScope supa,inst
	
	DumpScope Int Ptr clas[2],inst

End Function

Function DumpObject( inst:Byte Ptr,index )

	Local clas:Int Ptr=(Int Ptr Ptr inst)[0]
	
	If clas=Int Ptr Varptr bbStringClass

		WriteDebug DebugEscapeString(String.FromShorts( Short Ptr(inst+12),(Int Ptr (inst+8))[0] ))+"~n"

		Return

	Else If clas=Int Ptr Varptr bbArrayClass
	
		Local length=(Int Ptr (inst+20))[0]
		
		If Not length Return
		
		Local decl:Int[3]
		decl[0]=DEBUGDECLKIND_LOCAL
		decl[2]=(Int Ptr (inst+8))[0]
		
		Local sz=DebugDeclSize( decl )
		
		Local p:Byte Ptr=Byte Ptr(20+(Int Ptr (inst+12))[0]*4)

		For Local i=1 To 10

			If index>=length Exit
			
			decl[3]=Int(p+index*sz)
		
			Local value$=DebugDeclValue( decl,inst )
			
			WriteDebug "["+index+"]="+value+"~n"
			
			index:+1
			
		Next
		
		If index<length

			WriteDebug "...=$"+ToHex(Int inst)+":"+index+"~n"
	
		EndIf
		
	Else
			
		If Not clas[0]
			WriteDebug "Object~n"
			Return
		EndIf
	
		DumpClassScope clas,inst
	
	EndIf
	
End Function

Function DumpScopeStack()
	For Local i=Max(scopeStackTop-100,0) Until scopeStackTop
		Local t:TScope=scopeStack[i]
		Local stm:Int Ptr=t.stm
		If Not stm Continue
		WriteDebug "@"+DebugStmFile(stm)+"<"+DebugStmLine(stm)+","+DebugStmChar(stm)+">~n"
		DumpScope t.scope,t.inst
	Next
End Function

Function UpdateDebug( msg$ )
	Global indebug
	If indebug Return
	indebug=True
	
?Win32
	_appHwnd=GetForegroundWindow();
	'SetForegroundWindow( _ideHwnd );
?
?MacOs
	'fullscreen debug too hard in MacOS!
	If CGDisplayIsCaptured( 0 )
		WriteStdout msg
		End
	EndIf
?
	WriteDebug msg
	Repeat
		WriteDebug "~n"
		Local line$=ReadDebug()

		Select line[..1].ToLower()
		Case "r"
			mode=MODE_RUN
			Exit
		Case "s"
			mode=MODE_STEP
			debugLevel=funcLevel
			Exit
		Case "e"
			mode=MODE_STEPIN
			Exit
		Case "l"
			mode=MODE_STEPOUT
			debugLevel=scopeStackTop-1
			Exit
		Case "t"
			WriteDebug "StackTrace{~n"
			DumpScopeStack
			WriteDebug "}~n"
		Case "d"
			Local t$=line[1..].Trim()
			Local index
			Local i=t.Find(":")
			If i<>-1
				index=Int( t[i+1..] )
				t=t[..i]
			EndIf
			If t[..1]="$" t=t[1..].Trim()
			If t[..2].ToLower()="0x" t=t[2..].Trim()
			Local pointer = Int( "$"+t )
			If Not (pointer And bbGCValidate(pointer)) Then Continue
			Local inst:Int Ptr=Int Ptr pointer
			
			Local cmd$="ObjectDump@"+ToHex( Int inst )
			If i<>-1 cmd:+":"+index
			WriteDebug cmd$+"{~n"

			DumpObject inst,index
			WriteDebug "}~n"
		Case "h"
			WriteDebug "T - Stack trace~n"
			WriteDebug "R - Run from here~n"
			WriteDebug "S - Step through source code~n"
			WriteDebug "E - Step into function call~n"
			WriteDebug "L - Leave function or local block~n"
			WriteDebug "Q - Quit~n"
			WriteDebug "H - This text~n"
			WriteDebug "Dxxxxxxxx - Dump object at hex address xxxxxxxx~n"
		Case "q"
			End
		End Select
	Forever

?Win32
	If _appHwnd And _appHwnd<>_ideHwnd 
		If IsIconic(_apphwnd)
			ShowWindow _appHwnd,SW_RESTORE
		Else
			ShowWindow _appHwnd,SW_SHOW
		EndIf		
		_apphwnd=0
	EndIf
?
	indebug=False
End Function

Function OnDebugStop()
?Threaded
	If Not bbIsMainThread() Return
?
	UpdateDebug "DebugStop:~n"
End Function

Function OnDebugLog( message$ )
?Threaded
	If Not bbIsMainThread() Return
?
	WriteStdout "DebugLog:"+message+"~n"
End Function

Function OnDebugEnterStm( stm:Int Ptr )
?Threaded
	If Not bbIsMainThread() Return
?
	currentScope.stm=stm
	
	Select mode
	Case MODE_RUN
		Return
	Case MODE_STEP
		If funcLevel>debugLevel 
			Return
		EndIf
	Case MODE_STEPOUT
		If scopeStackTop>debugLevel
			Return
		EndIf
	End Select
	
	UpdateDebug "Debug:~n"
End Function

Function OnDebugEnterScope( scope:Int Ptr,inst:Byte Ptr )
?Threaded
	If Not bbIsMainThread() Return
?
	GCSuspend

	If scopeStackTop=scopeStack.length 
		scopeStack=scopeStack[..scopeStackTop * 2 + 32]
		For Local i=scopeStackTop Until scopeStack.length
			scopeStack[i]=New TScope
		Next
	EndIf
	
	currentScope=scopeStack[scopeStackTop]

	currentScope.scope=scope
	currentScope.inst=inst

	scopeStackTop:+1

	If currentScope.scope[DEBUGSCOPE_KIND]=DEBUGSCOPEKIND_FUNCTION funcLevel:+1

	GCResume	
End Function

Function OnDebugLeaveScope()
?Threaded
	If Not bbIsMainThread() Return
?
	GCSuspend

	If Not scopeStackTop DebugError "scope stack underflow"

	If currentScope.scope[DEBUGSCOPE_KIND]=DEBUGSCOPEKIND_FUNCTION funcLevel:-1
	
	scopeStackTop:-1

	If scopeStackTop
		currentScope=scopeStack[scopeStackTop-1]
	Else
		currentScope=New TScope
	EndIf

	GCResume	
End Function

Function OnDebugPushExState()
?Threaded
	If Not bbIsMainThread() Return
?
	GCSuspend

	If exStateStackTop=exStateStack.length 
		exStateStack=exStateStack[..exStateStackTop * 2 + 32]
		For Local i=exStateStackTop Until exStateStack.length
			exStateStack[i]=New TExState
		Next
	EndIf
	
	exStateStack[exStateStackTop].scopeStackTop=scopeStackTop
	
	exStateStackTop:+1

	GCResume	
End Function

Function OnDebugPopExState()
?Threaded
	If Not bbIsMainThread() Return
?
	GCSuspend

	If Not exStateStackTop DebugError "exception stack underflow"

	exStateStackTop:-1

	scopeStackTop=exStateStack[exStateStackTop].scopeStackTop
	
	If scopeStackTop
		currentScope=scopeStack[scopeStackTop-1]
	Else
		currentScope=New TScope
	EndIf

	GCResume	
End Function

Function OnDebugUnhandledEx( ex:Object )
?Threaded
	If Not bbIsMainThread() Return
?
	GCSuspend
	
	UpdateDebug "Unhandled Exception:"+ex.ToString()+"~n"

	GCResume	
End Function

