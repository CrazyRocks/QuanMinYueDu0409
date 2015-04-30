//
//  OWCSSButton.h
//  YuanYang
//
//  Created by grenlight on 14/6/22.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UIStyleObject;
@interface OWCSSButton : UIButton
{
    UIStyleObject   *css;
}
- (void)setStyleName:(NSString *)styleName;

@end
