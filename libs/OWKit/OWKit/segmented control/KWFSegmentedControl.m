//
//  KWFSegmentedControl.m
//  KWFBooks
//
//  Created by  iMac001 on 12-11-9.
//
//

#import "KWFSegmentedControl.h"
#import "UIStyleObject.h"
#import "OWColor.h"

@interface KWFSegmentedControl (){
    float conerRadius;
}
@property (nonatomic, retain) NSMutableArray *items;
- (BOOL)_mustCustomize;
@end

@implementation KWFSegmentedControl
@synthesize items;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    
    [self setup];
    
	NSMutableArray *ar = [NSMutableArray arrayWithCapacity:self.numberOfSegments];
    
	for (NSInteger i = 0; i < self.numberOfSegments; i++) {
		NSString *aTitle = [self titleForSegmentAtIndex:i];
		if (aTitle) {
			[ar addObject:aTitle];
		}
	}
	self.items = ar;
	[self setNeedsDisplay];
    
}

- (void)setup
{
    [self setNormalColor:@"#ffffff,#ffffff"
           selectedColor:@"#E70300,#E70300"
             borderColor:@"#B20000"
         textNormalColor:@"#EA0000"
       textSelectedColor:@"#ffffff"
                fontSize:14 frameSizeHeight:30 corner:0];

}

- (id)initWithItems:(NSArray *)array
{
	self = [super initWithItems:array];
	if (self) {
		if (array) {
			NSMutableArray *mutableArray = [array mutableCopy];
			self.items = mutableArray;
		}
        else {
			self.items = [NSMutableArray array];
		}
	}
	return self;
}

- (void)dealloc
{
	self.items               = nil;
	self.font                = nil;
}

- (void)setNormalColor:(NSString *)normalColor
         selectedColor:(NSString *)selectedColor
           borderColor:(NSString *)_borderColor
       textNormalColor:(NSString *)tnColor
     textSelectedColor:(NSString *)tsColor
              fontSize:(float)fontSize
       frameSizeHeight:(float)height
                corner:(float)coner
{
    conerRadius = coner;
    selectedItemColor = [OWColor gradientColorWithHexString:selectedColor];
    unselectedItemColor = [OWColor gradientColorWithHexString:normalColor];
    borderColor = [OWColor colorWithHexString:_borderColor];
    normalTextColor = [OWColor colorWithHexString:tnColor];
    selectedTextColor = [OWColor colorWithHexString:tsColor];
    
    [self setFont:[UIFont systemFontOfSize:fontSize]];
    
    CGRect frame = self.frame;
    frame.size.height = height;
    [self setFrame:frame];

    [self setNeedsDisplay];
}

- (void)setStyle:(UIStyleObject *)style
{
    conerRadius = style.cornerRadius;
    selectedItemColor = style.gradientBackground_selected;
    unselectedItemColor = style.gradientBackground;
    borderColor = style.borderColor;
    normalTextColor = style.fontColor;
    selectedTextColor = style.fontColor_selected;
    
    [self setFont:[UIFont systemFontOfSize:style.fontSize]];
    [self setNeedsDisplay];

}

- (BOOL)_mustCustomize
{
//	return self.segmentedControlStyle == UISegmentedControlStyleBordered
//    || self.segmentedControlStyle == UISegmentedControlStylePlain;
    return YES;
}

#pragma mark - Custom accessors

- (UIFont *)font
{
	if (_font == nil) {
		self.font = [UIFont boldSystemFontOfSize:14.0f];
	}
	return _font;
}

- (void)setFont:(UIFont *)aFont
{
	if (_font != aFont) {
		_font = aFont;
		
		[self setNeedsDisplay];
	}
}

#pragma mark - Overridden UISegmentedControl methods

- (void)layoutSubviews
{
	for (UIView *subView in self.subviews) {
		[subView removeFromSuperview];
	}
}

