/*
 *  Copyright (c) 2013 The CCP project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a Beijing Speedtong Information Technology Co.,Ltd license
 *  that can be found in the LICENSE file in the root of the web site.
 *
 *                    http://www.cloopen.com
 *
 *  An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "ChatDBConnection.h"
#import "Statement.h"

static sqlite3*                     theDatabase = nil;

#define RESOURCE_DATABASE_NAME      @"appResource.db"
#define CHAT_DATABASE_NAME          @"chatConfigDB.db"

@implementation ChatDBConnection

+ (sqlite3*)openDatabase:(NSString *)dbFilename
{
    sqlite3* instance;
    NSString *documentsDirectory;
    
    documentsDirectory = [NSString stringWithFormat:@"%@/Library/Caches/", NSHomeDirectory()];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:dbFilename];
    
    if (sqlite3_open([path UTF8String], &instance) != SQLITE_OK)
	{
        sqlite3_close(instance);
        return nil;
    }
    return instance;
}

+ (sqlite3 *)getSharedDatabase
{
    // TODO 不同用户 切换数据库
    if (theDatabase == nil)
	{
        sqlite3_config(SQLITE_CONFIG_SERIALIZED);
        
        NSString *chatDataBaseName = [NSString stringWithFormat:@"%@_%@", [AppManager instance].userId, CHAT_DATABASE_NAME];

//        NSString *chatDataBaseName = CHAT_DATABASE_NAME;
        theDatabase = [self openDatabase:chatDataBaseName];
        if (theDatabase == nil)
		{
            [ChatDBConnection createEditableCopyOfDatabaseIfNeeded:true];
			theDatabase = [self openDatabase:chatDataBaseName];
        }
    }
    
    return theDatabase;
}

- (void)changeDBName:(NSString *)dbFilename
{
    NSString *documentsDirectory;
    NSError *error;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    documentsDirectory = [NSString stringWithFormat:@"%@/Library/Caches/", NSHomeDirectory()];
    
    NSString *old_filepath = [documentsDirectory stringByAppendingPathComponent:dbFilename];
    NSString *new_filename = [NSString stringWithFormat:@"%@%@", [AppManager instance].userId, CHAT_DATABASE_NAME];
    
    NSString *newPath = [[old_filepath stringByDeletingLastPathComponent] stringByAppendingPathComponent:new_filename];
    
    if ([fileManager moveItemAtPath:old_filepath toPath:newPath error:&error] != YES) {
        NSLog(@"change database name error: %@", [error localizedDescription]);
    } else {
        NSLog(@"change database name success !");
    }
    
    //显示文件目录的内容
    NSLog(@"Documentsdirectory: %@",
          [fileManager contentsOfDirectoryAtPath:documentsDirectory error:&error]);
}

const char *optimize_sql = "VACUUM; ANALYZE";

+ (void)closeDatabase
{
    if (theDatabase)
	{
        sqlite3_close(theDatabase);
    }
}

// Creates a writable copy of the bundled default database in the application Documents directory.
+ (void)createEditableCopyOfDatabaseIfNeeded:(BOOL)force
{
    // First, test for existence.
    BOOL success;
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString *documentsDirectory = [NSString stringWithFormat:@"%@/Library/Caches/", NSHomeDirectory()];
    
    NSString *chatDataBaseName = [NSString stringWithFormat:@"%@%@", [AppManager instance].userId, CHAT_DATABASE_NAME];
//    NSString *chatDataBaseName = CHAT_DATABASE_NAME;
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:chatDataBaseName];
    
    if (force)
	{
        [fileManager removeItemAtPath:writableDBPath error:&error];
    }
    
    // No exists any database file. Create new one.
    //
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success)
		return;
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:RESOURCE_DATABASE_NAME];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success)
	{
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}

+ (void)beginTransaction
{
    char *errmsg;
    int flag = sqlite3_exec(theDatabase, "BEGIN", NULL, NULL, &errmsg);
    if (SQLITE_OK != flag)
    {
        sqlite3_free(errmsg);
    }
}

+ (void)commitTransaction
{
    char *errmsg;
    int flag = sqlite3_exec(theDatabase, "COMMIT", NULL, NULL, &errmsg);
    if (SQLITE_OK != flag)
    {
        sqlite3_free(errmsg);
    }
}

+ (void)rollbackTransaction
{
	char *errmsg;
    sqlite3_exec(theDatabase, "ROLLBACK", NULL, NULL, &errmsg);
}

+ (Statement*)statementWithQuery:(const char *)sql
{
    Statement* stmt = [Statement statementWithDB:[self getSharedDatabase] query:sql];
    return stmt;
}

+ (void)alert
{
    //NSString *sqlite3err = [NSString stringWithUTF8String:sqlite3_errmsg(theDatabase)];
}
+ (long long) getLastInsertId
{
	return sqlite3_last_insert_rowid(theDatabase);
}
@end
