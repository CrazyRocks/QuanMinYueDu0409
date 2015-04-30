//
//  ALMoviePlayerController.h
//  ALMoviePlayerController
//
//  Created by Anthony Lobianco on 10/8/13.
//  Copyright (c) 2013 Anthony Lobianco. All rights reserved.
//

#import <MediaPlayer/MPMoviePlayerController.h>
#import "ALMoviePlayerControls.h"
#import "OWTextAttachment.h"


static NSString * const ALMoviePlayerContentURLDidChangeNotification = @"ALMoviePlayerContentURLDidChangeNotification";

@protocol ALMoviePlayerControllerDelegate <NSObject>
@optional
- (void)movieTimedOut;
@required
- (void)moviePlayerWillMoveFromWindow;
@end

@interface ALMoviePlayerController : MPMoviePlayerController
{
    CGRect smallFrame;
    CGPoint samllPoint;
    UIImageView *imageView;
}
- (void)setFrame:(CGRect)frame;
- (id)initWithFrame:(CGRect)frame;

//设置中心点要在设置玩frame后使用
-(void)setMySamllTypeCenter:(CGPoint)point;
-(void)changeSamllType;
-(void)setImageView:(UIImage *)image;

@property (nonatomic, retain) OWTextAttachment *attachment;

@property (nonatomic, weak) id<ALMoviePlayerControllerDelegate> delegate;
@property (nonatomic, strong) ALMoviePlayerControls *controls;

@end
