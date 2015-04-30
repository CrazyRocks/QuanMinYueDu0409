//
//  OWBundleButton.m
//  OWKit
//
//  Created by grenlight on 14/7/23.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "OWBundleButton.h"

@implementation OWBundleButton

- (void)setIcon:(NSString *)iconName inBundle:(Class)bundleClass
{
    imageName = iconName;
    
    NSBundle *bundle;
    if (bundleClass) {
        bundle= [NSBundle bundleForClass:bundleClass];
    }
    else {
        bundle = [NSBundle mainBundle];
    }
    NSString *normal = [bundle pathForResource:[NSString stringWithFormat:@"%@_normal@2x",imageName] ofType:@"png"];
    if (normal) {
        [self setImage:[UIImage imageWithContentsOfFile:normal] forState:UIControlStateNormal];
    }
    
    NSString *selected = [bundle pathForResource:[NSString stringWithFormat:@"%@_selected@2x",imageName] ofType:@"png"];
    if (selected) {
        [self setImage:[UIImage imageWithContentsOfFile:selected] forState:UIControlStateHighlighted];
        [self setImage:[UIImage imageWithContentsOfFile:selected] forState:UIControlStateSelected];
    }
}


@end
