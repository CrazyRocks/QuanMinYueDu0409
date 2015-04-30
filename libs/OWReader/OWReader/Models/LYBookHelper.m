//
//  LYBookHelper.m
//  LYBookStore
//
//  Created by grenlight on 14/7/21.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "LYBookHelper.h"
#import "LYBookSceneManager.h"
#import <CommonCrypto/CommonDigest.h>

@implementation LYBookHelper

+ (UIImage *)imageNamed:(NSString *)imageName
{
    NSBundle *bundle = [LYBookSceneManager manager].assetsBundle;
    return [OWImage imageWithName:[NSString stringWithFormat:@"%@@2x", imageName]
                           bundle:bundle];
}

+ (UIStyleObject *)styleNamed:(NSString *)styleName
{
    return [[LYBookSceneManager manager].styleManager getStyle:styleName];
}

+ (BOOL)isNightMode
{
    NSString *sceneMode = [[LYBookSceneManager manager] sceneMode];
    if ([sceneMode isEqualToString:@"night"]) {
        return YES;
    }
    else {
        return NO;
    }
}

+ (NSString *)generateBookGUID:(NSString *)bn
{
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
//    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
//    [dateFormatter setDateFormat:@"yyyyMMddHHmmssSSS"];
//    NSString *bid = [dateFormatter stringFromDate:[NSDate date]];
//    bid = [bid stringByAppendingString:bn];
//    bid = [LYBookHelper md5:bid];
    
    return [LYBookHelper md5:bn];
}


+ (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}
@end
