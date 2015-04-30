//
//  ZYBasicHTTPRequest.m
//  YuanYang
//
//  Created by grenlight on 14/6/21.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "OWBasicHTTPRequest.h"

@implementation OWBasicHTTPRequest

- (id)init
{
    if (self = [super init]) {
        cdd = [LYCoreDataDelegate sharedInstance];
    }
    return self;
}

- (void)cancelRequest
{
    [httpRequest cancel];
}

- (void)dealloc
{
    [self cancelRequest];
    completionBlock = nil;
    faultBlock = nil;
}
@end
