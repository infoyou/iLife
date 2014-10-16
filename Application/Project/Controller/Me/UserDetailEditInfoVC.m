
#import <QuartzCore/QuartzCore.h>
#import "UserDetailEditInfoVC.h"
#import "CommonHeader.h"
#import "GCPlaceholderTextView.h"

@interface UserDetailEditInfoVC () <UITextViewDelegate, UITextFieldDelegate, PassValueDelegate>

@end

@implementation UserDetailEditInfoVC {
    
    UIView *_backgroundView;
    UITextView *_contentTextView;

    int _marginX;
    int _marginY;
    int _distY;
    
    UITextField *_nameTextField;
    UserObject *_userObject;
    
    UIBarButtonItem *_rightButton;
    
    NSMutableArray *dropArray;
	UILabel *_characterCountLabel;
    int _macCharacterCount;
    
    int _type;
    
    int _selIndex;
}

@synthesize delegate = _delegate;
@synthesize matchList;

- (void)dealloc
{

    RELEASE_OBJ(matchList);
    RELEASE_OBJ(dropArray);
    RELEASE_OBJ(_userObject);
    
    [super dealloc];
}

- (id)initWithDataModal:(UserObject *)dataModal propType:(int)propType
{
    if (self = [super init]) {
        
        _userObject = dataModal;
        _type = propType;
        dropArray = nil;
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.view.backgroundColor = DEFAULT_VIEW_COLOR;
    
    self.navigationItem.title = self.title;
    
    _macCharacterCount = 200;
    
    [self initNavButton];
    
    [self initData];
    
    if (_type == USER_PROPERTY_SUPEREMAIL) {
        [self addMatchView];
    } else {
        [CommonMethod viewAddGuestureRecognizer:self.view withTarget:self withSEL:@selector(viewTapped:)];
    }
}

- (void)initNavButton
{
    UIBarButtonItem *btnSave = [[UIBarButtonItem alloc]
                                initWithTitle:LocaleStringForKey(NSSaveTitle, nil)
                                style:UIBarButtonItemStylePlain
                                target:self
                                action:@selector(rightNavButtonClicked:)];
    self.navigationItem.rightBarButtonItem = btnSave;
    [btnSave release];
}

- (void)loadUpdateChatGroup:(LoadTriggerType)triggerType forNew:(BOOL)forNew
{
    NSMutableDictionary *specialDict = [NSMutableDictionary dictionary];
    
    switch (_type) {
            
        // --- P&G start ---
        case USER_PROPERTY_FUNCTION:
            if (_contentTextView.text) {
                _userObject.function = _contentTextView.text;
                [specialDict setValue:_userObject.function forKey:@"Function"];
            }
            break;
            
        case USER_PROPERTY_CHANNEL:
            if (_contentTextView.text) {
                _userObject.channel = _contentTextView.text;
                _userObject.channelId = _selIndex;
            }
            break;
            
        case USER_PROPERTY_BAND:
            if (_contentTextView.text)
                _userObject.band = _contentTextView.text;
            break;
        // --- P&G end ---
            
        case USER_PROPERTY_EMAIL:
        {
            if (_contentTextView.text)
                _userObject.userEmail = _contentTextView.text;
            break;
        }
            
        case USER_PROPERTY_PHONE:
        {
            if (_contentTextView.text) {
                _userObject.userTel = _contentTextView.text;
                [specialDict setValue:_userObject.userTel forKey:@"UserTelephone"];
            }
            break;
        }
            
        case USER_PROPERTY_TEL:
        {
            if (_contentTextView.text) {
                _userObject.userCellphone = _contentTextView.text;
                [specialDict setValue:_userObject.userCellphone forKey:@"UserCellphone"];
            }
            break;
        }
            
        case USER_PROPERTY_GENDER:
        {
            NSString *result = _contentTextView.text;
            if ([result isEqual:LocaleStringForKey(NSMaleTitle, nil)]) {
                _userObject.userGender = 1;
            } else if ([result isEqual:LocaleStringForKey(NSFemaleTitle, nil)]) {
                _userObject.userGender = 2;
            }
            break;
        }
            
        case USER_PROPERTY_SUPEREMAIL:
        {
            if (_contentTextView.text) {
                _userObject.superEmail = _contentTextView.text;
                [specialDict setValue:_userObject.superEmail forKey:@"SuperiorName"];
            }
            break;
        }
            
        case USER_PROPERTY_LOCATION:
        {
            if (_contentTextView.text) {
                _userObject.location = _contentTextView.text;
                [specialDict setValue:_userObject.location forKey:@"Location"];
            }
            break;
        }
            
        case USER_PROPERTY_SERVICEYEAR:
        {
            if (_contentTextView.text) {
                _userObject.serviceYear = _contentTextView.text;
                [specialDict setValue:_userObject.serviceYear forKey:@"ServiceYear"];
            }
            break;
        }
        
        case USER_PROPERTY_SUBORDINATECOUNT:
        {
            if (_contentTextView.text) {
                _userObject.subordinateCount = _contentTextView.text;
                [specialDict setValue:_userObject.subordinateCount forKey:@"SubordinateCount"];
            }
            break;
        }
            
        default:
            break;
    }
    
    [specialDict setValue:_userObject.userEmail forKey:@"UserEmail"];
    [specialDict setValue:[AppManager instance].pgCookie forKey:@"PGToken"];
    
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@%@", VALUE_API_PREFIX, API_SERVICE_USER, API_MODIFY_USER_INFO];
    NSString *url = [ProjectAPI getURL:urlStr specialDict:specialDict];
    
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:CHAT_GROUP_UPDATE_TY];
    [connFacade fetchGets:url];
}


