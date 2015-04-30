//
//  GlobalManager.m
//  LongYuanYueDu
//
//  Created by gren light on 12-10-26.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import "GlobalManager.h"

@implementation GlobalManager

static GlobalManager *instance;

@synthesize currentNavigationState;

+(GlobalManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        instance = [[GlobalManager alloc] init];
    });
    return  instance;
}

-(void)intoSearchModel
{
    
}

-(void)quitSearchModel
{
    
}

-(void)setNavigationState:(MainNavigationBarStatus)state
{
    currentNavigationState = state;
    [[NSNotificationCenter defaultCenter] postNotificationName:NAVIGATIONSTATUS_CHANGED object:nil];
}

@end
