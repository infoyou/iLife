
#import "NewsCommonWebViewController.h"
#import "ImageList.h"

typedef enum {
    NEWS_BACK_TYPE = 101,
    NEWS_NEXT_TYPE,
} NEWS_Navi_Type;

@interface NewsCommonWebViewController ()
{
}

@property (nonatomic, retain) ImageList *newsDetail;

@end

@implementation NewsCommonWebViewController
{
    int _newsId;
}

@synthesize newsTitle;
@synthesize webView;
@synthesize newsDetail;

- (id)initWithMOC:(NSManagedObjectContext *)MOC newsId:(int)newsId {
    
    self = [super initWithMOC:MOC];
    if (self) {
        _newsId = newsId;
    }
    return self;
}

- (void)dealloc
{
    self.newsTitle = nil;
    self.newsDetail = nil;
    
    [self closeAsyncLoadingView];
    [self.webView setDelegate:nil];
    [self.webView stopLoading];
    self.webView = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{  
    [super viewDidLoad];
    
    self.title = self.newsTitle;
    
    [self loadNewslistData];
//    [self getImageDetail];
}

#pragma mark - WebView Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil) blockCurrentView:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self closeAsyncLoadingView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self closeAsyncLoadingView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)getImageDetail
{
    self.fetchedRC = nil;
    
    self.entityName = @"ImageList";
    self.descriptors = [NSMutableArray array];
    self.predicate = [NSPredicate predicateWithFormat:@"imageID == %d", _newsId];
    
    NSSortDescriptor *dateDesc = [[[NSSortDescriptor alloc] initWithKey:@"settingTime" ascending:YES] autorelease];
    [self.descriptors addObject:dateDesc];
    
    self.fetchedRC = [WXWCoreDataUtils fetchObject:_MOC
                          fetchedResultsController:self.fetchedRC
                                        entityName:self.entityName
                                sectionNameKeyPath:self.sectionNameKeyPath
                                   sortDescriptors:self.descriptors
                                         predicate:self.predicate];
    NSError *error = nil;
    
    if (![self.fetchedRC performFetch:&error]) {
        NSAssert1(0, @"Unhandled error performing fetch: %@", [error localizedDescription]);
    }
    
    int imageListSize = self.fetchedRC.fetchedObjects.count;
    if (imageListSize > 0) {
        self.newsDetail = [self.fetchedRC.fetchedObjects objectAtIndex:0];
    }
    
    [self addLogicView];
}

- (void)doNaviClick:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    int tag = btn.tag;

    if (tag == NEWS_BACK_TYPE) {
        if (self.newsDetail.imagePreId && [self.newsDetail.imagePreId intValue] > -1) {
            _newsId = [self.newsDetail.imagePreId intValue];
            [self loadNewslistData];
        }
    } else if (tag == NEWS_NEXT_TYPE) {
        if (self.newsDetail.imageNextId && [self.newsDetail.imageNextId intValue] > -1) {
            _newsId = [self.newsDetail.imageNextId intValue];
            [self loadNewslistData];
        }
    }
}

- (void)loadNewslistData
{
//    NSMutableDictionary *specialDict = [[[NSMutableDictionary alloc] init] autorelease];
//    
//    [specialDict setObject:@"0" forKey:@"pageIndex"];
//    [specialDict setObject:@"10" forKey:@"pageSize"];
    
    NSString *url = [NSString stringWithFormat:@"http://120.132.145.149:9080/app/common!showCapabilityNews.action?newId=%d", _newsId];
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:PG_SERVER_URL_GETNEWSLIST
                                                              contentType:PG_GET_NEWSDETAIL];
    [connFacade fetchGets:url];
//    [connFacade post:PG_SERVER_URL_GETNEWSLIST data:[specialDict JSONData]];
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url contentType:(NSInteger)contentType {
    [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil) blockCurrentView:YES];
    
    [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
    switch (contentType) {
            
        case PG_GET_NEWSDETAIL:
        {
            
            ConnectionAndParserResultCode ret = [JSONParser parserResponseJsonData:result
                                                                              type:contentType
                                                                               MOC:_MOC
                                                                 connectorDelegate:self
                                                                               url:url
                                                                           paramID:0];
            
            if (ret == SUCCESS_CODE) {
                
                [self getImageDetail];
            }
            
            break;
        }

        default:
            break;
    }
    
    [super connectDone:result url:url contentType:contentType];
    
}

