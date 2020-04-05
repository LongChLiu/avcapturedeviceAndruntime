//
//  VideoCapturerParam.m
//  AVCaptureDemo
//
//  Created by 刘隆昌 on 2020/4/1.
//  Copyright © 2020 刘隆昌. All rights reserved.
//

#import "VideoVapturer.h"
#import <UIKit/UIKit.h>


@implementation VideoCapturerParam

-(instancetype)init{
    self = [super init];
    if (self) {
        _devicePosition = AVCaptureDevicePositionFront;
        _sessionPreset = AVCaptureSessionPreset1280x720;
        _frameRate = 15;
        _videoOrientation = AVCaptureVideoOrientationPortrait;
        
        switch ([UIDevice currentDevice].orientation) {
            case UIDeviceOrientationPortrait:
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                break;
            case UIDeviceOrientationLandscapeRight:
                break;
            case UIDeviceOrientationLandscapeLeft:
                break;
            default:
                break;
        }
    }
    return self;
}

@end


@interface VideoVapturer()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCapturePhotoCaptureDelegate,CAAnimationDelegate>
{
    AVCaptureDeviceInput * _newInput;
}

//采集会话
@property(nonatomic,strong)AVCaptureSession* captureSession;
//采集输入设备 也就是摄像头
@property(nonatomic,strong)AVCaptureDeviceInput* captureDeviceInput;
//采集输出
@property(nonatomic,strong)AVCaptureVideoDataOutput* captureVideoDataOutput;
//预览图层，把这个图层放在View上就能播放
@property(nonatomic,strong)AVCaptureVideoPreviewLayer* videoPreviewLayer;
//输出连接
@property(nonatomic,strong)AVCaptureConnection* captureConnection;
//是否已经在采集
@property(nonatomic,assign)BOOL isCapturing;


@end

@implementation VideoVapturer

-(void)dealloc{
    NSLog(@"___%s___",__func__);
}

-(instancetype)initWithCaptureParam:(VideoCapturerParam*)param error:(NSError* _Nullable __autoreleasing* _Nullable)error{
    if (self = [super init]) {
        NSError* errorMessage = nil;
        self.capturerParam = param;
        /*设置输入设备*//*获取所有摄像头*/
        AVCaptureDeviceDiscoverySession * _Nonnull cameras = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
        NSArray* captureDeviceArray = [cameras.devices filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"position == %d",_capturerParam.devicePosition]];
        
        if (captureDeviceArray.count == 0) {
            errorMessage = [self throw_errorWithDomain:@"VideoCapture:: Get Camera Failed!"];
            return nil;
        }
        
        //转化为输入设备
        AVCaptureDevice* camera = captureDeviceArray.firstObject;
        self.captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:camera error:&errorMessage];
        if (errorMessage) {
            errorMessage = [self throw_errorWithDomain:@"VideoCapture: AVCaptureDeviceInput init error!"];
            return nil;
        }
        
        
        
        //设置输出设备 //设置视频输出
        self.captureVideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        NSDictionary* videoSetting = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange],kCVPixelBufferPixelFormatTypeKey, nil];
        //
        [self.captureVideoDataOutput setVideoSettings:videoSetting];
        
        
        //设置输出串行队列和回调
        dispatch_queue_t outputQueue = dispatch_queue_create("VideoCaptureOutputQueue", DISPATCH_QUEUE_SERIAL);
        //设置代理
        [self.captureVideoDataOutput setSampleBufferDelegate:self queue:outputQueue];
        //丢弃延迟的帧
        self.captureVideoDataOutput.alwaysDiscardsLateVideoFrames = YES;
        
        
        //初始化会话
        self.captureSession = [[AVCaptureSession alloc] init];
        self.captureSession.usesApplicationAudioSession = NO;
        
        //添加输入设备到会话
        if ([self.captureSession canAddInput:self.captureDeviceInput]) {
            [self.captureSession addInput:self.captureDeviceInput];
        }else{
            [self throw_errorWithDomain:@"Video"];
            return nil;
        }
        
        //添加输出设备到会话
        if ([self.captureSession canAddOutput:self.captureVideoDataOutput]) {
            [self.captureSession addOutput:self.captureVideoDataOutput];
        }else{
            [self throw_errorWithDomain:@"VideoCapture: Add captureVideoDataOutput Failed!"];
            return nil;
        }
        
        
        
        //设置分辨率
        if ([self.captureSession canSetSessionPreset:self.capturerParam.sessionPreset]) {
            self.captureSession.sessionPreset = self.capturerParam.sessionPreset;
        }
        
        //初始化连接
        self.captureConnection = [self.captureVideoDataOutput connectionWithMediaType:AVMediaTypeVideo];
        
        //设置摄像头镜像，不设置的话前置摄像头采集出来的图像是反转的
        if (self.capturerParam.devicePosition == AVCaptureDevicePositionFront && self.captureConnection.supportsVideoMirroring) {
            self.captureConnection.videoMirrored = YES;
        }
        
        
        self.captureConnection.videoOrientation = self.capturerParam.videoOrientation;
        
        self.videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
        self.videoPreviewLayer.connection.videoOrientation = self.capturerParam.videoOrientation;
        self.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        
        if (error) {
            *error = errorMessage;
        }
        
        //设置帧率
        [self adjustFrameRate:self.capturerParam.frameRate];
    }
    return  self;
}

