//
//  RecommendArticleListController.h
//  PublicLibrary
//
//  Created by grenlight on 14-3-7.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <OWKit/OWKit.h>

@interface RecommendArticleListController : OWCommonTableViewController
{
}
//需要与此列表的滚动联动的controller
@property (nonatomic, weak) UIViewController *scrollLinkageController;

- (void)loadLocalData:(NSString *)cid;
- (void)requestArticleList:(NSString *)cid;

@end
