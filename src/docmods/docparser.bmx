Strict

Import BRL.StandardIO
Import BRL.MaxUtil

Import "bmxtoker.bmx"

Function FormatTags( t$ Var,bbTag$,htmlTag$ )
	Local i
	Repeat
		i=t.Find( bbTag,i )
		If i=-1 Exit
		
		If i And t[i-1]>32
			i:+1
			Continue
		EndIf

		Local e		
		If i<t.length-1 And t[i+1]=Asc("{")
			Local e=t.Find( "}",i+2 )
			If e=-1 
				i:+2
				Continue
			EndIf
			Local q$="<"+htmlTag+">"+t[i+2..e]+"</"+htmlTag+">"
			t=t[..i]+q+t[e+1..]
			i:+q.length
			
		Else
			e=i+1
			While e<t.length
				Local c=t[e]
				If c=Asc(".") And e+1<t.length And IsAlpha( t[e+1] )
					e:+2
					Continue
				EndIf
				If c = Asc(";") Return
				If c<>Asc("_") And Not IsAlphaNumeric(c) Exit
				e:+1
			Wend
			Local q$="<"+htmlTag+">"+t[i+1..e]+"</"+htmlTag+">"
			t=t[..i]+q+t[e..]
			i:+q.length
		EndIf
	Forever
End Function

Function FindIdent( pre$,text$,i Var,e Var )

	i=text.Find( pre,i )
	
	If i=-1 Return False
	
	If i>0 And text[i-1]>32 Return False
	
	e=i+1
	While e<text.length
		Local c=text[e]
		If c=Asc(".") And e+1<text.length And IsAlpha( text[e+1] )
			e:+2
			Continue
		EndIf
		If c<>Asc("_") And Not IsAlphaNumeric(c) Exit
		e:+1
	Wend
	Return True
End Function

Function FormatText( t$ Var )

	If t.length And IsAlphaNumeric( t[t.length-1] ) t:+"."

	Local i,e

	'do links
	i=0
	While FindIdent( "#",t,i,e )
	
		While e<t.length-1 And t[e]=Asc(".") And IsAlpha( t[e+1] )
			e:+2
			While e<t.length And IsAlpha(t[e])
				e:+1
			Wend
		Wend
		
		Local id$=t[i+1..e],q=id.Find("."),ln$

		If q=-1
			ln="<a href=#"+id+">"+id+"</a>"
		Else
			ln="<a href=../../../"
			Repeat
				ln:+id[..q]+".mod/"
				id=id[q+1..]
				q=id.Find(".")
			Until q=-1
			ln:+"doc/commands.html#"+id+">"+id+"</a>"
		EndIf
			
		t=t[..i]+ln+t[e..]
		i:+ln.length
	Wend
	
	FormatTags t,"@","b"
	FormatTags t,"%","i"
	FormatTags t,"&","pre"
	
	'do tables
	i=0
	Repeat
		i=t.Find( "~n[",i )
		If i=-1 Exit
		
		Local i2=t.Find( "~n]",i+3 )
		If i2=-1 Exit
		
		Local q$=t[i+2..i2]

		q=q.Replace( "* ","</td></tr><tr><td>" )
		q=q.Replace( " | ","</td><td>" )
		
		q="~n<table><tr><td>"+q+"</table>~n"
		
		t=t[..i]+q+t[i2+2..]
		i:+q.length

	Forever
	
	'paras
	t=t.Replace( "~n~n","~n<p>~n" )
	
End Function

