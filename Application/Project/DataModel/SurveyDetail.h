//
//  SurveyDetail.h
//  QiXin
//
//  Created by Adam on 14-6-24.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "GlobalConstants.h"
#import "CommonUtils.h"

@interface SurveyDetail : NSManagedObject

@property (nonatomic, retain) NSString * questionSupId;
@property (nonatomic, retain) NSString * answer;
@property (nonatomic, retain) NSNumber * isMultiOption;
@property (nonatomic, retain) NSNumber * isSubjective;
@property (nonatomic, retain) NSNumber * questionIndex;
@property (nonatomic, retain) NSNumber * questionType;
@property (nonatomic, retain) NSString * questionId;
@property (nonatomic, retain) NSString * problem;
@property (nonatomic, retain) NSString * ugcStr;

- (void)updateData:(NSDictionary *)dic isFirst:(BOOL)isFirst;

@end
