﻿//
//  CommonMethod.m
//  Project
//
//  Created by Peter on 13-7-16.
//  Copyright (c) 2013年 kid. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <CommonCrypto/CommonDigest.h>
#import "CommonMethod.h"
#import "GlobalConstants.h"
#import "URLHelper.h"
#import "JSONKit.h"
#import "UserProfile.h"
#import "ProjectAPI.h"
#import "UserDataManager.h"
#import "AppManager.h"
#import "WXWCustomeAlertView.h"
#import <sys/utsname.h>
#import "UIDevice+Hardware.h"
#import "HttpClientSyn.h"
#import "NSString+JITIOSLib.h"
#import "ProjectAPI.h"


@implementation CommonMethod

@synthesize navigationRootViewController = _navigationRootViewController;
@synthesize navigationController = _navigationController;
@synthesize lastViewController = _lastViewController;

static CommonMethod *instance = nil;

+ (CommonMethod *)getInstance {
    
#if 0
    if (nil != instance) {
        return instance;
    }
    
    static dispatch_once_t pred;        // Lock
    dispatch_once(&pred, ^{             // This code is called at most once per app
        instance = [[HardwareInfo alloc] init];
    });
    
#endif
    
    @synchronized(self) {
        if(instance == nil)
            instance = [[super allocWithZone:NULL] init];
    }
    
    return instance;
}

- (UINavigationController *) getNavigationController
{
    [CommonMethod getInstance].navigationRootViewController.navigationController.navigationBar.tintColor = [[ThemeManager shareInstance] getColorWithName:@"kNaviBarTitleLabel"];
    return [CommonMethod getInstance].navigationRootViewController.navigationController;
}

+ (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font {
    return [text sizeWithFont:font constrainedToSize:CGSizeMake(MAXFLOAT, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
}

+ (void) sortArray:(NSMutableArray *)dicArray orderWithKey:(NSString *)key ascending:(BOOL)yesOrNo
{
    NSSortDescriptor *distanceDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:yesOrNo];
    NSArray *descriptors = [NSArray arrayWithObjects:distanceDescriptor,nil];
    [dicArray sortUsingDescriptors:descriptors];
    [distanceDescriptor release];
}

+ (NSString *)GetUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return [(NSString *)string autorelease];
}

+ (NSString*)deviceString
{
    // 需要#import "sys/utsname.h"
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([deviceString isEqualToString:@"iPhone1,1"])    return IPHONE_1G_NAMESTRING;
    if ([deviceString isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"Verizon iPhone 4";
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    DLog(@"NOTE: Unknown device type: %@", deviceString);
    return deviceString;
}


+ (UIImage *) createImageWithColor: (UIColor *) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);

    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return theImage;
}


+ (UIImage *) createImageWithColor: (UIColor *) color withRect:(CGRect )rect
{
    //    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}


+ (UIButton *)addButton:(id)target withRect:(CGRect)rect withTitle:(NSString *)title withTarget:(SEL)sel
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    button.frame = rect;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter ];
    
    [button addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

+ (UITextField *)addTextField:(id)target withRect:(CGRect)rect withEdgeMakeRect:(UIEdgeInsets)edgeRect withPlaceHolderText:(NSString *)placeholder
{
    UITextField *field = [[UITextField alloc] initWithFrame:rect];
    field.background = [self createImageWithColor:RANDOM_COLOR];
    field.layer.cornerRadius = 3.0f;
    field.layer.frame = rect;
    field.font = FONT_SYSTEM_SIZE(25);
    field.textColor = COLOR(0x40, 0x40, 0x40);
    field.placeholder = placeholder;
    
    //    field.edgeInsets = edgeRect;//;
    
    field.delegate = target;
    
    
    return field;
}


+ (UILabel *)addLabel:(CGRect)rect withTitle:(NSString *)title withFont:(UIFont *)font
{
    UILabel *label = [[[UILabel alloc] initWithFrame:rect] autorelease];
    label.text = title;
    label.textAlignment = NSTextAlignmentLeft ;
    [label setFont:font];
    
    return label;
}


+ (UIImage *)drawImageToRect:(UIImage *)image withRegionRect:(CGRect)regionRect
{
    UIGraphicsBeginImageContext(regionRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, regionRect);
    
    [image  drawInRect:regionRect];
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return theImage;
}

+ (UIImage *) drawImageToRect:(UIImage *)image withImageRect:(CGRect )imageRect withRegionRect:(CGRect)regionRect
{
    UIGraphicsBeginImageContext(regionRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, regionRect);
    
    [image  drawInRect:imageRect];
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return theImage;
}

+ (UIImage *) drawImageToRect:(UIImage *)image withImageRect:(CGRect )imageRect withMaskImage:(UIImage *)maskImage withMaskImageRect:(CGRect )imageMaskRect withRegionRect:(CGRect)regionRect
{
    UIGraphicsBeginImageContext(regionRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, regionRect);
    
    [maskImage drawInRect:imageMaskRect];
    [image  drawInRect:imageRect];
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return theImage;
}

+ (UIImage*) regionImage:(UIImage*) image withRect:(CGRect ) rect
{
    CGImageRef subImageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
    CGRect smallBounds = CGRectMake(rect.origin.x, rect.origin.y, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    CGImageRelease(subImageRef);
    
    return smallImage;
}

+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

+ (BOOL)writeImage:(UIImage*)image toFileAtPath:(NSString*)aPath
{
    if ((image == nil) || (aPath == nil) || ([aPath isEqualToString:@""]))
        return NO;
    
    @try
    {
        NSData *imageData = nil;
        NSString *ext = [aPath pathExtension];
        if ([ext isEqualToString:@"png"])
        {
            imageData = UIImagePNGRepresentation(image);
        }
        else
        {
            // the rest, we write to jpeg
            // 0. best, 1. lost. about compress.
            imageData = UIImageJPEGRepresentation(image, 0);
        }
        if ((imageData == nil) || ([imageData length] <= 0))
            return NO;
        [imageData writeToFile:aPath atomically:YES];
        return YES;
    }
    
    @catch (NSException *e)
    {
        DLog(@"create thumbnail exception.");
    }
    return NO;
}

+ (void)writeImage:(UIImage *)image toLocalPath:(NSString *)localPath completion:(void (^)(BOOL))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		
        NSData *data = UIImageJPEGRepresentation(image, 0);
        
        BOOL result = [data writeToFile:localPath atomically:YES];
        
		dispatch_async(dispatch_get_main_queue(), ^{
			if(completion)
				completion(result);
		});
	});
}

