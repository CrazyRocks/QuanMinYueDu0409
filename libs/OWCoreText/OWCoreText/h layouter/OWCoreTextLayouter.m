

#import "OWCoreTextLayouter.h"
#import "GLCTPageInfo.h"
#import <OWCoreText/OWCoreText.h>
#import "OWCoreTextLayoutLine.h"
#import <OWHTMLToAttriString.h>


@interface OWCoreTextLayouter(){
    
    NSArray   *endSymbols ;
    NSArray   *startSymbols;
    
    NSArray   *images;
    //内容的起始偏移量
    float     contentOffsetY;

}
@end


@implementation OWCoreTextLayouter

@synthesize textRect;
@synthesize attributedString, textString, imageURLs, summaryString, framesetter, catName;
@synthesize navIndex, lines;

-(void)initCSS
{
}

-(id)init
{
    self = [super init];
    if (self) {
        _defaultImageSize = CGSizeZero;
    }
    return self;
}

- (void)initWithHTML:(NSString *)html frame:(CGRect)frame startPage:(NSInteger)sp
{
    textRect = frame;
    self.maxLines = 0;
    [self initWithHTML:html startPage:sp contentOffsetY:0 attriStringTransfom:nil];
    [self generatePageInfo:frame];
}

- (void)initWithHTML:(NSString *)html
               frame:(CGRect)frame
           startPage:(NSInteger)sp
 attriStringTransfom:(OWHTMLToAttriString *)htmlToAttriString
{
    textRect = frame;
    self.maxLines = 0;
    [self initWithHTML:html startPage:sp contentOffsetY:0
   attriStringTransfom:htmlToAttriString];
    [self generatePageInfo:frame];
}

- (void)initWithHTML:(NSString *)html frame:(CGRect)frame maxLines:(NSInteger)ml
{
    [self initWithHTML:html frame:frame maxLines:ml attriStringTransfom:nil];
}

- (void)initWithHTML:(NSString *)html frame:(CGRect)frame maxLines:(NSInteger)ml attriStringTransfom:(OWHTMLToAttriString *)htmlToAttriString
{
    textRect = frame;
    self.maxLines = ml;
    [self initWithHTML:html startPage:0 contentOffsetY:0 attriStringTransfom:htmlToAttriString];
    [self generatePageInfo:frame];
}

-(void)initWithHTML:(NSString *)html frame:(CGRect)frame startPage:(NSInteger)sp contentOffsetY:(float)offsetY
{
    textRect = frame;
    self.maxLines = 0;
    [self initWithHTML:html startPage:sp contentOffsetY:offsetY attriStringTransfom:nil];
     [self generatePageInfo:frame];
}

-(void)initWithHTML:(NSString *)html frame:(CGRect)frame startPage:(NSInteger)sp contentOffsetY:(float)offsetY defaultImageSize:(CGSize)imageSize
{
    _defaultImageSize = imageSize;
    [self initWithHTML:html frame:frame startPage:sp contentOffsetY:offsetY];
}

-(void)initWithHTML:(NSString *)html  startPage:(NSInteger)sp contentOffsetY:(float)offsetY  attriStringTransfom:(OWHTMLToAttriString *)htmlToAttriString
{
    contentOffsetY = offsetY;

    if (htmlToAttriString) {
        self.htmlTranslater = htmlToAttriString;
    }
    else {
        self.htmlTranslater = [OWHTMLToAttriString sharedInstance];
    }
    self.htmlTranslater.imageSize = textRect.size;
    [self.htmlTranslater generateAttriStringWithHTML:html];

    attributedString = self.htmlTranslater.attributedString;
    startPageNum = sp;
    
    startSymbols = [NSArray arrayWithObjects:@"‘", @"《", @"“", @"「", @"（", nil];
    
}

//是否为只能出现在行尾的标点符号
- (BOOL)isEndSymbol:(NSString *)str
{
    if(!endSymbols){
        endSymbols = [NSArray arrayWithObjects:@"。", @"，",  @"’",   @"》",
                      @"？", @"！",  @"”", @"、", @"；", @"：", @"·", @".", @"－", @"─",
                      @"」", @"）", nil];
    }
    for(NSString *s in endSymbols){
        if([s isEqualToString:str]){
            return YES;
        }
    }
    return NO;
}

