//
//  SearchCell.h
//  LYBookStore
//
//  Created by grenlight on 14/10/30.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchModel.h"
@interface SearchCell : UITableViewCell

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *line;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *contentLab;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *catLab;
@property (nonatomic, retain) SearchModel *model;


-(void)setCellViewContent;

@end
