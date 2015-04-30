//
//  OWInfiniteContentLayoutFrame.m
//  OWCoreText
//
//  Created by  oowwww on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.
//

#import "OWInfiniteContentLayoutFrame.h"
#import "OWCoreTextLayouter.h"
#import "OWCoreTextLayoutLine.h"
#import "OWCoreTextGlyphRun.h"
#import "OWTextAttachment.h"
#import "OWInfiniteCoreTextLayouter.h"

@implementation OWInfiniteContentLayoutFrame
@synthesize lines, frame;

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (NSArray *)linesVisibleInRect:(CGRect)rect
{
	NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:[self.lines count]];
	
	BOOL earlyBreakPossible = NO;
	
	for (OWCoreTextLayoutLine *oneLine in self.lines) {
        CGRect lineFrame = oneLine.frame;
        // CGRectIntersectsRect returns false if the frame has 0 width, which
        // lines that consist only of line-breaks have. Set the min-width
        // to one to work-around.
        lineFrame.size.width = lineFrame.size.width>1?lineFrame.size.width:1;
		if (CGRectIntersectsRect(rect, lineFrame)) {
			[tmpArray addObject:oneLine];
			earlyBreakPossible = YES;
		}
		else {
			if (earlyBreakPossible) {
				break;
			}
		}
	}
	return tmpArray;
}

- (NSArray *)linesContainedInRect:(CGRect)rect
{
	NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:[self.lines count]];
	
	BOOL earlyBreakPossible = NO;
	
	for (OWCoreTextLayoutLine *oneLine in self.lines)
	{
		if (CGRectContainsRect(rect, oneLine.frame))
		{
			[tmpArray addObject:oneLine];
			earlyBreakPossible = YES;
		}
		else
		{
			if (earlyBreakPossible)
			{
				break;
			}
		}
	}
	
	return tmpArray;
}

#pragma mark Drawing

- (void)_setShadowInContext:(CGContextRef)context fromDictionary:(NSDictionary *)dictionary
{
	UIColor *color = [dictionary objectForKey:@"Color"];
	CGSize offset = [[dictionary objectForKey:@"Offset"] CGSizeValue];
	CGFloat blur = [[dictionary objectForKey:@"Blur"] floatValue];
	
	CGFloat scaleFactor = 1.0;
	if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]){
		scaleFactor = [[UIScreen mainScreen] scale];
	}
	
	// workaround for scale 1: strangely offset (1,1) with blur 0 does not draw any shadow, (1.01,1.01) does
	if (scaleFactor==1.0)
	{
		if (fabs(offset.width)==1.0)
		{
			offset.width *= 1.50;
		}
		
		if (fabs(offset.height)==1.0)
		{
			offset.height *= 1.50;
		}
	}
	
	CGContextSetShadowWithColor(context, offset, blur, color.CGColor);
}

- (void)drawInContext:(CGContextRef)context drawImages:(BOOL)drawImages
{
    if (!context) {
		return;
	}
    
	CGContextSaveGState(context);
	
	// Flip the coordinate system
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	CGContextScaleCTM(context, 1.0, -1.0);
	CGContextTranslateCTM(context, 0, -self.frame.size.height);
	
    NSMutableArray *tmpAttachments = [NSMutableArray array];
    
	// instead of using the convenience method to draw the entire frame, we draw individual glyph runs
	for (OWCoreTextLayoutLine *oneLine in self.lines) {
		for (OWCoreTextGlyphRun *oneRun in oneLine.glyphRuns) {
			
            OWTextAttachment *attachment = oneRun.attachment;
            
            if (attachment) {
                
                if(attachment.contentType == OWTextAttachmentTypeAnnotation){
                    attachment.positionCenter = CGPointMake( CGRectGetMidX(oneRun.frame),  CGRectGetMidY(oneRun.frame));
                    [tmpAttachments addObject:attachment];
                }
                else if (attachment.contentType == OWTextAttachmentTypeImage) {
                    [self drawImage:oneRun inContext:context];
                }
                continue;
            }
            [self drawText:oneRun line:oneLine inContext:context];
		}
	}
    _textAttachments = [[NSArray alloc] initWithArray:tmpAttachments];
	CGContextRestoreGState(context);
}

