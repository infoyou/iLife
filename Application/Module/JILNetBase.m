//
//  JILNetBase.m
//  O2OQiandao
//
//  Created by hys on 14-9-11.
//  Copyright (c) 2014年 jit. All rights reserved.
//

#import "JILNetBase.h"



@implementation JILNetBase
-(void)RequestWithRequestType:(NetType *)type param:(NSDictionary *)dic
{
    
    NSURLRequest* request=[self RequestUrl:type param:dic];
    
    AFHTTPRequestOperation * operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [self OperationBlock:operation];
    [operation start];

}

-(AFHTTPRequestOperation*)RequestOperationWithRequestType:(NetType *)type param:(NSDictionary *)dic
{
   
    NSURLRequest* request=[self RequestUrl:type param:dic];
    
    AFHTTPRequestOperation * operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    
    [self OperationBlock:operation];
    return operation;

}

-(void)OperationBlock:(AFHTTPRequestOperation*)operation
{
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation*operation, id responseObject)
    {
        [self.netBaseDelegate handleRequestSuccessData:responseObject];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        [self.netBaseDelegate handleRequestFailedData:error];
        self.requestType=nil;
    }];
}

-(NSURLRequest*)RequestUrl:(NetType *)type param:(NSDictionary *)dic
{
    
    AFHTTPClient * client = [self RequestClient];
    NSString* typeStr;
    if (type==NET_GET) {
        typeStr=@"GET";
    }else{
        typeStr=@"POST";
    }
    NSURLRequest * request = [client requestWithMethod:typeStr
                                                  path:@"BuyerGateway.ashx"
                                            parameters:dic];
    return request;
}


-(AFHTTPClient*)RequestClient
{
//    NSString* baseUrl=@"http://192.168.0.8/AppInterface/BuyFood";
    NSString* baseUrl=@"http://test.wymc.com.cn/AppInterface/BuyFood";
    baseUrl=[baseUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    AFHTTPClient * client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
    return client;
}
@end
