Rem
 NEHE OpenGL Lesson 36:  Radial Blur & Rendering To A Texture
 converted to blitzmax by David Bird
EndRem
Strict

'User Defined Variables
Global C_WIDTH = 640
Global C_HEIGHT= 480
Global	angle# 						 'Used To Rotate The Helix
Global 	vertexes#[4,3]     'Holds Float Info For 4 Sets Of Vertices
Global	normal#[3]         'An Array To Store The Normal Data
Global 	BlurTexture        'An Unsigned Int To Store The Texture Number
Global tSize=256
Const RAD_TO_DEG! =  57.2957795130823208767981548141052

Function Cos_R!(rads!)
  Return Cos(rads * RAD_TO_DEG)
EndFunction

Function Sin_R!(rads!)
  Return Sin(rads * RAD_TO_DEG)
EndFunction

Function EmptyTexture()											' Create An Empty Texture
	Local txtnumber											' Texture ID
	Local data[tSize*tSize*4]
	glGenTextures(1, Varptr txtnumber )								' Create 1 Texture
	glBindTexture(GL_TEXTURE_2D, txtnumber)					' Bind The Texture
	glTexImage2D(GL_TEXTURE_2D, 0, 4, 128, 128, 0,..
		GL_RGBA, GL_UNSIGNED_BYTE, data)						' Build Texture Using Information In data
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR)
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR)
	Return txtnumber											' Return The Texture ID
EndFunction

Function ReduceToUnit(vector:Float Ptr)								' Reduces A Normal Vector (3 Coordinates)
	Local length#
	' Calculates The Length Of The Vector
	length = Sqr((vector[0]*vector[0]) + (vector[1]*vector[1]) + (vector[2]*vector[2]))
	If length = 0.0 length=1.0						' Prevents Divide By 0 Error By Providing

	vector[0]:/ length										' Dividing Each Element By
	vector[1]:/ length										' The Length Results In A
	vector[2]:/ length										' Unit Normal Vector.
End Function

