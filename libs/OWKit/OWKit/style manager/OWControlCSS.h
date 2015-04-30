//
//  GLButtonParameter.h
//  KWFBooks
//
//  Created by gren light on 13-2-23.
//
//

#import <Foundation/Foundation.h>

@interface OWControlCSS : NSObject

@property(nonatomic,retain)UIColor *borderColor_normal;
@property(nonatomic,retain)UIColor *borderColor_highlight;
@property(nonatomic, assign) float  borderWidth;

@property(nonatomic,retain)UIColor *shadowColor_normal;
@property(nonatomic,retain)UIColor *shadowColor_highlight;
@property(nonatomic,assign)CGPoint  shadowColorOffset;

@property(nonatomic,retain)UIColor *innerGlow_normal;
@property(nonatomic,retain)UIColor *innerGlow_highlight;
@property(nonatomic, assign) float  innerGlowWidth;

@property(nonatomic,retain)NSArray *fillColor_normal;
@property(nonatomic,retain)NSArray *fillColor_highlight;

@property(nonatomic,assign)float    cornerRadius;

@property(nonatomic,retain)UIColor *textColor_normal;
@property(nonatomic,retain)UIColor *textColor_highlight;
@property(nonatomic,retain)UIColor *textColor_disabled;

@end
