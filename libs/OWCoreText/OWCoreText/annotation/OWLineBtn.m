//
//  OWLineBtn.m
//  OWCoreText
//
//  Created by grenlight on 14-10-8.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "OWLineBtn.h"

@implementation OWLineBtn

+(CGPathRef)pathFromPoints:(NSArray*)points
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:[[points objectAtIndex:0] CGPointValue]];
    
    NSInteger count = points.count;
    for (NSInteger i = 1; i<count; i++)
    {
        [path addLineToPoint:[[points objectAtIndex:i] CGPointValue]];
    }
    [path closePath];
    
    return CGPathCreateCopy(path.CGPath);
}

-(id)initWithPoints:(NSArray*)points
{
    CGPathRef path = [OWLineBtn pathFromPoints:points];
    
    self = [super initWithFrame:CGPathGetBoundingBox(path)];
    
    if (self)
    {
        [self setUserInteractionEnabled:YES];
        CGAffineTransform t = CGAffineTransformMakeTranslation(-CGRectGetMinX(self.frame), -CGRectGetMinY(self.frame));
        [[self layer] setPath:CGPathCreateCopyByTransformingPath(path, &t)];
        [[self layer] setFillMode:kCAFillRuleNonZero];
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}

//-(void)setEvenOddFilRule:(BOOL)evenOddFilRule
//{
//    _evenOddFilRule = evenOddFilRule;
//
//    [[self layer] setFillMode:(_evenOddFilRule?kCAFillRuleEvenOdd:kCAFillRuleNonZero)];
//}


#pragma mark - Overrided methods.

+(Class)layerClass
{
    return [CAShapeLayer class];
}

-(CAShapeLayer*)layer
{
    return (CAShapeLayer*)[super layer];
}

-(void)setBackgroundColor:(UIColor *)backgroundColor
{
    [[self layer] setFillColor:backgroundColor.CGColor];
    
    [[self layer] setStrokeColor:backgroundColor.CGColor];
}

-(UIColor *)backgroundColor
{
    return [UIColor colorWithCGColor:[[self layer] fillColor]];
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (CGPathContainsPoint([[self layer] path], NULL, point, ([[self layer] fillRule] == kCAFillRuleEvenOdd)))
    {
        return [super hitTest:point withEvent:event];
    }
    else
    {
        return nil;
    }
    
}


@end
