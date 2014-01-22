
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

		glColor3f 1.0,0.0,0.0						'Set The Color To Red
		glVertex3f 0.0, 1.0, 0.0						'Top
		glColor3f 0.0,1.0,0.0						'Set The Color To Green
		glVertex3f -1.0,-1.0, 0.0					'Bottom Left
		glColor3f 0.0,0.0,1.0						'Set The Color To Blue
		glVertex3f 1.0,-1.0, 0.0						'Bottom Right

	glEnd										'Finished Drawing The Triangle

	glLoadIdentity()								'Reset The Current Modelview Matrix
	glTranslatef 1.5,0.0,-6.0						'Move Right 1.5 Units And Into The Screen 6.0
	glRotatef rquad,1.0,0.0,0.0						'Rotate The Quad On The X axis ( New )

	glColor3f 0.5,0.5,1.0							'Set The Color To Blue One Time Only
	glBegin GL_QUADS								'Draw A Quad

		glVertex3f -1.0, 1.0, 0.0					'Top Left
		glVertex3f  1.0, 1.0, 0.0					'Top Right
		glVertex3f  1.0,-1.0, 0.0					'Bottom Right
		glVertex3f-1.0,-1.0,0.0						'Bottom Left
		
	glEnd										'Finished Drawing The Quad

	rtri:+0.7										'Increase The Rotation Variable For The Triangle ( New )
	rquad:-0.55									'Decrease The Rotation Variable For The Quad     ( New )

	Flip

Wend
