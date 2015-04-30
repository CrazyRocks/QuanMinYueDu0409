//
//  OWMagazineShelfManager.m
//  LYMagazineService
//
//  Created by grenlight on 14-5-16.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import "LYMagazineShelfManager.h"
#import "LYCoreDataDelegate.h"
#import "LYAccountManager.h"
#import "LYMagazineManager.h"
#import "LYMagCatelogueTableCellData.h"
#import "LYUtilityManager.h"

@implementation LYMagazineShelfManager


+ (LYMagazineShelfManager *)sharedInstance
{
    static LYMagazineShelfManager *instence;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instence = [[LYMagazineShelfManager alloc] init];
        [instence setup];
    });
    return instence;
}

-(void)setup
{
    inQueueMags = [[NSMutableSet alloc] init];
    downloadQueue = [[NSOperationQueue alloc] init];
    downloadQueue.maxConcurrentOperationCount = 1;
    [downloadQueue setSuspended:NO];
    
    cdd = [LYCoreDataDelegate sharedInstance];
    magManager = [[LYMagazineManager alloc] init];
}

-(void)dealloc
{
    [downloadQueue cancelAllOperations];
    [downloadQueue setSuspended:YES ];
}

- (BOOL)isDownloaded:(LYMagazineInfo *)mag
{
    __block NSArray *fetchResult;
    [cdd.parentMOC performBlockAndWait:^{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"magGUID=%@ AND year=%@ AND issue=%@ AND userID=%@", mag.magGUID, mag.year, mag.issue, [LYAccountManager getUserName]];
        fetchResult = [cdd getCoreDataList:@"LYMagazine" byPredicate:predicate sort:nil fetchLimit:1 fetchOffset:0];
    }];
    if (fetchResult && fetchResult.count > 0)
        return YES;
    else
        return NO;
}

- (void)downloadMagazine:(LYMagazineInfo *)mag
{
    NSString *magGUID = [NSString stringWithFormat:@"%@_%@_%@", mag.magGUID, mag.year, mag.issue];
    if ([inQueueMags containsObject:magGUID]) return;
    
    if (![[CommonNetworkingManager sharedInstance] isReachable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"当前没有网络连接，无法完成下载" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    [inQueueMags addObject:magGUID];
    
    NSMutableDictionary *info = [@{@"mag":mag, @"GUID":magGUID} mutableCopy];
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                            selector:@selector(downloadOperation:)
                                                                              object:info];
    
    [downloadQueue addOperation:operation];
    [downloadQueue setSuspended:NO ];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MAG_DOWNLOAD_BEGIN object:nil userInfo:info];
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("MagazineDownload", 0);
    dispatch_group_async(group, queue, ^{
        
    });
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);

}

-(void)downloadOperation:(NSMutableDictionary *)info
{
    GLNoneParamBlock errorBlock = ^{
        [inQueueMags removeObject:info[@"GUID"]];
        [[NSNotificationCenter defaultCenter] postNotificationName:MAG_DOWNLOAD_ERROR object:nil userInfo:info];
    };
    
    void(^progressNotification)(float) = ^(float progress){
        [info setValue:[NSNumber numberWithFloat:progress] forKey:@"progress"];
        [[NSNotificationCenter defaultCenter] postNotificationName:MAG_DOWNLOAD_PROGRESS object:nil userInfo:info];
    };
    LYMagazineInfo *mag = info[@"mag"];
    [magManager getCatelogue:mag completion:^(NSArray *cataloues){
        progressNotification(0.05);

        __block NSMutableArray *articles = [[NSMutableArray alloc] init];
        __block NSInteger index = 0;
        __block NSInteger errorCount = 0;
        
        downloadingArticle = ^{
            LYMagCatelogueTableCellData *cat = cataloues[index];
            [[LYMagazineShelfManager sharedInstance] downloadArticle:cat.titleID magazine:mag complete:^(NSDictionary *article, bool alreadyInDB) {
                errorCount = 0;
                if (!alreadyInDB) {
                    [articles addObject:article];
                    progressNotification(0.05 + 0.95*((float)index/cataloues.count));
                }
                index ++;
                
                if (index < cataloues.count) {
                    [LYMagazineShelfManager sharedInstance] -> downloadingArticle();
                }
                else {
                    //下载成功
                    [[LYMagazineShelfManager sharedInstance] -> cdd.parentMOC performBlockAndWait:^{
                        [[LYMagazineShelfManager sharedInstance] saveMagazine:mag];
                        [[LYMagazineShelfManager sharedInstance] saveCatalogue:cataloues forMag:mag];
                        [[LYMagazineShelfManager sharedInstance] saveArticle:articles forMag:mag];
                    }];
                    progressNotification(1.0f);
                    [[LYMagazineShelfManager sharedInstance]->inQueueMags removeObject:info[@"GUID"]];
                    [[NSNotificationCenter defaultCenter] postNotificationName:MAG_DOWNLOAD_COMPLETE object:nil userInfo:info];
                }
                
            } fault:^{
                errorCount ++;
                //每篇文章下载失败后再尝试2次，还是失败则整个杂志下载失败
                if (errorCount == 3) {
                    [articles removeAllObjects];
                    articles = nil;
                    
                    errorBlock();
                }
                else {
                    [LYMagazineShelfManager sharedInstance] -> downloadingArticle();
                }
            }];
        };
        
        downloadingArticle();
    } fault:^(NSString *msg){
        errorBlock();

    }];

}


