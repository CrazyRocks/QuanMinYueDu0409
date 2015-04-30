//
//  UIScrollView+CancleScrolling.m
//  GoodSui
//
//  Created by 龙源 on 13-9-12.
//  Copyright (c) 2013年 grenlight. All rights reserved.
//

#import "UIScrollView+CancleScrolling.h"

@implementation UIScrollView (CancleScrolling)

- (void)cancleScroll
{
    self.scrollEnabled = NO;
    self.scrollEnabled = YES;
}
@end
