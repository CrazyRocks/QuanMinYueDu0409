//
//  AudioViewController.m
//  LYBookStore
//
//  Created by grenlight on 14/10/28.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "AudioViewController.h"
#import <OWCoreText/AudioCommon.h>
#import <OWCoreText/OWCoreText.h>
@interface AudioViewController ()

@end

@implementation AudioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    if (isPad) {
        self.view.frame = CGRectMake(0, 0, appWidth, appHeight);
//    }
    
    
    //样式
    
    rootView.layer.cornerRadius = 10;
    self.view.hidden = YES;
    rootView.alpha = 0.0f;
    
    [pce start];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showViewAnimation
{
    rootView.alpha = 1.0f;
    self.view.hidden = NO;
    
//    [OWAnimator basicAnimate:rootView toScale:CGPointZero duration:0.f delay:0 completion:^{
    
        [OWAnimator spring:rootView toScale:CGPointMake(1, 1) delay:0];
        
//    }];
    
}

-(void)hiddenViewAnimation
{
    
    [OWAnimator basicAnimate:rootView toScale:CGPointZero duration:0.4f delay:0 completion:^{
        
    }];

    [UIView animateWithDuration:0.4 animations:^{
        rootView.alpha = 0.0f;
        rootView.center = self.endPoint;
    } completion:^(BOOL finished) {
        self.view.hidden = YES;
        rootView.center = CGPointMake(appWidth/2, appHeight/2);
    }];
    
    
    [UIView animateWithDuration:0.4 animations:^{
        
    } completion:^(BOOL finished) {
       
        
    }];
    
}


-(void)play
{
    
    if (self.player.url != nil)
    {
        [self.player play];
    }
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
    
}


-(NSString *)formaTime:(int)num
{
    int secs = num %60 ;//分钟
    int min = num /60;//秒
    if (num < 60)
    {
        return [NSString stringWithFormat:@"0:%02d",num];
    }
    else
    {
        return [NSString stringWithFormat:@"%d:%02d",min,secs];
    }
}


-(void)updateMeters
{
    [self.player updateMeters];
    
    currentLab.text = [self formaTime:_player.currentTime];
    maxLab.text = [self formaTime:_player.duration];
    
    progressView.progress = self.player.currentTime / self.player.duration;
}

-(void)setPlayerURL:(NSURL *)url
{
    if (!self.player) {
        
        NSError *error;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
            UIImage *image = [VideoIcon getMessageFromAudio:url];
            
            dispatch_async(dispatch_get_main_queue(), ^{
            
                iconImageView.image = image;
                
            });
        });
        
        NSString *pt = [[url absoluteString] stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
        
//        NSLog(@"pt === %@",pt);
        
        NSArray *arr = [pt componentsSeparatedByString:@"/"];
        
        NSString *name = [arr lastObject];
        
//        NSLog(@"%@",arr);
        
        NSArray *arr1 = [name componentsSeparatedByString:@"."];
        
        NSString *name1 = [arr1 firstObject];
        
        titleLab.text = name1;
        
        
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
        
        //让app支持接受远程控制事件
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        
        
        
        
        _player = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        
        _player.delegate = self;
        
        currentLab.text = [self formaTime:_player.currentTime];
        maxLab.text = [self formaTime:_player.duration];
        
        progressView.progress = self.player.currentTime / self.player.duration;
        
        [self play];
    }
}

#pragma mark 按钮点击事件

-(IBAction)playBtnAction:(id)sender
{
    [self play];
    [pce start];
}

-(IBAction)pauBtnAction:(id)sender
{
    [self.player pause];
    [pce stop];
//    self.view.hidden = YES;
    
    
    [self hiddenViewAnimation];
    
    
    if ([self.delegate respondsToSelector:@selector(pauMusicAction)]) {
        [self.delegate pauMusicAction];
    }
    
    
}

-(IBAction)stopBtnAction:(id)sender
{
    [pce start];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopBtnAnimation" object:nil];
    
    [self.player stop];
    
    self.player = nil;
    
    self.view.hidden = YES;
    
    [AudioCommon sharedInstance].currentURL = nil;
    
    if ([self.delegate respondsToSelector:@selector(stopMusicAction)]) {
        [self.delegate stopMusicAction];
    }
    
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self play];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self hiddenSelfShowBtn];
}

-(void)hiddenSelfShowBtn
{
    [self hiddenViewAnimation];
    
    if ([self.delegate respondsToSelector:@selector(hiddenAudioViewShowBtn)]) {
        [self.delegate hiddenAudioViewShowBtn];
    }
    
}

- (BOOL)shouldAutorotate
{
    return NO;
}

@end
