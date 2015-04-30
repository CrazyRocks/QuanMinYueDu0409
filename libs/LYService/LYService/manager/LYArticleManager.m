//
//  ArticleManager.m
//  LongYuanYueDu
//
//  Created by  iMac001 on 12-10-22.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import "LYArticleManager.h"
#import "LYArticle.h"
#import "LYCoreDataDelegate.h"
#import "LYArticleTableCellData.h"
#import "LYUserEvent.h"
#import "LYMagCatelogueTableCellData.h"
#import "LYUtilityManager.h"

@implementation LYArticleManager

static LYArticleManager *instance;

+(LYArticleManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LYArticleManager alloc] init];
    });
    return instance;
}

- (id)init
{
    if ((self = [super init])) {
    }
    return self;
}


-(void)getArticleDetail:(GLParamBlock)sCallBack
         fault:(GLHttpRequstFault)fCallBack
{
    id articleCell = [CommonNetworkingManager sharedInstance].getCurrentArticle;
    NSString *titleID = ((LYArticleTableCellData *)articleCell).titleID;
    
    LYArticle *art = [self getLocalArticleByID:titleID];
    if (art) {
        currentArticle = art;
        if(sCallBack) sCallBack(art);
    }
    else {
        //设置文章已读
        [self setArticleAlreadyRead:titleID];
        
        [self getArticleFormServer:articleCell completion:sCallBack fault:fCallBack];
    }
}

-(void)getArticleFormServer:(id)articleCell
                   completion:(GLParamBlock)sCallBack
                     fault:(GLHttpRequstFault)fCallBack
{
    
    [httpRequest cancel];
    
    NSString *titleID = ((LYArticleTableCellData *)articleCell).titleID;

    NSString *urlString;
    if ([articleCell isKindOfClass:[LYMagCatelogueTableCellData class]]) {
        urlString = MAGAZINE_ARTICLE_DETAIL_API;
    }
    else {
        urlString = LONGYUAN_ARTICLEDETAIL_API;
    }
    __weak LYArticleManager *weakSelf = self;

    completionBlock = ^(NSDictionary *result) {
        __block LYArticle *art = [weakSelf saveArticleToLocal:result[@"Data"]];
        [weakSelf setCurrentArticle:art completion:sCallBack];
    };
    faultBlock = ^(NSString *message) {
        if(fCallBack) fCallBack(message);
    };
    NSDictionary *params = @{@"articleid":titleID};;
    
    httpRequest = [CommonNetworkingManager GET:urlString parameters:params completeBlock:completionBlock faultBlock:faultBlock];

}

- (void)setCurrentArticle:(LYArticle *)art completion:(GLParamBlock)completion
{
    currentArticle = art;
    if(completion) completion(currentArticle);
}

-(void)setFavorite:(BOOL)bl
{
    [cdd.parentMOC performBlockAndWait:^{
        currentArticle.isFavorite = [NSNumber numberWithBool:bl];
        [cdd.parentMOC save:nil];
    }];
}

//保存文章到本地
-(LYArticle *)saveArticleToLocal:(NSDictionary *)dic
{
    return [self saveArticleToLocal:dic  context:cdd.parentMOC];
}

-(LYArticle *)saveArticleToLocal:(NSDictionary *)dic
                       context:(NSManagedObjectContext *)context
{
    __block LYArticle *art;
    art = [self getLocalArticleByID:dic[@"ArticleID"]  context:context];
    if (!art)
        [self createArticle:&art info:dic context:context];
    
    [context performBlockAndWait:^{
        art.content = dic[@"Content"];
        
        if (dic[@"IsRead"]) {
            BOOL canRead = [(NSNumber *)dic[@"IsRead"] boolValue];
            art.canRead = [NSNumber numberWithBool:canRead];
        }
        art.accessTime = [NSDate date];
        
        [context save:nil];
        [cdd saveParentMOC];
    }];
    
    return art;
}

