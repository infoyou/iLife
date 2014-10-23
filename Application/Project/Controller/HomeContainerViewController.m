
#import "HomeContainerViewController.h"
#import "VisitingFarmsViewController.h"
#import "ShoppingCartViewController.h"
#import "OrderDetailViewController.h"
#import "MeListViewController.h"
#import "ShareViewController.h"
#import "LoginViewController.h"
#import "RegistViewController.h"

#import "GlobalConstants.h"
#import "TextPool.h"
#import "CommonHeader.h"
#import "CommonWebViewController.h"
#import "AppManager.h"
#import "TabBarView.h"

@interface HomeContainerViewController () <TabDelegate, MFMessageComposeViewControllerDelegate>
{
    bool isFromTabBar;
    
    CGFloat _tabbarOriginalY;
    
    UIView *shareView;
}

@property (nonatomic, retain) TabBarView *tabBar;
@property (nonatomic, retain) UIWindow *statusBarBackground;
@property (nonatomic, retain) RootViewController *currentVC;

@property (nonatomic, retain) VisitingFarmsViewController *visitingFarmsVC;
@property (nonatomic, retain) ShoppingCartViewController *shoppingCartVC;
@property (nonatomic, retain) OrderDetailViewController *orderVC;
@property (nonatomic, retain) MeListViewController *meTypeVC;

//@property (nonatomic, retain) NSManagedObjectContext *MOC;

@end

@implementation HomeContainerViewController
//@synthesize MOC;

#pragma mark - init views
- (void)initTabBar {
    if (CURRENT_OS_VERSION >= IOS7) {
        _tabbarOriginalY = SCREEN_HEIGHT - HOMEPAGE_TAB_HEIGHT;
    } else {
        _tabbarOriginalY = SCREEN_HEIGHT - HOMEPAGE_TAB_HEIGHT - self.navigationController.navigationBar.frame.size.height;
    }
    
    self.tabBar = [[[TabBarView alloc] initWithFrame:CGRectMake(0, _tabbarOriginalY, SCREEN_WIDTH, HOMEPAGE_TAB_HEIGHT) delegate:self] autorelease];
    [self.view addSubview:self.tabBar];
}

- (void)initNavigationBarTitle {
    //    self.navigationItem.title = LocaleStringForKey(NSAppTitle, nil);
}

- (CGFloat)contentHeight {
    
    float backVal = self.view.frame.size.height - HOMEPAGE_TAB_HEIGHT;
    DLog(@"backVal ==================== %0.f", backVal);
    
    return backVal;
}

#pragma mark - life cycle methods
- (id)initHomepageWithMOC:(NSManagedObjectContext *)MOC
{
    self = [super initWithMOCWithoutBackButton:MOC];
    if (self) {
        [CommonMethod getInstance].navigationRootViewController = self;
    }
    return self;
}

