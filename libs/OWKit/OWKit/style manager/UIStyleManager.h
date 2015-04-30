//
//  UIStyleManager.h
//  PublicLibrary
//
//  Created by grenlight on 14-1-13.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIStyleObject.h"
#import "OWControlCSS.h"

@interface UIStyleManager : NSObject
{
    NSMutableDictionary *styleDictionary;
}
+ (UIStyleManager *)sharedInstance;

//是否已经加载了样式文件
- (BOOL)styleFileLoadedAlready;

- (void)parseStyleFile:(NSString *)fileName;
- (void)parseStyleFile:(NSString *)fileName inBundle:(NSBundle *)bundle;

- (UIStyleObject *)getStyle:(NSString *)styleName;
@end
