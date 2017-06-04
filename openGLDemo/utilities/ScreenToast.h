//
//  ScreenToast.h
//  openGLDemo
//
//  Created by 方阳 on 2017/5/10.
//  Copyright © 2017年 dw_fangyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScreenToast : NSObject

+ (instancetype)sharedInstance;

- (void)showToast:(NSString*)toast;

@end
