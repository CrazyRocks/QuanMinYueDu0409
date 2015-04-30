//
//  RecommendManager.h
//  LongYuanYueDu
//
//  Created by  iMac001 on 12-10-19.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OWBasicHTTPRequest.h"

@interface LYRecommendManager : OWBasicHTTPRequest
{
    
}

/*
1.先从本地取得已有的旧数据
 根据旧数据里的第一条去请求最新的
 */
- (void)getLocalRecommendList:(NSString *)cid
              successCallBack:(GLParamBlock)sCallBack
               failedCallBack:(GLHttpRequstFault)fCallBack;

/*
 第一，第二页都与本地数据进行比对，如果本地有，则停止存储，直接用本地数据
 本地数据之后再往下翻页，则使用最后一条记录请求
 */
- (void)getRecommendList:(NSString *)cid
              pageIndex:(NSInteger)pageIndex
        successCallBack:(GLHttpRequstMultiResults)sCallBack
         failedCallBack:(GLHttpRequstFault)fCallBack;

+ (LYArticleTableCellData *)parseArticleListItem:(NSDictionary *)dic categoryID:(NSString *)cid;

@end
