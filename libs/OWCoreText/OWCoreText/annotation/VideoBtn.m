//
//  VideoBtn.m
//  OWCoreText
//
//  Created by grenlight on 14/10/27.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "VideoBtn.h"
#import "OWColor.h"
#import "OWAnimator.h"
#import "AudioCommon.h"

@implementation VideoBtn

-(id)initWithFrame:(CGRect)frame withOWTextAttachment:(OWTextAttachment *)att
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.attachment = att;
        
        
        [self setup];
    }
    
    return self;
}

-(id)initWithFrame:(CGRect)frame withOWTextAttachmentAudio:(OWTextAttachment *)att
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.attachment = att;
        
        
        [self setupAudio];
    }
    
    return self;
}

-(void)recoveryOfAnimation:(NSNotification *)notification
{
    if ([[AudioCommon sharedInstance].currentURL isEqual:[NSURL URLWithString:self.attachment.contents]]) {
        [self autoPlay];
    }

}


-(void)setupAudio
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recoveryOfAnimation:) name:@"Recovery_of_animation" object:nil];
    
    self.clipsToBounds = YES;
    
    
    _videoIcon = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, self.bounds.size.height-20, self.bounds.size.height-20)];
    _videoIcon.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    _videoIcon.layer.cornerRadius = _videoIcon.frame.size.height/2;
    _videoIcon.clipsToBounds = YES;
    _videoIcon.layer.borderColor = [UIColor blackColor].CGColor;
    _videoIcon.layer.borderWidth = 2;
    
    
    _actionIcon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    _actionIcon.userInteractionEnabled = NO;
    UIView *mask = [[UIView alloc]initWithFrame:_videoIcon.bounds];
    
    
    mask.backgroundColor = [UIColor blackColor];
    mask.alpha = 0.4;
    
    UIView *mask2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    mask2.backgroundColor = [OWColor colorWithHexString:@"#BB1100"];
    mask2.layer.borderWidth = 2;
    mask2.layer.borderColor = [UIColor blackColor].CGColor;
    mask2.layer.cornerRadius = mask2.frame.size.height/2;
    mask2.userInteractionEnabled = NO;
    _actionIcon.image = [UIImage imageNamed:@"moviePlay"];
    [_actionIcon setContentMode:UIViewContentModeScaleAspectFit];
    _actionIcon.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    mask2.center = _actionIcon.center;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        UIImage *img = [VideoIcon getMessageFromAudio:[NSURL URLWithString:self.attachment.contents]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            _videoIcon.image = img;
            
        });
        
    });
    
    [self addSubview:_videoIcon];
    [_videoIcon addSubview:mask];
    [self addSubview:mask2];
    [self addSubview:_actionIcon];
    
    
    [self addTarget:self action:@selector(intoAudio:) forControlEvents:UIControlEventTouchUpInside];
}



-(void)setup
{
    
    _videoIcon = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, self.bounds.size.width-20, self.bounds.size.height-20)];
    
    _actionIcon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    
    UIView *mask = [[UIView alloc]initWithFrame:_videoIcon.bounds];
    mask.backgroundColor = [UIColor blackColor];
    mask.alpha = 0.4;
    
    
    _actionIcon.image = [UIImage imageNamed:@"moviePlay"];
    [_actionIcon setContentMode:UIViewContentModeScaleAspectFit];
    _actionIcon.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    
    UIImage *image = [VideoIcon getImage:[NSURL URLWithString:self.attachment.contents]];
    
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            _videoIcon.image = image;
            
        });
        
    });
    
    [self addSubview:_videoIcon];
    [_videoIcon addSubview:mask];
    [self addSubview:_actionIcon];
    
    
    [self addTarget:self action:@selector(intoVideo:) forControlEvents:UIControlEventTouchUpInside];
//
//    [self addTarget:self action:@selector(qqq:) forControlEvents:UIControlEventTouchDown];
    
}

-(void)qqq:(id)sender
{
    
    [OWAnimator basicAnimate:sender toScale:CGPointMake(0.9, 0.9) duration:0.2f delay:0 completion:^{
        
        
    }];
    
}





-(void)intoAudio:(id)sender
{
//    [OWAnimator basicAnimate:self toScale:CGPointMake(0.9, 0.9) duration:0.2f delay:0 completion:^{
//        
//       
//        
//        
//        
//    }];
    
     [OWAnimator spring:sender toScale:CGPointMake(1, 1) delay:0];
    
    if (isAnimation) {
        
        [self stopAnimation];
        
        
        if ([self.delegate respondsToSelector:@selector(audioEndPlayAction:)]) {
            [self.delegate audioEndPlayAction:sender];
        }
        
    }else{
        
        [self autoPlay];
        
        
        if ([self.delegate respondsToSelector:@selector(audioBeginPlayAction:)]) {
            [self.delegate audioBeginPlayAction:sender];
        }
        
    }
    
    self.userInteractionEnabled = NO;
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(touchNumber) userInfo:nil repeats:NO];
}

-(void)touchNumber
{
    self.userInteractionEnabled = YES;
}


-(void)autoPlay
{
    isAnimation = YES;
    _actionIcon.image = [UIImage imageNamed:@"moviePause"];
    
    CABasicAnimation *animation;
    animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.toValue = [NSNumber numberWithFloat:M_PI*2.0];
    animation.duration = 10;
    animation.cumulative = YES;
    animation.repeatCount = 10000;
    [_videoIcon.layer addAnimation:animation forKey:@"transform.rotation.z"];
    
}

-(void)stopAnimation
{
    isAnimation = NO;
    _actionIcon.image = [UIImage imageNamed:@"moviePlay"];
    [_videoIcon.layer removeAllAnimations];
    
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)intoVideo:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(goToVideoCtrl:)]) {
        [self.delegate goToVideoCtrl:sender];
    }
}


//- (void)starButtonClicked:(id)sender
//{
//    //先将未到时间执行前的任务取消。
//    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(intoAudio:) object:sender];
//    [self performSelector:@selector(intoAudio:) withObject:sender afterDelay:0.5f];
//}


@end
