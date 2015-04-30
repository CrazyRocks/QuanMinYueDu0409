//
//  OWInfiniteCoreTextLayouter.m
//  OWCoreText
//
//  Created by  iMac001 on 12-10-22.
//
//

#import "OWInfiniteCoreTextLayouter.h"
#import "OWCoreTextLayouter.h"
#import "GLCTPageInfo.h"
#import <OWCoreText/OWCoreText.h>
#import "OWCoreTextLayoutLine.h"
#import "OWHTMLToAttriString.h"


@interface OWInfiniteCoreTextLayouter(){
    
    NSArray   *endSymbols ;
    NSArray   *startSymbols;
    
    NSArray   *images;
    //内容的起始偏移量
    float     contentOffsetY;
    
}
@end


@implementation OWInfiniteCoreTextLayouter

@synthesize textString, imageURLs, framesetter;
@synthesize infiniteHeight, lineOffset, lines;

-(void)initCSS
{
}

-(id)init
{
    self = [super init];
    if (self) {
        _defaultImageSize = CGSizeZero;
        lineOffset = CGPointZero;
    }
    return self;
}

- (void)generatePageInfo:(CGRect)rect
{
    lines = [self generateLines:self.attributedString
                       maxLines:self.maxLines
                  startPosition:CGPointMake(0, contentOffsetY)
                          width:CGRectGetWidth(rect)
                      getHeight:&infiniteHeight];
}

- (NSArray *)paragraphRanges:(NSString *)string
{
    NSArray *paragraphs = [string componentsSeparatedByString:@"\n"];
    NSRange range = NSMakeRange(0, 0);
    NSMutableArray *tmpArray = [NSMutableArray array];
    
    for (NSString *oneString in paragraphs) {
        range.length = [oneString length]+1;
        
        NSValue *value = [NSValue valueWithRange:range];
        [tmpArray addObject:value];
        
        range.location += range.length;
    }
    
    // prevent counting a paragraph after a final newline
    if ([string hasSuffix:@"\n"]) {
        [tmpArray removeLastObject];
    }
    
	return tmpArray;
}

- (GLCTPageInfo *)getPageInfo:(NSInteger)pn
{
    return  [pages objectForKey:[NSNumber numberWithInteger:pn]];
}

-(NSInteger)getPageNumberByPosition:(NSInteger)pos
{
    for (id key in pages) {
        GLCTPageInfo *info = [pages objectForKey:key];
        
        if(pos >= info.location && pos <= (info.location + info.lenght)){
            return [key intValue];
        }
        
    }
    return  startPageNum;
}

- (NSInteger)getPageCount
{
    return pages.count;
}

-(BOOL)detectRelease:(NSInteger)pageNumber
{
    NSInteger lower = pageNumber - 2;
    NSInteger upper = pageNumber + 2;
    if (endPageNum < lower ||startPageNum > upper) {
        return YES;
    }
    return NO;
}

- (NSArray *)linesVisibleInRect:(CGRect)rect
{
	NSMutableArray *tmpArray = [[NSMutableArray alloc]init];
	
	CGFloat minY = CGRectGetMinY(rect);
	CGFloat maxY = CGRectGetMaxY(rect);
	
	for (OWCoreTextLayoutLine *oneLine in lines) {
		CGRect lineFrame = oneLine.frame;
		
		if (CGRectGetMaxY(lineFrame)<minY)
			continue;
		
		if (lineFrame.origin.y > maxY)
			break;
        
		lineFrame.size.width = lineFrame.size.width>1?lineFrame.size.width:1;
//		NSLog(@"lineFrame:%f, %f, %f, %f",lineFrame.origin.x, lineFrame.origin.y, lineFrame.size.width, lineFrame.size.height);
		if (CGRectIntersectsRect(rect, lineFrame))
			[tmpArray addObject:oneLine];
	}
	return tmpArray;
}

-(NSArray *)getAllLines
{
    return lines;
}

