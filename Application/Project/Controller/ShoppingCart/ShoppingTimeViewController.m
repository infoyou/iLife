//
//  ShoppingTimeViewController.m
//  iLife
//
//  Created by hys on 14-9-25.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import "ShoppingTimeViewController.h"
#import "UIColor+expanded.h"
#import "UILabel+Category.h"
#import "JILBase.h"
#import "VisitingFarmsViewController.h"
#import "HomeContainerViewController.h"

@interface ShoppingTimeViewController ()<JILNetBaseDelegate>
{
    NSInteger _lastBtn;
}

@property(nonatomic, retain)JILNetBase* netBase;
@property(nonatomic, retain)NSMutableArray* btnAndTickArray;
@property(nonatomic, retain)NSArray* timeInfoArray;
@property(nonatomic, retain)UILabel* priceLabel;
@property(nonatomic, retain)UIScrollView* scrollView;


@end

@implementation ShoppingTimeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    if ([WXWCommonUtils currentOSVersion] < IOS7) {
        self.view.frame = CGRectOffset(self.view.frame, 0, -20);
    }
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setShowsVerticalScrollIndicator:NO];
    [_tableView setHidden:YES];
    
    self.btnAndTickArray=[[NSMutableArray alloc]initWithCapacity:8];
    _lastBtn=0;
    
    UIView* dateTitleView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 45)];
    [dateTitleView setBackgroundColor:[UIColor whiteColor]];
    [self setDateView:dateTitleView];
    [self.view addSubview:dateTitleView];
    
    self.scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 46, 320, 220)];
//    [self setTimeView:scrollView];
    [self.scrollView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.scrollView];
    
    UIView* squareView=[[UIView alloc]initWithFrame:CGRectMake(0, 266, 320, SCREEN_HEIGHT-64-270-45)];
    [squareView setBackgroundColor:[UIColor whiteColor]];
    [self setSquareView:squareView];
    [self.view addSubview:squareView];
    
    UIView* bottomView=[[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-64-46, 320, 46)];
    [bottomView setBackgroundColor:[UIColor whiteColor]];
    [self setBottomView:bottomView];
    [self.view addSubview:bottomView];
    
    self.netBase=[[JILNetBase alloc]init];
    self.netBase.netBaseDelegate=self;
    [self.netBase RequestWithRequestType:NET_GET param:[self getParamWithAction:@"getDeliverTimeList" UserID:[AppManager instance].userId Parameters:@{}]];
}

#pragma mark-handle Request
-(void)handleRequestSuccessData:(id)object
{
    
    NSDictionary* dic=[self JSONValue:object];
    if ([[dic objectForKey:@"ResultCode"] integerValue]==0) {
        if (self.netBase.requestType==(RequestType*)BUY_COMMITCART) {
            //
            [self confirmWithMessage:@"订单已经生成" title:@""];
            self.netBase.requestType=(RequestType*)BUY_DELETECART;
            [self.netBase RequestWithRequestType:NET_GET param:[self getParamWithAction:@"RemoveAllItem" UserID:@"004852E9-7AA1-4C3F-97A3-361B8EA96464" Parameters:@{}]];
        }else if (self.netBase.requestType==(RequestType*)BUY_DELETECART){
            self.netBase.requestType=nil;
            [AppManager instance].updateCache = YES;
            [self.navigationController popToRootViewControllerAnimated:YES];
            [self.homeVC selectFirstTabBar];
        }else{
            self.timeInfoArray=[[dic objectForKey:@"Data"] objectForKey:@"TimeInfo"];
            [self setTimeView:self.scrollView];
        }
        
    }
}

-(void)handleRequestFailedData:(NSError *)error
{
    
}

