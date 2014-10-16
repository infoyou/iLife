//
//  ShoppingTimeViewController.h
//  iLife
//
//  Created by hys on 14-9-25.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import "BaseListViewController.h"

@interface ShoppingTimeViewController : BaseListViewController
@property(nonatomic, retain)HomeContainerViewController* homeVC;
@property(nonatomic, retain)NSMutableArray* foodParam;
@property(nonatomic)float totalPrice;

@end
