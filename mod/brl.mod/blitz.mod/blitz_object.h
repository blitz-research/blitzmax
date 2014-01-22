
#ifndef BLITZ_OBJECT_H
#define BLITZ_OBJECT_H

#include "blitz_types.h"

#ifdef __cplusplus
extern "C"{
#endif

#define BBNULL (&bbNullObject)

#define BBNULLOBJECT (&bbNullObject)

struct BBClass{
	//extends BBGCPool
	BBClass*	super;
	void		(*free)( BBObject *o );
	
	BBDebugScope*debug_scope;

	int		instance_size;

	void		(*ctor)( BBObject *o );
	void		(*dtor)( BBObject *o );
	
	BBString*	(*ToString)( BBObject *x );
	int		(*Compare)( BBObject *x,BBObject *y );
	BBObject*	(*SendMessage)( BBObject *m,BBObject *s );
	void		(*_reserved1_)();
	void		(*_reserved2_)();
	void		(*_reserved3_)();
	
	void*	vfns[32];
};

struct BBObject{
	//extends BBGCMem
	BBClass*	clas;
	int		refs;
};

extern	BBClass bbObjectClass;
extern	BBObject bbNullObject;

BBObject*	bbObjectNew( BBClass *t );
void		bbObjectFree( BBObject *o );

void		bbObjectCtor( BBObject *o );
void		bbObjectDtor( BBObject *o );

BBString*	bbObjectToString( BBObject *o );
int		bbObjectCompare( BBObject *x,BBObject *y );
BBObject*	bbObjectSendMessage( BBObject *m,BBObject *s );
void		bbObjectReserved();

BBObject*	bbObjectDowncast( BBObject *o,BBClass *t );

void		bbObjectRegisterType( BBClass *clas );
BBClass**	bbObjectRegisteredTypes( int *count );

#ifdef __cplusplus
}
#endif

#endif
