//
//  LYRefreshIndicator.h
//  OWKit
//
//  Created by grenlight on 14/7/25.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIStyleObject.h"

@interface LYRefreshIndicator : UIView
{
    float progress;
    
    NSInteger   currentStep;
    
    id          displayLink;
    BOOL        isAnimating;
}
//最大下拉值
@property (nonatomic, assign) float maxDropDownDistance;
//在此值之前不走进度
@property (nonatomic, assign) float offsetY;

@property (nonatomic, strong) UIStyleObject   *style;

-(void)startAnimating;
-(void)stopAnimating;

- (void)dropDistance:(float)distance;

@end
