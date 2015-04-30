//
//  LYBookSlider.h
//  LYBookStore
//
//  Created by grenlight on 14-4-28.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GLSliderBubbleController;
@protocol LYBookSliderDelegate;

@interface LYBookSlider : UISlider
{
    GLSliderBubbleController *bubbleController;
    float touchLocationX;//触摸起始点
    
    NSInteger currentValue;
    
    BOOL    isThumbVisible;
}
@property(nonatomic,assign)id<LYBookSliderDelegate> delegate;

- (void)showThumb;
- (void)hideThumb;

@end

@protocol LYBookSliderDelegate <NSObject>

@optional
-(void)thumbStartTracking:(LYBookSlider *)slider  byValue:(NSInteger)value point:(CGPoint)point;
-(void)thumbMoved:(LYBookSlider *)slider  byValue:(NSInteger)value point:(CGPoint)point;
-(void)thumbStopTracking:(LYBookSlider *)slide  byValue:(NSInteger)value;
-(BOOL)canTouchThumb;

@end
