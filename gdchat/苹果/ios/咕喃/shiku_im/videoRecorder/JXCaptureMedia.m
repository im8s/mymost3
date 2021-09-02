#import "JXCaptureMedia.h"
#import "UIImage-Extensions.h"

@implementation JXCaptureMedia

dispatch_queue_t cameraProcessingQueue, audioProcessingQueue;

@synthesize captureSession = _capSession,logoImage,saveVideoToImage,curFlashMode,labelTime,logoRect;
@synthesize isRecording=_isRecording,audioSampleRate,audioEncodeBitRate,videoWidth,videoHeight,videoEncodeBitRate,videoFrames,audioChannels,isRecordAudio,isFrontFace,previewRect,previewLayer=_prevLayer,outputFileName,referenceOrientation,videoOrientation,isEditVideo,isOnlySaveFirstImage,outputImageFiles;

/*
1.读一个文件进行转换 ok
2.镜头转换 ok
3.叠图或文字 ok
4.抓图保存为文件 ok
5.补光灯，可以选择自动、打开、关闭三种状态；ok
6.剪裁图片 ok
7.录像中止或被中止的事件 ok
8.检测是否有录制设备 ok
9.输入输出参数化 ok
10.支持双音频输入混音为一条单音轨
11.内存释放 ok
12.显示时间 ok
*/



#pragma mark -
#pragma mark Initialization
- (id)init {
    NSLog(@"JXCaptureMedia.init");
    self = [super init];
    if (self) {
        /*We initialize some variables (they might be not initialized depending on what is commented or not)*/
        _imageView = nil;
        _prevLayer = nil;
        _customLayer = nil;
        curFlashMode = AVCaptureFlashModeAuto;
        audioSampleRate = 22050*2;//音频采样率
        audioEncodeBitRate = 32*1000;//32Kbps
        audioChannels = 1;
        videoEncodeBitRate = 300*1000;//300Kbps
        videoFrames = 15;
        videoHeight = 480;
        videoWidth  = 480;
        saveVideoToImage = 0;
        isRecordAudio    = 1;
        _isPaused = 0;
        _isSendEnd = 0;
        isEditVideo = 0;
        isFrontFace = 1;
        referenceOrientation = AVCaptureVideoOrientationPortrait;
        _startSessionTime.value = 0;
        outputImageFiles = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"JXCaptureMedia.dealloc");
//	[_capSession release];
//    [_captureVideo release];
//    [_captureAudio release];
//    [_prevLayer release];
//    [outputFileName release];
    [outputImageFiles removeAllObjects];
//    [outputImageFiles release];
//    
//    [super dealloc];
}

- (BOOL)initCapture {
	/*We setup the input*/
    if([self cameraCount]<=0){
        [g_App performSelector:@selector(showAlert:) withObject:Localized(@"JXAlert_NoCenmar") afterDelay:1];
//        [g_App showAlert:@"没有摄像头"];
        return 0;
    }
    _capSession = [[AVCaptureSession alloc] init];
    [_capSession beginConfiguration];
    
    if(isFrontFace)
        _deviceVideo = [AVCaptureDeviceInput
                        deviceInputWithDevice:[self frontFacingCamera]
                        error:nil];
    else
        _deviceVideo = [AVCaptureDeviceInput
                        deviceInputWithDevice:[self backFacingCamera]
                        error:nil];

    if(!_deviceVideo){
        [g_App performSelector:@selector(showAlert:) withObject:Localized(@"JX_CanNotopenCenmar") afterDelay:1];
//        [g_App showAlert:@"无法打开摄像头，请确定在隐私->相机设置中打开了权限"];
        return 0;
    }
        
    AVCaptureDevicePosition position = [[_deviceVideo device] position];
    
    isFrontFace = position == AVCaptureDevicePositionFront;
    NSLog(@"isFrontFace=%d",isFrontFace);

        /*We setupt the output*/
	_captureVideo = [[AVCaptureVideoDataOutput alloc] init];
	/*While a frame is processes in -captureOutput:didOutputSampleBuffer:fromConnection: delegate methods no other frames are added in the queue.
	 If you don't want this behaviour set the property to NO */
	_captureVideo.alwaysDiscardsLateVideoFrames = YES;
	/*We specify a minimum duration for each frame (play with this settings to avoid having too many frames waiting
	 in the queue because it can cause memory issues). It is similar to the inverse of the maximum framerate.
	 In this example we set a min frame duration of 1/10 seconds so a maximum framerate of 10fps. We say that
	 we are not able to process more than 10 frames per second.*/
	_captureVideo.minFrameDuration = CMTimeMake(1, videoFrames);
    NSLog(@"videoEncodeBitRate=%d,%d",videoFrames,videoEncodeBitRate);
	
	/*We create a serial queue to handle the processing of our frames*/
	// Set the video output to store frame in BGRA (It is supposed to be faster)
/*	NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
	NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA]; 
	NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];*/
    
    NSDictionary * videoSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                               [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA],(NSString*)kCVPixelBufferPixelFormatTypeKey,
                               [NSNumber numberWithInt:videoWidth], (id)kCVPixelBufferWidthKey,
                               [NSNumber numberWithInt:videoHeight], (id)kCVPixelBufferHeightKey,
                               nil];
    
	[_captureVideo setVideoSettings:videoSettings]; 
	/*And we create a capture session*/

	dispatch_queue_t queueVideo;
	queueVideo = dispatch_queue_create("queueVideo", DISPATCH_QUEUE_SERIAL);
	[_captureVideo setSampleBufferDelegate:self queue:queueVideo];
