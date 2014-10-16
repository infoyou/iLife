
#import "LanguageListViewController.h"
#import "WXWUIUtils.h"
#import "AppManager.h"
#import "WXWLabel.h"

#define FONT_SIZE           16
#define LABEL_Y             10

#define LANGUAGE_LIST_CELL_HEIGHT   50

@interface LanguageListViewController () <AppSettingDelegate>
{
    BOOL isFirst;
    
    UIViewController *_parentVC;
    
    id _entrance;
    SEL _refreshAction;
    int selectIndex;
}

@end

@implementation LanguageListViewController

- (id)initWithParentVC:(UIViewController *)parentVC
              entrance:(id)entrance
         refreshAction:(SEL)refreshAction {
    
    self = [super init];
    
    if (self) {
        
        _parentVC = parentVC;
        
        _entrance = entrance;
        _refreshAction = refreshAction;
        
        // Custom initialization
        if ([WXWCommonUtils currentLanguage] == EN_TY)
        {
            selectIndex = 0;
        } else {
            selectIndex = 1;
        }
    }
    return self;
}

- (void)dealloc
{
    isFirst = NO;
    [super dealloc];
}

- (void)initNavibar
{
    [self addLeftBarButtonWithTitle:LocaleStringForKey(NSCancelTitle,nil)
                             target:self
                             action:@selector(doClose:)];
	
//    self.title = LocaleStringForKey(NSLanguageTitle,nil);

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = TRANSPARENT_COLOR;
    label.font = [UIFont boldSystemFontOfSize:18.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [[ThemeManager shareInstance] getColorWithName:@"kNaviBarTitleLabel"];
    self.navigationItem.titleView = label;
    label.text = LocaleStringForKey(NSLanguageTitle,nil);
    [label sizeToFit];
    
	// done
    [self addRightBarButtonWithTitle:LocaleStringForKey(NSDoneTitle,nil)
                              target:self
                              action:@selector(doResetLanguage:)];
}

- (void)initTableView
{
    CGRect mTabFrame = CGRectMake(0, 0, SCREEN_WIDTH, self.view.frame.size.height);
	_tableView = [[UITableView alloc] initWithFrame:mTabFrame
                                              style:UITableViewStyleGrouped];
	
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_tableView.dataSource = self;
	_tableView.delegate = self;
    [_tableView setAllowsMultipleSelection:NO];
    _tableView.tintColor = [[ThemeManager shareInstance] getColorWithName:@"kNaviBarTitleLabel"];
    
    _tableView.backgroundView = nil;
	
	[self.view addSubview:_tableView];
//    [super initTableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initNavibar];
    [self initTableView];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - handle empty list
- (BOOL)listIsEmpty {
    return NO;
}

#pragma mark - table
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  LANGUAGE_LIST_CELL_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 17.6f;
}

-(void)configureCell:(NSIndexPath *)indexPath aCell:(UITableViewCell *)cell
{
    int row = [indexPath row];
    [cell setBackgroundColor:[UIColor whiteColor]];
    
    CGRect cellLableRect = CGRectMake(16.5f, (LANGUAGE_LIST_CELL_HEIGHT-18.0f)/2, 100.0f, 18.0f);
    switch (row) {
        case 0:
        {
            // Label
            WXWLabel *cellLabel = [[[WXWLabel alloc] initWithFrame:cellLableRect
                                                          textColor:[UIColor blackColor]
                                                        shadowColor:TRANSPARENT_COLOR
                                                               font:FONT(15)] autorelease];
            cellLabel.text = @"English";
            [cell.contentView addSubview:cellLabel];
        }
            break;
            
        case 1:
        {
            WXWLabel *cellLabel = [[[WXWLabel alloc] initWithFrame:cellLableRect
                                                         textColor:[UIColor blackColor]
                                                       shadowColor:TRANSPARENT_COLOR
                                                              font:FONT(15)] autorelease];
            cellLabel.text = @"中文";
            [cell.contentView addSubview:cellLabel];
        }
            break;
            
        default:
            break;
    }
    
    if (!isFirst && selectIndex == row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        isFirst = YES;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LanguageListCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSArray *subviews = [[NSArray alloc] initWithArray:cell.contentView.subviews];
    for (UIView *subview in subviews) {
        [subview removeFromSuperview];
    }
    [subviews release];
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    // Configure the cell...
    [self configureCell:indexPath aCell:cell];
    
    if (selectIndex == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] == selectIndex) {
        return;
    }
    
    int newRow = [indexPath row];
    
    if(newRow != selectIndex)
    {
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:selectIndex
                                                        inSection:0];
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:lastIndexPath];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        
        selectIndex = newRow;
    }
    
    [super deselectCell];
}

#pragma mark - back

- (void)doClose:(id)sender {
    //  [self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doResetLanguage:(id)sender
{
    switch (selectIndex) {
        case 0:
        {
            [[WXWSystemInfoManager instance] setLanguageWithType:EN_TY];
        }
            break;
            
        case 1:
        {
            [[WXWSystemInfoManager instance] setLanguageWithType:ZH_HANS_TY];
        }
            break;
            
        default:
            break;
    }
    
    [self triggerReloadForLanguageSwitch];
}

#pragma mark - ECAppSettingDelegate method
- (void)triggerReloadForLanguageSwitch {
    if (ZH_HANS_TY == [WXWSystemInfoManager instance].currentLanguageCode) {
        [WXWUIUtils showActivityView:self.view text:@"正在切换语言..."];
    } else {
        [WXWUIUtils showActivityView:self.view text:@"Setting Language..."];
    }
    
    [WXWCommonUtils setLanguage:[WXWSystemInfoManager instance].currentLanguageDesc];
    [[AppManager instance] reloadForLanguageSwitch:self];
}

- (void)languageSwitchDone {
    
    // refresh tab bar item of homepage
    if (_parentVC && [_parentVC respondsToSelector:@selector(refreshTabItems)]) {
        [_parentVC performSelector:@selector(refreshTabItems)];
    }
    
    if (_entrance && _refreshAction) {
        [_entrance performSelector:_refreshAction];
    }
    
    [WXWUIUtils closeActivityView];
    
    [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSLanguageSwitchDoneMsg, nil)
                              alternativeMsg:nil
                                     msgType:SUCCESS_TY
                          belowNavigationBar:YES];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)closeSpinView {
    [WXWUIUtils closeActivityView];
}

@end
