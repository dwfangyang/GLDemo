//
//  DatabaseManager.h
//  openGLDemo
//
//  Created by 方阳 on 2017/7/19.
//  Copyright © 2017年 dw_fangyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DatabaseManager : NSObject

+ (instancetype)sharedManager;

- (void)openDataBase;

@end
