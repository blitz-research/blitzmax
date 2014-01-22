
#ifndef BLITZ_TYPES_H
#define BLITZ_TYPES_H

#ifdef __cplusplus
extern "C"{
#endif

#ifdef _MSC_VER
	typedef __int64 BBInt64;
	typedef unsigned __int64 BBUInt64;
#else
	typedef long long BBInt64;
	typedef unsigned long long BBUInt64;
#endif

typedef unsigned short	BBChar;

typedef struct BBClass	BBClass;
typedef struct BBObject	BBObject;
typedef struct BBString	BBString;
typedef struct BBArray	BBArray;

typedef unsigned char	BBBYTE;
typedef unsigned short	BBSHORT;
typedef signed int		BBINT;
typedef BBInt64			BBLONG;
typedef float			BBFLOAT;
typedef double			BBDOUBLE;
typedef BBClass*		BBCLASS;
typedef BBObject*		BBOBJECT;
typedef BBString*		BBSTRING;
typedef BBArray*		BBARRAY;

extern const char *bbVoidTypeTag;	//"?"
extern const char *bbByteTypeTag;	//"b"
extern const char *bbShortTypeTag;	//"s"
extern const char *bbIntTypeTag;	//"i"
extern const char *bbLongTypeTag;	//"l"
extern const char *bbFloatTypeTag;	//"f"
extern const char *bbDoubleTypeTag;	//"d"
extern const char *bbStringTypeTag;	//"$"
extern const char *bbObjectTypeTag;	//":Object"
extern const char *bbBytePtrTypeTag;//"*b"

#ifdef __cplusplus
}
#endif

#endif
