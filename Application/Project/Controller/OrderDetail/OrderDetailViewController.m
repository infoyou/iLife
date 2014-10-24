
#import "OrderDetailViewController.h"
#import "OrderPayViewController.h"
#import "LoginViewController.h"
#import "UIViewController+JSONValue.h"

#define LOGIN_TAG  1

@implementation OrderTotal

@synthesize orderId = _orderId;
@synthesize orderNo = _orderNo;
@synthesize totalAmount = _totalAmount;
@synthesize orderCanPay = _orderCanPay;
@synthesize orderCanCancel = _orderCanCancel;
@synthesize groupArray = _groupArray;
@end

@implementation OrderDetail

@synthesize orderDetailId = _orderDetailId;
@synthesize itemId = _itemId;
@synthesize skuId = _skuId;
@synthesize itemName = _itemName;
@synthesize itemUnit = _itemUnit;
@synthesize purchaseWeight = _purchaseWeight;
@synthesize realWeight = _realWeight;
@synthesize realAmount = _realAmount;
@synthesize orderStatus = _orderStatus;
@synthesize isFirst = _isFirst;
@end

@implementation OrderCompletedTotal
@synthesize orderId = _orderId;
@synthesize orderNo = _orderNo;
@synthesize orderTime = _orderTime;
@synthesize detailArray = _detailArray;
@end

@implementation OrderCompletedDetail

@synthesize deliverOrderID = _deliverOrderID;
@synthesize itemCategoryId = _itemCategoryId;
@synthesize itemCategoryName = _itemCategoryName;
@synthesize unitID = _unitID;
@synthesize unitName = _unitName;
@synthesize goodCount = _goodCount;
@synthesize normalCount = _normalCount;
@synthesize badCount = _badCount;
@synthesize evaluationTypeID = _evaluationTypeID;
@synthesize itemCount = _itemCount;

@end

enum Button_Switch_Enum
{
    ORDERSTATE_CELL_BTN_TAG,
    EVALUATION_BTN_TAG,
};

enum Button_Order_State_Tag_Enum
{
    BTN_ORDER_CANCEL_TAG = 21,
    BTN_ORDER_PAY_TAG,
};

enum Button_Evaluation_Tag_Enum
{
    BTN_GOOD_TAG = 10,
    BTN_OK_TAG,
    BTN_BAD_TAG,
    BTN_HAPPY_TAG,
    BTN_SAD_TAG,
};

#define SWITCH_BTN_H       45

@interface OrderDetailViewController () {
    
    NSMutableArray *_orderArray;
    NSMutableArray *_orderCompletedArray;
}

@end

