Strict

Rem
bbdoc: MaxGUI/Localization
End Rem
Module MaxGUI.Localization

ModuleInfo "Version: 1.02"
ModuleInfo "Author: Seb Hollington"
ModuleInfo "License: zlib/libpng"

Import BRL.System
Import "language.bmx"

Const LOCALIZATION_OFF:Int = 0
Const LOCALIZATION_ON:Int = 1

Rem
bbdoc: Returns the localized version of a string.
about: This function takes one parameter: @{localizationstring$}.

A localization string is just like any other string except that any phrase enclosed in a double pair of
curly-braces is identified as a localization token.  For example, the following examples all use valid
localization strings.

{{
LocalizeString("{{welcomemessage}}")                      'Localization token(s): welcomemessage
LocalizeString("{{apptitlelabel}}: {{AppTitle}}")         'Localization token(s): apptitlelabel, AppTitle
LocalizeString("Current Time: {{CurrentTime}}")           'Localization token(s): CurrentTime
}}

Localization tokens are case insensitive, and may be made up of any combination of alphanumeric
characters.  Firstly, the token is tested to see if it is a reserved word.  The following tokens
are currently reserved (although more maybe added in the future):

[ @{Localization Token} | @{Token Will Be Replaced With...}
* AppDir | The value of the #AppDir global constant.
* AppFile | The value of the #AppFile global constant.
* AppTitle | The value of the #AppTitle global constant.
* LaunchDir | The value of the #LaunchDir global constant.
* GCMemAlloced | The value returned by the #GCMemAlloced function (at the moment the token is parsed).
]

There are also some reserved date and time tokens which will display the current date and time (at the
moment of parsing) using any formats defined in the current language.  If there are no matching formats
explicitly defined, the formats default to:

[ @{Localization Token} | @{Default Format} | @{Sample Output}
* ShortTime | "hh:mm pp" | 02:36 {{pm}}
* LongTime | "hh:mm:ss" | 14:36:51
* ShortDate | "dd/mm/yy" | 04/08/09
* LongDate | "dddd oo mmmm yyyy" | {{Monday}} {{4th}} {{August}} 2009
]

Notice how any text-based time and date information is wrapped in curly braces.  These tokens will be
localized, just like any other token, and so can be modified by adding a corresponding entry to the
localization language.

This also demonstrates the ability of the localization parser to handle nested tokens.  To prevent lock-
ups, the localization parser checks for cyclic token definitions, and if one is encountered the token will
be simply replaced with '!ERROR!' and the the offending localization string will be identified in the warning
message written to standard error.

If and only if the localization token isn't reserved will the current localization language be queried.  If
no localization language is selected, or if there is no matching token defined in the current language, the
token will simply be stripped of its curly braces in the returned string.  Each language is required to have
at least one token defined: {{LanguageID}}.  This should represent the language name e.g. 'Fran�ais (French)'.

