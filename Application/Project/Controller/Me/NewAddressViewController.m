//
//  NewAddressViewController.m
//  Association
//
//  Created by Adam on 14-6-25.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import "NewAddressViewController.h"
#import "JILBase.h"
#import "JILOptionPicker.h"

#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
#define CITY_TAG 10
#define AREA_TAG 11
#define AREAESTATE_TAG 12
@interface NewAddressViewController ()<JILNetBaseDelegate>
{
}

@property(nonatomic, retain)JILOptionPicker* pickerView;
@property(nonatomic, retain)JILNetBase* netBase;
@property(nonatomic, retain)NSArray* cityArray;
@property(nonatomic, retain)NSArray* districtArray;
@property(nonatomic, retain)NSArray* communityArray;
@property(nonatomic, retain)NSMutableArray* options;
@property(nonatomic, retain)UILabel* pickerTitleLab;
@property(nonatomic, retain)NSString* cityID;
@property(nonatomic, retain)NSString* areaID;
@property(nonatomic, retain)NSString* estateID;
@property(nonatomic)NSInteger flag;

@property (retain, nonatomic) IBOutlet UITextField *cityTextField;
@property (retain, nonatomic) IBOutlet UITextField *districtTextField;
@property (retain, nonatomic) IBOutlet UITextField *communityTextField;
@property (retain, nonatomic) IBOutlet UITextField *nameTextField;
@property (retain, nonatomic) IBOutlet UITextField *mobileNumberTextField;
@property (retain, nonatomic) IBOutlet UITextField *detailAddressTextField;

@end

@implementation NewAddressViewController
{
}

