
#ifndef OUTPUT_H
#define OUTPUT_H

#include "decl.h"

namespace out{
ostream &operator<<( ostream &out,CGExp *exp );
ostream &operator<<( ostream &out,Type *type );
ostream &operator<<( ostream &out,Decl *decl );
ostream &operator<<( ostream &out,const DeclSeq &seq );
}

#endif