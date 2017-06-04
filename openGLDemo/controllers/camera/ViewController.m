//
//  ViewController.m
//  openGLDemo
//
//  Created by 方阳 on 16/9/4.
//  Copyright © 2016年 dw_fangyang. All rights reserved.
//

#import "ViewController.h"
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import "GLSimplestImageView.h"
#import <QuartzCore/QuartzCore.h>
#import "CameraDataController.h"
#import "offScreenContext.h"
#import "RecordButton.h"
#import "DanmakuInputView.h"
#import <GLKit/GLKit.h>
#import "PermissionInterceptor.h"

#import "VRPlayerViewController.h"
#import "AlbumVideoPickerController.h"

@interface ViewController ()

@property (nonatomic,strong) GLSimplestImageView* simpleView;
@property (nonatomic,strong) CameraDataController* datacontroller;
@property (nonatomic,strong) RecordButton* btnRecord;

@property (nonatomic,assign) BOOL isRecording;

@property (nonatomic,strong) UIButton* btnDanmaku;
@property (nonatomic,strong) DanmakuInputView* inputView;

@property (nonatomic,strong) UIButton* btnSwitchCamera;

@property (nonatomic,strong) UIButton* btnVR;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configNotice];
    
    CGRect frame = [UIScreen mainScreen].bounds;
    
    _simpleView = [[GLSimplestImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_simpleView];
    _simpleView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    
    _btnRecord = [[RecordButton alloc] initWithFrame:CGRectMake(frame.size.width/2-40, frame.size.height- 68, 80, 60)];
    [self.view addSubview:_btnRecord];
    
    _btnRecord.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    [_btnRecord addTarget:self action:@selector(recordBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self configDanmakuBtn];
    
    _btnSwitchCamera = [[UIButton alloc] initWithFrame:CGRectMake(10, frame.size.height-56, 36, 36)];
    [self.view addSubview:_btnSwitchCamera];
    //[_btnSwitchCamera setTitle:@"切换相机" forState:UIControlStateNormal];
    [_btnSwitchCamera setImage:[UIImage imageNamed:@"camera_switch"] forState:UIControlStateNormal];
    //[_btnSwitchCamera setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1] forState:UIControlStateNormal];
    [_btnSwitchCamera addTarget:self action:@selector(switchCameraBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    _btnSwitchCamera.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin;
    
    _btnVR = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width-50, frame.size.height-100, 30 , 30)];
    [self.view addSubview:_btnVR];
    _btnVR.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
    [_btnVR addTarget:self action:@selector(vrBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_btnVR.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_btnVR setTitle:@"VR" forState:UIControlStateNormal];
    [_btnVR setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
}

- (void)dealloc
{
    if( self.viewLoaded )
    {
        [self.btnRecord removeTarget:self action:@selector(recordBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnSwitchCamera removeTarget:self action:@selector(switchCameraBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)configDanmakuBtn;
{
    CGRect frame = [UIScreen mainScreen].bounds;
    _btnDanmaku = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width-46, frame.size.height-56, 36, 36)];
    //[_btnDanmaku setTitle:@"弹幕" forState:UIControlStateNormal];
    [_btnDanmaku setImage:[UIImage imageNamed:@"danmakuIcon"] forState:UIControlStateNormal];
    //[_btnDanmaku setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1] forState:UIControlStateNormal];
    [self.view addSubview:_btnDanmaku];
    _btnDanmaku.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
    [_btnDanmaku addTarget:self action:@selector(danmakuBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configDanmakuInputView;
{
    CGRect frame = [UIScreen mainScreen].bounds;
    _inputView = [[DanmakuInputView alloc] initWithFrame:CGRectMake(5, frame.size.height-60, frame.size.width-10, 40)];
    [self.view addSubview:_inputView];
    _inputView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    
    __weak __typeof(self) wself = self;
    self.inputView.danmakuBlock = ^(NSString* danmaku){
        [wself.datacontroller addDanmaku:danmaku];
    };
}

- (void)configNotice;
{
    CGRect frame = [UIScreen mainScreen].bounds;
    AVAuthorizationStatus stat = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if( stat == AVAuthorizationStatusDenied )
    {
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width/2-160, frame.size.height/2-20, 320, 40)];
        [self.view addSubview:label];
        label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [label setTextAlignment:NSTextAlignmentCenter];
        label.text = @"此app需要您到设置中开启相机权限";
        return;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark touchevent
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    [super touchesBegan:touches withEvent:event];
}

#pragma mark rotation
- (BOOL)shouldAutorotate
{
    return !self.isRecording;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskLandscapeRight|UIInterfaceOrientationMaskLandscapeLeft;
}

#pragma mark view event
- (void)viewDidLayoutSubviews
{
    self.simpleView.frame = self.view.bounds;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if( !self.datacontroller )
    {
        self.datacontroller = [CameraDataController new];
        [[offScreenContext sharedContext] getCircleImageForSize:CGSizeMake(60, 60) Radius:30 Color:[UIColor redColor] withCompletion:^(UIImage *img) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_btnRecord setBackgroundImage:img forState:UIControlStateNormal];
            });
        }];
        [self.datacontroller startCaptureWith:self.simpleView];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
//    self.simpleView.frame = CGRectMake(0, 0, size.width, size.height);
//    self.view.frame = CGRectMake(0, 0, size.width, size.height);
    UIDeviceOrientation orientation =  [UIDevice currentDevice].orientation;
    if( orientation != UIDeviceOrientationPortrait )
    {
        [self.datacontroller rotateToOrientation:orientation== UIDeviceOrientationLandscapeLeft?  AVCaptureVideoOrientationLandscapeRight:AVCaptureVideoOrientationLandscapeLeft];
    }
    else
    {
        [self.datacontroller rotateToOrientation:AVCaptureVideoOrientationPortrait];
    }
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

#pragma mark IBAction
- (void)recordBtnTapped:(UIButton*)btn
{
    if( !self.isRecording )
    {
        if( ![[PermissionInterceptor sharedInterceptor] requestPermission:PermissionCamera,PermissionAlbum,PermissionAudio] )
        {
            return;
        }
        [self.datacontroller startEncodeVideoAndAudio];
        [self.btnRecord startRecording];
    }
    else
    {
        [self.datacontroller stopEncodeVideoAndAudio];
        [self.btnRecord stopRecording];
    }
    self.isRecording = !self.isRecording;
}

- (void)danmakuBtnTapped:(UIButton*)btn;
{
    if( !self.inputView )
    {
        [self configDanmakuInputView];
    }
    self.inputView.hidden = NO;
    [self.inputView becomeFirstResponder];
}

- (void)switchCameraBtnTapped:(UIButton*)btn;
{
    [self.datacontroller switchCamera];
}

- (void)vrBtnTapped:(UIButton*)btn;
{
    if( !self.presentedViewController )
    {
        [self.datacontroller stopCapture];
        [self.datacontroller stopEncodeVideoAndAudio];
        [self.btnRecord stopRecording];
        
        AlbumVideoPickerController* controller = [AlbumVideoPickerController new];
        [self presentViewController:controller animated:YES completion:nil];
        
        __weak UIViewController* ctrl = controller;
        controller.videoPickedBlock = ^(NSURL* videoUrl){
            if( videoUrl )
            {
                VRPlayerViewController* vc = [VRPlayerViewController new];
                vc.videoUrl = videoUrl;
                vc.completion = ^{
                    [self.datacontroller startCaptureWith:self.simpleView];
                };
                [self presentViewController:vc animated:YES completion:nil];
            }
            else
            {
                [self.datacontroller startCaptureWith:self.simpleView];
                [ctrl dismissViewControllerAnimated:YES completion:nil];
            }
        };
    }
}
@end