- (NSUInteger)numberOfSegments
{
	if (!self.items || ![self _mustCustomize]) {
		return [super numberOfSegments];
	}
    else {
		return self.items.count;
	}
}

- (void)drawRect:(CGRect)rect
{
    if (![self _mustCustomize]) {
		return;
	}
 
	// TODO: support for segment custom width
	CGSize itemSize = CGSizeMake(round(rect.size.width / self.numberOfSegments), rect.size.height);
    
	CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(c, 1);

    __block CGFloat minx, midx, maxx, miny, midy, maxy;
    __block CGRect rrect;
	
    void(^DrawRect)(CGRect) = ^(CGRect rrect){
        minx = CGRectGetMinX(rrect);
        midx = CGRectGetMidX(rrect);
        maxx = CGRectGetMaxX(rrect);
        miny = CGRectGetMinY(rrect) ;
        midy = CGRectGetMidY(rrect) ;
        maxy = CGRectGetMaxY(rrect);
        CGContextMoveToPoint(c, minx , midy );
        CGContextAddArcToPoint(c, minx , miny , midx , miny, conerRadius);
        CGContextAddArcToPoint(c, maxx , miny , maxx , midy , conerRadius);
        CGContextAddArcToPoint(c, maxx , maxy , midx , maxy , conerRadius);
        CGContextAddArcToPoint(c, minx , maxy, minx , midy , conerRadius);
        CGContextClosePath(c);
    };
    
    CGContextSaveGState(c);

    rrect = CGRectMake(0.25, 0.25, CGRectGetWidth(rect)-0.5f, CGRectGetHeight(rect)-1.5f);
    DrawRect(rrect);
	CGContextClip(c);
	
	
    //渐变填充
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    NSArray *arr = unselectedItemColor;
    CGFloat components[8] = {
        [arr[0] floatValue], [arr[1] floatValue], [arr[2] floatValue], [arr[3] floatValue],
        [arr[4] floatValue], [arr[5] floatValue],[arr[6] floatValue], [arr[7] floatValue]
    };
    		
	CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, 2);
	CGContextDrawLinearGradient(c, gradient, CGPointZero, CGPointMake(0, rect.size.height), kCGGradientDrawsBeforeStartLocation);
	CFRelease(gradient);
	
    arr = selectedItemColor;
    CGFloat selectedColors[8] = {
        [arr[0] floatValue], [arr[1] floatValue], [arr[2] floatValue], [arr[3] floatValue],
        [arr[4] floatValue], [arr[5] floatValue],[arr[6] floatValue], [arr[7] floatValue]
    };
   
	for (NSInteger i = 0; i < self.numberOfSegments; i++) {
		id item = self.items[i];
		
		CGRect itemBgRect = CGRectMake(i * itemSize.width,
									   0.0f,
									   itemSize.width,
									   rect.size.height);
		
        //被选中的项
		if (i == self.selectedSegmentIndex) {
            CGContextSaveGState(c);
            CGContextClipToRect(c, itemBgRect);
             gradient = CGGradientCreateWithColorComponents(colorSpace, selectedColors, NULL, 2);
            CGContextDrawLinearGradient(c, gradient, CGPointZero, CGPointMake(0, itemBgRect.size.height), kCGGradientDrawsBeforeStartLocation);
            CFRelease(gradient);
            CGContextRestoreGState(c);
		}
		
		if ([item isKindOfClass:[NSString class]]) {
			
			NSString *string = (NSString *)items[i];
			CGSize stringSize = [string sizeWithFont:self.font];
			CGRect stringRect = CGRectMake(i * itemSize.width + (itemSize.width - stringSize.width) / 2,
										   (itemSize.height - stringSize.height) / 2,
										   stringSize.width,
										   stringSize.height);
			
			if (self.selectedSegmentIndex == i) {
				[selectedTextColor setFill];
				[string drawInRect:stringRect withFont:self.font];
			}
            else {
				[normalTextColor setFill];
				[string drawInRect:stringRect withFont:self.font];
			}
		}
		if (i>0) {
          	//分割线
            CGContextSaveGState(c);
            float splitX =round(itemBgRect.origin.x);
            if( splitX > itemBgRect.origin.x)
                splitX -= 0.25;
            else
                splitX += 0.25;

            CGContextMoveToPoint(c, splitX, itemBgRect.origin.y);
            CGContextAddLineToPoint(c, splitX, itemBgRect.size.height);
            CGContextSetStrokeColorWithColor(c, borderColor.CGColor);
            CGContextStrokePath(c);
            
            CGContextRestoreGState(c);
        }
		
	}
    CFRelease(colorSpace);

    CGContextSetStrokeColorWithColor(c, borderColor.CGColor);
    rrect = CGRectMake(0.5, 0.5, CGRectGetWidth(rect)-2, CGRectGetHeight(rect)-2);
    DrawRect(rrect);
    CGContextDrawPath(c, kCGPathStroke);
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (![self _mustCustomize]) {
		[super touchesBegan:touches withEvent:event];
	}
    else {
		CGPoint point = [[touches anyObject] locationInView:self];
		NSInteger itemIndex = floor(self.numberOfSegments * point.x / self.bounds.size.width);
		self.selectedSegmentIndex = itemIndex;
		
		[self setNeedsDisplay];
	}
}

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex
{
	if (selectedSegmentIndex == self.selectedSegmentIndex) return;
	
	[super setSelectedSegmentIndex:selectedSegmentIndex];
	
#ifdef __IPHONE_5_0
	if ([self respondsToSelector:@selector(apportionsSegmentWidthsByContent)]
		&& [self _mustCustomize])
	{
		[self sendActionsForControlEvents:UIControlEventValueChanged];
	}
#endif
    [self setNeedsDisplay];
}

