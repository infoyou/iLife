
#import "OrderPayViewController.h"
#import "AlixLibService.h"
#import "PartnerConfig.h"
#import "AlixPayOrder.h"
#import "DataSigner.h"
#import "AlixPayResult.h"
#import "DataVerifier.h"

#define FOOTER_H    47

@interface OrderPayViewController () <UIGestureRecognizerDelegate> {
    
    int tableHeight;
    int selIndex;
    BOOL checkFlag;
}

@property (nonatomic, copy) NSString *totalAmountStr;

@end

@implementation OrderPayViewController {

    NSMutableDictionary* mImgCacheDic;
}

@synthesize totalAmountStr = _totalAmountStr;

- (id)initWithMOC:(NSManagedObjectContext *)MOC totalAmount:(NSString *)totalAmount
{
    
    self = [super initNoNeedDisplayEmptyMessageTableWithMOC:MOC
                                      needRefreshHeaderView:NO
                                      needRefreshFooterView:NO
                                                 tableStyle:UITableViewStylePlain];
    if (self) {
        tableHeight = 170;
        selIndex = 0;
        _totalAmountStr = totalAmount;
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"支付";
    
    [self prepareData];
    
    if ([WXWCommonUtils currentOSVersion] < IOS7) {
        self.view.frame = CGRectOffset(self.view.frame, 0, -20);
    }
    
    _tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - FOOTER_H);
    
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setShowsVerticalScrollIndicator:NO];
    
    [self addFootView];

    checkFlag = YES;
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

#pragma mark - add View

- (void)addFootView
{
    UIImageView *splitImg = (UIImageView *)[self.view viewWithTag:200];
    UILabel *payLabel = (UILabel *)[self.view viewWithTag:201];
    UILabel *payTotalLabel = (UILabel *)[self.view viewWithTag:202];
    
    payTotalLabel.text = [NSString stringWithFormat:@"￥%@", _totalAmountStr];
    
    UIButton *payBtn = (UIButton *)[self.view viewWithTag:203];
    
    payBtn.layer.cornerRadius = 3.f;
    payBtn.layer.masksToBounds = YES;
    
    if (SCREEN_HEIGHT < 568) {

        splitImg.frame = CGRectOffset(splitImg.frame, 0, -88);
        payLabel.frame = CGRectOffset(payLabel.frame, 0, -88);
        payTotalLabel.frame = CGRectOffset(payTotalLabel.frame, 0, -88);
        payBtn.frame = CGRectOffset(payBtn.frame, 0, -88);
    }

}

#pragma mark - table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 58;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return tableHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *materialCellIdentifier = @"OrderPayCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:materialCellIdentifier];
    
    for (UIView *subView in cell.contentView.subviews)
    {
        [subView removeFromSuperview];
    }
    
    //            if (cell == nil) {
    
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"OrderPayCell" owner:self options:nil];
    
    cell = [nib objectAtIndex:0];
    //            }
    
    UIImageView *optionImg = (UIImageView *)[cell viewWithTag:11];
    if (selIndex != indexPath.row) {
        optionImg.image = [UIImage imageNamed:@"pay_option.png"];
    } else {
        optionImg.image = [UIImage imageNamed:@"pay_option_sel.png"];
    }
    
    UIImageView *bgImg = (UIImageView *)[cell viewWithTag:10];
    UIImageView *payTypeImg = (UIImageView *)[cell viewWithTag:12];
    UILabel *payTextLabel = (UILabel *)[cell viewWithTag:13];
    UILabel *payRemarkLabel = (UILabel *)[cell viewWithTag:14];
    
    bgImg.layer.borderWidth = 0.6f;
    bgImg.layer.masksToBounds = YES;
    bgImg.layer.borderColor = HEX_COLOR(@"0xd6d6d6").CGColor;
    
    switch (indexPath.row) {
        case 0:
        {
            payTypeImg.image = [UIImage imageNamed:@"pay_alipay.png"];
            payTextLabel.text = @"支付宝扫码支付:";
            payRemarkLabel.text = @"推荐有支付宝账号的用户使用";
        }
            break;
        
        case 1:
        {
            payTypeImg.image = [UIImage imageNamed:@"pay_cft.png"];
            payTextLabel.text = @"财付通扫码支付:";
            payRemarkLabel.text = @"推荐有财付通账号的用户使用";
        }
            break;
            
        case 2:
        {
            payTypeImg.image = [UIImage imageNamed:@"pay_union.png"];
            payTextLabel.text = @"银联支付:";
            payRemarkLabel.text = @"支持银行卡支付,需开通网银";
        }
            break;
            
        default:
            break;
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"OrderPayHead" owner:self options:nil];
    UITableViewCell* cell = [nib objectAtIndex:0];
    
    cell.userInteractionEnabled = YES;
    
    UILabel *amountLabel = (UILabel *)[cell viewWithTag:100];
    UIImageView *bgImg = (UIImageView *)[cell viewWithTag:101];
    UIImageView *checkBoxImg = (UIImageView *)[cell viewWithTag:102];
    UILabel *checkLabel = (UILabel *)[cell viewWithTag:103];
    
    amountLabel.text = [NSString stringWithFormat:@"￥%@", _totalAmountStr];
    
    bgImg.userInteractionEnabled = YES;
    checkBoxImg.userInteractionEnabled = YES;
    checkLabel.userInteractionEnabled = YES;
    
    bgImg.layer.borderWidth = 0.6f;
    bgImg.layer.masksToBounds = YES;
    bgImg.layer.borderColor = HEX_COLOR(@"0xd6d6d6").CGColor;
    
    [self addTapGestureRecognizer:bgImg];
    [self addTapGestureRecognizer:checkBoxImg];
    [self addTapGestureRecognizer:checkLabel];
    
    checkBoxImg.highlighted = checkFlag;
    
    return cell.contentView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selIndex = indexPath.row;
    
    [_tableView reloadData];
}

