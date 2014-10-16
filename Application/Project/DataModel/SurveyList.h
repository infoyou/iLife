//
//  SurveyList.h
//  QiXin
//
//  Created by Adam on 14-6-24.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "GlobalConstants.h"
#import "CommonUtils.h"


@interface SurveyList : NSManagedObject

@property (nonatomic, retain) NSNumber * isMultiAnswer;
@property (nonatomic, retain) NSNumber * isPassed;
@property (nonatomic, retain) NSNumber * joinedCount;
@property (nonatomic, retain) NSNumber * passedCount;
@property (nonatomic, retain) NSNumber * passRate;
@property (nonatomic, retain) NSString * releaseTime;
@property (nonatomic, retain) NSString * endTime;
@property (nonatomic, retain) NSString * surface;
@property (nonatomic, retain) NSString * surfaceImage;
@property (nonatomic, retain) NSString * testId;
@property (nonatomic, retain) NSString * topic;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * isEnd;
@property (nonatomic, retain) NSNumber * status;

// web
@property (nonatomic, retain) NSString * webAnswer;
@property (nonatomic, retain) NSString * webResult;
@property (nonatomic, retain) NSNumber * webScore;

- (void)updateData:(NSDictionary *)dic;

@end
