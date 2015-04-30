//
//  loadViewAdaptToScreenController.m
//  LongYuanYueDu
//
//  Created by  iMac001 on 12-10-15.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import "loadViewAdaptToScreenController.h"

@interface loadViewAdaptToScreenController ()

@end

@implementation loadViewAdaptToScreenController

-(void)loadView
{
    [super loadView];
    CGRect frame = CGRectMake(0, 0, appWidth, appHeight);
    self.view = [[UIView alloc] initWithFrame:frame];
}


@end
