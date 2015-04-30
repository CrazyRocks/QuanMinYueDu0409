//  Created by OW on 11-5-4.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.

#import "OWCoreTextLayoutFrame.h"
#import "OWCoreTextLayouter.h"
#import "OWCoreTextLayoutLine.h"
#import "OWCoreTextGlyphRun.h"
#import "OWTextAttachment.h"
#import "GLCTPageInfo.h"
#import "OWSinglePageView.h"

@implementation OWCoreTextLayoutFrame
{
    
    NSInteger tag;
    GLCTPageInfo *pageInfo;
    
}
@synthesize paddingLeft;

- (id)initWithFrame:(CGRect)frame andPageInfo:(GLCTPageInfo *)info
{
	self = [super init];
	if (self) {
		_frame = frame;
		pageInfo = info;
	}
	return self;
}

- (NSString *)description
{
	return pageInfo.description;
}

- (NSArray *)lines
{
    return pageInfo.lines;
}

- (NSArray *)linesVisibleInRect:(CGRect)rect
{
	NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:[self.lines count]];
	
	BOOL earlyBreakPossible = NO;
	
	for (OWCoreTextLayoutLine *oneLine in self.lines)
	{
        CGRect lineFrame = oneLine.frame;
        // CGRectIntersectsRect returns false if the frame has 0 width, which
        // lines that consist only of line-breaks have. Set the min-width
        // to one to work-around.
        lineFrame.size.width = lineFrame.size.width>1?lineFrame.size.width:1;
		if (CGRectIntersectsRect(rect, lineFrame))
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

- (NSArray *)linesContainedInRect:(CGRect)rect
{
	NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:[self.lines count]];
	
	BOOL earlyBreakPossible = NO;
	
	for (OWCoreTextLayoutLine *oneLine in self.lines) {
		if (CGRectContainsRect(rect, oneLine.frame)) {
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

#pragma mark Drawing

- (void)_setShadowInContext:(CGContextRef)context fromDictionary:(NSDictionary *)dictionary
{
	UIColor *color = [dictionary objectForKey:@"Color"];
	CGSize offset = [[dictionary objectForKey:@"Offset"] CGSizeValue];
	CGFloat blur = [[dictionary objectForKey:@"Blur"] floatValue];
	
	CGFloat scaleFactor = 1.0;
	if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
	{
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
    if (!context)
        return;

	CGContextSaveGState(context);
	
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	CGContextScaleCTM(context, 1.0, -1.0);
	CGContextTranslateCTM(context, 0, -self.frame.size.height);
	
    NSMutableArray *tmpAttachments = [NSMutableArray array];

	for (OWCoreTextLayoutLine *oneLine in self.lines) {

		for (OWCoreTextGlyphRun *oneRun in oneLine.glyphRuns) {
			textPosition = CGPointMake(oneLine.frame.origin.x, self.frame.size.height - oneRun.frame.origin.y - oneRun.ascent);
            textPosition.x += paddingLeft;
            
//			NSLog(@"textPosition:%f, %f",textPosition.x,textPosition.y);
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
			
			CGContextSetTextPosition(context, textPosition.x + self.edgeInsets.left,
                                     textPosition.y-self.edgeInsets.top);
			
            OWTextAttachment *attachment = oneRun.attachment;
            
            if (attachment) {
                if(attachment.contentType == OWTextAttachmentTypeAnnotation){
                    attachment.positionCenter = CGPointMake( CGRectGetMidX(oneRun.frame),  CGRectGetMidY(oneRun.frame));
                    [tmpAttachments addObject:attachment];
                }
                else if (attachment.contentType == OWTextAttachmentTypeImage) {
                    [self drawImage:attachment inContext:context];
                }

            }
            else 
                [oneRun drawInContext:context];			
		}
	}
    _textAttachments = [[NSArray alloc] initWithArray:tmpAttachments];
	CGContextRestoreGState(context);
    
    if (self.pageView) {
        [self.pageView drawAnnotation];
    }
}

- (void)drawImage:(OWTextAttachment *)attachment inContext:(CGContextRef)context
{
    UIImage *image;
    image = [OWHTMLToAttriString decryptImage:attachment.contents];//[UIImage imageWithContentsOfFile:attachment.contents];
    
    if (!image) {
//        image   = [imageManager getImageByURL:attachment.contents];
    }
    
    CGRect flippedRect;
    if (self.lines.count == 1) {
        float targetWidth = CGRectGetWidth(self.frame);
        float targetHeight = targetWidth / attachment.displaySize.width *attachment.displaySize.height;
        flippedRect = CGRectMake(0, (CGRectGetHeight(self.frame) - targetHeight) / 2.0,
                                 targetWidth, targetHeight);
        
        [self.pageView.delegate isFullScreenContent];
    }
    else {
        CGPoint origin = textPosition;
        origin.x = (self.frame.size.width - attachment.displaySize.width)/2;
        origin.y -= self.edgeInsets.top;
        
        if (origin.x < 0)
            origin.x = 0;
        
        flippedRect = CGRectMake(origin.x, origin.y, attachment.displaySize.width, attachment.displaySize.height);
 
    }
    CGContextDrawImage(context, flippedRect, image.CGImage);
}

#pragma mark Text Attachments

- (NSArray *)textAttachments
{
	if (!_textAttachments)
        return nil;
    
    NSMutableArray *tmpAttachments = [NSMutableArray array];
    
    for (OWCoreTextLayoutLine *oneLine in self.lines)
    {
        for (OWCoreTextGlyphRun *oneRun in oneLine.glyphRuns)
        {
            OWTextAttachment *attachment = [oneRun attachment];
            
            if (attachment)
            {
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
	
	for (OWCoreTextLayoutLine *oneLine in self.lines){
		[array addObjectsFromArray:[oneLine stringIndices]];
	}
	
	return array;
}

- (NSInteger)lineIndexForGlyphIndex:(NSInteger)index
{
	NSInteger retIndex = 0;
	for (OWCoreTextLayoutLine *oneLine in self.lines) {
		NSInteger count = [oneLine numberOfGlyphs];
		if (index >= count) {
			index -= count;
		}
		else  {
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
