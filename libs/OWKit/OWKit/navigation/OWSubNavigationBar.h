//
//  SubNavigationBar.h
//  GoodSui
//
//  Created by 龙源 on 13-6-18.
//  Copyright (c) 2013年 grenlight. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UIStyleObject;

@interface OWSubNavigationItem : NSObject

@property (nonatomic, retain) NSString * catID;
@property (nonatomic, retain) NSNumber * isFavorite;
@property (nonatomic, retain) NSString * catName;
@property (nonatomic, retain) NSNumber * sort;

@end


@protocol SubNavigationBarDelegate;

@interface OWSubNavigationBar : UIView<UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    
    UIButton *selectedButton;
    
    NSArray *dataSource;
    
    NSMutableArray *buttons;
    
    //当前选择的类，不使用index来恢复当前的选择，是因为排序后，之前选择项的index产生了变化
    NSString        *selectedCategoryID;
    
    UIStyleObject   *style;
}
@property (nonatomic, assign) id<SubNavigationBarDelegate> delegate;

- (void)renderItems:(NSArray *)array;
- (void)renderItems:(NSArray *)array selectedIndex:(NSInteger)index;

- (void)setSelectedIndex:(NSInteger)index;

- (void)autoTapByIndex:(NSInteger)index;

@end

@protocol SubNavigationBarDelegate <NSObject>

@optional
- (float)navigationBarItemWidth;
//控制滚动区域及范围
- (UIEdgeInsets)subNavigationBarEdgeInsets;

- (void)navigationBarSelectedItem:(NSString *)itemID itemIndex:(NSInteger)index;

@end
