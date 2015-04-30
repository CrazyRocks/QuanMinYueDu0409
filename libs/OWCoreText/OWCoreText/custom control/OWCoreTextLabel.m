//
//  OWCoreTextLabel.m
//
//  Created by  oowwww on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.
//

#import "OWCoreTextLabel.h"
#import "OWCoreTextLayouter.h"
#import "OWCoreTextLayoutLine.h"

@implementation OWCoreTextLabel

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.numberOfLines = 0;
    }
    return self;
}

-(float)renderText:(NSAttributedString *)attriString
{
    float currentHeight=0;
    OWCoreTextLayouter *layouter = [[OWCoreTextLayouter alloc] init];
    textLines = [layouter generateLines:attriString
                               maxLines:self.numberOfLines
                             startPosition:CGPointMake(0, currentHeight)
                                  width:CGRectGetWidth(self.frame)
                              getHeight:&currentHeight];
    CGRect itemFrame  = self.frame;
    itemFrame.size.height = currentHeight;
    [self setFrame:itemFrame];
    [self setNeedsDisplay];
    return currentHeight;
}

- (void)renderByLineText:(NSArray *)lines
{
    textLines = lines;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    CGContextFillRect(context, self.bounds);
        
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	CGContextScaleCTM(context, 1.0, -1.0);
	CGContextTranslateCTM(context, 0, -CGRectGetHeight(self.bounds));
    
    for (OWCoreTextLayoutLine *oneLine in textLines) {
        CGPoint textPosition = CGPointMake(oneLine.frame.origin.x , self.frame.size.height - (oneLine.frame.origin.y + oneLine.ascent));
        CGContextSetTextPosition(context, textPosition.x, textPosition.y);
        [oneLine drawInContext:context];
	}
}


@end
