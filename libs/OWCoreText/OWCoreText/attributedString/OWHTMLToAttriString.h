//
//  OWHTMLToAttriString.h
//  OWCoreText
//
//  Created by 龙源 on 13-7-19.
//
//

#import <Foundation/Foundation.h>
#import <OWKit/OWKit.h>

@class OWCoreTextLayouter;

@interface OWHTMLToAttriString : NSObject
{
    OWCoreTextLayouter  *layouter;
    NSMutableDictionary *cssDictionary;
    NSDictionary                    *parentAttributes;//当前字符属性
    NSDictionary                    *globalAttributes;//全局样式
    NSMutableDictionary             *tagHandlers;

    float           fontScale;
}

@property(nonatomic,retain) NSMutableAttributedString *attributedString;
@property (assign, nonatomic) CGSize    imageSize;
@property (nonatomic, strong) NSString  *imageBasicPath;
@property (nonatomic, strong) NSString  *fontName;
@property (nonatomic, strong) NSBundle  *bundle;


#pragma mark 新增属性
@property (nonatomic, strong) NSString  *videoBasicPath;



+ (OWHTMLToAttriString *)sharedInstance;

- (void)setCSS:(NSString *)fileName;

//字体大小缩放值
- (void)setCSS:(NSString *)fileName fontSizeScale:(float)scale;
- (void)scaleFontSize:(float)scale;

//添加新的CSS对像，如果已有旧的则替换
- (void)appendCSS:(NSString *)fileName;

- (float)convertHTML:(NSString *)html width:(float)width toLine:(NSArray **)lines;
- (float)convertHTML:(NSString *)html
               width:(float)width
             maxLine:(int)maxLine
              toLine:(NSArray **)lines;

- (float)convertHTML:(NSString *)html startPoint:(CGPoint)point width:(float)width
             maxLine:(int)maxLine toLine:(NSArray **)lines;

- (void)generateAttriStringWithHTML:(NSString *)html;

+ (UIImage *)decryptImage:(NSString *)inputPath;

@end