//开始采集
-(NSError*)startCapture{
    if (self.isCapturing) {
        return [self throw_errorWithDomain:@"VideoCapture: startCapture failed: is capturing"];
    }
    
    //摄像头权限判断
    AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (videoAuthStatus != AVAuthorizationStatusAuthorized) {
        return [self throw_errorWithDomain:@"VideoCapture:: Camera Authorizate failed!"];
    }
    
    [self.captureSession startRunning];
    self.isCapturing = YES;
    LOGT(@"开始采集视频");
    
    return nil;
}


//停止采集
-(NSError*)stopCapture{
    if (!self.isCapturing) {
        return [self throw_errorWithDomain:@"VideoCapture: stop capture failed! is not capturing"];
    }
    [self.captureSession stopRunning];
    self.isCapturing = NO;
    LOGT(@"停止视频采集");
    return nil;
}


//设置帧率
-(NSError*)adjustFrameRate:(NSInteger)frameRate{
    NSError* error = nil;
    AVFrameRateRange* frameRateRange = [self.captureDeviceInput.device.activeFormat.videoSupportedFrameRateRanges objectAtIndex:0];
    NSLog(@"帧率设置范围: min: %f , max: %f", frameRateRange.minFrameRate,frameRateRange.maxFrameRate);
    
    if (frameRate > frameRateRange.maxFrameRate || frameRate < frameRateRange.minFrameRate) {
        return [self throw_errorWithDomain:@"VideoCapture: Set FrameRate failed: out of rang"];
    }
    
    [self.captureDeviceInput.device lockForConfiguration:&error];
    self.captureDeviceInput.device.activeVideoMinFrameDuration = CMTimeMake(1, (int)frameRate);
    self.captureDeviceInput.device.activeVideoMaxFrameDuration = CMTimeMake(1, (int)frameRate);
    [self.captureDeviceInput.device unlockForConfiguration];
    return error;
}


/*摄像头翻转*/
-(NSError*)reverseCamera{
    //获取所有摄像头
    AVCaptureDeviceDiscoverySession * _Nonnull cameras = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position: AVCaptureDevicePositionUnspecified];//AVCaptureDevicePositionFront & AVCaptureDevicePositionBack
    
    //获取当前摄像头方向
    AVCaptureDevicePosition currentPosition = self.captureDeviceInput.device.position;
    AVCaptureDevicePosition toPosition = AVCaptureDevicePositionUnspecified;
    
    if (currentPosition == AVCaptureDevicePositionBack || currentPosition == AVCaptureDevicePositionUnspecified) {
        toPosition = AVCaptureDevicePositionFront;
    }else{
        toPosition = AVCaptureDevicePositionBack;
    }
        
    NSArray* captureDeviceArray = [cameras.devices filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"position == %d",toPosition]];
    
    if (captureDeviceArray.count == 0) {
        return [self throw_errorWithDomain:@"VideoCapture: reverseCamera failed! get new  camera failed!"];
    }
    
    NSError* error = nil;
    //添加翻转页面
    CATransition *animation = [CATransition animation];
    animation.duration = 1.0;
    animation.delegate = self;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = @"oglFlip";
    
    AVCaptureDevice *camera = captureDeviceArray.firstObject;
    _newInput = [AVCaptureDeviceInput deviceInputWithDevice:camera error:&error];
    
    animation.subtype = kCATransitionFromRight;
    [self.videoPreviewLayer addAnimation:animation forKey:nil];
    /*在翻转动画时机修改输入设备*/
    
    //重新获取连接并设置方向
    self.captureConnection = [self.captureVideoDataOutput connectionWithMediaType:AVMediaTypeVideo];
    //设置摄像头镜像 不设置的话前置摄像头采集出来的图像是反转的
    if (toPosition == AVCaptureDevicePositionFront && self.captureConnection.supportsVideoMirroring) {
        self.captureConnection.videoMirrored = YES;
    }
    self.captureConnection.videoOrientation = self.capturerParam.videoOrientation;
    return nil;
}

-(void)animationDidStart:(CAAnimation *)anim{//修改输入设备
    [self.captureSession beginConfiguration];
    [self.captureSession removeInput:self.captureDeviceInput];
    if ([self.captureSession canAddInput:self->_newInput]) {
        [self.captureSession addInput:self->_newInput];
        self.captureDeviceInput = self->_newInput;
    }
    [self.captureSession commitConfiguration];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{}


//修改分辨率
-(void)changeSessionPreset:(AVCaptureSessionPreset)sessionPreset{
    if (self.capturerParam.sessionPreset == sessionPreset) {
        return;
    }    
    self.capturerParam.sessionPreset = sessionPreset;
    if ([self.captureSession canSetSessionPreset:self.capturerParam.sessionPreset]) {
        [self.captureSession setSessionPreset:self.capturerParam.sessionPreset];
        NSLog(@"%@",LOGT(@"分辨率切换成功"));
    }
}

#pragma mark ------ AVCaptureVideoDataOutputSampleBufferDelegate
/*
 摄像头采集数据回调
 @param output 输出设备
 @param sampleBuffer 帧缓存数据，描述当前帧数据信息
 @param connection 连接
 */
-(void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
    if ([self.delegate respondsToSelector:@selector(videoCaptureOutputDataCallBack:)]) {
        [self.delegate videoCaptureOutputDataCallBack:sampleBuffer];
    }
}



-(NSError*)throw_errorWithDomain:(NSString*)domain{
    NSLog(@"%@",domain);
    return [NSError errorWithDomain:domain code:1 userInfo:nil];
}


@end






