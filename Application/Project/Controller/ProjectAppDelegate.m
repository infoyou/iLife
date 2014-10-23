

#import "ProjectAppDelegate.h"
#import "HomeContainerViewController.h"
#import "BaseNavigationController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <CrashReporter/CrashReporter.h>
#import "WXWDebugLogOutput.h"
#import "UIDevice+Hardware.h"
#import "WXWDBConnection.h"
#import "WXWImageManager.h"
#import "CommonUtils.h"
#import "FileUtils.h"
#import "AppManager.h"
#import "ProjectAPI.h"
#import "GlobalConstants.h"
#import "CrashMethod.h"
#import "LogUploader.h"
#import "ProjectDBManager.h"

#import "WXApi.h"
#import "MobClick.h"
#import "iflyMSC/IFlySpeechUtility.h"

#import "LoginViewController.h"
//#import "ModelEngineVoip.h"
//#import "VoipIncomingViewController.h"

#import "Reachability.h"

//#import "PushListener.h"
#import "PushNotifyServer.h"

#import "DirectionMPMoviePlayerViewController.h"

@interface ProjectAppDelegate () <CurrentLoginVCDelegate, WXApiDelegate>

@property (nonatomic, retain) BaseNavigationController *homeNC;
@property (nonatomic, assign) LoginViewController *userLoginVC;
@property (nonatomic, retain) BaseNavigationController *splashNav;
@property (nonatomic, retain) BaseNavigationController *loginNav;
@property (nonatomic, assign) BOOL isEndsplahsed;

@property (nonatomic, retain) UITabBarController *tabBarViewController;
@end

@implementation ProjectAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize loginNav = _loginNav;
@synthesize userLoginVC = _userLoginVC;
//@synthesize modelEngineVoip;

#pragma mark - properties

- (void)dealloc {
//    self.modelEngineVoip = nil;
    
    [super dealloc];
}

- (HomeContainerViewController *)homepageContainer {
    if (nil == _homepageContainer) {
        _homepageContainer = [[HomeContainerViewController alloc] initHomepageWithMOC:self.managedObjectContext];
    }
    
    return _homepageContainer;
}

- (BaseNavigationController *)homeNC {
    if (nil == _homeNC) {
        _homeNC = [[BaseNavigationController alloc] initWithRootViewController:self.homepageContainer];
    }
    
    
    [_homepageContainer selectFirstTabBar];
    [_homepageContainer modifyFromTabBarFlag];
    
    self.window.rootViewController = _homepageContainer;
    return _homeNC;
}

#pragma mark - prepare app

- (void)applyCurrentLanguage {
    [WXWSystemInfoManager instance].currentLanguageCode = [WXWCommonUtils fetchIntegerValueFromLocal:SYSTEM_LANGUAGE_LOCAL_KEY];
    
    if ([WXWSystemInfoManager instance].currentLanguageCode == NO_TY) {
        [WXWCommonUtils getLocalLanguage];
    }else {
        [WXWCommonUtils getDBLanguage];
    }
}

- (void)prepareDB {
    [WXWDBConnection prepareBizDB];
}

- (void)prepareApp {
//    [self prepareCrashReporter];
    
    [self loadNessesaryResource];
    
    _startup = YES;
    
    if (![IPHONE_SIMULATOR isEqualToString:[WXWCommonUtils deviceModel]]) {
        [self registerNotify];
    }
    
    [WXWSystemInfoManager instance].currentLanguageCode = ZH_HANS_TY;
    [WXWCommonUtils saveIntegerValueToLocal:[WXWSystemInfoManager instance].currentLanguageCode
                              key:SYSTEM_LANGUAGE_LOCAL_KEY];
    [self applyCurrentLanguage];
    
    // register call back method for MOC save notification
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:sel_registerName("handleSaveNotification:")
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:self.managedObjectContext];
    
    [self prepareDB];
    
    // register app to WeChat
    [WXApi registerApp:WX_API_KEY];
    
    // get Device System
    [WXWCommonUtils parserDeviceSystemInfo];
}

#pragma mark - view navigation
- (void)switchViews:(BaseNavigationController *)toBeDisplayedNav {
    
    CATransition *viewFadein = [CATransition animation];
    viewFadein.duration = 0.3f;
    viewFadein.type = kCATransitionFade;
    
    [self.window.layer addAnimation:viewFadein forKey:nil];
    
    if (_premiereNav) {
        _premiereNav.view.hidden = YES;
        [_premiereNav.view removeFromSuperview];
    }
    
    toBeDisplayedNav.view.hidden = NO;
    
    [self.window setRootViewController:toBeDisplayedNav];
   
    _premiereNav = toBeDisplayedNav;
    
}

- (void)clearHomepageViewController {
    
    [self.homepageContainer cancelConnectionAndImageLoading];
    self.homepageContainer = nil;
    self.homeNC = nil;
}

