
#include "freeverb.h"

const float	muted		= 0;
const float	fixedgain	= 0.015f;
const float	scalewet	= 3;
const float	scaledry	= 2;
const float	scaledamp	= 0.4f;
const float	scaleroom	= 0.28f;
const float	offsetroom	= 0.7f;
const float	initialroom	= 0.5f;
const float	initialdamp	= 0.5f;
const float	initialwet	= 1 / 3;//(scalewet);
const float	initialdry	= 0;
const float	initialwidth	= 1;
const float	initialmode	= 0;
const float	freezemode	= 0.5f;

float undenormalise(void *sample) 
{
	if (((*(unsigned int*)sample) &  0x7f800000) == 0)
		return 0.0f;
	return *(float*)sample;
}

void comb_init(comb* pcombobj)
{
	pcombobj->filterstore = 0;
	pcombobj->bufidx = 0;
}

void comb_setbuffer(comb* pcombobj,float *buf, int size) 
{
	pcombobj->buffer = buf;
	pcombobj->bufsize = size;
}

float comb_process(comb* pcombobj,float input) 
{
	float output;

	output = pcombobj->buffer[pcombobj->bufidx];
	undenormalise(&output);

	pcombobj->filterstore = (output * pcombobj->damp2) + (pcombobj->filterstore * pcombobj->damp1);
	undenormalise(&pcombobj->filterstore);

	pcombobj->buffer[pcombobj->bufidx] = input + (pcombobj->filterstore * pcombobj->feedback);

	if (++pcombobj->bufidx >= pcombobj->bufsize)
		pcombobj->bufidx = 0;

	return output;
}

void comb_mute(comb* pcombobj) 
{
	int i = 0;
	for (i = 0; i < pcombobj->bufsize; i++)
		pcombobj->buffer[i] = 0;
}

void comb_setdamp(comb* pcombobj,float val) 
{
	pcombobj->damp1 = val;
	pcombobj->damp2 = 1 - val;
}

float comb_getdamp(comb* pcombobj) 
{
	return pcombobj->damp1;
}

void comb_setfeedback(comb* pcombobj,float val) 
{
	pcombobj->feedback = val;
}

float comb_getfeedback(comb* pcombobj) 
{
	return pcombobj->feedback;
}


void allpass_init(allpass* pallpassobj) 
{
	pallpassobj->bufidx = 0;
}

void allpass_setbuffer(allpass* pallpassobj,float *buf, int size) 
{
	pallpassobj->buffer = buf;
	pallpassobj->bufsize = size;
}
float allpass_process(allpass* pallpassobj,float input) 
{
	float output;
	float bufout;

	bufout = pallpassobj->buffer[pallpassobj->bufidx];
	undenormalise(&bufout);

	output = -input + bufout;
	pallpassobj->buffer[pallpassobj->bufidx] = input + (bufout * pallpassobj->feedback);

	if (++pallpassobj->bufidx >= pallpassobj->bufsize)
		pallpassobj->bufidx = 0;

	return output;
}
void allpass_mute(allpass* pallpassobj) 
{
	int i = 0;
	for (i = 0; i < pallpassobj->bufsize; i++)
		pallpassobj->buffer[i] = 0;
}

void allpass_setfeedback(allpass* pallpassobj,float val) 
{
	pallpassobj->feedback = val;
}

float allpass_getfeedback(allpass* pallpassobj) 
{
	return pallpassobj->feedback;
}



void revmodel_init(revmodel* pmodelobj) 
{
	comb_init(pmodelobj->combL+0);
	comb_init(pmodelobj->combL+1);
	comb_init(pmodelobj->combL+2);
	comb_init(pmodelobj->combL+3);
	comb_init(pmodelobj->combL+4);
	comb_init(pmodelobj->combL+5);
	comb_init(pmodelobj->combL+6);
	comb_init(pmodelobj->combL+7);
	comb_setbuffer(pmodelobj->combL+0,pmodelobj->bufcombL1,combtuningL1);
	comb_setbuffer(pmodelobj->combL+1,pmodelobj->bufcombL2,combtuningL2);
	comb_setbuffer(pmodelobj->combL+2,pmodelobj->bufcombL3,combtuningL3);
	comb_setbuffer(pmodelobj->combL+3,pmodelobj->bufcombL4,combtuningL4);
	comb_setbuffer(pmodelobj->combL+4,pmodelobj->bufcombL5,combtuningL5);
	comb_setbuffer(pmodelobj->combL+5,pmodelobj->bufcombL6,combtuningL6);
	comb_setbuffer(pmodelobj->combL+6,pmodelobj->bufcombL7,combtuningL7);
	comb_setbuffer(pmodelobj->combL+7,pmodelobj->bufcombL8,combtuningL8);

	allpass_init(pmodelobj->allpassL+0);
	allpass_init(pmodelobj->allpassL+1);
	allpass_init(pmodelobj->allpassL+2);
	allpass_init(pmodelobj->allpassL+3);
	allpass_setbuffer(pmodelobj->allpassL+0,pmodelobj->bufallpassL1,allpasstuningL1);
	allpass_setbuffer(pmodelobj->allpassL+1,pmodelobj->bufallpassL2,allpasstuningL2);
	allpass_setbuffer(pmodelobj->allpassL+2,pmodelobj->bufallpassL3,allpasstuningL3);
	allpass_setbuffer(pmodelobj->allpassL+3,pmodelobj->bufallpassL4,allpasstuningL4);
	allpass_setfeedback(pmodelobj->allpassL+0,0.5f);
	allpass_setfeedback(pmodelobj->allpassL+1,0.5f);
	allpass_setfeedback(pmodelobj->allpassL+2,0.5f);
	allpass_setfeedback(pmodelobj->allpassL+3,0.5f);

	revmodel_setwet(pmodelobj,initialwet);
	revmodel_setroomsize(pmodelobj,initialroom);
	revmodel_setdry(pmodelobj,initialdry);
	revmodel_setdamp(pmodelobj,initialdamp);
	revmodel_setwidth(pmodelobj,initialwidth);
	revmodel_setmode(pmodelobj,initialmode);
	revmodel_mute(pmodelobj);
}

