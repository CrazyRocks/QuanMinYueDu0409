//
//  MagazineManager.m
//  LongYuanYueDu
//
//  Created by  iMac001 on 12-10-17.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import "LYMagazineManager.h"
#import "LYMagCatelogueTableCellData.h"
#import "LYMagazineItem.h"
#import "LYMagazineTableCellData.h"
#import <OWKit/OWKit.h> 
#import "LYUtilityManager.h"

@implementation LYMagazineManager


//订阅列表
-(void)getSubscriptionList:(GLHttpRequstMultiResults)sCallBack
            failedCallBack:(GLHttpRequstFault)fCallBack
{
    [self cancelRequest];
    __unsafe_unretained LYMagazineManager *weakSelf = self;
    
    completionBlock = ^(NSDictionary *result){
        //        NSLog(@"magazine GetOrderList: %@",result);
        [weakSelf excuteCompletionBlock:sCallBack byResult:result];
    };
    
    faultBlock = ^(NSString *message) {
        if(fCallBack) fCallBack(message);
    };
    httpRequest = [CommonNetworkingManager GET:LONGYUAN_ORDER_LIST_API parameters:nil completeBlock:completionBlock faultBlock:faultBlock];

}

- (NSArray *)excuteCompletionBlock:(GLHttpRequstMultiResults)block
                     byResult:(NSDictionary *)result
{
    NSMutableArray *results = [[NSMutableArray alloc] init];
    NSArray *arr = result[@"Data"];

    if (arr && [arr isKindOfClass:[NSArray class]]) {
        for (NSDictionary *info in arr) {
            [results addObject:[LYMagazineManager parseMagazineTableCellData:info]];
        }
    }
    
    NSInteger pageCount = 1;
    if (result[@"ItemCount"])
        pageCount = ceilf([result[@"ItemCount"] integerValue] / 30.0f);
    
    if (block) block(results, pageCount);
    
    return results;
}

//杂志列表
-(void)getMagazineList:(NSInteger)pageIndex
            byCategory:(NSString *)cid
       successCallBack:(GLHttpRequstMultiResults)sCallBack
        failedCallBack:(GLHttpRequstFault)fCallBack
{
    [self cancelRequest];

    __unsafe_unretained LYMagazineManager *weakSelf = self;
    completionBlock = ^(NSDictionary *result) {

        //保存第一页数据
        if (pageIndex == 1) {
            NSString *fileName = [NSString stringWithFormat:@"Mag_%@.plist", cid];
            [weakSelf saveData:result tofile:fileName];
        }
        
        [weakSelf excuteCompletionBlock:sCallBack byResult:result];
    };
    faultBlock = ^(NSString *message) {

        if(fCallBack) fCallBack(message);
    };
    
    NSDictionary *param = @{@"categorycode":cid, @"pageindex":@(pageIndex),
                            @"pagesize":@"30", @"itemcount":@(0), @"magazinetype":@(2)};
    
   httpRequest = [CommonNetworkingManager GET:LONGYUAN_MAGAZINE_LIST_API parameters:param completeBlock:completionBlock faultBlock:faultBlock];
}

#pragma mark 存取本地数据
- (void)saveData:(NSDictionary *)result tofile:(NSString *)file
{
    NSString *bundlePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [bundlePath stringByAppendingPathComponent:file];
    
    NSMutableDictionary *newResult = [NSMutableDictionary new];
    
    for (NSString *key in result) {
        if ([key isEqualToString:@"Data"]) {
            NSArray *arr = result[@"Data"];
            NSMutableArray *newArray = [NSMutableArray new];
            for (NSDictionary *item in arr) {
                NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
                for (NSString *key in item) {
                    id value = item[key];
                    if (value) {
                        if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
                            [info setObject:value forKey:key];
                        }
                        else if ([value isKindOfClass:[NSArray class]]) {
                            [info setObject:value forKey:key];
                        }
                    }
                }
                [newArray addObject:info];
            }
            [newResult setObject:newArray forKey:@"Data"];
        }
        else {
            id value = result[key];
            if (value) {
                if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
                    [newResult setObject:value forKey:key];
                }
            }
        }
    }
    
    NSURL *url = [NSURL fileURLWithPath:filePath];
    [newResult writeToURL:url atomically:YES];
}

