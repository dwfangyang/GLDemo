//
//  DBResultSet.h
//  openGLDemo
//
//  Created by 方阳 on 2017/7/20.
//  Copyright © 2017年 dw_fangyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DBResultSet : NSObject

- (instancetype)initWithStatement:(sqlite3_stmt*)stmt;

- (BOOL)next;

- (id)valueForColumn:(int)idx;

@end
