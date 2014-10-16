//
//  PlatNotifyListCell.h
//  Project
//
//  Created by Adam on 14-9-3.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewCell.h"

#import "PlatNotifyListViewController.h"

@class MessageItem;

#define PLAT_NOTIFY_CELL_HEIGHT 68.0f

@interface PlatNotifyListCell : BaseTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

- (void)updataCellData:(MessageItem *)messageItem;

@end
