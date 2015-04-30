//
//  LYMagazineGlobal.m
//  LYMagazinesStand
//
//  Created by grenlight on 14-5-15.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import "LYMagazineGlobal.h"

@implementation LYMagazineGlobal

+ (LYMagazineGlobal *)sharedInstance
{
    static LYMagazineGlobal *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LYMagazineGlobal alloc] init];
    });
    return instance;
}


@end
