
#import "MeListViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "CommonMethod.h"
#import "WXApi.h"
#import "UIImageView+WebCache.h"
#import "HomeContainerViewController.h"
#import "MeSettingController.h"
#import "IdentityAuthViewController.h"
#import "MeTableViewCell.h"
#import "VPImageCropperViewController.h"
#import "ChangePWDViewController.h"
#import "FeedQuestionViewController.h"
#import "UserDetailEditViewController.h"
#import "UserObject.h"

#import "AddressListController.h"
#import "PlatNotifyListViewController.h"
#import "MerchantsListViewController.h"
#import "HistoryOrderListViewController.h"

#define kTableSectionHeight 11.f
#define kTableHeadHeight    62.f
#define kTableFootheight    145.f

typedef enum {
    ALERT_TAG_MUST_UPDATE = 1,
    ALERT_TAG_CHOISE_UPDATE = 2,
}  UPDATE_ALERT_TAG;

typedef enum : NSUInteger {
    Me_Section0_Type = 0,
    Me_Section1_Type,
    Me_Section2_Type,
    Me_Section3_Type
} MeSectionType;

enum Section2_Section_Type
{
    Seprate_Img_Type = 102,
    UserName_lbl_Type,
    Vision_lbl_Type,
};

enum sheetType
{
    Camera_Sheet_Type,
    Share_Sheet_Type,
    Logout_Sheet_Type,
};

enum Head_Control_Type
{
    Head_userImg_Type = 301,
    Head_name_Type,
    Head_title_Type,
    Head_ticket_Type,
    Head_detail_Type,
};

@interface MeListViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, VPImageCropperDelegate, UIAlertViewDelegate>

@property (nonatomic, retain) UITableView *m_meTableView;
@property (nonatomic, retain) UIImageView *m_userImgView;
@property (nonatomic, retain) UIImageView *m_headView;

@end

@implementation MeListViewController
{
    UserObject *userInfo;
}

@synthesize m_meTableView;
@synthesize m_userImgView;
@synthesize m_headView;

