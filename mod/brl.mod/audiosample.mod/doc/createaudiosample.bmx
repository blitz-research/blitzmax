' createaudiosample.bmx

Local sample:TAudioSample=CreateAudioSample( 32,11025,SF_MONO8 )

For Local k=0 Until 32
        sample.samples[k]=Sin(k*360/32)*127.5+127.5
Next

Local sound:TSound=LoadSound( sample,True )

PlaySound(sound)

Input