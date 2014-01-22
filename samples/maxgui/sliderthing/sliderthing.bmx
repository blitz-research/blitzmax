'
' www.sublimegames.com
' Silly picture tool by Stephen Greener (aka Shagwana)
'
'

Strict
Import MaxGUI.Drivers


'_/ Consts \_______________________________________________________________________________________________________________
 

Const iLEVEL_X_PIXEL_SIZE:Int = 32
Const iLEVEL_Y_PIXEL_SIZE:Int = 32

Const iLEVEL_X_SIZE:Int = 512 / iLEVEL_X_PIXEL_SIZE
Const iLEVEL_Y_SIZE:Int = 512 / iLEVEL_Y_PIXEL_SIZE


'_/ Includes \_______________________________________________________________________________________________________________



'Image files
Incbin "sourcepic.jpg"   '512x512 


'_/ Types \_______________________________________________________________________________________________________________



Type tLevelInfo

  Field pImage:TImage[iLEVEL_X_SIZE,iLEVEL_Y_SIZE]
  Field pMapping:TImage[iLEVEL_X_SIZE,iLEVEL_Y_SIZE]


  Method Reset()
    For Local iX:Int=0 To iLEVEL_X_SIZE-1
      For Local iY:Int=0 To iLEVEL_Y_SIZE-1
        pMapping[iX,iY]=pImage[iX,iY]
        Next
      Next
    End Method

  Method Load(sFilename:String)
    'Load the image
    Local pPixmap:TPixmap=LoadPixmap(sFilename)
    pPixmap:TPixmap=ConvertPixmap(pPixmap:TPixmap,PF_BGR888)
    For Local iX:Int=0 To iLEVEL_X_SIZE-1
      For Local iY:Int=0 To iLEVEL_Y_SIZE-1
        Local tWinPixMap:TPixmap=PixmapWindow(pPixmap:TPixmap,iX*iLEVEL_X_PIXEL_SIZE,iY*iLEVEL_Y_PIXEL_SIZE,iLEVEL_X_PIXEL_SIZE,iLEVEL_Y_PIXEL_SIZE)
        pImage:TImage[iX,iY]=LoadImage(tWinPixMap:TPixmap,MASKEDIMAGE)    'Chop up the image into tiles
        pMapping[iX,iY]=pImage:TImage[iX,iY]
        Next
      Next
    End Method

  Method Draw()
    SetBlend SOLIDBLEND
    For Local iX:Int=0 To iLEVEL_X_SIZE-1
      For Local iY:Int=0 To iLEVEL_Y_SIZE-1
        DrawImage pMapping[iX,iY],(iX*32),(iY*32)
        Next
      Next
    Flip
    End Method

  End Type 




'_/ Setup \_______________________________________________________________________________________________________________

Local pMainWindow:TGadget = CreateWindow("Picture sliding thing v1.0",(GadgetWidth(Desktop())-600)/2,(GadgetHeight(Desktop())-600)/2,600,600,Null,WINDOW_TITLEBAR | WINDOW_CLIENTCOORDS)
Local pCanvas:TGadget = CreateCanvas(44,44,512,512,pMainWindow:TGadget)

Local pLeftButton:TGadget[16]
Local pRightButton:TGadget[16]
Local pTopButton:TGadget[16]
Local pBottomButton:TGadget[16]

For Local iLoop:Int=0 To 15
  pRightButton[iLoop]=CreateButton("+",512+44,44+(iLoop*32),32,32,pMainWindow,BUTTON_PUSH)
  pLeftButton[iLoop]=CreateButton("+",44-32,44+(iLoop*32),32,32,pMainWindow,BUTTON_PUSH)
  pTopButton[iLoop]=CreateButton("+",44+(iLoop*32),44-32,32,32,pMainWindow,BUTTON_PUSH)
  pBottomButton[iLoop]=CreateButton("+",44+(iLoop*32),512+44,32,32,pMainWindow,BUTTON_PUSH)
  Next


