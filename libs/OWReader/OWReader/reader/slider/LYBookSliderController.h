//
//  LYBookSliderController.h
//  LYBookStore
//
//  Created by grenlight on 14-4-25.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LYBookSlider.h"
#import "OWProgressView.h"

typedef void (^SliderBlock)(NSInteger);
@protocol GLSliderDelegate;

@interface LYBookSliderController : UIViewController<LYBookSliderDelegate>
{
    //当前页码改变后的回调方法
    SliderBlock valueChangeCallBack;
    
    CGRect homeFrame, schoolFrame;
    CGPoint    homeCenter, schoolCenter;
    
    //是否可以滑动
    BOOL    canSlide;
    
    __weak IBOutlet LYBookSlider   *slider;
    __weak IBOutlet OWProgressView *progressView;
}
@property(nonatomic,assign)id<GLSliderDelegate> delegate;
@property(nonatomic,assign)NSInteger currentValue;

//+ (instancetype)sharedInstance;

- (void)setPageCount:(NSInteger)count;
- (void)setPageDisplayed:(NSInteger)pgIndex;

- (void)showSlider;
- (void)hideSlider;

- (void)showProgressView;
- (void)hideProgressView;

@end

@protocol GLSliderDelegate <NSObject>

@optional
-(NSInteger)sliderMaxValue;
-(NSInteger)sliderCurrentValue;
-(NSString *)sliderCurrentTitle;
//根据当前值取得Title
-(NSString *)sliderGetTitleByCurrentValue:(NSInteger)cv;
-(void)sliderValueChanged:(NSInteger)pageNum;

@end