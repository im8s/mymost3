/*
1.纯播放器
2.纯录音器
3.即播又录器
4.即播又录，还即时合成,并支持声道
5.支持暂停
6.支持分路控制音量，麦克风音量，伴奏音量
7.支持切换左右声道，立体声输出
8.支持声效模式：回音，正常，变调，并即时保存
9.检查文件格式
10.支持定时
11.监测音量
12.对伴奏的音量调节记录进文件
*/

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>			// for vdsp functions
#import "lame.h"

#define NUM_FILES 1                         // number of audio files read in by old method
#define kDelayBufferLength 1024 * 100       // measured in slices - a couple seconds worth at 44.1k
#define MP3_SIZE 8192


// Data structure for mono or stereo sound, to pass to the application's render callback function, 
//    which gets invoked by a Mixer unit input bus when it needs more audio to play.
// Note: this is used by the callbacks for playing looped files (old way)
typedef struct {
    UInt32               writeNumber;
    BOOL                 isStereo;           // set to true if there is data in the audioDataRight member
    UInt32               frameCount;         // the total number of frames in the audio data
    UInt32               sampleNumber;       // the next audio sample to play
    float                sampleRate;
    AudioUnitSampleType      *audioDataLeft;     // the complete left (or mono) channel of audio data read from an audio file
    AudioUnitSampleType      *audioDataRight;    // the complete right channel of audio data read from an audio file
    ExtAudioFileRef      audioFile;	    
} soundStruct, *soundStructPtr;


@interface MixerHostAudio : NSObject <AVAudioSessionDelegate> {
    BOOL                            isPlayer;   //开启播放器
    BOOL                            isRecorder; //开启录音器
    BOOL                            isGenerator;//开启产生器
    BOOL                            isOutputer; //开启录音保存
    BOOL                            isEffecter; //开启效果器
    BOOL                            isMixSave;  //开启混音保存
    BOOL                            isPaused;   //是否暂停
    BOOL                            isPlayMic;  //回放录音
    BOOL                            isHeadset;  //接上耳塞
    BOOL                            isIPad1;    //是否ipad1

    NSString*                       importAudioFile;  //播放文件
    NSString*                       outputAudioFile;  //输出文件
    int                             outputChanelIndex;//输出声道
    float                           volumeRecorder;   //输入音量
    float                           volumePlayer;     //输出音量
    NSTimeInterval                  currentTime;      //当前时间   
    NSTimeInterval                  timeLenRecord;    //录音时长
    UInt32                          recordSamples;    //录音总sample
    FILE * _mp3;
    lame_t                          lame;
    unsigned char _mp3_buffer[MP3_SIZE];
    
    
    
    ExtAudioFileRef                 audioFile;
    Float64                         graphSampleRate;                // audio graph sample rate
    CFURLRef                        sourceURLArray[NUM_FILES];      // for handling loop files
    soundStruct                     soundStructArray[NUM_FILES];    // scope reference for loop file callback
	
    //float _oldVolPlayer;
    //float _oldVolRecorder;
    // Before using an AudioStreamBasicDescription struct you must initialize it to 0. However, because these ASBDs
    // are declared in external storage, they are automatically initialized to 0. 
    AudioStreamBasicDescription     stereoStreamFormat;     // standard stereo 8.24 fixed point
    AudioStreamBasicDescription     monoStreamFormat;       // standard mono 8.24 fixed point
    AudioStreamBasicDescription     SInt16StreamFormat;		// signed 16 bit int sample format
	AudioStreamBasicDescription     floatStreamFormat;		// float sample format (for testing)
    AudioStreamBasicDescription     auEffectStreamFormat;		// audio unit Effect format 
    AudioStreamBasicDescription     stereoFileFormat;     // standard stereo 8.24 fixed point
    AudioStreamBasicDescription     monoFileFormat;       // standard mono 8.24 fixed point
    

    AUGraph                         processingGraph;        // the main audio graph
    BOOL                            playing;                // indicates audiograph is running
    BOOL                            interruptedDuringPlayback;  // indicates interruption happened while audiograph running

    // some of the audio units in this app
    
    
    AudioUnit                       ioUnit;                  // remote io unit
    AudioUnit                       mixerUnit;                  // multichannel mixer audio unit
    
    
    AUNode      iONode;             // node for I/O unit speaker
    AUNode      mixerNode;          // node for Multichannel Mixer unit

    
		
