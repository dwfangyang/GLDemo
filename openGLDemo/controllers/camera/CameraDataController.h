//
//  CameraDataController.h
//  openGLDemo
//
//  Created by 方阳 on 17/3/9.
//  Copyright © 2017年 dw_fangyang. All rights reserved.
//

#import "dataController.h"
#import <AVFoundation/AVFoundation.h>
#import "videoCapturer.h"
#import "VideoEncoder.h"
#import "audioCapturer.h"

@class GLSimplestImageView;
@interface CameraDataController : dataController<videoCapturerDelegate,VideoEncoderDelegate,AudioCapturerSampleDelegate>

- (void)addDanmaku:(NSString*)danmaku;

- (void)switchCamera;

- (void)startCaptureWith:(GLSimplestImageView*)imgView;

- (void)rotateToOrientation:(AVCaptureVideoOrientation)orientation;

- (void)startEncodeVideoAndAudio;

- (void)stopEncodeVideoAndAudio;

@end
