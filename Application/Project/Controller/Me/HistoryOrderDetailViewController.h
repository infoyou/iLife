
/*!
 @header HistoryOrderDetailViewController.h
 @abstract 订单列表界面
 @author Adam
 @version 1.00 2014/9/9 Creation
 */

#import "BaseListViewController.h"
#import "HistoryOrderListViewController.h"

@class OrderItem;

@interface HistoryOrderDetailViewController : BaseListViewController {
}

/*!
 @method
 @abstract 初始化
 @discussion
 @param text MOC RootViewController
 @param error nil
 @result id
 */
- (id)initWithMOC:(NSManagedObjectContext*)viewMOC orderId:(NSString *)orderId;

@end

/*
 "OrderId": "D20C3D8A-D1DA-5223-0EC6-99EC11EB21F6",
 "OrderNo": "100314487775",
 "OrderTime": "2014-9-19",
 "Amount": "50.6",
 */

@interface HistoryOrderTotal : NSObject
{}

@property (nonatomic, retain)NSString* orderId;
@property (nonatomic, retain)NSString* orderNo;
@property (nonatomic, retain)NSString* orderTime;
@property (nonatomic, retain)NSString* totalAmount;
@property (nonatomic, retain)NSMutableArray* detailArray;
@end

/*
 "ItemName": "白菜",
 "Weight": "500",
 "RealWeight": "520",
 "ItemAmount": "20"
 */

@interface HistoryOrderDetail : NSObject
{}

@property (nonatomic, retain)NSString* itemName;
@property (nonatomic, retain)NSString* weight;
@property (nonatomic, retain)NSString* realWeight;
@property (nonatomic, retain)NSString* itemAmount;
@property (nonatomic, retain)NSString* status;

@end
