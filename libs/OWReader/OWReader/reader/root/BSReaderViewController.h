//
//  LogicBookRootViewController.h
//  LogicBook
//
//  Created by  iMac001 on 12-11-20.
//
//

#import <UIKit/UIKit.h>
#import <OWKit/OWViewController.h>
#import "LYBookHelper.h"
@class MyBook;

@interface BSReaderViewController : OWViewController
{    
    CGRect homeFrame, leftFrame, centerFrame, rightFrame;

    //从封面打开 / 从文字列表打开 模式
    BOOL    isCoverMode;
    
    UIView *rootView;
    
    CGPoint lastPoint;
}
- (void)openFromRect:(CGRect)rect cover:(UIImage *)img;
//从非封面模式打开
- (void)openWithNoneCover;


- (void)intoCatalogue;
- (void)intoContent;


- (void)quitReader;

@end
