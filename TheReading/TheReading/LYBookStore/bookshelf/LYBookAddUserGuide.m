//
//  LYBookAddUserGuide.m
//  LYBookStore
//
//  Created by grenlight on 14/7/17.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "LYBookAddUserGuide.h"
#import <OWKit/OWKit.h>
#import <LYService/LYService.h>
#import "LYBookConfig.h"

@implementation LYBookAddUserGuide

+ (LYBookAddUserGuide *)sharedUserGuide
{
    static LYBookAddUserGuide *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LYBookAddUserGuide alloc] init];
        instance->addedUserGuide = NO;
    });
    return instance;
}

- (void)addUserGuide:(UIViewController *)controller
{
    if (addedUserGuide) {
        return;
    }
    addedUserGuide = YES;
    self.parentController = controller;
    if ([LYBookConfig sharedInstance].bookShelfMode == lyBorrowMode) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        if (![ud boolForKey:@"BarcodeUserGuidForFirstTime"]) {
            [ud setBool:YES forKey:@"BarcodeUserGuidForFirstTime"];
            [ud synchronize];
            userGuidView = [[UIImageView alloc] initWithFrame:controller.view.bounds];
            userGuidView.image = [OWImage imageWithName:(appHeight > 480 ? @"barcodeUserGuid_568@2x" : @"barcodeUserGuid@2x") bundle:[NSBundle bundleForClass:[self class]]];
            userGuidView.contentMode = UIViewContentModeScaleToFill;
            userGuidView.alpha = 0;
            [controller.view addSubview:userGuidView];
            [UIView animateWithDuration:0.25 animations:^{
                userGuidView.alpha = 1;
            }];
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeUserCuide)];
            tapGesture.numberOfTapsRequired = 1;
            [controller.view addGestureRecognizer:tapGesture];
        }
    }
}

- (void)removeUserCuide
{
    if (!userGuidView || !addedUserGuide)
        return;
    
    [UIView animateWithDuration:0.2 animations:^{
        userGuidView.alpha = 0;
    } completion:^(BOOL finished) {
        [userGuidView removeFromSuperview];
        userGuidView = nil;
    }];
    
    for (UIGestureRecognizer *gesture in self.parentController.view.gestureRecognizers) {
        if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
            [self.parentController.view removeGestureRecognizer:gesture];
        }
    }
}
@end
