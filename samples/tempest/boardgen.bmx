Strict

' this generates the web coordinates for tempest

Local fh = WriteFile("boarddata.bmx")
Local a#

WriteLine fh,"' Continuous, CenterY, YOFFSET, x1,y1,...x16,y16  - created by boardgen"

For Local b = 1 To 48
Select b
Case 1 'circle (level 1)

	WriteLine fh,"'Level 1 - circle"
	Local s$ = "DefData "+True+",400"+",-80,"
	
	For a#=0 Until 	16 '360 Step 22.5 '30
		s$ = s$ + Int(Cos(a*22.5)*200) +","+ Int(Sin(a*22.5)*200)
		If a < 15 Then s$=s$+","
	Next
	WriteLine fh,s$
	
Case 2 ' square (level 2)
	Local stepsx#[] = [2.0,2.0,2.0,2.0,2.0,1.0,0.0,-1.0,-2.0,-2.0,-2.0,-2.0,-2.0,-1.0,0.0,1.0]
	Local stepsy#[] = [2.0,1.0,0.0,-1.0,-2.0,-2.0,-2.0,-2.0,-2.0,-1.0,0.0,1.0,2.0,2.0,2.0,2.0]

	WriteLine fh,"'Level 2 - square"
	Local s$ = "DefData "+True+",400"+",-80,"
	
	For a#=0 Until 16
		s$ = s$ + Int(-stepsx[a]*100) +","+ Int(stepsy[a]*100)
		If a < 15 Then s$=s$+","
	Next
	WriteLine fh,s$
	
Case 3 ' plus (level 3)
	Local stepsx#[] = [1.0,2.0,2.0,2.0,1.0,1.0,0.0,-1.0,-1.0,-2.0,-2.0,-2.0,-1.0,-1.0,0.0,1.0]
	Local stepsy#[] = [1.0,1.0,0.0,-1.0,-1.0,-2.0,-2.0,-2.0,-1.0,-1.0,0.0,1.0,1.0,2.0,2.0,2.0]

	WriteLine fh,"'Level 3 - plus"
	Local s$ = "DefData "+True+",400"+",-80,"
	
	For a#=0 Until 16
		s$ = s$ + Int(-stepsx[a]*100) +","+ Int(stepsy[a]*100)
		If a < 15 Then s$=s$+","
	Next
	WriteLine fh,s$

Case 4 'binoculars - level 4
	Local stepsx#[] = [ 1.0, 3.0, 5.5, 6.5, 6.5, 5.5, 3.0, 1.0,-1.0,-3.0,-5.5,-6.5,-6.5,-5.5,-3.0,-1.0]
	Local stepsy#[] = [-3.5,-5.0,-4.0,-2.0, 1.0, 3.0, 4.0, 2.5, 2.5, 4.0, 3.0, 1.0,-2.0,-4.0,-5.0,-3.5]

	WriteLine fh,"'Level 4 - binoculars"
	Local s$ = "DefData "+True+",380"+",-75,"
	
	For a#=0 Until 16
		s$ = s$ + Int(-stepsx[a]*40) +","+ Int(-stepsy[a]*30)
		If a < 15 Then s$=s$+","
	Next
	WriteLine fh,s$
	
Case 5 ' cross level 5
	Local stepsx#[] = [ 1.0, 2.0, 4.0, 7.0, 7.0, 4.0, 2.0, 1.0,-1.0,-2.0,-4.0,-7.0,-7.0,-4.0,-2.0,-1.0]
	Local stepsy#[] = [-7.0,-4.0,-2.0,-1.0, 1.0, 2.0, 4.0, 7.0, 7.0, 4.0, 2.0, 1.0,-1.0,-2.0,-4.0,-7.0]

	WriteLine fh,"'Level 5 - cross"
	Local s$ = "DefData "+True+",415"+",-90,"
	
	For a#=0 Until 16
		s$ = s$ + Int(-stepsx[a]*30) +","+ Int(-stepsy[a]*30)
		If a < 15 Then s$=s$+","
	Next
	WriteLine fh,s$
	
