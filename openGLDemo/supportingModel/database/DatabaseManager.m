//
//  DatabaseManager.m
//  openGLDemo
//
//  Created by 方阳 on 2017/7/19.
//  Copyright © 2017年 dw_fangyang. All rights reserved.
//

#import "DatabaseManager.h"
#import "DbInstance.h"
#import "DBResultSet.h"

@implementation DatabaseManager

+ (instancetype)sharedManager
{
    static DatabaseManager* mgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mgr = [DatabaseManager new];
    });
    return mgr;
}

- (void)openDataBase;
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths objectAtIndex:0];
    NSString *dbPath = [documents stringByAppendingPathComponent:@"default.db"];
    
    DbInstance* db = [[DbInstance alloc] initWithDbfile:dbPath];
    BOOL b = [db openWithKey:@"default"];
    [db performSql:@"CREATE TABLE IF NOT EXISTS accounts (\
     account_no INTEGER PRIMARY KEY\
     NOT NULL,\
     balance    DECIMAL NOT NULL\
     DEFAULT 0\
     );"];
    [db performSql:@"CREATE TABLE IF NOT EXISTS account_changes(\
    account_no integer not null,\
    flag text not null,\
    amount decimal not null,\
    changed_at text not null\
    );"];
    [db performSql:@"INSERT INTO accounts (\
     account_no,\
     balance\
     )\
     VALUES (\
             100,\
             20100\
             );"];
    [db performSql:@"INSERT INTO accounts (\
    account_no,\
    balance\
    )\
    VALUES (\
    200,\
    10100\
    );"];
    [db performSql:@"INSERT INTO account_changes(account_no,flag,amount,changed_at)\
    values(100,'-',1000,datetime('now'));"];
    DBResultSet* set = [db performQuery:@"select * from accounts",@"a"];
    
    while( [set next] )
    {
        id a = [set valueForColumn:1];
        a = [set valueForColumn:0];
    }
}
@end