@implementation OrderDetailViewController {
    
    int switchBtnIndex;
    NSMutableDictionary* mImgCacheDic;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
       viewHeight:(CGFloat)viewHeight
  homeContainerVC:(RootViewController *)homeContainerVC {
    
    self = [super initNoNeedDisplayEmptyMessageTableWithMOC:MOC
                                      needRefreshHeaderView:NO
                                      needRefreshFooterView:NO
                                                 tableStyle:UITableViewStylePlain];
    if (self) {
        self.parentVC = homeContainerVC;
        _viewHeight = viewHeight;
        _orderArray = [[NSMutableArray alloc] initWithCapacity:10];
        _orderCompletedArray = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
    if ([AppManager instance].passwd && [[AppManager instance].passwd length]>0) {
        [self getOrderPayList];
    } else {
        [self askWithMessage:@"尚未登录，请先登录" alertTag:LOGIN_TAG];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self prepareData];
    
    if ([WXWCommonUtils currentOSVersion] < IOS7) {
        self.view.frame = CGRectOffset(self.view.frame, 0, -20);
    }
    
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setShowsVerticalScrollIndicator:NO];
    _tableView.frame = CGRectMake(0, SWITCH_BTN_H, SCREEN_WIDTH, SCREEN_HEIGHT - SWITCH_BTN_H - 64 - HOMEPAGE_TAB_HEIGHT);
    [self addSwitchButton];

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
    switchBtnIndex = 0;
    mImgCacheDic = [[NSMutableDictionary alloc] initWithCapacity:10];

}

#pragma mark - table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    switch(switchBtnIndex)
    {
        case 0:
        {
            if ([_orderArray count] > 0) {
                return [_orderArray count];
            } else {
                return 1;
            }
        }
            
        case 1:
        {
            if ([_orderCompletedArray count] > 0) {
                return _orderCompletedArray.count;
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
                OrderTotal *orderTotal = (OrderTotal *)_orderArray[section];
                return [orderTotal.groupArray count];
            } else {
                return 0;
            }
        }
            
        case 1:
        {
            if ([_orderCompletedArray count] > 0) {
                return ((OrderCompletedTotal *)_orderCompletedArray[section]).detailArray.count;
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
            if ([_orderArray count] > 0) {
                return 50;
            } else {
                return 0;
            }
        }
            
        case 1:
        {
            if ([_orderCompletedArray count] > 0) {
                return 58;
            } else {
                return 0;
            }
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
            if ([_orderArray count] > 0) {
                return 70.f;
            } else {
                return 0;
            }
        }
            
        case 1:
        {
            if ([_orderCompletedArray count] > 0) {
                return 33.f;
            } else {
                return 0;
            }
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
            
            if ([_orderArray count] > 0) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"OrderStateCellSection" owner:self options:nil];
                UITableViewCell* cell = [nib objectAtIndex:0];
                
                UIButton *cancelBtn = (UIButton *)[cell viewWithTag:BTN_ORDER_CANCEL_TAG];
                cancelBtn.layer.cornerRadius = 3.f;
                cancelBtn.layer.masksToBounds = YES;
                cancelBtn.tag = section * 1000 + BTN_ORDER_CANCEL_TAG;
                [cancelBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
                
                UIButton *payBtn = (UIButton *)[cell viewWithTag:BTN_ORDER_PAY_TAG];
                payBtn.layer.cornerRadius = 3.f;
                payBtn.layer.masksToBounds = YES;
                payBtn.tag = section * 1000 + BTN_ORDER_PAY_TAG;
                [payBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
                
                OrderTotal *orderTotal = (OrderTotal *)_orderArray[section];
                
                UILabel *orderTitle = (UILabel*)[cell viewWithTag:10];
                UILabel *totalAmount = (UILabel*)[cell viewWithTag:11];
                
                // button enable by order status
                orderTitle.text = [NSString stringWithFormat:@"订单编号: %@", orderTotal.orderNo];
                totalAmount.text = [NSString stringWithFormat:@"总计: %@元", orderTotal.totalAmount];
                
                // --------- cancel enable start
                if (![@"1" isEqualToString:orderTotal.orderCanPay]) {
                    [cancelBtn setBackgroundColor:HEX_COLOR(@"0xbebebe")];
                    [cancelBtn setEnabled:NO];
                } else {
                    [cancelBtn setBackgroundColor:HEX_COLOR(@"0xff9449")];
                    [cancelBtn setEnabled:YES];
                }
                // --------- cancel enable end
                
                // --------- pay enable start
                if (![@"1" isEqualToString:orderTotal.orderCanCancel]) {
                    [payBtn setBackgroundColor:HEX_COLOR(@"0xbebebe")];
                    [payBtn setEnabled:NO];
                } else {
                    [payBtn setBackgroundColor:HEX_COLOR(@"0xff9449")];
                    [payBtn setEnabled:YES];
                }
                // --------- pay enable end
                
                return cell.contentView;
            } else {
                return nil;
            }
            
        }
            
        case 1:
        {
            
            if ([_orderCompletedArray count] > 0) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"EvaluationCellSection" owner:self options:nil];
                UITableViewCell* cell = [nib objectAtIndex:0];
                
                UILabel *orderTitle = (UILabel*)[cell viewWithTag:10];
                UILabel *timeTitle = (UILabel*)[cell viewWithTag:11];
                
                OrderCompletedTotal *orderTotal = (OrderCompletedTotal *)_orderCompletedArray[section];
                orderTitle.text = [NSString stringWithFormat:@"订单编号: %@", orderTotal.orderNo];
                timeTitle.text = orderTotal.orderTime;
                
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
            UILabel *orderState = (UILabel*)[cell viewWithTag:13];
            
            NSMutableArray *orderDetailArray = ((OrderTotal *)_orderArray[section]).groupArray[row];
            
            OrderDetail *orderDetail = orderDetailArray[0];
            skuName.text = orderDetail.itemName;
            weight.text = [NSString stringWithFormat:@"%@%@", orderDetail.realWeight, orderDetail.itemUnit];
            price.text = [NSString stringWithFormat:@"已购%@%@/%@元", orderDetail.purchaseWeight, orderDetail.itemUnit, orderDetail.realAmount];
            orderState.text = [CommonUtils getOrderStateName:[[NSString stringWithFormat:@"%@",orderDetail.orderStatus] intValue]];
            
            if (orderDetail.isFirst && row != 0) {
                int spliteH = 5;
                UIView *splitTopView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)] autorelease];
                splitTopView.backgroundColor = HEX_COLOR(@"0xe8e8e8");
                [cell.contentView addSubview:splitTopView];
                
                UIView *splitView = [[[UIView alloc] initWithFrame:CGRectMake(0, 1, SCREEN_WIDTH, spliteH)] autorelease];
                splitView.backgroundColor = HEX_COLOR(@"0xf7f7f7");
                [cell.contentView addSubview:splitView];
                
                UIView *splitBottomView = [[[UIView alloc] initWithFrame:CGRectMake(0, spliteH+1, SCREEN_WIDTH, 1)] autorelease];
                splitBottomView.backgroundColor = HEX_COLOR(@"0xe8e8e8");
                [cell.contentView addSubview:splitBottomView];
            } else if (indexPath.row != 0) {
                UIView *splitView = [[[UIView alloc] initWithFrame:CGRectMake(10, 1, SCREEN_WIDTH-10, 1)] autorelease];
                splitView.backgroundColor = HEX_COLOR(@"0xe5e5e5");
                [cell.contentView addSubview:splitView];
            }

            return cell;
        }
            
        case 1:
        {
            static NSString *materialCellIdentifier = @"EvaluationCellIdentifier";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:materialCellIdentifier];
            
            if (cell != nil) {
                for (UIView *subView in cell.contentView.subviews)
                {
                    [subView removeFromSuperview];
                }
            }
            
