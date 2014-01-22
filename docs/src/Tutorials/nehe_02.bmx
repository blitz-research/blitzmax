
GLGraphics 640,480

glEnable GL_DEPTH_TEST								'Enables Depth Testing

glMatrixMode GL_PROJECTION							'Select The Projection Matrix
glLoadIdentity										'Reset The Projection Matrix

glFrustum -0.1, 0.1,-0.1, 0.1, 0.1, 100.0			'Setup The Projection Matrix Frustum

glMatrixMode GL_MODELVIEW							'Select The ModelView Matrix
glLoadIdentity										'Reset The ModelView Matrix

While Not KeyHit( KEY_ESCAPE )

	glClear GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT	'Clear The Screen And The Depth Buffer

	glLoadIdentity									'Reset The ModelView Matrix
	glTranslatef -1.5,0.0,-6.0						'Move Left 1.5 Units And Into The Screen 6.0

	glBegin GL_TRIANGLES							'Drawing Using Triangles

		glVertex3f  0.0, 1.0, 0.0					'Top
		glVertex3f -1.0,-1.0, 0.0					'Bottom Left
		glVertex3f  1.0,-1.0, 0.0					'Bottom Right

	glEnd											'Finished Drawing The Triangle

	glTranslatef 3.0,0.0,0.0						'Move Right 3 Units

	glBegin GL_QUADS								'Draw A Quad

		glVertex3f -1.0, 1.0, 0.0					'Top Left
		glVertex3f  1.0, 1.0, 0.0					'Top Right
		glVertex3f  1.0,-1.0, 0.0					'Bottom Right
		glVertex3f-1.0,-1.0,0.0						'Bottom Left
		
	glEnd											'Finished Drawing The Quad
	
	Flip

Wend