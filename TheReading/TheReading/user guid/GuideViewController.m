//
//  GuideViewController.m
//  GoodSui
//
//  Created by 龙源 on 13-8-29.
//  Copyright (c) 2013年 grenlight. All rights reserved.
//

#import "GuideViewController.h"
#import "OWAppGuide.h"
#import "LYMagazinesStand.h"
#import <OWKit/OWKit.h>
#import <LYService/LYService.h>

@interface GuideViewController ()

@end

@implementation GuideViewController

- (id)init
{
    self = [super initWithNibName:@"GuideViewController" bundle:nil];
    return self;
}

+ (GuideViewController *)sharedInstance
{
    static GuideViewController *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GuideViewController alloc] init];
    });
    return instance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setFrame:CGRectMake(0, 0, appWidth, appHeight)];
    self.view.backgroundColor = [UIColor blackColor];
    
    [_scrollView setContentSize:CGSizeMake(appWidth*3, CGRectGetHeight(_scrollView.bounds))];
    _scrollView.delegate = self;
    
    CGRect frame = _scrollView.bounds;
    
    NSString *imageName = @"guide";

    if (isiOS7) {
         [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
    
    for (int i=0; i<3; i++) {
        UIImageView *imageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%i",imageName,i]]];
        frame.origin.x = appWidth*i;
        [imageV setFrame:frame];
        [_scrollView addSubview:imageV];
    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    [self.view addGestureRecognizer:tap];
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    swipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipe];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger page = ceilf(scrollView.contentOffset.x/ CGRectGetWidth(scrollView.bounds));
    pageControl.currentPage = page;
    if (page == 2) {
        scrollView.userInteractionEnabled = NO;
    }
}


- (void)tapped
{
    if (pageControl.currentPage < 2) {
        NSLog(@"page:%li",(long)pageControl.currentPage);
        return;
    }
    [UIView animateWithDuration:0.3 animations:^{
        [self.view.superview setAlpha:0];
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        self.view = nil;
        [OWAppGuide clear];
        if (isiOS7)
            [[UIApplication sharedApplication] setStatusBarHidden:NO];

    }];
}
@end
