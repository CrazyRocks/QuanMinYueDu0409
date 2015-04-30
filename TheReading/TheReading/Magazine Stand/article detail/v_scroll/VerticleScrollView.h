//
//  VerticleScrollView.h
//  LYMagazinesStand
//
//  Created by grenlight on 14-3-9.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ArticleDetailController, NextChapterIndicator;

@interface VerticleScrollView : UIView<UIScrollViewDelegate>
{
    ArticleDetailController            *contentView;
    ArticleDetailController            *maskView;
    
    NextChapterIndicator                *nextIndicator;

    NSInteger           pageDisplayed;
    
    NSInteger           currentRequsted;
    //总页数
    NSInteger           pageCount;
    
@private
    float                  contentOffsetY;
    CGPoint                preCenter, currentCenter, nextCenter;
    
}

@end