//	dispatch_release(queueVideo);
	
    [_capSession setSessionPreset:AVCaptureSessionPresetMedium];
	/*We add input and output*/
	[_capSession addInput:_deviceVideo];
	[_capSession addOutput:_captureVideo];
    
    /*We use medium quality, ont the iPhone 4 this demo would be laging too much, the conversion in UIImage and CGImage demands too much ressources for a 720p resolution.*/
    

    //音频:
    if(isRecordAudio){
        dispatch_queue_t queueAudio;
        queueAudio = dispatch_queue_create("queueAudio", NULL);
        
        _deviceAudio = [AVCaptureDeviceInput 
                        deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio] 
                        error:nil];
        if(!_deviceAudio){
            [g_App performSelector:@selector(showAlert:) withObject:Localized(@"JX_CanNotOpenMicr") afterDelay:1];
            return 0;
        }
        _captureAudio =  [[AVCaptureAudioDataOutput alloc] init];
        
        //    [_captureAudio setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
        [_captureAudio setSampleBufferDelegate:self queue:queueAudio];
        [_capSession addInput:_deviceAudio];
        [_capSession addOutput:_captureAudio];
//        dispatch_release(queueAudio);
    }

    [_capSession commitConfiguration];

    int temp;
    for(int i=0;i<[[_captureVideo connections] count];i++){
        AVCaptureConnection* p = [[_captureVideo connections] objectAtIndex:i];
//        NSLog(@"p=%d,%d" ,p.videoOrientation,p.supportsVideoOrientation);
        temp = p.videoOrientation;
        //        NSLog(@"p=%f,%d",p.videoMinFrameDuration.value/p.videoMinFrameDuration.timescale,p.videoOrientation);
    }
    self.videoOrientation = temp;

    //    [self createNotify];
    NSLog(@"initCapture");
    return 1;
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position ){
            return device;
        }
    return nil;
}
-(BOOL)createPreview:(UIView*)parentView{
    BOOL b = [self initCapture];
    if(!b)
        return b;
    if (_maxTime<=0) {
        _maxTime = 60;
    }
	_prevLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession: _capSession];
    if(previewRect.size.height == 0 && previewRect.size.width==0)
        _prevLayer.frame = parentView.bounds;
    else
        _prevLayer.frame = previewRect;
//    _prevLayer.frame = CGRectMake(0, (JX_SCREEN_HEIGHT-JX_SCREEN_WIDTH)/2, JX_SCREEN_WIDTH, JX_SCREEN_WIDTH);
    _prevLayer.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
	_prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    parentView.layer.masksToBounds = YES;
//	[parentView.layer addSublayer: _prevLayer];
    [parentView.layer insertSublayer:_prevLayer below:[[parentView.layer sublayers] objectAtIndex:0]];
    
    [_capSession startRunning];
    return b;
}


