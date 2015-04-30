//
//  AutoDownloadManager.h
//  LongYuanYueDu
//
//  Created by  iMac001 on 12-12-17.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OWBasicHTTPRequest.h"

@class LYArticleManager;
@interface LYAutoDownloadManager : OWBasicHTTPRequest
{
    dispatch_queue_t   queue;
    BOOL               canAutoDownload;
    
    //需要下载的收藏
    NSArray                  *needDownloadsFavorites;
    //需要下载的图片
    NSMutableArray           *needDownloadsImages;
        
    //正在下载
    BOOL                      isDownloading;

}
+(LYAutoDownloadManager *)sharedInstance;
-(void)start;

//挂起自动下载
-(void)suspend;
//继续
-(void)resume;

@end