- (NSDictionary *)getDataByFileName:(NSString *)file
{
    NSString *bundlePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [bundlePath stringByAppendingPathComponent:file];
    return [NSDictionary dictionaryWithContentsOfFile:filePath];
}


-(AFHTTPRequestOperation *)reqestArticleDetail:(LYMagCatelogueTableCellData *)magCell
                               successCallBack:(GLHttpRequstResult)sCallBack
                                failedCallBack:(GLHttpRequstFault)fCallBack
{
    return [CommonNetworkingManager GET:MAGAZINE_ARTICLE_DETAIL_API parameters:@{@"articleid":magCell.titleID} completeBlock:^(NSDictionary *result) {
        
    } faultBlock:^(NSString *msg) {
        
    }];
}

- (void)getLocalMagazineList:(NSString *)category completion:(GLHttpRequstMultiResults)sCallBack
{
    NSString *fileName = [NSString stringWithFormat:@"Mag_%@.plist", category];
    NSDictionary *result = [self getDataByFileName:fileName];
    [self excuteCompletionBlock:sCallBack byResult:result];
}


-(void)getMagazineCatelogue:(void(^)(NSArray *,LYMagazineInfo *))sCallBack
                      fault:(GLHttpRequstFault)fCallBack
{
    [self cancelRequest];
    LYMagazineTableCellData *mag = [[CommonNetworkingManager sharedInstance] currentMagazine];
    httpRequest = [self getMagazineCatelogue:mag completion:sCallBack fault:fCallBack];
}

- (AFHTTPRequestOperation *)getMagazineCatelogue:(LYMagazineTableCellData *)mag
                  completion:(void(^)(NSArray *,LYMagazineInfo *))sCallBack
                       fault:(GLHttpRequstFault)fCallBack
{
    __unsafe_unretained LYMagazineManager *weakSelf = self;
    completionBlock = ^(NSDictionary *result) {
        //        NSLog(@"getMagazineCatelogue:%@",result);
        LYMagazineInfo *magInfo = [[LYMagazineInfo alloc] init];
        
        magInfo.magazineName = mag.magName;
        magInfo.coverURL = mag.cover;
        
        magInfo.year = mag.year;
        magInfo.issue = mag.issue;
        magInfo.magGUID = mag.magGUID;
        magInfo.cycle = mag.cycle;
        magInfo.FormattedIssue = [NSString stringWithFormat:@"%@年第%@期", magInfo.year, magInfo.issue];
        
        NSMutableArray *parsedResult = [[NSMutableArray alloc] init];
        NSArray *arr = result[@"Data"];
        for(NSDictionary *dic in arr) {
            for (NSDictionary *item in dic[@"Articles"]) {
                LYMagCatelogueTableCellData *cellData = [weakSelf parseArticleListItem:item column:dic[@"Column"]];
                if (cellData)
                    [parsedResult addObject:cellData];
            }
        }
        if (sCallBack) sCallBack(parsedResult, magInfo);
    };
    
    faultBlock = ^(NSString *message) {
        if (fCallBack) fCallBack(message);
    };
    
    NSDictionary *params =   @{@"magazineguid":mag.magGUID,
                               @"year":mag.year,
                               @"issue":mag.issue};
    
    return [CommonNetworkingManager GET:LONGYUAN_MAGAZINE_CATELOGUE_API parameters:params completeBlock:completionBlock faultBlock:faultBlock];
}

