//
//  ImageModuleViewController.m
//  Project
//
//  Created by Adam on 14-7-16.
//  Copyright (c) 2013年 jit. All rights reserved.
//

#import "ImageModuleViewController.h"
#import "UIImageView+WebCache.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"

#define IMAGE_WITH_IMAGE_NAME(name)     [UIImage imageNamed:name]

@interface ImageModuleViewController ()

@property (nonatomic, retain)    NSMutableArray *_urls;
@end

@implementation ImageModuleViewController
@synthesize _urls;

- (void)dealloc {
    
    RELEASE_OBJ(_urls);
    [super dealloc];
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC {
    
    self = [super initWithMOC:MOC];
    
    if (self) {
//        self.parentVC = pVC;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // 0.图片链接
    _urls = [[NSMutableArray alloc] initWithObjects:@"http://pic8.nipic.com/20100722/3650425_094421959608_2.jpg",
              @"http://pic7.nipic.com/20100518/3409334_031036043513_2.jpg",
              @"http://pic7.nipic.com/20100522/1263764_000410773639_2.jpg",
              @"http://pic15.nipic.com/20110809/7810872_142045323136_2.jpg",
              @"http://pic8.nipic.com/20100701/438652_161203018213_2.jpg",
              @"http://www.27270.com/uploads/tu/201211/166/4.jpg",
              @"http://img1.100ye.com/img2/4/1197/365/10795865/msgpic/61042182.jpg",
              @"http://5.26923.com/download/pic/000/324/7986c2bdc81e313f9af55ac852e37a99.jpg",
              @"http://img.cheshi-img.com/sellernews/201204/1926926372.jpg", nil];
    
	// 1.创建9个UIImageView
    UIImage *placeholder = [UIImage imageNamed:@"MJPhotoBrowser.bundle/imagePlaceholder.png"];
    
    CGFloat width = 70;
    CGFloat height = 70;
    CGFloat margin = 20;
    CGFloat startX = (self.view.frame.size.width - 3 * width - 2 * margin) * 0.5;
    CGFloat startY = 50;
    
    for (int i = 0; i<_urls.count; i++) {
        
        UIImageView *imageView = [[UIImageView alloc] init];
        
        // 计算位置
        int row = i/3;
        int column = i%3;
        CGFloat x = startX + column * (width + margin);
        CGFloat y = startY + row * (height + margin);
        imageView.frame = CGRectMake(x, y, width, height);
        
        // 下载图片
        [imageView setImageWithURL:[NSURL URLWithString:_urls[i]] placeholderImage:placeholder options:SDWebImageRetryFailed | SDWebImageLowPriority];
        
        // 事件监听
        imageView.tag = i;
        imageView.userInteractionEnabled = YES;
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)]];
        
        // 内容模式
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        [self.view addSubview:imageView];
    }
    
    [self tapImage:0];
}

- (void)showDetail:(int)showIndex
{
    
    NSArray *subviews = self.view.subviews;
    int subSize = [subviews count];
    int offset = 0;
    for (int i=0; i<subSize; i++) {
        if (![self.view.subviews[i] isKindOfClass:NSClassFromString(@"UIImageView")]) {
            offset ++;
        } else {
            break;
        }
    }
    
    int count = _urls.count;
    // 1.封装图片数据
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i<count; i++) {
        // 替换为中等尺寸图片
        NSString *url = _urls[i];
        //        [_urls[i] stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:url]; // 图片路径
        photo.srcImageView = self.view.subviews[i+offset]; // 来源于哪个UIImageView
        
        [photos addObject:photo];
    }
    
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = showIndex; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];
}

- (void)tapImage:(UITapGestureRecognizer *)tap
{
    
    [self showDetail:tap.view.tag];
}

@end
