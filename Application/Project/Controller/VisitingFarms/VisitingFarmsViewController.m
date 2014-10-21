
#import "VisitingFarmsViewController.h"
#import "UIView+JITIOSLib.h"
#import "JILOptionPicker.h"
#import "CustomActionSheet.h"
#import "JILBase.h"
#import "EditAddressViewController.h"
#import "AddressListController.h"
#import "LoginViewController.h"


#define INTERVAL_NUM 1000

@interface VisitingFarmsViewController ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,JILNetBaseDelegate,UIWebViewDelegate,UIAlertViewDelegate>
{
    UILabel* _addressLabel;
    UILabel* _farmNameLabel;
    BOOL _hasAddress;
    BOOL _update;

}
@property (retain, nonatomic) IBOutlet UITableViewCell *farmCategoryCellView;
@property (retain, nonatomic) IBOutlet UITableViewCell *farmFoodCellView;
@property (retain, nonatomic) UIView *weightView;
@property (retain, nonatomic) JILOptionPicker *weightPickerView;
@property (retain, nonatomic) UIView *foodView;

@property(nonatomic,retain)UITableView* categoryTableView;
@property(nonatomic,retain)UITableView* foodTableView;
@property(nonatomic,retain)NSArray* catrgoryList;
@property(nonatomic,retain)NSMutableArray* foodList;



@property(nonatomic,retain)CustomActionSheet* asheet;


@property(nonatomic,retain)JILNetBase* netBase;
@property(nonatomic,retain)NSString* itemCategoryID;
@property(nonatomic,retain)NSMutableArray* options;
@property(nonatomic,retain)NSIndexPath* foodIndexPath;



@end

@implementation VisitingFarmsViewController {
    
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
        _update=NO;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    //获取菜的类别
    if (!_update) {
        [MBProgressHUD showMessag:@"刷新菜场" toView:self.view];
        [self.netBase RequestWithRequestType:NET_GET param:[self getParamWithAction:@"GetItemCategoryList" UserID:@"59853FB6-F003-47B0-9D06-09D2CE20A14D" Parameters:@{}]];
        [[UIApplication sharedApplication].delegate window].userInteractionEnabled=NO;
        _update=YES;
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _hasAddress=NO;
    if ([WXWCommonUtils currentOSVersion] < IOS7) {
        self.view.frame = CGRectOffset(self.view.frame, 0, -20);
    }
    
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setShowsVerticalScrollIndicator:NO];
    [_tableView setHidden:YES];

    UIView* addressView=[[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 36)] autorelease];
    [self.view addSubview:addressView];
    [self addAddressView:addressView];
   
    UIView* farmView=[[[UIView alloc]initWithFrame:CGRectMake(0, 37, 320, 36)] autorelease];
    [self.view addSubview:farmView];
    [self addFarmView:farmView];
    

    self.categoryTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 73, 45, SCREEN_HEIGHT-64-48-72) style:UITableViewStylePlain];
    self.categoryTableView.delegate=self;
    self.categoryTableView.dataSource=self;
    [self.categoryTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:self.categoryTableView];
    
    self.foodTableView=[[UITableView alloc]initWithFrame:CGRectMake(46, 73, 274, SCREEN_HEIGHT-64-48-72) style:UITableViewStylePlain];
    self.foodTableView.delegate=self;
    self.foodTableView.dataSource=self;
    [self.view addSubview:self.foodTableView];
    self.options=[NSMutableArray arrayWithObject:@"nil"];

    
   
//    [self.netBase RequestWithRequestType:NET_GET param:[self getParamWithAction:@"GetItemCategoryList" UserID:@"004852E9-7AA1-4C3F-97A3-361B8EA96464" Parameters:@{}]];
}


