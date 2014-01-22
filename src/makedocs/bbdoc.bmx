
Strict

Import "parse.bmx"

'still pretty ugly - could probably be done in a few lines with Bah.RegEx!

Type TBBLinkResolver

	Method ResolveLink$( link$ ) Abstract

End Type

Private

'finds a 'span' style tag starting at index i - eg: @bold or @{this is bold}
'
'returns bit after tag, fills in b and e with begin and end of range.
Function FindBBTag$( text$,tag$,i,b Var,e Var )
	Repeat
		i=text.Find( tag,i )
		If i=-1 Return
		If i=0 Or text[i-1]<=32 Or text[i-1]=Asc(">") Exit
		i:+tag.length
	Forever
	b=i
	i:+1
	If i=text.length Return
	Local t$
	If text[i]=Asc("{")
		i:+1
		While i<text.length And text[i]<>Asc("}")
			i:+1
		Wend
		t=text[b+2..i]
		If i<text.length i:+1
		e=i
	Else
		i:+1
		While i<text.length And (IsIdentChar(text[i]) Or text[i]=Asc("."))
			i:+1
		Wend
		If text[i-1]=Asc(".") i:-1
		t=text[b+1..i]		
		e=i
	EndIf
	Return t
End Function

'does simple html tags, bold, italic etc.	
Function FormatBBTags( text$ Var,bbTag$,htmlTag$ )
	Local i
	Repeat
		Local b,e
		Local t$=FindBBTag( text,bbTag,i,b,e )
		If Not t Return
		
		t="<"+htmlTag+">"+t+"</"+htmlTag+">"
		text=text[..b]+t+text[e..]
		i=b+t.length
	Forever
End Function

Public

Function BBToHtml2$( text$,doc:TBBLinkResolver )
	Local i

	'newlines
	text=text.Replace( "\~n","<br>~n" )
	
	'paras
	text=text.Replace( "~n~n","~n<p>~n" )

	'tabs
	text=text.Replace( "~n~t","~n&nbsp;&nbsp; " )
	
	'headings
	i=0
	Local hl=1
	Repeat
		i=text.Find( "~n+",i )
		If i=-1 Exit
		
		Local i2=text.Find( "~n",i+2 )
		If i2=-1 Exit
		
		Local q$=text[i+2..i2]
		q="<h"+hl+">"+q+"</h"+hl+">"
		
		If hl=1 hl=2
		
		text=text[..i]+q+text[i2..]
		i:+q.length
	Forever
	
	'tables
	i=0
	Repeat
		i=text.Find( "~n[",i )
		If i=-1 Exit
		
		Local i2=text.Find( "~n]",i+2 )
		If i2=-1 Exit
		
		Local q$=text[i+2..i2]
		
		If q.Find( " | " )=-1	'list?
			q=q.Replace( "~n*","<li>" )
			q="<ul>"+q+"</ul>"
		Else
			q=q.Replace( "~n*","</td></tr><tr><td> " )
			q=q.Replace( " | ","</td><td>" )
			q="~n<table><tr><td>"+q+"</table>~n"
		EndIf
		
		text=text[..i]+q+text[i2+2..]
		i:+q.length
	Forever
	
	'quotes
	i=0
	Repeat
		i=text.Find( "~n{",i )
		If i=-1 Exit
		
		Local i2=text.Find(  "~n}",i+2 )
		If i2=-1 Exit
		
		Local q$=text[i+2..i2]
		
		q="<blockquote>"+q+"</blockquote>"
		
		text=text[..i]+q+text[i2+2..]
		i:+q.length
	Forever
	
	'links
	i=0
	Repeat
		Local b,e
		Local t$=FindBBTag( text,"#",i,b,e )
		If Not t Exit
		
		t=doc.ResolveLink( t )
		text=text[..b]+t+Text[e..]
		i=b+t.length
	Forever
	
	'span tags
	FormatBBTags text,"@","b"

	FormatBBTags text,"%","i"

	'escapes
	i=0
	Repeat
		i=text.Find( "~~",i )
		If i=-1 Or i=text.length-1 Exit
		
		Local r$=Chr( text[i+1] )
		Select r
		Case "<" r="&lt;"
		Case ">" r="&gt;"
		End Select
		
		text=text[..i]+r+text[i+2..]
		i:+r.length
	Forever
	
	Return text
	
End Function

'bbdoc to html conversion
Function BBToHtml$( text$,doc:TBBLinkResolver )
	
	text=text.Replace( "~r~n","~n" )
	
	Local out$,i
	
	'preformatted code...
	Repeat
		Local i1=text.Find( "~n{{",i )
		If i1=-1 Exit

		Local i2=text.Find(  "~n}}",i+3 )
		If i2=-1 Exit
		
		out:+BBToHtml2( text[i..i1],doc )
		
		out:+"<pre>"+text[i1+3..i2].Trim()+"</pre>"
		
		i=i2+3
	Forever
	
	out:+BBToHtml2( text[i..],doc )
	
	Return out
	
End Function	
		
