//
//  HistoryOrderListViewController.h
//  Project
//
//  Created by Adam on 14-9-3.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseListViewController.h"
#import "HistoryOrderListCell.h"

@interface HistoryOrderListViewController : BaseListViewController

- (id)initWithMOC:(NSManagedObjectContext *)MOC
         parentVC:(RootViewController *)pVC;

@end

@interface OrderItem : NSObject
{}

@property (nonatomic, retain)NSString* orderId;
@property (nonatomic, retain)NSString* orderNo;
@property (nonatomic, retain)NSString* orderTime;
@property (nonatomic, retain)NSString* amount;
@property (nonatomic, retain)NSString* orderDetail;

@end