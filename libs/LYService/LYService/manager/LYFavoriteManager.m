//
//  FavoriteManager.m
//  LongYuanYueDu
//
//  Created by  iMac001 on 12-10-31.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import "LYFavoriteManager.h"
#import "LYFavorite.h"
#import "LYCoreDataDelegate.h"
#import "LYArticleTableCellData.h"
#import "LYArticleManager.h"
#import "LYMagCatelogueTableCellData.h"
#import "LYUtilityManager.h"

@implementation LYFavoriteManager

- (AFHTTPRequestOperation *)getList:(NSInteger)pageIndex
                    completionBlock:(GLHttpRequstMultiResults)completion
                         faultBlock:(GLHttpRequstFault)fault
{
    NSDictionary *params = @{@"pageindex":@(pageIndex),
                             @"pagesize":@30,
                             @"itemcount":@(0),
                             @"resourcekind":@(100)} ;
    return [CommonNetworkingManager GET:LONGYUAN_FAVORITE_SYNC parameters:params completeBlock:^(NSDictionary *result) {
        NSArray *favorites = result[@"Data"];
        if (![favorites isKindOfClass:[NSArray class]] || favorites.count == 0) {
            completion(nil,0);
            return;
        }
        
        if (pageIndex == 1) {
            [cdd.parentMOC performBlockAndWait:^{
                [cdd deleteObjects:@"LYFavorite"];
                [cdd.parentMOC save:nil];
            }];
        }
        NSArray *list = [self saveFavorites:favorites];
        
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for (LYFavorite *f in list) {
            LYArticleTableCellData *cellData = [self parseFavorite:f];
            [arr addObject:cellData];
        }

        NSInteger pageCount = 1;
        if (result[@"ItemCount"])
            pageCount = ceilf([result[@"ItemCount"] integerValue] / 30.0f);
        
        completion(arr, pageCount);
        
    } faultBlock:^(NSString *message) {
        if (fault)
            fault(message);
        
    }];
}

- (NSArray *)saveFavorites:(NSArray *)favorites
{
    NSMutableArray *list = [NSMutableArray new];
    [cdd.parentMOC performBlockAndWait:^{
        for (NSDictionary *item in favorites) {
            LYFavorite *favorite = [NSEntityDescription insertNewObjectForEntityForName:@"LYFavorite"
                                                                 inManagedObjectContext:cdd.parentMOC];
            favorite.userName = [[NSUserDefaults standardUserDefaults] objectForKey:LONGYUAN_NAME];
            favorite.favoriteID = [item[@"ID"] stringValue];
            favorite.titleID = item[@"ArticleID"];
            favorite.title = item[@"Title"];
            favorite.summary = [LYUtilityManager stringByTrimmingAllSpaces:item[@"Introduction"]];
            favorite.author = item[@"Author"];
            favorite.magGUID = item[@"MagazineGuid"];
            favorite.magName = item[@"MagazineName"];
            favorite.magYear = [item[@"Year"] stringValue];
            favorite.magIssue = [item[@"Issue"] stringValue];
            
            if ([item[@"FirstImg"] isKindOfClass:[NSString class]])
                favorite.thumbnailURL = item[@"FirstImg"];
            
            favorite.kind = item[@"Kind"];
//            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//            [formatter setLenient:YES];
//            favorite.addDate = [formatter dateFromString:[[item objectForKey:@"CreateDate"] isEqualToString:@""] ? @"0" :[item objectForKey:@"CreateDate"]];
            favorite.isAlreadySync = [NSNumber numberWithBool:YES];
            favorite.contentDownloaded = [NSNumber numberWithBool:NO];
            [list addObject:favorite];
        }
        [cdd.parentMOC save:nil];
    }];
    return list;
}

- (LYArticleTableCellData *)parseFavorite:(LYFavorite *)favorite
{
    LYArticleTableCellData *art = [[LYArticleTableCellData alloc] init];
    art.favoriteID = favorite.favoriteID;
    art.titleID = favorite.titleID;
    art.author = favorite.author;
    art.title = favorite.title;
    art.magGUID = favorite.magGUID;
    art.magName = favorite.magName;
    art.summary = favorite.summary;
    art.thumbnailURL = favorite.thumbnailURL;
    art.isEditMode = NO;
    art.willDeleted = NO;
    art.textRect = CGRectMake(10, 10, 300, 90);
    return art;
}

- (void)setArticle:(LYArticleTableCellData *)art toFavorite:(BOOL)bl completion:(GLNoneParamBlock)completion fault:(GLNoneParamBlock)fault
{
    if (bl) {
        [self addFavoriteToServer:art completion:completion fault:fault];
    }
    else {
        [self deleteFavorite:art completion:completion fault:fault];
    }
}

- (BOOL)isFavorite:(LYArticleTableCellData *)art
{
    BOOL isFavorite = NO;
    if (art.titleID) {
        [self isFavorite:&isFavorite article:art completion:nil fault:nil];
    }
    
    return isFavorite;
}

- (NSArray *)getLocalFavorites
{
    __block NSArray *mutableFetchResults;

    [cdd.parentMOC performBlockAndWait:^{
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"addDate" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        
        NSPredicate *predicate;
        predicate = [NSPredicate predicateWithFormat:@"isAlreadyDeleted=%@ and userName=%@",[NSNumber numberWithBool:NO],
                     [[NSUserDefaults standardUserDefaults] objectForKey:LONGYUAN_NAME]];
        
        
        mutableFetchResults =[cdd getCoreDataList:@"LYFavorite"
                                      byPredicate:predicate
                                             sort:sortDescriptors
                                       fetchLimit:0
                                      fetchOffset:0
                                          context:cdd.parentMOC];
    }];

    return mutableFetchResults;

}

