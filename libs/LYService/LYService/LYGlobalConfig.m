//
//  LYGlobalConfig2.m
//  LYMagazineService
//
//  Created by grenlight on 13-12-23.
//  Copyright (c) 2013年 OOWWWW. All rights reserved.
//

#import "LYGlobalConfig.h"

@implementation LYGlobalConfig

+ (LYGlobalConfig *)sharedInstance
{
    static LYGlobalConfig *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LYGlobalConfig alloc] init];
    });
    return instance;
    
}

- (id)init
{
    if (self=[super init]) {
        self.allowToShare = NO;
        self.versionOfTheArticleDetailView = 1;
        if (isiOS7) {
            self.statusBarStyle = UIStatusBarStyleLightContent;
        }
    }
    return self;
}

- (void)setApiDomain:(NSString *)apiDomain
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:apiDomain forKey:@"API_DOMAIN"];
    [defaults synchronize];
}

- (NSString *)apiDomain
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"API_DOMAIN"];
}

@end
