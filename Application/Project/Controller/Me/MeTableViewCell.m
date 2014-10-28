
#import "MeTableViewCell.h"

enum MeType_Cell_Type
{
    MeCell_Title_Type = 10,
    MeCell_Value_Type,
    MeCell_Icon_Type,
    MeCell_Icon_Mark_Type,
    MeCell_Badge_Type,
};

@implementation MeTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self addSubview:[self createTypeLbl]];
        [self addSubview:[self createIconImg]];
        [self addSubview:[self createIconMarkImg]];
        [self addSubview:[self createTextValView]];
    }
    return self;
}

- (UILabel *)createTypeLbl
{
    float lblHeight = 18.0f;
    float lblWidth = 100.0f;
    float gap = 45.f;
    
    CGRect rect = CGRectMake(gap, (kMeTypeCellHeight - lblHeight)/2 - 1, lblWidth, lblHeight);
    UILabel *titleLbl = [InformationDefault createLblWithFrame:rect withTextColor:[UIColor blackColor] withFont:Arial_FONT(16) withTag:MeCell_Title_Type];
    return titleLbl;
}

- (UIImageView *)createIconImg
{
    UIImageView *iconImg = [InformationDefault createImgViewWithFrame:CGRectZero withImage:nil withColor:[UIColor clearColor] withTag:MeCell_Icon_Type];
    
    return iconImg;
}

- (UIImageView *)createIconMarkImg
{
    UIImageView *iconImg = [InformationDefault createImgViewWithFrame:CGRectZero withImage:nil withColor:[UIColor clearColor] withTag:MeCell_Icon_Mark_Type];
    
    return iconImg;
}

- (UILabel *)createTextValView
{
    CGRect badgeRect = CGRectMake(108.5, 19.5, 175, 17);
    UILabel *badgeLbl = [InformationDefault createLblWithFrame:badgeRect withTextColor:[UIColor colorWithHexString:@"0x999999"] withFont:FONT_SYSTEM_SIZE(16) withTag:MeCell_Value_Type];
    [badgeLbl setTextAlignment:NSTextAlignmentRight];
    return badgeLbl;
}

- (void)setCellText:(NSString *)contentStr
{
    UILabel *titleLbl = (UILabel *)[self viewWithTag:MeCell_Title_Type];
    [titleLbl setText:[NSString stringWithFormat:@"%@",contentStr]];
    
//    if ([contentStr isEqualToString:LocaleStringForKey(@"平台通知", nil)]) {
//        [self setCellMarkIcon];
//    }
}

- (void)setCellTextVal:(NSString *)valStr
{
    UILabel *badgeLbl = (UILabel *)[self viewWithTag:MeCell_Value_Type];
    [badgeLbl setText:[NSString stringWithFormat:@"%@", valStr]];
}

- (void)setCellIcon:(UIImage *)iconImg
{
    float xPoint = 20.f;
    UIImageView *img = (UIImageView *)[self viewWithTag:MeCell_Icon_Type];
    [img setBounds:CGRectMake(0, 0, 18, 18)];
    [img setCenter:CGPointMake(xPoint, kMeTypeCellHeight/2)];
    [img setImage:iconImg];
}

- (void)setCellMarkIcon
{
    // user mark
    UIImageView *img = (UIImageView *)[self viewWithTag:MeCell_Icon_Mark_Type];
    [img setBounds:CGRectMake(0, 0, 7, 7)];
    [img setCenter:CGPointMake(34.f, 12)];
    [img setImage:[UIImage imageNamed:@"me_mark.png"]];
    
    [self addSubview:img];
}

- (void)setBadgeData:(NSString *)badge isHidden:(BOOL)hidden
{
    UILabel *badgeLbl = (UILabel *)[self viewWithTag:MeCell_Value_Type];
    UIImageView *badgeview = (UIImageView *)[self viewWithTag:MeCell_Badge_Type];
    
    if (!hidden && [badge intValue] > 0)
    {
        [badgeview setAlpha:1.0];
        [badgeview setHidden:NO];
        [badgeLbl setText:[NSString stringWithFormat:@"%@",badge]];
    } else {
        [badgeview setAlpha:0.0];
        [badgeview setHidden:YES];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
