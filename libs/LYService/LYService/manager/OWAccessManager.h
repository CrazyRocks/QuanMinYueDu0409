//
//  OWAccessManager.h
//  PublicLibrary
//
//  Created by grenlight on 14-3-12.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OWAccessManager : NSObject
{
    NSMutableDictionary *catData;
}
//已经刷新过了的分类
@property (nonatomic, strong) NSMutableSet  *refreshedCategories;

+ (OWAccessManager *)sharedInstance;

- (void)saveRefreshedCategory:(NSString *)cid;
- (BOOL)isRefreshedCategory:(NSString *)cid;

- (void)saveRefreshedCategory:(NSString *)cid listData:(NSArray *)data;
- (NSArray *)getListByCategory:(NSString *)cid;

- (void)removeCategory:(NSString *)cid;

@end
