//
//  SyncManager.m
//  LongYuanYueDu
//
//  Created by  iMac001 on 12-12-20.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import "LYSyncManager.h"
#import "LYFavorite.h"
#import "LYAutoDownloadManager.h"
#import "LYFavoriteManager.h"

@implementation LYSyncManager

+(LYSyncManager *)sharedInstance
{
    static LYSyncManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LYSyncManager alloc] init];
        instance->alreadySync = NO;
    });
    return instance;
}

-(void)dealloc
{
    dispatch_resume(queue);
}

-(void)startSync
{
    if (alreadySync)
        return;
    
    alreadySync = YES;
    
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(globalQueue, ^{
        
//        //从服务器分页获取本地没有的收藏项
//        [self getFavoritesFromServer:1];
//
//        //自动下载收藏的文章
//        [[LYAutoDownloadManager sharedInstance] start];
        
    });
}

//获取需要删除的收藏
- (NSArray *)getNeedDeleteFavorites
{
    NSPredicate  *predicate = [NSPredicate predicateWithFormat:@"userName=%@ AND isAlreadyDeleted=%@",
                               [[NSUserDefaults standardUserDefaults] objectForKey:LONGYUAN_NAME],
                               [NSNumber numberWithBool:YES]];
    return [self getFavoritesByPredicate:predicate];
}

//获取本地需要同步到服务器的收藏
-(NSArray *)getNeedAyncFavorites
{
    NSPredicate  *predicate = [NSPredicate predicateWithFormat:@"userName=%@ AND isAlreadySync=%@",
                               [[NSUserDefaults standardUserDefaults] objectForKey:LONGYUAN_NAME],
                               [NSNumber numberWithBool:NO]];
    return [self getFavoritesByPredicate:predicate];
}

-(NSArray *)getFavoritesByPredicate:(NSPredicate *)predicate
{
    __block NSArray *fetchResults;
    [cdd.parentMOC performBlockAndWait:^{
        fetchResults =[cdd getCoreDataList:@"LYFavorite"
                               byPredicate:predicate
                                      sort:nil];
    }];
   
    return fetchResults;
}

-(void)getLocalFavoriteAritcleIDs
{
    NSArray *fetchResults;
    NSPredicate  *predicate = [NSPredicate predicateWithFormat:@"userName=%@ AND isAlreadyDeleted=%@",
                               [[NSUserDefaults standardUserDefaults] objectForKey:LONGYUAN_NAME],
                               [NSNumber numberWithBool:NO]];
    fetchResults = [self getFavoritesByPredicate:predicate];
    
    [titleIDs appendString:@""];
    NSInteger i = 0;
    for (LYFavorite *fav in fetchResults) {
        if(i>0)
        {
            [titleIDs appendString:@"|"];
        }
        [titleIDs appendString:fav.titleID];
        i++;
    }
}

- (void)getFavoritesFromServer:(uint)pageIndex
{
}
@end
