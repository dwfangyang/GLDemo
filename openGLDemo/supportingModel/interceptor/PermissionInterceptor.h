//
//  PermissionInterceptor.h
//  openGLDemo
//
//  Created by 方阳 on 2017/6/3.
//  Copyright © 2017年 dw_fangyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSUInteger,PermissionType)
{
    PermissionCamera = 0x1,
    PermissionAudio = 0x2,
    PermissionAlbum = 0x4,
};

@interface PermissionInterceptor : NSObject

+ (instancetype)sharedInterceptor;

- (BOOL)requestPermission:(PermissionType)type,...;

@end
