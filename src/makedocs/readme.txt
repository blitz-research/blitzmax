
docmods has been driving me nuts for a while now, so here's a rewrite...


***** makedocs *****

New version of docmods is called makedocs.

New doc system should coexist peacefully with current system as it uses '/docs'
(plural!) dir as opposed to current '/doc' (singular!) dir.

New doc system depends on some IDE tweaks, so old IDE's can stick with docmods and '/doc'
dir if they want.


***** The docs/html dir *****

All docs now end up in /docs/html. commands.txt ends up in /docs/html/Modules dir.
 
/docs/html is deleted and rebuilt from scratch every time makedocs is run.

Generated docs are completely standalone - no more linking into /mod dir etc. This
means docs can be viewed entirely separately from bmx install.

This does mean some duplication - eg: the examples and images etc found in module 'doc' dirs
ended up duped. However, this does offer a different solution to the 'oops I stuffed the 
example code' problem as opposed to the current 'prefix the file with dot' solution...

IDE help tree is now based entirely on contents of /docs/html. Basic idea here is:

* Every folder in /docs/html containing an index.html file is considered to be a node
in the help tree.

* index.html files are also scanned for local links (eg: href=#blah). These are added to
the help tree as leaves. Local links starting with non-alpha chars are ignored (TODO).

* html files within a node are also added as leaves. Ditto, html files starting with 
non-alpha chars are ignored (TODO).


***** The docs/src dir *****

Prior to building docs, /docs/src is copied to /docs/html.

This is where static docs go: language guide, user guide, tutorials etc.

By providing a dir tree in /docs/src with appropriate index.html files, the IDE
can auto integrate custom/static docs into help tree.

/docs/src can also contain .bbdoc files - these are converted to html files by makedocs.


***** Doccing modules *****

The basic idea behind docing modules remains the same.

The bbdoc for module declarations now allowed you to provide a 'path' for the module, eg:

Rem
bbdoc: Audio/Audio Samples
End Rem
Module BRL.AudioSample

...this wil cause the module docs to end up in /docs/html/Audio/Audio Samples/index.html.

This actually allows for creative doc arrangments - eg: instead of flat 2 level docs...

Graphics
	Max2D
		GLMax2D
		DX7Max2D
	Pixmaps
		BMPLoader
		PNGLoader
GUI
	MaxGUI
		Win32MaxGui
		CocoaMaxGUI

...etc...

However, I'm not sure whether that would introduce more confusion than benefit! Thoughts?


***** BBDOC system ******

BBDoc is a simple tag based formatting system.

The main benefit it offers is sane link creation - just #Blah to link to Blah without
worrying about where it is.

To link to consts, globals, functions etc, use eg: #LoadImage.

To link to modules, use eg: #BRL.Audio.

BBDoc supports 2 kinds of tags - span tags and div tags.

Span tags may appear anywhere, but must be preceded by a space. The tag affects the
succeeding identifier (identifiers include _ and .). Span tags may be followed by {} to
enclose text containing spaces, non-identifier characters etc.

Div tags must appear at the start of a line. Div tags affect one or more lines.

Span tags:

# link
@ bold
% italic

Div tags:

. tab - remainder of line is indented
+ heading - remainder of line is a heading
[ start table
* start table row (only within tables)
] end table
{{ start preformatted block
}} end preformatted block (this is the only tag recognized within a preformatted block)

Misc tags:

\~n line break.
| start table cell (only within tables) - must have a space on either side.

BBDoc also converts double newline sequences into paragraph breaks.

Literal tag chars can be inserted using '~'. To insert a '~', use '~~'.

***** Examples *****

This is in bold. %{But this lot} is in italics.

This is ~#not a link!

Please refer to the #{User Guide} for more information.

Here is a table:
[ @Item | @Value
* item1 | value1
]

{{
This is some sample code.
}}
