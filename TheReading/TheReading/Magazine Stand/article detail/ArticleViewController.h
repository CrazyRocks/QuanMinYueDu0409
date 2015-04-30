//
//  CoreTextPageViewController.h
//  DragonSourceEPUB
//
//  Created by iMac001 on 12-1-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OWKit/OWKit.h>

#import <LYService/LYGlobalConfig.h> 

@class OWInfiniteScrollView,LYArticleTableCellData, LYArticleManager;
@protocol PageViewDelegate;

@interface ArticleViewController : loadViewAdaptToScreenController<UIScrollViewDelegate>
{
    float touchLocationY;
 
    OWInfiniteScrollView          *pageContentView;
    LYArticleTableCellData          *currentArticle;

    ArticleDetailReaderStatus      currentState;
    
    NSString                      *headerHTML, *contentHTML;
    
    LYArticleManager    *requestManager;

}

@property(nonatomic,assign)id<PageViewDelegate> delegate;


-(void)setPagePosition:(CGRect )rect ;
-(void)setArticle:(LYArticleTableCellData *)article;
//装载文章标题信息,释放旧的文章数据
-(void)loadHeader;
//下载文章并呈现
-(void)loadArticle;

-(void)fontSizeChange;

-(NSString *)getArticleWebURL;

@end