Case 6 ' triangle level 6
	Local stepsx#[] = [ 3.4, 5.0, 4.0, 3.0, 2.0, 1.0, 0.0,-1.0,-2.0,-3.0,-4.0,-5.0,-3.4,-1.6, 0.0, 1.6]
	Local stepsy#[] = [ 6.0, 6.0, 3.0, 0.0,-3.0,-6.0,-9.0,-6.0,-3.0, 0.0, 3.0, 6.0, 6.0, 6.0, 6.0, 6.0]

	WriteLine fh,"'Level 6 - triangle"
	Local s$ = "DefData "+True+",390"+",-40,"
	
	For a#=0 Until 16
		s$ = s$ + Int(-stepsx[a]*35) +","+ Int(stepsy[a]*28)
		If a < 15 Then s$=s$+","
	Next
	WriteLine fh,s$

Case 7 'clover (level 7)
	Local stepsx#[] = [1.8, 2.0, 1.0, 2.0, 1.8, 0.5, 0.0,-0.5,-1.8,-2.0,-1.0,-2.0,-1.8,-0.5, 0.0, 0.5]
	Local stepsy#[] = [1.8, 0.5, 0.0,-0.5,-1.8,-2.0,-1.0,-2.0,-1.8,-0.5, 0.0, 0.5, 1.8, 2.0, 1.0, 2.0]

	WriteLine fh,"'Level 7 - clover"
	Local s$ = "DefData "+True+",310"+",-10,"
	
	For a#=0 Until 16
		s$ = s$ + Int(-stepsx[a]*100) +","+ Int(stepsy[a]*100)
		If a < 15 Then s$=s$+","
	Next
	WriteLine fh,s$

Case 8 'V (level 8)
	Local stepsx#[] = [ 8.0, 7.0, 6.0, 5.0, 4.0, 3.0, 2.0, 1.0,-1.0,-2.0,-3.0,-4.0,-5.0,-6.0,-7.0,-8.0]
	Local stepsy#[] = [ 4.0, 3.0, 2.0, 1.0, 0.0,-1.0,-2.0,-3.0,-3.0,-2.0,-1.0, 0.0, 1.0, 2.0, 3.0, 4.0]

	WriteLine fh,"'Level 8 - Vee"
	Local s$ = "DefData "+False+",240"+",90,"
	
	For a#=0 Until 16
		s$ = s$ + Int(stepsx[a]*30) +","+ Int(-stepsy[a]*55)
		If a < 15 Then s$=s$+","
	Next
	WriteLine fh,s$
Case 9 'steps (level 9)
	Local stepsx#[] = [ 7.0, 7.0, 5.0, 5.0, 3.0, 3.0, 1.0, 1.0,-1.0,-1.0,-3.0,-3.0,-5.0,-5.0,-7.0,-7.0]
	Local stepsy#[] = [-3.0,-1.0,-1.0, 1.0, 1.0, 3.0, 3.0, 5.0, 5.0, 3.0, 3.0, 1.0, 1.0,-1.0,-1.0,-3.0]

	WriteLine fh,"'Level 9 - steps"
	Local s$ = "DefData "+False+",200"+",100,"
	
	For a#=0 Until 16
		s$ = s$ + Int(stepsx[a]*40) +","+ Int(stepsy[a]*36)
		If a < 15 Then s$=s$+","
	Next
	WriteLine fh,s$
	
Case 10 'U (level 10)
	Local stepsx#[] = [ 7.0, 7.0, 7.0, 7.0, 6.8, 5.5, 3.5, 1.0,-1.0,-3.5,-5.5,-6.8,-7.0,-7.0,-7.0,-7.0]
	Local stepsy#[] = [-5.0,-3.0,-1.0, 1.0, 3.0, 5.0, 6.5, 7.0, 7.0, 6.5, 5.0, 3.0, 1.0,-1.0,-3.0,-5.0]

	WriteLine fh,"'Level 10 - U"
	Local s$ = "DefData "+False+",500"+",-200,"
	
	For a#=0 Until 16
		s$ = s$ + Int(stepsx[a]*30) +","+ Int(stepsy[a]*35)
		If a < 15 Then s$=s$+","
	Next
	WriteLine fh,s$