//计算哪张图片在当前页面或下一页中
- (NSInteger)calculateWitchImageIsInPage:(NSInteger)currentPage
                              range:(NSRange)rg
                          addToPage:(BOOL)addToPage
{
    for(NSDictionary *dic in images){
        NSInteger location = [(NSNumber *)[dic objectForKey:@"location"] integerValue];

        void(^AddPageInfo)() = ^{
            if(addToPage){
                GLCTPageInfo *pi = [[GLCTPageInfo alloc]init];
                pi.pageNumber = currentPage;
                pi.imagePath  = [dic objectForKey:@"path"];
                [pages setObject:pi forKey:[NSNumber numberWithInteger:currentPage]];
            }
        };
        
        if(rg.length == 0){
            if(location == rg.location){
                AddPageInfo();
//                return currentPage;
            }
        }
        else {
            if(location >= rg.location && location <= (rg.location + rg.length)){
                currentPage += 1;
                AddPageInfo();
//                return currentPage;
            }
        }
    }
    return currentPage;
}

- (void)generatePage
{
    [self generatePageInfo:textRect];
}

- (void)generatePageInfo:(CGRect)rect
{
    NSUInteger pageIndex = startPageNum;
    
    pages = [[NSMutableDictionary alloc]init ];
    
    textString = [attributedString string];
   
    if(textString.length == 0){
//        [self calculateWitchImageIsInPage:startPageNum range:NSMakeRange(0, 0) addToPage:YES];
        return ;
    }
    CFAttributedStringRef cfString = (__bridge CFAttributedStringRef)attributedString; 
    framesetter = CTFramesetterCreateWithAttributedString(cfString);
	CTTypesetterRef typesetter = CTFramesetterGetTypesetter(framesetter);
    
    newRect = CGRectZero;
    newRect.size = rect.size;
	lineOrigin = newRect.origin;
    lineOrigin.y += contentOffsetY;
	
	previousLine = nil;
	
	NSMutableArray *paragraphRanges = [[self paragraphRanges] mutableCopy];
	NSRange currentParagraphRange = [[paragraphRanges objectAtIndex:0] rangeValue];
	
	lineRange = NSMakeRange(0, textString.length);
	NSMutableArray *pageLines = [[NSMutableArray alloc]init];
	// 每一页的最大Y坐标
	CGFloat maxY = CGRectGetMaxY(newRect);
	NSUInteger maxIndex = textString.length;
	NSUInteger fittingLength = 0;
    	    
    GLCTPageInfo *pageInfo;
    pageInfo = [[GLCTPageInfo alloc]init];
    pageInfo.location = 0;
    pageInfo.lenght = 0;
    pageInfo.pageNumber = pageIndex;

	do {
		while (lineRange.location >= (currentParagraphRange.location+currentParagraphRange.length)) {
			// we are outside of this paragraph, so we go to the next
			[paragraphRanges removeObjectAtIndex:0];
			
			currentParagraphRange = [[paragraphRanges objectAtIndex:0] rangeValue];
		}
		
		isAtBeginOfParagraph = (currentParagraphRange.location == lineRange.location);
		
		paragraphStyle = (__bridge CTParagraphStyleRef)[attributedString attribute:(id)kCTParagraphStyleAttributeName atIndex:lineRange.location effectiveRange:NULL];
		
		offsetX = 0;
		
		if (isAtBeginOfParagraph) {
            CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierFirstLineHeadIndent, sizeof(offsetX), &offsetX);		
		}
		else {
			CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierHeadIndent, sizeof(offsetX), &offsetX);
		}
		
		lineOrigin.x = offsetX + newRect.origin.x;
		
		// find how many characters we get into this line
		lineRange.length = CTTypesetterSuggestLineBreak(typesetter, lineRange.location, newRect.size.width - offsetX);
		if (NSMaxRange(lineRange) > maxIndex) {
			lineRange.length = maxIndex - lineRange.location;
		}
		
		if (NSMaxRange(lineRange) == NSMaxRange(currentParagraphRange)) {
			// at end of paragraph, record the spacing
			CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierParagraphSpacing, sizeof(currentLineMetrics.paragraphSpacing), &currentLineMetrics.paragraphSpacing);
		}
        
		line = CTTypesetterCreateLine(typesetter, CFRangeMake(lineRange.location, lineRange.length));
		
		// we need all metrics so get the at once
		currentLineMetrics.width = CTLineGetTypographicBounds(line, &currentLineMetrics.ascent, &currentLineMetrics.descent, &currentLineMetrics.leading);
        
        //对比行的实际宽度与页面宽度，追加必要的字符使文本布局更完美    
        isAtEndOfParagraph = (currentParagraphRange.location + currentParagraphRange.length == lineRange.location +lineRange.length);
        
        //重新计算行尾及下行首的标点位置
