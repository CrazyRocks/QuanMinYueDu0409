//
//  OWMagazineShelfManager.h
//  LYMagazineService
//
//  Created by grenlight on 14-5-16.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYMagazineInfo.h"
#import "LYGlobalConfig.h"
#import "LYMagazine.h"
#import "LYMagazineCatalogue.h"
#import "LYArticle.h"
#import "LYMagazineTableCellData.h"
#import "CommonNetworkingManager.h"

@class LYCoreDataDelegate, LYMagazineManager;

@interface LYMagazineShelfManager : NSObject
{
    NSMutableSet       *inQueueMags;
    NSOperationQueue   *downloadQueue;

    LYCoreDataDelegate *cdd;
    
    void(^downloadingArticle)();
    
    LYMagazineManager   *magManager;
}
+ (LYMagazineShelfManager *)sharedInstance;

//是否已下载过
- (BOOL)isDownloaded:(LYMagazineInfo *)mag;

//下载
- (void)downloadMagazine:(LYMagazineInfo *)mag;

//所有下载的杂志
- (NSArray *)getAllMagazines;

//删除某本杂志
- (void)deleteMagazine:(LYMagazineTableCellData *)mag;

//杂志目录
- (NSArray *)getMagazineCatalogues:(LYMagazine *)magazine;


//杂志文章
@end
