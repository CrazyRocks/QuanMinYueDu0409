//
//  NextChapterIndicator.m
//  KWFBooks
//
//  Created by gren light on 13-3-24.
//
//

#import "NextChapterIndicator.h"
#import <OWKit/OWKit.h>
#import <LYService/LYService.h>

@implementation NextChapterIndicator

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    homeCenter = CGPointMake(appWidth/2, appHeight + CGRectGetHeight(self.frame)/2.0f);
    [self setCenter:homeCenter];
    
    schoolCenter = CGPointMake(appWidth/2, -CGRectGetHeight(self.frame)/2.0f);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float temY = scrollView.contentOffset.y - (scrollView.contentSize.height - appHeight + 10);
    if (temY > 0 && temY < CGRectGetHeight(self.frame)) {
        [self setCenter:CGPointMake(homeCenter.x, homeCenter.y - temY)];
    }
}

- (void)goHome
{
    [self setCenter:homeCenter];
}

- (void)goToSchool
{
    [self setCenter:schoolCenter];
}

- (void)drawRect:(CGRect)rect
{
    __block CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 0.5f);
    
    __block CGFloat minx, midx, maxx, miny, midy, maxy;
    __block CGRect rrect;
    __block float radius = 3;
    
    void(^DrawRect)(CGRect) = ^(CGRect rrect) {
        minx = CGRectGetMinX(rrect);
        midx = CGRectGetMidX(rrect);
        maxx = CGRectGetMaxX(rrect);
        miny = CGRectGetMinY(rrect) ;
        midy = CGRectGetMidY(rrect) ;
        maxy = CGRectGetMaxY(rrect);
        CGContextMoveToPoint(context, minx , maxy );
        CGContextAddArcToPoint(context, minx , miny , midx , miny, radius);
        CGContextAddArcToPoint(context, maxx , miny , maxx , maxy , radius);
        CGContextAddLineToPoint(context, maxx, maxy);
//        CGContextAddLineToPoint(context, minx, maxy);
        CGContextClosePath(context);
    };
    
    CGContextSetShadowWithColor(context, CGSizeMake(0, 0), 1, [OWColor colorWithHex:0x000000 ].CGColor);
    
    //外边框
    CGContextSetStrokeColorWithColor(context, [OWColor colorWithHex:0x000000 alpha:1].CGColor);
    rrect = CGRectMake(0.25, 1.25, CGRectGetWidth(rect)-0.5, CGRectGetHeight(rect)-1.25f);
    DrawRect(rrect);
    CGContextDrawPath(context, kCGPathStroke);
    CGContextSaveGState(context);


    rrect = CGRectMake(0.25, 1.25, CGRectGetWidth(rect)-0.5, CGRectGetHeight(rect)-1.25f);
    DrawRect(rrect);
	CGContextClip(context);
    
    NSArray *fillColor = [OWColor gradientColorWithHexString:@"#333333,#585858"];
    
    float(^getComponent)(uint) = ^(uint index){
        return  [fillColor[index] floatValue];
    };
    //渐变填充
    CGFloat components[8] = {
        getComponent(0), getComponent(1), getComponent(2), getComponent(3),
        getComponent(4), getComponent(5), getComponent(6), getComponent(7)
	};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, 2);
	CGContextDrawLinearGradient(context, gradient, CGPointZero, CGPointMake(0, rect.size.height), kCGGradientDrawsBeforeStartLocation);
	CFRelease(gradient);
    CFRelease(colorSpace);
    CGContextRestoreGState(context);    
    

    //内阴影
    CGContextSetStrokeColorWithColor(context, [OWColor colorWithHex:0xffffff alpha:0.2].CGColor);
    rrect = CGRectMake(0.75, 1.75, CGRectGetWidth(rect)-1.5, CGRectGetHeight(rect)-2.25f);
    DrawRect(rrect);
    CGContextDrawPath(context, kCGPathStroke);
    

}


@end
