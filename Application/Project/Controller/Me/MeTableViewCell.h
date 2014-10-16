//
//  MeTableViewCell.h
//  Project
//
//  Created by Vshare on 14-4-16.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InformationDefault.h"
#import "GlobalConstants.h"
#import "WXWTextPool.h"

#define kMeTypeCellHeight  49.0f

@interface MeTableViewCell : UITableViewCell

- (void)setCellText:(NSString *)contentStr;
- (void)setCellTextVal:(NSString *)contentStr;
- (void)setCellIcon:(UIImage *)iconImg;
- (void)setBadgeData:(NSString *)badge isHidden:(BOOL)hidden;

@end
