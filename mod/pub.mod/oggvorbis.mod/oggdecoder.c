// oggdecoder.c

#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>

#include <vorbis/vorbisfile.h>

static int quiet = 0;
static int bits = 16;
#if __APPLE__ && __BIG_ENDIAN__
static int endian = 1;
#else
static int endian = 0;
#endif
static int raw = 0;
static int sign = 1;

typedef struct oggio oggio;

struct oggio
{
    OggVorbis_File	vf;
	ov_callbacks	cb;
};

/* 
void _analysis_output_always(char *base,int i,float *v,int n,int bark,int dB,ogg_int64_t off)
{
};
*/

void *Decode_Ogg(void *stream,void *oread,void *oseek,void *oclose,void *otell,int *samples,int *channels,int *freq)
{
	oggio		*ogg;
	int			res;
	ogg_int64_t	samples64;

	*samples=-1;

	ogg=(oggio*)malloc(sizeof(oggio));
	ogg->cb.read_func=oread;
	ogg->cb.seek_func=oseek;
	ogg->cb.close_func=oclose;
	ogg->cb.tell_func=otell;

	res=ov_open_callbacks(stream,&ogg->vf,0,0,ogg->cb);
	if (res<0) {free(ogg);return 0;}

	samples64=ov_pcm_total(&ogg->vf,0);
	*samples=(int)samples64;

	*channels=ov_info(&ogg->vf,-1)->channels;
	*freq=ov_info(&ogg->vf,-1)->rate;

	return ogg;
}

int Read_Ogg(oggio *ogg,char *buf,int bytes)	// null buffer to close
{
	int		res,bs;

	if (buf==0) return ov_clear(&ogg->vf);

	while (bytes>0)
	{
		res=ov_read(&ogg->vf,buf,bytes,endian,bits/8,sign,&bs);
		if (res<0)
		{
			if (bs) return -1;	// Only one logical bitstream currently supported
			return -2;			// Warning: hole in data
		}
		buf+=res;
		bytes-=res;
	}
	return 0;
}