//        if(!isAtEndOfParagraph){
//            float endWidth = newRect.size.width - (currentLineMetrics.width +offset);
//            int chaCount = floor(endWidth / 18); 
//            //行尾宽度超过1个字符时，追加字符
//            if(chaCount > 0){
//                int nextCharLocation = lineRange.location +lineRange.length + chaCount ;
//                if(textString.length >= nextCharLocation + 1){
//                    NSString *lineText = [textString substringWithRange:NSMakeRange(nextCharLocation, 1)];
//                    if([self isEndSymbol:lineText]){
//                        lineRange.length += (chaCount + 1);
//                    }else {
//                        lineRange.length += chaCount;
//                    }
//                    CFRelease(line);
//                    line = CTTypesetterCreateLine(typesetter, CFRangeMake(lineRange.location, lineRange.length));
//                    currentLineMetrics.width = CTLineGetTypographicBounds(line, &currentLineMetrics.ascent, &currentLineMetrics.descent, &currentLineMetrics.leading);
//                }
//              
//            }
//
//        }
        
        CGFloat lineHeight = [self calculateLineSpace];

        [self setLineTextAlignment];
        
		CGFloat lineBottom = lineOrigin.y + currentLineMetrics.descent;
//        NSLog(@"lineBottom:%f, %f",lineOrigin.x, currentLineMetrics.descent);
// && (lineHeight > 35 && lineBottom > (maxY + 20))
        
        //如果行高超过了maxY,会成死循环，so....
        if (lineBottom > maxY && lineHeight < (maxY-20) ) {
//            NSLog(@"fdafa:%f, %f, %f",maxY, lineBottom, lineHeight);
            pageInfo.lines = [pageLines copy];
            
            NSUInteger length = pageInfo.location+pageInfo.lenght;
            if (length > textString.length) {
//                NSLog(@"out string");
                pageInfo.lenght = textString.length - pageInfo.location;
            }
            pageInfo.description = [self getPageSummary:pageInfo];
            pageInfo.catIndex = navIndex ;
            [pages setObject:pageInfo forKey:[NSNumber numberWithInteger:pageIndex]];
            
            //计算图片页面,图片始终加到相应位置的下一页
            pageIndex ++;
//            pageIndex = [self calculateWitchImageIsInPage:pageIndex range:descriptionRange addToPage:YES];
            
            [pageLines removeAllObjects];
            pageLines = nil;
            pageLines = [[NSMutableArray alloc] init];
            pageInfo = [[GLCTPageInfo alloc] init];
            //            pageInfo.location = lineRange.location + lineRange.length;
            pageInfo.location = lineRange.location;
            pageInfo.pageNumber = pageIndex;
            pageInfo.lenght = 0;
            newRect.origin= CGPointZero;
            lineOrigin = newRect.origin;
        }
        else {
            // wrap it
            OWCoreTextLayoutLine *newLine = [[OWCoreTextLayoutLine alloc] initWithLine:line layouter:self];
            newLine.baselineOrigin = lineOrigin;
            newLine.isLastLine = isAtEndOfParagraph;
            
            fittingLength += lineRange.length;
            pageInfo.lenght += lineRange.length;
            
            [pageLines addObject:newLine];
            
            lineRange.location += lineRange.length;
            
            previousLine = newLine;
            previousLineMetrics = currentLineMetrics;
//            NSLog(@"lineOrigin:%f, %f",lineOrigin.x, lineOrigin.y);
        }
        CFRelease(line);

	}
	while (lineRange.location < maxIndex);

    pageInfo.lines = [pageLines copy];
    
    pageInfo.description = [self getPageSummary:pageInfo];
    pageInfo.catIndex = navIndex ;

    [pages setObject:pageInfo forKey:[NSNumber numberWithInteger:pageIndex]];
    //    pageIndex = [self calculateWitchImageIsInPage:pageIndex+1 range:descriptionRange addToPage:YES];
    pageIndex --;
    endPageNum = startPageNum+[pages count]-1;
