
Strict

' bmk_bb2bmx.bmx v0.4
' by Simon Armstrong

' converts BlitzBasic source files to BlitzMax

' history

' AND OR operators -> bitwise if not followed by conditional operators =<>  
' Min and Max -> _Min and _Max
' HandleFromObject and HandleToObject added to bbtype.bmx 
' link and list fields in bbtype -> _link and _list
' IncrementArrays$(code$) adds 1 to all array dimensions of array declarations
' ReadString(TStream) function added and FreeSound(sound)->Release(sound)
' hidepointer -> hidemouse showpointer -> showmouse
' delete obj -> obj.remove
' readpixel->dev.blitz3d.readpixel writepixel->dev.blitz3d.writepixel
' seekfile -> seekstream  filepos -> streampos
' channelvolume->SetChannelVolume soundvolume->
' readbytes -> ReadBank writebytes-> WriteBankq
' xor->~ getkey->waitkey mousewait->waitmouse
' handle -> HandleFromObject object -> HandleToObject
' stop -> DebugStop
' .label -> #label
' param[n]->param[] in function declarations
' added TypePrefix$ to help avoid type name / variable name clashes
' processes include files
' output bbtype.bmx and bbvkey.bmx files (thanks to Terabit) 
' moved to bmk_bb2bmx
' inline comments replace ; with '
' command separators replace : with ;
' type specifiers replace . with :
' field separators replace \ with .
' boolean operators replace and or with & |
' array declarations replace Dim x(100) with Global x[100+1]
' graphics commands Line,Rect,Oval,Text -> DrawLine,DrawRect,DrawOval,DrawText
' implement old style Type handling for Each First Last Before After Insert
' Str becomes String
' Delete Each list -> list.Clear()
' Delete -> Release
' Data->DefData Read->ReadData
' KeyDown->VKeyDown KeyHit->VKeyHit
' native Color and ClsColor commands added to header

' not supported / stubbed out

' no float->boolean so error is "bitwise operators can only be used with integers"
' MouseZSpeed(), FreeBank(bank), Locate( x,y )
' LoopSound(sound), ChannelPitch(channel,hz),PlayCDTrack( track,mode=0 )

Import brl.retro

Const TAB$=Chr(9)

Global TypePrefix$="bb"

Function main()
	Local AppArgs$[]=["bb2bmx","bob.bb"]
	Local srcfile$,destfile$
	Local n=Len AppArgs
	If n<2
		Print "bb2bmx srcfile.bb [destfile.bmx]"
		End
	EndIf
	srcfile$=AppArgs[1]
	destfile$=Replace$(srcfile,".bb",".bmx")
	If n>2 destfile$=AppArgs[2]
	bb2bmx(srcfile,destfile)
End Function

Function ConvertBB(args$[])
	Local srcfile$,destfile$
	If Len args<1 Throw "convertbb option requires a filename"
	srcfile$=args[0]
	If Len args>1 destfile=args[1]
	bb2bmx srcfile,destfile
End Function

Global Includes:TList
Global Complete:TList
Global TypeLists:TList

Function bb2bmx(srcfile$,destfile$)
	Local	s$,currdir$,inc$,done$
	Local	destinclude$
	Local	src:TList,isrc:TList
	Local	dest:TList,idest:TList
	Local	incs:TList

	Includes=New TList
	TypeLists=New TList
	Complete=New TList
	
	currdir=CurrentDir()
		
	src=ReadTextFile(srcfile)
	If Not src Throw "bb2bmx failed to open "+srcfile

	If Not destfile	destfile$=Replace$(srcfile,".bb",".bmx")
	ChangeDir ExtractDir(srcfile)

	WriteVKeyFile
	WriteBBTypeFile
	
	dest=New TList	

	Print "converting "+srcfile
	ConvertSourceList(src,dest)

' process includes

	While Not Includes.IsEmpty()
		incs=Includes
		Includes=New TList
		For srcfile=EachIn incs

