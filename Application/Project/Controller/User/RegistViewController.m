//
//  RegistViewController.m
//  iLife
//
//  Created by Adam on 14-9-11.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import "RegistViewController.h"
#import "LoginViewController.h"
#import "FMDBConnection.h"

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
    
//    _mMobileTxt.text = @"13524010590";
//    _mPswdTxt.text = @"123321";
//    _mMobileCodeTxt.text = @"1234";
    
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

- (void)doQiXinLoginAction
{
    
    NSMutableDictionary *specialDict = [NSMutableDictionary dictionary];
    
    [specialDict setValue:_mMobileTxt.text forKey:@"Mobile"];
    [specialDict setValue:_mPswdTxt.text forKey:@"Password"];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@%@", VALUE_API_PREFIX, API_SERVICE_USER, API_USER_LOGIN];
    NSString *url = [ProjectAPI getURL:urlStr specialDict:specialDict];
    DLog(@"url = %@", url);
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:USER_LOGIN_TY];
    [connFacade fetchGets:url];
}

- (void)bindPushServer
{
    
    NSMutableDictionary *specialDict = [NSMutableDictionary dictionary];
    
    [specialDict setValue:[AppManager instance].deviceToken forKey:@"DeviceToken"];
    [specialDict setValue:@"2" forKey:@"Role"];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@%@", VALUE_API_PREFIX, API_SERVICE_USER, API_BIND_PUSH];
    
    NSString *url = [ProjectAPI getURL:urlStr specialDict:specialDict];
    DLog(@"url = %@", url);
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:USER_BIND_TY];
    
    [connFacade fetchGets:url];
}

