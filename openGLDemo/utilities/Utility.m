//
//  Utility.m
//  openGLDemo
//
//  Created by 方阳 on 17/3/15.
//  Copyright © 2017年 dw_fangyang. All rights reserved.
//

#import "Utility.h"

@implementation Utility

#pragma mark api
+ (NSTimeInterval)curTimeStamp
{
    return [[NSDate date] timeIntervalSince1970];
}

+ (int32_t)fps
{
    return 30;
}
@end
