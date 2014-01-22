
#ifndef CGDEBUG_H
#define CGDEBUG_H

#include "cgflow.h"

bool cgVerify( std::ostream &o,CGExp *exp );
bool cgVerify( std::ostream &o,CGStm *stm );
bool cgVerify( std::ostream &o,CGFun *fun );

std::ostream &operator<<( std::ostream &out,CGStm *stm );
std::ostream &operator<<( std::ostream &out,CGExp *exp );
std::ostream &operator<<( std::ostream &out,CGFun *fun );

std::ostream &operator<<( std::ostream &out,CGFlow *flow );

std::ostream &operator<<( std::ostream &out,const CGStmSeq &seq );
std::ostream &operator<<( std::ostream &out,const CGAsmSeq &seq );

#endif