
Strict

Framework brl.basic

Import Pub.StdC

Try

ChangeDir LaunchDir

If AppArgs.length<>2 And AppArgs.length<>3
	Print "Command line error"
	End
EndIf

Local in:TStream=CreateBankStream( LoadBank( AppArgs[1] ) ),out:TStream

If AppArgs.length=3
	out=WriteStream( AppArgs[2] )
Else
	out=WriteStream( AppArgs[1] )
EndIf

If Not out Throw "Failed to create output stream"

While Not in.Eof()

	Local line$=in.ReadLine()
	
	Local t_line$=line
	
	If line And line[0]=9
		Local i=line.Find( Chr(9),1 )
		If i<>-1
			Local sz
			Local op$=line[1..i]
			Local args$=line[i+1..]
			Select op
			Case "db"
				op=".byte"
				If args[..1]="~q" And args[args.length-3..]="~q,0"
					op=".asciz"
					args="~q"+args[1..args.length-3]+"~q"
				EndIf
			Case "dw"
				op=".short"
			Case "dd"
				op=".long"
			Case "extrn"
				op=".reference"
			Case "public"
				op=".globl"
			Case "align"
				op=".align"
			Case "file"
				If args[..1]="~q" And args[args.length-1..]="~q"
					args=args[1..args.length-1]
				EndIf
				Local r:TStream=ReadStream( args ),n
				If Not r Throw "Unable to open file "+args
				Local buf:Byte[64]
				Repeat
					Local n=r.Read( buf,64 )
					If Not n Exit
					Local t$="~t.byte~t"+buf[0]
					For Local i=1 Until n
						t:+","+buf[i]
					Next
					WriteString out,t
					WriteString out,"~n"
				Forever
				r.Close
				op=""
			Case "section"
				op="."+args
				args=""
			Default
				Local i=args.Find( "," )
				If i=-1
					sz=FixArg( args,op )
					If op="call"
						If sz Or args.StartsWith( "%" )
							args="*"+args
						Endif
					Endif
'					If sz And op="call" args="*"+args
				Else
					Local arg2$=args[..i]
					Local arg1$=args[i+1..]
					Local sz1=FixArg( arg1 )
					Local sz2=FixArg( arg2 )
					sz=sz1
					If sz2 sz=sz2
					Select op
					Case "lea"
						sz=0
					Case "movzx","movsx"
						Local s$
						Select sz
						Case 1
							s="b"
						Case 2
							s="w"
						Case 0
							Select arg1
							Case "%al","%bl","%cl","%dl"
								s$="b"
							Case "%ax","%bx","%cx","%dx","%bp","%sp","%si","%di"
								s$="w"
							End Select
						End Select
						op=op[..4]+s+"l"
						sz=0
					Case "fdiv","fsub"
						If arg1="%st(0)" And arg2[..3]="%st" op=op[..4]+"r"
					Case "fdivp","fsubp"
						If arg1="%st(0)" And arg2[..3]="%st" op=op[..4]+"rp"
					Case "fdivr","fsubr"
						If arg1="%st(0)" And arg2[..3]="%st" op=op[..4]
					Case "fdivrp","fsubrp"
						If arg1="%st(0)" And arg2[..3]="%st" op=op[..4]+"p"
					End Select
					args=arg1+","+arg2
				EndIf
				Local fpsz
				If op And op[0]=Asc("f")
					Select op
					Case ..
					"fild","fist","fistp","ficom","ficomp",..
					"fiadd","fisub","fimul","fidiv","fidivr"
					Default
						fpsz=True
					End Select
				EndIf
				Select sz
				Case 1
					op:+"b"
				Case 2
					op:+"w"
				Case 4
					If fpsz op:+"s" Else op:+"l"
				Case 8
					If fpsz op:+"l" Else op:+"q"
				End Select
			End Select
			If op line=Chr(9)+op+Chr(9)+args Else line=""
		EndIf
	EndIf
	
	WriteString out,line
	WriteString out,"~n"
	
Wend

in.Close

Catch ex:Object

	WriteStdout "fasm2as failed: "+ex.ToString()+"~n"
	
	exit_ -1

End Try

End

Function RegSize( r$ )
	Select r
	Case "eax","ebx","ecx","edx","esi","edi","ebp","esp"
		Return 4
	End Select
End Function

Function FixArg( arg$ Var,op$="" )

	If Not arg.EndsWith( "]" )
		If arg[0]=Asc("_")
			If op[0]<>Asc("j") And op<>"call" arg="$"+arg
		Else If (arg[0]>=48 And arg[0]<=57) Or arg[0]=Asc("-")
			arg="$"+arg
		Else
			If arg[..2]="st" arg="st("+arg[2..]+")"
			arg="%"+arg
		EndIf
		Return 0
	EndIf
	
	Local sz
	
	If arg.StartsWith( "[" )
		arg=arg[1..arg.length-1]
	Else If arg.StartsWith( "byte [" )
		arg=arg[6..arg.length-1]
		sz=1
	Else If arg.StartsWith( "word [" )
		arg=arg[6..arg.length-1]
		sz=2
	Else If arg.StartsWith( "dword [" )
		arg=arg[7..arg.length-1]
		sz=4
	Else If arg.StartsWith( "qword [" )
		arg=arg[7..arg.length-1]
		sz=8
	Else
		Throw "Error"
	EndIf
	
	arg=arg.Replace( "+-","-" )
	arg=arg.Replace( "-","+-" )

	Local base$,index$,scale$,disp$
	For Local t$=EachIn arg.Split( "+" )
		If t.Contains("*")
			If index Throw "Error"
			Local bits$[]=t.Split( "*" )
			If bits.length<>2 Throw "Error"
			index=bits[0]
			scale=bits[1]
		Else If RegSize( t )
			If base
				If index Throw "Error"
				index=t
				scale="1"
			Else
				base=t
			EndIf
		Else
			If disp
				disp=(disp+"+"+t).Replace( "+-","-" )
			Else
				disp=t
			EndIf
		EndIf
	Next

	If base And index
		arg=disp+"(%"+base+",%"+index+","+scale+")"
	Else If base
		arg=disp+"(%"+base+")"
	Else If index
		arg=disp+"(,%"+index+","+scale+")"
	Else If disp
		arg=disp
	Else
		Throw "Error!"
	EndIf
	
	Return sz
End Function
