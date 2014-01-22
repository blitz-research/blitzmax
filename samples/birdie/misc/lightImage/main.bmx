'
' Using Lightblend/image as a light
'
Strict

'Include media in the final file
Incbin "media/fl.png"
Incbin "media/light.png"
Incbin "media/B-Max.png"

'set the graphics mode
Graphics 640, 480, 32

'Hide the pointer
HideMouse

'All images will be handled from the center
AutoMidHandle True

'Load images in now. incbin points the file to the included images
Global backImage:TImage = LoadImage("incbin::media/fl.png")
Global logoImage:TImage = LoadImage("incbin::media/B-Max.png")
Global lightImage:TImage = LoadImage("incbin::media/light.png")

'setup some vars now
Local x#, y#, tim#
Local mx, my
Local lightcolor[] = [255,255,255]
Local BackColor[]  = [128,128,128]

'Main Loop
While Not KeyDown(KEY_ESCAPE)
  x:+5*Sin(tim)
  y:+1
  tim:+4
  mx = MouseX()
  my = MouseY()

  'draw the backgound
  SetScale 1,1
  SetColor BackColor[0],BackColor[1],BackColor[2]
  TileImage backImage,x,y

  'draw the logo
  SetBlend MaskBlend
  SetColor 0,0,0
  DrawImage logoimage,340,260
  SetColor 100,100,100
  DrawImage logoimage,320,240

  'Draw the light
  SetBlend LightBlend
  SetColor LightColor[0],LightColor[1],LightColor[2]
  SetScale 1.5+1*Cos(tim), 1.5+1*Cos(tim)
  DrawImage lightimage, mx, my
  
  'draw the mousepointer
  SetBlend SolidBlend
  SetColor 255,255,255
  SetScale 1,1
  DrawLine mx-5,my,mx+5,my
  DrawLine mx,my-5,mx,my+5
  Flip
Wend

End

