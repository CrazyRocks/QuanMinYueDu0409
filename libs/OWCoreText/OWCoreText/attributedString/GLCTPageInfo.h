//
//  GLCTPageInfo.h
//
//  Created by  oowwww on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLCTPageInfo : NSObject
@property(nonatomic, strong)NSArray *lines;
//章节中的位置
@property(nonatomic,assign)NSInteger location;
@property(nonatomic,assign)NSInteger lenght;
@property(nonatomic,assign)NSInteger pageNumber;
@property(nonatomic, strong)NSString *description;
//@property(nonatomic,assign)BOOL isImage;
@property(nonatomic, strong)NSString *imagePath;
@property(nonatomic, strong)NSNumber *catIndex;
//是否加书签
@property(nonatomic,assign)BOOL isBookmark;

@end
