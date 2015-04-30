//
//  RecommentTableCell.h
//  LongYuanYueDu
//
//  Created by  iMac001 on 12-10-16.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OWKit/OWKit.h>
#import "LYMagazinesStand.h"

@class OWTiledView, LYArticleTableCellData;

@interface RecommendArticleTableCell : UITableViewCell
{
    __weak IBOutlet UIImageView  *webImageView;
    __weak  LYArticleTableCellData  *contentInfo;
    
    __weak IBOutlet NSLayoutConstraint *thumbHeightConstraint, *thumbTrailingConstraint;

    __weak IBOutlet UIImageView     *logoImageView;
    __weak IBOutlet UILabel    *titleLabel, *magLabel, *summaryLabel;
}

- (void)setContent:(LYArticleTableCellData *)info;
-(void)rerenderContent;

@end
