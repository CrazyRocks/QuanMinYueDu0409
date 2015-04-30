//
//  OWAnnotationView.m
//  GLViewTest
//
//  Created by iMac001 on 12-5-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import "OWAnnotationView.h"
#import "OWAnnotationTextView.h"
#import <OWKit/OWColor.h>
#import <OWKit/OWImage.h> 

#define kCornerRadius  8.0f

#define kTriangleHeight 7.0f
#define kTriangleRadius  8.0f

#define PADDING_LEFT 25
#define PADDING_TOP 25

@interface OWAnnotationBubble : UIView
{
    BOOL isDirectionUp; 
}
@property(nonatomic,assign)float anglePointX;//尖角位置

-(id)initWithFrame:(CGRect)frame ;
-(void)drawRectByAnglePointX:(float)apx directionUp:(BOOL)b;

@end

@implementation OWAnnotationBubble

@synthesize anglePointX;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)drawRectByAnglePointX:(float)apx directionUp:(BOOL)b
{
    anglePointX = apx;
    isDirectionUp = b;
    [self setNeedsDisplay];

}

//当前是否为夜间模式
- (BOOL)isNightMode
{
    NSUserDefaults *defauts = [NSUserDefaults standardUserDefaults];
    NSString  *mode = [defauts stringForKey:@"scene_mode"];
    if ([mode isEqualToString:@"night"]) {
        NSLog(@"night Mode");
        return YES;
    }
    return NO;
}

- (long)popBorderColor
{
    if([self isNightMode])
        return 0X000000;
    else
        return 0xA09A87;
}

- (float)popBorderAlpha
{
    if([self isNightMode])
        return 1.0f;
    else
        return 1.0f;
}

- (long)popShadowColor
{
    return [self popBorderColor];
}

- (long)popShadowFillColor
{
    if([self isNightMode])
        return [self popBorderColor];
    else
        return 0xffffff;
}

- (float)popShadowFillColorAlpha
{
    if([self isNightMode])
        return [self popBorderAlpha];
    else
        return 0.4;
}

-(void)drawUpBubble:(CGContextRef)c :(CGRect)rect
{
    float rightJoinX, leftJoinX, anglePointY;
    rightJoinX = anglePointX + kTriangleRadius ;
    leftJoinX = anglePointX - kTriangleRadius;
     CGRect rectFrame = rect;
    rectFrame.size.height -= kTriangleHeight;

    if (isDirectionUp) {
        // Rect with radius, will be used to clip the entire view
        CGFloat minx = CGRectGetMinX(rect) + 1, midx = CGRectGetMidX(rectFrame),
        maxx = CGRectGetMaxX(rectFrame) ;
        CGFloat miny = CGRectGetMinY(rect) + 1, midy = CGRectGetMidY(rectFrame) ,
        maxy = CGRectGetMaxY(rectFrame) ;
       
        anglePointY = maxy + kTriangleHeight - .5;
        
        CGContextMoveToPoint(c, minx - .5, midy - .5);
        CGContextAddArcToPoint(c, minx - .5, miny - .5, midx - .5, miny - .5, kCornerRadius);
        CGContextAddArcToPoint(c, maxx - .5, miny - .5, maxx - .5, midy - .5, kCornerRadius);
        CGContextAddArcToPoint(c, maxx - .5, maxy - .5, rightJoinX, maxy - .5, kCornerRadius);
        CGContextAddLineToPoint(c, rightJoinX, maxy - .5);
        
        //弧形尖角
//        CGContextAddArc(c, rightJoinX, rect.size.height - .5, kTriangleRadius,  3.0*(M_PI/2.0),M_PI, true);
//        CGContextAddArc(c, leftJoinX , rect.size.height - .5, kTriangleRadius,   0.0, 3.0*(M_PI/2.0),true);
        
        //直线尖角
        CGContextAddLineToPoint(c, anglePointX, anglePointY);
        CGContextAddLineToPoint(c, leftJoinX, maxy - .5);
        
        CGContextAddArcToPoint(c, minx - .5, maxy - .5, minx - .5, midy - .5, kCornerRadius);
        CGContextClosePath(c); 
    }
    else {
        rectFrame.origin.y += kTriangleHeight;
        
        CGFloat minx = CGRectGetMinX(rectFrame) + 1, midx = CGRectGetMidX(rectFrame),
        maxx = CGRectGetMaxX(rectFrame) ;
        CGFloat miny = CGRectGetMinY(rectFrame) + 1, midy = CGRectGetMidY(rectFrame) ,
        maxy = CGRectGetMaxY(rectFrame) ;
        
        anglePointY = miny - (kTriangleHeight - .5);
        
        CGContextMoveToPoint(c, minx - .5, midy - .5);
        CGContextAddArcToPoint(c, minx - .5, miny - .5, leftJoinX, miny - .5, kCornerRadius);
        
        CGContextAddLineToPoint(c, leftJoinX, miny - .5);
        CGContextAddLineToPoint(c, anglePointX, anglePointY);
        CGContextAddLineToPoint(c, rightJoinX, miny - .5);

        CGContextAddArcToPoint(c, maxx - .5, miny - .5, maxx - .5, midy - .5, kCornerRadius);
        CGContextAddArcToPoint(c, maxx - .5, maxy - .5, midx-.5, maxy - .5, kCornerRadius);
      
        
        CGContextAddArcToPoint(c, minx - .5, maxy - .5, minx - .5, midy - .5, kCornerRadius);
        CGContextClosePath(c); 
    }
    
}

