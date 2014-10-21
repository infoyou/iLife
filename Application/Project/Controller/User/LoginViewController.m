
#import "LoginViewController.h"
#import "CommonHeader.h"
#import "WXWCustomeAlertView.h"
#import "UnderlinedButton.h"
#import "UIWebViewController.h"
#import "SelectView.h"
#import "UIDevice+Hardware.h"
#import "RegistViewController.h"
#import "FindPasswordViewController.h"

typedef enum {
    EMAIL_INFO_TYPE = 30,
    PASSWORD_INFO_TYPE,
    COMPANY_INFO_TYPE,
    
    COMPANY_TYPE,
    AUTOLOGIN_TYPE,
    LOGIN_TYPE,
} Login_Element_Type;

typedef enum {
    ALERT_TAG_MUST_UPDATE = 1,
    ALERT_TAG_CHOISE_UPDATE = 2,
}  UPDATE_ALERT_TAG;

@interface LoginViewController () <WXWConnectorDelegate, UITextFieldDelegate, UIAlertViewDelegate, SelectViewDelegate>
{
    UITextField *_companyField;
    UITextField *_nameField;
    UITextField *_passwordField;
    
    BOOL _isAutoLogin;
}

@property (nonatomic, retain) UITextField *_companyField;
@property (nonatomic, retain) UITextField *_nameField;
@property (nonatomic, retain) UITextField *_passwordField;

@property (nonatomic, retain) SelectView *_selectView;
@end

@implementation LoginViewController
@synthesize _companyField;
@synthesize _nameField;
@synthesize _passwordField;
@synthesize _selectView;

- (id)initWithMOC:(NSManagedObjectContext *)MOC
         parentVC:(RootViewController *)pVC {
    
    self = [super initWithMOC:MOC];{
        
        [CommonMethod getInstance].MOC = _MOC;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self checkIsAutoLogin];
    
    [self doLoginLogic];
//    [self doUpdateSoftAction];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.navigationController.navigationBarHidden = YES;

    self.navigationItem.leftBarButtonItem = BAR_IMG_BUTTON([UIImage imageNamed:@"home_btn1.png"], UIBarButtonItemStyleBordered, self, @selector(menuBtnTapped:));
    
    self.title = LocaleStringForKey(NSLoginTitle, nil);
    
    [self setLoginVCField];
    
//    [self.view addSubview:[self setCompanyBtnType]];
    [self setLoginVCBtn];
    
//    [self initLisentingKeyboard];
}

- (void)setData
{
    
    self._nameField.text = [[AppManager instance].userDefaults usernameRemembered];
//    self._companyField.text = @"上海杰亦特信息技术有限公司";
}

- (void)checkIsAutoLogin
{
    NSString *emailStr = [[AppManager instance].userDefaults usernameRemembered];
    NSString *pwdStr = [[AppManager instance].userDefaults passwordRemembered];
    
    UIButton *autoBtn = (UIButton *)[self.view viewWithTag:AUTOLOGIN_TYPE];
    
    if ([emailStr length] > 0 && [pwdStr length] > 0)
    {
        _isAutoLogin = YES;
        _nameField.text = emailStr;
        _passwordField.text = pwdStr;
        _companyField.text = [[AppManager instance].userDefaults customerNameRemembered];
        [autoBtn setImage:IMAGE_WITH_IMAGE_NAME(@"login_auto_sel") forState:UIControlStateNormal];
    } else {
        _isAutoLogin = NO;
        [autoBtn setImage:IMAGE_WITH_IMAGE_NAME(@"login_auto_unsel") forState:UIControlStateNormal];
    }
    
    [self setData];
}

#pragma mark - Set Login Control

