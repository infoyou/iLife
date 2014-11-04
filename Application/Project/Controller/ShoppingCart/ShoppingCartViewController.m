
#import "ShoppingCartViewController.h"
#import "UIColor+expanded.h"
#import "JILBase.h"
#import "UIView+JITIOSLib.h"
#import "ShoppingTimeViewController.h"

@interface ShoppingCartViewController ()<JILNetBaseDelegate>
{

}
@property(nonatomic, retain)HomeContainerViewController* homeVC;
@property(nonatomic, retain)NSMutableArray* foodParam;
@property(nonatomic, retain)NSMutableArray* foodList;
@property(nonatomic, retain)NSIndexPath* deleteIndexPath;
@property(nonatomic, retain)UILabel* priceLabel;
@property(nonatomic, retain)JILNetBase* netBase;
@property(nonatomic)float totalPrice;

- (IBAction)handleDelete:(UIButton *)sender;

@end

@implementation ShoppingCartViewController {
    
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
        self.netBase=[[JILNetBase alloc]init];
        self.netBase.netBaseDelegate=self;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [MBProgressHUD showMessag:@"刷新购物车" toView:self.view];
    [self.netBase RequestWithRequestType:NET_GET param:[self getParamWithAction:@"GetCardItemList" UserID:[AppManager instance].userId Parameters:@{}]];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if ([WXWCommonUtils currentOSVersion] < IOS7) {
        self.view.frame = CGRectOffset(self.view.frame, 0, -20);
    }

    [_tableView setShowsVerticalScrollIndicator:NO];
    [_tableView setFrame:CGRectMake(0, 0, 320, SCREEN_HEIGHT-64-48-45)];
    [_tableView setBackgroundColor:[UIColor colorWithRGBHex:0xf7f7f7]];
    
    self.foodParam=[[NSMutableArray alloc]initWithCapacity:10];

    UIButton* commitBtn=[[UIButton alloc]initWithFrame:CGRectMake(117, SCREEN_HEIGHT-64-48-38, 85, 30)];
    [commitBtn setBackgroundImage:[UIImage imageNamed:@"shoppingcart_commit_normal.png"] forState:UIControlStateNormal];
    [commitBtn setBackgroundImage:[UIImage imageNamed:@"shoppingcart_commit_light.png"] forState:UIControlStateHighlighted];
    [commitBtn setTitle:@"立即下单" forState:UIControlStateNormal];
    [commitBtn.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
    [commitBtn addTarget:self action:@selector(handleCommit) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:commitBtn];
    
    self.priceLabel=[[UILabel alloc]initWithFrame:CGRectMake(220, SCREEN_HEIGHT-64-48-38, 100, 30)];
    [self showtotalPrice];
    [self.view addSubview:self.priceLabel];
}

#pragma mark-handle Request
-(void)handleRequestSuccessData:(id)object
{
    NSDictionary* dic=[self JSONValue:object];
    if (self.netBase.requestType==(RequestType*)BUY_DELETECART) {
        //
        if ([[dic objectForKey:@"ResultCode"] integerValue]==0) {
            [[[self.foodList objectAtIndex:self.deleteIndexPath.section] objectForKey:@"ItemCartList"] removeObjectAtIndex:self.deleteIndexPath.row];
//            [self.foodList removeObjectAtIndex:self.deleteIndexPath.row];
            [self.tableView reloadData];
            [self showtotalPrice];
            [AppManager instance].updateCache=YES;
            [AppManager instance].cartCount-=1;
        }
        self.netBase.requestType=nil;
    }else{
        if ([[dic objectForKey:@"ResultCode"] integerValue]==0) {
            if ([[[dic objectForKey:@"Data"] objectForKey:@"ItemList"] isEqual:[NSNull null]]||[[dic objectForKey:@"Data"] objectForKey:@"ItemList"]==nil) {
                self.foodList=[NSMutableArray arrayWithArray:[NSArray array]];
            }else{
                 self.foodList=[NSMutableArray arrayWithArray:[[dic objectForKey:@"Data"] objectForKey:@"ItemList"]];
            }
            [self.tableView reloadData];
            [self showtotalPrice];
        }
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];

    
}

-(void)handleRequestFailedData:(NSError *)error{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    self.netBase.requestType=nil;
}

#pragma mark-SetUp tableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.foodList count]>0?[self.foodList count]:0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self.foodList objectAtIndex:section] objectForKey:@"ItemCartList"] count];;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ShoppongCartCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* nib=[[NSBundle mainBundle] loadNibNamed:@"ShoppongCartCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSDictionary* dic=[[[self.foodList objectAtIndex:indexPath.section] objectForKey:@"ItemCartList"] objectAtIndex:indexPath.row];
    [cell setText:[dic objectForKey:@"ItemName"] toLabelWithTag:10];
    NSString* unit=[NSString stringWithFormat:@"%@%@",[[dic objectForKey:@"ItemType"] integerValue]==0?@"500":@"",[dic objectForKey:@"ItemUnit"]];
    [cell setText:[NSString stringWithFormat:@"%.2f元/%@",[[dic objectForKey:@"Price"] floatValue],unit] toLabelWithTag:11];
    [cell setText:[NSString stringWithFormat:@"%d%@",[[dic objectForKey:@"Weight"] integerValue],[dic objectForKey:@"ItemUnit"]] toLabelWithTag:12];

    [cell setText:[NSString stringWithFormat:@"金额%.2f元",[[dic objectForKey:@"Amount"] floatValue]] toLabelWithTag:13];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView* bgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 10)];
    [bgView setBackgroundColor:[UIColor colorWithRGBHex:0xf7f7f7]];
    return bgView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

