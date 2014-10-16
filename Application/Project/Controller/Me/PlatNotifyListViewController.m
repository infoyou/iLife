//
//  PlatNotifyListViewController.m
//  Project
//
//  Created by Adam on 14-9-3.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import "PlatNotifyListViewController.h"
#import "PlatNotifyDetailViewController.h"

#define KSEARCHBAR_HEIGHT 44.0f

@implementation MessageItem

@synthesize messageID = _messageID;
@synthesize messageTime = _messageTime;
@synthesize title = _title;
@synthesize body = _body;

- (void)dealloc
{
    [_messageID release];
    [_messageTime release];
    [_title release];
    [_body release];
    
    [super dealloc];
}

@end

@interface PlatNotifyListViewController () <UISearchBarDelegate>
{
    UISearchBar *_searchBar;
    UITableView *_storeTable;
    UIView *_searchBGView;
    NSMutableArray *_messageArray;
}

@property (nonatomic, retain) UISearchBar *_searchBar;
@property (nonatomic, retain) UITableView *_storeTable;
@property (nonatomic, retain) UIView *_searchBGView;

@end


@implementation PlatNotifyListViewController
{
    int defaultIndex;
}

@synthesize _searchBar;
@synthesize _storeTable;
@synthesize _searchBGView;


- (void)dealloc
{
    [_searchBar release];
    [_storeTable release];
    [super dealloc];
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
         parentVC:(RootViewController *)pVC
{
    
    self = [super initWithMOC:MOC
        needRefreshHeaderView:NO
        needRefreshFooterView:NO];
    
    if (self) {
        self.parentVC = pVC;
        defaultIndex = 0;
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"平台通知";
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:[self setStoreTable]];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [_tableView setAlpha:0];
    
    _messageArray = [[NSMutableArray alloc] initWithCapacity:10];
    
    [self getSystemMessage];
}

- (UISearchBar *)createSearchBar
{
    CGRect searchRect = CGRectMake(0, 0, SCREEN_WIDTH, KSEARCHBAR_HEIGHT);
    self._searchBar = [[[UISearchBar alloc]initWithFrame:searchRect] autorelease];
    [_searchBar setDelegate:self];
    [_searchBar setBarStyle:UIBarStyleDefault];
    [_searchBar setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [_searchBar setPlaceholder:LocaleStringForKey(NSSearchTitle, nil)];
    [_searchBar setKeyboardType:UIKeyboardTypeDefault];
    [_searchBar setTintColor:[UIColor lightGrayColor]];
    //    [m_searchBar setInputAccessoryView:[self setAccessoryView]];
    return self._searchBar;
}

- (UITableView *)setStoreTable
{
    self._storeTable = [[[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStylePlain]autorelease];
    [_storeTable setBackgroundColor:[UIColor whiteColor]];
    [_storeTable setDataSource:self];
    [_storeTable setDelegate:self];
    [_storeTable setAllowsMultipleSelection:NO];
    [_storeTable setSeparatorInset:UIEdgeInsetsMake(0, 11, 0, 0)];
//    [_storeTable setTableHeaderView:[self createSearchBar]];
    [_storeTable setSeparatorColor:TRANSPARENT_COLOR];
    
    return self._storeTable;
}

#pragma mark - Search Delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    
    self._searchBGView = [[[UIView alloc] initWithFrame:CGRectMake(0, KSEARCHBAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - KSEARCHBAR_HEIGHT)] autorelease];
    self._searchBGView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    
    UITapGestureRecognizer *tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(cancelSearch:)] autorelease];
    [self._searchBGView addGestureRecognizer:tapGesture];
    
    [self.view addSubview:self._searchBGView];
    
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self._searchBGView.alpha = 0.8f;
                     }];
}

- (void)cancelSearch:(UITapGestureRecognizer *)tapGesture
{
    [self disableSearchStatus];
}

