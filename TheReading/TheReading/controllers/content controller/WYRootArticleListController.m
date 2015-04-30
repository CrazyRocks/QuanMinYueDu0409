//
//  LYBookStoreController.m
//  LYBookStore
//
//  Created by grenlight on 14-5-6.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import "WYRootArticleListController.h"
#import <LYService/LYService.h>
#import "WYArticleListSubNavController.h"
#import <OWKit/OWKit.h>
#import "WYMenuManager.h"

@interface WYRootArticleListController ()
{
    WYArticleListSubNavController *subNavController;
    WYMenuManager           *menuManager;
}
@end

@implementation WYRootArticleListController

- (id)init
{
    self = [super initWithNibName:@"WYRootArticleListController" bundle:nil];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithNoneNavigationBar
{
    self = [super initWithNoneNavigationBar];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    subNavController = [[WYArticleListSubNavController alloc] init];
    [self addChildViewController:subNavController];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (categories && categories.count > 0) {
        [self initContentView];
    }
    else {
        [self createStatusManageView];
        [self requestCategories];
    }
}

- (NSString *)loadingMessage
{
    return @"正在获取文章分类";
}

- (NSString *)errorMessage
{
    return @"该栏目下没有内容，请询问单位管理员";
}

- (void)reloading:(id)sender
{
    [self requestCategories];
}

- (void)requestCategories
{
    if (!menuManager) {
        menuManager = [[WYMenuManager alloc] init];
    }
    __weak typeof (self) weakSelf = self;
    
    [menuManager getCategories:self.menu completion:^(id result) {
        [weakSelf requestComplete:result];
    } fault:^(NSString *msg) {
        [weakSelf requestFault:msg];
    }];
}

- (void)requestComplete:(id)result
{
    categories = result;
    if (categories && categories.count > 0) {
        [self initContentView];
    }
    else {
        [statusManageView requestFault];
    }
}

- (void)requestFault:(NSString *)msg
{
    [statusManageView requestFault];
}

- (void)initContentView
{
    [statusManageView stopRequest];
    
    subNavController.view.backgroundColor = self.view.backgroundColor;
    subNavController.menuManager = menuManager;
    
    [self.view insertSubview:subNavController.view atIndex:0];
    UIEdgeInsets padding = UIEdgeInsetsMake(0, 0, 0, 0);
    [subNavController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(padding);
    }];
}

@end
