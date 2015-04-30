//
//  MagSearchTableCell.h
//  PublicLibrary
//
//  Created by grenlight on 13-12-7.
//  Copyright (c) 2013年 grenlight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LYService/LYService.h>
#import <OWKit/OWKit.h>

@class LYMagazineSearchCellData;

@interface MagSearchTableCell : UITableViewCell
{
}
@property (nonatomic, retain) UIStyleObject  *listStyle;

- (void)setContent:(NSString *)title;
@end