- (void)setLoginVCField
{
    float hGap = 162.5f;
    float wGap = 38.0f;
    float sGap = 11.0f;
    float txtHeight = 38.0f;
    
    NSMutableArray *placeArr = [[[NSMutableArray alloc] initWithObjects:LocaleStringForKey(NSNamePlaceholder,nil), LocaleStringForKey(NSPswdPlaceholder,nil), @"公司", nil] autorelease];
    
    for (int i = 0; i < 2; i++)
    {
        UITextField *textField = [[[UITextField alloc] init] autorelease];
        [textField setBackgroundColor:TRANSPARENT_COLOR];
        [textField setTag:i + 30];
        [textField setPlaceholder:[placeArr objectAtIndex:i]];
        [textField setFont:FONT_SYSTEM_SIZE(15)];

        textField.frame = CGRectMake(55, 37 + (67*i), 245.f, 35);
        [textField setBorderStyle:UITextBorderStyleNone];
        if (i == 0) {
            [textField setKeyboardType:UIKeyboardTypePhonePad];
        } else {
            [textField setKeyboardType:UIKeyboardTypeEmailAddress];
        }
        [textField setReturnKeyType:UIReturnKeyDefault];
        
        [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
        
        textField.contentVerticalAlignment
        = UIControlContentVerticalAlignmentCenter;
        
        if (i == 1) {
            [textField setSecureTextEntry:YES];
        }
        
        // bg view
        UIImageView *bgView = [[[UIImageView alloc] init] autorelease];
        [bgView setImage:IMAGE_WITH_IMAGE_NAME(@"login_field_bg")];
        bgView.frame = CGRectMake(16, 35 + (67*i), 287, 40);
        
        if (i == 0) {
            
            UIImageView *textIconView = [[[UIImageView alloc] initWithFrame:CGRectMake(13.f, 9, 15.5, 19.5)] autorelease];
            [textIconView setImage:IMAGE_WITH_IMAGE_NAME(@"login_user")];
            [bgView addSubview:textIconView];
        } else if (i == 1) {
            
            UIImageView *textIconView = [[[UIImageView alloc] initWithFrame:CGRectMake(13.f, 9, 15.5, 19.5)] autorelease];
            [textIconView setImage:IMAGE_WITH_IMAGE_NAME(@"login_pswd")];
            [bgView addSubview:textIconView];
        }
        
        [self.view addSubview:textField];
        [self.view insertSubview:bgView belowSubview:textField];
    }
    
    self._nameField =     (UITextField *)[self.view viewWithTag:EMAIL_INFO_TYPE];
    self._passwordField = (UITextField *)[self.view viewWithTag:PASSWORD_INFO_TYPE];
    self._companyField =  (UITextField *)[self.view viewWithTag:COMPANY_INFO_TYPE];
    
    [_companyField setFrame:CGRectMake(wGap + sGap, hGap, SCREEN_WIDTH - wGap*3 + 2, txtHeight)];
    
    self._nameField.text = [[AppManager instance].userDefaults usernameRemembered];
}


- (UIButton *)setCompanyBtnType
{
    float hGap = 162.5f;
    float wGap = 36.0f;
    
    UIImage *img = IMAGE_WITH_IMAGE_NAME(@"dropIcon");
    UIButton *companyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [companyBtn setBackgroundColor:[UIColor clearColor]];
    [companyBtn setTag:COMPANY_TYPE];
    [companyBtn setImage:img forState:UIControlStateNormal];
    [companyBtn setBounds:CGRectMake(0, 0, wGap, wGap)];
    [companyBtn setCenter:CGPointMake(SCREEN_WIDTH - (wGap + wGap/2),hGap + wGap/2)];
    [companyBtn addTarget:self action:@selector(companyClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return companyBtn;
}

- (void)setLoginVCBtn
{
    
    UIView *autoView = [[[UIView alloc] initWithFrame:CGRectMake(60, 267.f, 238, 22)] autorelease];
    
    // auto btn
//    UIButton *autoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [autoBtn setBackgroundColor:[UIColor clearColor]];
//    [autoBtn setTag:AUTOLOGIN_TYPE];
//    [autoBtn setImage:IMAGE_WITH_IMAGE_NAME(@"login_auto_unsel") forState:UIControlStateNormal];
//    [autoBtn setFrame:CGRectMake(0, 0, 22, 22)];
//    [autoBtn addTarget:self action:@selector(autoLoginClick:) forControlEvents:UIControlEventTouchUpInside];
//    [autoView addSubview:autoBtn];
    
    // auto label
    WXWLabel *autoLabel = [[WXWLabel alloc] initWithFrame:CGRectMake(0, 0, 238, 22) textColor:HEX_COLOR(@"0x82bf24") shadowColor:TRANSPARENT_COLOR];
    autoLabel.text = LocaleStringForKey(@"忘记密码!", nil);
    autoLabel.font = FONT_SYSTEM_SIZE(14);
    autoLabel.textAlignment = NSTextAlignmentRight;
    
    autoLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(findPasswordClick:)] autorelease];
    [autoLabel addGestureRecognizer:tapGesture];
    [autoView addSubview:autoLabel];
    
    [self.view addSubview:autoView];
    
    // login
    {
        UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [loginBtn setBackgroundColor:[UIColor clearColor]];
        [loginBtn setTag:LOGIN_TYPE];
        [loginBtn setBackgroundImage:IMAGE_WITH_IMAGE_NAME(@"login_btn") forState:UIControlStateNormal];
        [loginBtn setBackgroundImage:IMAGE_WITH_IMAGE_NAME(@"login_btn_sel") forState:UIControlStateHighlighted];
        [loginBtn setTitle:LocaleStringForKey(NSLoginTitle, nil) forState:UIControlStateNormal];
        [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [loginBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [loginBtn setFrame:CGRectMake(16, 167, 287, 40)];
        
        [loginBtn addTarget:self action:@selector(loginBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:loginBtn];
    }
    
    // Regist
    {
        UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [loginBtn setBackgroundColor:[UIColor clearColor]];
        [loginBtn setTag:LOGIN_TYPE];
        [loginBtn setBackgroundImage:IMAGE_WITH_IMAGE_NAME(@"login_regist") forState:UIControlStateNormal];
        [loginBtn setBackgroundImage:IMAGE_WITH_IMAGE_NAME(@"login_regist") forState:UIControlStateHighlighted];
        [loginBtn setTitle:LocaleStringForKey(NSLoginRegister, nil) forState:UIControlStateNormal];
        [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [loginBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [loginBtn setFrame:CGRectMake(16, 217, 287, 40)];
        
        [loginBtn addTarget:self action:@selector(registBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:loginBtn];
    }
}

- (void)autoLoginClick:(id)sender
{
    UIButton *autoBtn = (UIButton *)sender;
    
    if (!_isAutoLogin)
    {
        _isAutoLogin = YES;
        [autoBtn setImage:IMAGE_WITH_IMAGE_NAME(@"login_auto_sel") forState:UIControlStateNormal];
    } else {
        _isAutoLogin = NO;
        [autoBtn setImage:IMAGE_WITH_IMAGE_NAME(@"login_auto_unsel") forState:UIControlStateNormal];
    }
}

- (void)registBtnClick:(id)sender
{
    RegistViewController *vc = [[[RegistViewController alloc] initWithNibName:@"RegistViewController" bundle:nil] autorelease];
    
    UINavigationController *vcNav = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
    vcNav.navigationBar.tintColor = TITLESTYLE_COLOR;
    
    [self presentViewController:vcNav animated:YES completion:nil];
}

- (void)findPasswordClick:(id)sender
{
    FindPasswordViewController *vc = [[[FindPasswordViewController alloc] initWithNibName:@"FindPasswordViewController" bundle:nil] autorelease];
    
    UINavigationController *vcNav = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
    vcNav.navigationBar.tintColor = TITLESTYLE_COLOR;
    
    [self presentViewController:vcNav animated:YES completion:nil];
}

- (void)loginBtnClick:(id)sender
{
    if ([self checkInputTxt])
    {
       
        [self doQiXinLoginAction];
    }
//    [self.delegate loginSuccessfull:self];   //跳过登陆验证
}

- (void)doLoginLogic
{
    if (_isAutoLogin) {
        if ([self checkInputTxt])
        {
           
            [self doQiXinLoginAction];
        }
    }
//    [self.delegate loginSuccessfull:self];   //跳过登陆验证
}

- (BOOL)checkInputTxt
{
    // Mobile
    if (!_nameField.text.length) {
        [[[[UIAlertView alloc] initWithTitle:LocaleStringForKey(NSCommonWarning, nil) message:@"请输入手机号码!" delegate:nil cancelButtonTitle:LocaleStringForKey(NSSureTitle, nil) otherButtonTitles: nil] autorelease] show];
        return NO;
    }
    
    if (_nameField.text.length != 11) {
        [[[[UIAlertView alloc] initWithTitle:LocaleStringForKey(NSCommonWarning, nil) message:@"请输入正确的手机号码!" delegate:nil cancelButtonTitle:LocaleStringForKey(NSSureTitle, nil) otherButtonTitles: nil] autorelease] show];
        return NO;
    }
    
    // Pswd
    if (!_passwordField.text.length) {
        [[[[UIAlertView alloc] initWithTitle:LocaleStringForKey(NSCommonWarning, nil) message:@"请输入密码!" delegate:nil cancelButtonTitle:LocaleStringForKey(NSSureTitle, nil) otherButtonTitles: nil] autorelease] show];
        return NO;
    }
    
    if (_passwordField.text.length < 4 || _passwordField.text.length > 16) {
        [[[[UIAlertView alloc] initWithTitle:LocaleStringForKey(NSCommonWarning, nil) message:@"请输入正确的密码(4-16位)!" delegate:nil cancelButtonTitle:LocaleStringForKey(NSSureTitle, nil) otherButtonTitles: nil] autorelease] show];
        return NO;
    }

    
//    if (!_companyField.text.length) {
//        [[[[UIAlertView alloc] initWithTitle:LocaleStringForKey(NSCommonWarning, nil) message:@"请选择角色" delegate:nil cancelButtonTitle:LocaleStringForKey(NSSureTitle, nil) otherButtonTitles: nil] autorelease]show];
//        return NO;
//    }
    
    return YES;
}

- (void)autoLogin
{
    
    _nameField.text = [[AppManager instance].userDefaults usernameRemembered];
    NSString *md5Password = [[AppManager instance].userDefaults passwordRemembered];
    _passwordField.text = md5Password;
    _companyField.text = [[AppManager instance].userDefaults customerNameRemembered];
    
    if (_nameField.text.length > 0 && md5Password.length > 0) {
        
        [[AppManager instance].userDefaults rememberUsername:[[AppManager instance].userDefaults usernameRemembered] andPassword:[[AppManager instance].userDefaults passwordRemembered] pswdStr:[[AppManager instance].userDefaults passwordStrRemembered] customerName:_companyField.text userId:[[AppManager instance].userDefaults getSaveUserId]];
        _isAutoLogin = YES;
    }
    
    [self doUpdateSoftAction];
}

- (void)bringToFront
{
    self.view.hidden = NO;
    ProjectAppDelegate *delegate = (ProjectAppDelegate *)APP_DELEGATE;
    [delegate.window addSubview:self.view];
    [delegate.window bringSubviewToFront:self.view];
}

- (void)registerButtonClicked:(id)sender
{
    UIWebViewController *webVC = [[[UIWebViewController alloc] init] autorelease];
    webVC.strUrl = [NSString stringWithFormat:@"http://112.124.68.147:9004/HtmlApps/html/special/embaunion/new_adduserinfo.html?customerId=%@&openId=123", CUSTOMER_ID];
    webVC.strTitle = @"注册";
    
    UINavigationController *webViewNav = [[[UINavigationController alloc] initWithRootViewController:webVC] autorelease];
    webViewNav.navigationBar.tintColor = TITLESTYLE_COLOR;
    
    [self presentViewController:webViewNav animated:YES completion:nil];
}

#pragma mark - request

- (void)doQiXinLoginAction
{
    
    NSMutableDictionary *specialDict = [NSMutableDictionary dictionary];

    [specialDict setValue:_nameField.text forKey:@"Mobile"];
    [specialDict setValue:_passwordField.text /*[CommonMethod hashStringAsMD5:_passwordField.text]*/ forKey:@"Password"];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@%@", VALUE_API_PREFIX, API_SERVICE_USER, API_USER_LOGIN];
    NSString *url = [ProjectAPI getURL:urlStr specialDict:specialDict];
    DLog(@"url = %@", url);
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:USER_LOGIN_TY];
    
    [connFacade fetchGets:url];
}

- (void)doUpdateSoftAction
{
    
    NSMutableDictionary *specialDict = [NSMutableDictionary dictionary];
    [specialDict setValue:APP_NAME forKey:@"AppName"];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@", VALUE_API_PREFIX, API_UPDATE_SERVICE];
    NSString *url = [ProjectAPI getURL:urlStr specialDict:specialDict];
    DLog(@"url = %@", url);
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:UPDATE_VERSION_TY];
    
    [connFacade fetchGets:url];
}

- (void)forgetPasswordButtonClicked:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:FORGET_PASSWORD_LINK]];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)initLisentingKeyboard
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
#ifdef __IPHONE_5_0
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
#endif
}

#pragma mark - keyboard show or hidden
-(void)autoMovekeyBoard:(float)h withDuration:(float)duration{
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        CGRect rect = self.view.frame;
        if (h) {
            if (SCREEN_HEIGHT > 480) {
                self.view.frame = CGRectMake(0.0f, -40, self.view.frame.size.width, self.view.frame.size.height);
            } else {
                self.view.frame = CGRectMake(0.0f, -110, self.view.frame.size.width, self.view.frame.size.height);
            }
            
        } else {
            rect.origin.y = ([CommonMethod is7System] ? 0 : 0);
            self.view.frame = rect;
        }
        
    } completion:^(BOOL finished) {
        // stub
    }];
    
}