Case 11 'line (level 11)
	Local x# = -7.5

	WriteLine fh,"'Level 11 - horiz line"
	Local s$ = "DefData "+False+",230"+",70,"
	For a#=0 Until 16
		s$ = s$ + Int(-x*40) +","+"160"
		x:+1.0
		If a < 15 Then s$=s$+","
	Next
	WriteLine fh,s$
	
Case 12 'heart (level 12)
	Local stepsx#[] = [2.0, 5.0, 6.0, 6.0, 5.0, 3.0, 0.0,-3.0,-5.0,-6.0,-6.0,-5.0,-2.0,-0.5, 0.0, 0.5]
	Local stepsy#[] = [6.0, 5.7, 2.0,-2.0,-5.0,-7.0,-8.0,-7.0,-5.0,-2.0, 2.0, 5.7, 6.0, 3.0,-1.0, 3.0]

	WriteLine fh,"'Level 12 - heart"
	Local s$ = "DefData "+True+",540"+",-210,"
	
	For a#=0 Until 16
		s$ = s$ + Int(stepsx[a]*30) +","+ Int(-stepsy[a]*30)
		If a < 15 Then s$=s$+","
	Next
	WriteLine fh,s$

Case 13 ' star (level 13)
	Local stepsx#[] = [1.5,2.5,2.0, 2.5, 1.5, 1.0, 0.0,-1.0,-1.5,-2.5,-2.0,-2.5,-1.5,-1.0,0.0,1.0]
	Local stepsy#[] = [1.3,1.0,0.0,-1.0,-1.3,-2.2,-1.7,-2.2,-1.3,-1.0, 0.0, 1.0, 1.3, 2.2,1.7,2.2]

	WriteLine fh,"'Level 13 - star"
	Local s$ = "DefData "+True+",415"+",-95,"
	
	For a#=0 Until 16
		s$ = s$ + Int(-stepsx[a]*80) +","+ Int(stepsy[a]*100)
		If a < 15 Then s$=s$+","
	Next
	WriteLine fh,s$

Case 14 'W (level 14)
	Local stepsx#[] = [ 8.0, 7.0, 6.7, 6.1, 4.7, 2.7, 1.5, 0.6,-0.6,-1.5,-2.7,-4.7,-6.1,-6.7,-7.0,-8.0]
	Local stepsy#[] = [-3.0,-1.0, 1.5, 3.7, 5.2, 5.2, 4.0, 2.0, 2.0, 4.0, 5.2, 5.2, 3.7, 1.5,-1.0,-3.0]

	WriteLine fh,"'Level 14 - W"
	Local s$ = "DefData "+False+",140"+",120,"
	
	For a#=0 Until 16
		s$ = s$ + Int(stepsx[a]*35) +","+ Int(stepsy[a]*35)
		If a < 15 Then s$=s$+","
	Next
	WriteLine fh,s$

Case 15 ' broken v (level 15)

	Local stepsx#[] = [ -8.0, -7.5, -7.0, -6.5, -4.0, -2.8, -2.1, -1.1, 1.0, 2.5, 3.7, 4.5, 5.0, 5.5, 6.5,8.0]
	Local stepsy#[] = [ 8.0, 5.4, 3.0, 0.2, 0.7,-1.5,-4.0,-5.5,-5.0,-6.5,-4.0,-2.0, 1.0, 3.0, 5.0, 7.0]

	WriteLine fh,"'Level 15 - broken V"
	Local s$ = "DefData "+False+",240"+",75,"
	
	For a#=0 Until 16
		s$ = s$ + Int(-stepsx[a]*35) +","+ Int(-stepsy[a]*30)
		If a < 15 Then s$=s$+","
	Next
	WriteLine fh,s$

