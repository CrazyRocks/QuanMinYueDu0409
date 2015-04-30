//
//  ArticleSearchResultTableCell.h
//  LongYuanYueDu
//
//  Created by  iMac001 on 12-10-26.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LYMagazinesStand.h"
#import <OWKit/OWKit.h>
#import <LYService/LYService.h>

@class LYArticleTableCellData,OWTiledView;

@interface ArticleSearchResultTableCell : ArticleTableCell
{
    @private
    __weak IBOutlet UILabel        *titleLB;
    
    __weak IBOutlet OWSplitLineView    *splitLine;

}
@property (nonatomic, weak) UIStyleObject *styleObject;

-(void)setContent:(LYArticleTableCellData *)info;

@end
