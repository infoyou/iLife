//
//  MBProgressHUD+Add.h
//  Project
//
//  Created by Adam on 14-7-17.
//  Copyright (c) 2013年 jit. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (Add)

+ (void)showError:(NSString *)error toView:(UIView *)view;
+ (void)showSuccess:(NSString *)success toView:(UIView *)view;

+ (MBProgressHUD *)showMessag:(NSString *)message toView:(UIView *)view;

@end
