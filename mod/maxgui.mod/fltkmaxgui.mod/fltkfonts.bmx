Strict

Import MaxGUI.MaxGUI
Import "fltkimports.bmx"
Private
Include "fltkdecls.bmx"
Public

Type TFLGUIFont Extends TGUIFont
	
	Field flfamily:TFLFontFamily
	
	Function LoadFont:TFLGUIFont( name$,height:Double,flags )
		Local tmpFLGUIFont:TFLGUIFont = New TFLGUIFont.SetFont(name,height,flags)
		tmpFLGUIFont.Initialize()
		Return tmpFLGUIFont
	EndFunction
	
	Method SetFont:TFLGUIFont( name$,height:Double,flags )
		Self.name = name
		Self.style = flags
		Self.size = height
		Return Self
	EndMethod
	
	Method CharWidth( charcode )
		Return 0
	EndMethod
	
	Method GetSizeForFl:Double()
		?Win32
		Return size+2
		?Not Win32
		Return size
		?
	EndMethod
	
	Method Initialize()
		flfamily = TFLFontFamily.GetFamily( name )
		handle = flfamily.GetFontID(style)
	EndMethod
	
	'Sort by family name, then by size and finally by style.
	Method Compare( o:Object )
		Local f:TFLGUIFont = TFLGUIFont(o)
		If Not f Then Return Super.Compare(o)
		Local tmpComparison% = flFamily.Compare(f.flfamily)
		If tmpComparison Then Return tmpComparison
		If (size = f.size) Then
			Return (style-f.style)
		Else
			Return (size-f.size)
		EndIf
	EndMethod
	
EndType

Type TFLFontFamily
	
	Const IDSTYLEMASK% = (FL_BOLD|FL_ITALIC)
	
	Global arrFamilies:TFLFontFamily[], intLoadedAll% = False
	Global defaultSizes:Int[] = [8, 10, 11, 12, 14, 16, 18, 20, 24, 32, 36, 42, 48, 64, 72]
	
	Global fmyDefault:TFLFontFamily
	
	Field strName$, strLowName$, intSizes[], intStyles, ids[IDSTYLEMASK+1]
	
	Function Initialize()
		fmyDefault = TFLFontFamily.GetFamily( TFLFontFamily.FriendlyNameFromID( FL_HELVETICA ) )
	EndFunction
	
	Function GetFamily:TFLFontFamily( name$ )
		Local tmpFamily:TFLFontFamily = LoadFamily( name$ )
		If tmpFamily Then Return tmpFamily Else Return fmyDefault
	EndFunction
	
	Function FindFamily:TFLFontFamily( name$ )
		name = name.ToLower()
		For Local tmpFamily:TFLFontFamily = EachIn arrFamilies
			If name = tmpFamily.strLowName Then Return tmpFamily
		Next
	EndFunction
	
	Function LoadAll:TFLFontFamily[]()
		Local tmpLastName$ = "", tmpFamily:TFLFontFamily
		If Not intLoadedAll Then intLoadedAll = True Else Return arrFamilies
		For Local id=0 Until flCountFonts()
			Local f$=FriendlyNameFromID(id)
			If f <> tmpLastName Then
				tmpFamily = FindFamily( f )
				If Not tmpFamily Then
					tmpFamily = FamilyFromSingleID(id)
				EndIf
			EndIf
			Local tmpStyle% = StyleFromID(id)
			tmpFamily.intStyles:|tmpStyle
			tmpFamily.ids[tmpStyle] = id
			tmpLastName = f
		Next
		
		arrFamilies.Sort()
		
		Return arrFamilies
	EndFunction
	
	Function LoadFamily:TFLFontFamily( name$ )
		
		Local tmpFamily:TFLFontFamily = FindFamily( name$ )
		If tmpFamily Then Return tmpFamily
		
		name = name.ToLower()
		
		For Local id=0 Until flCountFonts()
			Local f$=FriendlyNameFromID(id).ToLower()
			If f = name Then
				If Not tmpFamily Then tmpFamily = FamilyFromSingleID(id)
				Local tmpStyle% = StyleFromID(id)
				tmpFamily.intStyles:|tmpStyle
				tmpFamily.ids[tmpStyle] = id
			EndIf
		Next
		
		arrFamilies.Sort()
		
		Return tmpFamily
		
	EndFunction
	
	Function FamilyFromSingleID:TFLFontFamily(id)
		Local tmpFamily:TFLFontFamily = New TFLFontFamily
		tmpFamily.strName = FriendlyNameFromID(id)
		tmpFamily.strLowName = tmpFamily.strName.ToLower()
		Local tmpSizes:Int
		For Local i% = 0 Until flFontSizes(id,Varptr tmpSizes)
			If i = 0 And Int Ptr(tmpSizes)[i] = 0 Then
				tmpFamily.intSizes = defaultSizes
				Exit
			EndIf
			tmpFamily.intSizes:+[Int Ptr(tmpSizes)[i]]
		Next
		arrFamilies:+[tmpFamily]
		Return tmpFamily
	EndFunction
	
	Function NameFromID$(id)
		Return flFontName(id)
	End Function
	
	Function FriendlyNameFromID$(id)
		Local tmpName$ = flFriendlyFontName(id)
		If tmpName.EndsWith(" bold") Then tmpName = tmpName[..tmpName.length-5]
		If tmpName.EndsWith(" bold italic") Then tmpName = tmpName[..tmpName.length-12]
		If tmpName.EndsWith(" italic") Then tmpName = tmpName[..tmpName.length-7]
		Return tmpName
	End Function
	
	Function StyleFromID(id)
		Return flFriendlyFontAttributes(id)
	EndFunction
	
	Method GetFontID(style)
		style:&IDSTYLEMASK
		If (intStyles&style)=style Then Return ids[style]
		For Local id = EachIn ids
			If id Then Return id
		Next
	End Method
	
	Method GetFamilySizes:Int[]()
		Return intSizes
	EndMethod
	
	Method Compare( o:Object )
		Local f:TFLFontFamily=TFLFontFamily(o)
		If Not f Then Return Super.Compare(o)
		Return strLowName.Compare( f.strLowName )
	End Method
	
