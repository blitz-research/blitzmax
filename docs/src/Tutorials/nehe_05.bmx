
GLGraphics 640,480

glEnable GL_DEPTH_TEST								'Enables Depth Testing

glMatrixMode GL_PROJECTION							'Select The Projection Matrix
glLoadIdentity										'Reset The Projection Matrix

glFrustum -0.1, 0.1,-0.1, 0.1, 0.1, 100.0				'Setup The Projection Matrix Frustum

glMatrixMode GL_MODELVIEW							'Select The ModelView Matrix
glLoadIdentity										'Reset The ModelView Matrix

Local rtri:Float									'Angle For The Triangle ( New )
Local rquad:Float									'Angle For The Quad     ( New )

While Not KeyHit( KEY_ESCAPE )

	glClear GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT		'Clear The Screen And The Depth Buffer

	glLoadIdentity									'Reset The ModelView Matrix
	glTranslatef -1.5,0.0,-6.0						'Move Left 1.5 Units And Into The Screen 6.0

	glRotatef rtri,0.0,1.0,0.0						'Rotate The Triangle On The Y axis ( New )

	glBegin GL_TRIANGLES							'Drawing Using Triangles

		glColor3f 1.0,0.0,0.0						'Red
		glVertex3f 0.0, 1.0, 0.0						'Top Of Triangle (Front)
		glColor3f 0.0,1.0,0.0						'Green
		glVertex3f -1.0,-1.0, 1.0					'Left Of Triangle (Front)
		glColor3f 0.0,0.0,1.0						'Blue
		glVertex3f 1.0,-1.0, 1.0						'Right Of Triangle (Front)
	
		glColor3f 1.0,0.0,0.0						'Red
		glVertex3f 0.0, 1.0, 0.0						'Top Of Triangle (Right)
		glColor3f 0.0,0.0,1.0						'Blue
		glVertex3f 1.0,-1.0, 1.0						'Left Of Triangle (Right)
		glColor3f 0.0,1.0,0.0						'Green
		glVertex3f 1.0,-1.0, -1.0					'Right Of Triangle (Right)

		glColor3f 1.0,0.0,0.0						'Red
		glVertex3f 0.0, 1.0, 0.0						'Top Of Triangle (Back)
		glColor3f 0.0,1.0,0.0						'Green
		glVertex3f 1.0,-1.0, -1.0					'Left Of Triangle (Back)
		glColor3f 0.0,0.0,1.0						'Blue
		glVertex3f -1.0,-1.0, -1.0					'Right Of Triangle (Back)

		glColor3f 1.0,0.0,0.0						'Red
		glVertex3f 0.0, 1.0, 0.0						'Top Of Triangle (Left)
		glColor3f 0.0,0.0,1.0						'Blue
		glVertex3f -1.0,-1.0,-1.0					'Left Of Triangle (Left)
		glColor3f 0.0,1.0,0.0						'Green
		glVertex3f -1.0,-1.0, 1.0					'Right Of Triangle (Left)

	glEnd										'Finished Drawing The Pyramid

	glLoadIdentity()								'Reset The Current Modelview Matrix
	glTranslatef 1.5,0.0,-7.0						'Move Right 1.5 Units And Into The Screen 7.0
	glRotatef rquad,1.0,1.0,1.0						'Rotate The Quad On The X, Y and Z axis ( New )

	glColor3f 0.5,0.5,1.0							'Set The Color To Blue One Time Only
	glBegin GL_QUADS								'Draw A Quad

		glColor3f 0.0,1.0,0.0						'Set The Color To Green
		glVertex3f  1.0, 1.0,-1.0					'Top Right Of The Quad (Top)
		glVertex3f -1.0, 1.0,-1.0					'Top Left Of The Quad (Top)
		glVertex3f -1.0, 1.0, 1.0					'Bottom Left Of The Quad (Top)
		glVertex3f  1.0, 1.0, 1.0					'Bottom Right Of The Quad (Top)

		glColor3f 1.0,0.5,0.0						'Set The Color To Orange
		glVertex3f  1.0,-1.0, 1.0					'Top Right Of The Quad (Bottom)
		glVertex3f -1.0,-1.0, 1.0					'Top Left Of The Quad (Bottom)
		glVertex3f -1.0,-1.0,-1.0					'Bottom Left Of The Quad (Bottom)
		glVertex3f  1.0,-1.0,-1.0					'Bottom Right Of The Quad (Bottom)

		glColor3f 1.0,0.0,0.0						'Set The Color To Red
		glVertex3f 1.0, 1.0, 1.0						'Top Right Of The Quad (Front)
		glVertex3f -1.0, 1.0, 1.0					'Top Left Of The Quad (Front)
		glVertex3f -1.0,-1.0, 1.0					'Bottom Left Of The Quad (Front)
		glVertex3f  1.0,-1.0, 1.0					'Bottom Right Of The Quad (Front)

		glColor3f 1.0,1.0,0.0						'Set The Color To Yellow
		glVertex3f  1.0,-1.0,-1.0					'Bottom Left Of The Quad (Back)
		glVertex3f -1.0,-1.0,-1.0					'Bottom Right Of The Quad (Back)
		glVertex3f -1.0, 1.0,-1.0					'Top Right Of The Quad (Back)
		glVertex3f  1.0, 1.0,-1.0					'Top Left Of The Quad (Back)

		glColor3f 0.0,0.0,1.0						'Set The Color To Blue
		glVertex3f -1.0, 1.0, 1.0					'Top Right Of The Quad (Left)
		glVertex3f -1.0, 1.0,-1.0					'Top Left Of The Quad (Left)
		glVertex3f -1.0,-1.0,-1.0					'Bottom Left Of The Quad (Left)
		glVertex3f -1.0,-1.0, 1.0					'Bottom Right Of The Quad (Left)

		glColor3f 1.0,0.0,1.0						'Set The Color To Violet
		glVertex3f  1.0, 1.0,-1.0					'Top Right Of The Quad (Right)
		glVertex3f  1.0, 1.0, 1.0					'Top Left Of The Quad (Right)
		glVertex3f  1.0,-1.0, 1.0					'Bottom Left Of The Quad (Right)
		glVertex3f  1.0,-1.0,-1.0					'Bottom Right Of The Quad (Right)
		
	glEnd										'Finished Drawing The Box

	rtri:+0.6										'Increase The Rotation Variable For The Triangle ( New )
	rquad:-0.85									'Decrease The Rotation Variable For The Quad     ( New )

	Flip

Wend
