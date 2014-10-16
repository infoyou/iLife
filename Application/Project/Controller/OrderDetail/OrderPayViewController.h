/*!
 @header OrderPayViewController.h
 @abstract 订单列表界面
 @author Adam
 @version 1.00 2014/9/9 Creation
 */

#import "BaseListViewController.h"

@interface OrderPayViewController : BaseListViewController {
}

/*!
 @method
 @abstract 初始化
 @discussion
 @param text MOC RootViewController
 @param error nil
 @result id
 */
- (id)initWithMOC:(NSManagedObjectContext *)MOC totalAmount:(NSString *)totalAmount;

- (void)updateOrderAmount:(NSString *)totalAmount;

- (IBAction)btnClick:(id)send;

@end