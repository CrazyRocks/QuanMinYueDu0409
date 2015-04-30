//
//  LYUtilityManager.h
//  LYService
//
//  Created by grenlight on 15/1/3.
//  Copyright (c) 2015年 grenlight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LYUtilityManager : NSObject

+ (NSArray *)filterDictionaryNilValue:(NSArray *)arr;

//移除所有空格 &nbsp;
+ (NSString *)stringByTrimmingAllSpaces:(NSString *)str;

//移除所有html标签
+ (NSString *)stringByRemoveHTMLTags:(NSString *)str;

+ (NSString *)magazineCycleByType:(NSNumber *)type;

@end
