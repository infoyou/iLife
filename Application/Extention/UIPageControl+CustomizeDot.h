//
//  UIPageControl+CustomizeDot.h
//  Project
//
//  Created by MobGuang on 13-1-30.
//
//

#import <UIKit/UIKit.h>

@interface UIPageControl (CustomizeDot)

- (void)setCurrentSelectedPage:(NSInteger)page;

@property (nonatomic, assign) NSInteger currentSelectedPage;

@end
