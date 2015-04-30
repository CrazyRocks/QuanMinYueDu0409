//
//  OWBundleButton.h
//  OWKit
//
//  Created by grenlight on 14/7/23.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "OWAnimationButton.h"

@interface OWBundleButton : OWAnimationButton
{
@private
    NSString    *imageName;
}
- (void)setIcon:(NSString *)iconName inBundle:(Class)bundleClass;

@end