#pragma mark-Setup ButtonAction
-(void)handleCommitOrder
{
    if (_lastBtn!=0) {
        self.foodParam=[NSMutableArray arrayWithArray:@[@{@"SKUId":@"104081001",@"Weight":@"200"}]];  //初始化的时候已经传值了,后期这个得注释掉，只是为了配合接口才这样写
        
        NSString* TimeID=[[self.timeInfoArray objectAtIndex:_lastBtn-1] objectForKey:@"TimeID"];
//        TimeID=@"2245555555555555";
        self.netBase.requestType=(RequestType*)BUY_COMMITCART;
        [self.netBase RequestWithRequestType:NET_GET param:[self getParamWithAction:@"SubmitDeliveryOrder" UserID:[AppManager instance].userId Parameters:@{@"TimeID":TimeID,@"ItemList":self.foodParam}]];
    }else{
        [self confirmWithMessage:@"请选择时间" title:@""];
    }
    
}
-(void)selectTimeButton:(UIButton*)button
{
    if (_lastBtn==0) {
        _lastBtn=button.tag+1;
        UIImageView* ImgViewNew=(UIImageView*)[[self.btnAndTickArray objectAtIndex:_lastBtn-1] objectForKey:@"Tick"];
        [ImgViewNew setHidden:NO];
    }else{
        UIImageView* ImgView=(UIImageView*)[[self.btnAndTickArray objectAtIndex:_lastBtn-1] objectForKey:@"Tick"];
        [ImgView setHidden:YES];
        _lastBtn=button.tag+1;
        UIImageView* ImgViewNew=(UIImageView*)[[self.btnAndTickArray objectAtIndex:_lastBtn-1] objectForKey:@"Tick"];
        [ImgViewNew setHidden:NO];
    }
    
}

