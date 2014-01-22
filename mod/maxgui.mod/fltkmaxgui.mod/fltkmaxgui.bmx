Rem
bbdoc: MaxGUI Drivers/FLTKMaxGUI
End Rem
Module MaxGUI.FLTKMaxGUI

Strict

Import pub.zlib
Import pub.libpng
'Import pub.libjpeg

ModuleInfo "Version: 1.60"
ModuleInfo "Author: Simon Armstrong, Seb Hollington"
ModuleInfo "License: zlib/libpng"

ModuleInfo "Credit: FLTKMaxGUI is based in part on the work of the FLTK project (http://www.fltk.org)."
ModuleInfo "Credit: FLTKMaxGUI also uses the fantastic FLTK Utility Widgets from http://www.osc.edu/archive/FLU/ ."

?Linux
ModuleInfo "CC_OPTS: `freetype-config --cflags`"

Import "fltkgui.bmx"
?
