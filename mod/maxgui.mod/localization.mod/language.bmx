Strict

Import Brl.Map
Import Brl.TextStream

Rem
bbdoc: Create a new empty language to be used with MaxGUI's localization system. 
about: This function is provided in case it is necessary to create a new language from scratch. 
In the majority of cases, languages should instead be loaded from INI files using #LoadLanguage. 

Use the #DefineLanguageToken, #RemoveLanguageToken and #ClearLanguageTokens commands to add to and 
modify the returned language.  #SetLanguageName and #LanguageName may also be useful.

See Also: #LoadLanguage, #SetLocalizationLanguage, #LocalizeString and #LocalizeGadget.
EndRem
Function CreateLanguage:TMaxGuiLanguage( name$ )
	Return New TMaxGuiLanguage.Create(name)
EndFunction

Rem
bbdoc: Load a language from an INI text stream.
about: @{url} can be a filepath or any other readable #TStream object.

The INI text stream must contain, at minimum, an INI section labelled '[LanguageDefinition]' and 
a 'LanguageID' token which should be assigned an appropriate language name.

A typical language INI file may look something like:

{{
[LanguageDefinition]

LanguageID = Français (French)
LanguageVersion = v0.1
LanguageAuthor = Various Sources

; Toolbar Tips
tb_new                                       = "Nouveau"
tb_open                                      = "Ouvrir"
tb_close                                     = "Fermer"
tb_save                                      = "Enregistrer"
tb_cut                                       = "Couper"
tb_copy                                      = "Copier"
tb_paste                                     = "Coller"
...
tb_home                                      = "Page d'Accueil"
tb_back                                      = "Précédente"
tb_forward                                   = "Suivante"

; Tabs
tab_help                                     = "Aide"
tab_output                                   = "Sortie"
tab_locked:%1                                = "construction:%1"

; Time Format, by example: 13:09:02
; h = 1 (12 hour clock)       hh = 13 (24 hour clock)
; m = 9 (without leading 0)   mm = 09 (including leading 0)
; s = 2 (without leading 0)   ss = 02 (including leading 0)
; pp = {{pm}} (or '{{am}}' from 00:00 -> 11:59)

longtime = hh:mm:ss pp
shorttime = {{longtime}}          ; We want short time to be formatted exactly like {{longtime}}

; Date Format, by example: 9th June 2009
; d = 9    dd = 09    ddd = {{Wed}}    dddd = {{Wednesday}}
; m = 6    mm = 06    mmm = {{Jun}}    mmmm = {{June}}
; yy = 09  yyyy = 2009             oo = {{9th}}

longdate = dddd oo mmmm dddd      ; e.g. Wednesday 9th June 2009
shortdate = dd/mm/yy              ; e.g. 09/06/09

; AM / PM
am = AM
pm = PM

; Ordinals

1st = 1e
2nd = 2er
3rd = 3e
4th = 4e
; etc.

; Days of the week

Monday = "Lundi"
Mon = "Lun"
Tueday = "Mardi"
Tue = "Mar"
Wednesday = "Mercredi"
Wed = "Mer"
Thursday = "Jeudi"
Thu = "Jeu"
Friday = "Vendredi"
Fri = "Ven"
Saturday = "Samedi"
Sat = "Sam"
Sunday = "Dimanche"
Sun = "Dim"
}}

Note how a semicolon ';' is used to mark the start of a line comment.

INI files support the following escape sequence characters:

[ @{INI Escape Sequence} | @{BlitzMax Equivalent}  
* \\ | ~\ 
* \r | ~~r 
* \n | ~~n 
* \t | ~~t
* \# | ~# 
* \; | ; 
* \: | : 
] 

