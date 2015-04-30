//
//  LYMagReaderViewController.h
//  LYMagazinesStand
//
//  Created by grenlight on 14-5-19.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import <OWKit/OWKit.h>

@interface LYMagReaderViewController : XibAdaptToScreenController
{
    CGRect homeFrame, leftFrame, centerFrame, rightFrame;

    //从封面打开 / 从文字列表打开 模式
    BOOL    isCoverMode;
}

- (void)openFromRect:(CGRect)rect cover:(UIImage *)img;
//从非封面模式打开
- (void)openWithNoneCover;

- (void)intoCatalogue;
- (void)intoContent;

- (void)quitReader;
@end
