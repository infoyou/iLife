
/*!
 @header OrderDetailViewController.h
 @abstract 订单列表界面
 @author Adam
 @version 1.00 2014/9/9 Creation
 */

#import "BaseListViewController.h"

@interface OrderDetailViewController : BaseListViewController {
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

/*
 "OrderID": "906E50F7-4EF2-4B6C-A3B6-712698EE5B08",
 "OrderNo": "10031001",
 "Amount": 300,
 */

@interface OrderTotal : NSObject
{}

@property (nonatomic, retain)NSString* orderId;
@property (nonatomic, retain)NSString* orderCanPay;
@property (nonatomic, retain)NSString* orderCanCancel;
@property (nonatomic, retain)NSString* orderNo;
@property (nonatomic, retain)NSString* totalAmount;
@property (nonatomic, retain)NSMutableArray* groupArray;
@end

/*
 "OrderDetailID": "5221E3A0-825B-46AF-774D-4924E67E8312",
 "ItemID": "717A0F4A-F88B-4106-ABBA-FB1EA9D2FF2D",
 "SKUID": "8A490C3E-FC0C-1F56-FFDC-46798A2FBFD5",
 "ItemName": "白菜",
 "PurchaseWeight": 5000,
 "RealWeight": 4999,
 "RealAmount": 20,
 "Status": 1
 */

@interface OrderDetail : NSObject
{}

@property (nonatomic, retain)NSString* orderDetailId;
@property (nonatomic, retain)NSString* itemId;
@property (nonatomic, retain)NSString* skuId;
@property (nonatomic, retain)NSString* itemName;
@property (nonatomic, retain)NSString* itemUnit;
@property (nonatomic, retain)NSString* purchaseWeight;
@property (nonatomic, retain)NSString* realWeight;
@property (nonatomic, retain)NSString* realAmount;
@property (nonatomic, retain)NSString* orderStatus;
@property (nonatomic, assign)BOOL isFirst;

@end

/*
 "OrderID": "3675A113-5C61-5C0B-06ED-74762405295D",
 "OrderTime": "2014-09-24",
 "OrderNo": "104007001",
 */
@interface OrderCompletedTotal : NSObject
{}

@property (nonatomic, retain)NSString* orderId;
@property (nonatomic, retain)NSString* orderNo;
@property (nonatomic, retain)NSString* orderTime;
@property (nonatomic, retain)NSMutableArray* detailArray;
@end

/*
 "DeliverOrderID": "B326E4D8-172C-3B7B-AD11-5B065787B488",
 "ItemCategoryId": "AE9E8578-0B28-775E-971A-DF822FC4B395",
 "ItemCategoryName": "蔬菜",
 "UnitID": "2875CEDE-46C6-F4B3-B7EF-3EC9BC7116B3",
 "UnitName": "菜场一号",
 "GoodCount": 10,
 "NormalCount": 25,
 "BadCount": 5
 */
@interface OrderCompletedDetail : NSObject
{}

@property (nonatomic, retain)NSString* deliverOrderID;
@property (nonatomic, retain)NSString* itemCategoryId;
@property (nonatomic, retain)NSString* itemCategoryName;
@property (nonatomic, retain)NSString* unitID;
@property (nonatomic, retain)NSString* unitName;
@property (nonatomic, retain)NSString* goodCount;
@property (nonatomic, retain)NSString* normalCount;
@property (nonatomic, retain)NSString* badCount;
@property (nonatomic, retain)NSString* evaluationTypeID;
@property (nonatomic, retain)NSString* itemCount;

@end
