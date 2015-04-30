//
//  LYSFCell.h
//  LYBookStore
//
//  Created by grenlight on 14/6/18.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LYSFCell : UITableViewCell
{
    IBOutlet UILabel *titleLabel;
    IBOutlet UIImageView    *selectedIcon;
}

- (void)setInfo:(NSString *)title;

@end
