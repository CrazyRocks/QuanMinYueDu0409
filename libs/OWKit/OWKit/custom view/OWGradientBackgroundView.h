//
//  NavBarBackgroundView.h
//  LongYuanYueDu
//
//  Created by 龙源 on 13-8-18.
//  Copyright (c) 2013年 LONGYUAN. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIStyleObject;

@interface OWGradientBackgroundView : UIView
{
    @private
    UIStyleObject *style;
}
- (void)drawByStyle:(UIStyleObject *)aStyle;
@end