- (void)rightNavButtonClicked:(id)sender
{
    [self loadUpdateChatGroup:TRIGGERED_BY_AUTOLOAD forNew:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewTapped:(UISwipeGestureRecognizer *)recognizer
{
    [_nameTextField resignFirstResponder];
}

- (void)initData
{
    _marginX = 0;
    _marginY = 10;
    _distY = 10;

    int startX = _marginX;
    int startY = _marginY + ITEM_BASE_TOP_VIEW_HEIGHT;
    int width = SCREEN_WIDTH - 2*startX;
    int height = SCREEN_HEIGHT;
    _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(startX, startY, width, height)];
    _backgroundView.layer.cornerRadius = 0.0f;
    _backgroundView.backgroundColor = [UIColor whiteColor];
    
    //------------------------------------------------------
    startY = _marginY;
    width = _backgroundView.frame.size.width - 2*startX;
    height = 40;
    
    _contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(startX, startY, width, height)];
    _contentTextView.font = FONT_SYSTEM_SIZE(15);
    _contentTextView.delegate = self;
    _contentTextView.textColor = [UIColor darkGrayColor];
    _contentTextView.backgroundColor = TRANSPARENT_COLOR;
//    _contentTextView.clearButtonMode = UITextFieldViewModeNever;
    
    [_backgroundView addSubview:_contentTextView];
    
    _characterCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _contentTextView.frame.origin.y + _contentTextView.frame.size.height - 10, _contentTextView.frame.size.width, 30)];
    [_characterCountLabel setFont:FONT_SYSTEM_SIZE(14)];
    _characterCountLabel.textAlignment = UITextAlignmentRight;
    _characterCountLabel.textColor = [UIColor colorWithHexString:@"0x666666"];
//    [_backgroundView  addSubview:_characterCountLabel];
    //------------------------------------------------------
    
    CGRect rect = _backgroundView.frame;
    rect.size.height = _contentTextView.frame.origin.y + _contentTextView.frame.size.height + _distY;
    _backgroundView.frame = rect;
    //------------------------------------------------------
    [self changeTextViewHeight:_contentTextView];
    
    [self.view addSubview:_backgroundView];
    [_backgroundView release];
    
    switch (_type) {
        // --- P&G start ---
        case USER_PROPERTY_FUNCTION:
            _contentTextView.text = _userObject.function;
            _macCharacterCount = GROUP_PROPERTY_MAX_COUNT_EMAIL;
            break;
            
        case USER_PROPERTY_CHANNEL:
            _contentTextView.text = _userObject.channel;
            _macCharacterCount = GROUP_PROPERTY_MAX_COUNT_EMAIL;
            break;
            
        case USER_PROPERTY_BAND:
            _contentTextView.text = _userObject.band;
            _macCharacterCount = GROUP_PROPERTY_MAX_COUNT_EMAIL;
            break;
        // --- P&G end ---
            
        case USER_PROPERTY_EMAIL:
            _contentTextView.text = _userObject.userEmail;
            _macCharacterCount = GROUP_PROPERTY_MAX_COUNT_EMAIL;
            break;
        
        case USER_PROPERTY_PHONE:
            _contentTextView.text = _userObject.userTel;
            _macCharacterCount = GROUP_PROPERTY_MAX_COUNT_PHONE;
            break;
            
        case USER_PROPERTY_TEL:
            _contentTextView.text = _userObject.userCellphone;
            _macCharacterCount = GROUP_PROPERTY_MAX_COUNT_EMAIL;
            break;
            
        case USER_PROPERTY_SUPEREMAIL:
            _contentTextView.text = _userObject.superEmail;
            _macCharacterCount = GROUP_PROPERTY_MAX_COUNT_EMAIL;
            break;
            
        case USER_PROPERTY_LOCATION:
            _contentTextView.text = _userObject.location;
            
            _macCharacterCount = GROUP_PROPERTY_MAX_COUNT_EMAIL;
            break;

        case USER_PROPERTY_GENDER:
        {
            NSString *genderStr = LocaleStringForKey(NSMaleTitle, nil);
            if (_userObject.userGender > 1) {
                genderStr = LocaleStringForKey(NSFemaleTitle, nil);
            }
            _contentTextView.text = genderStr;
            _macCharacterCount = GROUP_PROPERTY_MAX_COUNT_EMAIL;
            break;
        }
            
        case USER_PROPERTY_SERVICEYEAR:
            _contentTextView.text = _userObject.serviceYear;
            _macCharacterCount = GROUP_PROPERTY_MAX_COUNT_EMAIL;
            _contentTextView.keyboardType = UIKeyboardTypeNumberPad;
            break;
        
        case USER_PROPERTY_SUBORDINATECOUNT:
            _contentTextView.text = _userObject.subordinateCount;
            _macCharacterCount = GROUP_PROPERTY_MAX_COUNT_EMAIL;
            _contentTextView.keyboardType = UIKeyboardTypeNumberPad;
            break;
            
        default:
            break;
    }
    
	[_characterCountLabel setText:[NSString stringWithFormat:@"%d/%d",  _contentTextView.text.length, _macCharacterCount]];
    
    [self changeTextViewHeight:_contentTextView];
}