- (void)dealloc {
    
    self.tabBar = nil;
    
    self.currentVC = nil;
    
    self.statusBarBackground = nil;
    
    [_visitingFarmsVC release];
    [_shoppingCartVC release];
    [_orderVC release];
    [_meTypeVC release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    isFromTabBar = YES;
    self.view.backgroundColor = DEFAULT_VIEW_COLOR;
    
    [self initTabBar];
    
    [self initNavigationBarTitle];
    
    [self selectFirstTabBar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotifyData)
                                                 name:UIApplicationDidReceivedRomateNotificationName
                                               object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self doShowOrHideNaviBar];
    
    if (self.currentVC) {
        [WXWCommonUtils checkAndExecuteSelectorWithName:@"play" byTarget:self.currentVC];
        
        if (CURRENT_OS_VERSION >= IOS7) {
//            if ([self.currentVC isKindOfClass:[VisitingFarmsViewController class]]) {
//            } else {
                self.statusBarBackground.backgroundColor = [UIColor whiteColor];
                [self.statusBarBackground setHidden:NO];
//            }
        }
        
        [self.currentVC viewWillAppear:animated];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (self.currentVC) {
        [WXWCommonUtils checkAndExecuteSelectorWithName:@"stopPlay" byTarget:self.currentVC];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - clear current vc
- (void)clearCurrentVC {
    [self.currentVC cancelConnectionAndImageLoading];
    [self.currentVC cancelLocation];
    
    if (self.currentVC.view) {
        [self.currentVC.view removeFromSuperview];
    }
    
    self.currentVC = nil;
}

#pragma mark - refresh tab items
- (void)refreshTabItems {
    
    [self.tabBar refreshItems];
    self.tabBar.backgroundColor = [[ThemeManager shareInstance] getColorWithName:@"tabBarBGColor"];
    [self.view bringSubviewToFront:self.tabBar];
    [self.tabBar switchTabHighlightStatus:TAB_BAR_FOURTH_TAG];
}

- (void)modifyFromTabBar
{
    isFromTabBar = NO;
}

#pragma mark - show or hide navi bar
- (void)hiddenNavigationBar {
    [self doShowOrHideNaviBar];
    isFromTabBar = YES;
}

- (void)showNavigationBar {
    [self doShowOrHideNaviBar];
    isFromTabBar = YES;
}

- (void)modifyFromTabBarFlag
{
    isFromTabBar = YES;
}

- (void)adjustTabViewFrame {
    
    int y = SCREEN_HEIGHT - HOMEPAGE_TAB_HEIGHT;
    
//    if ([self.currentVC isKindOfClass:[VisitingFarmsViewController class]]) {
//        self.tabBar.frame = CGRectMake(0, y, SCREEN_WIDTH, HOMEPAGE_TAB_HEIGHT);
//    } else {
        self.tabBar.frame = CGRectMake(0, y - 64, SCREEN_WIDTH, HOMEPAGE_TAB_HEIGHT);
//    }
}

- (void)changeTabView:(BOOL)isShow {
    self.tabBar.hidden = !isShow;
    
    [self showNavigationBar];
}

- (void)doShowOrHideNaviBar {
    
    self.navigationController.navigationBarHidden = NO;
    
    UIColor *barColor = [[ThemeManager shareInstance] getColorWithName:@"kNaviBarTitleLabel"];
    
    NSDictionary *titleBarAttributes = @{
                                         UITextAttributeFont : FONT_SYSTEM_SIZE(18),
                                         UITextAttributeTextShadowColor : TRANSPARENT_COLOR,
                                         UITextAttributeTextColor : barColor,
                                         NSForegroundColorAttributeName : barColor
                                         };
    [self.navigationController.navigationBar setTitleTextAttributes:titleBarAttributes];
    
    /*
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     HEX_COLOR(@"0xdba449"), UITextAttributeTextColor,
                                                                     [UIColor colorWithRed:0 green:0.7 blue:0.8 alpha:1], UITextAttributeTextShadowColor,
                                                                     [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset,
                                                                     [UIFont fontWithName:@"Arial-Bold" size:0.0], UITextAttributeFont,
                                                                     nil]];
    */
    
    if ([self.currentVC isKindOfClass:[VisitingFarmsViewController class]])
    {
        /*
         // Hidden Bar
        self.navigationController.navigationBarHidden = YES;
        if (isFromTabBar) {
            [self.currentVC.view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - HOMEPAGE_TAB_HEIGHT)];
        }
        */
        [self.currentVC.view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - HOMEPAGE_TAB_HEIGHT - 64)];
        
    } else if([self.currentVC isKindOfClass:[ShoppingCartViewController class]]){
        [self.currentVC.view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - HOMEPAGE_TAB_HEIGHT - 64)];
    } else if([self.currentVC isKindOfClass:[OrderDetailViewController class]]){
        [self.currentVC.view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 4)];
    } else if([self.currentVC isKindOfClass:[MeListViewController class]]){
        [self.currentVC.view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - HOMEPAGE_TAB_HEIGHT - 64)];
    } else {
        [self.currentVC.view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    }
    
    [self adjustTabViewFrame];
}

#pragma mark - TabDelegate methods

