
#include "reverb.h"
#include <stdlib.h>

void Reverb_init(Reverb* preverbobj)
{
	preverbobj->drytime = 0.43f;
	preverbobj->wettime = 0.57f;
	preverbobj->dampness = 0.45f;
	preverbobj->roomwidth = 0.56f;
	preverbobj->roomsize = 0.56f;
	preverbobj->m_rate = 0;
	preverbobj->m_ch = 0;
	preverbobj->m_buffers = NULL;
}
void Reverb_release(Reverb* preverbobj)
{
	if (preverbobj->m_buffers)
	{
		free(preverbobj->m_buffers);
	}	
}

void Reverb_Process(Reverb* preverbobj,
			 short *audio_data,
			 const int length,
			 const int samplingFreqHz,
			 const int channelnum)
{
	int i=0;
	unsigned j=0,k=0;

	if ( samplingFreqHz != preverbobj->m_rate || channelnum != preverbobj->m_ch)
	{
		preverbobj->m_rate = samplingFreqHz;
		preverbobj->m_ch = channelnum;
		if (preverbobj->m_buffers)
		{
			free(preverbobj->m_buffers);
		}
		preverbobj->m_buffers = (revmodel*)malloc(preverbobj->m_ch*sizeof(revmodel));
		for ( i = 0; i < preverbobj->m_ch; i++ )
		{
			revmodel * e = preverbobj->m_buffers+i;
			revmodel_init(e);
			revmodel_setwet(e,preverbobj->wettime);
			revmodel_setdry(e,preverbobj->drytime);
			revmodel_setdamp(e,preverbobj->dampness);
			revmodel_setroomsize(e,preverbobj->roomsize);
			revmodel_setwidth(e,preverbobj->roomwidth);
		}
	}

	for (i = 0; i < preverbobj->m_ch; i++ )
	{			
		revmodel * e = preverbobj->m_buffers+i;
		short * data = audio_data + i;
		for (j = 0, k = length/preverbobj->m_ch; j < k; j++ )
		{
			*data = (short)revmodel_processsample(e,*data );
			data += preverbobj->m_ch;
		}
	}
}

int Reverb_SetProperty(Reverb* preverbobj,float drytime, float wettime, float dampness, float roomwidth, float roomsize)
{
	int i=0;
	if (drytime>1||drytime<0
		||wettime>1||wettime<0
		||dampness>1||dampness<0
		||roomwidth>1||roomwidth<0
		||roomsize>1||roomwidth<0)
	{
		return -1;
	}

	preverbobj->drytime = drytime;
	preverbobj->wettime = wettime;
	preverbobj->dampness = dampness;
	preverbobj->roomwidth = roomwidth;
	preverbobj->roomsize = roomsize;

	for ( i = 0; i < preverbobj->m_ch; i++ )
	{
		revmodel * e = preverbobj->m_buffers+i;
		revmodel_setwet(e,preverbobj->wettime);
		revmodel_setdry(e,preverbobj->drytime);
		revmodel_setdamp(e,preverbobj->dampness);
		revmodel_setroomsize(e,preverbobj->roomsize);
		revmodel_setwidth(e,preverbobj->roomwidth);
	}

	return 0;
}
int Reverb_GetProperty(Reverb* preverbobj,float* drytime, float* wettime, float* dampness, float* roomwidth, float* roomsize)
{
	*drytime = preverbobj->drytime;
	*wettime = preverbobj->wettime;
	*dampness = preverbobj->dampness;
	*roomwidth = preverbobj->roomwidth;
	*roomsize = preverbobj->roomsize;
	return 0;
}

