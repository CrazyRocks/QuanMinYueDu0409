//
//  LYBookSlider.m
//  LYBookStore
//
//  Created by grenlight on 14-4-28.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import "LYBookSlider.h"
#import "GLSliderBubbleController.h"
#import <OWKit/OWKit.h>
#import <LYService/LYGlobalConfig.h>
//#import "GLNotificationName.h"

#import "JRReaderNotificationName.h"


#import "LYBookSceneManager.h"
//#import "GLNotificationName.h"
#import "JRReaderNotificationName.h"
#import "LYBookHelper.h"

@implementation LYBookSlider
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)setup
{ 
    self.minimumValue = 1;
    currentValue = 1;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSceneMode) name:BOOK_SCENE_CHANGED object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)changeSceneMode
{
    if (isThumbVisible) {
        [self showThumb];
    }
    else {
        [self hideThumb];
    }
}

- (void)setTrack
{
    [self setMinimumTrackImage:[LYBookHelper imageNamed:@"track_over"] forState:UIControlStateNormal];
    [self setMaximumTrackImage:[LYBookHelper imageNamed:@"track"] forState:UIControlStateNormal];
}

- (void)showThumb
{
    NSString *sceneMode = [[LYBookSceneManager manager] sceneMode];
    NSString *bundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.bundle",sceneMode]];
    
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    
    
    
    
    
//    [self setThumbImage:[LYBookHelper imageNamed:@"thumb"] forState:UIControlStateNormal];
    
    NSInteger scale = [UIScreen mainScreen].scale;
    
    NSString *imageName = @"thumb";
    
    NSString *sourceName;
    
    if (scale > 1) {
        sourceName = [NSString stringWithFormat:@"%@@%zdx",imageName, scale] ;
    }else{
        sourceName = imageName;
    }
    
    NSString *normal = [bundle pathForResource:sourceName ofType:@"png"];
    
    [self setThumbImage:[UIImage imageWithContentsOfFile:normal] forState:UIControlStateNormal];
    
    
    [self setTrack];
    self.userInteractionEnabled = YES;
    
    isThumbVisible = YES;
}

- (void)hideThumb
{
    [self setThumbImage:[LYBookHelper imageNamed:@"thumb_none"] forState:UIControlStateNormal];
    [self setTrack];

    self.userInteractionEnabled = NO;
    
    isThumbVisible = NO;
}

//- (BOOL)isContinuous
//{
//    if (roundf(self.value) > currentValue)
//        return YES;
//    else
//        return NO;
//}

//重写样式
- (CGRect)trackRectForBounds:(CGRect)bounds
{
    return CGRectMake(0, (CGRectGetHeight(bounds)-6)/2.0f,CGRectGetWidth(bounds), 3);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.maximumValue < 1) {
        return;
    }
    
    [super touchesBegan:touches withEvent:event];
    
    currentValue = roundf(self.value);
    
    [self.delegate thumbStartTracking:self byValue:currentValue point:[[touches anyObject] locationInView:self]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.maximumValue < 1) {
        return;
    }
    [super touchesMoved:touches withEvent:event];
    
    float newTouchLocationX = [[touches anyObject] locationInView:self].x;
    
    touchLocationX = newTouchLocationX;
    currentValue = roundf(self.value);
    [delegate thumbMoved:self byValue:currentValue point:[[touches anyObject] locationInView:self]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.maximumValue < 1) {
        return;
    }
    [super touchesEnded:touches withEvent:event];
    [delegate thumbStopTracking:self byValue:currentValue];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.maximumValue < 1) {
        return;
    }
    [delegate thumbStopTracking:self byValue:currentValue];
}


@end
