//
//  MagazineManager.h
//  LongYuanYueDu
//
//  Created by  iMac001 on 12-10-17.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYMagazineInfo.h"
#import "LYMagazineTableCellData.h"
#import "OWBasicHTTPRequest.h"
#import "LYMagCatelogueTableCellData.h"

@interface LYMagazineManager : OWBasicHTTPRequest

//订阅列表
-(void)getSubscriptionList:(GLHttpRequstMultiResults)sCallBack
            failedCallBack:(GLHttpRequstFault)fCallBack;

//期刊推荐列表，分类列表
-(void)getMagazineList:(NSInteger)pageIndex
            byCategory:(NSString *)cid
       successCallBack:(GLHttpRequstMultiResults)sCallBack
        failedCallBack:(GLHttpRequstFault)fCallBack;

//期刊文章详情
-(AFHTTPRequestOperation *)reqestArticleDetail:(LYMagCatelogueTableCellData *)magCell
                               successCallBack:(GLHttpRequstResult)sCallBack
                                failedCallBack:(GLHttpRequstFault)fCallBack;

//取得本地列表
- (void)getLocalMagazineList:(NSString *)category completion:(GLHttpRequstMultiResults)sCallBack;

-(void)getMagazineCatelogue:(void(^)(NSArray *,LYMagazineInfo *))sCallBack
                      fault:(GLHttpRequstFault)fCallBack;

- (AFHTTPRequestOperation *)getMagazineCatelogue:(LYMagazineTableCellData *)magInfo
                                      completion:(void(^)(NSArray *,LYMagazineInfo *))sCallBack
                                           fault:(GLHttpRequstFault)fCallBack;

- (AFHTTPRequestOperation *)getCatelogue:(LYMagazineInfo *)magInfo
                              completion:(GLHttpRequstResult)sCallBack
                                   fault:(GLHttpRequstFault)fCallBack;

//关注期刊
+ (void)focusMagazine:(LYMagazineTableCellData *)cellData bySender:(id)sender;

+ (void)focusMagazine:(LYMagazineTableCellData *)cellData
           completion:(GLNoneParamBlock)completion
                fault:(GLNoneParamBlock)fault;


//是否被已被关注
+ (void)isFocused:(NSString *)magazineGUID
       completion:(GLNoneParamBlock)completion
            fault:(GLNoneParamBlock)fault;;

//取消关注
- (void)disfocusMagazine:(LYMagazineTableCellData *)cellData
              completion:(GLNoneParamBlock)completion
                   fault:(GLNoneParamBlock)fault;

//关注列表
-(AFHTTPRequestOperation *)getFocusedMagazineList:(NSInteger)pageIndex
              successCallBack:(GLHttpRequstMultiResults)sCallBack
               failedCallBack:(GLHttpRequstFault)fCallBack;

//关注列表
- (NSArray *)getLocalFocusedMagazineList;

+ (LYMagazineTableCellData *)parseMagazineTableCellData:(NSDictionary *)info;

@end
