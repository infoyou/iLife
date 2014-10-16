//
//  CustomActionSheet.h
//  iLife
//
//  Created by hys on 14-9-17.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomActionSheet : UIActionSheet

@property(nonatomic,retain)UIView* contentView;
@property(nonatomic)BOOL adaptation;

-(id)initWithContentView:(UIView*)view;
- (void)dismissWithButtonIndex:(NSInteger)index animated:(BOOL)animated;

@end
