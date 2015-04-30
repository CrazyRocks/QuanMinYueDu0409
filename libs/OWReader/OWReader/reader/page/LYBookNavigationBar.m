//
//  LYBookNavigationBar.m
//  LYBookStore
//
//  Created by grenlight on 14/7/19.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "LYBookNavigationBar.h"
//#import "GLNotificationName.h"

#import "JRReaderNotificationName.h"

#import "LYBookSceneManager.h"
#import "LYBookHelper.h"

@implementation LYBookNavigationBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self registerNotifi];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self registerNotifi];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)registerNotifi
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSceneMode) name:BOOK_SCENE_CHANGED object:nil];
}

- (UIStyleObject *)getStyle
{
    return [[LYBookSceneManager manager].styleManager getStyle:@"顶部导航栏"];
}

- (void)changeSceneMode
{
    [self updateStyle];
}

@end