- (void)goHomePage {
    
    [self switchViews:self.homeNC];
}

- (void)logout
{
    if (_userLoginVC) {
        
        [self clearLogin];
        _userLoginVC = [[LoginViewController alloc] initWithMOC:self.homepageContainer.MOC
                                                           parentVC:self.homepageContainer];
        
        _userLoginVC.delegate = self;
        _userLoginVC.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        
// ----------  替换 开始 ----------
//        [self.window setRootViewController:_userLoginVC];
        
//        UINavigationController *vcNav = [[[UINavigationController alloc] initWithRootViewController:_userLoginVC] autorelease];
//        vcNav.navigationBar.tintColor = TITLESTYLE_COLOR;
//        
//        [self.window setRootViewController:vcNav];
        [self goHomePage];
// ----------  替换 结束 ----------
        
        NSArray *array = [NSArray arrayWithObjects:@"ChatGroupModel", nil];
        [[ProjectDBManager instance] deleteEntity:array MOC:_managedObjectContext];
        
    }
    
//    [[PushListener defaultListener] removeObserver];
}

#pragma mark - push notification
- (void)registerNotify
{
    //    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    
    if (IS_OS_8_OR_LATER) {
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         UIRemoteNotificationTypeBadge |
         UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeSound];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    DLog(@"My token is: %@", deviceToken);
    [AppManager instance].deviceToken = [NSString stringWithFormat:@"%@", deviceToken];
    [AppManager instance].deviceToken = [[AppManager instance].deviceToken stringByReplacingOccurrencesOfString:@"<" withString:@""];
    [AppManager instance].deviceToken = [[AppManager instance].deviceToken stringByReplacingOccurrencesOfString:@">" withString:@""];
    [AppManager instance].deviceToken = [[AppManager instance].deviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
//    [self endSplash];
}

- (void)endSplash
{
    if (!self.isEndsplahsed) {
       
#if APP_TYPE == APP_TYPE_EMBA
    
    if (![IPHONE_SIMULATOR isEqualToString:[WXWCommonUtils deviceModel]]) {
        
        [self endSplash:nil];
    }
    
#endif
        self.isEndsplahsed = YES;
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    DLog(@"Failed to get token, error: %@", error);
    
//    [self endSplash];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    [AppManager instance].notifyDataDict = userInfo;
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidReceivedRomateNotificationName
                                                        object:self
                                                      userInfo:nil];
}

#pragma mark - system call back methods
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // prepare meta data and cache
    [self prepareApp];
    
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [self regist3rd];
    
    // prepare UI homepage
    [[AppManager instance] changeNavigationBarStyle];
    
    [self endSplash:nil];

    return YES;
}

- (void)regist3rd
{
    // Weixin
    [WXApi registerApp:WEIXIN_APP_ID];
    
    // Umeng
    [MobClick startWithAppkey:UMENG_ANALYS_APP_KEY reportPolicy:SEND_INTERVAL channelId:nil];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:version];
    [MobClick setLogEnabled:YES];
    
    // Voice
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@", @"53c87f6c"];
    [IFlySpeechUtility createUtility:initString];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
//    [self.modelEngineVoip stopUdpTest];
//    [self.modelEngineVoip stopCurRecording];
//    self.modelEngineVoip.appIsActive = NO;
    
    DLog(@"application will resign active");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    DLog(@"application will enter background");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    
    // clear UIWebView cache
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    // clear image cache
    [[WXWImageManager instance] clearImageCacheForHandleMemoryWarning];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

//    self.modelEngineVoip.appIsActive = YES;
    
    application.applicationIconBadgeNumber = 0;
    
    /*
    PushNotifyServer *pushNotifyServer = [[[PushNotifyServer alloc] init] autorelease];
    [NSThread detachNewThreadSelector:@selector(triggerNotify)
                             toTarget:pushNotifyServer
                           withObject:nil];
    */
    
    LogUploader *log = [[[LogUploader alloc] init] autorelease];
    [NSThread detachNewThreadSelector:@selector(triggerUpload)
                             toTarget:log
                           withObject:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidBecomeActiveNotification object:self];
    