Type TDocs

	Field kind		'T_CONST, T_GLOBAL etc
	Field ident$	'identifier
	Field proto$	'Global/Function etc text
	Field bbdoc$	'rem/endrem bbdoc: text
	Field infos:TList=New TList	'ModuleInfo's
	Field imports:TList = New TList ' Added by BaH - 25/05/2006
	Field parent:TDocs ' Added by BaH - 25/05/2006
	Field textCache:TTextCache
	
	Field kids:TList=New TList
	
	Method Sort()
		kids.Sort
		For Local t:TDocs=EachIn kids
			t.Sort
		Next
	End Method
	
	' Added by BaH - 25/05/2006
	' Checks for extra references to the same imports...
	Method containsImport:Int(_file:String)
		If imports.contains(_file) Then
			Return True
		End If
		If parent <> Null Then
			Return parent.containsImport(_file)
		End If
		
		Return False
	End Method
	
	Method Compare( with:Object )
		Local t:TDocs=TDocs(with)

		If kind=t.kind
			If kind=T_MODULE 
				Return bbdoc.ToLower().Compare( t.bbdoc.ToLower() )
			EndIf
			Return ident.ToLower().Compare( t.ident.ToLower() )
		EndIf

		If kind=T_MODULE Return -1
		If t.kind=T_MODULE Return 1
		
		If kind=T_CONST Return -1
		If t.kind=T_CONST Return 1

		If kind=T_GLOBAL Return -1
		If t.kind=T_GLOBAL Return 1
		
		If kind=T_FIELD Return -1
		If t.kind=T_FIELD Return 1

		If kind=T_METHOD Return -1
		If t.kind=T_METHOD Return 1

		If kind=T_FUNCTION Return -1
		If t.kind=T_FUNCTION Return 1
		
		If kind=T_TYPE Return -1
		If t.kind=T_TYPE Return 1
		
		If kind=T_EOL Return -1
		If t.kind=T_EOL Return 1
		
		Throw "OOps!"
		
	End Method
	
	Method CacheTexts()
		If textCache = Null Then
			textCache = TTextCache.Create(bbdoc, kind)
		
			If Not kids.IsEmpty()
				Local tkind=0
				For Local doc:TDocs=EachIn kids
					doc.CacheTexts()
				Next
			EndIf

		End If

	End Method
	
	Method EmitHtml$(summary:Int = False)
		Local example$

		Local stream:TStream=ReadStream( ident+".bmx" )
		If stream
			While Not stream.Eof()
				example:+stream.ReadLine()+"~n"
			Wend
			stream.Close
			example=example.Trim()
		EndIf
		
		If Not summary Then
			Select kind
			Case 0
			Case T_MODULE
				TPrint "<html><head><title>"+textCache.shortdesc+" reference</title>"
				TPrint "<link rel=stylesheet Type=text/css href='../../../../doc/bmxstyle.css'>"
				TPrint "</head><body>"
				Local n_consts
				Local n_globals
				Local n_functions
				Local n_types
				Local n_keywords:Int
				For Local t:TDocs=EachIn kids
					Select t.kind
					Case T_CONST n_consts:+1
					Case T_GLOBAL n_globals:+1
					Case T_FUNCTION n_functions:+1
					Case T_TYPE
						' Type is doc'd or there are doc'd kids
						If t.bbdoc Or t.kids.count() > 0 Then
							n_types:+1
						End If
					Case T_EOL n_keywords:+1
					End Select
				Next
				
				TPrint "<table width=100% cellspacing=0><tr align=center><td class=small>&nbsp;</td>"
				TPrint "<td class=small width=1%><b>"+ident+":</b></td>"
				If n_consts TPrint "<td class=small width=1%><a href=#consts class=small>Constants</a></td>"
				If n_globals TPrint "<td class=small width=1%><a href=#globals class=small>Globals</a></td>"
				If n_functions TPrint "<td class=small width=1%><a href=#functions class=small>Functions</a></td>"
				If n_types TPrint "<td class=small width=1%><a href=#types class=small>Types</a></td>"
				If n_keywords TPrint "<td class=small width=1%><a href=#keywords class=small>Keywords</a></td>"
				
				If Not infos.IsEmpty()
					TPrint "<td class=small width=1%><a href=#modinfo class=small>Modinfo</a></td>"
				EndIf
				
				Local t$=ModuleSource( ident.ToLower() )
				Local i=t.Find( "/mod/" )
				If i<>-1
					t="../../../.."+t[i..]
					TPrint "<td class=small width=1%><a href='"+t+"' class=small>Source</a></td>"
				EndIf
				TPrint "<td class=small>&nbsp;</td></tr></table>"
				
				Local stream:TStream=ReadStream( "intro.bbdoc" )
				
				If stream
					TPrint "<h1>"+textCache.shortdesc+"</h1>"
					If textCache.longdesc TPrint textCache.longdesc.Trim()
				Else
					stream=ReadStream( "intro.html" )
					If Not stream
						TPrint "<h1>"+textCache.shortdesc+"</h1>"
						If textCache.longdesc TPrint textCache.longdesc.Trim()
					EndIf
				EndIf
				
				If stream
					Local intro$
					While Not stream.Eof()
						intro:+stream.ReadLine()+"~n"
					Wend
					Local i=intro.Find("<body>")
					If i<>-1
						intro=intro[i+6..]
						i=intro.find("</body>")
						If i<>-1 intro=intro[..i]
					EndIf
					stream.close
					intro=intro.Trim()
					FormatText intro
					TPrint intro
				EndIf
	
				' Show summaries
				If Not kids.IsEmpty()
					Local s:String = Null
					Local tkind=0
					Local count:Int = 0
					For Local doc:TDocs=EachIn kids
						' kind is Type and is not doc'd and there are no doc'd kids
						If doc.kind = T_TYPE And (Not doc.bbdoc And doc.kids.count() = 0) Then
							Continue
						End If
					
						s = "<table class=doc width=100%>"
						
						If kind<>T_TYPE And doc.kind<>tkind
							count = 0
							If tkind <> 0 Then
								If tkind = T_CONST Or tkind = T_GLOBAL Or tkind = T_EOL Then
									TPrint "</td></tr>"
								End If
								TPrint "</table>"
							End If
							Select doc.kind
								Case T_CONST TPrint "<h2><a name=consts></a>Constants Summary</h2>" + s + "<tr><td colspan=2>"
								Case T_GLOBAL TPrint "<h2><a name=globals></a>Globals Summary</h2>" + s + "<tr><td colspan=2>"
								Case T_FUNCTION TPrint "<h2><a name=functions></a>Functions Summary</h2>" + s
								Case T_TYPE TPrint "<h2><a name=types></a>Types Summary</h2>" + s
								Case T_EOL TPrint "<h2><a name=keywords></a>Keywords Summary</h2>" + s + "<tr><td colspan=2>"
								Default
									Continue
							End Select
							tkind=doc.kind
						EndIf
						count:+ 1
						If count > 1 Then
							If tkind = T_CONST Or tkind = T_GLOBAL Or tkind = T_EOL Then
								TPrint ", "
							End If
						End If 
						doc.EmitHtml(True)
					Next
					If s Then
						TPrint "</table>"
					End If
				EndIf
						
			Default
				TPrint "<table class=doc width=100% cellspacing=3 id="+ident+">"
				TPrint "<tr><td class=doctop colspan=2>"+proto+"</td></tr>"
				If textCache.returns
					TPrint "<tr><td class=docleft width=1%>Returns</td><td class=docright>"+textCache.returns+"</td></tr>"
				EndIf
				If textCache.shortdesc
					TPrint "<tr><td class=docleft width=1%>Description</td><td class=docright>"+textCache.shortdesc+"</td></tr>"
				EndIf
				If textCache.longdesc
					TPrint "<tr><td class=docleft width=1%>Information</td><td class=docright>"+textCache.longdesc+"</td></tr>"
				EndIf
				If example
					TPrint "<tr><td class=docleft width=1%><a href="+ident+".bmx class=small>Example</a></td><td class=docright><pre>"+example+"</pre></td></tr>"
				EndIf
				TPrint "</table>"
			End Select

			If kind = T_TYPE Then
				' Show summaries
				If Not kids.IsEmpty()
					Local s:String = Null
					Local tkind=0
					Local count:Int = 0
					For Local doc:TDocs=EachIn kids
						s = "<table class=doc width=90% align=center>" + ..
							"<tr ><th class=doctop colspan=2 align=left>"
						If doc.kind<>tkind
							count = 0
							If tkind <> 0 Then
								If tkind = T_CONST Or tkind = T_GLOBAL Or tkind = T_EOL Or tkind = T_FIELD Then
									TPrint "</td></tr>"
								End If
								TPrint "</table>"
							End If
							Select doc.kind
								Case T_CONST TPrint s + "<a name=" + ident + "_consts></a>Constants Summary</th></tr><tr><td colspan=2>"
								Case T_FIELD TPrint s + "<a name=" + ident + "_fields></a>Fields Summary</th></tr><tr><td colspan=2>"
								Case T_GLOBAL TPrint s + "<a name=" + ident + "_globals></a>Globals Summary</th></tr><tr><td colspan=2>"
								Case T_FUNCTION TPrint s + "<a name=" + ident + "_functions></a>Functions Summary</th></tr>"
								Case T_METHOD TPrint s + "<a name=" + ident + "_methods></a>Methods Summary</th></tr>"
								Default
									Continue
							End Select
							tkind=doc.kind
						EndIf
						count:+ 1
						If count > 1 Then
							If tkind = T_CONST Or tkind = T_GLOBAL Or tkind = T_FIELD Then
								TPrint ", "
							End If
						End If 
						doc.EmitHtml(True)
					Next
					If s Then
						TPrint "</table>"
					End If
				EndIf
			End If

			If Not kids.IsEmpty()
				Local tkind=0
				For Local doc:TDocs=EachIn kids
					' kind is Type and is not doc'd and there are no doc'd kids
					If doc.kind = T_TYPE And (Not doc.bbdoc And doc.kids.count() = 0) Then
						Continue
					End If

					If kind<>T_TYPE And doc.kind<>tkind
						TPrint "<h2"
						Select doc.kind
						Case T_CONST TPrint " id=constsdet>Constants"
						Case T_GLOBAL TPrint " id=globalsdet>Globals"
						Case T_FUNCTION TPrint " id=functionsdet>Functions"
						Case T_TYPE TPrint " id=typesdet>Types"
						Case T_FIELD TPrint ">Fields"
						Case T_METHOD TPrint ">Methods"
						Case T_EOL TPrint ">Keywords"
						End Select
						TPrint "</h2>"
						tkind=doc.kind
					EndIf
					doc.EmitHtml
					If kind<>T_TYPE TPrint "<br>"
				Next
			EndIf			
		Else
			Select kind
				Case T_CONST, T_GLOBAL, T_FIELD, T_EOL
					TPrint "<a href=#" + ident + ">" + ident + "</a>"
				Case T_FUNCTION, T_METHOD, T_TYPE
					TPrint "<tr><td class=docleft width=1%><a href=#" + ident + ">" + ident + "</a></td><td class=docright>"
					If textCache.shortdesc
						TPrint textCache.shortdesc
					Else
						TPrint "&nbsp;"
					EndIf
					TPrint "</td></tr>"
			End Select
		End If
		

		
		Select kind
		Case T_MODULE
			If Not infos.IsEmpty()
				TPrint "<h2 id=modinfo>Module Information</h2>"
				TPrint "<table width=100%>"
				For Local t$=EachIn infos
					t=t[1..t.length-1]
					If Not t Continue
					Local i=t.Find(":")
					If i=-1 Continue
					Local key$=t[..i].Trim()
					Local val$=t[i+1..].Trim()
					TPrint "<tr><th width=1%>"+key+"</th><td>"+val+"</td></tr>"
				Next
			EndIf
			TPrint "</body></html>"
		End Select
		
	End Method

