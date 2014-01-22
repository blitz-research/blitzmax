
Object^Null{

	-New()="bbObjectCtor"
	-Delete()="bbObjectDtor"

	-ToString:String()="bbObjectToString"
	-Compare:Int( otherObject:Object )="bbObjectCompare"
	-SendMessage:Object( message:Object,source:object )="bbObjectSendMessage"

	-_reserved1_()="bbObjectReserved"
	-_reserved2_()="bbObjectReserved"
	-_reserved3_()="bbObjectReserved"
	
}="bbObjectClass"

String^Object{

	.length:Int

	-ToString:String()="bbStringToString"
	-Compare:Int(otherObject:Object)="bbStringCompare"
	
	-Find:Int( subString:String,startIndex=0 )="bbStringFind"
	-FindLast:Int( subString:String,startIndex=0 )="bbStringFindLast"
	
	-Trim:String()="bbStringTrim"
	-Replace:String( substring:String,withString:String )="bbStringReplace"

	-ToLower:String()="bbStringToLower"
	-ToUpper:String()="bbStringToUpper"
	
	-ToInt:Int()="bbStringToInt"
	-ToLong:Long()="bbStringToLong"
	-ToFloat:Float()="bbStringToFloat"
	-ToDouble:Double()="bbStringToDouble"
	-ToCString:Byte Ptr()="bbStringToCString"
	-ToWString:Short Ptr()="bbStringToWString"

	+FromInt:String( intValue:Int)="bbStringFromInt"
	+FromLong:String( longValue:Long )="bbStringFromLong"
	+FromFloat:String( floatValue:Float )="bbStringFromFloat"
	+FromDouble:String( doubleValue:Double )="bbStringFromDouble"
	+FromCString:String( cString:Byte Ptr )="bbStringFromCString"
	+FromWString:String( wString:Short ptr )="bbStringFromWString"
	
	+FromBytes:String( bytes:Byte Ptr,count )="bbStringFromBytes"
	+FromShorts:String( shorts:Short Ptr,count )="bbStringFromShorts"

	-StartsWith:Int( subString:String )="bbStringStartsWith"
	-EndsWith:Int( subString:String )="bbStringEndsWith"
	-Contains:Int( subString:String )="bbStringContains"
	
	-Split:String[]( separator:String )="bbStringSplit"
	-Join:String( bits:String[] )="bbStringJoin"
	
	+FromUTF8String:String( utf8String:Byte Ptr )="bbStringFromUTF8String"
	-ToUTF8String:Byte Ptr()="bbStringToUTF8String"

}AF="bbStringClass"

Array^Object{

	.elementTypeEncoding:Byte Ptr
	.numberOfDimensions:Int
	.sizeMinusHeader:Int
	.length:Int
	
	-Sort( ascending=1 )="bbArraySort"
	-Dimensions:Int[]()="bbArrayDimensions"
	
}AF="bbArrayClass"