+ (void)pushViewController:(UIViewController *)viewController withAnimated:(BOOL)animated
{
    @try {
        
        UIViewController *mvc = [CommonMethod getInstance].navigationRootViewController;
        mvc.navigationController.navigationBarHidden = NO;
        mvc.view.hidden = NO;
        [mvc.navigationController pushViewController:viewController animated:animated];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

+ (void)popViewController:(UIViewController *)viewController
{
    @try {
        
        UIViewController *mvc = [CommonMethod getInstance].navigationRootViewController;
        mvc.view.hidden = YES;
        [mvc.navigationController popViewControllerAnimated:YES];
        //        [[CommonMethod getInstance] setLastViewController:nil];
        
        //        if ([CommonMethod getInstance].lastViewController) {
        //            [self pushViewController:[CommonMethod getInstance].lastViewController withAnimated:NO];
        //            [[CommonMethod getInstance] setLastViewController:nil];
        //        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

+ (long long int)getCurrentTimeSince1970
{
    return (long long int)[[NSDate date] timeIntervalSince1970];
}

+ (NSString *)getDateFromNow:(int)distDay
{
    NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc]init]autorelease];
    
    NSTimeInterval interval = 24*60*60*distDay; //1:天数
    NSDate *date1 = (NSDate*) [[NSDate date] initWithTimeIntervalSinceNow:+interval];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    return[NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:date1]];
}

+(NSString *)getShortTime1:(NSTimeInterval)interval
{
    NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc]init]autorelease];
    
    
    NSDate *date1 = (NSDate*) [[NSDate date] initWithTimeIntervalSince1970:interval];
    [dateFormatter setDateFormat:@"MM-dd HH:mm:ss"];
    
    return[NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:date1]];
}

