
#include "blitz.h"

const char *bbVoidTypeTag="?";
const char *bbByteTypeTag="b";
const char *bbShortTypeTag="s";
const char *bbIntTypeTag="i";
const char *bbFloatTypeTag="f";
const char *bbDoubleTypeTag="d";
const char *bbStringTypeTag="$";
const char *bbObjectTypeTag=":Object";
const char *bbBytePtrTypeTag="*b";

BBINT bbConvertToInt( void *val,const char *tag ){
	switch( tag[0] ){
	case 'b':return *(BBBYTE*)val;
	case 's':return *(BBSHORT*)val;
	case 'i':return *(BBINT*)val;
	case 'f':return *(BBFLOAT*)val;
	case 'd':return *(BBDOUBLE*)val;
	case '$':return bbStringToInt( *(BBSTRING*)val );
	}
	return 0;
}

BBDOUBLE bbConvertToFloat( void *val,const char *tag ){
	switch( tag[0] ){
	case 'b':return *(BBBYTE*)val;
	case 's':return *(BBSHORT*)val;
	case 'i':return *(BBINT*)val;
	case 'f':return *(BBFLOAT*)val;
	case 'd':return *(BBDOUBLE*)val;
	case '$':return bbStringToFloat( *(BBSTRING*)val );
	}
	return 0;
}

BBSTRING bbConvertToString( void *val,const char *tag ){
	switch( tag[0] ){
	case 'b':return bbStringFromInt( *(BBBYTE*)val );
	case 's':return bbStringFromInt( *(BBSHORT*)val );
	case 'i':return bbStringFromInt( *(BBINT*)val );
	case 'f':return bbStringFromFloat( *(BBFLOAT*)val );
	case 'd':return bbStringFromFloat( *(BBDOUBLE*)val );
	case '$':return *(BBSTRING*)val;
	}
	return 0;
}
