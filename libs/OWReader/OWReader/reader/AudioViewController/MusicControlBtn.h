//
//  MusicControlBtn.h
//  TestAudio
//
//  Created by grenlight on 14/10/28.
//  Copyright (c) 2014年 qikan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PulsingHaloLayer.h"

@protocol MusicControlBtnDelegate <NSObject>

-(void)showView:(id)sender;

@end



@interface MusicControlBtn : UIButton
{
    NSMutableArray *colors;
    NSTimer *timer;
}
@property (nonatomic, strong) PulsingHaloLayer *halo;

@property (assign) id<MusicControlBtnDelegate>delegate;

@property (nonatomic, retain) UIImageView *iconImageView;

-(void)setImageViewIcon:(NSURL *)url;

-(void)autoPlay;

-(void)stopAnimation;

-(void)setHidden:(BOOL)hidden;


@end
