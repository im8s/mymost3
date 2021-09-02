//
//  JXConvertMedia.m
//  MyAVController
//
//  Created by imac on 13-3-8.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "JXConvertMedia.h"
#import "UIImage-Extensions.h"

@implementation JXConvertMedia
@synthesize outputFileName;
@synthesize audioSampleRate,audioEncodeBitRate,videoWidth,videoHeight,videoEncodeBitRate,videoFrames,audioChannels,saveVideoToImage,logoRect,logoImage,rotateSize,inputAudioFile1,inputAudioFile2,progress,progressText,delegate,onFinish;

- (id)init {
	self = [super init];
	if (self) {
        audioSampleRate = 44100;
        audioEncodeBitRate = 64000;
        audioChannels = 1;
        videoEncodeBitRate = 300*1000;
        videoHeight = JX_SCREEN_WIDTH;
        videoWidth  = 480;
        videoFrames = 15;
        [self initRotateSize];
	}
	return self;
}

- (void)dealloc {
//    NSLog(@"JXConvertMedia.dealloc");
//    [_videoReader release];
//    [_audioReader1 release];
//    [_audioReader2 release];
//    [_videoInput release];
//    [_audioInput release];
//    [_writer release];
//    [super dealloc];
}


-(void)openMedia:(NSString*)video audio1:(NSString*)audio1 audio2:(NSString*)audio2
{
    AVURLAsset * assetVideo;
    if(video){
        NSURL* url = [NSURL  fileURLWithPath:video];
        if ([video rangeOfString:@"://"].location != NSNotFound) {
            url = [NSURL URLWithString:video];
        }
        assetVideo = [AVURLAsset URLAssetWithURL:url options:nil];
        [self readVideo:assetVideo];
    }
    
    if(audio1){
        NSURL* url = [NSURL  fileURLWithPath:audio1];
        AVURLAsset * assetAudio = [AVURLAsset URLAssetWithURL:url options:nil];
        [self readAudio1:assetAudio];
    }

    if(audio2){
        if(![video isEqualToString:audio2]){
            NSURL* url = [NSURL  fileURLWithPath:audio2];
            assetVideo = [AVURLAsset URLAssetWithURL:url options:nil];
        }
        [self readAudio2:assetVideo];
    }

    [self createWriter];
}

- (void)readVideo:(AVURLAsset*)asset
{
    AVAssetTrack * videoTrack = nil;
    NSArray * tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if ([tracks count] == 1)
    {
        videoTrack = [tracks objectAtIndex:0];
        NSError * error = nil;
        
        _videoReader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
//        if (error)
//            NSLog(@"_videoReader fail!\n");
        
        NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
        NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
        NSDictionary* videoSettings = 
        [NSDictionary dictionaryWithObject:value forKey:key]; 
        
        [_videoReader addOutput:[AVAssetReaderTrackOutput 
                                 assetReaderTrackOutputWithTrack:videoTrack 
                                 outputSettings:videoSettings]];
        [_videoReader startReading];
        
    }
}

- (void)readAudio1:(AVURLAsset*)asset{
    AVAssetTrack * audioTrack = nil;
    NSArray * tracks = [asset tracksWithMediaType:AVMediaTypeAudio];
    if ([tracks count] == 1)
    {
        audioTrack = [tracks objectAtIndex:0];
        _audiotimeRange1= CMTimeRangeMake(kCMTimeZero, asset.duration);
        NSError * error = nil;
        
        _audioReader1 = [[AVAssetReader alloc] initWithAsset:asset error:&error];
//        if (error)
//            NSLog(@"_audioReader fail!\n");

        NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                  nil ];

        [_audioReader1 addOutput:[AVAssetReaderTrackOutput
                                 assetReaderTrackOutputWithTrack:audioTrack 
                                 outputSettings:settings]];
        [_audioReader1 startReading];
    }
}

