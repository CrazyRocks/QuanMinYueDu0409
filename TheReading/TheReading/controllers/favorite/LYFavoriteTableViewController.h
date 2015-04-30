//
//  FavoriteTableViewController.h
//  LongYuanYueDu
//
//  Created by  iMac001 on 12-10-31.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecommendArticleTableCell.h"

@interface LYFavoriteTableViewController : OWCommonTableViewController<OWTableViewDataSourceDelegate>
{
    IBOutlet UILabel      *messageLable;
    
    IBOutlet UIButton *editButton, *backButton;
    
    BOOL                   isEditMode;
    NSIndexPath           *willDeletedIndexPath;

}
@property (nonatomic, copy) ReturnMethod returnToPreController;

- (void)setBackButtonImage:(UIImage *)img;

- (void)setup;
- (IBAction)editing:(id)sender;

@end
