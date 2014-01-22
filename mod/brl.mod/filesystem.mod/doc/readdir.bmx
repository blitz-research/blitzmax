' readdir.bmx

dir=ReadDir(CurrentDir())

If Not dir RuntimeError "failed to read current directory"

Repeat
	t$=NextFile( dir )
	If t="" Exit
	If t="." Or t=".." Continue
	Print t	
Forever

CloseDir dir