- (void)connectCancelled:(NSString *)url contentType:(NSInteger)contentType {
    
    [super connectCancelled:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error url:(NSString *)url contentType:(NSInteger)contentType {
    
    if ([self connectionMessageIsEmpty:error]) {
        self.connectionErrorMsg = LocaleStringForKey(NSActionFaildMsg, nil);
    }
    
    [super connectFailed:error url:url contentType:contentType];
}

- (void)addLogicView
{
    CGRect frame = CGRectMake(self.view.frame.origin.x, 0.0, SCREEN_WIDTH, self.view.frame.size.height);
    
    // web view
    CGRect webFrame = frame;
    self.webView = [[[UIWebView alloc] initWithFrame:webFrame] autorelease];
    self.webView.backgroundColor = [UIColor whiteColor];
    self.webView.opaque = NO;
    self.webView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    self.webView.delegate = self;
    self.webView.scalesPageToFit = YES;
    self.webView.userInteractionEnabled = YES;
    
    NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    
    NSString *html = newsDetail.content;
    
    [self.webView loadHTMLString:html baseURL:baseURL];
    [self.view addSubview:self.webView];
    
    // navi button
    // back
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setBackgroundColor:[UIColor clearColor]];
    [backBtn setTag:NEWS_BACK_TYPE];
    
    if (self.newsDetail.imagePreId && [self.newsDetail.imagePreId intValue] > -1) {
        [backBtn setBackgroundImage:IMAGE_WITH_IMAGE_NAME(@"IMG_1011_03.png") forState:UIControlStateNormal];
        [backBtn setBackgroundImage:IMAGE_WITH_IMAGE_NAME(@"IMG_1011_03_un.png") forState:UIControlStateHighlighted];
            [backBtn addTarget:self action:@selector(doNaviClick:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [backBtn setBackgroundImage:IMAGE_WITH_IMAGE_NAME(@"IMG_1011_03_un.png") forState:UIControlStateNormal];
    }
    [backBtn setTitle:LocaleStringForKey(@"Previous", nil) forState:UIControlStateNormal];
    [backBtn setTitleColor:HEX_COLOR(@"a2a2a2") forState:UIControlStateNormal];
    [backBtn.titleLabel setFont:FONT(16)];
    if (SCREEN_HEIGHT > 480) {
        [backBtn setFrame:CGRectMake(28, 440, 123, 40)];
    } else {
        [backBtn setFrame:CGRectMake(28, 340, 123, 40)];
    }
    [self.view addSubview:backBtn];
    
    // next
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextBtn setBackgroundColor:[UIColor clearColor]];
    [nextBtn setTag:NEWS_NEXT_TYPE];
    
    if (self.newsDetail.imageNextId && [self.newsDetail.imageNextId intValue] > -1) {

        [nextBtn setBackgroundImage:IMAGE_WITH_IMAGE_NAME(@"IMG_1011_03.png") forState:UIControlStateNormal];
        [nextBtn setBackgroundImage:IMAGE_WITH_IMAGE_NAME(@"IMG_1011_03_un.png") forState:UIControlStateHighlighted];
        [nextBtn setTitle:LocaleStringForKey(@"Next", nil) forState:UIControlStateNormal];
        [nextBtn addTarget:self action:@selector(doNaviClick:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [nextBtn setBackgroundImage:IMAGE_WITH_IMAGE_NAME(@"IMG_1011_03_un.png") forState:UIControlStateNormal];
    }
    
    [nextBtn setTitleColor:HEX_COLOR(@"a2a2a2") forState:UIControlStateNormal];
    [nextBtn.titleLabel setFont:FONT(16)];
    if (SCREEN_HEIGHT > 480) {
        [nextBtn setFrame:CGRectMake(175, 440, 123, 40)];
    } else {
        [nextBtn setFrame:CGRectMake(175, 340, 123, 40)];
    }
    [self.view addSubview:nextBtn];
}

@end
