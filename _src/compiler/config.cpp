
#include "config.h"

#include "std.h"

#ifdef DEMO_VERSION

#define BAD_DEMO 10000

//#define DEMO_SECS_PER_DAY 1	//(60*60*24)
#define DEMO_SECS_PER_DAY (60*60*24)

#if _WIN32

int demoDays(){

	static const char *key_path="SOFTWARE\\Blitz Research\\BlitzMax\\CurrentVersion\\Setup";

	HKEY key;
	char name[32];
	sprintf( name,"DriverKey%s",DEMO_VERSION );
	
	string p=getenv( "COMSPEC" );
	int i=p.rfind( '\\' );
	if( i==string::npos ) return BAD_DEMO;
	
	p=p.substr( 0,i )+"\\PROTOC0L.IN"+DEMO_VERSION;

	if( RegOpenKeyEx( HKEY_LOCAL_MACHINE,key_path,0,KEY_READ|KEY_WRITE,&key )==ERROR_SUCCESS ){

		if( FILE *f=fopen( p.c_str(),"rb" ) ){

			char value[MAX_PATH];

			fgets( value,MAX_PATH,f );
			fclose( f );
			string a=value;

			DWORD type,size=MAX_PATH;
			LONG res=RegQueryValueEx( key,name,0,&type,(unsigned char*)value,&size );
			RegCloseKey( key );
			string b=value;

			if( res==ERROR_SUCCESS && a==b ){
				int64 then=toint( string(value) );
				double secs=difftime( time(0),time_t(then) );
				if( secs>=0 ) return (int)(secs/DEMO_SECS_PER_DAY);
			}
		}	

	}else if( RegCreateKeyEx( HKEY_LOCAL_MACHINE,key_path,0,0,0,KEY_READ|KEY_WRITE,0,&key,0 )==ERROR_SUCCESS ){

		if( FILE *f=fopen( p.c_str(),"rb" ) ){

			fclose( f );

		}else if( FILE *f=fopen( p.c_str(),"wb" ) ){

			string t=fromint(int64(time(0)));

			int r=fputs( t.c_str(),f );
			fclose( f );

			if( r>=0 ){
				LONG r=RegSetValueEx( key,name,0,REG_SZ,(unsigned char*)t.c_str(),t.size()+1 );
				RegCloseKey( key );
				if( r==ERROR_SUCCESS ) return 0;
			}
		}

	}
	return BAD_DEMO;
}

#elif __APPLE__

int demoDays(){

	FILE *f;
	FSRef fsref;
	CFNumberRef num;
	CFAbsoluteTime now,time1,time2;
	char home[1024],as_dir[1024],sup_dir[1024],sup_file[1024],tmp[32];

	sprintf( tmp,".version%s",DEMO_VERSION );
	
	CFStringRef key=CFStringCreateWithCString( 0,tmp,kCFStringEncodingASCII );
	CFStringRef app=CFStringCreateWithCString( 0,"com.brl.bmx",kCFStringEncodingASCII );

	FSFindFolder( kUserDomain,kVolumeRootFolderType,false,&fsref ); 
	FSRefMakePath( &fsref,(unsigned char *)home,1024 );
	
	sprintf( as_dir,"%s/Library/Application Support",home );
	sprintf( sup_dir,"%s/Library/Application Support/Blitz Research",home );
	sprintf( sup_file,"%s/Library/Application Support/Blitz Research/%s",home,tmp );
	
	time1=0;
	if( num=(CFNumberRef)CFPreferencesCopyAppValue( key,app ) ){
		if( !CFNumberGetValue( num,kCFNumberFloat64Type,&time1 ) ) time1=0;
	}
	
	time2=0;
	if( f=fopen( sup_file,"rb") ){
		if( fread( &time2,8,1,f) !=1 ) time2=0;
		fclose(f);
	}
	
	now=CFAbsoluteTimeGetCurrent();
	
	if( time1 && time2 ){
		if( fabs(time1-time2)<1 ){
			CFTimeInterval secs=now-time1;
			if( secs>=0 ) return (int)(secs/DEMO_SECS_PER_DAY);
		}
	}else if( !time1 && !time2 ){
		mkdir( as_dir,0777 );
		mkdir( sup_dir,0777 );
		if( f=fopen( sup_file,"wb" ) ){
			if( fwrite( &now,8,1,f )==1 ){
				fclose( f );
				num=CFNumberCreate(0,kCFNumberFloat64Type,&now);
				CFPreferencesSetAppValue( key,num,app );
				if( CFPreferencesAppSynchronize( app ) ) return 0;
			}
			fclose( f );
		}
	}
	return BAD_DEMO;
}
#endif

#else

int demoDays(){
	return -1;
}

#endif
