//
//  AppDelegate.m
//  优阅X版
//
//  Created by grenlight on 14-1-22.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "AppDelegate.h"
#import "CommonAppDelegate.h"
#import "OWAppGuide.h"
#import <LYService/LYService.h>
#import "LoginViewController.h"
#import <OWReader/BSReaderViewController.h>

@implementation AppDelegate

+ (AppDelegate *)sharedInstance
{
    return [UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [self normalLaunch];
//    [self openABookDirectly];
    
    [self performSelector:@selector(ifNeedsBlackStatusBar) withObject:nil afterDelay:0.1];
    
    [OWAppGuide show];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ifNeedsBlackStatusBar) name:@"OutEpubReader" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeStatusBarBg) name:@"IntoEpubReader" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logOut) name:@"AppLogOut" object:nil];
    
    return YES;
}

- (void)normalLaunch
{
    LoginViewController *loginController = [[LoginViewController alloc] init];
    [loginController setLoginCompleteBlock:^{
        [[CommonAppDelegate sharedInstance] intoRootViewController];
    }];
    self.navController = [[UINavigationController alloc] initWithRootViewController:loginController];
    self.navController.navigationBarHidden = YES;
    OWViewController *controller = [[OWViewController alloc] init];
    [controller addChildViewController:self.navController];
    [controller.view addSubview:self.navController.view];
    [[OWNavigationController sharedInstance] setRooController:controller];
    self.window.rootViewController = [OWNavigationController sharedInstance];
    [self.window makeKeyAndVisible];

    /*  -------------------------------------
     配置接口地址，AppID, 是否开启微博分享功能，文章翻页样式，UI样式
     
     AppID及接口地址等非UI样式的配置，需要在项目的 app config 文件夹下 ServerConfig.strings 中配置
     
     UI样式是在当前项目的 app config 文件夹下的UIStyleConfig.plist中配置
     ------------------------------------- */
    
    [CommonAppDelegate sharedInstance].appWindow = self.window;
    [[CommonAppDelegate sharedInstance] appConfig];
    
    [[CommonAppDelegate sharedInstance] appInit];
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"abc.xhtml" ofType:nil];
//    NSString *savePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    savePath = [savePath stringByAppendingPathComponent:@"20150324_2.xhtml"];
//    NSError *error;
//    [[NSFileManager defaultManager] copyItemAtPath:path toPath:savePath error:&error];
//    if (error) {
//        NSLog(@"%@",error.description);
//    }
//    else {
//        [[MyBooksManager sharedInstance] encryptFile:savePath];
//        
//        NSString *content = [[MyBooksManager sharedInstance] decryptFile:savePath];
//        NSString *text = [NSString stringWithContentsOfFile:savePath encoding:NSUTF8StringEncoding error:nil];
//
//        NSLog(@"8888 %@ 8888", text);
//    }
}

- (void)openABookDirectly
{
    self.window.rootViewController = [OWNavigationController sharedInstance];

    MyBook *book = [[MyBooksManager sharedInstance] allMyBooks][0];
    [MyBooksManager sharedInstance].currentReadBook = book;
    
    BSReaderViewController *controller = [[BSReaderViewController alloc] init];
    [[OWNavigationController sharedInstance] setRooController:controller];
    [controller openWithNoneCover];
    
    [self.window makeKeyAndVisible];
    
}

- (void)ifNeedsBlackStatusBar
{
    if (isPad) {
        if (!statusBarBg) {
            statusBarBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, appWidth, 20)];
            statusBarBg.backgroundColor = [UIColor blackColor];
        }
        [self.window addSubview:statusBarBg];
        [UIView animateWithDuration:0.3 animations:^{
            statusBarBg.alpha = 1;
        }];
        
    }
    else {
        
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)removeStatusBarBg
{
    [UIView animateWithDuration:0.3 animations:^{
        statusBarBg.alpha = 0;
    }];
}

- (void)logOut
{
    [LYAccountManager logOut];
    
    UINavigationController *navController = [AppDelegate sharedInstance].navController;
    for (UIViewController *controller in navController.viewControllers) {
        if ([controller isKindOfClass:[LoginViewController class]]) {
            [navController popToViewController:controller animated:YES];
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"applicationWillResignActive" object:nil];
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"applicationDidBecomeActive" object:nil];
}


@end
