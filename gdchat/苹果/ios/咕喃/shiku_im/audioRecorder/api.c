
#include "api.h"
#include <stdlib.h>

Reverb* createReverb()
{
	Reverb* pobj = (Reverb*)malloc(sizeof(Reverb));
	if (pobj)
	{
		Reverb_init(pobj);
		return pobj;
	}
	return NULL;
}
OSStatus deleteReverb(Reverb* pobj)
{
	OSStatus result = noErr;

	if (pobj)
	{
		Reverb_release(pobj);
		free(pobj);
	}

	return result;
}

//处理数据
OSStatus simpleDelay1 (Reverb* pobj, //混响对象
					  void *inRefCon, // scope reference
					  UInt32 inNumberFrames, // number of frames to process
					  SInt16 *sampleBuffer,//数据
					  int samplingFreqHz,
					  int channelNum)//是否双声道                               // frame data
{
	OSStatus result = noErr;

	Reverb_Process(pobj,sampleBuffer,inNumberFrames,samplingFreqHz,channelNum);

	return result;
}

//设置属性
OSStatus setReverbParem(Reverb* pobj,
						float drytime, 
						float wettime, 
						float dampness, 
						float roomwidth, 
						float roomsize)
{
	return Reverb_SetProperty(pobj,drytime,wettime,dampness,roomwidth,roomsize);
}

//获取属性
OSStatus getReverbParem(Reverb* pobj,
						float* drytime, 
						float* wettime, 
						float* dampness, 
						float* roomwidth, 
						float* roomsize)
{
	return Reverb_GetProperty(pobj,drytime,wettime,dampness,roomwidth,roomsize);
}
