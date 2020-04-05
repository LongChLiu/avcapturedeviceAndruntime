//
//  VideoCapturerParam.h
//  AVCaptureDemo
//
//  Created by 刘隆昌 on 2020/4/1.
//  Copyright © 2020 刘隆昌. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN


@protocol VideoCaptureDelegate<NSObject>

/*
 摄像头采集数据输出回调
 @param sampleBuffer 采集的数据
 */
-(void)videoCaptureOutputDataCallBack:(CMSampleBufferRef)sampleBuffer;


@end


@interface VideoCapturerParam : NSObject

/*摄像头位置 默认为前置摄像头 AVCaptureDevicePositonFront*/
@property(nonatomic,assign)AVCaptureDevicePosition devicePosition;
/*视频分辨率 默认AVCaptureSessionPreset1280x720*/
@property(nonatomic,assign)AVCaptureSessionPreset sessionPreset;
/*帧 单位为帧/秒，默认为15帧/秒*/
@property(nonatomic,assign)NSInteger frameRate;
/*摄像头方向 默认为当前手机屏幕方向*/
@property(nonatomic,assign)AVCaptureVideoOrientation videoOrientation;

@end





@interface VideoVapturer : NSObject


@property(nonatomic,weak)id<VideoCaptureDelegate>delegate;
/*预览图层，把这个图层加在view上并且为这个图层设置frame就能播放*/
@property(nonatomic,strong,readonly)AVCaptureVideoPreviewLayer* videoPreviewLayer;
/*视频采集参数*/
@property(nonatomic,strong)VideoCapturerParam *capturerParam;


-(instancetype)initWithCaptureParam:(VideoCapturerParam*)param error:(NSError* _Nullable __autoreleasing* _Nullable)error;


//开始视频采集
-(NSError*)startCapture;
//停止视频采集
-(NSError*)stopCapture;
//动态调整帧率
-(NSError*)adjustFrameRate:(NSInteger)frameRate;
//翻转摄像头
-(NSError*)reverseCamera;
//修改视频分辨率
-(void)changeSessionPreset:(AVCaptureSessionPreset)sessionPreset;


@end

NS_ASSUME_NONNULL_END
