' drawtext.bmx

' scrolls a large text string across the screen by decrementing the tickerx variable

Graphics 640,480

Local tickerx#=640

text$="Yo to all the Apple, Windows and Linux BlitzMax programmers in the house! "
text:+"Game development is the most fun, most advanced and definitely most cool "
text:+"software programming there is!"

While Not KeyHit(KEY_ESCAPE)
	Cls
	DrawText "Scrolling Text Demo",0,0
	DrawText text,tickerx#,400
	tickerx=tickerx-1
	If tickerx<-TextWidth(text) tickerx=640
	Flip	
Wend

End