- (void)drawRect:(CGRect)rect
{
    
    CGRect newRect = rect;
    newRect.origin.x += 8;
    newRect.origin.y += 8;
    newRect.size.width -= 16;
    newRect.size.height -= 18;
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextSaveGState(c);
    CGContextSetShadowWithColor(c, CGSizeMake(0, 2), 8, [OWColor colorWithHex:0x000000 alpha:0.7].CGColor);
    [self drawUpBubble:c :newRect];
    CGContextSetFillColorWithColor(c, [OWColor colorWithHex:[self popShadowFillColor] alpha:[self popShadowFillColorAlpha]].CGColor);
    CGContextDrawPath(c, kCGPathFill);
    //    CGContextSaveGState(c);
    //
    CGContextRestoreGState(c);
    
    CGContextSaveGState(c);
    
    [self drawUpBubble:c :newRect];
    
    CGContextClip(c);
    
    //渐变填充
    CGGradientRef gradient;
    if([self isNightMode]) {
        CGFloat components[8] = {
            0x34/255.0, 0x34/255.0, 0x34/255.0, 0.95,
            0x35/255.0f, 0x35/255.0f, 0x35/255.0, 0.95
        };
        gradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, 2);
    }
    else {
        CGFloat components[8] = {
            0xff/255.0, 0xff/255.0, 0xff/255.0, 0.95,
            0xff/255.0f, 0xff/255.0f, 0xff/255.0, 0.95
        };
        gradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, 2);
    }
    
    CFRelease(colorSpace);
    CGContextDrawLinearGradient(c, gradient, CGPointZero, CGPointMake(0, rect.size.height), kCGGradientDrawsBeforeStartLocation);
    CFRelease(gradient);
    CGContextRestoreGState(c);
    
//    CGContextSetStrokeColorWithColor(c, borderColor.CGColor);
//    CGContextSetLineWidth(c, [GLConfig popBorderWidth]);
//    [self drawUpBubble:c :newRect];
//    CGContextStrokePath(c);
    
}

@end


@interface OWAnnotationView()
{
    BOOL angleDirectionUp;
    OWAnnotationBubble *bubble;
    
    CGPoint homeCenter, schoolCenter;
}
@end

@implementation OWAnnotationView

- (id)init
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tapGesture =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapped)];
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tapGesture];
        
    }
    return self;
}

//当前是否为夜间模式
- (BOOL)isNightMode
{
    NSUserDefaults *defauts = [NSUserDefaults standardUserDefaults];
    NSString  *mode = [defauts stringForKey:@"scene_mode"];
    if ([mode isEqualToString:@"night"]) {
        return YES;
    }
    return NO;
}

