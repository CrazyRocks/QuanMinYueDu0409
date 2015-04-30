//
//  AudioCommon.m
//  OWCoreText
//
//  Created by grenlight on 14/10/28.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "AudioCommon.h"

@implementation AudioCommon

+(AudioCommon *)sharedInstance
{
    static dispatch_once_t onceToken;
    static AudioCommon *instance;
    
    dispatch_once(&onceToken, ^{
        instance = [[AudioCommon alloc] init];
    });
    
    return instance;
}

@end
