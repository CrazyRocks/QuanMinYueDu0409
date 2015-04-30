//
//  PageScrollView.h
//  DragonSourceReader
//
//  Created by iMac001 on 11-12-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArticleViewController.h"

@class ArticleDetailController;

@interface HorizontalPageScrollView : UIScrollView<UIScrollViewDelegate,PageViewDelegate>{
    @private
    //所有内容的容器
    UIView *contentCanvas;
}

@property(nonatomic,retain)ArticleDetailController *prePage;
@property(nonatomic,retain)ArticleDetailController *currentPage;
@property(nonatomic,retain)ArticleDetailController *nextPage;

- (void)renderArticle;

@end
