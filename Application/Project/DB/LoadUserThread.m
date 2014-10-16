
//
//  LoadUserThread.m
//  QiXin
//
//  Created by Adam on 14-6-18.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import "LoadUserThread.h"
#import "AppManager.h"
#import "ProjectDBManager.h"
#import "CommonMethod.h"
#import "FMDBConnection.h"
#import "WXWSyncConnectorFacade.h"
#import "ProjectAPI.h"
#import "JSON.h"
#import "JSONKit.h"

@interface LoadUserThread()
@end

@implementation LoadUserThread
{
    long long int startTime;
}

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void) dealloc
{
	[super dealloc];
}

- (void)loadUserData
{
    NSMutableDictionary *specialDict = [NSMutableDictionary dictionary];
    [specialDict setValue:@"0" forKey:@"PageIndex"];
    [specialDict setValue:MAX_DATA_SIZE forKey:@"PageSize"];
    
    //    if ([AppManager instance].lastUpdateUserMsgTime == 0) {
    [specialDict setValue:@"" forKey:@"LastTimeStamp"];
    //    } else {
    //        [specialDict setValue:@([AppManager instance].lastUpdateUserMsgTime) forKey:@"LastTimeStamp"];
    //    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@%@", VALUE_API_PREFIX, API_SERVICE_USER, API_GET_USER_LIST];
    NSString *url = [ProjectAPI getURL:urlStr specialDict:specialDict];
    
    // 将地址编码
    NSString *urlString = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    // 实例化NSMutableURLRequest，并进行参数配置
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString: urlString]];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setTimeoutInterval:60];
    [request setHTTPShouldHandleCookies:FALSE];
    [request setHTTPMethod:@"GET"];
    
    // Response对象，用来得到返回后的数据，比如，用statusCode==200 来判断返回正常
    NSHTTPURLResponse *response;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:&response error:nil];
    
    
    NSLog(@"load User data = %lld", [CommonMethod getCurrentTimeSince1970] - startTime);
    
    NSDictionary *resultDic = [returnData objectFromJSONData];
    NSDictionary *contentDic = OBJ_FROM_DIC(resultDic, @"Data");
    
    NSArray *userList = OBJ_FROM_DIC(contentDic, @"UserInfo");
    
    if (userList && userList.count) {
        
        for (int i = 0; i < userList.count; i++) {
            NSDictionary *userDict = [userList objectAtIndex:i];
            
            UserObject *userObject = [CommonMethod formatUserObjectWithParam:userDict];
            [[AppManager instance].allUsers addObject:userObject];
        }
    }

}

- (void)saveUserData
{
    int userCount = [AppManager instance].allUsers.count;
    
    if (userCount == 0) {
        return;
    } else {
        [[FMDBConnection instance] delUserTable];
        
        [[FMDBConnection instance] insertAllUserObjectDB:[AppManager instance].allUsers];
    }
}

- (void) main
{
	@autoreleasepool {

        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		@try {
            
            startTime = [CommonMethod getCurrentTimeSince1970];
            DLog(@"Handle user start");
            
            // 1, load User data from web
            [self loadUserData];
            
            // 2, save User data to DB
            [self saveUserData];
            
            [AppManager instance].lastUpdateUserMsgTime = [CommonMethod getCurrentTimeSince1970];
		}
        @catch (NSException *exception) {
            DLog(@"Exception name=%@",exception.name);
            DLog(@"Exception reason=%@",exception.reason);
		}
		@finally {
            [pool release];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_SAVE_ALL_USER_STATUS object:nil userInfo:nil];
			
            NSLog(@"Handle user End %lld", [CommonMethod getCurrentTimeSince1970] - startTime);
		}
	}
}

@end
