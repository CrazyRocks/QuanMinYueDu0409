//
//  OWAnnotationTextView.m
//  KWFBooks
//
//  Created by gren light on 12-9-1.
//
//

#import "OWAnnotationTextView.h"
#import "OWCoreTextLayoutLine.h"
#import "OWCoreTextLayouter.h"
#import "OWHTMLToAttriString.h"

@implementation OWAnnotationTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setUserInteractionEnabled:NO];
    }
    return self;
}

-(float)drawText:(NSString *)text byLayouter:(OWCoreTextLayouter *)layouter
{
    float currentHeight=0;
    float frameWidth = CGRectGetWidth(self.frame);
    NSArray *lines;
    currentHeight = [layouter.htmlTranslater
                     convertHTML:[NSString stringWithFormat:@"<p class='annotation'>%@<p>", text]
                     width:frameWidth toLine:&lines];
    textLines = lines;
    
    CGRect newFrame = self.frame;
    newFrame.size.height = currentHeight;
    [self setFrame:newFrame];
    [self setNeedsDisplay];
    return currentHeight;
}

-(void)drawRect:(CGRect)rect
{
    CGContextRef  context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    CGContextFillRect(context, self.bounds);
        
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	CGContextScaleCTM(context, 1.0, -1.0);
	CGContextTranslateCTM(context, 0, -CGRectGetHeight(self.bounds));
    
    for (OWCoreTextLayoutLine *oneLine in textLines) {
        CGPoint textPosition = CGPointMake(oneLine.frame.origin.x , self.frame.size.height - oneLine.frame.origin.y - oneLine.ascent);
        CGContextSetTextPosition(context, textPosition.x, textPosition.y);
        [oneLine drawInContext:context];
	}
}
@end
