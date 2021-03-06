
#import "VisitingFarmsViewController.h"
#import "UIView+JITIOSLib.h"
#import "JILOptionPicker.h"
#import "CustomActionSheet.h"
#import "JILBase.h"
#import "EditAddressViewController.h"
#import "AddressListController.h"
#import "LoginViewController.h"


typedef enum {
    ALERT_TAG_MUST_UPDATE = 1,
    ALERT_TAG_CHOISE_UPDATE = 2,
    LOGIN_TAG = 3,
}  UPDATE_ALERT_TAG;

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
@property(nonatomic,retain)NSMutableArray* categoryList;
@property(nonatomic,retain)NSMutableArray* foodList;
@property(nonatomic,retain)NSMutableDictionary* foodDic;
@property(nonatomic,retain)NSMutableDictionary* selectDict;
@property(nonatomic,retain)NSString* cacheDir;
@property(nonatomic)NSInteger categoryIndex;



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
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.cacheDir = [paths objectAtIndex:0];
    self.cacheDir=[self.cacheDir stringByAppendingPathComponent:@"Cache/cache.rtf"];
    self.categoryIndex=0;
    self.selectDict = [[NSMutableDictionary alloc] initWithCapacity:10];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    [self doUpdateSoftAction];
//    [self updateVersion];
    
    if (!_update) {
        if (![self existCache]) {
            [self requestUpdateData];
        } else {
            if ([AppManager instance].updateCache) {
                [self requestUpdateData];
            } else {
                [self readCache];
            }
        }
    }
}

#pragma mark - UpdateData
- (void)requestUpdateData
{
    [MBProgressHUD showMessag:@"加载中……" toView:self.view];
    self.categoryIndex=0;
    [self.selectDict removeAllObjects];
    self.netBase.requestType=(RequestType*)BUY_CARTLIST;
    [self.netBase RequestWithRequestType:NET_GET param:[self getParamWithAction:@"GetCardItemList" UserID:[AppManager instance].userId Parameters:@{}]];
    [[UIApplication sharedApplication].delegate window].userInteractionEnabled=NO;
    _update=YES;
}

-(BOOL)existCache
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:self.cacheDir]) {
        return YES;
    }else{
        return NO;
    }
}

-(void)updateCache
{
    //获取Documents文件夹目录
    if (self.categoryList&&self.foodDic) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docDir = [paths objectAtIndex:0];
        //获取文件管理器
        NSFileManager *fileManager = [NSFileManager defaultManager];
        //指定新建文件夹路径
        NSString *DocPath = [docDir stringByAppendingPathComponent:@"Cache"];
        //创建ImageFile文件夹
        [fileManager createDirectoryAtPath:DocPath withIntermediateDirectories:YES attributes:nil error:nil];
        
        NSDictionary* cache = @{@"categoryList":self.categoryList,
                                @"foodDic":self.foodDic,
                                @"CustomerName":_farmNameLabel.text,
                                @"Address":_addressLabel.text,
                                @"categoryIndex":[NSString stringWithFormat:@"%d",self.categoryIndex],
                                @"selectList":self.selectDict /*self.selectList*/};
        NSData *data=[NSKeyedArchiver archivedDataWithRootObject:cache];
        [fileManager createFileAtPath:[DocPath stringByAppendingString:@"/cache.rtf"] contents:data attributes:nil];
    }
    
    if ([[AppManager instance].passwd length]>0) {
    }else{
        _addressLabel.text=@"请增加您的收货地址";
    }
}