- (void)readAudio2:(AVURLAsset*)asset{
    AVAssetTrack * audioTrack = nil;
    NSArray * tracks = [asset tracksWithMediaType:AVMediaTypeAudio];
    if ([tracks count] == 1)
    {
        audioTrack = [tracks objectAtIndex:0];
        NSError * error = nil;
        
        _audioReader2 = [[AVAssetReader alloc] initWithAsset:asset error:&error];
//        if (error)
//            NSLog(@"_audioReader fail!\n");
        
        NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                  nil ];
        
        [_audioReader2 addOutput:[AVAssetReaderTrackOutput
                                  assetReaderTrackOutputWithTrack:audioTrack
                                  outputSettings:settings]];
        [_audioReader2 startReading];
    }
}

-(void) convert{
    [_writer startWriting];

    if(_videoReader)
        [self convertVideo];

    if(_audioReader1){
        if(_audioReader2)
            [self addTwoAudio];
        else
            [self convertOneAudio];
    }


//    [_writer endSessionAtSourceTime:_time];
    [_videoInput markAsFinished];
    [_audioInput markAsFinished];
    [_writer finishWriting];
//    [_writer finishWritingWithCompletionHandler:^{
//        NSLog(@"convert completed");
//		[self.delegate performSelectorOnMainThread:self.onFinish withObject:[outputFileName lastPathComponent] waitUntilDone:NO];
//    }];

//    NSLog(@"convert ok");
}

-(void) convertVideo{
    CMTime timeStart,timelen;
    double maxLen = (double)_audiotimeRange1.duration.value/_audiotimeRange1.duration.timescale;
    AVAssetReaderTrackOutput * outputVideo = [_videoReader.outputs objectAtIndex:0];
    _writeVideoCount = 0;
    [self setProgressValue:0];
    while ([_videoReader status] == AVAssetReaderStatusReading)
    {
        CMSampleBufferRef sampleBuffer = [outputVideo copyNextSampleBuffer];
        if (sampleBuffer){
            _time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            if(_writeVideoCount==0){
                [_writer startSessionAtSourceTime:_time];
                timeStart = _time;
            }
            //超时则退出
            timelen = CMTimeSubtract(_time,timeStart);
            double curLen = (double)timelen.value/timelen.timescale;
            [self setProgressValue:curLen/maxLen];
            if(curLen >= maxLen)
                break;

            [self changeSample:sampleBuffer];
            [self writeSampleBuffer:sampleBuffer ofType:AVMediaTypeVideo];

//            _time = CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer);
            _writeVideoCount++;
            CMItemCount numSamplesInBuffer = CMSampleBufferGetNumSamples(sampleBuffer);
            double sec = (double)_time.value/_time.timescale;
//            NSLog(@"%d,%d,%d,%d,%f",_writeVideoCount,numSamplesInBuffer,_time.value,_time.timescale,sec);
            CFRelease(sampleBuffer);
            
        }
    }
    _timeLast = _time;
}

/*
-(void) convertVideo{
    CMTime timeStart,timelen;
    double maxLen = (double)_audiotimeRange1.duration.value/_audiotimeRange1.duration.timescale;
    AVAssetReaderTrackOutput * outputVideo = [_videoReader.outputs objectAtIndex:0];
    _writeVideoCount = 0;
    [self setProgressValue:0];
    AVAssetReaderTrackOutput * outputAudio = [_audioReader1.outputs objectAtIndex:0];

    while ([_videoReader status] == AVAssetReaderStatusReading)
    {
        CMSampleBufferRef sampleBuffer = [outputVideo copyNextSampleBuffer];
        if (sampleBuffer){
            _time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            if(_writeVideoCount==0){
                [_writer startSessionAtSourceTime:_time];
                timeStart = _time;
            }
            //超时则退出
            timelen = CMTimeSubtract(_time,timeStart);
            double curLen = (double)timelen.value/timelen.timescale;
            [self setProgressValue:curLen/maxLen];
            if(curLen >= maxLen)
                break;
            
            [self changeSample:sampleBuffer];
            [self writeSampleBuffer:sampleBuffer ofType:AVMediaTypeVideo];

            _writeVideoCount++;
            CMItemCount numSamplesInBuffer = CMSampleBufferGetNumSamples(sampleBuffer);
            NSLog(@"video=%d,%d",_writeVideoCount,numSamplesInBuffer);
            CFRelease(sampleBuffer);
            
            if ([_audioReader1 status] == AVAssetReaderStatusReading)
            {
                CMSampleBufferRef sampleBuffer = [outputAudio copyNextSampleBuffer];
                if (sampleBuffer){
                    _time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
                    [self writeSampleBuffer:sampleBuffer ofType:AVMediaTypeAudio];
                    _writeAudioCount1++;
                    CMItemCount numSamplesInBuffer = CMSampleBufferGetNumSamples(sampleBuffer);
                    NSLog(@"audio=%d,%d",_writeAudioCount1,numSamplesInBuffer);
                    CFRelease(sampleBuffer);
                }
            }
        }
    }
}*/

