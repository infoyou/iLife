//
//  AddressListController.m
//  Project
//
//  Created by Adam on 14-9-3.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import "AddressListController.h"
#import "NewAddressViewController.h"

#define KSEARCHBAR_HEIGHT 44.0f

@implementation AddressItem

@synthesize addressId = _addressId;
@synthesize addressReceiver = _addressReceiver;
@synthesize receiverMobile = _receiverMobile;
@synthesize addressCity = _addressCity;
@synthesize addressArea = _addressArea;
@synthesize addressName = _addressName;
@synthesize addressIsDefault = _addressIsDefault;

- (void)dealloc
{
    [_addressId release];
    [_addressReceiver release];
    [_receiverMobile release];
    [_addressCity release];
    [_addressArea release];
    [_addressName release];
    [_addressIsDefault release];
    
    [super dealloc];
}

@end

@interface AddressListController () <AddressClickDelegate, UISearchBarDelegate>
{
    UISearchBar *_searchBar;
    UITableView *_storeTable;
    UIView *_searchBGView;
    NSMutableArray *_addressArray;
}

@property (nonatomic, retain) UISearchBar *_searchBar;
@property (nonatomic, retain) UITableView *_storeTable;
@property (nonatomic, retain) UIView *_searchBGView;

@end


@implementation AddressListController
{
    int defaultIndex;
    int delIndex;
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
        delIndex = 0;
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"选择地址";
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
    
    [self addRightBarButtonWithTitle:@"+添加" target:self action:@selector(addNewAddress:)];
    
    [self getDeliveryAddress];
    _addressArray = [[NSMutableArray alloc] initWithCapacity:10];
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
    return _addressArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ADDRESS_CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self drawCellContentWithTable:tableView atIndexPath:indexPath];
}

- (AddressListCell *)drawCellContentWithTable:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellIdentifier = @"AddressListCell";
    AddressListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (nil == cell)
    {
        cell = [[[AddressListCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:kCellIdentifier
                                  addressClickDelegate:self] autorelease];
    }
    [cell.contentView setBackgroundColor:[UIColor clearColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    BOOL showButFlag = NO;
    if (indexPath.row != defaultIndex) {
        showButFlag = YES;
    }
    
    AddressItem *addressItem = (AddressItem *)[_addressArray objectAtIndex:indexPath.row];
    [cell updataCellData:addressItem showButFlag:showButFlag];
    
    UIView *lineView = [[[UIView alloc] initWithFrame:CGRectMake(11, ADDRESS_CELL_HEIGHT-1, SCREEN_WIDTH-11, 0.6f)] autorelease];
    lineView.backgroundColor = HEX_COLOR(@"0xdddddd");
    [cell.contentView addSubview:lineView];
    
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"Click  Cell Index (%d)",indexPath.row);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - AddressClickDelegate method
- (void)clickAddressBtn:(id)Object
{
    UITableViewCell *selCell = (UITableViewCell *)Object;
    NSIndexPath* indexPath = [_storeTable indexPathForCell:selCell];
    defaultIndex = indexPath.row;
    
    [self setDefaultAddress];
}

- (void)delAddressBtn:(id)Object
{
    UITableViewCell *selCell= (UITableViewCell *)Object;
    NSIndexPath* indexPath = [_storeTable indexPathForCell:selCell];
    delIndex = indexPath.row;
    [self delDeliveryAddress];
}

- (void)addNewAddress:(id)sender {
    
    // add New Address
    NewAddressViewController *platNotifyDetail = [[[NewAddressViewController alloc] initWithNibName:@"NewAddressViewController" bundle:nil
                                                                                                            moc:nil] autorelease];
    
    [CommonMethod pushViewController:platNotifyDetail withAnimated:YES];
}

- (void)getDeliveryAddress
{
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@%@", VALUE_API_PREFIX, API_SERVICE_USER, API_GET_DELIVERY_ADDRESS];
    NSString *url = [ProjectAPI getURL:urlStr specialDict:nil];
    DLog(@"url = %@", url);
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:GET_DELIVERY_ADDRESS_TY];
    
    [connFacade fetchGets:url];
}

- (void)delDeliveryAddress
{
    AddressItem* addressItem=(AddressItem*)[_addressArray objectAtIndex:delIndex];
    NSString* addressID=addressItem.addressId;
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@%@", VALUE_API_PREFIX, API_SERVICE_USER, API_DEL_DELIVERY_ADDRESS];
    NSString *url = [ProjectAPI getURL:urlStr specialDict:@{@"DeliveryAddressID":addressID}];
    DLog(@"url = %@", url);
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:DEL_ADDRESS_TY];
    [connFacade fetchGets:url];
}


- (void)setDefaultAddress
{
    
    AddressItem *addressItem = [_addressArray objectAtIndex:defaultIndex];
    NSMutableDictionary *specialDict = [NSMutableDictionary dictionary];
    [specialDict setValue:addressItem.addressId forKey:@"DeliveryAddressID"];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@%@", VALUE_API_PREFIX, API_SERVICE_USER, API_SET_DEFAULT_ADDRESS];
    NSString *url = [ProjectAPI getURL:urlStr specialDict:specialDict];
    DLog(@"url = %@", url);
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:SET_DEFAULT_ADDRESS_TY];
    
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
            
        case SET_DEFAULT_ADDRESS_TY:
        {
            [_storeTable reloadData];
            break;
        }
            
        case GET_DELIVERY_ADDRESS_TY:
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
                
                NSArray *list = OBJ_FROM_DIC(dict, @"DeliveryAddress");
                for (NSDictionary *dic in list) {
                    
                    AddressItem *addressItem = [[AddressItem alloc] init];
                    addressItem.addressId = STRING_VALUE_FROM_DIC(dic, @"DeliveryAddressID");
                    addressItem.addressReceiver = STRING_VALUE_FROM_DIC(dic, @"Receiver");
                    addressItem.receiverMobile = STRING_VALUE_FROM_DIC(dic, @"MobileNumber");
                    addressItem.addressCity = STRING_VALUE_FROM_DIC(dic, @"City");
                    addressItem.addressArea = STRING_VALUE_FROM_DIC(dic, @"Area");
                    addressItem.addressName = STRING_VALUE_FROM_DIC(dic, @"DetailedAddress");
                    addressItem.addressIsDefault = STRING_VALUE_FROM_DIC(dic, @"IsDefault");
                    
                    [_addressArray addObject:addressItem];
                }
                
                [self._storeTable reloadData];
            }
            
            break;
        }
            
        case DEL_ADDRESS_TY:
        {
            ConnectionAndParserResultCode ret = [JSONParser parserResponseJsonData:result
                                                                              type:contentType
                                                                               MOC:_MOC
                                                                 connectorDelegate:self
                                                                               url:url
                                                                           paramID:0];
            
            if (ret == SUCCESS_CODE){
                [self getDeliveryAddress];
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
