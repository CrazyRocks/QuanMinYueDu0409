//
//  ContentManager.m
//  LogicBook
//
//  Created by iMac001 on 12-3-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LYBookRenderManager.h"
#import "GLLoading.h"
#import "BSCoreDataDelegate.h"
#import <OWCoreText/HTMLParser.h>
#import <OWCoreText/HTMLNode.h>
#import <OWCoreText/GLCTPageInfo.h>
#import "LYBookRenderManager+Async.h"
#import "SearchModel.h"
#import "ReadProessNetModel.h"
#import "JRReaderNotificationName.h"


@interface LYBookRenderManager()
{
    dispatch_queue_t queue;
}

-(void)calculatePageCount;

//根据页码决定是否释放某章节的布局资源
- (void)releaseLayouter:(NSInteger)pn;

@end

@implementation LYBookRenderManager

static LYBookRenderManager *instance;

@synthesize pageInfos, pageCount, currentCatalogue;
@synthesize catalogues, layouterDic;
@synthesize currentCatalogueNavIndex, isContentMode;
@synthesize pageSV;

- (id)init
{
    self = [super init];
    if (self) {
        queue = dispatch_queue_create("LYBook_Content_Manager_Queue", 0);
        pageInfos = [[NSMutableDictionary alloc] init];
        layouterDic = [[NSMutableDictionary alloc] init];
        
        pageCount = 0;
        isContentMode = NO;
        currentCatalogueNavIndex = -1;

    }
    return self;
}

-(void)reset
{
    [pageInfos removeAllObjects];
    [layouterDic removeAllObjects];

    pageCount = 0;
    isContentMode = NO;
    currentCatalogueNavIndex = -1;
    _catalogues = nil;
    pageSV = nil;
    [MyBooksManager sharedInstance].currentReadBook = nil;
}

+ (LYBookRenderManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LYBookRenderManager alloc] init];
    });
    return(instance);
}


- (NSString *)textRenderID
{
    _textRenderID = [NSString stringWithFormat:@"%@_%f", [LYBookSceneManager manager].fontName,
                     [LYBookSceneManager manager].fontSizeScale];
    return _textRenderID;
}

- (NSArray *)catalogues
{
    if (_catalogues == nil || _catalogues.count == 0) {
        _catalogues = [self getCatalogues];
    }
    return _catalogues;
};

- (void)parseCatalogue:(GLNoneParamBlock)block
{
    NSArray *cats = self.catalogues;
    if (cats && cats.count > 0) {
        if (block) block();
    }
    else {
        [self generateCatalogue:^{
            [[LYBookRenderManager sharedInstance] parseCatalogue:block];
        }];
    }
}

- (NSArray *)getCatalogues
{
    BSCoreDataDelegate *ad = [BSCoreDataDelegate sharedInstance];
    __block NSArray *fetchResults;
    [ad.parentMOC performBlockAndWait:^{
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"cID"
                                                                       ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookID=%@",[MyBooksManager sharedInstance].currentReadBook.bookID];
        fetchResults = [ad getCoreDataList:@"Catalogue"
                              byPredicate:predicate
                                     sort:sortDescriptors];
    }];
    return fetchResults;
}

-(OWCoreTextLayouter *)getLayouterFromTemp:(NSNumber *)index
{
    OWCoreTextLayouter *layouter = [layouterDic objectForKey:index];
    return layouter;
}

-(void)addLayouterToTemp:(OWCoreTextLayouter *)layouter :(NSNumber *)index
{
    if(layouter && index)
        [layouterDic setObject:layouter forKey:index]; 
    else {
//        NSLog(@"addLayouterToTemp---");
    }
}

//根据页码决定是否释放某章节的布局资源
- (void)releaseLayouter:(NSInteger)pn
{
    NSArray *keys = [layouterDic allKeys];
    for (id key in keys) {
        OWCoreTextLayouter *layouter = [layouterDic objectForKey:key];
        if (layouter) {
            if([layouter detectRelease:pn]) {
                [layouterDic removeObjectForKey:key];
                return;
            }
        }
    }
}

