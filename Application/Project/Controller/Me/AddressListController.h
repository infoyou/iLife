//
//  AddressListController.h
//  Project
//
//  Created by Adam on 14-9-3.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseListViewController.h"
#import "AddressListCell.h"

@interface AddressListController : BaseListViewController

- (id)initWithMOC:(NSManagedObjectContext *)MOC
         parentVC:(RootViewController *)pVC;

@end

/*
 "DeliveryAddressID": "5A737C4B-4603-C62B-5E31-7ED265D5CC11",
 "Receiver": "Alan",
 "MobileNumber": "18645258759",
 "City": "上海",
 "Area": "021",
 "DetailedAddress": "上海市静安区延平路121号",
 "IsDefault": "1"
 */

@interface AddressItem : NSObject
{}

@property (nonatomic, retain)NSString* addressId;
@property (nonatomic, retain)NSString* addressReceiver;
@property (nonatomic, retain)NSString* receiverMobile;
@property (nonatomic, retain)NSString* addressCity;
@property (nonatomic, retain)NSString* addressArea;
@property (nonatomic, retain)NSString* addressName;
@property (nonatomic, retain)NSString* addressIsDefault;

@end