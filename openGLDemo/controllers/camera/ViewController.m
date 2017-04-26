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

#import "VRPlayerViewController.h"

@interface ViewController ()

@property (nonatomic,strong) GLSimplestImageView* simpleView;
@property (nonatomic,strong) CameraDataController* datacontroller;
@property (nonatomic,strong) RecordButton* btnRecord;

@property (nonatomic,assign) BOOL isRecording;

@property (nonatomic,strong) UIButton* btnDanmaku;
@property (nonatomic,strong) DanmakuInputView* inputView;

@property (nonatomic,strong) UIButton* btnSwitchCamera;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _simpleView = [[GLSimplestImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_simpleView];
    _simpleView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    
    /*UIImageView* imgview = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    imgview.image = [UIImage imageNamed:@"c2"];
    [self.view addSubview:imgview];*/
    
    CGRect frame = [UIScreen mainScreen].bounds;
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
    return UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskLandscapeRight;
}

#pragma mark view event
- (void)viewDidLayoutSubviews
{
    self.simpleView.frame = self.view.bounds;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //return;
    if( !self.datacontroller )
    {
        self.datacontroller = [CameraDataController new];
        [self.datacontroller startCaptureWith:self.simpleView];
        [[offScreenContext sharedContext] getCircleImageForSize:CGSizeMake(60, 60) Radius:30 Color:[UIColor redColor] withCompletion:^(UIImage *img) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_btnRecord setBackgroundImage:img forState:UIControlStateNormal];
            });
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /*VRPlayerViewController* vc = [VRPlayerViewController new];
    [self presentViewController:vc animated:YES completion:nil];*/
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
//    self.simpleView.frame = CGRectMake(0, 0, size.width, size.height);
//    self.view.frame = CGRectMake(0, 0, size.width, size.height);
    if( size.width > size.height )
    {
        [self.datacontroller rotateToOrientation:AVCaptureVideoOrientationLandscapeRight];
    }
    else
    {
        [self.datacontroller rotateToOrientation:AVCaptureVideoOrientationPortrait];
    }
}

#pragma mark IBAction
- (void)recordBtnTapped:(UIButton*)btn
{
    if( !self.isRecording )
    {
        self.isRecording = YES;
        [self.datacontroller startEncodeVideoAndAudio];
        [self.btnRecord startRecording];
    }
    else
    {
        self.isRecording = NO;
        [self.datacontroller stopEncodeVideoAndAudio];
        [self.btnRecord stopRecording];
    }
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
@end

