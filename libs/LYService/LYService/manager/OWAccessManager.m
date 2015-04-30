//
//  OWAccessManager.m
//  PublicLibrary
//
//  Created by grenlight on 14-3-12.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "OWAccessManager.h"

@implementation OWAccessManager

+ (OWAccessManager *)sharedInstance
{
    static OWAccessManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[OWAccessManager alloc] init];
    });
    return instance;
}

- (id)init
{
    if (self = [super init]) {
        self.refreshedCategories = [[NSMutableSet alloc] init];
        catData = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)saveRefreshedCategory:(NSString *)cid
{
    if (![self isRefreshedCategory:cid]) {
        [self.refreshedCategories addObject:cid];
    }
}

- (void)saveRefreshedCategory:(NSString *)cid listData:(NSArray *)data
{
    [self saveRefreshedCategory:cid];
    [catData setObject:data forKey:cid];
}

- (NSArray *)getListByCategory:(NSString *)cid
{
    return [catData objectForKey:cid];
}

- (void)removeCategory:(NSString *)cid
{
    if ([catData objectForKey:cid])
        [catData removeObjectForKey:cid];
    
    [self.refreshedCategories removeObject:cid];
}

- (BOOL)isRefreshedCategory:(NSString *)cid
{
    return [self.refreshedCategories containsObject:cid];
}

@end
