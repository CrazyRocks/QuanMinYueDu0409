//
//  MagCatelogueCell.h
//  LongYuanYueDu
//
//  Created by 龙源 on 13-7-12.
//  Copyright (c) 2013年 LONGYUAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArticleTableCell.h"

@interface MagCatelogueCell : UITableViewCell
{
    __weak IBOutlet UILabel    *titleLabel;

}

- (void)setContent:(LYMagCatelogueTableCellData *)info;

@end
