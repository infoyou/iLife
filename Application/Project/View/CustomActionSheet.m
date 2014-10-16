//
//  CustomActionSheet.m
//  iLife
//
//  Created by hys on 14-9-17.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import "CustomActionSheet.h"

@implementation CustomActionSheet

- (id)initWithContentView:(UIView *)view
{
    self=[super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        //
        _adaptation=NO;
        self.contentView=view;
        if (SCREEN_HEIGHT==568&&!_adaptation) {
            CGRect frame=self.contentView.frame;
            frame.origin.y+=88;
            [self.contentView setFrame:frame];
            _adaptation=YES;
        }
        
    }
    return self;
}

- (void)dismissWithButtonIndex:(NSInteger)index animated:(BOOL)animated
{
    [self dismissWithClickedButtonIndex:index animated:animated];
    [self.delegate actionSheet:self clickedButtonAtIndex:index];
}

-(void)layoutSubviews{
    
    [super layoutSubviews];
    [self.superview addSubview:self.contentView];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