-(void)readCache
{
    NSData* data=[NSData dataWithContentsOfFile:self.cacheDir];
    NSDictionary* dic=[NSKeyedUnarchiver unarchiveObjectWithData:data];
    self.categoryList=[NSMutableArray arrayWithArray:[dic objectForKey:@"categoryList"]];
    self.foodDic=[NSMutableDictionary dictionaryWithDictionary:[dic objectForKey:@"foodDic"]];
    
    self.categoryIndex=[[dic objectForKey:@"categoryIndex"] integerValue];
    self.itemCategoryID=[[self.categoryList objectAtIndex:self.categoryIndex] objectForKey:@"ItemCategoryID"];
    self.foodList=[NSMutableArray arrayWithArray:[self.foodDic objectForKey:self.itemCategoryID]];
    
    self.selectDict = [NSMutableDictionary dictionaryWithDictionary:[dic objectForKey:@"selectList"]];
    if (self.selectDict != nil && ![self.selectDict isEqual:[NSNull null]]) {
        [AppManager instance].cartCount = [self.selectDict count];
    } else {
        [AppManager instance].cartCount = 0;
    }
    [self.categoryTableView reloadData];
    [self.foodTableView reloadData];
    
    if ([[AppManager instance].passwd length]>0) {
        _addressLabel.text=[dic objectForKey:@"Address"];
        _farmNameLabel.text=[dic objectForKey:@"CustomerName"];
    }else{
        _addressLabel.text=@"请增加您的收货地址";
        _farmNameLabel.text=@"输入地址后为您选择菜场";
    }
    _update=YES;
}