Case 16 'level 16 infinity
	Local stepsx#[] = [0.0,-1.0,-3.0,-5.0,-6.0,-5.0,-3.0,-1.0, 0.0, 1.0, 3.0, 5.0, 6.0, 5.0, 3.0, 1.0]
	Local stepsy#[] = [0.0, 2.0, 3.0, 2.0, 0.0,-2.0,-3.0,-2.0, 0.0, 2.0, 3.0, 2.0, 0.0,-2.0,-3.0,-2.0]

	WriteLine fh,"'Level 16 - infinity"
	Local s$ = "DefData "+True+",310"+",0,"
	
	For a#=0 Until 16
		s$ = s$ + Int(-stepsx[a]*48) +","+ Int(-stepsy[a]*55)
		If a < 15 Then s$=s$+","
	Next
	WriteLine fh,s$
	

'Tubes
Case 17 ' octagon (level 1)
	Local stepsx#[] = [2.0, 3.0, 3.0, 3.0, 2.0, 1.0, 0.0,-1.0,-2.0,-3.0,-3.0,-3.0,-2.0,-1.0,0.0,1.0]
	Local stepsy#[] = [1.5, 1.0, 0.0,-1.0,-1.5,-2.0,-2.0,-2.0,-1.5,-1.0, 0.0, 1.0, 1.5, 2.0,2.0,2.0]

	WriteLine fh,"'Level 17 - Tubes 1 - octagon"
	Local s$ = "DefData "+True+",400"+",-80,"
	
	For a#=0 Until 16
		s$ = s$ + Int(-stepsx[a]*60) +","+ Int(stepsy[a]*80)
		If a < 15 Then s$=s$+","
	Next
	WriteLine fh,s$
	
Case 18 ' tear (level 2)
	Local stepsx#[] = [ 3.5, 4.5, 4.5, 3.5, 2.0, 1.0, 0.0,-1.0,-2.0,-3.5,-4.5,-4.5,-3.5,-1.6, 0.0, 1.6]
	Local stepsy#[] = [ 5.0, 3.0, 0.0,-2.0,-4.0,-6.0,-8.0,-6.0,-4.0,-2.0, 0.0, 3.0, 5.0, 6.0, 6.0, 6.0]

	WriteLine fh,"'Level 18 - Tubes 2 - tear"
	Local s$ = "DefData "+True+",390"+",-40,"
	
	For a#=0 Until 16
		s$ = s$ + Int(-stepsx[a]*35) +","+ Int(stepsy[a]*30)
		If a < 15 Then s$=s$+","
	Next
	WriteLine fh,s$

Case 19 'closed V (level 3)
	WriteLine fh,"'Level 19 - Tubes 3 - false closed V"
	WriteLine fh,"DefData 0,400,0,0,-210,75,-210,150,-175,225,-125,225,-50,150,-25,95,45,50,110,-50,110,-95,45,-150,-25,-225,-50,-225,-125,-150,-175,-75,-210,0,-210"
	
Case 20 ' bowtie (level 4)
	Local stepsx#[] = [3.0, 5.0, 5.0, 5.0, 5.0, 3.0, 1.0,-1.0,-3.0,-5.0,-5.0,-5.0,-5.0,-3.0,-1.0, 1.0]
	Local stepsy#[] = [1.5, 3.0, 1.5,-1.5,-3.0,-1.5,-1.0,-1.0,-1.5,-3.0,-1.5, 1.5, 3.0, 1.5, 1.0, 1.0]

	WriteLine fh,"'Level 20 - Tubes 4 - bowtie"
	Local s$ = "DefData "+True+",300"+",0,"
	
	For a#=0 Until 16
		s$ = s$ + Int(-stepsx[a]*50) +","+ Int(stepsy[a]*50)
		If a < 15 Then s$=s$+","
	Next
	WriteLine fh,s$

