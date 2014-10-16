
#import "FMDBConnection.h"
#import "GlobalConstants.h"
#import "CommonMethod.h"
#import "AppManager.h"

// Business Object
#import "UserObject.h"

static FMDBConnection *instance = nil;

@implementation FMDBConnection

#pragma mark - singleton method

// 获取一个instance实例，如果有必要的话，实例化一个
+ (FMDBConnection *)instance {
    if (instance == nil) {
        instance = [[super allocWithZone:NULL] init];
    }
    
    return instance;
}

// 当第一次使用这个单例时，会调用这个init方法。
- (id)init
{
    self = [super init];
    
    if (self) {
        // 通常在这里做一些相关的初始化任务
        [self setup];
    }
    
    return self;
}

// 这个dealloc方法永远都不会被调用--因为在程序的生命周期内容，该单例一直都存在。（所以该方法可以不用实现）
- (void)dealloc
{
    
}

// 通过返回当前的instance实例，就能防止实例化一个新的对象。
+ (id)allocWithZone:(NSZone*)zone {
    return [self instance];
}

// 同样，不希望生成单例的多个拷贝。
- (id)copyWithZone:(NSZone *)zone {
    return self;
}

#pragma mark - init db
- (NSString *)documentsDirectory {
	return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
}

- (NSString *)getDBPath:(NSString *)dbFileName {
	NSString *docDir = [self documentsDirectory];
	NSString *dbPath = [docDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_V%@.sqlite", dbFileName, VERSION]];
	return dbPath;
}

- (void)setup {
    if (self.db == nil) {
        self.db = [FMDatabase databaseWithPath:[self getDBPath:PROJECT_DB_NAME]];
    }
    
    if ([self openDB]) {
        [self createTables];
    }
}

- (BOOL)openDB {
    return [self.db open];
}

- (BOOL)closeDB {
    return [self.db close];
}


- (void)createTables {
	
    BOOL res = NO;
    
    //-------------------------------user cache-----------------------------
    /*
     NSString *userId; //用户id
     NSString *userName; //中文名
     NSString *userNameEn; //英文名
     NSString *chatId; //
     NSString *customerId; //
     NSString *userImageUrl; //头像
     NSString *userTel;
     NSString *userEmail; //邮件
     NSString *userStatus; //
     NSString *userCode; //
     NSString *groupId; //
     NSString *userDept; // 部门
     NSString *userTitle; // 头衔
     NSString *userRole; // 角色
     int isFriend;
     int isDelete;
     int userGender;
     【function、channel、band】【email、LM. Email、based city、Tel、gender；P&G Service year】
     */
	NSString *createUserTableMsg = @"create table if not exists user (userId TEXT PRIMARY KEY, userName TEXT, userNameEn TEXT, chatId TEXT, customerId TEXT, userImageUrl TEXT, userTel TEXT, userEmail TEXT, userStatus TEXT, userCode TEXT, groupId TEXT, userDept TEXT, userTitle TEXT, userRole TEXT, isFriend int, isDelete int, userGender int, userCellphone TEXT, userBirthDay TEXT, superName TEXT, location TEXT, serviceYear TEXT, subordinateCount TEXT, band TEXT, superEmail TEXT, function TEXT, channel TEXT, channelId int)";
    
    res = [self.db executeUpdate:createUserTableMsg];
	if (!res) {
        DLog(@"error when creating user table");
    } else {
        DLog(@"success to creating user table");
    }
    
    //------------------------------------------------------------
    
    //--------------- updateSoftAlertTable cache ------------------
    /*
     NSString *userId; //用户id
     NSString *updatePromptDay;
     NSString *flag;
     */
    
	NSString *createUpdateSoftAlertTableMsg = @"create table if not exists updateSoftAlertTable (updatePromptDay TEXT PRIMARY KEY, flag TEXT)";
    
    res = [self.db executeUpdate:createUpdateSoftAlertTableMsg];
	if (!res) {
        DLog(@"error when creating updateSoftAlertTable table");
    } else {
        DLog(@"success to creating updateSoftAlertTable table");
    }
    
    //------------------------------------------------------------
    
    //--------------------chat group user cache-----------------------
    /*
     NSString *userId; //用户id
     NSString *userName; //中文名
     NSString *userNameEn; //英文名
     NSString *chatId; //
     NSString *customerId; //
     NSString *userImageUrl; //头像
     NSString *userTel;
     NSString *userEmail; //邮件
     NSString *userStatus; //
     NSString *userCode; //
     NSString *groupId; //
     NSString *userDept; // 部门
     NSString *userTitle; // 头衔
     NSString *userRole; // 角色
     int isFriend;
     int isDelete;
     int userGender;
     */
	NSString *createChatUserTableMsg = @"create table if not exists chat_group_user (groupId TEXT, userId TEXT, chatId TEXT, userName TEXT, userNameEn TEXT, customerId TEXT, userImageUrl TEXT, userCode TEXT, isDelete int, PRIMARY KEY(groupId, userId, chatId))";
    
    res = [self.db executeUpdate:createChatUserTableMsg];
	if (!res) {
        DLog(@"error when creating chat_group_user table");
    } else {
        DLog(@"success to creating chat_group_user table");
    }
    
    //------------------------------------------------------------
}

// ------------------------ User start -------------------------------
#pragma mark - do business action
- (void)insertAllUserObjectDB:(NSArray *)userList
{
    [self.db beginTransaction];
    BOOL isRoolBack = NO;
    
    UserObject *userInfo = nil;
    static NSString *sql = @"INSERT INTO user VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    
    @try
    {
            
        for (int i = 0; i < userList.count; i++) {
            userInfo = [userList objectAtIndex:i];
            
            NSArray *argumentsArray = [[NSArray alloc] initWithObjects:userInfo.userId,
                                       userInfo.userName,
                                       userInfo.userNameEn,
                                       userInfo.chatId,
                                       userInfo.customerId != nil ? userInfo.customerId : @"",
                                       userInfo.userImageUrl != nil ? userInfo.userImageUrl : @"",
                                       userInfo.userTel != nil ? userInfo.userTel : @"",
                                       userInfo.userEmail != nil ? userInfo.userEmail : @"",
                                       userInfo.userStatus != nil ? userInfo.userStatus : @"",
                                       userInfo.userCode != nil ? userInfo.userCode : @"",
                                       userInfo.groupId != nil ? userInfo.groupId : @"",
                                       userInfo.userDept != nil ? userInfo.userDept : @"",
                                       userInfo.userTitle != nil ? userInfo.userTitle : @"",
                                       userInfo.userRole != nil ? userInfo.userRole : @"",
                                       NUMBER(userInfo.isFriend),
                                       NUMBER(userInfo.isDelete),
                                       NUMBER(userInfo.userGender),
                                       userInfo.userCellphone != nil ? userInfo.userCellphone : @"",
                                       userInfo.userBirthDay != nil ? userInfo.userBirthDay : @"",
                                       userInfo.superName != nil ? userInfo.superName : @"",
                                       
                                       userInfo.location != nil ? userInfo.location : @"",
                                       userInfo.serviceYear != nil ? userInfo.serviceYear : @"",
                                       userInfo.subordinateCount != nil ? userInfo.subordinateCount : @"",
                                       userInfo.band != nil ? userInfo.band : @"",
                                       userInfo.superEmail != nil ? userInfo.superEmail : @"",
                                       userInfo.function != nil ? userInfo.function : @"",
                                       userInfo.channel != nil ? userInfo.channel : @"",
                                       NUMBER(userInfo.channelId),
                                       nil];
            
//            if ([[AppManager instance].userId isEqualToString:userInfo.userId]) {
//                NSLog(@"argumentsArray is %@", [argumentsArray description]);
//            }
            
            BOOL res = [self.db executeUpdate:sql
                         withArgumentsInArray:argumentsArray];
            
            if (!res) {
                DLog(@"insert user error !");
            }
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
        isRoolBack = YES;
        [self.db rollback];
    }
    @finally
    {
        if (!isRoolBack) {
            [self.db commit];
        }
    }
}

#pragma mark - update business action
- (void)updateUserObjectDB:(UserObject *)userInfo
{
    [self.db beginTransaction];
    BOOL isRoolBack = NO;
    
    static NSString *sql = @"update user set userId=?,userName=?,userNameEn=?,chatId=?,customerId=?,userImageUrl=?,userTel=?,userEmail=?,userStatus=?,userCode=?,groupId=?,userDept=?,userTitle=?,userRole=?,isFriend=?,isDelete =?,userGender =?,userCellphone =?, userBirthDay =?,superName =?,location =?, serviceYear =?, subordinateCount =?, band =?, superEmail =?, function =?, channel =?, channelId =? where userId = ?";
    
    @try
    {
            
        BOOL res = [self.db executeUpdate:sql
                     withArgumentsInArray:@[userInfo.userId,
                                            userInfo.userName,
                                            userInfo.userNameEn,
                                            userInfo.chatId,
                                            userInfo.customerId != nil ? userInfo.customerId : @"",
                                            userInfo.userImageUrl != nil ? userInfo.userImageUrl : @"",
                                            userInfo.userTel != nil ? userInfo.userTel : @"",
                                            userInfo.userEmail != nil ? userInfo.userEmail : @"",
                                            userInfo.userStatus != nil ? userInfo.userStatus : @"",
                                            userInfo.userCode != nil ? userInfo.userCode : @"",
                                            userInfo.groupId != nil ? userInfo.groupId : @"",
                                            userInfo.userDept != nil ? userInfo.userDept : @"",
                                            userInfo.userTitle != nil ? userInfo.userTitle : @"",
                                            userInfo.userRole != nil ? userInfo.userRole : @"",
                                            NUMBER(userInfo.isFriend),
                                            NUMBER(userInfo.isDelete),
                                            NUMBER(userInfo.userGender),
                                            userInfo.userCellphone != nil ? userInfo.userCellphone : @"",
                                            userInfo.userBirthDay != nil ? userInfo.userBirthDay : @"",
                                            userInfo.superName != nil ? userInfo.superName : @"",
                                            
                                            userInfo.location != nil ? userInfo.location : @"",
                                            userInfo.serviceYear != nil ? userInfo.serviceYear : @"",
                                            userInfo.subordinateCount != nil ? userInfo.subordinateCount : @"",
                                            userInfo.band != nil ? userInfo.band : @"",
                                            userInfo.superEmail != nil ? userInfo.superEmail : @"",
                                            userInfo.function != nil ? userInfo.function : @"",
                                            userInfo.channel != nil ? userInfo.channel : @"",
                                            NUMBER(userInfo.channelId),
                                            
                                            userInfo.userId]];
        
        if (!res) {
            DLog(@"update user error!");
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
        isRoolBack = YES;
        [self.db rollback];
    }
    @finally
    {
        if (!isRoolBack) {
            [self.db commit];
        }
    }
}

- (UserObject *)getUserByUserId:(NSString *)userId {
    
    UserObject *userObject = nil;
    
    NSString *sql = @"select * from user where userId = ?";
    FMResultSet *res = [self.db executeQuery:sql, userId];
    
    while ([res next]) {
        userObject = [[self parseUserBaseInfo:res] retain];
    }
    
    return userObject;
}

- (UserObject *)getUserInfoByVoipIdFromDB:(NSString*)userChatId
{
    UserObject *userObject = nil;
    
    NSString *sql = @"select * from user where chatId = ?";
    FMResultSet *res = [self.db executeQuery:sql, userChatId];
    
    while ([res next]) {
        userObject = [[self parseUserBaseInfo:res] retain];
    }
    
    return userObject;
}

- (NSMutableArray *)getUserByNameKeyword:(NSString *)keyword {

    NSMutableArray *userArray = [NSMutableArray array];

    NSString *sql = [NSString stringWithFormat:@"select * from user where userName like '%%%@%%' or userNameEn like '%%%@%%'", keyword, keyword];
    FMResultSet *res = [self.db executeQuery:sql];
    
    while ([res next]) {
        [userArray addObject:[self parseUserBaseInfo:res]];
    }
    
    return userArray;
}

- (NSMutableArray *)getUserEmailByKeyword:(NSString *)keyword {
    
    NSMutableArray *userEmailArray = [NSMutableArray array];
    
    NSString *sql = [NSString stringWithFormat:@"select * from user where userEmail like '%@%%'", keyword];
    FMResultSet *res = [self.db executeQuery:sql];
    
    while ([res next]) {
        [userEmailArray addObject:[res stringForColumn:@"userEmail"]];
    }
    
    return userEmailArray;
}

- (UserObject *)parseUserBaseInfo:(FMResultSet *)res
{
    UserObject *userObject = [[[UserObject alloc] init] autorelease];
    
    userObject.userId = [res stringForColumn:@"userId"];
    userObject.userName = [res stringForColumn:@"userName"];
    userObject.userNameEn = [res stringForColumn:@"userNameEn"];
    userObject.chatId = [res stringForColumn:@"chatId"];
    userObject.customerId = [res stringForColumn:@"customerId"];
    userObject.userImageUrl = [res stringForColumn:@"userImageUrl"];
    userObject.userTel = [res stringForColumn:@"userTel"];
    userObject.userEmail = [res stringForColumn:@"userEmail"];
    userObject.userStatus = [res stringForColumn:@"userStatus"];
    userObject.userCode = [res stringForColumn:@"userCode"];
    userObject.groupId = [res stringForColumn:@"groupId"]; //
    userObject.userDept = [res stringForColumn:@"userDept"]; // 部门
    userObject.userTitle = [res stringForColumn:@"userTitle"]; // 头衔
    userObject.userRole = [res stringForColumn:@"userRole"]; // 角色
    userObject.isFriend = [res intForColumn:@"isFriend"];
    userObject.isDelete = [res intForColumn:@"isDelete"];
    userObject.userGender = [res intForColumn:@"userGender"];
    userObject.userCellphone = [res stringForColumn:@"userCellphone"];
    userObject.userBirthDay = [res stringForColumn:@"userBirthDay"];
    userObject.superName = [res stringForColumn:@"superName"];
    
//    location TEXT, serviceYear TEXT, band TEXT, superEmail TEXT, function TEXT, channel
    userObject.location = [res stringForColumn:@"location"];
    userObject.serviceYear = [res stringForColumn:@"serviceYear"];
    userObject.subordinateCount = [res stringForColumn:@"subordinateCount"];
    userObject.band = [res stringForColumn:@"band"];
    userObject.superEmail = [res stringForColumn:@"superEmail"];
    userObject.function = [res stringForColumn:@"function"];
    userObject.channel = [res stringForColumn:@"channel"];
    userObject.channelId = [res intForColumn:@"channelId"];
    
    return userObject;
}

- (void)delUserTable {
    
    NSString *sql = @"delete from user";
    FMResultSet *res = [self.db executeQuery:sql];
    
    if ([res next]) {
    }
}

// ------------------------ User end -------------------------------

// ------------------------ Update Soft start -------------------------------
#pragma mark - do business action
- (void)insertSoftDB:(NSArray *)updateArray
{
    [self.db beginTransaction];
    BOOL isRoolBack = NO;
    
    static NSString *sql = @"INSERT INTO updateSoftAlertTable VALUES(?,?)";
    
    @try
    {
        
        BOOL res = [self.db executeUpdate:sql
                     withArgumentsInArray:updateArray];
        
        if (!res) {
            DLog(@"insert updateSoftAlertTable error !");
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
        isRoolBack = YES;
        [self.db rollback];
    }
    @finally
    {
        if (!isRoolBack) {
            [self.db commit];
        }
    }
}

#pragma mark - update business action
- (void)updateSoftDB:(NSArray *)updateArray
{
    [self.db beginTransaction];
    BOOL isRoolBack = NO;
    
    static NSString *sql = @"update updateSoftAlertTable flag=? where updatePromptDay=?";
    
    @try
    {
        
        BOOL res = [self.db executeUpdate:sql
                     withArgumentsInArray:updateArray];
        
        if (!res) {
            DLog(@"update Soft Alert Table error!");
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
        isRoolBack = YES;
        [self.db rollback];
    }
    @finally
    {
        if (!isRoolBack) {
            [self.db commit];
        }
    }
}

- (int)getUpdateSoftDB:(NSString *)updatePromptDay {
    
    NSString *sql = nil;
    FMResultSet *res = nil;
    
    sql = @"select * from updateSoftAlertTable where updatePromptDay = ?";
    res = [self.db executeQuery:sql, updatePromptDay];
    
    if ([res next]) {
        
        NSString *flag = [res stringForColumn:@"flag"];
        return [flag intValue];
    }
    
    return -1;
}

- (void)delUpdateSoftDB {
    
    NSString *sql = @"delete from updateSoftAlertTable";
    FMResultSet *res = [self.db executeQuery:sql];
    
    if ([res next]) {
    }
}

// ------------------------ Update Soft end -------------------------------

@end
