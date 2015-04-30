//
//  GLConfig.h
//  GLConfiguration
//
//  Created by iMac001 on 12-3-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


//书名
#define BOOK_NAME @"朱厚泽文存"
//作者
#define AUTHOR @"朱厚泽"
#define WRITE_ATTRIBUTE @"著"
//导航文件名
#define navFileName @"toc.ncx"

//封面上不适合显示超过6个字的书名
//#define BOOK_NAME_FOR_COVER @"女少年"
#define BOOK_NAME_FOR_COVER BOOK_NAME





@interface BSConfig : NSObject

//目录是否采用层级样式
@property(nonatomic,assign)BOOL isHierarchyStyle;

+(BSConfig *)sharedInstance;

@end
