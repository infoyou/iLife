
#import "HistoryOrderDetailViewController.h"
#import "OrderPayViewController.h"

@implementation HistoryOrderTotal

@synthesize orderId = _orderId;
@synthesize orderNo = _orderNo;
@synthesize orderTime = _orderTime;
@synthesize totalAmount = _totalAmount;
@synthesize detailArray = _detailArray;
@end

@implementation HistoryOrderDetail

@synthesize itemName = _itemName;
@synthesize weight = _weight;
@synthesize realWeight = _realWeight;
@synthesize itemAmount = _itemAmount;
@synthesize status = _status;

@end

enum Button_Order_State_Tag_Enum
{
    BTN_ORDER_CANCEL_TAG = 21,
    BTN_ORDER_PAY_TAG,
};

@interface HistoryOrderDetailViewController () {
    
    int switchBtnIndex;
    NSMutableArray *_orderArray;
    NSString *_orderId;
}

@end

@implementation HistoryOrderDetailViewController {
    
    NSMutableDictionary* mImgCacheDic;
}

- (id)initWithMOC:(NSManagedObjectContext*)viewMOC orderId:(NSString *)orderId {
    
    self = [super initNoNeedDisplayEmptyMessageTableWithMOC:viewMOC
                                      needRefreshHeaderView:NO
                                      needRefreshFooterView:NO
                                                 tableStyle:UITableViewStylePlain];
    
    if (self) {
        _orderArray = [[NSMutableArray alloc] initWithCapacity:10];
        switchBtnIndex = 0;
        _orderId = orderId;
        
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"历史订单";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self prepareData];
    
    if ([WXWCommonUtils currentOSVersion] < IOS7) {
        self.view.frame = CGRectOffset(self.view.frame, 0, -20);
    }
    
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setShowsVerticalScrollIndicator:NO];
    
    _tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64);
    
    [self getOrderPayList];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
}

#pragma mark - prepare Data
- (void)prepareData
{
    mImgCacheDic = [[NSMutableDictionary alloc] initWithCapacity:10];
}

#pragma mark - table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    switch(switchBtnIndex)
    {
        case 0:
        {
            if ([_orderArray count] > 0) {
                return ((HistoryOrderTotal *)_orderArray[0]).detailArray.count;
            } else {
                return 1;
            }
        }
            
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch(switchBtnIndex)
    {
        case 0:
        {
            if ([_orderArray count] > 0) {
                HistoryOrderTotal *historyOrderTotal = (HistoryOrderTotal *)_orderArray[0];
                return [historyOrderTotal.detailArray[section] count];
            } else {
                return 0;
            }
        }
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    switch(switchBtnIndex)
    {
        case 0:
        {
            return 50;
        }
            
        case 1:
        {
            return 58;
        }
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch(switchBtnIndex)
    {
        case 0:
        {
            if (section == 0)
                return 70.f;
            else
                return 0.f;
        }
            
        case 1:
        {
            return 33.f;
        }
    }
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    switch(switchBtnIndex)
    {
        case 0:
        {
            
            if ([_orderArray count] > 0 && section == 0) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"OrderStateCellSection" owner:self options:nil];
                UITableViewCell* cell = [nib objectAtIndex:0];
                
                UIButton *cancelBtn = (UIButton *)[cell viewWithTag:BTN_ORDER_CANCEL_TAG];
                cancelBtn.layer.cornerRadius = 3.f;
                cancelBtn.layer.masksToBounds = YES;
                cancelBtn.hidden = YES;
                [cancelBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
                
                UIButton *payBtn = (UIButton *)[cell viewWithTag:BTN_ORDER_PAY_TAG];
                payBtn.layer.cornerRadius = 3.f;
                payBtn.layer.masksToBounds = YES;
                payBtn.hidden = YES;
                [payBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];

                UILabel *orderTime = (UILabel*)[cell viewWithTag:9];
                UILabel *orderTitle = (UILabel*)[cell viewWithTag:10];
                UILabel *totalAmount = (UILabel*)[cell viewWithTag:11];
                
                orderTime.hidden = NO;
                
                HistoryOrderTotal *orderTotal = (HistoryOrderTotal *)_orderArray[section];
                orderTitle.text = [NSString stringWithFormat:@"订单编号: %@", orderTotal.orderNo];
                totalAmount.text = [NSString stringWithFormat:@"总计: %@元", orderTotal.totalAmount];
                orderTime.text = orderTotal.orderTime;
                
                return cell.contentView;
            } else {
                return nil;
            }
        }
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    switch(switchBtnIndex)
    {
        case 0:
        {
            return 10.f;
        }
            
        case 1:
        {
            return 10.f;
        }
    }
    
    return 0;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)] autorelease];
    footView.backgroundColor = HEX_COLOR(@"0xf7f7f7");
    
    return footView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int row = indexPath.row;
    int section = indexPath.section;
    
    switch(switchBtnIndex)
    {
        case 0:
        {
            static NSString *materialCellIdentifier = @"OrderStateCellIdentifier";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:materialCellIdentifier];
            
            if (cell != nil) {
                for (UIView *subView in cell.contentView.subviews)
                {
                    [subView removeFromSuperview];
                }
            }
            
//            if (cell == nil) {
            
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"OrderStateCell" owner:self options:nil];
                
                cell = [nib objectAtIndex:0];