End Type

Type TFLFontRequest
	Field	open, currentfont:TFLGUIFont
	
	Field	window:TGadget
	Field	fontbox:TGadget,stylebox:TGadget,sizebox:TGadget,sizetext:TGadget,samplebox:TGadget
	Field	ok:TGadget,cancel:TGadget
	
	Method New()
		Initialize()
	EndMethod

	Method Refresh(font:TFLGUIFont)
		SetFamily( font.flfamily )
		SetStyle( font.style )
		SetSize( Int(font.size) )
		SetGadgetFont samplebox, font
	End Method
	
	Field currentSize% = -1
	
	Method GetSize()
		If currentSize < 0 Then Return 12 Else Return currentSize
	EndMethod
	
	Method SetSize( size% )
		currentSize = size
		SetGadgetText( sizetext, size )
		For Local i% = CountGadgetItems( sizebox )-1 To 0 Step -1
			If Int(GadgetItemText( sizebox, i )) = size Then
				SelectGadgetItem sizebox, i
				Return
			EndIf
		Next
		If SelectedGadgetItem( sizebox ) > -1 Then DeselectGadgetItem( sizebox, SelectedGadgetItem ( sizebox ) )
	EndMethod
	
	Field currentStyle% = -1
	
	Method GetStyle()
		Return Max( currentStyle, FONT_NORMAL )
	EndMethod
	
	Method SetStyle( style% )
		currentStyle = style
		If SelectedGadgetItem( styleBox ) <> currentStyle Then
			If currentStyle < 0 Then DeselectGadgetItem( stylebox, SelectedGadgetItem( stylebox ) ) Else SelectGadgetItem( stylebox, Min(currentStyle, CountGadgetItems( stylebox )-1 ) )
		EndIf
	EndMethod
	
	Method GetFont:TFLGUIFont()
		Local tmpFamily:TFLFontFamily = GetFamily()
		Local tmpFont:TFLGUIFont = New TFLGUIFont.SetFont( tmpFamily.strName, GetSize(), GetStyle() )
		tmpFont.flfamily = tmpFamily;tmpFont.handle = tmpFamily.GetFontID(GetStyle())
		Return tmpFont
	End Method
	
	Method GetFamily:TFLFontFamily()
		Local tmpFamily:TFLFontFamily = TFLFontFamily.fmyDefault
		If SelectedGadgetItem(fontbox) > -1 Then
			tmpFamily = TFLFontFamily ( GadgetItemExtra( fontbox, SelectedGadgetItem( fontbox ) ) )
		EndIf
		Return tmpFamily
	EndMethod

	Method SetFamily( family:TFLFontFamily )
		For Local i% = 0 Until CountGadgetItems( fontbox )
			Local tmpItemFamily:TFLFontFamily = TFLFontFamily(GadgetItemExtra( fontbox, i ))
			If tmpItemFamily = family Then
				SelectGadgetItem fontbox, i
				
				ClearGadgetItems stylebox
				AddGadgetItem stylebox, "Regular", 0, -1, "", String(FONT_NORMAL)
				If family.intStyles&FONT_BOLD Then AddGadgetItem stylebox, "Bold", 0, -1, "", String(FONT_BOLD)
				If family.intStyles&FONT_ITALIC Then AddGadgetItem stylebox, "Italic", 0, -1, "", String(FONT_ITALIC)
				If (family.intStyles&(FONT_ITALIC|FONT_BOLD))=FONT_BOLD|FONT_ITALIC Then
					AddGadgetItem stylebox, "Bold & Italic", 0, -1, "", String(FONT_BOLD|FONT_ITALIC)
				EndIf
				currentStyle = Min(currentStyle,family.intStyles)
				
				ClearGadgetItems sizebox
				For Local tmpSize% = EachIn family.intSizes
					AddGadgetItem sizebox, tmpSize
				Next
				
				Return
			EndIf
		Next
	EndMethod

	Function RequestHandler:Object(id,data:Object,context:Object)
		Local this:TFLFontRequest
		Local event:TEvent
		event=TEvent(data)
		If event
			this=TFLFontRequest(context)
			If this this.OnEvent event
		EndIf
	End Function

	Method OnEvent(event:TEvent)
		Local item = event.data
		Select event.id
			Case EVENT_GADGETSELECT, EVENT_GADGETACTION
				Select event.source
					Case fontbox
						SetFamily TFLFontFamily(event.extra)
						Refresh(GetFont())
					Case stylebox
						If event.data < 0 Then
							currentStyle = -1
						Else
							currentStyle = Int( String( GadgetItemExtra( stylebox, event.data ) ) )
						EndIf
						Refresh(GetFont())
					Case sizebox
						If event.data < 0 Then
							currentSize = -1
						Else
							currentSize = Int( GadgetItemText( sizebox, event.data ) )
						EndIf
						Refresh(GetFont())
					Case cancel
						currentfont = Null
						open=False
					Case ok
						currentfont = GetFont()
						open=False
				End Select
			Case EVENT_GADGETLOSTFOCUS
				Select event.source
					Case sizetext
						Local tmpText$ = GadgetText(sizetext)
						If tmpText Then
							Local tmpInt% = Max(Int( tmpText ), 0)
							If tmpInt = tmpText Then
								currentSize = tmpInt
								Refresh(GetFont())
							EndIf
						EndIf
				End Select
			Case EVENT_WINDOWCLOSE
				Select event.source
					Case window
						currentfont = Null
						open=False
				EndSelect
		EndSelect
	End Method
	
	Method Request:TFLGUIFont(font:TFLGUIFont)
		open=True;currentfont = Null
		AddHook EmitEventHook,RequestHandler,Self,100000
		Local tmpParent:TGadget = ActiveGadget()
		While tmpParent And tmpParent.Class() <> GADGET_WINDOW
			tmpParent = GadgetGroup(tmpParent)
		Wend
		If Not tmpParent Then tmpParent = Desktop()
		SetGadgetShape( window, GadgetX(tmpParent)+50, GadgetY(tmpParent)+50, ClientWidth(window), ClientHeight(window) )
		ShowGadget window
		If font Then Refresh(font)
		While open
			WaitSystem()
		Wend
		RemoveHook EmitEventHook,RequestHandler,Self
		HideGadget window
		Return currentfont
	End Method
	
	Method Initialize()
		window=CreateWindow("Choose a font...",0,0,392,284,Null,WINDOW_TITLEBAR|WINDOW_HIDDEN|WINDOW_CLIENTCOORDS|WINDOW_CENTER)
		flSetModal(QueryGadget(window,QUERY_FLWIDGET))
		CreateLabel "Font:",4,4,200,24,window
		fontbox=CreateListBox(4,28,200,ClientHeight(window)-134,window)
		CreateLabel "Style:",214,4,100,24,window
		stylebox=CreateListBox(214,28,100,ClientHeight(window)-134,window)
		CreateLabel "Size:",324,4,64,24,window
		sizetext=CreateTextField(324,28,64,21,window)
		sizebox=CreateListBox(324,49,64,ClientHeight(window)-155,window)
		SetGadgetFilter(sizetext,NumberFilter)
		Local y=ClientHeight(window)-102
		samplebox=CreateLabel("Sample Text",4,y,ClientWidth(window)-8,64,window,LABEL_CENTER|LABEL_SUNKENFRAME)
		cancel=CreateButton("Cancel",4,ClientHeight(window)-30,80,26,window,BUTTON_CANCEL)
		ok=CreateButton("OK",ClientWidth(window)-4-80,ClientHeight(window)-30,80,26,window,BUTTON_OK)
		For Local tmpFamily:TFLFontFamily = EachIn TFLFontFamily.LoadAll()
			AddGadgetItem fontbox,tmpFamily.strName, 0, -1, "", tmpFamily
		Next
	End Method
	
	Function NumberFilter( event:TEvent, context:Object )
		Select event.id
			Case EVENT_KEYCHAR
				If (event.data > "9"[0] Or event.data < "0"[0]) And (event.data <> 8) Then
					Return False
				Else
					Return True
				EndIf
		EndSelect
		Return True
	EndFunction
	
EndType