-(void)convertOneAudio{
    //转换音频：
    AVAssetReaderTrackOutput * outputAudio = [_audioReader1.outputs objectAtIndex:0];
//    CMTime time;
    _writeAudioCount1 = 0;
    while ([_audioReader1 status] == AVAssetReaderStatusReading)
    {
        CMSampleBufferRef sampleBuffer = [outputAudio copyNextSampleBuffer];
        if (sampleBuffer){
            _time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
//            if(_writeAudioCount1==0)
//                [_writer startSessionAtSourceTime:_time];
            [self writeSampleBuffer:sampleBuffer ofType:AVMediaTypeAudio];
            _writeAudioCount1++;

//            _time = CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer);
            double sec = (double)_time.value/_time.timescale;
            CMItemCount numSamplesInBuffer = CMSampleBufferGetNumSamples(sampleBuffer);
//            NSLog(@"%d,%d,%d,%d,%f",_writeAudioCount1,numSamplesInBuffer,_time.value,_time.timescale,sec);
            CFRelease(sampleBuffer);
        }
    }
}

-(void)addTwoAudio{
    CMTime time,timeStart,timelen;
    double maxLen = (double)_audiotimeRange1.duration.value/_audiotimeRange1.duration.timescale;

    AudioBufferList  audioBufferList1;
    AudioBuffer audioBuffer1;
    AudioBufferList  audioBufferList2;
    AudioBuffer audioBuffer2;
    
    //转换音频：
    AVAssetReaderTrackOutput * outputAudio1 = [_audioReader1.outputs objectAtIndex:0];
    AVAssetReaderTrackOutput * outputAudio2 = [_audioReader2.outputs objectAtIndex:0];
    _writeAudioCount1 = 0;
    [self setProgressValue:0];
    while ([_audioReader1 status] == AVAssetReaderStatusReading)
    {
        CMSampleBufferRef sampleBuffer1 = [outputAudio1 copyNextSampleBuffer];
        if (sampleBuffer1){
            time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer1);
            if(_writeAudioCount1==0){
                [_writer startSessionAtSourceTime:time];
                timeStart = time;
            }
            timelen = CMTimeSubtract(time,timeStart);
            double curLen = (double)timelen.value/timelen.timescale;
            [self setProgressValue:curLen/maxLen];
            if(curLen >= maxLen)
                break;

            if(_audioReader2){//假如有双音轨:
                if([_audioReader2 status] == AVAssetReaderStatusReading){
                    CMSampleBufferRef sampleBuffer2 = [outputAudio2 copyNextSampleBuffer];
                    if(sampleBuffer2) {
                        CMItemCount samples1 = CMSampleBufferGetNumSamples(sampleBuffer1);
                        CMItemCount samples2 = CMSampleBufferGetNumSamples(sampleBuffer2);
                        
                        CMBlockBufferRef blockBuffer1;
                        CMBlockBufferRef blockBuffer2;
                        
                        CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer1, NULL, &audioBufferList1, sizeof(audioBufferList1), NULL, NULL, kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment, &blockBuffer1);
                        audioBuffer1 = audioBufferList1.mBuffers[0];
                        
                        CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer2, NULL, &audioBufferList2, sizeof(audioBufferList2), NULL, NULL, kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment, &blockBuffer2);
                        audioBuffer2 = audioBufferList2.mBuffers[0];
                        
                        SInt16* p1 = audioBuffer1.mData;
                        SInt16* p2 = audioBuffer2.mData;
                        
                        for(int i=0;i<samples1;i++){
                            p1[i] = get2To1Sample16(p1[i] , p2[i*2], 1, 1);
//                            p1[i*2] = get2To1Sample16(p1[i*2] , p2[i], 1, 1);
//                            p1[i*2+1] = get2To1Sample16(p1[i*2+1] , p2[i], 1, 1);
                        }
                        
                        p1 = NULL;
                        p2 = NULL;
                        
                        CFRelease(sampleBuffer2);
//                        NSLog(@"count=%d,mDataByteSize=%d,%d;samples=%d,%d;",_writeAudioCount1,audioBuffer1.mDataByteSize,audioBuffer2.mDataByteSize,samples1,samples2);
                    }
                }
            }
            

            [self writeSampleBuffer:sampleBuffer1 ofType:AVMediaTypeAudio];
            CFRelease(sampleBuffer1);

