//
//  LYCoverAnimationView.m
//  LYBookStore
//
//  Created by grenlight on 14-4-21.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import "OWCoverAnimationView.h"
#import "OWBlockDefine.h"
#import "OWImage.h"

@implementation OWCoverAnimationView


-(void)viewWithView:(UIView *)view
{
    [self viewWithImage:[OWImage CompositeImage:view]];
    
}

-(void)viewWithImage:(UIImage *)img
{
    [self cutLayersFromImage:img];
    self.frameInterval = 1;
    self.backgroundColor = [UIColor  clearColor];
}

- (UIImageView *)generateCoverView
{
    UIImageView *maskView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    maskView.backgroundColor = [UIColor blueColor];
    maskView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    maskView.contentMode = UIViewContentModeScaleToFill;
    maskView.image = coverImage;
    
    return maskView;
}

-(void)cutLayersFromImage:(UIImage *)image
{
    coverImage = image;
    if (!self.coverView) {
        self.coverView = [self generateCoverView];
        [self addSubview:self.coverView];
    }
    self.coverView.layer.anchorPoint = CGPointMake(0, 0.5);
    self.coverView.layer.position = CGPointMake(0, self.layer.position.y);
}

- (void)closeCover:(GLNoneParamBlock)callBack
{
    closeCallBack = callBack;
    
    self.hidden = NO;
    [self setOpened:YES];
}

-(void)setOpened:(BOOL)aOpened
{
    _opened = aOpened;
    if (_opened) {
        translationX = -M_PI_2;
        acceleration = 0.004f;
        speed = 0.005;
        self.hidden = NO;

    }
    else {
        translationX = 0;
        acceleration = -0.0001f;
        speed = -0.0;
    }
    [self startAnimation];
}

-(BOOL)opened
{
    return _opened;
}

-(void)enterFrame
{
    if(_opened) {
        if (translationX >= -0.01) {
            [self stopAnimation];
            self.coverView.layer.transform = CATransform3DIdentity;

            if (closeCallBack) closeCallBack();
            
            return;
        }
        speed += acceleration;

    }
    else {
        if (translationX < -M_PI_2) {
            [self stopAnimation];
            self.hidden = YES;
            return;
        }
        speed += acceleration;
        acceleration -= 0.00007;
    }
    translationX += speed;
    [self transformWithY:translationX];
    
}

-(void)transformWithY:(float)value
{
    CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
    rotationAndPerspectiveTransform.m34 = 1.0 / -1000;
    
    rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform,  value , 0.0f , 1.0f, 0.0f);
    
    self.coverView.layer.transform = rotationAndPerspectiveTransform;
}

- (void)stopAnimation
{
    [super stopAnimation];
    
}

-(void)dealloc
{
    [self stopAnimation];
}

@end
