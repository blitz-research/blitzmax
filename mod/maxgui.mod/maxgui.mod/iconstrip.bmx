Strict

Import BRL.Pixmap

Type TIconStrip
	
	Field pixmap:TPixmap
	Field count
	
	Method ExtractIconPixmap:TPixmap(index:Int)
		If (index>=count) Then Return Null
		If (index < 0) Then Return pixmap.Copy()
		Return pixmap.Window(index*pixmap.height,0,pixmap.height,pixmap.height)
	EndMethod
	
EndType
