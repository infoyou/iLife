
/*!
 @header AppManager.h
 @abstract 系统内存
 @author Adam
 @version 1.00 2014/03/26 Creation
 */

#import <Foundation/Foundation.h>
#import "UserHeader.h"
#import "ProjectUserDefaults.h"
#import "AppSystemDelegate.h"
#import "LoadUserThread.h"

@interface AppManager : NSObject {
    
    id<AppSettingDelegate>_settingDelegate;
    BOOL _reloadDataForLanguageSwitch;
    
    NSMutableArray *visiblePopTipViews;
    NSString *chartContent;
}

// --- PG start----
@property (nonatomic, copy) NSString *pgName;
@property (nonatomic, assign) int pgPoint;
@property (nonatomic, copy) NSString *pgCookie;
@property (nonatomic, retain) NSNumber *surveyType;
@property (nonatomic, retain) NSNumber *surveyPassType;
@property (nonatomic, copy) NSString *surveyItemTopic;
@property (nonatomic, retain) NSNumber *surveyPassRate;
@property (nonatomic, retain) NSString *surveyId;
@property (nonatomic, retain) NSNumber *surveyIsMultiAnswer;
@property (nonatomic, retain) NSMutableArray *pgChannelArray;
// --- PG end----

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userEmail;

@property (nonatomic, copy) NSString *sessionId;
@property (nonatomic, copy) NSString *userChatId;
@property (nonatomic, copy) NSString *userChatPwd;
@property (nonatomic, copy) NSString *userChatAccountId;
@property (nonatomic, copy) NSString *userChatToken;

@property (nonatomic, copy) NSString *userEditVal;
@property (nonatomic, copy) NSString *userEditValId;

@property (nonatomic, copy) NSString *userType;
@property (nonatomic, copy) NSString *clientID;
@property (nonatomic, copy) NSString *customerID;
@property (nonatomic, copy) NSString *vipID;
@property (nonatomic, copy) NSString *userTitle;
@property (nonatomic, copy) NSString *userDept;

@property (nonatomic, copy) NSString *userImageUrl;

@property (nonatomic, copy) NSString *isLoginLicall;
@property (nonatomic, retain) NSMutableDictionary *common;
@property (nonatomic, retain) NSMutableDictionary *commonUsedDic;
@property (nonatomic, copy) NSString *passwd;
@property (nonatomic, copy) NSString *hostUrl;
@property (nonatomic, retain) NSString *updateURL;
@property (nonatomic, copy) NSString *deviceToken;
@property (nonatomic, assign) int isMandatory;
@property (nonatomic, assign) NSString *recommend;
@property (nonatomic, assign) NSInteger vipType;

@property (nonatomic, retain) UserDataManager *userDM;

@property (nonatomic, retain) NSMutableArray *visiblePopTipViews;
@property (nonatomic, copy) NSString *chartContent;

@property (nonatomic, assign) NSDictionary *bundleDict;

@property (nonatomic, assign) ProjectUserDefaults *userDefaults;

// TODO only for Test
@property (nonatomic, retain) NSMutableDictionary *chatUserDict;

@property (nonatomic, assign) long long int lastUpdateUserMsgTime;

// All user
@property (nonatomic, retain) NSMutableArray *allUsers;
@property (nonatomic, assign) BOOL isLoadAllUserDataDone;
@property (nonatomic, retain) LoadUserThread *loadUserThread;

@property (nonatomic, assign) BOOL updateCache;

+ (AppManager *)instance;

- (void)prepareData;
- (void)initUserDefaults;

- (NSMutableDictionary *)specialWithInvokeType:(int)type;
- (NSMutableDictionary *)specialWithInvokeType:(int)type specifieduserID:(int)userId;

- (void) updateLoginSuccess:(NSDictionary *)dict;

- (void)exchangeRuleToExpert;
- (void)exchangeRuleToDaPeople;

//Language
- (void)reloadForLanguageSwitch:(id<AppSettingDelegate>)settingDelegate;

#pragma mark - chanage NaviBar Style
- (void)changeNavigationBarStyle;
@end
