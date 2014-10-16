
#import "SplashViewController.h"
#import "WXWCommonUtils.h"
#import "ProjectAPI.h"
#import "AppManager.h"
#import "TextPool.h"
#import "JSONParser.h"
#import "JSONKit.h"
#import "CommonMethod.h"
#import "UIDevice+Hardware.h"
#import <MediaPlayer/MediaPlayer.h>

#import "DirectionMPMoviePlayerViewController.h"

@interface SplashViewController ()

@end

@implementation SplashViewController

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
    
    self.navigationController.navigationBarHidden = YES;
    
    UIImage *image = nil;
    NSString *model = [WXWCommonUtils deviceModel];
    
    if ([model isEqualToString:IPHONE_1G_NAMESTRING] ||
        [model isEqualToString:IPHONE_3G_NAMESTRING] ||
        [model isEqualToString:IPHONE_3GS_NAMESTRING] ||
        [model isEqualToString:IPHONE_4_NAMESTRING] ||
        [model isEqualToString:IPHONE_4S_NAMESTRING] ) {
        
        image = [UIImage imageNamed:@"Default.png"];
    } else {

        image = [UIImage imageNamed:@"Default-568h.png"];
    }
    
    self.view.backgroundColor = [UIColor blackColor];
    
    CGRect imageFrame = CGRectZero;
    
    if ([CommonMethod is7System]) {
        imageFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    } else {
        
        imageFrame = CGRectMake(0, -20.0f, self.view.frame.size.width, self.view.frame.size.height + 20);
    }
    
    UIImageView *startUpImageView = [[[UIImageView alloc] initWithFrame:imageFrame] autorelease];
    startUpImageView.backgroundColor = [UIColor blackColor];
    startUpImageView.image = image;
    
    [self.view addSubview:startUpImageView];
    
    startUpImageView.alpha = 0.0f;
    [UIView animateWithDuration:2 animations:^{
        
        startUpImageView.alpha = 1.0f;
    } completion:^(BOOL finished){ }];

    
    [self startSplash];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([IPHONE_SIMULATOR isEqualToString:[WXWCommonUtils deviceModel]]) {
        
    if (self.delegate && [self.delegate respondsToSelector:@selector(endSplash:)]) {
        [self.delegate endSplash:self];
    }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIDeviceOrientationIsLandscape(interfaceOrientation);
}

- (void)startSplash
{
#if 0
    [self showProgressWithLabel:LocaleStringForKey(NSSplashLoadNessesaryResource, nil) task:^int(MBProgressHUD * hud) {
        sleep(2);
        return 1;
    } completion:^(int result) {
        if (result) {
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(endSplash:)]) {
                [self.delegate endSplash:self];
            }
        }
    }];
#elif 1
#endif
}

@end
