
'BlitzMax keyword definitions

Rem
keyword: Strict
bbdoc: Use strict mode
about: Strict mode advises the compiler to report as errors all auto defined variables. #Strict should appear
at the top of your source code before any program code.

keyword: End
bbdoc: End program execution

keyword: "Rem"
bbdoc: Begin a remark block
about: All code between #Rem and #EndRem is ignored by the BlitzMax compiler.

keyword: "EndRem"
bbdoc: End a remark block
about:All code between #Rem and #EndRem is ignored by the BlitzMax compiler.

keyword: True
bbdoc: Constant integer of value 1

keyword: False
bbdoc: Constant integer of value 0

keyword: Pi
bbdoc: Constant double of value 3.1415926535897932384626433832795

keyword: Null
bbdoc: Get Default value
about: #Null returns a different value depending on context. When used in a numeric context, the value 0 is
returned. When used in a string or array context, an empty string or array is returned. When used in an
object context, the 'null object' is returned.

keyword: Byte
bbdoc: Unsigned 8 bit integer type

keyword: Short
bbdoc: Unsigned 16 bit integer type

keyword: Int
bbdoc: Signed 32 bit integer type

keyword: Long
bbdoc: Signed 64 bit integer type

keyword: Float
bbdoc: 32 bit Floating point type

keyword: Double
bbdoc: 64 bit floating point type

keyword: String
bbdoc: String type

keyword: Object
bbdoc: Object type

keyword: Var
bbdoc: Composite type specifier for 'by reference' types

keyword: Ptr
bbdoc: Composite type specifier for pointer types

keyword: If
bbdoc: Begin a conditional block.

keyword: Then
bbdoc: Optional separator between the condition and associated code in an If statement.

keyword: Else
bbdoc: Else provides the ability for an If Then construct to execute a second block of code when the If condition is false.

keyword: ElseIf
bbdoc: ElseIf provides the ability to test and execute a section of code if the initial condition failed.

keyword: EndIf
bbdoc: Marks the end of an If Then block.

keyword: For
bbdoc: Marks the start of a loop that uses an iterator to execute a section of code repeatedly.

keyword: To
bbdoc: Followed by a constant which is used to calculate when to exit a For..Next loop.

keyword: Step
bbdoc: Specifies an optional constant that is used to increment the For iterator.

keyword: Next
bbdoc: End a for block

keyword: EachIn
bbdoc: Iterate throough and array or collection

keyword: While
bbdoc: Execute a block of close while a condition is true

keyword: Wend
bbdoc: End a while block

keyword: Repeat
bbdoc: Execute a block of code until a termination condition is met, or forever

keyword: Until
bbdoc: End a repeat block

keyword: Forever
bbdoc: End a repeat block

keyword: Select
bbdoc: Begin a select block

keyword: EndSelect
bbdoc: End a select block

keyword: Case
bbdoc: Conditional code inside a select block

keyword: Default
bbdoc: Default code inside a select block

keyword: Exit
bbdoc: Exit enclosing loop

keyword: Continue
bbdoc: Continue execution of enclosing loop

keyword: Const
bbdoc: Declare a constant

keyword: Local
bbdoc: Declare a local variable

keyword: Global
bbdoc: Declare a global variable

keyword: Field
bbdoc: Declare a field variable

keyword: Function
bbdoc: Begin a function declaration

keyword: EndFunction
bbdoc: End a function declaration

keyword: Return
bbdoc: Return from a function

keyword: Type
bbdoc: Begin a user defined type declaration

keyword: EndType
bbdoc: End a user defined type declaration

keyword: Extends
bbdoc: Specify user defined type supertype

keyword: Method
bbdoc: Begin a method declaration

keyword: EndMethod
bbdoc: End a method declaration

keyword: Abstract
bbdoc: Denote a type or method as <i>abstract</i>
about: An abstract type cannot be instantiated using <font class=token>New</font> - it is designed to be 
extended. A type with any abstract methods is itself automatically abstract.

keyword: Final
bbdoc: Denote a type or method as <i>final</i>
about: Final types can not be extended and final methods can not be overridden. All methods of a final
type are themselves automatically final.

keyword: New
bbdoc: Create an instance of a user defined type

keyword: Self
bbdoc: Self is used in BlitzMax Methods to reference the invoking variable.

keyword: Super
bbdoc: Super evaluates to Self cast to the method's immediate base class.

keyword: Delete
bbdoc: Reserved for future expansion

keyword: Release
bbdoc: Release references to a handle or object

keyword: Public
bbdoc: Public makes a variable, function or method accessible from outside the current source file (default).

keyword: Private
bbdoc: Private makes a variable, function or method only accessible from within the current source file.

keyword: Extern
bbdoc: Extern marks the beginning of an external list of function declarations.

keyword: EndExtern
bbdoc: EndExtern marks the end of an Extern section.

keyword: Module
bbdoc: Declare module scope and identifier

keyword: ModuleInfo
bbdoc: Define module properties

keyword: Incbin
bbdoc: Embed a data file

keyword: IncbinPtr
bbdoc: Get start address of embedded data file

keyword: IncbinLen
bbdoc: Get length of embedded data file

keyword: Import
bbdoc: Import declarations from a module of source file

keyword: Assert
bbdoc: Throw a runtimeerror if a condition is false

keyword: Goto
bbdoc: Transfer program flow to specified label

keyword: Try
bbdoc: Begin declaration of a try block

keyword: EndTry
bbdoc: End declaration of a try block

keyword: Catch
bbdoc: Catch an exception object in a try block

keyword: Throw
bbdoc: Throw an exception object to the enclosing try block

keyword: DefData
bbdoc: Define class BASIC style data

keyword: ReadData
bbdoc: Read classic BASIC style data

keyword: RestoreData
bbdoc: Restore classic BASIC style data

keyword: And
bbdoc: Conditional 'and' binary operator

keyword: Or
bbdoc: Conditional 'Or' binary operator

keyword: Not
bbdoc: Conditional 'Not' binary operator

keyword: Shl
bbdoc: Bitwise 'Shift left' binary operator

keyword: Shr
bbdoc: Bitwise 'Shift right' binary operator

keyword: Sar
bbdoc: Bitwise 'Shit arithmetic right' binary operator

keyword: Len
bbdoc: Number of characters in a string or elements in an array

keyword: Abs
bbdoc: Numeric 'absolute value' unary operator

keyword: Mod
bbdoc: Numeric 'modulus' or 'remainder' binary operator

keyword: Sgn
bbdoc: Numeric 'sign' unary operator

keyword: Min
bbdoc: Numeric 'minimum' binary operator

keyword: Max
bbdoc: Numeric 'maximum' binary operator

keyword: Varptr
bbdoc: Find the address of a variable

keyword: SizeOf
bbdoc: Bytes of memory occupied by a variable, string, array or object

keyword: Asc
bbdoc: Get character value of the first character of a string
about: #Asc returns -1 if string has 0 length.

keyword: Chr
bbdoc: Create a string of length 1 with a character code

EndRem

