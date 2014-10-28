
#import "MeSettingController.h"
#import "ChangePWDViewController.h"
#import "HomeContainerViewController.h"
#import "WXWLabel.h"
#import "SkinListViewController.h"
#import "LanguageListViewController.h"
#import "FileUtils.h"
#import "AboutViewController.h"

#define SETTING_CELL_HEIGHT  50.0f

typedef enum
{
    Change_Language_Cell_Type,
    Clear_Cache_Cell_Type,
    Change_Skin_Cell_Type,
} MsgSettingCellType;

typedef enum : NSUInteger {
    User_Setting_Section0_Type,
    User_Setting_Section1_Type,
    User_Setting_Section2_Type
} UserSettingSectionType;

enum ALERT_TAG {
    ALERT_TAG_CLEAR_CACHE = 1,
    ALERT_TAG_UPDATE = 2,
};

@interface MeSettingController ()
{
    UITableView *_setTableView;
}

@property (nonatomic, retain) UITableView *_setTableView;

@end

@implementation MeSettingController
@synthesize _setTableView;


- (void)dealloc
{
    [_setTableView release];
    [super dealloc];
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
         parentVC:(RootViewController *)pVC
{
    
    self = [super initWithMOC:MOC
        needRefreshHeaderView:NO
        needRefreshFooterView:NO];
    
    if (self) {
        self.parentVC = (HomeContainerViewController*)pVC;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.alpha = 0;
    
    self.title = LocaleStringForKey(NSSettingsTitle, nil);
    
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor colorWithHexString:@"0xeeeeee"]];
    [self.view addSubview:[self setSettingTable]];
}

- (UITableView *)setSettingTable
{
    self._setTableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStyleGrouped] autorelease];
    [_setTableView setDataSource:self];
    [_setTableView setDelegate:self];
    [_setTableView setAllowsMultipleSelection:NO];
    [_setTableView setSeparatorInset:UIEdgeInsetsMake(0, 18.0, 0, 0)];
    [_setTableView setBackgroundColor:TRANSPARENT_COLOR];
    
    return self._setTableView;
}

- (NSMutableDictionary *)setCellTextData
{

    NSMutableArray *passwordArr = [[[NSMutableArray alloc]initWithObjects:LocaleStringForKey(NSChangePwdTitle, nil), nil]autorelease];
    NSMutableArray *privacyArr = [[[NSMutableArray alloc]initWithObjects:LocaleStringForKey(NSSwitchLanguage, nil), LocaleStringForKey(NSClearMemory, nil), LocaleStringForKey(NSChangeSkin, nil), nil] autorelease];
    NSMutableArray *aboutArr = [[[NSMutableArray alloc]initWithObjects:LocaleStringForKey(NSSoftAbout, nil), nil]autorelease];
    
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
    [dataDic setObject:passwordArr forKey:[NSNumber numberWithInt:20]];
    [dataDic setObject:privacyArr forKey:[NSNumber numberWithInt:21]];
    [dataDic setObject:aboutArr forKey:[NSNumber numberWithInt:22]];
    
    return dataDic;
}

- (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
    [tableView setTableHeaderView:view];
    [view release];
}