//            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"EvaluationCell" owner:self options:nil];
                
                cell = [nib objectAtIndex:0];
//            }
            
            UILabel *skuName = (UILabel*)[cell viewWithTag:5];
            UILabel *unitName = (UILabel*)[cell viewWithTag:6];
            
            UILabel *goodNum = (UILabel*)[cell viewWithTag:110];
            UILabel *okNum = (UILabel*)[cell viewWithTag:111];
            UILabel *badNum = (UILabel*)[cell viewWithTag:112];
            
            OrderCompletedDetail *orderDetail = ((OrderCompletedTotal *)_orderCompletedArray[section]).detailArray[row];
            
            skuName.text = orderDetail.itemCategoryName;
            unitName.text = orderDetail.unitName;
            goodNum.text = [NSString stringWithFormat:@"%@", orderDetail.goodCount];
            okNum.text = [NSString stringWithFormat:@"%@", orderDetail.normalCount];
            badNum.text = [NSString stringWithFormat:@"%@", orderDetail.badCount];
            
            UIImageView *goodImgView = (UIImageView*)[cell.contentView viewWithTag:BTN_GOOD_TAG];
            UIImageView *okImgView = (UIImageView*)[cell.contentView viewWithTag:BTN_OK_TAG];
            UIImageView *badImgView = (UIImageView*)[cell.contentView viewWithTag:BTN_BAD_TAG];
            UIImageView *happyImgView = (UIImageView*)[cell.contentView viewWithTag:BTN_HAPPY_TAG];
            UIImageView *sadImgView = (UIImageView*)[cell.contentView viewWithTag:BTN_SAD_TAG];
            
            row += 2;
            
            goodImgView.tag = row*5+section*1000;
            okImgView.tag = row*5+1+section*1000;
            badImgView.tag = row*5+2+section*1000;
            happyImgView.tag = row*5+3+section*1000;
            sadImgView.tag = row*5+4+section*1000;
            
            [self addTapGestureRecognizer:happyImgView];
            [self addTapGestureRecognizer:sadImgView];
            
            NSString *evaluationTypeIDStr = [NSString stringWithFormat:@"%@", orderDetail.evaluationTypeID];
            int evaluationTypeID = [evaluationTypeIDStr intValue];
            
            if (indexPath.row != 0) {
                UIView *splitView = [[[UIView alloc] initWithFrame:CGRectMake(10, 1, SCREEN_WIDTH-10, 1)] autorelease];
                splitView.backgroundColor = HEX_COLOR(@"0xe8e8e8");
                [cell.contentView addSubview:splitView];
            }
            
            switch (evaluationTypeID) {
                case 0:
                {
                    if (goodImgView.isHighlighted || okImgView.isHighlighted || badImgView.isHighlighted) {
                        return cell;
                    }
                    
                    [self addTapGestureRecognizer:goodImgView];
                    [self addTapGestureRecognizer:okImgView];
                    [self addTapGestureRecognizer:badImgView];
                }
                    break;
                    
                case 1:
                {
                    goodImgView.highlighted = YES;
                }
                    break;
                    
                case 2:
                {
                    okImgView.highlighted = YES;
                }
                    break;
                    
                case 3:
                {
                    badImgView.highlighted = YES;
                }
                    break;
                    
                default:
                    break;
            }
            
            return cell;
        }
    }
    
    return nil;
}

