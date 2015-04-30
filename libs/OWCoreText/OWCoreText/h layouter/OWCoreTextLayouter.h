//
//  OWCoreTextLayouter.h
//  OWCoreTextTest
//
//  Created by  oowwww on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import "OWHTMLToAttriString.h"

typedef struct
{
    CGFloat ascent;
    CGFloat descent;
    CGFloat width;
    CGFloat leading;
    CGFloat trailingWhitespaceWidth;
    CGFloat paragraphSpacing;
} lineMetrics;

@class GLCTPageInfo, OWCoreTextLayoutLine;

@interface OWCoreTextLayouter : NSObject
{
    //行位置
    CGPoint         lineOrigin;
    //文本绘制区（从 0，0位置开始）
    CGRect          newRect;
    OWCoreTextLayoutLine    *previousLine;
    CTLineRef               line;
    NSRange                 lineRange;
    
    CTParagraphStyleRef     paragraphStyle;
    BOOL                    isAtBeginOfParagraph, isAtEndOfParagraph ;
    CGFloat                 offsetX;
    
    lineMetrics     currentLineMetrics;
	lineMetrics     previousLineMetrics;
    
    NSUInteger                 startPageNum;
    NSUInteger                 endPageNum;
    
    NSMutableDictionary  *pages;
    
    CGSize              _defaultImageSize;

}
@property (nonatomic, strong)   NSMutableArray       *lines;

@property (nonatomic, strong)   NSMutableAttributedString *attributedString;
@property (nonatomic, retain)   NSArray                     *imageURLs;
@property (nonatomic, retain)    NSString                    *textString;
@property (nonatomic, retain)    NSString       *summaryString;
@property  (nonatomic)          CTFramesetterRef     framesetter;
@property (nonatomic, retain)    NSString            *catName;
@property (nonatomic, assign)   CGRect               textRect ;
@property (nonatomic, strong) OWHTMLToAttriString   *htmlTranslater;

@property (nonatomic, assign) NSInteger maxLines;

//layouter在字典中的索引，也是目录的索引
@property(nonatomic,retain)NSNumber *navIndex;
//文本渲染区的最大高度
@property(nonatomic,assign)float infiniteHeight;

- (void)initWithHTML:(NSString *)html
               frame:(CGRect)frame 
           startPage:(NSInteger)sp;

- (void)initWithHTML:(NSString *)html
               frame:(CGRect)frame
           startPage:(NSInteger)sp
 attriStringTransfom:(OWHTMLToAttriString *)htmlToAttriString;

- (void)initWithHTML:(NSString *)html
               frame:(CGRect)frame
            maxLines:(NSInteger)lines;

- (void)initWithHTML:(NSString *)html
               frame:(CGRect)frame
            maxLines:(NSInteger)lines
 attriStringTransfom:(OWHTMLToAttriString *)htmlToAttriString;

- (void)initWithHTML:(NSString *)html
               frame:(CGRect)frame
           startPage:(NSInteger)sp
      contentOffsetY:(float)offsetY;

- (void)initWithHTML:(NSString *)html
               frame:(CGRect)frame
           startPage:(NSInteger)sp
      contentOffsetY:(float)offsetY
    defaultImageSize:(CGSize)imageSize;

- (void)initCSS;

- (BOOL)isEndSymbol:(NSString *)str;

//解析NSAttributedString到单页PageInfo
//生成页面
- (void)generatePage;

- (NSArray *)linesVisibleInRect:(CGRect)rect;
- (NSArray *)getAllLines;

- (NSMutableArray *)generateLines:(NSAttributedString *)attriString
                         maxLines:(NSInteger)max
                    startPosition:(CGPoint)position
                            width:(float)w
                        getHeight:(float *)height;

//取得单面frame
- (GLCTPageInfo *)getPageInfo:(NSInteger)pn;

//根据字符位置取得页码（书签）
-(NSInteger)getPageNumberByPosition:(NSInteger)pos;
//取得总的页面数
-(NSInteger)getPageCount;

//检测此对象是否要被释放
-(BOOL)detectRelease:(NSInteger)pageNumber;

@end


