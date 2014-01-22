'===============================================================================
' Little Shooty Test Thing
' Code & Stuff by Richard Olpin (rik@olpin.net)
'===============================================================================
' Background.bmx
'
' Module for tilemapped background layer
'
'===============================================================================

Global bgtileset, bgwidth=256
Global skyfade, cloud
Global direction=1
Global map:Int[6,1000,2]
Global worldpos

'==============================================================================
' Init BG
'==============================================================================

Function CreateBG()
	bgtileset=LoadAnimImage:TImage("gfx/hill_1.png",256,256,0,9, MASKEDIMAGE )	
	skyfade=LoadAnimImage:TImage("gfx/sky32.png",32,32,0,48 )	
	cloud = LoadImage:TImage("gfx/bigcloud.png")
	RandomMap()
EndFunction

'==============================================================================
' Note: 
'==============================================================================

Function RenderBackground( worldx, worldy)

	Local sframe,soffset,lx
	Local layerpos, mappos, offset

	'-------------------------------
	' Sky
	'-------------------------------	

	SetBlend ALPHABLEND
	SetAlpha 1
	SetRotation 0
	SetScale 1,1

	If y_offset<0 Then y_offset=0
	If y_offset>600 Then y_offset=600
	
	sframe = Int(y_offset/32) ; If sframe>24 Then sframe=24
	soffset = y_offset Mod 32

  	For x = 0 To WIDTH Step 32
		For y=0 To 18	
			DrawImage skyfade,x,(y*32)-soffset,sframe+y
		Next
	Next

	'-------------------------------
	' Clouds
	'-------------------------------	

	SetBlend ALPHABLEND
	SetAlpha 0.25
	DrawImage cloud,sky_pos, 100
	
	'-------------------------------
	' Hills
	'-------------------------------	
	SetAlpha 1
 
	' layerpos = scaled from worldpos for parallax
	' map_pos = offset into Map
	' offset = shift for 
						
	layerpos = worldpos/8
	mappos 	= Int(layerpos/bgwidth)
	offset 	= layerpos Mod bgwidth
		
	For x = 0 To 5
  		DrawImage bgtileset,(x*bgwidth)-offset,380-(y_offset/12), map[5,mappos+x,0]
	Next	

	layerpos = worldpos/6
	mappos 	= Int(layerpos/bgwidth)
	offset 	= layerpos Mod bgwidth
	
	For x = 0 To 5
  		DrawImage bgtileset,(x*bgwidth)-offset,430-(y_offset/11), map[4,mappos+x,0]
	Next	

	layerpos = worldpos/4
	mappos 	= Int(layerpos/bgwidth)
	offset 	= layerpos Mod bgwidth

	For x = 0 To 5
  		DrawImage bgtileset,(x*bgwidth)-offset,480-(y_offset/10), map[3,mappos+x,0]
	Next	

	layerpos = worldpos/2
	mappos 	= Int(layerpos/bgwidth)
	offset 	= layerpos Mod bgwidth

	For x = 0 To 5
  		DrawImage bgtileset,(x*bgwidth)-offset,530-(y_offset/9), map[2,mappos+x,0]
	Next	
		
	'----------------------------------
	' Layer 1 Hills with collisions
	'----------------------------------
	
	SetAlpha 1
		
	mappos 	= Int(worldpos/bgwidth)
	offset 	= worldpos Mod bgwidth
	
	For x = 0 To 5
  		DrawImage    bgtileset,(x*bgwidth)-offset,480, map[1,mappos+x,0]
'		CollideImage bgtileset,(x*bgwidth)-offset,480, map[1,mappos+x,0],0,2
	Next	
	
End Function


'===============================================================================
' Description:
'
' Quick hack to test the concept. Need to sort this out fully. 
'
'===============================================================================

Function MoveBg()

	sky_pos = sky_pos - (scroll_speed/32)
	If sky_pos<-256 Then sky_pos=1000

  worldpos=worldpos + scroll_speed
 
End Function

'==============================================================================
' Random Map
'
' Test function only to randomise map data
'==============================================================================

Function RandomMap()
	Local h=0, l=0,pos=0

	For h=0 To 5
	
		pos=0
	
		While pos<980
			
			'--------------------------
			' Hill 
			map(h,pos,0)=1 ' Hill ramp up	
			pos:+1	
			l=Rand(5)
			If h=1 Then l=Rand(10)
			If h=5 Then l=Rand(20)  
									
			While l>0
				map(h,pos,0)=Rand(2,7)
				pos:+1
				l:-1
			Wend
			
			map(h,pos,0)=8 ' Hill ramp down
			pos:+1		
			
			'--------------------------
			' Gap 
			
			l=Rand(3)
			While l>0
				If pos<1000 map(h,pos,0)=0
				pos:+1
				l:-1
			Wend
			
			
		Wend

	Next

End Function


'===============================================================================
' END OF FILE
'===============================================================================
