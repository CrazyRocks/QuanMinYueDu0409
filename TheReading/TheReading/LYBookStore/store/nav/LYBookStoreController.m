//
//  LYBookStoreController.m
//  LYBookStore
//
//  Created by grenlight on 14-5-6.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import "LYBookStoreController.h"
#import <OWKit/OWKit.h>
#import <LYService/LYService.h>
#import "LYBookStoreSubNavController.h"
#import "LYBookConfig.h"
#import "LYBookCategorySortingController.h"

@interface LYBookStoreController ()
{
    LYBookStoreSubNavController *subNavController;
    
    LYAccountManager            *accountManager;
}
@end

@implementation LYBookStoreController

- (id)init
{
    self = [super initWithNibName:@"LYBookStoreController" bundle:[NSBundle bundleForClass:[self class]]];
    if (self) {
        [self setup];
        needShowNavigationBar = YES;
    }
    return self;
}

- (id)initWithNoneNavigationBar
{
    self = [super initWithNibName:@"LYBookStoreController" bundle:[NSBundle bundleForClass:[self class]]];
    if (self) {
        [self setup];
        needShowNavigationBar = NO;
    }
    return self;
}

- (void)setup
{
    subNavController = [[LYBookStoreSubNavController alloc] init];
    [self addChildViewController:subNavController];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
        
    [navBar setTitle:@"书库"];
    navBar.hidden = !needShowNavigationBar;
    [backButton setIcon:@"back_button" inBundle:nil];
    
    [self performSelector:@selector(renderContentView) withObject:nil afterDelay:0.1];
}

- (void)setBackButtonImage:(UIImage *)img
{
    [backButton setImage:img forState:UIControlStateNormal];
}

- (NSString *)loadingMessage
{
    return @"正在加载书店信息";
}

- (NSString *)errorMessage
{
    return @"该栏目下没有内容，请询问单位管理员";
}

//在视图frame调整完成之后
- (void)renderContentView
{
    if (bookCategories && bookCategories.count > 0) {
        [self initContentView];
    }
    else {
        [self createStatusManageView];
        [self requestCategories];
    }
}

- (void)reloading:(id)sender
{
    [self renderContentView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [OWNavigationController sharedInstance].canMoveByPanGesture = NO;
}

- (void)requestCategories
{
    __weak typeof (self) weakSelf = self;
    httpRequest = [[LYCategoryManager sharedInstance] getBookCategoriesFromServer:self.menu
                                                                       completion:^(NSArray *results) {
       NSMutableArray *items = [[NSMutableArray alloc] init];
       for (NSDictionary *cat in results) {
           OWSubNavigationItem *item = [[OWSubNavigationItem alloc] init];
           item.catID = cat[@"CategoryCode"];
           item.catName  = cat[@"CategoryName"];
           [items addObject:item];
       }
       bookCategories = items;
       [LYBookConfig sharedInstance].bookCategories = items;
       
       [weakSelf initContentView];
   } failedCallBack:^(NSString *msg) {
       [weakSelf requestFault];
   }];
}

- (void)requestFault
{
    [statusManageView requestFault];
}

- (void)initContentView
{
    if (bookCategories.count == 0) {
        [self requestFault];
    }
    else {
        [statusManageView stopRequest];

        subNavController.categories = bookCategories;
        
        [self.view insertSubview:subNavController.view atIndex:0];
        
        float offsetY = needShowNavigationBar ? 64 : 0;
        UIEdgeInsets padding = UIEdgeInsetsMake(offsetY, 0, 0, 0);
        [subNavController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view).with.insets(padding);
        }];
    }
}

- (void)comeback:(id)sender
{
    //清除数据的缓存
    for (OWSubNavigationItem *item in bookCategories) {
        [[OWAccessManager sharedInstance] removeCategory:item.catID];
    }
    if (self.returnToPreController) {
        self.returnToPreController();
    }
    else {
        [super comeback:sender];
    }
    
    [OWNavigationController sharedInstance].canMoveByPanGesture = YES;
}

@end