+ (NSString *)convertURLToLocal:(NSString *)url {
    if (![url isEqual:[NSNull null]]) {
        
        NSString *str = [url stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
        str = [str stringByReplacingOccurrencesOfString:@":" withString:@"_"];
        str = [str stringByReplacingOccurrencesOfString:@"." withString:@"_"];
        str = [str stringByReplacingOccurrencesOfString:@"?" withString:@"_"];
        str = [str stringByReplacingOccurrencesOfString:@"=" withString:@"_"];
        
        str = [NSString stringWithFormat:@"%@", str];
        
        return str;
    }
    return nil;
}

+ (NSString *)convertURLToLocal:(NSString *)url withId:(NSString *)itemId
{
    if (![url isEqual:[NSNull null]]) {
        
        NSString *str = [url stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
        str = [str stringByReplacingOccurrencesOfString:@":" withString:@"_"];
        str = [str stringByReplacingOccurrencesOfString:@"." withString:@"_"];
        
        str = [NSString stringWithFormat:@"%@_%@", str, itemId];
        
        return str;
    }
    return nil;
}

+ (NSString *)getLocalDownloadFileName:(NSString *)imageURL  withId:(NSString *)itemId
{
    if (![imageURL isEqual:[NSNull null]]) {
        
        NSString *str = [imageURL stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
        str = [str stringByReplacingOccurrencesOfString:@":" withString:@"_"];
        str = [str stringByReplacingOccurrencesOfString:@"." withString:@"_"];
        
        
        str = [NSString stringWithFormat:@"%@_%@", str, itemId];
        
        return [[self getLocalImageFolder] stringByAppendingPathComponent:str];
    }
    return nil;
    
}

+ (NSString *)getLocalDownloadFileName:(NSString *)fileURL
{
    if (![fileURL isEqual:[NSNull null]]) {
        
        NSString *str = [fileURL stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
        str = [str stringByReplacingOccurrencesOfString:@":" withString:@"_"];
        str = [str stringByReplacingOccurrencesOfString:@"." withString:@"_"];
        
        str = [NSString stringWithFormat:@"%@", str];
        
        return [[self getLocalDownloadFolder] stringByAppendingPathComponent:str];
    }
    return nil;
    
}

+ (void)loadImageWithURL:(NSString *)imageURL
             delegateFor:(id)delegateFor
               localName:(NSString *)name
                finished:(void (^)(void))finished {
    //    NSString *downloadFile = [CommonMethod getLocalDownloadFileName:imageURL withId:name];
    NSString *_downloadTempFile = [NSString stringWithFormat:@"%@.tmp", name];
    
    DLog(@"localFileName:%@", name);
    
    if (![CommonMethod isExist:name]) {
        
        NSURL *url = [NSURL URLWithString:[imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        ASIHTTPRequest *_request = [[ASIHTTPRequest alloc] initWithURL:url];
        [_request setDidReceiveResponseHeadersSelector:@selector(didReceiveResponseHeaders:)];
        [_request setDidStartSelector:@selector(didStartSelector)];
        //    [_request setDownloadProgressDelegate:_progressView];
        [_request setDelegate:delegateFor];
        [_request setShowAccurateProgress:YES];
        [_request setAllowResumeForFileDownloads:YES];
        
        [_request setDownloadDestinationPath:name];
        [_request setTemporaryFileDownloadPath:_downloadTempFile];
        [_request startAsynchronous];
        [_request release];
    }else{
        finished();
    }
}

+ (NSString *)getLocalImageFolder
{
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/image"];
}

+ (NSString *)getLocalDownloadFolder
{
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/download"];
}

+(NSString *)getLocalTrainingDownloadFolder
{
    
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/download/training"];
}


+ (BOOL)isExist:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    if (!documentsDirectory) {
        DLog(@"Documents directory not found!");
        return FALSE;
    }
    if([[NSFileManager defaultManager] fileExistsAtPath:fileName]){
        DLog(@"File is found");
        return TRUE;
    }else{
        DLog(@"File is not found");
        return FALSE;
    }
}

+ (void)viewAddGuestureRecognizer:(UIView *)view withTarget:(id)target withSEL:(SEL)sel
{
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:target action:sel];
    
    [view addGestureRecognizer:singleTap];
}

+ (NSString *)isNull:(id)var
{
    if (var == [NSNull null] || [var isEqualToString:@"<null>"]) {
        return nil;
    }
    return var;
}

#pragma mark - jsonstring from url

+ (NSString *)JSONStringFromURL:(NSString *)url {
    return [[url componentsSeparatedByString:@"="] lastObject];
}

+ (NSDictionary *)dictionaryFromURL:(NSString *)url {
    return [[[self class] JSONStringFromURL:url] objectFromJSONString];
}

+ (NSDictionary *)dictionaryFromJSONString:(NSString *)jsonString {
    return [jsonString objectFromJSONString];
}

#pragma mark - encapsulation request content

+ (NSMutableDictionary *)encapsulationReqContentWithParam:(NSDictionary *)dict {
    
    NSDictionary *reqContent = [dict objectForKey:@"ReqContent"];
    NSDictionary *commonDic = [reqContent objectForKey:KEY_API_COMMON];
    
    NSDictionary *sDic = [reqContent objectForKey:KEY_API_SPECIAL];
    
    NSMutableDictionary *specialDic = [[[NSMutableDictionary alloc] init] autorelease];
    
    //    NSArray *dataArr = [dict objectForKey:KEY_API_DATA];
    
    [specialDic setObject:[dict objectForKey:KEY_API_DATA] forKey:KEY_API_PROPERTYVALUELIST];
    [specialDic setObject:[sDic objectForKey:KEY_API_INVOKETYPE] forKey:KEY_API_INVOKETYPE];
    //    [specialDic setObject:NUMBER(type) forKey:KEY_API_INVOKETYPE];
    
    NSMutableDictionary *returnDic = [[[NSMutableDictionary alloc] init] autorelease];
    [returnDic setObject:commonDic forKey:KEY_API_COMMON];
    [returnDic setObject:specialDic forKey:KEY_API_SPECIAL];
    //    DLog(@"returnDic: %@",returnDic);
    return returnDic;
    
}

+ (NSMutableDictionary *)encapsulationReqContentWithParam:(NSDictionary *)dict withInvokeType:(int)type {
    NSDictionary *reqContent = [dict objectForKey:@"ReqContent"];
    
    NSDictionary *commonDic = [reqContent objectForKey:KEY_API_COMMON];
    
    NSMutableDictionary *sDic = [[reqContent objectForKey:KEY_API_SPECIAL] mutableCopy];
    
    if ([sDic objectForKey:KEY_API_INVOKETYPE]) {
        [sDic removeObjectForKey:KEY_API_INVOKETYPE];
    }
    [sDic setObject:NUMBER(type) forKey:KEY_API_INVOKETYPE];
    
    NSMutableDictionary *returnDic = [[[NSMutableDictionary alloc] init] autorelease];
    [returnDic setObject:commonDic forKey:KEY_API_COMMON];
    
    [sDic setObject:[dict objectForKey:KEY_API_PROPERTYVALUELIST] forKey:KEY_API_PROPERTYVALUELIST];
    
    [returnDic setObject:sDic forKey:KEY_API_SPECIAL];
    DLog(@"returnDic: %@",returnDic);
    [sDic release];
    return returnDic;
}

#pragma mark - userbaseinfo

+ (UserBaseInfo *)userBaseInfoWithUserProfile:(UserProfile *)userProfile {
    UserBaseInfo *ubf = [[[UserBaseInfo alloc] init] autorelease];
    
    ubf.groups = [[[NSMutableArray alloc] init] autorelease];
    
    for (int i = 0; i < userProfile.propertyGroups.count; i++) {
        PropertyGroup *pg = (PropertyGroup *)userProfile.propertyGroups[i];
        
        UserProperty *up = [[[UserProperty alloc] init] autorelease];
        up.values = [[[NSMutableArray alloc] init] autorelease];
        up.names = [[[NSMutableArray alloc] init] autorelease];
        
        for (int j = 0; j < pg.propertyLists.count; j++) {
            
            PropertyList *pl = (PropertyList *)pg.propertyLists[j];
            
            if (pl.controlType == CONTROLTYPE_DROPLIST) {
                
                NSString *value = @"";
                
                for (int ii = 0; ii < pl.optionLists.count; ii++) {
                    
                    OptionList *opl = pl.optionLists[ii];
                    
                    if ([pl.propertyValue isEqualToString:[NSString stringWithFormat:@"%d",opl.optionLookupID]]) {
                        //                        [up.values addObject:opl.optionValue];
                        value = opl.optionValue;
                    }
                }
                [up.values addObject:value];
                [up.names addObject:pl.propertyName];
            }else {
                [up.values addObject:pl.propertyValue];
                [up.names addObject:pl.propertyName];
            }
        }
        
        [ubf.groups addObject:up];
    }
    ubf.userID = userProfile.userID;
    ubf.isFriend = userProfile.isFriend;
    ubf.isDelete = userProfile.isDelete;
    DLog(@"userBasInfo:%@",ubf.groups);
    return ubf;
}

+ (UserBaseInfo *)userBaseInfoWithUserID:(int)userID {
    UserProfile *up = [[CommonMethod userProfileWithUserID:userID] retain];
    UserBaseInfo *ubf = [[CommonMethod userBaseInfoWithUserProfile:up] retain];
    [ubf parseValueProperties];
    return ubf;
}


+ (UserBaseInfo *)userBaseInfoWithDictUserProfile:(UserProfile *)userProfile {
    UserBaseInfo *ubf = [[CommonMethod userBaseInfoWithUserProfile:userProfile] retain];
    [ubf parseValueProperties];
    return ubf;
}

#pragma mark - userprofile
+ (UserObject *)formatUserObjectWithParam:(NSDictionary *)userInfo
{
    UserObject *userObject = [[[UserObject alloc] init] autorelease];
    
    userObject.userName = STRING_VALUE_FROM_DIC(userInfo, @"user_name");
    userObject.userId = STRING_VALUE_FROM_DIC(userInfo, @"user_id");
    userObject.chatId = STRING_VALUE_FROM_DIC(userInfo, @"VoipAccount");
    userObject.userTitle = STRING_VALUE_FROM_DIC(userInfo, @"JobFunc");
    userObject.userRole = STRING_VALUE_FROM_DIC(userInfo, @"RoleName");
    userObject.userDept = STRING_VALUE_FROM_DIC(userInfo, @"Dept");
    userObject.userCode = STRING_VALUE_FROM_DIC(userInfo, @"user_code");
    userObject.userNameEn = STRING_VALUE_FROM_DIC(userInfo, @"user_name_en");
    userObject.userEmail = STRING_VALUE_FROM_DIC(userInfo, @"user_email");
    userObject.userTel = STRING_VALUE_FROM_DIC(userInfo, @"user_telephone");
    userObject.userImageUrl = STRING_VALUE_FROM_DIC(userInfo, @"HighImageUrl");
    userObject.userGender = INT_VALUE_FROM_DIC(userInfo, @"user_gender");
    userObject.isFriend = 0;
    userObject.isDelete = INT_VALUE_FROM_DIC(userInfo, @"user_status")-1;
    userObject.userCellphone = STRING_VALUE_FROM_DIC(userInfo, @"user_cellphone");
    userObject.userBirthDay = STRING_VALUE_FROM_DIC(userInfo, @"userBirthDay");
    userObject.superName = STRING_VALUE_FROM_DIC(userInfo, @"SuperiorName");
    userObject.customerId = CUSTOMER_ID;
    userObject.userStatus = @"1";
    userObject.groupId = @"";
    
    userObject.channel = STRING_VALUE_FROM_DIC(userInfo, @"Channel");
    userObject.channelId = INT_VALUE_FROM_DIC(userInfo, @"channelId");
    userObject.function = STRING_VALUE_FROM_DIC(userInfo, @"Dept");
    userObject.superEmail = STRING_VALUE_FROM_DIC(userInfo, @"SuperiorName");
    userObject.location = STRING_VALUE_FROM_DIC(userInfo, @"Location");
    userObject.serviceYear = STRING_VALUE_FROM_DIC(userInfo, @"ServiceYear");
    userObject.band = STRING_VALUE_FROM_DIC(userInfo, @"JobFunc");
    userObject.subordinateCount = STRING_VALUE_FROM_DIC(userInfo, @"SubordinateCount");
    
    return userObject;
}

#pragma mark - userprofile
+ (UserProfile *)formatUserProfileWithParm:(NSDictionary *)dict {
    
    UserProfile *up = [[[UserProfile alloc] init] autorelease];
    up.userID = [[dict objectForKey:kUserID] integerValue];
    up.isFriend = [[dict objectForKey:kIsFriend] integerValue];
    up.isDelete = [[dict objectForKey:kIsDelete] integerValue];
    up.propertyGroups = [[[NSMutableArray alloc] init] autorelease];
    
    NSArray *groupArr = [dict objectForKey:kPropertyGroup];
    
    for (int i = 0; i < groupArr.count; i++) {
        
        NSDictionary *groupDic = groupArr[i];
        
        PropertyGroup *pg = [[PropertyGroup alloc] init];
        pg.propertyGroupID = [[groupDic objectForKey:kPropertyGroupID] integerValue];
        pg.propertyLists = [[[NSMutableArray alloc] init] autorelease];
        
        NSArray *listArr = [groupDic objectForKey:kPropertyList];
        
        for (int j = 0; j < listArr.count; j++) {
            
            NSDictionary *listDic = listArr[j];
            PropertyList *pl = [[PropertyList alloc] init];
            
            pl.optionLists = [[[NSMutableArray alloc] init] autorelease];
            
            pl.childUserPropertyClientID = [ [self isNull:[listDic objectForKey:kChildUserPropertyClientID]]  integerValue];
            pl.controlType = [ [self isNull:[listDic objectForKey:kControlType]] integerValue];
            pl.defaultValue = [listDic objectForKey:kDefaultValue];
            pl.displayIndex = [[self isNull:[listDic objectForKey:kDisplayIndex]] integerValue];
            pl.isRequired = [[self isNull:[listDic objectForKey:kIsRequired]] boolValue];
            pl.maxLength = [[self isNull:[listDic objectForKey:kMaxLength] ]integerValue];
            pl.minLength = [[self isNull:[listDic objectForKey:kMinLength]] integerValue];
            
            NSArray *ol = [listDic objectForKey:kOptionList];
            
            if (![ol isEqual:[NSNull null]] && ol.count) {
                for (int i = 0; i < ol.count; i++) {
                    OptionList *opl = [[[OptionList alloc] init] autorelease];
                    NSDictionary *dic = ol[i];
                    opl.optionLookupID = [[self isNull:[dic objectForKey:kOptionLookupID]] integerValue];
                    opl.optionValue = [dic objectForKey:kOptionValue];
                    [pl.optionLists addObject:opl];
                }
            }
            
            pl.propertyName = [listDic objectForKey:kPropertyName];
            pl.propertyValue = [listDic objectForKey:kPropertyValue];
            pl.regularExpression = [listDic objectForKey:kRegularExpression];
            pl.userPropertyClientID = [[self isNull:[listDic objectForKey:kUserPropertyClientID]] integerValue];
            
            [pg.propertyLists addObject:pl];
            [pl release];
        }
        
        [up.propertyGroups addObject:pg];
        [pg release];
    }
    DLog(@"userProgile:%@ %d",up.propertyGroups, up.propertyGroups.count);
    return up;
}

+ (NSArray *)userProfilesFromUserList:(NSArray *)array {
#if 1
    NSMutableArray *arr = [[[NSMutableArray alloc] init] autorelease];
    
    for (int i = 0; i < array.count; i++) {
        //        UserProfile *up = [[UserProfile alloc] init];
        
        NSDictionary *deltaDic = [array objectAtIndex:i];
        //        up.userID = [[deltaDic objectForKey:@"userID"] integerValue];
        
        
        [arr addObject:[CommonMethod formatUserProfileWithParm:deltaDic]];
    }
    //    [UserDataManager defaultManager].userProfiles = arr;
    return arr;
#endif
    
    //    NSMutableArray *userProfiles = [NSMutableArray array];
    //    for (UserProfile *q in [UserDataManager defaultManager].userProfiles) {
    //
    //        for (UserProfile *p in array) {
    //            if (p.userID == q.userID) {
    //                [userProfiles addObject:q];
    //            }
    //        }
    //    }
    //
    //    return userProfiles;
}


+ (NSArray *)userProfilesFromUserListWithUserInfo:(NSArray *)array
{
    NSMutableArray *userProfiles = [NSMutableArray array];
    for (UserProfile *q in [AppManager instance].userDM.userProfiles) {
        
        for (UserProfile *p in array) {
            if (p.userID == q.userID) {
                [userProfiles addObject:q];
            }
        }
    }
    
    return userProfiles;
}

+ (UserProfile *)userProfileWithUserID:(int)userID {
    if ([AppManager instance].userDM.userProfiles.count > 0) {
        for (UserProfile *up in [AppManager instance].userDM.userProfiles) {
            DLog(@"%d:%d", up.userID, userID);
            if (up.userID == userID) {
                return up;
            }
        }
    }
    return nil;
}

+ (UserProfile *)userProfileFromMemberList:(NSArray *)memberList WithUerID:(int)userID {
    if (memberList.count && ![memberList isEqual:[NSNull null]]) {
        for (UserProfile *up in memberList) {
            if (up.userID == userID) {
                return up;
            }
        }
    }
    return nil;
}

+ (NSString *)saveUserProfileWithParam:(NSDictionary *)dict {
    //#if USE_ASIHTTP
    //    return [APIInfo saveUserProfileWithParam:dict];
    //#else
    //    return FALSE;
    //#endif
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@?ReqContent=%@",VALUE_API_PREFIX,KEY_GETUSERLIST_URL,[dict JSONString]];
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request startSynchronous];
    NSError *error = [request error];
    NSString *result = @"";
	if (!error) {
        DLog(@"%@",[request responseString]);
		NSDictionary *dic = [[request responseString] objectFromJSONString];
        
        NSString *code = [dic objectForKey:RET_CODE_NAME];
        NSString *desc = [dic objectForKey:@"description"];
        if(![@"200" isEqualToString:code]) {
            result = desc;
        }
    }
    
    return result;
}

+ (BOOL)uploadUserProfileImageWithImage:(UIImage *)image {
    return YES;
}

#pragma mark - list

+ (List *)listWithParam:(NSMutableDictionary *)dict {
    List *list = [[[List alloc] init] autorelease];
    list.informationLists = [[[NSMutableArray alloc] init] autorelease];
    
#if USE_ASIHTTP
    NSDictionary *dic = [APIInfo getInformationServiceForList:dict];
    list.isAll = [[dic objectForKey:@"param1"] boolValue];
    NSArray *arr = [dic objectForKey:@"list1"];
    for (int i = 0; i < arr.count; i++) {
        InformationList *infoList = [[[InformationList alloc] init] autorelease];
        NSDictionary *dic1 = arr[i];
        infoList.ID = [[dic1 objectForKey:@"param1"] integerValue];
        infoList.informationType = [[dic1 objectForKey:@"param2"] integerValue];
        infoList.link = [dic1 objectForKey:@"param3"];
        infoList.linkType = [[dic1 objectForKey:@"param4"] integerValue];
        infoList.reader = [[dic1 objectForKey:@"param5"] integerValue];
        infoList.comment = [[dic1 objectForKey:@"param6"] integerValue];
        infoList.sortOrder = [[dic1 objectForKey:@"param7"] integerValue];
        infoList.zipURL = [dic1 objectForKey:@"param8"];
        infoList.clientID = [[dic1 objectForKey:@"param9"] integerValue];
        infoList.lastUpdateTime = [dic1 objectForKey:@"param10"];
        infoList.title = [dic1 objectForKey:@"param11"];
        
        [list.informationLists addObject:infoList];
    }
    [ListDataManager defaultManager].informationLists = list.informationLists;
    return list;
#else
    return nil;
#endif
}

+ (List *)listWithParam:(NSMutableDictionary *)dict keyword:(NSString *)keyword {
    List *list = [[[List alloc] init] autorelease];
    list.informationLists = [[[NSMutableArray alloc] init] autorelease];
    
#if USE_ASIHTTP
    NSDictionary *dic = [APIInfo getInformationSearchResultForList:dict keyword:keyword];
    list.isAll = [[dic objectForKey:@"param1"] boolValue];
    NSArray *arr = [dic objectForKey:@"list1"];
    for (int i = 0; i < arr.count; i++) {
        InformationList *infoList = [[[InformationList alloc] init] autorelease];
        NSDictionary *dic1 = arr[i];
        infoList.ID = [[dic1 objectForKey:@"param1"] integerValue];
        infoList.informationType = [[dic1 objectForKey:@"param2"] integerValue];
        infoList.link = [dic1 objectForKey:@"param3"];
        infoList.linkType = [[dic1 objectForKey:@"param4"] integerValue];
        infoList.reader = [[dic1 objectForKey:@"param5"] integerValue];
        infoList.comment = [[dic1 objectForKey:@"param6"] integerValue];
        infoList.sortOrder = [[dic1 objectForKey:@"param7"] integerValue];
        infoList.zipURL = [dic1 objectForKey:@"param8"];
        infoList.clientID = [[dic1 objectForKey:@"param9"] integerValue];
        infoList.lastUpdateTime = [dic1 objectForKey:@"param10"];
        infoList.title = [dic1 objectForKey:@"param11"];
        
        [list.informationLists addObject:infoList];
    }
    //    [ListDataManager defaultManager].informationResultLists = list.informationLists;
    return list;
#else
    return nil;
#endif
}

+ (NSMutableArray *)imageList {
    
#if USE_ASIHTTP
    NSMutableArray *arr = [[[NSMutableArray alloc] init] autorelease];
    NSDictionary *dict = [APIInfo getInformationServiceForSideImage];
    
    NSArray *ar = [dict objectForKey:@"list1"];
    for (int i = 0; i < ar.count; i++) {
        
        NSDictionary *dic = ar[i];
        ImageList *iList = [[ImageList alloc] init];
        
        iList.imageID = [[dic objectForKey:@"param1"] integerValue];
        iList.imageURL = [dic objectForKey:@"param2"];
        iList.title = [dic objectForKey:@"param3"];
        iList.sortOrder = [[dic objectForKey:@"param4"] integerValue];
        iList.target = [[dic objectForKey:@"param5"] integerValue];
        
        [arr addObject:iList];
        [iList release];
    }
    return arr;
#else
    return nil;
#endif
}

#pragma mark - url encode && decode

+ (NSString *)encodeURLWithURL:(NSString *)url {
    return [URLHelper StringEncode:url];
}

+ (NSString *)decodeURLWithURL:(NSString *)url {
    return [URLHelper StringDecode:url];
}

#pragma mark - md5 hash

+ (NSString*)hashStringAsMD5:(NSString*)str {
    
	const char *concat_str = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(concat_str, strlen(concat_str), result);
    NSMutableString *hash = [NSMutableString string];
    
	for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++){
        [hash appendFormat:@"%02X", result[i]];
	}
    
	return [hash lowercaseString];
}
+ (BOOL)is7System
{
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7)
        return FALSE;
    
    return TRUE;
}


+ (BOOL)is6System
{
    if ([[UIDevice currentDevice].systemVersion floatValue] < 6)
        return FALSE;
    
    return TRUE;
}


#pragma mark -- alert view

+ (void)showAlert:(id)delegate  title:(NSString *)title tip:(NSString *)tip
{
    
    WXWCustomeAlertView *customeAlertView = [[WXWCustomeAlertView alloc]init];
    customeAlertView.delegate = delegate;
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:title,CUSTOMIZED_TITLE,tip,CUSTOMIZED_TIP,  nil];
    [customeAlertView updateInfo:dict];
    
    [customeAlertView show];
}