-(void)initCoreText
{
    OWCoreTextLayouter *layouter = [[OWCoreTextLayouter alloc] init ];
    [layouter initCSS];
}


- (NSInteger)currentPageNumber
{
    return _currentPageNumber;
}

- (void)drawPage:(PageViewController *)page byPageNumber:(uint)pageNum andCatelogue:(Catalogue *)cat
{
    OWCoreTextLayouter *layouter;
    layouter = [self getLayouterByCatalogue:cat];;
    
    [page setPageInfo:layouter :pageNum];
}

- (void)setCurrentPageNumber:(NSInteger)aCurrentPageNumber
{
    if(aCurrentPageNumber == _currentPageNumber ) {
      return;
    }
    
    dispatch_async(queue, ^{
        
        //根据页码决定是否释放某章节的布局资源
        [self releaseLayouter:aCurrentPageNumber];
        
        //渲染当前页，
        //这里只是提供渲染文本的参数，是否重绘文本由文本视图决定
        //计算当前章节（因为有可能是通过进度条直接跳转到某个章节，所以要每次计算）
        currentCatalogue = [self calculateCatalogue_by_PageNumber:aCurrentPageNumber];
        
        OWCoreTextLayouter *currentLayouter, *nextLayouter, *preLayouter;
        currentLayouter = [self getLayouterByCatalogue:currentCatalogue];
        
        NSInteger navIndex = [currentCatalogue.navIndex integerValue];
        NSString *renderID = [self textRenderID];
        NSInteger start = [currentCatalogue.startPages[renderID] integerValue];
        NSInteger end = start + [currentCatalogue.pageCounts[renderID] integerValue]-1;
        NSInteger prePage = aCurrentPageNumber -1;
        NSInteger nextPage = aCurrentPageNumber + 1;
        
        Catalogue *nextCat, *preCat;
        nextCat = preCat = currentCatalogue;
        
        //渲染下一页,必要时加载下一章节
        if(nextPage < pageCount) {
            if(nextPage > end){
                nextCat = self.catalogues[(navIndex + 1)];
            }
            nextLayouter = [self getLayouterByCatalogue:nextCat];
        };
        
        //渲染上一页,必要时加载上一章节
        if(prePage > 0) {
            if(prePage < start){
                preCat = self.catalogues[(navIndex -1)];
            }
            preLayouter = [self getLayouterByCatalogue:preCat];
        };
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [pageSV setUserInteractionEnabled:YES];
            [pageSV setPageCount:pageCount];
            [pageSV setPageDisplayed:aCurrentPageNumber];
            
#warning message 需要更改的地方
            
            [pageSV.currentPage setPageInfo:currentLayouter :aCurrentPageNumber];
            
            if(nextLayouter)
                [pageSV.nextPage setPageInfo:nextLayouter :nextPage];
            if(preLayouter)
                [pageSV.prePage setPageInfo:preLayouter :prePage];
            
            NSDictionary *info = @{@"pageNumber":[NSNumber numberWithInteger:aCurrentPageNumber]};
            [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_PAGENUM_CHANGED object:nil userInfo:info];
            _currentPageNumber = aCurrentPageNumber;
            
        });
        
        NSInteger position = ((GLCTPageInfo *)[currentLayouter getPageInfo:aCurrentPageNumber]).location;
        
        [[MyBooksManager sharedInstance] saveReadProgress:(float)_currentPageNumber/(float)pageCount cid:currentCatalogue.cID position:@(position)];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeCurrentPageNumber" object:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"The_synchronization_schedule" object:nil];
        
    });

}

-(void)intoPage:(NSInteger)pn
{
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeWordSize_GetScreen" object:nil];
    
    _currentPageNumber = 0; 
//    [pageSV.currentPage setPageInfo:nil :_currentPageNumber];
    [self setCurrentPageNumber:pn];
}