- (void)getUserInfo
{
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@%@", VALUE_API_PREFIX, API_SERVICE_USER, API_MEMBER_INFO];
    
    NSString *url = [ProjectAPI getURL:urlStr specialDict:nil];
    DLog(@"url = %@", url);
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:USER_INFO_TY];
    
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
            
        case USER_INFO_TY:
        {
            NSDictionary *resultDict = [result objectFromJSONData];
            NSDictionary *dict = OBJ_FROM_DIC(resultDict, @"Data");
            
            NSString *strMobile = STRING_VALUE_FROM_DIC(dict, @"Mobile");
            NSString *strAmount = STRING_VALUE_FROM_DIC(dict, @"Amount");
            
            UserObject *userInfo = [[FMDBConnection instance] getUserByUserId:[AppManager instance].userId];
            
            userInfo.userTel = strMobile;
            userInfo.band = strAmount;
            
            [[FMDBConnection instance] updateUserObjectDB:userInfo];
            
            [self bindPushServer];
        }
            break;
            
        case USER_REGIST_MOBILE_REPSWD_TY:
        {
            ConnectionAndParserResultCode ret = [JSONParser parserResponseJsonData:result
                                                                              type:contentType
                                                                               MOC:_MOC
                                                                 connectorDelegate:self
                                                                               url:url
                                                                           paramID:0];
            
            NSDictionary *resultDict = [result objectFromJSONData];
            
            if (ret == SUCCESS_CODE) {
                
                NSDictionary *dict = OBJ_FROM_DIC(resultDict, @"Data");
                
                [[AppManager instance].userDefaults rememberUsername:_mMobileTxt.text andPassword:_mPswdTxt.text pswdStr:_mPswdTxt.text emailName:_mMobileTxt.text userId:@""];
                
                [self doQiXinLoginAction];
                
            } else {
                NSString *msg = [resultDict objectForKey:@"Message"];
                
                [[[[UIAlertView alloc] initWithTitle:LocaleStringForKey(NSNoteTitle, nil) message:msg delegate:nil cancelButtonTitle:LocaleStringForKey(NSSureTitle, nil) otherButtonTitles: nil] autorelease]show];
                
                [super connectDone:result
                               url:url
                       contentType:contentType];
                
                return;
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
                
            }
            
            break;
        }
            
        case USER_LOGIN_TY:
        {
            [self.view endEditing:YES];
            
            ConnectionAndParserResultCode ret = [JSONParser parserResponseJsonData:result
                                                                              type:contentType
                                                                               MOC:_MOC
                                                                 connectorDelegate:self
                                                                               url:url
                                                                           paramID:0];
            
            if (ret == SUCCESS_CODE) {
                
                NSDictionary *resultDict = [result objectFromJSONData];
                NSDictionary *dataDict = OBJ_FROM_DIC(resultDict, @"Data");
                NSDictionary *dict = OBJ_FROM_DIC(dataDict, @"Member");
                
                if (dict && [dict count] > 0) {
                    NSString *updateURL = [dict objectForKey:@"updateURL"];
                    if (!updateURL || [updateURL isEqual:[NSNull null]] || [updateURL isEqual:@"<null>"]) {
                        
                    } else {
                        [AppManager instance].updateURL = updateURL;
                        DLog(@"%@", [AppManager instance].updateURL);
                    }
                    
                    NSString *isMandatory = [dict objectForKey:@"IsMandatory"];
                    if (!isMandatory || [isMandatory isEqual:[NSNull null]] || [isMandatory isEqual:@"<null>"]) {
                        
                    } else {
                        [AppManager instance].isMandatory = [isMandatory integerValue];
                        DLog(@"%d", [AppManager instance].isMandatory);
                        
                        //                        if ([AppManager instance].isMandatory == 1) {
                        //
                        //                            UIAlertView *updateAlertView = [[UIAlertView alloc] initWithTitle:LocaleStringForKey(NSNoteTitle, nil)
                        //                                                                                      message:@"有版本更新，您必须更新后才可使用。"
                        //                                                                                     delegate:self
                        //                                                                            cancelButtonTitle:LocaleStringForKey(NSCancelTitle, nil)
                        //                                                                            otherButtonTitles:LocaleStringForKey(NSSureTitle, nil), nil];
                        //                            updateAlertView.tag = ALERT_TAG_CHOISE_UPDATE;
                        //
                        //                            [updateAlertView show];
                        //                        }
                    }
                    
                    // [[AppManager instance] updateLoginSuccess:dict];
                    
                    // AppManage
                    [AppManager instance].userId = [dict objectForKey:@"VipID"];
                    [AppManager instance].userName = [dict objectForKey:@"VipName"];
                    [AppManager instance].userEmail = [dict objectForKey:@"Mobile"];
                    [AppManager instance].userImageUrl = STRING_VALUE_FROM_DIC(dict, @"ImageUrl");
                    
                    // Save
                    UserObject *userObject = [[[UserObject alloc] init] autorelease];
                    userObject.userId = STRING_VALUE_FROM_DIC(dict, @"VipID");
                    userObject.userName = STRING_VALUE_FROM_DIC(dict, @"VipName");
                    userObject.userEmail = STRING_VALUE_FROM_DIC(dict, @"Mobile");
                    userObject.userTel = STRING_VALUE_FROM_DIC(dict, @"Mobile");
                    userObject.userImageUrl = STRING_VALUE_FROM_DIC(dict, @"ImageUrl");
                    
                    userObject.userGender = 1;//INT_VALUE_FROM_DIC(userDic, @"UserGender");
                    userObject.chatId = @"";//STRING_VALUE_FROM_DIC(userDic, @"VoipAccount");
                    userObject.userTitle = @"";//STRING_VALUE_FROM_DIC(userDic, @"JobFunc");
                    userObject.userRole = @"";//STRING_VALUE_FROM_DIC(userDic, @"RoleName");
                    userObject.userDept = @"";//STRING_VALUE_FROM_DIC(userDic, @"Dept");
                    userObject.userCode = @"";//STRING_VALUE_FROM_DIC(userDic, @"user_code");
                    userObject.userNameEn = @"";//STRING_VALUE_FROM_DIC(userDic, @"user_name_en");
                    userObject.isFriend = 0;
                    userObject.isDelete = 0;//INT_VALUE_FROM_DIC(userDic, @"user_status")-1;
                    userObject.superName = @"";//STRING_VALUE_FROM_DIC(userDic, @"SuperiorName");
                    
                    userObject.userBirthDay = @"";//STRING_VALUE_FROM_DIC(userDic, @"UserBirthday");
                    userObject.userCellphone = @"";//STRING_VALUE_FROM_DIC(userDic, @"UserCellphone");
                    
                    // P&G
                    userObject.channel = @"";//STRING_VALUE_FROM_DIC(userDic, @"Channel");
                    userObject.function = @"";//STRING_VALUE_FROM_DIC(userDic, @"Dept");
                    userObject.superEmail = @"";//STRING_VALUE_FROM_DIC(userDic, @"SuperiorName");
                    userObject.location = @"";//STRING_VALUE_FROM_DIC(userDic, @"Location");
                    userObject.serviceYear = @"";//STRING_VALUE_FROM_DIC(userDic, @"ServiceYear");
                    userObject.band = @"";//STRING_VALUE_FROM_DIC(userDic, @"JobFunc");
                    userObject.subordinateCount = @"";//STRING_VALUE_FROM_DIC(userDic, @"SubordinateCount");
                    
                    NSArray *userList = [[[NSArray alloc] initWithObjects:userObject, nil] autorelease];
                    [[FMDBConnection instance] insertAllUserObjectDB:userList];
                    
                    //                    if (self.delegate && [self.delegate respondsToSelector:@selector(loginSuccessfull:)]) {
                    [AppManager instance].passwd = _mPswdTxt.text;  //保存一下密码
                    [AppManager instance].userId = [[[resultDict objectForKey:@"Data"] objectForKey:@"Member"] objectForKey:@"VipID"];
                    //                        [self.delegate loginSuccessfull:self];
                    
                    [[AppManager instance].userDefaults rememberUsername:_mMobileTxt.text andPassword:_mPswdTxt.text pswdStr:_mPswdTxt.text emailName:_mMobileTxt.text userId:[AppManager instance].userId];
                    
                    [AppManager instance].updateCache = YES;
                    
                    [self getUserInfo];
                    //                    }
                    
                } else {
                    NSString *msg = [resultDict objectForKey:@"Message"];
                    
                    [[[[UIAlertView alloc] initWithTitle:LocaleStringForKey(NSNoteTitle, nil) message:msg delegate:nil cancelButtonTitle:LocaleStringForKey(NSSureTitle, nil) otherButtonTitles: nil] autorelease]show];
                    return;
                }
            } else {
                
                NSDictionary *resultDict = [result objectFromJSONData];
                NSString *msg = [resultDict objectForKey:@"Message"];
                
                [[[[UIAlertView alloc]initWithTitle:LocaleStringForKey(NSNoteTitle, nil) message:msg delegate:nil cancelButtonTitle:LocaleStringForKey(NSSureTitle, nil) otherButtonTitles: nil] autorelease]show];
            }
            
            break;
        }
            
        case USER_BIND_TY:
        {
            [WXWUIUtils closeActivityView];
            [self dismissModalViewControllerAnimated:YES];
            
            ProjectAppDelegate *delegate = (ProjectAppDelegate *)APP_DELEGATE;
            [delegate goHomePage];
            
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

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    CGRect textFieldRect = [self.view.window convertRect:textField.bounds fromView:textField];
    
    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
    
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    
    CGFloat numerator = midline - viewRect.origin.y - 0.2 * viewRect.size.height;
    
    CGFloat denominator = 0.7 * viewRect.size.height;
    
    CGFloat heightFraction = numerator / denominator;
    
    if (heightFraction < 0.0) {
        heightFraction = 0.0;
    } else if (heightFraction > 1.0) {
        heightFraction = 1.0;
    }
    
    _animatedDistance = floor(216 * heightFraction) + 50 - 20;
    int maxY = CGRectGetMaxY(self.view.frame);
    
    NSLog(@"%f", maxY - _animatedDistance);
    
    [self upAnimate];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self downAnimate];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
