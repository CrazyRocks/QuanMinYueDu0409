//
//  OWBookButton.h
//  LYBookStore
//
//  Created by grenlight on 14/7/19.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <OWKit/OWKit.h>

@interface OWBookButton : OWAnimationButton
{
    @private
    NSString *imageName;
}
- (void)setIcon:(NSString *)iconName;

@end