- (void)setSegmentedControlStyle:(UISegmentedControlStyle)aStyle
{
	[super setSegmentedControlStyle:aStyle];
	if ([self _mustCustomize]) {
		[self setNeedsDisplay];
	}
}

- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)segment
{
	if (![self _mustCustomize]) {
		[super setTitle:title forSegmentAtIndex:segment];
	} else {
		[self.items replaceObjectAtIndex:segment withObject:title];
		[self setNeedsDisplay];
	}
}

- (void)setImage:(UIImage *)image forSegmentAtIndex:(NSUInteger)segment
{
	if (![self _mustCustomize]) {
		[super setImage:image forSegmentAtIndex:segment];
	} else {
		[self.items replaceObjectAtIndex:segment withObject:image];
		[self setNeedsDisplay];
	}
}

- (void)insertSegmentWithTitle:(NSString *)title atIndex:(NSUInteger)segment animated:(BOOL)animated
{
	if (![self _mustCustomize]) {
		[super insertSegmentWithTitle:title atIndex:segment animated:animated];
	} else {
		if (segment >= self.numberOfSegments && segment != 0) return;
		[super insertSegmentWithTitle:title atIndex:segment animated:animated];
		[self.items insertObject:title atIndex:segment];
		[self setNeedsDisplay];
	}
}

- (void)insertSegmentWithImage:(UIImage *)image atIndex:(NSUInteger)segment animated:(BOOL)animated
{
	if (![self _mustCustomize]) {
		[super insertSegmentWithImage:image atIndex:segment animated:animated];
	} else {
		if (segment >= self.numberOfSegments) return;
		[super insertSegmentWithImage:image atIndex:segment animated:animated];
		[self.items insertObject:image atIndex:segment];
		[self setNeedsDisplay];
	}
}

- (void)removeSegmentAtIndex:(NSUInteger)segment animated:(BOOL)animated
{
	if (![self _mustCustomize]) {
		[super removeSegmentAtIndex:segment animated:animated];
	} else {
		if (segment >= self.numberOfSegments) return;
		[self.items removeObjectAtIndex:segment];
		[self setNeedsDisplay];
	}
}




@end
