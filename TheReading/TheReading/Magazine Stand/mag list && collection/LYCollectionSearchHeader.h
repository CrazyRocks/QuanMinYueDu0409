//
//  LYMagCollectionHeader.h
//  LYMagazinesStand
//
//  Created by grenlight on 14-5-23.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LYCollectionSearchHeader : UIView
{
    __weak IBOutlet UIButton *searchButton;
}
//0: 杂志， 1：图书
@property (nonatomic, assign) NSInteger searchType;

- (IBAction)tapped:(id)sender;

@end