' check if include already converted

			For done=EachIn complete
				If done=srcfile Exit
			Next
			If done=srcfile Continue

			complete.AddLast srcfile			
			isrc=ReadTextFile(srcfile)
			If Not isrc Throw "bb2bmx failed to open included file "+srcfile
			ChangeDir ExtractDir(srcfile)

			idest=New TList
			Print "converting "+srcfile

			ConvertSourceList(isrc,idest)
			destinclude$=Replace$(srcfile,".bb",".bmx")
			WriteTextFile(destinclude,idest)
		Next
	Wend
	
	ChangeDir(currdir)

	For s$=EachIn TypeLists
		dest.addfirst s$
	Next
		
	dest.addfirst ""
	dest.addfirst "Import "+Chr(34)+"bbvkey.bmx"+Chr(34)
	dest.addfirst "Import "+Chr(34)+"bbtype.bmx"+Chr(34)

	WriteTextFile(destfile,dest)
	
End Function

Function ProcessInclude$(s$)
	Local	path$,inc$
	Local	q,r
	
	q=Instr(s,Chr(34))
	If q=0 Return s$	
	r=Instr(s,Chr(34),q+1)
	If r=0 Return s$
	path$=s[q..r-1]

	path=RealPath(path$)
	For inc=EachIn Includes
		If inc=path Exit
	Next
	If inc<>path
		Includes.AddLast(path)	
	EndIf

	Return Replace$(s$,".bb",".bmx")
End Function

Function FindToken(s$,t$,p)
	Local	l$,c
	t=Lower(t)
	l=Lower(s)
	Repeat
		p=Instr(l,t,p+1)
		If Not p Exit
		If p>1
			c=l[p-2]
			If c>47 And c<58 Continue	'0-9
			If c>95 And c<122 Continue	'a-z
			If c=Asc("_") Continue
		EndIf
		If p+Len(t)-1<Len(l)
			c=l[p+Len(t)-1]
			If c>47 And c<58 Continue	'0-9
			If c>95 And c<122 Continue	'a-z
			If c=Asc("_") Continue
		EndIf
		Return p
	Forever
End Function

Function ReplaceToken$(s$,t$,r$)
	Local	l$,p,c
	Repeat
		p=FindToken(s,t,p)
		If Not p Exit
		s=s[..p-1]+r$+s[p+Len(t)-1..]	
		p:+Len r$
	Forever
	Return s
End Function

Function FindEOC(s$,p)	'return position of next space or command separator
	Local	q,r
	q=Instr(s," ",p)
	If q=0 q=Len s+1
	r=Instr(s,";",p)
	If r And r<q q=r
	r=Instr(s,"<",p)
	If r And r<q q=r
	r=Instr(s,">",p)
	If r And r<q q=r
	r=Instr(s,"=",p)
	If r And r<q q=r
	r=Instr(s,"-",p)
	If r And r<q q=r
	r=Instr(s,"+",p)
	If r And r<q q=r
	r=Instr(s,"*",p)
	If r And r<q q=r
	Return q
End Function

Function StripDims$(s$)	'remove dimensions in blitz arrays for blitzmax function parameters
	Local	p,q
	p=1
	Repeat
		p=Instr(s$,"[",p)
		If p=0 Exit
		q=Instr(s$,"]",p)
		If q=0 Exit
		s$=s$[..p]+s$[q-1..]
		p=p+1	
	Forever
	Return s
End Function

Function IncrementArrays$(s$)	'replace all arguments inside [] with 
	Local p,q,a$
	p=Instr(s$,"[")
	If p=0 Return
	p=Instr(s$,"=")
	If p 
'		print "IncrementArray rejecting s$="+s$
		Return s$
	EndIf
	p=0
	While True
		p=Instr(s$,"[",p)
		If p=0 Exit
		q=Instr(s$,"]",p)
		If q=0 Exit
		a$=s$[p..q-1]
		a$=Replace(a$,",","+1,")
		a$=a$+"+1"
		s$=s$[..p]+a$+s$[q-1..]
		p=p+Len(a$)+1
	Wend
	Return s$
End Function

Function ConvertBoolOps$(s$) ' if AND OR not followed by < > = convert to bool operator & | 
	Local	p,q,r,t	

	While True
		t=FindToken(s$,"And",p)
		If t=0 Exit		
		q=Len(s$)
		r=FindToken(s$,"Then",t)
		If r And r<q q=r
		r=Instr(s$,";",t)
		If r And r<q q=r
