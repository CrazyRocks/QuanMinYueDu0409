//
//  MusicControlBtn.m
//  TestAudio
//
//  Created by grenlight on 14/10/28.
//  Copyright (c) 2014年 qikan. All rights reserved.
//

#import "MusicControlBtn.h"
#import <OWCoreText/VideoIcon.h>
#import <OWCoreText/AudioCommon.h>
#import <OWKit/OWColor.h>
#import "OWAnimator.h"

@implementation MusicControlBtn

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self setup];
        
    }
    
    return self;
}

-(void)setup
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recoveryOfAnimation:) name:@"Recovery_of_animation" object:nil];
    
    self.hidden = YES;
    self.alpha = 0.0f;
    
//    self.layer.borderColor = [OWColor colorWithHexString:@"#D3D3D3"].CGColor;
//    self.layer.borderWidth = 1.0f;
//    self.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.layer.shadowOffset = CGSizeMake(1, 1);
//    self.layer.shadowOpacity = 8;
    
    colors = [[NSMutableArray alloc]init];
    
    [colors addObject:[OWColor colorWithHexString:@"#B5B5B5"]];
    [colors addObject:[OWColor colorWithHexString:@"#efa0c2"]];
    [colors addObject:[OWColor colorWithHexString:@"#b6a900"]];
    [colors addObject:[OWColor colorWithHexString:@"#004a9a"]];
    [colors addObject:[OWColor colorWithHexString:@"#7c0025"]];
    [colors addObject:[OWColor colorWithHexString:@"#cce09c"]];
    
    UIView *mask = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
    mask.layer.cornerRadius = mask.frame.size.width/2;
    mask.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    mask.backgroundColor = [OWColor colorWithHexString:@"#BB1100"];
    mask.layer.borderWidth = 0.5f;
    mask.layer.borderColor = [OWColor colorWithHexString:@"#D3D3D3"].CGColor;
    mask.userInteractionEnabled = NO;
    UILabel *lab = [[UILabel alloc]initWithFrame:mask.bounds];
    lab.text = @"M";
    lab.textAlignment = 1;
    lab.textColor = [OWColor colorWithHexString:@"#FFFFFF"];
    [lab setFont:[UIFont systemFontOfSize:9]];
    [mask addSubview:lab];
    
    self.backgroundColor = [UIColor clearColor];
    
    self.layer.cornerRadius = self.frame.size.width/2;
//    self.clipsToBounds = YES;
    _iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width-10, self.frame.size.height-10)];
    _iconImageView.backgroundColor = [UIColor blackColor];
    _iconImageView.clipsToBounds = YES;
    _iconImageView.layer.cornerRadius = _iconImageView.frame.size.width/2;
    _iconImageView.center = mask.center;
    _iconImageView.layer.borderColor = [OWColor colorWithHexString:@"#D3D3D3"].CGColor;
    _iconImageView.layer.borderWidth = 1.0f;
    [_iconImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self addSubview:_iconImageView];
    
    [self addSubview:mask];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
    
    [self addTarget:self action:@selector(showView:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.halo = [PulsingHaloLayer layer];
    self.halo.cornerRadius = 60;
    self.halo.position = self.iconImageView.center;
    self.halo.backgroundColor = [OWColor colorWithHexString:@"#ffffff"].CGColor;
    
    [self setupInitialValues];
    
    [self.layer insertSublayer:self.halo below:self.iconImageView.layer];
    
}

- (void)setupInitialValues {
    
    timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(changeColor) userInfo:nil repeats:YES];
    
}

-(void)changeColor
{
    int k = arc4random() % 6;
    
    UIColor *color = [colors objectAtIndex:k];
    
    self.halo.backgroundColor = color.CGColor;
}

-(void)setImageViewIcon:(NSURL *)url
{
    if (url) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
            UIImage *image = [VideoIcon getMessageFromAudio:url];
            
            dispatch_async(dispatch_get_main_queue(), ^{
        
                
                NSLog(@"image ======== %@",image);
                
                _iconImageView.image = image;
                [self setHidden:NO];
                
            });
            
        });

    }
}

