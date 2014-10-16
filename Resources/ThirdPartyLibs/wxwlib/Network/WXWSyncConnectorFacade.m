
#import "WXWSyncConnectorFacade.h"
#import "WXWCommonUtils.h"
#import "WXWSystemInfoManager.h"

@implementation WXWSyncConnectorFacade

- (void)dealloc {
  
  [super dealloc];
}

#pragma mark - upload log
- (NSMutableData *)assembleLogData:(NSDictionary *)dic 
                       logFileName:(NSString *)logFileName
                        logContent:(NSData *)logContent
                      originalData:(NSMutableData *)originalData {
    
    NSString *param = [WXWCommonUtils convertParaToHttpBodyStr:dic];
    
    param = [param stringByAppendingString:[NSString stringWithFormat:@"--%@\n", WXW_FORM_BOUNDARY]];
    param = [param stringByAppendingString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"attach\"; filename=\"%@\"\nContent-Type: application/octet-stream\n\n", 
                                            logFileName]];		
    
    [originalData appendData:[param dataUsingEncoding:NSUTF8StringEncoding 
                                 allowLossyConversion:YES]];
    
    [originalData appendData:logContent];
    
    // append footer
	NSString *footer = [NSString stringWithFormat:@"\n--%@--\n", WXW_FORM_BOUNDARY];
	[originalData appendData:[footer dataUsingEncoding:NSUTF8StringEncoding
                                  allowLossyConversion:YES]];
    
    DLog(@"params: %@", [[[NSString alloc] initWithData:originalData encoding:NSUTF8StringEncoding] autorelease]);
    return originalData;
}

- (NSData *)uploadLog:(NSString *)logContent logFileName:(NSString*)logFileName{
    NSDictionary *dic = nil;
    dic = @{@"action": @"error_upload",
           @"plat": @"i",
           @"type": @"iAlumni"};
    
    return [self syncPost:ERROR_LOG_UPLOAD_URL
                     data:[self assembleLogData:dic
                                    logFileName:logFileName
                                     logContent:[logContent dataUsingEncoding:NSUTF8StringEncoding]
                                   originalData:[NSMutableData data]]];
}

- (NSData *)uploadLogData:(NSData *)data logFileName:(NSString*)logFileName {
  NSDictionary *dic = nil;
  dic = @{@"action": @"error_upload",
         @"plat": @"i",
         @"type": @"iAlumni"};
  
  return [self syncPost:ERROR_LOG_UPLOAD_URL
                   data:[self assembleLogData:dic
                                  logFileName:logFileName
                                   logContent:data
                                 originalData:[NSMutableData data]]];
  
}


- (NSData *)uploadLogData:(NSDictionary *)dic data:(NSData *)data logFileName:(NSString*)logFileName {
    
    return [self syncPost:ERROR_LOG_UPLOAD_URL
                     data:[self assembleLogData:dic
                                    logFileName:logFileName
                                     logContent:data
                                   originalData:[NSMutableData data]]];
}

- (NSData *)uploadLog:(NSString *)logContent {
  NSDictionary *dic = nil;
  
  dic = @{@"action": @"log_upload", 
         @"plat": @"i",
         @"version": VERSION,
         @"user_id": LLINT_TO_STRING([WXWSystemInfoManager instance].userId),
         @"message": logContent};
  
  NSString *url = [WXWCommonUtils assembleUrl:nil];
	return [self syncPost:url paramDic:dic];
}

#pragma mark - get & show
- (NSData *)fetchGets:(NSString *)url {
    return [self syncGet:url];
}

@end