Function ProcessHelix()												' Draws A Helix
  Local a
	Local x#													' Helix x Coordinate
	Local y#													' Helix y Coordinate
	Local z#													' Helix z Coordinate
	Local phi#												' Angle
	Local theta#											' Angle
	Local v#,u#												' Angles
	Local r#													' Radius Of Twist
	Local twists = 5												' 5 Twists
	Local glfMaterialColor#[]=[0.4#,0.2#,0.8#,1.0#]			' Set The Material Color
	Local specular#[]=[1.0#,1.0#,1.0#,1.0#]					' Sets Up Specular Lighting
  Local tv1#[3],tv2#[3]

	glLoadIdentity()											' Reset The Modelview Matrix
	gluLookAt(0, 5, 50, 0, 0, 0, 0, 1, 0)						' Eye Position (0,5,50) Center Of Scene (0,0,0), Up On Y Axis

	glPushMatrix()												' Push The Modelview Matrix

	glTranslatef(0,0,-50)										' Translate 50 Units Into The Screen
	glRotatef(angle/2.0,1,0,0)								' Rotate By angle/2 On The X-Axis
	glRotatef(angle/3.0,0,1,0)								' Rotate By angle/3 On The Y-Axis
  glMaterialfv(GL_FRONT_AND_BACK,GL_AMBIENT_AND_DIFFUSE,glfMaterialColor)
	glMaterialfv(GL_FRONT_AND_BACK,GL_SPECULAR,specular)

	r=1.5														' Radius

	glBegin(GL_QUADS)											' Begin Drawing Quads
	For phi=0 Until 360 Step 20.0							' 360 Degrees In Steps Of 20
		For theta=0 Until (360*twists) Step 20.0 	' 360 Degrees * Number Of Twists In Steps Of 20
			v=(phi/180.0*3.142)								' Calculate Angle Of First Point	(  0 )
			u=(theta/180.0*3.142)							' Calculate Angle Of First Point	(  0 )

			x=(cos_r(u)*(2.0+cos_r(v) ))*r					' Calculate x Position (1st Point)
			y=(sin_r(u)*(2.0+cos_r(v) ))*r					' Calculate y Position (1st Point)
			z=((( u-(2.0*3.142)) + sin_r(v) )* r)		' Calculate z Position (1st Point)

			vertexes[0,0]=x									' Set x Value Of First Vertex
			vertexes[0,1]=y									' Set y Value Of First Vertex
			vertexes[0,2]=z									' Set z Value Of First Vertex

			v=(phi/180.0*3.142)								' Calculate Angle Of Second Point	(  0 )
			u=((theta+20)/180.0*3.142)						' Calculate Angle Of Second Point	( 20 )

			x=(cos_r(u)*(2.0+cos_r(v) ))*r					' Calculate x Position (2nd Point)
			y=(sin_r(u)*(2.0+cos_r(v) ))*r					' Calculate y Position (2nd Point)
			z=((( u-(2.0*3.142)) + sin_r(v) ) * r)		' Calculate z Position (2nd Point)

			vertexes[1,0]=x									' Set x Value Of Second Vertex
			vertexes[1,1]=y									' Set y Value Of Second Vertex
			vertexes[1,2]=z									' Set z Value Of Second Vertex

			v=((phi+20)/180.0*3.142)							' Calculate Angle Of Third Point	( 20 )
			u=((theta+20)/180.0*3.142)						' Calculate Angle Of Third Point	( 20 )

			x=(cos_r(u)*(2.0+cos_r(v) ))*r					' Calculate x Position (3rd Point)
			y=(sin_r(u)*(2.0+cos_r(v) ))*r					' Calculate y Position (3rd Point)
			z=((( u-(2.0*3.142)) + sin_r(v) ) * r)		' Calculate z Position (3rd Point)

			vertexes[2,0]=x									' Set x Value Of Third Vertex
			vertexes[2,1]=y									' Set y Value Of Third Vertex
			vertexes[2,2]=z									' Set z Value Of Third Vertex

			v=((phi+20)/180.0*3.142)							' Calculate Angle Of Fourth Point	( 20 )
			u=((theta)/180.0*3.142)							' Calculate Angle Of Fourth Point	(  0 )

			x=Float(cos_r(u)*(2.0+cos_r(v) ))*r					' Calculate x Position (4th Point)
			y=Float(sin_r(u)*(2.0+cos_r(v) ))*r					' Calculate y Position (4th Point)
			z=Float((( u-(2.0*3.142)) + sin_r(v) ) * r)		' Calculate z Position (4th Point)

			vertexes[3,0]=x									' Set x Value Of Fourth Vertex
			vertexes[3,1]=y									' Set y Value Of Fourth Vertex
			vertexes[3,2]=z									' Set z Value Of Fourth Vertex

      For a=0 Until 3
      	' Calculate The Vector From Point 1 To Point 0
      	tv1[a] = vertexes[0,a] - vertexes[1,a]									' Vector 1.x=Vertex[0].x-Vertex[1].x
    	  tv2[a] = vertexes[1,a] - vertexes[2,a]									' Vector 2.x=Vertex[0].x-Vertex[1].x
        ' Compute The Cross Product To Give Us A Surface Normal
      Next
      normal[0] = tv1[1]*tv2[2] - tv1[2]*tv2[1]
      normal[1] = tv1[2]*tv2[0] - tv1[0]*tv2[2]
      normal[2] = tv1[0]*tv2[1] - tv1[1]*tv2[0]
    	ReduceToUnit(normal)											' Normalize The Vectors

    	glNormal3f(normal[0],normal[1],normal[2])			' Set The Normal

			' Render The Quad
			glVertex3f(vertexes[0,0],vertexes[0,1],vertexes[0,2])
			glVertex3f(vertexes[1,0],vertexes[1,1],vertexes[1,2])
			glVertex3f(vertexes[2,0],vertexes[2,1],vertexes[2,2])
			glVertex3f(vertexes[3,0],vertexes[3,1],vertexes[3,2])
		Next
	Next
	glEnd()													' Done Rendering Quads

	glPopMatrix()												' Pop The Matrix