Global tGameLevel:tLevelInfo = New tLevelInfo
tGameLevel.Load("incbin::sourcepic.jpg")    'Load it from the included file

Local bQuitProgram=False

'_/ Main program \_______________________________________________________________________________________________________________



Repeat

	gccollect
   
	WaitEvent() 

    Local pGadgetResposible:TGadget=Null
    Local iDir:Int=-1
    Local iXLine:Int=-1
    Local iYLine:Int=-1

    For Local iLoop:Int=0 To 15
      If EventSource()=pLeftButton[iLoop] 
        pGadgetResposible=pLeftButton[iLoop]
        iXLine=-1
        iYLine=iLoop
        iDir=1
        EndIf
      If EventSource()=pRightButton[iLoop] 
        pGadgetResposible=pRightButton[iLoop] 
        iXLine=-1
        iYLine=iLoop
        iDir=-1
        EndIf
      If EventSource()=pTopButton[iLoop] 
        pGadgetResposible=pTopButton[iLoop]
        iYLine=-1
        iXLine=iLoop
        iDir=1
        EndIf
      If EventSource()=pBottomButton[iLoop] 
        pGadgetResposible=pBottomButton[iLoop]
        iYLine=-1
        iXLine=iLoop
        iDir=-1
        EndIf
      Next



    If pGadgetResposible<>Null
      'Was a slider gadget ? ...

      If iYLine<>-1
        'X line to scroll
        If iDir=1
          'Scroll map one way
          Local pTemp:TImage=tGameLevel.pMapping[0,iYLine]
          For Local iP:Int=0 To iLEVEL_Y_SIZE-2
            tGameLevel.pMapping[iP,iYLine]=tGameLevel.pMapping[iP+1,iYLine]
            Next
          tGameLevel.pMapping[iLEVEL_X_SIZE-1,iYLine]=pTemp:TImage
          Else
          'Scroll map the other way
          Local pTemp:TImage=tGameLevel.pMapping[iLEVEL_X_SIZE-1,iYLine]
          For Local iP:Int=iLEVEL_Y_SIZE-2 To 0 Step -1
            tGameLevel.pMapping[iP+1,iYLine]=tGameLevel.pMapping[iP,iYLine]
            Next
          tGameLevel.pMapping[0,iYLine]=pTemp:TImage
          EndIf

        Else 
        'Presume that iXLine<>-1
        If iDir=1
          'Scroll map one way
          Local pTemp:TImage=tGameLevel.pMapping[iXLine,0]
          For Local iP:Int=0 To iLEVEL_X_SIZE-2
            tGameLevel.pMapping[iXLine,iP]=tGameLevel.pMapping[iXLine,iP+1]
            Next
          tGameLevel.pMapping[iXLine,iLEVEL_X_SIZE-1]=pTemp:TImage
          Else
          'Scroll map the other way
          Local pTemp:TImage=tGameLevel.pMapping[iXLine,iLEVEL_Y_SIZE-1]
          For Local iP:Int=iLEVEL_X_SIZE-2 To 0 Step -1
            tGameLevel.pMapping[iXLine,iP+1]=tGameLevel.pMapping[iXLine,iP]
            Next
          tGameLevel.pMapping[iXLine,0]=pTemp:TImage
          EndIf

        EndIf

      'Redraw the display cause we have moved it
      SetGraphics CanvasGraphics(pCanvas)
      Cls
      tGameLevel.Draw()



      Else

      'Not one of the main game control gadgets
      Select EventID()
     	
        Case EVENT_GADGETPAINT
        'Redraw the main display
	    SetGraphics CanvasGraphics(pCanvas)
        Cls
        tGameLevel.Draw()
	
        Case EVENT_WINDOWCLOSE
        'Quit the program
        bQuitProgram=True

        End Select
      EndIf

  
  Until bQuitProgram=True

End