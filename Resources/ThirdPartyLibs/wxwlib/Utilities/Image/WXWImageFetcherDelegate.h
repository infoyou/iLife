//
//  WXWImageFetcherDelegate.h
//  Project
//
//  Created by Adam on 11-11-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WXWImageFetcherDelegate <NSObject>

@optional
- (void)imageFetchStarted:(NSString *)url;
- (void)imageFetchFailed:(NSError *)error url:(NSString *)url;

@required
- (void)imageFetchDone:(UIImage *)image url:(NSString *)url;
- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url;

@end
