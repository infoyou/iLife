
/*!
 @header VisitingFarmsViewController.h
 @abstract 资讯界面
 @author Adam
 @version 1.00 2014/03/12 Creation
 */

#import "BaseListViewController.h"

#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

@interface VisitingFarmsViewController : BaseListViewController {
}

/*!
 @method
 @abstract 初始化
 @discussion
 @param text MOC RootViewController
 @param error nil
 @result id
 */
- (id)initWithMOC:(NSManagedObjectContext *)MOC
       viewHeight:(CGFloat)viewHeight
  homeContainerVC:(RootViewController *)homeContainerVC;

@end
