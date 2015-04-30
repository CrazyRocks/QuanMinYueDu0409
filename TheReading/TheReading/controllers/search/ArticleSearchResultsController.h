//
//  ArticleSearchResultsController.h
//  LongYuanYueDu
//
//  Created by  iMac001 on 12-10-26.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OWKit/OWKit.h>

@interface ArticleSearchResultsController : OWCommonTableViewController
{
    //当前搜索结果页码
    NSString *_keywords;
    
    
    __weak IBOutlet  UILabel                 *_noneResultMessageLB;
    __weak IBOutlet  UIActivityIndicatorView *_indicatorView;
    
    NSNumber    *searchCount;
    
    BOOL        isSearching;
}

-(void)beginSearch:(NSString *)keywords;

@end
