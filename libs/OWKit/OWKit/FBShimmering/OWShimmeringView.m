//
//  OWShimmeringView.m
//  LYCommonLibrary
//
//  Created by grenlight on 14-5-7.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import "OWShimmeringView.h"
#import "FBShimmering.h"
#import "FBShimmeringView.h"

@implementation OWShimmeringView


- (id)initWithMessage:(NSString *)msg
{
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40);
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _frontColor = [UIColor blackColor];
        [self addShimmeringView:msg];
    }
    return self;
}

- (void)addShimmeringView:(NSString *)message
{
    shimmeringView = [[FBShimmeringView alloc] initWithFrame:self.bounds];
    shimmeringView.shimmering = YES;
    shimmeringView.shimmeringBeginFadeDuration = 0.25;
    shimmeringView.shimmeringOpacity = 0.3;
    shimmeringView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight| UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self insertSubview:shimmeringView atIndex:0];
    
    UILabel *logoLabel = [[UILabel alloc] initWithFrame:shimmeringView.bounds];
    logoLabel.font = [UIFont systemFontOfSize:22];
    logoLabel.textColor = self.frontColor;
    logoLabel.textAlignment = NSTextAlignmentCenter;
    [logoLabel setText: message];
    logoLabel.backgroundColor = [UIColor clearColor];
    shimmeringView.contentView = logoLabel;
    logoLabel = nil;
}

- (void)setFrontColor:(UIColor *)frontColor
{
    _frontColor = frontColor;
    if (shimmeringView) {
        ((UILabel *)shimmeringView.contentView).textColor = _frontColor;
    }
}

- (void)removeFromSuperview
{
    shimmeringView.shimmering = NO;
    [shimmeringView removeFromSuperview];
    shimmeringView = nil;
    
    [super removeFromSuperview];
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    
    if (hidden) {
        shimmeringView.shimmering = NO;
    }
    else {
        shimmeringView.shimmering = YES;
    }
}


- (void)dealloc
{
    shimmeringView = nil;
    _frontColor = nil;
}

@end
