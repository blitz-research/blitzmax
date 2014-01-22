
'Simple GL cube demo
'Written by Birdie

Import MaxGui.Drivers

Strict
SetGraphicsDriver GLGraphicsDriver(),GRAPHICS_BACKBUFFER|GRAPHICS_DEPTHBUFFER

Global ax#, ay#,tim#

Local w:TGadget = CreateWindow("Easy GL Cube in a GUI window", 10, 10, 512, 512 )

Local c:TGadget = CreateCanvas(0,0,w.ClientWidth(),w.ClientHeight(),w,0)
c.setlayout 1,1,1,1
CreateTimer( 60 )

While True
        WaitEvent()
        Select EventID()
                Case EVENT_WINDOWCLOSE
                        End
                Case EVENT_TIMERTICK
                        RedrawGadget c
                        
                Case EVENT_GADGETPAINT
                        SetGraphics CanvasGraphics( c )
                                Local wid = c.ClientWidth()
                                Local hgt = c.ClientHeight()
                                Local asp# = Float(wid)/Float(hgt)
                                
                                glViewport 0,0,wid,hgt
                                glMatrixMode GL_PROJECTION
                                glLoadIdentity
                                gluPerspective 45, asp, 1, 100
                                gltranslatef 0,0,-50+tim
                                tim=20*Cos(MilliSecs()/10.0)
                                
                                glMatrixMode GL_MODELVIEW
                                glLoadIdentity
                                
                                Local global_ambient#[]=[0.6#, 0.5#,  0.3#, 1.0#]
                                Local light0pos#[]=     [0.0#, 5.0#, 10.0#, 1.0#]
                                Local light0ambient#[]= [0.5#, 0.5#,  0.5#, 1.0#]
                                Local light0diffuse#[]= [0.3#, 0.3#,  0.3#, 1.0#]
                                Local light0specular#[]=[0.8#, 0.8#,  0.8#, 1.0#]
                        
                                Local lmodel_ambient#[]=[ 0.2#,0.2#,0.2#,1.0#]
                                glLightModelfv(GL_LIGHT_MODEL_AMBIENT,lmodel_ambient)
                        
                                glLightModelfv(GL_LIGHT_MODEL_AMBIENT, global_ambient)
                                glLightfv(GL_LIGHT0, GL_POSITION, light0pos)
                                glLightfv(GL_LIGHT0, GL_AMBIENT, light0ambient)
                                glLightfv(GL_LIGHT0, GL_DIFFUSE, light0diffuse)
                                glLightfv(GL_LIGHT0, GL_SPECULAR, light0specular)
                                glEnable(GL_LIGHTING)
                                glEnable(GL_LIGHT0)
                                glShadeModel(GL_SMOOTH)
                                glMateriali(GL_FRONT, GL_SHININESS, 128)
        
                                                                
                                glClearColor 0,0,0.5,1
                                glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

                                glEnable(GL_DEPTH_TEST)
                                
                                glRotatef ax,1,0,0
                                glRotatef ay,0,1,0
                                ax:+1
                                ay:+5
                                DrawSizeCube(7)
                                
                                Flip
                                
        EndSelect
Wend



Function DrawSizeCube(size#)
        size=-size
        'Front Face
        glBegin(GL_TRIANGLE_STRIP)
                glNormal3f( 0.0, 0.0, 1.0)
                glVertex3f( size, size,-size)
                glNormal3f( 0.0, 0.0, 1.0)
                glVertex3f(-size, size,-size)
                glNormal3f( 0.0, 0.0, 1.0)
                glVertex3f( size,-size,-size)
                glNormal3f( 0.0, 0.0, 1.0)
                glVertex3f(-size,-size,-size)
        glEnd
        'Back Face
        glNormal3f( 0.0, 0.0, -1.0)
        glBegin(GL_TRIANGLE_STRIP)
                glVertex3f(-size, size, size)
                glVertex3f( size, size, size)
                glVertex3f(-size,-size, size)
                glVertex3f( size,-size, size)
        glEnd
        'Right Face
        glNormal3f( 1.0, 0.0, 0.0)
        glBegin(GL_TRIANGLE_STRIP)
                glVertex3f(-size, size,-size)
                glVertex3f(-size, size, size)
                glVertex3f(-size,-size,-size)
                glVertex3f(-size,-size, size)
        glEnd
        'Left Face
        glNormal3f( -1.0, 0.0, 0.0)
        glBegin(GL_TRIANGLE_STRIP)
                glVertex3f( size, size, size)
                glVertex3f( size, size,-size)
                glVertex3f( size,-size, size)
                glVertex3f( size,-size,-size)
        glEnd
        'Bottom Face
        glNormal3f( 0.0, -1.0, 0.0)
        glBegin(GL_TRIANGLE_STRIP)
                glVertex3f( size, size,-size)
                glVertex3f( size, size, size)
                glVertex3f(-size, size,-size)
                glVertex3f(-size, size, size)
        glEnd
        'Top Face
        glNormal3f( 0.0, 1.0, 0.0)
        glBegin(GL_TRIANGLE_STRIP)
                glVertex3f( size,-size,-size)
                glVertex3f(-size,-size,-size)
                glVertex3f( size,-size, size)
                glVertex3f(-size,-size, size)
    glEnd
End Function

