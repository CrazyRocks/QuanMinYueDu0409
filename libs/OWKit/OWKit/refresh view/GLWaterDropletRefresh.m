//
//  WaterDropletRefresh.m
//  RefreshEffect
//
//  Created by grenlight on 14-1-1.
//  Copyright (c) 2014年 OWWWW. All rights reserved.
//

#import "GLWaterDropletRefresh.h"
#import "OWBlockDefine.h"
#import "OWColor.h"


@implementation GLWaterDropletRefresh

- (id)initWithWidth:(float)w
{
    CGRect frame = CGRectMake(0, 0, w, 100);
    self = [super initWithFrame:frame];
    if (self) {
        CGRect bgFrame = CGRectInset(frame, -1, -1);
        bg = [[UIView alloc] initWithFrame:bgFrame];
        bg.backgroundColor = [OWColor colorWithHexString:@"#ee000000"];
        bg.layer.borderWidth = 1;
        bg.layer.borderColor = [OWColor colorWithHexString:@"#666666"].CGColor;
        [bg setAlpha:0];
        [self addSubview:bg];
        
        dropletView = [[WaterDropletView alloc] initWithWidth:w];
        dropletView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:dropletView];
        self.backgroundColor = [UIColor clearColor];
        
        isDropped = NO;
        canMoveable = NO;
        normalCenter = CGPointMake(w/2.0f, - 50);
        refreshingCenter = CGPointMake(normalCenter.x, normalCenter.y + CGRectGetHeight(self.frame));
    }
    return self;
}

- (void)setOwner:(UIScrollView *)owner
{
    _owner = owner;
    [dropletView setOwner:owner];
}

- (void)setLineColor:(UIColor *)lineColor
{
    _lineColor = lineColor;
    [dropletView setLineColor:lineColor];
}

- (void)setCircleColor:(UIColor *)circleColor
{
    [dropletView setCircleColor:circleColor];
}

- (void)setRefreshBlock:(GLNoneParamBlock)refreshBlock
{
    [dropletView setRefreshBlock:refreshBlock];
}

- (void)ownerTouchBegan
{
    if (fabs(self.center.y - normalCenter.y) < 0.1 && fabs(self.owner.contentOffset.y - 0.0) < 0.1) {
        canMoveable = YES;
        isDropped = NO;
    }
    else {
        canMoveable = NO;
    }
}

- (void)dropByOffsetY:(float)offsetY
{
    if (!canMoveable)
        return;
    
    CGPoint center = CGPointMake(normalCenter.x, normalCenter.y + offsetY);
   
    //正在刷新，则视图固定不动
    if (isDropped) {
        [self setCenter:refreshingCenter];
    }
    else if (center.y >= 50) {
        isDropped = YES;
        canMoveable = NO;
        [dropletView droppingAnimating];
        [UIView animateWithDuration:0.2 delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                                [bg setAlpha:1];
                            } completion:Nil];
    }
    else if (center.y < 50 && center.y >= normalCenter.y){
        [self setCenter:center];
//        NSLog(@"move:%f",center.y);
        [dropletView pullByOffsetY:offsetY];
    }
}


- (void)stopAnimating
{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [self setCenter:normalCenter];
                     } completion:^(BOOL finished) {
                         if (finished) {
                             isDropped = NO;
                         }
                     }];
    
    [UIView animateWithDuration:1 delay:0
                        options:UIViewAnimationOptionCurveEaseIn animations:^{
                            [bg setAlpha:0];
                        } completion:Nil];
    
    [dropletView stopAnimating];

}


@end