//第一次打开时，lastReadCID ＝＝ 0；
- (void)continueRead
{
    
    dispatch_async(queue, ^{
        NSInteger page = 1;
        currentCatalogue = nil;
        MyBook *book = [MyBooksManager sharedInstance].currentReadBook;
        for (Catalogue *item in self.catalogues) {
            if ([item.cID integerValue] == [book.lastReadCID integerValue]) {
                currentCatalogue = item;
                break;
            }
        }
        if (!currentCatalogue) {
            if (!self.catalogues || self.catalogues.count == 0) {
                return ;
            }
            else {
                currentCatalogue = self.catalogues[0];
            }
        }
        OWCoreTextLayouter *layouter = [self getLayouterByCatalogue:currentCatalogue];
        page = [layouter getPageNumberByPosition:[book.lastReadPosition integerValue]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[LYBookRenderManager sharedInstance] intoLayouter:layouter page:page];
        });
    });
}

- (void)intoLayouter:(OWCoreTextLayouter *)layouter page:(NSInteger)page
{
    MyBook *book = [MyBooksManager sharedInstance].currentReadBook;

    NSNumber *pc = book.pageCounts[self.textRenderID];
    
    if ( pc && [pc integerValue] > 0 ) {
        pageCount = [pc integerValue];
        
        [self intoPage:page];
    }
    else {
        
        //不存在时候需要先算当前章节
        [pageSV.currentPage setPageInfo:nil :0 ];
        
        
        [pageSV setPageCount:[layouter getPageCount]];
        [pageSV setPageDisplayed:page];
        
        
        [pageSV.currentPage setPageInfo:layouter :page ];
        
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeWordSize_GetScreen" object:nil];
        
        // 因为这个layouter是临时的，需要从缓存里移除
        if (currentCatalogue.navIndex) {
            
            [layouterDic removeObjectForKey:currentCatalogue.navIndex];
        }
        
        [self reRenderBook];
    }
}


- (void)changeFontStyle
{
    _currentPageNumber = 0;
    //置空当前的布局
    if (pageSV) {
        [pageSV.currentPage setPageInfo:nil :0];
        [pageSV.prePage setPageInfo:nil :0];
        [pageSV.nextPage setPageInfo:nil :0];
    }
    if (pageInfos) {
        [pageInfos removeAllObjects];
        [layouterDic removeAllObjects];
    }
    else {
        pageInfos = [[NSMutableDictionary alloc] init];
        layouterDic = [[NSMutableDictionary alloc] init];
    }
    [self continueRead];
}

//进入指定目录
//在没有解析完成内容之前，是不能打开目录的，so,不用检测是否解析完成
- (void)intoCatelogue:(Catalogue *)cat
{    
    currentCatalogue = cat;
    isContentMode = YES;
    
    _currentPageNumber = 0;
    [pageSV.currentPage setPageInfo:nil :_currentPageNumber];
    
    NSNumber *pageIndex = currentCatalogue.startPages[self.textRenderID];
    
    [self setCurrentPageNumber:[pageIndex integerValue]];
}


-(void)intoBookmark:(Bookmark *)bm
{
    _currentPageNumber = 0;
    [pageSV.currentPage setPageInfo:nil :_currentPageNumber];
    
    currentCatalogue = self.catalogues[[bm.catIndex integerValue] ];
    OWCoreTextLayouter *layouter = [self getLayouterByCatalogue:currentCatalogue];
    
    NSInteger page = [layouter getPageNumberByPosition:[bm.position integerValue]];
    
    [self setCurrentPageNumber:page];
}

-(void)intoBookDigest:(BookDigest *)bd
{
    _currentPageNumber = 0;
    [pageSV.currentPage setPageInfo:nil :_currentPageNumber];
    
    currentCatalogue = self.catalogues[[bd.catIndex integerValue] ];
    OWCoreTextLayouter *layouter = [self getLayouterByCatalogue:currentCatalogue];
    
    NSRange range = NSRangeFromString(bd.range);
    
    NSInteger tager = range.location;
    
    NSInteger page = [layouter getPageNumberByPosition:tager];
    
    [self setCurrentPageNumber:page];
}

