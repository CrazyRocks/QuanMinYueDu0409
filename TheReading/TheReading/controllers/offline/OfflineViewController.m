//
//  OfflineViewController.m
//  PublicLibrary
//
//  Created by grenlight on 14-5-29.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "OfflineViewController.h"
#import "LYBookStore.h"
#import "LYMagazinesStand.h"
#import "LYMagazineShelfController.h"

@interface OfflineViewController ()
{
    LYBookShelfController *bookShelf;
    LYMagazineShelfController *magShelf;
    
    OWViewController    *currentController;
}
@end

@implementation OfflineViewController

- (id)init
{
    self = [super init];
    if (self) {
        bookShelf = [[LYBookShelfController alloc] initWithNoneNavigationBar];
        bookShelf.bookType = lyBook;
        [self addChildViewController:bookShelf];
        
        magShelf = [[LYMagazineShelfController alloc] init];
        magShelf.isLocalMagazine = YES;
        [self addChildViewController:magShelf];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [OWColor colorWithHexString:@"#fafafa"];
    [self intoViewController:magShelf];

    UIStyleObject *style = [[UIStyleManager sharedInstance] getStyle:@"书架模块顶部SegmentedControl"];
     [segmentControl setStyle:style];

}

- (void)segmentedValueChanged:(KWFSegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0) {
        [self intoViewController:magShelf];
    }
    else {
        [self intoViewController:bookShelf];
    }
}

- (void)intoViewController:(OWViewController *)controller
{
    controller.view.alpha = 1;
    [self.view insertSubview:controller.view atIndex:0];
    UIEdgeInsets padding = UIEdgeInsetsMake(64, 0, 0, 0);
    [controller.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(padding);
    }];
    
    [UIView animateWithDuration:0.3 animations:^{
        currentController.view.alpha = 0;
    } completion:^(BOOL finished) {
        [currentController.view removeFromSuperview];
        currentController = controller;
    }];
}

- (void)comeback:(id)sender
{
    if (self.returnToPreController) {
        self.returnToPreController();
    }
    else
        [super comeback:sender];
}

@end