-(void)singleTapped
{
    CGAffineTransform transform = CGAffineTransformMakeScale(0.9, 0.9);
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
        [bubble setCenter:schoolCenter];
        [bubble setAlpha:0];
        bubble.transform = transform;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

-(void)setContent:(NSString *)cnt andAnglePoint:(CGPoint)point
{
    
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    
     
    float width, height,  contentHeight;
    if(cnt.length > 32)
        width = 310;
    else if(cnt.length > 20)
        width = 270;
    else if(cnt.length > 8)
        width = 230;
    else 
        width = 160;
    
    OWAnnotationTextView *textV = [[OWAnnotationTextView alloc]initWithFrame:CGRectMake(0, -7, width-PADDING_LEFT*2, 30)];
    contentHeight = [textV drawText:cnt byLayouter:self.layouter];
    
//    NSLog(@"contentHeight:%f",contentHeight);

    height = contentHeight + PADDING_TOP*2 + kTriangleHeight;
    if(contentHeight > 95){
       height = 95 + PADDING_TOP*2 + kTriangleHeight;
    }
    float x, y;
    angleDirectionUp = YES ;//true 为正，false 为反
    
    //触点位置小于左中心点或大于右中心点时，气泡保持不动，只调整尖角位置
    
//    rightCenterX = screenWidth - leftCenterX;


    if (width == screenWidth - 10) {
        x = 5;
    }
    else {
        x = point.x - width/2;
        if(x < 5){
            x = 5;
        }
        else if(x + width > (screenWidth - 10 + 5)){
            x = screenWidth - 10 + 5-width;
        }
    }
    
    if(point.y < height+80){
        y = point.y + 5;
        angleDirectionUp = NO;
    }
    else {
        y = point.y-(height+5);
    }
    
    
    CGRect frame = CGRectMake(x, y, width, height);
    
    bubble = [[OWAnnotationBubble alloc]initWithFrame:frame];
    float apx = [self convertPoint:point toView:bubble].x;
    [bubble drawRectByAnglePointX:apx directionUp:angleDirectionUp];
    [self addSubview:bubble];
    
    if (contentHeight > 50 ) {
        NSString *popUpMask = [self isNightMode] ? @"popUpMask_night@2x" : @"popUpMask@2x";
        NSString *popDownMask = [self isNightMode] ? @"popDownMask_night@2x" : @"popDownMask@2x";
        
        UIImageView *upMask = [[UIImageView alloc] initWithImage:
                               [OWImage imageWithNoneDeformable:[OWImage imageWithName:popUpMask bundle:[NSBundle bundleForClass:[self class]]]
                                                     edgeInsets:UIEdgeInsetsMake(0, 20, 0, 20)]];
        UIImageView *downMask = [[UIImageView alloc] initWithImage:
                               [OWImage imageWithNoneDeformable:[OWImage imageWithName:popDownMask  bundle:[NSBundle bundleForClass:[self class]]]
                                                     edgeInsets:UIEdgeInsetsMake(0, 20, 0, 20)]];
        CGRect frame1 ;
        CGRect frame2 ;
        
        if (angleDirectionUp) {
            frame1 = CGRectMake(9, 8, width-18, 14);
            frame2 =CGRectMake(9,  height - 14 - 11 - kTriangleHeight, width - 18, 14);
        }
        else {
            frame1 = CGRectMake(9, kTriangleHeight + 8, width-18, 14);
            frame2 =CGRectMake(9, height - 14 - 11, width - 18, 14);

        }
        
        [upMask setFrame:frame1];
        [downMask setFrame:frame2];
        
        [bubble addSubview:upMask];
        [bubble addSubview:downMask];
    }
    scrollView = [[UIScrollView alloc]init];
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.clipsToBounds = YES;
    scrollView.contentInset = UIEdgeInsetsMake(14, 0, 14, 0);    
    
    CGRect scrollRec ;
    if(angleDirectionUp)
        scrollRec = CGRectMake(PADDING_LEFT, PADDING_TOP-14, width, height +28 -( PADDING_TOP*2 + kTriangleHeight));
    else {
        scrollRec = CGRectMake(PADDING_LEFT, PADDING_TOP + kTriangleHeight-14, width, height + 28 -( PADDING_TOP*2 + kTriangleHeight));
    }
    
    [scrollView setFrame:scrollRec];
//    scrollView.contentOffset = CGPointMake(0, 10);
    scrollView.contentSize = CGSizeMake(width, contentHeight);
    scrollView.showsVerticalScrollIndicator = YES;
    scrollView.scrollEnabled = YES;
    [scrollView addSubview:textV];
    [bubble insertSubview:scrollView atIndex:0];
    
    [[[[UIApplication sharedApplication]windows]objectAtIndex:0] addSubview:self];
    homeCenter = bubble.center;
    schoolCenter = homeCenter;
    if(angleDirectionUp)
        schoolCenter.y += 30;
    else 
        schoolCenter.y -= 30;
    [bubble setCenter:schoolCenter];
    [bubble setAlpha:0.1];
    bubble.transform = CGAffineTransformMakeScale(0.9, 0.9);
    CGAffineTransform transform = CGAffineTransformMakeScale(1, 1);
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
        [bubble setCenter:homeCenter];
        [bubble setAlpha:1];
        bubble.transform = transform;
    } completion:^(BOOL finished) {
        
    } ];
    
}

-(void)dealloc
{
//    NSLog(@"OWAnnotationView_dealloc");
}

@end