#pragma mark - Responding to keyboard events
- (void)keyboardWillShow:(NSNotification *)notification {
    
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [self autoMovekeyBoard:keyboardRect.size.height withDuration:animationDuration];
}


- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [self autoMovekeyBoard:0 withDuration:animationDuration];
}

- (void)hideKeyboard {
    
    //[self.inputToolbar.textView resignFirstResponder];
    //keyboardIsVisible = NO;
    //[self moveInputBarWithKeyboardHeight:0.0 withDuration:0.0];
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType {
    
    if (contentType == USER_LOGIN_TY) {
        [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil) blockCurrentView:YES];
    }
    
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
                [self bringToFront];
                [self.view endEditing:YES];
                
                NSDictionary *resultDict = [result objectFromJSONData];
                NSDictionary *dict = OBJ_FROM_DIC(resultDict, @"Data");
                
                if (dict && [dict count] > 0) {
                    NSString *updateURL = [dict objectForKey:@"UpdateURL"];
                    NSString *updateContent = [dict objectForKey:@"UpdateContent"];
                    
                    if (!updateURL || [updateURL isEqual:[NSNull null]] || [updateURL isEqual:@"<null>"]) {
                        
                    } else {
                        [AppManager instance].updateURL = updateURL;
                        DLog(@"%@", [AppManager instance].updateURL);
                    }
                    
                    NSString *isMandatory = [dict objectForKey:@"IsMandatoryUpdate"];
                    if (!isMandatory || [isMandatory isEqual:[NSNull null]] || [isMandatory isEqual:@"<null>"]) {
                        
                        [self doLoginLogic];
                    } else {

                        [AppManager instance].isMandatory = INT_VALUE_FROM_DIC(dict, @"IsMandatoryUpdate");
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
                            
                            [updateAlertView show];
                        } else {
                            
                            int updateAlertType = [[FMDBConnection instance] getUpdateSoftDB:[CommonUtils currentDateStr]];
                            
                            if ( updateAlertType == -1) {
                                
                                [[FMDBConnection instance] delUpdateSoftDB];
                                
                                NSArray *insertArray = [[NSArray alloc] initWithObjects:[CommonUtils currentDateStr], @"0", nil];
                                [[FMDBConnection instance] insertSoftDB:insertArray];

                            } else {
                                [self doLoginLogic];
                                return;
                            }
                            
                            // 需要提示
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
                            
                            [updateAlertView show];
                            
                            NSArray *insertArray = [[NSArray alloc] initWithObjects:@"1", [CommonUtils currentDateStr], nil];
                            [[FMDBConnection instance] updateSoftDB:insertArray];
                        }
                    }
                }
            } else if (ret == SESSION_EXPIRED_CODE){
                if (!_isAutoLogin) {
                    [self bringToFront];
                }
                [self doLoginLogic];
            }
        }
            [super connectDone:result
                           url:url
                   contentType:contentType];
            
            break;
            
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
                        
                        if ([AppManager instance].isMandatory == 1) {
                            
                            UIAlertView *updateAlertView = [[UIAlertView alloc] initWithTitle:LocaleStringForKey(NSNoteTitle, nil)
                                                                         message:@"有版本更新，您必须更新后才可使用。"
                                                                        delegate:self
                                                               cancelButtonTitle:LocaleStringForKey(NSCancelTitle, nil)
                                                               otherButtonTitles:LocaleStringForKey(NSSureTitle, nil), nil];
                            updateAlertView.tag = ALERT_TAG_CHOISE_UPDATE;

                            [updateAlertView show];
                        }
                    }
                    
