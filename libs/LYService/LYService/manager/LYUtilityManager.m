//
//  LYUtilityManager.m
//  LYService
//
//  Created by grenlight on 15/1/3.
//  Copyright (c) 2015年 grenlight. All rights reserved.
//

#import "LYUtilityManager.h"

@implementation LYUtilityManager

+ (NSArray *)filterDictionaryNilValue:(NSArray *)arr
{
    NSMutableArray *newArray = [NSMutableArray new];
    for (NSDictionary *item in arr) {
        NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
        for (NSString *key in item) {
            id value = item[key];
            if (value) {
                if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
                    [info setObject:value forKey:key];
                }
                else if ([value isKindOfClass:[NSArray class]]) {
                    
                }
                else {
                    [info setObject:@"" forKey:key];
                }
            }
        }
        [newArray addObject:info];
    }
    return newArray;
}

+ (NSString *)stringByTrimmingAllSpaces:(NSString *)str
{
    NSString *newStr = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    newStr = [newStr stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
    newStr = [newStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    newStr = [self stringByRemoveHTMLTags:newStr];
    
    return newStr;
}

+ (NSString *)stringByRemoveHTMLTags:(NSString *)str
{
    NSRange r;
    NSString *newStr = [self stringByDecodingXMLEntities:str];
//    NSString *newStr = [str copy];

    while ((r = [newStr rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound) {
        newStr = [newStr stringByReplacingCharactersInRange:r withString:@""];
    }
//    while ((r = [newStr rangeOfString:@"&lt;[^&gt;]+&gt;" options:NSRegularExpressionSearch]).location != NSNotFound) {
//        newStr = [newStr stringByReplacingCharactersInRange:r withString:@""];
//    }
    return newStr;
}

+ (NSString *)stringByDecodingXMLEntities:(NSString *)str
{
    NSUInteger myLength = [str length];
    NSUInteger ampIndex = [str rangeOfString:@"&" options:NSLiteralSearch].location;
    
    if (ampIndex == NSNotFound) {
        return str;
    }
    // Make result string with some extra capacity.
    NSMutableString *result = [NSMutableString stringWithCapacity:(myLength * 1.25)];
    
    NSScanner *scanner = [NSScanner scannerWithString:str];
    do {
        // Scan up to the next entity or the end of the string.
        NSString *nonEntityString;
        if ([scanner scanUpToString:@"&" intoString:&nonEntityString]) {
            [result appendString:nonEntityString];
        }
        if ([scanner isAtEnd]) {
            goto finish;
        }
        // Scan either a HTML or numeric character entity reference.
        if ([scanner scanString:@"&amp;" intoString:NULL])
            [result appendString:@"&"];
        else if ([scanner scanString:@"&apos;" intoString:NULL])
            [result appendString:@"'"];
        else if ([scanner scanString:@"&quot;" intoString:NULL])
            [result appendString:@"\""];
        else if ([scanner scanString:@"&lt;" intoString:NULL])
            [result appendString:@"<"];
        else if ([scanner scanString:@"&gt;" intoString:NULL])
            [result appendString:@">"];
        else if ([scanner scanString:@"&#" intoString:NULL]) {
            BOOL gotNumber;
            unsigned charCode;
            NSString *xForHex = @"";
            
            // Is it hex or decimal?
            if ([scanner scanString:@"x" intoString:&xForHex]) {
                gotNumber = [scanner scanHexInt:&charCode];
            }
            else {
                gotNumber = [scanner scanInt:(int*)&charCode];
            }
            if (gotNumber) {
                [result appendFormat:@"%C", (unichar)charCode];
            }
            else {
                NSString *unknownEntity = @"";
                [scanner scanUpToString:@";" intoString:&unknownEntity];
                [result appendFormat:@"&#%@%@;", xForHex, unknownEntity];
            }
            [scanner scanString:@";" intoString:NULL];
        }
        else {
            NSString *unknownEntity = @"";
            [scanner scanUpToString:@";" intoString:&unknownEntity];
            NSString *semicolon = @"";
            [scanner scanString:@";" intoString:&semicolon];
            [result appendFormat:@"%@%@", unknownEntity, semicolon];
        }
    }
    while (![scanner isAtEnd]);
    
finish:
    return result;
}


+ (NSString *)magazineCycleByType:(NSNumber *)type
{
    NSString *cycle;
    switch ([type integerValue]) {
        case 1:
            cycle = @"周刊";
            break;
        case 2:
            cycle = @"半月刊";
            break;
        case 3:
            cycle = @"月刊";
            break;
        case 4:
            cycle = @"双月刊";
            break;
        case 5:
            cycle = @"季刊";
            break;
        case 6:
            cycle = @"旬刊";
            break;
        case 7:
            cycle = @"双周刊";
            break;
        case 8:
            cycle = @"半年刊";
            break;
        case 9:
            cycle = @"年刊";
            break;
        default:
            break;
    }
    return cycle;
}
@end
