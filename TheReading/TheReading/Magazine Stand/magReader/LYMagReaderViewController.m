//
//  LYMagReaderViewController.m
//  LYMagazinesStand
//
//  Created by grenlight on 14-5-19.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import "LYMagReaderViewController.h"
#import <OWCoreText/OWHTMLToAttriString.h>
#import "MagCatelogueListController.h"
#import "ArticleDetailMainController.h"
#import <OWKit/OWKit.h>
#import <LYService/LYService.h>
#import "LYMagazineGlobal.h"

@interface LYMagReaderViewController ()
{
    MagCatelogueListController *catController;
    ArticleDetailMainController   *contController;
    
    OWCoverAnimationView    *coverView;
    UIView                  *contentView;

}
@end

@implementation LYMagReaderViewController


- (id)init
{
    self = [super init];
    if (self) {
        catController =  [[MagCatelogueListController alloc] init];
        [self addChildViewController:catController];
        
        contController  = [[ArticleDetailMainController alloc] init];
        [self addChildViewController:contController];
        
        __weak typeof (self) weakSelf = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:MAG_BACKTO_SHELF object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [weakSelf quitReader];
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:MAG_OPEN_CATALOGUE object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [weakSelf intoCatalogue];
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:MAG_OPEN_CONTENT object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [weakSelf intoContent];
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:MAG_CONTINUE_READ object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [weakSelf continueRead];
        }];
    }
    return self;
}

- (void)releaseData
{
    [coverView removeFromSuperview];
    coverView = nil;
    
    [super releaseData];
}

-(void)loadView
{
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, appWidth, appHeight)];
    
    contentView = [[UIView alloc] initWithFrame:self.view.bounds];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    contentView.clipsToBounds = YES;
    contentView.backgroundColor = [OWColor colorWithHexString:@"#fafafa"];
    [self.view addSubview:contentView];
    
    coverView = [[OWCoverAnimationView alloc] initWithFrame:contentView.bounds];
    coverView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight| UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [contentView addSubview:coverView];
    
    [self performSelector:@selector(removePanGesture) withObject:nil afterDelay:1];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    centerFrame = leftFrame = rightFrame = self.view.bounds;
    leftFrame.origin.x = (-appWidth);
    rightFrame.origin.x = appWidth;
    
    [contController.view setFrame:rightFrame];
    [contentView addSubview:contController.view];
}

-  (void)openWithNoneCover
{
    isCoverMode = NO;
    contentView.frame = self.view.bounds;
    [self contentAlphaIn];
    coverView.hidden = YES;
}

- (void)updateStatusBarStyle
{
   
}

- (void)removePanGesture
{
    for (UIGestureRecognizer *gesture in self.view.gestureRecognizers) {
        if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
            [self.view removeGestureRecognizer:gesture];
            return;
        }
    }
}

- (void)openFromRect:(CGRect)rect cover:(UIImage *)img
{
    isCoverMode = YES;
    [coverView viewWithImage:img];
    
    homeFrame = rect;
    [contentView setFrame:homeFrame];
    [UIView animateWithDuration:0.45 animations:^{
        contentView.frame = self.view.bounds;
    }];
    [self contentAlphaIn];
    [coverView performSelector:@selector(startAnimation) withObject:nil afterDelay:0.1];
}


- (void)contentAlphaIn
{
    if (![NSThread isMainThread]) {
        [NSThread mainThread];
    }
    catController.view.alpha = 0;
    catController.view.frame = centerFrame;
    [contentView insertSubview:catController.view atIndex:0];
    [UIView animateWithDuration:0.35 animations:^{
        catController.view.alpha = 1;
    }];
}

- (void)intoCatalogue
{
    catController.view.frame = leftFrame;
    [contentView insertSubview:catController.view atIndex:1];
    
    [UIView animateWithDuration:0.25 animations:^{
        catController.view.frame = centerFrame;
        contController.view.frame = rightFrame;
    }];
    [catController updateStatusBarStyle];

}

- (void)intoContent
{
    contController.view.frame = rightFrame;
    [contentView addSubview:contController.view];
    [contController clearOldContent];
    
    [UIView animateWithDuration:0.25 animations:^{
        catController.view.frame = leftFrame;
        contController.view.frame = centerFrame;
    } completion:^(BOOL finished) {
        [catController.view removeFromSuperview];
        [contController updateStatusBarStyle];
        [contController renderContentView];
    }];
}

- (void)continueRead
{
    contController.view.frame = rightFrame;
    [contentView addSubview:contController.view];
    
    [UIView animateWithDuration:0.25 animations:^{
        catController.view.frame = leftFrame;
        contController.view.frame = centerFrame;
    } completion:^(BOOL finished) {
        [catController.view removeFromSuperview];
        [contController updateStatusBarStyle];
        [contController continueRead];
    }];
}

- (void)quitReader
{
    __weak typeof (self) weakSelf = self;
    if (isCoverMode) {
        [contentView bringSubviewToFront:coverView];
        [coverView closeCover:^{
            [weakSelf backToHome];
        }];
        [[OWNavigationController sharedInstance] popViewControllerWithNoneAnimation:1.0];
    }
    else {
        [super comeback:nil];
    }
}

- (void)backToHome
{
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         contentView.frame = homeFrame;
                     } completion:^(BOOL finished) {
                         
                     }];
    
}

@end