#pragma mark-handle Request
-(void)handleRequestSuccessData:(id)object
{
    NSDictionary* dic=[self JSONValue:object];
    if (self.netBase.requestType==(RequestType*)BUY_FOODLIST) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if ([[dic objectForKey:@"IsSuccess"] integerValue]==1) {
            self.foodList=[[dic objectForKey:@"Data"] objectForKey:@"ItemSaleInfo"];
            [self.foodTableView reloadData];
        }
        [[UIApplication sharedApplication].delegate window].userInteractionEnabled=YES;
        self.netBase.requestType=nil;
    }else if (self.netBase.requestType==(RequestType*)BUY_PUTINCART){
        if ([[dic objectForKey:@"IsSuccess"] integerValue]==1) {
            [self setAddWeightButton];
        }
        self.netBase.requestType=nil;
    }else if (self.netBase.requestType==(RequestType*)BUY_FOODINFORMATION){
        if ([[dic objectForKey:@"IsSuccess"] integerValue]==1) {
            NSString* url=[[[dic objectForKey:@"Data"] objectForKey:@"ItemDescURL"] length]>0?[[dic objectForKey:@"Data"] objectForKey:@"ItemDescURL"]:@"http://www.baidu.com";
            [self createFoodView:url];
            [[[UIApplication sharedApplication].delegate window] addSubview:self.foodView];
        }
        self.netBase.requestType=nil;
    }else{
        if ([[dic objectForKey:@"IsSuccess"] integerValue]==1) {
            self.catrgoryList=[[dic objectForKey:@"Data"] objectForKey:@"ItemType"];
            if ([[[dic objectForKey:@"Data"] objectForKey:@"DefaultAddress"] length]>0) {
                _addressLabel.text=[[dic objectForKey:@"Data"] objectForKey:@"DefaultAddress"];
                _hasAddress=YES;
            }else{
                _hasAddress=NO;
            }
            _farmNameLabel.text=[[dic objectForKey:@"Data"] objectForKey:@"CustomerName"];
            [self.categoryTableView reloadData];
            if ([self.catrgoryList count]>0) {
                self.itemCategoryID=[[self.catrgoryList objectAtIndex:0] objectForKey:@"ItemCategoryID"];
                self.netBase.requestType=(RequestType*)BUY_FOODLIST;
                [self.netBase RequestWithRequestType:NET_GET param:[self getParamWithAction:@"GetItemSaleList" UserID:@"59853FB6-F003-47B0-9D06-09D2CE20A14D" Parameters:@{@"ItemCategoryID":self.itemCategoryID}]];
            }
        }
    }
}

-(void)handleRequestFailedData:(NSError *)error
{
    if (self.netBase.requestType==(RequestType*)BUY_FOODLIST) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
//    self.netBase.requestType=nil;
}
#pragma mark-SetUp tableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView isEqual:self.categoryTableView]) {
        return 55.f;
    }else{
        return 60.f;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:self.categoryTableView]) {
        return [self.catrgoryList count]<7?7:[self.catrgoryList count];
    }else{
        return [self.foodList count]?[self.foodList count]:0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.categoryTableView]) {
        static NSString *CellIdentifier = @"FarmCategoryCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            [[NSBundle mainBundle] loadNibNamed:@"FarmCategoryCell" owner:self options:nil];
            cell = self.farmCategoryCellView;
            [self setFarmCategoryCellView:nil];
        }
        
        if (indexPath.row<[self.catrgoryList count]) {
            NSMutableString* categoryName=[[NSMutableString alloc]initWithString:[[self.catrgoryList objectAtIndex:indexPath.row] objectForKey:@"ItemCategoryName"]];;
            [cell labelWithTag:10].numberOfLines=[categoryName length];
            [categoryName insertString:@"\n" atIndex:1];
            [cell setText:categoryName toLabelWithTag:10];
        }else{
            [cell setText:@"" toLabelWithTag:10];
        }
        return cell;

    }else{
        static NSString *CellIdentifier = @"FarmFoodCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            [[NSBundle mainBundle] loadNibNamed:@"FarmFoodCell" owner:self options:nil];
            cell = self.farmFoodCellView;
            [self setFarmFoodCellView:nil];
        }
        
        [cell setText:[[self.foodList objectAtIndex:indexPath.row] objectForKey:@"ItemName"]  toLabelWithTag:10];
        [cell setText:[NSString stringWithFormat:@"%.2f",[[[self.foodList objectAtIndex:indexPath.row] objectForKey:@"SKUPrice"] floatValue]] toLabelWithTag:11];
        [cell setText:[[self.foodList objectAtIndex:indexPath.row] objectForKey:@"ItemUnit"] toLabelWithTag:13];
        [self resumeAddWeightButton:cell];
        return cell;

    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([tableView isEqual:self.categoryTableView]) {
        if (indexPath.row<[self.catrgoryList count]) {
            [MBProgressHUD showMessag:@"刷新菜厂" toView:self.view];
            self.netBase.requestType=(RequestType*)BUY_FOODLIST;
            [self.netBase RequestWithRequestType:NET_GET param:[self getParamWithAction:@"GetItemSaleList" UserID:@"59853FB6-F003-47B0-9D06-09D2CE20A14D" Parameters:@{@"ItemCategoryID":[[self.catrgoryList objectAtIndex:indexPath.row] objectForKey:@"ItemCategoryID"]}]];
        }
    }else{
        self.netBase.requestType=(RequestType*)BUY_FOODINFORMATION;
        NSString* itemID=[[self.foodList objectAtIndex:indexPath.row] objectForKey:@"ItemId"];
        [self.netBase RequestWithRequestType:NET_GET param:[self getParamWithAction:@"ShowItemDesc" UserID:@"59853FB6-F003-47B0-9D06-09D2CE20A14D" Parameters:@{@"ItemID":itemID}]];
    }
}


