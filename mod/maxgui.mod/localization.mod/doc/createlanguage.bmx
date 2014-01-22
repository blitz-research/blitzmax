' createlanguage.bmx

Strict

Import MaxGUI.Drivers

' Enable the localization engine, and automatically localize gadgets when they are created
SetLocalizationMode(LOCALIZATION_ON|LOCALIZATION_OVERRIDE)

Global window:TGadget = CreateWindow("{{window_title}}",100,100,320,240,Null,WINDOW_TITLEBAR|WINDOW_STATUS)
	
	Global btnEnglish:TGadget = CreateButton("{{btn_english}}",5,5,100,30,window,BUTTON_RADIO)
	Global btnFrench:TGadget = CreateButton("{{btn_french}}",5,40,100,30,window,BUTTON_RADIO)
	SetButtonState( btnEnglish, True )

' Create a new 'English' language
Global lngEnglish:TMaxGUILanguage = CreateLanguage("English (English)")

DefineLanguageToken( lngEnglish, "window_title", "My Window" )
DefineLanguageToken( lngEnglish, "btn_english", "English" )
DefineLanguageToken( lngEnglish, "btn_french", "French" )

' Create a new 'French' language
Global lngFrench:TMaxGUILanguage = CreateLanguage("Français (French)")

DefineLanguageToken( lngFrench, "window_title", "Ma Fenêtre" )
DefineLanguageToken( lngFrench, "btn_english", "Anglais" )
DefineLanguageToken( lngFrench, "btn_french", "Français" )

' Set the default language
SetLocalizationLanguage( lngEnglish )

Repeat
	SetStatusText window, LanguageName( LocalizationLanguage() )
	Select WaitEvent()
		Case EVENT_GADGETACTION
			Select EventSource()
				Case btnEnglish
					SetLocalizationLanguage( lngEnglish )
				Case btnFrench
					SetLocalizationLanguage( lngFrench )
			EndSelect
		Case EVENT_APPTERMINATE, EVENT_WINDOWCLOSE
			End
	EndSelect
Forever

