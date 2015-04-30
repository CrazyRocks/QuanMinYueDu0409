//
//  SelectionCell.h
//  TheReading
//
//  Created by grenlight on 15/1/6.
//  Copyright (c) 2015年 grenlight. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectionCell : UITableViewCell
{
    IBOutlet OWActivityIndicatorView *indicator;
}

- (void)showIndicator;
- (void)hideIndicator;

@end
