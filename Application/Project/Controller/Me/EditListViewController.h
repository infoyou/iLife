
/*!
 @header EditListViewController.h
 @abstract 列表
 @author Adam
 @version 1.00 2014/07/08 Creation
 */

#import "BaseListViewController.h"

@interface EditListViewController : BaseListViewController

- (id)initWithParentVC:(UIViewController *)parentVC
                 title:(NSString *)title
              entrance:(id)entrance
         refreshAction:(SEL)refreshAction;

- (void)setShowArray:(NSMutableArray *)showArray valArray:(NSMutableArray *)valArray defaultShowName:(NSString *)defaultShowName contentType:(int)contentType;

@end