- (void)downloadArticle:(NSString *)titleID magazine:(LYMagazineInfo *)mag
               complete:(void(^)(NSDictionary *, bool))completeBlock
                  fault:(void(^)())faultBlock
{
    __block NSArray *fetchResult;
    [cdd.parentMOC performBlockAndWait:^{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"magGUID=%@ AND titleID=%@ AND magYear=%@ AND magIssue=%@", mag.magGUID, titleID, mag.year, mag.issue];
        fetchResult = [cdd getCoreDataList:@"LYArticle" byPredicate:predicate sort:nil fetchLimit:1 fetchOffset:0];
    }];
    
    if (!fetchResult || fetchResult.count == 0) {
        NSDictionary *params =@{@"articleid":titleID};
        [CommonNetworkingManager sycGET:MAGAZINE_ARTICLE_DETAIL_API parameters:params completeBlock:^(NSDictionary *results) {
            completeBlock(results[@"Data"], NO);
        } faultBlock:^(NSString *msg) {
            faultBlock();
        }];
    }
    else {
        completeBlock(nil, YES);
    }
}

- (void)saveMagazine:(LYMagazineInfo *)info
{
    LYMagazine *mag = [NSEntityDescription insertNewObjectForEntityForName:@"LYMagazine"
                                                             inManagedObjectContext:cdd.parentMOC];
    mag.magGUID = info.magGUID;
    mag.magName = info.magazineName;
    mag.cover = info.coverURL;
    mag.year = @([info.year integerValue]);
    mag.issue = @([info.issue integerValue]);
    mag.userID = [LYAccountManager getUserName];
    
    [cdd.parentMOC save:nil];
}

- (void)saveCatalogue:(NSArray *)arr forMag:(LYMagazineInfo *)mag
{
    for (LYMagCatelogueTableCellData *item in arr) {
        LYMagazineCatalogue *cat = [NSEntityDescription insertNewObjectForEntityForName:@"LYMagazineCatalogue"
                                                                 inManagedObjectContext:cdd.parentMOC];
        cat.titleID = item.titleID;
        cat.title = item.title;
        cat.magGUID = mag.magGUID;
        cat.magYear = @([mag.year integerValue]);
        cat.magIssue = @([mag.issue integerValue]);
        cat.column = item.sectionName;
        cat.userID = [LYAccountManager getUserName];
    }
    [cdd.parentMOC save:nil];

}

- (void)saveArticle:(NSArray *)arr forMag:(LYMagazineInfo *)mag
{
    for (NSDictionary *dic in arr) {
        LYArticle *article = [NSEntityDescription insertNewObjectForEntityForName:@"LYArticle"
                                                                   inManagedObjectContext:cdd.parentMOC];
        article.titleID = dic[@"ArticleID"];
        article.magGUID= mag.magGUID;
        article.magYear = @([mag.year integerValue]);
        article.magIssue = @([mag.issue integerValue]);
        article.title = dic[@"Title"];
        article.subTitle = dic[@"SubTitile"];
        article.author = dic[@"Author"];
        article.summary = dic[@"Summary"];
        if (article.summary) {
            article.summary = [LYUtilityManager stringByTrimmingAllSpaces:article.summary];
        }
        article.content = dic[@"Content"];
        article.magIcon = dic[@"IconList"];
        article.magName = mag.magazineName;
        article.webURL = dic[@"WebURL"];
    }
    [cdd.parentMOC save:nil];

}

- (NSArray *)getAllMagazines
{
    __block NSArray *list;
    [cdd.parentMOC performBlockAndWait:^{
        NSPredicate *predicate;
        predicate = [NSPredicate predicateWithFormat:@"userID=%@", [LYAccountManager getUserName]];
        list = [cdd getCoreDataList:@"LYMagazine" byPredicate:predicate sort:nil];
        
    }];
//    NSMutableArray *arr = [[NSMutableArray alloc] init];
//    for (LYMagazine *mag in list) {
//        LYMagazineTableCellData *cellData = [[LYMagazineTableCellData alloc] init];
//        cellData.magGUID = mag.magGUID;
//        cellData.magName = mag.magName;
//        cellData.year = [mag.year stringValue];
//        cellData.issue = [mag.issue stringValue];
//        cellData.cover = mag.cover;
//        [arr addObject:cellData];
//    }
    return list;
}

- (NSArray *)getMagazineCatalogues:(LYMagazine *)mag
{
    __block NSArray *fetchResult;
    [cdd.parentMOC performBlockAndWait:^{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"magGUID=%@ AND magYear=%@ AND magIssue=%@ AND userID=%@", mag.magGUID, mag.year, mag.issue, mag.userID];
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"column" ascending:NO];
        fetchResult = [cdd getCoreDataList:@"LYMagazineCatalogue" byPredicate:predicate sort:@[sortDescriptor] fetchLimit:0 fetchOffset:0];
    }];

    return fetchResult;
}


- (void)deleteMagazine:(LYMagazineTableCellData *)mag
{
    [cdd.parentMOC performBlockAndWait:^{
        NSPredicate *predicate ;
        predicate = [NSPredicate predicateWithFormat:@"magGUID=%@ AND magYear=%@ AND magIssue=%@ AND userID=%@", mag.magGUID, mag.year, mag.issue, [LYAccountManager getUserName]];
        [cdd deleteObjects:@"LYMagazineCatalogue" predicate:predicate sort:nil fetchOffset:0 fetchLimit:0];
        
        predicate = [NSPredicate predicateWithFormat:@"magGUID=%@ AND year=%@ AND issue=%@ AND userID=%@", mag.magGUID, mag.year, mag.issue, [LYAccountManager getUserName]];
        [cdd deleteObjects:@"LYMagazine" predicate:predicate sort:nil fetchOffset:0 fetchLimit:0];

        [cdd.parentMOC save:nil];
    }];
}

@end