#pragma mark -
#pragma mark AVCaptureSession delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput 
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer 
	   fromConnection:(AVCaptureConnection *)connection 
{ 
    /*We create an autorelease pool because as we are not in the main_queue our code is
	 not executed in the main thread. So we have to create an autorelease pool for the thread we are in*/
	

    
    // a very dense way to keep track of the time at which this frame
    // occurs relative to the output stream, but it's just an example!
    if(_isRecording && !_isPaused){
        CMTime t = CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer);                   
        NSLog(@"%lld,%d",t.value,t.timescale);
        if(_startSessionTime.value == 0){
//        if( _writer.status ==  AVAssetWriterStatusUnknown && _startSessionTime.value == 0){
            _startSessionTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            [_writer startWriting];
            [_writer startSessionAtSourceTime:_startSessionTime];
            NSLog(@"start=%lld,%d",t.value,t.timescale);
            return;
        }
        if( _writer.status <=  AVAssetWriterStatusWriting )
        {
            if(captureOutput == _captureVideo)
                if(_videoInput.readyForMoreMediaData){
                    _writeVideoCount++;
                    
                    [self showRecordTime:sampleBuffer];
                    if(_adaptor){
//                        [_adaptor appendPixelBuffer:[self cutPixelBuffer:sampleBuffer] withPresentationTime:t];
                    }else{
                        if(isEditVideo){
                            [self changeSample:sampleBuffer];
//                            [self cutSampleBuffer:sampleBuffer];
//                            [self cutPixelBuffer:sampleBuffer];
                        }
                        if( _writer.status <=  AVAssetWriterStatusWriting )
                            [_videoInput appendSampleBuffer:sampleBuffer];
                    }
                }
            if(captureOutput == _captureAudio)
                if(_audioInput.readyForMoreMediaData){
//                    CMSampleBufferSetOutputPresentationTimeStamp(sampleBuffer,CMTimeMakeWithSeconds(_lastTime,30));                   
                    [_audioInput appendSampleBuffer:sampleBuffer];
                    _writeAudioCount++;
                    NSLog(@"audio");
                }
        }
    }
}	

-(void)showRecordTime:(CMSampleBufferRef)sampleBuffer {
    CMTime t = CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer);
    t = CMTimeSubtract(t,_startSessionTime);
    NSInteger m = (t.value/t.timescale)/60;
    NSInteger n = (t.value/t.timescale)%60;
    self.timeLen = t.value/t.timescale;
    NSString * labelTimeStr;
    if (!_isReciprocal) {
        labelTimeStr = [NSString stringWithFormat:@"%.2ld:%.2ld",m,n];
    }else{
        if(_maxTime){
        NSInteger maxM = (_maxTime-self.timeLen)/60;
        NSInteger maxN = (_maxTime-self.timeLen)%60;
        labelTimeStr = [NSString stringWithFormat:@"%ld:%.2ld",maxM,maxN];
        }
    }
    
    
    if(labelTime){
        if( ![_lastShowTime isEqualToString:labelTimeStr] ){
            [labelTime performSelectorOnMainThread:@selector(setText:) withObject:labelTimeStr waitUntilDone:YES];
//            [_lastShowTime release];
            _lastShowTime = labelTimeStr;
//            [_lastShowTime retain];
        }
        
//        if(self.timeLen >= self.maxTime && !_isSendEnd){
//            _isSendEnd = YES;
//            [g_notify postNotificationName:kVideoRecordEndNotifaction object:self userInfo:nil];
//        }
    }
    if(self.timeLen >= self.maxTime && !_isSendEnd){
        _isSendEnd = YES;
        [g_notify postNotificationName:kVideoRecordEndNotifaction object:self userInfo:nil];
    }
    
}

-(void)changeSample:(CMSampleBufferRef)sampleBuffer {
    @autoreleasepool{
//    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    /*Lock the image buffer*/
    CVImageBufferRef imageBuffer=NULL;
    imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    /*Get information about the image*/
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    /*Create a CGImageRef from the CVImageBufferRef*/
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef newImage = CGBitmapContextCreateImage(newContext);
    
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
    
//    [pool drain];
    }
} 

