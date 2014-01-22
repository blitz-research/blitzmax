
Strict

Rem
bbdoc: MaxGUI/Drivers
about:
Your MaxGUI applications should import this module if they want BlitzMax to selectively import the latest official #{MaxGUI drivers} for your application and platform:

[ @Platform | @{Default Driver}
* Windows 2000/XP/Vista | #MaxGUI.Win32MaxGUIEx
* Windows 9X | #MaxGUI.Win32MaxGUIEx (requires unicows.dll or MSLU to run)
* Linux | #MaxGUI.FLTKMaxGUI
* Mac OS X | #MaxGUI.CocoaMaxGUI
]
End Rem
Module MaxGUI.Drivers

ModuleInfo "Version: 0.04"
ModuleInfo "Author: Simon Armstrong"
ModuleInfo "License: zlib/libpng"

?Win32
Import MaxGUI.Win32MaxGUIEx
Import "-lunicows"
?MacOs
Import Maxgui.CocoaMaxGui
?Linux
Import Maxgui.FLTKMaxGui
?
