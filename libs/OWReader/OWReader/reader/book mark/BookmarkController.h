//
//  BookmarkController.h
//  LogicBook
//
//  Created by iMac001 on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GLCTPageInfo;

@interface BookmarkController : UIViewController
{
    BOOL _isMarked;
}
- (void)movingView:(float)offsetY;
- (void)goHome;

- (void)setPageInfo:(GLCTPageInfo *)bl catalogue:(NSString *)cat catIndex:(NSNumber *)cid ;
//是否已经被加为书签
- (void)isMarked:(BOOL)bl;

@end