-(void)intoBookSearch:(SearchModel *)model
{
    _currentPageNumber = 0;
    [pageSV.currentPage setPageInfo:nil :_currentPageNumber];
    
    currentCatalogue = self.catalogues[[model.navIndex integerValue]];
    OWCoreTextLayouter *layouter = [self getLayouterByCatalogue:currentCatalogue];
    
    NSInteger page = [layouter getPageNumberByPosition:model.location];
    
    [self setCurrentPageNumber:page];
}

-(void)intoBookLastReadWithReadNetModel:(ReadProessNetModel *)model
{
    _currentPageNumber = 0;
    [pageSV.currentPage setPageInfo:nil :_currentPageNumber];
    
    for (Catalogue *obj in self.catalogues) {
        if ([obj.cID integerValue] == [model.catIndex integerValue]) {
            currentCatalogue = obj;
        }
    }
    
    OWCoreTextLayouter *layouter = [self getLayouterByCatalogue:currentCatalogue];
    
    NSInteger page = [layouter getPageNumberByPosition:[model.pos integerValue]];
    
    [self setCurrentPageNumber:page];
}



- (OWCoreTextLayouter *)getLayouterByCatalogue:(Catalogue *)cat
{
    OWCoreTextLayouter *layouter = [self getLayouterFromTemp:cat.navIndex];
    if( !layouter) {
        layouter = [self generateLayouterByCat:cat];
        [self addLayouterToTemp:layouter :cat.navIndex];
    }
    return layouter;
}

- (OWCoreTextLayouter *)generateLayouterByCat:(Catalogue *)cat
{
    NSString *htmlContent;

    NSString *path = [[[BSCoreDataDelegate sharedInstance] cacheDocumentsDirectory] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"/%@/%@/%@", cat.bookID, [MyBooksManager sharedInstance].currentReadBook.opsPath, cat.filePath]];
    
//    NSString *html = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    NSString *html = [[MyBooksManager sharedInstance] decryptFile:path];

    HTMLParser *parser = [[HTMLParser alloc] initWithString:html error:Nil ];
    htmlContent = [[parser body] rawContents];
    if (!htmlContent) return nil;
    
    OWCoreTextLayouter *layouter;
    layouter = [[OWCoreTextLayouter alloc]init ];
    layouter.catName = cat.cName;
    layouter.navIndex = cat.navIndex;
    NSNumber *startPages = cat.startPages[[self textRenderID]];
    NSInteger page ;
    if (startPages) {
        page = [startPages integerValue];
    }
    else {
        page = 1;
    }
    //         NSLog(@"content:%@, %@",cat.mFSStartPage, cat.cName);
    [layouter initWithHTML:htmlContent
                     frame:[BSGlobalAttri sharedInstance].textRect
                 startPage:page
       attriStringTransfom:[LYBookSceneManager manager].htmlToAttriString];

    return layouter;
}

- (Catalogue *)calculateCatalogue_by_PageNumber:(NSInteger)pn
{
   return [self calculateCat:0 :(self.catalogues.count-1) :pn ];
}

- (Catalogue *)calculateCat:(NSInteger)lower :(NSInteger)upper :(NSInteger)pn
{
    NSInteger newUpper = lower + ceilf((upper-lower)/2.0f);
    NSString *renderID = [self textRenderID];
    Catalogue *c = self.catalogues[newUpper];
    NSInteger startPage = [c.startPages[renderID] integerValue];
    NSInteger endPage = startPage + [c.pageCounts[renderID] integerValue] - 1;
    if (startPage <= 0 && endPage <= 0) {
        return nil;
    }
    if (pn < startPage) {
       return [self calculateCat:lower :newUpper-1 :pn ];
    }
    else if (pn > endPage) {
        return [self calculateCat:newUpper+1 :upper :pn ];
    }
    return c;
}

#pragma mark 进度条代理

- (NSInteger)sliderMaxValue
{
    return pageCount;
}

- (NSInteger)sliderCurrentValue
{
    return _currentPageNumber;
}

- (NSString *)sliderCurrentTitle
{
    return currentCatalogue.cName;
}

- (NSString *)sliderGetTitleByCurrentValue:(NSInteger)cv
{
    Catalogue *c = [self calculateCatalogue_by_PageNumber:cv];
    return c.cName;
}

