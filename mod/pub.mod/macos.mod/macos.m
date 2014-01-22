
//pinched from ADC - no idea how it works!

#include "macos.h"

static int sysctlbyname_with_pid (const char *name, pid_t pid, 
                            void *oldp, size_t *oldlenp, 
                            void *newp, size_t newlen)
{
	if (pid == 0) {
		if (sysctlbyname(name, oldp, oldlenp, newp, newlen) == -1) {
			return -1;
		}
	}else{
		int mib[CTL_MAXNAME];
		size_t len = CTL_MAXNAME;
		if (sysctlnametomib(name, mib, &len) == -1) {
			return -1;
		}
		mib[len] = pid;
		len++;
		if (sysctl(mib, len, oldp, oldlenp, newp, newlen) == -1)  {
			return -1;
		}
	}
	return 0;
}

int is_pid_native( pid_t pid )
{
	int ret = 0;
	size_t sz = sizeof(ret);
 
	if (sysctlbyname_with_pid("sysctl.proc_native", pid, &ret, &sz, NULL, 0) == -1) {
		if (errno == ENOENT) {
			// sysctl doesn't exist, which means that this version of Mac OS 
			// pre-dates Rosetta, so the application must be native.
			return 1;
		}
		return -1;
	}
	return ret;
}

BBString *bbStringFromNSString( NSString *s ){
	BBString	*bbstring;
	unsigned short *buff;
	int n;
	n=[s length];
	buff=malloc( n*2 );
	[s getCharacters:buff];
	bbstring=bbStringFromShorts( buff,n );
	free( buff );
	return bbstring;
}

NSString *NSStringFromBBString( BBString *s ){
	return [NSString stringWithCharacters:s->buf length:s->length];
}
