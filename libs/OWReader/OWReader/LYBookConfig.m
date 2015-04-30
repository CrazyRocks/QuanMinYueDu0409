//
//  LYBookConfig.m
//  LYBookStore
//
//  Created by grenlight on 14-5-9.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import "LYBookConfig.h"

@implementation LYBookConfig

+ (LYBookConfig *)sharedInstance
{
    static LYBookConfig *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LYBookConfig alloc] init];
    });
    return instance;
}


@end
