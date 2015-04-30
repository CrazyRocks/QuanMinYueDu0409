//
//  OWBottomAlignImageView.m
//  OWKit
//
//  Created by grenlight on 14/8/7.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "OWBottomAlignImageView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation OWBottomAlignImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)updateBorder
{
    coverBottomY = CGRectGetMaxY(self.bounds);
    originalHeight = CGRectGetHeight(self.bounds);
    
    float scaleX = CGRectGetWidth(self.bounds) / self.image.size.width;
    float newHeight = scaleX * self.image.size.height;
    float y;
    if (newHeight > originalHeight) {
        newHeight = originalHeight;
        y = coverBottomY - originalHeight;
    }
    else {
        y = coverBottomY - newHeight;
    }
    if (y > 0) {
        for (NSLayoutConstraint *layout in self.constraints) {
            if (layout.firstAttribute == NSLayoutAttributeTop) {
                layout.constant = y;
            }
        }
    }
}

- (void)setImageWithURL:(NSString *)url;
{
    __weak typeof (self) weakSelf = self;
    [self sd_setImageWithURL:[NSURL URLWithString:url] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [weakSelf updateBorder];
    }];
}

@end
