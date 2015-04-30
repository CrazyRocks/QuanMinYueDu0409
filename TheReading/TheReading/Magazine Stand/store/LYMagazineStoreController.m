//
//  LYMagazineStoreController.m
//  LYMagazinesStand
//
//  Created by grenlight on 14/7/31.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "LYMagazineStoreController.h"
#import "LYMagazinesSubNavController.h"
#import "LYMagazineGlobal.h"

@interface LYMagazineStoreController () {
    LYMagazinesSubNavController *subNavController;
}
@end

@implementation LYMagazineStoreController

- (id)init
{
    if (self=[super init]) {
        categoryManager = [[LYCategoryManager alloc] init];
        subNavController = [[LYMagazinesSubNavController alloc] init];
        [self addChildViewController:subNavController];
    }
    return self;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 64, appWidth, appHeight-64-49)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self requestCategories];
}

- (NSString *)loadingMessage
{
    return @"正在加载杂志分类";
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
    if ([LYMagazineGlobal sharedInstance].magCategories && [LYMagazineGlobal sharedInstance].magCategories.count > 0) {
        [self initContentView];
    }
    else {
        [self createStatusManageView];
        [httpRequest cancel];
        __weak typeof(self) weakSelf = self;
        httpRequest =  [categoryManager getMagazineCagegory:self.menu completion:^(NSArray *arr){
            NSMutableArray *items = [[NSMutableArray alloc] init];
            for (NSDictionary *cat in arr) {
                OWSubNavigationItem *item = [[OWSubNavigationItem alloc] init];
                item.catID = cat[@"CategoryCode"];
                item.catName  = cat[@"CategoryName"];
                [items addObject:item];
            }
            [LYMagazineGlobal sharedInstance].magCategories = items;
            [weakSelf initContentView];
        } failedCallBack:^(NSString *msg) {
            [weakSelf requestFault];
        }];
    }
}

- (void)requestFault
{
    [statusManageView requestFault];
}

- (void)initContentView
{
    [statusManageView stopRequest];
    subNavController.categories = [LYMagazineGlobal sharedInstance].magCategories;
    [self.view addSubview:subNavController.view];
    
    UIEdgeInsets padding = UIEdgeInsetsMake(0, 0, 0, 0);
    [subNavController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(padding);
    }];
}


@end
