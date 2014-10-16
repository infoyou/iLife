//
//  NewAddressViewController.m
//  Association
//
//  Created by Adam on 14-6-25.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import "NewAddressViewController.h"

@interface NewAddressViewController ()
{
}

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

- (void)saveAddress:(id)sender
{
    ShowAlert(self, NSLocalizedString(NSNoteTitle, nil), @"非常抱歉,该地址附近没有菜场配送.", NSLocalizedString(NSSureTitle, nil));
}

@end