+ (NSString *)convertLongTimeToString:(NSTimeInterval)timestamp
{
    NSDate *today =[NSDate dateWithTimeIntervalSince1970:timestamp];
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
	NSString *dateString = [dateFormat stringFromDate:today];
	[dateFormat release];
	dateFormat = nil;
	return dateString;
}

+ (NSString *)convertLongTimeToCircleMarketingString:(NSTimeInterval)timestamp
{
    NSDate *today =[NSDate dateWithTimeIntervalSince1970:timestamp];
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
	NSString *dateString = [dateFormat stringFromDate:today];
	[dateFormat release];
	dateFormat = nil;
	return dateString;
}

+ (NSDate *)getChatTimeAutoMatchFormatDate:(NSString *)dateStr
{
    
    NSDate *msgCreatedDate = nil;
    int dateLen = [dateStr length];
    NSString *dateFormat = nil;
    NSString *msgCreateStr = dateStr;
    
    if (dateLen > 14) {
        dateFormat = kDEFAULT_DATE_TIME_FORMAT;
    } else {
        dateFormat = kDATE_TIME_FORMAT;
        
        if (dateLen < 14) {
            msgCreateStr = [NSString stringWithFormat:@"%@0", msgCreateStr];
        }
    }
    
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:dateFormat];
    NSLocale *locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"] autorelease];
    [formatter setLocale:locale];
    
    msgCreatedDate = [formatter dateFromString:msgCreateStr];
    
    return msgCreatedDate;
}