- (void)removeCurrentView {
    
    [WXWCommonUtils checkAndExecuteSelectorWithName:@"stopPlay" byTarget:self.currentVC];
    
    [self clearCurrentVC];
}

- (void)arrangeCurrentVC:(RootViewController *)vc {
    
    [self removeCurrentView];
    
    self.currentVC = vc;
    
    [self.view addSubview:self.currentVC.view];
    
    DLog(@" ===== currentVC.view.frame ===== %@", NSStringFromCGRect(self.currentVC.view.frame));
    
    if ([WXWCommonUtils currentOSVersion] < IOS5) {
        [self.currentVC viewWillAppear:YES];
    }
    
    [self doShowOrHideNaviBar];
    
    [self.view bringSubviewToFront:self.tabBar];
}

- (void)refreshBadges {
    [self.tabBar refreshBadges];
}

//首页
- (void)selectFirstTabBar {
    
//     if ([self.currentVC isKindOfClass:[VisitingFarmsViewController class]]) {
//         return;
//     }

    self.navigationItem.title = LocaleStringForKey(NSMainPageBottomBarInformation, nil);
    
    self.navigationItem.rightBarButtonItems = nil;
    self.navigationItem.rightBarButtonItem = nil;
    
    if ([AppManager instance].passwd && [[AppManager instance].passwd length] > 0) {
        
        // right
        UIBarButtonItem* sendItem = [[[UIBarButtonItem alloc] initWithTitle:LocaleStringForKey(@"个人中心", nil) style:UIBarButtonItemStyleDone
                                                                     target:self action:@selector(goProfile)] autorelease];
        [sendItem setTintColor:[UIColor whiteColor]];
        self.navigationItem.rightBarButtonItem = sendItem;
        
    } else {
        
        UIBarButtonItem* registBtnItem = [[[UIBarButtonItem alloc] initWithTitle:LocaleStringForKey(@"注册", nil) style:UIBarButtonItemStyleDone
                                                                     target:self action:@selector(goRegist)] autorelease];
        [registBtnItem setTintColor:[UIColor whiteColor]];
        
        UIBarButtonItem* splitBtnItem = [[[UIBarButtonItem alloc] initWithTitle:LocaleStringForKey(@"|", nil) style:UIBarButtonItemStyleDone
                                                                          target:self action:nil] autorelease];
        [splitBtnItem setTintColor:[UIColor whiteColor]];
        
        UIBarButtonItem* loginBtnItem = [[[UIBarButtonItem alloc] initWithTitle:LocaleStringForKey(@"登录", nil) style:UIBarButtonItemStyleDone
                                                                     target:self action:@selector(goLogin)] autorelease];
        [loginBtnItem setTintColor:[UIColor whiteColor]];
        
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:loginBtnItem, splitBtnItem, registBtnItem, nil]];
        
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    }
    
     if (!self.visitingFarmsVC)
     _visitingFarmsVC = [[VisitingFarmsViewController alloc] initWithMOC:self.MOC
                                                   viewHeight:[self contentHeight]
                                              homeContainerVC:self];
    
     [self arrangeCurrentVC:self.visitingFarmsVC];
    
     [self.tabBar switchTabHighlightStatus:TAB_BAR_FIRST_TAG];
}

// 购物车
- (void)selectSecondTabBar
{
    if ([self.currentVC isKindOfClass:[ShoppingCartViewController class]]) {
        return;
    }
    
    self.navigationItem.title = LocaleStringForKey(NSMainPageBottomBarCommunicat, nil);
    self.navigationItem.rightBarButtonItems = nil;
    self.navigationItem.rightBarButtonItem = nil;
    
    if (!self.shoppingCartVC)
        _shoppingCartVC = [[ShoppingCartViewController alloc] initWithMOC:_MOC viewHeight:[self contentHeight] homeContainerVC:self];
    [self arrangeCurrentVC:self.shoppingCartVC];
}

