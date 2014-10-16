//
//  SurveyItem.m
//  QiXin
//
//  Created by Adam on 14-6-24.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import "SurveyItem.h"


@implementation SurveyItem

@dynamic answer;
@dynamic content;
@dynamic itemId;
@dynamic name;
@dynamic questionId;
@dynamic isSelect;
@dynamic mediaUrl;
@dynamic mediaType;

/*
 
 OptionIndex	String	选项索引
 OptionsText	String	选项内容
 OptionMedia	String	选项媒体：资源地址
 MediaType      Int     媒体类型：1图片 2视频
 
  */

- (void)updateData:(NSDictionary *)dic isFirst:(BOOL)isFirst questionIdStr:(NSString*)questionIdStr
{
    self.questionId = questionIdStr;
    self.itemId = STRING_VALUE_FROM_DIC(dic, @"OptionIndex");
    self.name = STRING_VALUE_FROM_DIC(dic, @"OptionIndex");
    self.content = STRING_VALUE_FROM_DIC(dic, @"OptionsText");
    
    self.answer = @(INT_VALUE_FROM_DIC(dic, @"answer"));
    self.mediaUrl = STRING_VALUE_FROM_DIC(dic, @"OptionIndex");
    self.mediaType = @(INT_VALUE_FROM_DIC(dic, @"MediaType"));
    
//    if (isFirst) {
//        self.isSelect = @(NO);
//    }
}

@end
