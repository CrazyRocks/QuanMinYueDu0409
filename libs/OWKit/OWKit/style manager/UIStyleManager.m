//
//  UIStyleManager.m
//  PublicLibrary
//
//  Created by grenlight on 14-1-13.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "UIStyleManager.h"
#import "OWColor.h"

@implementation UIStyleManager

+ (UIStyleManager *)sharedInstance
{
    static UIStyleManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[UIStyleManager alloc] init];
    });
    return instance;
}

- (BOOL)styleFileLoadedAlready
{
    if (styleDictionary && styleDictionary.count > 0)
        return YES;
    else
        return NO;
}

- (void)parseStyleFile:(NSString *)fileName
{
    [self parseStyleFile:fileName inBundle:[NSBundle mainBundle]];
}

- (void)parseStyleFile:(NSString *)fileName inBundle:(NSBundle *)bundle
{
    NSString *path = [bundle pathForResource:fileName ofType:@"plist"];
    NSDictionary *rootDict = [NSDictionary dictionaryWithContentsOfFile:path];
    
    styleDictionary = [[NSMutableDictionary alloc] init];
    
    for (NSString *keyName in rootDict) {
        UIStyleObject *style = [self generateStyleObject:rootDict[keyName]];
        [styleDictionary setObject:style forKey:keyName];
    }
}

- (UIStyleObject *)generateStyleObject:(NSDictionary *)dict
{
    UIStyleObject *style = [[UIStyleObject alloc] init];
    
    for (NSString *key in dict) {
        id value = [dict objectForKey:key];
        
        if ([key isEqualToString:@"background"]) {
            style.background = [OWColor colorWithHexString:(NSString *)value];
        }
        
        else if ([key isEqualToString:@"useBackgroundImage"]) {
            style.useBackgroundImage =  [value boolValue];
        }
        
        else if ([key isEqualToString:@"background-image"]) {
            style.background_Image =  (NSString *)value;
        }
        
        else if ([key isEqualToString:@"font-color"]) {
            style.fontColor = [OWColor colorWithHexString:(NSString *)value];
        }
        
        else if ([key isEqualToString:@"shadow-color"]) {
            style.shadowColor = [OWColor colorWithHexString:(NSString *)value];
        }
        
        else if ([key isEqualToString:@"shadow-width"]) {
            style.shadowWidth = [value floatValue];
        }
        
        else if ([key isEqualToString:@"font-size"]) {
            style.fontSize = [value floatValue];
        }
        
        else if ([key isEqualToString:@"background-selected"]) {
            style.background_selected = [OWColor colorWithHexString:(NSString *)value];
        }
        
        else if ([key isEqualToString:@"font-color-selected"]) {
            style.fontColor_selected = [OWColor colorWithHexString:(NSString *)value];
        }
        else if ([key isEqualToString:@"background-gradient"]) {
            style.gradientBackground = [OWColor gradientColorWithHexString:(NSString *)value];
        }
        
        else if ([key isEqualToString:@"background-gradient-selected"]) {
            style.gradientBackground_selected = [OWColor gradientColorWithHexString:(NSString *)value];
        }
        
        else if ([key isEqualToString:@"verticle-line-color"]) {
            style.vLineColor = [OWColor colorWithHexString:(NSString *)value];
        }
        
        else if ([key isEqualToString:@"verticle-line-width"]) {
            style.vLineWidth = [value floatValue];
        }
        
        else if ([key isEqualToString:@"horizontal-line-color"]) {
            style.hLineColor = [OWColor colorWithHexString:(NSString *)value];
        }
        
        else if ([key isEqualToString:@"horizontal-line-width"]) {
            style.hLineWidth = [value floatValue];
        }
        
        else if ([key isEqualToString:@"border-width"]) {
            style.borderWidth = [value floatValue];
        }
        
        else if ([key isEqualToString:@"border-color"]) {
            style.borderColor = [OWColor colorWithHexString:(NSString *)value];
        }
        
        else if ([key isEqualToString:@"fill-color"]) {
            style.fillColor = [OWColor colorWithHexString:(NSString *)value];
        }
        
        else if ([key isEqualToString:@"corner-radius"]) {
            style.cornerRadius = [value floatValue];
        }
        
        else if ([key isEqualToString:@"border-color-selected"]) {
            style.borderColor_selected = [OWColor colorWithHexString:(NSString *)value];
        }
    }
    return  style;
}

- (UIStyleObject *)getStyle:(NSString *)styleName
{
    return [styleDictionary objectForKey:styleName];
}
@end
