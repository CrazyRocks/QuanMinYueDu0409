
//  Created by OW on 11-5-4.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.

#import <CoreText/CoreText.h>

@class OWCoreTextLayoutLine, OWSinglePageView;


@class OWCoreTextLayouter, GLCTPageInfo;
/**

 */
@interface OWCoreTextLayoutFrame : NSObject 
{
    CGRect _frame;
    NSArray *_textAttachments;
    CGPoint textPosition;
}
@property(assign)CGRect              frame;
@property(assign)float               paddingLeft;

@property (nonatomic, weak)     OWSinglePageView    *pageView;
@property (nonatomic, assign) 	UIEdgeInsets    edgeInsets;

- (id)initWithFrame:(CGRect)frame andPageInfo:(GLCTPageInfo *)info;

- (NSArray *)stringIndices;

- (void)drawInContext:(CGContextRef)context drawImages:(BOOL)drawImages;

- (NSInteger)lineIndexForGlyphIndex:(NSInteger)index;

- (CGRect)frameOfGlyphAtIndex:(NSInteger)index;

- (NSArray *)linesVisibleInRect:(CGRect)rect; 

- (NSArray *)linesContainedInRect:(CGRect)rect;


- (OWCoreTextLayoutLine *)lineContainingIndex:(NSUInteger)index;

- (NSArray *)textAttachments;


/**
 The array of all OWTextAttachment instances that belong to the receiver which also match the specified predicate.
 
 @param predicate A predicate that uses properties of <OWTextAttachment> to reduce the returned array
 @returns A filtered array of text attachments.
 */
- (NSArray *)textAttachmentsWithPredicate:(NSPredicate *)predicate;



@end
