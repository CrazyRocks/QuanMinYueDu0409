//
//  NSString+DrawSize.m
//  LYCommonLibrary
//
//  Created by grenlight on 14-5-9.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import "NSString+DrawSize.h"

@implementation NSString (DrawSize)

- (CGSize)sizeWithFont:(UIFont *)font width:(float)width
{
    CGSize size;
    if (isiOS7) {
        NSDictionary *attribute = @{NSFontAttributeName: font};
        CGRect rect=[self boundingRectWithSize:CGSizeMake(width, 5000) options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil];
        size = rect.size;
    }
    else {
        size = [self sizeWithFont:font constrainedToSize:CGSizeMake(width, 5000) lineBreakMode:NSLineBreakByWordWrapping];
    }
    return size;
}
@end