void revmodel_mute(revmodel* pmodelobj) 
{
	int i=0;

	if (revmodel_getmode(pmodelobj) >= freezemode)
		return;

	for (i = 0; i < numcombs; i++) {
		comb_mute(pmodelobj->combL+i);
	}

	for (i = 0; i < numallpasses; i++) {
		allpass_mute(pmodelobj->allpassL+i);
	}
}

float revmodel_processsample(revmodel* pmodelobj,float in)
{
	float samp = in;
	float mono_out = 0.0f;
	float mono_in = samp;
	float input = (mono_in) * pmodelobj->gain;
	int i = 0;
	for(i=0; i<numcombs; i++)
	{
		mono_out += comb_process(pmodelobj->combL+i,input);
	}
	for(i=0; i<numallpasses; i++)
	{
		mono_out = allpass_process(pmodelobj->allpassL+i,mono_out);
	}
	samp = mono_in * pmodelobj->dry + mono_out * pmodelobj->wet1;
	if (samp>32767)
		samp=32767;
	if (samp<-32768)
		samp=-32768;
		
	return samp;
}

void revmodel_update(revmodel* pmodelobj) 
{
	int i;
	pmodelobj->wet1 = pmodelobj->wet * (pmodelobj->width / 2 + 0.5f);

	if (pmodelobj->mode >= freezemode) 
	{
		pmodelobj->roomsize1 = 1;
		pmodelobj->damp1 = 0;
		pmodelobj->gain = muted;
	} 
	else 
	{
		pmodelobj->roomsize1 = pmodelobj->roomsize;
		pmodelobj->damp1 = pmodelobj->damp;
		pmodelobj->gain = fixedgain;
	}

	for (i = 0; i < numcombs; i++) 
	{
		comb_setfeedback(pmodelobj->combL+i,pmodelobj->roomsize1);
	}

	for (i = 0; i < numcombs; i++) {
		comb_setdamp(pmodelobj->combL+i,pmodelobj->damp1);
	}
}

void revmodel_setroomsize(revmodel* pmodelobj,float value) 
{
	pmodelobj->roomsize = (value * scaleroom) + offsetroom;
	revmodel_update(pmodelobj);
}

float revmodel_getroomsize(revmodel* pmodelobj) 
{
	return (pmodelobj->roomsize - offsetroom) / scaleroom;
}

void revmodel_setdamp(revmodel* pmodelobj,float value) 
{
	pmodelobj->damp = value * scaledamp;
	revmodel_update(pmodelobj);
}

float revmodel_getdamp(revmodel* pmodelobj) 
{
	return pmodelobj->damp / scaledamp;
}

void revmodel_setwet(revmodel* pmodelobj,float value) 
{
	pmodelobj->wet = value * scalewet;
	revmodel_update(pmodelobj);
}

float revmodel_getwet(revmodel* pmodelobj) 
{
	return pmodelobj->wet / scalewet;
}

void revmodel_setdry(revmodel* pmodelobj,float value) 
{
	pmodelobj->dry = value * scaledry;
}

float revmodel_getdry(revmodel* pmodelobj) 
{
	return pmodelobj->dry / scaledry;
}

void revmodel_setwidth(revmodel* pmodelobj,float value) 
{
	pmodelobj->width = value;
	revmodel_update(pmodelobj);
}

float revmodel_getwidth(revmodel* pmodelobj) 
{
	return pmodelobj->width;
}

void revmodel_setmode(revmodel* pmodelobj,float value) 
{
	pmodelobj->mode = value;
	revmodel_update(pmodelobj);
}

float revmodel_getmode(revmodel* pmodelobj) 
{
	if (pmodelobj->mode >= freezemode)
		return 1;
	else
		return 0;
}