Case 21 ' | (level 5)
	Local stepsx#[] = [ 7.0, 7.0, 7.0, 7.0, 7.0, 6.5, 6.0, 5.0, 4.0, 3.5, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0]
	Local stepsy#[] = [ 7.0, 6.0, 5.0, 4.0, 3.0, 2.0, 1.0, 0.0,-1.0,-2.0,-3.0,-4.0,-5.0,-6.0,-7.0,-8.0]

	WriteLine fh,"'Level 21 - Tubes 5 - vert bent line"
	Local s$ = "DefData "+False+",280"+",0,"
	
	For a#=0 Until 16
		s$ = s$ + Int(stepsx[a]*30) +","+ Int(-stepsy[a]*30)
		If a < 15 Then s$=s$+","
	Next
	WriteLine fh,s$

Case 22 ' [] (level 6)
	Local stepsx#[] = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,-1.0,-1.0,-1.0,-1.0,-1.0,-1.0,-1.0,-1.0, 1.0]
	Local stepsy#[] = [5.0, 3.0, 1.0,-1.0,-3.0,-5.0,-7.0,-7.0,-5.0,-3.0,-1.0, 1.0, 3.0, 5.0, 7.0, 7.0]

	WriteLine fh,"'Level 22 - Tubes 6 - thin rectangle"
	Local s$ = "DefData "+True+",300"+",0,"
	
	For a#=0 Until 16
		s$ = s$ + Int(-stepsx[a]*30) +","+ Int(stepsy[a]*30)
		If a < 15 Then s$=s$+","
	Next
	WriteLine fh,s$
	

Case 23 ' @ (level 7)
	Local stepsx#[] = [ 3.0, 2.0, 1.0, 0.0,-1.0,-2.0,-3.0,-2.0,-1.0, 0.0, 1.0, 2.0, 1.0, 0.0,-1.0, 0.0]
	Local stepsy#[] = [ 0.0, 1.0, 2.0, 3.0, 2.0, 1.0, 0.0,-1.0,-2.0,-3.0,-2.0,-1.0, 0.0, 1.0, 0.0,-1.0]

	WriteLine fh,"'Level 23 - Tubes 7 - spiral"
	Local s$ = "DefData "+False+",300"+",0,"
	
	For a#=0 Until 16
		s$ = s$ + Int(-stepsx[a]*70) +","+ Int(-stepsy[a]*70)
		If a < 15 Then s$=s$+","
	Next
	WriteLine fh,s$


Case 24 ' ^U^ (level 8)
	Local stepsx#[] = [8.0, 6.0, 4.0, 2.0, 1.0, 1.0, 1.0, 1.0,-1.0,-1.0,-1.0,-1.0,-2.0,-4.0,-6.0,-8.0]
	Local stepsy#[] = [1.0, 2.0, 2.0, 1.0,-1.0,-3.0,-5.0,-7.0,-7.0,-5.0,-3.0,-1.0, 1.0, 2.0, 2.0, 1.0]

	WriteLine fh,"'Level 24 - Tubes 8 - ^U^"
	Local s$ = "DefData "+False+",100"+",90,"
	
	For a#=0 Until 16
		s$ = s$ + Int(stepsx[a]*30) +","+ Int(-stepsy[a]*30)
		If a < 15 Then s$=s$+","
	Next
	WriteLine fh,s$
	

Case 25 ' half spade (level 9)
	Local stepsx#[] = [ 1.0, 1.0, 2.0, 4.0, 6.0, 7.0, 8.0, 9.0, 8.0, 6.0, 4.0, 2.0, 1.0, 1.0, 1.0, 1.0]
	Local stepsy#[] = [ 6.0, 5.0, 4.0, 3.0, 2.0, 1.0, 0.0,-1.0,-2.5,-4.0,-4.0,-2.5,-1.0,-2.0,-3.0,-4.0]

	WriteLine fh,"'Level 25 - Tubes 9 - half spade"
	Local s$ = "DefData "+False+",350"+",0,"
	
	For a#=0 Until 16
		s$ = s$ + Int(stepsx[a]*30) +","+ Int(-stepsy[a]*45)
		If a < 15 Then s$=s$+","
	Next
	WriteLine fh,s$

