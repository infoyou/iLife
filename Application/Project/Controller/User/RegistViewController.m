//
//  RegistViewController.m
//  iLife
//
//  Created by Adam on 14-9-11.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import "RegistViewController.h"

@interface RegistViewController () <UITextFieldDelegate>
{
    NSInteger timeInterval;
}

@property (nonatomic, retain) NSTimer  *meetingTimer;

@end

@implementation RegistViewController

@synthesize mMobileTxt = _mMobileTxt;
@synthesize mMobileCodeTxt = _mMobileCodeTxt;
@synthesize mPswdTxt = _mPswdTxt;

@synthesize mGetCodeingNum = _mGetCodeingNum;
@synthesize mRequestBtn = _mRequestBtn;
@synthesize mGetCodeingBtn = _mGetCodeingBtn;
@synthesize mSubmitBtn = _mSubmitBtn;
@synthesize meetingTimer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil].view;
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"注册";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[ThemeManager shareInstance] getThemeImage:@"button_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(doClose:)];

    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    [self addRightBarButtonWithTitle:@""
                              target:self
                              action:nil];

    _mGetCodeingBtn.hidden = YES;
    _mGetCodeingNum.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnClick:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    int tag = btn.tag;
    
    switch (tag) {
        case 10:
        {
            
            if (_mMobileTxt.text.length != 11) {
                [[[[UIAlertView alloc] initWithTitle:LocaleStringForKey(NSCommonWarning, nil) message:@"请输入手机号码!" delegate:nil cancelButtonTitle:LocaleStringForKey(NSSureTitle, nil) otherButtonTitles:nil] autorelease] show];
                return;
            }

            _mRequestBtn.hidden = YES;
            _mGetCodeingBtn.hidden = NO;
            _mGetCodeingNum.hidden = NO;
            
            self.meetingTimer = [NSTimer scheduledTimerWithTimeInterval:1. target:self selector:@selector(timeIntervalGrow) userInfo:nil repeats:YES];
            
            [self getMobileCode];
        }
            break;
            
        case 12:
        {
            [self resetPswdByMobileCode];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - action
- (void)doClose:(id)sender {
    
    [WXWUIUtils closeActivityView];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)getMobileCode
{
    
    NSMutableDictionary *specialDict = [NSMutableDictionary dictionary];
    
    [specialDict setValue:_mMobileTxt.text forKey:@"Mobile"];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@%@", VALUE_API_PREFIX, API_SERVICE_USER, API_USER_PHONE_CODE];
    NSString *url = [ProjectAPI getURL:urlStr specialDict:specialDict];
    DLog(@"url = %@", url);
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:USER_REGIST_MOBILE_CODE_TY];
    
    [connFacade fetchGets:url];
}

- (BOOL)checkInputTxt
{
    // Mobile
    if (!_mMobileTxt.text.length) {
        [[[[UIAlertView alloc] initWithTitle:LocaleStringForKey(NSCommonWarning, nil) message:@"请输入手机号码!" delegate:nil cancelButtonTitle:LocaleStringForKey(NSSureTitle, nil) otherButtonTitles: nil] autorelease] show];
        return NO;
    }
    
    if (_mMobileTxt.text.length != 11) {
        [[[[UIAlertView alloc] initWithTitle:LocaleStringForKey(NSCommonWarning, nil) message:@"请输入正确的手机号码!" delegate:nil cancelButtonTitle:LocaleStringForKey(NSSureTitle, nil) otherButtonTitles: nil] autorelease] show];
        return NO;
    }
    
    // Mobile Code
    if (!_mMobileCodeTxt.text.length) {
        [[[[UIAlertView alloc] initWithTitle:LocaleStringForKey(NSCommonWarning, nil) message:@"请输入验证码!" delegate:nil cancelButtonTitle:LocaleStringForKey(NSSureTitle, nil) otherButtonTitles: nil] autorelease] show];
        return NO;
    }
    
    if (_mMobileCodeTxt.text.length != 4) {
        [[[[UIAlertView alloc] initWithTitle:LocaleStringForKey(NSCommonWarning, nil) message:@"请输入正确的验证码!" delegate:nil cancelButtonTitle:LocaleStringForKey(NSSureTitle, nil) otherButtonTitles: nil] autorelease] show];
        return NO;
    }
    
    // Pswd
    if (!_mPswdTxt.text.length) {
        [[[[UIAlertView alloc] initWithTitle:LocaleStringForKey(NSCommonWarning, nil) message:@"请输入密码!" delegate:nil cancelButtonTitle:LocaleStringForKey(NSSureTitle, nil) otherButtonTitles: nil] autorelease] show];
        return NO;
    }
    
    if (_mPswdTxt.text.length < 4 || _mPswdTxt.text.length > 16) {
        [[[[UIAlertView alloc] initWithTitle:LocaleStringForKey(NSCommonWarning, nil) message:@"请输入正确的密码(4-16位)!" delegate:nil cancelButtonTitle:LocaleStringForKey(NSSureTitle, nil) otherButtonTitles: nil] autorelease] show];
        return NO;
    }
    
    return YES;
}

- (void)resetPswdByMobileCode
{
    
    if (![self checkInputTxt]) {
        return;
    }
    
    NSMutableDictionary *specialDict = [NSMutableDictionary dictionary];
    
    [specialDict setValue:_mMobileTxt.text forKey:@"Mobile"];
    [specialDict setValue:_mMobileCodeTxt.text forKey:@"AuthCode"];
    [specialDict setValue:_mPswdTxt.text/*[_mPswdTxt.text MD5String]*/ forKey:@"NewPassword"];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@%@", VALUE_API_PREFIX, API_SERVICE_USER, API_USER_REGISTER];
    NSString *url = [ProjectAPI getURL:urlStr specialDict:specialDict];
    DLog(@"url = %@", url);
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:USER_REGIST_MOBILE_REPSWD_TY];
    
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
            
        case USER_REGIST_MOBILE_REPSWD_TY:
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
                
                //执行程序
                [self dismissModalViewControllerAnimated:YES];
            }
            
            break;
        }
            
        case USER_REGIST_MOBILE_CODE_TY: {
            ConnectionAndParserResultCode ret = [JSONParser parserResponseJsonData:result
                                                                              type:contentType
                                                                               MOC:_MOC
                                                                 connectorDelegate:self
                                                                               url:url
                                                                           paramID:0];
            
            if (ret == SUCCESS_CODE) {
                
                NSDictionary *resultDict = [result objectFromJSONData];
                NSDictionary *dict = OBJ_FROM_DIC(resultDict, @"Data");
                
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

#pragma mark - update mobile
- (void)updateMobile:(NSString *)mobile
{
    _mMobileTxt.text = mobile;
    _mMobileTxt.enabled = NO;
}

- (void)timeIntervalGrow
{
    timeInterval ++;
    
    if (timeInterval >= 60)
    {
        timeInterval = 0;
        _mGetCodeingNum.text = @"60";
        [self.meetingTimer invalidate];
        self.meetingTimer  = nil;
        
        _mGetCodeingBtn.hidden = YES;
        _mGetCodeingNum.hidden = YES;
        _mRequestBtn.hidden = NO;
    } else {
        _mGetCodeingBtn.hidden = NO;
        _mGetCodeingNum.hidden = NO;
        _mRequestBtn.hidden = YES;
        _mGetCodeingNum.text = [NSString stringWithFormat:@"%d", 60 - timeInterval];
    }
}

#pragma mark - text change
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField isEqual:_mMobileTxt]) {

        if (range.location > 10)
            return NO; // return NO to not change text
        return YES;
    }
    
    if ([textField isEqual:_mPswdTxt]) {
        
        if (range.location > 15)
            return NO; // return NO to not change text
        return YES;
    }
    
    if ([textField isEqual:_mMobileCodeTxt]) {
        
        if (range.location > 3)
            return NO; // return NO to not change text
        return YES;
    }
    
    return YES;
}

@end
