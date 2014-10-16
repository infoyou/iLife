//
//  UIViewController+JSONValue.h
//  iLife
//
//  Created by hys on 14-9-22.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBJson.h"
#import "JSONKit.h"

@interface UIViewController (JSONValue)

-(void)confirmWithMessage:(NSString *)msg title:(NSString *)title;

-(NSDictionary*)JSONValue:(id)object;

-(NSDictionary*)getParamWithAction:(NSString*)action UserID:(NSString*)userID Parameters:(NSDictionary*)parameters;

@end
