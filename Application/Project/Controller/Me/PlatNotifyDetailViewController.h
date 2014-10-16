//
//  PlatNotifyDetailViewController.h
//  Association
//
//  Created by Adam on 14-6-25.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import "RootViewController.h"
#import "CommonMethod.h"
#import "PlatNotifyListViewController.h"
#import "CustomUILabel.h"

@class MessageItem;

@interface PlatNotifyDetailViewController : RootViewController
{
}

@property (nonatomic, retain) IBOutlet UILabel *mTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *mDateLabel;
@property (nonatomic, retain) IBOutlet CustomUILabel *mDescLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
                  moc:(NSManagedObjectContext*)viewMOC orderItem:(MessageItem *)orderItem;

@end