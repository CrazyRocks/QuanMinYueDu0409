//
//  GLValidate.m
//  LogicBook
//
//  Created by iMac001 on 12-4-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GLValidate.h"

@implementation GLValidate

+(BOOL)isValidateEmail:(NSString *)email {
//    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
//    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
//    return [emailTest evaluateWithObject:email];

    NSString *regExPattern = @"^[A-Z0-9._%+-]+@[A-Z0-9.-]+.[A-Z]{2,4}$";
    return [GLValidate validate:email byRegExPattern:regExPattern];

}

+(BOOL)isVAlidateString:(NSString *)str length:(uint)len{
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(str.length > len)
        return true;
    return false;
}

+ (BOOL)isValidateCellPhone:(NSString *)cellPhone
{
    NSString *regExPattern = @"^(13[0-9]|15[012356789]|17[678]|18[0-9]|14[57])[0-9]{8}$";
    
    BOOL result = [GLValidate validate:cellPhone byRegExPattern:regExPattern];
    if (!result) {
        //美国或加拿大的手机号
        regExPattern = @"^(\d{10})|(\(*[0-9]{3}\)*[\s-])[0-9]{3}-[0-9]{4}$";
    }
    return  result;
}

+ (BOOL)validate:(NSString *)str byRegExPattern:(NSString *)regExPattern
{
    if(str == nil ) return NO;
    if(str.length == 0) return NO;
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:str options:0 range:NSMakeRange(0, [str length])];
    if (regExMatches == 0)
        return NO;
    else
        return YES;
}
@end
