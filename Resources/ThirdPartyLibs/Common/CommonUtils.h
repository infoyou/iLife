//
//  CommonUtils.h
//  Project
//
//  Created by Peter on 13-9-26.
//  Copyright (c) 2013年 com.jit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonHeader.h"

@interface CommonUtils : NSObject


#pragma mark - user default local storage
+ (void)saveIntegerValueToLocal:(NSInteger)value key:(NSString *)key;
+ (void)saveLongLongIntegerValueToLocal:(long long)value key:(NSString *)key;
+ (void)saveStringValueToLocal:(NSString *)value key:(NSString *)key;
+ (long long)fetchLonglongIntegerValueFromLocal:(NSString *)key;
+ (NSString *)fetchStringValueFromLocal:(NSString *)key;
+ (void)removeLocalInfoValueForKey:(NSString *)key;
+ (void)saveBoolValueToLocal:(BOOL)value key:(NSString *)key;
+ (BOOL)fetchBoolValueFromLocal:(NSString *)key;
+ (NSInteger)fetchIntegerValueFromLocal:(NSString *)key;

#pragma mark - date time
+ (NSString *)currentHourTime;
+ (NSString *)currentHourMinSecondTime;
+ (NSString *)currentDateStr;
+ (NSDate *)convertDateTimeFromUnixTS:(NSTimeInterval)unixDate;
+ (NSString *)simpleFormatDate:(NSDate *)date secondAccuracy:(BOOL)secondAccuracy;
+ (NSString *)simpleFormatDateWithYear:(NSDate *)date secondAccuracy:(BOOL)secondAccuracy;
+ (NSTimeInterval)convertToUnixTS:(NSDate *)date;
+ (NSString *)getElapsedTime:(NSDate *)timeline;
+ (NSDate *)makeDate:(NSString *)birthday;
+ (NSString *)dateToString:(NSDate*)date;

+ (NSInteger)getElapsedDayCount:(NSDate *)date;
+ (NSDate *)getOffsetDateTime:(NSDate *)nowDate offset:(NSInteger)offset;
+ (NSString *)getQuantumTimeWithDateFormat:(NSString *)timeline;
//+ (NSString *)getQuantumTimeWithTimeStamp:(NSString *)timeline;


#pragma mark - validate json data
+ (id)validateResult:(NSDictionary *)contentDic dicKey:(NSString *)key;

#pragma mark - validate password format
+ (BOOL)passwordFormatIsValidated:(NSString *)passwordStr;

#pragma mark - Share to WeChat
+ (BOOL)shareByWeChat:(NSInteger)scene
                title:(NSString *)title
                image:(NSString *)image
          description:(NSString *)description
                  url:(NSString *)url;

//+ (BOOL)sharePostByWeChat:(Post *)post
//                    scene:(NSInteger)scene
//                      url:(NSString *)url
//                    image:(UIImage *)image;

+ (NSString *)deviceModel;
+ (NSString *)documentsDirectory;
+ (CGFloat)currentOSVersion;

#pragma mark - image scale utility
+ (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage;

#pragma mark - crop image
+ (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize;

#pragma mark - file exist
+ (BOOL)isFileExitAtPath:(NSString*)aFilename;
+ (BOOL)isFileExitAtPath:(NSString *)fileName fileParentName:(NSString*)fileParentName;

#pragma mark - get New type
+ (NSString*)getNetType;

#pragma mark - 定宽高度自适应
+ (int)calcuViewHeight:(NSString *)content font:(UIFont*)font width:(float)width;

@end
