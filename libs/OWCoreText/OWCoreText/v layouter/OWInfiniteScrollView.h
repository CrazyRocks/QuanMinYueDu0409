//
//  OWScrollView.h
//
//  Created by  oowwww on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OWInfiniteCoreTextLayouter, OWInfiniteContentView, OWCoreTextLayouter,  OWMagnifierView;

@interface OWInfiniteScrollView : UIScrollView
{
@private
    OWCoreTextLayouter      *layouter;

    OWInfiniteContentView   *currentContentView;
    //放大镜
    OWMagnifierView         *magnifierView;
    
    UIView                  *headerView;
    UIView                  *footerView;
}
@property (nonatomic, strong) UIView *bg;

-(void)setHeaderView:(UIView *)hv;
-(void)setFooterView:(UIView *)fv;

-(void)renderContent:(NSString *)content isShowHalf:(BOOL)bl defaultImageSize:(CGSize)imageSize;

//重新渲染文章，当用户调整了字号大小时
-(void)rerenderContent:(NSString *)content defaultImageSize:(CGSize)imageSize;

-(void)renderByLayouter:(OWCoreTextLayouter *)aLayouter offset:(CGPoint)offset;
@end