+ (NSString *)getYearTimeAutoMatchFormat:(NSString *)dateStr
{
    return [self getYearFormatedTime:[self getChatTimeAutoMatchFormatDate:dateStr]];
}

+ (NSString *)getChatTimeAutoMatchFormat:(NSString *)dateStr
{
    return [self getChatFormatedTime:[self getChatTimeAutoMatchFormatDate:dateStr]];
}

+ (NSTimeInterval)getChatTimeAutoMatchTimeInterval:(NSString *)dateStr
{
    
    return [[self getChatTimeAutoMatchFormatDate:dateStr] timeIntervalSince1970];
}

+ (NSString *)getYearFormatedTime:(NSDate *)orderDate
{
    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setAMSymbol:@"AM"];
    NSLocale *locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"] autorelease];
    [dateFormatter setLocale:locale];
    
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    
    NSString *timeStr = [dateFormatter stringFromDate:orderDate];
    
    return timeStr;
}

+ (NSString *)getChatFormatedTime:(NSDate *)orderDate
{
    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setAMSymbol:@"AM"];
    NSLocale *locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"] autorelease];
    [dateFormatter setLocale:locale];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit |NSHourCalendarUnit |NSMinuteCalendarUnit;
    NSDateComponents *cmp1 = [calendar components:unitFlags fromDate:orderDate];
    NSDateComponents *cmp2 = [calendar components:unitFlags fromDate:[NSDate date]];
    
    NSString *timeStr = @"";
    
    if ([cmp1 day] == [cmp2 day]) {
        [dateFormatter setDateFormat:@"HH:mm"];
        timeStr = [dateFormatter stringFromDate:orderDate];
    } else {
        [dateFormatter setDateFormat:@"MM/dd HH:mm"];
    }
    
    timeStr = [dateFormatter stringFromDate:orderDate];
    
    return timeStr;
}

