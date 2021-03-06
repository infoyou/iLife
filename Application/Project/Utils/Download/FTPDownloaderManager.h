//
//  FTPDownloader.h
//  Project
//
//  Created by Yfeng__ on 13-11-9.
//  Copyright (c) 2013年 com.jit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KLFTPTransferItem.h"
#import "KLFTPTransfer.h"
#import "WXWDownloadInfo.h"


@interface FTPDownloaderManager : NSObject

@property (nonatomic, assign) KLFTPAccount * defaultFTPAccount;
@property (nonatomic, assign) NSMutableArray *listenerArray;
@property (nonatomic, assign) NSMutableDictionary *transferListDict;
@property (nonatomic, assign) NSMutableDictionary *downloadInfoDict;

+ (FTPDownloaderManager *)instance;

- (void)registerListener:(id)listener;
- (void)unRegisterListener:(id)listener;

- (KLFTPTransferItem *)getTransferItem:(WXWDownloadInfo *)downloadInfo;
- (KLFTPTransfer *)getTransferByItem:(KLFTPTransferItem *)transferItem;
- (KLFTPTransfer *)getTransferByDownloadInfo:(WXWDownloadInfo *)downloadInfo;
- (WXWDownloadInfo *)getDownloadInfoByUniqueKey:(NSString *)uniqueKey;
- (NSMutableDictionary *)getAllDownloadingChapter;

@end


@protocol FTPDownloaderManagerDelegate <NSObject>


@end