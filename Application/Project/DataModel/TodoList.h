//
//  TodoList.h
//  QiXin
//
//  Created by Adam on 14-6-18.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "GlobalConstants.h"
#import "CommonUtils.h"

@interface TodoList : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * todoId;
@property (nonatomic, retain) NSString * createTime;
@property (nonatomic, retain) NSNumber * read;
@property (nonatomic, retain) NSString * reason;
@property (nonatomic, retain) NSString * courseId;
@property (nonatomic, retain) NSString * type;

- (void)updateData:(NSDictionary *)dic;

@end
