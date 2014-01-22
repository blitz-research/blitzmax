
' Test program for the UTAH Teapot. 
' BlitzMax versio by Peter Scheutz 2004.12.18

Strict

Import "teapot.bmx"

Type ogld_color4f
	Field r#,g#,b#,a#
End Type

Type ogld_pos4f
	Field x#,y#,z#,w#
End Type


Local teapot
Local z#=-4
Local xrot#=0
Local yrot#=0


GLGraphics 800,600

	glClearColor(0.2, 0.0, 0.4, 0.0)
	glEnable(GL_DEPTH_TEST)
	
	glEnable GL_AUTO_NORMAL
	glEnable GL_NORMALIZE

	teapot= ogld_TeaPot(16)

	ResizeViewport 800,600

	initlights 

	gldisable(GL_CULL_FACE)
	
	

While Not KeyHit(Key_Escape)

	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
	
	glMatrixMode GL_MODELVIEW
	glLoadIdentity

	glTranslatef 0,0,-8
	glRotatef yrot,1,0,0
	glRotatef xrot,0,1,0


	glTranslatef 0.0,-1.0,0.0	
	glCallList teapot

	Flip
	
	xrot = xrot +1
	yrot = yrot +.1

Wend

Function ResizeViewport(w,h)

	Local aspect#


	If w = 0 Then h = 1

	glViewport 0,0,w,h

	glMatrixMode GL_PROJECTION
	glLoadIdentity
	aspect#=Float(w)/Float(h)
	

	gluPerspective 45.0,aspect,1.0,100.0
	glMatrixMode GL_MODELVIEW    


End Function

Function initlights()

	Local ambient:ogld_color4f = New ogld_color4f
	Local position:ogld_pos4f = New ogld_pos4f

	Local mat_ambient:ogld_color4f = New ogld_color4f
	Local mat_diffuse:ogld_color4f = New ogld_color4f
	Local mat_specular:ogld_color4f = New ogld_color4f
	Local mat_shininess:ogld_color4f = New ogld_color4f	
	

	
	ambient.r=0.2
	ambient.g=0.2
	ambient.b=0.2
	ambient.a=1	

	position.x=-2
	position.y=5
	position.z=0
	position.w=1		

	mat_ambient.r=1
	mat_ambient.g=0
	mat_ambient.b=0
	mat_diffuse.a=1

	mat_diffuse.r=1
	mat_diffuse.g=0
	mat_diffuse.b=0
	mat_diffuse.a=1



	mat_specular.r=1
	mat_specular.g=1
	mat_specular.b=1
	mat_specular.a=1


	mat_shininess.r=50.0
	mat_shininess.g=50.0
	mat_shininess.b=50.0
	mat_shininess.a=0


	glEnable(GL_LIGHTING);
	glEnable(GL_LIGHT0);

	glLightfv GL_LIGHT0, GL_AMBIENT, Varptr(ambient.r)
	glLightfv GL_LIGHT0, GL_POSITION, Varptr(position.x)


	glMaterialfv GL_FRONT, GL_DIFFUSE, Varptr(mat_diffuse.r)
	glMaterialfv GL_FRONT, GL_AMBIENT, Varptr(mat_ambient.r)
	glMaterialfv GL_FRONT, GL_SPECULAR, Varptr(mat_specular.r)
	glMaterialfv GL_FRONT, GL_SHININESS, Varptr(mat_shininess.r)

End Function