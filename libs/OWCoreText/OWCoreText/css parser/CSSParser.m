//
//  CSSParser.m
//  OWCoreText
//
//  Created by 龙源 on 13-7-19.
//
//

#import "CSSParser.h"
#import <OWKit/OWKit.h>
#import <CoreText/CoreText.h>

@interface UIStyle : NSObject

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) float fontSize;
@property (nonatomic, strong) NSString *fontName;
@property (nonatomic, assign) CTTextAlignment textAlignment;
@property (nonatomic, assign) float textIndent;
@property (nonatomic, assign) float lineHeight;
@property (nonatomic, assign) float paddingTop;
@property (nonatomic, assign) float paddingLeft;
@property (nonatomic, assign) float paddingBottom;
@property (nonatomic, assign) float letterSpacing;
@end

@implementation UIStyle

- (id)init
{
    self = [super init];
    if (self) {
        self.fontName = @"FZLTXHK--GBK1-0";
        self.fontSize = 12;
        self.letterSpacing = 1;
        self.color = [UIColor blackColor];
        self.textAlignment = kCTTextAlignmentLeft;
        self.textIndent = 0;
        self.lineHeight = 12;
        self.paddingTop = 0;
        self.paddingLeft = 0;
        self.paddingBottom = 0;
    }
    return self;
}
@end

@implementation CSSParser

- (id)init
{
    if (self = [super init]) {
        self.fontSizeScale = 1.0f;
    }
    return self;
}

- (NSMutableDictionary *)parseCSS:(NSString *)fileName
{
    if (!self.bundle) {
        self.bundle = [NSBundle mainBundle];
    }
    NSString *path = [self.bundle pathForResource:fileName ofType:@"css"];
    if (!path) {
        NSLog(@"没找到样式文件：%@", fileName);
        return Nil;
    }
    NSString *fileString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    NSArray *arr = [fileString componentsSeparatedByString:@"}"];
    
    NSMutableDictionary *cssDictionary = [[NSMutableDictionary alloc] init];
    
    NSCharacterSet *keyEndSet = [NSCharacterSet characterSetWithCharactersInString:@":"];
    NSCharacterSet *valueEndSet = [NSCharacterSet characterSetWithCharactersInString:@";"];
     NSCharacterSet *startSet = [NSCharacterSet characterSetWithCharactersInString:@"{"];
    
    for (NSString *cssString in arr) {        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

        NSScanner *scanner = [[NSScanner alloc] initWithString:cssString];
        NSString *cssName;
        [scanner scanUpToCharactersFromSet:startSet intoString:&cssName];
        [scanner scanCharactersFromSet:startSet intoString:NULL];
        
        if (!cssName) break;

        while (![scanner isAtEnd]) {
            NSString *key;
            NSString *value;
            
            [scanner scanUpToCharactersFromSet:keyEndSet intoString:&key];
            [scanner scanCharactersFromSet:keyEndSet intoString:NULL];
            [scanner scanUpToCharactersFromSet:valueEndSet intoString:&value];
            [scanner scanCharactersFromSet:valueEndSet intoString:NULL];
            
            [dict setValue:value forKey:key];
        }
        [cssDictionary setValue:[self generateCSS:dict] forKey:cssName];
    }
//    NSLog(@"afa:%@",cssDictionary);
    return cssDictionary;
}


