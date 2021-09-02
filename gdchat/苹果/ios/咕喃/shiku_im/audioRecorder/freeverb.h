#pragma once

#ifdef __cplusplus
extern "C"
{
#endif

typedef struct 
{
	float feedback;
	float filterstore;
	float damp1;
	float damp2;
	float *buffer;
	int bufsize;
	int bufidx;
}comb;

void comb_init(comb* pcombobj);
void comb_setbuffer(comb* pcombobj,float *buf, int size);
float comb_process(comb* pcombobj,float inp);
void comb_mute(comb* pcombobj);
void comb_setdamp(comb* pcombobj,float val);
float comb_getdamp(comb* pcombobj);
void comb_setfeedback(comb* pcombobj,float val);
float comb_getfeedback(comb* pcombobj);



typedef struct 
{
	float feedback;
	float *buffer;
	int bufsize;
	int bufidx;
}allpass;

void allpass_init(allpass* pallpassobj);
void allpass_setbuffer(allpass* pallpassobj,float *buf, int size);
float allpass_process(allpass* pallpassobj,float inp);
void allpass_mute(allpass* pallpassobj);
void allpass_setfeedback(allpass* pallpassobj,float val);
float allpass_getfeedback(allpass* pallpassobj);


#define numcombs 8//const int	numcombs	= 8;
#define numallpasses 4//const int	numallpasses	= 4;

#define combtuningL1 1116//const int combtuningL1		= 1116;
#define combtuningL2 1188//const int combtuningL2		= 1188;
#define combtuningL3 1277//const int combtuningL3		= 1277;
#define combtuningL4 1356//const int combtuningL4		= 1356;
#define combtuningL5 1422//const int combtuningL5		= 1422;
#define combtuningL6 1491//const int combtuningL6		= 1491;
#define combtuningL7 1557//const int combtuningL7		= 1557;
#define combtuningL8 1617//const int combtuningL8		= 1617;
#define allpasstuningL1 556//const int allpasstuningL1	= 556;
#define allpasstuningL2 441//const int allpasstuningL2	= 441;
#define allpasstuningL3 341//const int allpasstuningL3	= 341;
#define allpasstuningL4 225//const int allpasstuningL4	= 225;


typedef struct
{
	float gain;
	float roomsize, roomsize1;
	float damp, damp1;
	float wet, wet1, wet2;
	float dry;
	float width;
	float mode;

	comb combL[numcombs];


	allpass	allpassL[numallpasses];

	float bufcombL1[combtuningL1];
	float bufcombL2[combtuningL2];
	float bufcombL3[combtuningL3];
	float bufcombL4[combtuningL4];
	float bufcombL5[combtuningL5];
	float bufcombL6[combtuningL6];
	float bufcombL7[combtuningL7];
	float bufcombL8[combtuningL8];

	float bufallpassL1[allpasstuningL1];
	float bufallpassL2[allpasstuningL2];
	float bufallpassL3[allpasstuningL3];
	float bufallpassL4[allpasstuningL4];
}revmodel;

void revmodel_init(revmodel* pmodelobj);
void revmodel_mute(revmodel* pmodelobj);
float revmodel_processsample(revmodel* pmodelobj,float in);
void revmodel_setroomsize(revmodel* pmodelobj,float value);
float revmodel_getroomsize(revmodel* pmodelobj);
void revmodel_setdamp(revmodel* pmodelobj,float value);
float revmodel_getdamp(revmodel* pmodelobj);
void revmodel_setwet(revmodel* pmodelobj,float value);
float revmodel_getwet(revmodel* pmodelobj);
void revmodel_setdry(revmodel* pmodelobj,float value);
float revmodel_getdry(revmodel* pmodelobj);
void revmodel_setwidth(revmodel* pmodelobj,float value);
float revmodel_getwidth(revmodel* pmodelobj);
void revmodel_setmode(revmodel* pmodelobj,float value);
float revmodel_getmode(revmodel* pmodelobj);
void revmodel_update(revmodel* pmodelobj);


#ifdef __cplusplus
}
#endif


















