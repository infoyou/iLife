//
//  MerchantsListViewController.m
//  Project
//
//  Created by Adam on 14-9-3.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import "MerchantsListViewController.h"
#import "ZBarSDK.h"

#define KSEARCHBAR_HEIGHT   44.0f
#define kTableSectionHeight 11.f

#define kTableFootheight    200

@implementation MerchantItem

@synthesize merchantId = _merchantId;
@synthesize merchantName = _merchantName;
@synthesize merchantUserName = _merchantUserName;

- (void)dealloc
{
    [_merchantId release];
    [_merchantName release];
    [_merchantUserName release];
    
    [super dealloc];
}

@end

@interface MerchantsListViewController () <UISearchBarDelegate>
{
    UISearchBar *_searchBar;
    UITableView *_storeTable;
    UIView *_searchBGView;
    NSMutableArray *_merchantArray;
}

@property (nonatomic, retain) UISearchBar *_searchBar;
@property (nonatomic, retain) UITableView *_storeTable;
@property (nonatomic, retain) UIView *_searchBGView;

@end


@implementation MerchantsListViewController
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
        self.title = @"常用卖家";
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
    
    [self addRightBarButtonWithTitle:@"+创建" target:self action:@selector(addNewAddress:)];
    
    _merchantArray = [[NSMutableArray alloc] initWithCapacity:10];
    
    [self getPrioritySeller];
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
    return _merchantArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return MERCHANTS_CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self drawCellContentWithTable:tableView atIndexPath:indexPath];
}

- (MerchantsListCell *)drawCellContentWithTable:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellIdentifier = @"MerchantsListCell";
    MerchantsListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (nil == cell)
    {
        cell = [[[MerchantsListCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:kCellIdentifier] autorelease];
    }
    [cell.contentView setBackgroundColor:[UIColor clearColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    MerchantItem *merchantItem = [_merchantArray objectAtIndex:indexPath.row];
    [cell updataCellData:merchantItem];
    
    UIView *lineView = [[[UIView alloc] initWithFrame:CGRectMake(11, MERCHANTS_CELL_HEIGHT-1, SCREEN_WIDTH-11, 0.6f)] autorelease];
    lineView.backgroundColor = HEX_COLOR(@"0xdddddd");
    [cell.contentView addSubview:lineView];
    
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"Click  Cell Index (%d)",indexPath.row);
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    
    if (section == 0)
    {
        UIView *footBGView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kTableFootheight)] autorelease];
        [footBGView setBackgroundColor:TRANSPARENT_COLOR];
        
        UIView *footView = [[[UIView alloc] initWithFrame:CGRectMake(0, kTableSectionHeight, SCREEN_WIDTH, MERCHANTS_CELL_HEIGHT)] autorelease];
        [footView setBackgroundColor:[UIColor whiteColor]];
        
//        [footView addSubview:[self createScanningBtn]];
        
        [footBGView addSubview:footView];
        
        return footBGView;
    } else {
        return nil;
    }
    
}

- (UIButton *)createScanningBtn
{
    UIButton *logoutBtn = [[[UIButton alloc]initWithFrame:CGRectMake(35, kTableFootheight - 50, SCREEN_WIDTH - 35*2, 50)] autorelease];
    [logoutBtn setBackgroundColor:HEX_COLOR(@"0xffa74e")];
    [logoutBtn.titleLabel setFont:FONT_SYSTEM_SIZE(16)];
    [logoutBtn setTitleColor:HEX_COLOR(@"0xffffff") forState:UIControlStateNormal];
    [logoutBtn setTitleColor:HEX_COLOR(@"0xffffff") forState:UIControlStateSelected];
    [logoutBtn setTitle:LocaleStringForKey(@"扫描", Nil) forState:UIControlStateNormal];
    [logoutBtn addTarget:self action:@selector(doScanning) forControlEvents:UIControlEventTouchUpInside];
    
    // layer
    [logoutBtn.layer setBorderWidth:1.0];
    [logoutBtn.layer setBorderColor:HEX_COLOR(@"0xffa74e").CGColor];
    [logoutBtn.layer setCornerRadius:3];
    [logoutBtn.layer setMasksToBounds:YES];
    
    return logoutBtn;
}

- (void)doScanning
{
}

- (void)getPrioritySeller
{
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@%@", VALUE_API_PREFIX, API_SERVICE_USER, API_GET_PRIORITY_SELLER];
    NSString *url = [ProjectAPI getURL:urlStr specialDict:nil];
    DLog(@"url = %@", url);
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:GET_PRIORITY_SELLER_TY];
    
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
            
        case API_SELLER_PRIORITY_TY:
        {
            [self getPrioritySeller];
            
            break;
        }
            
        case GET_PRIORITY_SELLER_TY:
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
                
                if (_merchantArray && [_merchantArray count]>0) {
                    [_merchantArray removeAllObjects];
                }
                
                NSArray *list = OBJ_FROM_DIC(dict, @"PrioritySeller");
                for (NSDictionary *dic in list) {
                    NSString *unitID = STRING_VALUE_FROM_DIC(dic, @"UnitID");
                    NSString *itemCategoryID = STRING_VALUE_FROM_DIC(dic, @"ItemCategoryID");
                    NSString *itemCategoryName = STRING_VALUE_FROM_DIC(dic, @"ItemCategoryName");
                    NSString *name = STRING_VALUE_FROM_DIC(dic, @"Name");
                    
                    MerchantItem *merchantItem = [[MerchantItem alloc] init];
                    merchantItem.merchantId = itemCategoryID;
                    merchantItem.merchantName = itemCategoryName;
                    merchantItem.merchantUserName = name;
                    
                    [_merchantArray addObject:merchantItem];
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

- (void)addNewAddress:(id)sender {
    
    /*扫描二维码部分：
     导入ZBarSDK文件并引入一下框架
     AVFoundation.framework
     CoreMedia.framework
     CoreVideo.framework
     QuartzCore.framework
     libiconv.dylib
     引入头文件#import “ZBarSDK.h” 即可使用
     当找到条形码时，会执行代理方法
     
     - (void) imagePickerController: (UIImagePickerController*) reader didFinishPickingMediaWithInfo: (NSDictionary*) info
     
     最后读取并显示了条形码的图片和内容。*/
    
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    ZBarImageScanner *scanner = reader.scanner;
    
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    [self presentModalViewController: reader
                            animated: YES];
    [reader release];

}

- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    id<NSFastEnumeration> results =
    [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        break;
    
    [reader dismissModalViewControllerAnimated: YES];
    
    NSString *resultStr =  symbol.data ;    
    NSLog(@"resultStr = %@", resultStr);
    
    NSDictionary *specialDict = [resultStr objectFromJSONString];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@%@", VALUE_API_PREFIX, API_SERVICE_USER, API_SELLER_PRIORITY];
    NSString *url = [ProjectAPI getURL:urlStr specialDict:specialDict];
    DLog(@"url = %@", url);
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:API_SELLER_PRIORITY_TY];
    
    [connFacade fetchGets:url];

}

@end
