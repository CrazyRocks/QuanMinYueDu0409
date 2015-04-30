//
//  OWMagnifierView.m
//  KWFBooks
//
//  Created by gren light on 12-9-4.
//
//

#import "OWMagnifierView.h"

@implementation FastCATiledLayer
+(CFTimeInterval)fadeDuration {
    return 0.0;
}
@end

@implementation OWMagnifierView
+ (Class)layerClass
{
    return [FastCATiledLayer class];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderColor = [[UIColor darkGrayColor] CGColor];
        self.layer.borderWidth = 1;
        self.layer.cornerRadius = CGRectGetWidth(frame) / 2;
        self.layer.masksToBounds = NO;
        
        self.backgroundColor = [UIColor clearColor];
        
        contentLayer = (id)[self layer];
        contentLayer.backgroundColor = [UIColor clearColor].CGColor;
        
        UIScreen *mainScreen = [UIScreen mainScreen];
        CGFloat scale = mainScreen.scale;
        
        CGSize tileSize = CGSizeMake(mainScreen.bounds.size.width*scale, mainScreen.applicationFrame.size.height * scale);
        contentLayer.tileSize = tileSize;
        
        diameter = CGRectGetHeight(frame);
        radius = diameter / 2.0f;
     
    }
    return self;
}
-(void)willMoveToSuperview:(UIView *)newSuperview{
    self.alpha = 0;
}
-(void)didMoveToSuperview{
    [UIView animateWithDuration:0.25 animations:^{
        [self setAlpha:1];
    }];
}
-(void)moveView{
    CGPoint newCenter = touchPoint;
    newCenter.x = floorf(newCenter.x);
    newCenter.y = floorf(newCenter.y);
    newCenter.y -= CGRectGetWidth(self.bounds);
    [UIView animateWithDuration:0.2 animations:^{
        [self setCenter:newCenter];
    }];
}
-(void)magnify:(CGPoint)point viewChanged:(BOOL)bl{
    touchPoint = point;

    if(bl){
        [self setCenter:point];
        UIView *windowview = [[UIApplication sharedApplication] keyWindow];
        
        UIGraphicsBeginImageContextWithOptions(windowview.bounds.size, YES, 2);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        [windowview.layer renderInContext:context];
        contentImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

    }
    [contentLayer setNeedsDisplay];
    [self moveView];

}


-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context{
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    CGContextFillRect(context, self.bounds);
    
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, 0, -CGRectGetHeight(self.frame));
    
    //等比缩放裁剪背景图片
    CGContextSaveGState(context);
    
    UIBezierPath *clipPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                        cornerRadius:CGRectGetWidth(self.bounds)/2.0f];
    CGContextAddPath(context, [clipPath CGPath]);
    CGContextClip(context);
    
    CGContextSetFillColorWithColor(context, [[UIColor grayColor] CGColor]);
    CGContextFillRect(context, self.bounds);
    
    CGRect cntFrame = CGRectZero;
    cntFrame.size = contentImage.size;
    cntFrame.origin.x =  floorf(radius - touchPoint.x) ;
    cntFrame.origin.y =  floorf(touchPoint.y - cntFrame.size.height + radius);

//    NSLog(@"%f, %f,  %f, %f",cntFrame.origin.x,cntFrame.origin.y,cntFrame.size.width,cntFrame.size.height);
    CGContextDrawImage(context, cntFrame, contentImage.CGImage);
    
    
    CGContextRestoreGState(context);
}
@end
