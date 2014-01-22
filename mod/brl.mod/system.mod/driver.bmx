
Strict

Type TSystemDriver

	Method Poll() Abstract
	Method Wait() Abstract
	
	Method MoveMouse( x,y ) Abstract
	Method SetMouseVisible( visible ) Abstract
	
	Method Notify( text$,serious ) Abstract
	Method Confirm( text$,serious ) Abstract
	Method Proceed( text$,serious ) Abstract
	Method RequestFile$( text$,exts$,save,file$ ) Abstract
	Method RequestDir$( text$,path$ ) Abstract

	Method OpenURL( url$ ) Abstract	
	
End Type

Global Driver:TSystemDriver
