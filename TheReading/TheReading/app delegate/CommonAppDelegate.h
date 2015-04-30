//
//  CommonAppDelegate.h
//  PublicLibrary
//
//  Created by grenlight on 14-5-28.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WYRootViewController;

@interface CommonAppDelegate : NSObject
{
    UIViewController  *rootViewController;
}
@property (nonatomic, assign) UIWindow  *appWindow;
//是否已加载分类
@property (nonatomic, assign) BOOL      isLoadedCategories;

+ (CommonAppDelegate *)sharedInstance;

- (void)appConfig;

- (void)appInit;

- (void)intoRootViewController;

@end
