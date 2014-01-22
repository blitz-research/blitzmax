
Strict

Import "docstyle.bmx"

Type TFredborgStyle Extends TDocStyle

	Method EmitHeader()

		'emit HTML header	
		Emit "<html><head><title>"+doc.id+"</title>"
		Emit "<link rel=stylesheet Type=text/css href=~q"+relRootDir+"/styles/fredborg.css~q>"
		Emit "</head><body>"
		
		'emit title bar
		Emit "<table width=100% cellspacing=0><tr align=center><td class=small>&nbsp;</td>"
		Emit "<td class=small width=1%><b>"+doc.id+":</b></td>"

		'emit links to summaries		
		For Local t$=EachIn allKinds
			If t="/" Or Not ChildList( t ) Continue

			Emit "<td class=small width=1%><a href=#_"+t+" class=small>"+t+"s</a></td>"

		Next

		'emit link to module source
		If doc.kind="Module"
			Local t$=ModuleSource( doc.id.ToLower() ),i=t.Find( "/mod/" )
			If i<>-1
				t=relRootDir+"/../.."+t[i..]
				Emit "<td class=small width=1%><a href='"+t+"' class=small>Source</a></td>"
			EndIf
		EndIf
		
		'end title bar
		Emit "<td class=small>&nbsp;</td></tr></table><br><br>"
		
		'emit about
		If doc.about Emit doc.about+"<br><br>"

	End Method
	
	Method EmitFooter()

		'emit HTML footer
		Emit "</body></html>"

	End Method
	
	Method EmitLinks( kind$ )

		Local list:TList=ChildList( kind )
		If Not list Return
		
		'emit anchor: _Const, _Function etc...
		
		If kind="/"
		
			Emit "<table class=doc cellspacing=3>"
			
			For Local t:TDocNode=EachIn list
			
				Emit "<tr><td class=docleft width=1%> #{"+t.id+"}</td></tr>"
	
			Next
	
			Emit "</table>"
		
		Else
		
			Emit "<a name=_"+kind+"></a>"
			Emit "<h2>"+kind+"s</h2>"
		
			Emit "<table class=doc width=100% cellspacing=3>"
			
			For Local t:TDocNode=EachIn list
			
				Emit "<tr><td class=docleft width=1%> #{"+t.id+"}</td><td class=docright>"+t.bbdoc+"</td></tr>"
	
			Next
	
			Emit "</table>"
		EndIf
	
	End Method
	
	Method EmitDecls( kind$ )

		Local list:TList=ChildList( kind )
		If Not list Return
		
		Emit "<h2>"+kind+" reference</h2>"
		
		For Local t:TDocNode=EachIn list
		
			Emit "<a name=~q"+t.id+"~q></a>"
		
			Emit "<p><table class=doc width=100% cellspacing=3>"
			Emit "<tr><td class=doctop colspan=2>"+t.proto+"</td></tr>"

			If t.returns
				Emit "<tr><td class=docleft width=1%>Returns</td><td class=docright>"+t.returns+"</td></tr>"
			EndIf

			If t.bbdoc
				Emit "<tr><td class=docleft width=1%>Description</td><td class=docright>"+t.bbdoc+"</td></tr>"
			EndIf

			If t.about
				Emit "<tr><td class=docleft width=1%>Information</td><td class=docright>"+t.about+"</td></tr>"
			EndIf
			
			If t.example 
				Local p$=t.example
				Local link$="<a href=~q"+p+"~q>Example</a>"
				Local code$=LoadText( absDocDir+"/"+p ).Trim()
				code="~n{{~n"+code+"~n}}~n"
				Emit "<tr><td class=docleft width=1%>"+link+"</td><td class=docright>"+code+"</td></tr>"
			EndIf
	
			Emit "</table>"
		
		Next
		
	End Method

End Type
