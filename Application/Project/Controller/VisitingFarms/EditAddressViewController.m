//
//  EditAddressViewController.m
//  iLife
//
//  Created by hys on 14-9-25.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import "EditAddressViewController.h"
#import "JILBase.h"

@interface EditAddressViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UITextViewDelegate,JILNetBaseDelegate>

@property (retain, nonatomic) IBOutletCollection(UITableViewCell) NSArray *cellArray;
@property (retain, nonatomic) UITableView* addressTableView;
@property (retain, nonatomic) JILNetBase* netBase;


@end

@implementation EditAddressViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.netBase=[[JILNetBase alloc]init];
        self.netBase.netBaseDelegate=self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    [self.tableView setHidden:YES];
    self.view.backgroundColor = [UIColor whiteColor];
    if ([WXWCommonUtils currentOSVersion] < IOS7) {
        self.view.frame = CGRectOffset(self.view.frame, 0, -20);
    }

    UIBarButtonItem* sendItem = [[[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(addAddress)] autorelease];
    [sendItem setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = sendItem;


    [self.tableView setFrame:CGRectMake(0, 0, 320, 290)];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    self.tableView.scrollEnabled=NO;
    UIView* bgView=[[UIView alloc]initWithFrame:CGRectMake(0, 290, 320, 400)];
    [bgView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:bgView];
}
#pragma mark-SaveAddress
-(void)addAddress
{
    [self.netBase RequestWithRequestType:NET_GET param:[self getParamWithAction:@"NewDeliveryAddress" UserID:@"004852E9-7AA1-4C3F-97A3-361B8EA96464" Parameters:@{@"MobileNumber":@"13585645523",@"Receiver":@"allen",@"CityID":@"201",@"AreaID":@"439",@"DetailedAddress":@"延平路121号"}]];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)handleRequestSuccessData:(id)object
{
    NSDictionary* dic=[self JSONValue:object];
    if ([[dic objectForKey:@"IsSuccess"] integerValue]==1) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self confirmWithMessage:@"添加地址失败" title:nil];
    }
}

-(void)handleRequestFailedData:(NSError *)error
{
    [self confirmWithMessage:@"添加地址失败" title:nil];
}
#pragma mark-SetUp tableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row<4) {
        return 50.0f;
    }else if (indexPath.row==4){
        return 90.0f;
    }else{
        return 0.0f;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row<5) {
        return _cellArray[indexPath.row];
    }else{
        return nil;
    }
    
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==2) {
        //
    }else if (indexPath.row==3){
        
    }
}

#pragma mark-Setup TextDelegate
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text; {
    
    if ([@"\n" isEqualToString:text] == YES) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_cellArray release];
    [super dealloc];
}
@end
