//
//  UserDetailEditCell.h
//  Project
//
//  Created by Vshare on 14-4-16.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InformationDefault.h"
#import "UIColor+expanded.h"
#import "BaseConstants.h"

#define kUserDetailCellHeight  56.0f

@interface UserDetailEditCell : UITableViewCell

- (void)setLabelData:(NSString *)contentStr;
- (void)setTextData:(NSString *)badge;

@end
