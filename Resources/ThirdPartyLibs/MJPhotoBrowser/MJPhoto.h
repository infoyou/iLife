//
//  MJPhoto.h
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 jit. All rights reserved.

#import <Foundation/Foundation.h>

@interface MJPhoto : NSObject
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) UIImage *image; // 完整的图片

@property (nonatomic, retain) UIImageView *srcImageView; // 来源view
@property (nonatomic, retain, readonly) UIImage *placeholder;
@property (nonatomic, retain, readonly) UIImage *capture;

@property (nonatomic, assign) BOOL firstShow;

// 是否已经保存到相册
@property (nonatomic, assign) BOOL save;
@property (nonatomic, assign) int index; // 索引
@end