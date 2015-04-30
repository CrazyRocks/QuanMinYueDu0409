//
//  GLAnimateView.h
//  DragonSource
//
//  Created by  oowwww on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface OWAnimateView : UIView
{
    BOOL animating;
	BOOL displayLinkSupported;
    id displayLink;
    
}
@property(nonatomic)NSInteger frameInterval;

-(void)startAnimation;
-(void)stopAnimation;
//进入帧
-(void)enterFrame;

@end