EndFunction

Function ViewOrtho()												' Set Up An Ortho View
	glMatrixMode(GL_PROJECTION)								' Select Projection
	glPushMatrix()												' Push The Matrix
	glLoadIdentity()											' Reset The Matrix
	glOrtho( 0, C_WIDTH ,C_HEIGHT , 0, -10, 10 )							' Select Ortho Mode (640x480)
	glMatrixMode(GL_MODELVIEW)									' Select Modelview Matrix
	glPushMatrix()												' Push The Matrix
	glLoadIdentity()											' Reset The Matrix
EndFunction

Function ViewPerspective()											' Set Up A Perspective View
	glMatrixMode( GL_PROJECTION )								' Select Projection
	glPopMatrix()												' Pop The Matrix
	glMatrixMode( GL_MODELVIEW )								' Select Modelview
	glPopMatrix()												' Pop The Matrix
EndFunction

Function RenderToTexture()											' Renders To A Texture
	glViewport(0,0,tSize,tSize)									' Set Our Viewport (Match Texture Size)
	ProcessHelix()												' Render The Helix

	glBindTexture(GL_TEXTURE_2D,BlurTexture)					' Bind To The Blur Texture
	' Copy Our ViewPort To The Blur Texture (From 0,0 To 128,128... No Border)
	glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, 0, 0, tSize, tSize, 0)
	glClearColor(0.0, 0.0, 0.25, 0.5)						' Set The Clear Color To Medium Blue
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)			' Clear The Screen And Depth Buffer
	glViewport(0 , 0,C_WIDTH ,C_HEIGHT)									' Set Viewport (0,0 to 640x480)
EndFunction

