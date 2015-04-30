//
//  GLAnimateView.m
//  DragonSource
//
//  Created by  oowwww on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.
//

#import "OWAnimateView.h"

@implementation OWAnimateView

@synthesize frameInterval;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       [self sharedInit];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self sharedInit];
    }
    return  self;
}

-(void)sharedInit
{
    animating = FALSE;
    displayLink = nil;
    
    displayLinkSupported = TRUE;
    
    frameInterval = 240;
}

- (void)enterFrame {}

- (void) startAnimation
{
	if (!animating && displayLinkSupported) {
        displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(enterFrame)];
        [displayLink setFrameInterval:frameInterval];
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
		animating = TRUE;
	}
}

- (void)stopAnimation
{
	if (animating&&displayLinkSupported) {
        [displayLink invalidate];
        displayLink = nil;
        animating = FALSE;	
	}
}


@end