#pragma mark-Setup MainView
-(void)setBottomView:(UIView*)superView
{
    UIButton* commitBtn=[[UIButton alloc]initWithFrame:CGRectMake(117, 7, 85, 30)];
    [commitBtn setBackgroundImage:[UIImage imageNamed:@"shoppingcart_commit_normal.png"] forState:UIControlStateNormal];
    [commitBtn setBackgroundImage:[UIImage imageNamed:@"shoppingcart_commit_light.png"] forState:UIControlStateHighlighted];
    [commitBtn setTitle:@"立即下单" forState:UIControlStateNormal];
    [commitBtn.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
    [commitBtn addTarget:self action:@selector(handleCommitOrder) forControlEvents:UIControlEventTouchUpInside];
    [superView addSubview:commitBtn];
    
    self.priceLabel=[[UILabel alloc]initWithFrame:CGRectMake(220, 10, 100, 25)];
    [self.priceLabel setLabelWithSize:14.0f Color:[UIColor colorWithRGBHex:0xcc3333]];
    self.priceLabel.text=[NSString stringWithFormat:@"总计¥%.2f元",self.totalPrice];
    [superView addSubview:self.priceLabel];

}
-(void)setSquareView:(UIView*)superView
{
    for (int i=0; i<3; i++) {
        UIImageView* ImgView=[[UIImageView alloc]initWithFrame:CGRectMake(40, 20+i*45, 25, 25)];
        UILabel* lab=[[UILabel alloc]initWithFrame:CGRectMake(85, 20+i*45, 180, 25)];
        [lab setLabelWithSize:14.0f Color:[UIColor colorWithRGBHex:0x666666]];
        switch (i) {
            case 0:
            {
                ImgView.image=[UIImage imageNamed:@"shoppingcart_square_green.png"];
                lab.text=@"配送时间充裕";
            }
                break;
            case 1:
            {
                ImgView.image=[UIImage imageNamed:@"shoppingcart_square_yellow.png"];
                lab.text=@"配送时间紧张";
            }
                break;
            case 2:
            {
                ImgView.image=[UIImage imageNamed:@"shoppingcart_square_gray.png"];
                lab.text=@"不能配送";
            }
                break;
            default:
                break;
        }
        [superView addSubview:ImgView];
        [superView addSubview:lab];
        
    }
    [self setLineView:superView];
}

- (void)setTimeView:(UIView*)superView
{
    if ([self.timeInfoArray count]>0) {
        for (int i=0; i<[self.timeInfoArray count]; i++) {
            CGFloat x=i%2==0?40:180;
            UIButton* btn=[[UIButton alloc]initWithFrame:CGRectMake(x, (i/2)*50+20, 100, 30)];
            UIColor* color=[self setColor:[[[self.timeInfoArray objectAtIndex:i] objectForKey:@"Status"] integerValue]];
            if ([[[self.timeInfoArray objectAtIndex:i] objectForKey:@"Status"] integerValue]==2) {
                btn.enabled=NO;
            }
            [btn setBackgroundColor:color];
            btn.tag=i;
            [btn.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
            [self setBtnStr:btn];
            [btn addTarget:self action:@selector(selectTimeButton:) forControlEvents:UIControlEventTouchUpInside];
            [superView addSubview:btn];
            CGRect frame=btn.frame;
            UIImageView* tick=[[UIImageView alloc]initWithFrame:CGRectMake(frame.origin.x+frame.size.width-26, frame.origin.y+frame.size.height/2, 31, 27)];
            tick.image=[UIImage imageNamed:@"shoppingcart_tick.png"];
            [tick setHidden:YES];
            [superView addSubview:tick];
            NSDictionary* dic=@{@"Button":btn,@"Tick":tick};
            [self.btnAndTickArray addObject:dic];
        }
    }
    [self setLineView:superView];
    
    
    
}


- (void)setDateView:(UIView*)superView
{
    UILabel* diliverylab=[[UILabel alloc]initWithFrame:CGRectMake(10, 15, 65, 15)];
    diliverylab.text=@"送货日期:";
    [diliverylab setLabelWithSize:15.0f Color:[UIColor colorWithRGBHex:0x666666]];
    [superView addSubview:diliverylab];
    UILabel* daylab=[[UILabel alloc]initWithFrame:CGRectMake(85, 15, 30, 15)];
    daylab.text=@"今天";
    [daylab setLabelWithSize:15.0f Color:[UIColor colorWithRGBHex:0x82bf24]];
    [superView addSubview:daylab];
    UILabel* datelab=[[UILabel alloc]initWithFrame:CGRectMake(125, 15, 65, 15)];
    datelab.text=[self strWithDate:[NSDate date]];
    [datelab setLabelWithSize:15.0f Color:[UIColor colorWithRGBHex:0x666666]];
    [superView addSubview:datelab];
    UIImageView* arrow=[[[UIImageView alloc]initWithFrame:CGRectMake(304, 17, 6, 10)] autorelease];
    arrow.image=[UIImage imageNamed:@"farm_arrow.png"];
    [superView addSubview:arrow];
    [self setLineView:superView];
}

-(void)setLineView:(UIView*)superView
{
    UIImageView* addressline=[[[UIImageView alloc]initWithFrame:CGRectMake(0, superView.frame.size.height-1, 320, 1)] autorelease];
    addressline.image=[UIImage imageNamed:@"farm_line.png"];
    [addressline setAlpha:0.8];
    [superView addSubview:addressline];
}

-(NSString*)strWithDate:(NSDate*)date
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *comps = [gregorian components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit fromDate:date];
    NSInteger month=[comps month];
    
    NSInteger day=[comps day];
    NSMutableString* str=[[NSMutableString alloc]initWithString:@""];
    
    [str appendString:month<10?[NSString stringWithFormat:@"0%d月",month]:[NSString stringWithFormat:@"%d月",month]];
    [str appendString:day<10?[NSString stringWithFormat:@"0%d日",day]:[NSString stringWithFormat:@"%d日",day]];
    return str;
}
-(UIColor*)setColor:(NSInteger)status
{
    switch (status) {
        case 0:
            return [UIColor colorWithRGBHex:0x82bf24];
            break;
        case 1:
            return [UIColor colorWithRGBHex:0xffa74f];
            break;
        case 2:
            return [UIColor colorWithRGBHex:0xcccccc];
            break;
        default:
            return [UIColor colorWithRGBHex:0xcccccc];
            break;
    }
}
-(void)setBtnStr:(UIButton*)btn
{
    NSDictionary* dic=[self.timeInfoArray objectAtIndex:btn.tag];
    NSString* str=[NSString stringWithFormat:@"%@-%@",[dic objectForKey:@"BeginTime"],[dic objectForKey:@"EndTime"]];
    [btn setTitle:str forState:UIControlStateNormal];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
