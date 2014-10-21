//
//  AddressListCell.m
//  Project
//
//  Created by Adam on 14-9-3.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//


#import "AddressListCell.h"
#import "InformationDefault.h"
#import <QuartzCore/QuartzCore.h>
#import "BaseConstants.h"
#import "UIColor+Expanded.h"

typedef enum{
    
    ADDRESS_CELL_USER_TAG = 100,
    ADDRESS_CELL_MOBILE_TAG,
    ADDRESS_CELL_NAME_TAG,
    
    ADDRESS_CELL_ACTION_TAG,
    ADDRESS_CELL_BTN_TAG,
    ADDRESS_CELL_DELBTN_TAG
} AddressListType;

@implementation AddressListCell

@synthesize delegate = _delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier addressClickDelegate:(id<AddressClickDelegate>)addressClickDelegate
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self  setCellControl];
        self.delegate = addressClickDelegate;
    }
    return self;
}

- (void)setCellControl
{

    float xGap = 10.f;
    float yGap = 17.f;
    
    CGRect userRect = CGRectMake(xGap, yGap, 70, 15);
    UILabel *userLbl =[InformationDefault createLblWithFrame:userRect withTextColor:[UIColor blackColor] withFont:[UIFont systemFontOfSize:15] withTag:ADDRESS_CELL_USER_TAG];
    [self addSubview:userLbl];
    
    CGRect mobileRect = CGRectMake(88, yGap, 150, 15);
    UILabel *mobileLbl =[InformationDefault createLblWithFrame:mobileRect withTextColor:[UIColor blackColor] withFont:[UIFont systemFontOfSize:15] withTag:ADDRESS_CELL_MOBILE_TAG];
    [self addSubview:mobileLbl];
    
    CGRect nameRect = CGRectMake(xGap, 44, 233, 15);
    UILabel *nameLbl =[InformationDefault createLblWithFrame:nameRect withTextColor:[UIColor blackColor] withFont:[UIFont systemFontOfSize:15] withTag:ADDRESS_CELL_NAME_TAG];
    [self addSubview:nameLbl];
    
    CGRect actionRect = CGRectMake(279, 32.0, 30, 15);
    UILabel *actionLbl = [InformationDefault createLblWithFrame:actionRect withTextColor:[UIColor colorWithHexString:@"0x82bf24"] withFont:[UIFont systemFontOfSize:15] withTag:ADDRESS_CELL_ACTION_TAG];
    [self addSubview:actionLbl];
    
    UIButton *defaultButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [defaultButton setBackgroundColor:[UIColor colorWithHexString:@"0x82bf24"]];
//    [defaultButton setBackgroundImage:[CommonMethod createImageWithColor:[UIColor colorWithHexString:@"0x333333"]] forState:UIControlStateNormal];
    [defaultButton addTarget:self action:@selector(doDefaultButton:) forControlEvents:UIControlEventTouchUpInside];
    defaultButton.tag = ADDRESS_CELL_BTN_TAG;
    defaultButton.frame = CGRectMake(242, 10, 68, 25);
    [defaultButton setTitleColor:HEX_COLOR(@"0xffffff") forState:UIControlStateNormal];
    defaultButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [defaultButton setTitle:LocaleStringForKey(@"设为默认", nil) forState:UIControlStateNormal];
    [defaultButton.layer setBorderWidth:1.0];
    [defaultButton.layer setBorderColor:HEX_COLOR(@"0x82bf24")];
    [defaultButton.layer setCornerRadius:3];
    [defaultButton.layer setMasksToBounds:YES];
    [self addSubview:defaultButton];
    
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteButton setBackgroundColor:[UIColor colorWithHexString:@"0x82bf24"]];
    [deleteButton addTarget:self action:@selector(delAddressButton:) forControlEvents:UIControlEventTouchUpInside];
    deleteButton.tag = ADDRESS_CELL_DELBTN_TAG;
    deleteButton.frame = CGRectMake(242, 40, 68, 25);
    [deleteButton setTitleColor:HEX_COLOR(@"0xffffff") forState:UIControlStateNormal];
    deleteButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [deleteButton setTitle:LocaleStringForKey(@"删除地址", nil) forState:UIControlStateNormal];
    [deleteButton.layer setBorderWidth:1.0];
    [deleteButton.layer setBorderColor:HEX_COLOR(@"0x82bf24")];
    [deleteButton.layer setCornerRadius:3];
    [deleteButton.layer setMasksToBounds:YES];
    [self addSubview:deleteButton];
}

- (void)updataCellData:(AddressItem *)addressItem showButFlag:(BOOL)showButFlag
{
    UILabel *userLbl =  (UILabel *)[self viewWithTag:ADDRESS_CELL_USER_TAG];
    UILabel *mobileLbl = (UILabel *)[self viewWithTag:ADDRESS_CELL_MOBILE_TAG];
    UILabel *nameLbl =   (UILabel *)[self viewWithTag:ADDRESS_CELL_NAME_TAG];
    UILabel *actionLbl =  (UILabel *)[self viewWithTag:ADDRESS_CELL_ACTION_TAG];
    UIButton *userButton =  (UIButton *)[self viewWithTag:ADDRESS_CELL_BTN_TAG];
    UIButton *delButton = (UIButton *)[self viewWithTag:ADDRESS_CELL_DELBTN_TAG];
    
    [userLbl  setText:addressItem.addressReceiver];
    [mobileLbl setText:addressItem.receiverMobile];
    [nameLbl   setText:addressItem.addressName];
    
    if (!showButFlag) {
        delButton.hidden = YES;
        userButton.hidden = YES;
        [actionLbl setText:@"默认"];
    } else {
        delButton.hidden = NO;
        userButton.hidden = NO;
        [actionLbl setText:@""];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)doDefaultButton:(id)action
{
    [self.delegate clickAddressBtn:self];
}

- (void)delAddressButton:(UIButton*)sender
{
    [self.delegate delAddressBtn:self];
}
@end
