//
//  LYBookSliderController.m
//  LYBookStore
//
//  Created by grenlight on 14-4-25.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import "LYBookSliderController.h"
#import "GLSliderBubbleController.h"
#import <OWKit/OWKit.h>
#import <LYService/LYGlobalConfig.h>
//#import "GLNotificationName.h"
#import "JRReaderNotificationName.h"
#import "LYBookSceneManager.h"

//左右边距
#define kPaddingLR 25.0f

@interface LYBookSliderController ()
{
    CGPoint startPoint, endPoint;//滑动的起始、结束点
    
    GLSliderBubbleController *bubbleController;
    
   
    //
    NSInteger minValue, maxValue,_currentValue;
    float trackLength;//滑动条有效长度，用于计算当前页
    
}
@end

@implementation LYBookSliderController
@synthesize delegate;

- (id)init
{
    self = [super initWithNibName:@"LYBookSliderController" bundle:[NSBundle bundleForClass:[self class]]];
    if (self) {
        __weak typeof (self) weakSelf = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:BOOK_PAGENUM_CHANGED object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [weakSelf setCurrentValue:[note.userInfo[@"pageNumber"] integerValue]];
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:BOOK_PARSER_PROGRESS object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            NSNumber *progress = note.userInfo[@"progress"];
            [weakSelf setProgress:[progress floatValue]];
        }];
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static LYBookSliderController *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LYBookSliderController alloc] init];
    });
    return instance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, appWidth, self.view.frame.size.height);
    
    
    if (slider) {
        slider.delegate = self;
    }
    progressView.alpha = 0;
    
    [progressView setStrokeColor:[OWColor colorWithHex:0x63b8e5]];
        
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake(appWidth, 44);
    frame.origin.y = appHeight - frame.size.height;

    float centerY = CGRectGetHeight(frame) / 2.0f ;
    startPoint = CGPointMake(kPaddingLR, centerY);
    endPoint = CGPointMake( CGRectGetWidth(frame) - kPaddingLR, centerY);
    trackLength = CGRectGetWidth(frame) - kPaddingLR * 2;
    
    homeFrame = schoolFrame = slider.frame;
    schoolFrame.origin.x = kPaddingLR;
    schoolFrame.size.width -= kPaddingLR*2;
    
    canSlide = NO;
    [slider hideThumb];

    schoolCenter = CGPointMake(appWidth/2.0f, frame.origin.y+centerY);
    homeCenter = schoolCenter;
    homeCenter.y += centerY;
    
    self.view.center = homeCenter;
}

- (void)showSlider
{
    self.view.backgroundColor = [OWColor colorWithHexString:@"#161616"];
    canSlide = YES;
    [self animateTo:schoolCenter frame:schoolFrame callBack:^{
        [slider showThumb];
        
    }];
}

- (void)hideSlider
{
    self.view.backgroundColor = [UIColor clearColor];
    canSlide = NO;
    [self animateTo:homeCenter frame:homeFrame callBack:^{
        [slider hideThumb];
        
    }];
}

- (void)setProgress:(float)progress
{
    [progressView setStrokeEnd:progress animated:YES];
}

- (void)showProgressView
{
    [UIView animateWithDuration:0.25 animations:^{
        slider.alpha = 0;
        progressView.alpha = 1;
    }];
    [self animateTo:schoolCenter frame:schoolFrame callBack:nil];
}

- (void)hideProgressView
{
    [self animationToShowSlider];
}

- (void)animationToShowSlider
{
    [slider.layer removeAllAnimations];
    [progressView.layer removeAllAnimations];
    
    [UIView animateWithDuration:0.25 animations:^{
        slider.alpha = 1;
        progressView.alpha = 0;
    }];
}

- (void)setPageCount:(NSInteger)count
{
    maxValue = count;
    slider.maximumValue = count;
}

- (void)setPageDisplayed:(NSInteger)pgIndex
{
    _currentValue = pgIndex;
    [self setCurrentValue:pgIndex];
    
}

- (void)animateTo:(CGPoint)newCenter frame:(CGRect)newFrame callBack:(GLNoneParamBlock)callBack
{
    [UIView animateWithDuration:0.2 animations:^{
        self.view.center = newCenter;
        slider.frame = newFrame;
    } completion:^(BOOL finished) {
        if (callBack) callBack();
    }];
   
}

-(NSInteger)currentValue
{
    return _currentValue;
}

-(void)setCurrentValue:(NSInteger)aCurrentValue
{
    _currentValue = aCurrentValue;
    [slider setValue:_currentValue animated:YES];
}

- (void)showBubbleByPosition:(CGPoint)center title:(NSString *)t
{
    NSString *pn = [NSString stringWithFormat:@"%li / %li",(long)_currentValue, (long)maxValue];
    [bubbleController resetTitle:(t!=nil)?t:[delegate sliderGetTitleByCurrentValue:_currentValue]
                      pageNumber:pn  andAnglePoint:center];
}

#pragma mark slider delegate
//开始跟踪拖动，显示气泡
-(void)thumbStartTracking:(LYBookSlider *)thumb byValue:(NSInteger)value point:(CGPoint)point
{
    bubbleController = [[GLSliderBubbleController alloc] init];
    [self showBubbleByPosition:CGPointMake(point.x+kPaddingLR, point.y) title:[delegate sliderCurrentTitle]];
    
    [self.view addSubview:bubbleController.view];
}


-(void)thumbMoved:(LYBookSlider *)thumb byValue:(NSInteger)value point:(CGPoint)point
{
    CGPoint touchPoint;
    _currentValue = value;

    touchPoint = point;
    touchPoint.x += kPaddingLR;
    
    [self showBubbleByPosition:touchPoint title:nil];
}

-(void)thumbStopTracking:(LYBookSlider *)thumb byValue:(NSInteger)value
{
    [bubbleController removeFromSupperview];
    [self performSelector:@selector(excuteValueChange) withObject:nil afterDelay:0.01];
}

- (void)excuteValueChange
{
    [delegate  sliderValueChanged:_currentValue];
}

-(void)dealloc
{
    delegate = nil;
}


@end
