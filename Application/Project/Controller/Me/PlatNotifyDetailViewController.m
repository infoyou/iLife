//
//  PlatNotifyDetailViewController.m
//  Association
//
//  Created by Adam on 14-6-25.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import "PlatNotifyDetailViewController.h"

@interface PlatNotifyDetailViewController ()
{
}

@end

@implementation PlatNotifyDetailViewController
{
    MessageItem *_orderItem;
}

@synthesize mTitleLabel = _mTitleLabel;
@synthesize mDateLabel = _mDateLabel;
@synthesize mDescLabel = _mDescLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
                  moc:(NSManagedObjectContext*)viewMOC orderItem:(MessageItem *)orderItem
{
    self = [super initWithMOC:viewMOC];
    if (self) {
        _noNeedBackButton = NO;
        _orderItem = orderItem;
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
    self.navigationItem.title = LocaleStringForKey(NSDetailTitle, nil);
    
    _mTitleLabel.text = _orderItem.title;
    _mDateLabel.text = [NSString stringWithFormat:@"%@", _orderItem.messageTime];
    _mDescLabel.text = _orderItem.body;
    
    [_mDescLabel setVerticalAlignment:VerticalAlignmentTop];

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
