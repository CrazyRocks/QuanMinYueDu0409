//
//  LYSettingViewCell.h
//  LYBookStore
//
//  Created by grenlight on 14/8/28.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LYSettingViewCell : UITableViewCell
{
    CGPoint normalCenter, schoolCenter;
}
@property (nonatomic, weak) IBOutlet OWActivityIndicatorView *indicatorView;
@property (nonatomic, weak) IBOutlet UILabel          *titleLable, *messageLB;
@property (nonatomic, weak) IBOutlet UIImageView        *nextView;

@property (nonatomic, strong) NSIndexPath               *indexPath;
@property (nonatomic, copy) GLTableCellBlock             cellBlock;

- (void)renderStyleByTable:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;
- (void)checkUpdate;

@end