-(void)saveToImage:(CMSampleBufferRef)sampleBuffer newImage:(CGImageRef)newImage{
//    CMTime n = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    CMTime n = CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer);
    n = CMTimeSubtract(n,_startSessionTime);
    NSInteger m = n.value / n.timescale;
    BOOL isSave;
    
    isSave = m % saveVideoToImage == 0 || m==0;
    if(isSave && _saveCount<m && m<_maxTime){
        _saveCount = m;
        NSString* s;
        if(isOnlySaveFirstImage){
            s = [NSString stringWithFormat:@"%@.jpg", [outputFileName stringByDeletingPathExtension]];
            if(m/saveVideoToImage > 2)
                return;
        }
        else
            s = [NSString stringWithFormat:@"%@_%d.jpg", [outputFileName stringByDeletingPathExtension],m];

        CGRect r;
        size_t n;
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        _sampleWidth  = CVPixelBufferGetWidth(imageBuffer);
        _sampleHeight = CVPixelBufferGetHeight(imageBuffer);
        if(_sampleWidth<_sampleHeight){
            n = _sampleWidth;
            r = CGRectMake(0, (_sampleHeight-_sampleWidth)/2,  n, n);
        }
        else{
            n = _sampleHeight;
            r = CGRectMake((_sampleWidth-_sampleHeight)/2, 0, n, n);
        }
        
        UIImage *image= [UIImage imageWithCGImage:newImage scale:1.0 orientation:UIImageOrientationRight];
        image = [image imageAtRect:r];
        image = [image imageRotatedByDegrees:90];
        NSData* data = UIImageJPEGRepresentation(image,1);
        NSLog(@"saveToImage:%@",s);
        
        [data writeToFile:s atomically:YES];
        [outputImageFiles addObject:s];
        
        image = nil;
        data  = nil;
    }
}

#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload {
	_imageView = nil;
	_customLayer = nil;
	_prevLayer = nil;
}

- (BOOL) createWriter
{
    if(videoEncodeBitRate<=100)
        videoEncodeBitRate = 300*1000;
    if(videoFrames<=10)
        videoFrames = 15;
    NSLog(@"videoEncodeBitRate=%d,%d",videoFrames,videoEncodeBitRate);
//    NSString *file = [self file];
    
    if(outputFileName==nil)
        outputFileName = [ docFilePath stringByAppendingPathComponent:@"1.mp4"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputFileName])
        [[NSFileManager defaultManager] removeItemAtPath:outputFileName error:NULL];
    
    NSError *error = nil;
    _writer = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:outputFileName] fileType:AVFileTypeMPEG4 error:&error];
    
    if (error)
    {
        _writer = nil;
        
        NSLog(@"%@", error);
        return NO;
    }

    NSDictionary *settings;
    if(isRecordAudio){
        AudioChannelLayout acl;
        bzero( &acl, sizeof(acl));
        if(audioChannels>=2)
            acl.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
        else
            acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
        
        settings = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVFormatIDKey,
                                  [NSNumber numberWithFloat:audioSampleRate], AVSampleRateKey,
                                  [NSNumber numberWithInt:audioChannels], AVNumberOfChannelsKey,
                                  [NSNumber numberWithInt:audioEncodeBitRate], AVEncoderBitRateKey,
                                  [NSData dataWithBytes:&acl length:sizeof(acl)], AVChannelLayoutKey,
                                  nil ];
        
        _audioInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio outputSettings:settings];
        _audioInput.expectsMediaDataInRealTime = YES;
        [_writer addInput:_audioInput];
    }
    
    NSDictionary *codecSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithInt:videoEncodeBitRate], AVVideoAverageBitRateKey,
                                   [NSNumber numberWithInt:videoFrames],AVVideoMaxKeyFrameIntervalKey,
                                   AVVideoProfileLevelH264Baseline30, AVVideoProfileLevelKey,
                                   nil];    
    
    settings = [NSDictionary dictionaryWithObjectsAndKeys:
                AVVideoCodecH264, AVVideoCodecKey,
                [NSNumber numberWithInt:((int)videoWidth/16)*16], AVVideoWidthKey,
                [NSNumber numberWithInt:((int)videoHeight/16)*16], AVVideoHeightKey,
                [NSString stringWithString:AVVideoScalingModeResizeAspectFill], AVVideoScalingModeKey,
                codecSettings,AVVideoCompressionPropertiesKey,
                nil];
    
    _videoInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:settings];
    _videoInput.expectsMediaDataInRealTime = YES;    
    [_writer addInput:_videoInput];
    _writer.shouldOptimizeForNetworkUse = YES;
    
    _videoInput.transform = [self transformFromCurrentVideoOrientationToOrientation:self.referenceOrientation];
    _videoInput.transform = CGAffineTransformMakeRotation(M_PI/2);