//                    [[AppManager instance] updateLoginSuccess:dict];
                    
                    if (_isAutoLogin)
                    {
                        [[AppManager instance].userDefaults rememberUsername:_nameField.text andPassword:_passwordField.text pswdStr:_passwordField.text customerName:_passwordField.text userId:[[AppManager instance].userDefaults getSaveUserId]];
                    } else {
                        [[AppManager instance].userDefaults rememberUsername:_nameField.text andPassword:_passwordField.text pswdStr:_passwordField.text customerName:_passwordField.text userId:[AppManager instance].userId];
                    }
                    
                    
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
                    
                    if (self.delegate && [self.delegate respondsToSelector:@selector(loginSuccessfull:)]) {
                        [AppManager instance].passwd = _passwordField.text;  //保存一下密码
                        [AppManager instance].userId = [[[resultDict objectForKey:@"Data"] objectForKey:@"Member"] objectForKey:@"VipID"];
                        [self.delegate loginSuccessfull:self];
                        
                        [[AppManager instance].userDefaults rememberUsername:_nameField.text andPassword:_passwordField.text pswdStr:_passwordField.text customerName:_passwordField.text userId:[AppManager instance].userId];
                    }
                    
                } else {
                    NSString *msg = [resultDict objectForKey:@"Message"];
                    
                    [self bringToFront];
                    [[[[UIAlertView alloc] initWithTitle:LocaleStringForKey(NSNoteTitle, nil) message:msg delegate:nil cancelButtonTitle:LocaleStringForKey(NSSureTitle, nil) otherButtonTitles: nil] autorelease]show];
                    return;
                }
            } else {
                
                NSDictionary *resultDict = [result objectFromJSONData];
                NSString *msg = [resultDict objectForKey:@"Message"];
                
                [self bringToFront];
                [[[[UIAlertView alloc]initWithTitle:LocaleStringForKey(NSNoteTitle, nil) message:msg delegate:nil cancelButtonTitle:LocaleStringForKey(NSSureTitle, nil) otherButtonTitles: nil] autorelease]show];
            }
            
            break;
        }
            
        default:
            break;
    }
    