-(void)autoPlay
{
    
    CABasicAnimation *animation;
    animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.toValue = [NSNumber numberWithFloat:M_PI*2.0];
    animation.duration = 10;
    animation.cumulative = YES;
    animation.repeatCount = 10000;
    [_iconImageView.layer addAnimation:animation forKey:@"transform.rotation.z"];
    
}

-(void)stopAnimation
{
    [_iconImageView.layer removeAllAnimations];
}


-(void)pan:(UIPanGestureRecognizer *)pan
{
    if (pan.state == UIGestureRecognizerStateBegan) {
        
    }else if (pan.state == UIGestureRecognizerStateChanged){
        
        pan.view.center = [pan locationInView:self.superview];
        
    }else if (pan.state == UIGestureRecognizerStateEnded){
        
        CGPoint endPoint = [pan locationInView:self.superview];
        
        if (endPoint.x >= self.superview.frame.size.width/2) {
            
            if (endPoint.y <= 80) {
                
                [UIView animateWithDuration:0.2 animations:^{
                    pan.view.center = CGPointMake(self.superview.frame.size.width - self.frame.size.width/2, 80+self.frame.size.height/2);
                }];
                
            }else if (endPoint.y >= self.superview.frame.size.height - 40){
                
                [UIView animateWithDuration:0.2 animations:^{
                    pan.view.center = CGPointMake(self.superview.frame.size.width - self.frame.size.width/2, self.superview.frame.size.height - 40);
                }];
                
            }else{
                
                [UIView animateWithDuration:0.2 animations:^{
                    pan.view.center = CGPointMake(self.superview.frame.size.width - self.frame.size.width/2, endPoint.y);
                }];
                
                [OWAnimator basicAnimate:self.iconImageView toScale:CGPointZero duration:0.f delay:0 completion:^{
                    
                    [OWAnimator spring:self.iconImageView toScale:CGPointMake(1, 1) delay:0];
                    
                }];
                
            }
            
        }else{
            
            if (endPoint.y <= 80) {
                
                [UIView animateWithDuration:0.2 animations:^{
                    pan.view.center = CGPointMake(self.frame.size.width/2, 80+self.frame.size.height/2);
                }];
                
            }else if (endPoint.y >= self.superview.frame.size.height - 40){
                
                [UIView animateWithDuration:0.2 animations:^{
                    pan.view.center = CGPointMake(self.frame.size.width/2, self.superview.frame.size.height - 40);
                }];
                
            }else{
                
                [UIView animateWithDuration:0.2 animations:^{
                    pan.view.center = CGPointMake(self.frame.size.width/2, endPoint.y);
                }];
                
                [OWAnimator basicAnimate:self.iconImageView toScale:CGPointZero duration:0.f delay:0 completion:^{
                    
                            [OWAnimator spring:self.iconImageView toScale:CGPointMake(1, 1) delay:0];
                    
                }];
            }
            
        }
        
    }
}


//重写隐藏动画
-(void)setHidden:(BOOL)hidden
{
    if (hidden) {
        
        [UIView animateWithDuration:0.4 animations:^{
            
            self.alpha = 0.0f;
            
        } completion:^(BOOL finished) {
            
            [super setHidden:hidden];
            
        }];
        
        
    }else{
        
        [UIView animateWithDuration:0.4 animations:^{
            
            self.alpha = 1.0f;
            
        } completion:^(BOOL finished) {
            
            [super setHidden:hidden];
            
        }];
        
    }
}



-(void)showView:(id)sender
{
    
    [OWAnimator basicAnimate:self toScale:CGPointZero duration:0.4f delay:0 completion:^{
    
//        
    }];
    
    if ([self.delegate respondsToSelector:@selector(showView:)]) {
        [self.delegate showView:sender];
    }

}

-(void)recoveryOfAnimation:(NSNotification *)notification
{
    [self autoPlay];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
