//
//  WYContentCanvasController.m
//  PublicLibrary
//
//  Created by grenlight on 14-1-24.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "WYContentCanvasController.h"
#import "WYRootArticleListController.h"
#import "WYArticleSearchController.h"
#import "LYBookStoreRootController.h"
#import "OfflineViewController.h"
#import "LYMagazinesStandController.h"
#import "LYAudioController.h"
#import "LYFavoriteTableViewController.h"

@interface WYContentCanvasController ()
{
    LYFavoriteTableViewController   *favoriteListControler;
    WYArticleSearchController   *searchController;
    
    UINavigationController  *magazinesStandController;
    LYMagazinesStandController *magRootController;
    
    LYBookStoreRootController   *bookStoreController;
    OfflineViewController       *offlineController;
    
    LYAudioController           *audioController;
    
    OWViewController    *currentController;
    
    UITapGestureRecognizer  *tap;
}
@end

@implementation WYContentCanvasController

- (id)init
{
    self = [super initWithNibName:@"WYContentCanvasController" bundle:nil];
    if (self) {
        
        
        __weak typeof (self) weakSelf = self;

        favoriteListControler = [[LYFavoriteTableViewController alloc] init];
        
        [favoriteListControler setReturnToPreController:^{
            [weakSelf menuTapped:Nil];
        }];
        [self addChildViewController:favoriteListControler];
        
        searchController = [[WYArticleSearchController alloc] init];
        [self addChildViewController:searchController];
        
        offlineController = [[OfflineViewController alloc] init];
        [offlineController setReturnToPreController:^{
            [weakSelf menuTapped:Nil];
        }];
        [self addChildViewController:offlineController];
        
        magRootController= [[LYMagazinesStandController alloc] init];
        [magRootController setReturnToPreController:^{
            [weakSelf menuTapped:Nil];
        }];
        magazinesStandController = [[UINavigationController alloc] initWithRootViewController:magRootController];
        magazinesStandController.navigationBarHidden = YES;
        [self addChildViewController:magazinesStandController];
        
        bookStoreController = [[LYBookStoreRootController alloc] init];
        [bookStoreController setReturnToPreController:^{
            [weakSelf menuTapped:Nil];
        }];
        [self addChildViewController:bookStoreController];
        
        audioController  = [[LYAudioController alloc] init];
        [audioController setReturnToPreController:^{
            [weakSelf menuTapped:Nil];
        }];
        [self addChildViewController:audioController];
        
        tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizer:)];

        controllers = [NSMutableDictionary new];
    }
    return self;
}

- (void)releaseData
{
    //将当前controller置空，方便通过左边栏重建当前视图
    currentController = nil;
    [super releaseData];
}

- (void)updateStatusBarStyle
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[OWImage imageWithName:@"page_bg2"]];
    self.view.clipsToBounds = YES;
    
    contentView.backgroundColor = self.view.backgroundColor;
    magsStandCanvas.hidden = YES;
    
    if (isPad) {
        leftButton.hidden = YES;
        accountButton.hidden = YES;
    }
}

- (void)openMenu:(LYMenuData *)menu
{
    currentMenu = menu;
    NSString *moduleCode = menu.menuType;
    if ([menu.menuType isEqualToString:@"article"]) {
        [self intoArticleList:menu];
    }
    else if ([moduleCode isEqualToString:@"magazine"]) {
        [self intoMagazineStore];
    }
    else if ([moduleCode isEqualToString:@"book"]) {
        [self intoBookStore];
    }
    else if ([moduleCode isEqualToString:@"search"]) {
        [self intoArticleSearch];
    }
    else if ([moduleCode isEqualToString:@"articleFavorite"]) {
        [self intoFavoriteList];
    }
    else if ([moduleCode isEqualToString:@"shelf"]) {
        [self intoOffline];
    }
    else if ([moduleCode isEqualToString:@"audio"]) {
        [self intoAudio];
    }
    else if ([moduleCode isEqualToString:@"video"]) {
        [self intoAudio];
    }
}

- (WYRootArticleListController *)creatArticleListController:(LYMenuData *)menu
{
    WYRootArticleListController *rootArticleListController = [[WYRootArticleListController alloc] init];
    rootArticleListController.menu = menu;
    [controllers setObject:rootArticleListController forKey:menu.menuName];
    [self addChildViewController:rootArticleListController];

    return rootArticleListController;
}