// 订单
- (void)selectThirdTabBar {
    
    if ([self.currentVC isKindOfClass:[OrderDetailViewController class]]) {
        return;
    }

    self.navigationItem.title = LocaleStringForKey(NSMainPageBottomBarLearn, nil);
    self.navigationItem.rightBarButtonItems = nil;
    self.navigationItem.rightBarButtonItem = nil;
    
    if (!self.orderVC)
        _orderVC = [[OrderDetailViewController alloc] initWithMOC:_MOC viewHeight:[self contentHeight] homeContainerVC:self];
    [self arrangeCurrentVC:self.orderVC];
}

// 我
- (void)selectFourthTabBar
{

//    ShareViewController *aboutVC = [[ShareViewController alloc] initWithNibName:@"ShareViewController" bundle:nil moc:_MOC];
//    [self.navigationController pushViewController:aboutVC animated:YES];
//    [aboutVC release];
    
    {
        // totalBG
        UIView *shareBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        shareBgView.backgroundColor = TRANSPARENT_COLOR;
        
        // headBg
        UIView *headBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64-190)];
        headBgView.backgroundColor = HEX_COLOR(@"0x323232");
        headBgView.alpha = 0.6;
        
        [shareBgView addSubview:headBgView];
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ShareView" owner:self options:nil];
        UITableViewCell* cell = [nib objectAtIndex:0];
        
        UIImageView *shareWechat = (UIImageView *)[cell viewWithTag:10];
        UIImageView *shareWeibo = (UIImageView *)[cell viewWithTag:11];
        UIImageView *shareSMS = (UIImageView *)[cell viewWithTag:12];
        
        shareWechat.userInteractionEnabled = YES;
        shareWeibo.userInteractionEnabled = YES;
        shareSMS.userInteractionEnabled = YES;
        
        [self addTapGestureRecognizer:shareWechat];
        [self addTapGestureRecognizer:shareWeibo];
        [self addTapGestureRecognizer:shareSMS];
        
        UIButton *cancelBtn = (UIButton *)[cell viewWithTag:13];
        [cancelBtn addTarget:self action:@selector(btnShareCancelClick:) forControlEvents:UIControlEventTouchUpInside];
        
        CGRect contentFrame = CGRectMake(0, SCREEN_HEIGHT-64-190, SCREEN_HEIGHT, 190);
        UIView *shareContentBgView = [[UIView alloc] initWithFrame:contentFrame];
        shareContentBgView.backgroundColor = HEX_COLOR(@"0x323232");
        [shareContentBgView addSubview:cell.contentView];
        
        [shareBgView addSubview:shareContentBgView];
        shareView = shareBgView;
        
        [self.view addSubview:shareView];
    }
    
    /*
    if ([self.currentVC isKindOfClass:[MeListViewController class]]) {
        return;
    }
    
    self.navigationItem.title = LocaleStringForKey(NSMainPageBottomBarMe, nil);
    
    if (!self.meTypeVC) {
        _meTypeVC = [[MeListViewController alloc] initWithMOC:_MOC parentVC:self];
    }
    
    [self arrangeCurrentVC:self.meTypeVC];
     */
}

- (void)selectFifthTabBar
{
}

- (void)goRegist
{
    
    RegistViewController *registVC = [[[RegistViewController alloc] initWithNibName:@"RegistViewController" bundle:nil] autorelease];
    
    UINavigationController *vcNav = [[[UINavigationController alloc] initWithRootViewController:registVC] autorelease];
    vcNav.navigationBar.tintColor = TITLESTYLE_COLOR;
    
    [self presentViewController:vcNav animated:YES completion:nil];
}

- (void)goLogin
{
    self.navigationItem.rightBarButtonItems = nil;
    self.navigationItem.rightBarButtonItem = nil;
    
    LoginViewController* loginVC =[[LoginViewController alloc] init];
    
//    UINavigationController *vcNav = [[[UINavigationController alloc] initWithRootViewController:loginVC] autorelease];
//    vcNav.navigationBar.tintColor = TITLESTYLE_COLOR;
//    [self presentViewController:vcNav animated:YES completion:nil];
    
    loginVC.delegate = [UIApplication sharedApplication].delegate;
    [[[UIApplication sharedApplication].delegate window] setRootViewController:loginVC];
}