	FFTSetup fftSetup;			// fft predefined structure required by vdsp fft functions
	COMPLEX_SPLIT fftA;			// complex variable for fft
	int fftLog2n;               // base 2 log of fft size
    int fftN;                   // fft size
    int fftNOver2;              // half fft size
	size_t fftBufferCapacity;	// fft buffer size (in samples)
	size_t fftIndex;            // read index pointer in fft buffer 
    
    // working buffers for sample data
        
	void *dataBuffer;               //  input buffer from mic/line
	float *outputBuffer;            //  fft conversion buffer
	float *analysisBuffer;          //  fft analysis buffer
    SInt16 *conversion16BufferLeft;   // for data conversion from fixed point to integer
    SInt16 *conversion16BufferRight;   // for data conversion from fixed point to integer
    SInt32 *conversion32BufferLeft;   // for data conversion from fixed point to integer
    SInt32 *conversion32BufferRight;   // for data conversion from fixed point to integer

    // convolution 
    
   	float *filterBuffer;        // impusle response buffer
    int filterLength;           // length of filterBuffer
    float *signalBuffer;        // signal buffer
    int signalLength;           // signal length
    float *resultBuffer;        // result buffer
    int resultLength;           // result length
	    
    
// new instance variables for UI display objects
	
    int displayInputFrequency;              // frequency determined by analysis 
    float displayInputLevelLeft;            // average input level for meter left channel
    float displayInputLevelRight;           // average input level for meter right channel
    int displayNumberOfInputChannels;       // number of input channels detected on startup
    
    
// for the synth callback - these are now instance variables so we can pass em back and forth to mic callback using self for inrefcon
    
    float sinFreq;        // frequency of sine wave to generate
    float sinPhase;       // current phase
    BOOL synthNoteOn;     // determines whether note is playing
    
// mic FX type selection
    int micFxType;  // enumerated fx types: 
                    // 0: ring mod
                    // 1: fft
                    // 2: pitch shift
                    // 3: echo (delay)
                    // 4: low pass filter (moving average)
                    // 5: low pass filter (convolution)
    
    BOOL micFxOn;       // toggle for using mic fx
    float micFxControl; // multipurpose mix fx control slider
    
    BOOL inputDeviceIsAvailable;    // indicates whether input device is available on ipod touch    	
}

// property declarations - corresponding to instance variables declared above

@property(assign) BOOL                            isPlayer;   //开启播放器
@property(assign) BOOL                            isRecorder; //开启录音器
@property(assign) BOOL                            isGenerator;//开启混音器
@property(assign) BOOL                            isOutputer; //开启录音保存
@property(assign) BOOL                            isEffecter; //开启效果器
@property(assign) BOOL                            isMixSave;  //开启混音保存
@property(assign) BOOL                            isPlayMic;  //回放录音
@property(assign) BOOL                            isPaused;   //是否暂停
@property(assign) BOOL                            isHeadset;  //接上耳塞
@property(assign) BOOL                            isHeadsetTrue;//接上耳塞
@property(assign) BOOL                            isIPad1;    //是否ipad1
@property(assign) BOOL                            isIOS5;    //是否IOS5.x
@property(assign) BOOL                            isIOS6;    //是否IOS6.x
@property(assign) BOOL                            isErroring;//是否发生错误
@property(assign) BOOL                            isOutputMp3;//是否压缩成mp3
@property(assign) BOOL                            isReadFileToMemory;//是否读文件至内存

@property(assign) int                             outputChanelIndex;//输出声道
@property(assign) ExtAudioFileRef                 audioFile;  //保存的音频文件接口
@property(assign) NSTimeInterval                  currentTime;      //当前时间   
@property(assign) NSTimeInterval                  timeLenRecord;    //录音时长
@property(assign) UInt32                          recordSamples;    //录音总sample
@property (nonatomic,assign) id delegate;//父对象

