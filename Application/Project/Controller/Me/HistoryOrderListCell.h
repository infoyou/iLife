//
//  HistoryOrderListCell.h
//  Project
//
//  Created by Adam on 14-9-3.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewCell.h"
#import "HistoryOrderListViewController.h"

@class OrderItem;

#define HISTORY_ORDER_CELL_HEIGHT 53.0f

@interface HistoryOrderListCell : BaseTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

- (void)updataCellData:(OrderItem *)orderItem;

@end
