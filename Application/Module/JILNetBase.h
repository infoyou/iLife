//
//  JILNetBase.h
//  O2OQiandao
//
//  Created by hys on 14-9-11.
//  Copyright (c) 2014年 jit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "SBJson.h"

typedef enum{
    NET_GET=0,
    NET_POST=1
} NetType;

@protocol JILNetBaseDelegate <NSObject>

-(void)handleRequestSuccessData:(id)object;
-(void)handleRequestFailedData:(NSError*)error;

@end

typedef enum {
    BUY_FOODLIST=1,
    BUY_PUTINCART=2,
    BUY_DELETECART=3,
    BUY_COMMITCART=4,
    BUY_FOODINFORMATION=5,
    BUY_CITY=6,
    BUY_DISTRICT=7,
    BUY_COMMUNITY=8,
    BUY_CARTLIST=9
} RequestType;

@interface JILNetBase : NSObject

@property(assign,nonatomic)RequestType* requestType;

@property(retain,nonatomic)id<JILNetBaseDelegate>netBaseDelegate;

-(void)RequestWithRequestType:(NetType*)type param:(NSDictionary*)dic;

-(AFHTTPRequestOperation*)RequestOperationWithRequestType:(NetType*)type param:(NSDictionary*)dic;

-(NSURLRequest*)RequestUrl:(NetType*)type param:(NSDictionary*)dic;

-(AFHTTPClient*)RequestClient;

@end
