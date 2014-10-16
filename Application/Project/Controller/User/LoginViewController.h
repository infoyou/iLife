
/*!
 @header LoginViewController.h
 @abstract 登录界面
 @author Adam
 @version 1.00 2014/03/12 Creation
 */

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@protocol CurrentLoginVCDelegate;

@interface LoginViewController : RootViewController
{
}

@property (nonatomic, assign) id <CurrentLoginVCDelegate> delegate;

/*!
 @method
 @abstract 初始化
 @discussion
 @param text MOC RootViewController
 @param error nil
 @result id
 */
- (id)initWithMOC:(NSManagedObjectContext *)MOC
         parentVC:(RootViewController *)pVC;

- (void)autoLogin;

@end

@protocol CurrentLoginVCDelegate <NSObject>

- (BOOL)loginSuccessfull:(LoginViewController *)currentVC;
- (void)closeSplash;

@end
