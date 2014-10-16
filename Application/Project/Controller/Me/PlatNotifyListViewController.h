//
//  PlatNotifyListViewController.h
//  Project
//
//  Created by Adam on 14-9-3.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseListViewController.h"
#import "PlatNotifyListCell.h"

@interface PlatNotifyListViewController : BaseListViewController

- (id)initWithMOC:(NSManagedObjectContext *)MOC
         parentVC:(RootViewController *)pVC;

@end

@interface MessageItem : NSObject
{}

//"MessageID": "2B1993B5-7DF9-3AE8-1469-EB351F2698FA",
//"MessageTime": "2014-9-19 18:15:00",
//"Title": "买家Alan对您点赞",
//"Body": "您有新的系统消息"

@property (nonatomic, retain)NSString* messageID;
@property (nonatomic, retain)NSString* messageTime;
@property (nonatomic, retain)NSString* title;
@property (nonatomic, retain)NSString* body;

@end