//    _adaptor = [[AVAssetWriterInputPixelBufferAdaptor alloc] initWithAssetWriterInput:_videoInput
//     sourcePixelBufferAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA],    kCVPixelBufferPixelFormatTypeKey,
//      nil]];
    _adaptor = nil;
    NSLog(@"createWriter");
    return YES;
}

- (void) deleteWriter
{
//    [_videoInput release];
    _videoInput = nil;
    
//    [_audioInput release];
    _audioInput = nil;
    
//    [_writer release];
    _writer = nil;
}

-(void) start
{
    if( !_isRecording )
    {
        _saveCount = -1;
        _startSessionTime.value = 0;
        if( _writer == nil){
            if( ![self createWriter] ) {
                NSLog(@"Setup Writer Failed") ;
                return;
            }
        }

        if(!_capSession.running)
            [_capSession startRunning];

        
        _isRecording = YES;
        NSLog(@"start video recording...");
    }
}

-(void) stop
{
    if( _isRecording )
    {
        _isRecording = NO;
//        [_capSession stopRunning] ;
        [_videoInput markAsFinished];
        [_audioInput markAsFinished];
        if(![_writer finishWriting]) { 
            NSLog(@"finishWriting returned NO") ;
        }

        _videoInput = nil;
        _audioInput = nil;
        _writer = nil;
        _startSessionTime.value = 0;
        NSLog(@"video recording stopped:%d frames,%d audios",_writeVideoCount,_writeAudioCount);
    }
}

-(void)setting{
    AVCaptureConnection *videoConnection = NULL;
    
    [_capSession beginConfiguration];
    
    for ( AVCaptureConnection *connection in [_captureVideo connections] ) 
    {
        for ( AVCaptureInputPort *port in [connection inputPorts] ) 
        {
            if ( [[port mediaType] isEqual:AVMediaTypeVideo] ) 
            {
                videoConnection = connection;
            }
        }
    }
    if([videoConnection isVideoOrientationSupported]) // **Here it is, its always false**
    {
        [videoConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    }
    [_capSession commitConfiguration];
}

//-(void)clearQueue{
//    dispatch_queue_t queue = dispatch_queue_create("queueVideo", NULL);
//    dispatch_set_context(queue, (__bridge void * _Nullable)(self));
//    dispatch_set_finalizer_f(queue, _captureVideo);
//    [_captureVideo setSampleBufferDelegate: self queue: queue];
////    dispatch_release(queue);
//}

// Toggle between the front and back camera, if both are present.
- (BOOL) toggleCamera
{
    BOOL success = NO;
    
    if ([self cameraCount] > 1) {
        NSError *error;
        AVCaptureDeviceInput *newVideoInput=nil;
        AVCaptureDevicePosition position = [[_deviceVideo device] position];
        
        if (position == AVCaptureDevicePositionBack){
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontFacingCamera] error:&error];
            isFrontFace = YES;
        }
        else if (position == AVCaptureDevicePositionFront){
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:&error];
            isFrontFace = NO;
        }
        
        if (newVideoInput != nil) {
            [_capSession beginConfiguration];
            [_capSession removeInput:_deviceVideo];
            if ([_capSession canAddInput:newVideoInput])
                [_capSession addInput:newVideoInput];
            else
                [_capSession addInput:_deviceVideo];
            [_capSession commitConfiguration];
            success = YES;
//            [newVideoInput release];
            _deviceVideo = newVideoInput;
        }
    }
    return success;
}


#pragma mark Device Counts
- (NSUInteger) cameraCount
{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

- (NSUInteger) micCount
{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] count];
}

// Find a camera with the specificed AVCaptureDevicePosition, returning nil if one is not found

// Find a front facing camera, returning nil if one is not found
- (AVCaptureDevice *) frontFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

// Find a back facing camera, returning nil if one is not found
- (AVCaptureDevice *) backFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

// Find and return an audio device, returning nil if one is not found
- (AVCaptureDevice *) audioDevice
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    if ([devices count] > 0) {
        return [devices objectAtIndex:0];
    }
    return nil;
}

-(void)createNotify{
    [g_notify addObserver: self selector: @selector(onVideoError:) name: AVCaptureSessionRuntimeErrorNotification object: _capSession];
    [g_notify addObserver: self selector: @selector(onVideoInterrupted:) name: AVCaptureSessionWasInterruptedNotification object: _capSession];
}