-(void)sliderValueChanged:(NSInteger)pageNum
{
    currentCatalogue = nil;
    [self intoPage:pageNum];
}


#pragma mark 搜索功能
-(NSMutableArray *)searchBaseStringInAllCatalogs:(NSString *)baseString
{
    NSMutableArray *searchs = [[NSMutableArray alloc]init];
    
    if (baseString == nil|| [baseString isEqualToString:@""]) {
        return nil;
    }
    
    NSString *currnetName = [LYBookSceneManager manager].fontName;
    float currentSize = [LYBookSceneManager manager].fontSizeScale;
    NSString *base = [NSString stringWithFormat:@"%@_%f",currnetName,currentSize];
    
    int page = 0;
    
    for (Catalogue *obj in self.catalogues) {
        
        int pagelenght = [[obj.pageCounts objectForKey:base] intValue];
        
        NSString *htmlContent;
        
        NSString *path = [[[BSCoreDataDelegate sharedInstance] cacheDocumentsDirectory] stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"/%@/%@/%@", obj.bookID, [MyBooksManager sharedInstance].currentReadBook.opsPath, obj.filePath]];
        
//        NSString *html = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
        NSString *html = [[MyBooksManager sharedInstance] decryptFile:path];

        HTMLParser *parser = [[HTMLParser alloc] initWithString:html error:Nil ];
        htmlContent = [[parser body] allContents];
        
        NSString *find = baseString;
        
        NSString * stringToFind = [NSRegularExpression escapedPatternForString:find];
        
        NSError* error = NULL;
        
        NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:stringToFind options:0 error:&error];
        
        NSArray* match = [reg matchesInString:htmlContent options: NSMatchingReportCompletion range:NSMakeRange(0, [htmlContent length])];
        
        if (match.count != 0)
        {
            
            for (NSTextCheckingResult *matc in match)
            {
                NSRange range = [matc range];
                
                SearchModel *model = [[SearchModel alloc]init];
                model.cName = obj.cName;
                model.navIndex = obj.navIndex;
                model.location = range.location;
                
                
                if (isPad) {
                    
                    if (range.location + range.length + 100 < [htmlContent length]) {
                        
                        model.baseString = [htmlContent substringWithRange:NSMakeRange(range.location, range.length + 100)];
                        
                    }else{
                        
                        model.baseString = [htmlContent substringWithRange:range];
                        
                    }
                    
                    model.searchString = baseString;
                    
                }else{
                    
                    if (range.location + range.length + 20 < [htmlContent length]) {
                        
                        model.baseString = [htmlContent substringWithRange:NSMakeRange(range.location, range.length + 20)];
                        
                    }else{
                        
                        model.baseString = [htmlContent substringWithRange:range];
                        
                    }
                    
                    model.searchString = baseString;
                }
                
                [searchs addObject:model];
                
            }  
        }
        
        page += pagelenght - 1;
        
    }
    
    return searchs;
}

#pragma mark 更新页码
-(void)updataPageNumber
{
//    dispatch_async(queue, ^{
//        NSInteger page = 1;
//        currentCatalogue = nil;
//        MyBook *book = [MyBooksManager sharedInstance].currentReadBook;
//        for (Catalogue *item in self.catalogues) {
//            if ([item.cID integerValue] == [book.lastReadCID integerValue]) {
//                currentCatalogue = item;
//                break;
//            }
//        }
//        if (!currentCatalogue) {
//            if (!self.catalogues || self.catalogues.count == 0) {
//                return ;
//            }
//            else {
//                currentCatalogue = self.catalogues[0];
//            }
//        }
//        OWCoreTextLayouter *layouter = [self getLayouterByCatalogue:currentCatalogue];
//        page = [layouter getPageNumberByPosition:[book.lastReadPosition integerValue]];
//        dispatch_async(dispatch_get_main_queue(), ^{
////            [[LYBookRenderManager sharedInstance] intoLayouter:layouter page:page];
//            
//            
//        });
//    });
}



@end
