//
//  GLRoundButton.m
//  LogicBook
//
//  Created by  on 12-2-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GLRoundButton.h"
#import "BSGlobalAttri.h"
#import <OWKit/OWKit.h>
#import <LYService/LYGlobalConfig.h>

@interface GLRoundButton()
-(void)setBorderColor:(long)color radius:(float)radius;
@end

@implementation GLRoundButton

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){

    }
    return self;
}
-(id)initWithFrame:(CGRect)frame title:(NSString *)title borderColor:(long)color radius:(float)radius{
    self =[super initWithFrame:frame];
    if (self) {

        [self setTitle:title borderColor:color radius:radius];

    }
    return self;
}
- (void)layoutSubviews{
    
}

-(void)setTitle:(NSString *)title borderColor:(long)color radius:(float)radius{
    CGRect labelFrame = CGRectZero;
    labelFrame.size = self.frame.size;
    titleLB = [[UILabel alloc]initWithFrame:labelFrame];
    titleLB.backgroundColor = [UIColor clearColor];
    titleLB.textColor = [OWColor colorWithHex:0x666354];
    UIFont *font = [UIFont fontWithName:[BSGlobalAttri sharedInstance].lyFont size:14];
    
    [titleLB setFont:font];
    titleLB.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLB];
    [titleLB setText:title];

    [self setBorderColor:color radius:radius];
}

-(void)setImage:(NSString *)image borderColor:(long)color radius:(float)radius
{
    NSString *path = [[NSBundle mainBundle] pathForResource:image ofType:@"png"]; 
    UIImage *img = [UIImage imageWithContentsOfFile:path];
    UIImageView *imgV = [[UIImageView alloc]initWithImage:img];
    [imgV setCenter:CGPointMake(CGRectGetWidth(self.frame)/2.0, 
                                CGRectGetHeight(self.frame)/2.0)];
    [self addSubview:imgV];
    [self setBorderColor:color radius:radius];
}

-(void)setBorderColor:(long)color radius:(float)radius
{
    CALayer *layer = self.layer;
    layer.masksToBounds = YES;
    layer.cornerRadius = radius;
    layer.borderColor = [OWColor colorWithHex:color].CGColor;
    layer.borderWidth = 1.0;
}
- (void)setNormalColor:(UIColor *)nc touchedColor:(UIColor *)tc{
    normalColor = nc;
    touchedColor = tc;
    [self normalState];
}
- (void)normalState{
    self.backgroundColor = normalColor;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    self.backgroundColor = touchedColor;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [delegate glRoundButtonTapped:self];
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    self.backgroundColor = normalColor;
}

@end