#pragma mark-handle Request
-(void)handleRequestSuccessData:(id)object
{
    NSDictionary* dic=[self JSONValue:object];
    if (self.netBase.requestType==(RequestType*)BUY_FOODLIST) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if ([[dic objectForKey:@"ResultCode"] integerValue]==0) {
            self.foodList=[[dic objectForKey:@"Data"] objectForKey:@"ItemSaleInfo"];
            [self.foodDic setObject:self.foodList forKey:self.itemCategoryID];
            [self updateCache];
            NSData* data=[NSData dataWithContentsOfFile:self.cacheDir];
            NSDictionary* dic=[NSKeyedUnarchiver unarchiveObjectWithData:data];
            self.foodDic=[NSMutableDictionary dictionaryWithDictionary:[dic objectForKey:@"foodDic"]];
            [self.foodTableView reloadData];
            
//            [AppManager instance].updateCache=NO;
        }
        [[UIApplication sharedApplication].delegate window].userInteractionEnabled=YES;
        self.netBase.requestType=nil;
        
    } else if (self.netBase.requestType==(RequestType*)BUY_PUTINCART) {
        
        if ([[dic objectForKey:@"ResultCode"] integerValue]==0) {
            NSDictionary* d=[self.foodList objectAtIndex:self.foodIndexPath.row];
            NSString* title=[NSString stringWithFormat:@"%@%@",[[[d objectForKey:@"weightOption"] objectAtIndex:self.weightPickerView.selecttedIndex] objectForKey:@"Quantity"],[[[d objectForKey:@"weightOption"] objectAtIndex:self.weightPickerView.selecttedIndex] objectForKey:@"Unit"]];
            
            NSString *itemIdKey = [d objectForKey:@"ItemId"];
            
            if (![self.selectDict objectForKey:itemIdKey]) {
                [self.selectDict setObject:@{@"ItemId":itemIdKey, @"CategoryID":[[self.categoryList objectAtIndex:self.categoryIndex] objectForKey:@"ItemCategoryID"], @"title":title} forKey:itemIdKey];
            }
            
            UITableViewCell* cell=[self.foodTableView cellForRowAtIndexPath:self.foodIndexPath];
            [self setAddWeightButton:title cell:cell];
            [AppManager instance].cartCount = [self.selectDict count];
            [self.categoryTableView reloadData];
        }
        self.netBase.requestType=nil;
        
    }else if (self.netBase.requestType==(RequestType*)BUY_FOODINFORMATION){
        if ([[dic objectForKey:@"ResultCode"] integerValue]==0) {
            NSString* url=[[[dic objectForKey:@"Data"] objectForKey:@"ItemDescURL"] length]>0?[[dic objectForKey:@"Data"] objectForKey:@"ItemDescURL"]:@"http://www.baidu.com";
            [self createFoodView:url];
            [[[UIApplication sharedApplication].delegate window] addSubview:self.foodView];
        }
        self.netBase.requestType=nil;
    }else if (self.netBase.requestType==(RequestType*)BUY_CARTLIST){
        if ([[dic objectForKey:@"ResultCode"] integerValue]==0) {
            if (![[[dic objectForKey:@"Data"] objectForKey:@"ItemList"] isEqual:[NSNull null]]) {
                [self updateSelectList:[[dic objectForKey:@"Data"] objectForKey:@"ItemList"]];
            }else{
                [AppManager instance].cartCount=0;
            }
        }
        self.netBase.requestType=nil;
        [self.netBase RequestWithRequestType:NET_GET param:[self getParamWithAction:@"GetItemCategoryList" UserID:[[AppManager instance].userId length]>0?[AppManager instance].userId:@"59853FB6-F003-47B0-9D06-09D2CE20A14D" Parameters:@{}]];
        
    } else if (self.netBase.requestType==(RequestType*)UPDATE_VERSION) {
        
        int ret = [[dic objectForKey:@"ResultCode"] integerValue];
        NSDictionary *dict = nil;
        
        if (ret == SUCCESS_CODE) {

            if (![[[dic objectForKey:@"Data"] objectForKey:@"AppVersion"] isEqual:[NSNull null]]) {
                dict = [[dic objectForKey:@"Data"] objectForKey:@"AppVersion"];
            } else {
                return;
            }

            
            [self.view endEditing:YES];
            
            if (dict && [dict count] > 0) {
                
                NSString *isUpdate = [dict objectForKey:@"IsUpdate"];
                if (!isUpdate || [isUpdate isEqual:[NSNull null]] || [isUpdate isEqual:@"<null>"]) {
                } else {
                    int isUpdate = INT_VALUE_FROM_DIC(dict, @"IsUpdate");
                    
                    if (isUpdate != 1) {
//                        [[[[UIAlertView alloc] initWithTitle:LocaleStringForKey(NSNoteTitle, nil) message:@"当前版本是最新版本."/*@"The current version is the latest."*/ delegate:nil cancelButtonTitle:LocaleStringForKey(NSSureTitle, nil) otherButtonTitles:nil] autorelease] show];
                        
                        return;
                    }
                }
                
                NSString *updateURL = [dict objectForKey:@"DownLoadUrl"];
                NSString *updateContent = [dict objectForKey:@"Tip"];
                
                if (!updateURL || [updateURL isEqual:[NSNull null]] || [updateURL isEqual:@"<null>"]) {
                    
                } else {
                    [AppManager instance].updateURL = updateURL;
                    DLog(@"%@", [AppManager instance].updateURL);
                }
                
                NSString *isMandatory = [dict objectForKey:@"IsForce"];
                if (!isMandatory || [isMandatory isEqual:[NSNull null]] || [isMandatory isEqual:@"<null>"]) {
                    
                    //                        [self doLoginLogic];
                } else {
                    [AppManager instance].isMandatory = INT_VALUE_FROM_DIC(dict, @"IsForce");
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
        } else if (ret == 101) {
            [[[[UIAlertView alloc] initWithTitle:LocaleStringForKey(NSNoteTitle, nil) message:@"当前版本是最新版本."/*@"The current version is the latest."*/ delegate:nil cancelButtonTitle:LocaleStringForKey(NSSureTitle, nil) otherButtonTitles:nil] autorelease] show];
        }

        self.netBase.requestType=nil;
        
    } else {
        if ([[dic objectForKey:@"ResultCode"] integerValue]==0) {
            self.categoryList=[NSMutableArray arrayWithArray:[[dic objectForKey:@"Data"] objectForKey:@"ItemType"]];
            if ([[[dic objectForKey:@"Data"] objectForKey:@"DefaultAddress"] length]>0) {
                _addressLabel.text=[[dic objectForKey:@"Data"] objectForKey:@"DefaultAddress"];
                _hasAddress=YES;
            }else{
                _hasAddress=NO;
            }
            _farmNameLabel.text=[[dic objectForKey:@"Data"] objectForKey:@"CustomerName"];
            [self.categoryTableView reloadData];
            if ([self.categoryList count]>0) {
                if ([AppManager instance].updateFoodCache) {
                    [self updateFoodListCache];
                }
                self.itemCategoryID=[[self.categoryList objectAtIndex:self.categoryIndex] objectForKey:@"ItemCategoryID"];
                self.netBase.requestType=(RequestType*)BUY_FOODLIST;
                [self.netBase RequestWithRequestType:NET_GET param:[self getParamWithAction:@"GetItemSaleList" UserID:[[AppManager instance].userId length]>0?[AppManager instance].userId:@"59853FB6-F003-47B0-9D06-09D2CE20A14D" Parameters:@{@"ItemCategoryID":self.itemCategoryID}]];
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
        return 71.f;
    }else{
        return 60.f;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:self.categoryTableView]) {
        return [self.categoryList count]<7?7:[self.categoryList count];
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
        
        if (indexPath.row<[self.categoryList count]) {
            NSMutableString* categoryName=[[NSMutableString alloc]initWithString:[[self.categoryList objectAtIndex:indexPath.row] objectForKey:@"ItemCategoryName"]];;
            [cell labelWithTag:10].numberOfLines=[categoryName length];
            
            if (categoryName.length > 2) {
                [categoryName insertString:@"\n" atIndex:1];
                [categoryName insertString:@"\n" atIndex:3];
            } else {
                [categoryName insertString:@"\n" atIndex:1];
            }
            
            [cell setText:categoryName toLabelWithTag:10];
            
            if (indexPath.row==self.categoryIndex) {
                [[cell labelWithTag:10] setTextColor:RGBACOLOR(129, 192, 36, 1)];
            }else{
                [[cell labelWithTag:10] setTextColor:[UIColor blackColor]];
            }
            NSString* categoryID=[[self.categoryList objectAtIndex:indexPath.row] objectForKey:@"ItemCategoryID"];
            NSInteger succ=[self updateCategoryTableView:categoryID];
            if (succ>0) {
                [[cell imageViewWithTag:11] setAlpha:1.0f];
                [[cell labelWithTag:12] setAlpha:1.0f];
                [cell setText:[NSString stringWithFormat:@"%d",succ] toLabelWithTag:12];
            }else{
                [[cell imageViewWithTag:11] setAlpha:0.0f];
                [[cell labelWithTag:12] setAlpha:0.0f];
            }
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
        NSDictionary* d=[self.foodList objectAtIndex:indexPath.row];
        [cell setText:[d objectForKey:@"ItemName"]  toLabelWithTag:10];
        [cell setText:[NSString stringWithFormat:@"%.2f",[[d objectForKey:@"SKUPrice"] floatValue]] toLabelWithTag:11];
        [cell setText:[d objectForKey:@"ItemUnit"] toLabelWithTag:13];
        NSDictionary* res=[self showSelectList:[d objectForKey:@"ItemId"]];
        if (res==nil||[res isEqual:[NSNull null]]) {
            [self resumeAddWeightButton:cell];
        }else{
            [self setAddWeightButton:[res objectForKey:@"title"] cell:cell];
        }
        
        return cell;
        
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([tableView isEqual:self.categoryTableView]) {
        if (indexPath.row<[self.categoryList count]) {
            if (indexPath.row!=self.categoryIndex) {
                //刷新菜单
                self.categoryIndex=indexPath.row;
                self.itemCategoryID=[[self.categoryList objectAtIndex:self.categoryIndex] objectForKey:@"ItemCategoryID"];
                if ([self.foodDic objectForKey:self.itemCategoryID]==nil||[[self.foodDic objectForKey:self.itemCategoryID] isEqual:[NSNull null]]||[[self.foodDic objectForKey:self.itemCategoryID] count]==0) {
                    [self updateFoodList:indexPath];
                    
                }else{
                    if ([AppManager instance].updateFoodCache) {
                        [self updateFoodList:indexPath];
                    }else{
                        //读取缓存
//                        self.categoryIndex=indexPath.row;
//                        self.itemCategoryID=[[self.categoryList objectAtIndex:self.categoryIndex] objectForKey:@"ItemCategoryID"];
                        [self.categoryTableView reloadData];
                        [self.foodList removeAllObjects];
                        self.foodList=[NSMutableArray arrayWithArray:[self.foodDic objectForKey:self.itemCategoryID]];
                        [self.foodTableView reloadData];
                    }
                }
            }
        }
    }else{
        self.netBase.requestType=(RequestType*)BUY_FOODINFORMATION;
        NSString* itemID=[[self.foodList objectAtIndex:indexPath.row] objectForKey:@"ItemId"];
        [self.netBase RequestWithRequestType:NET_GET param:[self getParamWithAction:@"ShowItemDesc" UserID:[[AppManager instance].userId length]>0?[AppManager instance].userId:@"59853FB6-F003-47B0-9D06-09D2CE20A14D" Parameters:@{@"ItemID":itemID}]];
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

#pragma mark-choose select
-(void)updateFoodListCache
{
    [self.foodDic removeAllObjects];
    self.foodDic=[[NSMutableDictionary alloc]initWithCapacity:[self.categoryList count]];
    for (NSDictionary* d in self.categoryList) {
        [self.foodDic setObject:[NSNull null] forKey:[d objectForKey:@"ItemCategoryID"]];
    }
    [self updateCache];
    [AppManager instance].updateFoodCache=NO;
}

-(void)updateFoodList:(NSIndexPath*)indexPath
{
    self.categoryIndex=indexPath.row;
    self.itemCategoryID=[[self.categoryList objectAtIndex:self.categoryIndex] objectForKey:@"ItemCategoryID"];
    [self.categoryTableView reloadData];
    [MBProgressHUD showMessag:@"加载中……" toView:self.view];
    self.netBase.requestType=(RequestType*)BUY_FOODLIST;
    [self.netBase RequestWithRequestType:NET_GET param:[self getParamWithAction:@"GetItemSaleList" UserID:[[AppManager instance].userId length]>0?[AppManager instance].userId:@"59853FB6-F003-47B0-9D06-09D2CE20A14D" Parameters:@{@"ItemCategoryID":self.itemCategoryID}]];
}


-(NSInteger)updateCategoryTableView:(NSString*)categoryID
{
    NSInteger sum=0;
    for (NSString* key in self.selectDict) {
        NSString* categoryId=[[self.selectDict objectForKey:key] objectForKey:@"CategoryID"];
        if ([categoryID isEqualToString:categoryId]) {
            sum++;
        }
    }
    return sum;
}

-(void)updateSelectList:(NSArray*)itemList
{
    if ([itemList count]>0) {
        for (NSDictionary* d in itemList) {
            NSString* categoryID=[d objectForKey:@"ItemCategoryId"];
            NSArray* list=[d objectForKey:@"ItemCartList"];
            
            for (NSDictionary* res in list) {
                
                NSString *itemIdKey = [res objectForKey:@"ItemId"];
                [self.selectDict setObject:@{@"ItemId":itemIdKey, @"CategoryID":categoryID, @"title":[NSString stringWithFormat:@"%@克",[res objectForKey:@"Weight"]]} forKey:itemIdKey];
            }
        }
        [AppManager instance].cartCount=[self.selectDict count];
    }
}

- (NSDictionary*)showSelectList:(NSString*)itemID;
{
    if ([self.selectDict count]==0) {
        return nil;
    }else{
        for (NSString* key in self.selectDict) {
            if ([key isEqualToString:itemID]) {
                return [self.selectDict objectForKey:key];
            }
        }
        return nil;
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
        
        [self.netBase RequestWithRequestType:NET_GET param:[self getParamWithAction:@"PutItemCard" UserID:[[AppManager instance].userId length]>0?[AppManager instance].userId:@"59853FB6-F003-47B0-9D06-09D2CE20A14D" Parameters:@{@"SkuId":SkuId,@"Weight":weight}]];
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


- (void)addAddressButton
{
    if ([[AppManager instance].passwd length]>0) {
        _update=NO;
        AddressListController *addressVC = [[[AddressListController alloc] initWithMOC:_MOC parentVC:nil] autorelease];
        [CommonMethod pushViewController:addressVC withAnimated:YES];
    }else{
        [self askWithMessage:@"尚未登录，请先登录" alertTag:LOGIN_TAG];
    }
}

- (void)setAddWeightButton:(NSString*)title
                      cell:(UITableViewCell*)cell
{
    [[cell imageViewWithTag:14] setFrame:CGRectMake(213, 17, 50, 25)];
    [[cell imageViewWithTag:14] setImage:[UIImage imageNamed:@"farm_dialog.png"]];
    [[cell labelWithTag:15] setAlpha:1.0f];
    [cell setText:title toLabelWithTag:15];
}


-(void)resumeAddWeightButton:(UITableViewCell*)cell
{
    [[cell imageViewWithTag:14] setFrame:CGRectMake(238, 17, 25, 25)];
    [[cell imageViewWithTag:14] setImage:[UIImage imageNamed:@"farm_add.png"]];
    [[cell labelWithTag:15] setAlpha:0.0f];
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
    
    _addressLabel=[[UILabel alloc]initWithFrame:CGRectMake(40, 0, 300, 34)];
    _addressLabel.text=@"";
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
    _farmNameLabel.text=@"";
    _farmNameLabel.textColor=[UIColor redColor];
    _farmNameLabel.font=[UIFont systemFontOfSize:15.0f];
    [superView addSubview:_farmNameLabel];
}



- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [AppManager instance].updateCache=NO;
//    [AppManager instance].updateFoodCache=NO;
    [self updateCache];
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

#pragma mark - update version
- (void)updateVersion
{
    self.netBase.requestType=(RequestType*)UPDATE_VERSION;
    
    [self.netBase RequestWithRequestType:NET_GET param:[self getParamWithAction:@"AppUpdate" UserID:[[AppManager instance].userId length] > 0 ? [AppManager instance].userId:@"59853FB6-F003-47B0-9D06-09D2CE20A14D" Parameters:@{@"AppType":@"ios",@"PackName":@"1",@"ChannelId":@"1",@"Vcode":VERSION}]];
}

#pragma mark - UIAlertViewDelegate method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag != LOGIN_TAG) {

        [alertView release];
    }

    switch (alertView.tag) {
            
        case LOGIN_TAG:
        {
            if (buttonIndex==1) {
                LoginViewController* login=[[LoginViewController alloc]init];
                login.delegate=[UIApplication sharedApplication].delegate;
                [[[UIApplication sharedApplication].delegate window] setRootViewController:login];
            }
        }
            break;
            
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

- (void)doUpdateSoftAction
{
    
    NSMutableDictionary *specialDict = [NSMutableDictionary dictionary];
    [specialDict setValue:VERSION forKey:@"Vcode"];
    [specialDict setValue:@"1" forKey:@"PackName"];
    [specialDict setValue:@"1" forKey:@"ChannelId"];
    [specialDict setValue:@"ios" forKey:@"AppType"];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@%@", VALUE_API_PREFIX, API_SERVICE_USER, API_UPDATE_SERVICE];
    
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
                NSDictionary *dataDict = OBJ_FROM_DIC(resultDict, @"Data");
                
                NSDictionary *dict = OBJ_FROM_DIC(dataDict, @"AppVersion");
                
                if (dict && [dict count] > 0) {
                    
                    NSString *isUpdate = [dict objectForKey:@"IsUpdate"];
                    if (!isUpdate || [isUpdate isEqual:[NSNull null]] || [isUpdate isEqual:@"<null>"]) {
                    } else {
                        int isUpdate = INT_VALUE_FROM_DIC(dict, @"IsUpdate");
                        
                        if (isUpdate != 1) {
//                            [[[[UIAlertView alloc] initWithTitle:LocaleStringForKey(NSNoteTitle, nil) message:@"当前版本是最新版本."/*@"The current version is the latest."*/ delegate:nil cancelButtonTitle:LocaleStringForKey(NSSureTitle, nil) otherButtonTitles:nil] autorelease] show];
                            
                            return;
                        }
                    }
                    
                    NSString *updateURL = [dict objectForKey:@"DownLoadUrl"];
                    NSString *updateContent = [dict objectForKey:@"Tip"];
                    
                    if (!updateURL || [updateURL isEqual:[NSNull null]] || [updateURL isEqual:@"<null>"]) {
                        
                    } else {
                        [AppManager instance].updateURL = updateURL;
                        DLog(@"%@", [AppManager instance].updateURL);
                    }
                    
                    NSString *isMandatory = [dict objectForKey:@"IsForce"];
                    if (!isMandatory || [isMandatory isEqual:[NSNull null]] || [isMandatory isEqual:@"<null>"]) {
                        
                        //                        [self doLoginLogic];
                    } else {
                        [AppManager instance].isMandatory = INT_VALUE_FROM_DIC(dict, @"IsForce");
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
            } else if (ret == 101) {
                [[[[UIAlertView alloc] initWithTitle:LocaleStringForKey(NSNoteTitle, nil) message:@"当前版本是最新版本."/*@"The current version is the latest."*/ delegate:nil cancelButtonTitle:LocaleStringForKey(NSSureTitle, nil) otherButtonTitles:nil] autorelease] show];
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

@end
