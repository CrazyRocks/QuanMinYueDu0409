//
//  VideoBtn.h
//  OWCoreText
//
//  Created by grenlight on 14/10/27.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWTextAttachment.h"
#import "VideoIcon.h"

@protocol VideoBtnDelegate <NSObject>

-(void)goToVideoCtrl:(id)btn;

-(void)audioBeginPlayAction:(id)btn;

-(void)audioEndPlayAction:(id)btn;

@end

@interface VideoBtn : UIButton
{
    NSInteger cor;
    BOOL isAnimation;
}

@property (assign) id <VideoBtnDelegate> delegate;
@property (nonatomic, retain) OWTextAttachment *attachment;
@property (nonatomic, retain) UIImageView *videoIcon;
@property (nonatomic, retain) UIImageView *actionIcon;
@property (nonatomic, retain) NSTimer *timer;
//视频
-(id)initWithFrame:(CGRect)frame withOWTextAttachment:(OWTextAttachment *)att;

//音频
-(id)initWithFrame:(CGRect)frame withOWTextAttachmentAudio:(OWTextAttachment *)att;

-(void)autoPlay;

-(void)stopAnimation;

@end
