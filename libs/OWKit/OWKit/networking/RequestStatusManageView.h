//
//  RequestStatusViewManager.h
//  LongYuanYueDu
//
//  Created by 龙源 on 13-7-11.
//  Copyright (c) 2013年 LONGYUAN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OWShimmeringView.h"

@class OWActivityIndicatorView, OWViewController;

@interface RequestStatusManageView : UIView
{
    OWShimmeringView        *indicatorView;
    UIButton                *reloadButton;
    
}
@property (nonatomic, weak) OWViewController *parentViewController;
@property (nonatomic, assign) CGRect msgViewFrame;

@property (nonatomic, strong) NSString *loadingMessage;
@property (nonatomic, strong) NSString *errorMessage;
@property (nonatomic, strong) UIColor   *frontColor;

- (BOOL)isInternetReachable;

- (void)startRequest;
- (void)stopRequest;
- (void)requestFault;


@end