- (void)intoArticleList:(LYMenuData *)menu
{
    WYRootArticleListController *articleListController = controllers[menu.menuName];
    if (!articleListController) {
        articleListController = [self creatArticleListController:menu];
    }
    [self animateToShowController:articleListController];
    if (!isPad) {
        accountButton.hidden = NO;
    }
}

- (void)intoMagazineStore
{
    magRootController.menu = currentMenu;
    [self animateToShowController:magazinesStandController];
    if (!isPad) {
        accountButton.hidden = NO;
    }
}

- (void)intoArticleSearch
{
    [self animateToShowController:searchController];
    if (!isPad) {
        accountButton.hidden = NO;
    }
}

- (void)intoFavoriteList
{
    [self animateToShowController:favoriteListControler];
    if (!isPad) {
        accountButton.hidden = YES;
    }
}

- (void)intoBookStore
{
    bookStoreController.menu = currentMenu;
    [self animateToShowController:bookStoreController];
    if (!isPad) {
        accountButton.hidden = NO;
    }
}

- (void)intoOffline
{
    if (!isPad) {
        accountButton.hidden = NO;
    }
    [self animateToShowController:offlineController];
}

- (void)intoAudio
{
    [self animateToShowController:audioController];
    if (!isPad) {
        accountButton.hidden = NO;
    }
}

- (void)setNavTitle:(NSString *)title
{
    [navBar setTitle:title];
}

#pragma mark --actions
- (void)menuTapped:(id)sender
{
    [[PathStyleGestureController sharedInstance] intoLeftOrCenterControllerView];
}

- (void)accountTapped:(id)sender
{
    [[PathStyleGestureController sharedInstance] intoRightOrCenterControllerView];
    if ([searchController isViewLoaded]) {
        [searchController.searchField resignFirstResponder];
    }
}

- (void)tapGestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer
{
    [self menuTapped:nil];
}


- (void)intoFreeze
{
    contentView.userInteractionEnabled = NO;
    magsStandCanvas.userInteractionEnabled = NO;
    [self.view addGestureRecognizer:tap];
}

- (void)outFreeze
{
    contentView.userInteractionEnabled = YES;
    magsStandCanvas.userInteractionEnabled = YES;
    [self.view removeGestureRecognizer:tap];
}

- (void)animateToShowController:(OWViewController *)controller
{
    if (currentController == controller) {
        [[PathStyleGestureController sharedInstance] intoCenterControllerView];
        return;
    }
    
    if (isiOS7) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }
    UIEdgeInsets padding = UIEdgeInsetsMake(0, 0, 0, 0);

    if (controller == magazinesStandController ||
        controller == bookStoreController ||
        controller == offlineController || controller == favoriteListControler) {
        magsStandCanvas.hidden = NO;

        [magsStandCanvas insertSubview:controller.view atIndex:0];
        controller.view.alpha = 0;
        
        [controller.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(magsStandCanvas).with.insets(padding);
        }];
        
        if (controller == favoriteListControler ||
            controller == bookStoreController) {
            [controller performSelector:@selector(setBackButtonImage:) withObject:[UIImage imageNamed:@"menu_normal"]];
        }
        
        [UIView animateWithDuration:0.3 animations:^{
            controller.view.alpha = 1;
            currentController.view.alpha = 0;
        } completion:^(BOOL finished) {
            if (currentController) {
                [currentController.view removeFromSuperview];
            }
            currentController = controller;
        }];
    }
    else {
        magsStandCanvas.hidden = YES;

        [contentView insertSubview:controller.view atIndex:0];
        controller.view.alpha = 1;
        [controller.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(contentView).with.insets(padding);
        }];
        if (!currentController) {
            currentController = controller;
        }
        else {
            [UIView animateWithDuration:0.3 animations:^{
                currentController.view.alpha = 0;
            } completion:^(BOOL finished) {
                [currentController.view removeFromSuperview];

                currentController = controller;
            }];
        }
    }
    [[PathStyleGestureController sharedInstance] intoCenterControllerView];
}

- (void)animateController:(OWViewController *)controller alphaTo:(float)newAlpha thenRelease:(OWViewController *)controller2
{
    
}

@end