@synthesize mTitleLabel = _mTitleLabel;
@synthesize mDateLabel = _mDateLabel;
@synthesize mDescLabel = _mDescLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
                  moc:(NSManagedObjectContext*)viewMOC 
{
    self = [super initWithMOC:viewMOC];
    if (self) {
        _noNeedBackButton = NO;
        self.view = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil].view;
        self.netBase=[[JILNetBase alloc]init];
        self.netBase.netBaseDelegate=self;
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = LocaleStringForKey(@"添加新地址", nil);
    
    [self addRightBarButtonWithTitle:@"保存" target:self action:@selector(saveAddress:)];
    
    self.pickerView=[[JILOptionPicker alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self setPickerView];
    [self.pickerView setOptions:[NSArray array]];
    [self.pickerView setAlpha:0.0f];
    [[[UIApplication sharedApplication].delegate window] addSubview:self.pickerView];
    
    self.cityArray=[NSArray array];
    self.districtArray=[NSArray array];
    self.communityArray=[NSArray array];
    self.options=[[NSMutableArray alloc]initWithCapacity:10];
    
    
}

- (void)setPickerView
{
    UIImageView* bg=[[UIImageView alloc]initWithFrame:self.pickerView.frame];
    bg.image=[UIImage imageNamed:@"farm_bg.png"];
    [self.pickerView addSubview:bg];

    UIView* contengView=[[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-280, SCREEN_WIDTH, 280)];
    [contengView setBackgroundColor:[UIColor whiteColor]];
    [self.pickerView addSubview:contengView];
    
    
    self.pickerTitleLab=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.pickerView.frame.size.width, 46)];
    self.pickerTitleLab.text=@"";
    self.pickerTitleLab.textColor=RGBACOLOR(129, 192, 36, 1);
    self.pickerTitleLab.textAlignment=NSTextAlignmentCenter;
    self.pickerTitleLab.font=[UIFont systemFontOfSize:17.0f];
    [contengView addSubview:self.pickerTitleLab];
    
    UILabel* lineLab=[[UILabel alloc]initWithFrame:CGRectMake(10, 45, SCREEN_WIDTH-20, 1)];
    [lineLab setBackgroundColor:RGBACOLOR(129, 192, 36, 1)];
    [contengView addSubview:lineLab];
    
    UIPickerView* pickerView=[[UIPickerView alloc]initWithFrame:CGRectMake(0, 37, SCREEN_WIDTH, 162)];
    pickerView.dataSource=self.pickerView;
    pickerView.delegate=self.pickerView;
    self.pickerView.pickerView=pickerView;
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
    [cancleBtn addTarget:self action:@selector(removePickerView:) forControlEvents:UIControlEventTouchUpInside];
    [contengView addSubview:cancleBtn];
    
    UIButton* sureBtn=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2, 242, SCREEN_WIDTH/2, 38)];
    sureBtn.tag=11;
    [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
    [sureBtn setTitleColor:RGBACOLOR(129, 192, 36, 1) forState:UIControlStateNormal];
    [sureBtn.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [sureBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [sureBtn addTarget:self action:@selector(removePickerView:) forControlEvents:UIControlEventTouchUpInside];
    [contengView addSubview:sureBtn];

}


-(void)removePickerView:(UIButton*)sender
{
    [self.pickerView setAlpha:0.0f];
    if (sender.tag==11) {
        if (self.flag==CITY_TAG) {
            self.cityID=[[self.cityArray objectAtIndex:self.pickerView.selecttedIndex] objectForKey:@"CityId"];
            self.cityTextField.text=[[self.cityArray objectAtIndex:self.pickerView.selecttedIndex] objectForKey:@"CityName"];
        }else if (self.flag==AREA_TAG){
            self.areaID=[[self.districtArray objectAtIndex:self.pickerView.selecttedIndex] objectForKey:@"AreaId"];
            self.districtTextField.text=[[self.districtArray objectAtIndex:self.pickerView.selecttedIndex] objectForKey:@"AreaName"];
        }else if (self.flag==AREAESTATE_TAG){
            self.estateID=[[self.communityArray objectAtIndex:self.pickerView.selecttedIndex] objectForKey:@"EstateId"];
            self.communityTextField.text=[[self.communityArray objectAtIndex:self.pickerView.selecttedIndex] objectForKey:@"EstateName"];
        }
    }
}
- (void)dealloc
{
    [_cityTextField release];
    [_districtTextField release];
    [_communityTextField release];
    [_nameTextField release];
    [_mobileNumberTextField release];
    [_detailAddressTextField release];
    [super dealloc];
}

- (void)back:(id)sender
{
    
//    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1]
//                                          animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveAddress:(id)sender
{
    if ([self.nameTextField.text length]==0||[self.mobileNumberTextField.text length]==0||[self.cityTextField.text length]==0||[self.districtTextField.text length]==0||[self.communityTextField.text length]==0||[self.detailAddressTextField.text length]==0) {
        ShowAlert(self, NSLocalizedString(NSNoteTitle, nil), @"所有填写项不能为空", NSLocalizedString(NSSureTitle, nil));

    } else {
        [self.netBase RequestWithRequestType:NET_GET param:[self getParamWithAction:@"NewDeliveryAddress" UserID:[AppManager instance].userId Parameters:@{@"MobileNumber":self.mobileNumberTextField.text,@"Receiver":self.nameTextField.text,@"CityID":self.cityID,@"AreaID":self.areaID,@"EstateId":self.estateID,@"DetailedAddress":self.detailAddressTextField.text}]];
    }
//    [self.netBase RequestOperationWithRequestType:NET_GET param:[self getParamWithAction:@"NewDeliveryAddress" UserID:[AppManager instance].userId Parameters:@{@"MobileNumber":@"13585645523",@"Receiver":@"allen",@"CityID":self.cityID,@"AreaID":self.areaID,@"DetailedAddress":@"延平路121号"}]];
//    ShowAlert(self, NSLocalizedString(NSNoteTitle, nil), @"非常抱歉,该地址附近没有菜场配送.", NSLocalizedString(NSSureTitle, nil));
}

- (IBAction)selectAddress:(UIButton *)sender {
    [self.view endEditing:YES];
    switch (sender.tag) {
        case 10:
        {
            self.flag=CITY_TAG;
            self.pickerTitleLab.text=@"城市";
            if ([self.cityArray count]>0) {
                [self setCityOptions];
            }else{
                [MBProgressHUD showMessag:@"获取城市" toView:self.view];
                self.netBase.requestType=(RequestType*)BUY_CITY;
                [self.netBase RequestWithRequestType:NET_GET param:[self getParamWithAction:@"GetCityList" UserID:[AppManager instance].userId Parameters:@{}]];
            }
            [self.pickerView setAlpha:1.0f];
        }
            break;
        case 11:
        {
            self.flag=AREA_TAG;
            self.pickerTitleLab.text=@"区";
            if ([self.districtArray count]>0) {
                [self setAreaOptions];
            }else{
                [MBProgressHUD showMessag:@"获取区" toView:self.view];
                self.netBase.requestType=(RequestType*)BUY_DISTRICT;
                [self.netBase RequestWithRequestType:NET_GET param:[self getParamWithAction:@"GetCityAreaList" UserID:[AppManager instance].userId Parameters:@{@"CityId":@"85A0A6FD-D1DD-44E1-8913-907D8CE07BA6"}]];
            }
            [self.pickerView setAlpha:1.0f];
        }
            break;
        case 12:
        {
            self.flag=AREAESTATE_TAG;
            self.pickerTitleLab.text=@"小区";
            if ([self.communityArray count]>0) {
                [self setAreaEstateOptions];
            }else{
                [MBProgressHUD showMessag:@"获取小区" toView:self.view];
                self.netBase.requestType=(RequestType*)BUY_COMMITCART;
                [self.netBase RequestWithRequestType:NET_GET param:[self getParamWithAction:@"GetAreaEstateList" UserID:[AppManager instance].userId Parameters:@{@"AreaId":@"DCF9AC66-3FA8-4BFF-B45A-ACF49D9F68FD"}]];
            }
            [self.pickerView setAlpha:1.0f];
        }
            break;
        default:
            break;
    }
}

-(void)handleRequestSuccessData:(id)object
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSDictionary* dic=[self JSONValue:object];
    if (self.netBase.requestType==(RequestType*)BUY_CITY) {
        if ([[dic objectForKey:@"IsSuccess"] integerValue]==1){
            self.cityArray=[[dic objectForKey:@"Data"] objectForKey:@"CityList"];
            [self setCityOptions];
        }
        self.netBase.requestType=nil;
        
    }else if (self.netBase.requestType==(RequestType*)BUY_DISTRICT){
        if ([[dic objectForKey:@"IsSuccess"] integerValue]==1){
            self.districtArray=[[dic objectForKey:@"Data"] objectForKey:@"AreaList"];
            [self setAreaOptions];
        }
        self.netBase.requestType=nil;
    }else if (self.netBase.requestType==(RequestType*)BUY_COMMITCART){
        if ([[dic objectForKey:@"IsSuccess"] integerValue]==1){
            self.communityArray=[[dic objectForKey:@"Data"] objectForKey:@"EstateList"];
            [self setAreaEstateOptions];
        }
        self.netBase.requestType=nil;
    }else{
        if ([[dic objectForKey:@"IsSuccess"] integerValue]==1){
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            ShowAlert(self, NSLocalizedString(NSNoteTitle, nil), @"非常抱歉,该地址附近没有菜场配送.", NSLocalizedString(NSSureTitle, nil));
        }

    }
}

-(void)handleRequestFailedData:(NSError *)error
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

-(void)setCityOptions
{
    if ([self.cityArray count]>0) {
        [self.options removeAllObjects];
        for (NSDictionary* d in self.cityArray) {
            [self.options addObject:[d objectForKey:@"CityName"]];
        }
        [self.pickerView setOptions:self.options];
    }
}

-(void)setAreaOptions
{
    if ([self.districtArray count]>0) {
        [self.options removeAllObjects];
        for (NSDictionary* d in self.districtArray) {
            [self.options addObject:[d objectForKey:@"AreaName"]];
        }
        [self.pickerView setOptions:self.options];
    }
}

-(void)setAreaEstateOptions
{
    if ([self.communityArray count]>0) {
        [self.options removeAllObjects];
        for (NSDictionary* d in self.communityArray) {
            [self.options addObject:[d objectForKey:@"EstateName"]];
        }
        [self.pickerView setOptions:self.options];
    }

}
@end