- (void)createArticle:(LYArticle **)art_p
                 info:(NSDictionary *)dic
              context:(NSManagedObjectContext *)context
{
    [context performBlockAndWait:^{
        *art_p  = [NSEntityDescription insertNewObjectForEntityForName:@"LYArticle"
                                                inManagedObjectContext:context];
        (*art_p).titleID = [dic objectForKey:@"ArticleID"];
        (*art_p).categoryID = [[CommonNetworkingManager sharedInstance] recommendCategoryID];
        id title = dic[@"Title"];
        if (title && [title isKindOfClass:[NSString class]]) {
            (*art_p).title = title;
        }
        id SubTitle = dic[@"SubTitle"];
        if (SubTitle && [SubTitle isKindOfClass:[NSString class]]) {
            (*art_p).subTitle = SubTitle;
        }
        id Author = dic[@"Author"];
        if (Author && [Author isKindOfClass:[NSString class]]) {
            (*art_p).author = Author;
        }
        id Introduction = dic[@"Introduction"];
        if (Introduction && [Introduction isKindOfClass:[NSString class]]) {
            (*art_p).summary = [LYUtilityManager stringByTrimmingAllSpaces:Introduction];
        }
//        if (!(*art_p).summary && dic[@"Summary"]) {
//            id summary = dic[@"Summary"];
//            (*art_p).summary = [LYUtilityManager stringByTrimmingAllSpaces:summary];
//        }
        (*art_p).isFavorite = [NSNumber numberWithBool:NO];
        
        NSMutableArray *images = [NSMutableArray new];
        if ([dic[@"BigImgName"] isKindOfClass:[NSString class]]) {
            [images addObject:dic[@"BigImgName"]];
        }
        if ([dic[@"SmallImgName"] isKindOfClass:[NSString class]]) {
            [images addObject:dic[@"SmallImgName"]];
        }
        
        (*art_p).images = images;
       
    }];
}

//从本地库取得文章
-(LYArticle *)getLocalArticleByID:(NSString *)aID
{
    return [self getLocalArticleByID:aID context:cdd.parentMOC];
}

- (LYArticle *)getLocalArticleByID:(NSString *)aID context:(NSManagedObjectContext *)context
{
    __block     LYArticle *art;
    [context performBlockAndWait:^{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"titleID=%@",aID];
        NSArray *fetchResults;
        fetchResults =[cdd getCoreDataList:@"LYArticle"
                               byPredicate:predicate
                                      sort:nil
                                fetchLimit:1
                               fetchOffset:0
                                   context:context];
        
        if(!fetchResults ||fetchResults.count == 0)
            art = nil;
        else {
            art = fetchResults[0];
            //更新访问时间
            art.accessTime = [NSDate date];
        }
    }];
    
    return art;
}


-(BOOL)alreadyRead:(NSString *)articleID
{
    __block BOOL alreadyRead;
    [cdd.parentMOC performBlockAndWait:^{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cID=%@",articleID];
        NSArray *mutableFetchResults;
        mutableFetchResults =[cdd getCoreDataList:@"LYUserEvent"
                                      byPredicate:predicate
                                             sort:nil
                                       fetchLimit:1
                                      fetchOffset:0
                                          context:cdd.parentMOC];
        
        if(!mutableFetchResults ||mutableFetchResults.count == 0)
            alreadyRead = NO;
        else 
            alreadyRead = YES;
 
    }];
    return alreadyRead;
}

-(void)setArticleAlreadyRead:(NSString *)articleID
{
    [cdd.parentMOC performBlock:^{
        LYUserEvent *event  = [NSEntityDescription insertNewObjectForEntityForName:@"LYUserEvent"
                                                          inManagedObjectContext:cdd.parentMOC];
        event.cID = articleID;
        event.operationTime = [NSDate date];
        
        [self deleteUserEvents];
    }];
}

//清除已读记录
-(void)deleteUserEvents
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"operationTime" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [cdd deleteObjects:@"LYUserEvent" predicate:nil sort:sortDescriptors fetchOffset:1000 fetchLimit:0];
}

@end
