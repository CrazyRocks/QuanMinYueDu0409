//
//  LYBookHelper.h
//  LYBookStore
//
//  Created by grenlight on 14/7/21.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIStyleObject;

@interface LYBookHelper : NSObject

+ (UIImage *)imageNamed:(NSString *)imageName;

+ (UIStyleObject *)styleNamed:(NSString *)styleName;

+ (BOOL)isNightMode;

//生成书的唯一标识
+ (NSString *)generateBookGUID:(NSString *)bn;

+ (NSString *)md5:(NSString *)str;

@end