- (void)disableSearchStatus {
    
    if (self._searchBGView.alpha > 0.0f && _searchBar.isFirstResponder) {
        [UIView animateWithDuration:0.2f
                         animations:^{
                             self._searchBGView.alpha = 0.0f;
                         }
                         completion:^(BOOL finished){
                             [self._searchBGView removeFromSuperview];
                         }];
        
        [_searchBar resignFirstResponder];
        
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //TODO:
    [self disableSearchStatus];
    
}


#pragma mark - TableView Methods


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _messageArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return PLAT_NOTIFY_CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self drawCellContentWithTable:tableView atIndexPath:indexPath];
}

- (PlatNotifyListCell *)drawCellContentWithTable:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellIdentifier = @"PlatNotifyListCell";
    PlatNotifyListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (nil == cell)
    {
        cell = [[[PlatNotifyListCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:kCellIdentifier] autorelease];
    }
    [cell.contentView setBackgroundColor:[UIColor clearColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    MessageItem *orderItem = [_messageArray objectAtIndex:indexPath.row];
    [cell updataCellData:orderItem];
    
    UIView *lineView = [[[UIView alloc] initWithFrame:CGRectMake(11, PLAT_NOTIFY_CELL_HEIGHT-1, SCREEN_WIDTH-11, 0.6f)] autorelease];
    lineView.backgroundColor = HEX_COLOR(@"0xdddddd");
    [cell.contentView addSubview:lineView];
    
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"Click  Cell Index (%d)",indexPath.row);
    
    MessageItem *orderItem = [_messageArray objectAtIndex:indexPath.row];
    
    // 平台通知明细
    PlatNotifyDetailViewController *platNotifyDetail = [[[PlatNotifyDetailViewController alloc] initWithNibName:@"PlatNotifyDetailViewController" bundle:nil
                                                     moc:nil orderItem:orderItem] autorelease];
    
    [CommonMethod pushViewController:platNotifyDetail withAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getSystemMessage
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@%@", VALUE_API_PREFIX, API_SERVICE_USER, API_GET_SYSTEM_MESSAGE];
    NSString *url = [ProjectAPI getURL:urlStr specialDict:nil];
    DLog(@"url = %@", url);
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:GET_SYSTEM_MESSAGE_TY];
    
    [connFacade fetchGets:url];
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType {
    [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil) blockCurrentView:YES];
    
    [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
    
    switch (contentType) {
            
        case GET_SYSTEM_MESSAGE_TY:
        {
            ConnectionAndParserResultCode ret = [JSONParser parserResponseJsonData:result
                                                                              type:contentType
                                                                               MOC:_MOC
                                                                 connectorDelegate:self
                                                                               url:url
                                                                           paramID:0];
            
            if (ret == SUCCESS_CODE) {
                
                NSDictionary *resultDict = [result objectFromJSONData];
                NSDictionary *dict = OBJ_FROM_DIC(resultDict, @"Data");
                
                NSArray *list = OBJ_FROM_DIC(dict, @"SystemMessage");
                
                for (NSDictionary *dic in list) {
                    
                    NSString *messageID = STRING_VALUE_FROM_DIC(dic, @"MessageID");
                    NSString *messageTime = STRING_VALUE_FROM_DIC(dic, @"MessageTime");
                    NSString *title = STRING_VALUE_FROM_DIC(dic, @"Title");
                    NSString *body = STRING_VALUE_FROM_DIC(dic, @"Body");
                    
                    MessageItem *orderItem = [[MessageItem alloc] init];
                    orderItem.messageID = messageID;
                    orderItem.messageTime = messageTime;
                    orderItem.title = title;
                    orderItem.body = body;
                    
                    [_messageArray addObject:orderItem];
                }
                
                [self._storeTable reloadData];
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
    
    if ([self connectionMessageIsEmpty:error]) {
        self.connectionErrorMsg = LocaleStringForKey(NSActionFaildMsg, nil);
    }
    
    [super connectFailed:error url:url contentType:contentType];
}

@end
