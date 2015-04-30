//
//  ArticleHeaderViewController.h
//  LYMagazinesStand
//
//  Created by grenlight on 14-3-9.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import <OWKit/OWKit.h>
#import <LYService/LYService.h>

@interface ArticleHeaderViewController : OWViewController
{
    __weak IBOutlet UILabel *magNameLB, *timeLB;
    __weak IBOutlet UIView     *lineView;
}

- (void)setContentInfo:(LYArticleTableCellData *)cellData;
- (void)updateContentInfo:(LYArticle *)cellData;

@end
