//
//  GLButtonParameter.m
//  KWFBooks
//
//  Created by gren light on 13-2-23.
//
//

#import "OWControlCSS.h"

@implementation OWControlCSS

@synthesize borderColor_highlight, borderColor_normal;
@synthesize shadowColor_highlight, shadowColor_normal, shadowColorOffset;
@synthesize fillColor_highlight, fillColor_normal;
@synthesize cornerRadius;
@synthesize textColor_highlight, textColor_normal;

- (id)init
{
    self = [super init];
    if (self) {
        self.cornerRadius = 3;
        self.borderWidth = 0;
    }
    return self;
}

@end