- (NSDictionary *)generateCSS:(NSDictionary *)dict
{
    UIStyle *style = [[UIStyle alloc] init];
    
    for (NSString *key in dict) {
        id value = [dict objectForKey:key];
        
        if ([key isEqualToString:@"color"]) {
            style.color = [OWColor colorWithHexString:(NSString *)value];
        }
        
        else if ([key isEqualToString:@"font-family"]) {
            style.fontName = value;
        }
        
        else if ([key isEqualToString:@"font-size"]) {
            CGFloat fontSize = [self pixelToFloat:value];
            if (isPad) {
                fontSize += 7;
            }
            style.fontSize = roundf(fontSize * self.fontSizeScale);
        }
        
        else if ([key isEqualToString:@"letter-spacing"]) {
            style.letterSpacing = [self pixelToFloat:value];
        }
        
        else if ([key isEqualToString:@"text-indent"]) {
            CGFloat indent = [self pixelToFloat:value];
            if (isPad) {
                indent += 14;
            }
            style.textIndent = indent  * self.fontSizeScale;
        }
        
        else if ([key isEqualToString:@"text-align"]) {
            if ([value isEqualToString:@"left"])
                style.textAlignment = kCTTextAlignmentLeft;
            else if ([value isEqualToString:@"justify"])
                style.textAlignment = kCTTextAlignmentJustified;
            else if ([value isEqualToString:@"center"])
                style.textAlignment = kCTTextAlignmentCenter;
            else if ([value isEqualToString:@"right"])
                    style.textAlignment = kCTTextAlignmentRight;            
        }
        
        else if ([key isEqualToString:@"line-height"]) {
            CGFloat height = [self pixelToFloat:value];
            if (isPad) {
                height += 7;
            }
            style.lineHeight = height * self.fontSizeScale;
        }
        
        else if ([key isEqualToString:@"padding-top"]) {
            style.paddingTop = [self pixelToFloat:value] * self.fontSizeScale;
        }
        else if ([key isEqualToString:@"padding-bottom"]) {
            style.paddingBottom = [self pixelToFloat:value] * self.fontSizeScale;
        }
    }
    if (self.fontName && style.fontName) {
        style.fontName = self.fontName;
    }
    if (style.lineHeight < 8.0f)
        style.lineHeight = style.fontSize;

    return  [self getAttributesByCSS:style];
}

- (float)pixelToFloat:(NSString *)px
{
    NSNumber *number = [px componentsSeparatedByString:@"p"][0];
    return [number floatValue];
}

- (NSDictionary *)getAttributesByCSS:(UIStyle *)style
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    CTFontRef aFont = CTFontCreateWithName((__bridge CFStringRef)style.fontName, style.fontSize, NULL);
    [attributes setObject:(__bridge id)(aFont) forKey:(id)kCTFontAttributeName];
    CFRelease(aFont);
    //字间距
    [attributes setObject:[NSNumber numberWithFloat:style.letterSpacing] forKey:NSKernAttributeName];
    //字体边框线
//    [attributes setObject:[NSNumber numberWithFloat:2] forKey:NSStrokeWidthAttributeName];
//    [attributes setObject:(__bridge id)style.color.CGColor forKey:NSStrokeColorAttributeName];

    [attributes setObject:(__bridge id)style.color.CGColor forKey:(id)kCTForegroundColorAttributeName];

    float lineSpacing = (style.lineHeight - style.fontSize);

    NSString *reqSysVer = @"6.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending) {
        NSParagraphStyle *paragraphStyle = [self setiOS6ParagraphStyleByAlignment:style.textAlignment
                                                         firstLineIndent:style.textIndent
                                                              headIndent:style.paddingLeft
                                                               lineSpace:lineSpacing
                                                          paragraphSpace:style.paddingBottom
                                                    paragraphSpaceBefore:style.paddingTop];
        [attributes setObject:paragraphStyle forKey:(id)kCTParagraphStyleAttributeName];

    }
    else {
        CTParagraphStyleRef paragraphStyle =[self setiOS5ParagraphStyleByAlignment:style.textAlignment
                                                               firstLineIndent:style.textIndent
                                                                    headIndent:style.paddingLeft
                                                                     lineSpace:lineSpacing
                                                                paragraphSpace:style.paddingBottom
                                                          paragraphSpaceBefore:style.paddingTop];
        [attributes setObject:(__bridge id)paragraphStyle forKey:(id)kCTParagraphStyleAttributeName];
        CFRelease(paragraphStyle);

    }
   
    
    return attributes;
}

-(id)setParagraphStyleByAlignment:(CTTextAlignment)alignmt
                                   firstLineIndent:(float)indent
                                        headIndent:(float)hIndent
                                         lineSpace:(float)ls
                                    paragraphSpace:(float)ps
                              paragraphSpaceBefore:(float)psb
{
    return [self setiOS6ParagraphStyleByAlignment:alignmt firstLineIndent:indent headIndent:hIndent lineSpace:ls paragraphSpace:ps paragraphSpaceBefore:psb];
}

