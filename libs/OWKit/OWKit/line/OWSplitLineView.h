//
//  OWSplitLineView.h
//  LYCommonLibrary
//
//  Created by grenlight on 14-1-16.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UIStyleObject;

@interface OWSplitLineView : UIView
{
    @private
    UIStyleObject *style;
}

- (void)drawByStyle:(UIStyleObject *)aStyle;

@end
