
Strict

Framework brl.basic

Import brl.map

Rem

Cheezy little app to convert glew.h to bmx source.

Run this, then copy 'n' paste the output into opengl.bmx 
(everything <=glViewport) and glew.bmx (the rest!)

End Rem

Global in:TStream=ReadStream( "GL/glew.h" )

Global curr$,text$

Local funMap:TMap=New TMap
Local constMap:TMap=New TMap

While Not Eof(in)
	text=in.ReadLine()
	bump
	If curr="GLAPI"
		bump
		Local funty$=gltype()
		If funty<>"x" And curr="GLAPIENTRY"
			Local id$=bump()
			If id[..2]="gl" And bump()="("
				Local proto$=glproto()
				If proto<>"x"
					Print "Function "+id+funty+"("+proto+")"
				EndIf
			EndIf
		EndIf
	Else If curr="#"
		If bump()="define"
			Local id$=bump()
			If id[..11]="GL_VERSION_"
				
			Else If id[..3]="GL_"
				If Not constMap.ValueForKey(id)
					Local n$=bump()
					If n[..2]="0x"
						Print "Const "+id+"=$"+n[2..]
					Else If n.length And isdigit(n[0]) And n<>"1"
						Print "Const "+id+"="+n
					EndIf
					constMap.Insert id,n
				EndIf
			Else If id[..5]="GLEW_"
				If bump()="GLEW_GET_VAR" And bump()="("
					Local sym$=bump()
					If sym[..7]="__GLEW_" And bump()=")"
						Print "Global GL_"+id[5..]+":Byte=~q"+sym+"~q"
					EndIf
				EndIf
			Else If id[..2]="gl"
				If bump()="GLEW_GET_FUN" And bump()="("
					Local sym$=bump()
					If sym[..6]="__glew" And bump()=")"
						Local key$="PFNGL"+sym[6..].ToUpper()+"PROC"
						Local val$=String( funMap.ValueForKey( key ) )
						If val
							Print "Global "+id+val+"=~q"+sym+"~q"
						Else
							Print "***** "+sym+" *****"
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	Else If curr="typedef"
		bump
		Local funty$=gltype()
		If funty<>"x" And curr="(" And bump()="GLAPIENTRY" And bump()="*"
			Local id$=bump()
			If id[..5]="PFNGL" And bump()=")" And bump()="("
				Local proto$=glproto()
				If proto<>"x"
					funMap.Insert id,funty+"("+proto+")"
				EndIf
			EndIf
		EndIf
	EndIf
Wend

in.Close

Function glproto$()
	If bump()=")" Return ""
	Local proto$,err,argid
	Repeat
		Local argty$=gltype()
		If argty="x" Return argty
		Local id$
		If curr<>"," And curr<>")" And curr.length And (isalpha(curr[0]) Or curr[0]=Asc("_"))
			id$=curr
			If bump()="["
				While bump()<>"]"
				Wend
				bump
				If Not argty argty="Byte"
				argty:+" Ptr"
			EndIf
		Else
			id="arg"+argid
		EndIf
		argid:+1
		If proto proto:+","
		proto:+id+"_"+argty
		If curr=")"
			bump
			If proto="arg0_" proto=""
			Return proto
		EndIf
		If curr<>"," Return "x"
		bump
	Forever
End Function

Function gltype$()
	Local ty$
	If curr="const"
		bump
	EndIf
	Select curr
	Case "void","GLvoid"
		ty=""
	Case "char","GLbyte","GLubyte","GLchar","GLboolean","GLcharARB"
		ty="Byte"
	Case "GLshort","GLushort","GLhalf"
		ty="Short"
	Case "GLint","GLuint","GLenum","GLsizei","GLbitfield"
		ty="Int"
	Case "GLintptr","GLsizeiptr","GLintptrARB","GLsizeiptrARB"
		ty="Int"
	Case "GLhandleARB"
		ty="Int"
	Case "GLint64EXT","GLuint64EXT"
		ty="Long"
	Case "GLfloat","GLclampf"
		ty="Float"
	Case "GLdouble","GLclampd"
		ty="Double"
	Default
		Return "x"
	End Select
	Repeat
		bump
		If curr="const" bump
		If curr<>"*" Exit
		If Not ty ty="Byte"
		ty:+" Ptr"
	Forever
	If ty ty=":"+ty
	Return ty
End Function

Function isalpha( c )
	Return (c>=Asc("A") And c<=Asc("Z")) Or (c>=Asc("a") And c<=Asc("z"))
End Function

Function isdigit( c )
	Return c>=Asc("0") And c<=Asc("9")
End Function

Function isalnum( c )
	Return isalpha(c) Or isdigit(c)
End Function

Function isxdigit( c )
	Return (c>=Asc("A") And c<=Asc("F")) Or (c>=Asc("a") And c<=Asc("f")) Or isdigit(c)
End Function

Function bump$()
	Local i=0
	While i<text.length And text[i]<=Asc(" ")
		i:+1
	Wend
	If i=text.length
		curr=""
		text=""
		Return curr
	EndIf
	text=text[i..]
	Local c=text[0]
	i=1
	If isalpha(c) Or c=Asc("_")
		While i<text.length And (isalnum( text[i] ) Or text[i]=Asc("_"))
			i:+1
		Wend
	Else If c>=Asc("0") And c<=Asc("9")
		If i<text.length And c=Asc("0") And text[i]=Asc("x")
			i:+1
			While i<text.length And isxdigit(text[i])
				i:+1
			Wend
		Else
			While i<text.length And isdigit(text[i])
				i:+1
			Wend
		EndIf
	EndIf
	curr=text[..i]
	text=text[i..]
	Return curr
End Function
