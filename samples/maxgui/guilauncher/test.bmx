Strict

Import "TLauncher.bmx"

Local myL:TLauncher
Local myMode:TGraphicsMode

'myL = TLauncher.Create() <- The quick way, will create a standard requester with only a 4:3 aspect ratio.

myL = New TLauncher

myL.addAspectRatio( 4 , 3 )
myL.addAspectRatio( 16 , 9 )
myL.populateModes

myL.initGUI()
myL.show()
While Not myL.terminate
	myL.main
EndWhile
If myL.selected <> Null
	Print myL.selected.toString()
EndIf

