//
//  DBResultSet.m
//  openGLDemo
//
//  Created by 方阳 on 2017/7/20.
//  Copyright © 2017年 dw_fangyang. All rights reserved.
//

#import "DBResultSet.h"

@interface DBResultSet()

@property (nonatomic,assign) sqlite3_stmt* stmt;

@end

@implementation DBResultSet

- (instancetype)initWithStatement:(sqlite3_stmt*)stmt;
{
    if( self = [super init] )
    {
        _stmt = stmt;
    }
    return self;
}

- (BOOL)next;
{
    int ret = sqlite3_step(self.stmt);
    if( ret == SQLITE_OK )
    {
        return YES;
    }
    if( ret != SQLITE_ROW )
    {
        sqlite3_reset(self.stmt);
        self.stmt = nil;
    }
    return (ret == SQLITE_ROW);
}

- (id)valueForColumn:(int)idx
{
    int type = sqlite3_column_type(self.stmt, idx);
    if( type == SQLITE_INTEGER )
    {
        int64_t ret = sqlite3_column_int64(self.stmt, idx);
        return @(ret);
    }
    else if( type == SQLITE_FLOAT )
    {
        double ret = sqlite3_column_double(self.stmt, idx);
        return @(ret);
    }
    else if( type == SQLITE_BLOB )
    {
        int datasize = sqlite3_column_bytes(self.stmt, idx);
        const char* data = sqlite3_column_blob(self.stmt, idx);
        return [NSData dataWithBytes:data length:datasize];
    }
    else
    {
        const char* str = (const char*)sqlite3_column_text(self.stmt, idx);
        return [NSString stringWithUTF8String:str];
    }
}
@end