//            NSLog(@"%d",_writeAudioCount1);
//            NSLog(@"count=%d,mDataByteSize=%d,%d;samples=%d,%d;",_writeAudioCount1,audioBuffer1.mDataByteSize,audioBuffer2.mDataByteSize);
            _writeAudioCount1++;
        }
    }
}

SInt32 get2To1Sample32(SInt32 n1,SInt32 n2,float volume,float volRecord){
    return (n1*volRecord+volume*n2)/2; //录音放大2倍，伴奏跟随音量调节
}

SInt16 get2To1Sample16(SInt16 n1,SInt16 n2,float volume,float volRecord){
    return (n1*volRecord+volume*n2)/2; //录音放大2倍，伴奏跟随音量调节
}

-(void)setProgressValue:(double)n{
    progress.progress = n;
    progressText.text = [[NSString stringWithFormat:@"%.0f",progress.progress*100] stringByAppendingString:@"%"];
    [[NSRunLoop currentRunLoop]runUntilDate:[NSDate distantPast]];//重要
}

- (void) writeSampleBuffer:(CMSampleBufferRef)sampleBuffer ofType:(NSString *)mediaType
{
//    if ( _writer.status == AVAssetWriterStatusUnknown ) {
//        
//        if ([_writer startWriting]) {
//            [_writer startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
//        }
//    }
    
    if ( _writer.status == AVAssetWriterStatusWriting ) {
        
        if (mediaType == AVMediaTypeVideo) {
            if (_videoInput.readyForMoreMediaData)
                [_videoInput appendSampleBuffer:sampleBuffer];
            
        }
        
        if (mediaType == AVMediaTypeAudio) {
            if (_audioInput.readyForMoreMediaData)
                [_audioInput appendSampleBuffer:sampleBuffer];

        }
    }
}

- (void)removeFile:(NSURL *)fileURL
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [fileURL path];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSError *error;
        [fileManager removeItemAtPath:filePath error:&error];
//        if (!success)
//            [self showError:error];
    }
}

