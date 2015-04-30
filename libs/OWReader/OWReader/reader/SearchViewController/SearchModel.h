//
//  SearchModel.h
//  LYBookStore
//
//  Created by grenlight on 14/11/3.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchModel : NSObject

@property (nonatomic, retain) NSString *cName; //章节名称
@property (nonatomic, retain) NSNumber *pageIndex; //章节中的页数
@property (nonatomic, retain) NSString *baseString; //搜索结果的字符串
@property (nonatomic, retain) NSNumber * navIndex;
@property (nonatomic, strong) NSNumber *catIndex;
@property (nonatomic, assign) NSInteger location;
@property (nonatomic, retain) NSString *searchString;


@end
