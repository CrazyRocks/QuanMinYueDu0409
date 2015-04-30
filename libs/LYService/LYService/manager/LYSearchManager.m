//
//  SearchManager.m
//  LongYuanYueDu
//
//  Created by  iMac001 on 12-10-26.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import "LYSearchManager.h"
#import "LYRecommendManager.h"
#import "LYArticleTableCellData.h"
#import "LYMagazineSearchCellData.h"

@implementation LYSearchManager

-(AFHTTPRequestOperation *)searchArticlesByTitle:(NSString *)keywords
                   pageIndex:(NSInteger)pageindex
                                   countCallBack:(GLHttpRequstResult)countCallBack
             successCallBack:(GLHttpRequstMultiResults)sCallBack
              failedCallBack:(GLHttpRequstFault)fCallBack
{
    //搜索中文AF将自动编码
    NSDictionary *params =@{@"keyword":keywords,
                            @"categorycode":@"",
                            @"pageindex":@(pageindex),
                            @"pagesize":@"40",
                            @"itemcount":@(0)};
    
    return [CommonNetworkingManager GET:LONGYUAN_ARTICLESEARCH_API parameters:params completeBlock:^(NSDictionary *result){
        NSNumber *count = result[@"ItemCount"];
        countCallBack(count);
        NSInteger pageCount = ceilf([count integerValue] / 40.0f);
       
        NSMutableArray *parsedResult = [[NSMutableArray alloc] init];
        if (count.integerValue > 0) {
            NSArray *arr = result[@"Data"];
            for (NSDictionary *dic in arr) {
                LYArticleTableCellData *cellData = [LYSearchManager parseArticleListItem:dic];
                [parsedResult addObject:cellData];
            }
        }
        sCallBack(parsedResult, pageCount>0 ? pageCount : 1);
    } faultBlock:^(NSString *message){
        if(fCallBack) fCallBack(message);
    }];
    
}

-(AFHTTPRequestOperation *)searchMagazineByName:(NSString *)keywords
                                      pageIndex:(NSInteger)pageindex
                                  countCallBack:(GLHttpRequstResult)countCallBack
                                successCallBack:(GLHttpRequstMultiResults)sCallBack
                                 failedCallBack:(GLHttpRequstFault)fCallBack
{
    //搜索中文AF将自动编码
   
    NSDictionary *params = @{@"keyword":keywords, @"magazinetype":@(2),
                             @"pageindex":@"1", @"pagesize":@"30", @"itemcount":@(0)};

    return [CommonNetworkingManager GET:LONGYUAN_MAGAZINESEARCH_API parameters:params completeBlock:^(NSDictionary *result){
        //        NSLog(@"SearchResult:%@",result);
        countCallBack(result[@"ItemCount"]);
        NSInteger pageCount = ceilf([result[@"ItemCount"] integerValue] / 30.0f);

        NSMutableArray *parsedResult = [[NSMutableArray alloc] init];
        NSArray *arr = [result objectForKey:@"Data"];
        
        for (NSDictionary *info in arr) {
            LYMagazineSearchCellData *summary = [[LYMagazineSearchCellData alloc] init];
            summary.magName = info[@"MagazineName"];
            summary.issue = info[@"Issue"];
            summary.year = info[@"Year"];
            summary.magGUID  = info[@"MagazineGuid"];
            
            NSArray *covers = info[@"CoverImages"];
            if (covers && covers.count > 0) {
                summary.cover = covers.count > 1 ? covers[1] :covers[0];
            }
            
            summary.textRect = CGRectMake(20, 0, appWidth-40, 100);
            
            [parsedResult addObject:summary];
        }
        sCallBack(parsedResult, pageCount);
    } faultBlock:fCallBack];
    
}

- (AFHTTPRequestOperation *)searchBook:(NSString *)keywords
                             pageIndex:(NSInteger)pageindex
                         countCallBack:(GLHttpRequstResult)countCallBack
                       successCallBack:(GLHttpRequstMultiResults)sCallBack
                        failedCallBack:(GLHttpRequstFault)fCallBack
{
    NSDictionary *params = @{@"keyword":keywords, @"booktype":@(5),
                             @"pageindex":@"1", @"pagesize":@"30", @"itemcount":@(0)};
    
    AFHTTPRequestOperation *operation = [CommonNetworkingManager GET:LONGYUAN_BOOKSEARCH_API parameters:params completeBlock:^(NSDictionary *result){
        countCallBack(result[@"ItemCount"]);
        NSInteger pageCount = ceilf([result[@"ItemCount"] integerValue] / 30.0f);
        sCallBack(result[@"Data"], pageCount);
    } faultBlock:fCallBack];
    
    return operation;
}

- (void)getKeys:(GLParamBlock)sCallBack failedCallBack:(GLHttpRequstFault)fCallBack
{
    [self cancelRequest];

    NSString *url = [NSString stringWithFormat:@"%@/GetHotWords.ashx?",LONGYUAN_DOMAIN];
    completionBlock = ^(NSDictionary *result){
        sCallBack(result[@"HotWords"]);
    };
    
    faultBlock = ^(NSString *message){
        if(fCallBack) fCallBack(message);
    };
     httpRequest = [CommonNetworkingManager GET:url parameters:nil completeBlock:completionBlock faultBlock:faultBlock];
}

+ (LYArticleTableCellData *)parseArticleListItem:(NSDictionary *)dic
{
    LYArticleTableCellData *article = [LYRecommendManager parseArticleListItem:dic categoryID:@""];

    return article;
}

@end
