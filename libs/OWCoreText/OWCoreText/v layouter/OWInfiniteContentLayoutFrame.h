//
//  OWInfiniteContentLayoutFrame.h
//  OWCoreText
//
//  Created by  oowwww on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@class OWCoreTextLayoutLine;


@class OWCoreTextLayouter, OWImageManager;

@interface OWInfiniteContentLayoutFrame : NSObject
{
	NSArray *_textAttachments;
    
    CGPoint textPosition;
    
    OWImageManager *imageManager;
}
@property(assign)NSArray            *lines;
@property(assign)CGRect              frame;

/**
 An array that maps glyphs with string indices.
 */
- (NSArray *)stringIndices;

/**
 绘制文本
 */

- (void)drawInContext:(CGContextRef)context drawImages:(BOOL)drawImages;


/**
 
 Retrieves the index of the text line that contains the given glyph index.
 
 */
- (NSInteger)lineIndexForGlyphIndex:(NSInteger)index;


/**
 Retrieves the frame of the glyph at the given glyph index.
 */
- (CGRect)frameOfGlyphAtIndex:(NSInteger)index;


/**
 The text lines that are visible inside the given rectangle. Also incomplete lines are included.
 */
- (NSArray *)linesVisibleInRect:(CGRect)rect;


/**
 The text lines that are visible inside the given rectangle. Only fully visible lines are included.
 
 */
- (NSArray *)linesContainedInRect:(CGRect)rect;


/**
 The layout line that contains the given string index.
 
 */
- (OWCoreTextLayoutLine *)lineContainingIndex:(NSUInteger)index;

- (NSArray *)textAttachments;


/**
 The array of all OWTextAttachment instances that belong to the receiver which also match the specified predicate.
 
 @param predicate A predicate that uses properties of <OWTextAttachment> to reduce the returned array
 @returns A filtered array of text attachments.
 */
- (NSArray *)textAttachmentsWithPredicate:(NSPredicate *)predicate;



@end
