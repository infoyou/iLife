
#import "OrderPayViewController.h"

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
    
    if (SCREEN_HEIGHT == 480) {

//        splitImg.frame = CGRectOffset(splitImg.frame, 0, -88);
//        payLabel.frame = CGRectOffset(payLabel.frame, 0, -88);
//        payTotalLabel.frame = CGRectOffset(payTotalLabel.frame, 0, -88);
//        payBtn.frame = CGRectOffset(payBtn.frame, 0, -88);
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

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footView = [[[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - FOOTER_H, SCREEN_WIDTH, FOOTER_H)] autorelease];
    footView.backgroundColor = [UIColor redColor];
    
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"OrderPayFoot" owner:self options:nil];
    UITableViewCell* cell = [nib objectAtIndex:0];
    
    cell.frame = CGRectMake(0, SCREEN_HEIGHT - FOOTER_H, SCREEN_WIDTH, FOOTER_H);
    
    UIButton *payBtn = (UIButton *)[cell viewWithTag:203];
    payBtn.layer.cornerRadius = 3.f;
    payBtn.layer.masksToBounds = YES;
    [payBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [footView addSubview:cell.contentView];
    return footView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selIndex = indexPath.row;
    
    [_tableView reloadData];
}

#pragma mark - btn Click
- (IBAction)btnClick:(id)send
{
    ShowAlert(self, NSLocalizedString(NSNoteTitle, nil), @"支付成功\n货物将在18:30-19:00送达\n请注意查收", NSLocalizedString(NSSureTitle, nil));
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

@end
