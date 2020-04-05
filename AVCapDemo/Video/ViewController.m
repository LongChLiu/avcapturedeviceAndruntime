//
//  ViewController.m
//  AVCapDemo
//
//  Created by 刘隆昌 on 2020/4/4.
//  Copyright © 2020 刘隆昌. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "CaptureVC.h"


@interface ViewController ()

@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton* beginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [beginBtn setTitle:@"开始采集" forState:UIControlStateNormal];
    beginBtn.frame = CGRectMake(0, 0, 100, 40);
    beginBtn.center = CGPointMake(CGRectGetWidth(self.view.bounds)/2, CGRectGetHeight(self.view.bounds)/2);
    [beginBtn addTarget:self action:@selector(startCapture:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:beginBtn];
    [beginBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

-(void)startCapture:(UIButton*)btn{
    //查看摄像头权限
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusAuthorized) {
        //已经授权
        CaptureVC *captureVC = [[CaptureVC alloc] init];
        [self presentViewController:captureVC animated:YES completion:nil];
    }else{
        NSLog(@"未获取摄像头权限");
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            
        }];
    }
    
}





@end
