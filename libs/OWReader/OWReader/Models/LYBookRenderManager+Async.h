//
//  afdaafda.h
//  LYBookStore
//
//  Created by grenlight on 14/7/25.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYBookRenderManager.h"
#import "LYBookCatalogueParser.h"

@interface LYBookRenderManager(Async)
//重新计算整本书
- (void)reRenderBook;

/*
 调整字号字体后，重新计算当前页
 1，先重新计算整个章节的layouter
 2,从上次阅读的位置计算要呈现的新的页
 */
- (OWCoreTextLayouter *)reRenderCurrentPage;

-(void)generateCatalogue:(GLNoneParamBlock)block;

@end
