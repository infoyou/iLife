//
//  UILabel+Category.m
//  iLife
//
//  Created by hys on 14-9-25.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import "UILabel+Category.h"

@implementation UILabel (Category)

-(void)setLabelWithSize:(CGFloat)size Color:(UIColor *)color
{
    [self setFont:[UIFont systemFontOfSize:size]];
    [self setTextColor:color];
}

@end