- (NSMutableArray *)generateLines:(NSAttributedString *)attriString
                         maxLines:(NSInteger)max
                    startPosition:(CGPoint)position
                            width:(float)w
                        getHeight:(float *)height
{
    if (!attriString) return nil;
    NSMutableArray *pageLines = [[NSMutableArray alloc]init];
    textString = [attriString string];
    if (!textString || textString.length == 0)
    return Nil;
    
    NSInteger currentLineIndex = 1;
    CGRect newRect = CGRectZero;
    newRect.size = CGSizeMake(w, position.y);
    
    CFAttributedStringRef cfString = (__bridge CFAttributedStringRef)attriString;
    framesetter = CTFramesetterCreateWithAttributedString(cfString);
    
	CTTypesetterRef typesetter = CTFramesetterGetTypesetter(framesetter);
    
	CGPoint lineOrigin = newRect.origin;
    lineOrigin.y += position.y;
	OWCoreTextLayoutLine *previousLine = nil;
	NSMutableArray *paragraphRanges = [[self paragraphRanges:textString] mutableCopy];
	NSRange currentParagraphRange = [paragraphRanges[0] rangeValue];
	
	NSRange lineRange = NSMakeRange(0, textString.length);
	NSUInteger maxIndex = textString.length;
	NSUInteger fittingLength = 0;
    
	typedef struct {
		CGFloat ascent;
		CGFloat descent;
		CGFloat width;
		CGFloat leading;
		CGFloat trailingWhitespaceWidth;
		CGFloat paragraphSpacing;
        CGFloat paragraphSpacingBefore;
	} lineMetrics;
	
	lineMetrics currentLineMetrics;
	lineMetrics previousLineMetrics;
    CTParagraphStyleRef paragraphStyle;
    paragraphStyle = (__bridge CTParagraphStyleRef)[attriString attribute:(id)kCTParagraphStyleAttributeName atIndex:lineRange.location effectiveRange:&lineRange];
   
   	do {
		while (lineRange.location >= (currentParagraphRange.location+currentParagraphRange.length)) {
			[paragraphRanges removeObjectAtIndex:0];
			currentParagraphRange = [[paragraphRanges objectAtIndex:0] rangeValue];
            
            paragraphStyle = (__bridge CTParagraphStyleRef)[attriString attribute:(id)kCTParagraphStyleAttributeName atIndex:lineRange.location effectiveRange:&lineRange];

		}
		BOOL isAtBeginOfParagraph = (currentParagraphRange.location == lineRange.location);
		CGFloat offset = 0;
		
		if (isAtBeginOfParagraph)
            CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierFirstLineHeadIndent, sizeof(offset), &offset);
		else
			CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierHeadIndent, sizeof(offset), &offset);
		
		lineOrigin.x = offset + newRect.origin.x;
		
		lineRange.length = CTTypesetterSuggestLineBreak(typesetter, lineRange.location, newRect.size.width - offset);
		if (NSMaxRange(lineRange) > maxIndex)
			lineRange.length = maxIndex - lineRange.location;

		currentLineMetrics.paragraphSpacing = 0;
		if (NSMaxRange(lineRange) == NSMaxRange(currentParagraphRange)){
			// at end of paragraph, record the spacing
			CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierParagraphSpacing, sizeof(currentLineMetrics.paragraphSpacing), &currentLineMetrics.paragraphSpacing);
		}
        
		// create a line to fit
		CTLineRef line = CTTypesetterCreateLine(typesetter, CFRangeMake(lineRange.location, lineRange.length));
		
		// we need all metrics so get the at once
		currentLineMetrics.width = CTLineGetTypographicBounds(line, &currentLineMetrics.ascent, &currentLineMetrics.descent, &currentLineMetrics.leading);
        
        //对比行的实际宽度与页面宽度，追加必要的字符使文本布局更完美
        BOOL isAtEndOfParagraph = (currentParagraphRange.location + currentParagraphRange.length == lineRange.location +lineRange.length);
        
		// get line height in px if it is specified for this line
		CGFloat lineHeight = 0;
		CGFloat maxLineHeight = 0;
		
		
		if (CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierMaximumLineHeight, sizeof(maxLineHeight), &maxLineHeight)) {
			if (maxLineHeight>0 && lineHeight>maxLineHeight) 
				lineHeight = maxLineHeight;
		}
       		// get the correct baseline origin
		if (previousLine) {
			if (lineHeight==0)
                lineHeight = previousLineMetrics.descent + currentLineMetrics.ascent;
            
			if (isAtBeginOfParagraph) {
                //段间距
                currentLineMetrics.paragraphSpacingBefore = 0;
                 CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(currentLineMetrics.paragraphSpacingBefore), &currentLineMetrics.paragraphSpacingBefore);
				lineHeight += (previousLineMetrics.paragraphSpacing + currentLineMetrics.paragraphSpacingBefore);

            }			
		}
		else {
			if (lineHeight>0) {
				if (lineHeight<currentLineMetrics.ascent)
                    // special case, we fake it to look like CoreText
					lineHeight -= currentLineMetrics.descent;
                
			}
			else
                lineHeight = currentLineMetrics.ascent;

		}
        /*
         加上行间距
         这里要用 kCTParagraphStyleSpecifierLineSpacingAdjustment 
         用 kCTParagraphStyleSpecifierLineSpacing 获取不到值
         */
        CGFloat lineSpace = 0.0f;
        CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(lineSpace), &lineSpace);

        if (lineSpace < 0.1f)
            CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierLineSpacing, sizeof(lineSpace), &lineSpace);
                
		lineOrigin.y += lineHeight + lineSpace;

		// adjust lineOrigin based on paragraph text alignment
		CTTextAlignment textAlignment;
        	CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierAlignment, sizeof(textAlignment), &textAlignment);
		
		switch (textAlignment) {
			case kCTLeftTextAlignment:
                lineOrigin.x = newRect.origin.x + offset;
				break;
				
			case kCTNaturalTextAlignment:
			{
				// depends on the text direction
				CTWritingDirection baseWritingDirection;
				CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierBaseWritingDirection, sizeof(baseWritingDirection), &baseWritingDirection);
				
				if (baseWritingDirection != kCTWritingDirectionRightToLeft)
				{
					break;
				}
				
			}
				
			case kCTRightTextAlignment:
                lineOrigin.x = newRect.origin.x + offset + CTLineGetPenOffsetForFlush(line, 1.0, newRect.size.width - offset);
				break;
				
			case kCTCenterTextAlignment:
                lineOrigin.x = newRect.origin.x + offset + CTLineGetPenOffsetForFlush(line, 0.5, newRect.size.width - offset);
				break;
                
            case kCTJustifiedTextAlignment: {
                if (!isAtEndOfParagraph) {
                    // 不是段落最后一行的话设置两端对齐
                    NSUInteger lastCharLocation = lineRange.location +lineRange.length -1  ;
                    NSString *lineText = [textString substringWithRange:NSMakeRange(lastCharLocation, 1)];
                    float lineWidth = newRect.size.width-offset;
                    if ([self isEndSymbol:lineText]) {
                        lineWidth += lineWidth/(lineRange.length - 1)/2;
                    }
                    CTLineRef justifiedLine = CTLineCreateJustifiedLine(line, 1.0f, lineWidth);
                    if (justifiedLine) {
                        CFRelease(line);
                        line = justifiedLine;
                    }
                    
				}
				lineOrigin.x = newRect.origin.x + offset;
				
				break;
			}
		}
                
        OWCoreTextLayoutLine *newLine = [[OWCoreTextLayoutLine alloc] initWithLine:line layouter:self];
        CFRelease(line);
        newLine.baselineOrigin = lineOrigin;
        newLine.isLastLine = isAtEndOfParagraph;
        
        fittingLength += lineRange.length;
        
        [pageLines addObject:newLine];
        
        if(max > 0 && currentLineIndex == max){
            break;
        }
        lineRange.location += lineRange.length;
        currentLineIndex ++;

        previousLine = newLine;
        previousLineMetrics = currentLineMetrics;
        
    }while (lineRange.location < maxIndex);

//    CFRelease(framesetter);
    
    if (height) {
        CGFloat lineBottom = lineOrigin.y + currentLineMetrics.descent+ previousLineMetrics.paragraphSpacing;
        *height = lineBottom;
    }
    
    return  pageLines;
}

-(void)dealloc
{
    if(framesetter)
        CFRelease(framesetter);
    [pages removeAllObjects];
    pages = nil;
}

@end
