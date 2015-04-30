//
//  BookDigestTableViewCell.h
//  LYBookStore
//
//  Created by grenlight on 14-10-16.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookDigest.h"
#import <OWCoreText/OWSinglePageView.h>

@interface BookDigestTableViewCell : UITableViewCell
{

    UIFont *font;
    CGRect tFrame;

    UIStyleObject *style;
    __weak IBOutlet UILabel *timeLab;
    __weak IBOutlet UILabel *pageLab;
    __weak IBOutlet UILabel *messageLab;
    __weak IBOutlet UILabel *msgLab;

    __weak IBOutlet OWSplitLineView *line;
    
    IBOutlet NSLayoutConstraint  *lineTopConstraint;
}

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *digestStrLab;
@property BookDigest *digestModel;


-(void)renderContent:(BookDigest *)bd;

- (CGFloat)getCellHeight;

@end
