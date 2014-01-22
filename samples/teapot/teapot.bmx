' The UTAH Teapot. See <a href="http://sjbaker.org/teapot/" target="_blank">sjbaker.org/teapot/</a> For more information
' This Function returns an OpenGL display list.
' BlitzMax port by Peter Scheutz 2004.12.18
Function ogld_TeaPot(grid%)

	Local x#,y#,z#
	Local i, n
	Local verts
	Local teaList
	Local rimbank
	Local bodybank1
	Local bodybank2
	Local lidbank1
	Local lidbank2		
	Local handlebank1
	Local handlebank2
	Local spoutbank1
	Local spoutbank2


	verts=CreateBank(3*4*119)

	
	RestoreData teaPotVerts
	For i=0 To 118
		ReadData x#
		ReadData y#
		ReadData z#		
		
		PokeFloat verts,i*12,x
		PokeFloat verts,i*12+4,y		
		PokeFloat verts,i*12+8,z		
			
	Next

	rimbank=CreateBank(16*4*3)

	bodybank1=CreateBank(16*4*3)
	bodybank2=CreateBank(16*4*3)

	lidbank1=CreateBank(16*4*3)
	lidbank2=CreateBank(16*4*3)


	handlebank1=CreateBank(16*4*3)
	handlebank2=CreateBank(16*4*3)

	spoutbank1=CreateBank(16*4*3)
	spoutbank2=CreateBank(16*4*3)


	' rim
	RestoreData teaPotRim
	For n=0 To 15
		ReadData i
		PokeFloat rimbank,n*12,PeekFloat(verts,i*12)
		PokeFloat rimbank,n*12+4,PeekFloat(verts,i*12+4)
		PokeFloat rimbank,n*12+8,PeekFloat(verts,i*12+8)
	Next	

	' body
	RestoreData teaPotBody
	For n=0 To 15
		ReadData i
		PokeFloat bodybank1,n*12,PeekFloat(verts,i*12)
		PokeFloat bodybank1,n*12+4,PeekFloat(verts,i*12+4)
		PokeFloat bodybank1,n*12+8,PeekFloat(verts,i*12+8)
	Next
	For n=0 To 15
		ReadData i
		PokeFloat bodybank2,n*12,PeekFloat(verts,i*12)
		PokeFloat bodybank2,n*12+4,PeekFloat(verts,i*12+4)
		PokeFloat bodybank2,n*12+8,PeekFloat(verts,i*12+8)
	Next

	' lid
	RestoreData teaPotLid
	For n=0 To 15
		ReadData i
		PokeFloat lidbank1,n*12,PeekFloat(verts,i*12)
		PokeFloat lidbank1,n*12+4,PeekFloat(verts,i*12+4)
		PokeFloat lidbank1,n*12+8,PeekFloat(verts,i*12+8)
	Next
	For n=0 To 15
		ReadData i
		PokeFloat lidbank2,n*12,PeekFloat(verts,i*12)
		PokeFloat lidbank2,n*12+4,PeekFloat(verts,i*12+4)
		PokeFloat lidbank2,n*12+8,PeekFloat(verts,i*12+8)
	Next

	' handle
	RestoreData teaPotHandle
	For n=0 To 15
		ReadData i
		PokeFloat handlebank1,n*12,PeekFloat(verts,i*12)
		PokeFloat handlebank1,n*12+4,PeekFloat(verts,i*12+4)
		PokeFloat handlebank1,n*12+8,PeekFloat(verts,i*12+8)
	Next
	For n=0 To 15
		ReadData i
		PokeFloat handlebank2,n*12,PeekFloat(verts,i*12)
		PokeFloat handlebank2,n*12+4,PeekFloat(verts,i*12+4)
		PokeFloat handlebank2,n*12+8,PeekFloat(verts,i*12+8)
	Next

	' Spout
	RestoreData teaPotSpout
	For n=0 To 15
		ReadData i
		PokeFloat spoutbank1,n*12,PeekFloat(verts,i*12)
		PokeFloat spoutbank1,n*12+4,PeekFloat(verts,i*12+4)
		PokeFloat spoutbank1,n*12+8,PeekFloat(verts,i*12+8)
	Next
	For n=0 To 15
		ReadData i
		PokeFloat spoutbank2,n*12,PeekFloat(verts,i*12)
		PokeFloat spoutbank2,n*12+4,PeekFloat(verts,i*12+4)
		PokeFloat spoutbank2,n*12+8,PeekFloat(verts,i*12+8)
	Next



    teaList = glGenLists(1)
    glNewList teaList, GL_COMPILE
    glPushMatrix

    glRotatef 270, 1, 0, 0

	glEnable GL_MAP2_VERTEX_3
	glMapGrid2f grid, 0, 1, grid, 0, 1



	For i=0 To 3

		glMap2f GL_MAP2_VERTEX_3, 0, 1, 3, 4, 0, 1, 12, 4, Float Ptr( BankBuf(rimbank))
		glEvalMesh2 GL_FILL, 0, grid, 0, grid
	
		glMap2f GL_MAP2_VERTEX_3, 0, 1, 3, 4, 0, 1, 12, 4, Float Ptr( BankBuf(bodybank1))
		glEvalMesh2 GL_FILL, 0, grid, 0, grid
	
		glMap2f GL_MAP2_VERTEX_3, 0, 1, 3, 4, 0, 1, 12, 4, Float Ptr( BankBuf(bodybank2))
		glEvalMesh2 GL_FILL, 0, grid, 0, grid
	
		glMap2f GL_MAP2_VERTEX_3, 0, 1, 3, 4, 0, 1, 12, 4, Float Ptr( BankBuf(lidbank1))
		glEvalMesh2 GL_FILL, 0, grid, 0, grid
	
		glMap2f GL_MAP2_VERTEX_3, 0, 1, 3, 4, 0, 1, 12, 4, Float Ptr( BankBuf(lidbank2))
		glEvalMesh2 GL_FILL, 0, grid, 0, grid

	    glRotatef 90, 0, 0, 1


	Next 


	For i=0 To 1

		glMap2f GL_MAP2_VERTEX_3, 0, 1, 3, 4, 0, 1, 12, 4, Float Ptr( BankBuf(handlebank1))
		glEvalMesh2 GL_FILL, 0, grid, 0, grid
	
		glMap2f GL_MAP2_VERTEX_3, 0, 1, 3, 4, 0, 1, 12, 4, Float Ptr( BankBuf(handlebank2))
		glEvalMesh2 GL_FILL, 0, grid, 0, grid
	
	
		glMap2f GL_MAP2_VERTEX_3, 0, 1, 3, 4, 0, 1, 12, 4, Float Ptr( BankBuf(spoutbank1))
		glEvalMesh2 GL_FILL, 0, grid, 0, grid
	
		glMap2f GL_MAP2_VERTEX_3, 0, 1, 3, 4, 0, 1, 12, 4, Float Ptr( BankBuf(spoutbank2))
		glEvalMesh2 GL_FILL, 0, grid, 0, grid

		glScalef 1,-1,1 


	Next 


    glDisable GL_MAP2_VERTEX_3
    glPopMatrix
    glEndList

	Return teaList

