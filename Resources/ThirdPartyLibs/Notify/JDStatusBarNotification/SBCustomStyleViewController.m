//
//  SBCustomStyleViewController.m
//  JDStatusBarNotificationExample
//
//  Created by Markus on 08.11.13.
//  Copyright (c) 2013 Markus. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "JDStatusBarNotification.h"
#import "GlobalConstants.h"

/*
@interface SBCustomStyleViewController ()

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, weak) NSTimer *timer;

@property (nonatomic, assign) JDStatusBarAnimationType animationType;
@property (nonatomic, assign) JDStatusBarProgressBarPosition progressBarPosition;
@end

@implementation SBCustomStyleViewController

#pragma mark - UI Updates

- (void)updateStyle;
{
    [JDStatusBarNotification addStyleNamed:@"style" prepare:^JDStatusBarStyle *(JDStatusBarStyle *style) {
        
        style.font = FONT(14);
        style.textColor = [UIColor whiteColor];
        style.barColor = [UIColor blackColor];
        style.animationType = JDStatusBarAnimationTypeMove;
        
        style.progressBarColor = [UIColor redColor];
        style.progressBarPosition = JDStatusBarProgressBarPositionBottom;
        
        NSString *height = [@"text" stringByReplacingOccurrencesOfString:@"ProgressBarHeight (" withString:@""];
        height = [height stringByReplacingOccurrencesOfString:@" pt)" withString:@""];
        style.progressBarHeight = [height doubleValue];
        
        return style;
    }];
}

#pragma mark - Presentation

- (void)show:(id)sender;
{
    [JDStatusBarNotification showWithStatus:@"Show Message" dismissAfter:2.0 styleName:@"style"];
}

- (void)showWithProgress:(id)sender;
{
    double delayInSeconds = [JDStatusBarNotification isVisible] ? 0.0 : 0.25;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.progress = 0.0;
        [self startTimer];
    });
    
    [JDStatusBarNotification showWithStatus:@"Show Message" dismissAfter:1.3 styleName:@"style"];
}

#pragma mark - Progress Timer

- (void)startTimer;
{
    [JDStatusBarNotification showProgress:self.progress];
    
    [self.timer invalidate];
    self.timer = nil;
    
    if (self.progress < 1.0) {
        CGFloat step = 0.02;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:step target:self
                                                    selector:@selector(startTimer)
                                                    userInfo:nil repeats:NO];
        self.progress += step;
    } else {
        [self performSelector:@selector(hideProgress)
                   withObject:nil afterDelay:0.5];
    }
}

- (void)hideProgress;
{
    [JDStatusBarNotification showProgress:0.0];
}

@end
 */

