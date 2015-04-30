//
//  ArticleManager.h
//  LongYuanYueDu
//
//  Created by  iMac001 on 12-10-22.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OWBasicHTTPRequest.h"

@class LYArticle;

@interface LYArticleManager : OWBasicHTTPRequest
{
    @private
    LYArticle                  *currentArticle;

}
+(LYArticleManager *)sharedInstance;

//因为从不同的列表进入文章，权限可能不一样，所以存储文章时，需要存文章类型，
//查询本地库时也需要关联文章类型
-(void)getArticleDetail:(GLParamBlock)sCallBack
                  fault:(GLHttpRequstFault)fCallBack;

-(void)getArticleFormServer:(LYArticleTableCellData *)articleCell
                 completion:(GLParamBlock)sCallBack
                      fault:(GLHttpRequstFault)fCallBack;

-(LYArticle *)getLocalArticleByID:(NSString *)aID;
-(LYArticle *)getLocalArticleByID:(NSString *)aID
                        context:(NSManagedObjectContext *)context;



//当文章被加入收藏后，在文章库里将相应的全文标识为收藏
//收藏的文章不会被自动删除
-(void)setFavorite:(BOOL)bl;

-(LYArticle *)saveArticleToLocal:(NSDictionary *)dic;
-(LYArticle *)saveArticleToLocal:(NSDictionary *)dic
                       context:(NSManagedObjectContext *)context;


//文章是否已读
-(BOOL)alreadyRead:(NSString *)articleID;

@end
