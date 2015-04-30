//
//  LYBookNavigationBarController.m
//  LYBookStore
//
//  Created by grenlight on 14-4-28.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import "LYBookNavigationBarController.h"
#import "LYFontSizeControllerViewController.h"
#import <OWKit/OWKit.h>
#import <LYService/LYGlobalConfig.h>
//#import "GLNotificationName.h"
#import "JRReaderNotificationName.h"
#import "LYBookSceneManager.h"
#import "NetworkSynchronizationForBook.h"
#import "LYBookHelper.h"

@interface LYBookNavigationBarController ()
{
    LYFontSizeControllerViewController  *fontSizeController;
}
- (IBAction)intoCatalogue:(id)sender;
- (IBAction)fontSizeSetting:(id)sender;

@end

@implementation LYBookNavigationBarController

- (id)init
{
    if (self = [super initWithNibName:@"LYBookNavigationBarController" bundle:[NSBundle bundleForClass:[self class]]]) {
        fontSizeController = [[LYFontSizeControllerViewController alloc] init];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.frame = CGRectMake(0, 0, appWidth, self.view.frame.size.height);
    
    homeCenter = self.view.center;
    schoolCenter = homeCenter;
    schoolCenter.y = -64;

    [fontSizeButton setIcon:@"fontSizeSetting"];
    [catButton setIcon:@"catalogue_button"];
    [returnButton setIcon:@"back_button"];
    [sceneModeButton setIcon:@"sceneMode_button"];
    [searchBtn setIcon:@"catalogue_button"];
}

- (void)show
{
    [self animateTo:homeCenter
               type:UIViewAnimationOptionCurveEaseOut
           callBack:^{
               UIStatusBarStyle barStyle ;
               if (isPad)
                   barStyle = UIStatusBarStyleLightContent;
               else
                   barStyle = UIStatusBarStyleDefault ;

               if ([LYBookHelper isNightMode]) {
                   barStyle = UIStatusBarStyleLightContent;
               }
               [[UIApplication sharedApplication] setStatusBarStyle:barStyle animated:YES];
               
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }];
}

- (void)hide
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
 
    [self animateTo:schoolCenter
               type:UIViewAnimationOptionCurveEaseOut
           callBack:^{
        
    }];
  
}

- (void)animateTo:(CGPoint)newCenter type:(UIViewAnimationOptions)ops callBack:(GLNoneParamBlock)callBack
{
    [UIView animateWithDuration:0.25 delay:0
                        options:ops animations:^{
        self.view.center = newCenter;
    } completion:^(BOOL finished) {
        if (callBack) callBack();
    }];
}

- (void)comeback:(id)sender
{
    
#warning 添加上传阅读进度
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
       
        [[NetworkSynchronizationForBook manager] sendReadProgressToSever];
        
    });
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"removeAudio" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_BACKTO_BOOKSHELF object:nil];
    
}

- (void)intoCatalogue:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_OPEN_CATALOGUE object:nil];
}

-(IBAction)addSearch:(id)sender
{
    OWAnimationButton *btn = (OWAnimationButton *)sender;
    
    [OWAnimator basicAnimate:btn toScale:CGPointMake(0.8, 0.8) duration:0.2f delay:0 completion:^{
        
        [OWAnimator spring:btn toScale:CGPointMake(1, 1) delay:0];
        
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_OPEN_SEACH object:nil];
}

- (void)fontSizeSetting:(id)sender
{
    [[UIApplication sharedApplication].keyWindow addSubview:fontSizeController.view];
}


- (void)changeSceneMode:(id)sender
{
    NSString *sceneMode = [[LYBookSceneManager manager] sceneMode];
    NSString *newSceneMode;
    if ([sceneMode isEqualToString:@"day"]) {
        newSceneMode = @"night";
    }
    else {
        newSceneMode = @"day";
    }

    [[LYBookSceneManager manager] changeSceneMode:newSceneMode];
}
@end
