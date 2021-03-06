//
//  WXWNumberBadge.h
//  wxwlib
//
//  Created by MobGuang on 13-1-23.
//  Copyright (c) 2013年 MobGuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXWGradientView.h"

@class WXWLabel;

@interface WXWNumberBadge : UIView {
  @private
  WXWLabel *_numberLabel;
}

- (id)initWithFrame:(CGRect)frame
    backgroundColor:(UIColor *)backgroundColor
               font:(UIFont *)font;

#pragma mark - set title
- (void)setNumberWithTitle:(NSString *)title;

@end