Function DrawBlur(times, inc#)								' Draw The Blurred Image
  Local num
	Local spost# = 0.0											' Starting Texture Coordinate Offset
  Local alphainc# = 0.9 / Float(times)								' Fade Speed For Alpha Blending
	Local alpha# = 0.1											' Starting Alpha Value

	' Disable AutoTexture Coordinates
	glDisable(GL_TEXTURE_GEN_S)
	glDisable(GL_TEXTURE_GEN_T)

	glEnable(GL_TEXTURE_2D)									' Enable 2D Texture Mapping
	glDisable(GL_DEPTH_TEST)									' Disable Depth Testing
	glBlendFunc(GL_SRC_ALPHA,GL_ONE)							' Set Blending Mode
	glEnable(GL_BLEND)											' Enable Blending
	glBindTexture(GL_TEXTURE_2D,BlurTexture)					' Bind To The Blur Texture
	ViewOrtho()						      						' Switch To An Ortho View
  alphainc = alpha / times									' alphainc=0.2f / Times To Render Blur

	glBegin(GL_QUADS)											' Begin Drawing Quads
		For num = 0 Until  times						' Number Of Times To Render Blur
			glColor4f(1.0, 1.0, 1.0, alpha)					' Set The Alpha Value (Starts At 0.2)
			glTexCoord2f(0+spost,1-spost)						' Texture Coordinate	( 0, 1 )
			glVertex2f(0,0)									' First Vertex		(   0,   0 )

			glTexCoord2f(0+spost,0+spost)						' Texture Coordinate	( 0, 0 )
			glVertex2f(0,C_HEIGHT)									' Second Vertex	(   0, 480 )

			glTexCoord2f(1-spost,0+spost)						' Texture Coordinate	( 1, 0 )
			glVertex2f(C_WIDTH,C_HEIGHT)								' Third Vertex		( C_WIDTH, 480 )

			glTexCoord2f(1-spost,1-spost)						' Texture Coordinate	( 1, 1 )
			glVertex2f(C_WIDTH,0)									' Fourth Vertex	( C_WIDTH,   0 )

			spost:+ inc										' Gradually Increase spost (Zooming Closer To Texture Center)
			alpha = alpha - alphainc							' Gradually Decrease alpha (Gradually Fading Image Out)
		Next
	glEnd()													' Done Drawing Quads

	ViewPerspective()											' Switch To A Perspective View

	glEnable(GL_DEPTH_TEST)									' Enable Depth Testing
	glDisable(GL_TEXTURE_2D)									' Disable 2D Texture Mapping
	glDisable(GL_BLEND)										' Disable Blending


	glBindTexture(GL_TEXTURE_2D,0)								' Unbind The Blur Texture
EndFunction

Function Initialize ()
	' Start Of User Initialization
	angle		= 0.0											' Set Starting Angle To Zero
	BlurTexture = EmptyTexture()								' Create Our Empty Texture
	glViewport(0 , 0,C_WIDTH ,C_HEIGHT)	' Set Up A Viewport
	glMatrixMode(GL_PROJECTION)								' Select The Projection Matrix
	glLoadIdentity()											' Reset The Projection Matrix
	gluPerspective(50, Float(C_WIDTH)/Float(C_HEIGHT), 5,  2000) ' Set Our Perspective
	glMatrixMode(GL_MODELVIEW)									' Select The Modelview Matrix
	glLoadIdentity()											' Reset The Modelview Matrix
	glEnable(GL_DEPTH_TEST)									' Enable Depth Testing

	Local global_ambient#[]=[0.2#, 0.2#,  0.2#, 1.0#]		' Set Ambient Lighting To Fairly Dark Light (No Color)
	Local light0pos#[]=     [0.0#, 5.0#, 10.0#, 1.0#]		' Set The Light Position
	Local light0ambient#[]= [0.2#, 0.2#,  0.2#, 1.0#]		' More Ambient Light
	Local light0diffuse#[]= [0.3#, 0.3#,  0.3#, 1.0#]		' Set The Diffuse Light A Bit Brighter
	Local light0specular#[]=[0.8#, 0.8#,  0.8#, 1.0#]		' Fairly Bright Specular Lighting

	Local lmodel_ambient#[]=[ 0.2#,0.2#,0.2#,1.0#]			' And More Ambient Light
	glLightModelfv(GL_LIGHT_MODEL_AMBIENT,lmodel_ambient)		' Set The Ambient Light Model

	glLightModelfv(GL_LIGHT_MODEL_AMBIENT, global_ambient)		' Set The Global Ambient Light Model
	glLightfv(GL_LIGHT0, GL_POSITION, light0pos)				' Set The Lights Position
	glLightfv(GL_LIGHT0, GL_AMBIENT, light0ambient)			' Set The Ambient Light
	glLightfv(GL_LIGHT0, GL_DIFFUSE, light0diffuse)			' Set The Diffuse Light
	glLightfv(GL_LIGHT0, GL_SPECULAR, light0specular)			' Set Up Specular Lighting
	glEnable(GL_LIGHTING)										' Enable Lighting
	glEnable(GL_LIGHT0)					   					' Enable Light0
	glShadeModel(GL_SMOOTH)									' Select Smooth Shading
	glMateriali(GL_FRONT, GL_SHININESS, 128)
	glClearColor(0.0, 0.0, 0.0, 0.5)						' Set The Clear Color To Black
	Return 1												' Return TRUE (Initialization Successful)
EndFunction

Function Update(milliseconds#)								' Perform Motion Updates Here
	If KeyDown(KEY_ESCAPE) End
	angle:+(milliseconds/5.0)						' Update angle Based On The Clock
EndFunction

Function Draw()												' Draw The Scene
	glClearColor(0.0, 0.0, 0.0, 0.25)						' Set The Clear Color To Black
	glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)		' Clear Screen And Depth Buffer
	glLoadIdentity()											' Reset The View

	RenderToTexture()											' Render To A Texture
	ProcessHelix()												' Draw Our Helix
	DrawBlur(25,.02)											' Draw The Blur Effect
	glFlush ()													' Flush The GL Rendering Pipeline
EndFunction

GLGraphics C_WIDTH,C_HEIGHT,32

Initialize()

Repeat
    Update(25)
    Draw()
	Flip
Forever
