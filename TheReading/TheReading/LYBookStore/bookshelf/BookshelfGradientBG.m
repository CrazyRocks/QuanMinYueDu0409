//
//  BookshelfGradientBG.m
//  KWFBooks
//
//  Created by 龙源 on 13-10-10.
//
//

#import "BookshelfGradientBG.h"
#import <OWKit/OWKit.h>
#import <LYService/LYGlobalConfig.h>

@implementation BookshelfGradientBG

static float gradientHeight = 144;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *image = [UIImage imageNamed:@"bookshelf_bg"];
        CGRect rect = CGRectMake(0, 0, appWidth, 144*5);
        frontImageView = [[UIView alloc] initWithFrame:rect];
        backImageView = [[UIView alloc] initWithFrame:rect];
        backImageView.backgroundColor = [UIColor colorWithPatternImage:image];
        frontImageView.backgroundColor = [UIColor colorWithPatternImage:image];
        [self addSubview:frontImageView];
        
        frontCenter = frontImageView.center;
        backCenter = frontCenter;
        frontCenter.y -= gradientHeight;
        
        [frontImageView setCenter:frontCenter];
        [backImageView setCenter:backCenter];
        [self insertSubview:backImageView belowSubview:frontImageView];
        
        offsetCount = 0;
        currentOffsetY = 0;
    }
    return self;
}

- (void)setContentOffsetY:(float)offsetY
{
    NSInteger gradientCount = floorf(offsetY/gradientHeight);
    float newOffsetY = offsetY - gradientCount*gradientHeight;
    
    [frontImageView setCenter:CGPointMake(frontCenter.x, frontCenter.y - newOffsetY)];
    [backImageView setCenter:CGPointMake(backCenter.x, backCenter.y - newOffsetY)];

    float alpha = 1 - newOffsetY/gradientHeight;
    [frontImageView setAlpha:alpha];
    currentOffsetY = offsetY;
    
}

@end
