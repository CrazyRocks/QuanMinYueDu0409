//
//  OWActivityIndicatorView.m
//  ActivityIndicatorDemo
//
//  Created by grenlight on 13-12-9.
//
//

#import "OWActivityIndicatorView.h"

@implementation OWActivityIndicatorView

@synthesize frameInterval, steps, isAnimating;

- (id)initWithFrame:(CGRect)frame
{
    if (self= [super initWithFrame:frame]) {
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
    self.steps = 16;
    self.frameInterval = 2;
    self.color = [UIColor whiteColor];
    self.finSize = CGSizeMake(4, 4);
    self.alpha = 0;
    anglePerStep = (360/self.steps) * M_PI / 180;
    currStep = 0;
    
    isAnimating = NO;
}

- (void)startAnimating
{
	if (!isAnimating) {
        anglePerStep = (360/self.steps) * M_PI / 180;
        finRect = CGRectMake(self.bounds.size.width/2 - _finSize.width/2, 0,
                             _finSize.width, _finSize.height);

        displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(enterFrame)];
        [displayLink setFrameInterval:self.frameInterval];
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
		isAnimating = TRUE;
        [self setHidden:NO];
	}
    [self fadeEffect:1];
}

- (void)fadeEffect:(float)alpha
{
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = alpha;
    }];
}

- (void)stopAnimating
{
    [self fadeEffect:0];

	if (isAnimating) {
        [displayLink invalidate];
        displayLink = nil;
        isAnimating = FALSE;
	}
}

- (void)enterFrame
{
    currStep++;

    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    for (NSInteger i = 0; i < self.steps; i++) {
        [[self colorForStep:currStep-i] set];
        UIBezierPath *bezierPath = [self finPathWithStep:currStep-i];
        CGContextBeginPath(context);
        CGContextAddPath(context, bezierPath.CGPath);
        CGContextClosePath(context);
        CGContextFillPath(context);
        
        CGContextTranslateCTM(context, self.bounds.size.width / 2, self.bounds.size.height / 2);
        CGContextRotateCTM(context, anglePerStep);
        CGContextTranslateCTM(context, -(self.bounds.size.width / 2), -(self.bounds.size.height / 2));
    }
    
}

- (UIColor*)colorForStep:(NSUInteger)stepIndex
{
    CGFloat alpha =1-(stepIndex % (self.steps+1)) * (1.0 / (self.steps-1));
    CGColorRef copiedColor = CGColorCreateCopyWithAlpha(self.color.CGColor, alpha);
    UIColor *color = [UIColor colorWithCGColor:copiedColor];
    CGColorRelease(copiedColor);
    return color;
}

- (UIBezierPath *)finPathWithStep:(uint)stepIndex
{
    float factor = (float)(stepIndex % (self.steps+1))/8 * 2.0f;
    if (factor > 2.5)
        factor = 2.5;
    
    CGRect rect = CGRectOffset(finRect, factor/2.0f, factor/2.0f);
    rect.size.width -= factor;
    rect.size.height -= factor;
    
    return [UIBezierPath bezierPathWithRoundedRect:rect
                                 cornerRadius:self.finSize.width/2.0];
}


@end