%{NOTE: This function requires the LOCALIZATION_ON flag to be set (see #SetLocalizationMode) otherwise
the function will simply return @{localizationstring$} exactly as it was passed (including any curly braces).}

See Also: #SetLocalizationMode, #LocalizationMode, #SetLocalizationLanguage and #LocalizationLanguage.
EndRem
Function LocalizeString$( localizationstring$ )
	Return TMaxGUILocalizationEngine.LocalizeString( localizationstring )
EndFunction


Rem
bbdoc: Enable or disable the localization engine, and set other localization modes.
about: The mode can be set to:

[ @{Constant} | @{Meaning}
* LOCALIZATION_OFF | Any localized gadgets will display their localizedtext$ as their actual text.
* LOCALIZATION_ON | Localized gadgets will use the current language to display their text.
]

Either mode can be combined (btiwse OR'd) with LOCALIZATION_OVERRIDE, which will cause gadgets
to become automatically 'localized' when they are created, with any @{text$} parameters supplied
to the @{CreateGadget()} functions being interpreted as localization strings.

If any window menus are localized, #UpdateWindowMenu may have to be called on all relevant windows for the text changes
to be visible.

See Also: #LocalizationMode, #SetLocalizationLanguage, #LocalizationLanguage and #LocalizeGadget.
EndRem
Function SetLocalizationMode( mode:Int = LOCALIZATION_ON )
	_SetLocalizationMode(mode:Int)
EndFunction

Global _SetLocalizationMode( mode:Int ) = TMaxGUILocalizationEngine.SetMode

Rem
bbdoc: Returns the value previously set using #SetLocalizationMode.
about: The default value for a MaxGUI program is LOCALIZATION_OFF.

See #SetLocalizationMode for valid modes, and their corresponding constants.
EndRem
Function LocalizationMode:Int()
	Return TMaxGUILocalizationEngine.GetMode()
EndFunction

Rem
bbdoc: Set the language to be used by MaxGUI's localization system.
about: Languages can be loaded from files/streams using #LoadLanguage and created from scratch using
#CreateLanguage.

This function will automatically update the text of any gadget marked as 'localized' using #LocalizeGadget.

If any window menus are localized, #UpdateWindowMenu may have to be called on all relevant windows for the text changes
to be visible.

See Also: #LocalizationLanguage, #SetLocalizationMode, #LocalizationMode and #LocalizeString.
EndRem
Function SetLocalizationLanguage( language:TMaxGUILanguage )
	_SetLocalizationLanguage( language )
EndFunction

Global _SetLocalizationLanguage( language:TMaxGUILanguage ) = TMaxGUILocalizationEngine.SetLanguage

Rem
bbdoc: Returns the current language used by MaxGUI's localization system.
about: Use the #DefineLanguageToken, #RemoveLanguageToken and #ClearLanguageTokens commands to add to and
modify the returned language.  #SetLanguageName and #LanguageName may also be useful.

about: See Also: #SetLocalizationLanguage, #SetLocalizationMode, #LocalizationMode and #LocalizeGadget.
EndRem
Function LocalizationLanguage:TMaxGUILanguage()
	Return TMaxGUILocalizationEngine.GetLanguage()
EndFunction

Private

Type TMaxGUILocalizationEngine
	
	Global intLocalizationMode:Int = LOCALIZATION_OFF
	Global _currentLanguage:TMaxGUILanguage
	Global _localizeStack:String[]
	
	Method New()
		Return Null
	EndMethod
	
	' Indirection allows MaxGUI.MaxGUI's TMaxGUIDriver to intercept function calls
	' and update gadgets if necessary (see bottom of maxgui.mod/driver.bmx).
	Global SetMode( mode:Int ) = TMaxGUILocalizationEngine._SetMode
	Global SetLanguage( language:TMaxGUILanguage ) = TMaxGUILocalizationEngine._SetLanguage
	
	Function _SetMode( mode:Int )
		intLocalizationMode = mode
	EndFunction
	
	Function GetMode:Int()
		Return intLocalizationMode
	EndFunction
	
	Function GetLanguage:TMaxGUILanguage()
		Return _currentLanguage
	EndFunction
	
	Function _SetLanguage( language:TMaxGUILanguage )
		_currentLanguage = language
	EndFunction
	
	Function LocalizeString:String( Text$ )
		
		' Only localize the string if the localization engine is turned on.
		If (intLocalizationMode&LOCALIZATION_ON) Then
			
			' Check for cyclic definitions by comparing localization string with those on the stack.
			For Local i:Int = _localizeStack.length-1 To 0 Step -1
				If _localizeStack[i] = Text Then
					WriteStderr "WARNING: Encountered cyclic localization string: ~q"+_localizeStack[i]+"~q.~n"
					Return "!ERROR!"
				EndIf
			Next
			
			' Add localization string to the stack.
			_localizeStack:+[Text]
			
			Local tmpText:String
			Local i:Int, tmpPrevChar:Int		
			Local tmpCount:Int, tmpOpenings:Int[Text.length/2]		'manages opening character index for nested tokens
			
			' Start parsing for curly braces
			While i < Text.length
				Select Text[i]
					Case Asc("{")
					
						'If previous char was also an opening "{" then we're entering into a token
						If tmpPrevChar = Text[i] Then
							tmpOpenings[tmpCount] = i+1
							tmpCount:+1
							tmpPrevChar = 0
							
						'Otherwise update the value of the last char and move onto the next character.
						Else
							tmpPrevChar = Text[i]
						EndIf
						
					Case Asc("}")
						
						'If previous char was also a closing "}" then we're leaving a token, so interpret it.
						If tmpPrevChar = Text[i] Then
							
							' Retrieve the token text
							tmpCount:-1
							tmpText = Text[tmpOpenings[tmpCount]..i-1]
							
							' Check for reserved words or run it through the dictionary.
							Select tmpText.ToLower()
								
								' Keywords
								Case "appfile";tmpText = AppFile
								Case "appdir";tmpText = AppDir
								Case "apptitle";tmpText = AppTitle
								Case "launchdir";tmpText = LaunchDir
								Case "gcmemalloced";tmpText = GCMemAlloced()
								
								' Time parsing
								Case "shorttime", "longtime"
									' Check if the current language defines its own time format for the token
									If _currentLanguage Then tmpText = LocalizeString(_currentLanguage.LookupToken(tmpText))
									' Either way, call LocalizeTime() and then localize the returned string (in case it contains tokens too).
									tmpText = LocalizeString(LocalizedTime(tmpText))
									
								' Date parsing
								Case "shortdate", "longdate"
									' Check if the current language defines its own date format for the token
									If _currentLanguage Then tmpText = LocalizeString(_currentLanguage.LookupToken(tmpText))
									' Either way, call LocalizeDate() and then localize the returned string (in case it contains tokens too).
									tmpText = LocalizeString(LocalizedDate(tmpText))
									
								' Language definition
								Default
									If _currentLanguage Then
										' Lookup token using the current language, and localize the returned string (in case that contains tokens).
										tmpText = LocalizeString(_currentLanguage.LookupToken(tmpText))
									EndIf
									
							EndSelect
							
							' Substitute the localized text into the string in-place, to enable nested parsing to work.
							Text = Text[..tmpOpenings[tmpCount]-2] + tmpText + Text[i+1..]
							i:+(tmpText.length-(i+3-tmpOpenings[tmpCount]))
							tmpPrevChar = 0
							
						'Otherwise update the value of the last char and move onto the next character.
						Else
							tmpPrevChar = Text[i]
						EndIf
						
					Default
						tmpPrevChar = 0
				EndSelect
				i:+1
			Wend
			
			' Remove localization string from stack as we're about to return
			_localizeStack = _localizeStack[.._localizeStack.length-1]
			
		EndIf
		
		' Return the localized text.
		Return Text
		
	EndFunction
	
	Function LocalizedTime:String(pTimeFormat$)
		Local i:Int = 0, tmpTokenCount:Int = 0, tmpToken$, tmpTime:String[] = CurrentTime().Split(":")
		Select pTimeFormat.ToLower()
			Case "shorttime";pTimeFormat = "hh:mm "
			Case "longtime";pTimeFormat = "hh:mm:ss "
			Default;pTimeFormat:+" "
		EndSelect
		While i < pTimeFormat.length
			
			If tmpTokenCount And (pTimeFormat[i-1] <> pTimeFormat[i]) Then
				tmpToken = Null
				Select pTimeFormat[i-1]
					Case Asc("h")
						Select tmpTokenCount
							Case 1;tmpToken = Int(tmpTime[0]) Mod 12
							Case 2;tmpToken = Int(tmpTime[0])
						EndSelect
					Case Asc("m")
						Select tmpTokenCount
							Case 1;tmpToken = Int(tmpTime[1])
							Case 2;tmpToken = tmpTime[1]
						EndSelect
					Case Asc("s")
						Select tmpTokenCount
							Case 1;tmpToken = Int(tmpTime[2])
							Case 2;tmpToken = tmpTime[2]
						EndSelect
					Case Asc("p")
						If tmpTokenCount = 2 Then
							If tmpTime[0] < 12 Then tmpToken = "{{am}}" Else tmpToken = "{{pm}}"
						EndIf
				EndSelect
				If tmpToken
					pTimeFormat = pTimeFormat[..(i-tmpTokenCount)] + tmpToken + pTimeFormat[i..]
					i:+tmpToken.length-tmpTokenCount
				EndIf
				tmpTokenCount = 0
			EndIf
			
			Select pTimeFormat[i]
				Case "h"[0],"m"[0],"s"[0],"p"[0]
					tmpTokenCount:+1
				Default
					tmpTokenCount = 0
			EndSelect
			
			i:+1
			
		Wend
		Return pTimeFormat[..pTimeFormat.length-1]
	EndFunction
	
	Function LocalizedDate:String(pDateFormat$)
		Local i:Int = 0, tmpTokenCount:Int = 0, tmpToken$, tmpDate:String[] = CurrentDate().Split(" ")
		Select pDateFormat.ToLower()
			Case "shortdate";pDateFormat= "dd/mm/yy "
			Case "longdate";pDateFormat = "dddd oo mmmm yyyy "
			Default;pDateFormat:+" "
		EndSelect
		While i < pDateFormat.length
			
			If tmpTokenCount And (pDateFormat[i-1] <> pDateFormat[i]) Then
				tmpToken = Null
				Select pDateFormat[i-1]
					Case Asc("d")
						Select tmpTokenCount
							Case 1;tmpToken = Int(tmpDate[0])
							Case 2;tmpToken = tmpDate[0]
							Case 3,4
								Local tmpDayAsInt:Int = DayOfTheWeek(Int(tmpDate[0]),_MonthAsNumber(tmpDate[1]),Int(tmpDate[2]))
								If tmpTokenCount = 3 Then tmpToken = "{{"+_shortDays[tmpDayAsInt]+"}}" Else tmpToken = "{{"+_fullDays[tmpDayAsInt]+"}}"
						EndSelect
					Case Asc("m")
						Select tmpTokenCount
							Case 1,2
								Local tmpMonth:Int = _MonthAsNumber(tmpDate[1])
								If tmpTokenCount = 1 And tmpMonth < 10 Then tmpToken = " " + tmpMonth Else tmpToken = tmpMonth
							Case 3;tmpToken = "{{"+tmpDate[1]+"}}"
							Case 4;tmpToken = "{{" + _fullMonths[_MonthAsNumber(tmpDate[1])] + "}}"
						EndSelect
					Case Asc("y")
						Select tmpTokenCount
							Case 2;tmpToken = tmpDate[2][tmpDate.length-2..]
							Case 4;tmpToken = tmpDate[2]
						EndSelect
					Case Asc("o")
						If tmpTokenCount = 2 Then
							Select Int(tmpDate[0])
								Case 1,21,31;tmpToken = "{{" + Int(tmpDate[0]) + "st}}"
								Case 2,22;tmpToken = "{{" + Int(tmpDate[0]) + "nd}}"
								Case 3,23;tmpToken = "{{" + Int(tmpDate[0]) + "rd}}"
								Default;tmpToken = "{{" + Int(tmpDate[0]) + "th}}"
							EndSelect
						EndIf
				EndSelect
				If tmpToken
					pDateFormat = pDateFormat[..(i-tmpTokenCount)] + tmpToken + pDateFormat[i..]
					i:+tmpToken.length-tmpTokenCount
				EndIf
				tmpTokenCount = 0
			EndIf
			
			Select pDateFormat[i]
				Case Asc("d"),Asc("m"),Asc("y"),Asc("o")
					tmpTokenCount:+1
				Default
					tmpTokenCount = 0
			EndSelect
			
			i:+1
		Wend
		Return pDateFormat[..pDateFormat.length-1]
	EndFunction
	
	Global _fullMonths:String[] = ["", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
	Global _shortDays:String[] = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
	Global _fullDays:String[] = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
	
	Function _MonthAsNumber:Int(month$)
		Select month.ToLower()
			Case "jan";Return 1
			Case "feb";Return 2
			Case "mar";Return 3
			Case "apr";Return 4
			Case "may";Return 5
			Case "jun";Return 6
			Case "jul";Return 7
			Case "aug";Return 8
			Case "sep";Return 9
			Case "oct";Return 10
			Case "nov";Return 11
			Case "dec";Return 12
		EndSelect
		RuntimeError "Unrecognised month: ~q" + month + "~q"
	EndFunction
	
	Function DayOfTheWeek:Int(Day:Int, Month:Int, Year:Int)
		Local Jt:Float = Float(367 * Year - ((7 * (Year + 5001 + ((Month - 9) / 7))) / 4) + ((275 * Month) / 9) + Day + 1729777)+1.5
		Return (jt Mod 7)
	End Function

EndType