+ (NSString *)getFormatedTime:(NSTimeInterval)timestamp
{
    
    //-------------------------
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setAMSymbol:@"AM"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSDate *orderDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
    
    int time = [[NSDate date] timeIntervalSinceDate:orderDate];
    
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit |NSHourCalendarUnit |NSMinuteCalendarUnit;
    NSDateComponents *cmp1 = [calendar components:unitFlags fromDate:orderDate];
    NSDateComponents *cmp2 = [calendar components:unitFlags fromDate:[NSDate date]];
    
    NSString *timeStr=@"";
    
    if (time > 0) {
        if ([cmp1 day] == [cmp2 day]) { // 今天
            //                 if ([cmp1 hour] >=0 && [cmp1 hour] <6) {
            //                     [dateFormatter setDateFormat:@"HH:mm"];
            //                 }else if ([cmp1 hour] >=6 && [cmp1 hour] <12){
            //                     [dateFormatter setDateFormat:@"HH:mm"];
            //                 }else if ([cmp1 hour] >=12 && [cmp1 hour] <18){
            //                     [dateFormatter setDateFormat:@"HH:mm"];
            //                 }else {
            //                     [dateFormatter setDateFormat:@"HH:mm"];
            //                 }
            
            [dateFormatter setDateFormat:@"今天"];
            
        }else if ([cmp1 day] - [cmp2 day] < 0){
            
            //                 if ([cmp1 hour] >=0 && [cmp1 hour] <6) {
            //                     [dateFormatter setDateFormat:@"昨天"];
            //                 }else if ([cmp1 hour] >=6 && [cmp1 hour] <12){
            //                     [dateFormatter setDateFormat:@"昨天"];
            //                 }else if ([cmp1 hour] >=12 && [cmp1 hour] <18){
            //                     [dateFormatter setDateFormat:@"昨天"];
            //                 }else {
            //                     [dateFormatter setDateFormat:@"昨天"];
            //                 }
            [dateFormatter setDateFormat:@"昨天"];
        }else{
            [dateFormatter setDateFormat:@"MM-dd"];
        }
        timeStr = [dateFormatter stringFromDate:orderDate];
    }else if (time == 0) {
        [dateFormatter setDateFormat:@"HH:mm"];
        timeStr = [dateFormatter stringFromDate:orderDate];
    }else {
        time *= -1;
        if (time / 60 /60  <=0 ) {
            timeStr =[NSString stringWithFormat:@"%.0f分钟后",time / 60.f];
        }else if(time / 60 / 60 >0 && time / 60 / 60  / 24 <=0 ){
            timeStr =[NSString stringWithFormat:@"%.0f小时后",time / 60.f / 60.f ];
        }else{
            timeStr =[NSString stringWithFormat:@"%.0f天后",time / 60.f / 60.f / 24.f];
        }
    }
    return timeStr;
}

