//
//  OWShimmeringView.h
//  LYCommonLibrary
//
//  Created by grenlight on 14-5-7.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FBShimmeringView;

@interface OWShimmeringView : UIView
{
    FBShimmeringView        *shimmeringView;
}

@property (nonatomic, strong) UIColor *frontColor;

- (id)initWithMessage:(NSString *)msg;


@end
