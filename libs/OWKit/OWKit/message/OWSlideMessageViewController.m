//
//  GLAsyncMessageController.m
//
//  Created by  oowwww on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.
//

#import "OWSlideMessageViewController.h"
#import "OWKitGlobal.h"

@interface OWSlideMessageViewController ()

@end

@implementation OWSlideMessageViewController

- (id)init
{
    self = [super initWithNibName:@"OWSlideMessageViewController" bundle:[NSBundle bundleForClass:[OWSlideMessageViewController class]]];
    if (self) {
        homeCenter = CGPointMake(appWidth - 60, appHeight/2.0f - 30);
        schoolCenter = homeCenter;
        schoolCenter.x = appWidth + 60;
    }
    return self;
}

+(OWSlideMessageViewController *)sharedInstance
{
    static OWSlideMessageViewController *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[OWSlideMessageViewController alloc] init];
    });
    return instance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [messagePanel setCenter:schoolCenter];
}

- (void)animatingIn:(BOOL)autoClose
{
    [UIView animateWithDuration:0.25 animations:^{
        [messagePanel setCenter:homeCenter];
    } completion:^(BOOL finished) {
        if(autoClose)
            [self performSelector:@selector(animatingOut) withObject:nil afterDelay:1];
        
    }];
}

-(void)animatingOut
{
    isShow = NO;
    [UIView animateWithDuration:0.25 delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [messagePanel setCenter:schoolCenter];
                     } completion:^(BOOL finished) {
                         [self.view removeFromSuperview];
                         self.view = nil;
                     }];
}


@end