#pragma mark - switch btn
- (void)addSwitchButton
{
    
    // order state
    {
        UIButton *orderStateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [orderStateBtn setBackgroundColor:HEX_COLOR(@"0xfafafa")];
        //    [defaultButton setBackgroundImage:[CommonMethod createImageWithColor:[UIColor colorWithHexString:@"0x333333"]] forState:UIControlStateNormal];
        [orderStateBtn addTarget:self action:@selector(doOrderState) forControlEvents:UIControlEventTouchUpInside];
        orderStateBtn.tag = ORDERSTATE_CELL_BTN_TAG;
        orderStateBtn.frame = CGRectMake(0, 0, 160, SWITCH_BTN_H);
        
        orderStateBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [orderStateBtn setTitle:LocaleStringForKey(@"订单状态", nil) forState:UIControlStateNormal];
        [self.view addSubview:orderStateBtn];
        
        // bottom
        UIView *bottomView = [[[UIView alloc] initWithFrame:CGRectMake(0, SWITCH_BTN_H-5, 160.f, 5)] autorelease];
        bottomView.backgroundColor = HEX_COLOR(@"0x82bf24");
        [self.view addSubview:bottomView];
        
        if (switchBtnIndex == 0) {
            [orderStateBtn setTitleColor:HEX_COLOR(@"0x82bf24") forState:UIControlStateNormal];
            bottomView.hidden = NO;
        } else {
            [orderStateBtn setTitleColor:HEX_COLOR(@"0x666666") forState:UIControlStateNormal];
            bottomView.hidden = YES;
        }
    }
    
    // split line
    UIView *lineView = [[[UIView alloc] initWithFrame:CGRectMake(159.6, 10, 0.8f, SWITCH_BTN_H - 20)] autorelease];
    lineView.backgroundColor = HEX_COLOR(@"0xcccccc");
    [self.view addSubview:lineView];
    
    // evaluation
    {
        UIButton *evaluationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [evaluationBtn setBackgroundColor:HEX_COLOR(@"0xfafafa")];
        //    [defaultButton setBackgroundImage:[CommonMethod createImageWithColor:[UIColor colorWithHexString:@"0x333333"]] forState:UIControlStateNormal];
        [evaluationBtn addTarget:self action:@selector(doDefaultButton) forControlEvents:UIControlEventTouchUpInside];
        evaluationBtn.tag = EVALUATION_BTN_TAG;
        evaluationBtn.frame = CGRectMake(160, 0, 160, SWITCH_BTN_H);

        evaluationBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [evaluationBtn setTitle:LocaleStringForKey(@"评价", nil) forState:UIControlStateNormal];
        [self.view addSubview:evaluationBtn];
        
        // bottom
        UIView *bottomView = [[[UIView alloc] initWithFrame:CGRectMake(160.f, SWITCH_BTN_H-5, 160.f, 5)] autorelease];
        bottomView.backgroundColor = HEX_COLOR(@"0x82bf24");
        [self.view addSubview:bottomView];
        
        if (switchBtnIndex == 1) {
            [evaluationBtn setTitleColor:HEX_COLOR(@"0x82bf24") forState:UIControlStateNormal];
            bottomView.hidden = NO;
        } else {
            [evaluationBtn setTitleColor:HEX_COLOR(@"0x666666") forState:UIControlStateNormal];
            bottomView.hidden = YES;
        }

    }
    
    UIView *splitLine = [[UIView alloc] initWithFrame:CGRectMake(0, SWITCH_BTN_H-1, SCREEN_WIDTH, 1)];
    splitLine.backgroundColor = HEX_COLOR(@"0xd9d9d9");
    [self.view addSubview:splitLine];
    
    [_tableView reloadData];

}

- (void)doOrderState
{
    switchBtnIndex = 0;
    [self addSwitchButton];
    
    [self getOrderPayList];
}

- (void)doDefaultButton
{
    switchBtnIndex = 1;
    [self addSwitchButton];
    
    [self getCompletedOrderList];
}

#pragma mark - for gesture
- (void)addTapGestureRecognizer:(UIImageView*)targetImageview {
    UITapGestureRecognizer *swipeGR = [[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                               action:@selector(imageviewTouchEvents:)] autorelease];
    swipeGR.delegate = self;
    
    [targetImageview addGestureRecognizer:swipeGR];
    
    [mImgCacheDic setObject:targetImageview forKey:[NSString stringWithFormat:@"%d", targetImageview.tag]];
}