- (void)drawText:(OWCoreTextGlyphRun *)oneRun line:(OWCoreTextLayoutLine *)oneLine inContext:(CGContextRef)context
{
    textPosition = CGPointMake(oneLine.frame.origin.x + CGRectGetMinX(self.frame), self.frame.size.height - oneRun.frame.origin.y - oneRun.ascent);
//    NSLog(@"afdsafa:%f", textPosition.y);

    NSInteger superscriptStyle = [[oneRun.attributes objectForKey:(id)kCTSuperscriptAttributeName] integerValue];
    
    switch (superscriptStyle) {
        case 1:
            textPosition.y += oneRun.ascent * 0.47f;
            break;
            
        case -1:
            textPosition.y -= oneRun.ascent * 0.25f;
            break;
            
        default:
            break;
    }
    
    CGContextSetTextPosition(context, textPosition.x, textPosition.y);
    [oneRun drawInContext:context];
}

- (void)drawImage:(OWCoreTextGlyphRun *)oneRun inContext:(CGContextRef)context
{
    OWTextAttachment *attachment = oneRun.attachment;

    UIImage *image;
    image = [OWHTMLToAttriString decryptImage:attachment.contents];// [UIImage imageWithContentsOfFile:attachment.contents];
    
    if (!image) {
//        image   = [imageManager getImageByURL:attachment.contents];
    }
    
    CGPoint origin = CGPointMake(0, self.frame.size.height - oneRun.frame.origin.y - oneRun.ascent);
    origin.x = (self.frame.size.width - attachment.displaySize.width)/2.0f + CGRectGetMinX(self.frame);
 
//    NSLog(@"afdsa:%f, %f, %f, %f",origin.y, oneRun.frame.origin.y, oneRun.ascent, self.frame.size.height);
    CGRect flippedRect = CGRectMake(origin.x, origin.y, attachment.displaySize.width, attachment.displaySize.height);
    
    CGContextDrawImage(context, flippedRect, image.CGImage);
}

#pragma mark Text Attachments

- (NSArray *)textAttachments
{
	if (_textAttachments)
        return nil;
    
    NSMutableArray *tmpAttachments = [NSMutableArray array];
    
    for (OWCoreTextLayoutLine *oneLine in self.lines)
    {
        for (OWCoreTextGlyphRun *oneRun in oneLine.glyphRuns)
        {
            OWTextAttachment *attachment = [oneRun attachment];
            
            if (attachment) {
                attachment.positionCenter = CGPointMake( CGRectGetMidX(oneRun.frame),  CGRectGetMidY(oneRun.frame)-3);
                [tmpAttachments addObject:attachment];
            }
        }
    }
    _textAttachments = [[NSArray alloc] initWithArray:tmpAttachments];
	
	return _textAttachments;
}

- (NSArray *)textAttachmentsWithPredicate:(NSPredicate *)predicate
{
	return [[self textAttachments] filteredArrayUsingPredicate:predicate];
}



- (NSArray *)stringIndices
{
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self.lines count]];
	
	for (OWCoreTextLayoutLine *oneLine in self.lines)
	{
		[array addObjectsFromArray:[oneLine stringIndices]];
	}
	
	return array;
}

- (NSInteger)lineIndexForGlyphIndex:(NSInteger)index
{
	NSInteger retIndex = 0;
	for (OWCoreTextLayoutLine *oneLine in self.lines)
	{
		NSInteger count = [oneLine numberOfGlyphs];
		if (index >= count)
		{
			index -= count;
		}
		else
		{
			return retIndex;
		}
		
		retIndex++;
	}
	
	return retIndex;
}

- (CGRect)frameOfGlyphAtIndex:(NSInteger)index
{
	for (OWCoreTextLayoutLine *oneLine in self.lines)
	{
		NSInteger count = [oneLine numberOfGlyphs];
		if (index >= count)
		{
			index -= count;
		}
		else
		{
			return [oneLine frameOfGlyphAtIndex:index];
		}
	}
	
	return CGRectNull;
}


- (OWCoreTextLayoutLine *)lineContainingIndex:(NSUInteger)index
{
	for (OWCoreTextLayoutLine *oneLine in self.lines)
	{
		if (NSLocationInRange(index, [oneLine stringRange]))
		{
			return oneLine;
		}
	}
	
	return nil;
}
@end