The bottom three escape sequences are only strictly required if the value of the INI key is not enclosed 
in quotes.  For example, the following definitions are expected to evaluate to the same string ( ~#;: ).

{{ 
	MyToken = \#\;\:
	MyToken = "#;:"
	MyToken = "\#\;\:"
}}

Use the #DefineLanguageToken, #RemoveLanguageToken and #ClearLanguageTokens commands to add to and 
modify the returned language.  #SetLanguageName and #LanguageName may also be useful.

To construct a new language from scratch, use the #CreateLanguage command instead.

See Also: #SetLocalizationLanguage, #SaveLanguage, #LocalizeString and #LocalizeGadget.
EndRem
Function LoadLanguage:TMaxGuiLanguage( url:Object )
	Return TMaxGuiLanguage.LoadLanguage(url)
EndFunction

Rem
bbdoc: Saves a language as an INI section to the supplied stream.
about: @{url} can be a filepath or any other writable #TStream object.

If @{url} is a string ending in "/" or "\", it is assumed that @{url} is a directory path and a default filename 
will be appended like so:

{{
url = String(url) + LanguageName(language).Split(" ")[0] + ".language.ini"
}}

WARNING: This command will automatically overwrite any existing file at the supplied/resulting file path.

See Also: #LoadLanguage, #SetLocalizationLanguage, #LocalizeString and #LocalizeGadget.
EndRem
Function SaveLanguage( language:TMaxGuiLanguage, url:Object )
	If Not TStream(url) And (String(url).EndsWith("/") Or String(url).EndsWith("\")) Then 
		url = String(url) + language.GetName().Split(" ")[0] + ".language.ini"
	EndIf
	SaveText( language.Serialize(), url )
EndFunction

Rem
bbdoc: Redefine a language's name.
about: See Also: #LanguageName, #LoadLanguage, #CreateLanguage and #SetLocalizationLanguage.
EndRem
Function SetLanguageName( language:TMaxGuiLanguage, name$ )
	language.SetName(name)
EndFunction

Rem
bbdoc: Returns a language's name.
about: See Also: #SetLanguageName, #LoadLanguage, #CreateLanguage and #SetLocalizationLanguage.
EndRem
Function LanguageName$( language:TMaxGuiLanguage )
	Return language.GetName()
EndFunction

Rem
bbdoc: Define a language-specific value for a localization token.
about: Localization tokens are case insensitive, and if a token definition already exists in the language
the token value will be overwritten with this most recent @{value$}.

See Also: #LoadLanguage, #CreateLanguage, #SaveLanguage and #SetLocalizationLanguage.
EndRem
Function DefineLanguageToken( language:TMaxGuiLanguage, token$, value$ )
	language.DefineToken(token,value)
EndFunction

Rem
bbdoc: Look-up the value of a token for a specific language.
about: Localization tokens are case insensitive, and are either loaded in with the language or defined
using the #DefineLanguageToken command.

If an explicit token definition is not found in the language, the @{token$} string is returned as it was passed.

See Also: #LoadLanguage, #CreateLanguage, #SaveLanguage and #SetLocalizationLanguage.
EndRem
Function LanguageTokenDefinition$( language:TMaxGuiLanguage, token$ )
	Return language.LookupToken(token)
EndFunction

Rem
bbdoc: Remove a token definition from a language.
about: The only token which cannot be removed is 'LanguageID' as every language requires this one token to be defined -
it defines the language name.  If a matching token isn't already defined, then the command returns silently.

Note: Localization tokens are case insensitive so the following commands are all requesting the same token to be removed:

{{
RemoveLanguageToken( language, "WelcomeMessage" )
RemoveLanguageToken( language, "WELCOMEMESSAGE" )
RemoveLanguageToken( language, "welcomemessage" )
RemoveLanguageToken( language, "WeLcOmEmEsSaGe" )
}}

See Also: #ClearLanguageTokens, #DefineLanguageToken, #LoadLanguage, #CreateLanguage, #SaveLanguage and #SetLocalizationLanguage.
EndRem
Function RemoveLanguageToken( language:TMaxGuiLanguage, token$ )
	language.RemoveToken(token)
EndFunction

Rem
bbdoc: Removes all the tokens defined in a language.
about: The only token which will not be removed is 'LanguageID' as every language requires this one token to be defined -
it defines the language name.

See Also: #RemoveLanguageToken, #DefineLanguageToken, #LoadLanguage, #CreateLanguage, #SaveLanguage and #SetLocalizationLanguage.
EndRem
Function ClearLanguageTokens( language:TMaxGuiLanguage )
	language.ClearTokens()
EndFunction

Type TMaxGuiLanguage
	
	?Win32
	Const CARRIAGE_RETURN:String = "~r~n"
	?Not Win32
	Const CARRIAGE_RETURN:String = "~n"
	?
	
	Const SECTION_HEADER:String = "LanguageDefinition"
	Const LANGUAGENAME_TOKEN:String = "LanguageId"
	
	Field strName:String = "Unknown Language"
	Field mapDictionary:TMap = CreateMap()
	
	Method Create:TMaxGuiLanguage(name$)
		SetName(name)
		Return Self
	EndMethod
	
	Method SetName(pName$)
		DefineToken( LANGUAGENAME_TOKEN, pName )
	EndMethod
	
	Method GetName$()
		Return strName
	EndMethod
	
	Method DefineToken( pToken:String, pText:String )
		If pToken Then
			If pToken = LANGUAGENAME_TOKEN Then strName = pText
			MapInsert( mapDictionary, pToken.ToLower(), Prepare(pText) )
		EndIf
	EndMethod
	
	Method RemoveToken( pToken:String )
		If pToken And pToken.ToLower() <> LANGUAGENAME_TOKEN.ToLower() Then MapRemove( mapDictionary, pToken.ToLower() )
	EndMethod
	
	Method LookupToken$(pToken$)
		Local tmpValue$ = String(MapValueForKey( mapDictionary, pToken.ToLower() ))
		If tmpValue Then Return Prepare(tmpValue) Else Return pToken
	EndMethod
	
	Method ClearTokens()
		ClearMap mapDictionary
		SetName(GetName())
	EndMethod
	
	Method LoadEntriesFromText( text:String )
		
		'Very rough INI section parser
		
		Local tmpIndex:Int, tmpStage:Int = 0
		
		For Local tmpLine:String = EachIn text.Split("~n")
			
			tmpStage = 0
			
			'Search for valid ';' comment
			For tmpIndex = 0 Until tmpLine.length
				Select tmpLine[tmpIndex]
					Case Asc("~q");If tmpStage <> 0 Then tmpStage = 2
					Case Asc("=");If tmpStage = 0 Then tmpStage = 1
					Case Asc(";")
						If tmpStage = 0 Or tmpStage = 1 Then
							Exit
						Else 
							If tmpLine[tmpIndex-1] <> Asc("\") Then tmpStage = 0-(tmpIndex)
						EndIf
				EndSelect
			Next
			
			'Strip the comment if ';' was the last character
			If tmpStage < 0 Then tmpLine = tmpLine[..Abs(tmpStage)]
			
			'Strip any whitespace
			tmpLine = StripWhitespace(tmpLine[..tmpIndex])
			If Not tmpLine Then Continue
			
			'Test for a new section header
			If tmpLine[0] = "["[0] Then Exit
			
			'Slow but easy code to handle any escape characters
			tmpLine = tmpLine.Replace("\\","~0").Replace("\r","~r").Replace("\n","~n").Replace("\;",";").Replace("\#","#").Replace("\:",":").Replace("\t","~t").Replace("~0","\")
			
			'Find the separator
			tmpIndex = tmpLine.Find("=")
			
			'If we have a key/value pair, define a new key in our dictionary.
			If tmpIndex > 0 Then DefineToken( StripWhitespace(tmpLine[..tmpIndex],True), StripWhitespace(tmpLine[tmpIndex+1..],True) )
		Next
		
	EndMethod
	
	Method Serialize:String()
		
		Local tmpString:String = "["+SECTION_HEADER+"]" + CARRIAGE_RETURN + LANGUAGENAME_TOKEN + " = ~q" + GetName() + "~q" + CARRIAGE_RETURN
		For Local tmpKey:String = EachIn MapKeys(mapDictionary)
			If tmpKey <> LANGUAGENAME_TOKEN Then
				tmpString:+tmpKey+" = ~q"+String(MapValueForKey(mapDictionary,tmpKey))+"~q"+CARRIAGE_RETURN
			EndIf
		Next
		Return tmpString
		
	EndMethod
	
	Method Deserialize:TMaxGuiLanguage(pString$)
		
		Local tmpIndex:Int = pString.Find("["+SECTION_HEADER+"]")
		If tmpIndex < 0 Then Return Null
		
		tmpIndex = pString.Find("~n",tmpIndex+SECTION_HEADER.length+2)
		If tmpIndex < 0 Then Return Null
		
		If pString.ToLower().Find(LANGUAGENAME_TOKEN.ToLower(),tmpIndex+1) < 0 Then Return Null
		
		ClearMap mapDictionary
		LoadEntriesFromText( pString[tmpIndex..] )
		
		Return Self
	EndMethod
	
	Function LoadLanguage:TMaxGUILanguage( stream:Object )
		
		Return New TMaxGuiLanguage.Deserialize( LoadText(stream) )
		
	EndFunction
	
	Function StripWhitespace:String( text$, pStripQuotes:Int = False )
		Local i:Int, j:Int
		For i = 0 Until text.length
			If text[i] = " "[0] Or text[i] = "~t"[0] Then Continue
			Exit
		Next
		For j = text.length-1 To i Step -1
			If text[j] = " "[0] Or text[j] = "~t"[0] Or text[j] = "~r"[0] Then Continue
			Exit
		Next
		If pStripQuotes And (j-i)>0 And text[i] = "~q"[0] And text[j] = "~q"[0] Then
			i:+1;j:-1
		EndIf
		Return text[i..j+1]
	EndFunction
	
	Function Prepare$(text$)
		If text="~0" Then Return "" ElseIf text="" Then Return "~0"
		Return text
	EndFunction
	
EndType