Case 26 ' / (level 10)
	Local stepsx#[] = [-7.5,-6.5,-5.5,-4.5,-3.5,-2.5,-1.5,-0.5, 0.5, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5]
	Local stepsy#[] = [ 8.0, 7.0, 6.0, 5.0, 4.0, 3.0, 2.0, 1.0, 0.0,-1.0,-2.0,-3.0,-4.0,-5.0,-6.0,-7.0]

	WriteLine fh,"'Level 26 - Tubes 10 - diagonal line"
	Local s$ = "DefData "+False+",250"+",90,"
	
	For a#=0 Until 16
		s$ = s$ + Int(-stepsx[a]*40) +","+ Int(-stepsy[a]*25)
		If a < 15 Then s$=s$+","
	Next
	WriteLine fh,s$

Case 27 ' --- (level 11)
	Local stepsx#[] = [-7.0,-6.0,-5.0,-4.0,-3.0,-2.0,-1.0, 0.0, 0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0]
	Local stepsy#[] = [ 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0,-1.0,-0.0,-1.0,-0.0,-1.0,-0.0,-1.0,-0.0]

	WriteLine fh,"'Level 27 - Tubes 11 - jagged horz line"
	Local s$ = "DefData "+False+",200"+",200,"
	
	For a#=0 Until 16
		s$ = s$ + Int(-stepsx[a]*40) +","+ Int(stepsy[a]*25)
		If a < 15 Then s$=s$+","
	Next
	WriteLine fh,s$
	
Case 28 ' star (level 12)
	Local stepsx#[] = [1.0, 2.0, 1.5, 2.0, 1.0, 1.0, 0.0,-1.0,-1.0,-2.0,-1.5,-2.0,-1.0,-1.0, 0.0, 1.0]
	Local stepsy#[] = [1.0, 1.0, 0.0,-1.0,-1.0,-2.0,-1.5,-2.0,-1.0,-1.0, 0.0, 1.0, 1.0, 2.0, 1.5, 2.0]

	WriteLine fh,"'Level 28 - Tubes 12 - star/cross"
	Local s$ = "DefData "+True+",400"+",-80,"
	
	For a#=0 Until 16
		s$ = s$ + Int(-stepsx[a]*100) +","+ Int(stepsy[a]*100)
		If a < 15 Then s$=s$+","
	Next
	WriteLine fh,s$	

Case 29 ' claw (level 13)
	Local stepsx#[] = [4.0, 3.0, 4.5, 6.0, 4.0, 2.0, 0.0,-2.0,-4.0,-6.0,-4.5,-3.0,-4.0,-2.0, 0.0, 2.0]
	Local stepsy#[] = [1.0, 4.0, 2.0, 0.0,-2.0,-4.0,-6.0,-4.0,-2.0, 0.0, 2.0, 4.0, 1.0, 0.0,-1.0, 0.0]

	WriteLine fh,"'Level 29 - Tubes 13 - claw"
	Local s$ = "DefData "+True+",400"+",-100,"
	
	For a#=0 Until 16
		s$ = s$ + Int(stepsx[a]*50) +","+ Int(-stepsy[a]*35)
		If a < 15 Then s$=s$+","
	Next
	WriteLine fh,s$
	
