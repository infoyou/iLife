
#import "UserDetailCell.h"

enum MeType_Cell_Type
{
    MeCell_Title_Type = 10,
    MeCell_Value_Type,
};

@implementation UserDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        [self addSubview:[self createLabelView]];
        [self addSubview:[self createTextView]];
    }
    return self;
}

- (UILabel *)createLabelView
{
    CGRect rect = CGRectMake(15, 23, 110, 19);
    UILabel *titleLbl = [InformationDefault createLblWithFrame:rect withTextColor:[UIColor blackColor] withFont:FONT_SYSTEM_SIZE(16) withTag:MeCell_Title_Type];
    return titleLbl;
}

- (UILabel *)createTextView
{
    CGRect badgeRect = CGRectMake(125, 23, 175, 19);
    UILabel *badgeLbl = [InformationDefault createLblWithFrame:badgeRect withTextColor:[UIColor colorWithHexString:@"0x999999"] withFont:FONT_SYSTEM_SIZE(16) withTag:MeCell_Value_Type];
    [badgeLbl setTextAlignment:NSTextAlignmentRight];
//    [badgeLbl setBackgroundColor:[UIColor redColor]];
    return badgeLbl;
}

- (void)setLabelData:(NSString *)contentStr
{
    UILabel *titleLbl = (UILabel *)[self viewWithTag:MeCell_Title_Type];
    [titleLbl setText:[NSString stringWithFormat:@"%@",contentStr]];
}

- (void)setTextData:(NSString *)valStr
{

    UILabel *badgeLbl = (UILabel *)[self viewWithTag:MeCell_Value_Type];
    [badgeLbl setText:[NSString stringWithFormat:@"%@", valStr]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

@end
