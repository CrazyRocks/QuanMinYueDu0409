//
//  OWBookButton.m
//  LYBookStore
//
//  Created by grenlight on 14/7/19.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "OWBookButton.h"
#import "LYBookSceneManager.h"
#import <OWKit/OWKit.h> 
//#import "GLNotificationName.h"
#import "JRReaderNotificationName.h"
#import "LYBookSceneManager.h"
//#import "GLNotificationName.h"

@implementation OWBookButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sceneChanged) name:BOOK_SCENE_CHANGED object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setIcon:(NSString *)iconName
{
    imageName = iconName;
    [self updateIconImage];
}

- (void)sceneChanged
{
    __weak typeof (self) weakSelf = self;
    [OWAnimator basicAnimate:self toScale:CGPointZero duration:0.2f delay:0 completion:^{
        [weakSelf updateIconImage];
    }];
}

- (void)updateIconImage
{
    NSBundle *bundle = [LYBookSceneManager manager].assetsBundle;
    NSString *normal = [bundle pathForResource:[NSString stringWithFormat:@"%@_normal@2x",imageName] ofType:@"png"];
    if (normal) {
        [self setImage:[UIImage imageWithContentsOfFile:normal] forState:UIControlStateNormal];
    }
    
    NSString *selected = [bundle pathForResource:[NSString stringWithFormat:@"%@_selected@2x",imageName] ofType:@"png"];
    if (selected) {
        [self setImage:[UIImage imageWithContentsOfFile:selected] forState:UIControlStateHighlighted];
        [self setImage:[UIImage imageWithContentsOfFile:selected] forState:UIControlStateSelected];
    }

    [OWAnimator spring:self toScale:CGPointMake(1, 1) delay:0];
}

@end