//        NSLog(@"endPageNum:%i",endPageNum);
}
#pragma mark 行间距，段间距
- (CGFloat)calculateLineSpace
{
    CGFloat lineHeight = 0;
    CGFloat maxLineHeight = 0;
    
    if (CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierMaximumLineHeight, sizeof(maxLineHeight), &maxLineHeight)) {
        if (maxLineHeight>0 && lineHeight>maxLineHeight) {
            lineHeight = maxLineHeight;
            //                lineHeight = minLineHeight;
        }
    }
    
    // get the correct baseline origin
    if (previousLine) {
        if (lineHeight==0) {
            lineHeight = previousLineMetrics.descent + currentLineMetrics.ascent;
        }
        
        if (isAtBeginOfParagraph) {
            //段间距
            lineHeight += previousLineMetrics.paragraphSpacing;
            //                NSLog(@"段间距: %f",previousLineMetrics.paragraphSpacing);
            //段顶距
            CGFloat paddintTop = 0.0f;
            CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(paddintTop), &paddintTop);
            lineOrigin.y += paddintTop;
        }
    }
    else {
        if (lineHeight>0) {
            if (lineHeight<currentLineMetrics.ascent) {
                // special case, we fake it to look like CoreText
                lineHeight -= currentLineMetrics.descent;
            }
        }
        else {
            lineHeight = currentLineMetrics.ascent;
        }
    }
    /*
     加上行间距
     这里要用 kCTParagraphStyleSpecifierLineSpacingAdjustment
     用 kCTParagraphStyleSpecifierLineSpacing 获取不到值
     */
    CGFloat lineSpace = 0.0f;
    CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(lineSpace), &lineSpace);
    if (lineSpace == 0.0f)
        CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierLineSpacing, sizeof(lineSpace), &lineSpace);
    
    lineOrigin.y += lineHeight + lineSpace;
    
    return lineHeight;
}

#pragma mark 设置行文本对齐
- (void)setLineTextAlignment
{
    CTTextAlignment textAlignment;
    //		CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierAlignment, sizeof(textAlignment), &textAlignment);
    textAlignment = kCTJustifiedTextAlignment ;
    
    switch (textAlignment) {
        case kCTLeftTextAlignment: {
            lineOrigin.x = newRect.origin.x + offsetX;
            // nothing to do
            break;
        }
            
        case kCTNaturalTextAlignment: {
            // depends on the text direction
            CTWritingDirection baseWritingDirection;
            CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierBaseWritingDirection, sizeof(baseWritingDirection), &baseWritingDirection);
            
            if (baseWritingDirection != kCTWritingDirectionRightToLeft) {
                break;
            }
            
            // right alignment falls through
        }
            
        case kCTRightTextAlignment: {
            lineOrigin.x = newRect.origin.x + offsetX + CTLineGetPenOffsetForFlush(line, 1.0, newRect.size.width - offsetX);
            break;
        }
            
        case kCTCenterTextAlignment: {
            lineOrigin.x = newRect.origin.x + offsetX + CTLineGetPenOffsetForFlush(line, 0.5, newRect.size.width - offsetX);
            break;
        }
            
        case kCTJustifiedTextAlignment: {
            if (!isAtEndOfParagraph) {
                // 不是段落最后一行的话设置两端对齐
                NSUInteger lastCharLocation = lineRange.location +lineRange.length -1  ;
                NSString *lineText = [textString substringWithRange:NSMakeRange(lastCharLocation, 1)];
                float lineWidth = newRect.size.width-offsetX;
                if([self isEndSymbol:lineText]){
                    lineWidth += lineWidth/(lineRange.length - 1)/2;
                }
                CTLineRef justifiedLine = CTLineCreateJustifiedLine(line, 1.0f, lineWidth);
                if(justifiedLine){
                    CFRelease(line);
                    line = justifiedLine;
                }
                
            }
            lineOrigin.x = newRect.origin.x + offsetX;
            
            break;
        }
    }
}

#pragma mark 生成每一页的摘要
- (NSString *)getPageSummary:(GLCTPageInfo *)pageInfo
{
    NSRange descriptionRange;
    descriptionRange = NSMakeRange(pageInfo.location, pageInfo.lenght);
    NSString *summary ;
    if (!textString || [textString isEqualToString:@""] || textString.length < 2) {
        summary = textString;
    }
    else if ((pageInfo.location + pageInfo.lenght) > textString.length) {
        summary = [textString substringWithRange:NSMakeRange(pageInfo.location, textString.length-pageInfo.location)];
    }
    else {
        summary = [textString substringWithRange:descriptionRange];
    }
//
//    //如果是章节的第一页，页面描述需要去掉章节名称
//    if (pageInfo.location == 0) {
//        descriptionRange = NSMakeRange(catName.length, summary.length-catName.length);
//        summary = [summary substringWithRange:descriptionRange];
//    }
//    summary = [summary stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    summary = [summary stringByReplacingOccurrencesOfString: @"\r" withString:@""];
//    summary = [summary stringByReplacingOccurrencesOfString: @"\n" withString:@""];
    
    return summary;
}