- (void)dealloc
{
    RELEASE_OBJ(m_meTableView);
    RELEASE_OBJ(m_userImgView);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kThemeDidChangeNotification object:nil];
    
    [super dealloc];
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
         parentVC:(RootViewController *)pVC {
    
    self = [super initWithMOC:MOC
        needRefreshHeaderView:NO
        needRefreshFooterView:NO];
    
    if (self) {
        self.parentVC = pVC;
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    userInfo = [[FMDBConnection instance] getUserByUserId:[AppManager instance].userId];
    [self.m_meTableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = LocaleStringForKey(@"个人中心", nil);
//    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:[self createMeTypeTable]];
    
    //监听主题切换的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeNotification:) name:kThemeDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Create Control

- (UITableView *)createMeTypeTable
{
    CGRect tableFrame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 /*- HOMEPAGE_TAB_HEIGHT*/);
    self.m_meTableView = [[[UITableView alloc] initWithFrame:tableFrame style:UITableViewStyleGrouped] autorelease];
    [m_meTableView setBackgroundColor:[UIColor whiteColor]];
    [m_meTableView setDataSource:self];
    [m_meTableView setDelegate:self];
    [m_meTableView setShowsHorizontalScrollIndicator:NO];
    [m_meTableView setShowsVerticalScrollIndicator:NO];
    [m_meTableView setSeparatorInset:UIEdgeInsetsMake(0, 11, 0, 0)];
    [m_meTableView setSeparatorColor:HEX_COLOR(@"0xe1dfe0")];
//    [m_meTableView setSectionFooterHeight:12.0];//设置section之间的间距
    [m_meTableView setMultipleTouchEnabled:NO];
    
    return m_meTableView;
}

- (NSMutableDictionary *)setTitleDictionary
{
    NSMutableArray *section0Array = [[[NSMutableArray alloc] initWithObjects:LocaleStringForKey(@"平台通知", nil), LocaleStringForKey(@"常用地址", nil), LocaleStringForKey(@"常用卖家", nil), LocaleStringForKey(@"历史订单", nil), nil] autorelease];
    NSMutableArray *section1Array = [[[NSMutableArray alloc]initWithObjects:LocaleStringForKey(NSFeedbackMsg, nil), nil] autorelease];
    NSMutableArray *section2Array = [[[NSMutableArray alloc]initWithObjects:LocaleStringForKey(NSVersionTitle, nil), nil] autorelease];
    NSMutableArray *section3Array = [[[NSMutableArray alloc]initWithObjects:LocaleStringForKey(NSSettingsTitle, nil), nil] autorelease];
    
    NSMutableDictionary *titleDic = [NSMutableDictionary dictionary];
    [titleDic setObject:section0Array forKey:[NSNumber numberWithInt:10]];
    [titleDic setObject:section1Array forKey:[NSNumber numberWithInt:11]];
    [titleDic setObject:section2Array forKey:[NSNumber numberWithInt:12]];
    [titleDic setObject:section3Array forKey:[NSNumber numberWithInt:13]];
    
    return titleDic;
}

- (NSMutableDictionary *)setValueDictionary
{
    NSMutableArray *section0Array = [[[NSMutableArray alloc]initWithObjects:@"", @"", @"", @"", nil] autorelease];
    NSMutableArray *section1Array = [[[NSMutableArray alloc]initWithObjects:@"", nil] autorelease];
    
    NSString *version = [NSString stringWithFormat:@"V%@", VERSION];
    NSMutableArray *section2Array = [[[NSMutableArray alloc]initWithObjects:version, nil] autorelease];
    NSMutableArray *section3Array = [[[NSMutableArray alloc]initWithObjects:@"", nil] autorelease];
    
    NSMutableDictionary *titleDic = [NSMutableDictionary dictionary];
    [titleDic setObject:section0Array forKey:[NSNumber numberWithInt:10]];
    [titleDic setObject:section1Array forKey:[NSNumber numberWithInt:11]];
    [titleDic setObject:section2Array forKey:[NSNumber numberWithInt:12]];
    [titleDic setObject:section3Array forKey:[NSNumber numberWithInt:13]];
    
    return titleDic;
}

- (NSMutableDictionary *)setImageDictionary
{
    NSMutableArray *section0Array = [[[NSMutableArray alloc] initWithObjects:@"me_notify", @"me_address", @"me_merchants", @"me_order", nil] autorelease];
    NSMutableArray *section1Array = [[[NSMutableArray alloc] initWithObjects:@"me_feedback", nil] autorelease];
    NSMutableArray *section2Array = [[[NSMutableArray alloc] initWithObjects:@"me_update", nil] autorelease];
    NSMutableArray *section3Array = [[[NSMutableArray alloc] initWithObjects:@"me_setting", nil] autorelease];
    
    NSMutableDictionary *imageDic = [NSMutableDictionary dictionary];
    [imageDic setObject:section0Array forKey:[NSNumber numberWithInt:10]];
    [imageDic setObject:section1Array forKey:[NSNumber numberWithInt:11]];
    [imageDic setObject:section2Array forKey:[NSNumber numberWithInt:12]];
    [imageDic setObject:section3Array forKey:[NSNumber numberWithInt:13]];
    
    return imageDic;
}

- (UILabel *)createUserIDLbl
{
    float heightGap = 93.5f;
    float lblHeight = 16.0f;
    float lblWidth = 160.0f;
    
    CGRect userRect = CGRectMake((SCREEN_WIDTH - lblWidth)/2, heightGap, lblWidth, lblHeight);
    UILabel *userName = [InformationDefault createLblWithFrame:userRect withTextColor:[UIColor whiteColor] withFont:[UIFont boldSystemFontOfSize:15] withTag:UserName_lbl_Type];
    [userName setTextAlignment:NSTextAlignmentCenter];
    [userName setText:@"Vivien"];
    return userName;
}

- (UILabel *)createVisionLbl
{
    float lblHeght = 11.0f;
    UIColor *lblColor = [UIColor colorWithHexString:@"0xb1b1b1"];
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:11];
    CGRect lblFrame = CGRectMake(0, (kTableFootheight - lblHeght)/2 + 60, SCREEN_WIDTH, lblHeght);
    UILabel *visionLbl = [InformationDefault createLblWithFrame:lblFrame withTextColor:lblColor withFont:font withTag:Vision_lbl_Type];
    [visionLbl setTextAlignment:NSTextAlignmentCenter];
    [visionLbl setText:[NSString stringWithFormat:@"版本号：1.0"]];
    
    return visionLbl;
}

- (UIButton *)createLogoutBtn
{
    UIButton *logoutBtn = [[[UIButton alloc]initWithFrame:CGRectMake(10, kTableFootheight - kMeTypeCellHeight, SCREEN_WIDTH-20, kMeTypeCellHeight)] autorelease];
    
    [logoutBtn setBackgroundColor:HEX_COLOR(@"0x82bf24")];
    [logoutBtn.titleLabel setFont:FONT_SYSTEM_SIZE(15)];
    [logoutBtn setTitleColor:HEX_COLOR(@"0xffffff") forState:UIControlStateNormal];
    [logoutBtn setTitleColor:HEX_COLOR(@"0xffffff") forState:UIControlStateSelected];
    [logoutBtn setTitle:LocaleStringForKey(NSLogoutTitle, Nil) forState:UIControlStateNormal];
    [logoutBtn addTarget:self action:@selector(logoutClick) forControlEvents:UIControlEventTouchUpInside];
    
    // layer
    [logoutBtn.layer setBorderWidth:1.0];
    [logoutBtn.layer setBorderColor:HEX_COLOR(@"0x82bf24").CGColor];
    [logoutBtn.layer setCornerRadius:3];
    [logoutBtn.layer setMasksToBounds:YES];
    
    return logoutBtn;
}

- (UIImageView *)setUserMsgView
{
    CGRect headRect = CGRectMake(0, 0, SCREEN_WIDTH, kTableHeadHeight);
    self.m_headView = [[[UIImageView alloc] initWithFrame:headRect] autorelease];
    [m_headView setBackgroundColor:[UIColor whiteColor]];
    [m_headView setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer *tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileClick)] autorelease];
    [m_headView addGestureRecognizer:tapGesture];
    return m_headView;
}

