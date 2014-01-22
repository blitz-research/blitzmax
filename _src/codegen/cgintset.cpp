
#include "cgstd.h"

#include "cgintset.h"

using namespace std;

int CGIntSet::insert( int n ){
	int sz=size();
	set<int>::insert(n);
	return size()-sz;
}

int	CGIntSet::insert( const CGIntSet &t ){
	int sz=size();
	const_iterator it;
	for( it=t.begin();it!=t.end();++it ){
		set<int>::insert( *it );
	}
	return size()-sz;
}

int	CGIntSet::xinsert( const CGIntSet &t,const CGIntSet &p ){	//insert elements in t NOT in p
	int sz=size();
	const_iterator it;
	for( it=t.begin();it!=t.end();++it ){
		int n=*it;
		if( !p.count(n) ) set<int>::insert(n);
	}
	return size()-sz;
}

int	CGIntSet::erase( int n ){
	return set<int>::erase(n);
}

int	CGIntSet::erase( const CGIntSet &t ){
	int sz=size();
	const_iterator it;
	for( it=t.begin();it!=t.end();++it ){
		set<int>::erase( *it );
	}
	return sz-size();
}
int	CGIntSet::xerase( const CGIntSet &t,const CGIntSet &p ){	//erase elements in t NOT in p
	int sz=size();
	const_iterator it;
	for( it=t.begin();it!=t.end();++it ){
		int n=*it;
		if( !p.count(n) ) set<int>::erase(n);
	}
	return sz-size();
}

CGIntSet::iterator CGIntSet::erase( iterator it ){
	iterator t=it++;
	set<int>::erase(t);
	return it;
}