- (void)updateOrderAmount:(NSString *)totalAmount
{
    _totalAmountStr = totalAmount;
    [_tableView reloadData];
}

#pragma mark - for gesture
- (void)addTapGestureRecognizer:(UIView*)targetImageview {
    UITapGestureRecognizer *swipeGR = [[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                               action:@selector(imageviewTouchEvents:)] autorelease];
    swipeGR.delegate = self;
    
    [targetImageview addGestureRecognizer:swipeGR];
    [mImgCacheDic setObject:targetImageview forKey:[NSString stringWithFormat:@"%d", targetImageview.tag]];
    
}

- (void)imageviewTouchEvents:(UIGestureRecognizer *)gestureRecognizer
{

    UIView *view = (UIView *)[gestureRecognizer view];
    int tagValue = view.tag;
    DLog(@"%d is touched",tagValue);
    

    if (tagValue == 101 || tagValue == 102) {
       
        UIImageView *checkImgView = (UIImageView *)[mImgCacheDic objectForKey:@"102"];
        checkImgView.highlighted = !checkImgView.isHighlighted;
        checkFlag = checkImgView.isHighlighted;
    } else if(tagValue == 103) {
        
        UIImageView *checkImgView = (UIImageView *)[mImgCacheDic objectForKey:@"102"];
        checkImgView.highlighted = !checkImgView.isHighlighted;
        checkFlag = checkImgView.isHighlighted;
    }
}

#pragma mark - btn Click pay
- (IBAction)btnClick:(id)send
{
    
    // add notify
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePayResultStatus)
                                                 name:NOTIFY_PAY_RESULT_STATUS
                                               object:nil];
    
    /*
     *生成订单信息及签名
     *由于demo的局限性，采用了将私钥放在本地签名的方法，商户可以根据自身情况选择签名方法(为安全起见，在条件允许的前提下，我们推荐从商户服务器获取完整的订单信息)
     */
    
    NSString *appScheme = @"iLifeAlipay";
    NSString* orderInfo = [self getOrderInfo];
    NSString* signedStr = [self doRsa:orderInfo];
    
    NSLog(@"%@",signedStr);
    
    NSString *orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                             orderInfo, signedStr, @"RSA"];
    
    [AlixLibService payOrder:orderString AndScheme:appScheme seletor:@selector(paymentResult:) target:self];
}

- (NSString*)getOrderInfo
{
    AlixPayOrder *order = [[AlixPayOrder alloc] init];
    order.partner = PartnerID;
    order.seller = SellerID;
    
    order.tradeNO = [self generateTradeNO]; //订单ID（由商家自行制定）
    order.productName = @"商品标题";
    order.productDescription = @"商品描述";
    order.amount = _totalAmountStr;
//    [NSString stringWithFormat:@"%.2f", product.price]; //商品价格
    order.notifyURL =  @"http%3A%2F%2Fwwww.xxx.com"; //回调URL
    
    return [order description];
}

- (NSString *)generateTradeNO
{
    const int N = 15;
    
    NSString *sourceString = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *result = [[NSMutableString alloc] init] ;
    srand(time(0));
    for (int i = 0; i < N; i++)
    {
        unsigned index = rand() % [sourceString length];
        NSString *s = [sourceString substringWithRange:NSMakeRange(index, 1)];
        [result appendString:s];
    }
    return result;
}

- (NSString*)doRsa:(NSString*)orderInfo
{
    id<DataSigner> signer;
    signer = CreateRSADataSigner(PartnerPrivKey);
    NSString *signedString = [signer signString:orderInfo];
    return signedString;
}

- (void)paymentResultDelegate:(NSString *)result
{
    NSLog(@"%@",result);
}

//wap回调函数
-(void)paymentResult:(NSString *)resultd
{
    //结果处理
#if ! __has_feature(objc_arc)
    AlixPayResult* result = [[[AlixPayResult alloc] initWithString:resultd] autorelease];
#else
    AlixPayResult* result = [[AlixPayResult alloc] initWithString:resultd];
#endif
    if (result)
    {
        
        if (result.statusCode == 9000)
        {
            /*
             *用公钥验证签名 严格验证请使用result.resultString与result.signString验签
             */
            
            //交易成功
            NSString* key = AlipayPubKey;//签约帐户后获取到的支付宝公钥
            id<DataVerifier> verifier;
            verifier = CreateRSADataVerifier(key);
            
            if ([verifier verifyString:result.resultString withSign:result.signString])
            {
                //验证签名成功，交易结果无篡改
                
                ShowAlert(self, NSLocalizedString(NSNoteTitle, nil), @"支付成功\n货物将在18:30-19:00送达\n请注意查收", NSLocalizedString(NSSureTitle, nil));
            }
        } else {
            //交易失败
        }
    } else {
        //失败
    }
    
}

- (void)handlePayResultStatus
{
    NSLog(@"handlePayResultStatus");
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_PAY_RESULT_STATUS object:nil];
}

@end