End Type

Type TDocParser

	Field toker:TBMXToker
	
	Method Close()
		If Not toker Return
		toker.Close
		toker=Null
	End Method

	' Added by BaH - 25/05/2006
	Method processImport(parent:TDocs, txt:String)
	
		If txt.find(".bmx") > 0 Then
	
			Local importFile:String = ExtractDir(toker._filename) + "/" + txt[1..txt.length-1]
			Local _file:String = StripDir(importFile).toLower()
			
			If Not parent.containsImport(_file) Then
				If FileType(importFile) = 1 Then ' exists !
					parent.imports.AddLast(_file)
					Local _toker:TBMXToker=TBMXToker.Create(importFile)
					Local _parser:TDocParser=TDocParser.WithToker(_toker)
					_parser.Parse parent
					_parser.Close
				End If
			End If
		End If
	
	End Method

	Method Parse( parent:TDocs )
	
		If Not toker Throw "closed"
	
		While toker.Curr()<>T_EOF

			If toker.Curr()=T_ENDTYPE 
				If parent.kind=T_TYPE Return
				toker.Bump
				Continue
			EndIf

			' Added by BaH - 25/05/2006, modified 01/06/2006
			If toker.Curr()=T_IMPORT Or toker.Curr()=T_INCLUDE Then
				If parent.kind=T_MODULE
					If toker.Bump()=T_STRINGLIT
						processImport(parent, Toker.Text())
					End If
				End If
			End If
			
			If toker.Curr()=T_MODULEINFO
				If parent.kind=T_MODULE 
					If toker.Bump()=T_STRINGLIT
						parent.infos.AddLast toker.Text()
					EndIf
				EndIf
				toker.Bump
				Continue
			EndIf
		
			Local skip:Int = False
			Local kind:Int
			Local bbdoc$
			
			If toker.Curr()<>T_REM 
				kind = toker.Bump()
				
				' Fix to stop fields / methods etc appearing at top of docs if type not doc'd.
				If kind = T_TYPE Then
					skip = True
				Else
					Continue
				End If
			EndIf
			
			If Not skip Then
				If toker.Text()[..6]<>"bbdoc:"
					toker.Bump
					Continue
				EndIf
				bbdoc = toker.Text()

			
				kind=toker.Bump()
				If kind<>T_CONST And kind<>T_GLOBAL And kind<>T_FUNCTION And kind<>T_METHOD..
				And kind<>T_MODULE And kind<>T_TYPE And kind<>T_FIELD And kind<>T_EOL
					toker.Bump
					Continue
				EndIf
			End If
			
			Local ident$,proto$
			If kind=T_EOL
				Local i=bbdoc.Find( "keyword:" )
				If i=-1 Continue
				ident=bbdoc[i+8..].Replace( "~q","" )
				proto="Keyword "+ident.Trim()
			Else
				proto=toker.Line()
				If toker.Bump()<>T_IDENT Continue
				ident=toker.Text()
				If toker.Bump()=Asc(".") And toker.Bump()=T_IDENT
					ident:+"."+toker.Text()
				EndIf
				toker.Bump
				Select kind
				Case T_CONST,T_GLOBAL
					Local i=proto.Find( "=" )
					If i<>-1 proto=proto[..i]
				Case T_FUNCTION,T_METHOD
					Local i=proto.Find( "=" )
					While i<>-1 And proto.Find( ")",i+1 )<>-1
						i=proto.Find( "=",i+1 )
					Wend
					If i<>-1 proto=proto[..i]
					
					
					i=proto.toLower().Find( "nodebug" )
					While i<>-1 And proto.Find( ")",i+1 )<>-1
						i=proto.toLower().Find( "nodebug",i+1 )
					Wend
					If i<>-1 proto=proto[..i]
					
				End Select
			EndIf
			
			'got a valid Doc!
			Local docs:TDocs=New TDocs
			docs.kind=kind
			docs.ident=ident.Trim()
			docs.proto=proto.Trim()
			docs.bbdoc=bbdoc.Trim()
			docs.parent = parent ' Added by BaH - 25/05/2006

			parent.kids.AddLast docs
			
			If kind=T_MODULE Or kind=T_TYPE
				Parse docs
			EndIf
			
		Wend
	
	End Method
	
	Function WithToker:TDocParser( toker:TBmxToker )
	
		Local t:TDocParser=New TDocParser
		t.toker=toker
		Return t

	End Function
	
