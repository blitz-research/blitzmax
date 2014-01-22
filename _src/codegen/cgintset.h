
#ifndef CGINTSET_H
#define CGINTSET_H

struct CGIntSet : std::set<int>{

	int insert( int n );
	int insert( const CGIntSet &t );
	int xinsert( const CGIntSet &t,const CGIntSet &p );

	int erase( int n );
	int erase( const CGIntSet &t );
	int xerase( const CGIntSet &t,const CGIntSet &p );

	iterator erase( iterator it );
};

typedef CGIntSet::iterator CGIntIter;
typedef CGIntSet::const_iterator CGIntCIter;

#endif