-(void)onVideoError:(AVCaptureSession*)cap{
    [self stop];
}

-(void)onVideoInterrupted:(AVCaptureSession*)cap{
    [self stop];
}

-(void)setFlashMode:(AVCaptureFlashMode)n{
    AVCaptureDevice* device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if(device.hasFlash){
        [device lockForConfiguration:nil];
        curFlashMode = n;
        device.torchMode = n;
        device.flashMode = n;
        [device unlockForConfiguration];
    }
}

-(BOOL) pause{
    _isPaused = YES;
}

-(BOOL) play{
    _isPaused = NO;
}

- (CGFloat)angleOffsetFromPortraitOrientationToOrientation:(AVCaptureVideoOrientation)orientation
{
	CGFloat angle = 0.0;
	
	switch (orientation) {
		case AVCaptureVideoOrientationPortrait:
			angle = 0.0;
			break;
		case AVCaptureVideoOrientationPortraitUpsideDown:
			angle = M_PI;
			break;
		case AVCaptureVideoOrientationLandscapeRight:
			angle = -M_PI_2;
			break;
		case AVCaptureVideoOrientationLandscapeLeft:
			angle = M_PI_2;
			break;
		default:
			break;
	}
    
	return angle;
}

- (CGAffineTransform)transformFromCurrentVideoOrientationToOrientation:(AVCaptureVideoOrientation)orientation
{
	CGAffineTransform transform = CGAffineTransformIdentity;
    
	// Calculate offsets from an arbitrary reference orientation (portrait)
	CGFloat orientationAngleOffset      = [self angleOffsetFromPortraitOrientationToOrientation:orientation];
	CGFloat videoOrientationAngleOffset = [self angleOffsetFromPortraitOrientationToOrientation:self.videoOrientation];
	
	// Find the difference in angle between the passed in orientation and the current video orientation
	CGFloat angleOffset = orientationAngleOffset - videoOrientationAngleOffset;
	transform = CGAffineTransformMakeRotation(angleOffset);
	
	return transform;
}

- (CGImageRef)cgImageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer // Create a CGImageRef from sample buffer data
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    return [self cgImageFromImageBuffer:imageBuffer];
}

- (CGImageRef)cgImageFromImageBuffer:(CVImageBufferRef) imageBuffer // Create a CGImageRef from sample buffer data
{
    CVPixelBufferLockBaseAddress(imageBuffer,0);        // Lock the image buffer
    
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);   // Get information of the image
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    _sampleWidth  = CVPixelBufferGetWidth(imageBuffer);
    _sampleHeight = CVPixelBufferGetHeight(imageBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, _sampleWidth, _sampleHeight, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef newImage = CGBitmapContextCreateImage(newContext);
    CGContextRelease(newContext);
    
    CGColorSpaceRelease(colorSpace);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    return newImage;
}

- (CMSampleBufferRef)getSampleBufferUsingCIByCGInput:(CGImageRef)imageRef andProvidedSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    CIImage *theCoreImage = [CIImage imageWithCGImage:imageRef];
    
    CFDictionaryRef empty; // empty value for attr value.
    CFMutableDictionaryRef attrs;
    empty = CFDictionaryCreate(kCFAllocatorDefault, // our empty IOSurface properties dictionary
                               NULL,
                               NULL,
                               0,
                               &kCFTypeDictionaryKeyCallBacks,
                               &kCFTypeDictionaryValueCallBacks);
    attrs = CFDictionaryCreateMutable(kCFAllocatorDefault,
                                      1,
                                      &kCFTypeDictionaryKeyCallBacks,
                                      &kCFTypeDictionaryValueCallBacks);
    
    CFDictionarySetValue(attrs,
                         kCVPixelBufferIOSurfacePropertiesKey,
                         empty);
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    
    CVPixelBufferRef pixelBuffer;
    OSStatus err = CVPixelBufferCreate(kCFAllocatorSystemDefault, (size_t)theCoreImage.extent.size.width, (size_t)theCoreImage.extent.size.height, kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef) options, &pixelBuffer);
    if(err)
        NSLog(@"视频失败:CVPixelBufferCreate");
    
    CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
    
    CIContext *ciContext = [CIContext contextWithOptions: nil];
    [ciContext render:theCoreImage toCVPixelBuffer:pixelBuffer];
    
    CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
    CMSampleTimingInfo sampleTime = {
        .duration = CMSampleBufferGetDuration(sampleBuffer),
        .presentationTimeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer),
        .decodeTimeStamp = CMSampleBufferGetDecodeTimeStamp(sampleBuffer)
    };
    CMVideoFormatDescriptionRef videoInfo = NULL;
    CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer, &videoInfo);
    CMSampleBufferRef oBuf;
    err = CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer, true, NULL, NULL, videoInfo, &sampleTime, &sampleBuffer);
    if(err)
        NSLog(@"视频失败:getSampleBufferUsingCIByCGInput");
    CVPixelBufferRelease(pixelBuffer);
    CFRelease(videoInfo);
    return oBuf;
}