- (BOOL) createWriter
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputFileName]) 
        [[NSFileManager defaultManager] removeItemAtPath:outputFileName error:NULL];
    
    NSError *error = nil;
    _writer = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:outputFileName] fileType:AVFileTypeMPEG4 error:&error];
    
    if (error)
    {
//        NSLog(@"%@", error);
        return NO;
    }
    
    AudioChannelLayout acl;
    bzero( &acl, sizeof(acl));
    if(audioChannels>=2)
        acl.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    else
        acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
    
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVFormatIDKey,
                              [NSNumber numberWithFloat:audioSampleRate], AVSampleRateKey,
                              [NSNumber numberWithInt:audioChannels], AVNumberOfChannelsKey,
                              [NSNumber numberWithInt:audioEncodeBitRate], AVEncoderBitRateKey,
                              [NSData dataWithBytes:&acl length:sizeof(acl)], AVChannelLayoutKey,
                              nil ];
    
    _audioInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio outputSettings:settings];
    _audioInput.expectsMediaDataInRealTime = YES;
    [_writer addInput:_audioInput];
    
    NSDictionary *codecSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithInt:videoEncodeBitRate], AVVideoAverageBitRateKey,
                                   [NSNumber numberWithInt:videoFrames],AVVideoMaxKeyFrameIntervalKey,
                                   AVVideoProfileLevelH264Main31, AVVideoProfileLevelKey,
                                   nil];    
    
    settings = [NSDictionary dictionaryWithObjectsAndKeys:
                AVVideoCodecH264, AVVideoCodecKey,
                [NSNumber numberWithInt:((int)videoWidth/16)*16], AVVideoWidthKey,
                [NSNumber numberWithInt:((int)videoHeight/16)*16], AVVideoHeightKey,
                codecSettings,AVVideoCompressionPropertiesKey,
                nil];
    
    _videoInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:settings];
    _videoInput.expectsMediaDataInRealTime = YES;

    _writer.shouldOptimizeForNetworkUse = YES;
    [_writer addInput:_videoInput];
    
    return YES;
}

-(void)changeSample:(CMSampleBufferRef)sampleBuffer {
    @autoreleasepool {
//	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    /*Lock the image buffer*/
    CVImageBufferRef imageBuffer=NULL;
    imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0); 
    /*Get information about the image*/
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer); 
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer); 
    long width = CVPixelBufferGetWidth(imageBuffer);
    long height = CVPixelBufferGetHeight(imageBuffer);
    
//    UIGraphicsBeginImageContext(rotateSize);
    /*Create a CGImageRef from the CVImageBufferRef*/
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef newImage = CGBitmapContextCreateImage(newContext); 

    /*
	CGContextTranslateCTM(newContext, rotateSize.width/2, rotateSize.height/2);
	CGContextRotateCTM(newContext, -90.0 * M_PI / 180);
	CGContextScaleCTM(newContext, 1.0, 1.0);
    CGContextDrawImage(newContext, CGRectMake(-width/2, -height/2, width, height), newImage);
    */
    
    if(logoImage)
        CGContextDrawImage(newContext,logoRect,logoImage.CGImage);
	if(saveVideoToImage)
        [self saveToImage:sampleBuffer newImage:newImage];
    
    
	//[_customLayer performSelectorOnMainThread:@selector(setContents:) withObject: (id) newImage waitUntilDone:YES];
	//[_imageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:YES];
    
    
	
    CGContextRelease(newContext); 
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(newImage);
	CVPixelBufferUnlockBaseAddress(imageBuffer,0);
	
//	[pool drain];
        
    }
}

-(void)saveToImage:(CMSampleBufferRef)sampleBuffer newImage:(CGImageRef)newImage{
    CMTime n = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    int m = (int)(n.value / n.timescale);
    if(m % saveVideoToImage == 0){
        NSString* s = [NSString stringWithFormat:@"%@convert_video_%d.jpg",docFilePath,m];
        if(![s isEqualToString:_lastSaveFile]){
            UIImage *image= [UIImage imageWithCGImage:newImage scale:1.0 orientation:UIImageOrientationRight];
            image = [image imageAtRect:CGRectMake(80, 0, JX_SCREEN_WIDTH, JX_SCREEN_WIDTH)];
            NSData* data = UIImageJPEGRepresentation(image,0.8f);
//            NSLog(@"saveToImage:%@",s);
            [data writeToFile:s atomically:YES];
            image = nil;
            data  = nil;
//            [_lastSaveFile release];
            _lastSaveFile = s;
//            [_lastSaveFile retain];
        }
    }
}

-(void)initRotateSize{
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, videoWidth, videoHeight)];
    CGAffineTransform t = CGAffineTransformMakeRotation(-90.0/180*M_PI);
    rotatedViewBox.transform = t;
    rotateSize = rotatedViewBox.frame.size;
//    [rotatedViewBox release];
    rotateSize.width=480;
    rotateSize.height=480;
//    NSLog(@"rotateSize=%f,%f",rotateSize.width, rotateSize.height);
}


@end
