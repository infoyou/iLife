
#import "VisitingFarmsViewController.h"
#import "UIView+JITIOSLib.h"
#import "JILOptionPicker.h"
#import "CustomActionSheet.h"
#import "JILBase.h"
#import "EditAddressViewController.h"
#import "AddressListController.h"


#define INTERVAL_NUM 1000

@interface VisitingFarmsViewController ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,JILNetBaseDelegate>
{
    UILabel* _addressLabel;
    UILabel* _farmNameLabel;
    BOOL _hasAddress;
    BOOL _update;

}
@property (retain, nonatomic) IBOutlet UITableViewCell *farmCategoryCellView;
@property (retain, nonatomic) IBOutlet UITableViewCell *farmFoodCellView;
@property (retain, nonatomic) IBOutlet JILOptionPicker *weightPickerView;
@property (retain, nonatomic) IBOutlet UIView *foodView;

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
        [self.netBase RequestWithRequestType:NET_GET param:[self getParamWithAction:@"GetItemCategoryList" UserID:@"004852E9-7AA1-4C3F-97A3-361B8EA96464" Parameters:@{}]];
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

    [self.view.superview setBackgroundColor:[UIColor blueColor]];
    
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
        self.netBase.requestType=nil;
    }else if (self.netBase.requestType==(RequestType*)BUY_PUTINCART){
        if ([[dic objectForKey:@"IsSuccess"] integerValue]==1) {
            [self setAddWeightButton];
        }
        self.netBase.requestType=nil;
    }else if (self.netBase.requestType==(RequestType*)BUY_FOODINFORMATION){
        if ([[dic objectForKey:@"IsSuccess"] integerValue]==1) {
            NSArray* nib=[[NSBundle mainBundle] loadNibNamed:@"FarmFoodView" owner:self options:nil];
            self.foodView=[nib objectAtIndex:0];
            UIWebView* web=(UIWebView*)[self.foodView viewWithTag:10];
            [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[dic objectForKey:@"Data"] objectForKey:@"ItemDescURL"]]]];
            self.asheet=[[CustomActionSheet alloc]initWithContentView:self.foodView];
            self.asheet.delegate=self;
            [self.asheet showInView:[UIApplication sharedApplication].keyWindow];

        }
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
                [self.netBase RequestWithRequestType:NET_GET param:[self getParamWithAction:@"GetItemSaleList" UserID:@"004852E9-7AA1-4C3F-97A3-361B8EA96464" Parameters:@{@"ItemCategoryID":@"10544888"}]];
                
            }
        }
        
    }


}

-(void)handleRequestFailedData:(NSError *)error
{
    if (self.netBase.requestType==(RequestType*)BUY_FOODLIST) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
    self.netBase.requestType=nil;
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
        [self resumeAddWeightButton:cell];
        return cell;

    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.categoryTableView]) {
        if (indexPath.row<[self.catrgoryList count]) {
            [MBProgressHUD showMessag:@"刷新菜单" toView:self.view];
            self.netBase.requestType=(RequestType*)BUY_FOODLIST;
            [self.netBase RequestWithRequestType:NET_GET param:[self getParamWithAction:@"GetItemSaleList" UserID:@"004852E9-7AA1-4C3F-97A3-361B8EA96464" Parameters:@{@"ItemCategoryID":@"10544888"}]];
        }
    }else{
        self.netBase.requestType=(RequestType*)BUY_FOODINFORMATION;
        [self.netBase RequestWithRequestType:NET_GET param:[self getParamWithAction:@"ShowItemDesc" UserID:@"004852E9-7AA1-4C3F-97A3-361B8EA96464" Parameters:@{@"ItemID":@"2245"}]];
    }
}


- (IBAction)selectFoodWeight:(UIButton *)sender {
    UIView *view = sender;
    while (view != nil && ![view isKindOfClass:[UITableViewCell class]]) {
        view = [view superview];
    }
    
    self.foodIndexPath=[self.foodTableView indexPathForCell:(UITableViewCell*)view];
    NSMutableArray* weightArray=[[self.foodList objectAtIndex:self.foodIndexPath.row] objectForKey:@"weightOption"];
    [self.options removeAllObjects];
    for (NSDictionary* dic in weightArray) {
        [self.options addObject:[NSString stringWithFormat:@"%@克 - %@元",[dic objectForKey:@"Weight"],[dic objectForKey:@"Amount"]]];
    }
    NSArray* nib=[[NSBundle mainBundle] loadNibNamed:@"FarmWeightPickerView" owner:self options:nil];
    self.weightPickerView=[nib objectAtIndex:0];
//    self.options=[NSMutableArray arrayWithObject:@"nil"];
    [self.weightPickerView setOptions:self.options];

//    [self.weightPickerView setOptions:self.options];
    
    self.asheet=[[CustomActionSheet alloc]initWithContentView:self.weightPickerView];
    self.asheet.delegate=self;
    
    [self.asheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (IBAction)sureWeight:(UIButton *)sender {
    switch (sender.tag) {
        case 10:
            [self.asheet dismissWithButtonIndex:0 animated:NO];
            break;
        case 11:
            [self.asheet dismissWithButtonIndex:1 animated:NO];
            break;
        default:
            [self.asheet dismissWithButtonIndex:0 animated:NO];
            break;
    }
    
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex==1) {
        
        self.netBase.requestType=(RequestType*)BUY_PUTINCART;
        NSString* weight=[[[[self.foodList objectAtIndex:self.foodIndexPath.row] objectForKey:@"weightOption"] objectAtIndex:self.weightPickerView.selecttedIndex] objectForKey:@"Weight"];
        NSString* SkuId=[[self.foodList objectAtIndex:self.foodIndexPath.row] objectForKey:@"SKUId"];
        [self.netBase RequestWithRequestType:NET_GET param:[self getParamWithAction:@"PutItemCard" UserID:@"004852E9-7AA1-4C3F-97A3-361B8EA96464" Parameters:@{@"SkuId":SkuId,@"Weight":weight}]];
        
    }
}


#pragma mark-addView
- (void)addAddressButton
{
//    EditAddressViewController* editAddress=[[EditAddressViewController alloc]initWithNibName:@"EditAddressViewController" bundle:nil];
    _update=NO;
    AddressListController *addressVC = [[[AddressListController alloc] initWithMOC:_MOC parentVC:nil] autorelease];
    [CommonMethod pushViewController:addressVC withAnimated:YES];
//    [CommonMethod pushViewController:editAddress withAnimated:NO];

}

- (void)setAddWeightButton
{
    UITableViewCell* cell=[self.foodTableView cellForRowAtIndexPath:self.foodIndexPath];
    [[cell buttonWithTag:12] setBackgroundImage:[UIImage imageNamed:@"farm_dialog.png"] forState:UIControlStateNormal];
    [[cell buttonWithTag:12] setFrame:CGRectMake(213, 17, 50, 25)];
    [[cell buttonWithTag:12] setTitle:[NSString stringWithFormat:@"%@克",[[[[self.foodList objectAtIndex:self.foodIndexPath.row] objectForKey:@"weightOption"] objectAtIndex:self.weightPickerView.selecttedIndex] objectForKey:@"Weight"]] forState:UIControlStateNormal];
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
    
}

- (void)dealloc {
    [_farmCategoryCellView release];
    [_farmFoodCellView release];
    [_weightPickerView release];
    [_foodView release];
    [super dealloc];
}

@end
