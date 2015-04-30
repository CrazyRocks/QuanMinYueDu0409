//
//  SectionHeader.m
//  LongYuanYueDu
//
//  Created by  iMac001 on 12-11-1.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import "SectionHeader.h"

@implementation SectionHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setTitle:(NSString *)title
{
    titleLabel.text = title;
    UIStyleObject *style = [[UIStyleManager sharedInstance] getStyle:@"收藏列表Header"];
    titleLabel.textColor = style.fontColor;
    titleLabel.font = [UIFont systemFontOfSize:style.fontSize];
    
    [self drawByStyle:style];
}

@end