Case 30 ' ^-^ (level 14)
	Local stepsx#[] = [6.7, 5.7, 4.7, 3.7, 3.0, 2.5, 1.5, 0.5,-0.5,-1.5,-2.5,-3.0,-3.7,-4.7,-5.7,-6.7]
	Local stepsy#[] = [0.4, 1.5, 1.5, 0.5,-1.0,-3.0,-3.0,-3.0,-3.0,-3.0,-3.0,-1.0, 0.5, 1.5, 1.5, 0.4]

	WriteLine fh,"'Level 30 - Tubes 14 - ^-^"
	Local s$ = "DefData "+False+",200"+",150,"
	
	For a#=0 Until 16
		s$ = s$ + Int(stepsx[a]*40) +","+ Int(-stepsy[a]*25)
		If a < 15 Then s$=s$+","
	Next
	WriteLine fh,s$
	
Case 31 ' bent steps (level 15)
	Local stepsx#[] = [ 7.0, 6.0, 8.0, 6.0, 6.0, 4.0, 2.0, 1.0,-1.0,-2.0,-4.0,-6.0,-6.0,-8.0,-6.0,-7.0]
	Local stepsy#[] = [-3.0,-1.0, 0.0, 1.0, 3.0, 2.0, 4.0, 2.0, 2.0, 4.0, 2.0, 3.0, 1.0, 0.0,-1.0,-3.0]

	WriteLine fh,"'Level 31 - Tubes 15 - bent steps"
	Local s$ = "DefData "+False+",200"+",80,"
	
	For a#=0 Until 16
		s$ = s$ + Int(stepsx[a]*35) +","+ Int(stepsy[a]*50)
		If a < 15 Then s$=s$+","
	Next
	WriteLine fh,s$
	
Case 32 'triple infinity <><><>  (level 16)
	Local stepsx#[] = [ 1.0, 3.0, 5.0, 8.0, 8.0, 5.0, 3.0, 1.0,-1.0,-3.0,-5.0,-8.0,-8.0,-5.0,-3.0,-1.0]
	Local stepsy#[] = [-3.0, 0.0, 3.0, 1.0,-1.0,-3.0, 0.0, 3.0, 3.0, 0.0,-3.0,-1.0, 1.0, 3.0, 0.0,-3.0]

	WriteLine fh,"'Level 32 - Tubes 16 - triple infinity"
	Local s$ = "DefData "+True+",310"+",0,"
	
	For a#=0 Until 16
		s$ = s$ + Int(stepsx[a]*35) +","+ Int(-stepsy[a]*35)
		If a < 15 Then s$=s$+","
	Next
	WriteLine fh,s$
	
Case 33 'arc 
	WriteLine fh,"'Level 33 - rainbow"
	Local s$ = "DefData "+False+",480"+",-80,"
	
	For a#=0 Until 16 
		s$ = s$ + Int(-Cos((a+.5)*11.25)*200) +","+ Int(-Sin((a+.5)*11.25)*240)
		If a < 15 Then s$=s$+","
	Next
	WriteLine fh,s$

Case 34 ' pointy square 
	WriteLine fh,"'Level 34 - pointy square"
	WriteLine fh,"DefData 1,400,-80,-200,200,-170,100,-130,0,-170,-100,-200,-200,-100,-170,0,-130,100,-170,200,-200,170,-100,130,0,170,100,200,200,100,170,0,130,-100,170"
	
Case 35 ' 3 leaf
	WriteLine fh,"'Level 35 - 3 leaf clover"
	WriteLine fh,"DefData 1,375,0,0,0,170,0,260,66,190,144,75,118,0,0,-85,-128,-80,-228,0,-270,80,-228,85,-128,0,0,-75,118,-190,144,-260,66,-170,0"
	
Case 36 ' lips	
	WriteLine fh,"'Level 36 - lips"
	WriteLine fh,"DefData 1,400,-80,290,0,244,76,171,141,86,164,0,160,-86,164,-171,141,-244,76,-290,0,-244,-76,-171,-141,-76,-154,0,-100,76,-154,171,-141,244,-76"

Case 37 ' ~
	WriteLine fh,"'Level 37 - /\/"
	WriteLine fh,"DefData 0,310,0,280,-60,280,21,270,108,240,170,170,198,100,173,60,117,20,41,-20,-41,-60,-117,-100,-173,-170,-198,-240,-170,-270,-108,-280,-21,-280,60"
	
