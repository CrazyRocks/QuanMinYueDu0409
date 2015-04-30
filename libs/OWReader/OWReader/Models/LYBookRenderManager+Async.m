//
//  afdaafda.m
//  LYBookStore
//
//  Created by grenlight on 14/7/25.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "LYBookRenderManager+Async.h"
#import "LYBookSceneManager.h"
#import <OWCoreText/HTMLParser.h>
#import <OWCoreText/HTMLNode.h>
#import <OWCoreText/GLCTPageInfo.h>

#import "NetworkSynchronizationForBook.h"

#import "JRReaderNotificationName.h"

@implementation LYBookRenderManager(Async)


- (OWCoreTextLayouter *)reRenderCurrentPage
{
    __weak typeof (self) weakSelf = self;
    OWCoreTextLayouter *layouter = [weakSelf generateLayouterByCat:weakSelf.currentCatalogue];
    [weakSelf cleanAllLayouter];
    NSInteger page = [layouter getPageNumberByPosition:[[MyBooksManager sharedInstance].currentReadBook.lastReadPosition integerValue]];

    [weakSelf.pageSV.currentPage setPageInfo:layouter :page];
    
#pragma mark 重载当前页刷新摘要
    
    [weakSelf.pageSV.currentPage clearPageChooseLines];
    
    
    return layouter;
//
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
//    dispatch_async(queue, ^{
//        OWCoreTextLayouter *layouter = [weakSelf generateLayouterByCat:weakSelf.currentCatelogue];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [weakSelf cleanAllLayouter];
//            [weakSelf.pageSV.currentPage setPageInfo:currentLayouter :aCurrentPageNumber];
//
//        });
//    });
 
}

- (void)reRenderBook
{
    
    [NetworkSynchronizationForBook manager].isCalculation = YES;
    
    MyBook *book = [MyBooksManager sharedInstance].currentReadBook;
    
    
    if (book.pageCounts[self.textRenderID]) {
        self.pageCount = [book.pageCounts[self.textRenderID] integerValue];
        [self refreshCurrentPage];
        return;
    }
    
    
#warning message 当前视图是否接受手势
    self.pageSV.userInteractionEnabled = NO;

    [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_PARSER_BEGAIN object:nil];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        __block NSInteger startPage = 1;

        NSArray *fetchResults = [LYBookRenderManager sharedInstance].catalogues;
        for (NSInteger i = 0 ;i < fetchResults.count; i++) {
            Catalogue *cat = fetchResults[i];
//            NSLog(@"cat:%@",cat.cName);

            //是否有子目录，
            if (i+1 < fetchResults.count) {
                Catalogue *nextCat = fetchResults[i+1];
                if([nextCat.depth integerValue] > [cat.depth integerValue]){
                    [self saveCatalogue:cat startPage:startPage pageCount:0];
                    continue;
                }
            }
            //此处计算出来的是下一章的起始页码
            OWCoreTextLayouter *layouter = [self generateLayouterByCat:cat];
            
            if (layouter) {
                NSInteger pageCount = [layouter getPageCount];
                [self saveCatalogue:cat startPage:startPage pageCount:pageCount];
                
                startPage += pageCount;
            }
            NSDictionary *info = @{@"progress":@((float)i/(float)fetchResults.count)};
            [[NSNotificationCenter defaultCenter]
             postNotificationName:BOOK_PARSER_PROGRESS object:nil userInfo:info];
        }
        self.pageCount = startPage - 1;
        
        BSCoreDataDelegate  *cdd = [BSCoreDataDelegate sharedInstance];
        [cdd.parentMOC performBlockAndWait:^{

            MyBook *book  = [MyBooksManager sharedInstance].currentReadBook;
            NSMutableDictionary *pageCounts;
            if (!book.pageCounts) {
                pageCounts = [[NSMutableDictionary alloc] init];
            }
            else {
                pageCounts = [NSMutableDictionary dictionaryWithDictionary: book.pageCounts];
            }
            [pageCounts setValue:@(startPage-1) forKey:self.textRenderID];
            book.pageCounts = pageCounts ;

            [cdd.parentMOC save:nil];
        }];
        
        //更新列表数据，避免再次进入时重算页码
        [[MyBooksManager sharedInstance] allMyBooks];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_PARSER_COMPLETE object:nil];
            
//            self.pageSV.userInteractionEnabled = YES;
//            
//            if ([[MyBooksManager sharedInstance].currentReadBook.lastReadCID intValue] == 0) {
//                [self refreshCurrentPage];
//            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"changeShowAnimation_YES" object:nil];
            
            [self refreshCurrentPage];
            
        });
    });
}




- (void)refreshCurrentPage
{
    self.pageSV.userInteractionEnabled = YES;
    [self continueRead];
}

- (void)saveCatalogue:(Catalogue *)cat startPage:(NSInteger)startPage pageCount:(NSInteger)pageCount
{
    [[BSCoreDataDelegate sharedInstance].parentMOC performBlockAndWait:^{

        NSMutableDictionary *stp, *pcs;
        if (!cat.startPages) {
            stp = [[NSMutableDictionary alloc] init];
            pcs = [[NSMutableDictionary alloc] init];
        }
        else {
            stp = [NSMutableDictionary dictionaryWithDictionary:cat.startPages];
            pcs = [NSMutableDictionary dictionaryWithDictionary:cat.pageCounts];
        }
        [stp setValue:@(startPage) forKey:self.textRenderID];
        cat.startPages = stp ;
        [pcs setValue:@(pageCount) forKey:self.textRenderID];
        cat.pageCounts = pcs  ;

    }];
}

- (void)generateCatalogue:(GLNoneParamBlock)block
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(queue, ^{
        //解析目录
        LYBookCatalogueParser * cc = [[LYBookCatalogueParser alloc] init];
        [cc parse];

        dispatch_async(dispatch_get_main_queue(), ^{
            if(block) block();
        });
    });
}

//置空当前的布局
- (void)cleanAllLayouter
{
    _currentPageNumber = 0;
    if (self.pageSV) {
        [self.pageSV.currentPage setPageInfo:nil :0];
        [self.pageSV.prePage setPageInfo:nil :0];
        [self.pageSV.nextPage setPageInfo:nil :0];
    }
    if (self.pageInfos) {
        [self.pageInfos removeAllObjects];
        [self.layouterDic removeAllObjects];
    }
    else {
        self.pageInfos = [[NSMutableDictionary alloc] init];
        self.layouterDic = [[NSMutableDictionary alloc] init];
    }
}
@end
