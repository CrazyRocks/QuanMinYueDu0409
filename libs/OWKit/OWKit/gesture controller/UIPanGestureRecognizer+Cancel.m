//
//  UIPanGestureRecognizer+Cancel.m
//  GoodSui
//
//  Created by 龙源 on 13-9-12.
//  Copyright (c) 2013年 grenlight. All rights reserved.
//

#import "UIPanGestureRecognizer+Cancel.h"

@implementation UIPanGestureRecognizer (Cancel)

- (void)cancel
{
    self.enabled = NO;
    self.enabled = YES;
}

@end
