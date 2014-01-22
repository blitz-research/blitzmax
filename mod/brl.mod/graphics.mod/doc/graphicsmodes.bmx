
Print "Available graphics modes:"

For mode:TGraphicsMode=EachIn GraphicsModes()

	Print mode.width+","+mode.height+","+mode.depth+","+mode.hertz

Next
