//
//  FMDBConnection.h
//  Project
//
//  Created by Adam on 11-11-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "FMDatabase.h"
#import "FMResultSet.h"
#import "UserObject.h"

@interface FMDBConnection : NSObject

+ (FMDBConnection *)instance;

@property (nonatomic, retain) FMDatabase *db;

- (void)setup;
- (BOOL)openDB;
- (BOOL)closeDB;

#pragma mark - user
- (void)insertAllUserObjectDB:(NSArray *)userList;
- (UserObject *)getUserByUserId:(NSString *)userId;
- (UserObject *)getUserInfoByVoipIdFromDB:(NSString*)userChatId;
- (NSMutableArray *)getUserByNameKeyword:(NSString *)keyword;
- (NSMutableArray *)getUserEmailByKeyword:(NSString *)keyword;
- (void)delUserTable;
- (void)updateUserObjectDB:(UserObject *)userInfo;

#pragma mark - update soft
- (void)insertSoftDB:(NSArray *)updateArray;
- (void)updateSoftDB:(NSArray *)updateArray;
- (int)getUpdateSoftDB:(NSString *)updatePromptDay;
- (void)delUpdateSoftDB;

@end
