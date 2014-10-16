//
//  SurveyItem.h
//  QiXin
//
//  Created by Adam on 14-6-24.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "GlobalConstants.h"
#import "CommonUtils.h"

@interface SurveyItem : NSManagedObject

@property (nonatomic, retain) NSNumber * answer;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * itemId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * questionId;
@property (nonatomic, retain) NSNumber * isSelect;
@property (nonatomic, retain) NSString * mediaUrl;
@property (nonatomic, retain) NSNumber * mediaType;

- (void)updateData:(NSDictionary *)dic isFirst:(BOOL)isFirst questionIdStr:(NSString*)questionIdStr;

@end
