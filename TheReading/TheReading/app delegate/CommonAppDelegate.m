//
//  CommonAppDelegate.m
//  PublicLibrary
//
//  Created by grenlight on 14-5-28.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "CommonAppDelegate.h"
#import <OWKit/OWKit.h>
#import "LYBookStore.h"
#import <CoreText/CoreText.h>
#import <LYService/LYGlobalConfig.h>
#import "LYUpdateManager.h"

#import "WYRootViewController.h"
#import "WYRootController_iPad.h"
#import "WYMenuManager.h"
#import "YYStandardConfig.h"
#import <LYService/LYUpdateManager.h>

@implementation CommonAppDelegate

+ (CommonAppDelegate *)sharedInstance
{
    static CommonAppDelegate *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CommonAppDelegate alloc] init];
    });
    return instance;
}

- (void)appConfig
{
    NSString *configPath = [[NSBundle mainBundle] pathForResource:@"ServerConfig" ofType:@"strings"];
    NSDictionary *d = [NSDictionary dictionaryWithContentsOfFile:configPath];
    [[LYGlobalConfig sharedInstance] setServiceName:d[@"ServiceName"]];
    [LYGlobalConfig sharedInstance].applicationID = d[@"ApplicationID"];
    [[LYUpdateManager sharedInstance] checkUpdate:d[@"AppID"] complete:nil fault:nil];
    
    NSString *allowToShare = d[@"AllowToShare"];
    if ([allowToShare isEqualToString:@"YES"]) {
        [LYGlobalConfig sharedInstance].allowToShare = YES;
    }
    
    NSNumber *version = d[@"versionOfTheArticleDetailView"];
    if ([version intValue] == 2) {
        [LYGlobalConfig sharedInstance].versionOfTheArticleDetailView = 2;
    }
    
    configPath = nil;
    d = nil;
    
    //UI样式
    [[UIStyleManager sharedInstance] parseStyleFile:@"UIStyleConfig"];
        
    [LYBookConfig sharedInstance].bookShelfMode = lyStoreMode;
}

- (void)appInit
{
    //开始监听网络状态
    [CommonNetworkingManager sharedInstance];
    [OWAppLaunch show];

    [self initCategory];
    [self initCoreText];
}

- (void)initCategory
{
//    [OWAppLaunch hide];
//    [self launchToMainNavView];
//
    //因为某些程序逻辑的调整，导致用户需要重新登录一遍才能生效
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:@"IS_RELOGIN_COMPLETED_0"]) {
        [LYAccountManager logOut];
        [defaults setBool:YES forKey:@"IS_RELOGIN_COMPLETED_0"];
        [defaults synchronize];
    }
    
    //因为书本解析，加密 逻辑等的改变，导致需要清空原有的数据
    if (![defaults boolForKey:@"Need_Clear_AllBooks_0"]) {
        [[MyBooksManager sharedInstance] clearAllBooks];
        [defaults setBool:YES forKey:@"Need_Clear_AllBooks_0"];
        [defaults synchronize];
    }

    if ([LYAccountManager isLogin]) {
        NSArray *menus = [LYAccountManager GetMenuList];
        if (menus && menus.count > 0) {
            [self intoRootViewController];
            [LYAccountManager RequestMenuList:nil fault:nil];
        }
        else {
            __weak typeof (self) weakSelf = self;
            [LYAccountManager RequestMenuList:^(id result){
                [weakSelf intoRootViewController];
            } fault:nil];
        }
    }
    else {
        [OWAppLaunch clear];
    }
}

- (void)intoRootViewController
{
    [OWAppLaunch hide];
    if (isPad) {
        rootViewController = [[WYRootController_iPad alloc] init];
    }
    else {
        rootViewController = [[WYRootViewController alloc] init];
    }
    [[AppDelegate sharedInstance].navController pushViewController:rootViewController animated:NO];
}

-(void)initCoreText
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_async(queue, ^{
        __block NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        void(^initFont)(NSString *) = ^(NSString *fontName){
            CTFontRef aFont = CTFontCreateWithName((__bridge CFStringRef)fontName, 18, NULL);
            CTFontRef aFont2  = CTFontCreateCopyWithSymbolicTraits(aFont, 18, NULL, kCTFontItalicTrait, kCTFontBoldTrait);
//            [attributes setObject:(__bridge id)(aFont2?aFont2:aFont) forKey:(id)kCTFontAttributeName];
            attributes[(id)kCTFontAttributeName] = (__bridge id)(aFont2?aFont2:aFont);
            CFRelease(aFont);
            if(aFont2)  CFRelease(aFont2);
        };
        initFont(@"bodoni 72");//Bodoni 72 Oldstyle  ||  BODONI 72 SMALLCAPS
        initFont(@"ArialMT");
        initFont(@"FZLTXHK--GBK1-0");
    });
}



@end
