//
//  ShareViewController.m
//  Association
//
//  Created by Adam on 14-6-25.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import "ShareViewController.h"

@interface ShareViewController ()
{
}

@end

@implementation ShareViewController
{
}

@synthesize mVersionLabel = _mVersionLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
                  moc:(NSManagedObjectContext*)viewMOC
{
    self = [super initWithMOC:viewMOC];
    if (self) {
        _noNeedBackButton = NO;
        self.view = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil].view;
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
    self.navigationItem.title = @"分享";
    
    _mVersionLabel.text = [NSString stringWithFormat:@"%@ V%@", LocaleStringForKey(NSAppTitle, nil), VERSION];
}

- (void)dealloc
{
    [super dealloc];
}

- (void)back:(id)sender
{
    
//    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1]
//                                          animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
