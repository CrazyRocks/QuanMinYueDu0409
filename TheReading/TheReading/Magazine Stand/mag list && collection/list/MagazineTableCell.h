//
//  MagazineTableCell.h
//  LongYuanYueDu
//
//  Created by  iMac001 on 12-10-18.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>


@interface MagazineTableCell : UITableViewCell
{
    IBOutlet UIImageView  *webImageView;
    IBOutlet UILabel      *magNameLabel;
    IBOutlet UILabel      *updateTimeLabel;
}
-(void)setContent:(NSDictionary *)info ;
@end
