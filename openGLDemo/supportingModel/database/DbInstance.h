//
//  DbInstance.h
//  openGLDemo
//
//  Created by 方阳 on 2017/7/19.
//  Copyright © 2017年 dw_fangyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBResultSet;
@interface DbInstance : NSObject

- (instancetype)initWithDbfile:(NSString*)dbFilePath;

- (BOOL)openWithKey:(NSString*)key;

- (BOOL)close;

- (DBResultSet*)performQuery:(NSString*)sql,...;

- (BOOL)performSql:(NSString*)sql,...;

@end