-(NSParagraphStyle *)setiOS6ParagraphStyleByAlignment:(CTTextAlignment)alignmt
                  firstLineIndent:(float)indent
                       headIndent:(float)hIndent
                        lineSpace:(float)ls
                   paragraphSpace:(float)ps
             paragraphSpaceBefore:(float)psb
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    switch (alignmt) {
        case kCTJustifiedTextAlignment:
            style.alignment = NSTextAlignmentJustified;
            break;
            
        case kCTTextAlignmentCenter:
            style.alignment = NSTextAlignmentCenter;
            break;
            
        case kCTRightTextAlignment:
            style.alignment = NSTextAlignmentRight;
            break;
            
        default:
            style.alignment = NSTextAlignmentLeft;
            break;
    }
    [style setFirstLineHeadIndent:indent];
    [style setHeadIndent:hIndent];
    [style setLineSpacing:ls];
    [style setParagraphSpacing:ps];
    [style setParagraphSpacingBefore:psb];

    return style;

}

-(CTParagraphStyleRef)setiOS5ParagraphStyleByAlignment:(CTTextAlignment)alignmt
                                   firstLineIndent:(float)indent
                                        headIndent:(float)hIndent
                                         lineSpace:(float)ls
                                    paragraphSpace:(float)ps
                              paragraphSpaceBefore:(float)psb
{
       //创建文本对齐方式
    CTTextAlignment alignment = alignmt;//左对齐 kCTRightTextAlignment为右对齐
    CTParagraphStyleSetting alignmentStyle;
    alignmentStyle.spec=kCTParagraphStyleSpecifierAlignment;//指定为对齐属性
    alignmentStyle.valueSize=sizeof(alignment);
    alignmentStyle.value=&alignment;
    
    CGFloat firstLineIndent = indent;
    CTParagraphStyleSetting indentStyle;
    indentStyle.spec=kCTParagraphStyleSpecifierFirstLineHeadIndent;
    indentStyle.valueSize=sizeof(firstLineIndent);
    indentStyle.value=&firstLineIndent;
    
    CTParagraphStyleSetting headIndentStyle;
    headIndentStyle.spec=kCTParagraphStyleSpecifierHeadIndent;
    headIndentStyle.valueSize=sizeof(hIndent);
    headIndentStyle.value=&hIndent;
    
    //创建文本行间距
    CGFloat lineSpace=ls;//间距数据
    CTParagraphStyleSetting lineSpaceStyle;
    lineSpaceStyle.spec=kCTParagraphStyleSpecifierLineSpacing;//指定为行间距属性
    lineSpaceStyle.valueSize=sizeof(lineSpace);
    lineSpaceStyle.value=&lineSpace;
    
    //段间距
    CGFloat pSpace = ps;
    CTParagraphStyleSetting pSpaceStyle;
    pSpaceStyle.spec =kCTParagraphStyleSpecifierParagraphSpacing;
    //    pSpaceStyle.spec =kCTParagraphStyleSpecifierParagraphSpacingBefore;
    pSpaceStyle.valueSize = sizeof(pSpace);
    pSpaceStyle.value = &pSpace;
    
    //段前间距
    CGFloat pSpaceBefore = psb;
    CTParagraphStyleSetting pSpaceBeforeStyle;
    pSpaceBeforeStyle.spec =kCTParagraphStyleSpecifierParagraphSpacingBefore;
    pSpaceBeforeStyle.valueSize = sizeof(pSpaceBefore);
    pSpaceBeforeStyle.value = &pSpaceBefore;
    
    GLfloat pBreakMode = kCTLineBreakByTruncatingTail;
    CTParagraphStyleSetting pBreakModeStyle;
    pBreakModeStyle.spec =kCTParagraphStyleSpecifierLineBreakMode;
    pBreakModeStyle.valueSize = sizeof(pBreakMode);
    pBreakModeStyle.value = &pBreakMode;
    
    //创建样式数组
    CTParagraphStyleSetting settings[]={
        pSpaceStyle,alignmentStyle,lineSpaceStyle,indentStyle,headIndentStyle,pBreakModeStyle,pSpaceBeforeStyle
    };
   
    //设置样式
    CTParagraphStyleRef style;
    style= CTParagraphStyleCreate(settings, 5);
    return style;
}

@end
