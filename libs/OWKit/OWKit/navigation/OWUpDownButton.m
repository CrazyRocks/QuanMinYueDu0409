//
//  UpDownButton.m
//  PublicLibrary
//
//  Created by grenlight on 14-3-6.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "OWUpDownButton.h"

@implementation OWUpDownButton

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
    
    self.backgroundColor = [UIColor clearColor];
    bgView = [[UIImageView alloc] initWithFrame:self.bounds];
    bgView.image = [UIImage imageNamed:@"UpDownButton_bg"];
    [self addSubview:bgView];
    
    iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"downRow"]];
    CGPoint center = bgView.center;
    center.x +=1;
    center.y += 1;
    iconView.center = center;
    [self addSubview:iconView];
}

- (void)setExpand:(BOOL)isExpand
{
    CGAffineTransform transform;
    float alpha ;
    if (isExpand) {
        transform = CGAffineTransformRotate(CGAffineTransformIdentity,3.14);
        alpha = 0;
    }
    else {
        transform = CGAffineTransformIdentity;
        alpha = 1;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        iconView.transform = transform;
        bgView.alpha = alpha;
    }];
}

@end
