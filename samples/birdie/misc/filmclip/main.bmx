

Graphics 640,480,32

AutoMidHandle True
Global BMX01IMG:TImage = LoadImage("media/B-Max.png",FILTEREDIMAGE|DYNAMICIMAGE)
ConvertToBW BMX01IMG,0
Global FLM01IMG:TImage = LoadAnimImage("media/flmstp.png",126,66,0,10)

While Not KeyDown(KEY_ESCAPE)
  Cls

  SetColor 255,255,255
  SetBlend ALPHABLEND          
  SetScale 1,1
  SetAlpha Rnd(0.75,0.95)
  DrawImage bmx01img,320+Rnd(-1,1),240+Rnd(-1,1),0
  If Rand(40)=5
    SetColor 128,128,128
    SetBlend addativeBlend
    x=Rnd(640)
    DrawLine x,0,x+Rnd(-5,5),Rnd(400,480)
    EndIf
  SetBlend MASKBLEND
  SetColor 255,255,255
  SetScale 6.5,7.5
  DrawImage FLM01IMG,320,240,a
  a:+1
  a=a Mod 10
  Flip
Wend


Function ConvertToBW(i:TImage,frame)
  Local col,a,r,g,b,cc,x=0,y=0
  Local pix:TPixmap
  
  pix=LockImage(i,frame)
  While y<i.height
    x=0
    While x<i.width
      col = ReadPixel( pix, x, y )
      a = ( col & $ff000000)
      r = ( col & $ff0000 ) Shr 16
      g = ( col & $ff00 ) Shr 8
      b = ( col & $ff )
      cc= (r+g+b)/3
      col = a | (cc Shl 16) | (cc Shl 8) | cc
      WritePixel( pix, x, y, col )
      x=x+1
    Wend
    y=y+1
  Wend
  UnlockImage i,frame
EndFunction

