' RndDouble.bmx
' Two players take turns shooting at a target. The first hit wins.
' Player 1 hits 30% of the time, player 2 hits 40%.
' What is the probability that player 1 wins?

Function winner()   ' play game once, return winner 1 or 2
    Repeat
        If RndDouble() < 0.3 Then Return 1
        If RndDouble() < 0.4 Then Return 2
    Forever
End Function

Local count[3]

trials = 1000000

For n = 1 to trials
    count[ winner() ] :+ 1
Next

Print "Estimated probability = " + ( Double( count[1] ) / Double( trials ) )
Print
Print "    Exact probability = " + ( 15.0 / 29.0 )

Input ; End