- (IBAction)selectFoodWeight:(UIButton *)sender {
    if ([[AppManager instance].passwd length]>0) {
        UIView *view = sender;
        while (view != nil && ![view isKindOfClass:[UITableViewCell class]]) {
            view = [view superview];
        }
        self.foodIndexPath=[self.foodTableView indexPathForCell:(UITableViewCell*)view];
        NSMutableArray* weightArray=[[self.foodList objectAtIndex:self.foodIndexPath.row] objectForKey:@"weightOption"];
        [self.options removeAllObjects];
        for (NSDictionary* dic in weightArray) {
            [self.options addObject:[NSString stringWithFormat:@"%@%@ - %@%@",[dic objectForKey:@"Quantity"],[dic objectForKey:@"Unit"],[dic objectForKey:@"Amount"],[dic objectForKey:@"MoneyUnit"]]];
        }
        [self setWeightPickerView];
        [self.weightPickerView setOptions:self.options];
        [[[UIApplication sharedApplication].delegate window] addSubview:self.weightPickerView];
    }else{
        [self askWithMessage:@"尚未登录，请先登录" alertTag:LOGIN_TAG];
    }
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==LOGIN_TAG) {
        if (buttonIndex==1) {
            LoginViewController* login=[[LoginViewController alloc]init];
            [[[UIApplication sharedApplication].delegate window] setRootViewController:login];
//            [[AppManager instance].userDefaults rememberUsername:[[AppManager instance].userDefaults usernameRemembered] andPassword:@"" pswdStr:@"" customerName:@""];
//            
//            // Clear current user data
//            [WXWCoreDataUtils deleteEntitiesFromMOC:_MOC entityName:@"TodoList" predicate:nil];
//            [WXWCoreDataUtils deleteEntitiesFromMOC:_MOC entityName:@"SurveyDetail" predicate:nil];
//            [WXWCoreDataUtils deleteEntitiesFromMOC:_MOC entityName:@"SurveyItem" predicate:nil];
//            
//            // Do logout
//            [((ProjectAppDelegate *)APP_DELEGATE) logout];
//            [self.navigationController popToRootViewControllerAnimated:YES];

        }
    }
}





