//
//  MerchantsListCell.h
//  Project
//
//  Created by Adam on 14-9-3.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewCell.h"
#import "MerchantsListViewController.h"

@class MerchantItem;

#define MERCHANTS_CELL_HEIGHT 35.0f

@interface MerchantsListCell : BaseTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

- (void)updataCellData:(MerchantItem *)merchantItem;

@end
