
Rem

Build new style docs.

Only builds official docs and brl, maxgui and pub modules.

Calls 'docmods' first, which builds 3rd party modules.

End Rem

Strict

Framework BRL.Basic

Import "docnode.bmx"

Import "fredborgstyle.bmx"

system_ "~q"+BlitzMaxPath()+"/bin/docmods~q"

Local style:TDocStyle=New TFredborgStyle

DeleteDir BmxDocDir,True

CopyDir BlitzMaxPath()+"/docs/src",BmxDocDir

Local root:TDocNode=TDocNode.Create( "BlitzMax Help","/","/" )
root.about=LoadText( BmxDocDir+"/index.html" )

DocMods

DocBBDocs "/"

style.EmitDoc TDocNode.ForPath( "/" )

Local t$
For Local kv:TKeyValue=EachIn TDocStyle.commands
	t:+String( kv.Key() )+"|/docs/html"+String( kv.Value() )+"~n"
Next

Local p$=BlitzMaxPath()+"/doc/bmxmods/commands.txt"
If FileType( p )=FILETYPE_FILE t:+LoadText( p )

SaveText t,BmxDocDir+"/Modules/commands.txt"

Cleanup BmxDocDir

'*****

Function Cleanup( dir$ )
	For Local e$=EachIn LoadDir( dir )
		Local p$=dir+"/"+e
		Select FileType( p )
		Case FILETYPE_DIR
			Cleanup p
		Case FILETYPE_FILE
			If ExtractExt( e )="bbdoc"
				DeleteFile p
			Else If e.ToLower()="commands.html"
				DeleteFile p
			EndIf
		End Select
	Next
End Function

Function DocMods()

	For Local modid$=EachIn EnumModules()

		If Not modid.StartsWith( "brl." ) And Not modid.StartsWith( "pub." ) And Not modid.StartsWith("maxgui.") Continue

		Local p$=ModuleSource( modid )
		Try
			docBmxFile p,""
		Catch ex$
			Print "Error:"+ex
		End Try
	Next

End Function

Function DocBBDocs( docPath$ )

	Local p$=BmxDocDir+docPath
	
	For Local e$=EachIn LoadDir( p )

		Local q$=p+"/"+e

		Select FileType( q )
		Case FILETYPE_FILE
			Select ExtractExt( e )
			Case "bbdoc"
				Local id$=StripExt( e )
				If id="index" Or id="intro" Continue
				
				Local path$=(docPath+"/"+id).Replace( "//","/" )
				Local node:TDocNode=TDocNode.Create( id,path,"/" )
				
				node.about=LoadText( q )
			End Select
		Case FILETYPE_DIR
			DocBBDocs docPath+"/"+e
		End Select
	Next
	
End Function

Function docBmxFile( filePath$,docPath$ )

	If FileType( filePath )<>FILETYPE_FILE
		Print "Error: Unable to open '"+filePath+"'"
		Return
	EndIf

	Local docDir$=ExtractDir( filePath )+"/doc"
	If FileType( docDir )<>FILETYPE_DIR docDir=""

	Local inrem,typePath$,section$
	
	Local bbdoc$,returns$,about$,keyword$,params:TList
	
	Local text$=LoadText( filepath )
	
	For Local line$=EachIn text.Split( "~n" )

		line=line.Trim()
		Local tline$=line.ToLower()
		
		Local i
		Local id$=ParseIdent( tline,i )
		
		If id="end" id:+ParseIdent( tline,i )
		
		If i<tline.length And tline[i]=Asc(":")
			id:+":"
			i:+1
		EndIf
		
		If inrem
		
			If id="endrem"
			
				inrem=False
				
			Else If id="bbdoc:"
			
				bbdoc=line[i..].Trim()
				keyword=""
				returns=""
				about=""
				params=Null
				section="bbdoc"

			Else If bbdoc 
			
				Select id
				Case "keyword:"
					keyword=line[i..].Trim()
					section="keyword"
				Case "returns:"
					returns=line[i..].Trim()+"~n"
					section="returns"
				Case "about:"
					about=line[i..].Trim()+"~n"
					section="about"
				Case "param:"
					If Not params params=New TList
					params.AddLast line[6..].Trim()
					section="param"
				Default
					Select section
					Case "about"
						about:+line+"~n"
					Case "returns"
						returns:+" "+line
					Case "param"
						params.AddLast String( params.RemoveLast() )+" "+line
					Default
						'remaining sections 1 line only...
						If line Print "Error: Illegal bbdoc section in '"+filePath+"'"
					End Select
				End Select
			
			EndIf
		
		Else If id="rem"
		
			bbdoc=""
			inrem=True
			
		Else If id="endtype"

			If typePath
				docPath=typePath
				typePath=""
			EndIf
			
		Else If id="import" Or id="include"
		
			Local p$=ExtractDir( filePath )+"/"+ParseString( line,i )
			
			If ExtractExt( p ).ToLower()="bmx"
				docBmxFile p,docPath
			EndIf
		
		Else If bbdoc
		
			Local kind$,proto$
			
			If keyword
				id=keyword
				kind="Keyword"
				If id.StartsWith( "~q" ) And id.EndsWith( "~q" )
					id=id[1..id.length-1]
				EndIf
				proto=id
			Else If id
				For Local t$=EachIn AllKinds
					If id<>t.ToLower() Continue
					kind=t
					proto=line
					id=ParseIdent( line,i )
					Exit
				Next
			EndIf
			
			If kind

				Local path$

				Select kind
				Case "Type"
					If Not docPath Throw "No doc path"
					If typePath Throw "Type path already set"
					typePath=docPath
					docPath:+"/"+id
					path=docPath
				Case "Module"
					If docPath Throw "Doc path already set"
					If bbdoc.FindLast( "/" )=-1
						bbdoc="Other/"+bbdoc
					EndIf
					docPath="/Modules/"+bbdoc
					path=docPath
					Local i=bbdoc.FindLast( "/" )
					bbdoc=bbdoc[i+1..]
				Default
					If Not docPath Throw "No doc path"
					path=docPath+"/"+id
				End Select
				
				Local i=proto.Find( ")=" )
				If i<>-1 
					proto=proto[..i+1]
					If id.StartsWith( "Sort" ) proto:+" )"	'lazy!!!!!
				EndIf
				i=proto.Find( "=New" )
				If i<>-1
					proto=proto[..i]
				EndIf
				
				Local node:TDocNode=TDocNode.Create( id,path,kind )
				
				node.proto=proto
				node.bbdoc=bbdoc
				node.returns=returns
				node.about=about
				node.params=params
				
				If kind="Module" node.docDir=docDir
				
				Local tmpExampleFilePath$ = CasedFileName(docDir+"/"+id+".bmx")
				If docDir And FileType( tmpExampleFilePath )=FILETYPE_FILE
					node.example=StripDir(tmpExampleFilePath)
				EndIf
				
			EndIf
			
			bbdoc=""

		EndIf
	Next
	
End Function
