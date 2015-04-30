//
//  LYMenuData.m
//  LYService
//
//  Created by grenlight on 15/1/19.
//  Copyright (c) 2015年 grenlight. All rights reserved.
//

#import "LYMenuData.h"

@implementation LYMenuData

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"menuName": @"MenuName",
             @"menuType": @"MenuValue",
             @"menuValue":@"MenuValue",
             };
}

//转换MenuValue的值："article:1a,3c,b0,..."
+ (NSValueTransformer *)menuTypeJSONTransformer
{
    return [MTLValueTransformer transformerWithBlock:^id(NSString *value) {
        NSArray *arr =  [value componentsSeparatedByString:@":"];
        return arr[0];
    }];
}

+ (NSValueTransformer *)menuValueJSONTransformer
{
    return [MTLValueTransformer transformerWithBlock:^id(NSString *value) {
        NSArray *arr =  [value componentsSeparatedByString:@":"];
        if (arr.count > 1) {
            return [arr[1] componentsSeparatedByString:@","];
        }
        return [NSArray new];
    }];
}

@end