//
- (NSArray *)paragraphRanges
{
    NSArray *paragraphs = [textString componentsSeparatedByString:@"\n"];
    NSRange range = NSMakeRange(0, 0);
    NSMutableArray *tmpArray = [NSMutableArray array];
    
    for (NSString *oneString in paragraphs) {
        range.length = [oneString length]+1;
        
        NSValue *value = [NSValue valueWithRange:range];
        [tmpArray addObject:value];
        
        range.location += range.length;
    }
    
    // prevent counting a paragraph after a final newline
    if ([textString hasSuffix:@"\n"]) {
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

        if(pos >= info.location && pos < (info.location + info.lenght)){
           return [key intValue]; 
        }
            
    }
    return  startPageNum;
}

-(NSInteger)getPageCount
{
    if (pages)
        return pages.count;
    else
        return 1;
}

- (BOOL)detectRelease:(NSInteger)pageNumber
{
    NSInteger lower = pageNumber - 2;
    NSInteger upper = pageNumber + 2;
    if(endPageNum < lower ||startPageNum > upper){
        return YES;
    }
    return NO;
}

- (NSMutableArray *)generateLines:(NSAttributedString *)attriString maxLines:(NSInteger)max startPosition:(CGPoint)position width:(float)w getHeight:(float *)height
{
    return [self generateLines:attriString orginalString:nil maxLines:max startPosition:position width:w getHeight:height];
}

- (NSMutableArray *)generateLines:(NSAttributedString *)attriString 
             orginalString:(NSString *)string
                  maxLines:(NSInteger)max
             startPosition:(CGPoint)position 
                     width:(float)w
                 getHeight:(float *)height
{
    NSMutableArray *pageLines = [[NSMutableArray alloc]init];
    if(string == nil)
        string = attriString.string;
    
    NSInteger currentLineIndex = 1;
    CFAttributedStringRef cfString = (__bridge CFAttributedStringRef)attriString; 
    CTFramesetterRef framesetter2 = CTFramesetterCreateWithAttributedString(cfString);
	CTTypesetterRef typesetter = CTFramesetterGetTypesetter(framesetter2);

	lineOrigin = position;
	previousLine = nil;
	    
	NSRange currentParagraphRange = NSMakeRange(0, string.length);
    lineRange = NSMakeRange(0, string.length);
	NSUInteger maxIndex = string.length;
    
	do {
		
		isAtBeginOfParagraph = (currentParagraphRange.location == lineRange.location);
		
		paragraphStyle = (__bridge CTParagraphStyleRef)[attriString attribute:(id)kCTParagraphStyleAttributeName atIndex:lineRange.location effectiveRange:NULL];
		
		CGFloat offset = 0;
		
		if (isAtBeginOfParagraph)
		{
            CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierFirstLineHeadIndent, sizeof(offset), &offset);		
		}
		else
		{
			CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierHeadIndent, sizeof(offset), &offset);
		}
		
		lineOrigin.x = offset + position.x;
		
		// find how many characters we get into this line
		lineRange.length = CTTypesetterSuggestLineBreak(typesetter, lineRange.location, w - offset);
		if (NSMaxRange(lineRange) > maxIndex)
		{
			// only layout as much as was requested
			lineRange.length = maxIndex - lineRange.location;
		}
		
		if (NSMaxRange(lineRange) == NSMaxRange(currentParagraphRange))
		{
			// at end of paragraph, record the spacing
			CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierParagraphSpacing, sizeof(currentLineMetrics.paragraphSpacing), &currentLineMetrics.paragraphSpacing);
		}
        
		line = CTTypesetterCreateLine(typesetter, CFRangeMake(lineRange.location, lineRange.length));
		
		// we need all metrics so get the at once
		currentLineMetrics.width = CTLineGetTypographicBounds(line, &currentLineMetrics.ascent, &currentLineMetrics.descent, &currentLineMetrics.leading);
        
        //对比行的实际宽度与页面宽度，追加必要的字符使文本布局更完美    
        isAtEndOfParagraph = (currentParagraphRange.location + currentParagraphRange.length == lineRange.location +lineRange.length);
		// get line height in px if it is specified for this line
		CGFloat lineHeight = 0;
		CGFloat maxLineHeight = 0;
		
		if (CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierMaximumLineHeight, sizeof(maxLineHeight), &maxLineHeight))
		{
			if (maxLineHeight>0 && lineHeight>maxLineHeight)
			{
				lineHeight = maxLineHeight;
                //                lineHeight = minLineHeight;
			}
		}
        
		// get the correct baseline origin
		if (previousLine) {
			if (lineHeight==0) {
				lineHeight = previousLineMetrics.descent + currentLineMetrics.ascent;
			}
            
			if (isAtBeginOfParagraph) {
                //段间距
				lineHeight += previousLineMetrics.paragraphSpacing;
			}
			
		}
		else {
			if (lineHeight>0) {
				if (lineHeight<currentLineMetrics.ascent) {
					// special case, we fake it to look like CoreText
					lineHeight -= currentLineMetrics.descent; 
                    
				}
			}
			else 
			{
				lineHeight = currentLineMetrics.ascent;
                
			}
		}
        //加上行间距
        CGFloat lineSpace = 0;
        
        CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(lineSpace), &lineSpace);
        
        if (lineSpace < 0.1f)
            CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierLineSpacing, sizeof(lineSpace), &lineSpace);
		lineOrigin.y += lineHeight + lineSpace;
		
		CTTextAlignment textAlignment;
        CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierAlignment, sizeof(textAlignment), &textAlignment);

