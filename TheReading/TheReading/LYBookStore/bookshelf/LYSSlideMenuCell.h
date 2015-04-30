//
//  LYSSlideMenuCell.h
//  LYBookStore
//
//  Created by grenlight on 14/8/25.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LYSSlideMenuCell : UITableViewCell
{
    __weak IBOutlet UILabel *titleLB;
    __weak IBOutlet OWSplitLineView *splitLine;

}

- (void)setInfo:(NSString *)title;

@end
