//
//  GLAlphaInController.m
//  LogicBook
//
//  Created by iMac001 on 12-3-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GLAlphaInController.h"

@interface GLAlphaInController ()

@end

@implementation GLAlphaInController


- (void)viewWillAppear:(BOOL)animated
{
    [self.view setAlpha:0];
    [super viewWillAppear:animated];
    
    [UIView animateWithDuration:0.75 animations:^{
        [self.view setAlpha:1];
    }];
}


@end
