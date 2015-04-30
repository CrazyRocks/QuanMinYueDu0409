//
//  OWScrollView.m
//
//  Created by  oowwww on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.
//

#import "OWInfiniteScrollView.h"
#import "OWInfiniteContentView.h"
#import "OWInfiniteCoreTextLayouter.h"
#import <QuartzCore/QuartzCore.h>
#import <OWKit/OWColor.h>
#import "OWMagnifierView.h"

@implementation OWInfiniteScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.canCancelContentTouches = NO;
        self.decelerationRate = 0.7;
        self.bounces = YES;
        self.alwaysBounceVertical = YES;
//        self.delaysContentTouches = NO;
        currentContentView = [[OWInfiniteContentView alloc] init];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)renderContent:(NSString *)content isShowHalf:(BOOL)bl defaultImageSize:(CGSize)imageSize
{
    float contentWidth = CGRectGetWidth(self.frame) - (self.contentInset.left + self.contentInset.right);
    CGRect layouterFrame = CGRectMake(0, 0, contentWidth, CGRectGetHeight(self.frame));
    float contentOffsetY = 0;
    
    if (headerView) {
        contentOffsetY = CGRectGetHeight(headerView.bounds);
    }
    contentOffsetY += -5;
    layouter = [[OWInfiniteCoreTextLayouter alloc] init];
    [layouter  initWithHTML:content frame:layouterFrame startPage:0 contentOffsetY:contentOffsetY defaultImageSize:imageSize];

    __block float contentHeight = (layouter.infiniteHeight>appHeight+40) ? layouter.infiniteHeight : appHeight+40;
   
    if (footerView) {
        contentHeight += CGRectGetHeight(footerView.frame);
        
        CGPoint fCenter = CGPointMake(contentWidth / 2.0f, contentHeight- CGRectGetHeight(footerView.frame) / 2.0);
        [footerView setCenter:fCenter];
        [self addSubview:footerView];
    }
    self.contentSize = CGSizeMake(contentWidth, contentHeight);

    CGRect frame = CGRectMake(0, 0, contentWidth, contentHeight);
    currentContentView = [[OWInfiniteContentView alloc]initWithFrame:frame];
    currentContentView.layouter = layouter;
    [self insertSubview:currentContentView atIndex:0];
    
    [self appModeChanging];
}

-(void)rerenderContent:(NSString *)content defaultImageSize:(CGSize)imageSize
{
    if (currentContentView) {
        [currentContentView removeFromSuperview];
        currentContentView = nil;
        layouter = nil;
    }
    
    if(content == nil)  return;
    
    [self renderContent:content isShowHalf:NO defaultImageSize:imageSize];
}

-(void)renderByLayouter:(OWCoreTextLayouter *)aLayouter offset:(CGPoint)offset
{
    [currentContentView removeFromSuperview];
    currentContentView = nil;
    
    [self appModeChanging];
    
    if (aLayouter == nil) {
        [self setContentOffset:CGPointZero];
        return;
    }
    layouter = aLayouter;
    float contentHeight = (layouter.infiniteHeight>appHeight) ? layouter.infiniteHeight : appHeight+1;
    self.contentSize = CGSizeMake(appWidth, contentHeight);
    
    CGRect frame = CGRectMake(0, 0, appWidth, contentHeight);
    
    currentContentView = [[OWInfiniteContentView alloc]initWithFrame:frame];
    currentContentView.layouter = layouter;
    currentContentView.backgroundColor =[UIColor clearColor];
    [self addSubview:currentContentView];
    
    [self loadBackground:frame];

    [self setContentOffset:offset];
}

- (void)loadBackground:(CGRect)frame
{
    [self.bg setFrame:frame];
    [self insertSubview:self.bg atIndex:0];
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bg.bounds];
    self.bg.layer.shadowPath = path.CGPath;
}

-(void)appModeChanging
{
    currentContentView.backgroundColor = [UIColor clearColor];;
}

-(void)layoutSubviews
{
    if(!layouter) return;

//    [currentContentView layoutSubviewsInRect:self.bounds];

}

-(void) setHeaderView:(UIView *)hv
{
    self.contentSize = CGSizeZero;
    if (!headerView) {
        headerView = hv;
        CGPoint center = CGPointMake(CGRectGetWidth(self.frame) /2.0f - self.contentInset.left, CGRectGetHeight(hv.frame)/2.0f);
        [hv setCenter:center];
        [self insertSubview:hv atIndex:1];
    }
    
    if(currentContentView) {
        [currentContentView removeFromSuperview];
        currentContentView = nil;
    }
}

-(void)setFooterView:(UIView *)fv
{
    footerView = fv;
}

//- (void)removeSubviewsOutsideRect:(CGRect)rect
//{
//    NSSet *pages = [NSSet setWithSet:inStagePages];
//	for (OWPageFragment *page in pages)
//	{
//		if (CGRectGetMinY(page.frame)> CGRectGetMaxY(rect) || CGRectGetMaxY(page.frame) < CGRectGetMinY(rect))
//		{
//            [page removeFromSuperview];
//            [sparePages addObject:page];
//            [inStagePages removeObject:page];
//		}
//	}
//}
//-(void)removeAllSubviews{
//    for(OWPageFragment *page in inStagePages){
//        [page removeFromSuperview];
//        [sparePages addObject:page];
//    }
//    [inStagePages removeAllObjects];
//}

//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    
//    magnifierView = [[OWMagnifierView alloc]initWithFrame:CGRectMake(0, 0, 95, 95)];
//    
//    CGPoint touchPoint = [[touches anyObject] locationInView:self.superview];
//    [magnifierView magnify:touchPoint viewChanged:YES];
//    
//}
//-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
//    CGPoint newPoint = [[touches anyObject] locationInView:self.superview];
//    [magnifierView magnify:newPoint viewChanged:NO];
//
//    
////    newPoint.y -= CGRectGetHeight(magnifierView.frame);
////    
////    [UIView animateWithDuration:0.2 animations:^{
////        [magnifierView setCenter:newPoint];
////    }];
//    
//}
//-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
//    [self removeMagnifierView];
//    
//}
//-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
//    [self removeMagnifierView];
//}
//
//-(void)removeMagnifierView{
//    [magnifierView removeFromSuperview];
//    magnifierView = nil;
//}

@end