End Function


#teaPotRim
DefData 102, 103, 104, 105,   4,   5,   6,   7,   8,   9,  10,  11,  12,  13,  14,  15
#teaPotBody
DefData 12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,  23,  24,  25,  26,  27 
DefData 24,  25,  26,  27,  29,  30,  31,  32,  33,  34,  35,  36,  37,  38,  39,  40 
#teaPotLid
DefData 96,  96,  96,  96,  97,  98,  99, 100, 101, 101, 101, 101,   0,   1,   2,   3 
DefData 0,   1,   2,   3, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117 
#teaPotHandle
DefData 41,  42,  43,  44,  45,  46,  47,  48,  49,  50,  51,  52,  53,  54,  55,  56 
DefData 53,  54,  55,  56,  57,  58,  59,  60,  61,  62,  63,  64,  28,  65,  66,  67 
#teaPotSpout
DefData 68,  69,  70,  71,  72,  73,  74,  75,  76,  77,  78,  79,  80,  81,  82,  83 
DefData 80,  81,  82,  83,  84,  85,  86,  87,  88,  89,  90,  91,  92,  93,  94,  95 


#teaPotVerts
DefData  0.2000, 0.0000, 2.70000 , 0.2000, -0.1120, 2.70000 , 0.1120, -0.2000, 2.70000 
DefData 0.0000, -0.2000, 2.70000 , 1.3375, 0.0000, 2.53125 , 1.3375, -0.7490, 2.53125 
DefData 0.7490, -1.3375, 2.53125 , 0.0000, -1.3375, 2.53125 , 1.4375, 0.0000, 2.53125 
DefData 1.4375, -0.8050, 2.53125 , 0.8050, -1.4375, 2.53125 , 0.0000, -1.4375, 2.53125 
DefData 1.5000, 0.0000, 2.40000 , 1.5000, -0.8400, 2.40000 , 0.8400, -1.5000, 2.40000 
DefData 0.0000, -1.5000, 2.40000 , 1.7500, 0.0000, 1.87500 , 1.7500, -0.9800, 1.87500 
DefData 0.9800, -1.7500, 1.87500 , 0.0000, -1.7500, 1.87500 , 2.0000, 0.0000, 1.35000 
DefData 2.0000, -1.1200, 1.35000 , 1.1200, -2.0000, 1.35000 , 0.0000, -2.0000, 1.35000 
DefData 2.0000, 0.0000, 0.90000 , 2.0000, -1.1200, 0.90000 , 1.1200, -2.0000, 0.90000 
DefData 0.0000, -2.0000, 0.90000 , -2.0000, 0.0000, 0.90000 , 2.0000, 0.0000, 0.45000 
DefData 2.0000, -1.1200, 0.45000 , 1.1200, -2.0000, 0.45000 , 0.0000, -2.0000, 0.45000 
DefData 1.5000, 0.0000, 0.22500 , 1.5000, -0.8400, 0.22500 , 0.8400, -1.5000, 0.22500 
DefData 0.0000, -1.5000, 0.22500 , 1.5000, 0.0000, 0.15000 , 1.5000, -0.8400, 0.15000 
DefData 0.8400, -1.5000, 0.15000 , 0.0000, -1.5000, 0.15000 , -1.6000, 0.0000, 2.02500 
DefData -1.6000, -0.3000, 2.02500 , -1.5000, -0.3000, 2.25000 , -1.5000, 0.0000, 2.25000 
DefData -2.3000, 0.0000, 2.02500 , -2.3000, -0.3000, 2.02500 , -2.5000, -0.3000, 2.25000 
DefData -2.5000, 0.0000, 2.25000 , -2.7000, 0.0000, 2.02500 , -2.7000, -0.3000, 2.02500 
DefData -3.0000, -0.3000, 2.25000 , -3.0000, 0.0000, 2.25000 , -2.7000, 0.0000, 1.80000 
DefData -2.7000, -0.3000, 1.80000 , -3.0000, -0.3000, 1.80000 , -3.0000, 0.0000, 1.80000 
DefData -2.7000, 0.0000, 1.57500 , -2.7000, -0.3000, 1.57500 , -3.0000, -0.3000, 1.35000 
DefData -3.0000, 0.0000, 1.35000 , -2.5000, 0.0000, 1.12500 , -2.5000, -0.3000, 1.12500 
DefData -2.6500, -0.3000, 0.93750 , -2.6500, 0.0000, 0.93750 , -2.0000, -0.3000, 0.90000 
DefData -1.9000, -0.3000, 0.60000 , -1.9000, 0.0000, 0.60000 , 1.7000, 0.0000, 1.42500 
DefData 1.7000, -0.6600, 1.42500 , 1.7000, -0.6600, 0.60000 , 1.7000, 0.0000, 0.60000 
DefData 2.6000, 0.0000, 1.42500 , 2.6000, -0.6600, 1.42500 , 3.1000, -0.6600, 0.82500 
DefData 3.1000, 0.0000, 0.82500 , 2.3000, 0.0000, 2.10000 , 2.3000, -0.2500, 2.10000 
DefData 2.4000, -0.2500, 2.02500 , 2.4000, 0.0000, 2.02500 , 2.7000, 0.0000, 2.40000 
DefData 2.7000, -0.2500, 2.40000 , 3.3000, -0.2500, 2.40000 , 3.3000, 0.0000, 2.40000 
DefData 2.8000, 0.0000, 2.47500 , 2.8000, -0.2500, 2.47500 , 3.5250, -0.2500, 2.49375 
DefData 3.5250, 0.0000, 2.49375 , 2.9000, 0.0000, 2.47500 , 2.9000, -0.1500, 2.47500 
DefData 3.4500, -0.1500, 2.51250 , 3.4500, 0.0000, 2.51250 , 2.8000, 0.0000, 2.40000 
DefData 2.8000, -0.1500, 2.40000 , 3.2000, -0.1500, 2.40000 , 3.2000, 0.0000, 2.40000 
DefData 0.0000, 0.0000, 3.15000 , 0.8000, 0.0000, 3.15000 , 0.8000, -0.4500, 3.15000 
DefData 0.4500, -0.8000, 3.15000 , 0.0000, -0.8000, 3.15000 , 0.0000, 0.0000, 2.85000 
DefData 1.4000, 0.0000, 2.40000 , 1.4000, -0.7840, 2.40000 , 0.7840, -1.4000, 2.40000 
DefData 0.0000, -1.4000, 2.40000 , 0.4000, 0.0000, 2.55000 , 0.4000, -0.2240, 2.55000 
DefData 0.2240, -0.4000, 2.55000 , 0.0000, -0.4000, 2.55000 , 1.3000, 0.0000, 2.55000 
DefData 1.3000, -0.7280, 2.55000 , 0.7280, -1.3000, 2.55000 , 0.0000, -1.3000, 2.55000 
DefData 1.3000, 0.0000, 2.40000 , 1.3000, -0.7280, 2.40000 , 0.7280, -1.3000, 2.40000 
DefData 0.0000, -1.3000, 2.40000 , 0.0000, 0.0000, 0.00000 
