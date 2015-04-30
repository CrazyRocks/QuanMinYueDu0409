//
//  SearchManager.h
//  LongYuanYueDu
//
//  Created by  iMac001 on 12-10-26.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OWBasicHTTPRequest.h"

@interface LYSearchManager : OWBasicHTTPRequest

- (AFHTTPRequestOperation *)searchArticlesByTitle:(NSString *)keywords
                                        pageIndex:(NSInteger)pageindex
                                    countCallBack:(GLHttpRequstResult)countCallBack
                                  successCallBack:(GLHttpRequstMultiResults)sCallBack
                                   failedCallBack:(GLHttpRequstFault)fCallBack;

- (AFHTTPRequestOperation *)searchMagazineByName:(NSString *)keywords
                                       pageIndex:(NSInteger)pageindex
                                   countCallBack:(GLHttpRequstResult)countCallBack
                                 successCallBack:(GLHttpRequstMultiResults)sCallBack
                                  failedCallBack:(GLHttpRequstFault)fCallBack;

- (AFHTTPRequestOperation *)searchBook:(NSString *)keywords
                             pageIndex:(NSInteger)pageindex
                         countCallBack:(GLHttpRequstResult)countCallBack
                       successCallBack:(GLHttpRequstMultiResults)sCallBack
                        failedCallBack:(GLHttpRequstFault)fCallBack;

- (void)getKeys:(GLParamBlock)sCallBack
 failedCallBack:(GLHttpRequstFault)fCallBack;

@end
