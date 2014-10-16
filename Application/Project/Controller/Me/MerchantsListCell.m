//
//  MerchantsListCell.m
//  Project
//
//  Created by Adam on 14-9-3.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//


#import "MerchantsListCell.h"
#import "InformationDefault.h"
#import <QuartzCore/QuartzCore.h>
#import "BaseConstants.h"
#import "UIColor+Expanded.h"

typedef enum{
    
    ADDRESS_CELL_USER_TAG = 100,
    ADDRESS_CELL_MOBILE_TAG
    
} AddressListType;

@implementation MerchantsListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self  setCellControl];
    }
    return self;
}

- (void)setCellControl
{

    float xGap = 10.f;
    float yGap = 10.f;
    
    CGRect userRect = CGRectMake(xGap, yGap, 61, 15);
    UILabel *userLbl =[InformationDefault createLblWithFrame:userRect withTextColor:HEX_COLOR(@"0x82bf23") withFont:[UIFont systemFontOfSize:15] withTag:ADDRESS_CELL_USER_TAG];
    [self addSubview:userLbl];
    
    CGRect mobileRect = CGRectMake(82, yGap, 231, 15);
    UILabel *mobileLbl =[InformationDefault createLblWithFrame:mobileRect withTextColor:HEX_COLOR(@"0x666666") withFont:[UIFont systemFontOfSize:15] withTag:ADDRESS_CELL_MOBILE_TAG];
    [self addSubview:mobileLbl];
    
}

- (void)updataCellData:(MerchantItem *)merchantItem
{
    UILabel *userLbl =  (UILabel *)[self viewWithTag:ADDRESS_CELL_USER_TAG];
    UILabel *mobileLbl = (UILabel *)[self viewWithTag:ADDRESS_CELL_MOBILE_TAG];
    
    [userLbl  setText:merchantItem.merchantName];
    [mobileLbl setText:merchantItem.merchantUserName];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
