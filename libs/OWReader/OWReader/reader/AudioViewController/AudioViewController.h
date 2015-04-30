//
//  AudioViewController.h
//  LYBookStore
//
//  Created by grenlight on 14/10/28.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "PCSEQVisualizer.h"
#import "OWAnimator.h"

@protocol AudioViewControllerDelegate <NSObject>

-(void)stopMusicAction;

-(void)pauMusicAction;

-(void)hiddenAudioViewShowBtn;

@end


@interface AudioViewController : UIViewController<AVAudioPlayerDelegate>
{
    __unsafe_unretained IBOutlet PCSEQVisualizer *pce;
    __unsafe_unretained IBOutlet UIView *rootView;
    __unsafe_unretained IBOutlet UIButton *pauBtn;
    __unsafe_unretained IBOutlet UIButton *playBtn;
    __unsafe_unretained IBOutlet UIButton *stopBtn;
    __unsafe_unretained IBOutlet UIProgressView *progressView;
    __unsafe_unretained IBOutlet UILabel *currentLab;
    __unsafe_unretained IBOutlet UILabel *maxLab;
    __unsafe_unretained IBOutlet UILabel *titleLab;
    __unsafe_unretained IBOutlet UIImageView *iconImageView;
    NSTimer *timer;
}

@property CGPoint endPoint;

@property (assign) id<AudioViewControllerDelegate>delegate;

@property (nonatomic, retain) AVAudioPlayer *player;
//按钮点击事件
-(IBAction)playBtnAction:(id)sender;

-(IBAction)pauBtnAction:(id)sender;

-(IBAction)stopBtnAction:(id)sender;

//设置音乐路径
-(void)setPlayerURL:(NSURL *)url;

-(void)showViewAnimation;

-(void)hiddenViewAnimation;

@end
