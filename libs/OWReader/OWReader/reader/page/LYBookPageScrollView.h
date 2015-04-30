//
//  PageScrollView.h
//  DragonSourceReader
//
//  Created by iMac001 on 11-12-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageViewController.h"



@class LYBookPageRootController;

@interface LYBookPageScrollView : UIScrollView<UIScrollViewDelegate,PageViewDelegate,UIGestureRecognizerDelegate>
{
    Class   pageClass;
}

@property(nonatomic,retain)PageViewController *prePage;
@property(nonatomic,retain)PageViewController *currentPage;
@property(nonatomic,retain)PageViewController *nextPage;

@property (nonatomic, assign)LYBookPageRootController *parentController;

- (id)initWithFrame:(CGRect)frame pageClass:(Class)pageClassName;

//设置总面数
- (void)setPageCount:(NSInteger)count;

//设置当前页，并将视图滚动到正确的位置
//从目录进入时调用
- (void)setPageDisplayed:(NSInteger)pgIndex;


@end