- (void)imageviewTouchEvents:(UIGestureRecognizer *)gestureRecognizer
{
    UIImageView *view = (UIImageView*)[gestureRecognizer view];
    int viewTag = view.tag;
    
    DLog(@"%d is touched",viewTag);
    
    if (switchBtnIndex == 1) {
        
        int tagValue = viewTag%1000;
        
        UIImageView *goodImgView = nil;
        UIImageView *okImgView = nil;
        UIImageView *badImgView = nil;
        
        // BTN_GOOD_TAG
        if (tagValue%5 == 0) {

            goodImgView = (UIImageView *)[mImgCacheDic objectForKey:[NSString stringWithFormat:@"%d", viewTag]];
            okImgView = (UIImageView *)[mImgCacheDic objectForKey:[NSString stringWithFormat:@"%d", viewTag + 1]];
            badImgView = (UIImageView *)[mImgCacheDic objectForKey:[NSString stringWithFormat:@"%d", viewTag + 2]];
        }
        
        // BTN_OK_TAG
        if (tagValue%5 == 1) {
            
            goodImgView = (UIImageView *)[mImgCacheDic objectForKey:[NSString stringWithFormat:@"%d", viewTag - 1]];
            okImgView = (UIImageView *)[mImgCacheDic objectForKey:[NSString stringWithFormat:@"%d", viewTag]];
            badImgView = (UIImageView *)[mImgCacheDic objectForKey:[NSString stringWithFormat:@"%d", viewTag + 1]];
        }
        
        // BTN_BAD_TAG
        if (tagValue%5 == 2) {
            
            goodImgView = (UIImageView *)[mImgCacheDic objectForKey:[NSString stringWithFormat:@"%d", viewTag - 2]];
            okImgView = (UIImageView *)[mImgCacheDic objectForKey:[NSString stringWithFormat:@"%d", viewTag - 1]];
            badImgView = (UIImageView *)[mImgCacheDic objectForKey:[NSString stringWithFormat:@"%d", viewTag]];
        }
        
        goodImgView.highlighted = NO;
        okImgView.highlighted = NO;
        badImgView.highlighted = NO;
        
        if (tagValue%5 == 0) {
            goodImgView.highlighted = YES;
            [self setOrderEvaluation:viewTag];
        } else if (tagValue%5 == 1) {
            okImgView.highlighted = YES;
            [self setOrderEvaluation:viewTag];
        } else if (tagValue%5 == 2) {
            badImgView.highlighted = YES;
            [self setOrderEvaluation:viewTag];
        }
        
//        if (!view.highlighted) {
//            view.highlighted = YES;
//        } else {
//            view.highlighted = NO;
//        }
        
        if (tagValue%5 == 3) {
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(NSNoteTitle, nil) message:@"是否将该卖家设为常用卖家?\n这将会替换当前的常用卖家." delegate:self cancelButtonTitle:NSLocalizedString(NSCancelTitle, nil) otherButtonTitles:NSLocalizedString(NSSureTitle, nil), nil];
            
            [alert showAlertViewWithCompleteBlock:^(NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    [self setPriorityStore:viewTag];
                }
            }];

        } else if (tagValue%5 == 4) {
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(NSNoteTitle, nil) message:@"是否拉黑该卖家?\n拉黑后该卖家7日内将不能再抢购您的订单." delegate:self cancelButtonTitle:NSLocalizedString(NSCancelTitle, nil) otherButtonTitles:NSLocalizedString(NSSureTitle, nil), nil];
            
            [alert showAlertViewWithCompleteBlock:^(NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    [self setBlackStore:viewTag];
                }
            }];
            
//            ShowAlertWithTwoButton(self, NSLocalizedString(NSNoteTitle, nil), @"是否拉黑该卖家?\n拉黑后该卖家7日内将不能再抢购您的订单.", NSLocalizedString(NSCancelTitle, nil),NSLocalizedString(NSSureTitle, nil));
        }
    }
    
//    [_tableView reloadData];
}

#pragma mark - btn Click
- (void)btnClick:(id)send
{
    UIButton *btn = (UIButton*)send;
    
    int tagValue = btn.tag;
    int btnTag = tagValue;
    
    if (tagValue > 1000) {
        btnTag = tagValue%1000;
    }
    
    switch(btnTag) {
            
        case BTN_ORDER_CANCEL_TAG:
        {
            NSLog(@"Cancel");
            [self doOrderCancel:tagValue];
            
            break;
        }
            
        case BTN_ORDER_PAY_TAG:
        {
            NSLog(@"Pay");
            [self doOrderPay:tagValue];
            
            break;
        }
    }
}

