
Strict

Import "driver.bmx"

Rem
bbdoc: Max2D Image type
End Rem
Type TImage

	Field width,height,flags
	Field mask_r,mask_g,mask_b
	Field handle_x#,handle_y#
	Field pixmaps:TPixmap[]

	Field frames:TImageFrame[]
	Field seqs[]
	
	Method _pad()
	End Method
	
	Method Frame:TImageFrame( index )
		If seqs[index]=GraphicsSeq Return frames[index]
		frames[index]=_max2dDriver.CreateFrameFromPixmap( Lock(index,True,False),flags )
		If frames[index] seqs[index]=GraphicsSeq Else seqs[index]=0
		Return frames[index]
	End Method
	
	Method Lock:TPixmap( index,read,write )
		If write
			seqs[index]=0
			frames[index]=Null
		EndIf
		If Not pixmaps[index]
			pixmaps[index]=CreatePixmap( width,height,PF_RGBA8888 )
		EndIf
		Return pixmaps[index]
	End Method
	
	Method SetPixmap( index,pixmap:TPixmap )
		If (flags & MASKEDIMAGE) And AlphaBitsPerPixel[pixmap.format]=0
			pixmap=MaskPixmap( pixmap,mask_r,mask_g,mask_b )
		EndIf
		pixmaps[index]=pixmap
		seqs[index]=0
		frames[index]=Null
	End Method
	
	Function Create:TImage( width,height,frames,flags,mr,mg,mb )
		Local t:TImage=New TImage
		t.width=width
		t.height=height
		t.flags=flags
		t.mask_r=mr
		t.mask_g=mg
		t.mask_b=mb
		t.pixmaps=New TPixmap[frames]
		t.frames=New TImageFrame[frames]
		t.seqs=New Int[frames]
		Return t
	End Function
	
	Function Load:TImage( url:Object,flags,mr,mg,mb )
		Local pixmap:TPixmap=TPixmap(url)
		If Not pixmap pixmap=LoadPixmap(url)
		If Not pixmap Return
		Local t:TImage=Create( pixmap.width,pixmap.height,1,flags,mr,mg,mb )
		t.SetPixmap 0,pixmap
		Return t
	End Function

	Function LoadAnim:TImage( url:Object,cell_width,cell_height,first,count,flags,mr,mg,mb )
		Local pixmap:TPixmap=TPixmap(url)
		If Not pixmap pixmap=LoadPixmap(url)
		If Not pixmap Return

		Local x_cells=pixmap.width/cell_width
		Local y_cells=pixmap.height/cell_height
		If first+count>x_cells*y_cells Return
		
		Local t:TImage=Create( cell_width,cell_height,count,flags,mr,mg,mb )

		For Local cell=first To first+count-1
			Local x=cell Mod x_cells * cell_width
			Local y=cell / x_cells * cell_height
			Local window:TPixmap=pixmap.Window( x,y,cell_width,cell_height )
			t.SetPixmap cell-first,window.Copy()
		Next
		Return t
	End Function
	
End Type