- (AFHTTPRequestOperation *)getCatelogue:(LYMagazineInfo *)mag
                              completion:(GLHttpRequstResult)sCallBack
                                   fault:(GLHttpRequstFault)fCallBack
{
    NSDictionary *params =   @{@"magazineguid":mag.magGUID,
                               @"year":mag.year,
                               @"issue":mag.issue};
    __unsafe_unretained LYMagazineManager *weakSelf = self;

    return [CommonNetworkingManager GET:LONGYUAN_MAGAZINE_CATELOGUE_API parameters:params completeBlock:^(NSDictionary *result){
        NSMutableArray *parsedResult = [[NSMutableArray alloc] init];
        NSArray *arr = result[@"Data"];
        for(NSDictionary *dic in arr) {
            for (NSDictionary *item in dic[@"Articles"]) {
                LYMagCatelogueTableCellData *cellData = [weakSelf parseArticleListItem:item column:dic[@"Column"]];
                if (cellData)
                    [parsedResult addObject:cellData];
            }
        }
        sCallBack(parsedResult);
    } faultBlock:faultBlock];
}

-(LYMagCatelogueTableCellData *)parseArticleListItem:(NSDictionary *)dic column:(NSString *)column
{
    if (!dic[@"Title"])
        return nil;
    
    LYMagCatelogueTableCellData *article = [[LYMagCatelogueTableCellData alloc]init];
    article.categoryID = @"";
    article.titleID =  dic[@"ArticleID" ];
    article.title = dic[@"Title"];
    article.summary = dic[@"Summary"];
    if (article.summary) {
        article.summary  = [LYUtilityManager stringByTrimmingAllSpaces:article.summary];
    }
    
    article.thumbnailURL = [dic objectForKey:@"FirstImg"];
    if (article.thumbnailURL) {
        NSArray *arr = [article.thumbnailURL componentsSeparatedByString:@"."];
        NSString *suffix = [arr.lastObject lowercaseString];
        if(![suffix isEqual:@"jpg"] &&  ![suffix isEqual:@"jpeg"] && ![suffix isEqual:@"png"] && ![suffix isEqual:@"gif"]) {
            article.thumbnailURL = nil;
        }
    }
    article.magGUID = [CommonNetworkingManager sharedInstance].currentMagazine.magGUID;
    article.magazineIcon = [CommonNetworkingManager sharedInstance].currentMagazine.magIconURL;
    article.magName = [CommonNetworkingManager sharedInstance].currentMagazine.magName;
   
    article.sectionName = column;
    
    return article;
}


//保存杂志项
+ (LYMagazineTableCellData *)parseMagazineTableCellData:(NSDictionary *)info
{
    LYMagazineTableCellData *summary;
    summary = [[LYMagazineTableCellData alloc] init];
    
    summary.magName = info[@"MagazineName"];
    summary.issue = [info[@"Issue"] stringValue];
    summary.year = [info[@"Year"] stringValue];
    summary.magGUID  = info[@"MagazineGuid"];
    if (info[@"ID"]) {
        summary.concernID = info[@"ID"];
    }
    NSArray *covers = info[@"CoverImages"];
    if (covers && covers.count > 0) {
        summary.cover = covers.count > 1 ? covers[1] : covers[0];
    }
    
    return summary;
}

#pragma mark 关注期刊
+ (void)focusMagazine:(LYMagazineTableCellData *)cellData bySender:(OWButton *)sender
{
    [sender setEnabled:NO];

    [self focusMagazine:cellData
             completion:^{
                 [sender setTitle:@"已关注"];
                 [[OWSlideMessageViewController sharedInstance] showMessage:@"关注成功" autoClose:YES];
             } fault:^{
                 [sender setEnabled:YES];
                 [sender setTitle:@"关注失败"];
                 [[OWSlideMessageViewController sharedInstance] showMessage:@"关注失败" autoClose:YES];
             }];
}