' q is end of check	
		r=Instr(s$,"=",t);If r And r<=q p=q;Continue 	
		r=Instr(s$,"<",t);If r And r<=q p=q;Continue 	
		r=Instr(s$,">",t);If r And r<=q p=q;Continue 	
		s$=s[..t-1]+"&"+s[t+2..]
	Wend
	p=0
	While True
		t=FindToken(s$,"Or",p)
		If t=0 Exit		
		q=Len(s$)
		r=FindToken(s$,"Then",t)
		If r And r<q q=r
		r=Instr(s$,";",t)
		If r And r<q q=r
' q is end of check	
		r=Instr(s$,"=",t);If r And r<=q p=q;Continue 	
		r=Instr(s$,"<",t);If r And r<=q p=q;Continue 	
		r=Instr(s$,">",t);If r And r<=q p=q;Continue 	
		s$=s[..t-1]+"|"+s[t+1..]
	Wend
	Return s$
End Function

Function Convert$(s$)	'substring of source line before rem and between any string literals
	Local	p,q,r,c,n$
' replace : command separator
	s$=Replace(s$,":",";")
'.label->#label	
	p=Instr(Trim(s),".")
	If p=1 
		p=Instr(s,".")
		s="#"+s[p..]
	EndIf
' replace . type specifier
	p=1
	Repeat
		p=Instr(s,".",p+1)
		If Not p Exit
		c=s[p]
		If c>47 And c<58 Continue	'ignore if decimal point
		s=s[..p-1]+":"+TypePrefix$+s[p..]	
	Forever
