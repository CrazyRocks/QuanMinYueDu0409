//
//  AppDelegate.h
//  优阅X版
//
//  Created by grenlight on 14-1-22.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    UIView *statusBarBg;
}
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) UINavigationController  *navController;

+ (AppDelegate *)sharedInstance;

@end
