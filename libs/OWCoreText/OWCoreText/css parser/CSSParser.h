//
//  CSSParser.h
//  OWCoreText
//
//  Created by 龙源 on 13-7-19.
//
//

#import <Foundation/Foundation.h>

@interface CSSParser : NSObject
{
}
@property (nonatomic, assign) float     fontSizeScale;
@property (nonatomic, strong) NSString  *fontName;
@property (nonatomic, strong) NSBundle    *bundle;

- (NSMutableDictionary *)parseCSS:(NSString *)fileName;

@end
