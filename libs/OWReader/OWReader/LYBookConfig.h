//
//  LYBookConfig.h
//  LYBookStore
//
//  Created by grenlight on 14-5-9.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    lyNormalMode,
    lyBorrowMode,//借阅模式
    lyStoreMode //书店模式，可进书库下载图书
}LYBookShelfMode;

@interface LYBookConfig : NSObject

@property (nonatomic, assign) LYBookShelfMode bookShelfMode;

//主要用于识别用户是用的app扫描的图书二维码
@property (nonatomic, assign) NSString        *appCompany;

@property (nonatomic, strong) NSArray         *bookCategories;

+ (LYBookConfig *)sharedInstance;

@end
