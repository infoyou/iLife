//
//  TodoList.m
//  QiXin
//
//  Created by Adam on 14-6-18.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import "TodoList.h"


@implementation TodoList

@dynamic content;
@dynamic todoId;
@dynamic createTime;
@dynamic read;
@dynamic reason;
@dynamic courseId;
@dynamic type;

//"course_id" = 64;
//"create_time" = "2013-12-27 14:31:42";
//id = 18997;
//read = 0;
//reason = wrong;
//type = "TRAINING_INVITED";
//"web_notice_content" = "You have been invited to join  College I(GZ)(Jan.13-16) .";
- (void)updateData:(NSDictionary *)dic
{
    self.todoId = @(INT_VALUE_FROM_DIC(dic, @"id"));
    self.content =  STRING_VALUE_FROM_DIC(dic, @"web_notice_content");
    self.courseId = STRING_VALUE_FROM_DIC(dic, @"setting_time");
    self.createTime = STRING_VALUE_FROM_DIC(dic, @"create_time");
    self.read =  @(INT_VALUE_FROM_DIC(dic, @"read"));
    self.reason =  STRING_VALUE_FROM_DIC(dic, @"reason");
//    self.courseId =  STRING_VALUE_FROM_DIC(dic, @"course_id");
    //    self.type =  STRING_VALUE_FROM_DIC(dic, @"type");
}

@end
