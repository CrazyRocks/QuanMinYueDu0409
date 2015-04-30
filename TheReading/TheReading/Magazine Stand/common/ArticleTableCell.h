//
//  RecommentTableCell.h
//  LongYuanYueDu
//
//  Created by  iMac001 on 12-10-16.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OWCoreText/OWCoreTextLabel.h>
#import <OWKit/OWKit.h>
#import <LYService/LYService.h>
#import <SDWebImage/UIImageView+WebCache.h>

@class OWInfiniteContentView;

@interface ArticleTableCell : UITableViewCell
{
    
    __weak IBOutlet UIImageView  *webImageView;
    
    __weak  LYArticleTableCellData  *contentInfo;
    
    OWCoreTextLabel     *textLabel;

}

-(void)setContent:(LYArticleTableCellData *)info;
//已读样式重绘
-(void)rerenderContent;

@end
