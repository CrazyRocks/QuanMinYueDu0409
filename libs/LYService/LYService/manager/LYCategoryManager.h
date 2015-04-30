//
//  CategoryManager.h
//  LongYuan
//
//  Created by iMac001 on 12-6-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OWBasicHTTPRequest.h"
#import "LYMenuData.h"

@interface LYCategoryManager : OWBasicHTTPRequest
{

}

@property (nonatomic, strong) NSArray *categories;

+ (LYCategoryManager *)sharedInstance;


-(AFHTTPRequestOperation *)getCategoriesFromServer:(LYMenuData *)menu
                                        completion:(GLParamBlock)sCallBack
                                    failedCallBack:(GLHttpRequstFault)fCallBack;

//取得书的分类
- (AFHTTPRequestOperation *)getBookCategoriesFromServer:(LYMenuData *)menu
                                             completion:(GLParamBlock)sCallBack
                 failedCallBack:(GLHttpRequstFault)fCallBack;

//期刊分类
- (AFHTTPRequestOperation *)getMagazineCagegory:(LYMenuData *)menu
                                     completion:(GLParamBlock)sCallBack
                                 failedCallBack:(GLHttpRequstFault)fCallBack;

@end
