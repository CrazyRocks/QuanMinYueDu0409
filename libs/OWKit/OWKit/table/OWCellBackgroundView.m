//
//  OWCellBackgroundView.m
//  KWFBooks
//
//  Created by gren light on 13-3-25.
//
//

#import "OWCellBackgroundView.h"
#import "OWColor.h"


@implementation OWCellBackgroundView


@synthesize borderColor, borderWidth, fillColor, position;
@synthesize paddingLeft, cornerRadius;
@synthesize glowRadius, isSelectedBackgroundView;
@synthesize splitColor, splitWidth;

- (id)init
{
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        borderWidth = 0.5;
        glowRadius = 0;
        splitColor = borderColor = @"#999999";
        splitWidth = 0.5;
        fillColor = @"#ffffff";
        cornerRadius = 4;
        isSelectedBackgroundView = NO;
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{    
    __block CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(c, [[OWColor colorWithHexString:fillColor] CGColor]);
    CGContextSetStrokeColorWithColor(c, [[OWColor colorWithHexString:borderColor] CGColor]);
    CGContextSetLineWidth(c, borderWidth);
    
    rect.origin.x = paddingLeft;
    rect.size.width -= paddingLeft * 2;
    
    CGFloat minx = CGRectGetMinX(rect) ,  maxx = CGRectGetMaxX(rect) ;
    CGFloat maxy = CGRectGetMaxY(rect) ;
    
    __block CGFloat minx2, midx2, maxx2, miny2, midy2, maxy2;

    __block CGRect drawRect, glowRect;
    void(^DrawPath)(CGRect);
    
    void(^calculateCoordinate)(CGRect) = ^(CGRect rct){
        minx2 = CGRectGetMinX(rct);
        midx2 = CGRectGetMidX(rct);
        maxx2 = CGRectGetMaxX(rct);
        miny2 = CGRectGetMinY(rct) ;
        midy2 = CGRectGetMidY(rct) ;
        maxy2 = CGRectGetMaxY(rct);
    };

    //绘制分割线
    void(^drawSplitLine)() = ^{
        if (splitWidth == 0 || position == OWCellBackgroundViewPositionBottom || position == OWCellBackgroundViewPositionSingle)
            return ;
        CGContextSetStrokeColorWithColor(c, [[OWColor colorWithHexString:splitColor] CGColor]);
        CGContextSetLineWidth(c, splitWidth);
        CGContextMoveToPoint(c, minx + glowRadius, maxy-splitWidth/2);
        CGContextAddLineToPoint(c, maxx - glowRadius, maxy - splitWidth/2);
        CGContextDrawPath(c, kCGPathStroke);
    };
    
    drawRect = rect;
    drawRect.origin.x += (glowRadius + borderWidth/2);
    drawRect.size.width -= (glowRadius + borderWidth/2)*2;
    
    glowRect = rect;
    
    if (position == OWCellBackgroundViewPositionTop) {
        DrawPath = ^(CGRect rct) {
            calculateCoordinate(rct);
            CGContextMoveToPoint(c, minx2, maxy2);
            CGContextAddArcToPoint(c, minx2, miny2, midx2, miny2, cornerRadius);
            CGContextAddArcToPoint(c, maxx2, miny2, maxx2, maxy2, cornerRadius);
            CGContextAddLineToPoint(c, maxx2, maxy2);
        };
        drawRect.origin.y += (glowRadius + borderWidth/2);
        drawRect.size.height -= (glowRadius + borderWidth/2);
        
        glowRect.size.height += glowRadius*2;
    }
    else if (position == OWCellBackgroundViewPositionBottom) {
        DrawPath = ^(CGRect rct) {
            calculateCoordinate(rct);
            CGContextMoveToPoint(c, maxx2, miny2);
            CGContextAddLineToPoint(c, maxx2, midy2);
            CGContextAddArcToPoint(c, maxx2, maxy2, midx2, maxy2, cornerRadius);
            CGContextAddArcToPoint(c, minx2, maxy2, minx2, midy2, cornerRadius);
            CGContextAddLineToPoint(c, minx2, miny2);
        };
        drawRect.size.height -= (glowRadius + borderWidth/2);
        glowRect.origin.y -= glowRadius * 2;
        glowRect.size.height += glowRadius*2;

    }
    else if (position == OWCellBackgroundViewPositionMiddle) {
        DrawPath = ^(CGRect rct) {
            calculateCoordinate(rct);
            CGContextMoveToPoint(c, minx2, miny2);
            CGContextAddLineToPoint(c, maxx2, miny2);
            CGContextAddLineToPoint(c, maxx2, maxy2);
            CGContextAddLineToPoint(c, minx2, maxy2);
            CGContextClosePath(c);
        };
        drawRect.origin.y -= borderWidth;
        drawRect.size.height += borderWidth;
    }
    else { // if (position == OWCellBackgroundViewPositionSingle)
        DrawPath = ^(CGRect rct) {
            calculateCoordinate(rct);
            CGContextMoveToPoint(c, minx2 , midy2 );
            CGContextAddArcToPoint(c, minx2 , miny2 , midx2 , miny2, cornerRadius);
            CGContextAddArcToPoint(c, maxx2 , miny2 , maxx2 , midy2 , cornerRadius);
            CGContextAddArcToPoint(c, maxx2 , maxy2 , midx2 , maxy2 , cornerRadius);
            CGContextAddArcToPoint(c, minx2 , maxy2, minx2 , midy2 , cornerRadius);
            CGContextClosePath(c);
        };
        drawRect.origin.y += (glowRadius + borderWidth/2);
        drawRect.size.height -= (glowRadius + borderWidth/2)*2;
    }
    CGContextSetStrokeColorWithColor(c, [[OWColor colorWithHexString:borderColor] CGColor]);
    DrawPath(drawRect);
    CGContextDrawPath(c,isSelectedBackgroundView ? kCGPathFill : kCGPathFillStroke);
    drawSplitLine();

}

@end


