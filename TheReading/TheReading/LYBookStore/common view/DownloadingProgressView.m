//
//  DownloadingProgressView.m
//  KWFBooks
//
//  Created by 龙源 on 13-10-12.
//
//

#import "DownloadingProgressView.h"
#import "MyBook.h"
#import <OWKit/OWKit.h>
#import <LYService/LYGlobalConfig.h>

@implementation DownloadingProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setBookItem:(MyBook *)bookItem
{
    book = bookItem;
    
    self.progress = [book.downloadingProgress floatValue];
 
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [OWColor colorWithHexString:@"#ffffff"].CGColor);
    CGContextSetLineWidth(context, 4);
    
    CGContextAddArc(context, CGRectGetMidX(rect), CGRectGetMidY(rect), CGRectGetWidth(rect)/2.0-2.0, 0, M_PI*2, 0);
    CGContextDrawPath(context, kCGPathStroke);
    
    if (self.progress > 0) {
        CGContextSaveGState(context);
        
        CGContextSetStrokeColorWithColor(context, [OWColor colorWithHexString:@"#63b8e5"].CGColor);
        CGContextAddArc(context, CGRectGetMidX(rect), CGRectGetMidY(rect), CGRectGetWidth(rect)/2.0-2,
                        -M_PI/2, -M_PI/2 + (M_PI*2*self.progress), 0);
        CGContextDrawPath(context, kCGPathStroke);
    }
    
}

@end
