//
//  FeedEdit.h
//  Project
//
//  Created by XXX on 13-10-16.
//  Copyright (c) 2013年 com.jit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeedEdit : NSObject

+ (FeedEdit *)shared;

@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *email;

@end
