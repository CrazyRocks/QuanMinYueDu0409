//
//  MainMenuCell.h
//  PublicLibrary
//
//  Created by grenlight on 14-1-24.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainMenuCell : UITableViewCell
{
    __weak IBOutlet UIImageView    *iconView;
    __weak IBOutlet UILabel    *titleLB;

    UIStyleObject   *style;
    LYMenuData *cntInfo;
    
    __weak IBOutlet NSLayoutConstraint *iconLeftConstraint, *iconTopConstraint;
    __weak IBOutlet NSLayoutConstraint *titleLeftConstraint, *titleTopConstraint;
}
@property (nonatomic ,assign) BOOL needRenderForiPad;

- (void)setContent:(LYMenuData *)info;

@end
