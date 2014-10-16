//
//  RegistViewController.h
//  iLife
//
//  Created by Adam on 14-9-11.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface RegistViewController : RootViewController

@property (nonatomic, retain) IBOutlet UITextField *mMobileTxt;
@property (nonatomic, retain) IBOutlet UITextField *mMobileCodeTxt;
@property (nonatomic, retain) IBOutlet UITextField *mPswdTxt;

@property (nonatomic, retain) IBOutlet UILabel *mGetCodeingNum;
@property (nonatomic, retain) IBOutlet UIButton *mRequestBtn;
@property (nonatomic, retain) IBOutlet UIButton *mGetCodeingBtn;
@property (nonatomic, retain) IBOutlet UIButton *mSubmitBtn;

- (IBAction)btnClick:(id)sender;

@end
