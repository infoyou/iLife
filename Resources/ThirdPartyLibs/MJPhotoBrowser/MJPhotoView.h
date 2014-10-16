//
//  MJZoomingScrollView.h
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 jit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDWebImageManager.h"

@class MJPhotoBrowser, MJPhoto, MJPhotoView;

@protocol MJPhotoViewDelegate <NSObject>

- (void)photoViewImageFinishLoad:(MJPhotoView *)photoView;
- (void)photoViewSingleTap:(MJPhotoView *)photoView;
- (void)photoViewDidEndZoom:(MJPhotoView *)photoView;

@end

@interface MJPhotoView : UIScrollView <UIScrollViewDelegate, SDWebImageManagerDelegate>

// 图片
@property (nonatomic, retain) MJPhoto *photo;
// 代理
@property (nonatomic, assign) id<MJPhotoViewDelegate> photoViewDelegate;

@end