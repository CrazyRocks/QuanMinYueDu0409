//
//  UILabel+AutoBreakAndResize.m
//  LongYuanDigest
//
//  Created by 龙源 on 13-6-21.
//  Copyright (c) 2013年 longyuan. All rights reserved.
//

#import "UILabel+AutoBreakAndResize.h"

@implementation UILabel (AutoBreakAndResize)

- (void)setMultiLineText:(NSString *)txt
{
    CGSize txtSize = [txt sizeWithFont:self.font constrainedToSize:CGSizeMake(CGRectGetWidth(self.frame), appHeight)];
    float buttomDistance = appHeight - CGRectGetMaxY(self.frame);
    CGRect frame = self.frame;
    frame.origin.y = appHeight - (txtSize.height + buttomDistance);
    frame.size.height = txtSize.height;
    [self setFrame:frame];
    [self setText:txt];
}

@end
