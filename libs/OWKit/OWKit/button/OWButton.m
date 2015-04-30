//
//  GLButton.m
//  KWFBooks
//
//  Created by gren light on 13-2-23.
//
//

#import "OWButton.h"
#import "OWControlCSS.h"

@implementation OWButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setTitle:(NSString *)title style:(OWControlCSS *)cssStyle
{
    css = cssStyle;
    self.backgroundColor = [UIColor clearColor];
    
    [self setTitleColor:css.textColor_normal forState:UIControlStateNormal];
    [self setTitleColor:css.textColor_highlight forState:UIControlStateHighlighted];
    [self setTitleColor:css.textColor_disabled forState:UIControlStateDisabled];
    
    [self setTitle:title];
}

- (void)setTitle:(NSString *)title
{
    [self setTitle:title forState:UIControlStateNormal];
    [self setTitle:title forState:UIControlStateSelected];
    [self setTitle:title forState:UIControlStateHighlighted];
    [self setTitle:title forState:UIControlStateDisabled];
}

- (void)drawRect:(CGRect)rect
{
    __block CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(context, YES);
    
    CGRect borderRect = CGRectMake(0.25, 0.25, CGRectGetWidth(rect)-0.5f, CGRectGetHeight(rect)-1.0f);
    __block CGFloat minx, midx, maxx, miny, midy, maxy;
    
    void(^DrawRect)(CGRect) = ^(CGRect rrect) {
        minx = CGRectGetMinX(rrect);
        midx = CGRectGetMidX(rrect);
        maxx = CGRectGetMaxX(rrect);
        miny = CGRectGetMinY(rrect) ;
        midy = CGRectGetMidY(rrect) ;
        maxy = CGRectGetMaxY(rrect);
        CGContextMoveToPoint(context, minx , midy );
        CGContextAddArcToPoint(context, minx , miny , midx , miny, css.cornerRadius);
        CGContextAddArcToPoint(context, maxx , miny , maxx , midy , css.cornerRadius);
        CGContextAddArcToPoint(context, maxx , maxy , midx , maxy , css.cornerRadius);
        CGContextAddArcToPoint(context, minx , maxy, minx , midy , css.cornerRadius);
        CGContextClosePath(context);
    };
    
    float(^getComponent)(NSInteger) = ^(NSInteger index){
        if (needFill) {
            return  [css.fillColor_highlight[index] floatValue];
        }
        return  [css.fillColor_normal[index] floatValue];
    };
    
    //draw drop shadow
    CGContextSetLineWidth(context, css.borderWidth / 2.0f);
    CGContextSetStrokeColorWithColor(context, needFill ? css.shadowColor_highlight.CGColor : css.shadowColor_normal.CGColor);
    DrawRect(CGRectOffset(borderRect, 0, 0.25));
    CGContextDrawPath(context, kCGPathStroke);

    //draw fill
    CGContextSaveGState(context);
    
    DrawRect(borderRect);
	CGContextClip(context);
   
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

    //draw border
    CGContextSetStrokeColorWithColor(context, needFill ? css.borderColor_highlight.CGColor : css.borderColor_normal.CGColor);
    DrawRect(borderRect);
    CGContextDrawPath(context, kCGPathStroke);

    //draw inner glow
    if (css.innerGlow_normal) {
        CGFloat glowAlpha ;
        UIColor *glowColor = needFill ? css.innerGlow_highlight : css.innerGlow_normal;
        CGFloat red, green, blue;
        [glowColor getRed:&red green:&green blue:&blue alpha:&glowAlpha];
        CGContextSetLineWidth(context, 0.5);
       
        for (NSInteger i = 0; i < css.innerGlowWidth; i++) {
            CGRect glowRect = CGRectMake(borderRect.origin.x + 0.25 + 0.5*i, borderRect.origin.y + 0.25 + 0.5*i,
                                         CGRectGetWidth(borderRect)-0.5 - i, CGRectGetHeight(borderRect)-0.5 - i);
            CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:red green:green blue:blue alpha:glowAlpha-(glowAlpha/css.innerGlowWidth) * i].CGColor);
            DrawRect(glowRect);
            CGContextDrawPath(context, kCGPathStroke);

        }
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    needFill = YES;
    [self setNeedsDisplay];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    needFill = NO;
    [self setNeedsDisplay];
    [super touchesEnded:touches withEvent:event];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    needFill = NO;
    [self setNeedsDisplay];
}

@end
