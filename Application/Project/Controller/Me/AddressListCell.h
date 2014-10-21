//
//  AddressListCell.h
//  Project
//
//  Created by Adam on 14-9-3.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewCell.h"
#import "AddressListController.h"

@class AddressItem;

@protocol AddressClickDelegate;

#define ADDRESS_CELL_HEIGHT 76.0f

@interface AddressListCell : BaseTableViewCell

@property (nonatomic, assign) id<AddressClickDelegate> delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier addressClickDelegate:(id<AddressClickDelegate>)addressClickDelegate;

- (void)updataCellData:(AddressItem *)addressItem showButFlag:(BOOL)showButFlag;

@end

@protocol AddressClickDelegate <NSObject>

- (void)clickAddressBtn:(id)Object;

- (void)delAddressBtn:(id)Object;

@end