- (void)setTableHeadView
{
    
//    CGRect userAvtorRect =  CGRectMake(14, 11, 46.5, 46.5);
    CGRect userAvtorRect =  CGRectMake(22.5, 23, 22.5, 20);
    self.m_userImgView = [[[UIImageView alloc] initWithFrame:userAvtorRect] autorelease];
//    [self.m_userImgView setImageWithURL:[NSURL URLWithString:userInfo.userImageUrl] placeholderImage:[UIImage imageNamed:@"groupCellDefaultHeader.png"]];
    [self.m_userImgView setImage:[UIImage imageNamed:@"me_avtor.png"]];
    [self.m_headView addSubview:self.m_userImgView];
    
    CGRect userNameRect = CGRectMake(48, 24, 223, 20);
    UILabel *userNameLbl = [InformationDefault createLblWithFrame:userNameRect withTextColor:HEX_COLOR(@"0x666666") withFont:FONT_BOLD_SYSTEM_SIZE(16) withTag:Head_name_Type];
    [self.m_headView addSubview:userNameLbl];
    
    CGRect titleRect = CGRectMake(69.5, 40, 223, 14);
    UILabel *titleNameLbl = [InformationDefault createLblWithFrame:titleRect withTextColor:HEX_COLOR(@"0x999999") withFont:[UIFont fontWithName:@"Thonburi" size:13] withTag:Head_title_Type];
    [self.m_headView addSubview:titleNameLbl];
    
    UIImageView *ticketImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(180, 25, 22.5, 15.f)] autorelease];
    ticketImgView.image = [UIImage imageNamed:@"me_ticket.png"];
    [self.m_headView addSubview:ticketImgView];
    
    CGRect ticketRect = CGRectMake(212, 24, 110, 18);
    UILabel *ticketLbl = [InformationDefault createLblWithFrame:ticketRect withTextColor:HEX_COLOR(@"0x666666") withFont:FONT_BOLD_SYSTEM_SIZE(16) withTag:Head_ticket_Type];
    ticketLbl.text = @"菜票20元";
    [self.m_headView addSubview:ticketLbl];
    
    // line
    UIView *lineView = [[[UIView alloc] initWithFrame:CGRectMake(0, 61, SCREEN_WIDTH, 0.6f)] autorelease];
    lineView.backgroundColor = HEX_COLOR(@"0xe1dfe0");
    [self.m_headView addSubview:lineView];
}