//    NSString *md5Password = [[AppManager instance].userDefaults passwordRemembered];
//    if (md5Password && md5Password.length > 0) {
//        [_userLoginVC autoLogin];
//    }
    
    [AppManager instance].passwd = [[AppManager instance].userDefaults passwordRemembered];
    
    if ([[AppManager instance].userDefaults getSaveUserId] != nil) {
        [AppManager instance].userId = [[AppManager instance].userDefaults getSaveUserId];
    } else {
        [AppManager instance].userId = @"";
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self saveContext];
    
    [[WXWImageManager instance].imageCache clearAllCachedAndLocalImages];
    
    [WXWDBConnection closeDB];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextDidSaveNotification
                                                  object:self.managedObjectContext];
    
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    /*
    NSString *callID = [notification.userInfo objectForKey:KEY_CALLID];
    NSString *type = [notification.userInfo objectForKey:KEY_TYPE];
    NSString *call = [notification.userInfo objectForKey:KEY_CALL_TYPE];
    NSString *caller = [notification.userInfo objectForKey:KEY_CALLNUMBER];
    NSInteger calltype = call.integerValue;
    
    if ([type isEqualToString:@"comingCall"])
    {
        UIApplication *uiapp = [UIApplication sharedApplication];
        NSArray *localNotiArray = [uiapp scheduledLocalNotifications];
        for (UILocalNotification *notification in localNotiArray)
        {
            NSDictionary *dic = [notification userInfo];
            NSString *value = [dic objectForKey:KEY_TYPE];
            if ([value isEqualToString:@"comingCall"] || [value isEqualToString:@"releaseCall"])
            {
                [uiapp cancelLocalNotification:notification];
            }
        }
    }
     */
}

- (void)addressbookChangeCallback:(NSNotification *)_notification
{
    globalcontactsChanged = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"contactsChanged" object:nil userInfo:nil];
}

#pragma mark - rewrite
-(BOOL)application:(UIApplication*)application handleOpenURL:(NSURL *)url
{
    return [WXApi handleOpenURL:url delegate:self];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [WXApi handleOpenURL:url delegate:self];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            DLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack
- (void)handleSaveNotification:(NSNotification *)aNotification {
    [self.managedObjectContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)
                                                withObject:aNotification
                                             waitUntilDone:YES];
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Project" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ProductFramework.sqlite"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtURL:storeURL error:nil];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {

        DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void) makeWorkingDir
{
	[FileUtils mkdir:[CommonMethod getLocalDownloadFolder]];
	[FileUtils  mkdir:[CommonMethod getLocalImageFolder]];
}

- (void)loadNessesaryResource
{
    [self makeWorkingDir];
    [[AppManager instance] prepareData];
    [[ProjectAPI getInstance] setCommon:[AppManager instance].common];
}

- (BOOL)isNeedShowRegisterView
{
    return YES;
}

- (void)clearLogin
{
    [_userLoginVC.view removeFromSuperview];
    _userLoginVC = nil;
}

- (void)endSplash:(UIViewController *)vc
{
    if ([self isNeedShowRegisterView]) {
        if (!_userLoginVC) {
            
            _userLoginVC = [[LoginViewController alloc] initWithMOC:self.homepageContainer.MOC
                                                               parentVC:self.homepageContainer];
            _userLoginVC.view.hidden = YES;
            _userLoginVC.delegate = self;
            [_userLoginVC autoLogin];
        }
    } else {
        [self loginSuccessfull:_userLoginVC];
    }
}

-(void)closeSplash
{
    [self logout];
}

- (BOOL)loginSuccessfull:(LoginViewController *)vc
{
    [self goHomePage];
    
    //添加推送监听
//    [[PushListener defaultListener] addObserver];
    
    //上传crash文件
//    [CrashMethod uploadCrashReportWithThread:[NSString stringWithFormat:@"%@_%@", [AppManager instance].userId, [AppManager instance].userName]];
    
    return YES;
}

//
// Called to handle a pending crash report.
//
- (void)handleCrashReport {
    PLCrashReporter *crashReporter = [PLCrashReporter sharedReporter];
    NSData *crashData;
    NSError *error;
    
    // Try loading the crash report
    crashData = [crashReporter loadPendingCrashReportDataAndReturnError: &error];
    if (crashData == nil) {
        DLog(@"Could not load crash report: %@", error);
        goto finish;
    }
    
    // We could send the report from here, but we'll just print out
    // some debugging info instead
    PLCrashReport *report = [[[PLCrashReport alloc] initWithData: crashData error: &error] autorelease];
    if (report == nil) {
        DLog(@"Could not parse crash report");
        goto finish;
    }
    
    DLog(@"Crashed on %@", report.systemInfo.timestamp);
    DLog(@"Crashed with signal %@ (code %@, address=0x%" PRIx64 ")", report.signalInfo.name,
          report.signalInfo.code, report.signalInfo.address);
finish:
    return;
}

- (void)prepareCrashReporter {
    
    // Enable the Crash Reporter
    PLCrashReporter *crashReporter = [PLCrashReporter sharedReporter];
    NSError *error;
    
    /* Check if we previously crashed */
    if ([crashReporter hasPendingCrashReport])
        [self handleCrashReport];
    
    /* Enable the Crash Reporter */
    if (![crashReporter enableCrashReporterAndReturnError: &error])
        DLog(@"Warning: Could not enable crash reporter: %@", error);
}

#pragma mark - debug log
- (void)printLog:(NSString*)log
{
    DLog(@"Debug %@",log); //用于xcode日志输出
}

@end

