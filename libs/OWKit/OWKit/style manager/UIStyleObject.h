//
//  UIStyleObject.h
//  PublicLibrary
//
//  Created by grenlight on 14-1-13.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIStyleObject : NSObject

@property (nonatomic, strong) UIColor *background;
@property (nonatomic, strong) UIColor *fontColor;
@property (nonatomic, assign) BOOL      useBackgroundImage;
@property (nonatomic, strong) NSString *background_Image;

@property (nonatomic, strong) UIColor *background_selected;
@property (nonatomic, strong) UIColor *fontColor_selected;
@property (nonatomic, assign) float fontSize;

@property (nonatomic, strong) NSArray *gradientBackground;
@property (nonatomic, strong) NSArray *gradientBackground_selected;

@property (nonatomic, strong) UIColor *shadowColor;
@property (nonatomic, assign) float shadowWidth;

@property (nonatomic, assign) float vLineWidth;
@property (nonatomic, strong) UIColor *vLineColor;

@property (nonatomic, assign) float hLineWidth;
@property (nonatomic, strong) UIColor *hLineColor;

@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, strong) UIColor *borderColor_selected;

@property (nonatomic, assign) float borderWidth;
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, assign) float cornerRadius;

@end
