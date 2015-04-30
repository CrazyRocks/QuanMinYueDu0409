//
//  Created by  oowwww on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.


#import <CoreText/CoreText.h>

@class OWCoreTextLayoutLine;
@class OWTextAttachment;

@interface OWCoreTextGlyphRun : NSObject 
{
	NSRange _stringRange;
}

- (id)initWithRun:(CTRunRef)run layoutLine:(OWCoreTextLayoutLine *)layoutLine offset:(CGFloat)offset;

- (CGRect)frameOfGlyphAtIndex:(NSInteger)index;
- (CGRect)imageBoundsInContext:(CGContextRef)context;
- (NSRange)stringRange;
- (NSArray *)stringIndices;

- (void)drawInContext:(CGContextRef)context;

- (void)fixMetricsFromAttachment;

@property (nonatomic, assign, readonly) CGRect frame;
@property (nonatomic, assign, readonly) NSInteger numberOfGlyphs;
@property (nonatomic, unsafe_unretained, readonly) NSDictionary *attributes;	// subtle simulator bug - use assign not __unsafe_unretained in 4.2

@property (nonatomic, assign, readonly) CGFloat ascent;
@property (nonatomic, assign, readonly) CGFloat descent;
@property (nonatomic, assign, readonly) CGFloat leading;
@property (nonatomic, assign, readonly) CGFloat width;

@property (nonatomic, strong) OWTextAttachment *attachment;

@end
