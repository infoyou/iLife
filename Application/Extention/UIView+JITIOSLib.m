//
//  UIView+CPOS.m
//  cpos
//
//  Created by user on 13-3-1.
//  Copyright (c) 2013年 jit. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "UIView+JITIOSLib.h"

void drawViewAndLabels(UIView *view, CGContextRef context)
{
    if(view.alpha > 0) {
        CGFloat r, g, b, alp;
        [view.backgroundColor getRed:&r green:&g blue:&b alpha:&alp];
        CGContextSetRGBFillColor(context, r, g, b, view.alpha);
        CGContextFillRect(context, view.frame);
    }
    for(UIView *v in view.subviews) {
        if([v isKindOfClass:[UILabel class]]) {
            UILabel *l = (UILabel *) v;
            [l.textColor set];
            [l.text drawInRect:l.frame withFont:l.font lineBreakMode:l.lineBreakMode alignment:l.textAlignment];
        }
    }
}

@implementation UIView (JITIOSLib)
- (CGFloat) frameHeight
{
	return self.frame.size.height;
}

- (CGFloat) frameWidth
{
	return self.frame.size.width;
}

- (void) setFrameHeight:(CGFloat) height
{
	CGRect f = self.frame;
	f.size.height = height;
	self.frame = f;
}

- (void) stratchUpBy:(CGFloat) height
{
    CGRect f = self.frame;
    f.size.height += height;
    f.origin.y -= height;
    self.frame = f;
}

- (void) stratchLeftBy:(CGFloat) width
{
    CGRect f = self.frame;
    f.size.width += width;
    f.origin.x -= width;
    self.frame = f;
}

- (void) setFrameOriginY:(CGFloat) y animated:(BOOL) animated
{
	CGRect f = self.frame;
	f.origin.y = y;
	if(animated) {
		[UIView animateWithDuration:0.2f animations:^{self.frame = f;}];
	} else {
		self.frame = f;
	}
}

- (void) setFrameOriginX:(CGFloat) x animated:(BOOL) animated
{
	CGRect f = self.frame;
	f.origin.x = x;
	if(animated) {
		[UIView animateWithDuration:0.2f animations:^{self.frame = f;}];
	} else {
		self.frame = f;
	}
}

- (void) setFrameOriginX:(CGFloat) x
{
	CGRect f = self.frame;
	f.origin.x = x;
	self.frame = f;
}

- (void) setFrameSize:(CGSize) size
{
	CGRect f = self.frame;
	f.size.height = size.height;
	f.size.width = size.width;
	self.frame = f;
}

- (void) setFrameOrigin:(CGPoint) point
{
	CGRect f = self.frame;
	f.origin.x = point.x;
	f.origin.y = point.y;
	self.frame = f;
}

- (void) widthToFit
{
	CGRect f = self.frame;
	[self sizeToFit];
	f.size.width = self.frame.size.width;
	self.frame = f;
}

- (void) removeAllSubviews
{
	for(UIView *v in self.subviews)
		[v removeFromSuperview];
}

- (CGPoint) leftBottomPoint
{
	return CGPointMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height);
}

- (UILabel *) labelWithTag:(NSInteger) tag
{
	return (UILabel *) [self viewWithTag:tag];
}

- (UIButton *) buttonWithTag:(NSInteger) tag
{
	return (UIButton *) [self viewWithTag:tag];
}

- (UIImageView *) imageViewWithTag:(NSInteger) tag
{
	return (UIImageView *) [self viewWithTag:tag];
}

- (UITextField *) textFieldWithTag:(NSInteger)tag
{
    return (UITextField *) [self viewWithTag:tag];
}

- (UITextView *)  textViewWithTag:(NSInteger) tag
{
    return  (UITextView *) [self viewWithTag:tag];
}

- (void) setText:(NSString *) text toLabelWithTag:(NSInteger) tag
{
	UILabel *l = [self labelWithTag:tag];
	if(l)
		l.text = text;
}

- (void) settext:(NSString *)text toTextFieldWithTag:(NSInteger)tag
{
    UITextField *t = [self textFieldWithTag:tag];
    if (t) {
        t.text=text;
    }
}

- (void) settext:(NSString *)text toTextViewWithTag:(NSInteger) tag
{
    UITextView* t = [self textViewWithTag:tag];
    if (t) {
        t.text = text;
    }
}

- (void) setBorderWidth:(CGFloat) width color:(UIColor *) color
{
	[self.layer setBorderWidth:width];
	[self.layer setBorderColor:[color CGColor]];
}

- (void) makeRoundCornerShadowPanel
{
	[self setBorderWidth:1.f color:[UIColor lightGrayColor]];
	self.layer.cornerRadius = 5.f;
	self.layer.shadowOffset = CGSizeMake(2, 2);
	self.layer.shadowRadius = 5.f;
	self.layer.shadowOpacity = 0.6;
}

- (UIImage *) imageForViewAndLabels
{
    UIImage *result = nil;
    @try {
		UIGraphicsBeginImageContext(self.frame.size);
        for(UIView *v in self.subviews) {
            if([v isKindOfClass:[UILabel class]]) {
                UILabel *l = (UILabel *) v;
                [l.textColor set];
                [l.text drawInRect:l.frame withFont:l.font lineBreakMode:l.lineBreakMode alignment:l.textAlignment];
            }
        }
        result = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	} @catch (NSException *ex) {
        NSLog(@"Exception %@", ex.description);
	}
    return result;
}

- (void) setViewTintColor:(UIColor *) color
{
    if([self respondsToSelector:@selector(setTintColor:)]) {
        [self setTintColor:color];
    }
}

- (void) setViewTintAdjustmentMode:(UIViewTintAdjustmentMode) tintAdjustmentMode
{
    if([self respondsToSelector:@selector(setTintAdjustmentMode:)]) {
        [self setTintAdjustmentMode:tintAdjustmentMode];
    }
}


- (CATransition*) createWithDuration:(CFTimeInterval)duration withType:(NSString*)type andSubtype:(NSString*)subtype
{
    CATransition *animation=[CATransition animation];
    animation.duration=duration;
    animation.timingFunction=UIViewAnimationCurveEaseInOut;
    animation.type=type;
    animation.subtype=subtype;
    return animation;
}
@end