- (void)cutSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    //return if invalid sample buffer
    if (!CMSampleBufferIsValid(sampleBuffer)) {
        return;
    }
    
    
    //Get CG Image from sample buffer
    CGImageRef fromImage = [self cgImageFromSampleBuffer:sampleBuffer];
    if(!fromImage || (fromImage == NULL)){
        return;
    }
    
    CGRect r;
    size_t n;
    if(_sampleWidth<_sampleHeight){
        n = _sampleWidth;
        r = CGRectMake(0, (_sampleHeight-_sampleWidth)/2,  n, n);
    }
    else{
        n = _sampleHeight;
        r = CGRectMake((_sampleWidth-_sampleHeight)/2, 0, n, n);
    }
    CGImageRef toImage = CGImageCreateWithImageInRect(fromImage,r);
    
    
    //Convert back in CMSamplbuffer
//    sampleBuffer = [self getSampleBufferUsingCIByCGInput:toImage andProvidedSampleBuffer:sampleBuffer];
    [self getSampleBufferUsingCIByCGInput:toImage andProvidedSampleBuffer:sampleBuffer];
    
    //Release data if needed
    CGImageRelease(fromImage);
    CGImageRelease(toImage);
}


- (CVPixelBufferRef)CVPixelBufferRefFromUiImage:(CGImageRef)image{
    
    size_t height = CGImageGetHeight(image);
    size_t width = CGImageGetWidth(image);
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey, nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options, &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, width, height, 8, 4*width, rgbColorSpace, kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

- (CVPixelBufferRef)cutPixelBuffer:(CMSampleBufferRef)sampleBuffer{
    //return if invalid sample buffer
    if (!CMSampleBufferIsValid(sampleBuffer)){
        return NULL;
    }
    
    //Get CG Image from sample buffer
    CGImageRef fromImage = [self cgImageFromSampleBuffer:sampleBuffer];
    if(!fromImage || (fromImage == NULL)){
        return NULL;
    }
    
    CGRect r;
    size_t n;
    if(_sampleWidth<_sampleHeight){
        n = _sampleWidth;
        r = CGRectMake(0, (_sampleHeight-_sampleWidth)/2,  n, n);
    }
    else{
        n = _sampleHeight;
        r = CGRectMake((_sampleWidth-_sampleHeight)/2, 0, n, n);
    }
    CGImageRef toImage = CGImageCreateWithImageInRect(fromImage,r);
    
    //Convert back in CMSamplbuffer
    CVPixelBufferRef pxbuffer = [self CVPixelBufferRefFromUiImage:toImage];
    
    CMSampleTimingInfo sampleTime = {
        .duration = CMSampleBufferGetDuration(sampleBuffer),
        .presentationTimeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer),
        .decodeTimeStamp = CMSampleBufferGetDecodeTimeStamp(sampleBuffer)
    };
    CMVideoFormatDescriptionRef videoInfo = NULL;
    CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, pxbuffer, &videoInfo);
    
    
    OSStatus err = CMSampleBufferCreateForImageBuffer( kCFAllocatorDefault, pxbuffer, true, NULL, NULL, videoInfo, &sampleTime, &sampleBuffer);
    if(err)
        NSLog(@"失败：cutPixelBuffer");
    
    //Release data if needed
    CGImageRelease(fromImage);
    CGImageRelease(toImage);
    return pxbuffer;
}

-(void)clearTempFile{
    [[NSFileManager defaultManager] removeItemAtPath:outputFileName error:nil];
    for(int i=0;i<[outputImageFiles count];i++){
        [[NSFileManager defaultManager] removeItemAtPath:[outputImageFiles objectAtIndex:i] error:nil];
    }
}

@end
