//
//  UserDetailEditInfoVC.h
//  Project
//
//  Created by Adam on 14-6-3.
//  Copyright (c) 2013年 com.jit. All rights reserved.
//

#import "RootViewController.h"
#import "UserObject.h"
#import "MatchListViewController.h"

@protocol UserDetailEditInfoViewControllerDelegate;

@interface UserDetailEditInfoVC : RootViewController
{
    MatchListViewController *matchList;
}

@property (nonatomic, retain) MatchListViewController *matchList;
@property (nonatomic, assign) NSString *title;
@property (nonatomic, assign) id<UserDetailEditInfoViewControllerDelegate> delegate;

- (id)initWithDataModal:(UserObject *)dataModal propType:(int)propType;

@end

@protocol UserDetailEditInfoViewControllerDelegate <NSObject>

- (void)userDetailContentChanged:(BOOL)changed;

@end