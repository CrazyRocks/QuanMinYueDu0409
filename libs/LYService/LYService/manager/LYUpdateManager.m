//
//  LYUpdateManager.m
//  GoodSui
//
//  Created by grenlight on 13-12-17.
//  Copyright (c) 2013年 grenlight. All rights reserved.
//

#import "LYUpdateManager.h"
#import <OWKit/OWKit.h>
#import "LYGlobalConfig.h"
#import "CommonNetworkingManager.h" 

@implementation LYUpdateManager

+(LYUpdateManager *)sharedInstance
{
    static LYUpdateManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LYUpdateManager alloc] init];
    });
    return instance;
}

-(void)checkUpdate:(NSString *)appID
          complete:(void(^)())completion
             fault:(void(^)())fault
{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *url = [NSString stringWithFormat:@"%@api/ClientApp/GetLatest?",LONGYUAN_LOGIN_DOMAIN];
    __weak typeof (self) weakSelf = self;
    [CommonNetworkingManager GET:url parameters:nil completeBlock:^(NSDictionary *result) {
        [LYUpdateManager sharedInstance]->updateURL = result[@"updateurl"];
        if ([result[@"ver"] compare:version options:NSNumericSearch] == NSOrderedDescending) {
            UIAlertView *alertView =[[UIAlertView alloc] init];
            [alertView setMessage:@"有新版本啦！"];
            [alertView setDelegate: weakSelf];
            [alertView setCancelButtonIndex:1];
            [alertView addButtonWithTitle:@"现在更新"];
            [alertView addButtonWithTitle:@"以后再说"];
            [alertView show];
            
            if (completion) completion();
        }
        else {
            if (fault) fault();
        }
    } faultBlock:^(NSString *msg) {
        NSLog(@"checkUpdate Error:%@",msg);
        if (fault) fault();
    }];
   
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:updateURL]];
    }
}

@end