- (void)setUserDetailImg
{
    UIImage *nextImg = [UIImage imageNamed:@"me_detail"];
   
    UIImageView *moreUserMsgImg = [InformationDefault createImgViewWithFrame:CGRectMake(287, 25, 9.5f, 14.5f) withImage:nextImg withColor:[UIColor clearColor] withTag:Head_detail_Type];
    [self.m_headView addSubview:moreUserMsgImg];
}

- (void)setUserMessage:(NSDictionary *)dic
{
    UILabel *userNameLbl = (UILabel *)[self.m_headView viewWithTag:Head_name_Type];
    [userNameLbl setText:userInfo.userTel];
//    [userNameLbl setText:[AppManager instance].userName];
    
//    UILabel *userTitleLbl = (UILabel *)[self.m_headView viewWithTag:Head_title_Type];
//    [userTitleLbl setText:[AppManager instance].userTitle];
}

#pragma mark - Action Click
- (void)profileClick
{
    if (YES) {
        return;
    }
    
    UserDetailEditViewController *vc =
    [[[UserDetailEditViewController alloc] initWithMOC:_MOC] autorelease];
    [CommonMethod pushViewController:vc withAnimated:YES];
}

- (void)cameraClick
{
    [self editPortrait];
}

#pragma mark - TableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == Me_Section0_Type)
    {
        return 4;
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == Me_Section0_Type)
    {
        return kTableHeadHeight + kTableSectionHeight;
    }
    
    return kTableSectionHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kMeTypeCellHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == Me_Section0_Type)
    {
        UIView *headView = [[[UIView alloc] init] autorelease];
        [headView setBackgroundColor:[UIColor clearColor]];
        [headView addSubview:[self setUserMsgView]];
        [self setTableHeadView];
//        [self setUserDetailImg];
        [self setUserMessage:nil];
        return headView;
    } else {
        return nil;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == Me_Section0_Type)
    {
        return kTableFootheight;
    }
    return 0.1f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    
    if (section == Me_Section0_Type)
    {
        UIView *footBGView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kTableFootheight)] autorelease];
        [footBGView setBackgroundColor:[UIColor whiteColor]];
        
        [footBGView addSubview:[self createLogoutBtn]];
