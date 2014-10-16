//
//  UIAlertView+Block.h
//  iLife
//
//  Created by Adam on 14-9-25.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CompleteBlock) (NSInteger buttonIndex);

@interface UIAlertView (Block)

- (void)showAlertViewWithCompleteBlock:(CompleteBlock) block;

@end
