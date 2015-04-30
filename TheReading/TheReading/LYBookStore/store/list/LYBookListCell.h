//
//  LYBookListCell.h
//  LYBookStore
//
//  Created by grenlight on 14-5-7.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OWKit/OWBottomAlignImageView.h>

@interface LYBookListCell : UICollectionViewCell
{
    IBOutlet OWBottomAlignImageView  *webImageView;
    IBOutlet UILabel      *bookNameLB;
    
    IBOutlet NSLayoutConstraint *titleHeightConstraint;
        
}
- (void)setContent:(NSDictionary *)info ;

@end