#pragma mark-setup Button Action
-(void)handleCommit
{
    if ([self.foodList count]>0) {
        ShoppingTimeViewController* time=[[ShoppingTimeViewController alloc]initWithNibName:@"ShoppingTimeViewController" bundle:nil];
        [self setFoodParam];
        self.homeVC=(HomeContainerViewController*)self.parentVC;
        time.homeVC=self.homeVC;
        time.totalPrice=self.totalPrice;
        time.foodParam=self.foodParam;
        [CommonMethod pushViewController:time withAnimated:NO];
    }else{
        [self confirmWithMessage:@"请到逛菜场选择商品后进行下单" title:@""];
    }
}




- (IBAction)handleDelete:(UIButton *)sender {
    UIView *view = sender;
    while (view != nil && ![view isKindOfClass:[UITableViewCell class]]) {
        view = [view superview];
    }
    self.deleteIndexPath=[_tableView indexPathForCell:(UITableViewCell*)view];
    NSString* SkuId=[[[[self.foodList objectAtIndex:self.deleteIndexPath.section] objectForKey:@"ItemCartList"] objectAtIndex:self.deleteIndexPath.row] objectForKey:@"SkuId"];
//    SkuId=@"1040081044"; //后期需要注释掉
    [MBProgressHUD showMessag:@"正在删除..." toView:self.view];
    self.netBase.requestType=(RequestType*)BUY_DELETECART;
    [self.netBase RequestWithRequestType:NET_GET param:[self getParamWithAction:@"RemoveItem" UserID:[AppManager instance].userId Parameters:@{@"SkuId":SkuId}]];
}

#pragma mark-set others

-(void)setFoodParam
{
    for (NSDictionary* itemList in self.foodList) {
        for (NSDictionary* item in [itemList objectForKey:@"ItemCartList"]) {
            NSDictionary* param=@{@"SKUId":[item objectForKey:@"SkuId"],@"Weight":[item objectForKey:@"Weight"]};
            [self.foodParam addObject:param];
        }
    }
}

- (void)showtotalPrice
{
    self.totalPrice=[self totalAmount];
    NSMutableAttributedString* str=[[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"预计¥%.2f元",self.totalPrice]];
    [self setupStr:str];
    self.priceLabel.attributedText=str;
}

- (float)totalAmount
{
    if ([self.foodList count]>0) {
        float sum=0.0f;
        for (NSDictionary* itemList in self.foodList) {
            for (NSDictionary* item in [itemList objectForKey:@"ItemCartList"]) {
                sum+=[[item objectForKey:@"Amount"] floatValue];
            }
        }
        return sum;
    }else{
        return 0.0f;
    }
}

-(void)setupStr:(NSMutableAttributedString*)str
{
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,2)];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(2,[str length]-2)];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12.0f] range:NSMakeRange(0, [str length])];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


@end