' replace \ field separator
	s$=Replace(s$,"\",".")
' update BASIC API name changes
	s$=ReplaceToken(s,"freesound","Release")
	s$=ReplaceToken(s,"channelpan","SetChannelPan")
	s$=ReplaceToken(s,"filepos","StreamPos")
	s$=ReplaceToken(s,"seekfile","SeekStream")
	s$=ReplaceToken(s,"channelvolume","SetChannelVolume")
	s$=ReplaceToken(s,"readbytes","ReadBank")
	s$=ReplaceToken(s,"writebytes","WriteBank")
	s$=ReplaceToken(s,"mousewait","WaitMouse")
' hidepointer -> hidemouse showpointer -> showmouse
	s$=ReplaceToken(s,"hidepointer","HideMouse")
	s$=ReplaceToken(s,"showpointer","ShowMouse")
' replace boolean operators
	s$=ReplaceToken(s,"xor","~~")
	s$=ReplaceToken(s,"stop","DebugStop")

Rem
	s$=ReplaceToken(s,"and","&")
	s$=ReplaceToken(s,"or","|")
	s$=ReplaceToken(s,"chr$","chr")

	s$=ReplaceToken(s,"line","DrawLine")
	s$=ReplaceToken(s,"rect","DrawRect")
	s$=ReplaceToken(s,"oval","DrawOval")
	s$=ReplaceToken(s,"text","DrawText")
	s$=ReplaceToken(s,"color","SetColor")
	s$=ReplaceToken(s,"clscolor","SetCLSColor")
EndRem
	s$=ReplaceToken(s,"str","String")
	s$=ReplaceToken(s,"read","ReadData")
	s$=ReplaceToken(s,"data","DefData")
	s$=ReplaceToken(s,"restore","RestoreData")
	s$=ReplaceToken(s,"keydown","VKeyDown")
	s$=ReplaceToken(s,"keyhit","VKeyHit")
	s$=ReplaceToken(s,"getkey","WaitKey")
	s$=ReplaceToken(s,"readpixel","dev.blitz3d.ReadPixel")	'ReadPixelBuffer")
	s$=ReplaceToken(s,"writepixel","dev.blitz3d.WritePixel")
	s$=ReplaceToken(s,"graphicswidth","dev.blitz3d.GraphicsWidth")
	s$=ReplaceToken(s,"graphicsheight","dev.blitz3d.GraphicsHeight")

	s$=ReplaceToken(s,"min","fmin")
	s$=ReplaceToken(s,"max","fmax")

' delete obj -> obj.remove
	p=0
	Repeat
		p=FindToken(s,"delete",p)
		If Not p Exit
		If Lower(s[p+5..p+10])=" each" s=s[..p+5]+"Each "+TypePrefix$+Trim(s[p+10]);Continue		
		If Lower(s[p+5..p+11])=" first" s=s[..p+5]+"First "+TypePrefix$+Trim(s[p+11]);Continue		
		If Lower(s[p+5..p+10])=" last" s=s[..p+5]+"Last "+TypePrefix$+Trim(s[p+10]);Continue		
		q=Instr(s," ",p+7)
		If q=0 q=Len s+1
		r=Instr(s,";",p+7)
		If r And r<q q=r	
		s=s[..p-1]+s[p+6..q-1]+".Remove()"+s[q-1..]		'p+6
		p=q
	Forever

	s$=ConvertBoolOps(s)

	s$=ReplaceToken(s,"delete","Release")

' handle(obj) -> HandleFromObject(obj) object.blah(handle) -> HandleToObject(handle)

	s$=ReplaceToken(s,"handle","HandleFromObject")
	p=0
	Repeat
		p=FindToken(s,"object",p)
		If p=0 Exit
		q=Instr(s,":",p)
		If q=0 Exit
		r=Instr(s,"(",q)
		If r=0 Exit
		n$=s[q..r-1]
		c=1
		q=r
		While c
			If r>Len(s) Exit
			If s[r]="(" c:+1
			If s[r]=")" c:-1
			r:+1
		Wend
		s=s[..p-1]+n$+"(HandleToObject"+s[q-1..r-1]+")"+s[r..]
		p=p+Len(n)+16
	Forever

' replace New Type with New prefix_type 
	p=0
	Repeat
		p=FindToken(s,"New",p)
		If Not p Exit
		s=s[..p+3]+TypePrefix$+s[p+3..]
		p=p+1
	Forever
' replace Dim var(size) with Global var[size] 
	p=0
	Repeat
		p=FindToken(s,"Dim",p)
		If Not p Exit
		s=s[..p-1]+"Global"+s[p+2..]
		Repeat
			p=Instr(s,"(",p)
			If Not p Exit
			s=s[..p-1]+"["+s[p..]
			p=Instr(s,")",p)
			If Not p Exit
			s=s[..p-1]+"]"+s[p..]	'was +1
		Forever
		s=IncrementArrays(s$)
		Exit	'no multiple dim calls pre
'		if not p exit
	Forever
' replace function(param[4]) with function(param[])
	p=0
	Repeat
		p=FindToken(s,"Function",p)
		If Not p Exit
		p=Instr(s,"(",p)
		If Not p Exit
		q=Instr(s,")",p)
		If Not q Exit
		n$=StripDims(s[p..q-1])
		s=s[..p]+n+s[q-1..]		
		Exit	
	Forever	
' for b=each bob -> for b=eachin bob.list
	p=0
	Repeat
		p=FindToken(s,"Each",p)
		If Not p Exit
		q=FindEOC(s,p+6)
		s=s[..p-1]+"EachIn "+Trim(s[p+4..q-1])+"_list"+s[q-1..]		
		p=q
	Forever
' First class
	p=0
	Repeat
		p=FindToken(s,"First",p)
		If Not p Exit
		q=FindEOC(s,p+7)
		n$=Trim(s[p+5..q-1])
		s=s[..p-1]+TypePrefix+n+"("+n+"_list.First())"+s[q-1..]		
		p=q+Len(n)*2+14
	Forever
' Last class
	p=0
	Repeat
		p=FindToken(s,"Last",p)
		If Not p Exit
		q=FindEOC(s,p+6)
		n$=Trim(s[p+4..q-1])
		s=s[..p-1]+TypePrefix+n+"("+n+"_list.Last())"+s[q-1..]		
		p=q+Len(n)*2+13
	Forever	
' Insert b Before|After bob -> b.InsertAfter(bob)
	p=0
	Repeat
		p=FindToken(s,"Insert",p)
		If Not p Exit
		q=Instr(s," ",p+7)
		If Not q Exit
		n$=Lower(s[q..])
		If n$[..6]="before"
			n$="Before"
			r=q+7
		ElseIf n$[..5]="after"
			n$="After"
			r=q+6
		Else
			Exit
		EndIf
		c=FindEOC(s,r+1)
		s=s[..p-1]+s[p+6..q-1]+".Insert"+n$+"("+s[r..c-1]+")"+s[c..]	'n$+ simon was here
		p=c
	Forever
' After b -> b.After() 	
	p=0
	Repeat
		p=FindToken(s,"After",p)
		If Not p Exit
		q=Instr(s," ",p+7)
		If q=0 q=Len s+1
		r=Instr(s,";",p+7)
		If r And r<q q=r
		s=s[..p-1]+s[p+5..q-1]+".After()"+s[q-1..]		
		p=q
	Forever
' Before b -> b.Before() 	
	p=0
	Repeat
		p=FindToken(s,"Before",p)
		If Not p Exit
		q=Instr(s," ",p+8)
		If q=0 q=Len s+1
		r=Instr(s,";",p+8)
		If r And r<q q=r
		s=s[..p-1]+s[p+6..q-1]+".Before()"+s[q-1..]		
		p=q
	Forever
	Return s
End Function

Function FixQuotes$(q$)
	Local	p,n
	Repeat
		p=Instr(q,Chr(34),p)
		If p=0 Exit
		p=p+1
		n=n+1
	Forever
	If n&1 Return q$+Chr(34)	'add one for odd quoted lines
	Return q
End Function

Function ConvertSourceList(src:TList,dest:TList)
	Local	in$,out$,l$,p,q,r,inrem,name$
	Local	strings[]
	
	For in=EachIn src
		l$=Lower$(in)
		If l$="rem" l$="rem "
		If inrem
' terminate remarks		
			out$=in$
			p=Instr(l$,"endrem")
			If p<>1 p=Instr(l$,"end rem")
			If p=1
				inrem=0
			EndIf
		Else
' parse strings and remarks
			out$=""
			in$=fixquotes(in$)
			While in$
				q=Instr(in$,Chr(34))
				r=Instr(in$,";")
				inrem=Instr(l$,"rem ")		
				If inrem And inrem<q q=0
				If r And r<q q=0
				If q
					r=Instr(in$,Chr(34),q+1)
					If r=0 r=Len(in$)
					out$=out$+Convert(in$[..q-1])+in$[q-1..r]
					in$=in$[r..]	
					Continue				
				EndIf
				If inrem And inrem<r r=0
				If r
					out$=out$+Convert(in$[..r-1])+"'"+in$[r..]
					Exit
				EndIf
				If inrem
					out$=out$+Convert(in$[..inrem-1])+in$[inrem-1..]
					Exit
				EndIf
				out$=out$+Convert(in$)
				Exit
			Wend
		EndIf
	
		l$=Lower(out)
			
' type handling extras		
		If l$[..5]="type "
			name$=out$[5..]
			p=Instr(name," ")
			q=Instr(name,";")
			If (Not p) p=Len name
			If q And q<p p=q
			If p name=name[..p]
			name=Trim(name)
			p=p+5		
			
			TypeLists.AddLast "Global "+name+"_list:TList=new TList"
			dest.AddLast "Type "+TypePrefix$+name+" Extends TBBType"+out$[p..]
			dest.AddLast ""
			dest.AddLast TAB$+"Method New()"
			dest.AddLast TAB$+TAB$+"Add("+name+"_list)"
			dest.AddLast TAB$+"End Method"
			dest.AddLast ""
			dest.AddLast TAB$+"Method After:"+TypePrefix$+name+"()"
			dest.AddLast TAB$+TAB$+"Local t:TLink"
			dest.AddLast TAB$+TAB$+"t=_link.NextLink()"
			dest.AddLast TAB$+TAB$+"If t Return "+TypePrefix$+name+"(t.Value())"
			dest.AddLast TAB$+"End Method"
			dest.AddLast ""
			dest.AddLast TAB$+"Method Before:"+TypePrefix$+name+"()"
			dest.AddLast TAB$+TAB$+"Local t:TLink"
			dest.AddLast TAB$+TAB$+"t=_link.PrevLink()"
			dest.AddLast TAB$+TAB$+"If t Return "+TypePrefix$+name+"(t.Value())"
			dest.AddLast TAB$+"End Method"
			dest.AddLast ""
			Continue
		EndIf

' Include "blah.bb" ->	Include "blah.bmx"
		
		If l$[..8]="include " Or l$[..8]="include"+Chr$(34)
			out=ProcessInclude(out)
		EndIf
		
		dest.AddLast out
		
	Next
End Function

Function ReadTextFile:TList(file$)
	Local	f:TStream,n
	Local	txt:TList
	txt=New TList
	f=ReadStream(file)
	If Not f Return Null
	While Not Eof(f)
		txt.AddLast ReadLine(f)
		n:+1
	Wend
	Return txt
End Function

Function WriteTextFile(file$,txt:TList)
	Local	f:TStream,l$
	f=WriteStream(file)
	If Not f Return
	For l$=EachIn txt
		WriteLine f,l
	Next
	CloseStream f
End Function

Function WriteVKeyFile()
	Local dest:TStream=WriteFile("bbvkey.bmx")
	If Not dest Return
	WriteLine dest,"' virtual key support for legacy Blitz apps"
	WriteLine dest,""
	WriteLine dest,"Global VKEY[]=[.."
	WriteLine dest,"0,KEY_ESCAPE,KEY_1,KEY_2,KEY_3,KEY_4,KEY_5,KEY_6,KEY_7,KEY_8,KEY_9,KEY_0,.."
	WriteLine dest,"KEY_MINUS,KEY_EQUALS,KEY_BACKSPACE,KEY_TAB,KEY_Q,KEY_W,KEY_E,KEY_R,KEY_T,.."
	WriteLine dest,"KEY_Y,KEY_U,KEY_I,KEY_O,KEY_P,KEY_OPENBRACKET,KEY_CLOSEBRACKET,KEY_RETURN,.."
	WriteLine dest,"KEY_LCONTROL,KEY_A,KEY_S,KEY_D,KEY_F,KEY_G,KEY_H,KEY_J,KEY_K,KEY_L,.."
	WriteLine dest,"KEY_SEMICOLON,KEY_QUOTES,KEY_TILDE,KEY_LSHIFT,KEY_BACKSLASH,.."
	WriteLine dest,"KEY_Z,KEY_X,KEY_C,KEY_V,KEY_B,KEY_N,KEY_M,KEY_COMMA,KEY_PERIOD,KEY_SLASH,.."
	WriteLine dest,"KEY_RSHIFT,KEY_NUMMULTIPLY,KEY_ALT,KEY_SPACE,KEY_CAPSLOCK,.."
	WriteLine dest,"KEY_F1,KEY_F2,KEY_F3,KEY_F4,KEY_F5,KEY_F6,KEY_F7,KEY_F8,KEY_F9,KEY_F10,.."
	WriteLine dest,"KEY_NUMLOCK,KEY_SCROLL,KEY_NUM7,KEY_NUM8,KEY_NUM9,KEY_NUMSUBTRACT,KEY_NUM4,.."
	WriteLine dest,"KEY_NUM5,KEY_NUM6,KEY_NUMADD,KEY_NUM1,KEY_NUM2,KEY_NUM3,KEY_NUM0,.."
	WriteLine dest,"KEY_NUMDECIMAL,KEY_NUMSLASH,KEY_F11,KEY_F12,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,.."
	WriteLine dest,"0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,.."
	WriteLine dest,"KEY_EQUALS,0,0,KEY_MEDIA_PREV_TRACK,0,0,0,0,0,0,0,0,KEY_MEDIA_NEXT_TRACK,0,0,.."
	WriteLine dest,"KEY_ENTER,KEY_RCONTROL,0,0,KEY_VOLUME_MUTE,0,KEY_MEDIA_PLAY_PAUSE,0,.."
	WriteLine dest,"KEY_MEDIA_STOP,0,0,0,0,0,0,0,0,0,KEY_VOLUME_DOWN,0,KEY_VOLUME_UP,0,.."
	WriteLine dest,"KEY_BROWSER_HOME,KEY_DECIMAL,0,KEY_NUMDIVIDE,0,KEY_SCREEN,.."
	WriteLine dest,"0,0,0,0,0,0,0,0,0,0,0,0,0,KEY_PAUSE,0,KEY_HOME,KEY_UP,KEY_PAGEUP,0,.."
	WriteLine dest,"KEY_LEFT,0,KEY_RIGHT,0,KEY_END,KEY_DOWN,KEY_PAGEDOWN,KEY_INSERT,KEY_DELETE,.."
	WriteLine dest,"0,0,0,0,0,0,0,KEY_LWIN,KEY_RWIN,0,0,0,0,0,0,0,0,KEY_BROWSER_SEARCH,.."
	WriteLine dest,"KEY_BROWSER_FAVORITES,KEY_BROWSER_REFRESH,KEY_BROWSER_STOP,KEY_BROWSER_FORWARD,.."
	WriteLine dest,"KEY_BROWSER_BACK,0,KEY_LAUNCH_MAIL,KEY_LAUNCH_MEDIA_SELECT]"
	WriteLine dest,""	
	WriteLine dest,"Function VKeyDown(key);return KeyDown(VKEY[key]);End Function"
	WriteLine dest,"Function VKeyHit(key);return KeyHit(VKEY[key]);End Function"
	WriteLine dest,""
	WriteLine dest,"'currently unsupported in BlitzMax"	
	WriteLine dest,""
	WriteLine dest,"Function Locate( x,y );return 0;End Function"
	WriteLine dest,"Function MouseZSpeed();return 0;End Function"
	WriteLine dest,"Function FreeBank(bank);return 0;End Function"
	WriteLine dest,"Function LoopSound(sound);return 0;End Function"
	WriteLine dest,"Function ChannelPitch(channel,hz);return 0;End Function"
	WriteLine dest,"Function PlayCDTrack( track,mode=0 );return 0;End Function"
	WriteLine dest,"Function SoundVolume( sound,volume# );return 0;End Function"
	WriteLine dest,""
	CloseFile dest
End Function
	
Function WriteBBTypeFile()
	Local dest:TStream=WriteFile("bbtype.bmx")
	If Not dest Return
	WriteLine dest,"' BBType adds legacy Type functionality to BlitzMax Type"
	WriteLine dest,""
	WriteLine dest,"Type TBBType"
	WriteLine dest,""
	WriteLine dest,"	Field _list:TList"
	WriteLine dest,"	Field _link:TLink"
	WriteLine dest,""
	WriteLine dest,"	Method Add(t:TList)"
	WriteLine dest,"		_list=t"
	WriteLine dest,"		_link=_list.AddLast(self)"
	WriteLine dest,"	End Method"
	WriteLine dest,""
	WriteLine dest,"	Method InsertBefore(t:TBBType)"
	WriteLine dest,"		_link.Remove"
	WriteLine dest,"		_link=_list.InsertBeforeLink(self,t._link)"
	WriteLine dest,"	End Method"
	WriteLine dest,""
	WriteLine dest,"	Method InsertAfter(t:TBBType)"
	WriteLine dest,"		_link.Remove"
	WriteLine dest,"		_link=_list.InsertAfterLink(self,t._link)"
	WriteLine dest,"	End Method"
	WriteLine dest,""
	WriteLine dest,"	Method Remove()"
	WriteLine dest,"		_list.remove self"
	WriteLine dest,"	End Method"
	WriteLine dest,""
	WriteLine dest,"End Type"
	WriteLine dest,""
	WriteLine dest,"Function DeleteLast(t:TBBType)"
	WriteLine dest,"	if t TBBType(t._list.Last()).Remove()"
	WriteLine dest,"End Function"
	WriteLine dest,""
	WriteLine dest,"Function DeleteFirst(t:TBBType)"
	WriteLine dest,"	if t TBBType(t._list.First()).Remove()"
	WriteLine dest,"End Function"
	WriteLine dest,""
	WriteLine dest,"Function DeleteEach(t:TBBType)"
	WriteLine dest,"	if t t._list.Clear()"
	WriteLine dest,"End Function"
	WriteLine dest,""
	WriteLine dest,"Function ReadString$(in:TStream)"
	WriteLine dest,"	local	length"
	WriteLine dest,"	length=readint(in)"
	WriteLine dest,"	if length>0 and length<1024*1024 return brl.stream.readstring(in,length)"
	WriteLine dest,"End Function"
	WriteLine dest,""
	WriteLine dest,"Function HandleToObject:Object(obj:Object)"
	WriteLine dest,"	Return obj"
	WriteLine dest,"End Function"
	WriteLine dest,""
	WriteLine dest,"Function HandleFromObject(obj:Object)"
	WriteLine dest,"	Local h=HandleToObject(obj)"
	WriteLine dest,"	Return h"
	WriteLine dest,"End Function"
	WriteLine dest,""
	WriteLine dest,""
	CloseFile dest
End Function
