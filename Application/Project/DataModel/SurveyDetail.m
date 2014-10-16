//
//  SurveyDetail.m
//  QiXin
//
//  Created by Adam on 14-6-24.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import "SurveyDetail.h"
#import "AppManager.h"

@implementation SurveyDetail

@dynamic questionSupId;
@dynamic answer;
@dynamic isMultiOption;
@dynamic isSubjective;
@dynamic questionType;
@dynamic questionId;
@dynamic problem;
@dynamic questionIndex;

//"answer": "A",
//"id": 987,
//"is_multi_option": false,
//"problem": "What is Shopper Psychology 2? (Choose only one)",
//"question_type": "option",
//"subjective": false
- (void)updateData:(NSDictionary *)dic isFirst:(BOOL)isFirst
{
    // Survey & Test
    if ([dic objectForKey:@"QuestionID"] != nil) {
        self.questionId = STRING_VALUE_FROM_DIC(dic, @"QuestionID");
    } else {
        self.questionId = STRING_VALUE_FROM_DIC(dic, @"QuestionId");
    }
    
    self.questionSupId = [AppManager instance].surveyId;
    self.problem = STRING_VALUE_FROM_DIC(dic, @"QuestionDesc");
    self.questionType = @(INT_VALUE_FROM_DIC(dic, @"QuestionType"));
    self.questionIndex = @(INT_VALUE_FROM_DIC(dic, @"DisplayIndexNo"));
    
    int intQuestionType = [self.questionType intValue];
    if (intQuestionType == 1 || intQuestionType == 2 || intQuestionType == 3) {
        self.isSubjective = @(NO);
    } else {
        self.isSubjective = @(YES);
    }
    
    self.answer = STRING_VALUE_FROM_DIC(dic, @"Answer");
    
    self.isMultiOption = @(YES);
    
    if (intQuestionType == 1)
        self.isMultiOption = @(NO);
    
    if (isFirst) {
        self.ugcStr = @"";
    }
    
    // Course
    NSString *courseQuestion = STRING_VALUE_FROM_DIC(dic, @"question");
    if (courseQuestion && courseQuestion.length > 0) {
        self.problem = courseQuestion;
        self.questionId = [AppManager instance].surveyId;
        self.isSubjective = @(YES);
        self.questionType = @(4);
        self.ugcStr = self.answer;
    }
}

@end
