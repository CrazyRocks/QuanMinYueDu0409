//
//  LYBookStoreRootController.m
//  LYBookStore
//
//  Created by grenlight on 14/6/29.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import "LYBookStoreRootController.h"
#import "LYBookStoreController.h"
#import <OWKit/OWKit.h>
#import <LYService/LYService.h>
#import "LYBookStoreSubNavController.h"
#import "LYBookConfig.h"
#import "LYBookCategorySortingController.h"
#import "LYBookShelfController.h"

@interface LYBookStoreRootController ()
{
    LYBookStoreController       *storeController;
    LYBookShelfController       *shelfController;
    OWViewController            *currentController;
}
@end

@implementation LYBookStoreRootController

- (id)init
{
    self = [super initWithNibName:@"LYBookStoreRootController" bundle:[NSBundle bundleForClass:[self class]]];
    if (self) {
        [self setup];
        needShowNavigationBar = YES;
    }
    return self;
}

- (id)initWithNoneNavigationBar
{
    self = [super initWithNibName:@"LYBookStoreRootController" bundle:[NSBundle bundleForClass:[self class]]];
    if (self) {
        needShowNavigationBar = NO;
        [self setup];
    }
    return self;
}

- (void)setup
{
    storeController = [[LYBookStoreController alloc] initWithNoneNavigationBar];
    [self addChildViewController:storeController];
    
    shelfController = [[LYBookShelfController alloc] initWithNoneNavigationBar];
    shelfController.bookType = lyBook;
    [ self addChildViewController:shelfController];
    
    selectedIndex = -1;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (isPad) {
        backButton.hidden = YES;
    }
    else {
        [backButton setIcon:@"back_button" inBundle:nil];
    }

    UIStyleObject *style = [[UIStyleManager sharedInstance] getStyle:@"书架模块顶部SegmentedControl"];
    [segmentControl setStyle:style];

    [self performSelector:@selector(renderContentView) withObject:nil afterDelay:0.2];
}

- (void)renderContentView
{
    //将当前controller置空，用于内存警告后的重建
    currentController = nil;
    if (selectedIndex > 0) {
        [segmentControl setSelectedSegmentIndex:selectedIndex];
    }
    else {
        [segmentControl setSelectedSegmentIndex:0];
        storeController.menu = self.menu;
        [self intoViewController:storeController];
    }
}

- (void)segmentedValueChanged:(KWFSegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0) {
        storeController.menu = self.menu;
        [self intoViewController:storeController];
    }
    else {
        [self intoViewController:shelfController];
    }
    selectedIndex = sender.selectedSegmentIndex;
}

- (void)setBackButtonImage:(UIImage *)img
{
    [backButton setImage:img forState:UIControlStateNormal];
}

- (void)intoViewController:(OWViewController *)controller
{
    if (currentController == controller)
        return;
    
    float offsetY = 0;
    if (needShowNavigationBar) {
        offsetY = 64;
    }
    [self.view insertSubview:controller.view atIndex:0];

    UIEdgeInsets padding = UIEdgeInsetsMake(offsetY, 0, 0, 0);
    [controller.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(padding);
    }];
    
    controller.view.alpha = 1;
    
    navBar.userInteractionEnabled = YES;
    [self.view addSubview:navBar];
    
    if ([currentController isViewLoaded]) {
        [UIView animateWithDuration:0.3 animations:^{
            currentController.view.alpha = 0;
        } completion:^(BOOL finished) {
            [currentController.view removeFromSuperview];
            currentController = controller;
        }];
    }
    else {
        currentController = controller;
    }
}

- (void)comeback:(id)sender
{
    if (self.returnToPreController) {
        self.returnToPreController();
    }
    else {
        [super comeback:sender];
    }
    
    [OWNavigationController sharedInstance].canMoveByPanGesture = YES;
}

@end
