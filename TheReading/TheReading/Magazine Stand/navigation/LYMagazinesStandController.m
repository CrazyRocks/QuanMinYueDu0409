//
//  NavPanelViewController.m
//  PublicLibrary
//
//  Created by grenlight on 13-12-5.
//  Copyright (c) 2013年 grenlight. All rights reserved.
//

#import "LYMagazinesStandController.h"
#import "MagazineCollectionController.h"
#import "LYFavoriteTableViewController.h"
#import "LYFocusedMagCollectionController.h"
#import "LYMagazinesSubNavController.h"
#import "LYMagazineGlobal.h"
#import <OWKit/OWKit.h>
#import <LYService/LYService.h>
#import "LYMagazineShelfController.h"
#import "LYMagazineStoreController.h"
#import "MagTabbarBackground.h"

@interface LYMagazinesStandController ()
{
    LYMagazineStoreController     *storeController;
    
    LYFocusedMagCollectionController * focusedMagCollectionController;
    
    LYFavoriteTableViewController   *favoriteController;
    
    LYMagazineShelfController          *shelfController;
    
    OWViewController             * currentController;
    
}
@end

@implementation LYMagazinesStandController

- (id)init
{
    self = [super initWithNibName:@"LYMagazinesStandController" bundle:[NSBundle bundleForClass:[self class]]];
    if (self) {
        if (![[UIStyleManager sharedInstance] styleFileLoadedAlready]) {
            [[UIStyleManager sharedInstance] parseStyleFile:@"DefaultUIStyleConfig"];
        }
             
        storeController = [[LYMagazineStoreController alloc] init];
        [self addChildViewController:storeController];
        
        focusedMagCollectionController = [[LYFocusedMagCollectionController alloc] init];
        [self addChildViewController:focusedMagCollectionController];
        
        shelfController = [[LYMagazineShelfController alloc] init];
        [self addChildViewController:shelfController];
        
        favoriteController = [[LYFavoriteTableViewController alloc] initWithNoneNavigationBar];
        [self addChildViewController:favoriteController];
        

        //设置底部导航 UITabBarItem 的文字样式
        [UITabBarItem.appearance setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor darkGrayColor] } forState:UIControlStateNormal];
        
        [UITabBarItem.appearance setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor redColor] } forState:UIControlStateSelected];
    }

    return self;
}

- (void)releaseData
{
    tabBar.delegate = nil;
    [super releaseData];
}

- (void)updateStatusBarStyle
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [navBar setTitle:@"杂志库"];

    [self.view setBackgroundColor:[OWColor colorWithHex:0xfafafa]];
    [contentView setBackgroundColor:self.view.backgroundColor];

    tabBar.delegate = self;
    UIView *bg = [[MagTabbarBackground alloc] initWithFrame:tabBar.bounds];
    [tabBar insertSubview:bg atIndex:0];
    UIEdgeInsets padding = UIEdgeInsetsMake(0, 0, 0, 0);
    [bg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(tabBar).with.insets(padding);
    }];
    
    if (selectedTabBarItem) {
        [tabBar setSelectedItem:selectedTabBarItem];
    }

    UITabBarItem *item = tabBar.items[0];
    if (isiOS7) {
        item.selectedImage = [[UIImage imageNamed:@"magTabBar_store_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    else {
        [tabBar setSelectedImageTintColor:[UIColor redColor]];
    }
    tabBar.selectedItem = item;
   
    [self performSelector:@selector(loadingStoreView) withObject:nil afterDelay:0.5];
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateStatusBarStyle];
}

- (void)loadingStoreView
{
    storeController.menu = self.menu;
    [self transitionByViewController:storeController completion:^{
        
    }];
}

#pragma mark alertView any Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [LYGlobalConfig sharedInstance].staticKey =  [LYGlobalConfig sharedInstance].refreshKeyBlock();
    }
    else {
        [self.view setUserInteractionEnabled:YES];
    }
}



-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}


- (void)comeback:(id)sender
{
    if (self.returnToPreController) {
        self.view.userInteractionEnabled = YES;
        self.returnToPreController();
    }
    else
        [super comeback:sender];
}

#pragma mark tabBar delegate
- (void)tabBar:(UITabBar *)theTabBar didSelectItem:(UITabBarItem *)item
{
    OWViewController *tempController;
    selectedTabBarItem = item;
    
    NSString *title, *selectedImage;
    switch (item.tag) {
        case 0:
            selectedImage = @"magTabBar_store_selected";
            tempController = storeController;
            storeController.menu = self.menu;

            title = @"杂志库";
            break;
            
        case 1:
            selectedImage = @"magTabBar_shelf_selected";
            tempController = shelfController;
            title = @"杂志架";
            break;
            
        case 2:
            selectedImage = @"magTabBar_favorite_selected";
            tempController = favoriteController;
            title = @"收藏";
            break;
            
        case 3:
            selectedImage = @"magTabBar_focus_selected";
            tempController = focusedMagCollectionController;
            title = @"关注";
            break;
            
        default:
            break;
    }
    if (isiOS7) {
        item.selectedImage = [UIImage imageNamed:selectedImage];
    }
    else {
        [tabBar setSelectedImageTintColor:[UIColor redColor]];
    }

    if (tempController && tempController != currentController) {
        [navBar setTitle:title];
        if (currentController && [currentController respondsToSelector:@selector(outEditMode)])
            [currentController performSelector:@selector(outEditMode)];
        
        [self transitionByViewController:tempController completion:Nil];
    }
}


- (void)transitionByViewController:(OWViewController *)tempController completion:(GLNoneParamBlock)completion
{
    [tempController.view setFrame:contentView.bounds];
    tempController.view.alpha = 0;
    
    [contentView insertSubview:tempController.view atIndex:0];
    
    [UIView animateWithDuration:0.3 delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [tempController.view setAlpha:1];
                         [currentController.view setAlpha:0];
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [currentController.view removeFromSuperview];
                             currentController = tempController ;
                             if (completion)
                                 completion();
                         }
                     }];
}

@end