+ (void)focusMagazine:(LYMagazineTableCellData *)cellData completion:(GLNoneParamBlock)completion fault:(GLNoneParamBlock)fault
{
    NSDictionary *param = @{@"resourceid":cellData.magGUID,
                            @"resourcekind":@(2)};

    [CommonNetworkingManager POST:LONGYUAN_MAGAZINE_FOCUS_API parameters:param completeBlock:^(NSDictionary *result) {
        if (completion) completion();
    } faultBlock:^(NSString *MSG) {
        if (fault) fault();
    }];
}

- (void)disfocusMagazine:(LYMagazineTableCellData *)cellData completion:(GLNoneParamBlock)completion fault:(GLNoneParamBlock)fault
{
    NSDictionary *param = @{@"id":cellData.concernID,
                            @"resourcekind":@(2)};
    __unsafe_unretained LYMagazineManager *weakSelf = self;

    [CommonNetworkingManager POST:LONGYUAN_MAGAZINE_DISFOCUS_API parameters:param completeBlock:^(NSDictionary *result) {
        [weakSelf deleteFocusedMagazine:cellData.magGUID];
        if (completion) completion();
        
    } faultBlock:^(NSString *MSG) {
        if (fault) fault();
    }];
}

- (AFHTTPRequestOperation *)getFocusedMagazineList:(NSInteger)pageIndex
                                   successCallBack:(GLHttpRequstMultiResults)sCallBack
                                    failedCallBack:(GLHttpRequstFault)fCallBack
{
    NSDictionary *params = @{@"resourcekind":@(2),
                             @"pagesize":@(800), @"pageindex":@(1), @"itemcount":@(0)};
    __weak LYMagazineManager *weakSelf = self;
    return [CommonNetworkingManager GET:LONGYUAN_MAGAZINE_FOCUSLIST_API
                             parameters:params
                          completeBlock:^(NSDictionary *result) {
        NSArray *list = [weakSelf excuteCompletionBlock:sCallBack byResult:result];
//        [weakSelf saveMagazine:list];
//        sCallBack([weakSelf getLocalFocusedMagazineList], 1);
        sCallBack(list, 1);
    } faultBlock:^(NSString *msg) {
        if (fCallBack)
            fCallBack(msg);
    }];
}

- (NSArray *)getLocalFocusedMagazineList
{
    __block NSArray *list;
    [cdd.parentMOC performBlockAndWait:^{
        list = [cdd getCoreDataList:@"LYMagazineItem" byPredicate:nil sort:nil];
    }];
    return list;
}

- (void)saveMagazine:(NSArray *)list
{

    [cdd.parentMOC performBlockAndWait:^{
        for (LYMagazineTableCellData *cellData in list) {
            LYMagazineItem *magItem = [NSEntityDescription insertNewObjectForEntityForName:@"LYMagazineItem"
                                                                    inManagedObjectContext:cdd.parentMOC];
            magItem.magGUID = cellData.magGUID;
            magItem.cover = cellData.cover;
            magItem.magIconURL = cellData.magIconURL;
            magItem.magName = cellData.magName;
            if (cellData.issue) {
                magItem.issue = (NSString *)cellData.issue;
            }
            magItem.isUserFocused = @1;
        }
        
        [cdd.parentMOC save:nil];
    }];
}

- (void)deleteFocusedMagazine:(NSString *)magazineGUID
{
    [cdd.parentMOC performBlock:^{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"magGUID=%@",magazineGUID];
        [cdd deleteObjects:@"LYMagazineItem" predicate:predicate sort:nil fetchOffset:0 fetchLimit:0];
    }];
}

+ (void)isFocused:(NSString *)magazineGUID
       completion:(GLNoneParamBlock)completion
            fault:(GLNoneParamBlock)fault
{
    NSDictionary *params = @{@"resourceid":magazineGUID};
    [CommonNetworkingManager GET:MAGAZINE_ISFOCUSED_API parameters:params completeBlock:^(NSDictionary *result) {
        BOOL isFocused = [result[@"Data"][@"IsConcern"] boolValue];
        if (isFocused) {
            completion();
        }
        else {
            fault();
        }
    } faultBlock:^(NSString *msg) {
        fault();
    }];
}

@end
