' Rand.bmx
' Toss a pair of dice. Result is in the range 1+1 to 6+6.
' Count how many times each result appears.

Local count[13]

For n = 1 To 3600
    toss = Rand(1,6) + Rand(1,6)
    count[toss] :+ 1
Next

For toss = 2 To 12
    Print LSet(toss, 5)+count[toss]
Next