//        [footBGView addSubview:[self createVisionLbl]];

        return footBGView;
    } else {
        return nil;
    }
   
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellIdentifier = @"MeListCell";
    MeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (nil == cell)
    {
        cell = [[[MeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                reuseIdentifier:kCellIdentifier] autorelease];
    }
    [cell.contentView setBackgroundColor:[UIColor clearColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    [cell setCellText:[[[self setTitleDictionary] objectForKey:[NSNumber numberWithInt:indexPath.section + 10]] objectAtIndex:indexPath.row]];
    [cell setCellTextVal:[[[self setValueDictionary] objectForKey:[NSNumber numberWithInt:indexPath.section + 10]] objectAtIndex:indexPath.row]];
    UIImage *img = [UIImage imageNamed:[[[self setImageDictionary] objectForKey:[NSNumber numberWithInt:indexPath.section + 10]] objectAtIndex:indexPath.row]];
    [cell setCellIcon:img];
    
    [cell setBadgeData:nil isHidden:YES];
    
//    if (indexPath.section != Me_Section0_Type) {
        // cell detail icon
        UIImage *nextImg = [UIImage imageNamed:@"me_detail"];
        UIImageView *moreUserMsgImg = [InformationDefault createImgViewWithFrame:CGRectMake(287, 16, 9.5f, 14.5f) withImage:nextImg withColor:[UIColor clearColor] withTag:Head_detail_Type];
        [cell.contentView addSubview:moreUserMsgImg];
//    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = indexPath.row;
    
    switch (indexPath.section)
    {
        case Me_Section0_Type:
        {
//            [self showCommingAlert];
            
            /*
            IdentityAuthViewController *myInfo = [[[IdentityAuthViewController alloc] initWithMOC:_MOC parentVC:nil viewHeight:0] autorelease];
            [CommonMethod pushViewController:myInfo withAnimated:YES];
             */
            
            if (row == 0) {
                // 平台通知
                PlatNotifyListViewController *platNotifyVC = [[[PlatNotifyListViewController alloc] initWithMOC:_MOC parentVC:nil] autorelease];
                [CommonMethod pushViewController:platNotifyVC withAnimated:YES];
            } else if (row == 1) {
                // 常用地址
                AddressListController *addressVC = [[[AddressListController alloc] initWithMOC:_MOC parentVC:nil] autorelease];
                [CommonMethod pushViewController:addressVC withAnimated:YES];
            } else if (row == 2) {
                // 常用卖家
                MerchantsListViewController *merchantsVC = [[[MerchantsListViewController alloc] initWithMOC:_MOC parentVC:nil] autorelease];
                [CommonMethod pushViewController:merchantsVC withAnimated:YES];
            } else if (row == 3) {
                // 历史订单
                HistoryOrderListViewController *merchantsVC = [[[HistoryOrderListViewController alloc] initWithMOC:_MOC parentVC:nil] autorelease];
                [CommonMethod pushViewController:merchantsVC withAnimated:YES];
            }
        }
            break;
       
        case Me_Section1_Type:
        {
            FeedQuestionViewController *feed = [[[FeedQuestionViewController alloc] init] autorelease];
            [CommonMethod pushViewController:feed withAnimated:YES];
        }
            break;
            
         case Me_Section2_Type:
        {
            [self doUpdateSoftAction];
        }
            break;
        
         case Me_Section3_Type:
        {
            MeSettingController *settingVC = [[[MeSettingController alloc] initWithMOC:_MOC parentVC:self.parentVC] autorelease];
            [CommonMethod pushViewController:settingVC withAnimated:YES];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - share app
- (void)shareAndInvite {
    UIActionSheet *shareSheet = [[[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil] autorelease];
    
    [shareSheet addButtonWithTitle:LocaleStringForKey(NSShareBySMSTitle, nil)];
    [shareSheet addButtonWithTitle:LocaleStringForKey(NSShareByWeixinTitle, nil)];
    [shareSheet addButtonWithTitle:LocaleStringForKey(NSCancelTitle, nil)];
    shareSheet.cancelButtonIndex = [shareSheet numberOfButtons] - 1;
    [shareSheet setTag:Share_Sheet_Type];
    
//    [self.view addSubview:shareSheet];
//    [shareSheet showInView:self.view];
    [shareSheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)shareBySMS {
    if (![MFMessageComposeViewController canSendText]) {
        ShowAlert(self,LocaleStringForKey(NSNoteTitle, nil), LocaleStringForKey(NSNoSupportTitle, nil), LocaleStringForKey(NSOKTitle, nil));
        return;
    }
    
    MFMessageComposeViewController *controller = [[[MFMessageComposeViewController alloc] init] autorelease];
    controller.body = [AppManager instance].recommend;
    controller.recipients = @[NULL_PARAM_VALUE];
    controller.messageComposeDelegate = (id<MFMessageComposeViewControllerDelegate>)self;
    
    if (self.parentVC) {
        [self.parentVC.navigationController presentViewController:controller animated:YES completion:nil];
    }
}

- (void)shareByWeiXin
{
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
        
        NSString *url = [NSString stringWithFormat:@"http://weixun.co/gohigh_test.html"];
        
        BOOL reult = [CommonUtils shareByWeChat:WXSceneSession
                                          title:LocaleStringForKey(NSAppRecommendTitle, nil)
                                          image:[CommonMethod getAppIcon]
                                    description:[AppManager instance].recommend
                                            url:url];
        
        if (reult) {
            DLog(@"share sucessfully");
        }
    } else {
        UIAlertView *alView = [[UIAlertView alloc] initWithTitle:@""
                                                         message:@"你的iPhone上还没有安装微信,无法使用此功能，使用微信可以方便的把你喜欢的作品分享给好友。"
                                                        delegate:self
                                               cancelButtonTitle:@"取消"
                                               otherButtonTitles:@"免费下载微信", nil];
        [alView show];
        [alView release];
    }
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag)
    {
        case Camera_Sheet_Type:
        {
            if (buttonIndex == 0)
            {
                [self enterCameraForUser];
            } else if (buttonIndex == 1) {
                
                [self enterPhotoLibraryForUser];
            } else {
                return;
            }
        }
            break;
            
        case Share_Sheet_Type:
        {
            if (buttonIndex == 0)
            {
                [self shareBySMS];
            } else if (buttonIndex == 1) {
                
                [self shareByWeiXin];
            } else {
                return;
            }
        }
            
        case Logout_Sheet_Type:
        {
            if (buttonIndex == 0)
            {
                [self doLogout];
            } else {
                return;
            }

        }
            
        default:
            break;
    }
}

#pragma mark - ImagePickerView

- (void)editPortrait
{
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:LocaleStringForKey(NSCancelTitle, nil)
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:LocaleStringForKey(NSTakePhotoTitle, nil), LocaleStringForKey(NSChooseExistingPhotoTitle, nil), nil];
    [choiceSheet setTag:Camera_Sheet_Type];
    
    [choiceSheet showInView:[UIApplication sharedApplication].keyWindow];
}

#pragma mark - portraitImageView getter
- (UIImageView *)portraitImageView {
    if (!m_userImgView) {
       
        CGFloat width = 73.0f; CGFloat height = width;
        CGFloat xGap = (SCREEN_WIDTH - width)/2;
        CGFloat yGap = 13.0f;
        self.m_userImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(xGap, yGap, width, height)]autorelease];
        [m_userImgView.layer setCornerRadius:(m_userImgView.frame.size.height/2)];
        [m_userImgView.layer setMasksToBounds:YES];
        [m_userImgView setContentMode:UIViewContentModeScaleAspectFill];
        [m_userImgView setClipsToBounds:YES];
        m_userImgView.layer.shadowColor = [UIColor blackColor].CGColor;
        m_userImgView.layer.shadowOffset = CGSizeMake(4, 4);
        m_userImgView.layer.shadowOpacity = 0.5;
        m_userImgView.layer.shadowRadius = 2.0;
        m_userImgView.layer.borderColor = [[UIColor blackColor] CGColor];
        m_userImgView.layer.borderWidth = 2.0f;
        m_userImgView.userInteractionEnabled = YES;
        m_userImgView.backgroundColor = [UIColor blackColor];
    }
    return self.m_userImgView;
}

- (void)themeNotification:(id)sender
{
    HomeContainerViewController *homeContainerVC = (HomeContainerViewController *)self.parentVC;
    [homeContainerVC refreshTabItems];
}

- (void)changeTabShowState:(BOOL)isShow {
    HomeContainerViewController *homeContainerVC = (HomeContainerViewController *)self.parentVC;
    [homeContainerVC changeTabView:isShow];
}

#pragma mark - logout
- (void)logoutClick
{
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:LocaleStringForKey(NSCancelTitle, nil)
                                               destructiveButtonTitle:LocaleStringForKey(NSLogoutTitle, nil)
                                                    otherButtonTitles:nil];
    [choiceSheet setTag:Logout_Sheet_Type];
    
    [choiceSheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)doLogout
{
    DLog(@"LOG OUT CLICK....");
    [[AppManager instance].userDefaults rememberUsername:[[AppManager instance].userDefaults usernameRemembered] andPassword:@"" pswdStr:@"" customerName:@""];
    
    // Clear current user data
    [WXWCoreDataUtils deleteEntitiesFromMOC:_MOC entityName:@"TodoList" predicate:nil];
    [WXWCoreDataUtils deleteEntitiesFromMOC:_MOC entityName:@"SurveyDetail" predicate:nil];
    [WXWCoreDataUtils deleteEntitiesFromMOC:_MOC entityName:@"SurveyItem" predicate:nil];

    // Do logout
    [((ProjectAppDelegate *)APP_DELEGATE) logout];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    // Set Home param
    HomeContainerViewController *homeVC = (HomeContainerViewController *)self.parentVC;
    [homeVC selectFirstTabBar];
    [homeVC modifyFromTabBarFlag];
    
}

- (void)doUpdateSoftAction
{
    
    NSMutableDictionary *specialDict = [NSMutableDictionary dictionary];
    [specialDict setValue:@"QiXin" forKey:@"AppName"];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@", VALUE_API_PREFIX, API_UPDATE_SERVICE];
    NSString *url = [ProjectAPI getURL:urlStr specialDict:specialDict];
    DLog(@"url = %@", url);
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:UPDATE_VERSION_TY];
    
    [connFacade fetchGets:url];
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType {
    //    [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil) blockCurrentView:YES];
    
    [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
    
    switch (contentType) {
            
        case UPDATE_VERSION_TY:
        {
            int ret = SUCCESS_CODE;
            
            NSDictionary *resultDic = [result objectFromJSONData];
            if ([resultDic objectForKey:@"ResultCode"] != nil) {
                ret = INT_VALUE_FROM_DIC(resultDic, @"ResultCode");
            }
            
            if (ret == SUCCESS_CODE) {
//                [self bringToFront];
                [self.view endEditing:YES];
                
                NSDictionary *resultDict = [result objectFromJSONData];
                NSDictionary *dict = OBJ_FROM_DIC(resultDict, @"Data");
                
                if (dict && [dict count] > 0) {
                    NSString *updateURL = [dict objectForKey:@"UpdateURL"];
                    NSString *updateContent = [dict objectForKey:@"UpdateContent"];
                    
                    if (!updateURL || [updateURL isEqual:[NSNull null]] || [updateURL isEqual:@"<null>"]) {
                        
                    } else {
                        [AppManager instance].updateURL = updateURL;
                        DLog(@"%@", [AppManager instance].updateURL);
                    }
                    
                    NSString *isMandatory = [dict objectForKey:@"IsMandatoryUpdate"];
                    if (!isMandatory || [isMandatory isEqual:[NSNull null]] || [isMandatory isEqual:@"<null>"]) {
                        
//                        [self doLoginLogic];
                    } else {
                        [AppManager instance].isMandatory = INT_VALUE_FROM_DIC(dict, @"IsMandatoryUpdate");
                        DLog(@"%d", [AppManager instance].isMandatory);
                        
                        NSString *msgContent = nil;
                        UIAlertView *updateAlertView = nil;
                        if ([AppManager instance].isMandatory == 1) {
                            msgContent = @"有版本更新,您必须更新后才可使用.";
                            
                            if (updateContent && updateContent.length > 0) {
                                msgContent = updateContent;
                            }
                            
                            updateAlertView = [[UIAlertView alloc] initWithTitle:LocaleStringForKey(NSNoteTitle, nil)
                                                                         message:msgContent
                                                                        delegate:self
                                                               cancelButtonTitle:nil
                                                               otherButtonTitles:LocaleStringForKey(NSUpdateTitle, nil), nil];
                            updateAlertView.tag = ALERT_TAG_MUST_UPDATE;
                        } else {
                            msgContent = @"有新版本发布,需要更新吗?";
                            
                            if (updateContent && updateContent.length > 0) {
                                msgContent = updateContent;
                            }
                            
                            updateAlertView = [[UIAlertView alloc] initWithTitle:LocaleStringForKey(NSNoteTitle, nil)
                                                                         message:msgContent
                                                                        delegate:self
                                                               cancelButtonTitle:LocaleStringForKey(NSCancelTitle, nil)
                                                               otherButtonTitles:LocaleStringForKey(NSUpdateTitle, nil),nil];
                            updateAlertView.tag = ALERT_TAG_CHOISE_UPDATE;
                        }
                        
                        [updateAlertView show];
                    }
                }
            } else if (ret == 101){
                [[[[UIAlertView alloc] initWithTitle:LocaleStringForKey(NSNoteTitle, nil) message:@"当前版本是最新版本."/*@"The current version is the latest."*/ delegate:nil cancelButtonTitle:LocaleStringForKey(NSSureTitle, nil) otherButtonTitles:nil] autorelease]show];
            }
            break;
        }

        default:
            break;
    }
    
    [super connectDone:result
                   url:url
           contentType:contentType];
}

- (void)connectCancelled:(NSString *)url
             contentType:(NSInteger)contentType {
    
    [super connectCancelled:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(NSInteger)contentType {
    
    [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - UIAlertViewDelegate method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [alertView release];
    
    switch (alertView.tag) {
            
        case ALERT_TAG_MUST_UPDATE:
        {
            //            if (buttonIndex == 1)
            {
                [CommonMethod update:[AppManager instance].updateURL];
                exit(0);
                //            } else {
                //                exit(0);
            }
        }
            break;
            
        case ALERT_TAG_CHOISE_UPDATE:
        {
            if (buttonIndex == 1)
            {
                [CommonMethod update:[AppManager instance].updateURL];
                exit(0);
            } else {
            }
        }
            break;
            
        default:
            break;
    }
}

@end