- (void)getOrderPayList
{
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@%@", VALUE_API_PREFIX, API_SERVICE_USER, API_ORDER_LIST];
    NSString *url = [ProjectAPI getURL:urlStr specialDict:nil];
    DLog(@"url = %@", url);
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:API_ORDER_LIST_TY];
    
    [connFacade fetchGets:url];
}

- (void)doOrderPay:(int)tag
{
    if ( [_orderArray count] > 0 ) {

        int section = 0;
        
        if (tag > 1000) {
            section = tag/1000;
        }
        
        OrderTotal *orderTotal = (OrderTotal *)_orderArray[section];

        OrderPayViewController *vc =
        [[[OrderPayViewController alloc] initWithMOC:_MOC orderNo:orderTotal.orderNo totalAmount:orderTotal.totalAmount orderId:orderTotal.orderId] autorelease];
        
        [CommonMethod pushViewController:vc withAnimated:YES];
    }
}

- (void)doOrderCancel:(int)tag
{
    if ( [_orderArray count] > 0 ) {

        int section = 0;
        
        if (tag > 1000) {
            section = tag/1000;
        }
        
        OrderTotal *orderTotal = (OrderTotal *)_orderArray[section];
        NSMutableDictionary *specialDict = [NSMutableDictionary dictionary];
        [specialDict setValue:orderTotal.orderId forKey:@"OrderID"];
        
        NSString *urlStr = [NSString stringWithFormat:@"%@/%@%@", VALUE_API_PREFIX, API_SERVICE_USER, API_ORDER_CANCEL];
        NSString *url = [ProjectAPI getURL:urlStr specialDict:specialDict];
        DLog(@"url = %@", url);
        WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                                  contentType:API_ORDER_CANCEL_TY];
        
        [connFacade fetchGets:url];
    }
}

- (void)getCompletedOrderList
{
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@%@", VALUE_API_PREFIX, API_SERVICE_USER, API_ORDER_COMPLETED_LIST];
    NSString *url = [ProjectAPI getURL:urlStr specialDict:nil];
    DLog(@"url = %@", url);
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:API_ORDER_COMPLETED_LIST_TY];
    
    [connFacade fetchGets:url];
}

- (void)setOrderEvaluation:(int)tag
{
    int section = 0;
    int row = 0;
    
    if (tag > 1000) {
        section = tag/1000;
        row = tag%1000/5 - 2;
    } else {
        row = tag/5 - 2;
    }
    
    NSLog(@"section = %d, row = %d", section, row);
    
    OrderCompletedDetail *orderDetail = ((OrderCompletedTotal *)_orderCompletedArray[section]).detailArray[row];
    
    int tagValue = tag%1000;
    
    int evaluationTypeID = 0;
    
    if (tagValue%5 == 0) {
        evaluationTypeID = 1;
    } else if (tagValue%5 == 1) {
        evaluationTypeID = 2;
    } else if (tagValue%5 == 2) {
        evaluationTypeID = 3;
    }
    
    NSMutableDictionary *specialDict = [NSMutableDictionary dictionary];
    [specialDict setValue:orderDetail.deliverOrderID forKey:@"OrderID"];
    [specialDict setValue:[NSString stringWithFormat:@"%d", evaluationTypeID] forKey:@"EvaluationTypeID"];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@%@", VALUE_API_PREFIX, API_SERVICE_USER, API_ORDER_EVALUATION];
    NSString *url = [ProjectAPI getURL:urlStr specialDict:specialDict];
    DLog(@"url = %@", url);
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:API_ORDER_EVALUATION_TY];
    
    [connFacade fetchGets:url];
}

- (void)setPriorityStore:(int)tag
{
    int section = 0;
    int row = 0;
    
    if (tag > 1000) {
        section = tag/1000;
        row = tag%1000/5 - 2;
    } else {
        row = tag/5 - 2;
    }
    
    NSLog(@"section = %d, row = %d", section, row);
    
    OrderCompletedDetail *orderDetail = ((OrderCompletedTotal *)_orderCompletedArray[section]).detailArray[row];
    
    NSMutableDictionary *specialDict = [NSMutableDictionary dictionary];
    [specialDict setValue:orderDetail.unitID forKey:@"UnitID"];
    [specialDict setValue:orderDetail.itemCategoryId forKey:@"ItemCategoryID"];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@%@", VALUE_API_PREFIX, API_SERVICE_USER, API_SELLER_PRIORITY];
    NSString *url = [ProjectAPI getURL:urlStr specialDict:specialDict];
    DLog(@"url = %@", url);
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:API_SELLER_PRIORITY_TY];
    
    [connFacade fetchGets:url];
}

