
Strict

Import "docparser.bmx"

Local docs:TDocs=ParseMods()

docs.Sort

DocModHistory docs

End

If AppArgs.length=2 
	Select AppArgs[1].ToLower()
		Case "sync"
			SyncDocs docs
		Case "history"
			DocModHistory docs
	End Select	
Else
	DocMods docs
	SyncDocs docs
EndIf

' spit out versions.doc format history


Function DocModHistory( docs:TDocs )

	Local history$=LoadText("history120.txt")	
	
'	Local stdio:TStream=StandardIOStream
'	StandardIOStream=WriteFile( "commands.html" )

	For Local t:TDocs=EachIn docs.kids	
		If t.kind<>T_MODULE Continue
		For Local info$=EachIn t.infos
			If info[info.length-8..]<>"Release~q"
				If info[..8]="~qHistory" 
					Local h$="+ ("+t.ident+") "+info[10..info.length-1]
					If Not Instr(history,h) TPrint h
				EndIf
			EndIf
		Next
	
	Next

'	StandardIOStream.Close
'	StandardIOStream=stdio

End Function


Function ParseMods:TDocs()

	Local docs:TDocs=New TDocs
	
	Local mods:TList=EnumModules()
	
	For Local modid$=EachIn mods
			
		Local ident$=ModuleIdent( modid )
		Local modDir$=ModulePath( modid )
		Local bmxFile$=ModuleSource( modid )
		Local docDir$=modDir+"/doc"
		
		If FileType( modDir+"/"+ident+".bmx" )=FILETYPE_FILE
			If FileType( docDir )<>FILETYPE_DIR
				CreateDir docDir
				If FileType( docDir )<>FILETYPE_DIR
					TPrint "Failed to created directory:"+docDir
					Continue
				EndIf
			EndIf

			Local toker:TBMXToker=TBMXToker.Create( bmxFile )

			Local parser:TDocParser=TDocParser.WithToker( toker )
			
			parser.Parse docs
	
			parser.Close

		EndIf
		
	Next

	Return docs
	
End Function

Function DocMods( docs:TDocs )

	For Local t:TDocs=EachIn docs.kids
	
		If t.kind<>T_MODULE Continue
		
		ChangeDir ModulePath( t.ident.tolower() )+"/doc"	'linux fix for "BRL." case problem

		Local stdio:TStream=StandardIOStream
		StandardIOStream=WriteFile( "commands.html" )

		t.CacheTexts ' pre cache of text for output (allows us to use it for summaries etc) - BaH 03/09/2006
		t.EmitHtml

		StandardIOStream.Close
		StandardIOStream=stdio
	
	Next
End Function

Function SyncDocs( docs:TDocs )

	Local comms:TList=New TList
	Local index:TList=New TList
	
	Local stdio:TStream=StandardIOStream
	StandardIOStream=WriteFile( BlitzMaxPath()+"/doc/bmxmods/navbar.html" )
	
	TPrint "<html><head>"
	TPrint "<link rel=stylesheet type=text/css href='../bmxstyle.css'>"
	TPrint "<script>function toggle(a){if(a.display!='block')a.display='block';else a.display='none';}</script>"
	TPrint "</head><body class=navbar>"
	
	TPrint "<b>Module reference</b><br>"
	
	For Local t:TDocs=EachIn docs.kids

		If t.kind<>T_MODULE Continue
		
		Local modid$=t.ident.ToLower()
		Local modln$=modid.Replace(".","_")
		Local moddesc$=t.bbdoc[6..].Trim()
		Local i=moddesc.Find("~n")
		If i<>-1 moddesc=moddesc[..i]
		
		Local url$="../../mod/"+modid.Replace(".",".mod/")+".mod/doc/commands.html"
		
		TPrint "<a onClick=toggle("+modln+".style) class=navbig href="+url+" target=main>"+moddesc+"</a><br>"
		TPrint "<div id="+modln+" class=entries>"
		For Local p:TDocs=EachIn t.kids
			' kind is Type and is not doc'd and there are no doc'd kids
			If p.kind = T_TYPE And (Not p.bbdoc And p.kids.count() = 0) Then
				Continue
			End If
			Local turl$=url+"#"+p.ident
			TPrint "&nbsp;<a class=navsmall href="+turl+" target=main>"+p.ident+"</a><br>"
			index.AddLast p.ident+":"+turl
			Local i=p.proto.Find( " " )
			If i<>-1 comms.AddLast p.proto[i+1..].Trim()+"|"+turl[5..]
		Next
		TPrint "</div>"

	Next
	
	TPrint "<br>"
	TPrint "<b>Alphabetic index</b><br>"

	Local arr:Object[]=index.ToArray()
	arr.Sort
	For Local link$=EachIn arr
		Local i=link.Find( ":" )
		If i=-1 Throw "chunks"
		Local ident$=link[..i],url$=link[i+1..]
		TPrint "<a class=navsmall href="+url+" target=main>"+ident+"</a><br>"
	Next
	
	TPrint "</body></html>"
	
	StandardIOStream.Close
	StandardIOStream=WriteStream( BlitzMaxPath()+"/doc/bmxmods/commands.txt" )
	For Local t$=EachIn comms
		TPrint t
	Next
	StandardIOStream.Close
	StandardIOStream=stdio

End Function

