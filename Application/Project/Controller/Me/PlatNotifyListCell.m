//
//  PlatNotifyListCell.m
//  Project
//
//  Created by Adam on 14-9-3.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import "PlatNotifyListCell.h"
#import "InformationDefault.h"
#import <QuartzCore/QuartzCore.h>
#import "BaseConstants.h"
#import "UIColor+Expanded.h"

typedef enum {
    
    ADDRESS_CELL_TITLE_TAG = 100,
    ADDRESS_CELL_DATE_TAG,
    ADDRESS_CELL_DESC_TAG
    
} PlatNotifyListType;

@implementation PlatNotifyListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setCellControl];
    }
    return self;
}

- (void)setCellControl
{

    float xGap = 10.f;
    float yGap = 17.f;
    
    CGRect userRect = CGRectMake(xGap, yGap, 215, 15);
    UILabel *userLbl =[InformationDefault createLblWithFrame:userRect withTextColor:HEX_COLOR(@"0x333333") withFont:[UIFont systemFontOfSize:16] withTag:ADDRESS_CELL_TITLE_TAG];
    [self addSubview:userLbl];
    
    CGRect mobileRect = CGRectMake(235, yGap-2, 85, 15);
    UILabel *mobileLbl =[InformationDefault createLblWithFrame:mobileRect withTextColor:HEX_COLOR(@"0xcccccc") withFont:[UIFont systemFontOfSize:15] withTag:ADDRESS_CELL_DATE_TAG];
    [self addSubview:mobileLbl];
    
    CGRect nameRect = CGRectMake(xGap, 45, 286.5f, 15);
    UILabel *nameLbl =[InformationDefault createLblWithFrame:nameRect withTextColor:HEX_COLOR(@"0x999999") withFont:[UIFont systemFontOfSize:14] withTag:ADDRESS_CELL_DESC_TAG];
    nameLbl.numberOfLines = 1;
    [self addSubview:nameLbl];
    
}

- (void)updataCellData:(MessageItem *)messageItem
{
    UILabel *userLbl =  (UILabel *)[self viewWithTag:ADDRESS_CELL_TITLE_TAG];
    UILabel *mobileLbl = (UILabel *)[self viewWithTag:ADDRESS_CELL_DATE_TAG];
    UILabel *nameLbl =   (UILabel *)[self viewWithTag:ADDRESS_CELL_DESC_TAG];
    
    [userLbl  setText:messageItem.title];
    [mobileLbl setText:[CommonMethod getYearTimeAutoMatchFormat:messageItem.messageTime]];
    [nameLbl   setText:messageItem.body];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
