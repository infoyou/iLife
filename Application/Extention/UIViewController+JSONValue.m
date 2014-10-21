//
//  UIViewController+JSONValue.m
//  iLife
//
//  Created by hys on 14-9-22.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import "UIViewController+JSONValue.h"

@implementation UIViewController (JSONValue)

- (void) confirmWithMessage:(NSString *)msg title:(NSString *)title
{
	[[[[UIAlertView alloc]
	   initWithTitle:title
	   message:msg
	   delegate:self
	   cancelButtonTitle:@"OK"
	   otherButtonTitles:nil] autorelease] show];
}


- (void)askWithMessage:(NSString *) msg
               alertTag:(NSInteger) tag
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提醒" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = tag;
    [alert show];
}


-(NSDictionary*)JSONValue:(id)object
{
    if (object&&object!=[NSNull null]&&object!=nil) {
        NSString* aString=[[NSString alloc]initWithData:object encoding:NSUTF8StringEncoding];
        NSDictionary* dic=(NSDictionary*)[aString JSONValue];
        return dic;
    }else{
        return [NSDictionary dictionary];
    }
}


-(NSDictionary*)getParamWithAction:(NSString*)action UserID:(NSString*)userID Parameters:(NSDictionary*)parameters
{
    NSDictionary* req=@{@"UserID":userID,
                        @"Token":@"",
                        @"Parameters":parameters};
    NSDictionary* param=@{@"type":@"Product",
                          @"Action":action,
                          @"channel":@"0",
                          @"client":@"2",
                          @"req":[req JSONString]};
    return param;
}

@end
