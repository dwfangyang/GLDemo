//
//  PermissionInterceptor.m
//  openGLDemo
//
//  Created by 方阳 on 2017/6/3.
//  Copyright © 2017年 dw_fangyang. All rights reserved.
//

#import <Photos/Photos.h>
#import "PermissionInterceptor.h"
#import "ScreenToast.h"

@implementation PermissionInterceptor

+ (instancetype)sharedInterceptor
{
    static PermissionInterceptor* interceptor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        interceptor = [PermissionInterceptor new];
    });
    return interceptor;
}

- (BOOL)requestPermission:(PermissionType)type,...
{
    BOOL permitted = NO;
    va_list vargs;
    va_start(vargs, type);
    PermissionType arg = type;
    while ( type ) {
        if( arg )
        {
            switch (arg) {
                case PermissionCamera:
                {
                    AVAuthorizationStatus stat = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
                    if( stat != AVAuthorizationStatusAuthorized )
                    {
                        permitted = NO;
                        [[ScreenToast sharedInstance] showToast:@"此操作需要相机权限"];
                    }
                    else
                    {
                        permitted = YES;
                    }
                }
                    break;
                case PermissionAudio:
                {
                    AVAuthorizationStatus stat = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
                    if( stat != AVAuthorizationStatusAuthorized )
                    {
                        permitted = NO;
                        [[ScreenToast sharedInstance] showToast:@"此操作需要麦克风权限"];
                    }
                    else
                    {
                        permitted = YES;
                    }
                }
                    break;
                case PermissionAlbum:
                {
                    PHAuthorizationStatus stat = [PHPhotoLibrary authorizationStatus];
                    if( stat != PHAuthorizationStatusAuthorized )
                    {
                        permitted = NO;
                        [[ScreenToast sharedInstance] showToast:@"此操作需要相册权限"];
                    }
                    else{
                        permitted = YES;
                    }
                }
                    break;
                    
                default:
                    break;
            }
            if( !permitted )
            {
                break;
            }
        }
        else
        {
            break;
        }
        arg = va_arg(vargs, PermissionType);
    }
    va_end(vargs);
    return permitted;
}

@end