End Type

Type TTextCache
	Field returns:String
	Field keyword:String
	Field shortdesc:String
	Field longdesc:String
	Field parameters:TList = New TList

	Function Create:TTextCache(bbdoc:String, kind:Int)
		Local this:TTextCache = New TTextCache
		
		Local d:String = bbdoc
		
		Local i=d.Find("~n")
		If i=-1 i=d.length
		this.shortdesc=d[6..i].Trim()
		d=d[i+1..].Trim()
		If kind<>T_MODULE 
			FormatText this.shortdesc
		EndIf
		
	     If d.Find( "returns:" )=0
			Local i=d.Find("~n")
			If i=-1 i=d.length
			this.returns=d[8..i].Trim()
			d=d[i+1..].Trim()
			FormatText this.returns
		Else If d.Find( "keyword:" )=0
			Local i=d.Find("~n")
			If i=-1 i=d.length
			this.keyword=d[8..i].Trim()
			d=d[i+1..].Trim()
			FormatText this.keyword
		EndIf
		While d.Find("parameter:") = 0
			Local i=d.Find("~n")
			If i=-1 i=d.length
			Local param:String=d[10..i].Trim()
			d=d[i+1..].Trim()
			FormatText param
			this.parameters.addLast(param)
		Wend
		If d.Find( "about:" )=0
			this.longdesc=d[6..].Trim()
			FormatText this.longdesc
		EndIf	
		
		Return this
	End Function
End Type