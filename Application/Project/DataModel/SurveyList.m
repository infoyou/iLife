//
//  SurveyList.m
//  QiXin
//
//  Created by Adam on 14-6-24.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import "SurveyList.h"


@implementation SurveyList

@dynamic isMultiAnswer;
@dynamic isPassed;
@dynamic joinedCount;
@dynamic passedCount;
@dynamic passRate;
@dynamic releaseTime;
@dynamic surface;
@dynamic surfaceImage;
@dynamic testId;
@dynamic topic;
@dynamic type;
@dynamic endTime;
@dynamic status;
@dynamic isEnd;

/*
 
 SurveyTestId	String 	考试ID
 QuestionnaireName	String	标题
 Type	Int	类型(Test/Survey）
 Survey0 Test1
 QuestionnaireDesc	String	考试简介
 SurfaceImage	String	封面图片
 Redoable	Int	是否允许重做
 0可以重做 1不可重做
 JoinNum	Int	参加人数
 PassNum	Int	通过人数
 PassScore	Int	过关分数
 TestStatus	Int	-1 未考 0未通过 1通过
 ReleaseTime	DateTime	发布时间
 EndTime	DateTime	截止时间
 IsEnd	Int	是否已经截止
 0未截止 1截止
 
 */

- (void)updateData:(NSDictionary *)dic
{
    self.testId = STRING_VALUE_FROM_DIC(dic, @"SurveyTestId");
    self.surfaceImage =  STRING_VALUE_FROM_DIC(dic, @"SurfaceImage");
    self.releaseTime =  STRING_VALUE_FROM_DIC(dic, @"ReleaseTime");
    
    NSString* strEndTime = STRING_VALUE_FROM_DIC(dic, @"EndTime");
    
    if ([strEndTime rangeOfString:@"T"].length > 0) {
        
        strEndTime = [strEndTime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
        self.endTime = [strEndTime substringToIndex:19];
    } else {
        self.endTime = strEndTime;
    }
    
    self.topic = STRING_VALUE_FROM_DIC(dic, @"QuestionnaireName");
    self.type =  @(INT_VALUE_FROM_DIC(dic, @"Type"));
    self.isEnd =  @(INT_VALUE_FROM_DIC(dic, @"IsEnd"));
    self.status =  @(INT_VALUE_FROM_DIC(dic, @"TestStatus"));
    self.isMultiAnswer = @(INT_VALUE_FROM_DIC(dic, @"Redoable"));
    self.joinedCount = @(INT_VALUE_FROM_DIC(dic, @"JoinNum"));
    
    self.surface =  STRING_VALUE_FROM_DIC(dic, @"surface");
    self.isPassed = @(INT_VALUE_FROM_DIC(dic, @"is_passed"));
    self.passRate =  @(INT_VALUE_FROM_DIC(dic, @"pass_rate"));
    self.passedCount =  @(INT_VALUE_FROM_DIC(dic, @"passed_count"));
}

@end
