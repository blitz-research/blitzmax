'===============================================================================
' Little Shooty Test Thing
' Code & Stuff by Richard Olpin (rik@olpin.net)
'===============================================================================
' Player shots
'===============================================================================

Global bullets:TList=New TList

Const	WPN_NORMAL=0
Const 	WPN_DEFLASER=1

Type TBullet
	Global image
	
	Field link:TLink
	Field x#,y#,xs#,ys#
	Field rot#,alpha#,img

	Method Update()
		x:+xs
		alpha:+0.02
		If x>WIDTH
			' remove
			Return
		EndIf
		
		For Local e:TEnemy =EachIn enemies
			If ( x>(e.x-16) And x<(e.x+16) And y>(e.y-16) And y<(e.y+16) ) Then 
				e.hit()
				score:+100
			EndIf
		Next
		
		SetScale 1,1
		If player.primary_weapon = WPN_DEFLASER Then SetScale 1,0.5
		SetBlend ALPHABLEND
		DrawImage img,x,y
		
	End Method

	Function CreateBullet:TBullet( img, x#,y#, xs# )
		Local bullet:TBullet=New TBullet
		bullet.x=x
		bullet.y=y
		bullet.xs=xs
		bullet.alpha=0.1
		bullet.img=image
		bullets.AddLast bullet
	End Function

End Type

'===============================================================================
'
'===============================================================================