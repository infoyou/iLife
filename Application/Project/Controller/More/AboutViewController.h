//
//  AboutViewController.h
//  Association
//
//  Created by Adam on 14-6-25.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import "RootViewController.h"
#import "CommonMethod.h"

@interface AboutViewController : RootViewController
{
}

@property (nonatomic, retain) IBOutlet UILabel *mVersionLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
                  moc:(NSManagedObjectContext*)viewMOC;

@end