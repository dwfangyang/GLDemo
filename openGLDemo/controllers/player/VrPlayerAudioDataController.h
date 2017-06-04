//
//  VrPlayerAudioDataController.h
//  openGLDemo
//
//  Created by 方阳 on 17/4/30.
//  Copyright © 2017年 dw_fangyang. All rights reserved.
//

#import "dataController.h"

@protocol VRPlayerAudioDelegate <NSObject>

- (CMSampleBufferRef)getNextAudioSampleBuffer;

@end

@interface VrPlayerAudioDataController : dataController

@property (nonatomic,weak,readonly) id<VRPlayerAudioDelegate> delegate;

- (instancetype)initWithDelegate:(__weak id<VRPlayerAudioDelegate>)delegate;

@end
