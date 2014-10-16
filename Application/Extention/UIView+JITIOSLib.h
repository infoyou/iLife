//
//  UIView+CPOS.h
//  cpos
//
//  Created by user on 13-3-1.
//  Copyright (c) 2013年 jit. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIView (JITIOSLib)
- (CGFloat) frameHeight;
- (CGFloat) frameWidth;
- (CGPoint) leftBottomPoint;

- (void) setFrameHeight:(CGFloat) height;
- (void) stratchUpBy:(CGFloat) height;
- (void) stratchLeftBy:(CGFloat) width;
- (void) setFrameOriginY:(CGFloat) y animated:(BOOL) animated;
- (void) setFrameOriginX:(CGFloat) x;
- (void) setFrameOriginX:(CGFloat) x animated:(BOOL) animated;
- (void) setFrameSize:(CGSize) size;
- (void) setFrameOrigin:(CGPoint) point;
- (void) removeAllSubviews;
- (void) widthToFit;

- (UILabel *) labelWithTag:(NSInteger) tag;
- (UIButton *) buttonWithTag:(NSInteger) tag;
- (UIImageView *) imageViewWithTag:(NSInteger) tag;
- (UITextField *) textFieldWithTag:(NSInteger) tag;
- (UITextView *) textViewWithTag:(NSInteger) tag;
- (void) setText:(NSString *) text toLabelWithTag:(NSInteger) tag;
- (void) settext:(NSString *) text toTextFieldWithTag:(NSInteger) tag;
- (void) settext:(NSString *) text toTextViewWithTag:(NSInteger) tag;
- (void) setBorderWidth:(CGFloat) width color:(UIColor *) color;
- (void) makeRoundCornerShadowPanel;
- (UIImage *) imageForViewAndLabels;
- (void) setViewTintColor:(UIColor *) color;
- (void) setViewTintAdjustmentMode:(UIViewTintAdjustmentMode) tintAdjustmentMode;
- (CATransition*) createWithDuration:(CFTimeInterval)duration withType:(NSString*)type andSubtype:(NSString*)subtype;  //动画封装
@end