#pragma mark-addView
- (void)setWeightPickerView
{
    
    self.weightPickerView=[[JILOptionPicker alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    UIImageView* bg=[[UIImageView alloc]initWithFrame:self.weightPickerView.frame];
    bg.image=[UIImage imageNamed:@"farm_bg.png"];
    [self.weightPickerView addSubview:bg];
    
    
    UIView* contengView=[[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-280, SCREEN_WIDTH, 280)];
    [contengView setBackgroundColor:[UIColor whiteColor]];
    [self.weightPickerView addSubview:contengView];
    
    UILabel* titleLab=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, contengView.frame.size.width, 46)];
    titleLab.text=@"重量 - 金额";
    titleLab.textColor=RGBACOLOR(129, 192, 36, 1);
    titleLab.textAlignment=NSTextAlignmentCenter;
    titleLab.font=[UIFont systemFontOfSize:17.0f];
    [contengView addSubview:titleLab];
    UILabel* lineLab=[[UILabel alloc]initWithFrame:CGRectMake(10, 45, SCREEN_WIDTH-20, 1)];
    [lineLab setBackgroundColor:RGBACOLOR(129, 192, 36, 1)];
    [contengView addSubview:lineLab];
    
    UIPickerView* pickerView=[[UIPickerView alloc]initWithFrame:CGRectMake(0, 37, SCREEN_WIDTH, 162)];
    pickerView.dataSource=self.weightPickerView;
    pickerView.delegate=self.weightPickerView;
    self.weightPickerView.pickerView=pickerView;
    [contengView addSubview:pickerView];
    
    UILabel* lineLab1=[[UILabel alloc]initWithFrame:CGRectMake(0, 242, SCREEN_WIDTH, 1)];
    [lineLab1 setBackgroundColor:RGBACOLOR(129, 192, 36, 1)];
    [contengView addSubview:lineLab1];
    
    UIButton* cancleBtn=[[UIButton alloc]initWithFrame:CGRectMake(0, 242, SCREEN_WIDTH/2, 38)];
    cancleBtn.tag=10;
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancleBtn setTitleColor:RGBACOLOR(129, 192, 36, 1) forState:UIControlStateNormal];
    [cancleBtn.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [cancleBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [cancleBtn addTarget:self action:@selector(removeWeightPickerView:) forControlEvents:UIControlEventTouchUpInside];
    [contengView addSubview:cancleBtn];
    
    UIButton* sureBtn=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2, 242, SCREEN_WIDTH/2, 38)];
    sureBtn.tag=11;
    [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
    [sureBtn setTitleColor:RGBACOLOR(129, 192, 36, 1) forState:UIControlStateNormal];
    [sureBtn.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [sureBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [sureBtn addTarget:self action:@selector(removeWeightPickerView:) forControlEvents:UIControlEventTouchUpInside];
    [contengView addSubview:sureBtn];
}

- (void)removeWeightPickerView:(UIButton*)sender
{
    [self.weightPickerView removeFromSuperview];
    if (sender.tag==11) {
        self.netBase.requestType=(RequestType*)BUY_PUTINCART;
        NSDictionary* d=[self.foodList objectAtIndex:self.foodIndexPath.row];
        NSString* weight=[[[d objectForKey:@"weightOption"] objectAtIndex:self.weightPickerView.selecttedIndex] objectForKey:@"Quantity"];
        NSString* SkuId=[d objectForKey:@"SKUId"];
        [self.netBase RequestWithRequestType:NET_GET param:[self getParamWithAction:@"PutItemCard" UserID:@"59853FB6-F003-47B0-9D06-09D2CE20A14D" Parameters:@{@"SkuId":SkuId,@"Weight":weight}]];
    }
    
}

- (void)createFoodView:(NSString*)url
{
    if (!self.foodView) {
        self.foodView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        UIImageView* bg=[[UIImageView alloc]initWithFrame:self.foodView.frame];
        bg.image=[UIImage imageNamed:@"farm_bg.png"];
        [self.foodView addSubview:bg];
        
        UIWebView* web=[[UIWebView alloc]initWithFrame:CGRectMake(30, 40, SCREEN_WIDTH-60, SCREEN_HEIGHT-130)];
        web.delegate=self;
        web.tag=10;
        [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
        [self.foodView addSubview:web];
        
        UIButton* btn=[[UIButton alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-35)/2, SCREEN_HEIGHT-75, 35, 35)];
        [btn addTarget:self action:@selector(removeFoodView) forControlEvents:UIControlEventTouchUpInside];
        [btn setImage:[UIImage imageNamed:@"farm_close.png"] forState:UIControlStateNormal];
        [self.foodView addSubview:btn];
    }else{
        UIWebView* web=(UIWebView*)[self.foodView viewWithTag:10];
        [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    }
    [self.foodView setAlpha:1.0f];
}

- (void)removeFoodView
{
    [self.foodView setAlpha:0.0f];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"start");
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"finished");
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Falied");
}

- (void)addAddressButton
{
//    EditAddressViewController* editAddress=[[EditAddressViewController alloc]initWithNibName:@"EditAddressViewController" bundle:nil];
    if ([[AppManager instance].passwd length]>0) {
        _update=NO;
        AddressListController *addressVC = [[[AddressListController alloc] initWithMOC:_MOC parentVC:nil] autorelease];
        [CommonMethod pushViewController:addressVC withAnimated:YES];
    }else{
        [self askWithMessage:@"尚未登录，请先登录" alertTag:LOGIN_TAG];
    }
    
//    [CommonMethod pushViewController:editAddress withAnimated:NO];

}

- (void)setAddWeightButton
{
    UITableViewCell* cell=[self.foodTableView cellForRowAtIndexPath:self.foodIndexPath];
    [[cell buttonWithTag:12] setBackgroundImage:[UIImage imageNamed:@"farm_dialog.png"] forState:UIControlStateNormal];
    [[cell buttonWithTag:12] setFrame:CGRectMake(213, 17, 50, 25)];
    [[cell buttonWithTag:12] setTitle:[NSString stringWithFormat:@"%@%@",[[[[self.foodList objectAtIndex:self.foodIndexPath.row] objectForKey:@"weightOption"] objectAtIndex:self.weightPickerView.selecttedIndex] objectForKey:@"Quantity"],[[[[self.foodList objectAtIndex:self.foodIndexPath.row] objectForKey:@"weightOption"] objectAtIndex:self.weightPickerView.selecttedIndex] objectForKey:@"Unit"]] forState:UIControlStateNormal];
}

-(void)resumeAddWeightButton:(UITableViewCell*)cell
{
    [[cell buttonWithTag:12] setBackgroundImage:[UIImage imageNamed:@"farm_add.png"] forState:UIControlStateNormal];
    [[cell buttonWithTag:12] setFrame:CGRectMake(238, 17, 25, 25)];
    [[cell buttonWithTag:12] setTitle:@"" forState:UIControlStateNormal];
}

- (void)addAddressView:(UIView*)superView
{
    [superView setBackgroundColor:[UIColor clearColor]];
    UIImageView* addressIcon=[[[UIImageView alloc]initWithFrame:CGRectMake(12, 8, 16, 20)] autorelease];
    addressIcon.image=[UIImage imageNamed:@"farm_address.png"];
    [superView addSubview:addressIcon];
    UIImageView* addressline=[[[UIImageView alloc]initWithFrame:CGRectMake(0, 35, 320, 1)] autorelease];
    addressline.image=[UIImage imageNamed:@"farm_line.png"];
    [superView addSubview:addressline];
    _addressLabel=[[UILabel alloc]initWithFrame:CGRectMake(40, 10, 300, 16)];
    _addressLabel.text=@"请输入您的地址";
    _addressLabel.textColor=[UIColor redColor];
    _addressLabel.font=[UIFont systemFontOfSize:15.0f];
    [superView addSubview:_addressLabel];
    UIImageView* arrow=[[[UIImageView alloc]initWithFrame:CGRectMake(304, 13, 6, 10)] autorelease];
    arrow.image=[UIImage imageNamed:@"farm_arrow.png"];
    [superView addSubview:arrow];
    
    UIButton* addressBtn=[[UIButton alloc]initWithFrame:_addressLabel.frame];
    [addressBtn setBackgroundColor:[UIColor clearColor]];
    [addressBtn addTarget:self action:@selector(addAddressButton) forControlEvents:UIControlEventTouchUpInside];
    [superView addSubview:addressBtn];
}

- (void)addFarmView:(UIView*)superView
{
    [superView setBackgroundColor:[UIColor clearColor]];
    UIImageView* farmIcon=[[[UIImageView alloc]initWithFrame:CGRectMake(10, 9, 21, 18)] autorelease];
    farmIcon.image=[UIImage imageNamed:@"farm_farm.png"];
    [superView addSubview:farmIcon];
    UIImageView* addressline=[[[UIImageView alloc]initWithFrame:CGRectMake(0, 35, 320, 1)] autorelease];
    addressline.image=[UIImage imageNamed:@"farm_line.png"];
    [superView addSubview:addressline];
    _farmNameLabel=[[UILabel alloc]initWithFrame:CGRectMake(40, 10, 300, 16)];
    _farmNameLabel.text=@"输入地址后为您选择菜场";
    _farmNameLabel.textColor=[UIColor redColor];
    _farmNameLabel.font=[UIFont systemFontOfSize:15.0f];
    [superView addSubview:_farmNameLabel];
}



- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    _update=NO;
}

- (void)dealloc {
    [_farmCategoryCellView release];
    [_farmFoodCellView release];
    [_weightPickerView release];
    [_foodView release];
    [super dealloc];
}

@end
