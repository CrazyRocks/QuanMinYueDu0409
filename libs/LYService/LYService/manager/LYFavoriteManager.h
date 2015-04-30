//
//  FavoriteManager.h
//  LongYuanYueDu
//
//  Created by  iMac001 on 12-10-31.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWBasicHTTPRequest.h"

@class LYFavorite;

@class LYArticleTableCellData;
@interface LYFavoriteManager : OWBasicHTTPRequest
{
    NSManagedObjectContext *fetchContext;
}

- (void)setArticle:(LYArticleTableCellData *)art
        toFavorite:(BOOL)bl
        completion:(GLNoneParamBlock)completion
             fault:(GLNoneParamBlock)fault;

- (BOOL)isFavorite:(LYArticleTableCellData *)art;

- (AFHTTPRequestOperation *)getList:(NSInteger)pageIndex
completionBlock:(GLHttpRequstMultiResults)completion
     faultBlock:(GLHttpRequstFault)fault;

//以同步请求方式，删除服务器收藏且移除本地数据，
+(void)SyncDeleteFavorite:(LYFavorite *)favorite byContext:(NSManagedObjectContext *)context;

- (NSMutableArray *)getLocalFavorites;

@end