//    [_loginButton setEnabled:YES];
    
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
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(closeSplash)]) {
        [self.delegate closeSplash];
    }
//    if ([self connectionMessageIsEmpty:error]) {
//        self.connectionErrorMsg = LocaleStringForKey(NSActionFaildMsg, nil);
//    }
    
    [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - text field delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Company Action

- (void)companyClick:(id)sender
{
    DLog(@"COMPANY  SELECT  CLICK");
    [self.view endEditing:YES];
    
    NSMutableArray *dataArr = [NSMutableArray array];
    [dataArr addObject:@"宝洁"];
    [dataArr addObject:@"复星"];
    
    float  hGap = 200.5f;
    float  wGap = 38.0f;
    float  height = 200.0f;
    CGRect selectFrame = CGRectMake(wGap, hGap, SCREEN_WIDTH - wGap*2, height);
    
    _selectView = [[SelectView alloc] initWithData:dataArr Frame:selectFrame TipIcon:nil Delegate:self canScroll:YES];
    [_selectView showView];
}

- (void)selectWithData:(NSString *)name withIndex:(int)index
{
    // 保存角色信息到本地
    //    [[NSUserDefaults standardUserDefaults] setObject:name forKey:kChatUserRoleName];
    //    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [_companyField setText:name];
}

#pragma mark - UIAlertViewDelegate method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [alertView release];
    
    switch (alertView.tag) {
            
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
                [self doLoginLogic];
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - text change
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField isEqual:_nameField]) {
        
        if (range.location > 10)
            return NO; // return NO to not change text
        return YES;
    }
    
    if ([textField isEqual:_passwordField]) {
        
        if (range.location > 15)
            return NO; // return NO to not change text
        return YES;
    }
    
    return YES;
}

@end