+ (NSString *)stringForNow {
    NSDate *now =[NSDate date];
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
	NSString *dateString = [dateFormat stringFromDate:now];
	[dateFormat release];
	dateFormat = nil;
    return dateString;
}

+ (double)timestampOfCurrent {
    return [[NSDate date] timeIntervalSince1970];
}

#pragma mark - ftp settings

+ (void)preferenceFTPSettings:(NSDictionary *)dic {
    
}

#pragma mark - get icon

+ (NSString *)getAppIcon {
#if APP_TYPE == APP_TYPE_EMBA
    return @"Icon.png";
#elif APP_TYPE == APP_TYPE_CIO
    return @"cio_Icon.png";
#elif APP_TYPE == APP_TYPE_O2O
    return @"o2o_Icon.png";
#endif
}

#pragma mark -- study
+ (NSString *)getChapterFilePath:(ChapterList *)chapter
{
    NSString *localFileName = @"";
    NSString *extension = [chapter.chapterFileURL pathExtension];
    extension = [extension lowercaseString];
    if ([extension isEqualToString:@"mp4"] ) {
        
        localFileName =  [NSString stringWithFormat:@"%@/%@.mp4", [CommonMethod getLocalTrainingDownloadFolder],[CommonMethod convertURLToLocal:chapter.chapterFileURL withId:[chapter.chapterID stringValue]]];
    }else{
        localFileName =  [NSString stringWithFormat:@"%@/%@", [CommonMethod getLocalTrainingDownloadFolder],[CommonMethod convertURLToLocal:chapter.chapterFileURL withId:[chapter.chapterID stringValue]]];
        //        localFileName = [NSString stringWithFormat:@"%@%@", [CommonMethod getLocalTrainingDownloadFolder], [CommonMethod convertURLToLocal:chapter.chapterFileURL]];
    }
    
    return localFileName;
}

+ (NSString *)getChapterZipFilePath:(ChapterList *)chapter {
    return [NSString stringWithFormat:@"%@/%@",[CommonMethod getLocalTrainingDownloadFolder],[[[chapter.chapterFileURL lastPathComponent] componentsSeparatedByString:@"\\"] lastObject]];
}

+ (NSString *)getChapterZipFileFolderPath:(ChapterList *)chapter {
    return [NSString stringWithFormat:@"%@/%@",[CommonMethod getLocalTrainingDownloadFolder], [[[[chapter.chapterFileURL lastPathComponent] componentsSeparatedByString:@"\\"] lastObject] stringByDeletingPathExtension]];
}

//------------o2o orderlist----------

