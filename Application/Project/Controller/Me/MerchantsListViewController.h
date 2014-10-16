//
//  MerchantsListViewController.h
//  Project
//
//  Created by Adam on 14-9-3.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseListViewController.h"
#import "MerchantsListCell.h"

@interface MerchantsListViewController : BaseListViewController

- (id)initWithMOC:(NSManagedObjectContext *)MOC
         parentVC:(RootViewController *)pVC;

@end

@interface MerchantItem : NSObject
{}

//                "UnitID": "B806D5A9-4EB8-5EAB-A91E-C82300CBD1B8",
//                "ItemCategoryID": "C650D629-0335-25CC-E730-3B1ADB4F59CA",
//                "Name": "Alan",
//                "ItemCategoryName": "蔬菜"

@property (nonatomic, retain)NSString* merchantId;
@property (nonatomic, retain)NSString* merchantName;
@property (nonatomic, retain)NSString* merchantUserName;

@end