- (void)goProfile
{

    if ([AppManager instance].passwd && [[AppManager instance].passwd length]>0) {
        MeListViewController *meVC = [[[MeListViewController alloc] initWithMOC:_MOC parentVC:self] autorelease];
        [self.navigationController pushViewController:meVC animated:YES];
    } else {
        [self askWithMessage:@"尚未登录，请先登录" alertTag:LOGIN_TAG];
    }
}

#pragma mark - for gesture
- (void)addTapGestureRecognizer:(UIImageView*)targetImageview {
    UITapGestureRecognizer *swipeGR = [[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                               action:@selector(imageviewTouchEvents:)] autorelease];
    swipeGR.delegate = self;
    
    [targetImageview addGestureRecognizer:swipeGR];
}

- (void)imageviewTouchEvents:(UIGestureRecognizer *)gestureRecognizer
{
    UIImageView *view = (UIImageView*)[gestureRecognizer view];
    int viewTag = view.tag;
    
    DLog(@"%d is touched",viewTag);
    
    switch (viewTag) {
        case 10:
        {
            NSLog(@"wechat click");
        }
            break;
        
        case 11:
        {
            NSLog(@"weibo click");
        }
            break;
            
        case 12:
        {
            NSLog(@"sms click");
            [self showSMSPicker:nil];
        }
            break;
            
        default:
            break;
    }
}

- (void)btnShareCancelClick:(id)sender
{
    [shareView removeFromSuperview];
}

#pragma mark - send sms
- (void)displaySMSComposerSheet
{
    MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
    
    picker.messageComposeDelegate = self;
    
    picker.body = @"通过短信，分享 蔬菜达人";
    
    [self presentModalViewController:picker animated:YES];
    
    [picker release];
    
}

- (IBAction)showSMSPicker:(id)sender {
    
    Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
    
    if (messageClass != nil) {
        
        if ([messageClass canSendText]) {
            
            [self displaySMSComposerSheet];
        } else {
            //设备没有短信功能
        }
    } else {
        // iOS版本过低,iOS4.0以上才支持程序内发送短信
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if(result==MessageComposeResultSent)
    {
        NSLog(@"发短信成功");
    } else if(result==MessageComposeResultCancelled) {
        NSLog(@"发短信取消");
    } else if(result==MessageComposeResultFailed) {
        NSLog(@"发短信失败");
    }
}

#pragma mark-UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==LOGIN_TAG) {
        if (buttonIndex==1) {
            LoginViewController* login=[[LoginViewController alloc]init];
            login.delegate=[UIApplication sharedApplication].delegate;
            [[[UIApplication sharedApplication].delegate window] setRootViewController:login];
        }
    }
}

- (void)handleNotifyData
{
    
//    {"aps":{"alert":"This is Test message.", "sound":"notify.wav", "badge":2,"type":"1"}}
    
    NSDictionary *notifyDict = OBJ_FROM_DIC([AppManager instance].notifyDataDict, @"aps");
    NSString *typeStr = STRING_VALUE_FROM_DIC(notifyDict, @"type");
    
    int typeVal = 0;
    
    if (typeStr && typeStr.length > 0) {
        typeVal = [typeStr intValue];
    }
    
    switch (typeVal) {
        case 0:
        {
            [self selectThirdTabBar];
            [self.tabBar switchTabHighlightStatus:TAB_BAR_THIRD_TAG];
        }
            break;
            
        case 1:
        {
            [self selectFirstTabBar];
            [self.tabBar switchTabHighlightStatus:TAB_BAR_FIRST_TAG];
            
            MeListViewController *meVC = [[[MeListViewController alloc] initWithMOC:_MOC parentVC:self] autorelease];
            [self.navigationController pushViewController:meVC animated:YES];
            
            [meVC openNotifyVC];
        }
            break;
            
        default:
            break;
    }
}

@end
