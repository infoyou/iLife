//
//  ALSweepViewController.h
//  Aladdin
//
//  Created by user on 14-6-13.
//  Copyright (c) 2014年 com.jit. All rights reserved.
//

#import "RootViewController.h"
#import "ZBarSDK.h"

@interface ALSweepViewController : RootViewController < ZBarReaderViewDelegate >
{
    ZBarReaderView *readerView;
    UITextView *resultText;
    ZBarCameraSimulator *cameraSim;
}

@property (nonatomic,strong)  IBOutlet  ZBarReaderView                  *readerView;

@property(nonatomic,strong)                     NSString                 *itemId;

@property(nonatomic,strong)                     NSString                 *customerId;


#pragma mark -Get Item Id  And CustomerId
-(void) parseParam:(NSArray *) param;


@end