@property(nonatomic,retain,setter=setImportAudioFile:, getter=importAudioFile) NSString*             importAudioFile;  //播放文件
@property(nonatomic,retain,setter=setOutputAudioFile:, getter=outputAudioFile) NSString*             outputAudioFile;  //输出文件
@property(assign,setter=setVolumeRecorder:, getter=volumeRecorder) float                             volumeRecorder;   //输入音量
@property(assign,setter=setVolumePlayer:, getter=volumePlayer)float                                  volumePlayer;     //输出音量

@property (readwrite)           AudioStreamBasicDescription stereoStreamFormat;
@property (readwrite)           AudioStreamBasicDescription monoStreamFormat;
@property (readwrite)           AudioStreamBasicDescription SInt16StreamFormat;	
@property (readwrite)           AudioStreamBasicDescription floatStreamFormat;	
@property (readwrite)           AudioStreamBasicDescription auEffectStreamFormat;	

@property (readwrite)           Float64                     graphSampleRate;
@property (getter = isPlaying)  BOOL                        playing;
@property                       BOOL                        interruptedDuringPlayback;

@property                       AudioUnit                   mixerUnit;
@property                       AudioUnit                   ioUnit;

@property       AUNode      iONode;             
@property       AUNode      mixerNode;         

@property FFTSetup fftSetup;			
@property COMPLEX_SPLIT fftA;			
@property int fftLog2n;
@property int fftN;
@property int fftNOver2;		

@property void *dataBuffer;			
@property float *outputBuffer;		
@property float *analysisBuffer;	

@property SInt16 *conversion16BufferLeft;	
@property SInt16 *conversion16BufferRight;	
@property SInt32 *conversion32BufferLeft;	
@property SInt32 *conversion32BufferRight;	

@property float *filterBuffer;      // filter buffer
@property int filterLength;         // filter length
@property float *signalBuffer;      // signal buffer
@property int signalLength;         // signal length
@property float *resultBuffer;      // signal buffer
@property int resultLength;         // signal length


@property size_t fftBufferCapacity;	
@property size_t fftIndex;	


@property (assign) int displayInputFrequency;
@property (assign) float displayInputLevelLeft;
@property (assign) float displayInputLevelRight;
@property (assign) int displayNumberOfInputChannels;


@property float sinFreq;
@property float sinPhase;
@property BOOL  synthNoteOn;

@property int   micFxType;
@property BOOL  micFxOn;
@property float micFxControl;


@property BOOL inputDeviceIsAvailable;


// function (method) declarations
- (void) obtainSoundFileURLs;
- (void) setupAudioSession;
- (void) setupStereoStreamFormat;
- (void) setupMonoStreamFormat;
- (void) setupSInt16StreamFormat;
- (void) setupFloatStreamFormat;
- (void) setupStereoFileFormat;
- (void) setupMonoFileFormat;

- (void) setup;
- (void) initBuffer;
- (void) readAudioFilesIntoMemory;
- (void) configureAndInitializeAudioProcessingGraph;
- (void) setupAudioProcessingGraph;
- (void) connectAudioProcessingGraph;

- (void) start;
- (void) start:(SInt64)n;
- (BOOL) stop;
- (void) pause;
- (void) play;
- (void) seek:(NSTimeInterval)n;
- (BOOL) getHeadsetMode;
- (void) delete;

- (void) playSynthNote;
- (void) stopSynthNote;

- (void) enableMixerInput: (UInt32) inputBus isOn: (AudioUnitParameterValue) isONValue;
- (void) setMixerInput: (UInt32) inputBus gain: (AudioUnitParameterValue) inputGain;
- (void) setMixerOutputGain: (AudioUnitParameterValue) outputGain;
- (void) setMixerFx: (AudioUnitParameterValue) isOnValue;
- (void) setMixerBus5Fx: (AudioUnitParameterValue) isOnValue;

- (void) printASBD: (AudioStreamBasicDescription) asbd;
- (void) printErrorMessage: (NSString *) errorString withStatus: (OSStatus) result;

- (void) convolutionSetup;
- (void) FFTSetup;
- (void) initDelayBuffer;
- (Float32) getMixerOutputLevel;
- (soundStructPtr) getSoundArray:(int)index;
- (void)writeAudioFile:(int)totalFrames;

- (BOOL) writeMp3Buffer:(void*)buffer_l  nSamples:(int)nSamples;
- (void) closeMp3File;
- (void) createMp3File;

@end