#pragma mark - TableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == User_Setting_Section1_Type)
    {
        return 3;
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 17.5f;
    
//    if (section == User_Setting_Section0_Type)
//    {
//        return 17.5f;
//    } else {
//        return 0.f;
//    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SETTING_CELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1f;
    
//    if (section == User_Setting_Section1_Type)
//    {
//        return 100.0f;
//    } else {
//         return 14.0f;
//    }
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *headView = [[[UIView alloc] init] autorelease];
//    [headView setBackgroundColor:[UIColor redColor]];
//    return headView;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    UIView *headView = [[[UIView alloc] init] autorelease];
//    [headView setBackgroundColor:[UIColor blueColor]];
//    return headView;
//    
//    /*
//    if (section == User_Setting_Section1_Type)
//    {
//        float gap = 18.0f;
//        float hGap = 29.5f;
//        float btnHeight = 44.0f;
//        UIButton *logoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [logoutBtn setBackgroundColor:[UIColor clearColor]];
//        [logoutBtn setBackgroundImage:[UIImage imageNamed:@"Me_logout"] forState:UIControlStateNormal];
//        [logoutBtn setTitle:@"退出登录" forState:UIControlStateNormal];
//        [logoutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [logoutBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
//        [logoutBtn setBounds:CGRectMake(0, 0, SCREEN_WIDTH - gap*2, btnHeight)];
//        [logoutBtn setCenter:CGPointMake(SCREEN_WIDTH/2, hGap + btnHeight/2)];
//        [logoutBtn addTarget:self action:@selector(logoutClick:) forControlEvents:UIControlEventTouchUpInside];
//        
//        UIView *footView = [[[UIView alloc]init] autorelease];
//        [footView setBackgroundColor:[UIColor clearColor]];
//        [footView addSubview:logoutBtn];
//        
//        return footView;
//    }
//    */
//    return nil;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *kCellIdentifier = @"MeSettingCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    for (UIView *subView in cell.contentView.subviews)
    {
        [subView removeFromSuperview];
    }
    
//    if (nil == cell)
//    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:kCellIdentifier] autorelease];
        
        WXWLabel *cellLabel = [[[WXWLabel alloc] initWithFrame:CGRectMake(16.5f, (SETTING_CELL_HEIGHT-18.0f)/2, 260.0f, 18.0f)
                                                     textColor:[UIColor colorWithHexString:@"0x485156"]
                                                   shadowColor:TRANSPARENT_COLOR
                                                          font:FONT(15)] autorelease];
        [cellLabel setText:[[[self setCellTextData] objectForKey:[NSNumber numberWithInt:indexPath.section + 20]] objectAtIndex:indexPath.row]];
        [cell.contentView addSubview:cellLabel];
//    }
    
    [cell.contentView setBackgroundColor:[UIColor clearColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([indexPath section])
    {
        case User_Setting_Section0_Type:
        {
            ChangePWDViewController *vc = [[[ChangePWDViewController alloc] initWithMOC:_MOC] autorelease];
            [CommonMethod pushViewController:vc withAnimated:YES];
        }
            break;
            
        case User_Setting_Section1_Type:
        {
            switch ([indexPath row])
            {
                case Change_Skin_Cell_Type:
                {
                    SkinListViewController *styleVC = [[[SkinListViewController alloc] initSkinList:self.parentVC] autorelease];
                    [CommonMethod pushViewController:styleVC withAnimated:YES];
                }
                    break;
                    
                case Change_Language_Cell_Type:
                {
                    LanguageListViewController *languageVC = [[[LanguageListViewController alloc] initWithParentVC:self.parentVC entrance:self refreshAction:@selector(refreshForLanguageSwitch)] autorelease];
                    
                    BaseNavigationController *languageNC = [[[BaseNavigationController alloc] initWithRootViewController:languageVC] autorelease];
                    [self.parentViewController presentViewController:languageNC animated:YES completion:nil];
                }
                    break;
                    
                case Clear_Cache_Cell_Type:
                {
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case User_Setting_Section2_Type:
        {
            AboutViewController *aboutVC = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil moc:_MOC];
            [CommonMethod pushViewController:aboutVC withAnimated:YES];
            [aboutVC release];
        }
            break;
            
        default:
            break;
    }
    
}

- (void)logoutClick:(id)sender
{
    DLog(@"LOG OUT CLICK....");
    [[AppManager instance].userDefaults rememberUsername:[[AppManager instance].userDefaults usernameRemembered] andPassword:@"" pswdStr:@"" emailName:@"" userId:@""];
    [AppManager instance].userId = @"";
    [AppManager instance].passwd = @"";
    
    [((ProjectAppDelegate *)APP_DELEGATE) logout];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    HomeContainerViewController *homeVC = (HomeContainerViewController *)self.parentVC;
    [homeVC selectFirstTabBar];
    [homeVC modifyFromTabBarFlag];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshForLanguageSwitch {
    if (_personalEntrance && _refreshAction) {
        [_personalEntrance performSelector:_refreshAction];
    }
    [self._setTableView reloadData];
    
    self.navigationItem.title = LocaleStringForKey(NSSettingsTitle, nil);
}

@end
