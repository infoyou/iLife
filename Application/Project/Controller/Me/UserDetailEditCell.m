
#import "UserDetailEditCell.h"

enum UserDetailEdit_Cell_Type
{
    MeCell_Title_Type = 10,
    MeCell_Value_Type,
};

@implementation UserDetailEditCell

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
//    titleLbl.backgroundColor = [UIColor redColor];
    return titleLbl;
}

- (UILabel *)createTextView
{
    CGRect badgeRect = CGRectMake(125, 22, 165, 19);
    UILabel *badgeLbl = [InformationDefault createLblWithFrame:badgeRect withTextColor:[UIColor colorWithHexString:@"0x999999"] withFont:FONT_SYSTEM_SIZE(16) withTag:MeCell_Value_Type];
    [badgeLbl setTextAlignment:NSTextAlignmentRight];
//    [badgeLbl setBackgroundColor:[UIColor blueColor]];
    return badgeLbl;
}

- (void)setLabelData:(NSString *)contentStr
{
    UILabel *titleLbl = (UILabel *)[self viewWithTag:MeCell_Title_Type];
    [titleLbl setText:[NSString stringWithFormat:@"%@",contentStr]];
}

- (void)setTextData:(NSString *)badge
{

    UILabel *badgeLbl = (UILabel *)[self viewWithTag:MeCell_Value_Type];
    [badgeLbl setText:[NSString stringWithFormat:@"%@", badge]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

@end
