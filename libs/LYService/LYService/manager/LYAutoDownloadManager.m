//
//  AutoDownloadManager.m
//  LongYuanYueDu
//
//  Created by  iMac001 on 12-12-17.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import "LYAutoDownloadManager.h"
#import "LYFavorite.h"
#import "LYArticle.h"
#import "LYArticleManager.h"

@implementation LYAutoDownloadManager

+(LYAutoDownloadManager *)sharedInstance
{
    static LYAutoDownloadManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LYAutoDownloadManager alloc] init];
    });
    return instance;
}

-(void)dealloc
{
    dispatch_resume(queue);
}

-(void)suspend
{
    if(queue)
    {
        dispatch_suspend(queue);
    }
}

-(void)resume
{
    if(queue)
    {
        dispatch_resume(queue);
    }
}


-(void)autoDownloadSettingChanged
{
    canAutoDownload = [[NSUserDefaults standardUserDefaults] boolForKey:AUTO_DOWNLOAD];
    if (canAutoDownload) {
        [self resume];
        if (!isDownloading) {
            dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
            dispatch_async(globalQueue, ^{
               [self syncArticles];
            });
        }
    }
    else {
        [self suspend];
    }
}
//只自动下载用户最近访问过的3个分类，先下载推荐，再下载其它
//下载收藏的文章
-(void)start
{
    isDownloading = NO;
    needDownloadsImages = [[NSMutableArray alloc] init];
    
    //监听自动下载设置的改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoDownloadSettingChanged) name:AUTO_DOWNLOAD object:nil];
    
    
    queue = dispatch_queue_create("com.qikan.autoDownload",NULL);
    [self suspend];
    
    [self autoDownloadSettingChanged];

}

-(void)syncArticles
{
    isDownloading = YES;
    
    [cdd.parentMOC performBlockAndWait:^{
        NSPredicate  *predicate = [NSPredicate predicateWithFormat:@"userName=%@",[[NSUserDefaults standardUserDefaults] objectForKey:LONGYUAN_NAME]];
        
        needDownloadsFavorites = [cdd getCoreDataList:@"LYFavorite"
                                          byPredicate:predicate
                                                 sort:nil];
    }];

    if (needDownloadsFavorites && needDownloadsFavorites.count > 0) {
        for (LYFavorite *fav in needDownloadsFavorites) {
            [self requestArticleFromServer:fav];
        }
    }
    isDownloading = NO;
}

-(void)requestArticleFromServer:(LYFavorite *)fav
{
    id article = [[LYArticleManager sharedInstance] getLocalArticleByID:fav.titleID
                                                              context:cdd.parentMOC];
    if(article) return;
    
    NSDictionary *params = @{@"articleid":fav.titleID};;
    
    httpRequest = [CommonNetworkingManager GET:LONGYUAN_ARTICLEDETAIL_API parameters:params completeBlock:^(NSDictionary *result){
        LYArticle *art = [[LYArticleManager sharedInstance] saveArticleToLocal:result
                                                                       context:cdd.parentMOC];
        fav.contentDownloaded = [NSNumber numberWithBool:YES];
        //下载图片
        for (NSString *url in art.images) {
//            [imageManager getImageByURLString:url delegate:nil];
        }
    } faultBlock:^(NSString *msg) {
        
    }];
   
}


@end