- (void)setBlackStore:(int)tag
{
    int section = 0;
    int row = 0;
    
    if (tag > 1000) {
        section = tag/1000;
        row = tag%1000/5 - 2;
    } else {
        row = tag/5 - 2;
    }
    
    NSLog(@"section = %d, row = %d", section, row);
    
    OrderCompletedDetail *orderDetail = ((OrderCompletedTotal *)_orderCompletedArray[section]).detailArray[row];
    
    NSMutableDictionary *specialDict = [NSMutableDictionary dictionary];
    [specialDict setValue:orderDetail.unitID forKey:@"UnitID"];
    [specialDict setValue:orderDetail.itemCategoryId forKey:@"ItemCategoryID"];
    [specialDict setValue:orderDetail.deliverOrderID forKey:@"OrderId"];

    NSString *urlStr = [NSString stringWithFormat:@"%@/%@%@", VALUE_API_PREFIX, API_SERVICE_USER, API_SELLER_BLACK];
    NSString *url = [ProjectAPI getURL:urlStr specialDict:specialDict];
    DLog(@"url = %@", url);
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:API_SELLER_BLACK_TY];
    
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
            
        case API_ORDER_CANCEL_TY:
        {
            ConnectionAndParserResultCode ret = [JSONParser parserResponseJsonData:result
                                                                              type:contentType
                                                                               MOC:_MOC
                                                                 connectorDelegate:self
                                                                               url:url
                                                                           paramID:0];
            
            if (ret == SUCCESS_CODE) {

                [self getOrderPayList];
            }
            break;
        }
            
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
                
                NSArray *list = OBJ_FROM_DIC(dict, @"SOrderInfo");
                
                for (NSDictionary *totalDic in list) {
                    
                    OrderTotal *orderTotal = [[OrderTotal alloc] init];
                    orderTotal.orderId = STRING_VALUE_FROM_DIC(totalDic, @"OrderID");
                    orderTotal.orderNo = STRING_VALUE_FROM_DIC(totalDic, @"OrderNo");
                    orderTotal.totalAmount = STRING_VALUE_FROM_DIC(totalDic, @"Amount");
                    orderTotal.orderCanPay = [NSString stringWithFormat:@"%d", INT_VALUE_FROM_DIC(totalDic, @"OrderCanPay")];
                    orderTotal.orderCanCancel = [NSString stringWithFormat:@"%d", INT_VALUE_FROM_DIC(totalDic, @"orderCanCancel")];

                    
                    if (![orderTotal.orderCanPay length]) {
                        orderTotal.orderCanPay = @"1";
                    }
                    
                    if (![orderTotal.orderCanCancel length]) {
                        orderTotal.orderCanCancel = @"1";
                    }
                    
                    NSArray *orderGroupArray = OBJ_FROM_DIC(totalDic, @"OrderGroup");
                    NSMutableArray *groupArray = [NSMutableArray array];
                    
                    for (NSDictionary *sellDic in orderGroupArray) {
                        
                        NSString *status = STRING_VALUE_FROM_DIC(sellDic, @"Status");
                        NSArray *detailList = OBJ_FROM_DIC(sellDic, @"OrderDetailInfo");
                        
                        BOOL isFirst = YES;
                        for (NSDictionary *dic in detailList) {
                            
                            NSMutableArray *detailArray = [NSMutableArray array];
                            
                            OrderDetail *orderDetail = [[OrderDetail alloc] init];
                            orderDetail.orderDetailId = STRING_VALUE_FROM_DIC(dic, @"OrderDetailID");
                            orderDetail.itemId = STRING_VALUE_FROM_DIC(dic, @"ItemID");
                            orderDetail.skuId = STRING_VALUE_FROM_DIC(dic, @"SKUID");
                            orderDetail.itemName = STRING_VALUE_FROM_DIC(dic, @"ItemName");
                            orderDetail.itemUnit = STRING_VALUE_FROM_DIC(dic, @"ItemUnit");
                            orderDetail.purchaseWeight = STRING_VALUE_FROM_DIC(dic, @"PurchaseWeight");
                            orderDetail.realWeight = STRING_VALUE_FROM_DIC(dic, @"RealWeight");
                            orderDetail.realAmount = STRING_VALUE_FROM_DIC(dic, @"RealAmount");
                            orderDetail.isFirst = isFirst;
                            orderDetail.orderStatus = status;
                            
                            [detailArray addObject:orderDetail];
                            
                            [groupArray addObject:detailArray];
                            
                            isFirst = NO;
                        }
                        
                        orderTotal.groupArray = groupArray;
                    }
                    [_orderArray addObject:orderTotal];
                }
                
                
                [_tableView reloadData];
            }
            
            break;
        }
            
        case API_ORDER_EVALUATION_TY:
        {
            [self getCompletedOrderList];
            
            break;
        }
            
        case API_SELLER_PRIORITY_TY:
        {
            break;
        }
            
        case API_SELLER_BLACK_TY:
        {
            [_tableView reloadData];
            break;
        }
            
        case API_ORDER_COMPLETED_LIST_TY:
        {
            ConnectionAndParserResultCode ret = [JSONParser parserResponseJsonData:result
                                                                              type:contentType
                                                                               MOC:_MOC
                                                                 connectorDelegate:self
                                                                               url:url
                                                                           paramID:0];
            
            if (ret == SUCCESS_CODE) {
                
                [_orderCompletedArray removeAllObjects];
                
                NSDictionary *resultDict = [result objectFromJSONData];
                NSDictionary *dict = OBJ_FROM_DIC(resultDict, @"Data");
                
                NSArray *list = OBJ_FROM_DIC(dict, @"OrderInfo");
                
                for (NSDictionary *totalDic in list) {
                    OrderCompletedTotal *orderTotal = [[OrderCompletedTotal alloc] init];
                    orderTotal.orderId = STRING_VALUE_FROM_DIC(totalDic, @"OrderID");
                    orderTotal.orderNo = STRING_VALUE_FROM_DIC(totalDic, @"OrderNo");
                    orderTotal.orderTime = STRING_VALUE_FROM_DIC(totalDic, @"OrderTime");
                    
                    NSArray *detailList = OBJ_FROM_DIC(totalDic, @"DeliverOrder");
                    NSMutableArray *orderDetailArray = [NSMutableArray array];
                    
                    for (NSDictionary *dic in detailList) {
                        
                        OrderCompletedDetail *orderDetail = [[OrderCompletedDetail alloc] init];
                        orderDetail.deliverOrderID = STRING_VALUE_FROM_DIC(dic, @"DeliverOrderID");
                        orderDetail.itemCategoryId = STRING_VALUE_FROM_DIC(dic, @"ItemCategoryId");
                        orderDetail.itemCategoryName = STRING_VALUE_FROM_DIC(dic, @"ItemCategoryName");
                        orderDetail.unitID = STRING_VALUE_FROM_DIC(dic, @"UnitID");
                        orderDetail.unitName = STRING_VALUE_FROM_DIC(dic, @"UnitName");
                        orderDetail.goodCount = STRING_VALUE_FROM_DIC(dic, @"GoodCount");
                        orderDetail.normalCount = STRING_VALUE_FROM_DIC(dic, @"NormalCount");
                        orderDetail.badCount = STRING_VALUE_FROM_DIC(dic, @"BadCount");
                        orderDetail.evaluationTypeID = STRING_VALUE_FROM_DIC(dic, @"EvaluationTypeID");
                        orderDetail.itemCount = STRING_VALUE_FROM_DIC(dic, @"ItemCount");
                        
                        [orderDetailArray addObject:orderDetail];
                    }
                    
                    orderTotal.detailArray = orderDetailArray;
                    
                    [_orderCompletedArray addObject:orderTotal];
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

#pragma mark - UIAlertViewDelegate method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==LOGIN_TAG) {
        if (buttonIndex==1) {
//            LoginViewController* login=[[LoginViewController alloc] init];
//            login.delegate=[UIApplication sharedApplication].delegate;
//            [[[UIApplication sharedApplication].delegate window] setRootViewController:login];
            
            [AppManager instance].isFromHome = YES;
            LoginViewController* loginVC = [[[LoginViewController alloc] init] autorelease];
            
            UINavigationController *vcNav = [[[UINavigationController alloc] initWithRootViewController:loginVC] autorelease];
            vcNav.navigationBar.tintColor = TITLESTYLE_COLOR;
            loginVC.delegate = [UIApplication sharedApplication].delegate;
            
            [self presentViewController:vcNav animated:YES completion:nil];
        }
    }
}

@end
