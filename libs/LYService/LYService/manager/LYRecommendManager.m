//
//  RecommendManager.m
//  LongYuanYueDu
//
//  Created by  iMac001 on 12-10-19.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import "LYRecommendManager.h"
#import "LYArticleTableCellData.h"
#import "LYArticleSummary.h"
#import "LYUserEvent.h"
#import "LYUtilityManager.h"

@implementation LYRecommendManager


- (void)getRecommendList:(NSString *)cid
              pageIndex:(NSInteger)pageIndex
        successCallBack:(GLHttpRequstMultiResults)sCallBack
         failedCallBack:(GLHttpRequstFault)fCallBack
{
    [self cancelRequest];  
    
    __weak LYRecommendManager *weakSelf = self;
    
    completionBlock = ^(NSDictionary *result) {
        NSMutableArray *parsedResult = [[NSMutableArray alloc] init];
        NSMutableArray *arr = result[@"Data"];
        NSInteger pageCount = ceilf([result[@"ItemCount"] integerValue] / 30.0f);

        for (NSDictionary *dic in arr) {
            if (!dic || ![dic isKindOfClass:[NSDictionary class]])
                continue;
            LYArticleTableCellData *cellData = [LYRecommendManager parseArticleListItem:dic categoryID:cid];
            if (cellData != nil) {
                [parsedResult addObject:cellData];
            }
        }
        sCallBack(parsedResult,pageCount);

        //假如有更新，则清除旧数据
        if (pageIndex == 1 && parsedResult.count > 0) {
            [weakSelf saveArticleSummaryAsync:parsedResult categoryID:cid];
        }
    };
    
    faultBlock = ^(NSString *message) {
        if(fCallBack) fCallBack(message);
    };
 
    NSDictionary *params = @{@"categorycode":cid,
                             @"pagesize":@"30",
                             @"pageindex":[NSString stringWithFormat:@"%i",pageIndex],
                             @"itemcount":@(0)};

    httpRequest = [CommonNetworkingManager GET:LONGYUAN_ARTICLE_LIST_API parameters:params completeBlock:completionBlock faultBlock:faultBlock];
}

- (void)saveArticleSummaryAsync:(NSArray *)arr categoryID:(NSString *)cid
{
    [self DeleteLocalArticleList:cid];
    for (LYArticleTableCellData *cellData in arr) {
        [self SaveArticleSummary:cellData categoryID:cid];
    };
}

+ (LYArticleTableCellData *)parseArticleListItem:(NSDictionary *)dic categoryID:(NSString *)cid
{
    if (!dic[@"Title"])
        return nil;
    
    LYArticleTableCellData *article = [[LYArticleTableCellData alloc]init];
    article.categoryID = cid;
    article.titleID =  [dic objectForKey:@"ArticleID" ];
    article.title = [dic objectForKey:@"Title"];
    article.summary = dic[@"Summary"];
    if (article.summary) {
        article.summary  = [LYUtilityManager stringByTrimmingAllSpaces:article.summary];
    }

    article.author = [dic objectForKey:@"Author"];
    
    article.thumbnailWidth = 0;
    article.thumbnailHeight = 0;
    
    if ([dic[@"SmallImgName"] isKindOfClass:[NSString class]]) {
        article.thumbnailURL = dic[@"SmallImgName"];
    }
    if (!article.thumbnailURL && [dic[@"BigImgName"] isKindOfClass:[NSString class]]) {
        article.thumbnailURL = dic[@"BigImgName"];
    }
    
    //处理时间，便于数据按时间分组
    if (dic[@"UpdateDate"]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-ddTHH:mm:ss.S"];
        [formatter setLenient:YES];
        NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
        [formatter2 setDateFormat:@"yyyy年MM月dd日"];
        article.publishDate = [formatter dateFromString:[dic objectForKey:@"UpdateDate"]];
        article.publishDateSection = [formatter2 stringFromDate:article.publishDate];
    }

    return article;
}

//从本地数据库取得文章列表
- (void)getLocalRecommendList:(NSString *)cid
              successCallBack:(GLParamBlock)sCallBack
               failedCallBack:(GLHttpRequstFault)fCallBack
{
    
    NSPredicate *predicate = [self GetPredicate:cid];
    
    __block NSArray *fetchResults;
    [cdd.parentMOC performBlockAndWait:^{
        fetchResults =[cdd getCoreDataList:@"LYArticleSummary"
                                      byPredicate:predicate
                                             sort:nil];
    }];
    
    NSMutableArray *dataSource ;
    if(!fetchResults) {
        dataSource = nil;
    }
    else {
        dataSource = [[NSMutableArray alloc]init ];
        for (LYArticleSummary *item in fetchResults) {
            LYArticleTableCellData *article = [[LYArticleTableCellData alloc]init];
            //            article.categoryID = [item.categoryID copy];
            article.titleID = [item.articleID copy];
            article.categoryID = [item.categoryID copy];
            article.title = [item.title copy];
            article.author = [item.author copy];
            article.summary = [item.summary copy];
            article.publishDate = [item.publishDate copy];
            article.publishDateSection = [item.publishDateFormatString copy];
            
            article.thumbnailURL = [item.thumbnailURL copy];
            [dataSource addObject:article];
        }
    }
    sCallBack(dataSource);
}

//取得文章列表【推荐】本地最新的 时间
-(NSString *)getLatestDate:(NSString *)catID
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"publishDate" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    NSPredicate *predicate = [self GetPredicate:catID];
   
    NSArray *mutableFetchResults;
    mutableFetchResults =[cdd getCoreDataList:@"LYArticleSummary"
                                  byPredicate:predicate
                                         sort:sortDescriptors
                                   fetchLimit:1
                                  fetchOffset:0
                                      context:nil];
    
    NSString *result ;
    if(mutableFetchResults && mutableFetchResults.count > 0)
    {
        LYArticleSummary *art = mutableFetchResults[0];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        result = [formatter stringFromDate: art.publishDate] ;
    }
    return result;
}

//保存文章列表项
- (BOOL)SaveArticleSummary:(LYArticleTableCellData *)item categoryID:(NSString *)cid
{
    [cdd.parentMOC performBlockAndWait:^{
        LYArticleSummary *summary = [NSEntityDescription insertNewObjectForEntityForName:@"LYArticleSummary"
                                                                inManagedObjectContext:cdd.parentMOC];
        summary.categoryID = cid;
        summary.articleID = item.titleID;
        
        if ([item.thumbnailURL isKindOfClass:[NSString class]])
            summary.thumbnailURL = item.thumbnailURL;
        
        summary.title = item.title;
        summary.summary = item.summary;
       
        summary.publishDate = item.publishDate;
        summary.publishDateFormatString = item.publishDateSection;
        [cdd.parentMOC save:Nil];
    }];
   
    return YES;
    
}

//删除本地文章列表
- (void)DeleteLocalArticleList:(NSString *)categoryID
{
    [cdd.parentMOC performBlock:^{
        NSPredicate *predicate = [self GetPredicate:categoryID];
        [cdd deleteObjects:@"LYArticleSummary" predicate:predicate sort:nil fetchOffset:0 fetchLimit:0];
    }];
}

-(NSPredicate *)GetPredicate:(NSString *)categoryID
{
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"categoryID=%@",categoryID];
    return predicate;
}
@end