-(void)updateCharacterCount
{
    
    CGRect rect = _characterCountLabel.frame;
    rect.origin.y = _backgroundView.frame.origin.y + _backgroundView.frame.size.height - 10;
    _characterCountLabel.frame = rect;
}

#pragma mark - text field delegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType {
    [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil) blockCurrentView:YES];
    
    [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
    
    switch (contentType) {
        case CHAT_GROUP_UPDATE_TY:
        {
            ConnectionAndParserResultCode ret = [JSONParser parserResponseJsonData:result
                                                                              type:contentType
                                                                               MOC:_MOC
                                                                 connectorDelegate:self
                                                                               url:url
                                                                           paramID:0];
            if (ret == SUCCESS_CODE) {
                
                [[FMDBConnection instance] updateUserObjectDB:_userObject];
                [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSUpdateSuccessTitle, nil)
                                                 msgType:INFO_TY
                                      belowNavigationBar:YES];
                [self back:nil];
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

#pragma mark - uitextview delegate

-(void)changeTextViewHeight:(UITextView *)textView
{
    CGRect frame = textView.frame;
    CGSize size = [textView.text sizeWithFont:textView.font
                            constrainedToSize:CGSizeMake(280, 1000)
                                lineBreakMode:UILineBreakModeTailTruncation];
    frame.size.height = size.height > 1 ? size.height + 20 : 64;
    
    if (frame.size.height < 200) {
        
        textView.frame = frame;
        
        CGRect rect = _backgroundView.frame;
        rect.size.height = textView.frame.origin.y + textView.frame.size.height + _distY;
        _backgroundView.frame = rect;
    }
    
    [self updateCharacterCount];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (range.location < _macCharacterCount) {
        return YES;
    }
    int count = _macCharacterCount - [[textView text] length];
    if (count <= 0)
        return NO;
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    
    if (_type == USER_PROPERTY_SUPEREMAIL) {
        
//        textView.userInteractionEnabled = NO;
        [self doMatchLogic:textView.text];
    }
    
    // Update the character count
	int count = _macCharacterCount - [[textView text] length];
    
    if (count < 0) {
        textView.text = [textView.text substringToIndex:_macCharacterCount];
        count = 0;
    }
    
	[_characterCountLabel setText:[NSString stringWithFormat:@"%d/%d", _macCharacterCount - count, _macCharacterCount]];
    
    [self changeTextViewHeight:textView];
}

#pragma mark - PassValueDelegate method
- (void)passValue:(NSString *)value
{
    [_contentTextView resignFirstResponder];
    [self setMatchListHidden:YES];
    _contentTextView.text = value;
}

#pragma mark - match List
- (void)addMatchView
{
    
    matchList = [[MatchListViewController alloc] initWithStyle:UITableViewStylePlain];
    matchList._delegate = self;
    
    [self.view addSubview:matchList.view];
    [matchList.view setFrame:CGRectMake(10, 75, 300, 0)];
}

- (void)doMatchLogic:(NSString *)keyWords
{
    
    if ([keyWords length] != 0) {
        matchList._searchText = keyWords;
        
        [matchList updateMatchData:[[FMDBConnection instance] getUserEmailByKeyword:keyWords]];
        [self setMatchListHidden:NO];
    } else {
        [self setMatchListHidden:YES];
    }
}

- (void)setMatchListHidden:(BOOL)hidden
{
    
	NSInteger height = hidden ? 0 : 160;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:.2];
	[matchList.view setFrame:CGRectMake(10, 75, 300, height)];
	[UIView commitAnimations];
}

@end
