//
//  DbInstance.m
//  openGLDemo
//
//  Created by 方阳 on 2017/7/19.
//  Copyright © 2017年 dw_fangyang. All rights reserved.
//

#import "DbInstance.h"
#import "DBResultSet.h"
#import <sqlite3.h>

@interface DbInstance()
@property (nonatomic,assign) sqlite3* database;
@property (nonatomic,strong) NSString* dbFilePath;
@property (nonatomic,strong) dispatch_queue_t operationQueue;
@end

@implementation DbInstance

- (instancetype)initWithDbfile:(NSString*)dbFilePath;
{
    if( self = [super init] )
    {
        _database = nil;
        _dbFilePath = dbFilePath;
        _operationQueue = dispatch_queue_create("com.yy.sqlite", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (BOOL)openWithKey:(NSString*)key;
{
    if( !self.dbFilePath || _database )
    {
        return NO;
    }

    int ret = sqlite3_open([self.dbFilePath fileSystemRepresentation], &_database);
    if( ret != SQLITE_OK )
    {
        _database = nil;
        return NO;
    }
    
//    if( key.length )
//    {
//        const char* keystr = [key UTF8String];
//        ret = sqlite3_key(self.database,keystr,(int)strlen(keystr));
//    }
    sqlite3_busy_timeout(self.database, 2000);
    return YES;
}

- (BOOL)close
{
    if( !self.database )
    {
        return YES;
    }
    int  rc;
    BOOL retry;
    BOOL triedFinalizingOpenStatements = NO;
    
    do {
        retry   = NO;
        rc      = sqlite3_close(self.database);
        if (SQLITE_BUSY == rc || SQLITE_LOCKED == rc) {
            if (!triedFinalizingOpenStatements) {
                triedFinalizingOpenStatements = YES;
                sqlite3_stmt *pStmt;
                while ((pStmt = sqlite3_next_stmt(self.database, nil)) !=0) {
                    NSLog(@"Closing leaked statement");
                    sqlite3_finalize(pStmt);
                    retry = YES;
                }
            }
        }
        else if (SQLITE_OK != rc) {
            NSLog(@"error closing!: %d", rc);
        }
    }
    while (retry);
    self.database = nil;
    return YES;
}

- (DBResultSet*)performQuery:(NSString*)sql, ...
{
    if( !self.database )
    {
        return nil;
    }
    sqlite3_stmt* stmt;
    
    int ret = sqlite3_prepare_v2(self.database, [sql UTF8String], -1, &stmt, NULL);
    if( ret != SQLITE_OK )
    {
        sqlite3_finalize(stmt);
        return nil;
    }
    
    va_list args;
    va_start(args, sql);
    int preparecount = sqlite3_bind_parameter_count(stmt);
    int count = 0;
    id arg = va_arg(args, id);
    while ( arg && count < preparecount ) {
        [self bindObject:arg toColumn:count inStatement:stmt];
        
        ++count;
        arg = va_arg(args, id);
    }
    va_end(args);
    
    if( count != preparecount )
    {
        sqlite3_finalize(stmt);
        return nil;
    }
    
    DBResultSet* rs = [[DBResultSet alloc] initWithStatement:stmt];
    return rs;
}

- (BOOL)performSql:(NSString*)sql,...;
{
    if( !self.database )
    {
        return NO;
    }
    sqlite3_stmt* stmt;
    
    int ret = sqlite3_prepare_v2(self.database, [sql UTF8String], -1, &stmt, NULL);
    if( ret != SQLITE_OK )
    {
        sqlite3_finalize(stmt);
        return NO;
    }
    
    va_list args;
    va_start(args, sql);
    va_end(args);
    int preparecount = sqlite3_bind_parameter_count(stmt);
    int count = 0;
    id arg = va_arg(args, id);
    while ( arg && count < preparecount ) {
        [self bindObject:arg toColumn:count inStatement:stmt];
        
        ++count;
        arg = va_arg(args, id);
    }
    
    if( count != preparecount )
    {
        sqlite3_finalize(stmt);
        return NO;
    }
    
    ret = sqlite3_step(stmt);
    sqlite3_finalize(stmt);
    return (ret == SQLITE_DONE || ret == SQLITE_OK);
}

#pragma mark private interface
- (void)bindObject:(id)obj toColumn:(int)idx inStatement:(sqlite3_stmt*)pStmt {
    
    if ((!obj) || ((NSNull *)obj == [NSNull null])) {
        sqlite3_bind_null(pStmt, idx);
    }
    
    // FIXME - someday check the return codes on these binds.
    else if ([obj isKindOfClass:[NSData class]]) {
        const void *bytes = [obj bytes];
        if (!bytes) {
            // it's an empty NSData object, aka [NSData data].
            // Don't pass a NULL pointer, or sqlite will bind a SQL null instead of a blob.
            bytes = "";
        }
        sqlite3_bind_blob(pStmt, idx, bytes, (int)[obj length], SQLITE_STATIC);
    }
    else if ([obj isKindOfClass:[NSDate class]]) {
//        if (self.hasDateFormatter)
//            sqlite3_bind_text(pStmt, idx, [[self stringFromDate:obj] UTF8String], -1, SQLITE_STATIC);
//        else
            sqlite3_bind_double(pStmt, idx, [obj timeIntervalSince1970]);
    }
    else if ([obj isKindOfClass:[NSNumber class]]) {
        
        if (strcmp([obj objCType], @encode(char)) == 0) {
            sqlite3_bind_int(pStmt, idx, [obj charValue]);
        }
        else if (strcmp([obj objCType], @encode(unsigned char)) == 0) {
            sqlite3_bind_int(pStmt, idx, [obj unsignedCharValue]);
        }
        else if (strcmp([obj objCType], @encode(short)) == 0) {
            sqlite3_bind_int(pStmt, idx, [obj shortValue]);
        }
        else if (strcmp([obj objCType], @encode(unsigned short)) == 0) {
            sqlite3_bind_int(pStmt, idx, [obj unsignedShortValue]);
        }
        else if (strcmp([obj objCType], @encode(int)) == 0) {
            sqlite3_bind_int(pStmt, idx, [obj intValue]);
        }
        else if (strcmp([obj objCType], @encode(unsigned int)) == 0) {
            sqlite3_bind_int64(pStmt, idx, (long long)[obj unsignedIntValue]);
        }
        else if (strcmp([obj objCType], @encode(long)) == 0) {
            sqlite3_bind_int64(pStmt, idx, [obj longValue]);
        }
        else if (strcmp([obj objCType], @encode(unsigned long)) == 0) {
            sqlite3_bind_int64(pStmt, idx, (long long)[obj unsignedLongValue]);
        }
        else if (strcmp([obj objCType], @encode(long long)) == 0) {
            sqlite3_bind_int64(pStmt, idx, [obj longLongValue]);
        }
        else if (strcmp([obj objCType], @encode(unsigned long long)) == 0) {
            sqlite3_bind_int64(pStmt, idx, (long long)[obj unsignedLongLongValue]);
        }
        else if (strcmp([obj objCType], @encode(float)) == 0) {
            sqlite3_bind_double(pStmt, idx, [obj floatValue]);
        }
        else if (strcmp([obj objCType], @encode(double)) == 0) {
            sqlite3_bind_double(pStmt, idx, [obj doubleValue]);
        }
        else if (strcmp([obj objCType], @encode(BOOL)) == 0) {
            sqlite3_bind_int(pStmt, idx, ([obj boolValue] ? 1 : 0));
        }
        else {
            sqlite3_bind_text(pStmt, idx, [[obj description] UTF8String], -1, SQLITE_STATIC);
        }
    }
    else {
        sqlite3_bind_text(pStmt, idx, [[obj description] UTF8String], -1, SQLITE_STATIC);
    }
}

- (void)dealloc
{
    if( self.database )
    {
        [self close];
    }
    if( self.operationQueue )
    {
        self.operationQueue = nil;
    }
}
@end
