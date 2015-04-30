//
//  GlobalManager.m
//  LongYuanYueDu
//
//  Created by gren light on 12-10-26.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import "LYGlobalManager.h"

@implementation LYGlobalManager

static LYGlobalManager *instance;

+(LYGlobalManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        instance = [[LYGlobalManager alloc] init];
    });
    return  instance;
}

-(void)intoSearchModel
{
    
}

-(void)quitSearchModel
{
    
}


@end
