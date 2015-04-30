//
//  FrostedGlassBackgroundView.m
//  PublicLibrary
//
//  Created by grenlight on 13-12-4.
//  Copyright (c) 2013年 grenlight. All rights reserved.
//

#import "FrostedGlassBackgroundView.h"
#import "UIImage+ImageEffects.h"
#import "OWImage.h"

@implementation FrostedGlassBackgroundView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)setup
{
    self.clipsToBounds = YES;

    self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.95];
    self.imageView =  [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.imageView.backgroundColor = [UIColor clearColor];
    [self insertSubview:self.imageView atIndex:0];
}

- (void)setCenter:(CGPoint)center
{
    [super setCenter:center];
    [self.imageView setCenter:CGPointMake(appWidth - center.x, appHeight-center.y)];
}

- (void)generateFrostedGlassImage
{
    __unsafe_unretained typeof (self) weakSelf = self;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(queue, ^{
        UIImage *image = [OWImage CompositeImage:weakSelf.frostesView];
        image = [image applyLightEffect];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.imageView setImage:image];
        });
    });
}


@end