//            }
            
            UILabel *skuName = (UILabel*)[cell viewWithTag:10];
            UILabel *weight = (UILabel*)[cell viewWithTag:11];
            UILabel *price = (UILabel*)[cell viewWithTag:12];
            UILabel *state = (UILabel*)[cell viewWithTag:13];
            
            HistoryOrderTotal *historyOrderTotal = (HistoryOrderTotal *)_orderArray[0];
            HistoryOrderDetail *orderDetail = historyOrderTotal.detailArray[section][row];
            
            skuName.text = orderDetail.itemName;
            weight.text = [NSString stringWithFormat:@"%@克", orderDetail.realWeight];
            price.text = [NSString stringWithFormat:@"已购%@克/%@元", orderDetail.weight, orderDetail.itemAmount];
            state.text = [CommonUtils getOrderStateName:[[NSString stringWithFormat:@"%@",orderDetail.status] intValue]];
            
            if ([state.text isEqualToString:@"抢光了"]) {
                state.textColor = HEX_COLOR(@"0xcc0000");
            }
            
            if (indexPath.row != 0) {
                UIView *splitView = [[[UIView alloc] initWithFrame:CGRectMake(10, 1, SCREEN_WIDTH-10, 1)] autorelease];
                splitView.backgroundColor = HEX_COLOR(@"0xe5e5e5");
                [cell.contentView addSubview:splitView];
            }

            return cell;
        }
    }
    
    return nil;
}

- (void)getOrderPayList
{
    
    NSMutableDictionary *specialDict = [NSMutableDictionary dictionary];
    [specialDict setValue:_orderId forKey:@"OrderNo"];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@%@", VALUE_API_PREFIX, API_SERVICE_USER, API_GET_ORDER_DETAIL];
    NSString *url = [ProjectAPI getURL:urlStr specialDict:specialDict];
    DLog(@"url = %@", url);
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:API_ORDER_LIST_TY];
    
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
            
        case API_ORDER_LIST_TY:
        {
            ConnectionAndParserResultCode ret = [JSONParser parserResponseJsonData:result
                                                                              type:contentType
                                                                               MOC:_MOC
                                                                 connectorDelegate:self
                                                                               url:url
                                                                           paramID:0];
            
            if (ret == SUCCESS_CODE) {
                
                [_orderArray removeAllObjects];
                
                NSDictionary *resultDict = [result objectFromJSONData];
                NSDictionary *dict = OBJ_FROM_DIC(resultDict, @"Data");
                
                NSDictionary *historyOrderDict = OBJ_FROM_DIC(dict, @"HistoryOrderDetail");
                
                if (historyOrderDict != nil) {
                    
                    HistoryOrderTotal *orderTotal = [[HistoryOrderTotal alloc] init];
                    orderTotal.orderId = STRING_VALUE_FROM_DIC(historyOrderDict, @"OrderId");
                    orderTotal.orderNo = STRING_VALUE_FROM_DIC(historyOrderDict, @"OrderNo");
                    orderTotal.orderTime = STRING_VALUE_FROM_DIC(historyOrderDict, @"OrderTime");
                    orderTotal.totalAmount = STRING_VALUE_FROM_DIC(historyOrderDict, @"Amount");
                    
                    NSArray *sellOrderList = OBJ_FROM_DIC(historyOrderDict, @"HistorySellOrderDetail");
                    NSMutableArray *sellOrderArray = [NSMutableArray array];
                    
                    for (NSDictionary *sellDic in sellOrderList) {
                        
                        NSArray *sellOrderList = OBJ_FROM_DIC(sellDic, @"HistoryItemdetail");
                        NSString *status = STRING_VALUE_FROM_DIC(sellDic, @"Status");
                        
                        NSMutableArray *orderDetailArray = [NSMutableArray array];
                        
                        for (NSDictionary *dic in sellOrderList) {
                            HistoryOrderDetail *orderDetail = [[HistoryOrderDetail alloc] init];
                            orderDetail.itemName = STRING_VALUE_FROM_DIC(dic, @"ItemName");
                            orderDetail.realWeight = STRING_VALUE_FROM_DIC(dic, @"RealWeight");
                            orderDetail.weight = STRING_VALUE_FROM_DIC(dic, @"Weight");
                            orderDetail.itemAmount = STRING_VALUE_FROM_DIC(dic, @"ItemAmount");
                            orderDetail.status = status;
                            
                            [orderDetailArray addObject:orderDetail];
                        }
                        
                        [sellOrderArray addObject:orderDetailArray];
                    }
                    
                    orderTotal.detailArray = sellOrderArray;
                    
                    [_orderArray addObject:orderTotal];
                }
                
                [_tableView reloadData];
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