Case 38 ' cat
	WriteLine fh,"'Level 38 - cat"
	WriteLine fh,"DefData 1,400,-80,0,-100,66,-124,131,-111,204,-186,220,-60,214,46,161,121,86,174,0,180,-86,174,-161,121,-214,46,-220,-60,-204,-186,-131,-111,-66,-124"

Case 39 ' rocket
	WriteLine fh,"'Level 39 - rocket"
	WriteLine fh,"DefData 1,390,-40,-119,168,-175,108,-120,64,-65,0,-30,-74,-15,-158,0,-242,15,-158,30,-74,65,0,110,64,175,108,119,168,56,128,0,168,-56,128"
	
Case 40 ' pontiac 
	WriteLine fh,"'Level 40 - pontiac"
	WriteLine fh,"DefData 1,370,-50,160,-150,250,-190,200,-110,150,-30,100,50,50,130,0,210,-50,130,-100,50,-150,-30,-200,-110,-250,-190,-160,-150,-75,-110,0,-70,75,-110"

Case 41 ' Ev3
	WriteLine fh,"'Level 41 - Ev3"
	WriteLine fh,"DefData 0,220,40,170,-188,270,-136,230,-56,270,36,190,46,190,148,100,148,40,220,-40,220,-100,148,-190,148,-190,56,-270,36,-230,-56,-270,-136,-170,-188"
	
Case 42 ' \O/
	WriteLine fh,"'Level 42 - \O/"
	WriteLine fh,"DefData 0,270,30,300,130,200,160,100,160,0,140,-100,90,-150,0,-130,-100,-50,-170,50,-170,130,-100,150,0,100,90,0,140,-100,160,-200,160,-300,130"
	
Case 43 ' yakhorns
	WriteLine fh,"'Level 43 - yakhorns"
	WriteLine fh, "DefData 0,200,80,120,-210,200,-185,240,-100,200,-25,120,0,90,65,60,130,30,195,-30,195,-60,130,-90,65,-120,0,-200,-25,-240,-100,-200,-185,-120,-210"

Case 44 ' asteroid
	WriteLine fh,"'Level 44 - asteroid"
	WriteLine fh,"DefData 1,300,40,-150,90,-220,30,-220,-90,-140,-90,-60,-90,-100,-200,0,-200,100,-200,160,-140,230,-70,100,-30,160,20,220,70,130,170,70,100,-70,160"

Case 45 ' broken house
	WriteLine fh,"'Level 45 - broken house"
	WriteLine fh, "DefData 0,140,90,70,-138,150,-116,200,-46,200,36,200,116,230,228,120,178,40,210,-40,210,-120,178,-230,228,-200,116,-200,36,-200,-46,-150,-116,-70,-138"

Case 46 ' overlap star +
	WriteLine fh,"'Level 46 - overlap star"
	WriteLine fh,"DefData 1,300,0,-80,80,-100,10,-200,0,-100,-10,-80,-80,-10,-100,0,-200,10,-100,80,-80,100,-10,200,0,100,10,80,80,10,100,0,200,-10,100"

Case 47 ' pentagon
	WriteLine fh,"'Level 47 - pentagon"
	WriteLine fh,"DefData 1,440,-130,160,-80,250,-20,220,60,190,140,160,220,80,220,0,220,-80,220,-160,220,-190,140,-220,60,-250,-20,-160,-80,-75,-140,0,-190,75,-140"

Case 48 ' skull
	WriteLine fh,"'Level 48 - skull"
	WriteLine fh,"DefData 1,400,-80,180,40,124,86,111,151,66,204,0,220,-66,204,-111,151,-124,86,-180,40,-194,-46,-161,-131,-86,-184,0,-200,86,-184,161,-131,194,-46"
		
End Select	
Next

CloseFile(fh)

