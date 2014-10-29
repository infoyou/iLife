//
//  ALSweepViewController.m
//  Aladdin
//
//  Created by user on 14-6-13.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import "ALSweepViewController.h"

@interface ALSweepViewController ()

@end

@implementation ALSweepViewController

@synthesize readerView;

@synthesize itemId;

@synthesize customerId;

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"二维码/条码";
    
    ZBarImageScanner *imageScanner=[[ZBarImageScanner alloc] init];
    
    readerView=[[ZBarReaderView alloc] initWithImageScanner:imageScanner];
    
    [readerView setFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64)];
    
    [readerView setTracksSymbols:NO];
    
    readerView.readerDelegate = self;
    
    [self.view addSubview:readerView];
    
    
    //扫一扫底图
    UIImageView *bgImgV=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sweep.png"]];
    [self.view addSubview:bgImgV];
    UIImageView *barScanImgV=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"barScan.png"]];
    [barScanImgV setFrame:CGRectMake(self.view.bounds.size.width/2-110, 100, 219, 11)];
    [self.view addSubview:barScanImgV];
    
    [UIView beginAnimations:@"scanner" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:1.5];
    [UIView setAnimationDelay:0.2];
    [UIView setAnimationRepeatCount:HUGE_VALF];
    [barScanImgV setFrame:CGRectMake(self.view.bounds.size.width/2-110, 329, 219, 11)];
    
    [UIView commitAnimations];
    
    
    if(TARGET_IPHONE_SIMULATOR) {
        cameraSim = [[ZBarCameraSimulator alloc]
                     initWithViewController: self];
        cameraSim.readerView = readerView;
    }
}

- (void) readerView: (ZBarReaderView*) readerView
     didReadSymbols: (ZBarSymbolSet*) symbols
          fromImage: (UIImage*) image
{
    
    int flag=0;
    
    self.itemId=@"";
    
    self.customerId=@"";
    
    for (ZBarSymbol *sym in symbols) {
        
        NSString *result=sym.data;
        
        NSRange rang=[[result lowercaseString] rangeOfString:@"auth.html?"];
        
        if (rang.location+rang.length>0&&rang.length>0) {
            
            NSString *paramsString=[result substringFromIndex:rang.location+rang.length];
            
            NSArray *paramPairs=[paramsString componentsSeparatedByString:@"&"];
            
            for (int j=0; j<[paramPairs count]; j++) {
                
                NSString *paramString=[paramPairs objectAtIndex:j];
                
                NSArray *paramPair=[paramString componentsSeparatedByString:@"="];
                
                [self parseParam:paramPair];
                    
            }
            
            flag++;
            
        }
        
        
        NSLog(@"%@",sym.data);
        
    }
    
    if (flag>0) {
        
        if ([self.itemId length]>0) {
            
//            NSString *redirectURL=[[ALUIManagement shareUIManagement] getProductDetailURL:self.customerId itemId:self.itemId];
//            
//            [[ALUIManagement shareUIManagement] redirectViewController:redirectURL innerViewController:self];
            
        }
    }
    else
    {
        
        UIAlertView *alv=[[UIAlertView alloc] initWithTitle:nil message:@"二维码无效，请更换" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alv show];
        
    }
   
    
    
}

#pragma mark -Get Item Id  And CustomerId
-(void) parseParam:(NSArray *) param
{
    
    if ([param count]==2) {
        
        NSString *paramKey=[param objectAtIndex:0];
        
        NSString *paramValue=[param objectAtIndex:1];
        
        if ([paramKey isEqualToString:@"goodsId"]) {
            
            self.itemId=paramValue;
            
        }
        else if ([paramKey isEqualToString:@"customerId"])
        {
            self.customerId=paramValue;
        }
    }
    
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) orient
{
    // auto-rotation is supported
    return(YES);
}

- (void) willRotateToInterfaceOrientation: (UIInterfaceOrientation) orient
                                 duration: (NSTimeInterval) duration
{
    // compensate for view rotation so camera preview is not rotated
    [readerView willRotateToInterfaceOrientation: orient
                                        duration: duration];
}

- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear:animated];
    // run the reader when the view is visible
    [readerView start];
}

- (void) viewWillDisappear: (BOOL) animated
{
    [super viewWillDisappear:animated];
    [readerView stop];
}
-(void) willMoveToParentViewController:(UIViewController *)parent
{
    [self.navigationController setNavigationBarHidden:YES];
}


@end
