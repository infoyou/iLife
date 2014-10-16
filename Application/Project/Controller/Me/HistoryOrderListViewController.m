//
//  HistoryOrderListViewController.m
//  Project
//
//  Created by Adam on 14-9-3.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import "HistoryOrderListViewController.h"
#import "HistoryOrderDetailViewController.h"
#import "InformationDefault.h"

#define KSEARCHBAR_HEIGHT   44.0f
#define kTableSectionHeight 11.f

#define kTableFootheight    200

@implementation OrderItem

@synthesize orderId = _orderId;
@synthesize orderNo = _orderNo;
@synthesize orderTime = _orderTime;
@synthesize amount = _amount;
@synthesize orderDetail = _orderDetail;

- (void)dealloc
{
    [_orderId release];
    [_orderNo release];
    [_orderTime release];
    [_amount release];
    [_orderDetail release];
    
    [super dealloc];
}

@end

@interface HistoryOrderListViewController () <UISearchBarDelegate>
{
    UISearchBar *_searchBar;
    UITableView *_storeTable;
    UIView *_searchBGView;
}

@property (nonatomic, retain) UISearchBar *_searchBar;
@property (nonatomic, retain) UITableView *_storeTable;
@property (nonatomic, retain) UIView *_searchBGView;

@end


@implementation HistoryOrderListViewController
{
    int defaultIndex;
    NSMutableArray *_orderArray;
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
        self.title = @"历史订单";
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
    
    _orderArray = [[NSMutableArray alloc] initWithCapacity:10];
    
    [self getHistoryOrder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    self._storeTable = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStylePlain] autorelease];
    
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
    return _orderArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return HISTORY_ORDER_CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self drawCellContentWithTable:tableView atIndexPath:indexPath];
}

- (HistoryOrderListCell *)drawCellContentWithTable:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellIdentifier = @"HistoryOrderListCell";
    HistoryOrderListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    if (nil == cell)
    {
        cell = [[[HistoryOrderListCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:kCellIdentifier] autorelease];
    }
    [cell.contentView setBackgroundColor:[UIColor clearColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    OrderItem *orderItem = [_orderArray objectAtIndex:indexPath.row];
    [cell updataCellData:orderItem];
    
    UIView *lineView = [[[UIView alloc] initWithFrame:CGRectMake(11, HISTORY_ORDER_CELL_HEIGHT-1, SCREEN_WIDTH-11, 0.6f)] autorelease];
    lineView.backgroundColor = HEX_COLOR(@"0xdddddd");
    [cell.contentView addSubview:lineView];
    
    UIImage *nextImg = [UIImage imageNamed:@"me_detail"];
    UIImageView *moreUserMsgImg = [InformationDefault createImgViewWithFrame:CGRectMake(302, 16, 9.5f, 14.5f) withImage:nextImg withColor:[UIColor clearColor] withTag:10];
    [cell.contentView addSubview:moreUserMsgImg];
    
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"Click  Cell Index (%d)",indexPath.row);
    OrderItem *orderItem = [_orderArray objectAtIndex:indexPath.row];
    
    HistoryOrderDetailViewController *historyOrderDetailVC = [[[HistoryOrderDetailViewController alloc] initWithMOC:_MOC orderId:orderItem.orderNo] autorelease];
    
    [CommonMethod pushViewController:historyOrderDetailVC withAnimated:YES];

}

- (void)getHistoryOrder
{
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@%@", VALUE_API_PREFIX, API_SERVICE_USER, API_GET_HISTORY_ORDER];
    NSString *url = [ProjectAPI getURL:urlStr specialDict:nil];
    DLog(@"url = %@", url);
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:GET_HISTORY_ORDER_TY];
    
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
            
        case GET_HISTORY_ORDER_TY:
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
                
//                "OrderId": "D20C3D8A-D1DA-5223-0EC6-99EC11EB21F6",
//                "OrderNo": "100314487775",
//                "OrderTime": "2014-9-19",
//                "Amount": "50.6",
//                "HistoryOrderDetail"
                
                NSArray *list = OBJ_FROM_DIC(dict, @"HistoryOrder");
                for (NSDictionary *dic in list) {
                    NSString *orderId = STRING_VALUE_FROM_DIC(dic, @"OrderId");
                    NSString *orderNo = STRING_VALUE_FROM_DIC(dic, @"OrderNo");
                    NSString *orderTime = STRING_VALUE_FROM_DIC(dic, @"OrderTime");
                    NSString *amount = STRING_VALUE_FROM_DIC(dic, @"Amount");
                    NSString *orderDetail = STRING_VALUE_FROM_DIC(dic, @"HistoryOrderDetail");
                    
                    OrderItem *orderItem = [[OrderItem alloc] init];
                    orderItem.orderId = orderId;
                    orderItem.orderNo = orderNo;
                    orderItem.orderTime = orderTime;
                    orderItem.amount = amount;
                    orderItem.orderDetail = orderDetail;
                    
                    [_orderArray addObject:orderItem];
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