- (void)addFavoriteToServer:(LYArticleTableCellData *)article
                 completion:(GLNoneParamBlock)sCallBack
                      fault:(GLNoneParamBlock)fCallBack
{
    NSInteger kind = 103;
    NSString *issue = @"0", *year = @"0";
    
    if ([article isKindOfClass:[LYMagCatelogueTableCellData class]]) {
        kind = 101;
//        issue = ((LYMagCatelogueTableCellData *)article).
    }
    NSDictionary *params = @{@"resourceid":article.titleID,
                             @"resourcekind":@(kind),
                             @"year":year,
                             @"issue":issue};

    __unsafe_unretained LYFavoriteManager *weakSelf = self;
    
    GLParamBlock completion = ^(NSDictionary *result){
        [weakSelf isFavorite:nil article:article completion:sCallBack fault:fCallBack];
    };
    GLHttpRequstFault fault = ^(NSString *message){
        if (fCallBack) fCallBack();
    };
    httpRequest = [CommonNetworkingManager POST:LONGYUAN_ADD_FAVORITE_API parameters:params completeBlock:completion faultBlock:fault];
}

- (void)isFavorite:(BOOL *)isFavorite
           article:(LYArticleTableCellData *)article
        completion:(GLNoneParamBlock)sCallBack
             fault:(GLNoneParamBlock)fCallBack

{
    NSDictionary *params = @{@"resourceid":article.titleID,
                             @"year":@(0),
                             @"issue":@(0)};
    [CommonNetworkingManager sycGET:IS_FAVORITE_API parameters:params completeBlock:^(NSDictionary *result){
        NSNumber *fID = result[@"Data"][@"FavoriteID"] ;
        BOOL f;
        if ([fID integerValue] > 0) {
            article.favoriteID = [fID stringValue];
            f = YES;
        }
        else {
            f = NO;
        }
        
        if (isFavorite) {
            *isFavorite = f;
        }
        
        if (sCallBack)
            sCallBack();
        
    } faultBlock:^(NSString *msg){
        if (isFavorite) {
            *isFavorite = NO;
        }
        if (fCallBack) fCallBack();
    }];
}

+(void)SyncDeleteFavorite:(LYFavorite *)favorite byContext:(NSManagedObjectContext *)context
{
    NSDictionary *params = @{@"id": favorite.titleID};
    
    [CommonNetworkingManager POST:LONGYUAN_DELETE_FAVORITE_API parameters:params completeBlock:^(NSDictionary *result){
        [context performBlock:^{
            [context deleteObject:favorite];
            [context save:nil];
            [[LYCoreDataDelegate sharedInstance].parentMOC performBlock:^{
                [[LYCoreDataDelegate sharedInstance].parentMOC save:nil];
            }];
        }];
    } faultBlock:^(NSString *message){
        
    }];
}


//保存
- (LYFavorite *)saveFavorite:(LYArticleTableCellData *)item favoriteID:(NSString *)favID
{
    __block LYFavorite *favorite;
    [cdd.parentMOC performBlockAndWait:^{
        favorite = [cdd generateManagedObject:[LYFavorite class]];
        favorite.userName = [[NSUserDefaults standardUserDefaults] objectForKey:LONGYUAN_NAME];
        favorite.favoriteID = favID;
        favorite.titleID = item.titleID;
        favorite.thumbnailURL = item.thumbnailURL;
        favorite.title = item.title;
        favorite.summary = item.summary;
        favorite.author = item.author;
        favorite.magName = item.magName;
        
        favorite.magIssue = item.magIssue;
        
        favorite.magGUID  = item.magGUID;
        favorite.magazineIconURL = item.magazineIcon;
        favorite.publishDate = item.publishDate;
        favorite.publishDateFormatString = item.publishDateSection;
        favorite.addDate = [NSDate date];
        favorite.isAlreadySync = [NSNumber numberWithBool:NO];
        favorite.contentDownloaded = [NSNumber numberWithBool:YES];
        
        [cdd saveParentMOC];
    }];
    
    return favorite;
}

//删除收藏
- (void)deleteFavorite:(LYArticleTableCellData *)article
            completion:(GLNoneParamBlock)sCallBack
                 fault:(GLNoneParamBlock)fCallBack
{
    GLHttpRequstResult completion = ^(NSDictionary *result){
        [cdd.parentMOC performBlockAndWait:^{
            NSPredicate *predicate;
            predicate = [NSPredicate predicateWithFormat:@"favoriteID=%@ AND userName=%@",article.favoriteID,
                         [[NSUserDefaults standardUserDefaults] objectForKey:LONGYUAN_NAME]];
            [cdd deleteObjects:@"LYFavorite" predicate:predicate sort:nil fetchOffset:0 fetchLimit:0];
            
            if (sCallBack) sCallBack();
        }];
    
        [[LYArticleManager sharedInstance] setFavorite:NO];
    };
    
    GLHttpRequstFault fault = ^(NSString *message){
        if (fCallBack) fCallBack();
    };
    
    NSDictionary *params = @{@"id": article.favoriteID};
    
    httpRequest = [CommonNetworkingManager POST:LONGYUAN_DELETE_FAVORITE_API parameters:params completeBlock:completion faultBlock:fault];
}

@end
