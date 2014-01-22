
Strict

Import BRL.Map

Type TDocNode

	Field id$			'eg: BRL.Audio
	Field path$		'eg: Modules/Audio/Audio"
	Field kind$		'eg: "Module", "Function", "Type" etc
	
	Field proto$		'eg: Function LoadImage(...)
	Field bbdoc$		'eg: Load an image (shortdesc?)
	Field returns$	'eg: A new image
	Field about$		'eg: blah etc blah (longdesc?)
	Field params:TList	'eg: [x - the x coord, y - the y coord]
	
	Field docDir$		'eg: ../mod/brl.mod/max2d.mod/doc
	Field example$	'eg: LoadImage.bmx (path)
	
	Field children:TList=New TList
	
	Function ForPath:TDocNode( path$ )

		Return TDocNode( _pathMap.ValueForKey( path ) )

	End Function
	
	Function Create:TDocNode( id$,path$,kind$ )
	
		Local t:TDocNode=TDocNode( _pathMap.ValueForKey( path ) )
		
		If t
			If t.kind<>"/" And t.path<>path Throw "ERROR: "+t.kind+" "+kind
			If t.path = path Return t
		Else
			t=New TDocNode
			_pathMap.Insert path,t
		EndIf

		t.id=id
		t.path=path
		t.kind=kind
		
		Local q:TDocNode=t
		
		Repeat
			If path="/" Exit
			path=ExtractDir( path )
			Local p:TDocNode=TDocNode( _pathMap.ValueForKey( path ) )
			If p
				p.children.AddLast q
				Exit
			EndIf
			p=New TDocNode
			p.id=StripDir(path)
			p.path=path
			p.kind="/"
			p.children.AddLast q
			_pathMap.Insert path,p
			q=p
		Forever
		
		Return t
	End Function
	
	Global _pathMap:TMap=New TMap

End Type