//        textAlignment = kCTJustifiedTextAlignment ;
		
		switch (textAlignment) 
		{
			case kCTLeftTextAlignment:
			{
				lineOrigin.x = position.x + offset;
				// nothing to do
				break;
			}
				
			case kCTNaturalTextAlignment:
			{
				// depends on the text direction
				CTWritingDirection baseWritingDirection;
				CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierBaseWritingDirection, sizeof(baseWritingDirection), &baseWritingDirection);
				
				if (baseWritingDirection != kCTWritingDirectionRightToLeft)
				{
					break;
				}
				
				// right alignment falls through
			}
				
			case kCTRightTextAlignment:
			{
				lineOrigin.x = position.x + offset + CTLineGetPenOffsetForFlush(line, 1.0, w - offset);
				break;
			}
				
			case kCTCenterTextAlignment:
			{
				lineOrigin.x = position.x + offset + CTLineGetPenOffsetForFlush(line, 0.5, w - offset);
				break;
			}
				
            case kCTJustifiedTextAlignment:
			{
                if(!isAtEndOfParagraph){
                    // 不是段落最后一行的话设置两端对齐
                    NSUInteger lastCharLocation = lineRange.location +lineRange.length - 1  ;
                    NSString *lineText = [string substringWithRange:NSMakeRange(lastCharLocation, 1)];
                    float lineWidth = w-offset;
                    if([self isEndSymbol:lineText]){
                        lineWidth += lineWidth/(lineRange.length - 1)/2;
                    }
                    CTLineRef justifiedLine = CTLineCreateJustifiedLine(line, 1.0f, lineWidth);
                    if(justifiedLine){
                        CFRelease(line);
                        line = justifiedLine;
                    }
                    
				}
				lineOrigin.x = position.x + offset;
				
				break;
			}
		}
                
        OWCoreTextLayoutLine *newLine = [[OWCoreTextLayoutLine alloc] initWithLine:line layouter:self];
        newLine.baselineOrigin = lineOrigin;
        newLine.isLastLine = isAtEndOfParagraph;
        [pageLines addObject:newLine];
        CFRelease(line);

        previousLine = newLine;
        previousLineMetrics = currentLineMetrics; 
        
		if(max > 0 && currentLineIndex == max){
            break;
//            CGFloat lineBottom = lineOrigin.y + currentLineMetrics.descent+currentLineMetrics.paragraphSpacing;
//            *height = lineBottom;
//            CFRelease(framesetter2);
//
//            return pageLines;
      
		}
        lineRange.location += lineRange.length;           
        currentLineIndex ++;
        
	} 
	while (lineRange.location < maxIndex);
    CFRelease(framesetter2);

    CGFloat lineBottom = lineOrigin.y + currentLineMetrics.descent+ previousLineMetrics.paragraphSpacing;
    if (height) {
        *height = lineBottom;
    }

    return  pageLines;
}

-(NSArray *)linesVisibleInRect:(CGRect)rect
{
    return nil;
}

-(NSArray *)getAllLines
{
    return nil;
}

-(void)dealloc
{
//    NSLog(@"-------------------------------OWCoreTextLayouter____dealloc");
    if(framesetter) CFRelease(framesetter);

    if (pages) {
        [pages removeAllObjects];
        pages = nil;
    }
}

@end