+ (NSString *)messageIdFromUUID {
    return [[[CommonMethod GetUUID] lowercaseString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

+ (NSString *)URLForGetOrderList:(NSString *)customerId
                            page:(int)page
                        pageSize:(int)pageSize
                       timestamp:(long long int)timestamp
                          status:(int)status {
    return [NSString stringWithFormat:@"%@?dataType=%@&%@=%@&%@=%d&%@=%d&%@=%lld&%@=%d",API_SERVICE_O2O, KEY_API_NAME_GET_ORDER_LIST, KEY_API_PARAM_CUSTOMER_ID, customerId, KEY_API_PARAM_PAGE, page, KEY_API_PARAM_PAGE_SIZE, pageSize, KEY_API_PARAM_TIME_STAMP, timestamp, KEY_API_PARAM_STATUS, status];
}

+ (NSString *)URLForGetUserMessageList:(NSString *)customerId
                                unitId:(NSString *)unitId
                                userId:(NSString *)userId
                             timestamp:(long long)timestamp
                              pageSize:(int)pageSize
                      displayIndexLast:(int)displayIndexLast
                               vipType:(int)vipType {
    /*
     1 专家 2 客服 3 达人
     */
    return [NSString stringWithFormat:@"%@?dataType=%@&%@=%@&%@=%@&%@=%@&%@=%lld&%@=%d&%@=%d&vipType=%d",API_SERVICE_O2O, KEY_API_NAME_GET_USER_MESSAGE_LIST, KEY_API_PARAM_CUSTOMER_ID, customerId, KEY_API_PARAM_UNIT_ID, unitId, KEY_API_PARAM_USER_ID, userId, KEY_API_PARAM_TIME_STAMP, timestamp, KEY_API_PARAM_PAGE_SIZE, pageSize, KEY_API_PARAM_DISPLAY_INDEX_LAST, displayIndexLast, vipType];
}

+ (NSString *)URLForSubmitUserMessage:(NSString *)customerId
                               unitId:(NSString *)unitId
                               userId:(NSString *)userId {
    return [NSString stringWithFormat:@"%@?dataType=%@&%@=%@&%@=%@&%@=%@&",API_SERVICE_O2O, KEY_API_SUBMIT_UER_MESSAGE, KEY_API_PARAM_CUSTOMER_ID, customerId, KEY_API_PARAM_UNIT_ID, unitId, KEY_API_PARAM_USER_ID, userId];
}

+ (NSString *)URLForServiceWithAction:(NSString *)action
                         specialParam:(NSDictionary *)specparam;
{
    
    NSDictionary *param = @{@"common": @{@"locale":@"zh",
                                         @"userId":[AppManager instance].vipID,
                                         @"openId":@"",
                                         @"customerId":[AppManager instance].customerID},
                            @"special":specparam};
	return SPRINTF(@"%@OnlineShopping/data/Data.aspx?action=%@&ReqContent=%@", O2O_SERVER_BASE_URL, action, [[param JSONString] encodedURLString]);
}

+ (NSString *)URLForO2OLogin:(NSString *)customerName
                    userName:(NSString *)userName
                    password:(NSString *)password {
    return @"";
}

+ (NSString *)URLForGetVipDetail:(NSString *)openId
                          userId:(NSString *)userId
                    specialParam:(NSDictionary *)sepcparam {
    /*
     {"common":{"deviceToken":"","osInfo":"6.1","userId":"276683cddb144cfdb8eae106ad2fd81c","sessionId":"","openId":"o8Y7EjlvkNvWFpj-o1hvASKiIcfc","channel":"1","locale":"zh","version":"1.5.2","plat":"iPhone"},"special":{"page":"1","pageSize":"20"}}
     */
    
    NSDictionary *param = @{@"common": @{@"locale":@"zh",
                                         @"userId":userId,
                                         @"openId":openId,
                                         @"sessionId" : @"",
                                         @"plat" : @"iPhone",
                                         @"channel" : @"1",
                                         @"version" : @"1.0.9",
                                         @"osInfo" : @"7.0",
                                         @"deviceToken" : [AppManager instance].deviceToken},
                            @"special":sepcparam};
	return SPRINTF(@"%@?action=%@&ReqContent=%@", O2O_CLOUD_SERVER_BASE_URL, KEY_API_NAME_GET_VIP_DETAIL, [[param JSONString] encodedURLString]);
}

+ (NSString *)URLForGetItemKeep:(NSString *)openId
                         userId:(NSString *)userId
                   specialParam:(NSDictionary *)specparam {
    NSDictionary *param = @{@"common": @{@"locale":@"zh",
                                         /*@"userId": userId,*/
                                         @"openId": openId,//@"o8Y7Ejn8rEqD9L1rnlmBg1aMBM6o",
                                         @"sessionId" : @"",
                                         @"plat" : @"iPhone",
                                         @"channel" : @"1",
                                         @"version" : @"1.0.9",
                                         @"osInfo" : @"7.0",
                                         @"customerId" : @"f6a7da3d28f74f2abedfc3ea0cf65c01",// [AppManager instance].customerID,
                                         @"deviceToken" : [AppManager instance].deviceToken},
                            @"special":specparam};
	return SPRINTF(@"%@?action=%@&ReqContent=%@", O2O_CLOUD_SERVER_BASE_URL, KEY_API_NAME_GET_ITEM_KEEP, [[param JSONString] encodedURLString]);
}

+ (NSString *)URLForGetVipTags:(NSString *)openId
                        userId:(NSString *)userId
                  specialParam:(NSDictionary *)specparam {
    NSDictionary *param = @{@"common": @{@"locale":@"zh",
                                         @"userId":userId,
                                         @"openId":openId,
                                         @"sessionId" : @"",
                                         @"plat" : @"iPhone",
                                         @"channel" : @"1",
                                         @"version" : @"1.0.9",
                                         @"osInfo" : @"7.0",
                                         @"deviceToken" : [AppManager instance].deviceToken},
                            @"special":specparam};
	return SPRINTF(@"%@?action=%@&ReqContent=%@", O2O_CLOUD_SERVER_BASE_URL, KEY_API_NAME_GET_VIP_TAGS, [[param JSONString] encodedURLString]);
}

//------------ send method

+ (void)sendWithPostMethod:(NSString *)url
               requestData:(NSDictionary *)data
                   success:(void (^)(void))success
                    failed:(void (^)(void))failed {
    
    HttpClientSyn *http = [[HttpClientSyn alloc] init];
    NSMutableURLRequest *req = [NSMutableURLRequest POSTRequestForURL:url
                                                         withJSONData:[data JSONData]];
    NSDictionary *resp = [http sendRequestForJSONResponse:req];
    
    DLog(@"data:%@ resp:%@",data, resp);
    
    if(resp) {
        NSString *code = [resp objectForKey:RET_CODE_NAME];
        
        if([@"200" isEqualToString:code]) {
            
            success();
        }else {
            
            failed();
        }
    }else {
        failed();
    }
    [http release];
}

//------------tables--------

+ (NSArray *)tableNames {
    return [NSArray arrayWithObjects:
            //                                     @"user",
            @"userProfile",
            @"aloneMarketing",
            @"bookList",
            @"businessCategoryInfo",
            @"businessDetailImages",
            @"businessDetailInfo",
            @"chapterListInfo",
            @"chats",
            @"circleMarketingApply",
            @"circleMarketingImage",
            @"circleMarketingInfo",
            @"commonTable",
            @"communicateGroupList",
            @"courseInfo",
            @"courseListInfo",
            @"images",
            @"infoList",
            @"infoScrollWallImages",
            @"orderList",
            nil];
}


//---------update
+(void)update:(NSString *)urlStr
{
    if (urlStr && ![urlStr isEqualToString:@""]) {
        NSURL *url = [NSURL URLWithString:urlStr];
        
        if ([[url scheme] hasPrefix:@"itms-services"])
        {
            
            if (![[UIApplication sharedApplication] openURL:url]){
                DLog(@"%@%@",@"Failed to open url:",[url description]);
            }
        }
    }
}

//----------commit deviceToken

+ (void)commitDeviceToken {
    NSString *url = [CommonMethod URLForServiceWithAction:KEY_API_SET_IOS_DEVICE_TOKEN
                                             specialParam:@{@"DeviceToken":[AppManager instance].deviceToken}];
    DLog(@"call remote service at: '%@'", url);
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
	[request startSynchronous];
	NSError *error = [request error];
    NSDictionary *resp = nil;
	if (!error) {
        NSString *respstr = [request responseString];
		DLog(@"Response %@", respstr);
        resp = [respstr objectFromJSONString];
	} else {
		DLog(@"Failed to commit deviceToken, error = '%@'", error.description);
	}
    
    if(resp) {
        DLog(@"Suacceeded to commit deviceToken, respones = %@", resp.description);
    } else {
        DLog(@"Failed to commit deviceToken");
    }
}

@end
