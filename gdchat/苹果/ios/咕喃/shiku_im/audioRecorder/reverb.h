#pragma once

#ifdef __cplusplus
extern "C"
{
#endif

#include "freeverb.h"

//#define NULL  0

typedef struct 
{
	int m_rate, m_ch;
	float drytime;
	float wettime;
	float dampness;
	float roomwidth;
	float roomsize;
	revmodel* m_buffers;
}Reverb;

void Reverb_init(Reverb* preverbobj);
void Reverb_release(Reverb* preverbobj);
void Reverb_Process(Reverb* preverbobj,
					 short *audio_data,
					 const int length,
					 const int samplingFreqHz,
					 const int channelnum);
int Reverb_SetProperty(Reverb* preverbobj,float drytime, float wettime, float dampness, float roomwidth, float roomsize);
int Reverb_GetProperty(Reverb* preverbobj,float* drytime, float* wettime, float* dampness, float* roomwidth, float* roomsize);

#ifdef __cplusplus
}
#endif
